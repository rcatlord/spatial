library(dplyr); library(leaflet) ; library(rgdal) ; library(rmapshaper) ; library(ggmap)

uk <- readOGR("uk.geojson", "OGRGeoJSON")
uk_simplified <- ms_simplify(uk, keep = 0.1)

cities <- data.frame(
  city = as.character(c("Aberdeen","Aldershot","Barnsley","Basildon","Belfast","Birkenhead","Birmingham",
                        "Blackburn","Blackpool","Bournemouth","Bradford","Brighton","Bristol","Burnley","Cambridge",
                        "Cardiff","Chatham","Coventry","Crawley","Derby","Doncaster","Dundee","Edinburgh",
                        "Exeter","Glasgow","Gloucester","Huddersfield","Hull","Ipswich","Leeds","Leicester",
                        "Liverpool","London","Luton","Manchester","Mansfield","Middlesbrough","Milton Keynes",
                        "Newcastle","Newport","Northampton","Norwich","Nottingham","Oxford","Peterborough",
                        "Plymouth","Portsmouth","Preston","Reading","Sheffield","Slough","Southampton",
                        "Southend","Stoke","Sunderland","Swansea","Swindon","Telford","Wakefield",
                        "Warrington","Wigan","Worthing","York")))
cities <- mutate(cities, address = paste(city, ", United Kingdom", sep = '')) %>% 
  mutate_geocode(address, source = "google")

bins <- c(0, 29, 39, 49, 59, 69, Inf)
pal <- colorBin("Blues", domain = uk$Pct_Leave, bins = bins)

labels <- sprintf(
  "<strong>%s</strong><br/>%g%% Leave",
  uk$name, round(uk$Pct_Leave, 1)
) %>% lapply(htmltools::HTML)

leaflet() %>%
  setView(lng = 13.399340, lat = 52.516823, zoom = 4) %>%
  addProviderTiles(providers$Stamen.Watercolor) %>%
  addProviderTiles(providers$Stamen.TonerLines,
                   options = providerTileOptions(opacity = 0.35)) %>%
  addTiles(urlTemplate = "", 
           attribution = 'Contains National Statistics data © Crown copyright and database right [2017] and OS data © Crown copyright and database right [2017].') %>% 
  addPolygons(data = uk_simplified, fillColor = ~pal(Pct_Leave), weight = 0.5, opacity = 1, color = "white", fillOpacity = 0.8,
              highlight = highlightOptions(weight = 3, color = "#FFFF00", fillOpacity = 0.7, bringToFront = TRUE),
              label = labels,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "12px", direction = "auto")) %>% 
  addCircleMarkers(data = cities, ~lon, ~lat, radius = 4, color = "black", stroke = TRUE, fillColor = "white", fillOpacity = 1, weight = 1,
                   label = ~city, labelOptions = labelOptions(noHide = T, direction = 'top', offset = c(0, -25), textOnly = TRUE,
                                                              style=list(
                                                                'color'='white',
                                                                'text-shadow'= '0px 1px 1px #000000',
                                                                'font-family'= 'Helvetica',
                                                                'font-size' = '10px')),
                   group = "Cities") %>% 
  addLayersControl(position = 'topleft',
                   overlayGroups = "Cities",
                   options = layersControlOptions(collapsed = FALSE)) %>%
  hideGroup("Cities") %>% 
  addLegend(position = "bottomleft",
            colors = RColorBrewer::brewer.pal(6, "Blues"),
            labels = c("0-29%", "30-39%", "40-49%", "50-59%", "60-69%", "70% or more"),
            opacity = 0.8,
            title = "% voting to Leave") %>% 
  addLegend(position = "topright",
            colors = NULL,
            labels = NULL,
            title = htmltools::HTML("EU referendum results<br><em><small>23 June 2016</em></small>")) %>% 
  addLegend(position = "bottomright",
            colors = NULL,
            labels = NULL,
            title = htmltools::HTML("<small><a href='http://www.electoralcommission.org.uk/__data/assets/file/0014/212135/EU-referendum-result-data.csv'>Raw data</a> and
                                    <a href='https://github.com/rcatlord/spatial/blob/master/article50/leavers.R'>code</a></small>")) %>% 
  addEasyButton(
    easyButton(
      icon='fa-snowflake-o', title='Reset', position = "topleft",
      onClick=JS("function(btn, map){ map.setView([54.898260, -2.935810], 6);}")))

