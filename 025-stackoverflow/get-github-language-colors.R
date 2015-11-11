library("httr")
dfcols <- "https://raw.githubusercontent.com/doda/github-language-colors/master/colors.json" %>% 
  GET() %>%
  content() %>% 
  jsonlite::fromJSON() %>% 
  { data_frame(language = tolower(names(.)),
               color = unlist(.)) }

dfcols

