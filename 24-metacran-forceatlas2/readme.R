rm(list = ls())
library("httr")
library("plyr")
library("dplyr")
library("igraph")
library("ForceAtlas2") # devtools::install_github("analyxcompany/ForceAtlas2")
library("ggplot2")

lst_pcks <- "http://crandb.r-pkg.org/-/latest" %>% 
  GET() %>% 
  content()

df_pcks <- ldply(lst_pcks, function(x){
  x2 <- x[names(x) %in% c("Package", "Version", "Author", "URL", "Repository",
                          "crandb_file_date", "License", "Description", "Title")]
  dplyr::as_data_frame(x2)
})

df_pcks <- tbl_df(df_pcks) %>%
  select(-.id) %>%
  rename(name = Package) %>% 
  setNames(tolower(names(.)))

df_dpnds <- ldply(lst_pcks, function(x){
  depends <- names(x$Depends)
  if (!is.null(depends) & length(depends) > 0) data_frame(from = x$Package, to = depends)  
})

df_dpnds <- tbl_df(df_dpnds) %>% 
  select(from, to) %>% 
  filter(to != "R")


top_n <- 200

top_pcks <- data_frame(name = c(df_dpnds$to, df_dpnds$from)) %>% count(name) %>% arrange(desc(n)) %>% head(top_n)
top_pcks_names <- top_pcks$name


edges <- df_dpnds %>% filter(from %in% top_pcks_names & to %in% top_pcks_names)
nodes <- data_frame(name = unique(c(edges$to, edges$from))) %>% 
  left_join(df_pcks) %>% 
  left_join(top_pcks)
  

g <- graph.data.frame(edges, directed=FALSE, vertices = nodes)

plot(g)


t <- Sys.time()
layout <- layout.forceatlas2(g, iterations = 10000, plotstep = 100)
t - Sys.time()


layout <- layout %>%
  left_join(df_dpnds %>%  count(name = to)) %>%
  mutate(alpha = n/max(n))


df_dpnds_g

p <- ggplot(layout) +
  geom_point(aes(V1, V2, size = log(n), alpha = sqrt(alpha))) +
  # geom_text(aes(V1, V2, label = name, size = log(n), alpha = sqrt(alpha)), data = layout %>% filter(n>100)) +
  scale_size(range = c(1, 20)) 

p + ggthemes::theme_map() + theme(legend.position = "none",  panel.border = element_blank())


