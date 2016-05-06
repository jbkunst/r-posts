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
knitr::opts_chunk$set(message = FALSE, warning = FALSE,
                      fig.showtext = TRUE, dev = "CairoPNG")

#' This script is inspired and some copy&paste from:
#' 
#' * https://rpubs.com/chengjiun/52658
#' * http://amunategui.github.io/blending-models/

#' 
#' # Data
library(dplyr)
library(lubridate)
df <- readr::read_csv("train.csv")

head(df)

df <- df %>% 
  mutate(year = year(datetime),
         month = month(datetime),
         day = day(datetime),
         hour = hour(datetime)) %>% 
  dplyr::select(-datetime)

#' Samples
set.seed(123)

trainIndex <- createDataPartition(df$count, p = 0.8, list = FALSE, times = 1)

dftrain <- df[trainIndex, ]
dftest <- df[-trainIndex, ]


#'
#' # Feature Selection

#'
#' ## RRF
library(RRF)


#'
#' # Models
library(caret)
library(purrr)

#' Models whichs support regression:

map(getModelInfo(), "type") %>% 
  map_lgl(function(x) {
    any(x == "Regression")
  }) %>% 
  {.[.]} %>% 
  names()

formula <- count ~ .

mods_names <- c("neuralnet", "glmboost", "kknn", "ctree", "gbm", "lasso", "gamboost")

mods_fit <- map(mods_names, function(x){
  message(x)
  train(formula, data = dftrain, method = x) 
})

#'
#' # Validation
library(Metrics)

mape <- function(actual, predicted) {
  mean(abs((actual - predicted)/actual))
}

predictions <- predict(mods_fit, newdata = dftest)

names(predictions) <- mods_names

map(predictions, head)

act <- dftest$count

resulst <- map_df(predictions, function(x){
  data_frame(
    mse = mse(act, x),
    mae = mae(act, x),
    mape = mape(act, x)
  )
}, .id = "model")

resulst

