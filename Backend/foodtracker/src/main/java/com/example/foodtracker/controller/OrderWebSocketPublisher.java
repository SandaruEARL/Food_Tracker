package com.example.foodtracker.controller;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import com.example.foodtracker.dto.OrderStatusUpdate;
import com.example.foodtracker.model.Order;

@Component
public class OrderWebSocketPublisher {

    private final SimpMessagingTemplate messagingTemplate;

    public OrderWebSocketPublisher(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }


    public void sendOrderStatus(Order order, String role) {
        OrderStatusUpdate update = mapToDTO(order);
        messagingTemplate.convertAndSend("/topic/orders/" + role, update);
    }


    public void sendOrderStatusToUser(Order order, Long userId) {
        OrderStatusUpdate update = mapToDTO(order);
        messagingTemplate.convertAndSend("/topic/orders/CUSTOMER/" + userId, update);
    }


    private OrderStatusUpdate mapToDTO(Order order) {
        return new OrderStatusUpdate(
            order.getId(),
            order.getStatus(),
            order.getDescription(),
            order.getCustomerLocation(),
            order.getCustomerId(),
            order.getDriverId(),
            order.getRestaurantId()
        );
    }
}
