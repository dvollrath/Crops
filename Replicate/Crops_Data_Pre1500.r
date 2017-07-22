#######################################################################
# Date: 2016-11-08
# Author: Dietz Vollrath
# 
# Create Pre-1500 versions of CSI and GAEZ files
#
# 1. Read in region specific rasters, create stack
# 2. Read in table of pre-1500 regional distribution for each crop
# 3. Multiple regional distribution 0/1 for a crop by the raster stack
# 4. Sum across the multiplied raster stack - single 0/1 raster for crop in 1500
# 5. Multiply the 0/1 crop raster by CSI file for pre 1500 CSI
# 6. Multiply the 0/1 crop raster by GAEZ file for pre 1500 GAEZ
# 7. For 6, check if GAEZ file exists first
#
#######################################################################

setwd(refdir)

# Get region rasters and stack
files <- list.files(path='.', pattern="gadm_raster_reg_.*\\.tif")
regions <- stack(files) # stack of regional rasters
order <- lapply(names(regions), function(x) substr(x, 17, nchar(x))) # list regions
order <- unlist(order) # get in vector form for use later

# Get crop specific regions from Galor and Ozak
p1500 <- read.csv(file.path(datadir, "crops_control.csv"), header=TRUE)

# Loop through crops to generate p1500 CSI and suit files for each
## Using loop becaue each iteration is computation intense
## Doing as a matrix/vector calculation requires large virtual datasets
for (i in 1:nrow(p1500)) {
  crop <- p1500[i,"crop"] # get name of crop to use in CSI file names
  code <- p1500[i,"gaez"] # get gaez short code for use with GAEZ files
  message(sprintf("\nProcessing: %s\n", crop))
  c <- as.numeric(p1500[i,order]) # get vector of 0/1 region locations for crop
  cr <- c*regions # apply crop location 0/1 to layers
  cpre <- sum(cr) # sum across layers to get single 0/1 raster 
  
  csiname <- paste0(csidir,"/",water,"/",crop,input,".tif") # input CSI name
  csi <- raster(csiname) # get CSI raster
  csip1500 <- csi*cpre # apply pre1500 regions to CSI raster
  prename <- paste0(csidir,"/",water,"/",crop,input,"_p1500.tif") # output CSI name
  writeRaster(csip1500, prename, overwrite=TRUE) # write new p1500 file
  
  if (code!="") {
    gaezname <- paste0(gaezdir,"/","res03_crav6190l_sxlr_",code,".tif") # input GAEZ name
    gaez <- raster(gaezname) # get CSI raster
    gaezp1500 <- gaez*cpre # apply pre1500 regions to CSI raster
    prename <- paste0(gaezdir,"/","res03_crav6190l_sxlr_",code,"_p1500.tif") # output CSI name
    writeRaster(gaezp1500, prename, overwrite=TRUE) # write new p1500 file
  }
}