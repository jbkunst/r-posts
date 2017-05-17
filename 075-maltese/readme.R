rm(list = ls())
# devtools::install_github("bearloga/maltese")
library(tidyverse)
library(maltese)
library(timekit)
library(lubridate)

# data <- structure(list(x = c(70090.5778171204, 69356.3322413804, 67864.4479475701, 
#                              68523.3096806297, 68298.0427100604, 64327.9984660899),
#                        date = structure(c(1379894400, 1379980800, 1380067200, 1380153600,
#                                           1380240000, 1380499200), class = c("POSIXct","POSIXt"))),
#                   .Names = c("x", "date"), row.names = c(NA, -6L), class = c("tbl_df", "tbl", "data.frame"))

data <- readxl::read_excel("~/../Downloads/pronostico_consumo_v1.xlsx")
names(data) <- tolower(names(data))

data <- data %>% 
  rename(date = id_mes, y = provision) %>% 
  mutate(date = ymd(date))
data

mlts <- mlts_transform(
  data, date, y,
  p = 20, # how many previous points of data to use as features
  granularity = "day", # optional, can be automatically detected,
  extras = TRUE, extrasAsFactors = TRUE # FALSE by default :D
)

mlts <- tbl_df(mlts)
mlts

mod <- lm(y ~ ., data = mlts)

# mlts <- mutate(mlts, p = predict(mod))
ggplot(mlts) +
  geom_line(aes(dt, y))


h <- 50

fut <- max(mlts$dt) + days(1:h)
fut <- fut[as.POSIXlt(fut)$wday %in% c(1:5)]



ystart <- last(mlts$y)
  
mlts2 <- bind_rows(mlts %>% select(dt, y), data_frame(dt = fut, y = ystart))
mlts2 <- mlts_transform(mlts2, dt, y, p = 20, granularity = "day",
                        extras = TRUE, extrasAsFactors = TRUE)
mlts2 <- tbl_df(mlts2)
mlts2


preds <- map_df(1:100, function(i){ #i <- 1
  
  mlts2 <- mutate(mlts2, pred = predict(mod, newdata = mlts2))  
  
  mlts2 %>% 
    select(dt, pred) %>% 
    mutate(i = i)
  
}) 

preds %>% 
  filter(dt >= min(fut)) %>% 
  ggplot() + 
  geom_line(aes(dt, y, alpha = i))



