package com.example.foodtracker.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Entity
@Table(name = "orders")
public class Order {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String description;
    private String status;
    private Location customerLocation;

    @Column(nullable = true)
    private Long customerId;
    
    @Column(nullable = true)
    private Long driverId;

    @Column(nullable = true)
    private Long restaurantId;

}
