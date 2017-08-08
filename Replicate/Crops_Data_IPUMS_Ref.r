#######################################################################
# Date: 2016-11-08
# Author: Dietz Vollrath
# 
# Create reference files
# 1. Read in attributes of IPUMS shape file
# 2. Rasterize the polygons to GAEZ resolution
# 3. Estimate area in each cell of GADM raster
# 4. Get centroids of polygons
#
#######################################################################

setwd(refdir)

# Create reference table of zone identifiers
#shape <- shapefile(file.path(ipumdir,"world_geolev2.shp"))
#write.csv(shape,file="ipum_geolev2_data.csv")  # write poly data for use in other R routines
control <- read.csv("ipum_geolev2_data.csv", header=TRUE)
control$zone <- seq.int(nrow(control)) # add field to denote zone

# Rasterize the zone polygons
# GAEZ file serves as a template for cell resolution
#r <- raster(file.path(gaezdir,"lr_soi_sq1b_mze.tif"))
#ext <- extent(r)
#template <- raster(ext,nrow(r),ncol(r)) # template based on GAEZ file
#rasterize(shape,template,filename="ipum_raster_geolev2.tif")

# Create measure of each zone area in hectares, write zone data
ha   <- raster("gaez_area_ha.tif") # get raster of pixel ha's
gadm <- raster("ipum_raster_geolev2.tif") # get raster of IPUM polys
area <- zonal(ha,gadm,fun='sum',na.rm=TRUE,progress='text') # get sum of hectares in each poly
colnames(area) <- c("zone","Area_ha") # rename columns
control <- merge(control, area, by="zone") # merge area data with shape file
write.csv(control,file="ipum_geolev2_data_area.csv")  # write poly data for use in other R routines

# Get centroids of each GEOLEV2 polygon for use in spatial standard errors
#cent <- gCentroid(shape,byid=TRUE) # gest lat/lon of centroids
#cent.df <- as(cent, "data.frame") # convert to DF
#shape.df <- as(shape, "data.frame") # convert to DF
#colnames(cent.df) <- c("x_cent","y_cent")
#comb.df <- cbind(shape.df,cent.df) # merge centroids to shape file - warning: done by row, not OBJECTID
#write.csv(comb.df,file="all_cent_data_geolev2.csv") # write separate file of centroids
