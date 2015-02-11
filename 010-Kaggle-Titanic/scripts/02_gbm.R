#### WS ####
rm(list=ls())
library("gbm")

#### LOAD DATA ####
load("../data/process_data.RData")


dtrnf$Survived <- (dtrnf$Survived == "Y") %>% as.numeric
  

#### MODELLING ####
set.seed(500)
mod <- gbm(Survived ~ ., data=dtrnf, n.trees = 1000)

plot(mod)
mod
summary(mod)



#### PREDICT ####
preds <- predict(mod, newdata = dtstf, n.trees = 1000)
preds <- ifelse(preds>0, 1, 0)

dtstf$Survived <- preds

if(dtstf %>% filter(is.na(Survived)) %>% nrow == 0){
  message("YAY!")
} else {
  message("Some NAs")
}

write.csv(dtstf  %>% select(PassengerId, Survived),
          file=sprintf("../output/gbm_preds_%s.csv", Sys.Date()),
          quote=FALSE, row.names=FALSE)




