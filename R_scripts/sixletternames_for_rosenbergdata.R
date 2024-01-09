library(here)
library(tidyverse)


# import data from Rosenberg et al (2019): https://www.science.org/doi/10.1126/science.aaw1313
rosen_data <- 
  readr::read_csv(file=here("data/rosenberg_etal_2019_science.csv")) %>% 
  select(species, breeding_biome, bird_group)
saveRDS(rosen_data, file=here("data/rds_files/rosenberg_data_filtered.rds"))


# import JV data
jv_data <- read_csv(file=here("data/rds_files/JV_Percent_Bird_Populations_Combined.csv"))

# give Rosenberg data six-letter codes for species
# by matching English names in the two datasets
# note: only 495 of 529 species matched

jv_rosen_data <- dplyr::left_join(jv_data, rosen_data, by="species") %>% 
saveRDS(jv_rosen_data, file=here("data/rds_files/jv_data_with_birdgroups_and_biomes.rds"))

  
  
  