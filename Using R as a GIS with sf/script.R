## Using R as a GIS with sf ##

# Load the necessary packages
library(sf)
library(tidyverse)
library(tmap)
library(leaflet)

## Reading spatial data
# Load the Greater Manchester ward boundary GeoJSON
bdy <- st_read("wards.geojson", stringsAsFactors = F, quiet = TRUE)
class(bdy)
as.tibble(bdy)

# Rename and discard variables
bdy <- select(bdy, ward = wd16nm, 
              census_code = wd16cd, 
              district = lad16nm, geometry) 
as.tibble(bdy)

# Plot the ward boundaries
ggplot() +
  geom_sf(data = bdy, aes(fill = district), colour = "white") +
  scale_fill_brewer(palette = "Set3") +
  labs(fill = "District",
       title = "Greater Manchester wards",
       caption = "Contains OS data © Crown copyright and database right (2017)") +
  theme_void()

# Load the crime data
points <- read_csv("2017-02-greater-manchester-street.csv")
points

# Rename the variables and remove incidents with missing coordinates
points <- points %>% 
  select(category = `Crime type`,
         long = Longitude,
         lat = Latitude) %>% 
  mutate(category = factor(category)) %>% 
  filter(!is.na(long))
points

## Reprojecting
# Convert crimes to an `sf` object with a WGS84 (EPSG:4326) projection
points <- points %>% 
  st_as_sf(crs = 4326, coords = c("long", "lat"))
st_geometry(points)

# Reproject the ward boundaries to CRS WGS84
bdy <- bdy %>% 
  st_transform(crs = 4326)
st_geometry(bdy)

## Clipping and spatial joins     
points_sf <- st_join(points, bdy, join = st_within, left = FALSE)
class(points_sf)

# Calculate the frequency of Burglary offences by district in descending order
points_sf %>% 
  filter(category == "Burglary") %>% 
  group_by(district) %>% 
  summarise(n = n()) %>% 
  arrange(desc(n)) %>% 
  mutate(percent = round(n/sum(n)*100, 1))

## Points in polygon       
bdy_sf <- points %>% 
  filter(category == "Burglary") %>%  
  st_join(bdy, ., left = FALSE) %>% 
  count(ward)
head(bdy_sf)

## Choropleth mapping using `tmap`
tm_shape(bdy_sf) + 
  tm_fill(col = "n", n = 5, title = 'Frequency') +
  tm_borders() + 
  tm_compass(size = 4, position = c("right", "top")) +
  tm_scale_bar() +
  tm_credits("Contains OS data © Crown copyright and database right (2017)", position = c("center", "bottom")) +
  tm_layout("Burglary in Greater Manchester\n February 2017", legend.title.size = 0.8)

## Choropleth mapping using `leaflet`
pal <- colorBin("Blues", domain = bdy_sf$n, bins = 5)

leaflet(bdy_sf) %>% 
  addTiles(urlTemplate = "http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png", 
           attribution = '&copy; <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2017)</a>') %>% 
  addPolygons(fillColor = ~pal(n), fillOpacity = 0.8,
              weight = 2, opacity = 1, color = "grey",
              label = ~as.character(ward)) %>% 
  addLegend(pal = pal, values = ~n, opacity = 0.7, 
            title = 'Burglaries (Feb-17)', position = "bottomleft")

## Writing spatial data
st_write(bdy_sf, dsn = "bdy.shp", layer = "bdy.shp", driver = "ESRI Shapefile")