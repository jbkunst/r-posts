#' --- 
#' title: Tarea 01
#' output:
#'   html_document:
#'     theme: yeti
#'     toc: true
#'     toc_float: true
#' ---
#+ echo = FALSE, message = FALSE, warning = FALSE
knitr::opts_chunk$set(message = FALSE, warning = FALSE)
library(jbkmisc)
library(ggplot2)
theme_set(theme_jbk())
#' 
#' ## Evaluación y Consideraciones
#' 
#' Cada grupo deberá enviar un mail a <jbkunst@gmail.com> con el asunto 
#' "Tarea namber wan" (sin comillas) adjuntando un script el cual deberá 
#' correr sin errores al ser ejecutado y debe claramente señalar los comandos
#' (esto es el código mismo) con el cual obtuvo las respuestas incluyendo 
#' comentarios.
#' 
#' Se evaluará tango el código como el resultado. Con esto se intenta evitar las 
#' respuestas _al ojo_ o usando otras herramientas como _excel_.
#' Por ejemplo, `script_grupo_1.R`:
#' 
#' ```
#' # Pregunta 1
#' # Para esta pregunta debemos seleccionar filtrar el data frame y segun x > 5
#' # y reordenar segun la variable y:
#' 
#' data %>% 
#'   filter(x > 5) %>% 
#'   arrange(y)
#' 
#' ```
#' 
#' Son libres de hacer preguntas vía mail, ya sea especifiación de las preguntas
#' u otras cosas pero siempre háganlo escribiéndolo a todo el grupo.
#' 
#' Espero los script a __más tardar__ el miércoles 26 de este més (y de este año)
#' a las 11.59 PM. Obviamente lo pueden enviar el script más tarde, la única 
#' salvedad es que la nota final será la nota por el script dividido por 1.25 por 
#' cada hora que pase desde el límite. A modo de ejemplo si la nota es un 5.5, 
#' y fue entregado a las 3AM, la nota final será:
#' 
nota_script <- 6.0
nota_final <- nota_script/(1.11^3)
round(nota_final, 1)
#' 
#' 
#' ## Requerimientos
#' 
#' Necesitaremos algunos paquetes para trabajar. El siguiente código
#' instalará lo requerido:
#' 
library(tidyverse)

paquetes_a_instalar <- c("gapminder", "babynames", "fueleconomy", "nycflights13")

for(p in paquetes_a_instalar) {
  message("Instalando ", p)
  if(!p %in% rownames(installed.packages())) install.packages(p)
  library(p, character.only = TRUE)
}

#' ![](https://az616578.vo.msecnd.net/files/2015/11/06/6358243226338872701442058152_oq731NH.gif)
#' 
#' ## Pregunta 0 (el punto base)
#' 
#' Considere, la tabla `births` del paquete `babynames`. Esto es:
data("births", package = "babynames")
head(births)

#' ¿Cuántas columnas y filas posee la tabla _births_?
#' 
#' ## Pregunta 1
#' 
#' Considere, la tabla `births` del paquete `babynames`. Estudie los 
#' nacimientos por años en EE.UU:
ggplot(births) +
  geom_line(aes(year, births)) 

#' ¿En que _decada_ se obtuvo la menor cantidad de nacimientos?.
#' 
#' ## Pregunta 2
#' 
#' Considerando ahora la tabla `babynames` del paquete `babynames`:
data("babynames", package = "babynames")
glimpse(babynames)

#' Realice el proceso necesario para obtener el mismo estructura en cuanto
#' a _columnas_ que la tabla `births`. 
#' 
#' ## Pregunta 3
#' 
#' Genere un data frame partiendo de la tabla babyanes `babynames` y conteniendo
#' los nacimientos de personas de género femenino con el nombre _Nala_, _Ariel_
#' y _Elsa_ desde los años 1980 en adelante. 
#' 
#' ## Pregunta 4
#' 
#' Con el data frame obtenido en la pregunta anterior genere un gráfico que 
#' contenga la información de los nacimientos por año de cada uno de los
#' nombres mencionados y __mencione__ una hipótesis/suposición al respecto de lo 
#' observado.
#' 
#' hint: Use `facet_wrap(~ name, scales = "free_y")`.
#' 
#' 
#' ## Pregunta 5
#' 
#' Utilizando la tabla `airports` y `flights` del paquete `nycflights13`
#' obtenga una tabla que contenga conteos de vuelos según su destino además 
#' de la longitud y latidud del aeropuerto (de destino).
#' 
#' ## Pregunta 6
#' 
#' Apoyándose del siguiente gráfico
us <- map_data("state")

glimpse(us)

ggmap <- ggplot() +
  geom_polygon(data = us, aes(long, lat, group = group), 
               alpha = 0.25) +
  coord_fixed() # esto es para mantener la razón 1:1

ggmap

#' Agregue una capa de de puntos ubicando los aeropuertos obtenidos de la pregunta
#' anterior y usando además: `aes(size = la_cantidad_de_vuelos_a_dicho_aeropuerto)`.
#' 
#' tip: Use por favor geom_point(alpha = un_numero_menor_que_1) para tener
#' un resultado agradable a la vista.
#' 
#' ## Pregunta 7
#' 
#' A la izquiera del gráfico anterior se observan 2 puntos. Genere el/los pasos
#' necesarios para seleccionarlos usando la tabla resultante de la pregunta 5
#' para identificar los nombres de dichos areopuertos y responda ¿Dónde están?
#' ¿Que gracias tienen?
#' 
#' ## Pregunta 8
#' 
#' Considere la tabla `vehicles` del paquete `fueleconomy`.
#' 
#' Genere un subconjunto de la tabla `vehicles` considerando las 10 clases 
#' (columna `class`) más comunes y:
#' 
#' 1. Genere un gráfico de densidades del consumo en carretera (`hwy`)
#' separando por clase de vehículo. 
#' 
#' 2. Averigué como usar la función `geom_boxplot` para generar un gráfico
#' de _boxplots_ y así comparar las distribuciones de rendimiento según clase.
#' 
#' ## Pregunta 9
#' 
#' Con los 2 gráficos anteriormente obtenidos argumente cuales son las
#' debidildades y fortalezas de cada tipo de visualización. 
#' 
#' ## Pregunta 10
#' 
#' Usando la tabla anterior calcule el promedio, el mínimo y el máximo de
#' rendimiento según clase de vehículo.

