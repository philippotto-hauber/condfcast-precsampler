# Set-up----
# libraries
suppressMessages(library(iterators, lib.loc = "~/R_libs"))
suppressMessages(library(foreach, lib.loc = "~/R_libs"))
suppressMessages(library(doParallel, lib.loc = "~/R_libs"))
suppressMessages(library(crayon, lib.loc = "~/R_libs"))
suppressMessages(library(dplyr, lib.loc = "~/R_libs"))
suppressMessages(library(lubridate, lib.loc = "~/R_libs"))
suppressMessages(library(scoringRules, lib.loc = "~/R_libs"))
suppressMessages(library(tidyr, lib.loc = "~/R_libs"))
getwd()

# parallel set-up
registerDoParallel(cores=8)
print(getDoParWorkers())

dir_densities <- "./../models/dfm/forecasts/"
dir_releases <- "./releases/"
dir_vintages <- "./../data/"

list_vintages <- read.csv(paste0(dir_vintages, "list_vintages.csv"), header=F)

models <- c("Nr4_Nj1_Np2_Ns0", "Nr1_Nj1_Np2_Ns3") 
types <- c("unconditional", "conditional_hard")

# select variables
source("../data/realtime_data.R")
tmp <- realtime_data()
mnemonic_select <- tmp$mnemonic
mnemonic_select <- setdiff(mnemonic_select, c("gdp", "cpi", "inv"))
rm(tmp)

# Functions----

# wrapper for logS_sample
wrap_logs_sample <- function(y, dat){
  logs <- logs_sample(y[1], dat)
  return(logs)
}

# wrapper for crps_sample
wrap_crps_sample <- function(y, dat){
  crps <- crps_sample(y[1], dat)
  return(crps)
}

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
      
      # convert to long format and select only a few variables
      dat %>% 
        pivot_longer(-c(horizon, draw), names_to = "mnemonic", values_to = "value") %>%
        filter(mnemonic %in% mnemonic_select) %>%
        mutate(model = m,
               type = t) -> dat
      
      # convert horizon to quarter
      v_date <- as_date(list_vintages[v, 1])
      
      convert_horizon <- data.frame(horizon_new = c(seq(-1, 2)),
                                    horizon = c(seq(1, 4)))
      dat <- merge(dat, convert_horizon, by = "horizon") %>%
        select(-horizon) %>% 
        rename(horizon = horizon_new) -> dat
      
      quarter_tmp <- v_date + months(dat$horizon * 3) # given new horizon, calculate quarter
      dat %>%
        mutate(quarter = make_date(year = year(quarter_tmp), 
                                   month = month(quarter_tmp) + 2, 
                                   day = 1L)) -> dat
      
      # merge with releases
      dat <- merge(dat, df_releases, by= c("quarter", "mnemonic"))
      
      # calculate log score and crps
      dat %>% 
        group_by(mnemonic, quarter, horizon, type, model) %>% 
        summarise(logs = wrap_logs_sample(realization, value),
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
df_eval <- data.frame()

for (v in seq(1, nrow(list_vintages))){
  fn <- paste0(list_vintages[v, 1], ".csv")
  tmp <- read.csv(fn)
  df_eval <- rbind(df_eval, tmp[, seq(2, ncol(tmp))])
  file.remove(fn)
}

save("df_eval.Rda", df_eval)
