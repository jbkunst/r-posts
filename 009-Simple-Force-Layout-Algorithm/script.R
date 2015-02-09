rm(list=ls())
library("network")
library("mvtnorm")
library("ggplot2")
library("plyr")
library("dplyr")
library("reshape2")

net <- matrix(c(0,1,1,0,0,0,0,
                1,0,1,0,0,0,0,
                1,1,0,1,0,0,0,
                0,0,1,0,1,0,0,
                0,0,0,1,0,1,1,
                0,0,0,0,1,0,1,
                0,0,0,0,1,1,0),
              byrow = TRUE, nrow = 7)

net <- as.matrix.network(network(net), matrix.type="edgelist")

attr(net, "positions") <- rmvnorm(n = attr(net, "n"), sigma = diag(c(1, 1)))
attr(net, "edges") <- net[,]



net.plot <- function(net){
  
  dpos <- attr(net, "positions") %>%
    as.data.frame %>%
    mutate(names = attr(net, "vnames"))
  dedges <- attr(net, "edges") %>% as.data.frame
  dedges <- dedges %>%
    cbind( dpos[dedges$V1,] %>% setNames(c("xs", "ys"))) %>%
    cbind( dpos[dedges$V2,] %>% setNames(c("xe", "ye")))
  
  p <- ggplot() +
    geom_point(data=dpos, aes(V1, V2), size = 10, alpha = 0.3, color="darkblue") + 
    geom_segment(data=dedges, aes(x=xs, y=ys, xend=xe, yend=ye), alpha = 0.1, size = 2, color = "darkred") +
    geom_text(data=dpos, aes(V1, V2, label=names)) 
  p
}

net.update_positions <- function(net){
  
  dpos_actual <- attr(net, "positions") %>% as.data.frame
  dedges <- attr(net, "edges") %>% as.data.frame
  nodes <- attr(net, "vnames")

  # repulsive
  drep <- ldply(nodes, function(node){ # node <- 2 #sample(nodes, size = 1)
    
    node_x <- dpos_actual[node, "V1"]
    node_y <- dpos_actual[node, "V2"]
    
    dpos_actual[-node,] %>%
      mutate(V1 = node_x - V1,
             V2 = node_y - V2,
             r2 = V1^2+V2^2,
             V1 = V1/r2,
             V2 = V2/r2) %>%
      select(V1, V2) %>%
      colSums %>%
      setNames(c("dx", "dy"))
  })
  
  # attractive
  datt <- ldply(nodes, function(node){ # node <- 2 #sample(nodes, size = 1)
    
    relations_edges <- dedges %>%
      filter(V1 == node | V2 == node) %>%
      melt(id.vars = NULL) %>%
      .$value %>%
      unique %>%
      setdiff(node)
    
    node_x <- dpos_actual[node, "V1"]
    node_y <- dpos_actual[node, "V2"]
    
    dpos_actual[relations_edges,] %>%
      mutate(V1 = node_x - V1,
             V2 = node_y - V2,
             r2 = V1^2+V2^2,
             V1 = V1/r2,
             V2 = V2/r2) %>%
      select(V1, V2) %>%
      colSums %>%
      setNames(c("dx", "dy"))
  })
  
  dpos_updated <- dpos_actual + drep + datt
  attr(net, "positions") <- dpos_updated %>% as.matrix
    
  net
}



net.plot(net)
net <- net.update_positions(net)



