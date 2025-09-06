"use client";

import { useEffect, useState, useRef } from "react";
import { API_BASE_URL } from "./api";
import { useAuth } from "./useAuth";
import SockJS from "sockjs-client";
import { Client } from "@stomp/stompjs";

export const useOrders = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(false);
  const [availableOrders, setAvailableOrders] = useState([]);
  const { user } = useAuth();
  const [stompClient, setStompClient] = useState(null);
  const locationWatcherRef = useRef(null);

  const getAuthHeaders = () => {
    const storedUser = localStorage.getItem("user");
    const token = storedUser ? JSON.parse(storedUser)?.token : null;
    return {
      "Content-Type": "application/json",
      ...(token && { Authorization: `Bearer ${token}` }),
    };
  };

  // Fetch Orders
  const fetchOrders = async () => {
    setLoading(true);
    try {
      const response = await fetch(`${API_BASE_URL}/api/order/getrelavant`, {
        headers: getAuthHeaders(),
      });
      if (!response.ok) throw new Error("Failed to fetch orders");
      const data = await response.json();
      setOrders(data);
    } catch (error) {
      console.error("Fetch orders error:", error);
    } finally {
      setLoading(false);
    }
  };

  const fetchAvailableOrdersRestaurant = async () => {
    try {
      const response = await fetch(
        `${API_BASE_URL}/api/order/available/restaurant`,
        { headers: getAuthHeaders() }
      );
      if (!response.ok) throw new Error("Failed to fetch available orders");
      const data = await response.json();
      setAvailableOrders(data);
    } catch (error) {
      console.error("Fetch available orders error:", error);
    }
  };

  const fetchAvailableOrdersDriver = async () => {
    try {
      const response = await fetch(
        `${API_BASE_URL}/api/order/available/driver`,
        { headers: getAuthHeaders() }
      );
      if (!response.ok) throw new Error("Failed to fetch available orders");
      const data = await response.json();
      setAvailableOrders(data);
    } catch (error) {
      console.error("Fetch available orders error:", error);
    }
  };

  // Create Order
  const createOrder = async (orderData) => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/order/place`, {
        method: "POST",
        headers: getAuthHeaders(),
        body: JSON.stringify(orderData),
      });
      if (!response.ok) throw new Error("Failed to create order");
      const newOrder = await response.json();
      setOrders((prev) => [...prev, newOrder]);
      return newOrder;
    } catch (error) {
      console.error("Create order error:", error);
    }
  };

  // Start sending driver location
  const startSendingDriverLocation = (orderId) => {
    if (!navigator.geolocation) {
      alert("Geolocation not supported");
      return;
    }
  
    stopSendingDriverLocation(); 
  
    // REAL LOCATION
    // locationWatcherRef.current = navigator.geolocation.watchPosition(
    //   (position) => {
    //     if (stompClient && stompClient.connected) {
    //       stompClient.publish({
    //         destination: "/app/driverLocation",
    //         body: JSON.stringify({
    //           orderId,
    //           lat: position.coords.latitude,
    //           lng: position.coords.longitude,
    //         }),
    //       });
    //     }
    //   },
    //   (err) => console.error(err),
    //   { enableHighAccuracy: true, maximumAge: 10000 }
    // );
  

    //DUMMY LOCATION
    
    let dummyLat = 6.9271;
    let dummyLng = 79.8612;
    locationWatcherRef.current = setInterval(() => {
      if (stompClient && stompClient.connected) {
        stompClient.publish({
          destination: "/app/driverLocation",
          body: JSON.stringify({
            orderId,
            lat: dummyLat,
            lng: dummyLng,
          }),
        });
      }
  
     
      dummyLat += 0.0001;
      dummyLng += 0.0001;
    }, 3000); 
    
  };
  



const stopSendingDriverLocation = () => {
  if (locationWatcherRef.current !== null) {

    if (navigator.geolocation && navigator.geolocation.clearWatch) {
      navigator.geolocation.clearWatch(locationWatcherRef.current);
    }
    clearInterval(locationWatcherRef.current);
    locationWatcherRef.current = null;
  }
};


  // Update Order Status
  const updateOrderStatus = async (orderId, status) => {
    try {
      const response = await fetch(
        `${API_BASE_URL}/api/order/${orderId}/changestatus`,
        {
          method: "PUT",
          headers: getAuthHeaders(),
          body: JSON.stringify({ status }),
        }
      );
      if (!response.ok) throw new Error("Failed to update order status");
      const updatedOrder = await response.json();

      setOrders((prev) =>
        prev.map((order) => (order.id === orderId ? updatedOrder : order))
      );
      setAvailableOrders((prev) =>
        prev.filter((order) => order.id !== orderId)
      );

      if (user.type.toUpperCase() === "DRIVER" && status === "PICKED_UP" && stompClient) {
        startSendingDriverLocation(orderId);
      }

      if (user.type.toUpperCase() === "DRIVER" && status === "DELIVERED") {
        stopSendingDriverLocation();
      }

      return updatedOrder;
    } catch (error) {
      console.error("Update order status error:", error);
    }
  };

  // WebSocket
  useEffect(() => {
    if (!user) return;

    const role = user.type.toUpperCase();
    const userId = user.id;
    console.log("user id", userId);

    const client = new Client({
      webSocketFactory: () => new SockJS(`${API_BASE_URL}/ws`),
      reconnectDelay: 5000,
      heartbeatIncoming: 4000,
      heartbeatOutgoing: 4000,
      onConnect: () => {
        console.log(`Connected to WebSocket as role: ${role}`);

 
        if (role === "CUSTOMER") {
          client.subscribe(`/topic/orders/CUSTOMER/${userId}`, (message) => {
            if (!message.body) return;
            const updatedOrder = JSON.parse(message.body);
            setOrders((prev) => {
              const index = prev.findIndex((o) => o.id === updatedOrder.id);
              if (index !== -1) {
                const newOrders = [...prev];
                newOrders[index] = { ...newOrders[index], ...updatedOrder };
                return newOrders;
              } else {
                return [...prev, updatedOrder];
              }
            });
          });

          client.subscribe(`/topic/orders/CUSTOMER/location/${userId}`, (message) => {
            if (!message.body) return;
            const locationUpdate = JSON.parse(message.body);
            console.log("Location update received:", locationUpdate);
            setOrders((prev) => {
              const index = prev.findIndex((o) => o.id === locationUpdate.orderId);
              if (index !== -1) {
                const newOrders = [...prev];
                newOrders[index] = {
                  ...newOrders[index],
                  driverLat: locationUpdate.lat,
                  driverLng: locationUpdate.lng,
                };
                return newOrders;
              }
              return prev;
            });
          });
        } 

        else if (role === "RESTAURANT") {
          client.subscribe(`/topic/orders/RESTAURANT`, (message) => {
            if (!message.body) return;
            const updatedOrder = JSON.parse(message.body);

            if (updatedOrder.status === "NEW") {
              setAvailableOrders((prev) => {
                const index = prev.findIndex((o) => o.id === updatedOrder.id);
                if (index !== -1) {
                  const newOrders = [...prev];
                  newOrders[index] = { ...newOrders[index], ...updatedOrder };
                  return newOrders;
                } else {
                  return [...prev, updatedOrder];
                }
              });
            } else if (updatedOrder.restaurantId === userId) {
              setOrders((prev) => {
                const index = prev.findIndex((o) => o.id === updatedOrder.id);
                if (index !== -1) {
                  const newOrders = [...prev];
                  newOrders[index] = { ...newOrders[index], ...updatedOrder };
                  return newOrders;
                } else {
                  return [...prev, updatedOrder];
                }
              });
            }
          });
        } else if (role === "DRIVER") {
          client.subscribe(`/topic/orders/DRIVER`, (message) => {
            if (!message.body) return;
            const updatedOrder = JSON.parse(message.body);

            if (updatedOrder.status === "READY_FOR_PICKUP") {
              setAvailableOrders((prev) => {
                const index = prev.findIndex((o) => o.id === updatedOrder.id);
                if (index !== -1) {
                  const newOrders = [...prev];
                  newOrders[index] = { ...newOrders[index], ...updatedOrder };
                  return newOrders;
                } else {
                  return [...prev, updatedOrder];
                }
              });
            } else if (updatedOrder.driverId === userId) {
              setOrders((prev) => {
                const index = prev.findIndex((o) => o.id === updatedOrder.id);
                if (index !== -1) {
                  const newOrders = [...prev];
                  newOrders[index] = { ...newOrders[index], ...updatedOrder };
                  return newOrders;
                } else {
                  return [...prev, updatedOrder];
                }
              });
            }
          });
        }
      },
      onStompError: (frame) => {
        console.error("Broker reported error: " + frame.headers["message"], frame.body);
      },
    });

    client.activate();
    setStompClient(client);

    return () => {
      stopSendingDriverLocation();
      if (client.active) client.deactivate();
    };
  }, [user]);

  useEffect(() => {
    fetchOrders();
  }, []);

  return {
    orders,
    availableOrders,
    loading,
    fetchOrders,
    fetchAvailableOrdersDriver,
    fetchAvailableOrdersRestaurant,
    createOrder,
    updateOrderStatus,
    startSendingDriverLocation,
    stopSendingDriverLocation,
  };
};
