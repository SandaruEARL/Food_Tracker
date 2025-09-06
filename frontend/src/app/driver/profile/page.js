'use client';
import { useAuth } from '@/hooks/useAuth';
import { useState } from 'react';

export default function Profile() {

  const { user } = useAuth();

  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-2xl font-bold text-gray-800 mb-6">Driver Profile</h1>
      
      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex flex-col md:flex-row items-start md:items-center space-y-6 md:space-y-0 md:space-x-8">
          <div className="bg-gray-200 border-2 border-dashed rounded-xl w-32 h-32" />
          
          <div className="flex-1">
            <h2 className="text-xl font-bold text-gray-800">{user?.name}</h2>
            <div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <p className="text-sm text-gray-500">Email</p>
                <p className="text-gray-800">{user?.email}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Contact</p>
                <p className="text-gray-800">{user?.contact}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Vehicle</p>
                <p className="text-gray-800">{user?.vehicleType}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500">License Plate</p>
                <p className="text-gray-800">{user?.licensePlate}</p>
              </div>
            </div>
            
            <div className="mt-6 flex items-center">
              <div className="mr-4">
                <p className="text-sm text-gray-500">Rating</p>
                <div className="flex items-center">
                  <div className="text-yellow-400">
                    {'★'.repeat(5)}
                  </div>
                  <span className="ml-2 text-gray-800">{user?.rating}/5.0</span>
                </div>
              </div>
              <div>
                <p className="text-sm text-gray-500">Completed Deliveries</p>
                <p className="text-gray-800">{user?.completedDeliveries}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div className="mt-6 bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-bold text-gray-800 mb-4">Vehicle Information</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <p className="text-sm text-gray-500">Vehicle Type</p>
            <p className="text-gray-800">{user?.vehicleType}</p>
          </div>
          <div>
            <p className="text-sm text-gray-500">License Plate</p>
            <p className="text-gray-800">{user?.licensePlate}</p>
          </div>
          <div>
            <p className="text-sm text-gray-500">Insurance Valid Until</p>
            <p className="text-gray-800">December 31, 2024</p>
          </div>
          <div>
            <p className="text-sm text-gray-500">Vehicle Registration</p>
            <p className="text-gray-800">Valid until June 30, 2025</p>
          </div>
        </div>
      </div>
    </div>
  );
}