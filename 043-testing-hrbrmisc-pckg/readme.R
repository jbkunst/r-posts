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
knitr::opts_chunk$set(message = FALSE, warning = FALSE,
                      fig.showtext = TRUE, dev = "CairoPNG")

library("scales")
library("ggplot2")
library("grid")
library("hrbrmisc") # devtools::install_github("hrbrmstr/hrbrmisc")
library("tidyr")
library("showtext")

font.add.google("Open Sans Condensed",  regular.wt = 300, bold.wt = 700)
font.add.google("Lato")

showtext.auto()


theme_hrbrmstr <- function(base_family = "Open Sans Condensed",
                           base_size = 11,
                           strip_text_family = base_family,
                           strip_text_size = 12,
                           plot_title_family = "Open Sans Condensed",
                           plot_title_size = 18,
                           plot_title_margin = 16,
                           axis_title_family = "Open Sans Condensed",
                           axis_title_size = 9,
                           axis_title_just = "rt",
                           grid = TRUE,
                           axis = FALSE,
                           ticks = FALSE) {
  
  ret <- theme_minimal(base_family=base_family, base_size=base_size)
  
  ret <- ret + theme(legend.background=element_blank())
  ret <- ret + theme(legend.key=element_blank())
  
  if (inherits(grid, "character") | grid == TRUE) {
    
    ret <- ret + theme(panel.grid=element_line(color="#2b2b2bdd", size=0.10))
    ret <- ret + theme(panel.grid.major=element_line(color="#2b2b2b99", size=0.10))
    ret <- ret + theme(panel.grid.minor=element_line(color="#2b2b2b99", size=0.05))
    
    if (inherits(grid, "character")) {
      if (regexpr("X", grid)[1] < 0) ret <- ret + theme(panel.grid.major.x=element_blank())
      if (regexpr("Y", grid)[1] < 0) ret <- ret + theme(panel.grid.major.y=element_blank())
      if (regexpr("x", grid)[1] < 0) ret <- ret + theme(panel.grid.minor.x=element_blank())
      if (regexpr("y", grid)[1] < 0) ret <- ret + theme(panel.grid.minor.y=element_blank())
    }
    
  } else {
    ret <- ret + theme(panel.grid=element_blank())
  }
  
  if (inherits(axis, "character") | axis == TRUE) {
    ret <- ret + theme(axis.line=element_line(color="#2b2b2b", size=0.15))
    if (inherits(axis, "character")) {
      if (regexpr("X", axis)[1] < 0) ret <- ret + theme(axis.line.x=element_blank())
      if (regexpr("Y", axis)[1] < 0) ret <- ret + theme(axis.line.y=element_blank())
    }
  } else {
    ret <- ret + theme(axis.line=element_blank())
  }
  
  if (!ticks) ret <- ret + theme(axis.ticks = element_blank())
  
  xj <- switch(tolower(substr(axis_title_just, 1, 1)), b=0, l=0, m=0.5, c=0.5, r=1, t=1)
  yj <- switch(tolower(substr(axis_title_just, 2, 2)), b=0, l=0, m=0.5, c=0.5, r=1, t=1)
  
  ret <- ret + theme(axis.title.x=element_text(hjust=xj, size=axis_title_size, family=axis_title_family))
  ret <- ret + theme(axis.title.y=element_text(hjust=yj, size=axis_title_size, family=axis_title_family))
  ret <- ret + theme(strip.text=element_text(hjust=0, size=strip_text_size, family=strip_text_family))
  ret <- ret + theme(plot.title=element_text(hjust=0, size=plot_title_size, face = "bold", margin=margin(b=plot_title_margin), family=plot_title_family))
  ret <- ret + theme(strip.background=element_rect(fill="#858585", color=NA))
  ret <- ret + theme(strip.text=element_text(size=12, color="white", hjust=0.1))
  
  ret
  
}

theme_set(theme_hrbrmstr(plot_title_family = "Open Sans Condensed"))

#'
#'

data("diamonds")
head(diamonds)

tt <- "Plot Title"
st <- "This is a more detailed text"
src <- "Where the data comes from"
ggplot(diamonds) +
  labs(title = tt, subtite = st, source = src) + 
  geom_point(aes(carat, price, color = clarity)) +
  facet_wrap(~cut)
