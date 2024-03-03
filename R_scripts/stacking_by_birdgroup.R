library(here)
library(terra)
library(tidyverse)


# import raster data by type (abundance as a mean, max, or during migration)
# create list of file names for prebreeding data
prebreed_paths <- 
  list.files(path=here("data/cijv/"), pattern="pre-breeding") %>% 
  paste0("data/cijv/", .)

# create spatial raster collection (sprc) from marked files
# individual files can be read by terra::rast()
prebreed_data <- terra::sprc(prebreed_paths)

prebreed_list <- terra::as.list(prebreed_data)


# import data from Rosenberg et al (2019): https://www.science.org/doi/10.1126/science.aaw1313
rosen_data <- readr::read_csv(file=here("data/rosenberg_etal_2019_science.csv"))
rosen_data


# -----------------------
files <- 
  paste(here(), "/data/cijv/", stringr::str_split_i(files_to_plot_combos_by_season[[1]][[6]], "/", 9), sep="")

# residents
data <- terra::sprc(files)

# stack
stacked_data <- mosaic(data, fun="mean")
writeRaster(stacked_data, here("data/output/forest_generalist_landbird_residents.tif"), overwrite = TRUE)


                   


