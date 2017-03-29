library(dplyr); library(rgdal) ; library(geojsonio)

# Great Britain
gb_results <- read.csv(url("http://www.electoralcommission.org.uk/__data/assets/file/0014/212135/EU-referendum-result-data.csv")) %>% 
  select(code = `Area_Code`, Pct_Remain, Pct_Leave)

gb_boundaries <- "http://geoportal.statistics.gov.uk/datasets/3943c2114d764294a7c0079c4020d558_4.geojson"
gb_boundaries <- readOGR(dsn = gb_boundaries, layer = "OGRGeoJSON", verbose = FALSE)
names(gb_boundaries@data)[3] <- "name"
names(gb_boundaries@data)[2] <- "code"

gb_boundaries@data <- merge(gb_boundaries@data, gb_results, by = "code")
gb_boundaries@data[c(2,4,5,6)] <- NULL
geojson_write(gb_boundaries, file = "gb.geojson")

# Northern Ireland
ni_results <- read.csv(url("https://www.opendatani.gov.uk/dataset/9a2f7593-297e-409d-bdac-39ccc172a14e/resource/61cfee40-69f6-444e-bf03-3dd60bd6e1dc/download/eu-referendum-2016-constituency-count-totals.csv")) %>% 
  select(name = Constituency, 
         Votes_Cast = Number.of.ballot.papers.counted, 
         Remain = Number.of.votes.cast.in.favour.of.REMAIN, 
         Leave = Number.of.votes.cast.in.favour.of.LEAVE) %>% 
  mutate(Pct_Remain = Remain/Votes_Cast*100,
         Pct_Leave = Leave/Votes_Cast*100) %>% 
  select(-c(Votes_Cast, Remain, Leave))

ni_codes <- data.frame(
  name = c("Belfast East","Belfast North","Belfast South","Belfast West",
           "East Antrim","East Londonderry","Fermanagh & South Tyrone",
           "Foyle","Lagan Valley","Mid Ulster","Newry & Armagh",
           "North Antrim","North Down","South Antrim","South Down",
           "Strangford","Upper Bann","West Tyrone"),
  code = c("N06000001","N06000002","N06000003","N06000004",'N06000005',"N06000006",
           "N06000007","N06000008","N06000009","N06000010","N06000011","N06000012",
           "N06000013","N06000014","N06000015","N06000016","N06000017","N06000018"))
ni_results <- inner_join(ni_results, ni_codes, by = "name")

ni_boundaries <- "http://osni.spatial-ni.opendata.arcgis.com/datasets/563dc2ec3d9943428e3fe68966d40deb_3.geojson"
ni_boundaries <- readOGR(dsn = ni_boundaries, layer = "OGRGeoJSON", verbose = FALSE)
names(ni_boundaries@data)[1] <- "name"
names(ni_boundaries@data)[3] <- "code"
ni_boundaries@data <- merge(ni_boundaries@data, ni_results, by = "code")
ni_boundaries@data[c(2,3,4)] <- NULL
names(ni_boundaries@data)[2] <- "name"
geojson_write(ni_boundaries, file = "ni.geojson")
