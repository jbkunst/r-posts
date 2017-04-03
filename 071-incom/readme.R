# packages ----------------------------------------------------------------
rm(list = ls())
# devtools::install_github("krlmlr/kimisc")
# devtools::install_github("jbkunst/jbkmisc")
library(tidyverse)
library(broom)
library(jbkmisc)
library(kimisc)
library(viridis)
library(ggplot2)
library(scales)

theme_set(
  theme_jbk(
    plot_title_face = "plain"
    )
  )

red <- "#d35400"
income_max <- 1.5e6
update_geom_defaults("bar", list(fill = red))

dir.create("plots")
file.remove(dir("plots/", full.names = TRUE))

# data --------------------------------------------------------------------
data <- readRDS("146.rds")
glimpse(data)

data <- data %>% 
  rename(
    renta_liquida = renta_liquidax,
    edad = edadx
    ) %>% 
  mutate(
    renta_liquida_miles_cat =
      cut_format(
        renta_liquida/1000,
        c(0, 250, 500, 750, 1000, 1250, Inf),
        format_fun = scales::comma,
        include.lowest = TRUE),
    edad_cat = cut(edad, c(20, 40, 50, 60, 70, Inf)),
    ratio_ddacon_renta = 1000 * deudaconsumo / renta_liquida
    ) 

countp(data, renta_liquida_miles_cat)


gg <- ggplot(data)


# renta hist --------------------------------------------------------------
gg +
  geom_histogram(aes(renta_liquida)) + 
  scale_x_continuous(labels = dollar, limits = c(NA, income_max)) +
  scale_y_continuous(labels = comma) +
  labs(title = "Renta Líquida")
ggsav()


# renta hist quantiles ----------------------------------------------------1.
df_rent_quant <- data %>% 
  do(tidy(quantile(.$renta_liquida, c(10,25,50,75, 90)/100)))
df_rent_quant

last_plot() + 
  geom_vline(data = df_rent_quant, aes(xintercept = x), color = "gray50") +
  geom_text(data = df_rent_quant, aes(x = x, y = 0, label = names),
            hjust = 1.2, vjust = -1, size = 3,
            color = "gray20", family = "Calibri Light") +
  labs(subtitle = "Líneas indican quantiles")
ggsav()


# renta cat ---------------------------------------------------------------
df_rent_cat <- countp(data, renta_liquida_miles_cat)
df_rent_cat

gg +
  geom_bar(aes(renta_liquida_miles_cat), width = 0.5) +
  geom_text(data = df_rent_cat, aes(x = 1:nrow(df_rent_cat), y = n, label = comma(n)),
            vjust = -1, color = "gray20", family = "Calibri Light", size = 3) + 
  geom_text(data = df_rent_cat, aes(x = 1:nrow(df_rent_cat), y = n, label = percent(p)),
            vjust = 1.25, color = "gray20", family = "Calibri Light", size = 3) + 
  scale_y_continuous(labels = comma) +
  labs(title = "Renta Líquida en miles categorizada")
ggsav()


# edad --------------------------------------------------------------------
gg +
  geom_histogram(aes(edad)) + 
  scale_y_continuous(labels = comma) +
  labs(title = "Distribución Edad")
ggsav()


# edad cat ----------------------------------------------------------------
df_edad_cat <- countp(data, edad_cat)
df_edad_cat

gg +
  geom_bar(aes(edad_cat), width = 0.5) +
  geom_text(data = df_edad_cat, aes(x = 1:nrow(df_edad_cat), y = n, label = comma(n)),
            vjust = -1, color = "gray20", family = "Calibri Light", size = 3) + 
  geom_text(data = df_edad_cat, aes(x = 1:nrow(df_edad_cat), y = n, label = percent(p)),
            vjust = 1.25, color = "gray20", family = "Calibri Light", size = 3) + 
  scale_y_continuous(labels = comma) +
  labs(title = "Distribución Edad categorizada")
ggsav()

# renta edad --------------------------------------------------------------
data_renta <- filter(data, renta_liquida != 0)

ggplot(data_renta) + 
  geom_jitter(aes(edad, renta_liquida), alpha = 0.005, color = "black") +
  stat_density_2d(aes(edad, renta_liquida, fill = ..level.., alpha = ..level..),
                  geom = "polygon") +
  scale_y_continuous(labels = dollar) +
  coord_cartesian(ylim = c(0, income_max)) + 
  theme(legend.position = "none") +
  labs(title = "Distribución Edad vs Renta",
       subtitle = "Se destaca una concentración de Socios con 55 años de edad y $375mil renta.\n
En este caso se eliminaron rentas $0 (140mil casos app)")
ggsav()

ggplot(data_renta) + 
  geom_jitter(aes(edad, renta_liquida), alpha = 0.005, color = "black") +
  geom_smooth(aes(edad, renta_liquida), color = red) +
  scale_y_continuous(labels = dollar) +
  coord_cartesian(ylim = c(0, income_max)) + 
  labs(title = "Suavizamiento Renta segun Edad",
       subtitle = "En este caso se eliminaron rentas $0 (140mil casos app)")
ggsav()


# renta cat edad cat  -----------------------------------------------------
df_renta_edad_cat <- data %>% 
  countp(edad_cat, renta_liquida_miles_cat) %>% 
  group_by(edad_cat) %>% 
  mutate(p = n/sum(n))
df_renta_edad_cat

ggplot(df_renta_edad_cat) +
  geom_col(aes(renta_liquida_miles_cat, n), fill = red) +
  geom_text(aes(x = renta_liquida_miles_cat, y = n, label = comma(n)),
            vjust = -1, color = "gray20", family = "Calibri Light", size = 3) + 
  geom_text(aes(x = renta_liquida_miles_cat, y = n, label = percent(p)),
            vjust = 1.25, color = "gray20", family = "Calibri Light", size = 3) + 
  scale_y_continuous(labels = comma) +
  facet_wrap(~edad_cat, scales = "free") +
  labs(title = "Distribución Edad vs Renta",
       subtitle = "Todas las distribuciones son similares exceptuando Socios sobre 70 años de edad")
ggsav()

# renta edad cat ----------------------------------------------------------
gg +
  geom_boxplot(aes(edad_cat, renta_liquida), fill = red, outlier.colour = red,
               outlier.alpha = 0.1, width = 0.5, color = "gray50") + 
  scale_y_continuous(labels = dollar) +
  coord_cartesian(ylim = c(0, income_max)) +
  labs(title = "Distribución Edad categorizada vs Renta")
ggsav()

# ddaconsumo --------------------------------------------------------------
data_deuda_renta <- filter(data, renta_liquida != 0, deudaconsumo != 0)

ggplot(data_deuda_renta, aes(renta_liquida, ratio_ddacon_renta)) +
  geom_point(alpha = 0.005, color = "black") +
  stat_density_2d(aes(fill = ..level.., alpha = ..level..), geom = "polygon") +
  scale_alpha(range = c(0.0, .75)) +
  coord_cartesian(xlim = c(0, income_max), ylim = c(0, 50)) +
  scale_x_continuous(labels = dollar) + 
  scale_y_sqrt(breaks = c(0, 1, 10, 20, 40, 50)) +
  theme(legend.position = "none") +
  labs(title = "Distribución Renta vs Ratio Deuda Consumo/Renta",
       subtitle = "Se destaca una concentración de Socios $375mil renta y Ratio 1.\n
En este caso se consideran socios con rentas >$0 y Deudas >$0 (100mil casos app)")
ggsav()
  
last_plot() +
  facet_wrap(~edad_cat, scales = "free") +
  theme(legend.position = "none") +
  labs(title = "Distribución Renta vs Ratio Deuda Consumo/Renta segun Edad",
       subtitle = "Notar la diferencia de los Socios con menos de 40 años que están más endeudados")
ggsav()


ggplot(data_deuda_renta, aes(renta_liquida, ratio_ddacon_renta)) +
  geom_point(alpha = 0.005, color = "black") +
  geom_smooth(aes(color = edad_cat), se = FALSE) +
  scale_color_viridis(discrete = TRUE) +
  coord_cartesian(xlim = c(0, income_max), ylim = c(0, 50)) +
  scale_x_continuous(labels = dollar) + 
  scale_y_sqrt(breaks = c(1, 10, 20, 40, 50)) +
  labs(title = "Suavizamiento Renta vs Ratio Deuda Consumo/Renta segun Edad",
       subtitle = "Los Socios que poseen menos renta están más endeudados y comparando por 
rangos de edad, los de mayor edad tienen estar menos endeudados")
ggsav()

