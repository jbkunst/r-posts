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
hc_theme_null2 <- hc_theme_null(
  chart = list(style = list(fontFamily = "Alegreya Sans")),
  plotOptions = list(
    series = list(dataLabels = list(enabled = TRUE, format = "{point.name}")list(fillOpacity)
    )
  )

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



# autoencoder -------------------------------------------------------------
library(h2o)
library(tidyr)

df2 <- df %>% 
  arrange(State, Year) %>% 
  select(state = State, year = Year, us_diff) %>% 
  spread(year, us_diff)

df3 <- select(df2, -state)
df3

localH2O <- h2o.init(nthreads = -1)

dfh2o <- as.h2o(df3)

mod.autoenc <- h2o.deeplearning(
  x = names(dfh2o),
  training_frame = dfh2o,
  hidden = c(1000, 500, 2, 500, 1000),
  epochs = 1000,
  activation = "Tanh",
  autoencoder = TRUE
)

df_autoenc <- h2o.deepfeatures(mod.autoenc, dfh2o, layer = 3) %>% 
  as.data.frame() %>% 
  tbl_df() %>% 
  setNames(c("x", "y"))

df_autoenc <- df_autoenc %>% 
  mutate(name = df2$state) %>% 
  select(name, everything())

hchart(df_autoenc, "scatter", hcaes(x, y, name = name)) %>% 
  hc_add_theme(hc_theme_null2)



# clustering --------------------------------------------------------------
# hclust
hclst <- df_autoenc %>%
  select(x, y) %>% 
  dist() %>% 
  hclust()

plot(hclst)

K <- 4
rect.hclust(hclst, k = K, border = 2:4) 

df_autoenc <- mutate(df_autoenc, cluster_hc = cutree(hclst, k = K))

# k-means
df_kmods <- map_df(1:10, function(k){ # k <- 4
  
  set.seed(123)
  mod_km <- kmeans(select(df_autoenc, x, y), centers = k)
  
  data_frame(k = k, wc_ss =  mod_km$tot.withinss / mod_km$totss)
  
})

hchart(df_kmods, "line", hcaes(k, wc_ss))

K <- 3
mod_km <- kmeans(select(df_autoenc, x, y), centers = K)

df_autoenc <- mutate(df_autoenc, cluster_km = mod_km$cluster)


# paste
df_autoenc <- df_autoenc %>% 
  unite(group, starts_with("cluster"), remove = FALSE) %>% 
  mutate(group = as.character(as.factor(group)))

df_autoenc

hchart(df_autoenc, "point", hcaes(x, y, name = name, group = group)) %>% 
  hc_add_theme(hc_theme_null2)


# back to original data ---------------------------------------------------
dff <- left_join(df, df_autoenc %>% select(name, group),
                by = c("State" = "name"))

dff_summ <- dff %>% 
  group_by(group) %>% 
  summarise(us_diff_mean = mean(us_diff)) %>% 
  ungroup() %>% 
  arrange(desc(us_diff_mean)) %>% 
  mutate(color = colorize(seq_len(nrow(.)), c("blue", "gray", "red")))

count(df_autoenc, group)

dff <- dff %>% 
  mutate(
    group = factor(group,
                   levels = dff_summ$group,
                   labels = seq_len(nrow(dff_summ))
                   )
    )


library(viridis)
# library(directlabels)

ggplot(dff, aes(as.numeric(Year), us_diff)) + 
  geom_line(aes(group = State), alpha = 0.1) +
  # geom_dl(aes(label = State), method="last.points") + 
  geom_smooth(aes(group = group, color = group), method = "loess") + 
  geom_hline(aes(yintercept = 0)) +
  scale_color_viridis(discrete = TRUE) + 
  facet_wrap(~group, nrow = 1) + 
  theme_minimal() +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(nrow = 1, byrow = TRUE)) + 
  labs(
    title = "Clustering Unemployed Series",
    x = "Year",
    y = "Diff with US Total"
  )

uniseries <- dff %>% 
  group_by(name = State) %>% 
  do(un = list(.$us_diff))

series <- df_autoenc %>% 
  left_join(uniseries) %>% 
  group_by(group) %>% 
  do(data = list_parse(select(., name, x, y, un))) %>% 
  ungroup() %>% 
  left_join(dff_summ) %>% 
  arrange(desc(us_diff_mean)) %>% 
  mutate(name = paste("s", seq_len(nrow(.))))

series

highchart() %>% 
  hc_chart(type = "bubble") %>% 
  hc_plotOptions(scatter = list(marker = list(symbol = "circle")),
                 bubble = list(fillOpacity = 0.1)) %>% 
  hc_add_series_list(series) %>% 
  hc_add_theme(hc_theme_null2)
      
    
  

