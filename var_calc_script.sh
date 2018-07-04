#####script to calculate annual variance/mean/standard deviation for each dataset

declare -a Dataset=("ACCESS1-0" "ACCESS1-3" "bcc-csm1-1" "BNU-ESM" "CanESM2" "CCSM4" "CMCC-CESM" "CMCC-CM" "CNRM-CM5" "CSIRO-Mk3-6-0"\
		    "GFDL-CM3" "GFDL-ESM2G" "GFDL-ESM2M" "HadGEM2-CC" "HadGEM2-ES" "inmcm4" "IPSL-CM5A-LR" "IPSL-CM5A-MR" "IPSL-CM5B-LR"\
		     "MIROC5" "MIROC-ESM" "MIROC-ESM-CHEM" "MPI-ESM-LR" "MPI-ESM-MR" "MRI-CGCM3" "NorESM1-M" "HadGHCND")
		    
		    
#calculate annual variance from each file

	for idat in "${Dataset[@]}"
		do cdo yearstd "/srv/ccrc/data04/z5026024/CMIP5/hist_rcp85/anomalies/"$idat"_TN_1950-2014_anoms_masked_smoothed.nc" "/srv/ccrc/data04/z5026024/CMIP5/hist_rcp85/anomalies/ann_std/"$idat"_TN_1950-2014_anoms_masked_smoothed_ann_std.nc"
	done		    

