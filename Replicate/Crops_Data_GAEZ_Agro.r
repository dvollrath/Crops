#######################################################################
# Date: 2016-11-08
# Author: Dietz Vollrath
# 
# Process GAEZ Agro-climatic constraint files
#
# 1. For each constraint, get zonal statistics
#
# Output is CSV file of zones with average measure of each constraint
#######################################################################

## Reference rasters and identifier data
gadm <- raster(file.path(refdir, "gadm_raster_adm2.tif")) # admin boundaries
gaez <- read.csv(file.path(refdir, "gadm28_adm2_data.csv"), header=TRUE)

setwd(gaezdir)

# Soil suitability indices
files <- list.files(path='.', pattern="lr_soi_.*b_mze.tif")
for (f in files) {
  name <- substr(f[[1]], 8, 10) # get index identifier
  message(sprintf("\nProcessing: %s\n", f))
  x <- raster(f[[1]])
  s <- zonal(x,gadm,fun='mean',digits=3,na.rm=FALSE,progres='text')
  colnames(s) <- c("OBJECTID",paste0("agro_",name))
  gaez <- merge(gaez, s, by="OBJECTID")
}

# Terrain suitability indices
files <- list.files(path='.', pattern="lr_ter_.*05.tif")
for (f in files) {
  name <- substr(f[[1]], 8, 13) # get index identifier
  message(sprintf("\nProcessing: %s\n", f))
  x <- raster(f[[1]])
  s <- zonal(x,gadm,fun='mean',digits=3,na.rm=FALSE,progres='text')
  colnames(s) <- c("OBJECTID",paste0("agro_",name))
  gaez <- merge(gaez, s, by="OBJECTID")
}


# Climatic indices
files <- list.files(path='.', pattern="res01_.*_crav6190.tif")
for (f in files) {
  name <- substr(f[[1]], 7, 9) # get index identifier
  message(sprintf("\nProcessing: %s\n", f))
  x <- raster(f[[1]])
  s <- zonal(x,gadm,fun='mean',digits=3,na.rm=FALSE,progres='text')
  colnames(s) <- c("OBJECTID",paste0("agro_",name))
  gaez <- merge(gaez, s, by="OBJECTID")
}

# Save combined data frame to CSV
write.csv(gaez,file=file.path(refdir, "all_gaez_agro_data.csv"), row.names=FALSE, na="")
