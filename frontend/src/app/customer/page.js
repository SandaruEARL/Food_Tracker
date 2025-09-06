"use client";
import React, { useState } from "react";
import { FaShoppingCart } from "react-icons/fa";
import "../globals.css";
import { useOrders } from "@/hooks/useOrder";
import { useAuth } from "@/hooks/useAuth"; // adjust path if needed

export default function CustomerDashboard() {
  const { user, logout } = useAuth(); // get user from auth hook
  const [cart, setCart] = useState([]);
  const [orderDetails, setOrderDetails] = useState({
    description: "",
    lat: "",
    lng: "",
    address: "",
  });
  const [view, setView] = useState("cart");

  const { orders, loading, createOrder } = useOrders();

  console.log("Orders:", orders);

  const placeOrder = async () => {
    if (
      !orderDetails.description ||
      !orderDetails.lat ||
      !orderDetails.lng ||
      !orderDetails.address
    ) {
      alert("Please fill all order details.");
      return;
    }

    const newOrderData = {
      description: orderDetails.description,
      customerLocation: {
        lat: parseFloat(orderDetails.lat),
        lng: parseFloat(orderDetails.lng),
        address: orderDetails.address,
      },
    };

    await createOrder(newOrderData);
    setCart([]);
    setOrderDetails({ description: "", lat: "", lng: "", address: "" });
    setView("orders");
  };

  const handleLogout = () => {
    logout();
    window.location.href = "/";
  };

  if (!user) {
    return <p>Loading user...</p>;
  }

  return (
    <div className="min-h-screen bg-gray-100 p-6 bg-gradient-to-b from-sky-300 to-sky-100">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Welcome, {user.name}</h1>
        <div className="flex gap-3 items-center">
          <button
            onClick={() => setView("orders")}
            className="bg-yellow-600 text-white px-4 py-2 rounded-3xl"
          >
            Orders
          </button>
          <button
            onClick={() => setView("cart")}
            className="relative bg-white p-2 rounded-full shadow-md"
          >
            <FaShoppingCart className="text-xl text-sky-900" />
            <span className="absolute -top-1 -right-1 bg-red-600 text-white rounded-full px-1 text-xs">
              {cart.length}
            </span>
          </button>
          <button
            onClick={handleLogout}
            className="bg-sky-900 text-white px-4 py-2 rounded-3xl"
          >
            Logout
          </button>
        </div>
      </div>

      {view === "cart" && (
        <div>
          <h2 className="text-lg font-bold mb-4">Your Cart</h2>
          {cart.length === 0 ? (
            <p>Your cart is empty.</p>
          ) : (
            cart.map((item, index) => (
              <div
                key={index}
                className="flex justify-between bg-white p-3 rounded mb-2"
              >
                <p>{item.name}</p>
                <p>Rs {item.price}</p>
              </div>
            ))
          )}

          <div className="mt-6">
            <h2 className="text-lg font-bold mb-4">Order Details</h2>
            <input
              type="text"
              placeholder="Order Description"
              value={orderDetails.description}
              onChange={(e) =>
                setOrderDetails({
                  ...orderDetails,
                  description: e.target.value,
                })
              }
              className="border p-2 w-full mb-2 rounded"
            />
            <input
              type="number"
              placeholder="Latitude"
              value={orderDetails.lat}
              onChange={(e) =>
                setOrderDetails({ ...orderDetails, lat: e.target.value })
              }
              className="border p-2 w-full mb-2 rounded"
            />
            <input
              type="number"
              placeholder="Longitude"
              value={orderDetails.lng}
              onChange={(e) =>
                setOrderDetails({ ...orderDetails, lng: e.target.value })
              }
              className="border p-2 w-full mb-2 rounded"
            />
            <input
              type="text"
              placeholder="Address"
              value={orderDetails.address}
              onChange={(e) =>
                setOrderDetails({ ...orderDetails, address: e.target.value })
              }
              className="border p-2 w-full mb-4 rounded"
            />
            <button
              onClick={placeOrder}
              className="bg-green-600 text-white px-4 py-2 rounded"
            >
              Place Order
            </button>
          </div>
        </div>
      )}

      {view === "orders" && (
        <div>
          <h2 className="text-lg font-bold mb-4">Your Orders</h2>
          {loading && <p>Loading orders...</p>}
          {!loading && orders.length === 0 && <p>No orders yet.</p>}
          {orders
            .slice()
            .sort((a, b) => b.id - a.id)
            .map((order) => (
              <div key={order.id} className="bg-white p-4 rounded mb-4">
                <p className="font-semibold">Order #{order.id}</p>
                <p>{order.description}</p>
                <p>Status: {order.status}</p>

                {/* Show driver location only if order is PICKED_UP */}
                {order.status === "PICKED_UP" &&
                  order.driverLat !== undefined &&
                  order.driverLng !== undefined && (
                    <p>
                      Driver Location: {order.driverLat.toFixed(6)},{" "}
                      {order.driverLng.toFixed(6)}
                    </p>
                  )}
              </div>
            ))}
        </div>
      )}
    </div>
  );
}
