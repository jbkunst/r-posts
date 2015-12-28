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
data(favorite_bars)

highchart() %>% 
  hc_title(text = "My favorite Bars") %>%
  hc_subtitle(text = "(In percentage of awesomeness)") %>% 
  hc_chart(type = "pie") %>% 
  hc_xAxis(categories = favorite_bars$bar) %>% 
  hc_add_serie(data = favorite_bars$percent)

data(favorite_pies)

highchart() %>% 
  hc_title(text = "My favorite Pie") %>% 
  hc_subtitle(text = "(In percentage of tastiness)") %>% 
  hc_chart(type = "column") %>% 
  hc_xAxis(categories = favorite_pies$pie) %>% 
  hc_add_serie(data = favorite_pies$percent)
