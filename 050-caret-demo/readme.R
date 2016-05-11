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

#' 
#' # Data
library(dplyr)
library(lubridate)
library(caret)

df <- readr::read_csv("train.csv")

head(df)

df <- df %>% 
  mutate(year = year(datetime),
         month = month(datetime),
         day = day(datetime),
         hour = hour(datetime)) %>% 
  dplyr::select(-datetime, -year)

#' Samples
set.seed(123)

trainIndex <- createDataPartition(df$count, p = 0.5, list = FALSE, times = 1)

dftrain <- df[trainIndex, ]
dftest <- df[-trainIndex, ]

x <- dftrain %>% select(-count)
y <- dftrain[["count"]]
#'
#' # Feature Selection

#'
#' ## RRF
library(RRF)

formula <- count ~ .

rrf <- RRF(formula, dftrain)

rrfimp <- importance(rrf) %>% 
  as.data.frame() %>% 
  add_rownames("variable") %>% 
  arrange(desc(IncNodePurity))


#'
#' ## RFE
#'
rfeCtrl <- rfeControl(functions = lmFuncs, method = "repeatedcv", repeats = 10, verbose = FALSE)

lmProfile <- rfe(x, y, sizes = c(1:5, 10, 15), rfeControl = rfeCtrl)

names(lmProfile)

lmProfile$fit
  
#'
#' ## Filters
filterCtrl <- sbfControl(functions = rfSBF, method = "repeatedcv", repeats = 10)

rfWithFilter <- sbf(x, y, sbfControl = filterCtrl)

rfWithFilter

#'
#' # Models & Validation
library(caret)
library(purrr)
library(Metrics)

#' Models whichs support regression:

map(getModelInfo(), "type") %>% 
  map_lgl(function(x) {
    any(x == "Regression")
  }) %>% 
  {.[.]} %>% 
  names() %>% 
  sort()

mods_names <- c("earth", "ctree", "rpart", "rf", "gbm", "nnet")

seqnvars <- seq(nrow(rrfimp))

act <- dftest$count


dfbench <- map(seqnvars[-1], function(nvars){
  # nvars <- 5
  
  dftrainsub <- dftrain[, seq(1, 1 + nvars)]
  
  mods_fit <- map(mods_names, function(modname){
    
    # modname <- "earth"
    
    message("variables: ", nvars, " | modelo: ", modname)
    
    train(y = dftrain$count, x = dftrainsub, method = modname) 
    
  })
  
  predictions <- predict(mods_fit, newdata = dftest)
  
  mses <- map_dbl(predictions, function(x){
    mse(x, act)
  })
  
  data_frame(mod = mods_names, mse = mses, nvar = nvars)
  
})

dfbench2 <- map_df(dfbench, identity) %>% 
  mutate(nmvar = rep(rrfimp$variable, each = length(mods_names)),
         nmvar = factor(nmvar, rrfimp$variable))


library(ggplot2)

ggplot(dfbench2) +
  geom_line(aes(nmvar, mse, group = mod, color = mod)) + 
  coord_flip() + 
  scale_y_reverse()

ggplot(dfbench2) +
  geom_line(aes(nmvar, mse, group = mod, color = mod)) +
  # theme(axis.text.x = element_text(angle = 90)) + 
  scale_y_log10()

dfbench2 %>% filter(nmvar == "season")

