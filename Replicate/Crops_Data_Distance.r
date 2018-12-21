

cent  <- read.csv(file.path(refdir, "all_cent_data_gadm2.csv"), header=TRUE) # load EA location data

xy <- cbind(as.numeric(cent$x_cent),as.numeric(cent$y_cent)) 

dist <- pointDistance(xy,lonlat=TRUE,allpairs=TRUE) 
