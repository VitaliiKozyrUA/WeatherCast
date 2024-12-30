package com.kozyr.weathercast

import org.springframework.data.jpa.repository.JpaRepository

interface FlatLocationRepository : JpaRepository<FlatLocation, Long> {

}