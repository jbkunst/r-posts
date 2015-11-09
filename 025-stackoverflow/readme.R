#' ---
#' title: "What we ask in SO"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: false
#'    keep_md: yes
#' categories: R
#' layout: post
#' featured_image: /images/rchess-a-chess-package-for-r/featured_image-1.jpg
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
rm(list = ls())
library("stringr")
library("rvest")
library("readr")
library("plyr")
library("dplyr")
library("tidyr")
library("ggplot2")
library("showtext") 
library("zoo")
library("lubridate")

knitr::opts_chunk$set(warning = FALSE, cache = FALSE, fig.showtext = TRUE, dev = "CairoPNG", fig.width = 8)

font.add.google("Lato", "myfont")
showtext.auto()

theme_set(theme_minimal(base_family = "myfont") +
            theme(legend.position = "none",
                  text = element_text(size = 10),
                  title = element_text(size = 12)))


#'> When you're down and troubled <br/>
#'> And you need a **coding** hand <br/>
#'> And nothing, nothing is going right <br/>
#'> Open a **browser** and **type** of this <br/>
#'> And the first match will be there <br/>
#'> To brighten up even your darkest night.
#'

urls_data <- c(
  "https://data.stackexchange.com/stackoverflow/csv/497945",
  "https://data.stackexchange.com/stackoverflow/csv/497932",
  "https://data.stackexchange.com/stackoverflow/csv/497931",
  "https://data.stackexchange.com/stackoverflow/csv/497930",
  "https://data.stackexchange.com/stackoverflow/csv/497900",
  "https://data.stackexchange.com/stackoverflow/csv/497929")

dfqst <- ldply(urls_data, read_csv, .progress = "win")

dfqst <- tbl_df(dfqst) %>% 
  setNames(names(.) %>% tolower())

dftags <- adply(dfqst %>% select(id, creationdate, tags), .margins = 1, function(x){
  # x <- sample_n(dfqst %>% select(id, CreationDate, Tags), size = 1)
  tags <- str_split(x$tags, "<|>") %>% 
    unlist() %>% 
    setdiff(c("", "r"))
  data_frame(tag = tags)
}, .progress = "win") %>% tbl_df() %>% select(-tags)


dftagsmonth <- dftags %>% 
  mutate(creationdatemonth = as.yearmon(creationdate)) %>% 
  group_by(creationdatemonth, tag) %>% 
  summarise(count = n()) %>% 
  ungroup() %>% 
  mutate(creationdatemonth = as.Date(creationdatemonth))

toptags <- dftagsmonth %>%
  count(tag) %>% 
  filter(n >= length(unique(dftagsmonth$creationdatemonth))/2) %>%
  .$tag

dftagsmonth <- dftagsmonth %>%
  filter(tag %in% toptags)

# top last tags
dftagsmonthlasttops <- dftagsmonth %>% 
  filter(creationdatemonth == max(creationdatemonth)) %>% 
  arrange(desc(count)) %>% 
  head(10) %>% 
  mutate(color = c("red", "green", "darkred", "blue", "darkgreen",
                   "yellow", ""))
  

toptop_tags <- c("ggplot2" = "red",
                 "plot" = "darkolivegreen2",
                 "data.table" = "darkred",
                 "shiny" = "blue",
                 "data.frame" = "darkolivegreen2"
                 "dplyr" = "darkblue", "rstudio" = "#71a5d1",
                 "data.table" = "darkred",
                 # base/generic R
                  "function" = "darkolivegreen2",
                 "data.frame" = "darkolivegreen2", "regex" = "darkolivegreen2",
                 "matrix" = "darkolivegreen2")

dftagsmonthnames <- dftagsmonth %>% 
  filter(creationdatemonth == max(creationdatemonth)) %>% 
  arrange(desc(count)) %>% 
  head(10) %>% 
  mutate(creationdatemonth = creationdatemonth + months(2))

ggplot() + 
  geom_smooth(aes(creationdatemonth, y = count, group =  tag),
              data = dftagsmonth %>% filter(!tag %in% names(toptop_tags)),
              size = 0.2, se = FALSE, alpha = 0.2, color = "gray") +
  geom_smooth(aes(creationdatemonth, y = count, group =  tag, color =  tag),
              data = dftagsmonth %>% filter(tag %in% names(toptop_tags)),
              size = 2, se = FALSE, alpha = 0.5) + 
  scale_color_manual(values = toptop_tags) +
  theme(legend.position = "bottom") + 
  ggtitle("")
  
  

df_qtag2 <- df_qtag %>% 
  mutate(date = as.yearqtr(creation_date)) %>% 
  group_by(date, question_tag) %>% 
  summarize(tag_date_count = n()) %>% 
  ungroup() %>% 
  arrange(date, -tag_date_count) %>% 
  group_by(date) %>% 
  mutate(rank = row_number()) %>% 
  ungroup() %>%
  filter(rank <= 12) %>% 
  filter(year(date) >= 2010) %>% 
  mutate(date = as.Date(date), rank = factor(rank, levels = 12:1))


df_qtag22 <- df_qtag2 %>%
  filter(question_tag %in% df_qtag2$question_tag) %>% 
  group_by(question_tag) %>% 
  summarise(date = max(date)) %>% 
  left_join(df_qtag2 %>% select(question_tag, date, rank)) %>% 
  mutate(date = date + months(1))
## Joining by: c("question_tag", "date")
pcks_cols <- c("ggplot2" = "red", "dplyr" = "#71a5d1",
               "shiny" = "blue", "rstudio" = "#71a5d1",
               "data.table" = "darkred")

other_pcks <- df_qtag22$question_tag[!df_qtag22$question_tag %in% names(pcks_cols)]

other_pcks_cols <- rep("gray80", length(other_pcks))
names(other_pcks_cols) <- other_pcks
cols <- c(pcks_cols, other_pcks_cols)

ggplot(df_qtag2, aes(date, y = rank, group = question_tag, color = question_tag)) + 
  geom_line(size = 2) +
  geom_point(size = 4) +
  geom_point(size = 2, color = "white") + 
  geom_text(data = df_qtag22, aes(label = question_tag), hjust = -0, size = 4) + 
  scale_color_manual(values = cols) +
  ggtitle("Top tags by quarters")

#' * http://meta.stackoverflow.com/questions/295508/download-stack-overflow-database
#' * http://stackoverflow.com/questions/21571703/format-date-as-year-quarter
#' * http://stackoverflow.com/questions/15170777/add-a-rank-column-to-a-data-frame





############################
############################
############################
############################
############################



##### Question List
question_donwload <- function(verbose = TRUE, max.pages = 9999, site = "stackoverflow"){
  
  t0 <- Sys.time()
  
  api_url <- "https://api.stackexchange.com/2.2/questions"
  key <- "ifpYG3FCatEyPyX8AqkVCA(("
  qlist <- list()
  carry_on <- TRUE
  actual_page <- 1
  
  while (carry_on) {
    data <- api_url %>%
      GET(query = list(site = site, page = actual_page, key = key,
                       sort = "creation", pagesize = 100, order = "desc")) %>% 
      content()
    
    if (verbose & actual_page %% 500 == 0)
      message("page: ",actual_page ," | quota remaining: ", data$quota_remaining)
    
    qlist[[actual_page]] <- data$items
    
    actual_page <- actual_page + 1
    
    carry_on <- data$has_more
    
    if (actual_page > max.pages)
      carry_on <- FALSE
    
  }
  
  qlist <- unlist(qlist, recursive = FALSE)
  
  t1 <- Sys.time() - t0
  message(length(qlist), " question downloaded in ",
          round(t1,2), " ", attr(t1, "units")) 
  
  qlist 
  
}
# qlist <- question_donwload()
qlist <- readRDS("qlist.Rds")

#### Questions Dataframe
# Examine a element in the list:
x <- sample(qlist, size = )[[1]]
str(x)

namestoselc <- lapply(x, class) %>%
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
