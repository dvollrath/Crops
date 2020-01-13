#######################################################################
# Date: 2017-02-03
# Author: Dietz Vollrath
# 
# Map the estimated beta values by district
#######################################################################

## Reference rasters and identifier data
r <- raster(file.path(gaezdir, paste0("res03_crav6190l_sxlr_whe.tif"))) # get a GAEZ reference raster

blank <- r # intialize a raster based on GAEZ file
blank[] <- 0 # set all values to zero to begin

con=function(condition, trueValue, falseValue){ # define conditional function to check for values
  return(condition * trueValue + (!condition)*falseValue)}

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
writeRaster(cropsum,file.path(refdir,"map_crop_type.tif"), overwrite=TRUE) # write rasters for use in pixel analysis

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
  legend = c("Unsuitable", "Temperate", "Tropical", "Both"), # labels
  fill = colors,
  horiz = TRUE, # make it run across bottom of map
  bty="n"
)
dev.off()


### in black and white
colors <- c( # define colors by category
  "#e0e0e0", # unsuitable
  "#a0a0a0", # temperate
  "#606060", # tropical
  "#202020" # both
)
#colors <- c("palegoldenrod","palegreen","palegreen2","palegreen3")
#colors <- terrain.colors(4,alpha=1)
setEPS()
postscript(file.path(draftdir,"fig_world_crop_zones_bw.eps"),width=8,height=5)
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
  legend = c("Unsuitable", "Temperate", "Tropical", "Both"), # labels
  fill = colors,
  horiz = TRUE, # make it run across bottom of map
  bty="n"
)
dev.off()