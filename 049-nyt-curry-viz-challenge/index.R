rm(list = ls())
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("purrr"))
suppressPackageStartupMessages(library("readr"))
suppressPackageStartupMessages(library("highcharter"))

urldata <-  "https://static01.nyt.com/newsgraphics/2016/04/14/curry-threes/b061916ea9b7f0b553edad19221d12a423ec14ca/data-tidy.csv"


# raw tidy data
df <- read_csv(urldata)

# data for each line
data <- df %>% 
  select(-player, -pname, -year) %>% 
  as.list() %>% 
  transpose() %>% 
  map(unlist) %>% 
  map(as.vector) %>% 
  map(function(x) c(NA, x)) %>% 
  data_frame(data = .)

# data series
dss <- df %>% 
  select(name = pname, year) %>% 
  bind_cols(data) %>% 
  mutate(color = colorize_vector(year),
         color = hex_to_rgba(color, 0.5),
         original = color) %>% 
  sample_n(100) %>% # SADLY THERE ARE PERFORMANCE ISSUES FOR HIGHCHARTS
  list.parse2()
  

ovropts <- JS("function(){ this.update({color: 'black', shadow: {width: 7, opacity: 0.5, color: 'gray'} })}")
outopts <- JS("function(){ this.update({color: this.userOptions.original, shadow: false })}")

highchart() %>%
# highchart() %>%   
  hc_add_series_list(dss) %>% # data
  hc_yAxis(
    opposite = TRUE
  ) %>% 
  hc_xAxis(
    showFirstLabel = FALSE,
    labels = list(format = "{value}th", useHTML = TRUE)
  ) %>% 
  hc_colorAxis(
    stops = color_stops(),
    min = min(df$year),
    max = max(df$year)
    ) %>% 
  hc_tooltip(
    positioner = JS("function(){ return {x: 10, y: 10} } ")
  ) %>% 
  hc_plotOptions(             # plot.. options?!
    series = list(
      showInLegend = FALSE,
      step = TRUE,
      marker = list(enabled = FALSE),
      events = list(
        mouseOver = ovropts,
        mouseOut = outopts
      )
    )
  )
  
