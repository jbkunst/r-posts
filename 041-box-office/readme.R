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

library("dplyr")
library("rvest")
library("purrr")
library("stringr")
library("DT")
library("ggplot2")
library("scales")
library("directlabels")
library("lubridate")
library("RImagePalette")
library("printr")
library("highcharter")
library("htmltools")
#' 
#' *Shh.. this post is an excuse to test the brand new subtitles and 
#' captions in #ggplot2! powered by @hrbrmstr*.
#' 
#' <blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">&quot;And there 
#' came a day unlike any other,when earth&#39;s mightiest data sci vis tool added subtitles 
#' &amp; captions&quot; <a href="https://t.co/eRVPxz52iL">https://t.co/eRVPxz52iL</a> 
#' <a href="https://twitter.com/hashtag/rstats?src=hash">#rstats</a></p>&mdash; boB Rudis 
#' (@hrbrmstr) <a href="https://twitter.com/hrbrmstr/status/709824064190337027">March 15, 
#' 2016</a></blockquote>
#' <script async src="http://platform.twitter.com/widgets.js" charset="utf-8"></script>
#' 
#' The recently^[I remeber this movie like it was yesterday] SW7 ($930,901,726 gross income) 
#' and the not so standar Deadpool ($329,397,732) are **top 1** and **top 7** (and climbing) in 
#' terms of gross income according to  <http://www.boxofficemojo.com/> site.
#' Have you ask yourself how much gross income the movies produces? A lot i guess! 
#' What movies are the most succesfull in a particular saga? I dont know so write some
#' code to scrap and discover it because  <http://www.boxofficemojo.com/> have all these 
#' data and we're here visualize it.
#' 
#' 
#' ## Data
#' 
#' We'll extract the (only US) gross income for the top 200 movies^[You can get more if
#' you want to test the visualizations with 1000 movies] and then, for each movie extract
#' the *daily* chart section which containts for every day since the release date the gross
#' income per day! This is just fantastic. So here we go.
#' 
#+eval=FALSE
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
  # show_col(imgpltt)
  
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
      setNames(c("day", "date", "rank", "gross", "pd","na",
                 "theatres_avg", "na2", "gross_to_date", "day_number")) %>% 
      mutate(box_id = x) %>% 
      filter(!is.na(day_number))
  }
  
  saveRDS(dfgr, file = sprintf("data/%s.rds", x))
  
  dfgr
  
})

# This is only necessary if you have a non english R version
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
         production_budget = 1e6 * as.numeric(production_budget)
  )

rm(dfmovie2)

#+ echo=FALSE
save(dfgross, dfmovie, file = "data/boxoffice-data.RData")
rm(list = ls())
load("data/boxoffice-data.RData")

#' 
#' Finally  we have the movies data with some interesting colums like 
#' `production_budget`, total life time gross income `gross` and the
#' `max_day` column which count the days in theatres. Here are
#' the top 10 movies
#'

dfmovie %>%
  select(rank, title, year, gross, genre) %>% 
  mutate(gross = dollar(gross)) %>% 
  head(10)

#' Phantom Menace ad Jurassic World top 10? 
#'   
#' We have the incomes by day for every movie too. So we can plot time
#' series and compare! The data is just telling us what to do. Here's 
#' a sample of the detailed data by day.
#' 

dfgross %>%
  filter(box_id == "starwars7") %>% 
  mutate(gross = dollar(gross),
         gross_to_date = dollar(gross_to_date)) %>% 
  select(box_id, date, day_number, gross, gross_to_date) %>% 
  head(10)

#'
#' ## Plot
#' 
#' Okey, here we take a breath. A lot of ideas and only one order 
#' to code all of them. Just start considering the release date for every
#' movie and its gross income evolution.
#' 
#' First well use the color for every movie extracted using the 
#' nice `RImagePalette` package and the select the top movies and 
#' the movies with more days in theatres to annotate them in the plot. 

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
  select(max_day, box_id) %>% 
  head(ntoplabel) %>%
  .$box_id

movieslbl <- unique(c(moviestop, movieslng))
movieslbl <- setdiff(movieslbl, c("starwars4"))

fmt_dllr_mm <- function(x) {
  x %>% 
    {./1000000} %>% 
    dollar()
}

tt1 <- "Cumulative Gross Income"
stt1 <- "Titanic (1997),  Avatar (2009) and Star Wars VII (2016) are the movies with most gross income in the film history."
cptn <- "jkunst.com | Data from boxofficemojo.com"

dfgross %>% 
  ggplot(aes(date2, gross_to_date,
             color = box_id, label = str_to_title(box_id))) + 
  geom_line(alpha = 0.25) + 
  scale_color_manual(values = cols) + 
  geom_label(data = dfgross %>%
               filter(box_id %in% movieslbl) %>% 
               arrange(desc(day_number)) %>% 
               distinct(box_id)) + 
  theme(legend.position = "none") +
  xlim(as.Date(min(dfgross$date2)), as.Date(ymd(20170101))) + 
  scale_y_continuous(labels = fmt_dllr_mm) +
  labs(title = tt1, subtitle = stt1, caption = cptn,
       x = "Date", y = "Cumulative Gross (millions)")


#' Mmm the first conclusion I get from this:
#' 
#' > You don't need only network data to get a *spaghetti-like* plot. 
#' 
#' Mmm I think this is a nice result for the first try^[this is a lie, I did more tries
#' before this plot XD]. Clearly we can observe the date of release and compare the
#' gross income between the movies. Nice to see and remeber old classics like ET and
#' Back to the Future. Well the time scale is so big we can't differentiate how long
#' each movie had been in theatres. To get a more fair comparision we plot every movie
#' considering `x` the day since release. I'm not sure if `gross` is comparable due 
#' time of release but well keep data as is.


tt2 <- "Cumulative Gross Income by Days"
stt2 <- "Only 3 movies: Jurassic Park (497 days) ET, Gladiator and were more than a year in theaters."


dfgross %>% 
ggplot(aes(day_number, gross_to_date,
           color = box_id, label = str_to_title(box_id))) + 
  geom_line(alpha = 0.25) + 
  geom_label(data = dfgross %>%
               filter(box_id %in% movieslbl) %>% 
               arrange(desc(day_number)) %>% 
               distinct(box_id)) + 
  scale_color_manual(values = cols) + 
  theme(legend.position = "none") +
  xlim(NA, 550) + 
  scale_y_continuous(labels = fmt_dllr_mm) +
  labs(title = tt2, subtitle = stt2,  caption = cptn,
       x = "Days since release", y = "Cumulative Gross (millions)") +
  annotate("segment", x = 365, xend = 365, y = 0, yend = 925000000, colour = "gray") +
  geom_text(label = "One Year", x = 365, y = 950000000)

#' 
#' Jurassic Park and ET were more than a year! The plot still
#' like spaghetti but a *info-tasty* spagehtti.
#' 
#' Now, we can compare movies between other movies in their saga to 
#' show what part number is in general most successful in terms of 
#' income.

moviessaga <- dfgross %>% 
  distinct(movieserie, serienumber) %>% 
  count(movieserie) %>% 
  arrange(desc(n)) %>% 
  filter(n >= 4) %>% 
  .$movieserie

tt3 <- "Comparing Gross Income between Sagas"
stt3 <- "Interesting pattern and order is showed in Pirates of the Carrbbean, 
Shrek and Transformes where the second movie have the greatest income"
st <- gsub("\n", " ", stt3)

dfgross %>%
  filter(movieserie %in% moviessaga) %>%
  mutate(movieserie = factor(movieserie, levels = moviessaga)) %>% 
  ggplot(aes(day_number, gross_to_date, label = serienumber)) + 
  geom_line(aes(color = box_id), alpha = 0.5) +
  geom_label(data = dfgross %>%
               filter(movieserie %in% moviessaga) %>%
               mutate(serienumber = ifelse(box_id == "transformers06", 1, serienumber),
                      movieserie = factor(movieserie, levels = moviessaga)) %>%
               arrange(desc(day_number)) %>%
               distinct(box_id)) +
  facet_wrap(~movieserie, scales = "free_y") + 
  scale_y_continuous(labels = fmt_dllr_mm) +
  labs(title = tt3, subtitle = stt3, caption = cptn,
       x = "Days since release", y = "Gross (millions)") + 
  theme(legend.position = "none")

#' Aha! Nice pattern 2-3-1-4 in the Pirates of the caribbean, Shrek and Transformers
#' we got: The first movie have a long time in theatres but they arent more popular
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
         gross_budget_ratio = percent(gross/production_budget),
         production_budget = fmt_dllr_mm(production_budget),
         gross = fmt_dllr_mm(gross),
         name = title,
         color = img_main_color) %>% 
  list.parse3() 

t <- c("gross_budget_ratio", "production_budget", "gross", "distributor", "mpaa_rating")
x <- t %>% str_to_title() %>% gsub("_", " ", .)
y <- sprintf("{point.%s}", t)

tooltip <- tooltip_table(
  x, y,
  img = tags$img(src = "{point.img_url}", width = 150, height = 222,
                 style = "display: block;margin-left: auto;margin-right:auto"),
  `min-heigth` = 300 
)

hcscttr <- highchart() %>% 
  hc_chart(zoomType = "xy") %>% 
  hc_title(text = "Gross Income versus Production Budget") %>%
  hc_add_series(data = dsmovie, type = "scatter", showInLegend = FALSE) %>%
  hc_xAxis(title = list(text = "Gross income")) %>% 
  hc_yAxis(title = list(text = "Production Budget")) %>% 
  hc_tooltip(useHTML = TRUE,
             headerFormat = as.character(tags$small("{point.key}")),
             pointFormat = tooltip) %>% 
  hc_add_theme(hc_theme_smpl()) 

hcscttr

#' Mmm, not sure if we see a interesting pattern but the chart is
#' good for an exploratoy process: For example we can see *Superman
#' Returns* have a ~ 1 gross budget ratio.
#' 
#' Now we'll replicate the previous plots using [highcharter](jkunst.com/highcharter)
#' to have tooltips with more information ;D.

x <- c("Gros:", "Genre", "Runtime")
y <- c("$ {point.y}", "{point.series.options.extra.genre}", "{point.series.options.extra.runtime}")

tooltip <- tooltip_table(
  x, y,
  tags$img(src = "{point.series.options.extra.img_url}", width = 150, height = 222,
           style = "display: block;margin-left: auto;margin-right:auto")
)


# This function is a little tricky. We put the 
# title (not the value) only if the point is
# the LAST point in the data
fmtrr <- "function() {
  if (this.point.x == this.series.data[this.series.data.length-1].x & 
       this.series.options.showlabel) {
      return this.series.options.extra.title;
  } else {
      return null;
  }
}"

hcgross <- highchart() %>% 
  hc_chart(zoomType = "x") %>% 
  hc_tooltip(followPointer =  FALSE) %>% 
  hc_yAxis(title = list(text = "Gross income")) %>%
  hc_tooltip(
    useHTML = TRUE,
    pointFormat = tooltip
  ) %>% 
  hc_plotOptions(
    series = list(
      dataLabels = list(
        enabled = TRUE,
        align = "left",
        verticalAlign = "middle",
        formatter = JS(fmtrr),
        crop = FALSE,
        overflow = FALSE
      )
    )
  ) %>% 
  hc_add_theme(hc_theme_smpl()) 

hcgross1 <- hcgross %>% 
  hc_title(text = tt1) %>%
  hc_subtitle(text = stt1) %>%
  hc_xAxis(title = list(text = "Date")) %>%
  hc_xAxis(type = "datetime")

hcgross2 <- hcgross %>% 
  hc_title(text = tt1) %>% 
  hc_subtitle(text = stt2) %>%
  hc_xAxis(title = list(text = "Days since release")) %>% 
  hc_tooltip(headerFormat = as.character(tags$small("{point.key} days sinsce release")))

for (id in unique(dfgross$box_id)) {
# for (id in head(unique(dfgross$box_id), 10)) {
    
  message(id)
  dfaux <- dfgross %>% filter(box_id == id)
  
  dsmov <- dfmovie %>% 
    filter(box_id == id) %>% 
    as.list()
  
  showlabel <- id %in% movieslbl
  
  hcgross1  <- hcgross1 %>% 
    hc_add_serie_times_values(dfaux$date2, dfaux$gross_to_date,
                              name = id, showInLegend = FALSE,
                              extra = dsmov,  showlabel = showlabel,
                              color = hex_to_rgba(dsmov$img_main_color, 0.52))
  
  hcgross2  <- hcgross2 %>% 
    hc_add_serie(data = dfaux %>% select(day_number, gross_to_date) %>% list.parse2(),
                 name = id, showInLegend = FALSE, marker = list(enabled = FALSE),
                 extra = dsmov, showlabel = showlabel,
                 color = hex_to_rgba(dsmov$img_main_color, 0.25))
 
}

hcgross1
hcgross2

#' What do you think? I love see how R can make (almost!) ready 
#' publish plots and charts!

#+echo=FALSE
#### EXTRACT EXPORT 
hcgross1 <- hcgross %>% 
  hc_title(text = tt1) %>%
  hc_subtitle(text = stt1) %>%
  hc_xAxis(title = list(text = "Date")) %>%
  hc_xAxis(type = "datetime")

hcgross2 <- hcgross %>% 
  hc_title(text = tt1) %>% 
  hc_subtitle(text = stt2) %>%
  hc_xAxis(title = list(text = "Days since release")) %>% 
  hc_tooltip(headerFormat = as.character(tags$small("{point.key} days sinsce release")))

for (id in unique(dfgross$box_id)) {
  # for (id in head(unique(dfgross$box_id), 100)) {
  
  message(id)
  dfaux <- dfgross %>% filter(box_id == id)
  
  dsmov <- dfmovie %>% 
    filter(box_id == id) %>% 
    select(title, genre, img_url, mpaa_rating,img_main_color) %>% 
    as.list()
  
  showlabel <- id %in% movieslbl
  
  hcgross1  <- hcgross1 %>% 
    hc_add_serie_times_values(dfaux$date2, dfaux$gross_to_date,
                              name = id, showInLegend = FALSE,
                              extra = dsmov,  showlabel = showlabel,
                              color = hex_to_rgba(dsmov$img_main_color, 0.52))
  
  hcgross2  <- hcgross2 %>% 
    hc_add_serie(data = dfaux %>% select(day_number, gross_to_date) %>% list.parse2(),
                 name = id, showInLegend = FALSE, marker = list(enabled = FALSE),
                 extra = dsmov, showlabel = showlabel,
                 color = hex_to_rgba(dsmov$img_main_color, 0.25))
  
}

hcgross1
hcgross2


try(dir.create("js"))
export_hc(hcscttr, "js/mvie-scatter.js")
export_hc(hcgross1, "js/mvie-gross1.js")
export_hc(hcgross2, "js/mvie-gross2.js")


