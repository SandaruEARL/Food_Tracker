package com.example.foodtracker.service;

import java.util.Optional;

import com.example.foodtracker.config.JwtService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.foodtracker.model.User;
import com.example.foodtracker.repository.UserRepository;

@Service
public class AuthService  {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

     private static final Logger logger = LoggerFactory.getLogger(OrderService.class);

    public User userRegister(User user)  {

        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            throw new RuntimeException("Email already exists");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        try {
            userRepository.save(user);
            return user;
        } catch (Exception e) {
            logger.error("Error registering user: {}", e.getMessage(), e);
            throw new RuntimeException("Registration failed, Try again!");
        }
    }

    public User loginUser(User user){
        Optional<User> existingUser = userRepository.findByEmail(user.getEmail());
        if(!existingUser.isPresent()){
            throw new RuntimeException("Email or password is incorrect");
        }
        User exisngUserObj = existingUser.get();

        if (!passwordEncoder.matches(user.getPassword(), exisngUserObj.getPassword())) {
            throw new RuntimeException("Email or password is incorrect");
        }
        return exisngUserObj;

    }
    public String generateToken(User user) {
        return jwtService.generateToken(user.getEmail());
    }


}
