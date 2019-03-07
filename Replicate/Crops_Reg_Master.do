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
do "./Replicate/ols_spatial_HAC.ado" // set up program to do spatial standard errors
do "./Replicate/Crops_Reg_Program.do" // set up program used to run interaction regressions

//////////////////////////////////////
// Scripts to prepare data
//////////////////////////////////////
do "./Replicate/Crops_Reg_Collapse.do" // combines separate GIS datasets to one
do "./Replicate/Crops_Reg_Prep.do" // generates needed variables, set labels

//------ Need only run above this line once -------//

//////////////////////////////////////
// Baseline results table
//////////////////////////////////////
do "./Replicate/Crops_Reg_Base.do" // call the main temperate/tropical regressions (Table 2)
do "./Replicate/Crops_Reg_PopLand.do" // call robustness regressions (Table 3)
do "./Replicate/Crops_Reg_GAEZ.do" // call productivity regressions (Table 4)
do "./Replicate/Crops_Reg_DHS.do" // call DHS regressions (Table 5)

do "./Replicate/Crops_Reg_Region.do" // call political region regressions (Appendix)
do "./Replicate/Crops_Reg_Extend.do" // call extended crop definition regressions (Appendix)
do "./Replicate/Crops_Reg_ByCrop.do" // call single crop definition regressions (Appendix)

