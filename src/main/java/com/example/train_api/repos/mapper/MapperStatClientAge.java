package com.example.train_api.repos.mapper;


import org.springframework.jdbc.core.RowMapper;

import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;

public class MapperStatClientAge implements RowMapper<LocalDate> {
    @Override
    public LocalDate mapRow(ResultSet rs, int rowNum) throws SQLException {
        return rs.getDate("date_person").toLocalDate();
    }
}
