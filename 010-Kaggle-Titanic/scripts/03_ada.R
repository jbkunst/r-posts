#### WS ####
rm(list=ls())
library("ada")
library("ggplot2")

#### LOAD DATA ####
load("../data/process_data.RData")


dtrnf$Survived <- (dtrnf$Survived == "Y") %>% as.numeric
  

#### MODELLING ####
set.seed(500)
mod <- ada::ada(Survived ~ ., data=dtrnf, iter = 100)

plot(mod)
mod
summary(mod)



#### PREDICT ####
preds <- predict(mod, newdata = dtstf)
qplot(preds)


dtstf$Survived <- preds

if(dtstf %>% filter(is.na(Survived)) %>% nrow == 0){
  message("YAY!")
} else {
  message("Some NAs")
}

write.csv(dtstf  %>% select(PassengerId, Survived),
          file=sprintf("../output/ada_preds_%s.csv", Sys.Date()),
          quote=FALSE, row.names=FALSE)




