library(here)
library(terra)
library(tidyverse)

# import raster data by type (abundance as a mean, max, or during migration)
# create list of file names for rasters depicting maximum abundance 
paths_max_abun <- 
  list.files(path=here("data/cijv/"), pattern="max") %>% 
  paste0("data/cijv/", .)

# extract species names from file names
spp_max_abun <- substr(paths_max_abun, start=16, stop=21)
spp_max_abun #284 species

# import data from Rosenberg et al (2019): https://www.science.org/doi/10.1126/science.aaw1313
rosen_data <- readr::read_csv(file=here("data/rosenberg_etal_2019_science.csv"))


# give Rosenberg data six-letter codes for species
rosen_data$sixletter <- 
  
  
  
# do all species with rasters have habitat data available?
all(spp_max_abun %in% rosen_data$species)


# create spatial raster collection (sprc) from paths
# note: individual files can be read by terra::rast()
data_average_abun <- terra::sprc(paths_average_abun)

prebreed_list <- terra::as.list(prebreed_data)


