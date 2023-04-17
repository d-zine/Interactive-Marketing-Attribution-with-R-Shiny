#map3.R
library(leaflet)
library(yelpr)
library(leaflet.extras)
library(dplyr)

# Set Yelp API key and search parameters
api_key <- "7C03umuaSK76u77uUzu3HXytCvr_g3BD8oskFnyULthDGDnB45y9MQR2CfEKtjA1ZoaI_XFYQAC-BJ5o87qAj3RT-oEMTXXrGYG8OJlCiF8RE3eUrxbtO1aCtW48ZHYx"
search_categories <- "coffee,tea"
search_location <- "Philadelphia, PA"
search_limit <- 50

# Call Yelp API and extract business data
yelp_results <- business_search(api_key = api_key,
                                categories = search_categories,
                                location = search_location,
                                limit = search_limit)
yelp_businesses <- yelp_results$businesses


# Load Starbucks data and filter to necessary columns
starbucks_data <- read.csv("starbucks_data.csv")
starbucks_data <- starbucks_data %>%select(`latitude`, `longitude`,`dba`,`store_name`, `address`, `city`, `state`, `zip_code`)

# Add a new column to the dataset indicating whether each location should be red
starbucks_data$color <- ifelse(starbucks_data$store_name == "Proposed New Starbucks Location", "orange", "#00704A")

# Create a new map object
map3 <- leaflet(height = 800, width = 1000) %>%
  addProviderTiles("CartoDB.Voyager")  %>%
  setView(lng = -75.1652, lat = 39.9526, zoom = 12)

map3 <- addCircleMarkers(map3, 
                         lng = -75.1800, 
                         lat = 39.9528, 
                         color = "orange", 
                         fillColor = "orange", # Set the fillColor to red
                         radius = 8, 
                         popup = "<b>Proposed New Starbucks Location:</b> <br>2400 Chestnut",
                         options = markerOptions(clickable = TRUE, 
                                                 title = "Proposed New Starbucks Location",
                                                 opacity = 1))
# Add circle markers for Starbucks locations
map3 <- map3 %>%
  addCircleMarkers(
    data = starbucks_data,
    radius = 4,
    fillColor = starbucks_data$color,
    color = "white",
    fillOpacity = 0.8,
    stroke = TRUE,
    weight = 2,
    labelOptions = labelOptions(noHide = TRUE, textOnly = TRUE, direction = "auto"),
    popup = paste(starbucks_data$dba, "<br>",
                  starbucks_data$store_name, "<br>",
                  starbucks_data$address, "<br>",
                  starbucks_data$city, 
                  starbucks_data$state, 
                  starbucks_data$zip_code, "<br>")
  )

# Add heatmap layer to show the density of Starbucks locations
map3 <- map3 %>%
  addHeatmap(
    data = starbucks_data,
    lng = ~longitude,
    lat = ~latitude,
    blur = 20,
    max = 0.5,
    radius = 8
  )


# Add blue markers for Yelp businesses
# Add steelblue circle markers for Yelp businesses
map3 <- map3 %>%
  addCircleMarkers(
    data = yelp_businesses,
    lat = ~coordinates$latitude,
    lng = ~coordinates$longitude,
    fillColor='violet',
    radius = 4,
    color='white',
    fillOpacity = 0.8,
    stroke = TRUE,
    weight = 2,
    popup = ~paste("<strong>Starbucks Competition </strong>","<br>",
                   "<strong>Name:</strong>", name, "<br>",
                   "<strong>Address:</strong>", location$address1, "<br>",
                   "<strong>Rating:</strong>", rating, "<br>",
                   "<strong>Price:</strong>", price, "<br>",
                   "<strong>Categories:</strong>", categories[[1]]$title,",",categories[[2]]$title,",",categories[[3]]$title, "<br>",
                   "<a href=", url, " target='_blank'>", "View on Yelp", "</a>"))


# Show the map
map3