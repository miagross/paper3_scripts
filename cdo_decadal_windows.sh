#/bin/sh
##for decadal windows

declare -a Variable=("clt")
declare -a Season=("SON" "DJF" "MAM")
declare -a Model=("CanESM2" "CNRM-CM5" "CSIRO-Mk3-6-0" "inmcm4" "MPI-ESM-MR")
#declare -a Years=("1950" "1960" "1970" "1980" "1990" "2000" "2010" "2020" "2030" "2040" "2050" "2060" "2070" "2080" "2090")

#for iseas in "${Season[@]}";do
# #for ivar in "${Variable[@]}";do 
#  for iYr in "${Years[@]}";do
#   #echo $iYr/$((iYr+10))
#   cdo selyear,$iYr/$((iYr+9)) \
#   	"/srv/ccrc/data04/z5026024/CMIP5/heat_flux_data/hfss/hfss_day_CSIRO-Mk3-6-0_1950-2100_masked_2.5x2.5_"$iseas".nc" \
#	"/srv/ccrc/data04/z5026024/CMIP5/heat_flux_data/hfss/decadal/hfss_day_CSIRO-Mk3-6-0_"$iYr"-"$((iYr+9))"_masked_2.5x2.5_"$iseas".nc" 
#  done
# #done
#done


##for annual:
#for iVar in "${Variable[@]}";do
for iMod in "${Model[@]}";do
 for iSeas in "${Season[@]}";do
  for iYr in {2070..2099};do
  	cdo selyear,$iYr/$((iYr)) \
   		"/srv/ccrc/data40/z5026024/CMIP5/test_anoms_clims/split_yrs/"$iMod"_tas_anoms_test_clim_2070-2099_2.5x2.5_"$iSeas".nc" \
		"/srv/ccrc/data40/z5026024/CMIP5/test_anoms_clims/split_yrs/annual/"$iMod"_tas_anoms_test_clim_"$iYr"_2.5x2.5_"$iSeas".nc"
  done
 done
done
# done


######to calculate albedo (UW SW/DW SW)
#for iMod in "${Model[@]}";do
# for iSeas in "${Season[@]}";do
#  cdo div "/srv/ccrc/data04/z5026024/CMIP5/variables_data/rsus_day_"$iMod"_1950-2099_masked_2.5x2.5_"$iSeas".nc" \
#  "/srv/ccrc/data04/z5026024/CMIP5/variables_data/rsds_day_"$iMod"_1950-2099_masked_2.5x2.5_"$iSeas".nc" \
#  "/srv/ccrc/data04/z5026024/CMIP5/variables_data/albedo_day_"$iMod"_1950-2099_masked_2.5x2.5_"$iSeas".nc"
# done
#done


######to calculate net radiation budget (Q* = (DW SW - UW SW) + (DW LW - UW LW)
#for iMod in "${Model[@]}";do
# for iSeas in "${Season[@]}";do
#  cdo add "/srv/ccrc/data04/z5026024/CMIP5/net_radiation/Knet_"$iMod"_1950-2099_masked_2.5x2.5_"$iSeas".nc" \
#  "/srv/ccrc/data04/z5026024/CMIP5/net_radiation/Lnet_"$iMod"_1950-2099_masked_2.5x2.5_"$iSeas".nc" \
#  "/srv/ccrc/data04/z5026024/CMIP5/variables_data/Qnet_day_"$iMod"_1950-2099_masked_2.5x2.5_"$iSeas".nc"
# done
#done

	
