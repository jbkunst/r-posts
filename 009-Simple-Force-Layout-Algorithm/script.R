rm(list=ls())
library("network")
library("mvtnorm")
library("ggplot2")
library("plyr")
library("dplyr")
library("reshape2")
library("grid")
# 
# net <- matrix(c(0,1,1,0,0,0,0,
#                 1,0,1,0,0,0,0,
#                 1,1,0,1,0,0,0,
#                 0,0,1,0,1,0,0,
#                 0,0,0,1,0,1,1,
#                 0,0,0,0,1,0,1,
#                 0,0,0,0,1,1,0),
#               byrow = TRUE, nrow = 7)

net <- matrix(c(0,1,1,0,
                1,0,1,0,
                1,1,0,1,
                0,0,1,0),
              byrow = TRUE, nrow = 4)

K <- C <- 1

net <- as.matrix.network(network(net), matrix.type="edgelist")

net.fix <- function(net){
  attr(net, "positions") <- rmvnorm(n = attr(net, "n"), sigma = diag(c(1, 1)))
  attr(net, "edges") <- net[,] %>%
    as.data.frame %>%
    mutate(V1n = ifelse(V1<=V2, V1, V2),
           V2n = ifelse(V1<=V2, V2, V1)) %>%
    select(V1=V1n, V2=V2n) %>%
    distinct %>%
    as.matrix
  net
}

net <- net.fix(net)

net.calculate.repulsive <- function(net){
  
  dpositions <- attr(net, "positions") %>% as.data.frame
  dedges <- attr(net, "edges") %>% as.data.frame   
  nodes <- attr(net, "vnames")
  
  drep <- ldply(nodes, function(node){ # node <- 2 #sample(nodes, size = 1)
    
    node_x <- dpositions[node, "V1"]
    node_y <- dpositions[node, "V2"]
    
    dpositions[-node,] %>%
      mutate(node_origin = node,
             node_x = node_x,
             node_y = node_y,
             node_force = setdiff(nodes, node),
             dist = (V1 - node_x)^2 + (V2 - node_y)^2,
             dist = sqrt(dist),
             ex = (V1 - node_x)/dist,
             ey = (V2 - node_y )/dist,
             fx = -C*K^2*ex/dist,
             fy = -C*K^2*ey/dist)
  })
  
  drep
}

net.calculate.attractive <- function(net){
  
  dpositions <- attr(net, "positions") %>% as.data.frame
  dedges <- attr(net, "edges") %>% as.data.frame   
  nodes <- attr(net, "vnames")
  
  # attractive
  datt <- ldply(nodes, function(node){ # node <- 3 #sample(nodes, size = 1)
    
    relations_edges <- dedges %>%
      filter(V1 == node | V2 == node) %>%
      melt(id.vars = NULL) %>%
      .$value %>%
      unique %>%
      setdiff(node)
    
    node_x <- dpositions[node, "V1"]
    node_y <- dpositions[node, "V2"]
    
    dpositions[relations_edges,] %>%
      mutate(node_origin = node,
             node_x = node_x,
             node_y = node_y,
             node_force = relations_edges,
             dist = (V1 - node_x)^2 + (V2 - node_y)^2,
             dist = sqrt(dist),
             ex = (V1 - node_x)/dist,
             ey = (V2 - node_y )/dist,
             fx = ex*dist^2/K,
             fy = ey*dist^2/K)
  })
}

net.plot <- function(net){
  
  drep <- net.calculate.repulsive(net)
  datt <- net.calculate.attractive(net)
  
  drep2 <- drep %>% group_by(node_origin) %>% summarise(fx=sum(fx), fy=sum(fy))
  datt2 <- datt %>% group_by(node_origin) %>% summarise(fx=sum(fx), fy=sum(fy))
  
  dforce <- rbind.fill(drep, datt) %>%
    group_by(node_x, node_y) %>%
    summarise(fx=sum(fx), fy=sum(fy))
  
  dpositions <- attr(net, "positions") %>% as.data.frame %>% mutate(names = attr(net, "vnames"))
  dedges <- attr(net, "edges") %>% as.data.frame
  
  dedges <- dedges %>%
    cbind( dpositions[dedges$V1,1:2] %>% setNames(c("xs", "ys"))) %>%
    cbind( dpositions[dedges$V2,1:2] %>% setNames(c("xe", "ye")))
  
  p <- ggplot()
  p <- p + geom_point(data=dpositions, aes(V1, V2), size = 10, alpha = 0.7, color="black")
  p <- p + geom_segment(data=dedges, aes(x=xs, y=ys, xend=xe, yend=ye), alpha = 0.7, size = 2, color = "black")
#   p <- p + geom_segment(data=drep ,aes(x=node_x, y=node_y, xend=node_x+fx, yend=node_y+fy), alpha= 0.1, arrow = arrow(), color ="darkred", size=0.5)
#   p <- p + geom_segment(data=drep2,aes(x=node_x, y=node_y, xend=node_x+fx, yend=node_y+fy), alpha= 0.3, arrow = arrow(), color ="darkred", size=1.2)
#   p <- p + geom_segment(data=datt ,aes(x=node_x, y=node_y, xend=node_x+fx, yend=node_y+fy), alpha= 0.1, arrow = arrow(), color="darkblue", size=0.5)
#   p <- p + geom_segment(data=datt2,aes(x=node_x, y=node_y, xend=node_x+fx, yend=node_y+fy), alpha= 0.3, arrow = arrow(), color="darkblue", size=1.2)
#   p <- p + geom_segment(data=dforce,aes(x=node_x, y=node_y, xend=node_x+fx, yend=node_y+fy), alpha= 0.5, arrow = arrow(), color="green", size=1.2)
  p <- p + geom_text(data=dpositions, aes(V1, V2, label=names), color = "white")
  p <- p + theme_gray()
  p
}

net.plot(net)

net.update.positions <- function(net){
  
  dpositions <- attr(net, "positions")
  
  drep <- net.calculate.repulsive(net)
  datt <- net.calculate.attractive(net)  
  dforce <- rbind.fill(drep, datt) %>%
    group_by(node_origin) %>%
    summarise(fx=sum(fx), fy=sum(fy)) %>%
    select(fx, fy)
  
  dpositions_update <- dpositions + dforce
  dpositions_update <- dpositions_update %>%
    setNames(c("V1", "V2")) %>%
    as.matrix
  
  attr(net, "positions") <- dpositions_update
  
  net   
  
}


net.plot(net)
net <- net.update.positions(net)



