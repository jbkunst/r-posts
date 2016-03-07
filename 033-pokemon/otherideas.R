#### Use the stats ###
stts <- c("hp", "attack", "defense", "special_attack", "special_defense", "speed")

dftpstats  <- df %>% 
  select(type_1, color_1,
         hp, attack, defense, special_attack, special_defense, speed) %>% 
  gather(stat, value, -type_1, -color_1) %>% 
  group_by(type_1, color_1, stat) %>%
  summarise(value = median(value)) %>% 
  ungroup() %>% 
  mutate(stat = factor(stat, levels = stts)) %>% 
  arrange(type_1, as.numeric(stat))

dftpstats

hcstats <- highchart() %>% 
  hc_chart(type = "line", polar = TRUE) %>% 
  hc_plotOptions(line = list(marker = list(enabled = FALSE))) %>% 
  hc_xAxis(categories = stts,
           tickmarkPlacement = 'on',
           lineWidth = 0) %>% 
  hc_yAxis(gridLineInterpolation = 'polygon',
           lineWidth = 0,
           min = 0) %>% 
  hc_legend(align = "left", verticalAlign = "top",
            layout = "vertical") 

for (tp in unique(dftpstats$type_1)){
  
  dftpstats2 <- dftpstats %>% filter(type_1 == tp)
  
  hcstats <- hcstats %>% 
    hc_add_series(name = tp, data = dftpstats2$value,
                  color = hex_to_rgba(dftpstats2$color_1[1], 0.4))
  
}

hcstats
