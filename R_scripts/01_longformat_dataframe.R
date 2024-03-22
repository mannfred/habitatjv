library(here)
library(tidyverse)

# --------------------------------------------
# data from: https://cornell.app.box.com/v/JVeBirdCollab
# import data


# import JV data and filter for specific boundaries (PacificBirds and CIJV)
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


# are all CIJV and PacficBirds species with raster data represented in the JV dataset?
raster_files <- 
  c(list.files(path=here("data/CIJV")), list.files(path=here("data/PacificBirds"))) %>% 
  stringr::str_remove(., "_JV") # change "PacificBirds_JV" to "PacificBirds" to match database convention


spp_w_rasters <- 
  stringr::str_split_i(raster_files, pattern="_", i=2) %>% 
  unique() #515 species 

spp_w_data <- 
  jv_data %>% 
  dplyr::filter(full_name == "CIJV_Boundary_Complete.shp" | full_name == "PacificBirds_JV_Boundary.shp") %>% 
  select(species_code) %>% 
  unique() #506 species



# --------------------------------------------
# find species with missing data


# 12 species have rasters but are not in the JV data
# "brnthr"  "winwre3" "blabit1" "chiegr"  "clrwar1" "fotswi"  "greroa"  "gubter1" "lesnig"  "pinjay" "strher"  "yelrai" 
missing_spp1 <- spp_w_rasters[which(!(spp_w_rasters %in% spp_w_data$species_code))]

# there are  120 CIJV/PacificBirds species with JV data but are not represented in the Rosenberg data
# these species will be automatically filtered out when we left join the Rosenberg data to the JV data
missing_spp2 <- unique(jv_data$species_code)[which(!(unique(jv_data$species) %in% rosenberg_data$species))]

# any overlap?
any(missing_spp1 %in% missing_spp2) #FALSE
missing_spp <- c(missing_spp1, missing_spp2)
saveRDS(missing_spp, file=here("data/rds_files/missing_spp.rds"))




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
  tidyr::pivot_longer(cols = ends_with("prop_pop"), values_to = "prop_pop", names_to = "season") %>% 
  dplyr::mutate(season = str_remove(.$season, "_prop_pop")) %>% 
  dplyr::mutate(file_name_suffix = case_when(season == "nbreeding" & resident == "non-resident" ~ "abundance_full-year_max_21.tif",
                                               season == "breeding" & resident == "non-resident" ~ "breeding_abundance_seasonal_mean_21.tif",
                                               season == "postbreedingm" & resident == "non-resident" ~ "post-breeding_mig_abundance_seasonal_mean_21.tif",
                                               season == "prebreedingm" & resident == "non-resident" ~ "pre-breeding_mig_abundance_seasonal_mean_21.tif",
                                               resident == "resident" ~ "abundance_seasonal_mean_21.tif")) 
file_path <- 
  paste(here("data//"), jv_longformat$JV, sep="") %>% #folder name
  paste(., jv_longformat$JV, sep="/") %>% #JV name
  paste(., jv_longformat$species_code, jv_longformat$resident, jv_longformat$file_name_suffix, sep="_")

# add file paths to dataframe
jv_longformat$file_path <- file_path



# 
# # check that raster files actually exist in dataset
# existing_rasters <- c(list.files(path=here("data/CIJV"), full.names=TRUE), list.files(path=here("data/PacificBirds"), full.names=TRUE))
# 
# which(!(file_path %in% existing_rasters))


# assign stewardship responsibility labels --------------------------------

# From Andrew Huang: for each season, we define “Stewardship Responsibility” as 
# the top 90 percentile of species with the highest proportion

# new column for relative percentiles of proportion of global population
# and new column for JV responsibility designation if in top 90 percentile
jv_longformat <- jv_longformat %>% 
  group_by(full_name) %>% 
  mutate(percentile_pop = percent_rank(prop_pop)) %>% 
  mutate(stewardship_responsibility = if_else(percentile_pop > .9,
                                     "stewardship-responsibility",
                                     "all-species",
                                     missing = "NA")) %>%
  # remove extra rows for the resident species (if same abundance each season)
  # first, change season value to "resident"
  mutate(season = if_else(resident == TRUE,
                          "resident",
                          season)) %>% 
  # then drop duplicate rows with distinct()
  distinct() %>% 
  ungroup()

# save full dataset with priority designations
saveRDS(jv_longformat, file=here("data/rds_files/jv_longformat.rds"))

  
  