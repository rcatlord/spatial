### Anti-Trump and Pro-Remain - the same? ###

## Trump state visit petition map ##

# petition data
library(jsonlite)
url <- fromJSON("https://petition.parliament.uk/petitions/171928.json")
petition <- as.data.frame(url$data$attributes$signatures_by_constituency)

# 2015 general election data
library(httr) ; library(readxl) ; library(dplyr) ;
url <- "http://www.electoralcommission.org.uk/__data/assets/excel_doc/0011/189623/2015-UK-general-election-data-results-WEB.xlsx"
GET(url, write_disk(election <- tempfile(fileext = ".xlsx")))
election <- read_excel(election, sheet = 3) %>% 
  select(ons_code = `Constituency ID`, votes_cast  = `Valid Votes`)
petition <- merge(petition, election, by="ons_code") %>%
  mutate(percent = (signature_count/votes_cast)*100)

# constituency boundaries
library(rgdal)
url <- "http://geoportal.statistics.gov.uk/datasets/b0f309e493cf4b9ba0d343eebb97b5ee_3.geojson"
constituencies <- readOGR(dsn = url, layer = "OGRGeoJSON")
names(constituencies@data)[2] <- "ons_code"
constituencies@data <- data.frame(constituencies@data, petition[match(constituencies@data$ons_code, petition$ons_code),])

# map
library(RColorBrewer) ; library(classInt)
palette <- brewer.pal(5, "YlGnBu")
classes <- classIntervals(round(constituencies$percent, 1), n = 5, style = "quantile")
constituencies$cols <- findColours(classes, palette)
breaks <- classes$brks

library(leaflet)
petition_map <- leaflet() %>% 
  setView(lng = -2.935810, lat = 54.898260, zoom = 5) %>%
  addPolygons(data = constituencies, stroke = TRUE, color = "grey", weight = 0.5, opacity = 1,
              fill = TRUE, fillColor = ~cols, fillOpacity = 0.8, 
              label = ~stringr::str_c(name, ': ', paste(round(percent,digits=1),"%",sep=""))) %>%
  addLegend(position = "bottomleft",
            colors = RColorBrewer::brewer.pal(5, "YlGnBu"),
            labels = c("Smallest", "", "", "", "Largest"),
            opacity = 0.8,
            title = htmltools::HTML("Signatories per <em>constituency</em><br>as a % of votes cast at 2015<br>general election")) %>% 
  addLegend(position = "topright",
            colors = NULL,
            labels = NULL,
            title = htmltools::HTML("<a href='https://petition.parliament.uk/petitions/171928'>Petition against Trump's state visit</a><br><small>as of 15:45, 1 February 2017")) %>% 
  addEasyButton(easyButton(
    icon='fa-home', title='Reset',
    onClick=JS("function(btn, map){ map.setView([54.898260, -2.935810], 5);}"))) %>% 
  htmlwidgets::onRender(
    " function(el, t) {
    var myMap = this;
    myMap._container.style['background'] = '#ffffff';
    }")

## Pro-Remain referendum map ##

# EU referendum results
referendum <- read.csv(url("http://www.electoralcommission.org.uk/__data/assets/file/0014/212135/EU-referendum-result-data.csv")) %>% 
  select(ons_code = `Area_Code`, Pct_Remain)

# local authority boundaries
url <- "http://geoportal.statistics.gov.uk/datasets/3943c2114d764294a7c0079c4020d558_4.geojson"
local_authorities <- readOGR(dsn = url, layer = "OGRGeoJSON")
names(local_authorities@data)[2] <- "ons_code"
local_authorities@data <- data.frame(local_authorities@data, referendum[match(local_authorities@data$ons_code, referendum$ons_code),])

# map
palette <- brewer.pal(5, "YlGnBu")
classes <- classIntervals(round(local_authorities$Pct_Remain, 1), n = 5, style = "quantile")
local_authorities$cols <- findColours(classes, palette)
breaks <- classes$brks

referendum_map <- leaflet() %>%
  setView(lng = -2.935810, lat = 54.898260, zoom = 5) %>% 
  addPolygons(data = local_authorities, stroke = TRUE, color = "grey", weight = 0.5, opacity = 1,
              fill = TRUE, fillColor = ~cols, fillOpacity = 0.8, 
              label = ~stringr::str_c(lad14nm, ': ', paste(round(Pct_Remain,digits=1),"%",sep=""))) %>% 
  addLegend(position = "bottomleft",
            colors = RColorBrewer::brewer.pal(5, "YlGnBu"),
            labels = c("Smallest", "", "", "", "Largest"),
            opacity = 0.8,
            title = htmltools::HTML("% voting to remain<br>by <em>local authority</em>")) %>% 
  addLegend(position = "topright",
            colors = NULL,
            labels = NULL,
            title = htmltools::HTML("<a href='http://www.electoralcommission.org.uk/find-information-by-subject/elections-and-referendums/past-elections-and-referendums/eu-referendum/electorate-and-count-information'> EU referendum results </a><br><small>23 June 2016")) %>% 
  addEasyButton(easyButton(
    icon='fa-home', title='Reset',
    onClick=JS("function(btn, map){ map.setView([54.898260, -2.935810], 5);}"))) %>% 
  htmlwidgets::onRender(
    " function(el, t) {
    var myMap = this;
    myMap._container.style['background'] = '#ffffff';
    }")

# side-by-side
library(mapview)
map <- mapview::sync(petition_map, referendum_map)

# text
text <- htmltools::HTML("<h2>Anti-Trump and Pro-Remain - the same?</h2>")

credits <- htmltools::HTML("<small>Contains National Statistics data © Crown copyright and database right [2017] and OS data © Crown copyright and database right [2017].</small>
                           <br><br>The R code used to create these maps can be found <a href=https://github.com/rcatlord/spatial/blob/master/anti-trump_pro-remain.R>here</a>")

# final output
library(htmltools)
browsable(
  tagList(list(
    tags$head(tags$style("body{font-size: 14px;font-family:helvetica;}")),
    tags$div(style = 'height:20%;display:block;', text),
    tags$div(style = 'height:70%;display:block;', map),
    tags$div(style = 'height:10%;display:block;', credits)
  ))
)
