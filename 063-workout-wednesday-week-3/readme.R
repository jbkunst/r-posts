#' ---
#' title: ""
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE, fig.cap = "",
                      fig.showtext = TRUE, dev = "CairoPNG")

#' ---
#' output:
#'  html_document:
#'    keep_md: true
#' ---
#+ message=FALSE
# library(ggplot2)
# library(hrbrmisc)
library(readxl)
library(tidyverse)
library(highcharter)

options(highcharter.theme = hc_theme_smpl())

# Use official BLS annual unemployment data vs manually calculating the average
# Source: https://data.bls.gov/timeseries/LNU04000000?years_option=all_years&periods_option=specific_periods&periods=Annual+Data
annual_rate <- read_excel("SeriesReport-20170119223055_e79754.xlsx", skip=10) %>%
  mutate(Year = as.character(as.integer(Year)),
         Annual=Annual/100)

annual_rate

# The data source Andy Kriebel curated for you/us: https://1drv.ms/x/s!AhZVJtXF2-tD1UVEK7gYn2vN5Hxn #ty Andy!
df <- read_excel("staadata.xlsx") %>%
  left_join(annual_rate) %>%
  # filter(State != "District of Columbia") %>%
  mutate(
    year = as.Date(sprintf("%s-01-01", Year)),
    pct = (Unemployed / `Civilian Labor Force Population`),
    us_diff = -(Annual-pct),
    col = ifelse(us_diff<0,
                 "Better than U.S. National Average",
                 "Worse than U.S. National Average")
    )

df



# wrangling ---------------------------------------------------------------
library(tidyr)

df2 <- df %>% 
  arrange(State, Year) %>% 
  select(state = State, year = Year, us_diff) %>% 
  spread(year, us_diff)

df3 <- select(df2, -state)
df3



# autoencoder -------------------------------------------------------------
library(h2o)

localH2O <- h2o.init(nthreads = -2)

dfh2o <- as.h2o(df3)

mod.autoenc <- h2o.deeplearning(
  x = names(dfh2o),
  training_frame = dfh2o,
  hidden = c(1000, 400, 200, 2, 200, 400, 1000),
  epochs = 600,
  activation = "Tanh",
  autoencoder = TRUE
)

df_auto_enc <- h2o.deepfeatures(mod.autoenc, dfh2o, layer = 4) %>% 
  as.data.frame() %>% 
  tbl_df() %>% 
  setNames(c("x", "y")) %>% 
  mutate(name = df2$state)

df_auto_enc


hchart(df_auto_enc, "bubble", hcaes(x, y, name = name),
       maxSize = 15, dataLabels = list(enabled = TRUE, format = "{point.name}")) %>% 
  hc_add_theme(hc_theme_null(chart = list(style = list(fontFamily = "Alegreya Sans"))))



# hclust ------------------------------------------------------------------

# Compute pairewise distance matrices
dist.res <- dist(iris.scaled, method = "euclidean")
# Hierarchical clustering results
hc <- hclust(dist.res, method = "complete")
# Visualization of hclust
plot(hc, labels = FALSE, hang = -1)
# Add rectangle around 3 groups
rect.hclust(hc, k = 3, border = 2:4) 

hclst <- df_auto_enc %>%
  select(x, y) %>% 
  dist() %>% 
  hclust()


plot(hclst, labels = FALSE, hang = -1)
rect.hclust(hclst, k = 3, border = 2:4) 

cutree(hclst, k = 3)


# k-means -----------------------------------------------------------------
df_auto_enc_h2o <-  df_auto_enc %>% 
  select(-name) %>% 
  as.h2o()

df_kmod <- map_df(1:10, function(k){
  mod.km <- h2o.kmeans(training_frame = df_auto_enc_h2o, k = k, x = names(df_auto_enc_h2o))  
  mod.km@model$model_summary
})

df_kmod <- df_kmod %>%
  tbl_df() %>% 
  mutate(wc_ss = within_cluster_sum_of_squares/total_sum_of_squares,
         bt_ss = between_cluster_sum_of_squares/total_sum_of_squares)

df_kmod

hchart(df_kmod, "line", hcaes(number_of_clusters, wc_ss))

source("https://raw.githubusercontent.com/echen/gap-statistic/master/gap-statistic.R")
gap <- gap_statistic(select(df_auto_enc, -name))


K <- 3
mod.km <-  h2o.kmeans(training_frame = df_auto_enc_h2o, k = K, x = names(df_auto_enc_h2o))  
mod.km.preds <- h2o.predict(object = mod.km, newdata = df_auto_enc_h2o)
mod.km.preds <- as.character(as.vector(mod.km.preds) + 1)
mod.km.preds <- factor(mod.km.preds, seq(1, length(unique(mod.km.preds))))


df_auto_enc$cluster <- mod.km.preds









library(highcharter)

color <- df %>% 
  group_by(State) %>% 
  summarise(us_diff = median(us_diff)) %>% 
  mutate(color = colorize(us_diff)) %>% 
  .$color

df %>% 
  mutate(date = paste0(Year, "-01-01"),
         date = as.Date(date, format = "%Y-%m-%d")) %>% 
  hchart("line", hcaes(date, us_diff, group = State), color = color,
         showInLegend = FALSE) %>% 
  hc_tooltip(sort = TRUE, table = TRUE)
