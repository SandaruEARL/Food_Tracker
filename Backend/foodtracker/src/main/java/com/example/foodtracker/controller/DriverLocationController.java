package com.example.foodtracker.controller;

import com.example.foodtracker.dto.DriverLocation;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Controller;

@Controller
public class DriverLocationController {

    private final DriverLocationPublisher publisher;

    public DriverLocationController(DriverLocationPublisher publisher) {
        this.publisher = publisher;
    }

    @MessageMapping("/driverLocation")
    public void receiveDriverLocation(@Payload DriverLocation location) {
        publisher.sendDriverLocation(location);
    }
}
