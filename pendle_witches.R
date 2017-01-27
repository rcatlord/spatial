library(sp) ; library(osrm) ; library(leaflet) ; library(htmltools)

df <- read.csv(textConnection("id,name,long,lat,link
                              1,Pendle Heritage Centre,-2.21168,53.853907,https://upload.wikimedia.org/wikipedia/commons/a/a4/Pendle_Heritage_Centre%2C_Barrowford_-_geograph.org.uk_-_510629.jpg
                              2,Roughlee Old Hall,-2.2377,53.8599,https://upload.wikimedia.org/wikipedia/commons/1/14/Roughlee_-_Old_Hall_Farm_-_geograph.org.uk_-_67348.jpg
                              3,St. Mary's Church,-2.270811,53.850344,https://upload.wikimedia.org/wikipedia/commons/4/4f/The_Parish_Church_of_St_Mary%2C_Newchurch-in-Pendle_-_geograph.org.uk_-_1214694.jpg
                              4,Pendle Hill,-2.29857,53.868557,https://upload.wikimedia.org/wikipedia/commons/3/3f/Pendle_Hill_above_mist_235-0004.jpg
                              5,Downham,-2.327466,53.892725,https://upload.wikimedia.org/wikipedia/commons/8/84/Downham_Beck_%2C_bridge_and_village_-_geograph.org.uk_-_1580577.jpg
                              6,Clitheroe Castle,-2.39305,53.870803,https://upload.wikimedia.org/wikipedia/commons/c/c5/Clitheroe_Castle_-_geograph.org.uk_-_585375.jpg
                              7,Waddington,-2.41423,53.890492,https://upload.wikimedia.org/wikipedia/commons/a/ad/Waddington_-_top_of_the_village_-_geograph.org.uk_-_54065.jpg
                              8,Dunsop Bridge,-2.519552,53.945733,https://upload.wikimedia.org/wikipedia/commons/4/47/Bridge_over_the_River_Dunsop_-_geograph.org.uk_-_1017617.jpg
                              9,Jubilee Tower,-2.700038,54.009743,https://upload.wikimedia.org/wikipedia/commons/6/6b/The_Jubilee_Tower%2C_near_Lancaster_-_geograph.org.uk_-_14240.jpg
                              10,Lancaster Castle,-2.804987,54.049561,https://upload.wikimedia.org/wikipedia/commons/b/be/Lancaster_castle_and_priory.jpg
                              "))

points <- data.frame(df$lat, df$long)
names(points) <- c("X", "Y")
points$id <- 1:nrow(points)
for (i in 1:(nrow(points)-1)){
  path <- osrmRoute(src = points[i, 3:1],
                    dst = points[i+1, 3:1],
                    sp = TRUE)
  if (exists("route")){
    route <- rbind(route, path)
  }else{
    route <- path
  }
}

witch <- iconList(freq = makeIcon("witch.png", iconWidth = 50, iconHeight = 50))
popup <- paste0("<strong>", 
                df$name, "</strong>",
                "<br><br><img style='width: 150px;' src = ", df$link, ">",
                "<br><small> image: wikipedia.org </small>")

text <- HTML("<strong>On the trail of the Pendle witches</strong><br>
             <p>In the year 1612, nine men and women from Pendle Forest in Lancashire were charged with harming their neighbours by witchcraft. 
             They were taken on foot across the 45 mile trail to Lancaster Castle, judged to be guilty and sentenced to death by hanging.
             <br><br><em>Click on a witch to reveal a point along the trail.</em>")

map <- leaflet(data = df) %>%
  addProviderTiles("Stamen.Terrain", group = "Daytime",
                   options = tileOptions(minZoom = 10)) %>%
  addProviderTiles("CartoDB.DarkMatter", group = "Witching hour",
                   options = tileOptions(minZoom = 10)) %>%
  addMarkers(~long, ~lat, icon = witch, label = ~as.character(id), labelOptions = labelOptions(noHide = T, textOnly = TRUE, style=list('color'='black', 'font-size' = '16px')), popup = popup) %>% 
  addPolylines(data = route, group = ~id, color = "#FFFF00", weight = 8) %>%
  addLayersControl(position = 'bottomleft',
                   baseGroups = c("Daytime", "Witching hour"),
                   options = layersControlOptions(collapsed = FALSE)) %>% 
  addMeasure(position = "bottomleft",
             primaryLengthUnit = "meters",
             primaryAreaUnit = "sqmeters",
             activeColor = "#3D535D",
             completedColor = "#7D4479") %>% 
  addEasyButton(easyButton(
    icon='fa-home', title='Reset',
    onClick=JS("function(btn, map){ map.setView([53.945733, -2.519552], 10);}"))) %>% 
  addMiniMap(toggleDisplay = T, tiles = providers$Stamen.Watercolor) 

credits <- HTML("<h6>Credits: This interactive map was created using the <a href=https://cran.r-project.org/web/packages/leaflet/index.html>leaflet</a>, 
                <a href=https://cran.r-project.org/web/packages/sp/index.html>sp</a>, <a href=https://cran.r-project.org/web/packages/osrm/index.html>osrm</a> 
                and <a href=https://cran.r-project.org/web/packages/htmltools/index.html>htmltools</a> R packages. 
                The code can be found <a href=https://github.com/rcatlord/spatial/blob/master/pendle_witches.R>here</a>")

browsable(
  tagList(list(
    tags$head(tags$style("body{font-size: 14px;font-family:helvetica;}")),
    tags$div(style = 'height:20%;display:block;',text),
    tags$div(style = 'height:70%;display:block;',map),
    tags$div(style = 'height:10%;display:block;',credits)
  ))
)

