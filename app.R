library(shiny)
library(leaflet)
library(sp)
library(tidyverse)
library(readxl)
library(sf)

# read in small subset of fema data
data <- read_excel("data/DDS2.xlsx")

# set long and lat as numerics
data$long <- as.numeric(data$long)
data$lat <- as.numeric(data$lat)

# define UI for FEMA disaster declarations app
ui <- fluidPage(
  
  # attach css style sheet
  includeCSS("styles.css"),
  
  # display map
  leafletOutput("map"),
  
  # create absolute side panel
  absolutePanel(
    id="sidebar",
    h3(titlePanel("FEMA Disaster Declarations")),
    fixed = TRUE,
    draggable = FALSE,
    top = 30,
    left = 'auto',
    right = 20,
  
  # year range input
  sliderInput("range", label = "Year Range:", 
              min=min(data$year),
              max=max(data$year),
              value=c(min(data$year),max(data$year)),
              format="####",
              sep = "")
  
  ))

# define server logic to support app
server <- function(input, output, session) {
  
  filterReact <- reactive(
    
    # reacts to year range selected
    data %>%
      filter(data$year >= input$range[1] & data$year <= input$range[2])
    )
  
  # render map
  output$map <- renderLeaflet({
    
    # updates data to match year range
    data <- filterReact()
    
    leaflet() %>%
      addTiles() %>%
      addCircleMarkers(data = data,
                       clusterOptions = markerClusterOptions(),
                       lng = ~long,
                       lat = ~lat,
                       color = ~data$color,
                       popup = ~paste("<b>Title:</b>", data$title, "<br>",
                                      "<b>Type:</b>", data$type, "<br>",
                                      "<b>Area:</b>", data$area, "<br>",
                                      "<b>State:</b>", data$state, "<br>",
                                      "<b>Year:</b>", data$year)) %>%
      # custom map theme
      addProviderTiles("Thunderforest.Landscape") %>%
      addLegend("bottomright",
                labels = unique(data$type),
                colors = unique(data$color),
                opacity = .5)
    })
}

shinyApp(ui, server)
