#### WS ####
rm(list=ls())
library("randomForest")

#### LOAD DATA ####
load("../data/process_data.RData")


#### MODELLING ####
set.seed(500)
mod <- randomForest(Survived ~ ., data=dtrnf, ntree = 2000, do.trace = TRUE)

plot(mod)
importance(mod)
varImpPlot(mod)


#### PREDICT ####
dtstf$Survived <- ifelse(predict(mod, newdata = dtstf)=="Y", 1, 0)

if(dtstf %>% filter(is.na(Survived)) %>% nrow == 0){
  message("YAY!")
} else {
  message("Some NAs")
}

write.csv(dtstf  %>% select(PassengerId, Survived),
          file=sprintf("../output/rf_preds_%s.csv", Sys.Date()),
          quote=FALSE, row.names=FALSE)




