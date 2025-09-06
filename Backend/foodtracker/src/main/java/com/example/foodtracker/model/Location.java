package com.example.foodtracker.model;

import jakarta.persistence.Embeddable;
import lombok.Data;

@Data
@Embeddable
public class Location {
    
    private double lat;
    private double lng;
    private String address;
}
