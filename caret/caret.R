#### Introduction #####
# package: caret 
# paper: http://www.jstatsoft.org/v28/i05/paper

#### Setup ws ####
rm(list=ls())
library(plyr)
# l_ply(c("caret", "e1071"), function(x){ install.packages(x) })
library(caret)
set.seed(1)

#### Load Data ####
data(GermanCredit)
str(GermanCredit)
head(GermanCredit)
str(GermanCredit[, 1:10])
df <- GermanCredit[, 1:10]


#### Creating partition ####
inTrain <- createDataPartition(y = df$Class, p = .75, list = FALSE)

str(inTrain)
length(inTrain)/nrow(df)

training <- df[inTrain,]
testing <- df[-inTrain,]

ldply(list(df, training, testing), function(x){
  prop.table(table(x$Class))
})


#### Finding correlations ####
methods <- c("rpart", "ctree", "gbm","rf", "cforest", "nnet")

models <- llply(methods, function(x){
  fit <- train(training, y=training$Class, method=x, metric="ROC")
  fit
}, .progress="text")

names(models)

class(models[1])
class(models[[2]])
train <- models[[2]]
names(train)

predict(models[[1]], newdata = testing, )
predict(models[[2]], newdata = testing)
predict(models[[3]], newdata = testing)
predict(models[[4]], newdata = testing)
predict(models[[5]], newdata = testing)
predict(models[[6]], newdata = testing)

resamples
