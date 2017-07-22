#######################################################################
# Date: 2016-11-08
# Author: Dietz Vollrath
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
gadm <- raster(file.path(refdir, "gadm_raster_adm2.tif")) # admin boundaries
ha <- raster(file.path(refdir, "gaez_area_ha.tif")) # hectares by cell
csi <- read.csv(file.path(refdir, "gadm28_adm2_data.csv"), header=TRUE)

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
colnames(cells) <- c("OBJECTID","Count")
csi <- merge(csi, cells, by="OBJECTID")

# Get average calorie yield by zone - matching Galor and Ozak
meanyld <- zonal(maxyld,gadm,fun='mean',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(meanyld) <- c("OBJECTID","MeanYld")
csi <- merge(csi, meanyld, by="OBJECTID")

# Get total calories available by zone
cals <- zonal(maxcal,gadm,fun='sum',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(cals) <- c("OBJECTID","Cals")
csi <- merge(csi, cals, by="OBJECTID")

# Get adjusted max cals based on percent cultivated
faoperc <- raster(file.path(gaezdir, "lr_lco_faocrp00.tif")) # get raster of cultivated area
faoperc <- faoperc/100 # put in decimal form
maxperc <- faoperc*maxcal # adjust max cals by percent cultivated
calsperc <- zonal(maxperc,gadm,fun='sum',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(calsperc) <- c("OBJECTID","CalsPerc")
csi <- merge(csi, calsperc, by="OBJECTID")

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
  colnames(s) <- c("OBJECTID",paste0(name,"_cells",p1500))
  csi <- merge(csi, s, by="OBJECTID")
  
  # Get total calories where crop is max yielding, by zone
  s <- zonal(cal,gadm,fun='sum',digits=3,na.rm=FALSE,progress='text')
  colnames(s) <- c("OBJECTID",paste0(name,"_cals",p1500))
  csi <- merge(csi, s, by="OBJECTID")
}

# Save combined data frame to CSV
write.csv(csi,file=file.path(refdir, paste0("all_csi_data",p1500,".csv")),row.names=FALSE, na="")
