library(here)
library(terra)
library(tidyverse)


# ----------------------------------------------


#rename files in Pacific Birds folder to match naming convention of CIJV folder
old_names <- list.files(path=here("data/PacificBirds"), full.names=TRUE)
new_names <- gsub("JV_", "", old_names)
file.rename(old_names, new_names)

# stack rasters 
file_combos <- readRDS( file=here("data/rds_files/files_to_stack.rds"))


rasters <- rapply(file_combos, terra::rast, how="list")

# import list of file names for stacking
files_to_plot_combos_by_season <- readRDS(file=here("data/rds_files/files_to_plot_combos_by_season.rds"))


# import grouped rasters using file names
# stack by group
imported_rasters <- rapply(files_to_plot_combos_by_season, terra::rast, how="list")

test <- 
  file_combos[[1]][[1]][1] %>% 
  terra::sprc() %>% 
  terra::merge()
  
