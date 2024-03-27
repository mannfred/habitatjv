library(here)
library(terra)
library(tidyverse)


# ----------------------------------------------
#rename files in Pacific Birds folder to match naming convention of CIJV folder
old_names <- list.files(path=here("data/PacificBirds"), full.names=TRUE)
new_names <- gsub("JV_", "", old_names)
file.rename(old_names, new_names)

# find indicies of empty variable combos 
rasters <- readRDS(file=here("data/rds_files/files_to_stack.rds")) 

empty <- 
  rasters %>% 
  sapply(., nrow) %>% 
  {which(.==0)}

real_rasters <- rasters[-c(empty)]


# stack rasters (and exclude empties)
stacked_rasters <- 
  real_rasters %>% 
  rapply(., terra::rast, how="list") %>% 
  lapply(., terra::sprc) %>% 
  lapply(., terra::mosaic, fun="sum")


# ----------------------------------------------
# generate folder tree and populate with `mosaic`ed rasters

# import vector with folder names
variable_combos <- 
  readRDS(file=here("data/rds_files/variable_combos.rds")) %>% 
  dplyr::slice(-c(empty))

# create folder names
folder_names <- 
  sapply(variable_combos, str_replace_all, pattern="_", replacement="/") %>% 
  paste(here(), ., sep="/")

# create directories (be careful, this writes to your local machine!)
sapply(folder_names, dir.create, recursive = TRUE)

# move `mosaic`ed rasters to folder tree
dir_name <- 
  paste(folder_names, variable_combos$value, sep="/") %>% 
  paste(., ".tif", sep="")

mapply(terra::writeRaster, stacked_rasters, dir_name)


