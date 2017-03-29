library(dplyr); library(leaflet) ; library(rgdal)

uk <- readOGR("uk.geojson", "OGRGeoJSON")

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
  addPolygons(data = uk, fillColor = ~pal(Pct_Leave), weight = 0.5, opacity = 1, color = "white", fillOpacity = 0.8,
              highlight = highlightOptions(weight = 3, color = "#FFFF00", fillOpacity = 0.7, bringToFront = TRUE),
              label = labels,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "12px", direction = "auto")) %>% 
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
                                    <a href='https://github.com/rcatlord/spatial/blob/master/leavers/leavers.R'>code</a></small>")) %>% 
  addEasyButton(
    easyButton(
    icon='fa-snowflake-o', title='Reset', position = "topleft",
    onClick=JS("function(btn, map){ map.setView([54.898260, -2.935810], 6);}")))
