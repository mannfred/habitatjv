library(here)
library(terra)
library(tidyverse)


# import data by breeding type
# create list of file names for prebreeding data
prebreed_paths <- 
  list.files(path=here("data/cijv/"), pattern="pre-breeding") %>% 
  paste0("data/cijv/", .)

# create spatial raster collection (sprc) from marked files
prebreed_data <- terra::sprc(prebreed_paths)

prebreed_list <- terra::as.list(prebreed_data)



alfl<- terra::rast(here("data/cijv/CIJV_aldfly_non-resident_abundance_full-year_max_21.tif"))
alfl2 <- terra::rast(here("data/cijv/CIJV_aldfly_non-resident_post-breeding_mig_abundance_seasonal_mean_21.tif"))

pop_proportion <- 
  here("data/JV_Percent_Bird_Populations_Combined.csv") %>% 
  read.csv() %>%  
  as_tibble()                    


