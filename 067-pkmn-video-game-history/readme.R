library(tidyverse)
library(rvest)
library(janitor)
# https://en.wikipedia.org/wiki/List_of_Pok%C3%A9mon_video_games

data <- read_html("https://en.wikipedia.org/wiki/List_of_Pok%C3%A9mon_video_games") %>% 
  html_table(fill = TRUE) %>% 
  first()

data <- read_html("http://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_games") %>% 
  html_nodes("table") %>% 
  first()


data <- data %>% 
  clean_names %>%
  tbl_df

glimpse(data)

install.packages("ggbeeswarm")
library(ggplot2)
library(ggbeeswarm)

p <- ggplot(mpg,aes(x= 1, y = hwy)) + geom_beeswarm()
df <- ggplot_build(p)$data[[1]]
df <- df %>% 
  group_by(y) %>% 
  mutate(xs = scale(x, scale = FALSE))
ggplot(df) + 
  geom_point(aes(y, x))


p <- ggplot(mpg,aes(x= class, y = hwy)) + geom_beeswarm()
p
df <- ggplot_build(p)$data[[1]]
df <- df %>% 
  group_by(y) %>% 
  mutate(xs = scale(x, scale = FALSE))
ggplot(df) + 
  geom_point(aes(x, y))


hchart(df, "point", hcaes(x, y, group = group)) %>% 
  hc_xAxis(categories = sort(unique(mpg$class)))





