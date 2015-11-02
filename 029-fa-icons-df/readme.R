#' ---
#' title: "Download FA list"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: false
#'    keep_md: yes
#' ---

#' http://fortawesome.github.io/Font-Awesome/cheatsheet/

library("rvest")
library("plyr")
library("dplyr")
library("stringr")

rm(list = ls())

icons <- read_html("http://fortawesome.github.io/Font-Awesome/cheatsheet/") %>% 
  html_nodes("div.col-md-4.col-sm-6.col-lg-3")

dficons <- ldply(icons, function(divico){ # divico <- sample(icons, size = 1)[[1]]
    txt <- html_text(divico)
    data_frame(name = str_extract(txt, "fa-.*"),
               unicode = str_extract(txt, "\\[.*\\]") %>% str_replace_all("\\[|\\]", ""))
  }) 

dficons <- tbl_df(dficons)

dficons
