#######################################################################
# Date: 2016-11-08
# Author: Dietz Vollrath
# 
# Process HYDE population files
# 1. For each given year
# 2. For each of three types of pop data: total, rural, urban
# 3. Get totals for each pop type by zone
# 4. Combine year/pop type totals to overall zone data
#
# Output is CSV file of zones with pop data by year for each zone
#
# Intended to be called from Crops_SetDirectories.r
#######################################################################

# Years to incorporate
years <- c("1900","1950","2000") # make sure these are strings

## Reference rasters
gadm <- raster(file.path(refdir, "gadm_raster_adm2.tif")) # admin boundaries
id <- read.csv(file.path(refdir, "gadm28_adm2_data.csv"), header=TRUE)

## For all years
for (year in years) {
  message(sprintf("\nProcessing: %s\n", year))
  yeardir <- paste0(hydedir,"/",year,"AD_pop")
  
  # Total population count
  x <- raster(file.path(yeardir,paste0("popc_",year,"AD.asc")))
  popc <- zonal(x,gadm,fun='sum',na.rm=TRUE,progress='text')
  colnames(popc) <- c("OBJECTID",paste0("popc_",year))
  id <- merge(id, popc, by="OBJECTID")
  
  # Urban population count
  x <- raster(file.path(yeardir,paste0("urbc_",year,"AD.asc")))
  urbc <- zonal(x,gadm,fun='sum',na.rm=TRUE,progress='text')
  colnames(urbc) <- c("OBJECTID",paste0("urbc_",year))
  id <- merge(id, urbc, by="OBJECTID")
  
  # Rural population count
  x <- raster(file.path(yeardir,paste0("rurc_",year,"AD.asc")))
  rurc <- zonal(x,gadm,fun='sum',na.rm=TRUE,progress='text')
  colnames(rurc) <- c("OBJECTID",paste0("rurc_",year))
  id <- merge(id, rurc, by="OBJECTID")
}

write.csv(id,file=file.path(refdir,"all_hyde_data.csv"),row.names=FALSE, na="")

