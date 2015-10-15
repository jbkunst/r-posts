library("dplyr")
library("ggplot2")
library("ggthemes")
# library("riskr")

update_geom_defaults("line", list(size = 1.2))
theme_set(ggthemes::theme_fivethirtyeight(base_size = 11) +
            theme(rect = element_rect(fill = "white"),
                  axis.title = element_text(colour = "grey30"),
                  axis.title.y = element_text(angle = 90),
                  strip.background = element_rect(fill = "#434348"),
                  strip.text = element_text(color = "#F0F0F0"),
                  plot.title = element_text(face = "plain", size = structure(1.2, class = "rel")),
                  panel.margin.x =  grid::unit(1, "cm"),
                  panel.margin.y =  grid::unit(1, "cm")))


set.seed(123)
n <- 10000

model <- rbeta(n, 2, 1)
target <- rbinom(n, 1, prob = model)

model_2 <- model + runif(n)
model_3 <- ifelse(target < 0.5, model + runif(n),  model + runif(n) * 1.5)
random_model <- runif(n)
perfect_model <- ifelse(target < 0.5, runif(n) * 0.49, runif(n) * 0.5 + .51)
bad_model <-  -model


models_df <- data.frame(target, model, model_2, model_3,
                        random_model, perfect_model, bad_model)
head(models_df)


p <- gg_roc(target, models_df %>% select(contains("model"))) +
  ggthemes::scale_color_hc("darkunica") + 
  coord_equal()
p

perf(models_df$target, models_df %>% select(contains("model")))

gg_gain(target, model)
gg_gain(target, model_2)
gg_gain(target, model_3)
gg_gain(target, random_model)
gg_gain(target, perfect_model)
gg_gain(target, bad_model)


gg_dists(target, model)
gg_dists(target, model_2)
gg_dists(target, model_3)
gg_dists(target, random_model)
gg_dists(target, perfect_model)
gg_dists(target, bad_model)



gg_perf(target, model)
gg_perf(target, model_2)
gg_perf(target, model_3)
gg_perf(target, random_model)
gg_perf(target, perfect_model)
gg_perf(target, bad_model)