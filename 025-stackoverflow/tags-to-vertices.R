set.seed(1)
nrow <- 10
id <- sample(1:5, size = nrow, replace = TRUE)
tag <- sample(letters[1:4], size = nrow, replace = TRUE)


df <- data_frame(id, tag)
df %>% count(tag) %>% arrange(desc(n))


df2 <- left_join(df, df %>% select(id, tag2 = tag)) %>% 
  filter(tag < tag2)

df3 <- rbind(df2 %>% count(tag) %>% arrange(desc(n)),
             df2 %>% count(tag = tag2) %>% arrange(desc(n))) %>% 
  tbl_df() %>% 
  group_by(tag) %>%
  summarise(n = sum(n)) %>% 
  arrange(desc(n))


df %>% count(tag) %>% arrange(desc(n))
df3
