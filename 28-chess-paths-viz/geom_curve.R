library("ggplot2")

theme_set(ggthemes::theme_map())

df <- data_frame(x = 0, y = 0, xend = 1, yend = 1)


df1 <- data_frame(x = 0, y = 0, xend = 1, yend = 1)
df2 <- data_frame(x = 0, y = 0, xend = 3, yend = 3)

ggplot(df, aes(x, y, xend = xend, yend = yend, size = 1.2, alpha = 0.75)) +
  geom_curve(color = "white", curvature = 1, angle = 0) +
  geom_curve(color = "black", curvature = 0, angle = 1) +
  geom_curve(color = "red", curvature = 1, angle = 45) + 
  geom_curve(color = "blue", curvature = -1, angle = -45) +
  geom_curve(color = "green", curvature = 0.5, angle = 45) + 
  geom_curve(color = "yellow", curvature = -0.5, angle = -45) +
  geom_curve(color = "darkblue", curvature = 1, angle = 90) + 
  geom_curve(color = "darkred", curvature = -1, angle = -90) +
  geom_curve(color = "white", curvature = 0.5, angle = 90) + 
  geom_curve(color = "black", curvature = -0.5, angle = -90) +
  xlim(c(-1,1.5)) + ylim(c(-1,1.5))

ggplot(df, aes(x, y, xend = xend, yend = yend, size = 1.2, alpha = 0.75)) +
  geom_curve(color = "red", curvature = 1, angle = 45) + 
  geom_curve(color = "blue", curvature = -1, angle = -45) +
  xlim(c(-1,1.5)) + ylim(c(-1,1.5))


ggplot(df, aes(x, y, xend = xend, yend = yend, size = 1.2, alpha = 0.75)) +
  geom_curve(color = "red",  curvature =  0.85, angle =  45) + 
  geom_curve(color = "blue", curvature = -0.85, angle = -45) +
  xlim(c(-1,1.5)) + ylim(c(-1,1.5))


ggplot(df, aes(x, y, xend = xend, yend = yend, size = 1.2, alpha = 0.75)) +
  geom_curve(color = "red",  curvature =  0.85, angle =  120) + 
  geom_curve(color = "blue", curvature = -0.85, angle =  120) +
  xlim(c(-1,1.5)) + ylim(c(-1,1.5))


#### 

ggplot() +
  geom_curve(data = df1, aes(x, y, xend=xend, yend=yend),
             color = "red",  curvature =  0.5, angle =  120) + 
  geom_curve(data = df2, aes(x, y, xend=xend, yend=yend),
             color = "blue",  curvature =  0.5, angle =  120)
  
