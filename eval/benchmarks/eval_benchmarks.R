rm(list = ls())
#setwd("C:\Users\Philipp\Documents\GitHub\condfcast-precsampler\eval\benchmarks")

# Set-up----
library(tidyr)
library(dplyr)
library(lubridate)
library(scoringRules)

dir_vintages <- "./../../data/"
dir_fore <- "./forecasts/"
dir_releases <- "./../releases/"

list_vintages <- read.csv(paste0(dir_vintages, "list_vintages.csv"), header=F)

# Functions----

# wrapper for logS_sample
wrap_logs_sample <- function(y, dat){
  logs <- scoringRules::logs_sample(y[1], dat)
  return(logs)
}

# wrapper for crps_sample
wrap_crps_sample <- function(y, dat){
  crps <- scoringRules::crps_sample(y[1], dat)
  return(crps)
}

determine_horizon <- function(quarter, vintage)
{
  floor(lubridate::day(lubridate::days(quarter)-lubridate::days(vintage))/90)
}

df_fore <- data.frame()
for (v in list_vintages[, 1])
#for (v in list_vintages[1, 1])
{
  df_fore <- rbind(df_fore, 
                   read.csv(paste0(dir_fore, "benchmark_", v, ".csv"))
                   )
}

df_fore$quarter <- as.Date(df_fore$quarter)

df_fore$vintage <- as.Date(df_fore$vintage)

load(paste0(dir_releases, "releases.Rda"))

df_releases <- select(df_releases, quarter, mnemonic, realization = value)

df <- merge(df_fore, df_releases, 
            by.x = c("quarter", "series"), 
            by.y = c("quarter", "mnemonic"))

rm(df_fore, df_releases)

df <- filter(df, series != "inv")

# calculate log score and crps
df %>% 
  group_by(series, quarter, vintage) %>% 
  summarise(logs = wrap_logs_sample(realization, value),
            crps = wrap_crps_sample(realization, value)) -> df_eval_tmp

# calculate horizon from quarter and vintage
df_eval_tmp$horizon <- determine_horizon(df_eval_tmp$quarter, df_eval_tmp$vintage)

# calculate mean log score and crps
df_eval_tmp %>%
  group_by(series, horizon) %>%
  summarise(mean_logs = mean(logs),
            mean_crps = mean(crps),
            n_quarters = n()) -> df_eval




