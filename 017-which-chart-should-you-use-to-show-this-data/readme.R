#' ---
#' title: "ggplot2 version for 'Which chart should you use to show this data?'"
#' author: "Joshua Kunst"
#' output: 
#'  html_document: 
#'    keep_md: yes
#' ---

#+ fig.width=10, fig.height=5

#' [This post](http://gravyanecdote.com/visual-analytics/which-chart-should-you-use-to-show-this-data/) show
#' different ways to plot a *simple* data. The video uses tableau software and just for fun and learn we 
#' try to replicate all the plots in the ggplot's way.

#+ message=FALSE, warning=FALSE
library("dplyr")
library("tidyr")
library("lubridate")
library("ggplot2")
library("ggthemes")

#+ echo=FALSE
library("printr")
knitr::opts_chunk$set(collapse = TRUE, comment = ">", warning = FALSE,
                      fig.width = 10, fig.height = 5,
                      fig.align = "center", dpi = 72)

#' The theme for the ggplot:
theme_set(theme_fivethirtyeight() +
theme(strip.background = element_rect(fill = "#434348"),
      strip.text = element_text(color = "#F0F0F0"),
      plot.title = element_text(face = "plain")))

update_geom_defaults("line", list(colour = "#434348", size = 1.5))
update_geom_defaults("point", list(colour = "#434348", size = 3))
update_geom_defaults("bar", list(fill = "#7cb5ec"))
update_geom_defaults("text", list(size = 4, colour = "gray30"))



#' # The data and other stuff
data <- data_frame(year = 2005:2014,
                   A = c(100, 110, 140, 170, 120, 190, 220, 250, 240, 300),
                   B = c(80, 70, 50, 100, 130, 180, 220, 160, 260, 370))

data <- data %>%
  mutate(year = ymd(paste0(year, "-01-01")))

head(data)

#' The data will be easier to plot (this is a subjetive opinion) if we *tidier it a little bit*

data2 <- data %>% gather(product, sale, -year)

head(data2)

data3 <- data2 %>%
  group_by(year) %>% 
  summarise(sale = sum(sale))


ggplot(data3) + 
  geom_line(aes(x = year, y = sale))



ggplot(data2) +
  geom_line(aes(x = year, y = sale)) + 
  facet_grid(~product)


ggplot(data2) +
  geom_line(aes(x = year, y = sale)) + 
  facet_grid(product ~ .)


ggplot(data2) +
  geom_line(aes(x = year, y = sale, color = product)) +
  scale_color_hc()


data5 <- data2 %>% 
  group_by(product) %>%
  arrange(product) %>% 
  mutate(sale = cumsum(sale))

data6 <- rbind(data2 %>% mutate(value = "sale"),
               data5 %>% mutate(value = "running sum of sales"))


ggplot(data6) + 
  geom_line(aes(x = year, y = sale, color = product)) +
  facet_grid(value ~ ., scales = "free_y") +
  scale_colour_hc() 


data4 <- data2 %>% filter(year %in% c(max(year), min(year)))

ggplot(data4) +
  geom_line(aes(x = year, y = sale, color = product)) +
  scale_colour_hc() 


ggplot(data2) +
  geom_area(aes(x = year, y = sale, fill = product)) +
  scale_fill_hc() 


ggplot(data2) +
  geom_bar(aes(x = year, y = sale, fill = product),
           stat = "identity") +
  scale_fill_hc() 


ggplot(data2) +
  geom_bar(aes(x = year, y = sale, fill = product),
           stat = "identity", position = "dodge") +
  scale_fill_hc() 
