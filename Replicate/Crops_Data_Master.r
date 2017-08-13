#######################################################################
# Date: 2016-11-08
# Author: Dietz Vollrath
# 
# Set reference directories for all other scripts to use
# 1. Clears existing environment
# 2. Sets directories
# 3. Calls sub-routines to create datasets
#
#######################################################################

## Clear out existing environment
rm(list = ls()) 

## Set master directory where all sub-directories are located
mdir <- "~/dropbox/project/crops"

## Set working directories
refdir  <- paste0(mdir,"/Work") # working files and end data
codedir <- paste0(mdir,"/Replicate") # code

## Set data directories
gadmdir <- paste0(mdir,"/data/GADM") # Administrative polygons
gaezdir <- paste0(mdir,"/data/GAEZ") # Crop suitability data
hydedir <- paste0(mdir,"/data/HYDE") # Population data
csidir  <- paste0(mdir,"/data/CropCSI") # Crop caloric suitability
dmspdir <- paste0(mdir,"/data/DMSP/2000") # Night lights data
kgdir   <- paste0(mdir,"/data/Koeppen-Geiger-GIS") # KG climate zones
esdir   <- paste0(mdir,"/data/Earthstat") # Earthstat production data
ipumdir <- paste0(mdir,"/data/IPUMS") # IPUMS data
grumdir <- paste0(mdir,"/data/GRUMP") # GRUMP population data
datadir <- paste0(mdir,"/Replicate") # Control files

## Set crop list, input, and water conditions
water <- "rain_fed" ## alternative is "irrigated"
input <- "lo" ## alternatives are "med" and "hi"
p1500 <- "" ## alternatives are "" for post-1500, "_p1500" for pre-1500

## Libraries for use
library(raster)
library(rgdal)
library(maptools)
library(rgeos)

## Set working directory
setwd(refdir)

#######################################################################
## Call reference program
## Run this first, but only once is necessary
#source(file.path(codedir,'Crops_Data_Reference.r'))

#######################################################################
## Call individual data programs
## Comment these out as necessary
## Running all in order will take >2 hours
#source(file.path(codedir,'Crops_Data_HYDE_Stat.r')) # Population data
#source(file.path(codedir,'Crops_Data_CSI_ByCrop.r')) # Caloric data
#source(file.path(codedir,'Crops_Data_CSI_Max.r')) # Caloric data
#source(file.path(codedir,'Crops_Data_DMSP_Lights.r')) # Night lights data
#source(file.path(codedir,'Crops_Data_GAEZ_Agro.r')) # Constraint data
#source(file.path(codedir,'Crops_Data_GAEZ_Suit.r')) # Suitability data
#source(file.path(codedir,'Crops_Data_GAEZ_Cult.r')) # Cultivated area
#source(file.path(codedir,'Crops_Data_KG_Count.r')) # KG zone data
#source(file.path(codedir,'Crops_Data_Earthstat.r')) # Production data
source(file.path(codedir,'Crops_Data_GRUMP.r')) # Population data

#######################################################################
## Call programs for pre-1500 processing
## To create masked versions of CSI and GAEZ files that conform
## to pre-1500 crop availability
#source(file.path(codedir,'Crops_Data_Regions.r')) # Create region rasters
#source(file.path(codedir,'Crops_Data_Pre1500.r')) # Create pre1500 rasters
## Re-call the CSI programs to process on pre-1500 data
#p1500 <- "_p1500" ## alternatives are "" for post-1500, "_p1500" for pre-1500
#source(file.path(codedir,'Crops_Data_CSI_ByCrop.r')) # Caloric data
#source(file.path(codedir,'Crops_Data_CSI_Max.r')) # Caloric data

#######################################################################
## Call programs for IPUMS
## Create new zonal stats for crop productivity
## based on IPUMS boundary maps
#source(file.path(codedir,'Crops_Data_IPUMS_Ref.r'))
#source(file.path(codedir,'Crops_Data_CSI_IPUMS.r'))
#source(file.path(codedir,'Crops_Data_DMSP_IPUMS.r'))
#source(file.path(codedir,'Crops_Data_Earthstat_IPUMS.r'))
#source(file.path(codedir,'Crops_Data_GAEZ_IPUMS.r'))