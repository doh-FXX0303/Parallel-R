library(disk.frame)
library(feather)
library(data.table)
library(saves)
library(tidyverse)
options(scipen = 999)

##change this number to a smaller number if you don't have 32GB RAM.
##this will create a dataset roughly 6GB - 10GB in size.
size <- 12500000 * 2

##Large Data Ideas
df.large <- data.frame(
  split_by   = factor(rep(1:5, each = size)),
  strata     = factor(rep(1:5, each = size)),
  factors     = factor(rep(1:5, each = size)),
  price    = runif(size, min = -10, max = 125),
  y     = runif(size, min = 0, max = 2500),
  z     = runif(size, min = -10, max = 25),
  x        = runif(size, min = 0, max = 5000)
) %>%
  tibble::rowid_to_column("rowid")

object.size(df.large)
paste0(object.size(df.large) / 1000000000, " GB")

##Export on Disk
data.table::fwrite(df.large, file = "data_table.csv")
##saves save it into the working directory -- set ultra.fast = F to compress the files smaller
saves::saves(df.large,
             overwrite = T,
             ##only make ultra.fast = T if you do not want to compress/decompress the files
             ##ultra.fast = F doesn't seem to be working
             ultra.fast = T)
feather::write_feather(df.large, "my_data.feather")

##Check Size on Disk in GB
file.info("my_data.feather")$size / 1000000000
file.info("data_table.csv")$size / 1000000000
list_files <- lapply(list.files(path = "df.large", pattern = ".RData", full.names = T),
               function(f){file.info(f)$size})
saves.size <- do.call("rbind",list_files) %>% as.data.frame()
sum(saves.size$V1)/ 1000000000

##Read and convert into as.disk.frame()
system.time(df.large.table <- as.disk.frame(data.table::fread("data_table.csv",
                                                           select = c(
                                                             "strata", "factors", "y"
                                                           ))))

system.time(df.large.feather <- disk.frame::as.disk.frame(feather::read_feather("my_data.feather",
                                                     columns = c(
                                                       "strata", "factors", "y"
                                                     ))))

system.time(df.large.saves <- disk.frame::as.disk.frame(
  saves::loads(
    file = "df.large",
    variables = c("strata", "factors", "y"),
    ultra.fast = T,
    to.data.frame = T
  )
))

##object size in RAM GB after conversion to disk.frame
paste0(object.size(df.large.table) / 1000000000, " GB")
paste0(object.size(df.large.feather) / 1000000000, " GB")
paste0(object.size(df.large.saves) / 1000000000, " GB")