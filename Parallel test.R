library(tidyverse) # ggplot2, purrr, dplyr, tidyr, readr, tibble
library(vroom) # reading csv files fast with implicit parallelism
library(parallel) # parallel processing & backend for doParallel
library(doParallel) # parallel processing (foreach loops)
library(furrr) # parallel implementation of purrr 
library(future) # backend for furrr
library(multidplyr) # parallel processing

##I don't like seeing scientific notations in my results
options(scipen = 999)

newdata <- data.frame(a = "1")