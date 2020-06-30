library(shiny)
library(leaflet)
library(sp)
library(tidyverse)
library(readxl)

# read in small subset of fema data
data <- read_excel("data/sampleDDS.xlsx")

# make year a numeric
data$fyDeclared <- as.numeric(data$fyDeclared)

# set long and lat as numerics
data$long <- as.numeric(data$long)
data$lat <- as.numeric(data$lat)

# define UI for FEMA disaster declarations app
ui <- fluidPage(
  
  # display map
  leafletOutput("map"),
  
  # create absolute side panel
  absolutePanel(
    titlePanel("FEMA Disaster Declarations"))
  )

# define server logic to support app
server <- function(input, output, session) {
  
  # render map
  output$map <- renderLeaflet({ 
    
    leaflet() %>%
      addTiles() %>%
      addCircleMarkers(data = data,
                       lng = ~long,
                       lat = ~lat,
                       popup = ~paste("<b>Title:</b>", data$title, "<br>",
                                      "<b>Type:</b>", data$incidentType, "<br>",
                                      "<b>Area:</b>", data$declaredCountyArea,
                                      "<b>State:</b>", data$state, "<br>",
                                      "<b>Year:</b>", data$fyDeclared)) %>%
      # custom map theme
      addProviderTiles("Thunderforest.Landscape")
    
  })
  
}

shinyApp(ui, server)