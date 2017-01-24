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
library(idbr)
library(countrycode)
library(highcharter) 
library(httr)
library(viridisLite)
library(stringr)

options(highcharter.theme = hc_theme_smpl())
idbr::idb_api_key("35f116582d5a89d11a47c7ffbfc2ba309133f09d")

data(countrycode_data)
countrycode_data <- tbl_df(countrycode_data)
countrycode_data

fips <- countrycode_data$fips104
fips <- na.omit(fips)

fips_valid <- map_chr(sample(fips), function(x){ # x <- "AL"
  message(x)
  try({
    idb1(x, 1990, variables = c("AGE", "POP"))
    return(x)
  })
})

countrycode_data <- filter(countrycode_data, fips104 %in% fips_valid)
countrycode_data



set.seed(9876543)
countrycode_data %>% 
  sample_n(1) %>% 
  print() %>% 
  .[["fips104"]] -> fip

yrs <- 1990:2050
brks <- seq(0, 100, length.out = 10 + 1)


data <- idb1(fip, yrs, variables = c("AGE", "POP", "NAME"))
data


datag <- data %>% 
  mutate(agec = cut(AGE, breaks = brks, include.lowest = TRUE)) %>% 
  group_by(name = NAME, fip = FIPS, year = time, agec) %>% 
  summarise(pop = sum(POP),
            age_median = round(median(AGE))) %>% 
  ungroup() %>% 
  mutate(birth_year = year - age_median) %>% 
  print()


colors <- hex_to_rgba(inferno(length(brks) - 1, end = 0.9))

hchart(datag, "area", hcaes(year, pop, group = agec),
       color = colors, showInLegend = FALSE) %>% 
  hc_tooltip(table = TRUE) %>% 
  hc_plotOptions(
    series = list(
      stacking = "normal",
      marker = list(symbol = "circle", size = 0.1, enabled = FALSE, lineWidth = 0)
      )
    )

#' now 
#' 
#' 
paltte <- scales::col_numeric(str_sub(inferno(100), 0, -3),
                              domain = sort(unique(datag$birth_year)))

datag <- mutate(datag, segmentColor = paltte(birth_year))
datag


hc <- hchart(datag, "coloredarea", hcaes(year, pop, group = agec),
             color = "#444", showInLegend = FALSE) %>%
  hc_tooltip(table = TRUE) %>% 
  hc_plotOptions(
    series = list(
      stacking = "normal",
      marker = list(symbol = "circle", size = 0.1, enabled = FALSE, lineWidth = 0)
    )
  )

library(htmltools)
dep <-  htmlDependency(
  name = "multicolor_series",
  version = "1.1.0",
  src = c(
    href = "http://blacklabel.github.io/multicolor_series/js/"
  ),
  script = "multicolor_series.js"
)

hc$dependencies <- c(hc$dependencies, list(dep))

hc


