library(here)
library(terra)
library(tidyverse)


# ----------------------------------------------
# stack rasters by group and export

# import list of file names for stacking
files_to_plot_combos_by_season <- readRDS(file=here("data/rds_files/files_to_plot_combos_by_season.rds"))


# import grouped rasters using file names
# stack by group
imported_rasters <- rapply(files_to_plot_combos_by_season, terra::rast, how="list")

test <- 
  files_to_plot_combos_by_season[[1]][[1]] %>% 
  terra::sprc() %>% 
  terra::merge()
  
