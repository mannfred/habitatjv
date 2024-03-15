library(here)
library(tidyverse)

# ------------------------------------------
# From Andrew Huang: for each season, we define “Stewardship Priority” as the top 10 percentile of 
# species with the highest proportion

# Here, we start with the Canadian Intermountain JV
cijv_data <- 
  readRDS(file=here("data/rds_files/jv_longformat.rds")) %>% 
  dplyr::filter(full_name == "CIJV_Boundary_Complete.shp")

# new column for relative percentiles of proportion of global population
# and new column for JV priority designation if in top 90 percentile
cijv_data <- cijv_data %>% 
  mutate(percentile_pop = percent_rank(prop_pop)) %>% 
  mutate(top_90 = if_else(percentile_pop > .9,
                          "TRUE",
                          "FALSE",
                          missing = "NA"))


# Now, find priority species for Pacific Birds JV
pbjv_data <- 
  readRDS(file=here("data/rds_files/jv_data_with_birdgroups_and_biomes.rds")) %>% 
  dplyr::filter(full_name == "PacificBirds_JV_Boundary.shp")

pbjv_data <- pbjv_data %>% 
  mutate(percentile_pop = percent_rank(prop_pop)) %>% 
  mutate(top_90 = if_else(percentile_pop > .9,
                          "TRUE",
                          "FALSE",
                          missing = "NA"))

# create new dataframe with new priority columns
jv_rosen_data <- dplyr::bind_rows(pbjv_data, cijv_data)
saveRDS(jv_rosen_data, file=here("data/rds_files/jv_data_with_birdgroups_biomes_and_priorities.rds"))




# older priority designation code  ----------------------------------------

# 294 species for CIJV 
migrants <- cijv_data[which(cijv_data$Resident=="FALSE"),]
unique(migrants$species) # 261 spp

residents <- cijv_data[which(cijv_data$Resident=="TRUE"),]
unique(residents$species) # 33 spp



  

# ------------------------------------------
# find priority species for residents

# proportion on population should be the same for all four seasons
residents %>% select(6:10) 

# find resident species with the highest proportion of the global population
priority_finder <- 
  function(migrant_type=c(migrants, residents), 
           season=c("breeding_prop_pop", "nbreeding_prop_pop", 
                    "prebreedingm_prop_pop", "postbreedingm_prop_pop")) {

    migrant_type %>%  
    dplyr::filter(migrant_type[[season]] > quantile(migrant_type[[season]], 0.90, na.rm=TRUE)) 
    }


# assign priority for residents
priority_residents <- priority_finder(migrant_type=residents, season="breeding_prop_pop")

cijv_data$priority_resident <-
       ifelse(cijv_data$species_code %in% priority_residents$species_code, "TRUE", "FALSE")


# ------------------------------------------
# find CIJV species with the highest proportion of the global population over the course of migration
priority_prebreeding <- priority_finder(migrant_type=migrants, season="prebreedingm_prop_pop")

priority_breeding <- priority_finder(migrant_type=migrants, season="breeding_prop_pop")
 
priority_postbreeding <- priority_finder(migrant_type=migrants, season="postbreedingm_prop_pop")
 
priority_nonbreeding <- priority_finder(migrant_type=migrants, season="nbreeding_prop_pop")


# assign priority for migrants
# use same naming conventions as filenames:
# [1] "non-resident_abundance_full-year"   "non-resident_breeding_abundance"   
# [3] "non-resident_post-breeding_mig"     "non-resident_pre-breeding_mig"     
# [5] "non-resident_nonbreeding_abundance" "resident_abundance_seasonal" 

cijv_data$"priority_pre-breeding" <-
  ifelse(cijv_data$species_code %in% priority_prebreeding$species_code, "TRUE", "FALSE")

cijv_data$"priority_post-breeding" <-
  ifelse(cijv_data$species_code %in% priority_postbreeding$species_code, "TRUE", "FALSE")

cijv_data$"priority_nonbreeding" <-
  ifelse(cijv_data$species_code %in% priority_nonbreeding$species_code, "TRUE", "FALSE")

cijv_data$"priority_breeding" <-
  ifelse(cijv_data$species_code %in% priority_breeding$species_code, "TRUE", "FALSE")



# ------------------------------------------
# find priority species for Pacific Birds
pbjv_data <- 
  readRDS(file=here("data/rds_files/jv_data_with_birdgroups_and_biomes.rds")) %>% 
  dplyr::filter(full_name == "PacificBirds_JV_Boundary.shp")

# 487 entries for PBJV
migrants <- pbjv_data[which(pbjv_data$Resident=="FALSE"),]
residents <- pbjv_data[which(pbjv_data$Resident=="TRUE"),]


# assign priority for residents
priority_residents <- priority_finder(migrant_type=residents, season="breeding_prop_pop")

pbjv_data$priority_resident <-
  ifelse(pbjv_data$species_code %in% priority_residents$species_code, "TRUE", "FALSE")


# ------------------------------------------
# find species with the highest proportion of the global population over the course of migration
priority_prebreeding <- priority_finder(migrant_type=migrants, season="prebreedingm_prop_pop")

priority_breeding <- priority_finder(migrant_type=migrants, season="breeding_prop_pop")

priority_postbreeding <- priority_finder(migrant_type=migrants, season="postbreedingm_prop_pop")

priority_nonbreeding <- priority_finder(migrant_type=migrants, season="nbreeding_prop_pop")


# assign priority for migrants
pbjv_data$"priority_pre-breeding" <-
  ifelse(pbjv_data$species_code %in% priority_prebreeding$species_code, "TRUE", "FALSE")

pbjv_data$"priority_post-breeding" <-
  ifelse(pbjv_data$species_code %in% priority_postbreeding$species_code, "TRUE", "FALSE")

pbjv_data$"priority_nonbreeding" <-
  ifelse(pbjv_data$species_code %in% priority_nonbreeding$species_code, "TRUE", "FALSE")

pbjv_data$"priority_breeding" <-
  ifelse(pbjv_data$species_code %in% priority_breeding$species_code, "TRUE", "FALSE")

# create new dataframe with priority info
jv_rosen_data <- dplyr::bind_rows(pbjv_data, cijv_data)
saveRDS(jv_rosen_data, file=here("data/rds_files/jv_data_with_birdgroups_biomes_and_priorities.rds"))

