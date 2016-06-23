library(dplyr)
library(jsonlite)
library(purrr)

df <- fromJSON("http://bl.ocks.org/armollica/raw/6314f45890bcaaa45c808b5d2b0c602f/manufacturing.json")
df <- tbl_df(df)

head(df)
str(df)
