#######################################################################
# Date: 2017-02-03
# Author: Dietz Vollrath
# 
# Map the estimated beta values by district
#######################################################################

#shape <- shapefile(file.path(gadmdir,"gadm36_0.shp"))
#write.csv(shape,file=file.path(refdir,"gadm36_0_data.csv"))

country <- read.csv(file.path(refdir, "gadm36_0_data.csv"), header=TRUE)
colnames(country) <- c("OBJECTID","ISO","NAME_0")
gadm <- raster(file.path(refdir, "gadm_raster_adm0.tif")) # admin boundaries by country
r <- raster(file.path(refdir,"map_crop_type.tif")) # get map of crop types
max <- raster(file.path(refdir,"csi_maxcal.tif")) # get map of max cals by pixel

con=function(condition, trueValue, falseValue){ # define conditional function to check for values
  return(condition * trueValue + (!condition)*falseValue)}

croptype <- r # copy of crop type raster
croptemp <- con(croptype==1,.239,0) # raster of temp pixel, with temp beta
croptrop <- con(croptype==2,.088,0) # raster of trop pixel, with trop beta
cropmix  <- con(croptype==3,.128,0) # raster of mixed pixel, with mixed beta
cropzero <- con(croptype==0,0,0) # raster of unsuitable pixel, with zero beta
cropbeta <- croptemp + croptrop + cropmix + cropzero # sum, and each pixel now has crop beta

suitable <- con(croptype==0,0,1) # simple 0/1 for whether temp,trop,mixed vs unsuitable
max <- max*suitable # eliminate max cells unsuitable for agriculture from summations
cropwtd <- cropbeta*max # cals times beta for each pixel

sumcals <- zonal(max,gadm,fun='sum',digits=3,na.rm=TRUE,progress='text') ## fast zone stats
colnames(sumcals) <- c("zone","Cals")

sumwtd <- zonal(cropwtd,gadm,fun='sum',digits=3,na.rm=TRUE,progress='text') ## fast zone stats
colnames(sumwtd) <- c("zone","WtdCals")

sumall <- merge(sumcals,sumwtd,by="zone")

sumall$beta <- sumall$WtdCals/sumall$Cals

sumcountry <- zonal(gadm,gadm,fun='mean',digits=3,na.rm=FALSE,progress='text')

combine <- stack(gadm,max,croptype)
combdf  <- as.data.frame(combine)
write.csv(combdf,file.path(refdir,"gadm_pixel_crop_cal.csv"))


country <- merge(country,sumall,by="OBJECTID")


blank <- r # intialize a raster based on GAEZ file
blank[] <- 0 # set all values to zero to begin


temp <- c('brl','bck','rye','oat','wpo','whe') # temperate crops
trop <- c('csv','cow','pml','spo','rcw','yam') # tropical crops

sumtemp = blank # initiate the running sum of temperate suitability
for (f in temp) { # for all temperate crops
  message(sprintf("\nProcessing: %s\n", f))
  x <- raster(file.path(gaezdir, paste0("res03_crav6190l_sxlr_",f,".tif"))) # open suitability file
  x <- x/100 # put in 0-100 range
  sumtemp <- sumtemp + x # keep running sum of suitability numbers for temperate crops
}
flagtemp <- con(sumtemp==0,0,1) # check if zero suitability for any temperate crop, set to 0 if none, 1 if some

sumtrop = blank # initiate the running sum of temperate suitability
for (f in trop) { # for all tropical crops
  message(sprintf("\nProcessing: %s\n", f))
  x <- raster(file.path(gaezdir, paste0("res03_crav6190l_sxlr_",f,".tif"))) # open tropical file
  x <- x/100 # put in 0-100 range
  sumtrop <- sumtrop + x # keep running sum of suitability numbers for temperate crops
}
flagtrop <- con(sumtrop==0,0,2) # check if zero suitability for any temperate crop, set to 0 if none, 2 if some

cropsum <- blank + flagtemp + flagtrop # add temp and trop to blank. 0 = neither, 1 = temp only, 2 = trop only, 3 = both

e <- extent(-180, 180, -70, 90) # set extent to drop antartic region
cropextent <- crop(cropsum, e) # crop the cropsum raster to that extent

colors <- c( # define colors by category
  "#d3d532", # unsuitable
  "#d78d0d", # temperate
  "#48c665", # tropical
  "#22751a" # both
)
#colors <- c("palegoldenrod","palegreen","palegreen2","palegreen3")
#colors <- terrain.colors(4,alpha=1)
setEPS()
postscript(file.path(draftdir,"fig_world_crop_zones.eps"),width=8,height=5)
par(bty="n",mai=c(.25,.25,.25,0)) # set no borders parameter
plot( # plot crop suitability raster
  cropextent,
  legend = FALSE, # will create separately
  col =colors, # fill for the cells in the map
  xaxt = 'n',
  yaxt = 'n'  
)
legend( # add legend at bottom of plot
  "bottom", # make it run across bottom of map
  legend = c("Unsuitable (NA)", "Temperate (0.24)", "Tropical (0.09)", "Both (0.13)"), # labels
  fill = colors,
  horiz = TRUE, # make it run across bottom of map
  bty="n"
)
dev.off()