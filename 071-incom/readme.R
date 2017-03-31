# packages ----------------------------------------------------------------
rm(list = ls())
library(tidyverse)
library(jbkmisc)
# devtools::install_github("krlmlr/kimisc")
library(kimisc)
library(viridis)

theme_set(theme_jbk())
update_geom_defaults("bar", list(fill = "#d35400"))

# data --------------------------------------------------------------------
data <- readRDS("146.rds")
glimpse(data)

data$renta_liquidax

data <- data %>% 
  mutate(
    renta_liquidax_miles_cat =
      cut_format(
        renta_liquidax/1000,
        c(0, 250, 500, 750, 1000, 1250, Inf),
        format_fun = scales::comma,
        include.lowest = TRUE),
    edad_cat = cut(edadx, c(seq(20, 70, by = 10), Inf))
    )

countp(data, renta_liquidax_miles_cat)

ggplot(data) + geom_bar(aes(renta_liquidax_miles_cat), width = 0.5)
ggplot(data) + geom_histogram(aes(edadx))
ggplot(data) + geom_bar(aes(edad_cat))

ggplot(data) + geom_bar(aes(renta_liquidax_miles_cat), width = 0.5)

ggplot(data) + geom_bar(aes(renta_liquidax_miles_cat)) + facet_wrap(~edad_cat)

ggplot(data) +
  geom_line(aes(renta_liquidax_miles_cat, fill=..count.., group = edad_cat, color = edad_cat), stat="count", size = 1.2) +
  scale_color_viridis(discrete = TRUE, option = "B")
  
  