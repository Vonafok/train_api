package com.example.train_api.exeption;


import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;


@ControllerAdvice
public class GeneralExeptionHandle {

    @ExceptionHandler(NotFoundException.class)//404
    public ResponseEntity<Response> handleDefaultException(NotFoundException e) {
        Response response = new Response(e.getMessage());
        return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)//400
    public ResponseEntity<Response> handleDataFormatError(MethodArgumentTypeMismatchException ex) {
        Response response = new Response("Ошибка в формате переданного значения: " + ex.getMessage());
        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(BadRequestExeption.class)//400
    public ResponseEntity<Response> handleDefaultException(BadRequestExeption e) {
        Response response = new Response(e.getMessage());
        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(DataAccessException.class)//500
    public ResponseEntity<Response> handleDataAccessException(DataAccessException e) {
        Response response = new Response("Ошибка при выполнении запроса в БД", e.getMessage());
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

}

