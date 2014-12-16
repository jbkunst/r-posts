# I need to modify this 

Take from [there](https://gist.github.com/dsparks/3980277) and modify here!



```r
library(dplyr)
library(jpeg)
library(reshape)
library(ggplot2)
library(mclust)

img.path <- "Tulip-Farm-Skagit.jpg"

readImage <- readJPEG(img.path)

longImage <- melt(readImage)
head(longImage)
```

```
##   X1 X2 X3     value
## 1  1  1  1 0.6039216
## 2  2  1  1 0.6039216
## 3  3  1  1 0.6078431
## 4  4  1  1 0.6078431
## 5  5  1  1 0.6117647
## 6  6  1  1 0.6117647
```

```r
rgbImage <- reshape(longImage, timevar = "X3", idvar = c("X1", "X2"), direction = "wide")
rgbImage <- rgbImage %>%
  mutate(X1 = -X1,
         rgb = rgb(value.1, value.2, value.3))

head(rgbImage)
```

```
##   X1 X2   value.1   value.2   value.3     rgb
## 1 -1  1 0.6039216 0.7529412 0.8980392 #9AC0E5
## 2 -2  1 0.6039216 0.7529412 0.8980392 #9AC0E5
## 3 -3  1 0.6078431 0.7568627 0.9019608 #9BC1E6
## 4 -4  1 0.6078431 0.7568627 0.9019608 #9BC1E6
## 5 -5  1 0.6117647 0.7607843 0.9058824 #9CC2E7
## 6 -6  1 0.6117647 0.7607843 0.9058824 #9CC2E7
```

```r
plot(rgbImage$X2, rgbImage$X1, col = rgbImage$rgb, asp = 1, pch = ".")
```

![](Readme_files/figure-html/unnamed-chunk-1-1.png) 

```r
# Cluster in color space:
kColors <- 7  # Number of palette colors
kMeans <- kmeans(rgbImage %>% select(value.1, value.2, value.3), centers = kColors)


rgbImage <- rgbImage %>% mutate(rbgApp = rgb(kMeans$centers[kMeans$cluster, ]))

head(rgbImage)
```

```
##   X1 X2   value.1   value.2   value.3     rgb  rbgApp
## 1 -1  1 0.6039216 0.7529412 0.8980392 #9AC0E5 #B4D0DE
## 2 -2  1 0.6039216 0.7529412 0.8980392 #9AC0E5 #B4D0DE
## 3 -3  1 0.6078431 0.7568627 0.9019608 #9BC1E6 #B4D0DE
## 4 -4  1 0.6078431 0.7568627 0.9019608 #9BC1E6 #B4D0DE
## 5 -5  1 0.6117647 0.7607843 0.9058824 #9CC2E7 #B4D0DE
## 6 -6  1 0.6117647 0.7607843 0.9058824 #9CC2E7 #B4D0DE
```

```r
rgbImage_aux <- rgbImage %>%
  group_by(rbgApp) %>%
  summarise(n=n()) %>%
  arrange(n) %>%
  mutate(rbgApp = factor(rbgApp, levels = rbgApp))

rgbImage_aux
```

```
## Source: local data frame [7 x 2]
## 
##    rbgApp     n
## 1 #688C95 10399
## 2 #FAD110 25851
## 3 #ED7835 28831
## 4 #2B2E1B 37608
## 5 #6D6E3E 38853
## 6 #B4D0DE 47270
## 7 #D82D31 65338
```

```r
ggplot(rgbImage_aux) +
  geom_bar(aes(x=rbgApp, y=n, fill=rbgApp),  stat="identity") +
  scale_fill_manual(values=as.character(rgbImage_aux$rbgApp)) + 
  coord_flip() + theme_bw()
```

![](Readme_files/figure-html/unnamed-chunk-1-2.png) 

```r
plot(rgbImage$X2, rgbImage$X1, col = rgbImage$rbgApp, asp = 1, pch = ".")
```

![](Readme_files/figure-html/unnamed-chunk-1-3.png) 

```r
plot(rgbImage$X2, rgbImage$X1, col = rgbImage$rgb, asp = 1, pch = ".")
```

![](Readme_files/figure-html/unnamed-chunk-1-4.png) 
