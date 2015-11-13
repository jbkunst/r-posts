#' ---
#' title: "What we ask in Stackoverflow"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: false
#'    keep_md: yes
#' categories: R
#' layout: post
#' featured_image: https://www.sac.edu/StudentServices/InternationalStudents/Calendar%20of%20Events/questions-and-answers.jpg
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())
library("dplyr")
library("ggplot2")
library("showtext")
library("printr")

knitr::opts_chunk$set(warning = FALSE, cache = FALSE, fig.showtext = TRUE, dev = "CairoPNG", fig.width = 8)

# font.add.google("Lato", "myfont")
# showtext.auto()

theme_set(theme_minimal(base_size = 13, base_family = "myfont") +
            theme(legend.position = "none",
                  text = element_text(colour = "#616161")))

#### Post ####
#' Have you
#' 
#'> When you're down and troubled <br/>
#'> And you need a **coding** hand <br/>
#'> And nothing, nothing is going right <br/>
#'> Open a **browser** and **type** of this <br/>
#'> And the first match will be there <br/>
#'> To brighten up even your darkest night.
#'
#' 1. [The Data](#the-data)
#' 1. [Top Tags by Year](#top-tags-by-year)
#' 1. [The Topics this Year](#the-topics-this-year)
#' 1. [Bonus](#bonus)
#' 

#####' ### The Data ####
#'
#' If you want the SO data you can found at least 2 options:
#' 
#' 1. The StackEchange Data explorer. [link](https://data.stackexchange.com/stackoverflow/query/new)
#' 2. Stack Exchange Data Dump. (link)(https://archive.org/download/stackexchange).
#' 
#' The first case you can make any query but you are limited you obtain only 50,000 rows via csv file.
#' The second option you can download all the dump :) but it comes in xml format (:S?!). So I decided use the 
#' second source and write a [script](https://github.com/jbkunst/r-posts/blob/master/025-stackoverflow/xml-to-sqlite.R) 
#' to parse the 27GB xml file to extrack only the questions and load the data into a sqlite data base.
db <- src_sqlite("~/so-db.sqlite")

dfqst <- tbl(db, "questions")
nrow(dfqst) %>% prettyNum(big.mark = ",")
head(dfqst)

dftags <- tbl(db, "questions_tags")
nrow(dftags) %>% prettyNum(big.mark = ",")
head(dftags)

#####' ### Top Tags by Year ####
#' Well, it's almost end of year and we can talk about summaries about what happened this year. 
#' So, let's look about the changes in the top tags at stackoverflow
#' 
#' We need count grouping by *creationyear* and *tag*, then use *row_number* function to make the rank by
#' year and filter by the first 30 places.
dfqst <- dfqst %>% mutate(creationyear = substr(creationdate, 0, 5))

dftags2 <- left_join(dftags, dfqst %>% select(id, creationyear), by = "id")

dftags3 <- dftags2 %>% 
  group_by(creationyear, tag) %>% 
  summarize(count = n()) %>% 
  arrange(creationyear, -count) %>% 
  collect()

#' In the previous code we need to collect becuase we can't use *row_number* via *tbl* source
#' (or at least I don't know how to do it yet).
tops <- 30

dftags4 <- dftags3 %>% 
  group_by(creationyear) %>% 
  mutate(rank = row_number()) %>% 
  ungroup() %>%
  filter(rank <= tops) %>% 
  mutate(rank = factor(rank, levels = rev(seq(tops))),
         creationyear = as.numeric(creationyear))

#' Lets took the first 5 places this year. Nothing new.
dftags4 %>% filter(creationyear == 2015) %>% head(5)

#' The next data frames is to get the name at the start and end of the lines for our first plot.
dftags5 <- dftags4 %>% 
  filter(creationyear == max(creationyear)) %>% 
  mutate(creationyear = as.numeric(creationyear) + 0.25)

dftags6 <- dftags4 %>% 
  filter(creationyear == min(creationyear)) %>% 
  mutate(creationyear = as.numeric(creationyear) - 0.25)

#' Now, let's do a simply regresion model model *rank ~ year* to know if a tag's rank go 
#' up or down across the years. Maybe this is a very simply and non correct approach but it's good to explore
#' the trends. Let's consider the top *tags* in this year with at least 3 appearances:
tags_tags <- dftags4 %>%
  count(tag) %>%
  filter(n > 3) %>% # have at least 3 appearances
  filter(tag %in% dftags5$tag) %>% # top tags in 2015
  .$tag

dflms <- dftags4 %>% 
  filter(tag %in% tags_tags) %>% 
  group_by(tag) %>% 
  do(model = lm(as.numeric(rank) ~ creationyear, data = .)) %>% 
  mutate(slope = coefficients(model)[2]) %>% 
  arrange(slope) %>% 
  select(-model) %>% 
  mutate(trend = cut(slope, breaks = c(-Inf, -1, 1, Inf), labels = c("-", "=", "+")),
         slope = round(slope, 2)) %>% 
  arrange(desc(slope))

dflms %>% filter(trend != "=")

#' Mmm! What we see? *asp.net* is goind down and *arrays* is going up Now let's 
#' get some color for remark the most interesting results.
colors <- c("asp.net" = "#6a40fd", "r" = "#198ce7", "css" = "#563d7c", "javascript" = "#f1e05a",
            "json" = "#f1e05a", "android" = "#b07219", "arrays" = "#e44b23", "xml" = "green")

othertags <- dftags4 %>% distinct(tag) %>% filter(!tag %in% names(colors)) %>% .$tag

colors <- c(colors, setNames(rep("gray", length(othertags)), othertags))

#' Now the fun part! I call this  **The subway-style-rank-year-tag plot: the past and the future**.
#+ fig.height = 7, fig.width = 10
ggplot(dftags4, aes(creationyear, y = rank, group = tag, color = tag)) + 
  geom_line(size = 1.7, alpha = 0.25) +
  geom_line(size = 2.5, data = dftags4 %>% filter(tag %in% names(colors)[colors != "gray"])) +
  geom_point(size = 4, alpha = 0.25) +
  geom_point(size = 4, data = dftags4 %>% filter(tag %in% names(colors)[colors != "gray"])) +
  geom_point(size = 1.75, color = "white") +
  geom_text(data = dftags5, aes(label = tag), hjust = -0, size = 4.5) + 
  geom_text(data = dftags6, aes(label = tag), hjust = 1, size = 4.5) + 
  scale_color_manual(values = colors) +
  ggtitle("The subway-style-rank-year-tag plot:\nPast and the Future") +
  xlab("Top Tags by Year in Stackoverflow") +
  scale_x_continuous(breaks = seq(min(dftags4$creationyear) - 2,
                                 max(dftags4$creationyear) + 2),
                     limits = c(min(dftags4$creationyear) - 1.0,
                                max(dftags4$creationyear) + 0.5))

#' First of all: *javascript* is the top tag nowadays nothing new yet so let's focus in the changes of places: 
#' We can see the web/mobile technologies like android, json are now  more "popular" this days, same as 
#' css, html, nodejs, swift, ios, objective-c, etc. By other hand the *xml* and *asp.net* and friends 
#' (*.net*, *visual-studio*) tags aren't popular this year comparing with the previous years, but hey! Obviously 
#' a top 30 tag in SO means popular yet! but we need to remark these tags are becoming less popular every year.
#' 
#' Other important fact to mention is the increased popularity of the *r* tag (yay!).
#' 
#' And finally is interesting see how xml is going down and json s going up. It seems xml is being replaced
#' by json format gradually.
#' 
#+ echo=FALSE
rm(dflms, dftags3, dftags4, dftags5, dftags6, tags_tags, colors, othertags, tops)

#####' ### The Topics this Year ####
#' 
#' We know, for example, some question are tag by *database*, other are tagged with *sql* or *server* 
#' and maybe this questions belong to a family or group of questions. So let's find the 
#' topics/cluster/families/communities in all these questions.
#' 
#' The firs approach we'll test it be use [*resolution*](https://github.com/analyxcompany/resolution) package
#' to find communities in a network.
#' 
library("igraph")
library("ForceAtlas2")

dftagpair <- dftags2 %>%
  filter(creationyear == "2015") %>%
  select(id, tag) %>% 
  left_join(. %>% select(tag2 = tag, id), by = "id") %>% 
  filter(tag < tag2) %>% 
  count(tag, tag2) %>% 
  ungroup() %>% 
  arrange(desc(n))

# dftag2015 <- collect(dftag2015)
# dftagpair <- collect(dftagpair)
# save(dftag2015, dftagpair, file = "nets_df.RData")
# load("nets_df.RData")

quantile(dftagpair$n, seq(.9999, 1, length.out = 10))

q <- quantile(dftag2$n, .99)

dftag3 <- dftag2 %>% 
  filter(n >= q) %>% 
  rename(weight = n)

g <- graph.data.frame(dftag3, directed = FALSE)

plot(g)

fc <- cluster_fast_greedy(g)

members <- membership(fc)
dfmembers <- data_frame(member = names(members), cluster = members)

dfmembers %>% count(cluster) %>% arrange(desc(n))


dfmembers %>% filter(cluster == 3) %>% View()

dfmembers %>% filter(cluster == (dfmembers %>% filter(member == "ggplot2") %>% .$cluster)) %>% View()


dfmembers %>% filter(member == "r")



#####' ### Bonus ####
#' Some questions I readed for write this post
#' * [Transposing a dataframe maintaining the first column as heading](http://stackoverflow.com/questions/7970179/transposing-a-dataframe-maintaining-the-first-column-as-heading).
#' 
#' 
