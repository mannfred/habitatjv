library(here)
library(tidyverse)

# --------------------------------------------
# import data


# import JV data and filter for specific boundaries (Pacific and CIJV)
# 804 rows (species) some overlapping between boundaries)
jv_data <- 
  read_csv(file=here("data/JV_Percent_Bird_Populations_Combined.csv")) %>% 
  dplyr::filter(
    full_name == "PacificBirds_JV_Boundary.shp" | 
    full_name == "CIJV_Boundary_Complete.shp") %>% 
  dplyr::rename(resident = Resident) %>% 
  dplyr::mutate(resident = if_else(resident == TRUE, "resident", "non-resident", missing=NA))

# import data from Rosenberg et al (2019): https://www.science.org/doi/10.1126/science.aaw1313
# only 529 species represented, so there may not be complete overlap with `jv_data`
rosenberg_data <- 
  readr::read_csv(file=here("data/rosenberg_etal_2019_science.csv")) %>% 
  select(species, breeding_biome, bird_group)


# --------------------------------------------
# inspecting imported data


# are all CIJV species with raster data represented in the JV dataset?
cijv_folder <- list.files(path=here("data/CIJV"))
cijv_spp_w_rasters <- 
  stringr::str_split_i(cijv_folder, pattern="_", i=2) %>% 
  unique() #320 species 

cijv_spp_w_data <- 
  jv_data %>% 
  dplyr::filter(full_name == "CIJV_Boundary_Complete.shp") %>% 
  select(species_code) %>% 
  unique() #317 species

# 3 CIJV species have rasters but are not in the JV data
# "brnthr"  "whrsan"  "winwre3"
missing_spp1 <- cijv_spp_w_rasters[which(!(cijv_spp_w_rasters %in% cijv_spp_w_data$species_code))]
saveRDS(missing_spp1, file=here("data/rds_files/missing_spp1.rds"))

# there are  13 CIJV species with JV data but are not represented in the Rosenberg data
# therefore 13+3 (16) CIJV species with raster data will not be sorted
missing_spp2 <- jv_data$species_code[which(!(jv_data$species %in% rosenberg_data$species) & jv_data$full_name=="CIJV_Boundary_Complete.shp")]
saveRDS(missing_spp2, file=here("data/rds_files/missing_spp2.rds"))



# --------------------------------------------
# construct main dataset that will be referenced in the rest of the pipeline

# give Rosenberg data six-letter codes for species
# by matching English names in the two datasets
jv_rosen_data <- 
  dplyr::left_join(jv_data, rosenberg_data, by="species") %>% 
  tidyr::drop_na()

# migrating species have four unique "proportion of population" entries,
# one each for pre-, post-, breeding, and non-breeding abundances
# here, we transform the data to long format so that migrating species get four rows,
# each row with a unique `prop_pop` entry
jv_longformat <-
  jv_rosen_data %>% 
  tidyr::pivot_longer(cols = ends_with("prop_pop"), values_to = "prop_pop", names_to = "breeding_season") %>% 
  dplyr::mutate(breeding_season = str_remove(.$breeding_season, "_prop_pop")) 

saveRDS(jv_longformat, file=here("data/rds_files/jv_longformat.rds"))

  
  