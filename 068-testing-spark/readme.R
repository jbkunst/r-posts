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

tbl(sc, sql("SELECT * FROM flights")) 

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


