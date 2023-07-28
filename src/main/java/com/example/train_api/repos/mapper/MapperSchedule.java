package com.example.train_api.repos.mapper;

import com.example.train_api.entity.Schedule;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.sql.SQLException;


public class MapperSchedule implements RowMapper<Schedule> {

    @Override
    public Schedule mapRow(ResultSet rs, int rowNum) throws SQLException {

        Schedule schedule = new Schedule();
        schedule.setId_route(rs.getLong("id_route"));

        schedule.setName_arrival(rs.getString("rs2_localityname_railwaystation"));
        schedule.setId_time_arrival(rs.getLong("tt2_id_timetable"));

        schedule.setName_departure(rs.getString("rs1_localityname_railwaystation"));
        schedule.setId_time_departure(rs.getLong("tt1_id_timetable"));

        schedule.setType_train(rs.getString("type_train"));
        schedule.setTime_arrival(rs.getTimestamp("timedatearrival_timetable"));//прибытие в конечную точку
        schedule.setTime_departure(rs.getTimestamp("timedatedepartyre_timetable"));// отбытие


        return schedule;
    }

}
