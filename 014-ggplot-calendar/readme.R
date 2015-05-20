#' ---
#' title: "Calendar"
#' author: "Joshua Kunst"
#' output: 
#'  html_document: 
#'    keep_md: yes
#' ---

#+ fig.width=10, fig.height=5

library("lubridate")
library("ggplot2")
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("zoo"))
library("lubridate")


rm(list = ls())

set.seed(2015)
n <- 980
s <- seq(n)
values <- sin(s/pi/5) + 1.5*s/n + rexp(n, rate = 2)
dates <- ymd(20121014) + days(s - 1)

df <- data_frame(values, dates)

gg <- ggplot(df) + geom_line(aes(dates, values))
gg

start <- min(dates) %>% {c(year(.), month(.), 1)} %>% paste0(collapse = "-") %>% ymd()
fnish <- max(dates) %>% {c(year(.), month(.), 1)} %>% paste0(collapse = "-") %>% ymd()
fnish <- fnish + months(1) - days(1) 

df <- left_join(data_frame(date = seq.Date(as.Date(start), as.Date(fnish), by=1)),
                data_frame(date = as.Date(dates), value = values),
                by = "date")

df <- df %>% 
  mutate(year = year(date),
         month = month(date),
         month_label = month(date, label = TRUE),
         day = day(date),
         day_label = wday(date, label = TRUE),
         day_label = factor(as.character(day_label),
                            levels = c("Mon","Tues","Wed","Thurs","Fri","Sat","Sun"), ordered = TRUE),
         week = as.numeric(format(date,"%W")))

df_mw <- df %>% 
  group_by(year, month) %>% 
  summarise(minweek = min(week)) %>% 
  ungroup()

df <- df %>%
  left_join(df_mw, by = c("year", "month")) %>% 
  mutate(monthweek = week - minweek + 1)

df <- df %>% 
  arrange(date) %>% 
  filter(!is.na(value))

p <- ggplot(df) +
  geom_tile(aes(day_label, monthweek, fill = value), colour = "white") +
  facet_grid(year ~ month_label, scales = "free_x") +
  scale_y_reverse() + 
  theme(legend.position = "none") +
  geom_text(aes(day_label, monthweek, label = day, size = 2), colour = "white") +
  xlab(NULL) + ylab(NULL)

p

sessionInfo()
