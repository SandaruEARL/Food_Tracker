package com.example.foodtracker.dto;

import lombok.Data;

@Data
public class DriverLocation {
    private Long orderId;
    private double lat;
    private double lng;

    public DriverLocation(Long orderId, double lat, double lng) {
        this.orderId = orderId;
        this.lat = lat;
        this.lng = lng;
    }

  
}
