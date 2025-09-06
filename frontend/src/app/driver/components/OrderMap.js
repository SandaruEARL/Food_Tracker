'use client';
import { GoogleMap, Marker, useJsApiLoader } from '@react-google-maps/api';

const OrderMap = ({ driverLocation, orders, pickup, delivery }) => {
  const { isLoaded } = useJsApiLoader({
    id: 'google-map-script',
    googleMapsApiKey: process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY
  });

  console.log("Driver Location:", driverLocation);
  console.log("Orders:", orders);
  console.log("Pickup Location:", pickup);
  console.log("Delivery Location:", delivery);

  const containerStyle = {
    width: '100%',
    height: '100%'
  };

// Calculate map center
let center = { lat: 6.9271, lng: 79.8612 }; // Default to Colombo

if (driverLocation) {
  center = driverLocation;
} else if (delivery) {
  center = {
    lat: Number(delivery.lat),
    lng: Number(delivery.lng)
  };
}

  return isLoaded ? (
    <div className="h-full w-full">
      <GoogleMap
        mapContainerStyle={containerStyle}
        center={center}
        zoom={13}
      >
        {/* Driver Marker */}
        {driverLocation && (
          <Marker 
            position={{
              lat: Number(driverLocation.lat),
              lng: Number(driverLocation.lng)
            }} 
            label="D"
            icon={{ url: 'https://maps.google.com/mapfiles/ms/icons/blue-dot.png' }}
          />
        )}
        
        {/* Pickup Marker */}
        {pickup && (
          <Marker 
            position={{
              lat: Number(pickup.lat),
              lng: Number(pickup.lng)
            }} 
            label="P"
            icon={{ url: 'https://maps.google.com/mapfiles/ms/icons/green-dot.png' }}
          />
        )}
        
        {/* Delivery Marker */}
        {delivery && (
          <Marker 
            position={{
              lat: Number(delivery.lat),
              lng: Number(delivery.lng)
            }} 
            label="C"
            icon={{ url: 'https://maps.google.com/mapfiles/ms/icons/red-dot.png' }}
          />
        )}
        
        {/* Order Pickup Markers */}
        {orders && orders.map((order) => (
          order.pickupLocationCoords && (
            <Marker 
              key={order.id}
              position={{
                lat: Number(order.pickupLocationCoords.lat),
                lng: Number(order.pickupLocationCoords.lng)
              }} 
              label="R"
              icon={{ url: 'https://maps.google.com/mapfiles/ms/icons/green-dot.png' }}
            />
          )
        ))}
      </GoogleMap>
    </div>
  ) : (
    <div className="h-full bg-gray-200 flex items-center justify-center">
      Loading Map...
    </div>
  );
};

export default OrderMap;
