package com.example.demo;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);

        System.out.println("========================================");
        System.out.println("   SPRING BOOT DEMO STARTED SUCCESS!   ");
        System.out.println("   Version: 1.0.0                      ");
        System.out.println("   JDK: 17                             ");
        System.out.println("   Spring Boot: 3.2.5                  ");
        System.out.println("========================================");
    }

    @Bean
    CommandLineRunner startup() {
        return args -> {
            System.out.println("========================================");
            System.out.println("   APPLICATION IS READY!               ");
            System.out.println("   Jenkins Build Test Demo             ");
            System.out.println("========================================");
        };
    }
}