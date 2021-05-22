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

transform_series <- function(df, trafo_code)
{
  logdiff_series <- function(x){c(NA, 100 * log(x[seq(2, length(x))] / x[seq(1, length(x)-1)]))}
  diff_series <- function(x){c(NA, x[seq(2, length(x))] - x[seq(1, length(x)-1)])}
  logdiff4_series <- function(x){c(rep(NA, 4), 100 * log(x[seq(5, length(x))] / x[seq(1, length(x)-4)]))}
  if (trafo_code == "log, diff"){
    df %>% mutate(trafo = logdiff_series(raw)) -> df
  } else if (trafo_code == "diff"){
    df %>% mutate(trafo =  diff_series(raw)) -> df
  } else if (trafo_code == "y/y"){
    df %>% mutate(trafo =  logdiff4_series(raw)) -> df
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