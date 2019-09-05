#######################################################################
# Date: 2016-11-08
# Author: Dietz Vollrath
# 
# Process Calorie Suitability Index (CSI) files
# 1. Read crops_control.csv for info on which crops to process
# 2. Read in GADM raster, GADM hectare raster, GADM basic data
# 3. For each crop in control file, calculate total calories for each GADM zone
#
#######################################################################

control <- read.csv(file.path(datadir, "crops_control.csv"), header=TRUE)
crops <- control[control[,"ind"]=="Yes","crop"] # select crop names of crops indicated to be included by "Yes"

## Reference rasters and identifier data
gadm <- raster(file.path(refdir, "gadm_raster_adm2.tif")) # admin boundaries
ha <- raster(file.path(refdir, "gaez_area_ha.tif")) # hectares by cell
csi <- read.csv(file.path(refdir, "gadm28_adm2_data.csv"), header=TRUE)

## Update working directory for CSI input files
cworkdir <- paste0(csidir,"/",water) # update CSI data directory

message(sprintf("\nProcessing stack:\n"))

for (c in crops) { # for each individual crop
  message(sprintf("\nProcessing: %s\n", c))
  name <- c[[1]] # capture name of crop
  x <- paste0(name,input,p1500,".tif") # build file name for crop
  comp <- raster(file.path(cworkdir,x)) # load crop raster
  cal <- comp*ha # get calories in cells
  # Get total calories 
  s <- zonal(cal,gadm,fun='sum',digits=3,na.rm=FALSE,progress='text')
  colnames(s) <- c("OBJECTID",paste0(name,"_only_cals",p1500))
  csi <- merge(csi, s, by="OBJECTID")
}
# Sugarcane potential (zero calories)
message(sprintf("\nProcessing: %s\n", "sugarcane"))
comp <- raster(file.path(gaezdir,"res02_crav6190l_sugc150b_yld.tif"))
cal <- comp*ha # total potential outout
s <- zonal(cal,gadm,fun='sum',digits=3,na.rm=FALSE,progress='text')
colnames(s) <- c("OBJECTID","sugarcane_only_cals") # called "cals" to be consistent, but real output
csi <- merge(csi, s, by="OBJECTID")

# Tobacco potential (zero calories)
message(sprintf("\nProcessing: %s\n", "tobacco"))
comp <- raster(file.path(gaezdir,"res02_crav6190l_toba150b_yld.tif"))
cal <- comp*ha # total potential outout
s <- zonal(cal,gadm,fun='sum',digits=3,na.rm=FALSE,progress='text')
colnames(s) <- c("OBJECTID","tobacco_only_cals") # called "cals" to be consistent, but real output
csi <- merge(csi, s, by="OBJECTID")

# Save combined data frame to CSV
write.csv(csi,file=file.path(refdir, paste0("all_csi_only_data",p1500,".csv")),row.names=FALSE, na="")
