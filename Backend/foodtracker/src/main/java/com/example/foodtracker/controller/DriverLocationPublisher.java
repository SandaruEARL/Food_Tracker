package com.example.foodtracker.controller;

import com.example.foodtracker.dto.DriverLocation;
import com.example.foodtracker.model.Order;
import com.example.foodtracker.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

@Component
public class DriverLocationPublisher {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    private OrderRepository orderRepository;

    public void sendDriverLocation(DriverLocation location) {

        Order order = orderRepository.findById(location.getOrderId())
                .orElseThrow(() -> new RuntimeException("Order not found"));

        Long customerId = order.getCustomerId();

        String destination = "/topic/orders/CUSTOMER/location/" + customerId;
        messagingTemplate.convertAndSend(destination, location);
    }
}
