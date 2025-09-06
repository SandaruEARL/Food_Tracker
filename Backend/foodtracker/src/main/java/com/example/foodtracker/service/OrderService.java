package com.example.foodtracker.service;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.foodtracker.model.Order;
import com.example.foodtracker.repository.OrderRepository;

@Service
public class OrderService {
    
    @Autowired
    private OrderRepository orderRepository;

     private static final Logger logger = LoggerFactory.getLogger(OrderService.class);

    public Order createOrder(Order order, Long userId){
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
        order.setCustomerId(userId);
    
        if (order.getDescription() == null || order.getDescription().isEmpty()) {
            throw new IllegalArgumentException("Order description cannot be empty");
        }
        if (order.getCustomerLocation() == null) {
            throw new IllegalArgumentException("Customer location cannot be null");
        }
        if (order.getStatus() == null || order.getStatus().isEmpty()) {
            order.setStatus("NEW");
        }
        try {
            return orderRepository.save(order);
        } catch (Exception e) {
            logger.error("Error creating order: {}", e.getMessage(), e);
            throw new RuntimeException("Order creation failed, Try again!");
        }
       

    }

    public List<Order> getAvailableOrders(String role){
        try {
            if ("DRIVER".equalsIgnoreCase(role)) {
                return orderRepository.findByStatus("READY_FOR_PICKUP");
            } else if ("RESTAURANT".equalsIgnoreCase(role)) {
                return orderRepository.findByStatus("NEW");
            } 
            throw new IllegalArgumentException("Invalid user role: " + role);
        } catch (Exception e) {
            logger.error("Error fetching available orders: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to fetch available orders, Try again!");
        }
    }

    public List<Order> getAllOrders(){
        try {
            return orderRepository.findAll();
        } catch (Exception e) {
            logger.error("Error fetching all orders: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to fetch available orders, Try again!");
        }
    }


    public Order updateStatus(Long orderId, String status, Long userId, String role) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
    
        order.setStatus(status);
    
        if ("DRIVER".equalsIgnoreCase(role)) {
            order.setDriverId(userId);   
        } else if ("RESTAURANT".equalsIgnoreCase(role)) {
            order.setRestaurantId(userId);
        }
    
        try {
            return orderRepository.save(order);
        } catch (Exception e) {
            logger.error("Error updating order status: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to update order status, Try again!");
        }
    }
    
    public List<Order> getRelavant(Long userId, String role) {
        if (userId == null || role == null) {
            throw new IllegalArgumentException("User ID and role cannot be null");
        }
    
        try {
            if ("DRIVER".equalsIgnoreCase(role)) {
                return orderRepository.findByDriverId(userId);
            } else if ("RESTAURANT".equalsIgnoreCase(role)) {
                return orderRepository.findByRestaurantId(userId);
            } else if ("CUSTOMER".equalsIgnoreCase(role)) {
                return orderRepository.findByCustomerId(userId);
            } else {
                throw new IllegalArgumentException("Invalid user role: " + role);
            }
        } catch (Exception e) {
            logger.error("Error fetching relevant orders: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to fetch relevant orders, Try again!");
        }
    }
}
