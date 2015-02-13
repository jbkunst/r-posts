#### WS ####
rm(list=ls())
library("nloptr")
library("adabag")
library("ggplot2")

#### LOAD DATA ####
load("../data/process_data.RData")


#### MODELLING ####
set.seed(500)
mod <- adabag::boosting(Survived ~ ., data=dtrnf, mfinal = 200)

plot(mod)
mod
summary(mod)



#### PREDICT ####
preds <- predict(mod, newdata = dtstf)
qplot(preds)
preds <- ifelse(preds>.5, 1, 0)

dtstf$Survived <- preds

if(dtstf %>% filter(is.na(Survived)) %>% nrow == 0){
  message("YAY!")
} else {
  message("Some NAs")
}

write.csv(dtstf  %>% select(PassengerId, Survived),
          file=sprintf("../output/gbm_preds_%s.csv", Sys.Date()),
          quote=FALSE, row.names=FALSE)




