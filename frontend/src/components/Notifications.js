'use client';
import '../app/globals.css'
import React from 'react';

const Notifications = ({ message }) => {
  if (!message) return null;

  return (
    <div className="mb-6 p-4 bg-yellow-100 border-l-4 border-yellow-500">
      <p><strong>Notification:</strong> {message}</p>
    </div>
  );
};

export default Notifications;
