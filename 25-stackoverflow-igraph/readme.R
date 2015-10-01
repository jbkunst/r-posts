rm(list = ls())
library("httr")
library("igraph")
library("plyr")
library("dplyr")
library("purrr")
library("ggplot2")
library("tidyr")


# From https://api.stackexchange.com/docs/questions

# Global Parameters
SITE <- "stackoverflow"
TAG <- "r"
NPAGES <- 500 # 500 # 3600
API_URL <- "https://api.stackexchange.com/2.2/questions"
NTAGS <- 50

# Question List
qlist <- seq(NPAGES) %>% 
  map(function(p){
    # p <- 2
    data <- API_URL %>% 
      GET(query = list(site = SITE, tagged = TAG, page = p, sort = "creation")) %>% 
      content()
    data$items
  }) %>% 
  unlist(recursive = FALSE)

# saveRDS(qlist, "qlist.Rds")
qlist <- readRDS("qlist.Rds")


# Dataframe with question_id, question_tag
df_qtag <- ldply(qlist, function(x){
  # x <- sample(qlist, size = 1)[[1]]
  tags <- x$tags %>% unlist()
  if (length(tags) > 1) {
    data_frame(question_tag = setdiff(tags, TAG),
               question_id = x$question_id)  
  }
}, .progress = "tk")

df_qtag <- tbl_df(df_qtag)

toptags <- df_qtag %>%
  count(question_tag) %>% 
  arrange(desc(n)) %>% 
  head(NTAGS) %>%
  mutate(question_tag = factor(question_tag, rev(question_tag)))

toptags

ggplot(toptags) + 
  geom_bar(aes(question_tag, n), stat = "identity", width = 0.5) + 
  coord_flip()


# Examine a element in the list:
x <- sample(qlist, size = )[[1]]
str(x)

classes <- map(x, class) %>%
  dplyr::as_data_frame() %>% 
  gather(name, class)

classes

namestoselc <-  classes %>%
  filter(class != "list" & name != "link") %>%
  .$name

namestoselc


# Dataframe Questions
df_qst <- ldply(qlist, function(x){
  # x <- sample(qlist, size = 1)[[1]]
  x[ which(names(x) %in% namestoselc)] %>% 
    as_data_frame()
}, .progress = "win")

df_qst <- tbl_df(df_qst)

df_qst <- df_qst %>% 
  mutate(creation_date_2 = as.POSIXct(creation_date, origin="1970-01-01"))

df_qst$creation_date_2 %>% summary()


df_date_tags <- df_qst %>%
  select(question_id, creation_date_2) %>% 
  inner_join(df_qtag) %>% 
  filter(as.Date(creation_date_2) > as.Date("2015-01-01"))

ggplot(df_date_tags) + 
  geom_density(aes(creation_date_2, fill = question_tag))


