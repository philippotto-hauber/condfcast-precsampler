rm(list = ls())
setwd("C:/Users/Philipp/Documents/GitHub/condfcast-precsampler/data")

# SOURCE FUNCTIONS ----
source("realtime_data.R") # spec details for real-time data from Bbk
source("financial_data.R") # spec details for financial data from Bbk
source("functions.R") # helper functions


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

# export_vintage_to_csv <- function(df, sample_start, name, dir_out)
# {
#   df %>% 
#     filter(date >= sample_start) %>%
#     select(date, trafo, mnemonic) %>%
#     pivot_wider(names_from = mnemonic, values_from = trafo) -> df
#   
#   ind_vars <- which(colnames(df)!= "date") # col indices
#   ind_sample <- min(min(which(apply(is.na(df[, ind_vars]), 1, sum) == length(ind_vars)))-1, nrow(df)) # row indices
#   
#   df_export <- df[seq(1, ind_sample), ]
#   
#   write.csv(df_export, paste0(dir_out, name), row.names = F, na = "NaN")
#   
#   return(df_export)
# }

add_ReutersPoll_forecasts <- function(df_data, df_fore, sample_start, v_star)
{
  df_data %>% 
    filter(date >= sample_start) %>%
    select(date, trafo, mnemonic) %>%
    drop_na() -> df_data
  
  df_fore %>% 
    filter(dates_fore == v_star) %>%
    mutate(date = make_date(year = year(quarter), month = 3 * ceiling(month(quarter)/3), day = 1L)) %>%
    select(date, var, med, min, max) %>%
    pivot_longer(cols = c(med, min, max), names_to = "mnemonic", values_to = "trafo") %>%
    unite("mnemonic", c(mnemonic, var)) -> df_fore
  
  rbind(df_data, df_fore) %>% pivot_wider(names_from = mnemonic, values_from = trafo) -> df_export
  
  # check that there is no overlap between data and conditioning information
  intersect_dates_gdp <- intersect(as.character(df_export$date[!is.na(df_export$gdp)]),
                                   as.character(df_export$date[!is.na(df_export$med_gdp)])
                                  )
  intersect_dates_cpi <- intersect(as.character(df_export$date[!is.na(df_export$cpi)]),
                                   as.character(df_export$date[!is.na(df_export$med_cpi)])
                                  )

    if (length(intersect_dates_cpi) != 0 | length(intersect_dates_gdp) != 0)
    stop("Overlap between data and conditioning set. Abort!")
  
  # add flag indicating the sample used for estimation
  df_export$flag_estim <- 0
  df_export$flag_estim[!is.na(df_export$gdp)] <- 1
  
  return(df_export)
}
  
  

# PACKAGES----
library(bundesbank)
library(lubridate)
library(dplyr)
library(tidyr)
library(readxl)
library(readr)

# SET-UP----
dir_out <- paste0(getwd(), "/vintages/")
realtime_data_spec <- realtime_data()
financial_data_spec <- financial_data()
load("list_vintages.Rda")
load("ReutersPoll_data.Rda")
sample_start <- "1996-01-01"

# LOOP OVER VINTAGES----
for (v_star in list_vintages)
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
    
    df_export <- add_ReutersPoll_forecasts(df_data, df_out, sample_start, v_star)
    
    name <- paste0("vintage", v_star, ".csv")
    write.csv(df_export, paste0(dir_out, name), row.names = F, na = "NaN", quote=F)
}




# ggplot(df_export, aes(x = date))+
#   geom_line(aes(y = med_gdp), color = "red")+
#   geom_ribbon(aes(ymin = min_gdp, ymax = max_gdp), fill = "red", alpha = 0.2)+
#   geom_line(aes(y = gdp), color = "black")
# 
# ggplot(df_export, aes(x = date))+
#   geom_line(aes(y = med_cpi), color = "red")+
#   geom_ribbon(aes(ymin = min_cpi, ymax = max_cpi), fill = "red", alpha = 0.2)+
#   geom_line(aes(y = cpi), color = "black")



