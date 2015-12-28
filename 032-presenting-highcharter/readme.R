#' ---
#' title: "Presenting Highcharter"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    theme: journal
#'    toc: false
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE

#### setup ws packages ####
#+ echo=TRUE, message=FALSE, warning=FALSE
rm(list = ls())
library("highcharter")
library("magrittr")
library("dplyr")


#
head(iris)
iriscount <- count(iris, Species)

highchart() %>% 
  hc_title(text = "Edgar Anderson's Iris Data") %>%
  hc_xAxis(title = list(text = "Sepal Length")) %>% 
  hc_yAxis(title = list(text = "Sepal Width")) %>%
  hc_add_serie_scatter(iris$Sepal.Length, iris$Sepal.Width, iris$Species) %>% 
  hc_add_serie_labels_values(iriscount$Species, iriscount$n, type = "pie", name = "Total",
                             colorByPoint = TRUE, center = c('80%', '10%'),
                             size = 100, dataLabels = list(enabled = FALSE)) %>% 
  hc_add_theme(hc_theme_sandsignika())


data("favorite_bars")
data("favorite_pies")

highchart() %>% 
  hc_title(text = "This is a bar graph describing my favorite pies
           including a pie chart describing my favorite bars") %>%
  hc_subtitle(text = "In percentage of tastiness and awesomeness") %>% 
  hc_add_serie_labels_values(favorite_pies$pie, favorite_pies$percent, name = "Pie",
                             colorByPoint = TRUE, type = "column") %>% 
  hc_add_serie_labels_values(favorite_bars$bar, favorite_bars$percent, type = "pie",
                             name = "Bar", colorByPoint = TRUE, center = c('35%', '10%'),
                             size = 100, dataLabels = list(enabled = FALSE)) %>% 
  hc_yAxis(title = list(text = "percentage of tastiness"),
           labels = list(format = "{value}%"), max = 100) %>% 
  hc_xAxis(categories = favorite_pies$pie) %>% 
  hc_legend(enabled = FALSE) %>% 
  hc_tooltip(pointFormat = "{point.y}%")
