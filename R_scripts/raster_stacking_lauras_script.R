## Author: Laura Farwell, Pacific Birds Habitat Joint Venture
## Date: Nov 2023
## Email: laura_farwell@pacificbirds.org
## Phone: (360) 301-0378


## -------- Script for stacking eBird (Status & Trends) relative abundance rasters ---------

# Load required packages
library(terra)

# Set working directory
setwd("C:/Users/lfarwell/eBird_analyses_2023")

#### Load rasters for each bird group and season of interest (we started w 'abundance_full-year_max_21')

## Option 1: Can do this manually for a small set of rasters
amewig <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_amewig_non-resident_abundance_full-year_max_21.tif")
#brant <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_brant_non-resident_abundance_full-year_max_21.tif")
#mallar3 <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_mallar3_non-resident_abundance_full-year_max_21.tif")
#norpin <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_norpin_non-resident_abundance_full-year_max_21.tif")

## Option 2: Easier with many rasters to first create subfolders containing all of the raster layers you want,
  # for whatever groups of birds you're interested in (e.g., waterfowl, shorebirds)
  # and then load them into R as a list


#### --------------- ANNUAL MAX ------------------

# Import all files in each subfolder as a list using list.files()
wf_annualmax_list <- list.files(path = "./raster_stacks/wf_annualmax_rasters", pattern = ".tif$", all.files = T, full.names = T) 	# wf = waterfowl
sb_annualmax_list <- list.files(path = "./raster_stacks/sb_annualmax_rasters", pattern = ".tif$", all.files = T, full.names = T) 	# sb = shorebirds
wb_annualmax_list <- list.files(path = "./raster_stacks/wb_annualmax_rasters", pattern = ".tif$", all.files = T, full.names = T) 	# wb = waterbirds
wet_annualmax_list <- list.files(path = "./raster_stacks/wet_annualmax_rasters", pattern = ".tif$", all.files = T, full.names = T) 	# wet = wetland landbirds

# Create SpatRasterCollection from each bird group list using sprc()
wf_annualmax_sprc <- sprc(wf_annualmax_list)
sb_annualmax_sprc <- sprc(sb_annualmax_list)
wb_annualmax_sprc <- sprc(wb_annualmax_list)
wet_annualmax_sprc <- sprc(wet_annualmax_list)


#### SUM rasters (sum)
# mosaic relative abundance rasters (differing extents ok, just need same resolution) using mosaic()
  # and the "sum" function (other operators available, e.g. mean)
wf_annualmax_sum <- mosaic(wf_annualmax_sprc, fun = "sum")
sb_annualmax_sum <- mosaic(sb_annualmax_sprc, fun = "sum")
wb_annualmax_sum <- mosaic(wb_annualmax_sprc, fun = "sum")
wet_annualmax_sum <- mosaic(wet_annualmax_sprc, fun = "sum")

# export stacked (sum) rasters
writeRaster(wf_annualmax_sum, "wf_annualmax_sum.tif", overwrite = TRUE)
writeRaster(sb_annualmax_sum, "sb_annualmax_sum.tif", overwrite = TRUE)
writeRaster(wb_annualmax_sum, "wb_annualmax_sum.tif", overwrite = TRUE)
writeRaster(wet_annualmax_sum, "wet_annualmax_sum.tif", overwrite = TRUE)

# Check max values for species rasters, may need to set set threshold for extreme values using clamp()
# ex. wf_annualmax_sum has a max value of 7,666. This will likely "washing out" patterns
# Set values above some threshold value (e.g., 50, 100)
wf_annualmax_sum_max100 <- clamp(wf_annualmax_sum, lower = FALSE, upper = 100, values = TRUE)
writeRaster(wf_annualmax_sum_max100, "wf_annualmax_sum_max100.tif", overwrite = TRUE)
sb_annualmax_sum_max100 <- clamp(sb_annualmax_sum, lower = FALSE, upper = 100, values = TRUE)
writeRaster(sb_annualmax_sum_max100, "sb_annualmax_sum_max100.tif", overwrite = TRUE)


#### AVERAGE rasters (mean)
# mosaic relative abundance rasters (differing extents ok, just need same resolution) using mosaic()
# and the "mean" function (other operators available)
wf_annualmax_avg <- mosaic(wf_annualmax_sprc, fun = "mean")
sb_annualmax_avg <- mosaic(sb_annualmax_sprc, fun = "mean")

# export stacked (mean) rasters
writeRaster(wf_annualmax_avg, "wf_annualmax_avg.tif", overwrite = TRUE)
writeRaster(sb_annualmax_avg, "sb_annualmax_avg.tif", overwrite = TRUE)


#### --------------- SPRING MEAN ------------------

# Import all files in each subfolder as a list using list.files()
wf_springavg_list <- list.files(path = "./raster_stacks/wf_springavg_rasters", pattern = ".tif$", all.files = T, full.names = T)
sb_springavg_list <- list.files(path = "./raster_stacks/sb_springavg_rasters", pattern = ".tif$", all.files = T, full.names = T)

# Create SpatRasterCollection from each bird group list using sprc()
wf_springavg_sprc <- sprc(wf_springavg_list)
sb_springavg_sprc <- sprc(sb_springavg_list)

#### SUM rasters (sum)
# mosaic relative abundance rasters (with differing extents but same resolution) using mosaic()
# and the "sum" function (other operators available)
wf_springavg_sum <- mosaic(wf_springavg_sprc, fun = "sum")
sb_springavg_sum <- mosaic(sb_springavg_sprc, fun = "sum")

# export stacked (sum) rasters
writeRaster(wf_springavg_sum, "wf_springavg_sum.tif", overwrite = TRUE)
writeRaster(sb_springavg_sum, "sb_springavg_sum.tif", overwrite = TRUE)

# Check max values for species rasters, may need to set set threshold for extreme values using clamp()
# ex. wf_annualmax_sum has a max value of 7,666. This is likely "washing out" patterns
# Set values above some threshold value (e.g., 50, 100)
wf_springavg_sum_max100 <- clamp(wf_springavg_sum, lower = FALSE, upper = 100, values = TRUE)
writeRaster(wf_springavg_sum_max100, "wf_springavg_sum_max100.tif", overwrite = TRUE)
sb_springavg_sum_max100 <- clamp(sb_springavg_sum, lower = FALSE, upper = 100, values = TRUE)
writeRaster(sb_springavg_sum_max100, "sb_springavg_sum_max100.tif", overwrite = TRUE)


#### --------------- BREEDING MEAN ------------------

# Import all files in each subfolder as a list using list.files()
wf_breedavg_list <- list.files(path = "./raster_stacks/wf_breedavg_rasters", pattern = ".tif$", all.files = T, full.names = T)
sb_breedavg_list <- list.files(path = "./raster_stacks/sb_breedavg_rasters", pattern = ".tif$", all.files = T, full.names = T)

# Create SpatRasterCollection from each bird group list using sprc()
wf_breedavg_sprc <- sprc(wf_breedavg_list)
sb_breedavg_sprc <- sprc(sb_breedavg_list)

#### SUM rasters (sum)
# mosaic relative abundance rasters (with differing extents but same resolution) using mosaic()
# and the "sum" function (other operators available)
wf_breedavg_sum <- mosaic(wf_breedavg_sprc, fun = "sum")
sb_breedavg_sum <- mosaic(sb_breedavg_sprc, fun = "sum")

# export stacked (sum) rasters
writeRaster(wf_breedavg_sum, "wf_breedavg_sum.tif", overwrite = TRUE)
writeRaster(sb_breedavg_sum, "sb_breedavg_sum.tif", overwrite = TRUE)

# Check max values for species rasters, may need to set set threshold for extreme values using clamp()
# ex. wf_annualmax_sum has a max value of 7,666. This is likely "washing out" patterns
# Set values above some threshold value (e.g., 50, 100)
wf_breedavg_sum_max100 <- clamp(wf_breedavg_sum, lower = FALSE, upper = 100, values = TRUE)
writeRaster(wf_breedavg_sum_max100, "wf_breedavg_sum_max100.tif", overwrite = TRUE)
sb_breedavg_sum_max100 <- clamp(sb_breedavg_sum, lower = FALSE, upper = 100, values = TRUE)
writeRaster(sb_breedavg_sum_max100, "sb_breedavg_sum_max100.tif", overwrite = TRUE)


#### --------------- FALL MEAN ------------------

# Import all files in each subfolder as a list using list.files()
wf_fallavg_list <- list.files(path = "./raster_stacks/wf_fallavg_rasters", pattern = ".tif$", all.files = T, full.names = T)
sb_fallavg_list <- list.files(path = "./raster_stacks/sb_fallavg_rasters", pattern = ".tif$", all.files = T, full.names = T)

# Create SpatRasterCollection from each bird group list using sprc()
wf_fallavg_sprc <- sprc(wf_fallavg_list)
sb_fallavg_sprc <- sprc(sb_fallavg_list)

#### SUM rasters (sum)
# mosaic relative abundance rasters (with differing extents but same resolution) using mosaic()
# and the "sum" function (other operators available)
wf_fallavg_sum <- mosaic(wf_fallavg_sprc, fun = "sum")
sb_fallavg_sum <- mosaic(sb_fallavg_sprc, fun = "sum")

# export stacked (sum) rasters
writeRaster(wf_fallavg_sum, "wf_fallavg_sum.tif", overwrite = TRUE)
writeRaster(sb_fallavg_sum, "sb_fallavg_sum.tif", overwrite = TRUE)

# Check max values for species rasters, may need to set set threshold for extreme values using clamp()
# ex. wf_annualmax_sum has a max value of 7,666. This is likely "washing out" patterns
# Set values above some threshold value (e.g., 50, 100)
wf_fallavg_sum_max100 <- clamp(wf_fallavg_sum, lower = FALSE, upper = 100, values = TRUE)
writeRaster(wf_fallavg_sum_max100, "wf_fallavg_sum_max100.tif", overwrite = TRUE)
sb_fallavg_sum_max100 <- clamp(sb_fallavg_sum, lower = FALSE, upper = 100, values = TRUE)
writeRaster(sb_fallavg_sum_max100, "sb_fallavg_sum_max100.tif", overwrite = TRUE)


#### --------------- WINTER (NON-BREEDING) MEAN ------------------

# Import all files in each subfolder as a list using list.files()
wf_winteravg_list <- list.files(path = "./raster_stacks/wf_winteravg_rasters", pattern = ".tif$", all.files = T, full.names = T)
sb_winteravg_list <- list.files(path = "./raster_stacks/sb_winteravg_rasters", pattern = ".tif$", all.files = T, full.names = T)

# Create SpatRasterCollection from each bird group list using sprc()
wf_winteravg_sprc <- sprc(wf_winteravg_list)
sb_winteravg_sprc <- sprc(sb_winteravg_list)

#### SUM rasters (sum)
# mosaic relative abundance rasters (with differing extents but same resolution) using mosaic()
# and the "sum" function (other operators available)
wf_winteravg_sum <- mosaic(wf_winteravg_sprc, fun = "sum")
sb_winteravg_sum <- mosaic(sb_winteravg_sprc, fun = "sum")

# export stacked (sum) rasters
writeRaster(wf_winteravg_sum, "wf_winteravg_sum.tif", overwrite = TRUE)
writeRaster(sb_winteravg_sum, "sb_winteravg_sum.tif", overwrite = TRUE)

# Check max values for species rasters, may need to set set threshold for extreme values using clamp()
# ex. wf_annualmax_sum has a max value of 7,666. This is likely "washing out" patterns
# Set values above some threshold value (e.g., 50, 100)
wf_winteravg_sum_max100 <- clamp(wf_winteravg_sum, lower = FALSE, upper = 100, values = TRUE)
writeRaster(wf_winteravg_sum_max100, "wf_winteravg_sum_max100.tif", overwrite = TRUE)
sb_winteravg_sum_max100 <- clamp(sb_winteravg_sum, lower = FALSE, upper = 100, values = TRUE)
writeRaster(sb_winteravg_sum_max100, "sb_winteravg_sum_max100.tif", overwrite = TRUE)


#### --------------- SPECIES RICHNESS ------------------

## Note: could not get a 'for-loop' to work w classify() function
## So just loaded + reclassified these by hand
	## Still working on a more elegant solution - see code that doesn't work at bottom

# Load rel abund layers for target species group (e.g., waterfowl spp, below)
amewig <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_amewig_non-resident_abundance_full-year_max_21.tif")
bargol <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_bargol_non-resident_abundance_full-year_max_21.tif")
blksco2 <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_blksco2_non-resident_abundance_full-year_max_21.tif")
buwtea <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_buwtea_non-resident_abundance_full-year_max_21.tif")
brant <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_brant_non-resident_abundance_full-year_max_21.tif")
buffle <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_buffle_non-resident_abundance_full-year_max_21.tif")
cacgoo1 <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_cacgoo1_non-resident_abundance_full-year_max_21.tif")
cangoo <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_cangoo_non-resident_abundance_full-year_max_21.tif")
canvas <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_canvas_non-resident_abundance_full-year_max_21.tif")
cintea <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_cintea_non-resident_abundance_full-year_max_21.tif")
comeid <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_comeid_non-resident_abundance_full-year_max_21.tif")
comgol <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_comgol_non-resident_abundance_full-year_max_21.tif")
commer <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_commer_non-resident_abundance_full-year_max_21.tif")
empgoo <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_empgoo_non-resident_abundance_full-year_max_21.tif")
eurwig <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_eurwig_non-resident_abundance_full-year_max_21.tif")
gadwal <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_gadwal_non-resident_abundance_full-year_max_21.tif")
gresca <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_gresca_non-resident_abundance_full-year_max_21.tif")
gwfgoo <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_gwfgoo_non-resident_abundance_full-year_max_21.tif")
gnwtea <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_gnwtea_non-resident_abundance_full-year_max_21.tif")
harduc <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_harduc_non-resident_abundance_full-year_max_21.tif")
hoomer <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_hoomer_non-resident_abundance_full-year_max_21.tif")
kineid <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_kineid_non-resident_abundance_full-year_max_21.tif")
lessca <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_lessca_non-resident_abundance_full-year_max_21.tif")
lotduc <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_lotduc_non-resident_abundance_full-year_max_21.tif")
mallar3 <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_mallar3_non-resident_abundance_full-year_max_21.tif")
norpin <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_norpin_non-resident_abundance_full-year_max_21.tif")
norsho <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_norsho_non-resident_abundance_full-year_max_21.tif")
rebmer <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_rebmer_non-resident_abundance_full-year_max_21.tif")
redhea <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_redhea_non-resident_abundance_full-year_max_21.tif")
rinduc <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_rinduc_non-resident_abundance_full-year_max_21.tif")
rosgoo <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_rosgoo_non-resident_abundance_full-year_max_21.tif")
rudduc <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_rudduc_non-resident_abundance_full-year_max_21.tif")
snogoo <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_snogoo_non-resident_abundance_full-year_max_21.tif")
steeid <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_steeid_non-resident_abundance_full-year_max_21.tif")
sursco <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_sursco_non-resident_abundance_full-year_max_21.tif")
truswa <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_truswa_non-resident_abundance_full-year_max_21.tif")
tunswa <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_tunswa_non-resident_abundance_full-year_max_21.tif")
whwsco2 <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_whwsco2_non-resident_abundance_full-year_max_21.tif")
wooduc <- rast("./PBHJV_eBird_rasters/PacificBirds_JV_wooduc_non-resident_abundance_full-year_max_21.tif")

# Convert rel abundance layers to presence/absence (0, 1) ----- THIS WORKS -----
amewig_rich <- classify(amewig, rcl, include.lowest = F)
bargol_rich <- classify(bargol, rcl, include.lowest = F)
blksco2_rich <- classify(blksco2, rcl, include.lowest = F)
buwtea_rich <- classify(buwtea, rcl, include.lowest = F)
brant_rich <- classify(brant, rcl, include.lowest = F)
buffle_rich <- classify(buffle, rcl, include.lowest = F)
cacgoo1_rich <- classify(cacgoo1, rcl, include.lowest = F)
cangoo_rich <- classify(cangoo, rcl, include.lowest = F)
canvas_rich <- classify(canvas, rcl, include.lowest = F)
cintea_rich <- classify(cintea, rcl, include.lowest = F)
comeid_rich <- classify(comeid, rcl, include.lowest = F)
comgol_rich <- classify(comgol, rcl, include.lowest = F)
commer_rich <- classify(commer, rcl, include.lowest = F)
empgoo_rich <- classify(empgoo, rcl, include.lowest = F)
eurwig_rich <- classify(eurwig, rcl, include.lowest = F)
gadwal_rich <- classify(gadwal, rcl, include.lowest = F)
gresca_rich <- classify(gresca, rcl, include.lowest = F)
gwfgoo_rich <- classify(gwfgoo, rcl, include.lowest = F)
gnwtea_rich <- classify(gnwtea, rcl, include.lowest = F)
harduc_rich <- classify(harduc, rcl, include.lowest = F)
hoomer_rich <- classify(hoomer, rcl, include.lowest = F)
kineid_rich <- classify(kineid, rcl, include.lowest = F)
lessca_rich <- classify(lessca, rcl, include.lowest = F)
lotduc_rich <- classify(lotduc, rcl, include.lowest = F)
mallar3_rich <- classify(mallar3, rcl, include.lowest = F)
norpin_rich <- classify(norpin, rcl, include.lowest = F)
norsho_rich <- classify(norsho, rcl, include.lowest = F)
rebmer_rich <- classify(rebmer, rcl, include.lowest = F)
redhea_rich <- classify(redhea, rcl, include.lowest = F)
rinduc_rich <- classify(rinduc, rcl, include.lowest = F)
rosgoo_rich <- classify(rosgoo, rcl, include.lowest = F)
rudduc_rich <- classify(rudduc, rcl, include.lowest = F)
snogoo_rich <- classify(snogoo, rcl, include.lowest = F)
steeid_rich <- classify(steeid, rcl, include.lowest = F)
sursco_rich <- classify(sursco, rcl, include.lowest = F)
truswa_rich <- classify(truswa, rcl, include.lowest = F)
tunswa_rich <- classify(tunswa, rcl, include.lowest = F)
whwsco2_rich <- classify(whwsco2, rcl, include.lowest = F)
wooduc_rich <- classify(wooduc, rcl, include.lowest = F)

# Combine richness layers into a list
wf_rich_list <- list(amewig_rich, bargol_rich, blksco2_rich, buwtea_rich, brant_rich,
                     buffle_rich, cacgoo1_rich, cangoo_rich, canvas_rich, cintea_rich,
                     comeid_rich, comgol_rich, commer_rich, empgoo_rich, eurwig_rich,
                     gadwal_rich, gresca_rich, gwfgoo_rich, gnwtea_rich, harduc_rich,
                     hoomer_rich, kineid_rich, lessca_rich, lotduc_rich, mallar3_rich,
                     norpin_rich, norsho_rich, rebmer_rich, redhea_rich, rinduc_rich,
                     rosgoo_rich, rudduc_rich, snogoo_rich, steeid_rich, sursco_rich,
                     truswa_rich, tunswa_rich, whwsco2_rich, wooduc_rich)

# Create SpatRasterCollection from bird group list using sprc()
wf_rich_sprc <- sprc(wf_rich_list)

#### SUM rasters (sum)
# mosaic presence/absence rasters (differing extents ok, just need same resolution) using mosaic()
# and the "sum" function
wf_rich_sum <- mosaic(wf_rich_sprc, fun = "sum")

# export stacked (sum) rasters
writeRaster(wf_rich_sum, "wf_richness.tif", overwrite = TRUE)



##---------- FIX THIS LATER - APP() FUNCTION WON'T RUN w/ CLASSIFY() --------

# Write a classify() function so any pixel >0 to 10000 becomes 1 (from, to, becomes)
m <- c(0, 100000, 1)
rcl <- matrix(m, ncol=3, byrow = T)
# This works
amewig_rich <- classify(amewig, rcl, include.lowest = F) # don't want to include zero

# Write function to do the above
spp_rich <- function(i){classify(i, rcl, include.lowest = F)}

# Create a SpatRasterDataset to apply classify() function ----- THIS DOESN'T WORK -----
wf_sds <- sds(wf_annualmax_list)
wf_rich <- app(wf_sds, fun = "spp_rich")

# Alternatively, try using a for-loop ----- THIS DOESN'T WORK -----
for (i in 1:length(wf_sds)) {classify(i, rcl, include.lowest = F)}


