library("networkD3")
# Load data
data(MisLinks)
data(MisNodes)

# Plot
forceNetwork(Links = MisLinks, Nodes = MisNodes,
             Source = "source", Target = "target",
             Value = "value", NodeID = "name",
             Group = "group", opacity = 0.8)

head(MisNodes)
MisNodes %>% summarise(max(size))

nodes2 <- nodes %>% 
  select(name = label, group = cluster, size = n) %>% 
  mutate(size = round(30*size/max(size)))


head(MisLinks)
MisLinks %>% summarise(max(value))
edges2 <- edges %>% 
  left_join(nodes %>% select(from = label, id)) %>% 
  rename(source = id) %>%
  left_join(nodes %>% select(to = label, id)) %>% 
  rename(target = id) %>% 
  select(source, target, value = n) %>% 
  mutate(value = round(30*value^2/max(value^2))+1,
         source = source - 1,
         target = target - 1) %>% 
  arrange(desc(value)) %>% 
  head(nrow(nodes2)*2)


forceNetwork(Links = edges2, Nodes = nodes2,
             Source = "source", Target = "target",
             Value = "value", NodeID = "name",
             Group = "group", opacity = 0.8,
             linkDistance = 100, charge = -200)




