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

############################################
## Lo, Rain-fed
## Update working directory for CSI input files
message(sprintf("\nLo rain fed outcomes:\n"))
cworkdir <- paste0(csidir,"/rain_fed") # update CSI data directory
setwd(cworkdir)

## Build list of input CSI rasters and stack for analysis
files <- lapply(crops, function(x) paste0(x,"lo.tif")) # create list of file names
cropstack <- stack(files) # stack the file names
maxyld <- max(cropstack) # max yield in each cell
maxcal <- maxyld*ha # convert from calorie yield to total calories

# Get count of cells by zone
cells <- zonal(maxyld,gadm,fun='count',na.rm=TRUE,progress='text')
colnames(cells) <- c("OBJECTID","Count_lo_rain")
csi <- merge(csi, cells, by="OBJECTID")

# Get average calorie yield by zone - matching Galor and Ozak
meanyld <- zonal(maxyld,gadm,fun='mean',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(meanyld) <- c("OBJECTID","MeanYld_lo_rain")
csi <- merge(csi, meanyld, by="OBJECTID")

# Get total calories available by zone
cals <- zonal(maxcal,gadm,fun='sum',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(cals) <- c("OBJECTID","Cals_lo_rain")
csi <- merge(csi, cals, by="OBJECTID")

############################################
## Hi, rain-fed
## Update working directory for CSI input files
message(sprintf("\n High rain fed outcomes:\n"))
cworkdir <- paste0(csidir,"/rain_fed") # update CSI data directory
setwd(cworkdir)

## Build list of input CSI rasters and stack for analysis
files <- lapply(crops, function(x) paste0(x,"hi.tif")) # create list of file names
cropstack <- stack(files) # stack the file names
maxyld <- max(cropstack) # max yield in each cell
maxcal <- maxyld*ha # convert from calorie yield to total calories

# Get count of cells by zone
cells <- zonal(maxyld,gadm,fun='count',na.rm=TRUE,progress='text')
colnames(cells) <- c("OBJECTID","Count_hi_rain")
csi <- merge(csi, cells, by="OBJECTID")

# Get average calorie yield by zone - matching Galor and Ozak
meanyld <- zonal(maxyld,gadm,fun='mean',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(meanyld) <- c("OBJECTID","MeanYld_hi_rain")
csi <- merge(csi, meanyld, by="OBJECTID")

# Get total calories available by zone
cals <- zonal(maxcal,gadm,fun='sum',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(cals) <- c("OBJECTID","Cals_hi_rain")
csi <- merge(csi, cals, by="OBJECTID")

############################################
## Hi, irrigated
## Update working directory for CSI input files
message(sprintf("\n High irrigated outcomes:\n"))
cworkdir <- paste0(csidir,"/irrigated") # update CSI data directory
setwd(cworkdir)

## Build list of input CSI rasters and stack for analysis
files <- lapply(crops, function(x) paste0(x,"hi.tif")) # create list of file names
cropstack <- stack(files) # stack the file names
maxyld <- max(cropstack) # max yield in each cell
maxcal <- maxyld*ha # convert from calorie yield to total calories

# Get count of cells by zone
cells <- zonal(maxyld,gadm,fun='count',na.rm=TRUE,progress='text')
colnames(cells) <- c("OBJECTID","Count_hi_irr")
csi <- merge(csi, cells, by="OBJECTID")

# Get average calorie yield by zone - matching Galor and Ozak
meanyld <- zonal(maxyld,gadm,fun='mean',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(meanyld) <- c("OBJECTID","MeanYld_hi_irr")
csi <- merge(csi, meanyld, by="OBJECTID")

# Get total calories available by zone
cals <- zonal(maxcal,gadm,fun='sum',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(cals) <- c("OBJECTID","Cals_hi_irr")
csi <- merge(csi, cals, by="OBJECTID")

############################################
## Medium, rain
## Update working directory for CSI input files
message(sprintf("\n Medium rain outcomes:\n"))
cworkdir <- paste0(csidir,"/rain_fed") # update CSI data directory
setwd(cworkdir)

## Build list of input CSI rasters and stack for analysis
files <- lapply(crops, function(x) paste0(x,"med.tif")) # create list of file names
cropstack <- stack(files) # stack the file names
maxyld <- max(cropstack) # max yield in each cell
maxcal <- maxyld*ha # convert from calorie yield to total calories

# Get count of cells by zone
cells <- zonal(maxyld,gadm,fun='count',na.rm=TRUE,progress='text')
colnames(cells) <- c("OBJECTID","Count_med_rain")
csi <- merge(csi, cells, by="OBJECTID")

# Get average calorie yield by zone - matching Galor and Ozak
meanyld <- zonal(maxyld,gadm,fun='mean',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(meanyld) <- c("OBJECTID","MeanYld_med_rain")
csi <- merge(csi, meanyld, by="OBJECTID")

# Get total calories available by zone
cals <- zonal(maxcal,gadm,fun='sum',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(cals) <- c("OBJECTID","Cals_med_rain")
csi <- merge(csi, cals, by="OBJECTID")

############################################
## Medium, irrigated
## Update working directory for CSI input files
message(sprintf("\n Medium irrigated outcomes:\n"))
cworkdir <- paste0(csidir,"/irrigated") # update CSI data directory
setwd(cworkdir)

## Build list of input CSI rasters and stack for analysis
files <- lapply(crops, function(x) paste0(x,"med.tif")) # create list of file names
cropstack <- stack(files) # stack the file names
maxyld <- max(cropstack) # max yield in each cell
maxcal <- maxyld*ha # convert from calorie yield to total calories

# Get count of cells by zone
cells <- zonal(maxyld,gadm,fun='count',na.rm=TRUE,progress='text')
colnames(cells) <- c("OBJECTID","Count_med_irr")
csi <- merge(csi, cells, by="OBJECTID")

# Get average calorie yield by zone - matching Galor and Ozak
meanyld <- zonal(maxyld,gadm,fun='mean',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(meanyld) <- c("OBJECTID","MeanYld_med_irr")
csi <- merge(csi, meanyld, by="OBJECTID")

# Get total calories available by zone
cals <- zonal(maxcal,gadm,fun='sum',digits=3,na.rm=FALSE,progress='text') ## fast zone stats
colnames(cals) <- c("OBJECTID","Cals_med_irr")
csi <- merge(csi, cals, by="OBJECTID")

# Save combined data frame to CSV
write.csv(csi,file=file.path(refdir, paste0("all_csi_data_input_water.csv")),row.names=FALSE, na="")
