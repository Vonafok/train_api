package com.example.train_api.exeption;

public class BadRequestExeption extends RuntimeException {
    public BadRequestExeption(String message) {
        super(message);
    }

    public BadRequestExeption(String message, Throwable cause) {

        super(message, cause);
    }
}
