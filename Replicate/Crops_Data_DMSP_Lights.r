#######################################################################
# Date: 2017-02-03
# Author: Dietz Vollrath
# 
# Process DMSP Global night light data
#
# 1. Put DMPS and GADM data into similar extents and resolution
# 2. Do zonal statistics on DMPS light data using GADM
#
# Output is CSV file of zones with average suitability by crop
#######################################################################

## Reference rasters and identifier data
gadm <- raster(file.path(refdir, "gadm_raster_adm2.tif")) # admin boundaries
d <- read.csv(file.path(refdir, "gadm28_adm2_data.csv"), header=TRUE)

## Get light data as raster
dmsp <- raster(file.path(dmspdir, "F12-F15_20000103-20001229_rad_v4.avg_vis.tif"))

## Set up files to match extents
disgadm <- disaggregate(gadm,10) # disaggregate GADM by factor of 10 for resolution 
cgadm <- crop(disgadm,dmsp) # crop GADM to extent of dmsp file
rdmsp <- resample(dmsp,cgadm,progress='text') # need to resample DMSP to resolve slight difference in measured extent

## Zone statistics on lights data for GADM level
s <- zonal(rdmsp,cgadm,fun='mean',digits=3,na.rm=FALSE,progress='text')

colnames(s) <- c("OBJECTID","light_mean")
d <- merge(d, s, by="OBJECTID")

# Save combined data frame to CSV
write.csv(d,file=file.path(refdir, "all_dmsp_light_data.csv"), row.names=FALSE, na="")
