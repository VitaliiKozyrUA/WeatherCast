package com.kozyr.weathercast

import com.flowingcode.vaadin.addons.googlemaps.GoogleMap
import com.flowingcode.vaadin.addons.googlemaps.LatLon
import com.vaadin.componentfactory.Autocomplete
import com.vaadin.flow.component.Text
import com.vaadin.flow.component.button.Button
import com.vaadin.flow.component.grid.Grid
import com.vaadin.flow.component.html.Div
import com.vaadin.flow.component.html.Image
import com.vaadin.flow.component.orderedlayout.FlexComponent
import com.vaadin.flow.component.orderedlayout.HorizontalLayout
import com.vaadin.flow.component.orderedlayout.VerticalLayout
import com.vaadin.flow.component.popover.Popover
import com.vaadin.flow.component.select.Select
import com.vaadin.flow.router.Route
import org.springframework.beans.factory.annotation.Autowired
import java.awt.SystemColor.text
import java.sql.Timestamp

@Route("")
class MainView @Autowired constructor(
    private val flatLocationService: FlatLocationService,
    private val measurementService: MeasurementService
) : VerticalLayout() {

    private val mapPopover = createMapPopover()
    private val searchBox: Autocomplete = createSearchBox()
    private val dateSelector: Select<Timestamp> = createDateSelector()
    private val openMapButton = createOpenMapButton()
    private val weatherDataGrid = createWeatherDataGrid()
    private val noData = createNoDataLayout()

    init {
        setupLayout()
    }

    private fun setupLayout() {
        weatherDataGrid.isVisible = false

        val searchHeader = createSearchHeader()

        val logoImage = Image("https://cdn-icons-png.flaticon.com/512/9176/9176568.png", "Logo").apply {
            width = "70px"
            height = "70px"
        }
        val logoWrapper = Div(logoImage).apply {
            style.set("position", "absolute")
            style.set("top", "10")
            style.set("left", "10")
            style.set("z-index", "1000")
        }

        add(logoWrapper, searchHeader, weatherDataGrid, noData, mapPopover)
    }

    private fun createDateSelector(): Select<Timestamp> {
        return Select<Timestamp>().apply {
            label = "Вибір дати"
        }
    }

    private fun createSearchBox(): Autocomplete {
        return Autocomplete(10).apply {
            label = "Пошук погоди в регіоні"
            getElement().setAttribute("autocomplete", "new-password")
            setPlaceholder("Введіть назву регіону")

            addChangeListener { event -> handleSearchChange(event.value) }
            addAutocompleteValueAppliedListener { event ->
                if(event.value == null) return@addAutocompleteValueAppliedListener
                handleSelection(event.value.toString())
            }
            addValueClearListener {
                clearWeatherData()
                dateSelector.clear()
            }
        }
    }

    private fun createOpenMapButton(): Button {
        return Button().apply {
            text = "Вибрати на мапі"

            addClickListener {
                mapPopover.open()
            }
        }
    }

    private fun createMapPopover(): Popover {
        return Popover().apply {
            isAutofocus = true
            add(createMap())
        }
    }

    private fun handleSearchChange(input: String) {
        val locations = flatLocationService.getAllLocations()
        val locationSuggestions = locations.filter { it.regionName.contains(input, ignoreCase = true) }
        searchBox.setOptions(locationSuggestions.map { it.toString() })
    }

    private fun handleSelection(autocompleteValue: String) {
        val locations = flatLocationService.getAllLocations()
        val selectedLocation = locations.find {
            it.toString().replace(" ", "") == autocompleteValue.replace(" ", "")
        } ?: return

        val measurementsByTimestamp = measurementService.getMeasurementsById(selectedLocation.regionId)
            .groupBy { it.timestamp }

        dateSelector.setItems(
            measurementService.getMeasurementsById(selectedLocation.regionId).groupBy { it.timestamp }.keys
        )

        dateSelector.value = measurementsByTimestamp.toList().maxByOrNull { it.first }?.first

        dateSelector.addValueChangeListener { event ->
            val measurements = measurementsByTimestamp[event.value] ?: return@addValueChangeListener
            updateWeatherDataGrid(measurements, measurements.first().timestamp.toString())
        }

        val firstMeasurements = measurementsByTimestamp.toList().maxByOrNull { it.first }?.second ?: return

        val lastUpdateTimestamp = firstMeasurements.maxByOrNull { it.timestamp }?.timestamp
        updateWeatherDataGrid(firstMeasurements, lastUpdateTimestamp.toString())
    }

    private fun updateWeatherDataGrid(measurements: List<Measurement>, lastUpdate: String?) {
        setHorizontalComponentAlignment(FlexComponent.Alignment.CENTER, weatherDataGrid)
        weatherDataGrid.apply {
            isVisible = true
            noData.isVisible = false
            width = "50%"
            height = "fit-content"

            removeAllColumns()
            setItems(measurements)
            isAllRowsVisible = true

            addComponentColumn { measurement -> createMeasurementIcon(measurement.parameterName) }.setAutoWidth(true)
            addColumn { it.parameterName }.setAutoWidth(true)
            addColumn { "${it.value} ${it.parameterUnit}" }.setAutoWidth(true)
        }
    }

    private fun createMeasurementIcon(parameterName: String): Image {
        val iconUrl = when (parameterName) {
            "Температура" -> "https://cdn-icons-png.flaticon.com/512/1843/1843544.png"
            "Вологість" -> "https://cdn-icons-png.flaticon.com/512/219/219816.png"
            "Тиск повітря" -> "https://static-00.iconduck.com/assets.00/pressure-icon-2048x2048-ucftza2t.png"
            "Хмарність" -> "https://www.freeiconspng.com/thumbs/cloud-icon/cloud-icon-17.png"
            "Напрямок вітру" -> "https://cdn-icons-png.flaticon.com/512/3920/3920848.png"
            "Сила вітру" -> "https://cdn-icons-png.flaticon.com/512/54/54298.png"
            "Радіаційний фон" -> "https://cdn-icons-png.flaticon.com/512/1087/1087050.png"
            "Забрудненість шкідливими домішками" -> "https://cdn-icons-png.flaticon.com/512/4978/4978501.png"
            else -> ""
        }
        return Image(iconUrl, "Icon").apply {
            width = "50px"
            height = "50px"
        }
    }

    private fun clearWeatherData() {
        weatherDataGrid.isVisible = false
        noData.isVisible = true
    }

    private fun createWeatherDataGrid(): Grid<Measurement> {
        return Grid()
    }

    private fun createNoDataLayout(): VerticalLayout {
        return VerticalLayout().apply {
            width = "fit-content"
            height = "fit-content"
            setHorizontalComponentAlignment(FlexComponent.Alignment.CENTER, this)

            val image =
                Image("https://icons.veryicon.com/png/o/business/financial-category/no-data-6.png", "Icon").apply {
                    width = "150px"
                    height = "150px"
                }
            add(image)
            add(Text("Регіон не вибрано"))
        }
    }

    private fun createSearchHeader(): HorizontalLayout {
        return HorizontalLayout().apply {
            setWidthFull()
            alignItems = FlexComponent.Alignment.CENTER
            justifyContentMode = FlexComponent.JustifyContentMode.CENTER
            add(searchBox)
            add(openMapButton)
            add(dateSelector)
        }
    }

    private fun createMap(): GoogleMap {
        return GoogleMap("AIzaSyDa4bgyvf7nWJCL2CfAdFjf5tj7S3bVjxk", null, null).apply {
            mapType = GoogleMap.MapType.HYBRID
            center = LatLon(49.00760777, 31.4564755)
            zoom = 6
            width = "80vw"
            height = "80vh"

            val locations = flatLocationService.getAllLocations().filterNot { it.latitude == 0.0 }
            for (location in locations) {
                addMarker(
                    location.regionName,
                    LatLon(location.latitude, location.longitude),
                    false,
                    ""
                ).addClickListener {
                    handleSelection(location.toString())
                    searchBox.value = location.toString()
                    mapPopover.close()
                }
            }
        }
    }
}
