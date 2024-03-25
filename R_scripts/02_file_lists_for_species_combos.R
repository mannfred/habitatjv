library(here)
library(tidyverse)


jv_rosen_data <- readRDS(file=here("data/rds_files/jv_longformat.rds"))


# ----------------------------------------------
# get permutations of all variables of interest: JV, responsibility, birdgroup, breeding biome, and season
# then, filter JV data by all possible permutations

variable_combos <-
  paste(jv_rosen_data$JV, jv_rosen_data$stewardship_responsibility, jv_rosen_data$bird_group, jv_rosen_data$breeding_biome, jv_rosen_data$season, sep="_") %>% 
  unique() %>% 
  as_tibble()

saveRDS(variable_combos, file=here("data/rds_files/variable_combos.rds"))



file_combos <- list()
for (i in 1:nrow(variable_combos)){
  
  jv_i <- stringr::str_split_i(variable_combos[i,], pattern="_", i=1)
  responsibility_i <- stringr::str_split_i(variable_combos[i,], pattern="_", i=2)
  group_i <- stringr::str_split_i(variable_combos[i,], pattern="_", i=3)
  biome_i <- stringr::str_split_i(variable_combos[i,], pattern="_", i=4)
  season_i <- stringr::str_split_i(variable_combos[i,], pattern="_", i=5)
 
  if (responsibility_i == "stewardship-responsibility") { 
    
    # limit to species that are of stewardship responsibility
    file_combos[[i]] <- 
      jv_rosen_data %>% 
      dplyr::filter(JV == jv_i) %>% 
      dplyr::filter(stewardship_responsibility == "stewardship-responsibility") %>% 
      dplyr::filter(bird_group == group_i) %>% 
      dplyr::filter(breeding_biome == biome_i) %>% 
      dplyr::filter(season == season_i) %>% 
      dplyr::select(file_path) %>% 
      unique()
  }
  
  else {
    
    # include species that are of stewardship responsibility and non-stewardship responsibility
    file_combos[[i]] <- 
      jv_rosen_data %>% 
      dplyr::filter(JV == jv_i) %>% 
      dplyr::filter(stewardship_responsibility == "stewardship-responsibility" | stewardship_responsibility == "all-species") %>% 
      dplyr::filter(bird_group == group_i) %>% 
      dplyr::filter(breeding_biome == biome_i) %>% 
      dplyr::filter(season == season_i) %>% 
      dplyr::select(file_path) %>% 
      unique()
    
  }
}

# not all variable permutations have associtated raster data 
# e.g. yellow-throated warbler (PacificBirds JV) has 4 entries in JV dataframe, but only 2 are represented in raster folder
# remove names from `file_combos` that don't actually exist as raster data
raster_files <- list.files(path=here("data/"), pattern=".tif", recursive=TRUE, full.names=TRUE)

real_files <- lapply(file_combos, function(q) {q %>% dplyr::filter(file_path %in% raster_files)}) 
saveRDS(real_files, file=here("data/rds_files/files_to_stack.rds"))


