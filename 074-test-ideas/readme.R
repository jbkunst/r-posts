rm(list = ls())
library(tidyverse)

paquetes_a_instalar <- c("gapminder", "babynames", "nasaweather", "fueleconomy",
                         "fivethirtyeight")

for(p in paquetes_a_instalar) {
  message("Viendo ", p)
  if(!p %in% rownames(installed.packages())) install.packages(p)
  library(p, character.only = TRUE)
}


data(gapminder)
glimpse(gapminder)

data(babynames)
glimpse(babynames)

fueleconomy::common
fueleconomy::vehicles
data(vehicles)
glimpse(vehicles)

ggplot(vehicles) + 
  geom_point(aes(hwy, cty), alpha = 0.3) + 
  facet_grid(cyl ~ fuel)

nasaweather::atmos
nasaweather::atmos %>% 
  group_by(lat, long) %>% 
  count() %>% 
  ungroup() %>% 
  count(n)

nasaweather::atmos %>% 
  count(year, month) %>% 
  count()
nasaweather::glaciers


glimpse(fivethirtyeight::bob_ross)
glimpse(fivethirtyeight::bad_drivers)
glimpse(fivethirtyeight::avengers)
glimpse(fivethirtyeight::drinks)

avengers

     