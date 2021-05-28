rm(list = ls())

# SET-UP----
setwd("C:/Users/Philipp/Documents/GitHub/condfcast-precsampler/eval/releases/")

library(bundesbank)
library(lubridate)
library(tidyr)
library(dplyr)

# FUNCTIONS----

source("../../data/functions.R")

calc_first_release <- function(df_in, yys, qqs)
{
  # download data
  download_series <- function(code)
  {
    dat <- getSeries(code)
    dat$date <- make_date(year = as.numeric(substr(rownames(dat), 1, 4)), 
                          month = ceiling(as.numeric(substr(rownames(dat), 6, 7))/3)*3
    )
    
    dat %>% pivot_longer(-c(date), names_to = "vintage", values_to = "value") -> dat
    return(dat)
  }
  
  dat <- download_series(df_in$code)
  
  
  
  # calculate implicit deflator if needed
  if (!is.na(df_in$code_deflate))
  {
    dat_nominal <- download_series(df_in$code_deflate)
    dat_nominal <- rename(dat_nominal, value_nominal = value)
    dat <- merge(dat, dat_nominal, by = c("date", "vintage"))
    dat %>% 
      mutate(value_deflator = 100 * value_nominal / value) %>%
      select(value = value_deflator, date, vintage) -> dat
  }
  
  
  
  # temporal aggregation
  if (df_in$frequency != "Q"){
    dat %>% mutate(yy = year(date),
                   qq = ceiling(month(date)/3)
    ) %>%
      group_by(yy, qq, vintage) %>%
      summarise(valueQ = mean(value)) %>%
      ungroup() %>%
      mutate(date = make_date(year = yy, month = qq*3)) %>%
      select(vintage, date, valueQ) -> dat
  } else {
    dat <- rename(dat, valueQ = value)
  }
  
  
  dat %>% pivot_wider(names_from = "vintage", values_from = "valueQ") -> dat
  
  dates <- dat$date
  dat <- select(dat, -date)
  vintages <- as_date(colnames(dat))
  
  # loop over evaluation period
  df_out <- data.frame()
  for (yy in yys) {
    for (qq in qqs) {
      period <- make_date(year = yy, month = qq*3)
      ind_row <- which(dates == period)
      ind_col <- sum(is.na(dat[ind_row, ])) + 1
      first_release <- dat[ind_row, ind_col, drop=T] / dat[ind_row - 1, ind_col, drop=T] * 100 - 100
      df_out <- rbind(df_out, 
                      data.frame(quarter = dates[ind_row],
                                 vintage = vintages[ind_col],
                                 release = "first",
                                 value = first_release,
                                 mnemonic = df_in$mnemonic,
                                 variable = df_in$name,
                                 group = df_in$group,
                                 category = df_in$category)
      )
    }
  }
  return(df_out)
}

# CALCULATE FIRST RELEASES----

source("../../data/realtime_data.R")
realtime_vars <- realtime_data()

# evaluation period
yys <- c(seq(2006, 2017))
qqs <- c(seq(1, 4))


# loop over series
df_releases <- data.frame() # initialize dataframe
for (n in seq(1, nrow(realtime_vars)))
  df_releases <- rbind(df_releases, calc_first_release(realtime_vars[n, ], yys, qqs))

# EXPORT TO RDA----
save(file = "releases.Rda", df_releases)
