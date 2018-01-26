library(tidyverse)
library(rtweet)
library(memoise)

users <- search_users(q = "#rstats", n = 1000, parse = TRUE)
users <- unique(users)

users_n_friends <- users %>% 
  pull(user_id) %>% 
  get_friends(retryonratelimit = TRUE, verbose = TRUE)

