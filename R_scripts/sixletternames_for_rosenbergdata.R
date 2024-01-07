library(here)
library(tidyverse)


# import data from Rosenberg et al (2019): https://www.science.org/doi/10.1126/science.aaw1313
rosen_data <- readr::read_csv(file=here("data/rosenberg_etal_2019_science.csv"))

# import JV data
jv_data <- read_csv(file=here("data/JV_Percent_Bird_Populations_Combined.csv"))

# give Rosenberg data six-letter codes for species
# by matching English names in the two datasets
# note: only 495 of 529 species matched

rosen_data <- dplyr::inner_join(rosen_data, jv_data, by="species")

  
  
  