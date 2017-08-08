#######################################################################
# Date: 2016-11-08
# Author: Dietz Vollrath
# 
# Process GAEZ Suitability files
#
# 1. For each crop file, get zonal statistics on suitability
#
# Output is CSV file of zones with average suitability by crop
#######################################################################

## Reference rasters and identifier data
gadm <- raster(file.path(refdir, "ipum_raster_geolev2.tif")) # admin boundaries
gaez <- read.csv(file.path(refdir, "ipum_geolev2_data_area.csv"), header=TRUE)

setwd(gaezdir)

## Do not need an input crop list, because not comparing crops to one another
## Get all crop suitability files, pre and post 1500
files <- list.files(path='.', pattern="res03_crav6190l_sxlr_.*\\.tif")

for (f in files) {
  name <- substr(f[[1]], 22, nchar(f[[1]])-4) # get crop identifier
  message(sprintf("\nProcessing: %s\n", name))
  x <- raster(f[[1]])
  x <- x/100 # put in 0-100 range
  s <- zonal(x,gadm,fun='mean',digits=3,na.rm=FALSE,progres='text')
  colnames(s) <- c("zone",paste0("suit_",name))
  gaez <- merge(gaez, s, by="zone")
}

# Save combined data frame to CSV
write.csv(gaez,file=file.path(refdir, "all_gaez_suit_data_ipums.csv"), row.names=FALSE, na="")
