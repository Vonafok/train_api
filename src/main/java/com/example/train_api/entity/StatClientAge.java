package com.example.train_api.entity;

import java.sql.Date;
import java.util.List;

public class StatClientAge {
    List<Date> date;
    Integer stepAge;

    public StatClientAge(List<Date> date, Integer stepAge) {
        this.date = date;
        this.stepAge = stepAge;
    }

    public StatClientAge() {
    }

    public List<Date> getDate() {
        return date;
    }

    public Integer getStepAge() {
        return stepAge;
    }

    public void setDate(List<Date> date) {
        this.date = date;
    }

    public void setStepAge(Integer stepAge) {
        this.stepAge = stepAge;
    }

}
