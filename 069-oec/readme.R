#' ---
#' title: ""
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE, fig.cap = "")
#+

# packages ----------------------------------------------------------------
rm(list = ls())
library(tidyverse)
library(jbkmisc)
library(tidyr)
library(broom)
library(viridis)
theme_set(theme_jbk())

# data --------------------------------------------------------------------
# dprod <- read_csv("http://atlas.media.mit.edu/en/rankings/hs92/?download=true")
# names(dprod) <- tolower(names(dprod))
# dprod

data <- read_csv("http://atlas.media.mit.edu/en/rankings/country/?download=true")
names(data) <- tolower(names(data))
data

data <- countrycode::countrycode_data %>% 
  tbl_df() %>% 
  select(id = iso3c, continent) %>% 
  mutate(id= tolower(id)) %>% 
  right_join(data, by = "id") 

data %>% 
  count(country, continent) %>% 
  ungroup() %>% 
  count(continent)

data <- mutate(data, continent = ifelse(continent %in% c("Asia", "Oceania"),
                                        "Asia & Oceania", continent))

# explore -----------------------------------------------------------------
data %>% 
  count(year) %>% 
  ggplot() +
  geom_line(aes(year, n)) + 
  scale_y_continuous(limits = c(0, NA))

countries_to_study <- data %>% 
  group_by(country) %>% 
  summarise(
    n = n(),
    year_min = min(year)
    ) %>% 
  arrange(n) %>% 
  mutate(pcum = ecdf(n)(n))

ggplot(countries_to_study) + 
  geom_histogram(aes(n))

ggplot(countries_to_study) + 
  geom_line(aes(n, pcum))

countries_to_study <- filter(countries_to_study, pcum > .25)

data <- semi_join(data, countries_to_study)

data %>% 
  count(country) %>% 
  count(n)

ggplot(data) + 
  geom_bar(aes(continent, fill = continent)) + 
  scale_fill_viridis(discrete = TRUE)

ggplot(data) + 
  geom_smooth(aes(year, eci, group = continent, color = continent), se = FALSE) +
  scale_color_viridis(discrete = TRUE)
  
# ggplot(data, aes(year, eci)) + 
#   geom_line(aes(group = country, color = continent), alpha = .4) +
#   geom_smooth(aes(year, eci, group = continent, color = continent), se = FALSE) +
#   facet_wrap(~ continent) +
#   scale_color_viridis(discrete = TRUE) 

# filter(data, eci == min(eci))

data_ae <- data %>% 
  select(id, continent, year, eci) %>% 
  mutate(year = paste0("y", year)) %>% 
  spread(year, eci) %>% 
  arrange(id)


# autoencoder -------------------------------------------------------------
library(h2o)
h2o.init(nthreads = -1)

modae <- h2o.deeplearning(
  x = names(data_ae)[-c(1, 2)],
  training_frame = as.h2o(data_ae),
  hidden = c(400,  100, 2, 100, 400),
  activation = "Tanh",
  autoencoder = TRUE
  )
modae

dautoenc <- h2o.deepfeatures(modae, as.h2o(data_ae), layer = 3) %>% 
  as.data.frame() %>% 
  tbl_df() %>% 
  setNames(c("x", "y")) %>% 
  bind_cols(data_ae)

dautoenc

ggplot(dautoenc) + 
  geom_point(aes(x, y, color = continent)) + 
  scale_color_viridis(discrete = TRUE) 

data <- left_join(data, select(dautoenc, id, x, y), by = "id")

kmeans <- map_df(1:10, function(k){
  data %>% 
    select(x, y) %>% 
    kmeans(k) %>% 
    {.[["betweenss"]]} %>%
    {data_frame(k = k, b = 1 - .)}
}) 

ggplot(kmeans) +
  geom_line(aes(k, b))

kmod <- kmeans(select(data, x, y), 3)

data <- mutate(data, cluster = as.character(kmod$cluster))

ggplot(distinct(data, id, .keep_all = TRUE)) + 
  geom_point(aes(x, y, color = cluster), size = 2, alpha = 0.7) + 
  facet_wrap(~continent) + 
  scale_color_manual(values = c("red", "navy", "green"))
  
ggplot(data, aes(year, eci, color = cluster)) + 
  geom_smooth(size = 2, alpha = 0.7, se = FALSE) +
  # geom_line(aes(group = country), size = 1, alpha = 0.2) + 
  facet_wrap(~continent) + 
  scale_color_manual(values = c("red", "navy", "green"))