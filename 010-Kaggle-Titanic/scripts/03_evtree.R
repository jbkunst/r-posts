#### WS ####
rm(list=ls())
library("evtree")
library("ggplot2")

#### LOAD DATA ####
load("../data/process_data.RData")


# dtrnf$Survived <- (dtrnf$Survived == "Y") %>% as.numeric
  

#### MODELLING ####
set.seed(500)

ntree <- 20
mods <- llply(seq(ntree), function(index){ # index <- sample(seq(ntree), size = 1)
  
  idxs <- sample(nrow(dtrnf), replace = TRUE)
  daux <- dtrnf[idxs,]
  mt <- 5
  vars <- sample(setdiff(names(dtrnf), "Survived"), size = mt)
  daux <- daux %>% subset(select = c("Survived", vars))
    
  mod <- evtree::evtree(Survived ~ ., data=daux)
  mod$data <- NULL
  mod
}, .progress="text")



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




