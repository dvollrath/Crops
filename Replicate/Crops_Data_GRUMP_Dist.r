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
## GRUMP settlement data
#extent <- raster(file.path(grumdir,"glurextents.asc"))
#con=function(condition, trueValue, falseValue){
#  return(condition * trueValue + (!condition)*falseValue)}
#rurcell <- con(extent==1,NA,0) # id cells and mark with NA
cities <- shapefile(file.path(grumdir,"global_settlement_points_v1.01.shp"))

big <- cities[cities@data$ES00POP>49999,] # select points with 50K or more 

dist <- distanceFromPoints(object=gadm, xy=big) # find nearest distance from each raster point in GADM to settlement

