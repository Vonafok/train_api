package com.example.train_api.controller;
import com.example.train_api.entity.*;
import com.example.train_api.service.TrainService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;


import java.sql.Date;
import java.util.List;
import java.util.Map;

@RestController
public class TrainController {

    private final TrainService trainService;

    @Autowired
    public TrainController(TrainService trainService){
        this.trainService= trainService;
    }

    @GetMapping("/schedule")
    @ResponseBody
    public List<Schedule> getSchedule(@RequestParam("departure") String arrivalValue,
                                      @RequestParam("arrival") String departureValue,
                                      @RequestParam("train") String trainValue)  {
        List<Schedule> schedules = trainService.serviceGetSchedule(arrivalValue, departureValue, trainValue);
        return schedules;
    }
    @GetMapping("/ticket")
    @ResponseBody
    public List<Ticket> getTicket(@RequestParam("client") Long id_clientValue,
                                  @RequestParam("arrival") Long departureValue,
                                  @RequestParam("departure") Long arrivalValue,
                                  @RequestParam("placeList") List<Long> placeListValue,
                                  @RequestParam("personList") List<Long> personListValue ){
        List<Ticket> ticket = trainService.serviceGetTicket(id_clientValue,departureValue,arrivalValue,placeListValue,personListValue);
        return ticket;
    }
    @DeleteMapping("/deletebooking")
    public void deleteBooking(@RequestParam("booking") Long id_booking){
        trainService.serviceDeleteBooking(id_booking);
    }
    @GetMapping("/routestatclientage")
    @ResponseBody
    public Map<String,Integer> routeStatClientAge(@RequestParam("id_route")Long id_route,
                                                   @RequestParam("dateFrom") Date dateFrom,
                                                   @RequestParam("dateTo") Date dateTo,
                                                   @RequestParam("step")Integer step,
                                                  @RequestParam("maxAge") Integer maxAge
                                                  ){
        Map<String,Integer> map = trainService.serviceRouteStatClientAge(id_route,dateFrom,dateTo,step,maxAge);
        return map;
    }
}

