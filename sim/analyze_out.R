rm(list = ls())
setwd("C:/Users/Philipp/Documents/GitHub/condfcast-precsampler/sim")

library(ggplot2)
library(dplyr, tidyr)

dir_in <- "./out/"

dims = c("Nt_100_Nh_5_Nn_100_Ns_2",
         "Nt_100_Nh_5_Nn_20_Ns_2",
         "Nt_100_Nh_5_Nn_100_Ns_20",
         "Nt_100_Nh_5_Nn_20_Ns_25")

ftypes = c("uncond", "cond_hard", "cond_soft")

samplers <- c("CK", "DK", "HS")

file_prefix <- "runtime"

dat <- data.frame() # initialize empty data frame

for (s in samplers){
  for (f in ftypes){
    for (d in dims){
      filename <- paste(file_prefix, s, f, d, sep = "_")
      tmp <- read.csv(paste0(dir_in, filename, ".csv"), header = FALSE)
      dat <- rbind(dat, data.frame(value = tmp[, 1], sim = seq(1, nrow(tmp)),
                                   sampler = s, ftype = f, spec = d
                                   )
                   )
    }
  }
}


dat %>% 
  ggplot(aes(x = spec, y = value, color = sampler))+
    geom_boxplot()+
    facet_wrap(~ftype, nrow = 1)+
    theme(text = element_text(size=9),
        axis.text.x = element_text(angle=90, hjust = 1)) 

