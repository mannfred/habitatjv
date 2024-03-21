library(here)
library(tidyverse)


jv_rosen_data <- readRDS(file=here("data/rds_files/jv_data_with_birdgroups_biomes_and_responsibility.rds"))


# ----------------------------------------------
# get permutations of all variables of interest: `breeding_biome` and `bird_group`
# then, filter JV data by all possible `breeding_biome` and `bird_group` and `priority` permutations

biome_group_combos <-
  paste(jv_rosen_data$breeding_biome, jv_rosen_data$bird_group, sep="_") %>% 
  unique() %>% 
  as_tibble() %>% 
  filter(value != "NA_NA")

saveRDS(biome_group_combos, file=here("data/rds_files/biome_group_combos.rds"))


filtered_species_combos <- list()
for (i in 1:nrow(biome_group_combos)){
  
  biome_i <- stringr::str_split_i(biome_group_combos[i,], pattern="_", i=1)
  group_i <- stringr::str_split_i(biome_group_combos[i,], pattern="_", i=2)
  
  filtered_species_combos[[i]] <-
    jv_rosen_data %>% 
    dplyr::filter(breeding_biome == biome_i) %>% 
    dplyr::filter(bird_group == group_i) %>% 
    dplyr::select(species_code) %>% 
    unique()
  
}



# ----------------------------------------------
# use lists of species (generated above) and files 
# associated with each season
 
possible_seasons <- unique(species_filenames_seasons$season)
saveRDS(possible_seasons, file=here("data/rds_files/possible_seasons.rds"))


# "combos" being permutations of biome x bird group
files_to_plot_combos_by_season <- list() 

for (j in 1:length(filtered_species_combos)) {
  
  season_by_birdlist_no_paths <- list()
  season_by_birdlist_w_paths <- list()
  
  for(k in 1:length(possible_seasons)){
    
      season_by_birdlist_no_paths[[k]] <-
        species_filenames_seasons %>% 
        dplyr::filter(species_code %in% filtered_species_combos[[j]]$species_code) %>% 
        dplyr::filter(season == possible_seasons[k]) %>% 
        dplyr::select(file_name)
      
      season_by_birdlist_w_paths[[k]] <- 
        paste0(here(), "/data/cijv/", season_by_birdlist_no_paths[[k]]$file_name)
      
      
      }
  
  files_to_plot_combos_by_season[[j]] <- season_by_birdlist_w_paths
  
}

# inspect list of lists
# files_to_plot_combos_by_season is a list of 21 possible bird group x biome permutations
# each of the 21 elements is a list with six elements: one for each breeding season
# (see: `possible_seasons`)
str(files_to_plot_combos_by_season, max.level=1)
lapply(files_to_plot_combos_by_season[[1]], head)

saveRDS(files_to_plot_combos_by_season, file=here("data/rds_files/files_to_plot_combos_by_season.rds"))

