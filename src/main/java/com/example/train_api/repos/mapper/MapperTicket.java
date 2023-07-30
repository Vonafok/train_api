package com.example.train_api.repos.mapper;


import com.example.train_api.entity.Ticket;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.sql.SQLException;

public class MapperTicket implements RowMapper<Ticket> {

    @Override
    public Ticket mapRow(ResultSet rs, int rowNum) throws SQLException {
        Ticket ticket = new Ticket();
        ticket.setBookingId(rs.getLong("booking_id"));
        ticket.setBoughtplaceId(rs.getLong("boughtplace_id"));

        return ticket;
    }

}
