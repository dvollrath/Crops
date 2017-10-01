# How Tight are Malthusian Constraints?
T. Ryan Johnson and Dietrich Vollrath

## Replication of Main Results
The Code folder contains the necessary code to replicate all the results in the paper. There are two sets of code, the first generates a series of CSV datasets from raw GIS data (using R), and the second runs regressions using those CSV datasets (using Stata).

### Control files
There are three control files (both CSV format) in the "Code" folder.

1. crops_control.csv: this contains a list of crops to include in the analysis, along with codes used to denote them in some of the datasets. It also contains an indication of which regions these crops were available in prior to 1500. 
2. iso_codes.csv: this maps countries to ISO codes (3-digits), as well as region codes we use to group countries
3. crops_earthstat_control.csv: contains a list of crops to include when creating actual production data for a selected set of crops using the Earthscan data

Edits to these files will alter the results by changing which crops are used to calculate the productivity index in the paper, and/or changing which countries are included in certain sub-samples in the regressions.

### Generating data
These files are all names "Crops_Data_???.r". "Crops_Data_Master.r" is the single script that is used to kick off all the other scripts, and it contains all the settings that control the running of those scripts. 

Within "Crops_Data_Master.r", you should edit the following
```R
mdir <- "~/dropbox/project/crops"
```
to point towards the location of the folder that contains the data and code for the project. 

The lines following that assignment show you the necessary set of sub-folders that should exist for the code to run correctly.
```R
refdir  <- paste0(mdir,"/Work") # working files and end data
codedir <- paste0(mdir,"/Replicate") # code
gadmdir <- paste0(mdir,"/data/GADM") # Administrative polygons
gaezdir <- paste0(mdir,"/data/GAEZ") # Crop suitability data
hydedir <- paste0(mdir,"/data/HYDE") # Population data
csidir  <- paste0(mdir,"/data/CropCSI") # Crop caloric suitability
dmspdir <- paste0(mdir,"/data/DMSP/2000") # Night lights data
kgdir   <- paste0(mdir,"/data/Koeppen-Geiger-GIS") # KG climate zones
esdir   <- paste0(mdir,"/data/Earthstat") # Earthstat production data
grumdir <- paste0(mdir,"/data/GRUMP") # GRUMP population data
datadir <- paste0(mdir,"/Replicate") # Control files
```

The other options to set in this file refer to the Caloric Suitability Index parameters you want to use to generate the measure of productivity. 
```R
water <- "rain_fed" ## alternative is "irrigated"
input <- "lo" ## alternatives are "med" and "hi"
p1500 <- "" ## alternatives are "" for post-1500, "_p1500" for pre-1500
```
They are set to use the characteristics associated with exogenous variation in suitability. Setting the "p1500" flag to "_p1500" will tell the code to ignore crops in a region that were not present prior to 1500 (i.e. potatoes in Europe). 

With all these parameters set, you should use the script to call the "Crops_Data_Reference.r" script by uncommenting this line. This needs to be run once, and produces a rasterized version of the district boundaries (for use in zone statistics) as well as initializing a CSV file with ID's for each district that other scripts append their data to.

Once the "Crops_Data_Reference.r" script has been run once, you can comment out this call again. Then uncomment any or all of the other scripts listed to call those to produce specific CSV files of data. Calling all of them in order will take approximately 1-2 hours depending on your machine.

The final two scripts called by "Crops_Data_Master.r" refer to pre-1500 versions of the data. We do not use this in the paper, but the scripts are available if you want to use them. "Crops_Data_Regions.r" creates separate rasters that define broad regions, and crops are coded as available pre-1500 or not by region (i.e. Europe, South America, etc..). "Crops_Data_Pre1500.r" creates new pre-1500 versions of select CSI and GAEZ crop files, setting values for productivity or suitability to zero if the crop was not available in that region prior to 1500.

#### IPUMS data
In addition to the geographic data, the raw IPUMS data must be prepared separately for use in the robustness regressions. The script "Crops_Data_IPUMS.do" takes in the raw IPUMS extracts, and collapses those to summary measures of population for each district (denoted by GEOLEV2 variable) provided by IPUMS. This should be run first. Warning, this script takes hours to run, as it is collapsing millions of records from each extract.

With that run, the geography scripts in R can be run for the IPUMS districts. These separate scripts are necessary as IPUMS uses a different definition of districts than GADM. The final section of "Crops_Data_Master.r" shows the order for these scripts. 

Once those scripts have been run, then "Crops_Reg_IPUMS_Prep.do" can be run, which merges the collapsed population data with the geographic data. This script also runs the regressions for the IPUMS data.

### Data Sources
You can see the organization of the folders for the data in the "Crops_Data_Reference.r" script. All the data we use is public, and freely downloaded from the original sources. To facilitate an exact replication, you can access our files [here](https://www.dropbox.com/sh/6oqe37kzubrf5p4/AAB-E7Rq7CULkP_WzO3z4Pkia?dl=0). Note that the full set of data is around 25GB.

The original sources of the data can be found at the following links:

1. CropCSI: From Ozak and Galor (2016). See [here](https://ozak.github.io/Caloric-Suitability-Index/), and look for the "Caloric Suitability for Individual Crops" link towards the bottom of the page.
2. GADM: From [here](http://www.gadm.org), and see their download section.
3. GAEZ: From the [FAO](http://www.fao.org/nr/gaez/en/), and click on the "Access Data Portal" button. You need Flash installed to use it. It is also highly frustrating to download this data, as you have to pull down each individual dataset one by one. See below for a description of which files we use.
4. HYDE: From [here](http://themasites.pbl.nl/tridion/en/themasites/hyde/download/index-2.html), you click on the link to download data, which takes you to an FTP server. Use guest to login. Data are organized by year, with folders of the name "YYYYAD_pop". 
5. DMSP: From [here](https://ngdc.noaa.gov/eog/dmsp/downloadV4composites.html). We use the link for 2000/F15 data.
6. Koeppen-Geiger-GIS: From [here](http://koeppen-geiger.vu-wien.ac.at/shifts.htm), where you can find GIS shapefiles for the 1976-2000 observed classification towards the bottom of the page.
7. Earthstat: From [here](http://www.earthstat.org), go to data downloads and get the zip file for "major crops" from the "Harvested Area and Yield for 175 Crops" section.
8. IPUMS: From [here](https://international.ipums.org/international/), we downloaded the "spatially harmonized second-level geography" shape files (see the Geography and GIS page). We then created an extract of population data for the 39 countries that have data at this second level (see the Appendix to the paper for the list of 39 countries). 

**GAEZ data**. As noted, this is somewhat annoying to access. We use the following sets of data

1. lr_lco_faocrp00.tif: Percent of a grid-cell that is cultivated
2. lr_soi_sq?b_mze.tif: A set of 7 files (? is 1-7), which are measures of agro-climatic constraints (nutrient availability, excess salts, etc..)
3. res01_???_crav6190.tif: A set of 7 files (??? are codes ID's the files) which measure more agro-climatic constraints (growing period, reference evapotranspiration, etc..)
4. res03_crav6190l_sxlr_???.tif: A set of files (??? denote crop codes - see the crop_control.csv file) that measure suitability for a crop on a 0 to 100 scale

The shell script "Crops_GAEZ_unzip.sh" in the Replicate folder is a utility that will unzip the sets of zip files downloaded from GAEZ.

### Running Regressions
These files are all named "Crops_Reg_????.do". There are two files that need to be run first to merge the CSV files from R into a usable DTA file for Stata. 

1. Crops_Reg_Collapse.do: This will take each CSV file, aggregate the data up to the given level (country, province, district), and then merge them to one DTA file. You need to set (A) the directories for the CSV files and the data file of ISO codes and (B) the level of aggregation you want. In normal use, run this script twice. Once with the level of aggregation "gadm2" (for a district-level dataset) and once with the level "gadm1" (for a province-level dataset).

2. Crops_Reg_Prep.do: This takes the DTA file and produces several new variables (yields, population densities, etc..), winsorizes data, and creates several categorical variables for regions. It also produces summary stats tables and density plots. You need to set (A) the directories for the DTA files and where output (figures, etc..) should go and (B) the level of aggregation you want. In normal use, you'd use this script twice. Once with the level of aggregation "gadm2" (for a district-level dataset) and once with the level "gadm1" (for a province-level dataset).

Once those scripts are run, the DTA files necessary for the regressions are ready. "Crops_Reg_Master.do" controls the flow of work for the regressions. This do-file sets up and uses a small program called "reset" that sets global variables used by other do-files. Yes, global variables are scary and bad. No, we did not feel like programming everything to be a callable program. The small program that sets the globals always wipes out all globals first, so there should be no issues in replicating our work. 

In that "reset" program, you should edit the following
```
    global data "/users/dietz/dropbox/project/crops/work"
    global output "/users/dietz/dropbox/project/crops/drafts"
    global code "/users/dietz/dropbox/project/crops/replicate"
```
to point towards your the directories that contain the CSV files (data), the other source code (code), and where you want tables and figures to go (output).

"Crops_Reg_Master.do" then calls two do-files to put programs in memory - neither produce any output.

1. ols_spatial_HAC.ado: this is code from Hsiang (shsiang@berkeley.edu) to calculate Conley standard errors. You should not have to edit or touch this.
2. Crops_Reg_Program.do: these are programs that perform spatial regressions using variables passed to them, and using values of globals to control their execution. You should not have to edit or touch this.

"Crops_Reg_Master.do" then calls do-files based on the parameters you feed it. For each run, the do-file first calls the "reset" program, which resets the globals. It then assigns a "tag" to the run, which is used in the name of the output files to identify them. For example, we use the tag "base" to identify output files that were produced using our baseline assumptions. The do-file then calls three separate do-files, each associated with a specific table from the paper

1. Crops_Reg_Crops_Call.do: this produces Table 2 from the paper, with samples distinguished by crop families 
2. Crops_Reg_KGZones_Call.do: this produces Table 3 from the paper, with samples distinguished by climate zone
3. Crops_Reg_Region_Call.do: this produces Table 4 from the paper, with samples distinguished by region

"Crops_Reg_Master.do" can be run over and over again, setting different globals to different values to change the nature of the regressions. Our main robustness checks are all shown in the do-file (commented out) so one can see the idea. For example, to run using population data from 1900 we do the following
```
// 1900 population results
reset
global year 1900
global tag = "pop1900"
do "$code/Crops_Reg_Crops_Call.do" // call the crop-specific regressions
```
which will replicate Table 2, but using population data from 1900, and putting the tag "pop1900" in all the output file names.

### Producing tables
All of the regression output is written directly to TEX files. To see those results, you can compile the document. The file "Constraints-Tables.tex" in the "Drafts" folder is a tex document that is stripped down to only produce tables and figures, and includes no text or bibliography from the actual paper. Use your preferred TeX system to compile this.

Alternatively, you can simply view the TEX files of the tables. They are reasonably clear to look at in a normal text editor, but do not contain the normal headings found in the paper. 

## Replication of Table 5, Population Change
We do a validation check using the Acemoglu and Johnson dataset from "Disease and Development". The dataset, named "disease.dta", is available from Acemoglu's website. We do not alter it in any way. 

The code "Crops_Reg_Mortality.do" uses this data, after estimating separate elasticities for each country. You will only have to edit the directory locations in that do-file to reproduce Table 5.

## Replication of province-level estimates
As part of the appendix, we run separate estimates of the land elasticity for each province, and then look at the summary statistics of the elasticities by sub-sample, to confirm the variation we see in the baseline results. The script for this analysis is "Crops_Reg_Provinces.do".