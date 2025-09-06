'use client';
import { useEffect } from 'react';

const Notifications = ({ notifications, setNotifications }) => {

  useEffect(() => {
    if (notifications.length > 0) {
      const timer = setTimeout(() => {
        setNotifications(prev => prev.slice(1));
      }, 5000);
      
      return () => clearTimeout(timer);
    }
  }, [notifications, setNotifications]);

  if (notifications.length === 0) return null;

  return (
    <div className="fixed top-4 right-4 z-50 space-y-2">
      {notifications.map(notification => (
        <div 
          key={notification.id}
          className={`px-4 py-3 rounded-lg shadow-lg text-white ${
            notification.type === 'success' 
              ? 'bg-green-500' 
              : notification.type === 'error' 
                ? 'bg-red-500' 
                : 'bg-blue-500'
          }`}
        >
          <div className="flex justify-between items-start">
            <span>{notification.message}</span>
            <button 
              onClick={() => setNotifications(prev => prev.filter(n => n.id !== notification.id))}
              className="ml-4"
            >
              &times;
            </button>
          </div>
        </div>
      ))}
    </div>
  );
};

export default Notifications;