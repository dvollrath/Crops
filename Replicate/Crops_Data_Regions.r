#######################################################################
# Date: 2016-11-08
# Author: Dietz Vollrath
# 
# Create "Level -1" GADM files that identify only region
#
# 1. Read ISO code table to assign region code to countries
# 2. Merge region code to GADM data attribute table
# 3. Substitute region code for GADM identifier in raster
# 4. Create separate rasters for each individual region
#
#######################################################################

setwd(refdir)

## Define conditional function for use later
con=function(condition, trueValue, falseValue){
  return(condition * trueValue + (!condition)*falseValue)}

# Update region codes for all countries to match breakdown in Galor and Ozak
iso <- read.csv(file.path(datadir, "iso_codes.csv"), header=TRUE)
iso$region.code[iso$region=="Oceania"] <- 1
iso$region.code[iso$region=="Americas"] <-2
iso$region.code[iso$region=="Asia"] <-3
iso$region.code[iso$region=="Europe"] <-4
iso$region.code[iso$sub.region=="Northern Africa"] <- 5
iso$region.code[iso$region=="Africa" & iso$sub.region!="Northern Africa"] <- 6
names(iso)[names(iso)=="alpha.3"] <- "ISO"

# Get GADM attribute file and merge region codes
gadm <- read.csv(file.path(refdir, "gadm28_adm2_data.csv"), header=TRUE)
cm <- merge(gadm, iso, by="ISO")

# Build classification matrix and reclassify GADM raster to have only region codes
cm <- cm[,c("OBJECTID","region.code")]
r <- raster("gadm_raster_adm2.tif")
reg <- subs(r, cm, by="OBJECTID", which="region.code", subsWithNA=TRUE)
writeRaster(reg, "gadm_raster_region.tif", overwrite=TRUE)

# Build separate 1/0 rasters for each region and build stack
oceania <- con(reg==1,1,0)
writeRaster(oceania, "gadm_raster_reg_oceania.tif", overwrite=TRUE)
americas <- con(reg==2,1,0)
writeRaster(americas, "gadm_raster_reg_americas.tif", overwrite=TRUE)
asia <- con(reg==3,1,0)
writeRaster(asia, "gadm_raster_reg_asia.tif", overwrite=TRUE)
europe <- con(reg==4,1,0)
writeRaster(europe, "gadm_raster_reg_europe.tif", overwrite=TRUE)
nafrica <- con(reg==5,1,0)
writeRaster(nafrica, "gadm_raster_reg_nafrica.tif", overwrite=TRUE)
ssafrica <- con(reg==6,1,0)
writeRaster(ssafrica, "gadm_raster_reg_ssafrica.tif", overwrite=TRUE)


