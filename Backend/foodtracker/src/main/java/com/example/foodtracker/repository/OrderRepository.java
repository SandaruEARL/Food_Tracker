package com.example.foodtracker.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.foodtracker.model.Order;

public interface OrderRepository extends JpaRepository<Order, Long> {

    List<Order> findByStatus(String status);
    List<Order> findByCustomerId(Long customerId);
    List<Order> findByDriverId(Long driverId);
    List<Order> findByRestaurantId(Long restaurantId);
   
    
}
