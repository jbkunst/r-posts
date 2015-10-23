library("ggplot2")
library("dplyr")


df <- data_frame(x.to = c( 2, 3, 3, 2,-2,-3,-3,-2),
                 y.to = c( 3, 2,-2,-3,-3,-2, 2, 3),
                 x = 0,
                 y = 0,
                 x_gt_y = abs(x.to) > abs(y.to),
                 xy_sign = sign(x.to*y.to) == 1,
                 x_gt_y_equal_xy_sign = x_gt_y == xy_sign)


ggplot(df) + 
  geom_segment(aes(x = x, y = y, xend = x.to, yend = y.to, color = x_gt_y, linetype = !xy_sign),
               arrow = arrow(length = unit(0.25,"cm"))) + 
  coord_equal()

ggplot(df) + 
  geom_curve(aes(x = x, y = y, xend = x.to, yend = y.to, color = x_gt_y_equal_xy_sign),
             curvature = 0.75, angle = -45,
             arrow = arrow(length = unit(0.25,"cm"))) + 
  coord_equal() + 
  theme(legend.position = "bottom") +
  xlim(-4, 4) + ylim(-4,4)

ggplot() + 
  geom_curve(data = df %>% filter(x_gt_y_equal_xy_sign),
             aes(x = x, y = y, xend = x.to, yend = y.to, color = x_gt_y_equal_xy_sign),
             curvature = 0.75, angle = -45,
             arrow = arrow(length = unit(0.25,"cm"))) + 
  geom_curve(data = df %>% filter(!x_gt_y_equal_xy_sign),
             aes(x = x, y = y, xend = x.to, yend = y.to, color = x_gt_y_equal_xy_sign),
             curvature =-0.75, angle = 45,
             arrow = arrow(length = unit(0.25,"cm"))) + 
  coord_equal() + 
  theme(legend.position = "bottom") +
  xlim(-4, 4) + ylim(-4,4)
