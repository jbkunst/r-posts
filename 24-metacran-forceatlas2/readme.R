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


top_n <- 300

top_pcks <- data_frame(name = c(df_dpnds$to, df_dpnds$from)) %>% count(name) %>% arrange(desc(n)) %>% head(top_n)
top_pcks_names <- top_pcks$name


edges <- df_dpnds %>% filter(from %in% top_pcks_names & to %in% top_pcks_names)
nodes <- data_frame(name = unique(c(edges$to, edges$from))) %>% 
  left_join(df_pcks, by = "name") %>% 
  left_join(top_pcks, by = "name")
  

g <- graph.data.frame(edges, directed = FALSE, vertices = nodes)

plot(g)

plot.igraph(g, layout = layout.fruchterman.reingold, vertex.size = 2, vertex.label = NA)

gpos <- 

dlay <- as_data_frame(g, what="vertices") %>% 
  cbind(layout.fruchterman.reingold(g) %>% as.data.frame() %>% setNames(c("x", "y"))) %>% 
  tbl_df()

head(dlay)

ggplot(dlay) + 
  geom_point(aes(x, y, size = log(n)), alpha = 0.3, color = "white") +
  scale_size(range = c(1, 20)) +
  ggthemes::theme_map() +
  theme(legend.position = "none",
        plot.background = element_rect(fill = "black", colour = "black"),
        panel.border = element_blank())


