rm(list = ls())
setwd("C:/Users/Philipp/Documents/GitHub/condfcast-precsampler/eval/benchmarks")

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
source("./../../functions/functions.R")

# Read in benchmark forecasts for each vintage----
df_fore <- data.frame()
for (v in list_vintages[, 1])
{
  df_fore <- rbind(df_fore, 
                   read.csv(paste0(dir_fore, "benchmark_", v, ".csv"))
                   )
}

df_fore$quarter <- as.Date(df_fore$quarter)

df_fore$vintage <- as.Date(df_fore$vintage)


# Merge with realizations and calculate log score and CRPS----

load(paste0(dir_releases, "releases.Rda"))

df_releases <- select(df_releases, quarter, mnemonic, realization = value)

df <- merge(df_fore, df_releases, 
            by.x = c("quarter", "series"), 
            by.y = c("quarter", "mnemonic"))

rm(df_fore, df_releases)

# remove inventories as they were causing Inf when calculating the log score
df <- filter(df, series != "inv") 

df %>% 
  group_by(series, quarter, vintage) %>% 
  summarise(sfe = wrap_sfe(realization, value),
            logs = wrap_logs_sample(realization, value),
            crps = wrap_crps_sample(realization, value)) -> df_eval_benchmark

# calculate horizon from quarter and vintage
df_eval_benchmark$horizon <- determine_horizon(df_eval_benchmark$quarter, 
                                               df_eval_benchmark$vintage)


# Output file as Rda----
save(file = "df_eval_benchmark.Rda", df_eval_benchmark)



