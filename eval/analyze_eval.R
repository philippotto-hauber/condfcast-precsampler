rm(list = ls())

load("df_eval.Rda")

library(ggplot2)
library(tidyr)
library(dplyr)
library(lubridate)


# calculate average log score and crps
df_eval %>% 
  group_by(mnemonic, horizon, type, model) %>%
  summarise(mean_logs = mean(logs),
            mean_crps = mean(crps)) -> df_plot

# merge with category and group variable
source("../data/realtime_data.R")
tmp <- realtime_data()
tmp <- select(tmp, mnemonic, category)
df_plot <- merge(df_plot, tmp, by = "mnemonic")
rm(tmp)

# plot crps of conditional versus unconditional forecasts
df_plot %>%
  filter(horizon == -1) %>%
  select(-mean_logs) %>%
  pivot_longer(mean_crps, names_to = "score", values_to = "value") %>%
  pivot_wider(names_from = type, values_from = value) %>% 
  ggplot(aes(x = conditional_hard, y = unconditional, color = category, shape = model))+
    geom_point(size = 2)+
    geom_abline()
  