#' ---
#' title: ""
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

#+ echo=FALSE, message=FALSE, warning=FALSE
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE, fig.cap = "",
                      fig.showtext = TRUE, dev = "CairoPNG")



URL <- "http://www.bls.gov/lau/staadata.txt"
download.file(URL, destfile = "./data/UN.csv", method="curl")
# The file had too many extra carachters. I manually removed them, and
# put them into Unemployment.csv

## Unemployment rate in the range (1976 to 2014) 
unem = read.csv("./data/Unemployment.csv", sep=" ",head=TRUE)     
rownames(unem)<-unem$State
colnames(unem) <- sub("X", "\\2", colnames(unem))
unem[1]<-NULL

# We dont have the average so let's add a row with the Federal average
unem["Federal" ,] <- colSums(unem)/nrow(unem)

## We have Federal + 49 states and dates from (1976 to 2014). 
# Let's select common states and years 
states<-rownames(unem[rownames(unem) %in% rownames(mwage), ])
years<-colnames(mwage[! colnames(mwage) %in% colnames(unem), ])
unem<-unem[states,years]

# Now let's remove the extra states from Minimum wage. 
states2<-rownames(mwage[rownames(mwage) %in% rownames(unem), ])
mwage<-mwage[states2,] 

#Let's reorder mwage with the same order as unem (states alph. and Federal last)
mwage<-mwage[match(rownames(unem),rownames(mwage)),]


#' ---
#' output:
#'  html_document:
#'    keep_md: true
#' ---
#+ message=FALSE
library(ggplot2)
library(hrbrmisc)
library(readxl)
library(tidyverse)

# Use official BLS annual unemployment data vs manually calculating the average
# Source: https://data.bls.gov/timeseries/LNU04000000?years_option=all_years&periods_option=specific_periods&periods=Annual+Data
read_excel("~/Data/annual.xlsx", skip=10) %>%
  mutate(Year=as.character(as.integer(Year)), Annual=Annual/100) -> annual_rate


# The data source Andy Kriebel curated for you/us: https://1drv.ms/x/s!AhZVJtXF2-tD1UVEK7gYn2vN5Hxn #ty Andy!
read_excel("~/Data/staadata.xlsx") %>%
  left_join(annual_rate) %>%
  filter(State != "District of Columbia") %>%
  mutate(
    year = as.Date(sprintf("%s-01-01", Year)),
    pct = (Unemployed / `Civilian Labor Force Population`),
    us_diff = -(Annual-pct),
    col = ifelse(us_diff<0,
                 "Better than U.S. National Average",
                 "Worse than U.S. National Average")
  ) -> df

credits <- "Notes: Excludes the District of Columbia. 2016 figure represents October rate.\nData: U.S. Bureau of Labor Statistics <https://www.bls.gov/lau/staadata.txt>\nCredit: Matt Stiles/The Daily Viz <thedailyviz.com>"

#+ state_of_us, fig.height=21.5, fig.width=8.75, fig.retina=2
ggplot(df, aes(year, us_diff, group=State)) +
  geom_segment(aes(xend=year, yend=0, color=col), size=0.5) +
  scale_x_date(expand=c(0,0), date_labels="'%y") +
  scale_y_continuous(expand=c(0,0), label=scales::percent, limit=c(-0.09, 0.09)) +
  scale_color_manual(name=NULL, expand=c(0,0),
                     values=c(`Better than U.S. National Average`="#4575b4",
                              `Worse than U.S. National Average`="#d73027")) +
  facet_wrap(~State, ncol=5, scales="free_x") +
  labs(x=NULL, y=NULL, title="The State of U.S. Jobs: 1976-2016",
       subtitle="Percentage points below or above the national unemployment rate, by state. Negative values represent unemployment rates\nthat were lower - or better, from a jobs perspective - than the national rate.",
       caption=credits) +
  theme_hrbrmstr_msc(grid="Y", strip_text_size=9) +
  theme(panel.background=element_rect(color="#00000000", fill="#f0f0f055")) +
  theme(panel.spacing=unit(0.5, "lines")) +
  theme(plot.subtitle=element_text(family="MuseoSansCond-300")) +
  theme(legend.position="top")