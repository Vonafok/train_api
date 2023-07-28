package com.example.train_api.repos;


import com.example.train_api.entity.Schedule;
import com.example.train_api.entity.Ticket;
import com.example.train_api.repos.mapper.MapperSchedule;
import com.example.train_api.repos.mapper.MapperStatClientAge;
import com.example.train_api.repos.mapper.MapperTicket;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

@Repository
public class TrainRepository {

    private final NamedParameterJdbcTemplate jdbcTemplate;

    @Autowired
    public TrainRepository(NamedParameterJdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }


    public List<Schedule> selectSchedule(String arrivalValue, String departureValue, String trainValue) {
        final String sql = """
                SELECT rs1.localityname_railwaystation AS rs1_localityname_railwaystation ,
                       tt1.id_timetable AS tt1_id_timetable,
                       rs2.localityname_railwaystation AS rs2_localityname_railwaystation,
                       tt2.id_timetable AS tt2_id_timetable,
                       s1.id_route,
                       tr.type_train,
                       tt1.timedatedepartyre_timetable  ,
                       tt2.timedatearrival_timetable  
                FROM railwaystation rs1
                JOIN station s1 ON s1.id_railwaystation = rs1.id_railwaystation
                JOIN station s2 ON s2.id_route = s1.id_route
                JOIN timetable tt1 ON tt1.id_station = s1.id_station
                JOIN timetable tt2 ON tt2.id_station = s2.id_station
                JOIN railwaystation rs2 ON rs2.id_railwaystation = s2.id_railwaystation
                JOIN route r ON r.id_route = s1.id_route
                JOIN train tr ON tr.id_train = r.id_train
                WHERE rs1.localityname_railwaystation ILIKE '%' || :arrival || '%'
                  AND rs2.localityname_railwaystation ILIKE '%' || :departure || '%'
                  AND s2.serial_number_station > s1.serial_number_station
                  AND tr.type_train ILIKE '%' || :type_train || '%';
                """;
        var params = new MapSqlParameterSource();

        params.addValue("arrival", arrivalValue);
        params.addValue("departure", departureValue);
        params.addValue("type_train", trainValue);

        var res = jdbcTemplate.query(sql, params, new MapperSchedule());
        return res;
    }

    public List<Ticket> ticketing(Long client, Long departure, Long arrival, List<Long> placeList, List<Long> personList) {
        final String sql = """
                SELECT booking_id,boughtplace_id
                from combined_function(
                :id_client, 
                :departure, 
                :arrival, 
                ARRAY [:placeList], 
                ARRAY [:personList]);
                 """;
        var params = new MapSqlParameterSource();
        params.addValue("id_client", client);
        params.addValue("departure", departure);
        params.addValue("arrival", arrival);
        params.addValue("placeList", placeList);
        params.addValue("personList", personList);

        var res = jdbcTemplate.query(sql, params, new MapperTicket());
        return res;
    }

    public int deleteBooking(Long id_booking) {
        final String sql = """
                WITH booking_to_delete AS (
                    SELECT DISTINCT b.id_booking
                    FROM booking b
                    JOIN timetable tt ON tt.id_station = b.id_arrival_timetable
                    JOIN boughtplace bo ON bo.id_booking = b.id_booking
                    WHERE b.id_booking = :booking_id
                	AND tt.timedatedepartyre_timetable - INTERVAL '2 hours' > NOW()::timestamp with time zone
                )              
                DELETE FROM booking
                WHERE id_booking IN (SELECT id_booking FROM booking_to_delete);
                """;
        var params = new MapSqlParameterSource();
        params.addValue("booking_id", id_booking);
        int res = jdbcTemplate.update(sql, params);
        return res;

    }

    public List<LocalDate> statClientAge(Long id_route, Date dateFrom, Date dateTo, Integer step, Integer maxAge) {
        final String sql = """
                SELECT pr.date_person 
                FROM route r
                JOIN station s ON s.id_route = r.id_route
                JOIN timetable tt ON tt.id_station = s.id_station
                JOIN booking b ON b.id_arrival_timetable = tt.id_timetable
                JOIN booking_person bp ON bp.id_booking = b.id_booking
                JOIN person pr ON pr.id_person = bp.id_person
                WHERE r.id_route = :route_id
                AND b.timedate_booking BETWEEN :dateFrom AND :dateTo;
                """;
        var params = new MapSqlParameterSource();
        params.addValue("route_id", id_route);
        params.addValue("dateFrom", dateFrom);
        params.addValue("dateTo", dateTo);

        var res = jdbcTemplate.query(sql, params, new MapperStatClientAge());
        return res;

    }


}
