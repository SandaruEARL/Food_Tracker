"use client";

const OrdersTable = ({ availableOrders, orders, updateOrderStatus }) => {
  const handleMarkPreparing = async (orderId) => {
    await updateOrderStatus(orderId, "PREPARING");
  };
  const handleMarkReady = async (orderId) => {
    await updateOrderStatus(orderId, "READY_FOR_PICKUP");
  };

  const statusColors = {
    NEW: "bg-blue-100 text-blue-800",
    PREPARING: "bg-yellow-100 text-yellow-800",
    READY_FOR_PICKUP: "bg-green-100 text-green-800",
    Completed: "bg-gray-100 text-gray-800",
  };

  return (
    <div className="space-y-8">
      <div className="bg-white p-4 rounded-lg shadow-md">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-bold">Available Orders</h2>
          <div className="flex space-x-2">
            <input
              type="text"
              placeholder="Search orders..."
              className="border rounded px-3 py-1 text-sm"
            />
            <button className="bg-gray-200 hover:bg-gray-300 px-3 py-1 rounded text-sm">
              Filter
            </button>
          </div>
        </div>

        <div className="overflow-x-auto h-80 overflow-y-scroll">
          <table className="min-w-full">
            <thead>
              <tr className="bg-gray-100">
                <th className="text-left py-2 px-3">Order ID</th>
                <th className="text-left py-2 px-3">Customer</th>
                <th className="text-left py-2 px-3">Items</th>
                <th className="text-left py-2 px-3">Address</th>
                <th className="text-left py-2 px-3">Status</th>
                <th className="text-left py-2 px-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {availableOrders
                .filter((order) => order.status === "NEW")
                .slice()
                .sort((a, b) => b.id - a.id)
                .map((order) => (
                  <tr key={order.id} className="border-b hover:bg-gray-50">
                    <td className="py-3 px-3 font-medium">#{order.id}</td>
                    <td className="py-3 px-3">Customer {order.customerId}</td>
                    <td className="py-3 px-3">{order.description}</td>
                    <td className="py-3 px-3">
                      {order.customerLocation?.address}
                    </td>
                    <td className="py-3 px-3">
                      <span
                        className={`px-2 py-1 rounded text-xs ${
                          statusColors[order.status]
                        }`}
                      >
                        {order.status}
                      </span>
                    </td>
                    <td className="py-3 px-3">
                      {order.status === "NEW" && (
                        <button
                          onClick={() => handleMarkPreparing(order.id)}
                          className="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-sm mr-2"
                        >
                          Mark Preparing
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Ready for Pickup Orders Table */}
      {orders.length > 0 && (
        <div className="bg-white p-4 rounded-lg shadow-md h-80 overflow-y-scroll">
          <h2 className="text-xl font-bold mb-4">My Orders</h2>
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead>
                <tr className="bg-gray-100">
                  <th className="text-left py-2 px-3">Order ID</th>
                  <th className="text-left py-2 px-3">Customer</th>
                  <th className="text-left py-2 px-3">Items</th>
                  <th className="text-left py-2 px-3">Address</th>
                  <th className="text-left py-2 px-3">Status</th>
                  <th className="text-left py-2 px-3">Actions</th>{" "}
                  {/* ✅ Added column */}
                </tr>
              </thead>
              <tbody>
                {orders
                  .slice()
                  .sort((a, b) => b.id - a.id)
                  .map((order) => (
                    <tr key={order.id} className="border-b hover:bg-gray-50">
                      <td className="py-3 px-3 font-medium">#{order.id}</td>
                      <td className="py-3 px-3">Customer {order.customerId}</td>
                      <td className="py-3 px-3">{order.description}</td>
                      <td className="py-3 px-3">
                        {order.customerLocation?.address}
                      </td>
                      <td className="py-3 px-3">
                        <span
                          className={`px-2 py-1 rounded text-xs ${
                            order.status === "PREPARING"
                              ? "bg-yellow-100 text-yellow-800"
                              : order.status === "READY_FOR_PICKUP"
                              ? "bg-green-100 text-green-800"
                              : "bg-gray-100 text-gray-800"
                          }`}
                        >
                          {order.status}
                        </span>
                      </td>
                      <td className="py-3 px-3">
                        {order.status === "PREPARING" && (
                          <button
                            onClick={() => handleMarkReady(order.id)}
                            className="bg-green-500 hover:bg-green-600 text-white px-3 py-1 rounded text-sm"
                          >
                            Mark Ready
                          </button>
                        )}
                      </td>
                    </tr>
                  ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
};

export default OrdersTable;
