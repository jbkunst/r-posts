per.n <- function(p = "201201", n.ahead = 1){
  # per.n(n.ahead = -4);  per.n(n.ahead = 12)
  format(ymd(paste0(p, "01")) + months(n.ahead), "%Y%m")  
}

getWindows <- function(pers = per.n("201112", n.ahead =  seq(24)),
                       n.months.train = 8, n.months.val = 1){
  pers <- sort(pers)
  n.months <- n.months.train + n.months.val
  n.windows <- length(pers)-n.months
  
  windows <- llply(seq(n.windows), function(idx){ # idx <- sample(n.windows, size = 1) # idx <- 1
    list(train.monhts = pers[(idx):(idx+n.months.train-1)],
         val.months = pers[(idx+n.months.train):(idx+n.months.train-1+n.months.val)])
  })

}

getSplitData <- function(data=data, window = getWindows()[[1]]){
  
  dtrain <- data %>% filter(periodo %in% window$train.monhts)

  dtest <- data %>% filter(periodo %in% window$val.months)
  
  list(dtrain = dtrain, dtest = dtest)
  
}

getRFPerformance <- function(splitdata = getSplitData(data),
                             response.name ="LABEL.BUY",
                             predictive.names.patter = "att",
                             ntree = 200,
                             cut.point = 0.7){
  
  dtrain <- splitdata$dtrain
  dtest <- splitdata$dtest
  
  fml <- sprintf("factor(%s)", response.name)
  fml <- paste(fml, "~", paste(str_pattern(names(dtrain), predictive.names.patter), collapse =  " + "))  
  fml <- as.formula(fml)
  mod.rf <- randomForest(fml, data=dtrain, do.trace = TRUE, ntree = ntree)
  
  dtrain$prob <- predict(mod.rf, newdata = dtrain, type = "prob")[,2]
  dtrain$pred <- ifelse(dtrain$prob >= cut.point, 1, 0)
  
  dtest$prob <- predict(mod.rf, newdata = dtest, type = "prob")[,2]
  dtest$pred <- ifelse(dtest$prob >= cut.point, 1, 0)
  
  # t testing
#   tt <- score_indicators(dtrain$prob, dtrain$LABEL.BUY) %>% select(Size, Goods, Bads, BadRate, KS, AUCROC)
#   tt <- setNames(tt, paste0("Train", names(tt)))
#   tt <- cbind(tt, P = conf_matrix(dtrain$pred, dtrain$LABEL.BUY)$indicators.t$P)
#   tt
  
  # t val
  tv <- score_indicators(dtest$prob, dtest$LABEL.BUY) %>% select(Size, Goods, Bads, BadRate, KS, AUCROC)
  tv <- setNames(tv, paste0("Test", names(tv)))
  tv <- cbind(tv, TestPrecision = conf_matrix(dtest$pred, dtest$LABEL.BUY)$indicators.t$P)
  tv <- cbind(tv, TestEntry = dtrain %>% filter(pred==1) %>% nrow() / nrow(dtrain))
  
  cbind(data.frame(per.base = max(splitdata$dtrain$periodo)), tv)
   
}



str_pattern <- function (string, pattern){
  require(stringr)
  string[str_detect(string, pattern)]
}
