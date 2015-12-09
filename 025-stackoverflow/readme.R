#' ---
#' title: "What we question at Stackoverflow"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    theme: journal
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

knitr::opts_chunk$set(error = TRUE, warning = FALSE, cache = FALSE, fig.showtext = TRUE,
                      dev = "CairoPNG", fig.width = 8)

# font.add.google("Lato", "myfont")
# showtext.auto()

theme_set(theme_minimal(base_size = 13, base_family = "myfont") +
            theme(legend.position = "none",
                  text = element_text(colour = "#616161")))

#### Post ####
#' How many times you have an error in your code, query, etc and you don't have the solution? How many
#' time in these cases you open your *favorite browser* and search in your *favorite search engine* and type
#' (I mean copy/paste) that error and you click in the first result you get and then you don't feel alone
#' in this planet: "other person had the same problem/question/error as you", and finally, a little bit down you
#' see the most voted answer and YES it was a so simple mistake/fix. Well, this happens to me several times a week.
#'
#' Stackoverflow is the biggest site of Q&A that means have a lot of data and fortunately we can get it.
#'
#' *Original* thoughts come to my mind and it come in verse form (not in a haiku way):
#'
#'> When you're down and troubled <br/>
#'> And you need a **coding** hand <br/>
#'> And nothing, nothing is going right <br/>
#'> Open a **browser** and **type** about this <br/>
#'> And the first match will be there <br/>
#'> To brighten up even your darkest night.
#'
#' Well, now to code.
#'
#' 1. [The Data](#the-data)
#' 1. [Top Tags by Year](#top-tags-by-year)
#' 1. [The Topics this Year](#the-topics-this-year)
#' 1. [Bonus](#bonus)
#'

####' ### The Data ####
#'
#' If you want the SO data you can found at least 2 options:
#'
#' 1. [The StackEchange Data explorer](https://data.stackexchange.com/stackoverflow/query/new).
#' 2. [Stack Exchange Data Dump](https://archive.org/download/stackexchange).
#'
#' The first case you can make any query but you are limited you obtain only 50,000 rows via csv file.
#' The second option you can download all the dump :) but it comes in xml format (:S?!). So I decided use the
#' second source and write a [script](https://github.com/jbkunst/r-posts/blob/master/025-stackoverflow/xml-to-sqlite.R)
#' to parse the 27GB xml file to extract only the questions and load the data into a sqlite data base.
#+ eval=FALSE
# db <- src_sqlite("~/so-db.sqlite")

dfqst <- tbl(db, "questions")

dftags <- tbl(db, "questions_tags")

####' ### Top Tags by Year ####
#' Well, it's almost end of year and we can talk about summaries about what happened this year.
#' So, let's look about the changes in the top tags at stackoverflow.
#' We need count grouping by *creationyear* and *tag*, then use *row_number* function to make 
#' the rank by year and filter by the first 30 places.
#+ eval=FALSE
dfqst <- dfqst %>% mutate(creationyear = substr(creationdate, 0, 5))

dftags2 <- left_join(dftags, dfqst %>% select(id, creationyear), by = "id")
nrow(dftags2)

dftags3 <- dftags2 %>%
  group_by(creationyear, tag) %>%
  summarize(count = n()) %>%
  arrange(creationyear, -count) %>%
  collect()

#' In the previous code we need to collect becuase we can't use *row_number* via *tbl* source
#' (or at least I don't know how to do it yet).
#+ eval=FALSE
tops <- 30

dftags4 <- dftags3 %>%
  group_by(creationyear) %>%
  mutate(rank = row_number()) %>%
  ungroup() %>%
  filter(rank <= tops) %>%
  mutate(rank = factor(rank, levels = rev(seq(tops))),
         creationyear = as.numeric(creationyear))

#+ echo=FALSE
# checkpoint
# save(dftags4, file = "top_tags_by_year.RData")
load(file = "top_tags_by_year.RData")

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
  filter(n >= 3) %>% # have at least 3 appearances
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

#' Yay! it's not coincidence (may be yes because I choose tag with 3 or more appearances): R have a
#' a big increase in the las 3 years, The reason can be probably the datascience boom and how the data
#' have become somethig more important in technologies. Today everything is being measured. Other reason
#' is because R it's awesome. 
#' 
#' I'm not sure why the *arrays* have a similiar trend. This tag is a generic one because all programing
#' lenguages  arrays. My first guess is this a *web*'s colaterlal effect. In javascript
#' you need to know how handle data (usually the response to an ajax request is a json object which is
#' parsed into dict, arrays and/or list) to make you web interactive.
#'  
#' What else we see? *asp.net* same as *xml* and *sql-serve* are going down. Now let's put some 
#' color to emphasize the most interesting results.
colors <- c("asp.net" = "#6a40fd", "r" = "#198ce7", "css" = "#563d7c", "javascript" = "#f1e05a",
            "json" = "#f1e05a", "android" = "#b07219", "arrays" = "#e44b23", "xml" = "green")

othertags <- dftags4 %>% distinct(tag) %>% filter(!tag %in% names(colors)) %>% .$tag

colors <- c(colors, setNames(rep("gray", length(othertags)), othertags))

#' Now the fun part! I call this  **The subway-style-rank-year-tag plot: the past and the future**.
#+ fig.height = 7, fig.width = 10
p <- ggplot(mapping = aes(creationyear, y = rank, group = tag, color = tag)) +
  geom_line(size = 1.7, alpha = 0.25, data = dftags4) +
  geom_line(size = 2.5, data = dftags4 %>% filter(tag %in% names(colors)[colors != "gray"])) +
  geom_point(size = 4, alpha = 0.25, data = dftags4) +
  geom_point(size = 4, data = dftags4 %>% filter(tag %in% names(colors)[colors != "gray"])) +
  geom_point(size = 1.75, color = "white", data = dftags4) +
  geom_text(data = dftags5, aes(label = tag), hjust = -0, size = 4.5) +
  geom_text(data = dftags6, aes(label = tag), hjust = 1, size = 4.5) +
  scale_color_manual(values = colors) +
  ggtitle("The subway-style-rank-year-tag plot:\nPast and the Future") +
  xlab("Top Tags by Year in Stackoverflow") +
  scale_x_continuous(breaks = seq(min(dftags4$creationyear) - 2,
                                 max(dftags4$creationyear) + 2),
                     limits = c(min(dftags4$creationyear) - 1.0,
                                max(dftags4$creationyear) + 0.5))
p

#' First of all: *javascript*, the language of the web, is the top tag nowadays. This is nothing new yet
#' so let's focus in the changes of places. We can see the web/mobile technologies like android, json are now
#' more "popular" these days, same as css, html, nodejs, swift, ios, objective-c, etc. By other hand
#' the *xml* and *asp.net* (and its friends like *.net*, *visual-studio*) tags aren't popular this year comparing
#' with the previous years, but hey! obviously a top 30 tag in SO means popular yet!
#' In the same context is interesting see is how *xml* is 
#' going down and *json* s going up. It seems xml is being replaced by json format gradually. The same 
#' effect could be in *.net* with the rest of the webframeworks like ror, django, php frameworks. 
#'

####' ### The Topics this Year ####
#'
#' We know, for example, some question are tagged by *database*, other are tagged with *sql* or *mysql*
#' and maybe this questions belong to a family or group of questions. So let's find the
#' topics/cluster/families/communities in all 2015 questions.
#'
#' The approach we'll test is inspired by [Tagoverflow](http://stared.github.io/tagoverflow/) a nice app by
#' [Piotr Migdal](http://migdal.wikidot.com/) and [Marta Czarnocka-Cieciura](http://martaczc.deviantart.com/). To
#' find the communiest we use/test the [resolution package](github.com/analyxcompany/resoution) from the 
#' [analyxcompany](github.com/analyxcompany) team which is a R implementation of [Laplacian Dynamics and 
#' Multiscale Modular Structure in Networks](http://arxiv.org/pdf/0812.1770.pdf).
#'
#' *Let the extraction/transformation data/game begin!*:
#'
suppressPackageStartupMessages(library("igraph"))
library("resolution")
library("networkD3")

#+ eval=FALSE
dftags20150 <- dftags2 %>%
  filter(creationyear == "2015") %>%
  select(id, tag)

dfedge <- dftags20150 %>%
  left_join(dftags20150 %>% select(tag2 = tag, id), by = "id") %>%
  filter(tag < tag2) %>%
  count(tag, tag2) %>%
  ungroup() %>%
  arrange(desc(n)) %>%
  collect()

dfvert <- dftags20150 %>%
  group_by(tag) %>%
  summarise(n = n()) %>%
  ungroup() %>%
  arrange(desc(n)) %>%
  collect()

#+ echo=FALSE
# # a checkpoint!
# save(dfedge, dfvert, file = "nets_df.RData")
# rm(list=ls());
load("nets_df.RData")
#+ echo=TRUE

first_n <- 100

#' To reduce the calculation times and to talk generally we will use the fisrt `r first_n` top tags.
#' Then made a igraph element via the edges (tag-tag count) to use the cluster_resolution
#' algorithm to find groups. Sounds relative easy.

nodes <- dfvert %>%
  head(first_n) %>%
  mutate(id = seq(nrow(.))) %>%
  rename(label = tag) %>%
  select(id, label, n)

head(nodes)

edges <- dfedge %>%
  filter(tag %in% nodes$label, tag2 %in% nodes$label) %>%
  rename(from = tag, to = tag2)

head(edges)

#' So, now create the igraph object and get the cluster via this method:
g <- graph.data.frame(edges %>% rename(weight = n), directed = FALSE)
pr <- page.rank(g)$vector
c <- cluster_resolution(g, directed = FALSE)
V(g)$comm <- membership(c)



#' Add data to the nodes:
nodes <- nodes %>%
  left_join(data_frame(label = names(membership(c)),
                       cluster = as.character(membership(c))),
            by = "label")

#' Let's view some tags and size of each cluster. 
clusters <- nodes %>% 
  group_by(cluster) %>% 
  do({data_frame(top_tags = paste(head(.$label), collapse = ", "))}) %>%
  ungroup() %>% 
  left_join(nodes %>% 
              group_by(cluster) %>% 
              arrange(desc(n)) %>% 
              summarise(n_tags = n(), n_qst = sum(n)) %>%
              ungroup(),
            by = "cluster") %>% 
  arrange(desc(n_qst))

clusters

#' Mmm! The results from the algorithm make sense (at least for me). Let's enumerate/name them:
#' 
#' - The big *just-frontend* group leading by the top one javascript: jquery, html, css.
#' - The *java-and-android*.
#' - The *general-programming-rocks* :D cluster.
#' - The mmm... *prograWINg*. I sometimes use windows, about 95% of the time. 
#' - The *php-biased-backend* cluster.
#' - The *Imobile* programming group.
#' - Jst the *ror* cluster.
#' - Mmm I don't know how name this cluster: *nodo-monge*.
#' - And the *I-know-code-...-in-excel*.
#' 
#' Now let's name the cluster, plot them and check if it helps to
#' get an idea how the top tags in SO are related to each other.
#' 
clusters <- clusters %>% 
  mutate(cluster_name = c("frontend", "java-and-android", "general-programming-rocks",
                          "prograWINg", "php-biased-backedn", "Imobile", "ror",
                          "nodo-monge", "I-know-code-...-in-excel"),
         cluster_name = factor(cluster_name, levels = rev(cluster_name)))

ggplot(clusters) +
  geom_bar(aes(cluster_name, n_qst),
           stat = "identity", width = 0.5, fill = "#198ce7") +
  scale_y_continuous("Questions", labels = scales::comma) + 
  xlab(NULL) +
  coord_flip() +
  ggtitle("Distrution of Question in the top 100 tag clusters")

nodes <- nodes %>% 
  mutate(nn2 = round(30*n ^ 2/max(n ^ 2)) + 1) %>% 
  left_join(clusters %>% select(cluster, cluster_name),
            by = "cluster") %>% 
  mutate(cluster_order = seq(nrow(.)))

edges <- edges %>% 
  left_join(nodes %>% select(from = label, id), by = "from") %>% 
  rename(source = id) %>%
  left_join(nodes %>% select(to = label, id), by = "to") %>% 
  rename(target = id) %>% 
  mutate(ne2 = round(30*n ^ 3/max(n ^ 3)) + 1,
         source = source - 1,
         target = target - 1) %>% 
  arrange(desc(n)) %>% 
  head(nrow(nodes)*1.5) # this is to reduce the edges to plot

colorrange <- viridisLite::viridis(nrow(clusters)) %>% 
  stringr::str_sub(1, 7) %>% 
  paste0("'", ., "'", collapse = ", ") %>% 
  paste0("[", ., "]")

colordomain <- clusters$cluster_name %>% 
  paste0("'", ., "'", collapse = ", ") %>% 
  paste0("[", ., "]")

color_scale <- "d3.scale.ordinal().domain(%s).range(%s)" %>% 
  sprintf(colordomain, colorrange)

#' <link href='https://fonts.googleapis.com/css?family=Lato' rel='stylesheet' type='text/css'>
forceNetwork(Links = edges, Nodes = nodes,
             Source = "source", Target = "target",
             NodeID = "label", Group = "cluster_name",
             Value = "ne2", linkWidth = JS("function(d) { return Math.sqrt(d.value);}"),
             Nodesize = "nn2", radiusCalculation = JS("Math.sqrt(d.nodesize)+6"),
             colourScale = color_scale,
             opacity = 1, linkColour = "#BBB", legend = TRUE, 
             linkDistance = 50, charge = -100, bounded = TRUE,
             fontFamily = "Lato")

#'
#' ![ihniwid](http://i.kinja-img.com/gawker-media/image/upload/japbcvpavbzau9dbuaxf.jpg)
#'
#' Now let's try the adjacency matrix way.
#'
library("ggplot2")

nodes

edges


node_list <- get.data.frame(g, what = "vertices") %>% 
  tbl_df()

# Determine a community for each edge. If two nodes belong to the
# same community, label the edge with that community. If not,
# the edge community value is 'NA'
edge_list <- get.data.frame(g, what = "edges") %>%
  tbl_df() %>% 
  inner_join(node_list %>% select(name, comm), by = c("from" = "name")) %>%
  inner_join(node_list %>% select(name, comm), by = c("to" = "name")) %>%
  mutate(group = ifelse(comm.x == comm.y, comm.x, NA) %>% factor())

# Create a character vector containing every node name
all_nodes <- sort(node_list$name)

name_order <- (node_list %>% arrange(comm))$name

# Adjust the 'to' and 'from' factor levels so they are equal
# to this complete list of node names
# Reorder edge_list "from" and "to" factor levels based on
# this new name_order
plot_data <- edge_list %>%
  rbind(edge_list %>% rename(from = to, to = from)) %>% 
  mutate(to = factor(to, levels = rev(name_order)),
         from = factor(from, levels = name_order))

#+ fig.height = 9, fig.width = 9
p2 <- ggplot(plot_data, aes(x = from, y = to, fill = group, alpha = log(weight))) +
  geom_tile() +
  scale_x_discrete(drop = FALSE) +
  scale_y_discrete(drop = FALSE) +
  coord_equal() + 
  theme_bw() +
  theme(axis.text.x = element_text(angle = 270, hjust = 0),
        legend.position = "none") 
p2


p2 + 
  geom_hline(yintercept = length(name_order) - which(name_order=="r") + 1,
             size = 2, alpha = 0.4) +
  geom_vline(xintercept = which(name_order=="r") - 1,
             size = 2, alpha = 0.4) 
  

####' ### Bonus ####
#' Some questions I readed for write this post:
#'
#' * [Transposing a dataframe maintaining the first column as heading](http://stackoverflow.com/questions/7970179/transposing-a-dataframe-maintaining-the-first-column-as-heading).
#' * [Split a vector into chunks in R](http://stackoverflow.com/questions/3318333/split-a-vector-into-chunks-in-r)
#' * [What are the differences between community detection algorithms in igraph?](http://stackoverflow.com/questions/9471906/what-are-the-differences-between-community-detection-algorithms-in-igraph)
#' * [Capitalize the first letter of both words in a two word string](http://stackoverflow.com/questions/6364783/capitalize-the-first-letter-of-both-words-in-a-two-word-string)
#' * [R: simple multiplication causes integer overflow](http://stackoverflow.com/questions/17650803/r-simple-multiplication-causes-integer-overflow).
#'

####' ### References ####
#'
#' * [Finding communities in networks with R and igraph](http://www.sixhat.net/finding-communities-in-networks-with-r-and-igraph.html)
#' * [Adjacency matrix plots with R and ggplot2](http://matthewlincoln.net/2014/12/20/adjacency-matrix-plots-with-r-and-ggplot2.html)
