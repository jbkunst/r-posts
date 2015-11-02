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
    
    if (data$has_more) carry_on <- data$has_more
    if (actual_page %% 100 == 0) message("page: ",actual_page ," | quota remaining: ", data$quota_remaining)
    
    qlist[[actual_page]] <- data$items
    actual_page <- actual_page + 1
    
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

df_qtag_moretags <- inner_join(df_qtag,
                               df_qtag %>% count(question_id) %>% filter(n > 1) %>% select(question_id),
                               by = "question_id")


df_qtag_moretags %>% count(question_tag) %>% arrange(desc(question_tag))





df_qtag_top <- df_qtag %>% 
  count(question_tag) %>% 
  ungroup() %>% 
  arrange(desc(n)) %>% 
  head(NTAGS) %>% 
  mutate(question_tag = factor(question_tag, levels = rev(question_tag)))

ggplot(df_qtag_top) + 
  geom_bar(aes(question_tag, n), stat = "identity") +
  coord_flip()
  
top_tags <-  df_qtag_top$question_tag




daux <- df_qtag %>%
  filter(question_tag %in% top_tags) %>%
  mutate(count = 1)

t <- xtabs(count ~ question_id + question_tag, data = daux)

as.matrix(t)[, "ggplot2"]

df_qtag %>% 
  mutate(count = 1) %>% 
  spread(question_id, question_tag)


dfcounttags <- df_qtag %>%
  count(question_tag) %>% 
  arrange(desc(n)) %>% 
  mutate(question_tag = factor(question_tag, rev(question_tag))) %>% 
  head(NTAGS)


dftagsedges <- expand.grid(tag1 = dfcounttags$question_tag,
                           tag2 = dfcounttags$question_tag) %>% 
  tbl_df() %>% 
  filter(tag1 != tag2)

dftagsedges



ggplot(toptags) + 
  geom_bar(aes(question_tag, n), stat = "identity", width = 0.5) + 
  coord_flip()



df_qst$creation_date %>% summary()
df_qst$creation_date %>% as.Date()

t <- "2015-01-21"
format(df_qst$creation_date, "%Y%m01")


df_date_tags <- df_qst %>%
  select(question_id, creation_date) %>% 
  inner_join(df_qtag) %>% 
  mutate(creation_date =  ymd(format(creation_date, "%Y%m01"))) %>% 
  count(creation_date, question_tag) %>% 
  ungroup()


df_date_tags %>% 
  filter(question_tag %in% toptags$question_tag) %>% 
  .$question_tag

df_date_tags %>%
  filter(question_tag %in% toptags$question_tag,
         creation_date <= ymd("20150901")) %>%
  mutate(question_tag = factor(question_tag, levels = toptags$question_tag)) %>% 
  ggplot() + 
  geom_smooth(aes(creation_date, n, group = question_tag),
              color = "darkred", size = 1.5, se = FALSE) + 
  facet_wrap(~question_tag, scales = "free_y", ncol = 6) +
  theme(legend.position = "none")


