package com.example.foodtracker.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.foodtracker.dto.AuthResponse;
import com.example.foodtracker.model.User;
import com.example.foodtracker.service.AuthService;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody User user) {
        try {
            User registerdUser = authService.userRegister(user);

            // jwt token generation logic
            String token = authService.generateToken(registerdUser);

            AuthResponse authResponse = new AuthResponse(registerdUser.getId(),registerdUser.getEmail(), registerdUser.getName(), token, registerdUser.getType());
            return new ResponseEntity<>(authResponse, HttpStatus.CREATED);

        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }

    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody User user) {
        try {
            User loggedInUser = authService.loginUser(user);

            String token = authService.generateToken(loggedInUser);

            AuthResponse authResponse = new AuthResponse(loggedInUser.getId(), loggedInUser.getEmail(), loggedInUser.getName(), token, loggedInUser.getType());
            return new ResponseEntity<>(authResponse, HttpStatus.OK);

        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }

    }

}
