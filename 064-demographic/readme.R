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
knitr::opts_chunk$set(message = FALSE, warning = FALSE, fig.cap = "")

#  ------------------------------------------------------------------------
library(tidyverse)
library(highcharter)
library(idbr)
library(viridisLite)
library(forcats)
library(stringr)

options(highcharter.theme = hc_theme_smpl())
idb_api_key("35f116582d5a89d11a47c7ffbfc2ba309133f09d")

# data(countrycode_data)
# countrycode_data <- tbl_df(countrycode_data)
# countrycode_data
# fips <- countrycode_data$fips104
# fips <- na.omit(fips)
# fips_path <- "data/fips/fips_valid.rds"
# if(!file.exists(fips_path)) {
#   fips_valid <- map_chr(sample(fips), function(x){ # x <- "AL"
#     message(x)
#     try({ idb1(x, 1990, variables = c("AGE", "POP")); return(x) })
#   })
#   fips_valid <- fips_valid[nchar(fips_valid) == 2]
#   saveRDS(fips_valid, fips_path)
# } else {
#   fips_valid <- readRDS(fips_path)
# }
# 
# countrycode_data <- filter(countrycode_data, fips104 %in% fips_valid)
# countrycode_data
# 
# 
# set.seed(9876543)

fip <- "US"
yrs <- 1990:2050

system.time({
  data <- idb1(fip, yrs, variables = c("AGE", "POP", "NAME"), sex = "both")  
})

data

brks <- seq(0, 100, length.out = 10 + 1)

datag <- data %>% 
  mutate(agec = cut(AGE, breaks = brks, include.lowest = TRUE)) %>% 
  group_by(name = NAME, fip = FIPS, year = time, agec) %>% 
  summarise(pop = sum(POP),
            age_median = round(median(AGE))) %>% 
  ungroup() %>% 
  arrange(desc(age_median)) %>% 
  mutate(birth_year = year - age_median,
         agec = fct_inorder(agec)) %>% 
  print()

colors <- inferno(length(brks) - 1, begin = 0.1, end = .9) %>% 
  hex_to_rgba() %>% 
  rev()

hchart(datag, "area", hcaes(year, pop, group = agec),
       color = colors, showInLegend = FALSE) %>% 
  hc_tooltip(table = TRUE) %>% 
  hc_plotOptions(
    series = list(
      lineColor = "white",
      lineWidth = 0.5,
      stacking = "normal",
      marker = list(symbol = "circle", size = 0.1, enabled = FALSE, lineWidth = 0)
      )
    )

#' now 
#' 
#' 
paltte <- scales::col_numeric(
  str_sub(magma(100), 0, -3),
  # cm.colors(10, alpha = 1),
  domain = seq(min(datag$birth_year), max(datag$birth_year)))

datag <- mutate(datag, segmentColor = paltte(birth_year))

hchart(datag, "coloredarea", hcaes(year, pop, group = agec, segmentColor = segmentColor),
       color = "#444", showInLegend = FALSE) %>%
  hc_tooltip(table = TRUE) %>% 
  hc_plotOptions(
    series = list(
      stacking = "normal",
      marker = list(symbol = "circle", size = 0.1, enabled = FALSE, lineWidth = 0)
    )
  )




