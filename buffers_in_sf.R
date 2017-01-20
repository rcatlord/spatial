install.packages(c('sf'), type='mac.binary.mavericks', dependencies=T)

library(leaflet) ; library(sf) ; library(magrittr)

buffer <- c(-0.126951, 51.519420) %>%
  st_point() %>%
  st_sfc(crs = 4326) %>%
  st_transform(27700) %>%
  st_buffer(dist = 250) %>%
  st_transform(4326) %>%
  as("Spatial")

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(data = buffer, color = "orange", fillOpacity = 0.3)
