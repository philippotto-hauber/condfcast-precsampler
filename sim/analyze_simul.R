rm(list = ls())
setwd("C:/Users/Philipp/Documents/GitHub/condfcast-precsampler/sim")

library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)

#- set-up----
dir_in <- "./../../../Dissertation/condfcast-precsampler/sim/out/"
file_prefix <- "runtime"
Ng <- 10
models <- c(rep("ssm", 3), rep("var", 3))

dims = c("Nt_100_Nh_5_Nn_20_Ns_2",
         "Nt_100_Nh_5_Nn_100_Ns_2",
         "Nt_100_Nh_5_Nn_100_Ns_10",
         "Nt_100_Nh_5_Nn_3_Np_4",
         "Nt_100_Nh_5_Nn_20_Np_4",
         "Nt_100_Nh_5_Nn_100_Np_4")

ftypes = c("uncond", "cond_hard", "cond_soft")

samplers <- c("CK", "DK", "HS")

#- names for factor levels----
names_samplers <- c("Carter&Kohn (1994)", "Durbin&Koopman (2002)", "precision-sampler")
names_ftypes <- c("unconditional forecasts", "conditional forecasts (hard)", "conditional forecasts (soft)")
names_dims = c("small factor model",
               "large factor model",
               "large N,T factor model",
               "small-sized VAR",
               "medium-sized VAR",
               "large-sized VAR")

#- loop----
dat <- data.frame() # initialize empty data frame

for (g in seq(1, Ng)){
  for (s in samplers){
    for (f in ftypes){
      for (d in seq(1, length(dims))){
        filename <- paste(file_prefix, s, f, models[d], dims[d], "g", g, sep = "_")
        tmp <- read.csv(paste0(dir_in, filename, ".csv"), header = FALSE)
        dat <- rbind(dat, data.frame(value = tmp[, 1], sim = g,
                                     sampler = s, ftype = f, spec = dims[d]
                                     )
                     )
      }
    }
  }
}

#- plots for analysis----

# box plots
dat %>% 
  ggplot(aes(x = spec, y = value, color = sampler))+
  geom_boxplot()+
  facet_wrap(~ftype, ncol = 1, scales = "free_y")+
  theme(text = element_text(size=9),
        axis.text.x = element_text(angle=90, hjust = 1),
        legend.position="top")


# first run of simulatuions
dat %>% 
  filter(sim == 1) %>%
  ggplot(aes(x = spec, y = value, color = sampler))+
  geom_point()+
  facet_wrap(~ftype, ncol = 1, scales = "free_y")+
  theme(text = element_text(size=9),
        axis.text.x = element_text(angle=90, hjust = 1),
        legend.position="top")

#- plots for paper----

# relative runtime (precision-sampler = 1)
dat %>% 
pivot_wider(names_from = sampler, values_from = value) %>%
  mutate(HS = HS / HS,
         CK = CK / HS,
         DK = DK / HS) %>%
  pivot_longer(cols = -c(sim, ftype, spec), names_to = "sampler", values_to = "value") -> dat

# convert strings to factors----
dat$spec <- factor(dat$spec, levels = dims, labels = names_dims)
dat$ftype <- factor(dat$ftype, levels = ftypes, labels = names_ftypes)
dat$sampler <- factor(dat$sampler, levels = samplers, labels = names_samplers)

# re-do plot
dat %>% 
  filter(sim == 1,
         !(sampler == "precision-sampler"),
         !(ftype == "unconditional forecasts"),
         !(spec %in% c("large factor model", "small-sized VAR"))) %>%
  ggplot(aes(x = spec, y = value, shape = sampler))+
  geom_point()+
  scale_shape(solid = FALSE)+
  scale_y_continuous(trans='log10', breaks = c(0.5, 1, 5, 10, 30))+
  #scale_y_log10(breaks = c(1, 5, 10, 30))+
  #scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x))+
                  #labels = trans_format("log10", math_format(10^.x)))+
  facet_wrap(~ftype, ncol = 1)+
  theme_bw()+
  theme(text = element_text(size=9),
        legend.position="top", legend.title = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.text.x = element_text(angle=60, hjust = 1),
        axis.title.x = element_blank(),
        axis.title.y = element_blank()) 
