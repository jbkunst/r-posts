library(tidyverse)
library(rtweet)
library(memoise)


cfs <- memoise::cache_filesystem(".cache")

my_get_friends <- function(user_id = 7220752) {
  
  message(user_id)
  
  t0 <- Sys.time()
  
  while(TRUE) {
    
    message("waiting: ", round(difftime(Sys.time(), t0, units = "mins"), 3), " mins")
    
    out <- get_friends(user_id, verbose = TRUE)
    
    if(is.data.frame(out)) { break } else { Sys.sleep(0.5) } 
    
  }
  
  out
  
}
  

m_my_get_friends <- memoise(my_get_friends, cache = cfs)

m_my_get_friends()


users <- search_users(q = "#rstats", n = 5000, parse = TRUE)
users <- unique(users)


to_rmv <- c("733994123678490625", "733994123678490625", "844152803991994368",
            "735111228322906112", "804915763")

users_n_friends <- users %>% 
  filter(!user_id %in% to_rmv) %>% 
  pull(user_id) %>% 
  map_df(m_my_get_friends)
