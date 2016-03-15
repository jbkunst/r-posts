#' ---
#' title: ""
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())
library("jbkmisc")

blog_setup()
knitr::opts_chunk$set(fig.width = 10, fig.height = 6)

library("dplyr")
library("rvest")
library("purrr")
library("stringr")
library("DT")
library("ggplot2")
library("directlabels")
library("lubridate")
library("RImagePalette")

#'
#' ## Data
#' 

url <- "http://www.boxofficemojo.com/alltime/domestic.htm"

urls <- paste0(url, sprintf("?page=%s&p=.htm", 1:2))

dfmovie <- map_df(urls, function(x){
  # x <- sample(size = 1, urls)
  urlmovie <- read_html(x) %>% 
    html_nodes("table table tr a") %>%
    html_attr("href") %>% 
    .[str_detect(., "movies")]
  
  read_html(x) %>% 
    html_nodes("table table") %>% 
    html_table(fill = TRUE) %>% 
    .[[4]] %>% 
    tbl_df() %>% 
    .[-1, ] %>% 
    setNames(c("rank", "title", "studio", "gross", "year")) %>% 
    mutate(url_movie = urlmovie)
  
}) 

dfmovie <- dfmovie %>% 
  mutate(year = str_extract(year, "\\d+"),
         year = as.numeric(year),
         have_release = str_detect(url_movie, "releases"),
         box_id = str_extract(url_movie, "id=.*"),
         box_id = str_replace_all(box_id, "^id=|\\.htm$", ""))

dfmovie2 <- map_df(dfmovie$box_id, function(x){
  # x <- "starwars2"
  # x <- sample(dfmovie$box_id, size =1); 
  message(x)
  
  if (file.exists(sprintf("data/%s-p2.rds", x))) {
    dfm <- readRDS(sprintf("data/%s-p2.rds", x))
    return(dfm)
  }
  
  html <- sprintf("http://www.boxofficemojo.com/movies/?page=main&id=%s.htm", x) %>% 
    read_html()
  
  img_url <- html %>% 
    html_nodes("table table table img") %>% 
    .[[1]] %>% 
    html_attr("src")
  
  tmp <- tempfile(fileext = ".jpg")
  download.file(img_url, tmp, mode = "wb", quiet = TRUE)
  img <- jpeg::readJPEG(tmp)
  imgpltt <- image_palette(img, n = 1, choice = median)
  
  # par(mfrow = c(1, 2))
  # display_image(img)
  # scales::show_col(imgpltt)
  
  dfaux <- html %>% 
    html_nodes("table  table  table") %>% 
    .[[2]] %>% 
    html_table(fill = TRUE) %>% 
    .[-1, 1:2] %>% 
    tbl_df()

  dfm <- data_frame(
    box_id = x,
    distributor = str_replace(dfaux[2, 1], "Distributor: ", ""),
    genre = str_replace(dfaux[3, 1], "Genre: ", ""),
    mpaa_rating = str_replace(dfaux[4, 1], "MPAA Rating: ", ""),
    runtime = str_replace(dfaux[3, 2], "Runtime: ", ""),
    production_budget = str_extract(dfaux[4, 2], "\\d+"),
    img_url = img_url,
    img_main_color = imgpltt
  )
  
  saveRDS(dfm, file = sprintf("data/%s-p2.rds", x))
  
  dfm
    
})

dfgross <- map_df(dfmovie$box_id, function(x){
  # x <- sample(dfmovie$box_id, size =1)
  message(x)
  
  if (file.exists(sprintf("data/%s.rds", x))) {
    dfgr <- readRDS(sprintf("data/%s.rds", x))
    return(dfgr)
  }
    
  dfgr <- sprintf("http://www.boxofficemojo.com/movies/?page=daily&view=chart&id=%s.htm", x)  %>% 
    read_html() %>% 
    html_nodes("table table table") %>% 
    html_table(fill = TRUE) %>% 
    last() %>% 
    tbl_df()
  
  if (nrow(dfgr) == 1) {
    dfgr <- data_frame(box_id = x)
  } else {
    dfgr <- dfgr %>% 
      .[-1, ] %>% 
      setNames(c("day", "date", "rank", "gross", "pd", "na", "theaters_avg", "na2", "gross_to_date", "day_number")) %>% 
      mutate(box_id = x) %>% 
      filter(!is.na(day_number))
  }
  
  saveRDS(dfgr, file = sprintf("data/%s.rds", x))
  
  dfgr
  
})

try(x <- Sys.setlocale("LC_TIME", "en_US.UTF-8"))
try(x <- Sys.setlocale("LC_TIME", "English"))

dfgross <- dfgross %>% 
  mutate(gross = as.numeric(str_replace_all(gross, "\\$|\\,", "")),
         gross_to_date = as.numeric(str_replace_all(gross_to_date, "\\$|\\,", "")),
         day_number = as.numeric(day_number),
         date2 = str_replace_all(date, "\\t|\\.", ""),
         date2 = as.Date(date2, "%b %d, %Y"),
         decade = year(date2)/100,
         movieserie = str_extract(box_id, "^[A-Za-z]+|\\d{2,3}"),
         serienumber = str_extract(box_id, "\\d{1,2}$"),
         serienumber = ifelse(is.na(serienumber), 1, serienumber)) %>% 
  filter(!is.na(date)) 


dfmovie <- dfmovie %>% 
  left_join(dfmovie2, by = "box_id") %>% 
  left_join(dfgross %>% 
              group_by(box_id) %>% 
              summarise(max_day = max(day_number)),
            by = "box_id")

dfmovie <- dfmovie %>% 
  mutate(rank = as.numeric(rank),
         gross = as.numeric(str_replace_all(gross, "\\$|\\,", "")),
         studio = str_replace_all(studio, "\\.", "")
  )

head(dfmovie)
rm(dfmovie2)

save(dfgross, dfmovie, file = "data/data.RData")

#'
#' ## Plot
#' 

cols <- setNames(dfmovie$img_main_color, dfmovie$box_id)

ntoplabel <- 10 + 1 # rm starwars
nmostlong <- 10

moviestop <- dfmovie %>%
  arrange(rank) %>% 
  head(ntoplabel) %>%
  .$box_id

movieslng <- dfmovie %>%
  arrange(desc(max_day)) %>% 
  head(ntoplabel) %>%
  .$box_id

movieslbl <- unique(c(moviestop, movieslng))
movieslbl <- setdiff(movieslbl, c("starwars4"))

fmt_dllr_mm <- function(x) {
  x %>% 
    {./1000000} %>% 
    scales::dollar()
}

ggplot(dfgross,
             aes(date2, gross_to_date, color = box_id, label = str_to_title(box_id))) + 
  geom_line(alpha = 0.25) + 
  scale_color_manual(values = cols) + 
  geom_dl(data = dfgross %>% filter(box_id %in% movieslbl),
          method = list("last.points", cex = 0.75)) + 
  theme(legend.position = "none") +
  xlim(as.Date(min(dfgross$date2)), as.Date(ymd(20180101))) + 
  scale_y_continuous(labels = fmt_dllr_mm) +
  labs(title = "Cumulative gross for TOP 200 movies",
       subtitle = "the gross and length",
       caption = "Data from boxofficemojo.com",
       x = "Time",
       y = "Cumulative Gross (millions)")

ggplot(dfgross,
             aes(day_number, gross_to_date, color = box_id, label = str_to_title(box_id))) + 
  geom_line(alpha = 0.25) + 
  geom_dl(data = dfgross %>% filter(box_id %in% movieslbl),
          method = list("last.points", cex = 0.75)) + 
  scale_color_manual(values = cols) + 
  theme(legend.position = "none") +
  xlim(NA, 550) + 
  scale_y_continuous(labels = fmt_dllr_mm) +
  labs(title = "Cumulative gross for TOP 200 movies",
       subtitle = "the gross and length",
       caption = "Data from boxofficemojo.com",
       x = "Days since release",
       y = "Cumulative Gross (millions)")


moviessaga <- dfgross %>% 
  distinct(movieserie, serienumber) %>% 
  count(movieserie) %>% 
  arrange(desc(n)) %>% 
  filter(n >= 4) %>% 
  .$movieserie

ggplot(dfgross %>% filter(movieserie %in% moviessaga),
       aes(day_number, gross_to_date)) + 
  geom_line(aes(color = box_id), alpha = 0.5) +
  geom_dl(aes(label = serienumber), method = list("last.points", cex = 0.75), alpha = 0.75) + 
  facet_wrap(~movieserie, scales = "free") + 
  scale_y_continuous(labels = fmt_dllr_mm) +
  labs(title = "Comparing gross between sagas",
       subtitle = "Usually the order es 2, 1, 3, 4 in gross terms",
       caption = "Data from boxofficemojo.com",
       x = "Days since release",
       y = "Gross (millions)") + 
  theme(legend.position = "none")



