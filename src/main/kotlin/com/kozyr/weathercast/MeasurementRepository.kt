package com.kozyr.weathercast

import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.stereotype.Repository
import java.sql.Date
import java.sql.Timestamp

@Repository
class MeasurementRepository(private val jdbcTemplate: JdbcTemplate) {

    fun findMeasurementsByLocation(locationId: Long): List<Measurement> {
        val sql = """
            WITH DailyMeasurements AS (
                SELECT 
                    m.measurement_id,
                    m.station_id,
                    m.value,
                    m.timestamp,
                    m.parameter_name,
                    m.parameter_unit,
                    m.encrypted_value,
                    s.name AS station_name,
                    l.location_id,
                    l.name AS location_name,
                    ROW_NUMBER() OVER (
                        PARTITION BY DATE(m.timestamp), m.station_id, m.parameter_name 
                        ORDER BY m.timestamp ASC
                    ) AS row_num
                FROM 
                    measurement m
                JOIN 
                    station s ON m.station_id = s.station_id
                JOIN 
                    location l ON s.location_id = l.location_id
                WHERE 
                    l.location_id = ?
            )
            SELECT 
                measurement_id,
                station_id,
                value,
                timestamp,
                parameter_name,
                parameter_unit,
                encrypted_value,
                station_name,
                location_id,
                location_name
            FROM 
                DailyMeasurements
            WHERE 
                row_num = 1;
        """
        return jdbcTemplate.query(sql, arrayOf(locationId)) { rs, _ ->
            Measurement(
                measurementId = rs.getLong("measurement_id"),
                stationId = rs.getLong("station_id"),
                value = rs.getDouble("value"),
                timestamp = Timestamp.valueOf(rs.getString("timestamp")),
                parameterName = rs.getString("parameter_name"),
                parameterUnit = rs.getString("parameter_unit"),
                encryptedValue = rs.getString("encrypted_value"),
                stationName = rs.getString("station_name"),
                locationId = rs.getLong("location_id"),
                locationName = rs.getString("location_name")
            )
        }
    }
}