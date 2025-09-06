'use client';
import '../app/globals.css'
import React from 'react';

const LOCATIONS = {
  customer: { lat: 40.7589, lng: -73.9851, name: 'Customer Home' },
  driver: { lat: 40.7505, lng: -73.9934, name: 'Driver Location' }
};

const SimpleMap = () => {
  return (
    <div className="mb-6">
      <h2 className="font-semibold mb-2">Map</h2>
      <div className="w-full h-64 bg-gray-200 flex items-center justify-center">
        <p>Static Map: {LOCATIONS.customer.name} & {LOCATIONS.driver.name}</p>
      </div>
    </div>
  );
};

export default SimpleMap;
