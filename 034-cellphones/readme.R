#' ---
#' title: ""
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())
knitr::opts_chunk$set(error = TRUE, warning = FALSE, message = FALSE,
                      fig.showtext = TRUE, dev = "CairoPNG", fig.width = 8)
library("dplyr")
library("purrr")
library("rvest")
library("magrittr")
library("stringr")
library("tidyr")
library("highcharter")
library("lubridate")
library("ggplot2")
library("ggthemes")
library("printr")
library("broom")
library("htmltools")
library("showtext")

# font.add.google("Roboto", "myfont")
# showtext.auto()

theme_set(
  theme_fivethirtyeight(base_size = 13, base_family = "myfont") +
            theme(legend.position = "none")
  )

hcopts <- getOption("highcharter.options")
hcopts <- rlist::list.merge(
  hcopts,
  list(
    chart = list(
      credits = list(
        enabled = TRUE,
        text = "jkunst.com",
        href = "http://jkunst.com"
      )
    )
  )
)
options(highcharter.options = hcopts)

#' ### TL DRs
#' 
#' Time ago I changed my humble moto G 1st gen with a more big Mate Ascend 7 
#' and my thumb did things I didn't know to reach the opposite top corner. 
#' I one of this efforts to reach a far icon I remembered the *phone evolution*
#' image: 
#' 
#' ![Mobile-Phone-Evolution](Mobile-Phone-Evolution.png)
#'  
#' And then I asked how true is this image. How similiar is this trend in reality?
#' So, just for fun (and to show what highcharter can do too!) I coded to kwow the
#' truth.
#'  
#'  ## The data
#'  
#'  When you have doubts about the cellphones specficiaction you always finish
#'  in the gsmarena.com site. They did an analisys about this topic It was very
#'  descriptive but I think they could do better in terms of visualization:
#'  
#'  ![chart-weigth](http://cdn.gsmarena.com/vv/reviewsimg/shapes-and-sizes-study/chart-weight.gif)
#'  
#'  Well basically I made a script to get all the phone brand first. Then for each
#'  of them download all brands' phones (and not phone, beacuse I founded some AIO and some watches)
#'  
#'  
url <- "http://www.gsmarena.com"

tabletd <- file.path(url, "makers.php3") %>% 
  read_html() %>% 
  html_nodes("table td")

dfbrands <- data_frame(
  td1 = tabletd[seq(1, length(tabletd), 2)],
  td2 = tabletd[seq(2, length(tabletd), 2)]
  ) %>%  
  mutate(brand_name = html_node(td2, "a") %>% html_text(),
         brand_url = html_node(td1, "a") %>% html_attr("href"),
         brand_image_url = html_node(td1, "img") %>% html_attr("src"),
         brand_n_phn = str_extract(brand_name, "\\(\\d+\\)"),
         brand_n_phn = str_replace_all(brand_n_phn, "\\(|\\)", ""),
         brand_n_phn = as.numeric(brand_n_phn),
         brand_name = str_replace_all(brand_name, " phones \\(\\d+\\)", "")) %>% 
  select(-td1, -td2) %>% 
  arrange(-brand_n_phn)

head(dfbrands)

#' We have the brand logo so we can extract the main color of image
#' via  `caTools::read.gif`.

brand_color <- map_chr(dfbrands$brand_image_url, function(url){
  # url <- sample(dfbrands$brand_image_url, size = 1)
  # url <- "http://cdn2.gsmarena.com/vv/logos/lg_mmax.gif"
  img <- caTools::read.gif(url)
  
  colors <- count(data_frame(col = as.vector(img$image)), col) %>% 
    arrange(desc(n)) %>% 
    left_join(data_frame(hex = img$col, col = seq(length(img$col))),
              by = "col") %>% 
    filter(!is.na(hex) & !str_detect(hex, "#F[A-z0-9]F[A-z0-9]F[A-z0-9]"))
  
  str_sub(colors$hex[1], 0, 7)
  
})

dfbrands <- dfbrands %>% mutate(brand_color = brand_color)

#' We're ready to show our fist chart. Here we use the
#' `htmltootls` package to code the tooltip using the
#' tags which the package provide.

n <- 30

dsbrands <- dfbrands %>% 
  head(n) %>% 
  mutate(x = brand_name,
         y = brand_n_phn) %>% 
  list.parse3()

tooltip <- tagList(
  tags$span(style = "float:right;color:#3C3C3C", "{point.y} models"),
  tags$br(),
  tags$img(src = '{point.brand_image_url}')
) %>% as.character()

highchart() %>% 
  hc_title(text = sprintf("Top %s Brands with more phone models", n)) %>% 
  hc_subtitle(text = "data from: http://www.gsmarena.com/") %>% 
  hc_chart(zoomType = "x") %>% 
  hc_tooltip(
    useHTML = TRUE,
    backgroundColor = "white",
    borderWidth = 2,
    headerFormat = "<table style ='width:92px;height:22px' >",
    pointFormat = tooltip,
    footerFormat = "</table>"
  ) %>% 
  hc_yAxis(title = list(text = "Models")) %>% 
  hc_xAxis(categories = map_chr(dsbrands, function(x) x$brand_name)) %>% 
  hc_add_series(data = dsbrands,
                showInLegend = FALSE,
                colorByPoint = TRUE,
                name = "phones models",
                type = "bar") %>% 
  hc_add_theme(
    hc_theme_merge(
      hc_theme_538(),
      hc_theme(colors = map_chr(dsbrands, function(x) x$brand_color))
      )
  )

#' I know! Too much colors but I wanted to represent each bar with the
#' brand color (I'm sorry).
#' 
#' Back to the data: Samsung have over 1000 models! This dont say too much because
#' the hay over 10 Galaxy 5. Besides gsmarena don't have data about the marketshare. 
#' But we can make and idea about the status.
#' 
#' Now we'll scrape the phones data, brand by brand. This part of the code 
#' took a little long time.

#' ## Data phones
#' asdas
#+eval=FALSE
dfphones <- map_df(sample(dfbrands$brand_url), function(burl){
  
  # burl <- "dell-phones-61.php" # burl <- "samsung-phones-9.php"
  
  frdata <- paste0(burl, ".RData")
  
  if(file.exists(frdata))
    return(data_frame(burl))
  
  extract_page_info <- function(pburl) {
    message(pburl)
    phns <- read_html(pburl) %>% 
      html_nodes(".makers > ul > li")
    data_frame(
      phn = html_node(phns, "a") %>% html_text(),
      phn_url = html_node(phns, "a") %>% html_attr("href"),
      phn_image_url = html_node(phns, "img") %>% html_attr("src")  
    )
  }
  
  # check if have pages
  pages <- file.path(url, burl) %>% 
    read_html() %>% 
    html_nodes(".nav-pages a")
  
  if (length(pages) > 0) {
    
    dres <- pages %>% 
      html_attr("href") %>% 
      file.path(url, .) %>% 
      map_df(extract_page_info) %>% 
      rbind(extract_page_info(file.path(url, burl)))
    
  } else {
    
    dres <- extract_page_info(file.path(url, burl))
    
  }
  
  dres <- dres %>% 
    mutate(brand_url = burl)
  
  dres2 <- map_df(dres$phn_url, function(purl){
    # purl <- sample(dfphones$phn_url, size = 1);purl <- "samsung_galaxy_s5_mini-6252.php"
    message(purl)
    dfphn <- file.path(url, purl) %>% 
      read_html() %>% 
      html_table(fill = TRUE) %>% 
      map_df(function(t){
        c(t[1, 1]) %>% 
          cbind(rbind(as.matrix(t[1, 2:3]),
                      as.matrix(t[2:nrow(t), 1:2]))) %>% 
          as.data.frame(stringsAsFactors = FALSE) %>% 
          setNames(c("spec", "spec2", "value")) %>% 
          mutate(spec2 = str_replace_all(spec2, "Â", ""),
                 key = paste(spec, spec2, sep = "_") %>% str_to_lower(),
                 key = str_trim(key),
                 key = str_replace(key, "_$", "_other"),
                 key = str_replace_all(key, "\\.", "")) %>% 
          select(key, value)
      }) %>%
      distinct(key) %>% 
      spread(key, value) %>%
      mutate(phn_url = purl) 
  })
  
  dfphonebrand <- left_join(dres, dres2, by = "phn_url")
  
  save(dfphonebrand, file = frdata)
  
  data_frame(burl)
  
  
})

dfphones <- map_df(dfphones$burl, function(burl){
  load(paste0(burl, ".RData"))
  dfphonebrand
})

#+echo=FALSE
# save(dfbrands, dfphones, file = "gsmarena.RData")
rm(list = ls())
load(file = "gsmarena.RData")

#+echo=TRUE
dfphns <- dfbrands %>% 
  right_join(dfphones, by = "brand_url") 

#' Once time I read something like *the code to clean data is a dirty code*
#' and this is so true. Here we separate some value like `body dimensions`
#' beacuse have strings like `12 x 12 x 12` so we need to extract theses
#' values in separate columns (here we used `tidyr` package). 

dfphns <- dfphns %>% 
  mutate(body_dimensions = str_replace(body_dimensions, "mm \\(.*\\)", ""),
         weight = as.numeric(str_extract(body_weight, "\\d+"))) %>% 
  separate(body_dimensions, into = c("height", "width", "depth"), sep = " x ",
           remove = FALSE, convert = TRUE) %>% 
  mutate(height = as.numeric(height),
         width = as.numeric(width),
         depth = as.numeric(depth),
         r = t(col2rgb(brand_color))[, 1],
         g = t(col2rgb(brand_color))[, 2],
         b = t(col2rgb(brand_color))[, 3],
         brand_color_2 = paste("rgba(", r, ", ", g, ", ", b, ", 0.2)"),
         screen_body_ratio = str_extract(display_size, "\\d+\\.\\d+%"),
         screen_body_ratio = str_replace(screen_body_ratio, "%", ""),
         screen_body_ratio = as.numeric(screen_body_ratio),
         screen_ppi = str_extract(display_resolution, "~\\d+"),
         screen_ppi = as.numeric(str_replace(screen_ppi, "~", "")),
         talk_time = as.numeric(str_extract(`battery_talk time`, "\\d+")),
         camera = str_extract(camera_primary, ".* MP"),
         camera = as.numeric(str_replace(camera," MP", "")),
         year = str_extract(launch_announced, "\\d{4}"),
         month = str_extract(launch_announced, paste(month.abb, collapse = "|")),
         month = ifelse(str_detect(launch_announced, "1Q|Q1"), "Jan", month),
         month = ifelse(str_detect(launch_announced, "2Q|Q2"), "Apr", month),
         month = ifelse(str_detect(launch_announced, "3Q|Q3"), "Jul", month),
         month = ifelse(str_detect(launch_announced, "4Q|Q4"), "Oct", month),
         month = ifelse(is.na(month), "Jan", month)) %>% 
  # Cancelled Not officially announced yet 
  left_join(data_frame(month = month.abb, monthn = seq(12)), by = "month") %>% 
  mutate(launch_date = paste(year, monthn, 1, sep = "-"),
         launch_date = ymd(launch_date)) %>% 
  filter(!(is.na(year) | is.na(month) | is.na(height)),
         screen_body_ratio < 100)


dfbrandcolors <- dfphns %>% 
  select(brand_name, brand_color) %>% 
  distinct() %>% 
  {setNames(.$brand_color, .$brand_name)}

#' Now we have a more tidier data. Nice!
#' 
#' We'll extract some features/specifications like the pixels camera,
#' screen_body_ration, height and plot them vs time.
#+fig.width=9
dfphns %>%
  select(launch_date, brand_name, height, 
         depth, screen_body_ratio, camera) %>% 
  gather(key, value, -launch_date, -brand_name) %>% 
  ggplot(aes(launch_date, value)) + 
  geom_point(aes(color = brand_name), alpha = 0.25) +
  geom_smooth(color = "black", size = 1.2, alpha = 0.5) + 
  scale_color_manual(values = dfbrandcolors) +
  facet_wrap(~key, scales = "free") + 
  ggtitle("Release date vs phone specifications")

#' Clearly the megapixels are getting bigger and the
#' phones are getting more and more thinners nothing to worry about.
#' Now, the screen body ratio start to growth near of 2007 same 
#' date the first iPhone was realeased, coincidence? Not sure.
#' But what we see in height? we see a similiar trend
#' as the image. But this trend it's seem so slight but 
#' this is scale effect beacuse as I said before, there are some
#' NO phones in the data.
#' 
#' Now we'll transform the data to list to chart using 
#' highcharter.

dsphns <- dfphns %>% 
  filter(!is.na(height), !is.na(launch_date)) %>% 
  select(launch_date, height, brand_name, brand_color_2, 
         brand_image_url,
         phn, phn_image_url) %>% 
  mutate(x = datetime_to_timestamp(launch_date),
         y = height,
         color = brand_color_2) %>% 
  list.parse3()

dsphnsiphones <- dsphns[map_lgl(dsphns, function(x) str_detect(x$phn, "^iPhone") )]

glxys <- c("I9000 Galaxy S", "I9100G Galaxy S II", "I9300 Galaxy S III",
           "I9500 Galaxy S4", "Galaxy S5", "Galaxy S6", "Galaxy S6 edge",
           "Galaxy S7", "Galaxy S7 edge")

dsphnsgalaxy <- dsphns[map_lgl(dsphns, function(x) x$phn %in% glxys )]
  
#' To get the loess fit data we'll use the `broom` package to
#' get a tidy data frame to then transform it a list format.

fit <- loess(height ~ datetime_to_timestamp(launch_date),
             data = dfphns) %>% 
  augment() %>% 
  tbl_df()

head(fit)

dssmooth <- fit %>% 
  select(x = datetime_to_timestamp.launch_date.,
         y = .fitted) %>% 
  distinct(x) %>% # imporant!
  arrange(x) %>% # really important!
  list.parse3()

dssarea <- fit %>% 
  mutate(x = datetime_to_timestamp.launch_date.,
         y = .fitted - .se.fit,
         z = .fitted + .se.fit) %>% 
  select(x, y, z) %>% 
  distinct(x) %>% # imporant!
  arrange(x) %>% # really important!
  list.parse2()

#' The data is ready. Now make the tooltip and chart!

tooltip <- tagList(
  tags$span(style = "color:#3C3C3C", "{point.phn}"),
  tags$hr(),
  tags$img(src = '{point.brand_image_url}'),
  tags$br(),
  tags$img(src = '{point.phn_image_url}', width = "95%")
  ) %>% as.character()

highchart() %>% 
  hc_title(text = "Release date vs Heigth") %>% 
  hc_subtitle(text = "data from: http://www.gsmarena.com/") %>% 
  hc_chart(zoomType = "xy") %>% 
  hc_plotOptions(series = list(turboThreshold = 8000)) %>% 
  hc_yAxis(label = list(text = ""), min = 60, max = 170) %>%
  hc_xAxis(type = "datetime") %>% 
  hc_add_serie(data = dsphnsgalaxy, type = "scatter",
               dataLabels = list(enabled = TRUE, format = "{point.phn}"),
               name = "Galaxy S",zIndex = 1) %>%
  hc_add_serie(data = dsphnsiphones, type = "scatter",
               dataLabels = list(enabled = TRUE, format = "{point.phn}"),
               name = "IPhones",zIndex = 1) %>%
  hc_add_serie(data = dsphns, type = "scatter",
               name = "All Phones",zIndex = -5) %>%
  hc_add_serie(data = dssmooth, name = "Trend",
               type = "spline", lineWidth = 3, color = "#000",
               enableMouseTracking = FALSE,
               marker = list(enabled = FALSE)) %>%
  hc_add_serie(data = dssarea, 
               type = "arearange", fillOpacity = 0.25, color = "#c3c3c3",
               linkedTo = 'previous', name = "se",
               lineWidth = 1.5, enableMouseTracking = FALSE) %>% 
  hc_tooltip(
    useHTML = TRUE,
    backgroundColor = "white",
    borderWidth = 4,
    headerFormat = "<table style ='width:160px;height:200px' >",
    pointFormat = tooltip,
    footerFormat = "</table>"
  ) %>% 
  hc_add_theme(hc_theme_538())

#' And yep! The image and the trend are really similar 

#' ### Sessiong info
sessionInfo()
