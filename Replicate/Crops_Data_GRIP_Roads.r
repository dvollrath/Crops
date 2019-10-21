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
gadm <- raster(file.path(refdir, "gadm_raster_adm2.tif")) # admin boundaries
out <- read.csv(file.path(refdir, "gadm28_adm2_data.csv"), header=TRUE)

setwd(gripdir)

r <- raster("grip4_total_dens_m_km2.asc")
s <- zonal(r,gadm,fun='mean',digits=3,na.rm=FALSE,progress='text')
colnames(s) <- c("OBJECTID","road_total_dens")
out <- merge(out, s, by="OBJECTID")

r <- raster("grip4_tp1_dens_m_km2.asc")
s <- zonal(r,gadm,fun='mean',digits=3,na.rm=FALSE,progress='text')
colnames(s) <- c("OBJECTID","road_tp1_dens")
out <- merge(out, s, by="OBJECTID")

r <- raster("grip4_tp2_dens_m_km2.asc")
s <- zonal(r,gadm,fun='mean',digits=3,na.rm=FALSE,progress='text')
colnames(s) <- c("OBJECTID","road_tp2_dens")
out <- merge(out, s, by="OBJECTID")

r <- raster("grip4_tp3_dens_m_km2.asc")
s <- zonal(r,gadm,fun='mean',digits=3,na.rm=FALSE,progress='text')
colnames(s) <- c("OBJECTID","road_tp3_dens")
out <- merge(out, s, by="OBJECTID")

r <- raster("grip4_tp4_dens_m_km2.asc")
s <- zonal(r,gadm,fun='mean',digits=3,na.rm=FALSE,progress='text')
colnames(s) <- c("OBJECTID","road_tp4_dens")
out <- merge(out, s, by="OBJECTID")

r <- raster("grip4_tp5_dens_m_km2.asc")
s <- zonal(r,gadm,fun='mean',digits=3,na.rm=FALSE,progress='text')
colnames(s) <- c("OBJECTID","road_tp5_dens")
out <- merge(out, s, by="OBJECTID")

# Save combined data frame to CSV
write.csv(out,file=file.path(refdir, "all_grip_road_data.csv"), row.names=FALSE, na="")
