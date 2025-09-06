"use client";
import { useState, useEffect } from "react";
import OrderCard from "../components/OrderCard";
import OrderMap from "../components/OrderMap";
import Notifications from "../components/Notifications";
import { formatTime, formatDate } from "../utils/helpers";
import { useOrders } from "@/hooks/useOrder";
import { useAuth } from "@/hooks/useAuth";

export default function Dashboard() {
  const [driverLocation, setDriverLocation] = useState({
    lat: 6.9271,
    lng: 79.8612,
  });
  const [notifications, setNotifications] = useState([]);
  const [isLoading, setIsLoading] = useState(false);

  const {
    orders,
    availableOrders,
    fetchAvailableOrdersDriver,
    updateOrderStatus,
  } = useOrders();
  const { user } = useAuth();

  const assignedActiveOrders = orders.filter(
    (order) => order.driverId === user?.id && order.status === "PICKED_UP"
  );
  const completedOrders = orders.filter(
    (order) => order.driverId === user?.id && order.status === "DELIVERED"
  );

  // fetch orders initially
  useEffect(() => {
    const loadOrders = async () => {
      try {
        setIsLoading(true);
        await fetchAvailableOrdersDriver();
      } catch (error) {
        console.error("Error loading orders:", error);
      } finally {
        setIsLoading(false);
      }
    };
    loadOrders();
  }, []);

  const handleAcceptOrder = async (orderId) => {
    if (assignedActiveOrders.length > 0) {
      alert("You already have an active order. Complete it before accepting a new one.");
      return;
    }
    try {
      await updateOrderStatus(orderId, "PICKED_UP");
    } catch (error) {
      console.error("Error accepting order:", error);
    }
  };

  const handleDeliverOrder = async (orderId) => {
    try {
      await updateOrderStatus(orderId, "DELIVERED");
    } catch (error) {
      console.error("Error delivering order:", error);
    }
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Driver Dashboard</h1>
        <div className="text-sm text-gray-500">Today is {formatDate(new Date())}</div>
      </div>

      <Notifications notifications={notifications} setNotifications={setNotifications} />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
        {/* Available Orders */}
        <div className="bg-white rounded-lg shadow p-4">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-bold text-gray-800">Available Orders</h2>
            <span className="bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded">
              {availableOrders.length} orders
            </span>
          </div>
          <div className="space-y-4 h-80 overflow-y-scroll">
            {availableOrders.length > 0 ? (
              availableOrders
                .filter((order) => order.status === "READY_FOR_PICKUP")
                .slice()
                .sort((a, b) => b.id - a.id)
                .map((order) => (
                  <OrderCard
                    key={order.id}
                    order={order}
                    type="available"
                    onAction={() => handleAcceptOrder(order.id)}
                    disabled={assignedActiveOrders.length > 0} // disable if driver has active orders
                  />
                ))
            ) : (
              <p className="text-gray-500 text-center py-4">No available orders</p>
            )}
          </div>
        </div>

        {/* Active Orders */}
        <div className="bg-white rounded-lg shadow p-4">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-bold text-gray-800">Active Orders</h2>
            <span className="bg-yellow-100 text-yellow-800 text-xs px-2 py-1 rounded">
              {assignedActiveOrders.length} orders
            </span>
          </div>
          <div className="space-y-4 h-80 overflow-y-scroll">
            {assignedActiveOrders.length > 0 ? (
              assignedActiveOrders
                .slice()
                .sort((a, b) => b.id - a.id)
                .map((order) => (
                  <OrderCard
                    key={order.id}
                    order={order}
                    type="active"
                    onAction={() => handleDeliverOrder(order.id)}
                  />
                ))
            ) : (
              <p className="text-gray-500 text-center py-4">No active orders</p>
            )}
          </div>
        </div>

        {/* Map Section */}
        <div className="bg-white rounded-lg shadow p-4">
          <h2 className="text-xl font-bold text-gray-800 mb-4">Delivery Map</h2>
          <div className="h-96 rounded-lg overflow-hidden">
            <OrderMap driverLocation={driverLocation} orders={[...availableOrders, ...assignedActiveOrders]} />
          </div>
        </div>
      </div>

      {/* Completed Orders */}
      <div className="bg-white rounded-lg shadow p-4 mb-6">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-bold text-gray-800">Recently Completed</h2>
          <span className="bg-green-100 text-green-800 text-xs px-2 py-1 rounded">
            {completedOrders.length} orders
          </span>
        </div>

        <div className="overflow-x-auto h-80 overflow-y-scroll">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Order ID
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Customer
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Description
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Location
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {completedOrders
                .slice()
                .sort((a, b) => b.id - a.id)
                .slice(0, 6)
                .map((order) => (
                  <tr key={order.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3 whitespace-nowrap text-sm font-medium text-gray-900">
                      #{order.id}
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500">
                      {order.customerId}
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-900">{order.description}</td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500">{order.customerLocation.address}</td>
                  </tr>
                ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
