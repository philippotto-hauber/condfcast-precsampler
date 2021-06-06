# check when log score is equal to Inf
rm(list = ls())
setwd("C:/Users/Philipp/Documents/GitHub/condfcast-precsampler/eval")

load("df_eval.Rda")

logs_inf <- filter(df_eval, logs == Inf)

ind_n <- nrow(logs_inf)
ind_n <- 1
type_star <- logs_inf$type[ind_n]
model_star <- logs_inf$model[ind_n]
v_star <- logs_inf$vintage[ind_n]
quarter_star <- logs_inf$quarter[ind_n]
series_star <- logs_inf$mnemonic[ind_n]

dat <- read.csv(paste0("../models/dfm/forecasts/", type_star, "_", model_star, "_", v_star, ".csv")) #unconditional_Nr4_Nj1_Np2_Ns0_2009-01-07.csv")

dat %>%
  select(quarter, draw, !!series_star) %>%
  filter(quarter == !!quarter_star) -> dat_plot



# load realization
load("releases/releases.Rda")

df_releases %>%
  filter(quarter == !!quarter_star, mnemonic == !!series_star) %>%
  select(value) %>%
  as.numeric() -> realization
  
hist(dat_plot[[series_star]], breaks = 100, 
     xlim = c(min(min(dat_plot[[series_star]]), realization),
              max(max(dat_plot[[series_star]]), realization))
     )
abline(v=realization, col="blue")
