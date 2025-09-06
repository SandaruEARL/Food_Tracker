'use client';
import { useState } from 'react';
import OrderDetailsModal from './OrderDetailsModal';

export default function OrderCard({ order, type, onAction, disabled = false }) {
  const [showModal, setShowModal] = useState(false);
  
  const getStatusColor = () => {
    switch(order.status) {
      case 'NEW': 
        return 'bg-yellow-100 text-yellow-800';
      case 'ACCEPTED':
      case 'IN_PROGRESS': 
        return 'bg-blue-100 text-blue-800';
      case 'DELIVERED': 
        return 'bg-green-100 text-green-800';
      default: 
        return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <>
      <div className="border rounded-lg p-3 hover:shadow-md transition">
        <div className="flex justify-between items-start">
          <div>
            <p className="font-bold">Order #{order.id}</p>
            <p className="text-gray-600 text-sm">{order.description}</p>
          </div>
          <span className={`px-2 py-1 rounded text-xs ${getStatusColor()}`}>
            {order.status}
          </span>
        </div>
        
        <div className="mt-3 flex items-center justify-between">
          <div className="flex items-center">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 mr-1 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span className="text-sm text-gray-600">ETA: {order.eta}</span>
          </div>
          
          <div className="flex space-x-2">
            <button 
              className="bg-blue-600 text-white px-3 py-1.5 rounded-lg hover:bg-blue-700 transition text-sm"
              onClick={() => setShowModal(true)}
            >
              View
            </button>
            
            <button 
              className={`px-3 py-1.5 rounded-lg text-white text-sm transition ${
                disabled
                  ? "bg-gray-400 cursor-not-allowed"
                  : type === 'available'
                    ? 'bg-green-600 hover:bg-green-700'
                    : 'bg-orange-600 hover:bg-orange-700'
              }`}
              onClick={onAction}
              disabled={disabled}
              title={disabled ? "Complete active orders before accepting new ones" : ""}
            >
              {type === 'available' ? 'Accept' : 'Deliver'}
            </button>
          </div>
        </div>
      </div>
      
      {showModal && (
        <OrderDetailsModal 
          order={order} 
          onClose={() => setShowModal(false)} 
          onAction={onAction}
          actionLabel={type === 'available' ? 'Accept Order' : 'Mark Delivered'}
          disabled={disabled}
        />
      )}
    </>
  );
}
