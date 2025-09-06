'use client';
import '../app/globals.css'
import React from 'react';

const OrderList = ({ orders }) => {
  if (!orders.length) return <p>No orders available.</p>;

  return (
    <div className="mb-6">
      <h2 className="font-semibold mb-2">Your Orders</h2>
      <ul className="list-disc ml-5">
        {orders.map((order, index) => (
          <li key={index}>
            <strong>{order.description}</strong> - {order.status}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default OrderList;