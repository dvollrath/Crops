#######################################################################
# Date: 2016-11-08
# Author: Dietz Vollrath
# 
# Create reference files
# 1. Read in attributes of GADM file
# 2. Rasterize the GADM polygons to GAEZ resolution
# 3. Estimate area in each cell of GADM raster
# 4. Get area of each zone by doing zonal stats on GADM raster (for QA)
# 5. Get centroids of GADM1 and GADM2 polygons
#
#######################################################################

setwd(refdir)

# Extract coordinates and values from GADM raster
gadm <- raster("gadm_raster_adm2.tif") # get raster of ADM2 poly's
gadmex <- extent(gadm) # get extent of GADM map
gadmdata <- extract(gadm,gadmex, df=TRUE, cellnumbers=TRUE,progress='text') # extract data values 
gadmcoor <- as.data.frame(xyFromCell(gadm,gadmdata[,2])) # create data frame of x/y coordinates
alldata <- cbind(gadmcoor,gadmdata[,3])
colnames(alldata)<-c("X","Y","OBJECTID")
i <- 4

# Extract HYDE rural count data and bind to GADM raster
hyde <- raster(file.path(paste0(hydedir,"/2000AD_pop"),"rurc_2000AD.asc"))
hydeex <- extent(hyde)
hydedata <- extract(hyde,hydeex, df=TRUE, cellnumbers=TRUE,progress='text') # extract data values 
alldata <- cbind(alldata,hydedata[,3])
colnames(alldata)[i] <- "rurc_2000"
i <- i+1

# Extract HYDE urban data and bind to GADM raster
hyde <- raster(file.path(paste0(hydedir,"/2000AD_pop"),"urbc_2000AD.asc"))
hydeex <- extent(hyde)
hydedata <- extract(hyde,hydeex, df=TRUE, cellnumbers=TRUE,progress='text') # extract data values 
alldata <- cbind(alldata,hydedata[,3])
colnames(alldata)[i] <- "urbc_2000"
i <- i+1

# Extract CSI data on yield and total cals
csi <- raster(file.path(refdir,"csi_maxyld.tif"))
csiex <- extent(csi)
csidata <- extract(csi,csiex, df=TRUE, cellnumbers=TRUE,progress='text') # extract data values 
alldata <- cbind(alldata,csidata[,3])
colnames(alldata)[i] <- "csi_maxyld"
i <- i+1

csi <- raster(file.path(refdir,"csi_maxcal.tif"))
csiex <- extent(csi)
csidata <- extract(csi,csiex, df=TRUE, cellnumbers=TRUE,progress='text') # extract data values 
alldata <- cbind(alldata,csidata[,3])
colnames(alldata)[i] <- "csi_maxcal"
i <- i+1

# Extract GAEZ suitability indices
crops <- c("brl","bck","rye","oat","wpo","whe","csv","cow","pml","spo","rcw","yam")
for (c in crops) {
  message(sprintf("\nProcessing: %s\n", c))
  name <- paste0("res03_crav6190l_sxlr_",c,".tif")
  csi <- raster(file.path(gaezdir,name))
  csi <- csi/100
  csiex <- extent(csi)
  csidata <- extract(csi,csiex, df=TRUE, cellnumbers=TRUE) # extract data values 
  alldata <- cbind(alldata,csidata[,3])
  colnames(alldata)[i] <- paste0("suit_",c)
  i <- i+1
}

# Extract DMSP light data
dmsp <- raster(file.path(refdir,"dmsp_disaggregated.tif")) # use aggregate light data
dmsp <- extend(dmsp,gadmex,values=NA)
dmspex <- extent(dmsp)
dmspdata <- extract(dmsp,dmspex, df=TRUE, cellnumbers=TRUE,progress='text') # extract data values 
alldata <- cbind(alldata,dmspdata[,3])
colnames(alldata)[i] <- "dmsp_mean_light"
i <- i+1

# Drop any rows without complete data, and write to CSV file
alldata <- alldata[complete.cases(alldata), ]
write.csv(alldata,file="gadm28_pixel_data.csv",row.names=FALSE, na="")
