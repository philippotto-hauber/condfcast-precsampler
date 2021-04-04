rm(list = ls())
setwd("C:/Users/Philipp/Documents/GitHub/condfcast-precsampler/sim")

file_prefix <- "runtime"
dat <- data.frame() # initialize empty data frame
ns_mat <- matrix(c(100, 2, 20, 2, 100, 20), nrow = 2)
for (s in c("CK", "DK", "HS")){
  for (f in c("uncond", "cond_hard")){
    for (ns in seq(1, ncol(ns_mat))){
      filename <- paste(file_prefix, s, f, ns_mat[1, ns], ns_mat[2, ns], sep = "_")
      tmp <- read.csv(paste0(filename, ".csv"), header = TRUE)
      dat <- rbind(dat, data.frame(value = tmp[, 1], sim = seq(1, nrow(tmp)),
                                   sampler = s, ftype = f,
                                   spec = paste(ns_mat[1, ns], ns_mat[2, ns], sep = "_")
                                   )
                   )
    }
  }
}

library(ggplot2)

ggplot(dat, aes(x = spec, y = value, color = sampler))+geom_point()+facet_wrap(~ftype, nrow = 1)
