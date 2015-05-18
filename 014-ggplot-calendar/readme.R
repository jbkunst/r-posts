# install.packages("lubridate")
library("lubridate")
rm(list = ls())

n <- 100

s <- seq(n)

values <- sin(s/pi/10) + s/n + rexp(n, rate = 2)

dates <- ymd(20121014) + days(s-1)



require("ggplot2")
require("dplyr")
require("lubridate")
require("zoo")


start <- min(dates) %>% {c(year(.), month(.), 1)} %>% paste0(collapse = "-") %>% ymd()
fnish <- max(dates) %>% {c(year(.), month(.), 1)} %>% paste0(collapse = "-") %>% ymd()
fnish <- fnish + months(1) - days(1) 

df <- left_join(data_frame(date = seq.Date(as.Date(start), as.Date(fnish), by=1)),
                data_frame(date = as.Date(dates), value = values),
                by = "date")

df <- df %>% 
  mutate(year = year(date),
         month = month(date),
         month_label = month(date, label=TRUE),
         day = day(date),
         day_label = wday(date, label=TRUE),
         day_label = factor(as.character(day_label), levels=c("Mon","Tues","Wed","Thurs","Fri","Sat","Sun"), ordered = TRUE),
         week = as.numeric(format(date,"%W")),
         monthweek = ceiling(mday(date)/7))

df <- df %>% 
  arrange(date) 

df %>% filter(year == 2015 & month == 2)

ggplot(df) +
  geom_tile(aes(day_label, monthweek, fill = value), colour = "white") +
  facet_grid(year ~ month_label, scales = "free_x") +
  scale_y_reverse() + 
  theme(legend.position = "none") +
  geom_text(aes(day_label, monthweek,label=day, size = 2), colour = "white") +
  xlab(NULL) + ylab(NULL)

df <- transform(df,
                year = year(dates),
                month = month(dates),
                monthf = month(dates, label=TRUE),
                weekday = wday(dates),
                weekdayf = wday(dates, label=TRUE),
                yearmonth = as.yearmon(dates),
                yearmonthf = factor(as.yearmon(dates)),
                week = as.numeric(format(dates,"%W")), #week(dates),
                day = day(dates),
                monthday =  mday(dates),
                monthweek = ceiling(mday(dates)/7))
df <- ddply(df,  .(yearmonthf), transform, monthweek = 1 + week - min(week))
df$weekdayf <- factor(as.character(df$weekdayf), levels=c("Mon","Tues","Wed","Thurs","Fri","Sat","Sun"), ordered = TRUE)
head(df)


df <- df[complete.cases(df),]
p <- ggplot(df, aes(weekdayf, monthweek, fill = values)) + 
  geom_tile(colour = "white") +
  facet_grid(year ~ monthf, scales = "free_x") +
  scale_y_reverse() + 
  theme(legend.position = "none") +
  geom_text(aes(label=day, size = 2), colour = "white") +
  xlab(NULL) + ylab(NULL)

print(p)