

const startSendingDriverLocation = (orderId) => {
    if (!navigator.geolocation) {
      alert("Geolocation not supported");
      return;
    }
  
    navigator.geolocation.watchPosition(
      (position) => {
        if (stompClient && stompClient.connected) {
          stompClient.publish({
            destination: "/app/driverLocation",
            body: JSON.stringify({
              orderId,
              lat: position.coords.latitude,
              lng: position.coords.longitude,
            }),
          });
        }
      },
      (err) => console.error(err),
      { enableHighAccuracy: true, maximumAge: 10000 }
    );
  };
  