library(here)
library(tidyverse)

# ------------------------------------------
# From Andrew Huang: for each season, we define “Stewardship Responsibility” as the top 10 percentile of 
# species with the highest proportion

# read in long format jv data
jv_longformat <- readRDS(file=here("data/rds_files/jv_longformat.rds"))

# new column for relative percentiles of proportion of global population
# and new column for JV priority designation if in top 90 percentile
jv_priorities <- jv_longformat %>% 
  group_by(full_name) %>% 
  mutate(percentile_pop = percent_rank(prop_pop)) %>% 
  mutate(jv_priority = if_else(percentile_pop > .9,
                          "TRUE",
                          "FALSE",
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
saveRDS(jv_priorities, file=here("data/rds_files/jv_data_with_birdgroups_biomes_and_priorities.rds"))



