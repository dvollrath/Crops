#######################################################################
# Date: 2016-11-08
# Author: Dietz Vollrath
# 
# Create Koppen Geiger climate data
# 1. Read in shape file for KG data, rasterize to GADM resolution
# 2. Get crosstabs of KG cells within each GADM polygon
# 3. Rename the KG fields to a consistent standard
# 4. Merge with gadm28_adm2_data.csv and save file
#
#######################################################################

## Read shape file for KG zones
shape <- shapefile(file.path(kgdir,"koeppen-geiger.shp"))

setwd(refdir)
r <- raster("gadm_raster_adm2.tif") ## read in GADM raster to use as template
ext <- extent(r) ## get extent of GADM raster
template <- raster(ext,nrow(r),ncol(r)) ## create template roster using GADM information

rasterize(shape,template,filename="kg_raster_gadm2.tif",field="GRIDCODE",progress="text",overwrite=TRUE) ## rasterize KG file

## Load rasterized file and use to create KG stats for each GADM polygon
kg <- raster("kg_raster_gadm2.tif")
kgtab <- crosstab(kg,r,long=FALSE,useNA=FALSE,progress="text")
colnames(kgtab) <- c("kgid","OBJECTID","kgfreq")
kgwide <- reshape(kgtab,idvar="OBJECTID",timevar="kgid",direction="wide")

colnames(kgwide)[colnames(kgwide)=="kgfreq.11"] <- "kgfreqAfz"
colnames(kgwide)[colnames(kgwide)=="kgfreq.12"] <- "kgfreqAmz"
colnames(kgwide)[colnames(kgwide)=="kgfreq.13"] <- "kgfreqAsz"
colnames(kgwide)[colnames(kgwide)=="kgfreq.14"] <- "kgfreqAwz"
colnames(kgwide)[colnames(kgwide)=="kgfreq.21"] <- "kgfreqBDk" # use D for Desert (not W)
colnames(kgwide)[colnames(kgwide)=="kgfreq.22"] <- "kgfreqBDh" # use D for Desert (not W)
colnames(kgwide)[colnames(kgwide)=="kgfreq.26"] <- "kgfreqBPk" # use P for Steppe (not S)
colnames(kgwide)[colnames(kgwide)=="kgfreq.27"] <- "kgfreqBPh" # use P for Steppe (not S)
colnames(kgwide)[colnames(kgwide)=="kgfreq.31"] <- "kgfreqCfa"
colnames(kgwide)[colnames(kgwide)=="kgfreq.32"] <- "kgfreqCfb"
colnames(kgwide)[colnames(kgwide)=="kgfreq.33"] <- "kgfreqCfc"
colnames(kgwide)[colnames(kgwide)=="kgfreq.34"] <- "kgfreqCsa"
colnames(kgwide)[colnames(kgwide)=="kgfreq.35"] <- "kgfreqCsb"
colnames(kgwide)[colnames(kgwide)=="kgfreq.36"] <- "kgfreqCsc"
colnames(kgwide)[colnames(kgwide)=="kgfreq.37"] <- "kgfreqCwa"
colnames(kgwide)[colnames(kgwide)=="kgfreq.38"] <- "kgfreqCwb"
colnames(kgwide)[colnames(kgwide)=="kgfreq.39"] <- "kgfreqCwc"
colnames(kgwide)[colnames(kgwide)=="kgfreq.41"] <- "kgfreqDfa"
colnames(kgwide)[colnames(kgwide)=="kgfreq.42"] <- "kgfreqDfb"
colnames(kgwide)[colnames(kgwide)=="kgfreq.43"] <- "kgfreqDfc"
colnames(kgwide)[colnames(kgwide)=="kgfreq.44"] <- "kgfreqDfd"
colnames(kgwide)[colnames(kgwide)=="kgfreq.45"] <- "kgfreqDsa"
colnames(kgwide)[colnames(kgwide)=="kgfreq.46"] <- "kgfreqDsb"
colnames(kgwide)[colnames(kgwide)=="kgfreq.47"] <- "kgfreqDsc"
#colnames(kgwide)[colnames(kgwide)=="kgfreq.48"] <- "kgfreqDsd" # 48 has no obs, no var
colnames(kgwide)[colnames(kgwide)=="kgfreq.49"] <- "kgfreqDwa"
colnames(kgwide)[colnames(kgwide)=="kgfreq.50"] <- "kgfreqDwb"
colnames(kgwide)[colnames(kgwide)=="kgfreq.51"] <- "kgfreqDwc"
colnames(kgwide)[colnames(kgwide)=="kgfreq.52"] <- "kgfreqDwd"
colnames(kgwide)[colnames(kgwide)=="kgfreq.61"] <- "kgfreqEzF"
colnames(kgwide)[colnames(kgwide)=="kgfreq.62"] <- "kgfreqEzT"

## Merge with baseline GADM2 data and save
id <- read.csv(file.path(refdir, "gadm28_adm2_data.csv"), header=TRUE)
id <- merge(id, kgwide, by="OBJECTID")
write.csv(id,file=file.path(refdir,"all_kg_data.csv"),row.names=FALSE, na="")
