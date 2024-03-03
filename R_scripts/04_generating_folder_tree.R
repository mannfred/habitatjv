library(here)
library(tidyverse)



# ----------------------------------------------
# import data from "generating_file_lists_for_species_combos.R"
biome_group_combos <- readRDS(file=here("data/rds_files/biome_group_combos.rds"))
possible_seasons <- readRDS(file=here("data/rds_files/possible_seasons.rds"))


# ----------------------------------------------
# create folder tree to house sorted raster files

### WORKING ON THIS
boundary_folders <- paste(here("data/output/"), c("/cijv", "/pbjv"), sep="")
priority_folders <- sapply(boundary_folders, paste, c("/priority_species", "/all_species"), sep="")



sapply(priority_folders, dir.create)

root_directory <- paste(here("data/output"), biome_group_combos$value, sep = "/")
sapply(root_directory, dir.create)
####



# create subfolders names using season types
f <- function(x) {paste(x, possible_seasons, sep = "/")}
sub_directories <- sapply(root_directory, f)

# create the subdirs
sapply(sub_directories, dir.create)



# ----------------------------------------------
# put rasters into their designated folders

# procedure for every file:
# (1) look at the second string in `cijv_folder`
# (2) if it matches a row in `jv_rosen_data`, 
# then find and concatenate its `Breeding biome` and `bird group` columns
# (3) find the matching folder in `data/outputs`
# (4) look at the third, fourth, and fifth strings in the file name
# (5) match to the corresponding subfolder and copy to destination
cijv_folder <- list.files(path=here("data/cijv"))



g <- function(k) {
  
  species_in_filename <- 
    k %>% 
    stringr::str_remove(".tif") %>% 
    stringr::str_split(pattern="_") %>% 
    lapply(., "[", 2) %>% 
    lapply(., paste, collapse = "_") %>%
    unlist()
  
  row_number <- 
    which(jv_rosen_data$JV=="CIJV" & jv_rosen_data$species_code==species_in_filename)
  
  species_with_biome_group <-
    paste(jv_rosen_data[row_number,]$breeding_biome, jv_rosen_data[row_number,]$bird_group, sep="_")
  
  target_folder <- 
    k %>% 
    stringr::str_remove(".tif") %>% 
    stringr::str_split(pattern="_") %>% 
    lapply(., "[", c(3:5)) %>% 
    lapply(., paste, collapse = "_") %>%
    unlist()
  
  target_directory <- paste(here("data/output"), species_with_biome_group, target_folder, sep="/")
  
  origin_directory <- paste(here("data/cijv"), k, sep="/")
  
  file.copy(from=origin_directory, to=target_directory)
  
}

# sort files into folders
sapply(cijv_folder, g)                



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


