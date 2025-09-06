package com.example.foodtracker.dto;


import com.example.foodtracker.model.Location;

import jakarta.persistence.Column;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderStatusUpdate {
    private Long id;
    private String status;
    private String description;
    private Location customerLocation;
    private Long customerId;
    private Long driverId;
    private Long restaurantId;


}
