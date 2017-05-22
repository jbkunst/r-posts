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

data <- readxl::read_excel("pronostico_consumo_v1.xlsx")
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

h <- 45

last_date <- max(mlts$dt)
fut <- last_date  + days(1:h)
fut <- fut[as.POSIXlt(fut)$wday %in% c(1:5)]

ystart <- mean(mlts$y)
  
mlts2 <- bind_rows(mlts %>% select(dt, y), data_frame(dt = fut, y = ystart))
mlts2 <- mlts_transform(mlts2, dt, y, p = 20, granularity = "day",
                        extras = TRUE, extrasAsFactors = TRUE)
mlts2 <- tbl_df(mlts2)
mlts2

preds <- map_df(1:h, function(i){ # i <- 1
  message(i)
  
  ggplot(mlts2 %>% filter(year(dt) >= 2017)) +
    geom_line(aes(dt, y, color = ifelse(dt < last_date, "past", "forecast"))) +
    theme(legend.position = "none") +
    ggtitle(i) %>% 
    print()
  
  mlts2 <- mutate(mlts2, pred = predict(mod, newdata = mlts2))  
  mlts2 <- mutate(mlts2, y = ifelse(dt <= last_date + days(i), y, pred))
  mlts2 <- select(mlts2, dt, y, pred)
  
  p <-  mlts2 %>% 
    select(dt, y) %>% 
    mutate(i = i) %>% 
    tbl_df()
  
  mlts2 <<- mlts_transform(mlts2, dt, y, p = 20, granularity = "day",
                          extras = TRUE, extrasAsFactors = TRUE)
  
 p
  
}) 

preds %>% 
  filter(dt > last_date) %>% 
  ggplot() + 
  geom_line(aes(dt, y, group = i, alpha = i)) + 
  theme_minimal()

preds %>% 
  filter(dt > last_date) %>% 
  ggplot() + 
  geom_line(aes(dt, y)) + 
  facet_wrap(~i) + 
  theme_minimal()


preds %>% 
  filter(dt > last_date) %>% 
  spread(i, y)
  


