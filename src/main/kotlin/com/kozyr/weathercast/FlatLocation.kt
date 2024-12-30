package com.kozyr.weathercast

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table

@Entity
@Table(name = "flat_location")
data class FlatLocation(
    @Column(name = "country_id")
    val countryId: Long = 0L,
    @Column(name = "country_name")
    val countryName: String = "",
    @Column(name = "province_id")
    val provinceId: Long = 0L,
    @Column(name = "province_name")
    val provinceName: String = "",
    @Id
    @Column(name = "region_id")
    val regionId: Long = 0L,
    @Column(name = "region_name")
    val regionName: String = "",
    @Column(name = "latitude")
    val latitude: Double = 0.0,
    @Column(name = "longitude")
    val longitude: Double = 0.0,
) {
    override fun toString(): String {
        return "$countryName -> $provinceName -> $regionName"
    }
}
