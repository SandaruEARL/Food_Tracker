export const restaurantData = {
  name: "Bistro Central",
  stats: {
    newOrders: 5,
    inProgress: 8,
    completedToday: 32
  },
  orders: [
    { id: 1001, customer: "John Smith", description: "2 Veggie Burgers, 1 Fries", address: "123 Main St", status: "New", time: "12:30 PM" },
    { id: 1002, customer: "Emma Johnson", description: "Chicken Salad", address: "456 Oak Ave", status: "Preparing", time: "12:45 PM" },
    { id: 1003, customer: "Michael Brown", description: "Spaghetti Carbonara", address: "789 Pine Rd", status: "Ready for Pickup", time: "12:50 PM" },
    { id: 1004, customer: "Sarah Davis", description: "3 Tacos, Guacamole", address: "321 Elm St", status: "New", time: "1:05 PM" },
    { id: 1005, customer: "David Wilson", description: "Caesar Salad", address: "654 Maple Ave", status: "Preparing", time: "1:15 PM" },
  ],
  notifications: [
    { id: 1, message: "Order #1002 marked as Ready", time: "1:20 PM" },
    { id: 2, message: "Order #1003 completed", time: "1:15 PM" },
    { id: 3, message: "New order #1005 received", time: "1:10 PM" }
  ],
  location: { lat: 40.7128, lng: -74.0060 }
};