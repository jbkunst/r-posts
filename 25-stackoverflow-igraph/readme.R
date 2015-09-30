rm(list = ls())
library("httr")
library("plyr")
library("dplyr")
library("purrr")
library("igraph")
library("ggplot2")



# Global Parameters
SITE <- "stackoverflow"
TAG <- "r"
NPAGES <- 10
API_URL <- "https://api.stackexchange.com/2.2/questions"
NTAGS <- 50

# Question List
qlist <- seq(PAGES) %>% 
  map(function(p){
    # p <- 2
    data <- API_URL %>% 
      GET(query = list(site = SITE, tagged = TAG, page = p)) %>% 
      content()
    data$items
  }) %>% 
  unlist(recursive = FALSE)


# Question Tags Dataframe
qst_tgs <- ldply(question_list, function(x){
  # x <- sample(question_list, size = 1)[[1]]
  tags <- x$tags %>% unlist()
  if (length(tags) > 1) {
    data_frame(question_tag = setdiff(tags, TAG),
               question_id = x$question_id)  
  }
}, .progress = "win")

qst_tgs <- tbl_df(qst_tgs)

dftags <- qst_tgs %>%
  count(question_tag) %>%
  arrange(desc(n)) %>% 
  mutate(question_tag = factor(question_tag, levels = rev(question_tag)))

head(dftags)

ggplot(dftags %>% head(50)) +
  geom_bar(aes(question_tag, n), stat = "identity", width = 0.5) + 
  coord_flip()






