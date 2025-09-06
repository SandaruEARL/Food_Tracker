package com.example.foodtracker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
@RequestMapping
public class FoodtrackerApplication {

	public static void main(String[] args) {
		SpringApplication.run(FoodtrackerApplication.class, args);
	}

	@GetMapping("/api/hello")
	public String hello() {
		return "Hello, Food Tracker!";
	}
}
