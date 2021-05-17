rm(list = ls())
setwd("C:/Users/Philipp/Documents/GitHub/condfcast-precsampler/data")

# PACKAGES----
library(bundesbank)
library(lubridate)
library(dplyr)
library(tidyr)

# SOURCED FUNCTIONS ----
source("realtime_data.R")
source("financial_data.R")

# HELPER FUNCTIONS ----
download_realtime_data <- function(code, v_star)
{
  print(code)
  dat <- getSeries(code,
                   start = "1991-01",
                   end = format(Sys.Date(), "%Y-%m"),
                   return.class = "data.frame",
                   verbose = F, dest.dir = NULL)
  
  
  # convert dates and vintages to date format
  tmp <- rownames(dat)
  yy <- as.numeric(substr(tmp, 1, 4))
  mm <- as.numeric(substr(tmp, 6, 7)) 
  
  date <- make_date(year = yy, month = mm)
  
  tmp <- colnames(dat)
  yy <- as.numeric(substr(tmp, 1, 4))
  mm <- as.numeric(substr(tmp, 6, 7)) 
  dd <- as.numeric(substr(tmp, 9, 10))
  
  vint <- make_date(year = yy, month = mm, day = dd)
  
  # select vintage
  x_vint <- dat[, sum(vint <= v_star), drop = T] 
  
  return(data.frame(value = x_vint, date = date))
}

download_financial_data <- function(code)
{
  print(code)
  dat <- getSeries(code,
                   start = "1991-01",
                   end = format(Sys.Date(), "%Y-%m"),
                   return.class = "data.frame",
                   verbose = F, dest.dir = NULL)
  
  
  # convert dates and vintages to date format
  tmp <- dat$dates
  yy <- as.numeric(substr(tmp, 1, 4))
  mm <- as.numeric(substr(tmp, 6, 7)) 
  
  date <- make_date(year = yy, month = mm)

  return(data.frame(value = dat$values, date = date))
}

# helper functions
export_vintage_to_csv <- function(df, sample_start, name)
{
  df %>% 
    filter(date >= sample_start) %>%
    select(date, trafo, mnemonic) %>%
    pivot_wider(names_from = mnemonic, values_from = trafo) -> df
  
  ind_vars <- which(colnames(df)!= "date") # col indices
  ind_sample <- min(min(which(apply(is.na(df[, ind_vars]), 1, sum) == length(ind_vars)))-1, nrow(df)) # row indices
  
  df_export <- df[seq(1, ind_sample), ]
  
  write.csv(df_export, name, row.names = F, na = "NaN")
  
  return(df_export)
}

transform_series <- function(df, trafo_code)
{
  logdiff_series <- function(x){c(NA, 100 * log(x[seq(2, length(x))] / x[seq(1, length(x)-1)]))}
  diff_series <- function(x){c(NA, x[seq(2, length(x))] - x[seq(1, length(x)-1)])}
  if (trafo_code == "log, diff"){
    df %>% mutate(trafo = logdiff_series(raw)) -> df
  } else if (trafo_code == "diff"){
    df %>% mutate(trafo =  diff_series(raw)) -> df
  }else if (trafo_code == "none"){
    df %>% mutate(trafo =  raw) -> df
  }
  return(df)
}

aggregate_to_Q <- function(df, freq_code)
{
  if (freq_code == "M")
  {
    df %>% 
      mutate(yy = year(date),
             mm = month(date),
             qq = ceiling(mm/3)) %>%
      group_by(yy, qq) %>%
      summarize(raw = mean(value, na.rm = T)) %>%
      ungroup() %>%
      mutate(date = make_date(year = yy, month = qq * 3, day = 1L)) -> df
  } else
  {
    df %>% 
      mutate(yy = year(date),
             mm = month(date),
             qq = ceiling(mm/3)) %>%
      mutate(date = make_date(year = yy, month = qq * 3, day = 1L)) %>%
      rename(raw = value) -> df
  }
  
  return(df)
}

# MAIN FUNCTIONS----
get_realtime_data <- function(df_in, v_star)
{
  # get series from Bundesbank website
  df_out <- download_realtime_data(df_in$code, v_star)
  
  # calculate implicit deflator if needed
  if (!is.na(df_in$code_deflate))
  {
    df_nominal <- download_realtime_data(df_in$code_deflate, v_star)
    df_nominal <- rename(df_nominal, value_nominal = value)
    df_out <- merge(df_out, df_nominal)
    df_out %>% 
      mutate(value_deflator = 100 * value_nominal / value) %>%
      select(value = value_deflator, date) -> df_out
  }
  
  # temporal aggregation
  df_out <- aggregate_to_Q(df_out, df_in$frequency)
  
  # transform
  df_out <- transform_series(df_out, df_in$trafo)
  
  # add auxiliary vars
  df_out$group <- df_in$group
  df_out$category <- df_in$category
  df_out$name <- df_in$name
  df_out$mnemonic <- df_in$mnemonic
  
  # select and order df
  df_out %>% 
    select(date, raw, trafo, name, mnemonic, group, category) -> df_out
  
  return(df_out)
}

get_financial_data <- function(df_in, v_star)
{
  # get series from Bundesbank website
  df_out <- download_financial_data(df_in$code)
  
  # replicate real-time availability => end of previous month
  tmp <- as_date(v_star) - months(1)
  ind_available_date <- make_date(year = year(tmp), month = month(tmp), day = days_in_month(month(tmp)))
  df_out %>%
    filter(date <= ind_available_date) -> df_out
  
  # temporal aggregation
  df_out <- aggregate_to_Q(df_out, df_in$frequency)
  
  # transform
  str(df_out)
  df_out <- transform_series(df_out, df_in$trafo)
  
  # add auxiliary vars
  df_out$group <- df_in$group
  df_out$category <- df_in$category
  df_out$name <- df_in$name
  df_out$mnemonic <- df_in$mnemonic
  
  # select and order df
  df_out %>% 
    select(date, raw, trafo, name, mnemonic, group, category) -> df_out
  
  return(df_out)
}


# SET-UP----
realtime_data_spec <- realtime_data()
financial_data_spec <- financial_data()
vintages <- c("2006-02-28", "2006-05-31", "2006-08-31", "2006-11-30")
vintages <- c("2006-04-05")
sample_start <- "1996-01-01"


# LOOP OVER VINTAGES----
for (v_star in vintages)
{
    
    df_data <- data.frame()
    for (i in seq(1, nrow(realtime_data_spec)))
    {
          df_data <- rbind(df_data, get_realtime_data(realtime_data_spec[i, ], v_star))
    }

    for (i in seq(1, nrow(financial_data_spec)))
    {
          df_data <- rbind(df_data, get_financial_data(financial_data_spec[i, ], v_star))
    }
    
    name <- paste0("vintage", v_star, ".csv")
    export_vintage_to_csv(df_data, sample_start, name)
}


  






