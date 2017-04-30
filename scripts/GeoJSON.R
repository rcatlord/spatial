library(leaflet) ; library(jsonlite) ; library(htmltools)

geojson <- readLines("https://data.cdrc.ac.uk/dataset/35c1fb9d-df77-4261-9861-14fc75d6f26a/resource/da9e9f72-4d11-46e9-b33a-7a5e24b83d0c/download/cdrc-2013-mid-year-total-population-estimates-geodata-pack-lsoa-manchester-e08000003.geojson", warn = FALSE) %>%
    paste(collapse = "\n") %>%
    fromJSON(simplifyVector = FALSE)  
                   
population <- sapply(geojson$features, function(feat) {
  feat$properties$value
})

pal <- colorNumeric(
  palette = "YlOrRd",
  domain = population
)

geojson$features <- lapply(geojson$features, function(feat) {
  feat$properties$style <- list(fillColor = pal(feat$properties$value))
  feat
})

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>% 
  setView(lng = -2.222003, lat = 53.438074, zoom = 11) %>% 
  addGeoJSON(geojson, fillOpacity = 0.7, stroke = FALSE) %>%
  addLegend(colors = NULL, values = NULL, labels = NULL,
            title = HTML("<small>Contains National Statistics data © Crown copyright and database right 2015;<br> 
             Contains Ordnance Survey data © Crown copyright and database right 2015;<br>
                         Data provided by the <a href=https://data.cdrc.ac.uk/dataset/cdrc-2013-mid-year-total-population-estimates-geodata-pack-lsoa-manchester-e08000003>ESRC Consumer Data Research Centre</a>"),
                         position = 'bottomleft') %>% 
  addLegend(pal = pal, values = population, opacity = 1,
            title = HTML("ONS total population estimates<br> by LSOA (2013)"),
            position = 'bottomright')
