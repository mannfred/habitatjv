library(here)
library(tidyverse)


# ---------------------------------------
# inspect stacked rasters by plotting 
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




# ----------------------------------------------
# check that all original files are in sorted folders
# we expect 16 CIJV species to have not been sorted (see: "sixletternames_for_rosenbergdata.R")
missing_spp1 <- readRDS(file=here("data/rds_files/missing_spp1.rds"))
missing_spp2 <- readRDS(file=here("data/rds_files/missing_spp2.rds"))


sorted_files <- 
  list.files(here("data/output"), recursive=TRUE, pattern="\\.tif") %>% 
  basename()

all(cijv_folder %in% sorted_files) # FALSE, there are missing files

# there are 47 files from 16 species missing
missing_files <- cijv_folder[which(!(cijv_folder %in% sorted_files))]
missing_spp3 <- stringr::str_split_i(missing_files, pattern="_", i=2) %>% unique

# the species missing in the sorted folders are the 
# same as those identified in "sixletternames_for_rosenbergdata.R"
# note: `missing_spp1` and `missing_spp2` can be created in the R file stated above
identical(sort(missing_spp3), sort(c(missing_spp1, missing_spp2))) #TRUE


