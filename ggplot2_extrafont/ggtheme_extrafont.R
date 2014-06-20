#### load libraries ####
rm(list=ls())
options(stringsAsFactors=FALSE, width=16, height=9)
library(extrafont)
library(ggplot2)
library(scales)

#### data, functions, colors ####
data(diamonds)
data <- subset(diamonds, color %in% c("E", "F", "G") & cut %in% c("Ideal", "Premium", "Good"))
data$indicator <- ifelse(data$color %in% c("F"), 1, 0)
colors_hc <- c("#7CB5EC", "#313131", "#F7A35C", "#90EE7E", "#7798BF", "#AAEEEE", "#FF0066", 
               "#EEAAEE", "#55BF3B", "#DF5353", "#7798BF", "#AAEEEE")

theme_hc <- function(){
  theme(
    text                = element_text(family="Open Sans", size = 11),
    title               = element_text(hjust=0), 
    axis.title.x        = element_text(hjust=.5),
    axis.title.y        = element_text(hjust=.5),
    panel.grid.major.y  = element_line(color='gray', size = .3),
    panel.grid.minor.y  = element_blank(),
    panel.grid.major.x  = element_blank(),
    panel.grid.minor.x  = element_blank(),
    panel.border        = element_blank(),
    panel.background    = element_blank()
  )
}

#### plots ####
p1 <- ggplot(data) +  geom_bar(aes(cut), width =.4, fill = colors_hc[1]) +
  ggtitle("Cantidad de Elementos segun Corte") +  xlab("Corte") + ylab("Cantidad") +
  scale_y_continuous(labels = function (x){ format(x, big.mark = ".", scientific = FALSE, trim = TRUE) }) +
  theme_hc()
p1

p2 <- ggplot(data) + geom_density(aes(price, fill=cut, color=cut), alpha=I(0.5)) +
  ggtitle("Densidad de Precio según Color") +  xlab("Corte") + ylab("Densidad") +
  scale_y_continuous(labels = percent) +
  scale_fill_manual(values=colors_hc) +
  scale_x_log10() +
  theme_hc()
p2

p3 <- ggplot(data) + geom_bar(aes(color, fill=cut), position="dodge", width=.7) +
  ggtitle("Cantidad de Elementos segun Corte y Color") +  xlab("Corte") + ylab("Cantidad") +
  scale_y_continuous(labels = function (x){ format(x, big.mark = ".", scientific = FALSE, trim = TRUE) }) +
  scale_fill_manual(values=colors_hc) +
  theme_hc()
p3

p4 <- ggplot(data) +
  geom_bar(aes(cut, ..count../sum(..count..)), fill = colors_hc[1], width=.4) +
  ggtitle("Cantidad de Elementos segun Corte") +  xlab("Corte") + ylab("Cantidad") +
  stat_summary(aes(x=cut,y=indicator), fun.y=mean, colour="red", geom="point") +
  stat_summary(aes(x=cut,y=indicator, group = 1), fun.y=mean, colour="red", geom="line") +
  scale_y_continuous(labels = percent) +
  theme_hc()
p4

p5 <- ggplot(data[sample(nrow(data), size=1000),]) +
  geom_point(aes(carat, price, color=cut)) +
  ggtitle("Carat versus Precio según Corte") +  xlab("Carat") + ylab("Precio") +
  scale_color_manual(values=colors_hc) +
  theme_hc()
p5


pdf(file="~/Downloads/plots.pdf", width=16/1.33, height=9/1.33)
p1
p2
p3
p4
p5
dev.off()


