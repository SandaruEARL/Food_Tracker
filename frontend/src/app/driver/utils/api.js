// Mock API functions for driver operations
export const fetchAvailableOrders = async () => {
  // Simulate API call delay
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  // Return mock data
  return [
    {
      id: 'ORD-00125',
      customerName: 'Dinesh Jayawardena',
      customerContact: '+94 71 234 5678',
      restaurant: 'Upali\'s by Nawaloka',
      description: '1 Chicken Curry, 2 Parathas, 1 Watalappan',
      pickupLocationName: 'Upali\'s, Nawaloka Hospital, Colombo 02',
      deliveryLocationName: '123 Main Street, Colombo 05',
      status: 'NEW',
      createdTime: new Date().toISOString(),
      acceptedTime: null,
      deliveredTime: null,
      eta: '15 min',
      total: '1,850 LKR',
      pickupLocationCoords: { lat: 6.920, lng: 79.865 },
      deliveryLocationCoords: { lat: 6.910, lng: 79.870 }
    },
    {
      id: 'ORD-00126',
      customerName: 'Priyanka Bandara',
      customerContact: '+94 76 345 6789',
      restaurant: 'Barefoot Garden Cafe',
      description: '1 Seafood Platter, 2 Fresh Lime Juices',
      pickupLocationName: 'Barefoot Garden Cafe, Galle Road, Colombo 04',
      deliveryLocationName: '45 Marine Drive, Dehiwala',
      status: 'NEW',
      createdTime: new Date().toISOString(),
      acceptedTime: null,
      deliveredTime: null,
      eta: '25 min',
      total: '3,200 LKR',
      pickupLocationCoords: { lat: 6.8910, lng: 79.8570 },
      deliveryLocationCoords: { lat: 6.8400, lng: 79.8700 }
    }
  ];
};

export const acceptOrder = async (orderId) => {
  // Simulate API call delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  // Return mock updated order
  return {
    id: orderId,
    customerName: 'Customer Name',
    customerContact: '+94 77 123 4567',
    restaurant: 'Restaurant Name',
    description: 'Order description',
    pickupLocationName: 'Pickup location',
    deliveryLocationName: 'Delivery location',
    status: 'ACCEPTED',
    createdTime: new Date().toISOString(),
    acceptedTime: new Date().toISOString(),
    deliveredTime: null,
    eta: '10 min',
    total: '2,500 LKR',
    pickupLocationCoords: { lat: 6.9271, lng: 79.8612 },
    deliveryLocationCoords: { lat: 6.9000, lng: 79.8600 }
  };
};

export const markOrderDelivered = async (orderId) => {
  // Simulate API call delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  // Return mock updated order
  return {
    id: orderId,
    customerName: 'Customer Name',
    customerContact: '+94 77 123 4567',
    restaurant: 'Restaurant Name',
    description: 'Order description',
    pickupLocationName: 'Pickup location',
    deliveryLocationName: 'Delivery location',
    status: 'DELIVERED',
    createdTime: new Date(Date.now() - 3600000).toISOString(),
    acceptedTime: new Date(Date.now() - 1800000).toISOString(),
    deliveredTime: new Date().toISOString(),
    eta: '0 min',
    total: '2,500 LKR',
    pickupLocationCoords: { lat: 6.9271, lng: 79.8612 },
    deliveryLocationCoords: { lat: 6.9000, lng: 79.8600 }
  };
};


// Mock API functions for driver operations
export const fetchOrders = async () => {
  // Simulate API call delay
  await new Promise(resolve => setTimeout(resolve, 800));
  
  // Return mock data
  return [
    {
      id: 'ORD-00125',
      customerName: 'Dinesh Jayawardena',
      customerContact: '+94 71 234 5678',
      restaurant: 'Upali\'s by Nawaloka',
      description: '1 Chicken Curry, 2 Parathas, 1 Watalappan',
      pickupLocationName: 'Upali\'s, Nawaloka Hospital, Colombo 02',
      status: 'Pending',
      createdTime: new Date().toISOString(),
      acceptedTime: null,
      deliveredTime: null,
      eta: '15 min',
      total: '1,850 LKR',
      pickupLocationCoords: { lat: 6.920, lng: 79.865 },
      deliveryLocationCoords: { lat: 6.910, lng: 79.870 }
    },
    // ... other orders
  ];
};



export const deliverOrder = async (orderId) => {
  await new Promise(resolve => setTimeout(resolve, 500));
  return {
    id: orderId,
    // ... other order properties
    status: 'Completed',
    deliveredTime: new Date().toISOString()
  };
};