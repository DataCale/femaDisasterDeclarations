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
  
  # attach css style sheet
  includeCSS("styles.css"),
  
  # display map
  leafletOutput("map"),
  
  # create absolute side panel
  absolutePanel(
    id="sidebar",
    titlePanel(h2("FEMA Disaster Declarations")),
    fixed = TRUE,
    draggable = FALSE,
    top = 30,
    left = 'auto',
    right = 20,
  
  # year range input
  sliderInput(inputId = "range", label = "Year Range:", 
              min=min(data$fyDeclared),
              max=max(data$fyDeclared),
              value=c(min(data$fyDeclared),max(data$fyDeclared)),
              format="####",
              sep = "")
  ))

# define server logic to support app
server <- function(input, output, session) {
  
  # reacts to year range selected
  filterReact <- reactive(
    data %>%
      filter(data$fyDeclared >= input$range[1] & data$fyDeclared <= input$range[2])
  )
  
  # render map
  output$map <- renderLeaflet({
    
    # updates data to match year range
    data <- filterReact()
    
    leaflet() %>%
      addTiles() %>%
      addCircleMarkers(data = data,
                       lng = ~long,
                       lat = ~lat,
                       color = ~data$color,
                       popup = ~paste("<b>Title:</b>", data$title, "<br>",
                                      "<b>Type:</b>", data$incidentType, "<br>",
                                      "<b>Area:</b>", data$declaredCountyArea,
                                      "<b>State:</b>", data$state, "<br>",
                                      "<b>Year:</b>", data$fyDeclared)) %>%
      # custom map theme
      addProviderTiles("Thunderforest.Landscape") %>%
      addLegend("bottomright",
                labels = unique(data$incidentType),
                colors = unique(data$color),
                opacity = .5)
    
  })
  
}

shinyApp(ui, server)
