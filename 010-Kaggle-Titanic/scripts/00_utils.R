df.summary <- function(df){
  result <- 
    (ldply(df, function(x){ x  %>% is.na  %>% sum })     %>% setNames(c("Var", "NAs"))) %>%
    left_join(ldply(df, function(x){ x  %>% unique  %>% length})  %>% setNames(c("Var", "Uniques")), by = "Var") %>%
    left_join(ldply(df, class) %>% setNames(c("Var", "Class")), by = "Var")
  result
}

df.chr2factor <- function(df){
  
  df[,laply(df, is.character)] <- llply(df[,laply(df, is.character)], as.factor) %>%
    as.data.frame
  df
  
}