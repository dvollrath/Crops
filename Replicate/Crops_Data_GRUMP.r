#######################################################################
# Date: 2017-02-03
# Author: Dietz Vollrath
# 
# Process GRUMP population data
#
# 1. Input both GRUMP urban extents and GRUMP population count
# 2. Select population cells NOT in urban extents
# 3. Do zonal stats based on GADM zones for selected non-urban population
#
# Output is CSV file of zones with rural pop counts
#######################################################################

## Reference rasters and identifier data
gadm <- raster(file.path(refdir, "gadm_raster_adm2.tif")) # admin boundaries
out  <- read.csv(file.path(refdir, "gadm28_adm2_data.csv"), header=TRUE)

#######################################################################
## 2000 GRUMP data
extent <- raster(file.path(grumdir,"glurextents.asc"))
pop    <- raster(file.path(grumdir,"glup00g.asc")) # GRUMP unadjusted data

## Create raster of rural population from GRUMP
message(sprintf("\nMask rural extents:\n"))
con=function(condition, trueValue, falseValue){
  return(condition * trueValue + (!condition)*falseValue)}
rurcell <- con(extent==1,1,0) # id cells which are rural
rurpop  <- pop*rurcell # multiply pop by rurcell, sets urban cells to zero
writeRaster(rurpop,"grump_rurpop00.tif", overwrite=TRUE)

## Run zonal statistics
#rurpop <- raster("grump_rurpop.tif") # pull in rurpop raster if exists
message(sprintf("\nRun zone statistics:\n"))
disgadm <- disaggregate(gadm,10) # disaggregate GADM by factor of 10 for resolution 
cropgadm <- crop(disgadm,rurpop) # crop gadm to extent of rural pop
s <- zonal(rurpop,cropgadm,fun='sum',digits=3,na.rm=FALSE,progress='text')
colnames(s) <- c("OBJECTID","grump_rur_2000")
out <- merge(out, s, by="OBJECTID")

cropgadm <- crop(disgadm,pop)
s <- zonal(pop,cropgadm,fun='sum',digits=3,na.rm=FALSE,progress='text')
colnames(s) <- c("OBJECTID","grump_pop_2000")
out <- merge(out, s, by="OBJECTID")

#######################################################################
## 1990 GRUMP data
pop    <- raster(file.path(grumdir,"glup90g.asc")) # GRUMP unadjusted data

## Create raster of rural population from GRUMP
message(sprintf("\nMask rural extents:\n"))
rurpop  <- pop*rurcell # multiply pop by rurcell, sets urban cells to zero
writeRaster(rurpop,"grump_rurpop90.tif", overwrite=TRUE)

## Run zonal statistics
#rurpop <- raster("grump_rurpop.tif") # pull in rurpop raster if exists
message(sprintf("\nRun zone statistics:\n"))
disgadm <- disaggregate(gadm,10) # disaggregate GADM by factor of 10 for resolution 
cropgadm <- crop(disgadm,rurpop) # crop gadm to extent of rural pop
s <- zonal(rurpop,cropgadm,fun='sum',digits=3,na.rm=FALSE,progress='text')
colnames(s) <- c("OBJECTID","grump_rur_1990")
out <- merge(out, s, by="OBJECTID")

cropgadm <- crop(disgadm,pop)
s <- zonal(pop,cropgadm,fun='sum',digits=3,na.rm=FALSE,progress='text')
colnames(s) <- c("OBJECTID","grump_pop_1990")
out <- merge(out, s, by="OBJECTID")


# Save combined data frame to CSV
write.csv(out,file=file.path(refdir, "all_grump_pop_data.csv"),row.names=FALSE, na="")
