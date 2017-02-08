library(tmap) ; library(dplyr) ; library(rgdal)

# EU referendum results
referendum <- read.csv(url("http://www.electoralcommission.org.uk/__data/assets/file/0014/212135/EU-referendum-result-data.csv")) %>% 
  select(ons_code = `Area_Code`, Electorate, Pct_Turnout, Pct_Leave, Pct_Remain)

# Local authority boundaries
url <- "http://geoportal.statistics.gov.uk/datasets/3943c2114d764294a7c0079c4020d558_4.geojson"
bdy <- readOGR(dsn = url, layer = "OGRGeoJSON")
names(bdy@data)[2] <- "ons_code"
bdy@data <- data.frame(bdy@data, referendum[match(bdy@data$ons_code, referendum$ons_code),])

# create a map
bdy %>% qtm

# add a variable (% voting to Leave)
bdy %>% qtm(fill="Pct_Leave")

# add a north arrow
bdy %>% qtm(fill="Pct_Leave") + 
  tm_compass()

# apply different map style
bdy %>% qtm(fill="Pct_Leave") + 
  tm_compass() + 
  tm_style_natural()

# colour blind friendly
bdy %>% qtm(fill="Pct_Leave") + 
  tm_compass() + 
  tm_style_col_blind()

# projected in British National Grid
qtm(bdy, projection = "+init=epsg:27700", fill="Pct_Leave") + tm_scale_bar()

# old fashioned map
bdy_BNG <- bdy %>% set_projection("+init=epsg:27700")
tm_shape(bdy_BNG) + 
  tm_style_classic() + 
  tm_fill(col="Pct_Leave", title = '% voting leave') + 
  tm_borders() + 
  tm_compass(size=4)

# cartogram
library(cartogram)
carto <- bdy_BNG %>% cartogram(weight = "Electorate")
carto %>% qtm

# cartogram of % voting leave
tm_shape(carto) + 
  tm_fill(col="Pct_Leave", title='% voting Leave') + 
  tm_borders() 

# faceting
tm_shape(bdy_BNG) + 
  tm_fill(col=c("Pct_Leave", "Pct_Turnout"), title=c('% voting Leave','% turnout')) + 
  tm_borders()

# faceting with panel titles
tm_shape(bdy_BNG) + 
  tm_fill(col=c("Pct_Leave", "Pct_Turnout"), title=c('% voting Leave', '% turnout')) + 
  tm_borders() + tm_layout(panel.labels=c("Leave vote", "Turnout"))

# faceting with panel titles and a scale bar
tm_shape(bdy_BNG) + 
  tm_fill(col=c("Pct_Leave","Pct_Turnout"), title=c('% voting Leave','% turnout')) + 
  tm_borders() + tm_layout(panel.labels=c("Leave vote", "Turnout")) +
  tm_scale_bar()

# leaflet map
cmap <- tm_shape(bdy) + 
  tm_fill(col="Pct_Leave", title = '% voting Leave', style = 'jenks') + tm_borders()
tmap_leaflet(cmap)

# leaflet map with different basemaps
tmap_mode("view")
cmap + tm_view(basemaps = c("Stamen.Toner", "OpenStreetMap.BlackAndWhite"), alpha = 0.5)
