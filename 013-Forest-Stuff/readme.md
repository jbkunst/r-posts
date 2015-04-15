# Party!
Monday, April 13, 2015  

## Partiendo con la Party!

Ok don Mario! El ejemplo conversado. Cargamos librería `party`. Prefiero esta antes que `rpart` por un asunto de que el `plot` es mejor para visualizar el árbol.


```r
suppressPackageStartupMessages(library(party))
```

Cargamos datos de ejemplo. El bien conocido `iris`:


```
##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
## 1          5.1         3.5          1.4         0.2  setosa
## 2          4.9         3.0          1.4         0.2  setosa
## 3          4.7         3.2          1.3         0.2  setosa
## 4          4.6         3.1          1.5         0.2  setosa
## 5          5.0         3.6          1.4         0.2  setosa
## 6          5.4         3.9          1.7         0.4  setosa
```

```
## 'data.frame':	150 obs. of  5 variables:
##  $ Sepal.Length: num  5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
##  $ Sepal.Width : num  3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
##  $ Petal.Length: num  1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
##  $ Petal.Width : num  0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
##  $ Species     : Factor w/ 3 levels "setosa","versicolor",..: 1 1 1 1 1 1 1 1 1 1 ...
```

Un **arbolito simple** y lo miramos:


```r
tri <- ctree(Species ~ ., data = iris)

plot(tri)
```

![](readme_files/figure-html/unnamed-chunk-3-1.png) 

Creamos una data **nueva** y vemos la prediccion y el nodo al cual pertenece.


```r
niudata <- data.frame(Sepal.Length = 1,
                      Sepal.Width = 2,
                      Petal.Length  = 2,
                      Petal.Width = 1)
str(niudata)
```

```
## 'data.frame':	1 obs. of  4 variables:
##  $ Sepal.Length: num 1
##  $ Sepal.Width : num 2
##  $ Petal.Length: num 2
##  $ Petal.Width : num 1
```

```r
predict(tri, niudata, type ="prob")
```

```
## [[1]]
## [1] 0.00000000 0.97826087 0.02173913
```

```r
where(tri, niudata)
```

```
## [1] 5
```
![alt text](http://cienciaxxi.es/blog/wp-content/uploads/2011/12/juan-tamariz4.jpg)

chantatachan

## Ahora, lo que se necesita

Librerías que necesitamos:


```r
library("rpart")
library("caret")  
library("rattle")
library("rpart.plot")
library("dplyr")
```

Obtenemos datos y creamos un árbol y graficamos por si acaso:


```r
data(segmentationData)
segmentationData <- segmentationData[,-c(1,2)]

tree <- rpart(Class ~ ., data=segmentationData, control = rpart.control(minsplit=20, cp=0, maxdepth=4))

fancyRpartPlot(tree)
```

![](readme_files/figure-html/unnamed-chunk-6-1.png) 

```r
prp(tree)    	
```

![](readme_files/figure-html/unnamed-chunk-6-2.png) 


Al final, dado que tengo la clase original, los nodos y la prediccion del arbol (no en probabilidad, sino en clase). Puedo sacar por nodo la tasa de acierto y el porcentaje de casos que caen por nodo.


```r
rpart_summary <- function(tree){
  
  code <- data.frame(target = sort(unique(tree$y)),
                     target_f = factor(attr(tree, "ylevels")))
  
  cases <- data.frame(target = tree$y,
                      node = tree$where,
                      predict = predict(tree, type="class"))
  
  cases <- left_join(cases, code, by = "target")
  
  node_frame <- tree$frame[tree$frame$var == "<leaf>",] %>% rownames()
    
  summary <- cases %>%
    group_by(node) %>%
    summarise(count = n(),
              percent = count/nrow(.),
              node_accuracy = sum(predict == target_f)/count,
              node_prediction = unique(predict)) %>%
    ungroup() %>%
    mutate(node_frame = node_frame) %>%
    rename(node_where = node)
  
  summary
  
}
```


Y vemos el resultado: 

```r
resultado <- rpart_summary(tree)
resultado
```

```
## Source: local data frame [9 x 6]
## 
##   node_where count    percent node_accuracy node_prediction node_frame
## 1          3   814 0.40316989     0.9557740              PS          4
## 2          5    99 0.04903418     0.8484848              PS         10
## 3          7    25 0.01238237     0.6400000              PS         22
## 4          8    29 0.01436355     0.7931034              WS         23
## 5         11   323 0.15998019     0.6934985              PS         12
## 6         13    32 0.01584943     0.6875000              PS         26
## 7         14    79 0.03912828     0.8354430              WS         27
## 8         16    22 0.01089648     0.7727273              PS         14
## 9         17   596 0.29519564     0.7651007              WS         15
```

Y podemos agregar este resumen al árbol original.


```r
tree$summary <- resultado

tree$summary
```

```
## Source: local data frame [9 x 6]
## 
##   node_where count    percent node_accuracy node_prediction node_frame
## 1          3   814 0.40316989     0.9557740              PS          4
## 2          5    99 0.04903418     0.8484848              PS         10
## 3          7    25 0.01238237     0.6400000              PS         22
## 4          8    29 0.01436355     0.7931034              WS         23
## 5         11   323 0.15998019     0.6934985              PS         12
## 6         13    32 0.01584943     0.6875000              PS         26
## 7         14    79 0.03912828     0.8354430              WS         27
## 8         16    22 0.01089648     0.7727273              PS         14
## 9         17   596 0.29519564     0.7651007              WS         15
```

Comparar con


```r
tree$frame[tree$frame$var == "<leaf>", c(1,2, 9)]
```

```
##       var   n     yval2.V1     yval2.V2     yval2.V3     yval2.V4
## 4  <leaf> 814   1.00000000 778.00000000  36.00000000   0.95577396
## 10 <leaf>  99   1.00000000  84.00000000  15.00000000   0.84848485
## 22 <leaf>  25   1.00000000  16.00000000   9.00000000   0.64000000
## 23 <leaf>  29   2.00000000   6.00000000  23.00000000   0.20689655
## 12 <leaf> 323   1.00000000 224.00000000  99.00000000   0.69349845
## 26 <leaf>  32   1.00000000  22.00000000  10.00000000   0.68750000
## 27 <leaf>  79   2.00000000  13.00000000  66.00000000   0.16455696
## 14 <leaf>  22   1.00000000  17.00000000   5.00000000   0.77272727
## 15 <leaf> 596   2.00000000 140.00000000 456.00000000   0.23489933
##        yval2.V5 yval2.nodeprob
## 4    0.04422604     0.40316989
## 10   0.15151515     0.04903418
## 22   0.36000000     0.01238237
## 23   0.79310345     0.01436355
## 12   0.30650155     0.15998019
## 26   0.31250000     0.01584943
## 27   0.83544304     0.03912828
## 14   0.22727273     0.01089648
## 15   0.76510067     0.29519564
```

### Ahora nuevos datos

La sintaxis es media fea por lo que es mejor esconderla en una funcion:



```r
rpart_predict_nodes <- function(tree, newdata){
 nodes <- rpart:::pred.rpart(tree, rpart:::rpart.matrix(newdata)) 
 nodes
}

set.seed(10)
samp <- sample(seq(nrow(segmentationData)), size = 20)

niudata <- segmentationData[samp,]
niunodes  <- rpart_predict_nodes(tree, niudata) 
```

```
## Warning in rpart:::pred.rpart(tree, rpart:::rpart.matrix(newdata)): NAs
## introduced by coercion
```

```r
niunodes 
```

```
## 1025  620  862 1398  172  455  553  548 1239  864 1310 1141  228 1196  718 
##    3   11   17    3    8    3    3   11    3   11   17   17    5    3   11 
##  860  104  529  798 1673 
##   11    3    3    3    3
```

Y comparamos con los nodos obtenidos de la forma original


```r
all.equal(niunodes, tree$where[samp])
```

```
## [1] TRUE
```
