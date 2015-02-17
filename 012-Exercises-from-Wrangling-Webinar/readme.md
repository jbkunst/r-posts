# Tidyr



```r
# devtools::install_github("rstudio/EDAWR")
library(EDAWR)
suppressPackageStartupMessages(library(magrittr))
```

```
## Warning: package 'magrittr' was built under R version 3.1.2
```

```r
suppressPackageStartupMessages(library(tidyr))
```

```
## Warning: package 'tidyr' was built under R version 3.1.2
```

```r
# 1. Each variable is saved in its own column.
# 2. Each observation is saved in its own row.
# 3. Each "type" of observation stored 3 in a single table

########
# Storms
data(storms)
storms
```

```
##     storm wind pressure       date
## 1 Alberto  110     1007 2000-08-03
## 2    Alex   45     1009 1998-07-27
## 3 Allison   65     1005 1995-06-03
## 4     Ana   40     1013 1997-06-30
## 5  Arlene   50     1010 1999-06-11
## 6  Arthur   45     1010 1996-06-17
```

```r
storms %>%
  separate(date, c("year", "month", "day"), sep = "-")
```

```
## Source: local data frame [6 x 6]
## 
##     storm wind pressure year month day
## 1 Alberto  110     1007 2000    08  03
## 2    Alex   45     1009 1998    07  27
## 3 Allison   65     1005 1995    06  03
## 4     Ana   40     1013 1997    06  30
## 5  Arlene   50     1010 1999    06  11
## 6  Arthur   45     1010 1996    06  17
```

```r
########
# Cases
data(cases)
cases
```

```
##   country  2011  2012  2013
## 1      FR  7000  6900  7000
## 2      DE  5800  6000  6200
## 3      US 15000 14000 13000
```

```r
cases %>%
  gather(year, number, -country)
```

```
##   country year number
## 1      FR 2011   7000
## 2      DE 2011   5800
## 3      US 2011  15000
## 4      FR 2012   6900
## 5      DE 2012   6000
## 6      US 2012  14000
## 7      FR 2013   7000
## 8      DE 2013   6200
## 9      US 2013  13000
```

```r
########
# Pollution
data(pollution)
pollution
```

```
##       city  size amount
## 1 New York large     23
## 2 New York small     14
## 3   London large     22
## 4   London small     16
## 5  Beijing large    121
## 6  Beijing small     56
```

```r
pollution %>%
  spread(size, amount)
```

```
##       city large small
## 1  Beijing   121    56
## 2   London    22    16
## 3 New York    23    14
```

