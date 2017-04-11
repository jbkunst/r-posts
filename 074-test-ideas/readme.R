rm(list = ls())
library(tidyverse)

paquetes_a_instalar <- c("gapminder", "babynames", "nasaweather", "fueleconomy")

for(p in paquetes_a_instalar) {
  message("Viendo ", p)
  if(!p %in% rownames(installed.packages())) install.packages(p)
  library(p, character.only = TRUE)
}

