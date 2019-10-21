//////////////////////////////////////////////////////////////////////
// Master script
//
// Control the flow of work for regressions
// 1. Create program to reset globals controlling code
// 2. Call data merge and prep routines
// 3. Call regression routines under various assumptions
//
//////////////////////////////////////////////////////////////////////

cd "/users/dietz/dropbox/project/crops/"

set scheme plotplain

//////////////////////////////////////
// Scripts to load programs
//////////////////////////////////////
do "./Replicate/ols_spatial_JV.do" // set up program to do spatial standard errors
do "./Replicate/Crops_Reg_Program.do" // set up program used to run interaction regressions

//////////////////////////////////////
// Scripts to prepare data
//////////////////////////////////////
do "./Replicate/Crops_Reg_Collapse.do" // combines separate GIS datasets to one
do "./Replicate/Crops_Reg_Distance.do" // create measures of distance to cities
do "./Replicate/Crops_Reg_Prep.do" // generates needed variables, summary stats (Table 1)
do "./Replicate/Crops_Reg_IPUMS_Prep.do" // prep IPUMS data for use in Table 4
do "./Replicate/Crops_DHS_Migration.do" // migration data (Table 2)

//////////////////////////////////////
// Baseline results table
//////////////////////////////////////
do "./Replicate/Crops_Reg_Base.do" // call the main temperate/tropical regressions (Table 3)
do "./Replicate/Crops_Reg_PopLand.do" // call robustness regressions (Table 4)
do "./Replicate/Crops_Reg_GAEZ.do" // call productivity regressions (Table 5)
do "./Replicate/Crops_Reg_DHS.do" // call DHS regressions (Table 6)
do "./Replicate/Crops_Reg_Mixed.do" // call mixed region reg (Table 7)
do "./Replicate/Crops_Reg_Aggregate.do" // calc aggregate betas (Table 8)
do "./Replicate/Crops_Reg_Mortality.do" // call mortality regressions (Table 9)

do "./Replicate/Crops_Reg_ByCrop.do" // call single crop definition regressions (Appendix)
do "./Replicate/Crops_Reg_Climate.do" // call reg by climate zone (Appendix)
do "./Replicate/Crops_Reg_Constraints.do" // call reg using GAEZ constraints as controls (Appendix)
do "./Replicate/Crops_Reg_Terrain.do" // call reg limiting sample by terrain (Appendix)
