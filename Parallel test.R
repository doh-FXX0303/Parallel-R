library(tidyverse) # ggplot2, purrr, dplyr, tidyr, readr, tibble
library(vroom) # reading csv files fast with implicit parallelism
library(parallel) # parallel processing & backend for doParallel
library(doParallel) # parallel processing (foreach loops)
library(furrr) # parallel implementation of purrr 
library(future) # backend for furrr
library(multidplyr) # parallel processing

##I don't like seeing scientific notations in my results
options(scipen = 999)

library(feather)

##change this number to a smaller number if you don't have 32GB RAM.
size <- 35000000

##the number of cores is the number of partitions for the data files
cores <- 10

set.seed(7)
df <- data.frame( 
  split_by   = factor(rep(1:cores, each = size)),
  strata     = factor(rep(1:cores, each = size)),
  factors     = factor(rep(1:5, each = size)),
  price    = runif(size, min = -10, max = 125),
  y     = runif(size, min = 0, max = 2500),
  z     = runif(size, min = -10, max = 25),
  x        = runif(size, min = 0, max = 5000)
) %>%
  tibble::rowid_to_column("rowid")

object.size(df)
paste0(object.size(df)/1000000000," GB")

path <- "my_data.feather"
write_feather(df, path)
df <- read_feather(path)
paste0(object.size(df)/1000000000," GB")
rm(df)
library(disk.frame)
library(feather)
library(data.table)
library(saves)
saves::saves(df.table,overwrite = T, ultra.fast = T)

setup_disk.frame()
# this allows large datasets to be transferred between sessions
options(future.globals.maxSize = Inf)
options(scipen = 999)
paste0(object.size(df)/1000000000," GB")
system.time(df <- as.disk.frame(read_feather(path)))
system.time(df <- as.disk.frame(saves::loads(file = df.table, variables = c("strata","factors","y"),
                                             ultra.fast = T, 
                                             to.data.frame = T)))

df.table <- as.data.table(df)
paste0(object.size(df)/1000000000," GB")
paste0(object.size(df.table)/1000000000," GB")

1.680004432/0.000003552

df2 <- df %>% 
  dplyr::group_by(strata,factors) %>%
  dplyr::summarise(y = mean(y,na.rm = T)) %>% 
  collect()

