#######################################################################
# Date: 2016-11-08
# Author: Dietz Vollrath
# 
# Create file for GAEZ cultivated land area
#
#######################################################################

setwd(refdir)

gaez <- read.csv("gadm28_adm2_data.csv", header=TRUE)
ha <- raster("gaez_area_ha.tif") # get area of each cell
faoperc <- raster(file.path(gaezdir,"lr_lco_faocrp00.tif")) # get raster of cultivated area
faoperc <- faoperc/100 # put in decimal form

gadm <- raster("gadm_raster_adm2.tif") # get raster of ADM2 poly's
faogadm <- zonal(faoperc,gadm,fun='mean',na.rm=TRUE,progress='text') # get average percent cult in a poly
  ## This should be okay given cells within small poly's have similar size
colnames(faogadm) <- c("OBJECTID","Cult_area_perc") # rename columns
gaez <- merge(gaez, faogadm, by="OBJECTID") # merge area data with shape file
write.csv(gaez,file="all_gaez_cult.csv",na="")  # write poly data for use in other R routines
