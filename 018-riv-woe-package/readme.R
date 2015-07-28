#' ---
#' title: "RIV WOE Package"
#' author: "Joshua Kunst"
#' output: 
#'  html_document: 
#'    keep_md: yes
#' ---

#+ fig.width=10, fig.height=5
#+ echo=FALSE
# library("printr")
library("knitr")
options(digits = 3, knitr.table.format = "markdown")
knitr::opts_chunk$set(collapse = TRUE, comment = ">", warning = FALSE,
                      fig.width = 10, fig.height = 6,
                      fig.align = "center", dpi = 72)

#' # Introducction
#' 
#' - woe is data frame oriented, the functions have always a data frame argument.
#' - riskr is variable oriented, the functions have always a variable (non dataframe) argument.

#' # Load packages and data
# devtools::install_github("tomasgreif/woe")
library("woe")
library("riskr")

data("german_data")

#' Required for riskr
german_data$gb2 <- ifelse(german_data$gb == "good", 1, 0)

#' # Bivariate analysis:
#' 
#' ## 1 variable case

lvls <- names(sort(table(german_data$purpose)))
german_data$purpose <- factor(as.character(german_data$purpose), levels = lvls)

#' ### woe 
iv.str(german_data,"purpose","gb", verbose = FALSE)
iv.plot.woe(iv.mult(german_data,"gb",vars = c("purpose"), summary = FALSE))

#' ### riskr
bt(german_data$purpose, german_data$gb2)

plot_ba(german_data$purpose, german_data$gb2) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0))
  

#' ## data frame case
#' 
#' ### woe
iv.mult(german_data, "gb", vars =  c("purpose", "ca_status", "credit_history", "status_sex"),
        verbose = FALSE)

#' ### riskr
library("tidyr")
library("dplyr")

german_data %>% 
  tbl_df() %>% 
  select(gb2, purpose, ca_status, credit_history, status_sex) %>% 
  gather(variable, value, -gb2) %>% 
  group_by(variable) %>% 
  do({ bt(.$value, .$gb2)  })


# iv.num(german_data,"duration","gb")
# iv.mult(german_data,"gb",TRUE, verbose = TRUE)
# iv.plot.summary(iv.mult(german_data,"gb",TRUE))
# head(german_data$credit_amount)
# iv.binning.simple(german_data,"credit_amount")
