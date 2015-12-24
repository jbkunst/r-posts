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
rm(list = ls())
library("highcharter")
library("magrittr")

#
highchart() %>% 
  hc_title(text = "My favorite Bars") %>%
  hc_subtitle(text = "My favorite Bars") %>% 
  hc_chart(type = "pie") %>% 
hc_xAxis(categories = c("a", "b")) %>% 
  hc_add_serie(data = c(4, 5))

highchart() %>% 
  hc_title(text = "My favorite Pie") %>% 
  hc_subtitle(text = "My favorite Bars") %>% 
  hc_chart(type = "column") %>% 
  hc_xAxis(categories = c("a", "b")) %>% 
  hc_add_serie(data = c(4, 5))
