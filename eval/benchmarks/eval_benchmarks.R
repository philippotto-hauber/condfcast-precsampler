rm(list = ls())

dir_vintages <- "./../../data/"

list_vintages <- read.csv(paste0(dir_vintages, "list_vintages.csv"), header=F)