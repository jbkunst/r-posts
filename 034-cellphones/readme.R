#' ---
#' title: ""
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())
knitr::opts_chunk$set(message=FALSE, warning=FALSE)

#'
library("dplyr")
library("rvest")
library("magrittr")
library("stringr")
library("tidyr")

url <- "http://www.gsmarena.com/"

links <- read_html(str_c(url, "makers.php3")) %>% 
  html_nodes("table a")

dfbrands <- data_frame(brand = html_text(links),
                       brand_url = html_attr(links, "href")) %>% 
  filter(brand != "") %>% 
  mutate(brand = str_replace(brand, "phones", "")) %>% 
  separate(brand, c("brand", "phones"),  "\\(") %>% 
  mutate(phones = str_extract(phones, "\\d+"),
         phones = as.numeric(phones))



