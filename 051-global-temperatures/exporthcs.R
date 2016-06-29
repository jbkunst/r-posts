rm(list = ls())
source("readme.R")


export_hc(hc1, "hc1.js")
export_hc(hc11, "hc11.js")
export_hc(hc2, "hc2.js")
export_hc(hc3, "hc3.js")
export_hc(hc4, "hc4.js")
export_hc(hc5, "hc5.js")

thls <- list(
  chart  = list(
    style = list(fontFamily = "Roboto Condensed"),
    backgroundColor = "#323331"
  ),
  yAxis = list(
    gridLineColor = "#B71C1C",
    labels = list(format = "{value} C", useHTML = TRUE)
  ),
  plotOptions = list(series = list(showInLegend = FALSE))
)

jsn <- jsonlite::toJSON(thls, pretty = TRUE, auto_unbox = TRUE)
cat(jsn)

writeLines(jsn, "thm.js")
