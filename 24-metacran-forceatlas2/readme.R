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


args_slc <- c("Package", "Version", "Author", "URL", "Repository",
              "crandb_file_date", "License", "Description", "Title")
args_lst <- c("Depends", "releases", "Suggests", "Imports", "LinkingTo", "Enhances")

df_pcks <- ldply(lst_pcks, function(x){
  # x <- sample(lst_pcks, size = 1)[[1]]
  # x <- lst_pcks[["bigmemory"]]
  # message(x$Package)
  # x2 <- x[!names(x) %in% args_lst]
  x2 <- x[names(x) %in% args_slc]
  dplyr::as_data_frame(x2)
})

df_pcks <- tbl_df(df_pcks) %>% select(-.id) %>% rename(name = Package)
names(df_pcks) <- tolower(names(df_pcks))
names(df_pcks)

df_dpnds <- ldply(lst_pcks, function(x){
  # x <- sample(lst_pcks, size = 1)[[1]]
  # x <- lst_pcks[["bigmemory"]]
  # message(x$Package)
  depends <- names(x$Depends)
  if (!is.null(depends) & length(depends) > 0) {
    data_frame(from = x$Package, to = depends)  
  }
})

df_dpnds <- tbl_df(df_dpnds) %>% 
  select(from, to) %>% 
  filter(to != "R")

df_dpnds %>% count(from, to) %>% arrange(desc(n))
df_pcks %>% count(tolower(name)) %>% arrange(desc(n))



top_n <- 500
top_pcks <- df_dpnds %>% 
  count(to) %>% 
  arrange(desc(n)) %>% 
  head(top_n) %>% 
  .$to

df_pcks_g <- df_pcks %>% filter(name %in% top_pcks) %>% mutate(id = seq(nrow(.)))
df_dpnds_g <- df_dpnds %>% filter(from %in% top_pcks, to %in% top_pcks)


t <- Sys.time()
layout <- layout.forceatlas2(df_dpnds_g, iterations = 10000)
t - Sys.time()

layout <- layout %>%
  left_join(df_dpnds %>%  count(name = to)) %>%
  mutate(alpha = n/max(n))

p <- ggplot(layout) +
  geom_point(aes(V1, V2, size = log(n), alpha = sqrt(alpha))) +
  geom_text(aes(V1, V2, label = name, size = log(n), alpha = sqrt(alpha))) +
  scale_size(range = c(1, 20)) 

p + ggthemes::theme_map() + theme(legend.position = "none",  panel.border = element_blank())

# g <- graph.data.frame(df_pcks_g, directed = TRUE)
# plot(g)
# 
# edges <- plyr::laply(c(1,2,3), function(x){
#   # x <- 2
#   f <- df_dpnds_g[2,1]
#   t <- df_dpnds_g[2,2]
#   
#   f %in% top_pcks
#   t %in% top_pcks
#   df_pcks_g %>% filter(name == f)
#   df_dpnds_g %>% filter(from == f)
#   df_dpnds_g %>% filter(to == t)
#   
#   
#   which(df_pcks_g$name ==  as.vector(t()))
#   which(df_pcks_g$name ==  as.vector(t(df_dpnds_g[2,2])))
# })
# 
# 
# g <- graph.data.frame(layout, directed=FALSE)
# 
# g <- set.vertex.attribute(g, colnames(Hex.ed)[i], value=Hex.ed[,i])
# 
# g <- make_ring(10) %>%
#   set_vertex_attr("label", value = LETTERS[1:10])
# g
# g <- make_ring(10) %>%
#   set_edge_attr("label", value = LETTERS[1:10])
# g
# 
# plot(g)
# 
# add_edges()
# 
# 
# g <- make_empty_graph(n = 5) %>%
#   add_edges(c(1,2, 2,3, 3,4, 4,5)) %>%
#   set_edge_attr("color", value = "red") %>%
#   add_edges(c(5,1), color = "green")
# E(g)[[]]
# plot(g)

