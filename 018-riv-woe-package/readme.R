#' ---
#' title: "RIV WOE Package"
#' author: "Joshua Kunst"
#' output: 
#'  html_document: 
#'    keep_md: yes
#' ---

#+ fig.width=10, fig.height=5

# devtools::install_github("tomasgreif/woe")
library(woe)


iv.mult(german_data,"gb",TRUE)

iv.plot.summary(iv.mult(german_data,"gb",TRUE))


options(digits=2)

iv.mult(german_data,"gb", vars = c("housing","duration"))

iv.plot.woe(iv.mult(german_data, "gb", vars = c("housing","duration"), summary = FALSE))
