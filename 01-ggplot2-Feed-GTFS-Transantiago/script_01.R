# Source
# https://developers.google.com/transit/gtfs/reference
rm(list=ls())
options(stringsAsFactors=FALSE)

library(devtools)
library(ggplot2)
library(plyr)
library(dplyr)

source_url("https://raw.githubusercontent.com/jbkunst/reuse/master/R/gg_themes.R")

# Data
routes <- read.csv("data/routes.txt")
shapes <- read.csv("data/shapes.txt")
trips <- read.csv("data/trips.txt")
stops <- read.csv("data/stops.txt")

# Inspect
# shapes %>% head() # %>% View()
# trips %>% head()  #%>% View()
# routes %>% head() # %>% View()
# stops %>% head() # %>% View()

stops_metro <- stops %>% filter(!grepl("\\d", stop_id))

shapes_colors <- left_join(left_join(shapes %>% select(shape_id) %>% unique(),
                                     trips %>% select(shape_id, route_id) %>% unique()),
                           routes %>% select(route_id, route_color) %>% unique())

shapes_colors <- shapes_colors  %>% mutate(route_color = paste0("#", route_color))


routes_metro <- routes %>% filter(grepl("^L\\d",route_id))
shapes_metro <- shapes %>% filter(shape_id %in% trips$shape_id[trips$route_id %in% routes_metro$route_id])

shapes_colors_metro <- shapes_colors %>% filter(shape_id %in% trips$shape_id[trips$route_id %in% routes_metro$route_id])

idx1 <- which(grepl("L1", shapes_colors_metro$shape_id))
idx2 <- which(grepl("L2", shapes_colors_metro$shape_id))

shapes_colors_metro$route_color[idx1] <- "#FFD400"
shapes_colors_metro$route_color[idx2] <- "#FA0727"

# "#0A5FCA" "4A", "#FFD400" "2", "#1A1D6A" "4", "#FA0727" "1", "#008A63" "5"

ggplot() +
  geom_path(data=shapes, aes(shape_pt_lon, shape_pt_lat, group=shape_id), color="white", size=.2, alpha=.1) +
  geom_path(data=shapes_metro, aes(shape_pt_lon, shape_pt_lat, group=shape_id, colour=shape_id), size = 2, alpha=.7) +
  scale_color_manual(values=shapes_colors_metro$route_color) +
  geom_point(data=stops_metro, aes(stop_lon, stop_lat), shape=21, colour="white", alpha =.8) +
  coord_equal() +
  theme_null() +
  theme(plot.background = element_rect(fill = "black", colour = "black"),
        title = element_text(hjust=1, colour="white")) +
  ggtitle("TRANSANTIAGO\nSantiago's public transport system")

ggsave(filename="../plots/transantiago_gtfs.png", width=7, height=6.85)
ggsave(filename="../plots/transantiago_gtfs_hires.pdf", width=10, height=10)