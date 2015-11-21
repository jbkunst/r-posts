rm(list = ls())
library("dplyr")
library("rvest")



dfcolors <- read_html("http://lego.wikia.com/wiki/Colour_Palette") %>% 
  html_nodes("table") %>% 
  html_table(fill = TRUE) %>% 
  .[[3]] %>% 
  tbl_df()

dfcolors2 <- read_html("http://www.peeron.com/cgi-bin/invcgis/colorguide.cgi") %>% 
  html_nodes("table") %>% 
  html_table(fill = TRUE) %>% 
  .[[1]] %>% 
  tbl_df()

