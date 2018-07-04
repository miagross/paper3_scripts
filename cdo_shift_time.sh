#/bin/sh

declare -a Model=("CanESM2" "CNRM-CM5" "CSIRO-Mk3-6-0" "inmcm4" "MPI-ESM-MR")
#declare -a Model=("CNRM-CM5")

for iDat in "${Model[@]}";do
 cdo shifttime,+1days "/srv/ccrc/data01/z5026024/snow_cover_data/snc_day_"$iDat"_1950-2099_masked_2.5x2.5_new.nc" \
 		      "/srv/ccrc/data01/z5026024/snow_cover_data/snc_minus1_day_"$iDat"_1950-2099_masked_2.5x2.5.nc"
done 
