package com.example.train_api.entity;

import java.sql.Timestamp;

public class Schedule {

    Long id_route;
    String type_train;
    String name_departure; // точка А
    Timestamp time_departure; // время отбытия из точки А
    Long id_time_departure;
    String name_arrival; //точка Б
    Timestamp time_arrival; // время прибытия в точку Б
    Long id_time_arrival;






    public Schedule(String name_arrival, String name_departure, Long id_route, String type_train, Timestamp time_departure, Timestamp time_arrival) {
        this.name_arrival = name_arrival;
        this.name_departure = name_departure;
        this.id_route = id_route;
        this.type_train = type_train;
        this.time_departure = time_departure;
        this.time_arrival = time_arrival;
    }
    public Schedule(){

    }

    public String getName_arrival() {
        return name_arrival;
    }

    public String getName_departure() {
        return name_departure;
    }

    public Long getId_route() {
        return id_route;
    }

    public String getType_train() {
        return type_train;
    }

    public Timestamp getTime_departure() {
        return time_departure;
    }

    public Timestamp getTime_arrival() {
        return time_arrival;
    }


    public void setName_arrival(String name_arrival) {
        this.name_arrival = name_arrival;
    }

    public void setName_departure(String name_departure) {
        this.name_departure = name_departure;
    }

    public void setId_route(Long id_route) {
        this.id_route = id_route;
    }

    public void setType_train(String type_train) {
        this.type_train = type_train;
    }

    public void setTime_departure(Timestamp time_departure) {
        this.time_departure = time_departure;
    }

    public void setTime_arrival(Timestamp time_arrival) {
        this.time_arrival = time_arrival;
    }

    public Long getId_time_departure() {
        return id_time_departure;
    }

    public Long getId_time_arrival() {
        return id_time_arrival;
    }

    public void setId_time_departure(Long id_time_departure) {
        this.id_time_departure = id_time_departure;
    }

    public void setId_time_arrival(Long id_time_arrival) {
        this.id_time_arrival = id_time_arrival;
    }
}
