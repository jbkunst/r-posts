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
library("printr")


#' ## Text intro
url <- "http://www.gsmarena.com"

tabletd <- file.path(url, "makers.php3") %>% 
  read_html() %>% 
  html_nodes("table td")



dfbrands <- data_frame(
  td1 = tabletd[seq(1, length(tabletd), 2)],
  td2 = tabletd[seq(2, length(tabletd), 2)]
  ) %>%  
  mutate(bran_name = html_node(td2, "a") %>% html_text(),
         brand_url = html_node(td1, "a") %>% html_attr("href"),
         brand_image_url = html_node(td1, "img") %>% html_attr("src"),
         brand_n_phn = str_extract(bran_name, "\\(\\d+\\)"),
         brand_n_phn = str_replace_all(brand_n_phn, "\\(|\\)", ""),
         brand_n_phn = as.numeric(brand_n_phn),
         bran_name = str_replace_all(bran_name, " phones \\(\\d+\\)", "")) %>% 
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

n <- 50

dsbrands <- dfbrands %>% 
  head(n) %>% 
  mutate(x = bran_name,
         y = brand_n_phn) %>% 
  list.parse3()


highchart() %>% 
  hc_title(text = "Phone models by Brand") %>% 
  hc_subtitle(text = "source: http://www.gsmarena.com/") %>% 
  hc_chart(zoomType = "x") %>% 
  hc_tooltip(
    useHTML = TRUE,
    backgroundColor = "white",
    borderWidth = 2,
    headerFormat = "<table style ='width:92px;height:22px' >",
    pointFormat = paste("<span style='float:right;color:#3C3C3C'>{point.y} models</span><br>",
                        "<img src='{point.brand_image_url}'>"),
    footerFormat = "</table>"
  ) %>% 
  hc_xAxis(categories = map_chr(dsbrands, function(x) x$bran_name)) %>% 
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
message("Data phones *************")
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

message("Data phones info  *************")
dfphonesinfo <- map_df(dfphones$phn_url, function(purl){
  # purl <- sample(dfphones$phn_url, size = 1)
  # purl <- "samsung_galaxy_s5_mini-6252.php"
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

message("save *************")
# save(dfbrands, dfphones, dfphonesinfo, file = "checkpoint01.RData")
# rm(list = ls())
# load(file = "checkpoint01.RData")

dfphns <- dfbrands %>% 
  right_join(dfphones) %>% 
  right_join(dfphonesinfo)

rm(dfbrands, dfphones, dfphonesinfo)

dfphns2 <- dfphns %>% 
  mutate(screen_body_ratio = str_extract(display_size, "\\d+\\.\\d+%"),
         screen_body_ratio = str_replace(screen_body_ratio, "%", ""),
         screen_body_ratio = as.numeric(screen_body_ratio)) %>% 
  select(bran_name, phn, launch_status, launch_announced,
         display_size, screen_body_ratio) %>% 
  mutate(year = str_extract(launch_announced, "\\d{4}"),
         month = str_extract(launch_announced, paste(month.abb, collapse = "|")),
         month = ifelse(str_detect(launch_announced, "1Q|Q1"), "Jan", month),
         month = ifelse(str_detect(launch_announced, "2Q|Q2"), "Apr", month),
         month = ifelse(str_detect(launch_announced, "3Q|Q3"), "Jul", month),
         month = ifelse(str_detect(launch_announced, "4Q|Q4"), "Oct", month),
         month = ifelse(is.na(month), "Jan", month)) %>% 
  # Cancelled Not officially announced yet 
  filter(!(is.na(year) | is.na(month))) %>%
  left_join(data_frame(month = month.abb, monthn = seq(12))) %>% 
  mutate(launch_date = paste(year, monthn, 1, sep = "-"),
         launch_date = ymd(launch_date)) %>% 
  filter(screen_body_ratio < 100)

ggplot(dfphns2, aes(launch_date, screen_body_ratio)) +
  geom_point(aes(color = bran_name), size = 2, alpha = 0.4) +
  geom_smooth()
