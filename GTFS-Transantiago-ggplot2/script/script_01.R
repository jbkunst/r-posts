# Source
# https://developers.google.com/transit/gtfs/reference
rm(list=ls())
options(stringsAsFactors=FALSE)

library(ggplot2)


shapes <- read.csv("../data/shapes.txt")

head(shapes)

p <- ggplot(shapes) +
  geom_path(aes(shape_pt_lon, shape_pt_lat, group=shape_id), size=.2, alpha=.1) +
  coord_equal()
p


library(devtools)
library(plyr)
library(dplyr)

source_url("https://raw.githubusercontent.com/jbkunst/reuse/master/R/gg_themes.R")

routes <- read.csv("../data/routes.txt")
trips <- read.csv("../data/trips.txt")
stops <- read.csv("../data/stops.txt")

stops_metro <- stops %>% filter(!grepl("\\d", stop_id))

shapes_colors <- left_join(left_join(shapes %>% select(shape_id) %>% unique(),
                                     trips %>% select(shape_id, route_id) %>% unique(),
                                     by="shape_id"),
                           routes %>% select(route_id, route_color) %>% unique(),
                           by = "route_id")

shapes_colors <- shapes_colors  %>% mutate(route_color = paste0("#", route_color))

routes_metro <- routes %>% filter(grepl("^L\\d",route_id))

shapes_metro <- shapes %>% filter(shape_id %in% trips$shape_id[trips$route_id %in% routes_metro$route_id])

shapes_colors_metro <- shapes_colors %>% filter(shape_id %in% trips$shape_id[trips$route_id %in% routes_metro$route_id])

p2 <- ggplot() +
  geom_path(data=shapes, aes(shape_pt_lon, shape_pt_lat, group=shape_id),
            color="white", size=.2, alpha=.1) +
  geom_path(data=shapes_metro, aes(shape_pt_lon, shape_pt_lat, group=shape_id, colour=shape_id),
            size = 2, alpha=.7) +
  scale_color_manual(values=shapes_colors_metro$route_color) +
  geom_point(data=stops_metro, aes(stop_lon, stop_lat),
             shape=21, colour="white", alpha =.8) +
  coord_equal() +
  theme_null() +
  theme(plot.background = element_rect(fill = "black", colour = "black"),
        title = element_text(hjust=1, colour="white")) +
  ggtitle("TRANSANTIAGO\nSantiago's public transport system")
p2

ggsave(filename = "../plot/gtfs_transantiago_hires.pdf", plot = p2, width = 16, height = 16)

