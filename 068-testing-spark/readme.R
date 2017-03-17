# install.packages(c("devtools", "tidyverse", "nycflights13", "Lahman", "sparklyr", "digest",
#                    "scales", "prettyunits", "httpuv", "xtable"))


# library(sparklyr)
# spark_install(version = "1.6.2")

library(dplyr)
library(sparklyr)

sc <- spark_connect(master = "local")

# iris_tbl <- copy_to(sc, iris)
flights_tbl <- copy_to(sc, nycflights13::flights, "flights")
airlines_tbl <- copy_to(sc, nycflights13::airlines, "airlines")
# batting_tbl <- copy_to(sc, Lahman::Batting, "batting")

src_tbls(sc)


flights_tbl

tbl(sc, sql("SELECT count(*) FROM flights")) 
tbl(sc, sql("SELECT * FROM flights")) 


data(flights, package = "nycflights13") 
str(flights)
str(flights_tbl)

flights %>% 
  group_by(month) %>% 
  summarise(
    n = n(),
    sched_arr_time_sum = sum(sched_arr_time)
  )


flights_tbl %>% left_join(airlines_tbl)

class(flights_tbl)
flights_tbl %>% 
  group_by(carrier) %>% 
  summarise(
    n = n(),
    sched_arr_time_sum = sum(sched_arr_time)
  ) %>% 
  arrange(sched_arr_time_sum) %>% 
  show_query()
  
flights_tbl_carrier <- compute(flights_tbl_carrier)

left_join(flights_tbl_carrier, airlines_tbl)


# mod <- lm(dep_delay ~ ., data = nycflights13::flights)
# 8GB RAM
# Zzzz
# mod <- lm(dep_delay ~ ., data = sample_n(nycflights13::flights, 100000))
count(flights_tbl, year)
count(flights_tbl, month, sort = TRUE)

flights_tbl2 <- filter(flights_tbl, month >= 8)
flights_tbl2

resp <- "dep_delay"
feats <- setdiff(names(nycflights13::flights), resp)
mods <- ml_linear_regression(flights_tbl2, resp, feats, intercept = TRUE, alpha = 0, lambda = 0, iter.max = 100L)


