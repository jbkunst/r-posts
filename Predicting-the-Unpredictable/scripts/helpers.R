per.n <- function(p = "201201", n.ahead = 1){
  # per.n(n.ahead = -4);  per.n(n.ahead = 12)
  format(ymd(paste0(p, "01")) + months(n.ahead), "%Y%m")  
}

getWindows <- function(pers = per.n("201112", n.ahead =  seq(24)),
                       n.months.train = 3, n.months.val = 2){
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

Modelling <- function(splitdata = getSplitData(data), ){
  
}