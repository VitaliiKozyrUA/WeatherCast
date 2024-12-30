package com.kozyr.weathercast

import org.springframework.stereotype.Service

@Service
class MeasurementService(private val measurementRepository: MeasurementRepository) {

    fun getMeasurementsById(locationId: Long): List<Measurement> {
        return measurementRepository.findMeasurementsByLocation(locationId)
    }
}