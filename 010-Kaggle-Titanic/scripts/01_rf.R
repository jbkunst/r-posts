#### WS ####
rm(list=ls())
library("randomForest")
library("dplyr")
source("00_utils.R")

#### LOAD DATA ####
load("../data/process_data.RData")


#### MODELLING ####
head(data)

train <- data %>% filter(!is.na(Survived)) %>% select(-PassengerId)
test <- data %>% filter(is.na(Survived))
  

data %>% df.summary %>% filter(Class=="factor") %>% filter(Uniques>=32)

set.seed(500)
mod <- randomForest(factor(Survived) ~ ., data=train, ntree = 3000, do.trace = TRUE)

plot(mod)
importance(mod)
varImpPlot(mod)


#### PREDICT ####
preds <- predict(mod, newdata = test)

test$Survived <- preds

if(test %>% filter(is.na(Survived)) %>% nrow == 0){
  message("YAY!")
} else {
  message("Some NAs")
  test %>% filter(is.na(Survived))
}

write.csv(test  %>% select(PassengerId, Survived),
          file=sprintf("../output/rf_preds_%s.csv", Sys.Date()),
          quote=FALSE, row.names=FALSE)




