library("xml2")
library("dplyr")
library("stringr")
library("RSQLite")
rm(list = ls())

file <- "~/../Downloads/stackoverflow.com-Posts/Posts.xml"
# file <- "~/../Downloads/meta.stats.stackexchange.com/Posts.xml"
db_path <- file.path(dirname(file), "so-db.sqlite")

if (file.exists(db_path)) file.remove(db_path)

con <- file(description = file, open = "r")
db <- dbConnect(SQLite(), dbname = db_path)

invisible(readLines(con = con, n = 2))

max_iters <- 5000
actual_iter <- 0
chunk_size <- 500

total_posts <- 0
total_questions <- 0

while (TRUE) {
  
  actual_iter <- actual_iter + 1
  if (actual_iter %% 1000 == 0) {
    message("iter ", actual_iter)
    message("total_posts ", total_posts)
    message("total_questions ", total_questions)
  }
  
  tmplines <- readLines(con = con, n = chunk_size, encoding = "UTF-8")
  
  if (length(tmplines) == 0) {
    message("bye!")
    break
  } 
  
  if (str_detect(tmplines[length(tmplines)], "</posts>")) {
    message("Yay last chunk!")
    tmplines <- tmplines[-length(tmplines)]
  }
  
  total_posts <- total_posts + length(tmplines)
  
  x <- read_html(paste(tmplines, collapse = ""))
  
  rows <- x %>% xml_find_one("body") %>% xml_find_all("row")
  
  posttiypeids <- x %>%  xml_find_all("body") %>% xml_find_all("row") %>% xml_attr("posttypeid")
  
  rows <- rows[posttiypeids == "1"]
  
  total_questions <- total_questions + length(rows)
  
  df <- data_frame(id = rows %>% xml_attr("id"),
                   creationdate = rows %>% xml_attr("creationdate"),
                   score = rows %>% xml_attr("score"),
                   viewcount = rows %>% xml_attr("viewcount"),
                   title = rows %>% xml_attr("title"),
                   tags = rows %>% xml_attr("tags"))
  
  dbWriteTable(conn = db, name = "questions", as.data.frame(df),
               row.names = FALSE, append = TRUE)
  
  df2 <- df %>% select(id, tags) %>% group_by(id(1)
1 29) %>% do({
    data_frame(tag = str_split(.$tags, "<|>") %>% unlist() %>% setdiff(c("")))
  }) %>% ungroup()
  
  dbWriteTable(conn = db, name = "questions_tags", as.data.frame(df2),
               row.names = FALSE, append = TRUE)
  
}

dbDisconnect(db)


### test 
db <- dbConnect(SQLite(), dbname = db_path)
dbGetQuery(db, "select count(1) from questions")
dbGetQuery(db, "select count(1) from questions_tags")
dbDisconnect(db)
