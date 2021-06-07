# Set-up----
# libraries
suppressMessages(library(iterators, lib.loc = "~/R_libs"))
suppressMessages(library(foreach, lib.loc = "~/R_libs"))
suppressMessages(library(doParallel, lib.loc = "~/R_libs"))
suppressMessages(library(crayon, lib.loc = "~/R_libs"))
suppressMessages(library(dplyr, warn.conflicts = F, lib.loc = "~/R_libs"))
suppressMessages(library(lubridate, lib.loc = "~/R_libs"))
suppressMessages(library(scoringRules, lib.loc = "~/R_libs"))
suppressMessages(library(tidyr, lib.loc = "~/R_libs"))
getwd()
options(dplyr.summarise.inform = F)
# parallel set-up
registerDoParallel(cores=8)
print(getDoParWorkers())

dir_densities <- "./../models/dfm/forecasts/"
dir_releases <- "./releases/"
dir_vintages <- "./../data/"

list_vintages <- read.csv(paste0(dir_vintages, "list_vintages.csv"), header=F)
list_vintages <- list_vintages[seq(1, nrow(list_vintages)-2), , drop = F] # exclude 2018!
models <- c("Nr2_Nj1_Np2_Ns0", "Nr1_Nj1_Np2_Ns0","Nr5_Nj1_Np2_Ns0","Nr8_Nj1_Np2_Ns0") 
types <- c("unconditional", "conditional_hard")
# select variables
source("../data/realtime_data.R")
tmp <- realtime_data()
mnemonic_select <- tmp$mnemonic
mnemonic_select <- setdiff(mnemonic_select, c("gdp", "cpi", "inv"))
rm(tmp)

# Functions----
source("./../functions/functions.R")

# Releases----

load(paste0(dir_releases, "releases.Rda"))
df_releases %>% 
  select(quarter, realization = value, mnemonic) -> df_releases
# Loop over types, models and vintages----
tmp_out <- foreach (v = seq(1, nrow(list_vintages)), .combine = c) %dopar%
{
	print(v)
  df_eval <- data.frame()
  for (t in types){
    for (m in models){
      # load forecast output
      filename <- paste0(t, "_", m, "_", list_vintages[v, 1], ".csv")
      dat <- read.csv(paste0(dir_densities, filename))
      
      # convert quarter to date and calculate horizon
      dat$quarter <- as_date(dat$quarter)
      dat$horizon <- determine_horizon(dat$quarter, as_date(list_vintages[v, 1]))
      
      # convert to long format and select only a few variables
      dat %>% 
        pivot_longer(-c(horizon, quarter, draw), names_to = "mnemonic", values_to = "value") %>%
        filter(mnemonic %in% mnemonic_select) %>%
        mutate(model = m,
               type = t) -> dat
      
      # merge with releases
      dat <- merge(dat, df_releases, by= c("quarter", "mnemonic"))
      
      if (any(is.na(dat$realization)) || any(is.na(dat$value)))
      {
        print(list_vintages[v, 1])
        print(t)
        print(m)
        filter(dat, is.na(realization) || is.na(value))
        stop("Missings in either realizations or draws from the pred dens!")
      }
      
      # calculate sfe, log score and crps
      dat %>% 
        group_by(mnemonic, quarter, horizon, type, model) %>% 
        summarise(sfe = wrap_sfe(realization, value),
                  logs = wrap_logs_sample(realization, value),
                  crps = wrap_crps_sample(realization, value)) -> dat
      
      # add vintage to data.frame
      dat$vintage <- list_vintages[v, 1]
      
      # rbind to df_eval
      df_eval <- rbind(df_eval, dat)
    }
  }
  # save as csv
  write.csv(file = paste0(list_vintages[v, 1], ".csv"), df_eval)
}

# collect csv files in one Rda structure
df_eval_models <- data.frame()

for (v in seq(1, nrow(list_vintages))){
  fn <- paste0(list_vintages[v, 1], ".csv")
  tmp <- read.csv(fn)
  df_eval_models <- rbind(df_eval_models, tmp[, seq(2, ncol(tmp))])
  file.remove(fn)
}

save(file="df_eval_models.Rda", df_eval_models)
