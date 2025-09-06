'use client';
import { useState, useEffect } from 'react';
import { formatTime } from '../utils/helpers';
import Notifications from '../components/Notifications';
import OrderMap from '../components/OrderMap';
import { fetchOrders, acceptOrder, deliverOrder } from '../utils/api';

export default function ManageOrder() {
  // State for orders and UI
  const [orders, setOrders] = useState([]);
  const [filter, setFilter] = useState('All');
  const [searchTerm, setSearchTerm] = useState('');
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [showMap, setShowMap] = useState(false);
  const [notifications, setNotifications] = useState([]);
  const [selectedOrder, setSelectedOrder] = useState(null);

  // Load orders on component mount
  useEffect(() => {
    loadOrders();
    setupWebSocket();
  }, []);

  // Fetch orders from API
  const loadOrders = async () => {
    setIsRefreshing(true);
    try {
      const data = await fetchOrders();
      setOrders(data);
    } catch (error) {
      console.error('Error loading orders:', error);
      setNotifications([{
        id: Date.now(),
        type: 'error',
        message: 'Failed to load orders'
      }]);
    }
    setIsRefreshing(false);
  };

  // Setup WebSocket connection
  const setupWebSocket = () => {
    // This would be your actual WebSocket URL in production
    const ws = new WebSocket('ws://localhost:8080/ws');
    
    ws.onopen = () => {
      console.log('WebSocket connected');
    };
    
    ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      
      if (message.type === 'NEW_ORDER') {
        setOrders(prev => [...prev, message.order]);
        setNotifications(prev => [...prev, {
          id: Date.now(),
          type: 'info',
          message: `New order available: ${message.order.id}`
        }]);
      }
      else if (message.type === 'ORDER_UPDATED') {
        setOrders(prev => prev.map(order => 
          order.id === message.order.id ? message.order : order
        ));
      }
    };
    
    ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
    
    return () => ws.close();
  };

  // Handle accepting an order
  const handleAcceptOrder = async (orderId) => {
    try {
      const updatedOrder = await acceptOrder(orderId);
      setOrders(prev => prev.map(order => 
        order.id === orderId ? updatedOrder : order
      ));
      
      setNotifications([{
        id: Date.now(),
        type: 'success',
        message: `Order ${orderId} accepted!`
      }]);
    } catch (error) {
      console.error('Error accepting order:', error);
      setNotifications([{
        id: Date.now(),
        type: 'error',
        message: `Failed to accept order ${orderId}`
      }]);
    }
  };

  // Handle delivering an order
  const handleDeliverOrder = async (orderId) => {
    try {
      const updatedOrder = await deliverOrder(orderId);
      setOrders(prev => prev.map(order => 
        order.id === orderId ? updatedOrder : order
      ));
      
      setNotifications([{
        id: Date.now(),
        type: 'success',
        message: `Order ${orderId} delivered!`
      }]);
    } catch (error) {
      console.error('Error delivering order:', error);
      setNotifications([{
        id: Date.now(),
        type: 'error',
        message: `Failed to deliver order ${orderId}`
      }]);
    }
  };

  // Filter orders based on status and search term
  const filteredOrders = orders.filter(order => {
    // Apply status filter
    if (filter !== 'All') {
      if (filter === 'Pending' && order.status !== 'Pending') return false;
      if (filter === 'In Progress' && order.status !== 'In Progress') return false;
      if (filter === 'Completed' && order.status !== 'Completed') return false;
    }
    
    // Apply search filter
    if (searchTerm) {
      const term = searchTerm.toLowerCase();
      return (
        order.id.toLowerCase().includes(term) ||
        order.customerName.toLowerCase().includes(term) ||
        order.restaurant.toLowerCase().includes(term)
      );
    }
    
    return true;
  });

  // Get status badge class
  const getStatusClass = (status) => {
    switch(status) {
      case 'Pending': return 'bg-yellow-100 text-yellow-800';
      case 'In Progress': return 'bg-blue-100 text-blue-800';
      case 'Completed': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  // Statistics calculation
  const stats = {
    pending: orders.filter(o => o.status === 'Pending').length,
    inProgress: orders.filter(o => o.status === 'In Progress').length,
    completed: orders.filter(o => o.status === 'Completed').length
  };

  return (
    <div className="max-w-6xl mx-auto">
      <Notifications notifications={notifications} setNotifications={setNotifications} />
      
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Manage Orders</h1>
        <div className="mt-3 md:mt-0 flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2">
          <div className="relative">
            <input
              type="text"
              placeholder="Search orders..."
              className="border rounded-lg pl-10 pr-4 py-2 text-sm w-full sm:w-auto"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
            <svg 
              className="absolute left-3 top-2.5 h-5 w-5 text-gray-400" 
              fill="none" 
              stroke="currentColor" 
              viewBox="0 0 24 24"
            >
              <path strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
          <div className="flex space-x-2">
            <button 
              onClick={() => setShowMap(!showMap)}
              className={`px-4 py-2 rounded-lg transition text-sm ${
                showMap 
                  ? 'bg-gray-600 text-white' 
                  : 'bg-green-600 text-white hover:bg-green-700'
              }`}
            >
              {showMap ? 'Hide Map' : 'Show Map'}
            </button>
            <button 
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition text-sm flex items-center"
              onClick={loadOrders}
              disabled={isRefreshing}
            >
              {isRefreshing ? (
                <>
                  <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Refreshing...
                </>
              ) : 'Refresh Orders'}
            </button>
          </div>
        </div>
      </div>
      
      {/* Filter Tabs */}
      <div className="flex border-b border-gray-200 mb-6">
        {['All', 'Pending', 'In Progress', 'Completed'].map((tab) => (
          <button
            key={tab}
            className={`px-4 py-2 font-medium text-sm ${
              filter === tab
                ? 'text-blue-600 border-b-2 border-blue-600'
                : 'text-gray-500 hover:text-gray-700'
            }`}
            onClick={() => setFilter(tab)}
          >
            {tab}
          </button>
        ))}
      </div>
      
      {/* Map View */}
      {showMap && (
        <div className="bg-white rounded-lg shadow-lg p-4 mb-6">
          <h2 className="text-xl font-bold text-gray-800 mb-4">Orders Map</h2>
          <div className="h-96 rounded-lg overflow-hidden">
            <OrderMap 
              orders={orders.filter(order => 
                order.status === 'Pending' || order.status === 'In Progress'
              )}
            />
          </div>
        </div>
      )}
      
      {/* Orders Table */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Order ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Customer</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Restaurant</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredOrders.length > 0 ? (
                filteredOrders.map((order) => (
                  <tr key={order.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">#{order.id}</div>
                      <div className="text-xs text-gray-500">
                        {formatTime(order.createdTime)}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900">{order.description}</div>
                      <div className="text-xs text-gray-500">{order.total}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">{order.customerName}</div>
                      <div className="text-xs text-gray-500">{order.customerContact}</div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900">{order.restaurant}</div>
                      <div className="text-xs text-gray-500">{order.pickupLocationName}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 text-xs font-medium rounded-full ${getStatusClass(order.status)}`}>
                        {order.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm">
                      {order.status === 'Pending' && (
                        <button
                          className="bg-green-600 text-white px-3 py-1 rounded-md hover:bg-green-700 mr-2"
                          onClick={() => handleAcceptOrder(order.id)}
                        >
                          Accept
                        </button>
                      )}
                      {order.status === 'In Progress' && (
                        <button
                          className="bg-blue-600 text-white px-3 py-1 rounded-md hover:bg-blue-700"
                          onClick={() => handleDeliverOrder(order.id)}
                        >
                          Mark Delivered
                        </button>
                      )}
                      {order.status === 'Completed' && (
                        <span className="text-green-600">Completed</span>
                      )}
                      <button 
                        className="text-blue-600 hover:text-blue-800 ml-2"
                        onClick={() => setSelectedOrder(order)}
                      >
                        Details
                      </button>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="6" className="px-6 py-4 text-center text-sm text-gray-500">
                    No orders found
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
      
      {/* Order Summary */}
      <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-blue-50 rounded-lg p-4">
          <div className="flex items-center">
            <div className="bg-blue-100 p-2 rounded-lg mr-3">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-blue-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div>
              <p className="text-sm text-gray-600">Pending Orders</p>
              <p className="text-xl font-bold">
                {stats.pending}
              </p>
            </div>
          </div>
        </div>
        
        <div className="bg-yellow-50 rounded-lg p-4">
          <div className="flex items-center">
            <div className="bg-yellow-100 p-2 rounded-lg mr-3">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-yellow-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
              </svg>
            </div>
            <div>
              <p className="text-sm text-gray-600">In Progress</p>
              <p className="text-xl font-bold">
                {stats.inProgress}
              </p>
            </div>
          </div>
        </div>
        
        <div className="bg-green-50 rounded-lg p-4">
          <div className="flex items-center">
            <div className="bg-green-100 p-2 rounded-lg mr-3">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div>
              <p className="text-sm text-gray-600">Completed Today</p>
              <p className="text-xl font-bold">
                {stats.completed}
              </p>
            </div>
          </div>
        </div>
      </div>
      
      {/* Order Details Modal */}
      {selectedOrder && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl w-full max-w-md p-6">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-bold text-gray-800">Order #{selectedOrder.id}</h2>
              <button 
                onClick={() => setSelectedOrder(null)}
                className="text-gray-500 hover:text-gray-700"
              >
                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            
            <div className="space-y-4">
              <div>
                <p className="text-gray-600">Customer: {selectedOrder.customerName}</p>
                <p className="text-sm text-gray-500">Contact: {selectedOrder.customerContact}</p>
              </div>
              
              <div>
                <p className="text-gray-600">Restaurant: {selectedOrder.restaurant}</p>
                <p className="text-sm text-gray-500">Pickup: {selectedOrder.pickupLocationName}</p>
              </div>
              
              <div>
                <p className="text-gray-600">Order Details:</p>
                <p className="text-sm text-gray-800">{selectedOrder.description}</p>
                <p className="text-sm text-gray-800 font-bold mt-1">Total: {selectedOrder.total}</p>
              </div>
              
              <div className="flex justify-between">
                <span>Status:</span>
                <span className={`px-2 py-1 rounded text-xs ${getStatusClass(selectedOrder.status)}`}>
                  {selectedOrder.status}
                </span>
              </div>
              
              <div className="flex justify-between">
                <span>Created:</span>
                <span>{formatTime(selectedOrder.createdTime)}</span>
              </div>
              
              {selectedOrder.acceptedTime && (
                <div className="flex justify-between">
                  <span>Accepted:</span>
                  <span>{formatTime(selectedOrder.acceptedTime)}</span>
                </div>
              )}
              
              {selectedOrder.deliveredTime && (
                <div className="flex justify-between">
                  <span>Delivered:</span>
                  <span>{formatTime(selectedOrder.deliveredTime)}</span>
                </div>
              )}
            </div>
            
            <div className="mt-6 flex justify-end space-x-3">
              <button 
                onClick={() => setSelectedOrder(null)}
                className="border border-gray-300 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-50 transition"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}