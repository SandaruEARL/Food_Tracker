package com.example.foodtracker.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.foodtracker.dto.StatusUpdateRequest;
import com.example.foodtracker.model.Order;
import com.example.foodtracker.model.User;
import com.example.foodtracker.service.OrderService;
import com.example.foodtracker.service.UserPrincipal;

@RestController
@RequestMapping("/api/order")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @Autowired
    private OrderWebSocketPublisher orderWebSocketPublisher;

    @PostMapping("/place")
    public ResponseEntity<?> placeOrder(@RequestBody Order order,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            User user = userPrincipal.getUser();
            Order createdOrder = orderService.createOrder(order, user.getId());

            orderWebSocketPublisher.sendOrderStatus(createdOrder, "RESTAURANT");

            return new ResponseEntity<>(createdOrder, HttpStatus.CREATED);

        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/available/driver")
    public ResponseEntity<?> getAvailableDriver() {
        try {
           
            List<Order> orders = orderService.getAvailableOrders("DRIVER");

            return new ResponseEntity<>(orders, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/available/restaurant")
    public ResponseEntity<?> getAvailableRestaurant() {
        try {
         
            List<Order> orders = orderService.getAvailableOrders("RESTAURANT");

            return new ResponseEntity<>(orders, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/all")
    public ResponseEntity<?> getAll() {
        try {
            List<Order> orders = orderService.getAllOrders();
            return new ResponseEntity<>(orders, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @PutMapping("/{orderId}/changestatus")
    public ResponseEntity<?> changeOrderStatus(
            @PathVariable Long orderId,
            @RequestBody StatusUpdateRequest statusRequest,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
    
        try {
            User user = userPrincipal.getUser();
            String cleanStatus = statusRequest.getStatus();
            String role = user.getType();
    
            // Update order status
            Order updatedOrder = orderService.updateStatus(orderId, cleanStatus, user.getId(), role);
    
            // Send updates based on order status
            switch (updatedOrder.getStatus().toUpperCase()) {
                case "PREPARING":
                    orderWebSocketPublisher.sendOrderStatusToUser(updatedOrder, updatedOrder.getCustomerId());
                    orderWebSocketPublisher.sendOrderStatus(updatedOrder, "RESTAURANT");
                    break;
    
                default:
                    orderWebSocketPublisher.sendOrderStatusToUser(updatedOrder, updatedOrder.getCustomerId());
                    orderWebSocketPublisher.sendOrderStatus(updatedOrder, "RESTAURANT");
                    orderWebSocketPublisher.sendOrderStatus(updatedOrder, "DRIVER");
                    break;

            }
    
            return ResponseEntity.ok(updatedOrder);
    
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
    
    @GetMapping("/getrelavant")
    public ResponseEntity<?> getRelevantOrders(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            User user = userPrincipal.getUser();
            List<Order> orders = orderService.getRelavant(user.getId(), user.getType());
            return new ResponseEntity<>(orders, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

}
