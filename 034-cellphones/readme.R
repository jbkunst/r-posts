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

# https://github.com/joelcarlson/RImagePalette

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

n <- 10
highchart() %>% 
  hc_title(text = "Phone models by Brand") %>% 
  hc_subtitle(text = "source: http://www.gsmarena.com/") %>% 
  hc_chart(zoomType = "x") %>% 
  hc_xAxis(categories = dfbrands$bran_name, max = n - 1) %>% 
  hc_add_series(data = dfbrands$brand_n_phn,
                name = "phones models", color = "#A3A3A3",
                type = "column")

#' ## Data phones

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
