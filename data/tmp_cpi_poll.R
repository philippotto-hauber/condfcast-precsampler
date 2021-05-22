rm(list=ls())

library(lubridate)
library(dplyr)
library(tidyr)
library(bundesbank)

setwd("C:/Users/Philipp/Documents/GitHub/condfcast-precsampler/data")

# FUNCTIONS----

# define helper function
dropNA_first <- function(df)
# function that removes NA observations and drops first element
# output is a vector
{
  tmp <- df[!is.na(df)] # rem NA
  out <- tmp[-1] # drop first element
}

# source functions
source("functions.R")

# READ-IN REUTERS POLL DATA----
yy <- 2006
qq <- 1
dat <- read.csv(paste0(getwd(), "/raw/Reuters Poll/CPI/", yy, "Q", qq, ".csv"))

# BACK OUT DATES AND FORECASTS----
ind_date <- grep("consensus", dat[, 1], ignore.case = TRUE)
dates_fore_tmp <- dmy(dropNA_first(dat[ind_date, ]))

tmp <- grep("Contributor", dat[, 1], ignore.case = TRUE)
ind_contribs <- tmp + seq(1, nrow(dat)-tmp)

df_fore_yoy <- data.frame()
for (i in ind_contribs)
{
  fore <- as.numeric(dropNA_first(dat[i, ]))
  name_contrib <- dat[i, 1]
  df_fore_yoy <- rbind(df_fore_yoy, 
                            data.frame(yoy = fore, 
                                       dates = dates_fore_tmp,
                                       name = name_contrib)
                            )
  
}

df_fore_yoy$quarter_date <- make_date(year = yy, month = 3 * qq, day = 1) 

# TRANSFORM TO Q/Q GROWTH RATES----

v <- "2005-10-05"

df_fore_yoy %>%
  drop_na() %>%
  filter(dates == v) -> df_tmp

download_realtime_data("BBKRT.M.DE.Y.P.PC1.PC100.R.I", v) %>% 
  aggregate_to_Q("M") -> cpi

cpi$log_fore <- log(cpi$raw)

ind_row <- which(cpi$date == df_tmp$quarter_date[1])

df_tmp$qoq <- df_tmp$fore/100 + cpi$log[ind_row - 4]


