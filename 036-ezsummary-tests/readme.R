#' ---
#' title: ""
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+echo=FALSE
knitr::opts_chunk$set(warning=FALSE)

#+echo=TRUE
library("dplyr")
library("ezsummary")

data(diamonds, package = "ggplot2")
tbl <- diamonds

select_categorical <- function(tbl, nuniques = 10){
  
  selections <- purrr::map_lgl(tbl, function(x) {
    is.character(x) ||
      is.factor(x) ||
      is.logical(x) ||
      (length(unique(x)) <= nuniques) # this is when you have numeric variables with few uniques (dummies)
  })
  tbl[, selections]
  
}

select_quantitative <- function(tbl){
  
  selections <- purrr::map_lgl(tbl, function(x) is.numeric(x))
  tbl[, selections]
  
}

diamonds %>% 
  select_categorical() 

diamonds %>% 
  select_quantitative()


#### ####

# tbl <- diamonds %>% select_categorical() %>%  group_by(cut)
# tbl <- diamonds %>% select_categorical() %>%  group_by(cut, color)

ezsummary_categorical2 <- function(tbl){
  
  grp_cols <- names(attr(tbl, "labels"))
  
  tbl %>%
    purrr::map_if(is.factor, as.character) %>% # avoid warning
    as_data_frame() %>% # this ungroup the tbl
    group_by_(.dots = lapply(grp_cols, as.symbol)) %>%  # http://stackoverflow.com/questions/21208801/
    do({ezsum = 
      tidyr::gather(., key, value) %>% # you can use tidyr::gather(., variable, category)
      ungroup() %>%
      count(key, value) %>% 
      mutate(p = n/sum(n))
    }) %>% 
    # ungroup() %>%
    filter(!key %in% grp_cols) # not sure whiy appear as key a group col
 
}

diamonds %>%
  select_categorical() %>% 
  ezsummary_categorical() 

diamonds %>%
  select_categorical() %>% 
  ezsummary_categorical2() 

library(rbenchmark)

tblcat <- diamonds %>% select_categorical()
tblcat <- diamonds %>% select_categorical() %>%  group_by(cut, color)

benchmark(
  ezsummary_categorical(tblcat),
  ezsummary_categorical2(tblcat),
  replications = 100
)
# Mmm not so fast

t1 <- diamonds %>%
  select_categorical() %>% 
  ezsummary_categorical2() 

t1

# check how much groups are 
sum(t1$p) == nrow(distinct(t1, key))

t2 <- diamonds %>%
  select_categorical() %>% 
  group_by(cut, color) %>% 
  ezsummary_categorical2()

t2

# check how much groups are 
sum(t2$p) == nrow(distinct(t2, cut, color, key))

mtcars %>% 
  select_categorical(nuniques = 2) %>% 
  ezsummary_categorical2()




