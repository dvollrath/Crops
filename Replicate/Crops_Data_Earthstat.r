#######################################################################
# Date: 2016-11-08
# Author: Dietz Vollrath
# 
# Process Earthstat files for production and area harvested
#
# Output is CSV file of zones with aggregate tonnes and area by crop
#######################################################################

## Set crop list, input, and water conditions
control <- read.csv(file.path(datadir, "crops_earthstat_control.csv"), header=TRUE)
crops <- control[control[,"calc"]=="Yes","crop"] # select crop names of crops indicated to be included by "Yes"

## Reference rasters and identifier data
gadm <- raster(file.path(refdir, "gadm_raster_adm2.tif")) # admin boundaries
ha <- raster(file.path(refdir, "gaez_area_ha.tif")) # hectares by cell
es <- read.csv(file.path(refdir, "gadm28_adm2_data.csv"), header=TRUE)

## Update working directory for Earthstat input files
setwd(esdir)

for (c in crops) { # for each individual crop
  message(sprintf("\nProcessing: %s\n", c))
  name <- c[[1]] # capture name of crop
  folder <- paste0(name,"_HarvAreaYield_Geotiff")
  harvfile <- paste0(name,"_HarvestedAreaHectares.tif")
  prodfile <- paste0(name,"_Production.tif")
  cropdir <- paste0(esdir,"/",folder)
  setwd(cropdir)

  message(sprintf("\nHarvested area: %s\n", c))
  harv <- raster(harvfile)
  s <- zonal(harv,gadm,fun='sum',digits=3,na.rm=FALSE,progres='text')
  colnames(s) <- c("OBJECTID",paste0(name,"_harvarea"))
  es <- merge(es, s, by="OBJECTID")
  
  message(sprintf("\nProduction: %s\n", c))
  prod <- raster(prodfile)
  s <- zonal(prod,gadm,fun='sum',digits=3,na.rm=FALSE,progres='text')
  colnames(s) <- c("OBJECTID",paste0(name,"_production"))
  es <- merge(es, s, by="OBJECTID")
}

cropdir <- paste0(esdir,"/CroplandPastureArea2000_Geotiff")
setwd(cropdir)
pasture <-  raster("Pasture2000_5m.tif")
s <- zonal(pasture,gadm,fun='mean',digits=3,na.rm=FALSE,progres='text')
colnames(s) <- c("OBJECTID",paste0("es_pastureperc"))
es <- merge(es, s, by="OBJECTID")

crop <-  raster("Cropland2000_5m.tif")
s <- zonal(crop,gadm,fun='mean',digits=3,na.rm=FALSE,progres='text')
colnames(s) <- c("OBJECTID",paste0("es_cropperc"))
es <- merge(es, s, by="OBJECTID")

# Save combined data frame to CSV
write.csv(es,file=file.path(refdir, paste0("all_earthstat_data.csv")),row.names=FALSE, na="")
