#' --- 
#' title: Tarea 02
#' output:
#'   html_document:
#'     theme: yeti
#'     toc: true
#'     toc_float: true
#' ---
#' 
#+ echo = FALSE, message = FALSE, warning = FALSE
knitr::opts_chunk$set(message = FALSE, warning = FALSE)
library(tidyverse)
library(jbkmisc)
theme_set(theme_jbk())
#' 
#' ## Evaluación y Consideraciones
#' 

#' ## Pregunta 0 (punto base)
#' 
#' Ejecute el siguiente código
#' 

#' ## Pregunta 1
#' 
#' Considere la tabla `iris` que contiene la medición de características de 150
#'  flores para ciertas especies de _iris_. 
#' 
#' (morfología)[https://www.math.umd.edu/~petersd/666/html/iris_with_labels.jpg]
#' 
#' Estudie la relación entre el largo y el ancho del sépalo:

data(iris)
tbl_df(iris)

ggplot(iris, aes(Sepal.Length, Sepal.Width)) +
  geom_point(shape = 1) 

#' Genere una regresión lineal explicando `Sepal.Width` en función de 
#' `Sepal.Length` y genere el resultado visual usando `geom_smooth` y 
#' __comente__ lo obtenido
#' 
#' ## Pregunta 2
#' 
#' Con los datos anterior genere __3__ regresiones lineales, una para cada tipo
#' de especie, columna `Species` y además de graficarlas, comente y averigue
#' que nombre posee efecto observado.
#' 
#' 
#' ## Pregunta 3
#' 
#' Considere la tabla `credit` que contiene 50mil casos de clientes cuyas variables
#' fueron capturadas al momento que le otorgaron un producto de crédito y luego
#' de cierto tiempo (digamos un año) se mide la variable `bad` que indica si cayó 
#' en default durante el periodo que el cliente se observó, i.e.,
#' fue un mal mal mal cliente.#' 
#' 
credit <- read_csv("https://raw.githubusercontent.com/jbkunst/riskr/master/data/credit.csv")
glimpse(credit)

# removemos algunas columnas constantes
credit <- select(credit, -flag_other_card, -flag_mobile_phone, -flag_contact_phone)

# algunos cosas necesarias
credit <- mutate_if(credit, is.character, as.factor)
credit <- mutate(credit, bad = factor(bad))

# tamohs ready
glimpse(credit)

#' 
#' A partir de `credit` genere dos subconjuntos disjuntos (partición) en donde cada
#' una contenga aproximadamente 50% de los casos, i.e., partala a la _mitá_ [^1]
#' 
#' [^1]: Un humilde consejo, llame a estas tablas como `train` (de entrenamiento) 
#' y `test` de testing. Jerga que se usa habitualmente en este tipo de experimentos.
#' 
#' Para cada una de las tablas calcule la proporción de clientes que cayeron en
#' default y luego de comparar: __comente__.
#' 
#' 
#' ## Pregunta 4
#' 
#' Realice el siguiente experimento:
#' 
#' Con la primera tabla, genere un arbol[^2] de profundidad $i$, y genere las 
#' predicciones tanto en la primera tabla como en la segunda y obtenga para
#' cada una la tasa de correcta clasificación obtenida en cada tabla. 
#' 
#' [^2]: Con la función `ctree` del paquete `partykit`
#' 
#' Repita lo anterior para $i$ de 1 a 8 y vaya generando un data frame que indique
#' el numero de iteración, las tasa de correcta clasificación de la primera tabla
#' con la cual creó el arbol y la tasa obtenida en la segunda tabla. Algo como:
#' 
data_frame(i = 2, train = 321, test = 123)
#' 
#' Sus amigos acá son `for`, `data_frame` y `bind_rows`
#' 
#' ## Pregunta 5
#' 
#' Genere un gráfico en donde abajo contenga en número de iteración y en el eje-Y
#' la tasa de correcta clasifiación separado según la tabla de la cual proviene
#' la tasa. Además __comente__.
#' 
#' ## Pregunta 6
#' 
#' Lorem
