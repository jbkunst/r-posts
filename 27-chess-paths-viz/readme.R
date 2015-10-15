#' ---
#' title: "Chess movements"
#' author: "Joshua Kunst"
#' output:
#'  html_document:
#'    toc: true
#'    keep_md: yes
#' ---

library("rchess")
library("dplyr")
library("readr")

df <- read_csv("data/chess_magnus.csv.gz")
df
