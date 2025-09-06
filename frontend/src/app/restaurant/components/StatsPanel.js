'use client';

const StatsPanel = ({ orders, availableOrders }) => {

  const stats = {
    newOrders: availableOrders.filter(o => o.status === 'NEW').length,
    inProgress: orders.filter(o => o.status === 'PREPARING').length,
    completedToday: orders.filter(o => o.status === 'READY_FOR_PICKUP').length,
  };

  return (
    <div className="bg-white p-4 rounded-lg shadow-md">
      <h2 className="text-xl font-bold mb-4">Orders Summary</h2>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="border border-blue-200 rounded-lg p-4 text-center">
          <h3 className="text-gray-500">New Orders</h3>
          <p className="text-3xl font-bold text-blue-600">{stats.newOrders}</p>
        </div>
        <div className="border border-yellow-200 rounded-lg p-4 text-center">
          <h3 className="text-gray-500">In Progress</h3>
          <p className="text-3xl font-bold text-yellow-600">{stats.inProgress}</p>
        </div>
        <div className="border border-green-200 rounded-lg p-4 text-center">
          <h3 className="text-gray-500">Completed Today</h3>
          <p className="text-3xl font-bold text-green-600">{stats.completedToday}</p>
        </div>
      </div>
    </div>
  );
};

export default StatsPanel;
