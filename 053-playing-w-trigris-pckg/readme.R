# install.packages("tigris")
library(tigris)


counties <- c(5, 47, 61, 81, 85)
tracts <- tracts(state = 'NY',cb=TRUE)
tracts <- tracts(state = 'TX',cb=TRUE)

tracts <- tracts(state = 1, cb = TRUE)
tracts <- tracts(state = 51, cb = TRUE)

str(tracts@data)
head(tracts@data)

str(tracts, max.level = 2)



library(leaflet)
tarrant <- tracts("TX", "Tarrant", cb = TRUE)

leaflet(tarrant) %>%
  addTiles() %>%
  addPolygons(popup = ~NAME)


library(tigris)
library(ggplot2)
library(ggthemes)

me <- counties("NY", cb = TRUE)
me_map <- fortify(me)

gg <- ggplot()
gg <- gg + geom_map(data=me_map, map=me_map, 
                    aes(x=long, y=lat, map_id=id, fill=id),
                    color="black", size=0.25)
gg <- gg + coord_map()
gg <- gg + theme_map()
gg



ca <- primary_secondary_roads(state = 'California')
head(ca)
rt1 <- ca[ca$FULLNAME == 'State Rte 1', ]



library(tigris)
library(sp)

rds <- primary_secondary_roads()

plot(rds)

rds <- primary_roads()

str(rds, max.level = 3)

str(rds@data)
head(rds@data)
length(rds@lines)
rds@lines[[1]]




roads <- roads("Maine", "031")

# for ggplot, we need to simplify the lines otherwise it'll take
# forever to plot. however, gSimplify whacks the SpatialLinesDataFrame
# so we need to re-bind the data from the original object to it so
# we can use "fortify"

roads_simp <- rgeos::gSimplify(roads, tol=1/200, topologyPreserve=TRUE)
roads_simp <- SpatialLinesDataFrame(roads_simp, roads@data)

roads_map <- fortify(roads_simp) # this takes a bit

gg <- ggplot()
gg <- gg + geom_map(data=roads_map, map=roads_map,
                    aes(x=long, y=lat, map_id=id),
                    color="black", fill="white", size=0.25)
gg <- gg + coord_map()
gg <- gg + theme_map()
gg
