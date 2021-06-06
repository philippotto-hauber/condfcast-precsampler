rm(list = ls())
setwd("C:/Users/Philipp/Documents/GitHub/condfcast-precsampler/eval")

library(ggplot2)
library(tidyr)
library(dplyr)
library(lubridate)

# load logs and crps for each model, type of forecast vintage and quarter
load("df_eval.Rda")
df_eval$quarter <- as_date(df_eval$quarter)
df_eval$vintage <- as_date(df_eval$vintage)

# relative log score and crps 
load("benchmarks/df_eval_benchmark.Rda")

df_eval %>% merge(select(df_benchmark, 
                                      quarter, 
                                      vintage, 
                                      mnemonic = series, 
                                      logs_ar = logs, 
                                      crps_ar = crps
                         ), 
                  by = c("quarter", "vintage", "mnemonic")) %>%
            mutate(rel_logs = logs - logs_ar,
                   rel_crps = crps - crps_ar) %>%
            select(-logs_ar, -crps_ar, -logs, -crps) -> df_eval


# calculate average lore and crps
df_eval %>% 
  filter(quarter >= "2010-01-01")%>%
  group_by(mnemonic, horizon, type, model) %>%
  summarise(mean_logs = mean(rel_logs),
            mean_crps = mean(rel_crps)) -> df_eval

# merge with category and group variable
source("../data/realtime_data.R")
tmp <- realtime_data()
tmp <- select(tmp, mnemonic, category)
df_eval <- merge(df_eval, tmp, by = "mnemonic")
rm(tmp)

# plot crps of conditional versus unconditional forecasts
str_title <- "CRPS"
df_eval %>%
  filter(horizon >=-1) %>%
  pivot_longer(c(mean_crps, mean_logs), names_to = "score", values_to = "value") %>%
  filter(value != Inf, score == "mean_crps") %>%
  pivot_wider(names_from = type, values_from = value) -> df_plot # data-dependent lims!


ggplot(df_plot, aes(x = unconditional, 
                    y = conditional_hard, 
                    color = category,
                    shape = model)
       )+
  geom_point(size = 2)+
  geom_abline()+
  geom_vline(xintercept = 0,  alpha = 0.5)+
  geom_hline(yintercept = 0, alpha = 0.5)+
  facet_wrap(~factor(horizon), nrow = 1)+
  xlim(c(
         min(min(df_plot$unconditional), min(df_plot$conditional_hard)), 
         max(max(df_plot$unconditional), max(df_plot$conditional_hard))
         )
       )+
  ylim(c(
         min(min(df_plot$unconditional), min(df_plot$conditional_hard)), 
         max(max(df_plot$unconditional), max(df_plot$conditional_hard))
         )
       )+
  theme_minimal()+
  theme(legend.position="bottom")+
  labs(title = str_title)

# plot logs of conditional versus unconditional forecasts
str_title <- "log score"
df_eval %>%
  filter(horizon >=-1) %>%
  pivot_longer(c(mean_crps, mean_logs), names_to = "score", values_to = "value") %>%
  filter(value != Inf, score == "mean_logs") %>%
  pivot_wider(names_from = type, values_from = value) -> df_plot # data-dependent lims!


ggplot(df_plot, aes(x = unconditional, 
                    y = conditional_hard, 
                    color = category,
                    shape = model)
)+
  geom_point(size = 2)+
  geom_abline()+
  geom_vline(xintercept = 0,  alpha = 0.5)+
  geom_hline(yintercept = 0, alpha = 0.5)+
  facet_wrap(~factor(horizon), nrow = 1)+
  xlim(c(
    min(min(df_plot$unconditional), min(df_plot$conditional_hard)), 
    max(max(df_plot$unconditional), max(df_plot$conditional_hard))
  )
  )+
  ylim(c(
    min(min(df_plot$unconditional), min(df_plot$conditional_hard)), 
    max(max(df_plot$unconditional), max(df_plot$conditional_hard))
  )
  )+
  theme_minimal()+
  theme(legend.position="bottom")+
  labs(title = str_title)