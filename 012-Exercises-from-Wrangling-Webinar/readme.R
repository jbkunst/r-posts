# devtools::install_github("rstudio/EDAWR")
library(EDAWR)
library(magrittr)
library(tidyr)


# 1. Each variable is saved in its own column.
# 2. Each observation is saved in its own row.
# 3. Each "type" of observation stored 3 in a single table

########
# Storms
data(storms)
storms


storms %>%
  separate(date, c("year", "month", "day"), sep = "-")

########
# Cases
data(cases)
cases

cases %>%
  gather(year, number, -country)



########
# Pollution
data(pollution)
pollution

pollution %>%
  spread(size, amount)





