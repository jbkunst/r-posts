# install.packages(c("devtools", "tidyverse", "nycflights13", "Lahman", "sparklyr", "digest",
#                    "scales", "prettyunits", "httpuv", "xtable"))


# library(sparklyr)
# spark_install(version = "1.6.2")

library(sparklyr)
library(dplyr)

sc <- spark_connect(master = "local")

iris_tbl <- copy_to(sc, iris)
flights_tbl <- copy_to(sc, nycflights13::flights, "flights")
airlines_tbl <- copy_to(sc, nycflights13::airlines, "airlines")
batting_tbl <- copy_to(sc, Lahman::Batting, "batting")

src_tbls(sc)

filter(iris,  Species == "setosa")
filter(iris_tbl,  Species == "setosa")
