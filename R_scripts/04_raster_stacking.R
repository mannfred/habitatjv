library(here)
library(rnaturalearth)
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


# ---------------------------------------
# inspect by plotting 
# from Strimas-Mackey: https://ebird.github.io/ebirdst/articles/applications.html#map-extent
region_boundary <- rnaturalearth::ne_countries(country = c("canada", "united states of america"))

# project boundary to match raster data
test_raster <- rast(old_names[1])
region_boundary_proj <- st_transform(region_boundary, st_crs(test_raster))

# crop and mask to boundary
raster_masked <- 
  crop(stacked_rasters[[1]], region_boundary_proj) %>% 
  mask(region_boundary_proj)

# find the centroid of the region
region_centroid <-
  region_boundary %>% 
  st_geometry() %>%  
  st_transform(crs = 4326) %>%  
  st_centroid() %>%  
  st_coordinates() %>%  
  round(1)

# define projection
crs_laea <- paste0("+proj=laea +lat_0=", region_centroid[2],
                   " +lon_0=", region_centroid[1])

raster_laea <- terra::project(raster_masked[[1]], crs_laea, method="near") |> 
  # remove areas of the raster containing no data
  trim()  
