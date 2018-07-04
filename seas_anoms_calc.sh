#####script to calculate seasons, split years, multi-model mean from CMIP5 files

###declare an array variable...separate with a SPACE, not a comma!!
#declare -a Dataset=("ACCESS1-0" "ACCESS1-3" "bcc-csm1-1" "BNU-ESM" "CanESM2" "CCSM4" "CMCC-CESM" "CMCC-CM" "CNRM-CM5" "CSIRO-Mk3-6-0"\
#		    "GFDL-CM3" "GFDL-ESM2G" "GFDL-ESM2M" "HadGEM2-CC" "HadGEM2-ES" "inmcm4" "IPSL-CM5A-LR" "IPSL-CM5A-MR" "IPSL-CM5B-LR"\
#		     "MIROC5" "MIROC-ESM" "MIROC-ESM-CHEM" "MPI-ESM-LR" "MPI-ESM-MR" "MRI-CGCM3" "NorESM1-M")

declare -a Dataset=("CanESM2" "CNRM-CM5" "CSIRO-Mk3-6-0" "inmcm4" "MPI-ESM-MR")
#declare -a Dataset=("CNRM-CM5")
declare -a Variable=("clt")
declare -a Season=("DJF" "MAM" "SON")

#for iDat in "${Dataset[@]}";do
# for iVar in "${Variable[@]}";do
#    cdo splitseas "/srv/ccrc/data01/z5026024/cloud_cover_data/"$iVar"_day_"$iDat"_1950-2099_masked_2.5x2.5.nc" \
#    "/srv/ccrc/data01/z5026024/cloud_cover_data/seasonal/"$iVar"_day_"$iDat"_1950-2099_2.5x2.5_"
# done
#done

#for iDat in "${Dataset[@]}";do
# #for iVar in "${Variable[@]}";do
#  for iSeas in "${Season[@]}";do
#    cdo cat "/srv/ccrc/data01/z5026024/extremes_only_files/future_tas_1950-2099_clim/annual_exceedances/"$iDat"_tas_MIN_50-99_clim_"*"_EXTREMES_ONLY_2.5x2.5_"$iSeas".nc" \
#    "/srv/ccrc/data01/z5026024/extremes_only_files/future_tas_1950-2099_clim/annual_exceedances/"$iDat"_tas_MIN_50-99_clim_1950-2099_EXTREMES_ONLY_2.5x2.5_"$iSeas".nc"
#  done
# #done
#done	

#split files into time periods i.e. 1950-1979 and 2070-2099 (do for daily anomalies and annual mean!)

for iDat in "${Dataset[@]}";do
 for iVar in "${Variable[@]}";do
  for iSeas in "${Season[@]}";do
    cdo selyear,2070/2099 "/srv/ccrc/data01/z5026024/cloud_cover_data/seasonal/"$iVar"_day_"$iDat"_1950-2099_2.5x2.5_"$iSeas".nc" \
    "/srv/ccrc/data01/z5026024/cloud_cover_data/split_yrs/"$iVar"_day_"$iDat"_2070-2099_2.5x2.5_"$iSeas".nc"
  done
 done
done
