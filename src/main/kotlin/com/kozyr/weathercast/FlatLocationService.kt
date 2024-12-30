package com.kozyr.weathercast

import org.springframework.stereotype.Service

@Service
class FlatLocationService(private val flatLocationRepository: FlatLocationRepository) {

    fun getAllLocations(): List<FlatLocation> {
        return flatLocationRepository.findAll()
    }
}