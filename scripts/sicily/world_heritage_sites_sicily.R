## UNESCO World Heritage Sites in Sicily ##

library(tidyverse); library(rvest)

# Late Baroque Towns of the Val di Noto
webpage <- read_html("http://whc.unesco.org/en/list/1024/multiple=1&unique_number=1196")
tbl_baroque <- webpage %>%
  html_nodes("table") %>%
  .[3] %>%
  html_table(fill = TRUE) %>% 
  as.data.frame() %>% 
  mutate(group = "Late Baroque Towns of the Val di Noto") %>% 
  select(name = Name...Location, group, Coordinates) 
tbl_baroque$name <- gsub("\r\n.*$", "", tbl_baroque$name)

# Arab-Norman Palermo and the Cathedral Churches of Cefalú and Monreale
webpage <- read_html("http://whc.unesco.org/en/list/1487/multiple=1&unique_number=2048")
tbl_norman <- webpage %>%
  html_nodes("table") %>%
  .[3] %>%
  html_table(fill = TRUE) %>% 
  as.data.frame() %>% 
  mutate(group = "Arab-Norman Palermo and the Cathedral Churches of Cefalú and Monreale") %>% 
  select(name = Name...Location, group, Coordinates)

# Syracuse and the Rocky Necropolis of Pantalica
webpage <- read_html("http://whc.unesco.org/en/list/1200/multiple=1&unique_number=1377")
tbl_syracuse <- webpage %>%
  html_nodes("table") %>%
  .[3] %>%
  html_table(fill = TRUE) %>% 
  as.data.frame() %>% 
  mutate(group = "Syracuse and the Rocky Necropolis of Pantalica") %>% 
  select(name = Name...Location, group, Coordinates)
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
  mutate(name = "Isole Eolie (Aeolian Islands)",
         group = "Isole Eolie (Aeolian Islands)") %>% 
  select(name, group, Coordinates)

# Archaeological Area of Agrigento
webpage <- read_html("http://whc.unesco.org/en/list/831")
tbl_agrigento <- webpage %>%
  html_nodes(".alternate div") %>%
  .[3] %>%
  html_text() %>% 
  substring(., 10)  %>% 
  as.data.frame() %>% 
  rename_(Coordinates = names(.)[1]) %>% 
  mutate(name = "Archaeological Area of Agrigento",
         group = "Archaeological Area of Agrigento") %>% 
  select(name, group, Coordinates)

# Villa Romana del Casale
webpage <- read_html("http://whc.unesco.org/en/list/832")
tbl_armerina <- webpage %>%
  html_nodes(".alternate div") %>%
  .[3] %>%
  html_text() %>% 
  substring(., 10)  %>% 
  as.data.frame() %>% 
  rename_(Coordinates = names(.)[1]) %>% 
  mutate(name = "Villa Romana del Casale",
         group = "Villa Romana del Casale") %>% 
  select(name, group, Coordinates)

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
  addProviderTiles(providers$CartoDB.Positron, group = "Road map") %>% 
  addProviderTiles(providers$Stamen.TerrainBackground, group = "Terrain") %>%
  addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>% 
  addCircleMarkers(data = filter(pts, group == "Late Baroque Towns of the Val di Noto"),
                   color = "black", stroke = TRUE, weight = 1, fillColor = "#1b9e77", fillOpacity = 0.8, radius = 5,
                   label = sprintf("<strong>%s</strong>", filter(pts, group == "Late Baroque Towns of the Val di Noto")$name) %>% lapply(htmltools::HTML),
                   group = "Late Baroque Towns of the Val di Noto") %>% 
  addCircleMarkers(data = filter(pts, group == "Arab-Norman Palermo and the Cathedral Churches of Cefalú and Monreale"),
                   color = "black", stroke = TRUE, weight = 1, fillColor = "#d95f02", fillOpacity = 0.8, radius = 5,
                   label = sprintf("<strong>%s</strong>", filter(pts, group == "Arab-Norman Palermo and the Cathedral Churches of Cefalú and Monreale")$name) %>% lapply(htmltools::HTML),
                   group = "Arab-Norman Palermo and the Cathedral Churches of Cefalú and Monreale") %>% 
  addCircleMarkers(data = filter(pts, group == "Syracuse and the Rocky Necropolis of Pantalica"),
                   color = "black", stroke = TRUE, weight = 1, fillColor = "#7570b3", fillOpacity = 0.8, radius = 5,
                   label = sprintf("<strong>%s</strong>", filter(pts, group == "Syracuse and the Rocky Necropolis of Pantalica")$name) %>% lapply(htmltools::HTML),
                   group = "Syracuse and the Rocky Necropolis of Pantalica") %>% 
  addCircleMarkers(data = filter(pts, group == "Isole Eolie (Aeolian Islands)"),
                   color = "black", stroke = TRUE, weight = 1, fillColor = "#e7298a", fillOpacity = 0.8, radius = 5,
                   label = sprintf("<strong>%s</strong>", filter(pts, group == "Isole Eolie (Aeolian Islands)")$name) %>% lapply(htmltools::HTML),
                   group = "Isole Eolie (Aeolian Islands)") %>% 
  addCircleMarkers(data = filter(pts, group == "Archaeological Area of Agrigento"),
                   color = "black", stroke = TRUE, weight = 1, fillColor = "#e6ab02", fillOpacity = 0.8, radius = 5,
                   label = sprintf("<strong>%s</strong>", filter(pts, group == "Archaeological Area of Agrigento")$name) %>% lapply(htmltools::HTML),
                   group = "Archaeological Area of Agrigento") %>% 
  addCircleMarkers(data = filter(pts, group == "Villa Romana del Casale"),
                   color = "black", stroke = TRUE, weight = 1, fillColor = "#a6761d", fillOpacity = 0.8, radius = 5,
                   label = sprintf("<strong>%s</strong>", filter(pts, group == "Villa Romana del Casale")$name) %>% lapply(htmltools::HTML),
                   group = "Villa Romana del Casale") %>% 
  addLayersControl(position = 'bottomleft',
                   baseGroups = c("Road map", "Terrain", "Satellite"),
                   overlayGroups = c("Late Baroque Towns of the Val di Noto", 
                                     "Arab-Norman Palermo and the Cathedral Churches of Cefalú and Monreale", 
                                     "Syracuse and the Rocky Necropolis of Pantalica", 
                                     "Isole Eolie (Aeolian Islands)", 
                                     "Archaeological Area of Agrigento", 
                                     "Villa Romana del Casale"),
                   options = layersControlOptions(collapsed = FALSE)) %>% 
  hideGroup(c("Late Baroque Towns of the Val di Noto", 
              "Syracuse and the Rocky Necropolis of Pantalica", 
              "Isole Eolie (Aeolian Islands)", 
              "Archaeological Area of Agrigento", 
              "Villa Romana del Casale")) %>% 
  addControl("<strong>World Heritage Sites in Sicily</strong>",
             position = 'topright')
