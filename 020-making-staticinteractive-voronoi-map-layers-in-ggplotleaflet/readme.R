#' ---
#' title: "Making static/interactive voronoi map layers in ggplot/leaf"
#' output: 
#'  html_document: 
#'    keep_md: yes
#' ---
#' 
#' [original source](http://rud.is/b/2015/07/26/making-staticinteractive-voronoi-map-layers-in-ggplotleaflet/)
#+ warning=FALSE, message=FALSE
library("printr")
rm(list = ls())

library("sp")
library("rgdal")
library("deldir")
library("dplyr")
library("readr")
library("ggplot2")
library("ggthemes")



flights <- read_csv("http://bl.ocks.org/mbostock/raw/7608400/flights.csv")
airports <- read_csv("http://bl.ocks.org/mbostock/raw/7608400/airports.csv")

head(flights)
head(airports)


conus <- state.abb[!(state.abb %in% c("AK", "HI"))]


airports <- airports %>%
  filter(state %in% conus,
         iata %in% union(flights$origin, flights$destination))

orig <- flights %>% 
  count(origin) %>% 
  select(iata = origin, n1 = n)

dest <- flights %>% 
  count(destination) %>% 
  select(iata = destination, n2 = n)

orig_dest <- left_join(orig, dest, by = "iata") %>% 
  mutate(tot = n1 + n2) %>% 
  select(iata, tot)


airports <- left_join(airports,orig_dest) %>% 
  filter(!is.na(tot))

rm(orig_dest, orig, dest)

class(airports) <- "data.frame"

vor_pts <- SpatialPointsDataFrame(cbind(airports$longitude,
                                        airports$latitude),
                                  airports, match.ID = TRUE)
str(vor_pts)

identical(vor_pts@data, airports)

identical(as.numeric(vor_pts@coords),
          as.numeric(c(airports$longitude, airports$latitude)))



SPointsDF_to_voronoi_SPolysDF <- function(sp) {
  # sp <- vor_pts
  # tile.list extracts the polygon data from the deldir computation
  vor_desc <- tile.list(deldir(sp@coords[,1], sp@coords[,2]))
  
  lapply(1:(length(vor_desc)), function(i) {
    # i <- sample(seq(nrow(vor_pts)), size = 1)
    # tile.list gets us the points for the polygons but we
    # still have to close them, hence the need for the rbind
    tmp <- cbind(vor_desc[[i]]$x, vor_desc[[i]]$y)
    tmp <- rbind(tmp, tmp[1,])
    
    # now we can make the Polygon(s)
    Polygons(list(Polygon(tmp)), ID=i)
    
  }) -> vor_polygons
  
  # hopefully the caller passed in good metadata!
  sp_dat <- sp@data
  
  # this way the IDs _should_ match up w/the data & voronoi polys
  rownames(sp_dat) <- sapply(slot(SpatialPolygons(vor_polygons),
                                  'polygons'),
                             slot, 'ID')
  
  SpatialPolygonsDataFrame(SpatialPolygons(vor_polygons),
                           data = sp_dat)
  
}



vor <- SPointsDF_to_voronoi_SPolysDF(vor_pts)

vor_df <- fortify(vor)

states <- map_data("state")





gg <- ggplot()
# base map
gg <- gg + geom_map(data = states, map = states,
                    aes(x = long, y = lat, map_id = region),
                    color = "white", fill = "#cccccc", size = 0.5)
# airports layer
gg <- gg + geom_point(data = airports,
                      aes(x = longitude, y = latitude, size = sqrt(tot)),
                      shape = 21, color = "white", fill = "steelblue")
# voronoi layer
gg <- gg + geom_map(data = vor_df, map = vor_df,
                    aes(x = long, y = lat, map_id = id),
                    color = "#a5a5a5", fill = "#FFFFFF00", size = 0.25)

gg <- gg + scale_size(range = c(2, 9))

gg <- gg + coord_map("albers", lat0 = 30, lat1 = 40)

gg <- gg + theme_map()

gg <- gg + theme(legend.position = "none")

gg







library("leaflet")
library("rgeos")
library("htmltools")



url <- "http://eric.clst.org/wupl/Stuff/gz_2010_us_040_00_500k.json"
fil <- "gz_2010_us_040_00_500k.json"

if (!file.exists(fil)) download.file(url, fil, cacheOK = TRUE)

states_m <- readOGR("gz_2010_us_040_00_500k.json", 
                    "OGRGeoJSON", verbose = FALSE)

states_m <- subset(states_m, 
                   !NAME %in% c("Alaska", "Hawaii", "Puerto Rico"))

dat <- states_m@data # gSimplify whacks the data bits

states_m <- SpatialPolygonsDataFrame(gSimplify(states_m, 0.05,
                                               topologyPreserve = TRUE),
                                     dat, FALSE)



leaflet(width = 900, height = 650) %>%
  # base map
  addProviderTiles("Hydda.Base") %>%
  addPolygons(data = states_m,
              stroke = TRUE, color = "white", weight = 1, opacity = 1,
              fill = TRUE, fillColor = "#cccccc", smoothFactor = 0.5) %>%
  # airports layer
  addCircles(data = arrange(airports, desc(tot)),
             lng =~ longitude, lat =~ latitude,
             radius =~ sqrt(tot)*5000, # size is in m for addCircles O_o
             color = "white", weight = 1, opacity = 1,
             fillColor = "steelblue", fillOpacity = 1) %>%
  # voronoi (click) layer
  addPolygons(data = vor,
              stroke = TRUE, color = "#a5a5a5", weight = 0.25,
              fill = TRUE, fillOpacity = 0.0,
              smoothFactor = 0.5, 
              popup = sprintf("Total In/Out: %s",
                              as.character(vor@data$tot)))




#'
#'
#' http://letstalkdata.com/2014/05/creating-voronoi-diagrams-with-ggplot/
#' 
set.seed(105)
long <- rnorm(20,-98,15)
lat <- rnorm(20,39,10)
df <- data.frame(lat,long)

#This creates the voronoi line segments
voronoi <- deldir(df$long, df$lat)

#Now we can make a plot
ggplot() + 
  geom_segment(data = voronoi$dirsgs,
               aes(x = x1, y = y1, xend = x2, yend = y2),
               size = 2, linetype = 1, color= "#FFB958") + 
  geom_point(data = df,
             aes(long, lat), 
             fill = rgb(70,130,180,255,maxColorValue = 255),
             pch = 21, size = 4, color = "#333333")



