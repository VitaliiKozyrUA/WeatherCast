package com.kozyr.weathercast

import java.sql.Date
import java.sql.Timestamp

data class Measurement(
    val measurementId: Long,
    val stationId: Long,
    val value: Double,
    val timestamp: Timestamp,
    val parameterName: String,
    val parameterUnit: String,
    val encryptedValue: String?,
    val stationName: String,
    val locationId: Long,
    val locationName: String
)