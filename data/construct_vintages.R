rm(list = ls())
setwd("C:/Users/Philipp/Documents/GitHub/condfcast-precsampler/data")

# PACKAGES----
library(bundesbank)
library(lubridate)
library(dplyr)
library(tidyr)
library(readxl)
library(readr)

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
export_vintage_to_csv <- function(df, sample_start, name, dir_out)
{
  df %>% 
    filter(date >= sample_start) %>%
    select(date, trafo, mnemonic) %>%
    pivot_wider(names_from = mnemonic, values_from = trafo) -> df
  
  ind_vars <- which(colnames(df)!= "date") # col indices
  ind_sample <- min(min(which(apply(is.na(df[, ind_vars]), 1, sum) == length(ind_vars)))-1, nrow(df)) # row indices
  
  df_export <- df[seq(1, ind_sample), ]
  
  write.csv(df_export, paste0(dir_out, name), row.names = F, na = "NaN")
  
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

get_survey_data <- function(v_star)
{
  dir_data = paste0(getwd(), "/raw/")
  
  filename <- "main_indicators_nace2.xlsx"
  
  read_excel(path = paste0(dir_data, filename), 
             sheet = "Index", range = "A7:B41",
             col_names = c("geo_short", "geo_long")) %>% drop_na() -> countries
  
  read_excel(path = paste0(dir_data, filename), 
             sheet = "Index", range = "A47:B53",
             col_names = c("var_short", "var_long")) %>% drop_na() -> variables
  
  sheetname <- "MONTHLY"
  
  data <- read_excel(path = paste0(dir_data, filename), sheet = sheetname) %>%
    select_if(function(x){!all(is.na(x))}) %>%
    select(date = ...1, everything()) %>% 
    mutate(date = make_date(year = year(date), month = month(date), day = 1)) %>%
    gather(colname, value, -date) %>%
    mutate(value = parse_double(value)) %>%
    separate(colname, into = c("geo_short", 
                               "var_short")) 
  
  # join with data
  data <- data  %>% left_join(countries, by = "geo_short") %>%
    left_join(variables, by = "var_short") 
  
  # filter values for Germany and relevant indicators
  data <- filter(data, geo_long == "Germany", var_short != "ESI")
  
  # replicate real-time availability
  if (day(v_star) >= 28 & month(v_star) == 1) # December data is usually released in early January, so prior to Jan 8th we only have values until November!
  {
        tmp <- as_date(v_star) - months(2)
        ind_available_date <- make_date(year = year(tmp), month = month(tmp), day = days_in_month(month(tmp)))
  } else
  {
      if (day(v_star) >= 28){
        ind_available_date <- make_date(year = year(v_star), month = month(v_star), day = days_in_month(month(v_star)))
      } else {
        tmp <- as_date(v_star) - months(1)
        ind_available_date <- make_date(year = year(tmp), month = month(tmp), day = days_in_month(month(tmp)))
      }
  }
  data %>%
    filter(date <= ind_available_date) -> data
  
  
  # aggregate to quarterly frequency
  dataQ <- data.frame()
  
  for (i in unique(data$var_short)){
    name <- head(data$var_long[data$var_short == i], 1)
    df_tmp <- filter(data, var_short == !!i)
    df_tmp <- aggregate_to_Q(df_tmp, "M")
    df_tmp$mnemonic <- paste0("survey_", tolower(i))
    df_tmp$name <- name
    dataQ <- rbind(dataQ, df_tmp)
  }
  
  # add group, category
  dataQ$group <- "survey"
  dataQ$category <- "activity"
  dataQ$category[dataQ$mnemonic == "survey_eei"] <- "labor market"
  
  # add trafo
  dataQ$trafo <- dataQ$raw
  
  # select and order df
  dataQ %>% 
    select(date, raw, trafo, name, mnemonic, group, category) -> df_out
  
  return(df_out)
}

# SET-UP----
dir_out <- paste0(getwd(), "/vintages/")
realtime_data_spec <- realtime_data()
financial_data_spec <- financial_data()
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
    
    df_data <- rbind(df_data, get_survey_data(v_star))
    
    name <- paste0("vintage", v_star, ".csv")
    export_vintage_to_csv(df_data, sample_start, name, dir_out)
}


  






