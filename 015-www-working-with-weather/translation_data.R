# Data from 'https://centroccbb.cl/clima/indexData.php'
rm(list = ls())

library("rio")
library("dplyr")
library("rvest")


data <- import("Informe parcial.xls")

data <- data %>% tbl_df()

names(data)


# names(data) <- c("date", "time", "temperature", "humidity", "pressure", "precipitation",
#                  "solar_radiation", "wind_speed", "wind_direction",
#                  "chill", "Temperature_flushing", "htw_index", "thws_index", "dew_point",
#                  "rainfall_rate", "air_density")

names(data) <- c("date", "time", "temperature", "humidity", "pressure", "precipitation",
                 "solar_radiation", "wind_speed", "wind_direction",
                 "thermal_sensation", "rainfall_rate")

names(data)

data

str(data)

save(data, file = "wheather_data.RData")
