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
knitr::opts_chunk$set(message = FALSE, warning = FALSE)
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

hcopts <- options("highcharter.options")


#' ## Text intro
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
#' Extract the main color of each brand via the image.

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
  hc_subtitle(text = "source: http://www.gsmarena.com/") %>% 
  hc_chart(zoomType = "x") %>% 
  hc_tooltip(
    useHTML = TRUE,
    backgroundColor = "white",
    borderWidth = 2,
    headerFormat = "<table style ='width:92px;height:22px' >",
    pointFormat = tooltip,
    footerFormat = "</table>"
  ) %>% 
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

#' ## Data phones
#' asdas
#+eval=FALSE
dfphones <- map_df(dfbrands$brand_url, function(burl){
  # burl <- "dell-phones-61.php" # burl <- "samsung-phones-9.php"
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
      map_df(extract_page_info)
    
  } else {
    
    dres <- extract_page_info(file.path(url, burl))
    
  }
  
  dres %>% 
    mutate(brand_url = burl)
  
})

#+eval=FALSE
dfphonesinfo <- map_df(dfphones$phn_url, function(purl){
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

#+echo=FALSE
# save(dfbrands, dfphones, dfphonesinfo, file = "checkpoint01.RData")
rm(list = ls())
load(file = "checkpoint01.RData")

#+echo=TRUE
dfphns <- dfbrands %>% 
  right_join(dfphones, by = "brand_url") %>% 
  right_join(dfphonesinfo, by = "phn_url") 

dfphns <- dfphns %>% 
  mutate(body_dimensions = str_replace(body_dimensions, "mm \\(.*\\)", ""),
         weight = as.numeric(str_extract(body_weight, "\\d+"))) %>% 
  separate(body_dimensions, into = c("height", "width", "depth"), sep = " x ",
           remove = FALSE, convert = TRUE) %>% 
  mutate(height = as.numeric(height),
         width = as.numeric(width),
         depth = as.numeric(depth))


dfphns2 <- dfphns %>% 
  mutate(screen_body_ratio = str_extract(display_size, "\\d+\\.\\d+%"),
         screen_body_ratio = str_replace(screen_body_ratio, "%", ""),
         screen_body_ratio = as.numeric(screen_body_ratio),
         screen_ppi = str_extract(display_resolution, "~\\d+"),
         screen_ppi = as.numeric(str_replace(screen_ppi, "~", "")),
         talk_time = as.numeric(str_extract(`battery_talk time`, "\\d+")),
         camera = str_extract(camera_primary, ".* MP"),
         camera = as.numeric(str_replace(camera," MP", ""))) %>% 
  mutate(year = str_extract(launch_announced, "\\d{4}"),
         month = str_extract(launch_announced, paste(month.abb, collapse = "|")),
         month = ifelse(str_detect(launch_announced, "1Q|Q1"), "Jan", month),
         month = ifelse(str_detect(launch_announced, "2Q|Q2"), "Apr", month),
         month = ifelse(str_detect(launch_announced, "3Q|Q3"), "Jul", month),
         month = ifelse(str_detect(launch_announced, "4Q|Q4"), "Oct", month),
         month = ifelse(is.na(month), "Jan", month)) %>% 
  # Cancelled Not officially announced yet 
  filter(!(is.na(year) | is.na(month) | is.na(height))) %>%
  left_join(data_frame(month = month.abb, monthn = seq(12)), by = "month") %>% 
  mutate(launch_date = paste(year, monthn, 1, sep = "-"),
         launch_date = ymd(launch_date)) %>% 
  filter(screen_body_ratio < 100)

dfbrandcolors <- dfphns2 %>% 
  select(brand_name, brand_color) %>% 
  distinct() %>% 
  {setNames(.$brand_color, .$brand_name)}


#+fig.width=9
dfphns2 %>%
  select(launch_date, brand_name, height, 
         depth, screen_body_ratio, camera) %>% 
  gather(key, value, -launch_date, -brand_name) %>% 
  ggplot(aes(launch_date, value)) + 
  geom_point(aes(color = brand_name), alpha = 0.25) +
  geom_smooth(color = "black", size = 1.2, alpha = 0.5) + 
  scale_color_manual(values = dfbrandcolors) +
  facet_wrap(~key, scales = "free") + 
  ggtitle("Release date vs some characteristics") + 
  theme_fivethirtyeight() +
  theme(legend.position = "none")


dsphns2 <- dfphns2 %>% 
  select(launch_date, height, brand_name, brand_color, 
         brand_image_url,
         phn, phn_image_url) %>% 
  mutate(x = datetime_to_timestamp(launch_date),
         y = height,
         color = brand_color) %>% 
  list.parse3() %>% 
  map(function(x){
    x$color <- paste("rgba(", paste0(t(col2rgb(x$color)), collapse = ", "), ",", 0.2, ")")
    x
  })

dsphns2iphones <- dsphns2[map_lgl(dsphns2, function(x) str_detect(x$phn, "iPhone") )]

dsphns2galaxy <- dsphns2[map_lgl(dsphns2, function(x) str_detect(x$phn, "Galaxy S") )]
  
fit <- loess(height ~ datetime_to_timestamp(launch_date),
             data = dfphns2) %>% 
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

tooltip <- tagList(
  tags$span(style = "color:#3C3C3C", "{point.phn}"),
  tags$hr(),
  tags$img(src = '{point.brand_image_url}'),
  tags$br(),
  tags$img(src = '{point.phn_image_url}', width = "95%")
  ) %>% as.character()

highchart() %>% 
  hc_title(text = "Release date vs Heigth") %>% 
  hc_subtitle(text = "Woth the Local Polynomial Regression Fitting") %>% 
  hc_chart(zoomType = "xy") %>% 
  hc_plotOptions(series = list(turboThreshold = 6000)) %>% 
  hc_yAxis(label = list(text = ""), min = 60, max = 170) %>%
  hc_xAxis(type = "datetime") %>% 
  hc_add_serie(data = dsphns2, type = "scatter",
               name = "All Phones",zIndex = -3) %>%
  hc_add_serie(data = dsphns2galaxy, type = "scatter",
               dataLabels = list(enabled = TRUE, format = "{point.phn}"),
               name = "Galaxy S",zIndex = -3) %>%
  hc_add_serie(data = dsphns2iphones, type = "scatter",
               dataLabels = list(enabled = TRUE, format = "{point.phn}"),
               name = "IPhones",zIndex = -3) %>%
  hc_add_serie(data = dssmooth, name = "LOESS",
               type = "spline", lineWidth = 3, color = "#000",
               enableMouseTracking = FALSE,
               marker = list(enabled = FALSE)) %>%
  hc_add_serie(data = dssarea, 
               type = "arearange", fillOpacity = 0.25, color = "#c3c3c3",
               linkedTo = 'previous',
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

#' ## Sessiong info
sessionInfo()
