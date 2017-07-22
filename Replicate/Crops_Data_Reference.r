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
# Intended to be called from Crops_SetDirectories.r
#######################################################################

# Create reference table of zone identifiers
shape <- shapefile(file.path(gadmdir,"gadm28_adm2.shp"))

# Rasterize the zone polygons
# GAEZ file serves as a template for cell resolution
r <- raster(file.path(gaezdir,"lr_soi_sq1b_mze.tif"))
ext <- extent(r)
template <- raster(ext,nrow(r),ncol(r)) # template based on GAEZ file
rasterize(shape,template,filename="gadm_raster_adm2.tif")

# Create measure of hectares in each cell
r.area <- area(r)
ha <- r.area*100 ## convert km2 to hectares
writeRaster(ha,"gaez_area_ha.tif", overwrite=TRUE)

# Create measure of each zone area in hectares, write zone data
gadm <- raster("gadm_raster_adm2.tif") # get raster of ADM2 poly's
area <- zonal(ha,gadm,fun='sum',na.rm=TRUE,progress='text') # get sum of hectares in each poly
colnames(area) <- c("OBJECTID","Area_ha") # rename columns
shape <- merge(shape, area, by="OBJECTID") # merge area data with shape file
write.csv(shape,file="gadm28_adm2_data.csv")  # write poly data for use in other R routines

# Get centroids of each GADM2 polygon for use in spatial standard errors
cent <- gCentroid(shape,byid=TRUE) # gest lat/lon of centroids
cent.df <- as(cent, "data.frame") # convert to DF
shape.df <- as(shape, "data.frame") # convert to DF
colnames(cent.df) <- c("x_cent","y_cent")
comb.df <- cbind(shape.df,cent.df) # merge centroids to shape file - warning: done by row, not OBJECTID
write.csv(comb.df,file="all_cent_data_gadm2.csv") # write separate file of centroids

# Get centroids of each GADM1 polygon for use in spatial standard errors
shape <- shapefile(file.path(gadmdir,"gadm28_adm1.shp"))
cent <- gCentroid(shape,byid=TRUE) # gest lat/lon of centroids
cent.df <- as(cent, "data.frame") # convert to DF
shape.df <- as(shape, "data.frame") # convert to DF
colnames(cent.df) <- c("x_cent","y_cent")
comb.df <- cbind(shape.df,cent.df) # merge centroids to shape file - warning: done by row, not OBJECTID
write.csv(comb.df,file="all_cent_data_gadm1.csv") # write separate file of centroids


