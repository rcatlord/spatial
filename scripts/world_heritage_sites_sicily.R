## UNESCO World Heritage Sites in Sicily ##

library(tidyverse); library(rvest)

# Late Baroque Towns of the Val di Noto
webpage <- read_html("http://whc.unesco.org/en/list/1024/multiple=1&unique_number=1196")
tbl_baroque <- webpage %>%
  html_nodes("table") %>%
  .[3] %>%
  html_table(fill = TRUE) %>% 
  as.data.frame() %>% 
  select(name = Name...Location, Coordinates) 
tbl_baroque$name <- gsub("\r\n.*$", "", tbl_baroque$name)

# Arab-Norman Palermo and the Cathedral Churches of Cefalú and Monreale
webpage <- read_html("http://whc.unesco.org/en/list/1487/multiple=1&unique_number=2048")
tbl_norman <- webpage %>%
  html_nodes("table") %>%
  .[3] %>%
  html_table(fill = TRUE) %>% 
  as.data.frame() %>% 
  select(name = Name...Location, Coordinates)

# Syracuse and the Rocky Necropolis of Pantalica
webpage <- read_html("http://whc.unesco.org/en/list/1200/multiple=1&unique_number=1377")
tbl_syracuse <- webpage %>%
  html_nodes("table") %>%
  .[3] %>%
  html_table(fill = TRUE) %>% 
  as.data.frame() %>% 
  select(name = Name...Location, Coordinates)
tbl_syracuse$name <- gsub("\r\n.*$", "", tbl_syracuse$name)

# Isole Eolie (Aeolian Islands)
webpage <- read_html("http://whc.unesco.org/en/list/908/")
tbl_aeolian <- webpage %>%
  html_nodes(".alternate div") %>%
  .[3] %>%
  html_text() %>% 
  substring(., 10)  %>% 
  as.data.frame() %>% 
  rename_(Coordinates = names(.)[1]) %>% 
  mutate(name = "Isole Eolie (Aeolian Islands)") %>% 
  select(name, Coordinates)

# Archaeological Area of Agrigento
webpage <- read_html("http://whc.unesco.org/en/list/831")
tbl_agrigento <- webpage %>%
  html_nodes(".alternate div") %>%
  .[3] %>%
  html_text() %>% 
  substring(., 10)  %>% 
  as.data.frame() %>% 
  rename_(Coordinates = names(.)[1]) %>% 
  mutate(name = "Archaeological Area of Agrigento") %>% 
  select(name, Coordinates)

# Villa Romana del Casale
webpage <- read_html("http://whc.unesco.org/en/list/832")
tbl_armerina <- webpage %>%
  html_nodes(".alternate div") %>%
  .[3] %>%
  html_text() %>% 
  substring(., 10)  %>% 
  as.data.frame() %>% 
  rename_(Coordinates = names(.)[1]) %>% 
  mutate(name = "Villa Romana del Casale") %>% 
  select(name, Coordinates)

# Bind rows and convert coordinates
library(measurements)
df <- bind_rows(tbl_baroque, tbl_norman, tbl_syracuse, tbl_aeolian, tbl_agrigento, tbl_armerina)  %>% 
  mutate(Coordinates = substring(Coordinates, 2)) %>% 
  separate(Coordinates, c("lat", "long"), sep = "E") %>% 
  mutate(long = as.double(conv_unit(long, from = 'deg_min_sec', to = 'dec_deg')),
         lat = as.double(conv_unit(lat, from = 'deg_min_sec', to = 'dec_deg')))
# write.csv(df, "world_heritage_sites_sicily.csv")

# Project points
library(sf)
pts <- st_as_sf(df, coords = c("long", "lat"), crs = 4326)

# Plot
library(leaflet)
leaflet() %>%
  setView(14.015356, 37.599994, zoom = 8) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>% 
  addAwesomeMarkers(data = pts, label = ~name)
