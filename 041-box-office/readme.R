#' ---
#' title: "Visualizing Gross Income on Movies"
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
library("printr")
library("highcharter")
#' 
#' The recently (I remeber this movie like it was yesterday) SW7 ($930,901,726 gross income) 
#' and the non standar Deadpool ($329,397,732) are top 1 and top 7 in 
#' terms of gross income according to  <http://www.boxofficemojo.com/> site.
#' Have you ask yourself how much gross income the movies produces? Uff a lot! What movies are the most
#' succesfull in a particular saga? I dont know so lets discover it because 
#' <http://www.boxofficemojo.com/> have all these data and we're here to scrap it a 
#' visualize it (shh.. and this is an excellent excuses to
#' test the brand new subtitles and captions in #ggplot2! powered by @hrbrmstr)
#' 
#' <blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">&quot;And there 
#' came a day unlike any other,when earth&#39;s mightiest data sci vis tool added subtitles 
#' &amp; captions&quot; <a href="https://t.co/eRVPxz52iL">https://t.co/eRVPxz52iL</a> 
#' <a href="https://twitter.com/hashtag/rstats?src=hash">#rstats</a></p>&mdash; boB Rudis 
#' (@hrbrmstr) <a href="https://twitter.com/hrbrmstr/status/709824064190337027">March 15, 
#' 2016</a></blockquote>
#' <script async src="http://platform.twitter.com/widgets.js" charset="utf-8"></script>
#' 
#' 
#' ## Data
#' 
#' We'll extract the (only US) gross income for the top 200 movies (you can get more if
#' you want to test the visualizations with 1000 movies) and then, for each movie extract
#' the *daily* chart section which containts for every day since the release date the gross
#' income per day! This is just fantastic. So here we go.
#' 

#### scrap ####
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
    # I'm always have conecction issues so for avoid 
    # loose data I save the data.
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
         studio = str_replace_all(studio, "\\.", ""),
         production_budget = 10e6 * as.numeric(production_budget)
  )

head(dfmovie)
rm(dfmovie2)

#+ echo=FALSE
save(dfgross, dfmovie, file = "data/boxoffice-data.RData")
rm(list = ls())
load("data/boxoffice-data.RData")

#' 
#' Finally  we have the movies data with some interesting colums like 
#' `production_budet`, total life time gross income `gross` and the
#' `max_day` column which count the days in theaters. Here ara
#' the top 10 movies
#'

dfmovie %>%
  select(rank, title, gross, genre) %>% 
  mutate(gross = scales::dollar(gross)) %>% 
  head(10)

#' Phantom Menace ad Jurassic World top 10? 
#'   
#' We have too the incomes by day for every movie so, we can plot time
#' series and compare! The data is just telling us what to do.
#' 

datatable(dfgross %>% filter(box_id == "starwars7"))

#'
#' ## Plot
#' 
#' Okey, here we take a breath. A lot of ideas and only one order 
#' to code all of them. Just start considering the release date for every
#' movie and its gross income evolution. 
#' 
#'  First well use the color for every movie extracted using the 
#'  nice `RImagePalette` package and the select the top movies and 
#'  the movies with more day in theater to annotate them in the plot. 

#### plot ####
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
  labs(title = "Cumulative gross income for the TOP 200 movies",
       subtitle = "asd",
       caption = "Jbkunst || Data from boxofficemojo.com",
       x = "Time",
       y = "Cumulative Gross (millions)")

#' Mmm the first conclusion I get from this:
#' 
#' > You don't need only network data to get a *spaghetti-like* plot. 
#' 
#' Mmm I think this is a nice result for the first try^[this is a lie, I did more tries
#' before this plot XD]. Clearly we can observe the date of release and compare the
#' gross income between the movies. Nice to see and remeber old classics like ET and
#' Back to the Future. Well the time scale is so big we can't differentiate how long
#' each movie had been in theaters. To get a more fair comparision we plot every movie
#' considering `x` the day since release:

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

#' 
#' Now it's clearly see Jurassic Park and ET were more than a year It's still
#' like spaghetti but a tasty spagehtti.
#' 
#' Now, we can compare movies between other movies in their saga.

moviessaga <- dfgross %>% 
  distinct(movieserie, serienumber) %>% 
  count(movieserie) %>% 
  arrange(desc(n)) %>% 
  filter(n >= 4) %>% 
  .$movieserie

dfgross %>%
  filter(movieserie %in% moviessaga) %>%
  mutate(serienumber = ifelse(box_id == "transformers06", 1, serienumber)) %>% 
ggplot(aes(day_number, gross_to_date)) + 
  geom_line(aes(color = box_id), alpha = 0.5) +
  geom_dl(aes(label = serienumber), method = list("last.points", cex = 0.75), alpha = 0.75) + 
  facet_wrap(~movieserie, scales = "free_y") + 
  scale_y_continuous(labels = fmt_dllr_mm) +
  labs(title = "Comparing gross between sagas",
       subtitle = "In 3 of the 6 sagas with more movies the 1st movie have the longest time 
in theater but they are not the most popular than the 2nd and 3rd movie (in order)",
       caption = "Data from boxofficemojo.com",
       x = "Days since release",
       y = "Gross (millions)") + 
  theme(legend.position = "none")

#' Aha! Nice pattern 2-3-1-4 in the Pirates of the caribbean, Shrek and Transformers
#' we got: The first movie have a long time in theaters but they arent more popular
#' than the second one (and the 3rd) in the saga and the 4th is the movie with 
#' *less* gross imcome.
#' 
#' Now well try to implement the scatter version of `gross` vs `production_budget`. 
#' 
#### chart ####
dsmovie <- dfmovie %>% 
  filter(!is.na(production_budget)) %>% 
  mutate(x = gross,
         y = production_budget,
         z = max_day,
         name = title,
         color = img_main_color) %>% 
  list.parse3() 

str(dsmovie[[1]])

thmhc <- hc_theme(
  chart = list(
    style = list(
      fontFamily = "Roboto"
    )
  ),
  title = list(
    align = "left",
    style = list(
      fontFamily = "PT Sans Narrow"
    )
  ),
  subtitle = list(
    align = "left",
    style = list(
      fontFamily = "PT Sans Narrow"
    )
  ),
  xAxis = list(
    gridLineWidth = 1
  )
)


highchart() %>% 
  hc_title(text = "SasdasAs asdA asd") %>%
  hc_subtitle(text = "SasdasAs asdA asd") %>% 
  hc_add_series(data = dsmovie, type = "scatter",
                showInLegend = FALSE) %>%
  hc_add_theme(thmhc)


