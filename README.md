Background

The Cornell Lab of Ornithology (CLO) houses the data generated by “eBird” (https://ebird.org), one of the largest citizen science initiatives in existence with over 100 million observations contributed annually. These data are updated and released annually as “eBird Status and Trends”, including rasters describing relative population densities for ~2421 species. ECCC obtained raster data from the CLO for >300 species falling within the Pacific Birds and Canadian Intermountain Joint Ventures (JV). These rasters have been specially generated by eBird research scientists to be cropped to the JV boundaries of interest. The objective of this contract was to construct a pipeline to annotate and stack these raster data as a demonstration of the possibilities and potential tools that could be created from these JV-specific abundance data.


Methods

We created an RStudio Project housing three fully commented R scripts that can, with little or no modification, be downloaded and run on any local computer. The goal of the pipeline is to intake raster data in the format provided by the CLO, annotate these data with useful ecological attributes, and sort, stack, and move these data according to said attributes. All R scripts end with the file extension “.R”. All data are housed in the RStudio Project  folder “data” except the raw raster data, which is provided by the CLO at https://cornell.app.box.com/v/JVeBirdCollab. The raw raster data (~1.5 GB) needs to be downloaded into the folders “CIJV” and “PacificBirds” within the “data” folder in the RStudio Project by the user. We developed the RStudio Project to be reproducible for future versions of raw raster data, given the data continue to be formatted in the same way. We describe the R scripts as follows:

“01_longformat_dataframe.R”
This is the longest script because several steps are taken to generate a long-format data frame which all subsequent steps in the pipeline use as a reference. The original data frame “JV_Percent_Bird_Populations_Combined.csv” (see download link above) is formatted so that each row is a species with four columns describing its proportion of the global population across four seasons. We pivot this data frame so that each species has up to four rows, one each for each season (resident species have only one row as these species). At this stage, we add a column that links each row (species-season) to its corresponding raster in the data folder. This ties each data entry with actual data so that the raster files “follow” the database as we move through the pipeline.

In this script we also attach information concerning species’ breeding biome and ecotype (e.g. landbird, waterfowl, etc.) as described in Rosenberg et al (2019) 10.1126/science.aaw1313. We also designate species with over 90% of the global population within a given JV as having high stewardship responsibility. This threshold is arbitrary and can be readily changed in the script on line 124.

“02_file_lists_for_species_combos.R”
The objective of this script is to inspect the annotated database for all possible permutations of the variables of interest: JV boundaries, stewardship responsibility, ecotype, breeding biome, and season (for migratory species). We then use this reference index to find all possible raster files that could be associated with each variable permutation. For example, we can now find out which raster files are needed to analyse pre-migration landbird species that are within the Canadian Intermountain JV, and have high stewardship responsibility. Because the directories pointing to the raster files are connected to these variables, their location is readily ported to R for sorting.

“03_raster_stacking.R”
In this final R script we take the list of variable permutations and their corresponding rasters, and stack them into one raster for downstream use. This ArcGIS dashboard was used as a reference: https://www.arcgis.com/apps/dashboards/cdfd6ce90f714784ad6f798beb74edd9. 
This script uses the terra::mosaic() function (https://github.com/rspatial/terra) to stack rasters, and assigns pixel values by summing. Other stacking parameters can be chosen at this stage (e.g. mean, median), and standardization could also be performed (i.e. standardizing relative abundance for all species to a minimum of 0 and maximum of 1), depending on the downstream application.

This script also recursively generates a folder tree using variable permutations defined above. It then automates the writing and moving of stacked rasters (.TIF format) to their corresponding folders.

Results

In total we generated 248 unique variable combinations spanning 373 species. There were 12 species with raster data that did not have population data provided by eBird, and 120 species with rasters that were not represented in Rosenberg et al (2019). These 132 species are omitted from our pipeline.

These scripts have been trimmed and streamlined substantially, and use a very small number of R packages. A user can be given a folder of raster data from eBird, and can annotate, stack, and sort these rasters into an automatically generated folder tree in minutes, running on a modern laptop. Please contact the first author for any bugs or queries at mannfred@ualberta.ca. 
