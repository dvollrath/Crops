#######################################################################
# Date: 2016-11-08
# Author: Dietz Vollrath
# 
# PROCESS IS FOR IPUMS ZONES
#
# Process Calorie Suitability Index (CSI) files
# 1. Input rasters for crops given by control file
# 2. Get max calorie yield across those crops
# 3. Summarize these max calories by given zones
# 4. For each crop, identify in which cell it is the max
# 5. Summ calories and cells where crop is max, by zone
#
# Output is CSV file of zones with aggregate cals, and crop-specific cals
#######################################################################

control <- read.csv(file.path(datadir, "crops_control.csv"), header=TRUE)
crops <- control[control[,"max"]=="Yes","crop"] # select crop names of crops indicated to be included by "Yes"

## Reference rasters and identifier data
gadm <- raster(file.path(refdir, "ipum_raster_geolev2.tif")) # admin boundaries
ha <- raster(file.path(refdir, "gaez_area_ha.tif")) # hectares by cell
csi <- read.csv(file.path(refdir, "ipum_geolev2_data_area.csv"), header=TRUE)

## Update working directory for CSI input files
cworkdir <- paste0(csidir,"/",water) # update CSI data directory
setwd(cworkdir)

## Define conditional function for use later
con=function(condition, trueValue, falseValue){
  return(condition * trueValue + (!condition)*falseValue)}

message(sprintf("\nProcessing stack:\n"))

## Build list of input CSI rasters and stack for analysis
files <- lapply(crops, function(x) paste0(x,input,p1500,".tif")) # create list of file names
cropstack <- stack(files) # stack the file names
maxyld <- max(cropstack) # max yield in each cell
maxcal <- maxyld*ha # convert from calorie yield to total calories

# Get count of cells by zone
cells <- zonal(maxyld,gadm,fun='count',na.rm=TRUE,progress='text')
colnames(cells) <- c("zone","Count")
csi <- merge(csi, cells, by="zone")

# Get average calorie yield by zone - matching Galor and Ozak
meanyld <- zonal(maxyld,gadm,fun='mean',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(meanyld) <- c("zone","MeanYld")
csi <- merge(csi, meanyld, by="zone")

# Get total calories available by zone
cals <- zonal(maxcal,gadm,fun='sum',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(cals) <- c("zone","Cals")
csi <- merge(csi, cals, by="zone")

zero <-con(maxyld==0,1,0) ## identify zero yield cells

for (c in crops) { # for each individual crop
  message(sprintf("\nProcessing: %s\n", c))
  name <- c[[1]] # capture name of crop
  x <- paste0(name,input,p1500,".tif") # build file name for crop
  comp <- raster(x) # load crop raster
  id <- con(maxyld==comp,1,0) - zero # id cells where crop is max yielding
  yld <- comp*id # get yield in cells where crop is max yielding
  cal <- yld*ha # get calories in cells where crop is max yielding
  
  # Get number of cells where crop is max yielding, by zone
  s <- zonal(id,gadm,fun='sum',digits=3,na.rm=FALSE,progres='text')
  colnames(s) <- c("zone",paste0(name,"_cells",p1500))
  csi <- merge(csi, s, by="zone")
  
  # Get total calories where crop is max yielding, by zone
  s <- zonal(cal,gadm,fun='sum',digits=3,na.rm=FALSE,progress='text')
  colnames(s) <- c("zone",paste0(name,"_cals",p1500))
  csi <- merge(csi, s, by="zone")
  
  # Get total calories based only on that crop, in all cells  
  cal <- comp*ha
  s <- zonal(cal,gadm,fun='sum',digits=3,na.rm=FALSE,progress='text')
  colnames(s) <- c("zone",paste0(name,"_only_cals",p1500))
  csi <- merge(csi, s, by="zone")
}

# Save combined data frame to CSV
write.csv(csi,file=file.path(refdir,"all_csi_data_ipums.csv"),row.names=FALSE, na="")
