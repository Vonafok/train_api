package com.example.train_api.service;

import com.example.train_api.exeption.BadRequestExeption;
import com.example.train_api.exeption.NotFoundException;
import com.example.train_api.repos.TrainRepository;
import com.example.train_api.entity.Schedule;
import com.example.train_api.entity.Ticket;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.sql.Date;
import java.time.LocalDate;
import java.time.Period;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class TrainService {

    private final TrainRepository trainRepository;

    @Autowired
    public TrainService(TrainRepository trainRepository) {
        this.trainRepository = trainRepository;
    }

    public List<Schedule> serviceGetSchedule(String arrivalValue, String departureValue, String trainValue) {
        List<Schedule> schedules = trainRepository.selectSchedule(arrivalValue, departureValue, trainValue);

        if (schedules.isEmpty()) {
            throw new NotFoundException("Расписание не найдено");//404
        }

        return schedules;
    }

    public List<Ticket> serviceGetTicket(Long id_clientValue, Long departureValue, Long arrivalValue, List<Long> placeListValue, List<Long> personListValue) {
        List<Ticket> ticket = trainRepository.ticketing(id_clientValue, departureValue, arrivalValue, placeListValue, personListValue);
        if (ticket.get(0).getBookingId() == -1 || ticket.get(0).getBoughtplaceId() == -1) {
            throw new BadRequestExeption("Места уже куплены");//400
        }
        return ticket;
    }

    public void serviceDeleteBooking(Long id_booking) {
        var res = trainRepository.deleteBooking(id_booking);
        if (res == 0) {
            throw new NotFoundException("Заказ нельзя отменить");//404
        }
    }

    public Map<String, Integer> serviceRouteStatClientAge(Long id_route, Date dateFrom, Date dateTo, Integer step, Integer maxAge) {
        List<LocalDate> date = trainRepository.statClientAge(id_route, dateFrom, dateTo, step, maxAge);
        if (date.isEmpty()) {
            throw new NotFoundException("Не найдено людей по заданному маршруту, за заданный период");//404
        }
        var res = counting(step, date, maxAge);
        if (res.isEmpty() || maxAge <= 0 || step <= 0) {
            throw new BadRequestExeption("Произошла ошибка при подсчёте, возможно не верный step или maxAge");//400
        }
        return res;
    }


    private Map<String, Integer> counting(Integer step, List<LocalDate> dates, Integer maxAge) {
        LocalDate today = LocalDate.now();
        List<Integer> ages = new ArrayList<>();

        for (LocalDate date : dates) { // узнаем возраст
            Period period = Period.between(date, today);
            int age = period.getYears();
            ages.add(age);
        }
        Map<String, Integer> map = new LinkedHashMap<>(); // Linked для красоты

        for (int i = 0; i < maxAge / step; i++) {
            int lowStep = i * step; // нижнее значение диапозона
            int upStep = (i + 1) * step; // верхнее значени диапозона
            int sum = 0;
            for (int j = 0; j < ages.size(); j++) {
                if (lowStep < ages.get(j) && ages.get(j) < upStep)
                    sum++;
            }
            map.put(Integer.toString(lowStep), sum);
        }

        int other = 0;
        for (Integer value : map.values())
            other += value;

        map.put("other", ages.size() - other);
        return map;
    }
}
