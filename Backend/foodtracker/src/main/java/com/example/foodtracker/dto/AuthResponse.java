package com.example.foodtracker.dto;

import lombok.Data;

@Data
public class AuthResponse {
    private Long id;
    private String email;
    private String token;
    private String name;
    private String type;

    public AuthResponse(Long id,String email, String name, String token, String type) {
        this.id = id;
        this.email = email;
        this.name = name;
        this.token = token;
        this.type = type;

    }
}
