library("dplyr")
library("visNetwork")

url <- "http://visjs.org/examples/network/datasources/WorldCup2014.js"
ct <- V8::new_context()
ct$source(url)

nodes2 <- tbl_df(ct$get("nodes")) %>% head(Inf)
edges2 <- tbl_df(ct$get("edges")) %>% filter(from %in% nodes2$id, to %in% nodes2$id)

visNetwork(nodes2, edges2, width = 1000, height = 1000) %>%
  visPhysics(solver="barnesHut",
             barnesHut=list(gravitationalConstant= -80000, springConstant= 0.001,
                            springLength= 200), stabilization= FALSE ) %>%
  visInteraction(tooltipDelay= 200, hideEdgesOnDrag= TRUE) %>%
  visEdges(width = 0.15, color = list(inherit = 'from'), smooth = list(type = 'continuous'))
