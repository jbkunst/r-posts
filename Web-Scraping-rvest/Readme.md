# rvest



```r
# devtools::install_github("hadley/rvest")
library(rvest)
lego_movie <- html("http://www.imdb.com/title/tt1490017/")
```


```r
lego_movie %>% 
  html_node("strong span") %>%
  html_text() %>%
  as.numeric()
```

```
## [1] 7.9
```


```r
lego_movie %>%
  html_nodes("#titleCast .itemprop span") %>%
  html_text()
```

```
##  [1] "Will Arnett"     "Elizabeth Banks" "Craig Berry"    
##  [4] "Alison Brie"     "David Burrows"   "Anthony Daniels"
##  [7] "Charlie Day"     "Amanda Farinos"  "Keith Ferguson" 
## [10] "Will Ferrell"    "Will Forte"      "Dave Franco"    
## [13] "Morgan Freeman"  "Todd Hansen"     "Jonah Hill"
```


```r
lego_movie %>%
  html_nodes("table") %>%
  .[[3]] %>%
  html_table()
```

```
##                                              X 1            NA
## 1 this movie is very very deep and philosophical   mrdoctor524
## 2 This got an 8.0 and Wizard of Oz got an 8.1...  marr-justinm
## 3                         Discouraging Building?       Laestig
## 4                              LEGO - the plural      neil-476
## 5                                 Academy Awards   browncoatjw
## 6                    what was the funniest part? actionjacksin
```
