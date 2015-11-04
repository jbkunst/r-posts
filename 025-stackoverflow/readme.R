rm(list = ls())
library("httr")
library("igraph")
library("plyr")
library("dplyr")
library("purrr")
library("ggplot2")
library("tidyr")
library("lubridate")


# From https://api.stackexchange.com/docs/questions

# Global Parameters
SITE <- "stackoverflow"
TAG <- "r"
KEY <- "ifpYG3FCatEyPyX8AqkVCA(("
API_URL <- "https://api.stackexchange.com/2.2/questions"
NTAGS <- 50


##### Question List
question_donwload <- function(verbose = FALSE){
  qlist <- list()
  carry_on <- TRUE
  actual_page <- 1
  
  while (carry_on) {
    data <- API_URL %>%
      GET(query = list(site = SITE, tagged = TAG, page = actual_page, key = KEY,
                       sort = "creation", pagesize = 100, order = "desc")) %>% 
      content()
    
    if (actual_page %% 500 == 0) message("page: ",actual_page ," | quota remaining: ", data$quota_remaining)
    
    qlist[[actual_page]] <- data$items
    
    actual_page <- actual_page + 1
    
    carry_on <- data$has_more
    
  }
  
  qlist <- unlist(qlist, recursive = FALSE)
  
}
# qlist <- question_donwload()
# saveRDS(qlist, "qlist.Rds")
qlist <- readRDS("qlist.Rds")

#### Questions Dataframe
# Examine a element in the list:
x <- sample(qlist, size = )[[1]]
str(x)

namestoselc <- map(x, class) %>%
  dplyr::as_data_frame() %>% 
  gather(name, class) %>% 
  filter(class != "list" & name != "link") %>%
  .$name %>% 
  as.character()

df_qst <- ldply(qlist, function(x){
  # x <- sample(qlist, size = 1)[[1]]
  x[ which(names(x) %in% namestoselc)] %>% 
    as_data_frame()
}, .progress = "win")

df_qst <- tbl_df(df_qst)

rm(x, namestoselc)

df_qst <- df_qst %>% 
  mutate(creation_date = as.POSIXct(creation_date, origin = "1970-01-01"),
         last_activity_date = as.POSIXct(last_activity_date, origin = "1970-01-01"),
         creation_month = format(creation_date, "%Y-%m-01") %>% as.Date())

df_qst %>% 
  count(creation_month) %>% 
  ggplot(aes(creation_month, n)) + 
  geom_smooth()

# Dataframe with question_id, question_tag
df_qtag <- ldply(qlist, function(x){
  # x <- sample(qlist, size = 1)[[1]]
  tags <- x$tags %>% unlist()
  if (length(tags) > 1) {
    data_frame(question_tag = tags,
               question_id = x$question_id)  
  }
}, .progress = "win")

df_qtag <- tbl_df(df_qtag)
df_qtag <- df_qtag %>% filter(question_tag != "r")


