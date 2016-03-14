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
library("tidyr")
library("readr")
library("stringr")
library("highcharter")
library("ggplot2")
library("viridisLite")

#'
#' I'm just reinventing the wheel (idea just for fun) from:
#' 
#'  - http://graphics.wsj.com/infectious-diseases-and-vaccines/
#'  - https://github.com/blmoore/blogR/blob/master/R/measles_incidence_heatmap.R
#'  - https://github.com/rhiever/Data-Analysis-and-Machine-Learning-Projects/blob/master/revisiting-vaccine-visualizations/Revisiting%20the%20vaccine%20visualizations.ipynb
#' 
#'
df <- read_csv("data/MEASLES_Incidence_1928-2003_20160314103501.csv", skip = 2)
names(df) <- tolower(names(df))

dfg <- df %>% 
  gather(state, count, -year, -week) %>% 
  mutate(state = str_to_title(state)) %>% 
  group_by(year, state) %>% 
  summarise(count = sum(count, na.rm = TRUE)) %>% 
  ungroup() %>% 
  arrange(year, state) %>% 
  mutate(state_id = factor(state, unique(state)),
         state_id = as.numeric(state_id))



#' ## ggplot versions
ggplot(dfg) + 
  geom_line(aes(year, count, group = 1)) + 
  facet_wrap(~state) +
  theme_minimal()

ggplot(dfg) +
  geom_tile(aes(year, state, fill = count))

#' ## highcharter versions
ds <- dfg %>% 
  select(x = year, y = state_id, value = count) %>% 
  mutate(value = ifelse(value == 0, NA, value)) %>% 
  list.parse3()

n <- 10
stops <- data.frame(q = 0:n/n,
                    c = c(substring(viridis(n), 0, 7), "#F8F8F8")) %>% 
                    
  mutate(c = rev(c)) %>%
  list.parse2()

states <- dfg %>% 
  select(state, state_id) %>% 
  distinct() %>% 
  arrange(state_id) %>% 
  .$state

fntltp <- JS("function(){
                  return this.point.x + '<br>' +
             this.series.yAxis.categories[this.point.y] + '<br>' +
             Highcharts.numberFormat(this.point.value, 2);
             ; }")



subtitletxt <-
  "The number of infected people, measured over 70-some years and 
   across all 50 states and the District of Columbia, generally declined 
   after vaccines were introduced.<br>
   The heat maps below show number of cases per 100,000 people."

hc <- highchart() %>% 
  hc_title(text = "The Impact of Vaccines", align = "left") %>% 
  hc_subtitle(text = subtitletxt, align = "left") %>% 
  hc_chart(type = "heatmap",
           style = list(
             fontFamily = "Lora"
           )) %>% 
  hc_add_series(data = ds) %>% 
  hc_colorAxis(stops = stops, type = "logarithmic") %>% 
  hc_yAxis(categories = states,
           labels = list(style = list(fontSize = '10px')),
           title = NULL,
           tickInterval = 1,
           reversed = TRUE,
           max = 51,
           offset = -10,
           gridLineWidth = 0,
           showFirstLabel = FALSE,
           showLastLabel = FALSE) %>% 
  hc_xAxis(plotLines = list(
    list(color = "#333333",
         value = 1963,
         width = 3,
         zIndex = 5,
         label = list(text = "Vaccine Intoduced",
                      verticalAlign = "top",
                      style = list(color = "#606060"),
                      textAlign = "left",
                      rotation = 0)
         )
    )
    ) %>% 
  hc_legend(layout = "vertical",
            verticalAlign = "top",
            align = "right",
            valueDecimals = 0) %>% 
  hc_tooltip(formatter = fntltp)


hc
# saveRDS(hc, file = "~/impact-vaccines.rds")
