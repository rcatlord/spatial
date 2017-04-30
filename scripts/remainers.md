```{r, echo=FALSE, message=FALSE, warning=FALSE, out.width='100%', fig.height=7}
library(dplyr); library(ggmap); library(leaflet) ; library(rgdal)

referendum <- read.csv(url("http://www.electoralcommission.org.uk/__data/assets/file/0014/212135/EU-referendum-result-data.csv")) %>% 
  select(ons_code = `Area_Code`, Pct_Remain, Pct_Leave)

url <- "http://geoportal.statistics.gov.uk/datasets/3943c2114d764294a7c0079c4020d558_4.geojson"
local_authorities <- readOGR(dsn = url, layer = "OGRGeoJSON", verbose = FALSE)
names(local_authorities@data)[2] <- "ons_code"
local_authorities@data <- data.frame(local_authorities@data, referendum[match(local_authorities@data$ons_code, referendum$ons_code),])

cities <- data.frame(
  city = as.character(c("Aberdeen","Aldershot","Barnsley","Basildon","Birkenhead","Birmingham",
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
pal <- colorBin("BuGn", domain = local_authorities$Pct_Remain, bins = bins)

labels <- sprintf(
  "<strong>%s</strong><br/>%g%% Remain",
  local_authorities$lad14nm, round(local_authorities$Pct_Remain, 1)
) %>% lapply(htmltools::HTML)

leaflet() %>%
  setView(lng = -2.935810, lat = 54.898260, zoom = 6) %>% 
  addTiles(urlTemplate = "", 
           attribution = '<small>Contains National Statistics data © Crown copyright and database right [2017] and OS data © Crown copyright and database right [2017].</small>') %>% 
  addPolygons(data = local_authorities, fillColor = ~pal(Pct_Remain), weight = 0.5, opacity = 1, color = "white", fillOpacity = 0.8,
              highlight = highlightOptions(weight = 3, color = "#FFFF00", fillOpacity = 0.7, bringToFront = TRUE),
              label = labels,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "12px", direction = "auto")) %>% 
  addCircleMarkers(data = cities, ~lon, ~lat, radius = 4, color = "black", stroke = TRUE, fillColor = "white", fillOpacity = 1, weight = 1,
                   label = ~city, labelOptions = labelOptions(noHide = T, direction = 'top', offset = c(0, -25), textOnly = TRUE, textsize = '10px')) %>% 
  addLegend(position = "bottomleft",
            colors = RColorBrewer::brewer.pal(6, "BuGn"),
            labels = c("0-29%", "30-39%", "40-49%", "50-59%", "60-69%", "70% or more"),
            opacity = 0.8,
            title = "% voting to remain") %>% 
  addLegend(position = "topright",
            colors = NULL,
            labels = NULL,
            title = htmltools::HTML("EU referendum results<br><em><small>23 June 2016</em></small><br><br><small>Data: <a href='http://www.electoralcommission.org.uk/find-information-by-subject/elections-and-referendums/past-elections-and-referendums/eu-referendum/electorate-and-count-information'>The Electoral Commission</a></small>")) %>% 
  addEasyButton(easyButton(
    icon='fa-home', title='Reset',
    onClick=JS("function(btn, map){ map.setView([54.898260, -2.935810], 6);}"))) %>% 
  htmlwidgets::onRender(
    " function(el, t) {
    var myMap = this;
    myMap._container.style['background'] = '#ffffff';
    }")
```
