load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Script to calculate and plot changes in incoming/outgoing;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;longwave/shortwave radiation;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

begin 

;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "MPI-ESM-MR_changes_radiation_TNn_MAM"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)
plot = new(12,graphic)			;create plot array

;;;set-up map space
greymap=(/"grey"/) ; colormap with grey
gsn_merge_colormaps(wks,"posneg_1",greymap) 	;merge two color maps.. used to be hotcolr_19lev


;***********************************************************
;;******************READ IN INPUT FILES*********************
;***********************************************************

;;;RADIATION DATA

DLWDataDir_p1 = "/srv/ccrc/data04/z5026024/CMIP5/radiation_data/"
DLWData_p1 = DLWDataDir_p1+"rlds_day_MPI-ESM-MR_1950-1981_masked_2.5x2.5_MAM.nc"
DLWFile_p1 = addfile(DLWData_p1,"r")

DLW_p1	= DLWFile_p1->rlds		;downwelling longwave period 1

DLWDataDir_p2 = "/srv/ccrc/data04/z5026024/CMIP5/radiation_data/"
DLWData_p2 = DLWDataDir_p2+"rlds_day_MPI-ESM-MR_1982-2014_masked_2.5x2.5_MAM.nc"
DLWFile_p2 = addfile(DLWData_p2,"r")

DLW_p2	= DLWFile_p2->rlds		;downwelling longwave period 2


ULWDataDir_p1 = "/srv/ccrc/data04/z5026024/CMIP5/radiation_data/"
ULWData_p1 = ULWDataDir_p1+"rlus_day_MPI-ESM-MR_1950-1981_masked_2.5x2.5_MAM.nc"
ULWFile_p1 = addfile(ULWData_p1,"r")

ULW_p1	= ULWFile_p1->rlus		;upwelling longwave period 1

ULWDataDir_p2 = "/srv/ccrc/data04/z5026024/CMIP5/radiation_data/"
ULWData_p2 = DLWDataDir_p2+"rlus_day_MPI-ESM-MR_1982-2014_masked_2.5x2.5_MAM.nc"
ULWFile_p2 = addfile(ULWData_p2,"r")

ULW_p2	= ULWFile_p2->rlus		;upwelling longwave period 2

DSWDataDir_p1 = "/srv/ccrc/data04/z5026024/CMIP5/radiation_data/"
DSWData_p1 = DSWDataDir_p1+"rsds_day_MPI-ESM-MR_1950-1981_masked_2.5x2.5_MAM.nc"
DSWFile_p1 = addfile(DSWData_p1,"r")

DSW_p1	= DSWFile_p1->rsds		;downwelling shortwave period 1

DSWDataDir_p2 = "/srv/ccrc/data04/z5026024/CMIP5/radiation_data/"
DSWData_p2 = DSWDataDir_p2+"rsds_day_MPI-ESM-MR_1982-2014_masked_2.5x2.5_MAM.nc"
DSWFile_p2 = addfile(DSWData_p2,"r")

DSW_p2	= DSWFile_p2->rsds		;downwelling shortwave period 2

USWDataDir_p1 = "/srv/ccrc/data04/z5026024/CMIP5/radiation_data/"
USWData_p1 = USWDataDir_p1+"rsus_day_MPI-ESM-MR_1950-1981_masked_2.5x2.5_MAM.nc"
USWFile_p1 = addfile(USWData_p1,"r")

USW_p1	= USWFile_p1->rsus		;upwelling shortwave period 1

USWDataDir_p2 = "/srv/ccrc/data04/z5026024/CMIP5/radiation_data/"
USWData_p2 = USWDataDir_p2+"rsus_day_MPI-ESM-MR_1982-2014_masked_2.5x2.5_MAM.nc"
USWFile_p2 = addfile(USWData_p2,"r")

USW_p2	= USWFile_p2->rsus		;upwelling shortwave period 2


;;;ANNUAL EXTREME TEMP DATA

ExtDataDir = "/srv/ccrc/data04/z5026024/extremes_only_files/"
ExtData = ExtDataDir+"MPI-ESM-MR_TNn_1950-1981_masked_EXTREMES_ONLY_2.5x2.5_MAM.nc"
file1 = addfile(ExtData,"r")
ext_p1 = file1->extremes
lats = ext_p1&lat
lons = ext_p1&lon

;print(lats)
;printVarSummary(temp_p1)	;shows co-ordinates if using individual grid box!

ExtDataDir2 = "/srv/ccrc/data04/z5026024/extremes_only_files/"
ExtData2 = ExtDataDir2+"MPI-ESM-MR_TNn_1982-2014_masked_EXTREMES_ONLY_2.5x2.5_MAM.nc"
file2 = addfile(ExtData2,"r")
ext_p2 = file2->extremes


;***********************************************************
;;*************Set up data/calculations*********************
;***********************************************************

;;;SET UP EMPTY ARRAYS TO STORE DATA
ext_p1_3d = new(dimsizes(ext_p1),"float",-999.9)
ext_p2_3d = new(dimsizes(ext_p2),"float",-999.9)
DLW_p1_3d = new(dimsizes(DLW_p1),"float",-999.9)
DLW_p2_3d = new(dimsizes(DLW_p2),"float",-999.9)
ULW_p1_3d = new(dimsizes(ULW_p1),"float",-999.9)
ULW_p2_3d = new(dimsizes(ULW_p2),"float",-999.9)
DSW_p1_3d = new(dimsizes(DSW_p1),"float",-999.9)
DSW_p2_3d = new(dimsizes(DSW_p2),"float",-999.9)
USW_p1_3d = new(dimsizes(USW_p1),"float",-999.9)
USW_p2_3d = new(dimsizes(USW_p2),"float",-999.9)


;;;LOOP THROUGH LAT/LON TO GET CHANGES FOR EACH GRIDBOX

do ilat=0,dimsizes(lats)-1
 Lat=lats(ilat)
 ;print(ilat+": "+Lat)
 
 do ilon=0,dimsizes(lons)-1
  Lon=lons(ilon)
  ;print(ilon+": "+Lon)
  

  ;;;ONLY USE VALUES WHERE THERE ARE EXTREME VALUES
  ;;;i.e. ONLY USE VALUES WHERE NON-MISSING IN TEMP DATA

  ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(:,ilat,ilon)))		;indices that are non-missing in temp i.e. extremes
  
  if(.not.all(ismissing(ext_p1_ind_nomiss))) then   
   ext_p1_nomiss = ext_p1(ext_p1_ind_nomiss,ilat,ilon)  
   DLW_p1_extremes_only = DLW_p1(ext_p1_ind_nomiss,ilat,ilon)		;only indclude values for time steps with non-missing temp
   ULW_p1_extremes_only = ULW_p1(ext_p1_ind_nomiss,ilat,ilon)
   DSW_p1_extremes_only = DSW_p1(ext_p1_ind_nomiss,ilat,ilon)
   USW_p1_extremes_only = USW_p1(ext_p1_ind_nomiss,ilat,ilon)
   len_ext_p1 = dimsizes(ext_p1_nomiss)
   ext_p1_3d(0:(len_ext_p1)-1,ilat,ilon) = ext_p1_nomiss
   DLW_p1_3d(0:len_ext_p1-1,ilat,ilon) = DLW_p1_extremes_only
   ULW_p1_3d(0:len_ext_p1-1,ilat,ilon) = ULW_p1_extremes_only
   DSW_p1_3d(0:len_ext_p1-1,ilat,ilon) = DSW_p1_extremes_only
   USW_p1_3d(0:len_ext_p1-1,ilat,ilon) = USW_p1_extremes_only 
   delete([/ext_p1_nomiss,DLW_p1_extremes_only,ULW_p1_extremes_only,DSW_p1_extremes_only,USW_p1_extremes_only/])
  end if
  
  delete([/ext_p1_ind_nomiss/])
  
  ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(:,ilat,ilon)))
     
  if(.not.all(ismissing(ext_p2_ind_nomiss))) then      
   ext_p2_nomiss = ext_p2(ext_p2_ind_nomiss,ilat,ilon)  
   DLW_p2_extremes_only = DLW_p2(ext_p2_ind_nomiss,ilat,ilon)		
   ULW_p2_extremes_only = ULW_p2(ext_p2_ind_nomiss,ilat,ilon)
   DSW_p2_extremes_only = DSW_p2(ext_p2_ind_nomiss,ilat,ilon)
   USW_p2_extremes_only = USW_p2(ext_p2_ind_nomiss,ilat,ilon)
   len_ext_p2 = dimsizes(ext_p2_nomiss)   
   ext_p2_3d(0:len_ext_p2-1,ilat,ilon) = ext_p2_nomiss
   DLW_p2_3d(0:len_ext_p2-1,ilat,ilon) = DLW_p2_extremes_only
   ULW_p2_3d(0:len_ext_p2-1,ilat,ilon) = ULW_p2_extremes_only
   DSW_p2_3d(0:len_ext_p2-1,ilat,ilon) = DSW_p2_extremes_only
   USW_p2_3d(0:len_ext_p2-1,ilat,ilon) = USW_p2_extremes_only
   delete([/ext_p2_nomiss,DLW_p2_extremes_only,ULW_p2_extremes_only,DSW_p2_extremes_only,USW_p2_extremes_only/])
  end if
  
  delete([/ext_p2_ind_nomiss/])
  
 end do		;ends ilon loop
end do		;ends ilat loop
 
  
;;;CALCULATE AVERAGE OVER P1 AND P2, AND THEN P2 - P1 FOR CHANGES

DLW_p1_ext_ave = dim_avg_n_Wrap(DLW_p1_3d,0)		;average for downwelling longwave
DLW_p2_ext_ave = dim_avg_n_Wrap(DLW_p2_3d,0)
DLW_p1_mean_ave = dim_avg_n_Wrap(DLW_p1,0)
DLW_p2_mean_ave = dim_avg_n_Wrap(DLW_p2,0)

ULW_p1_ext_ave = dim_avg_n_Wrap(ULW_p1_3d,0)		;average for upwelling longwave
ULW_p2_ext_ave = dim_avg_n_Wrap(ULW_p2_3d,0)
ULW_p1_mean_ave = dim_avg_n_Wrap(ULW_p1,0)
ULW_p2_mean_ave = dim_avg_n_Wrap(ULW_p2,0)

DSW_p1_ext_ave = dim_avg_n_Wrap(DSW_p1_3d,0)		;average for downwelling shortwave
DSW_p2_ext_ave = dim_avg_n_Wrap(DSW_p2_3d,0)
DSW_p1_mean_ave = dim_avg_n_Wrap(DSW_p1,0)
DSW_p2_mean_ave = dim_avg_n_Wrap(DSW_p2,0)

USW_p1_ext_ave = dim_avg_n_Wrap(USW_p1_3d,0)		;average for upwelling shortwave
USW_p2_ext_ave = dim_avg_n_Wrap(USW_p2_3d,0)
USW_p1_mean_ave = dim_avg_n_Wrap(USW_p1,0)
USW_p2_mean_ave = dim_avg_n_Wrap(USW_p2,0)


DLW_ext_changes = DLW_p2_ext_ave - DLW_p1_ext_ave		;changes in downwelling longwave radiation
ULW_ext_changes = ULW_p2_ext_ave - ULW_p1_ext_ave		;changes in upwelling longwave radiation
DSW_ext_changes = DSW_p2_ext_ave - DSW_p1_ext_ave		;changes in downwelling shortwave radiation
USW_ext_changes = USW_p2_ext_ave - USW_p1_ext_ave		;changes in upwelling shortwave radiation

DLW_mean_changes = DLW_p2_mean_ave - DLW_p1_mean_ave
ULW_mean_changes = ULW_p2_mean_ave - ULW_p1_mean_ave
DSW_mean_changes = DSW_p2_mean_ave - DSW_p1_mean_ave
USW_mean_changes = USW_p2_mean_ave - USW_p1_mean_ave

DLW_excess = DLW_ext_changes - DLW_mean_changes
ULW_excess = ULW_ext_changes - ULW_mean_changes
DSW_excess = DSW_ext_changes - DSW_mean_changes
USW_excess = USW_ext_changes - USW_mean_changes


DLW_ext_changes!0="lat"
DLW_ext_changes&lat=lats
DLW_ext_changes&lat@units="degrees_north"
DLW_ext_changes!1="lon"
DLW_ext_changes&lon=lons
DLW_ext_changes&lon@units="degrees_east"

DLW_mean_changes!0="lat"
DLW_mean_changes&lat=lats
DLW_mean_changes&lat@units="degrees_north"
DLW_mean_changes!1="lon"
DLW_mean_changes&lon=lons
DLW_mean_changes&lon@units="degrees_east"

DLW_excess!0="lat"
DLW_excess&lat=lats
DLW_excess&lat@units="degrees_north"
DLW_excess!1="lon"
DLW_excess&lon=lons
DLW_excess&lon@units="degrees_east"

ULW_ext_changes!0="lat"
ULW_ext_changes&lat=lats
ULW_ext_changes&lat@units="degrees_north"
ULW_ext_changes!1="lon"
ULW_ext_changes&lon=lons
ULW_ext_changes&lon@units="degrees_east"

ULW_mean_changes!0="lat"
ULW_mean_changes&lat=lats
ULW_mean_changes&lat@units="degrees_north"
ULW_mean_changes!1="lon"
ULW_mean_changes&lon=lons
ULW_mean_changes&lon@units="degrees_east"

ULW_excess!0="lat"
ULW_excess&lat=lats
ULW_excess&lat@units="degrees_north"
ULW_excess!1="lon"
ULW_excess&lon=lons
ULW_excess&lon@units="degrees_east"

DSW_ext_changes!0="lat"
DSW_ext_changes&lat=lats
DSW_ext_changes&lat@units="degrees_north"
DSW_ext_changes!1="lon"
DSW_ext_changes&lon=lons
DSW_ext_changes&lon@units="degrees_east"

DSW_mean_changes!0="lat"
DSW_mean_changes&lat=lats
DSW_mean_changes&lat@units="degrees_north"
DSW_mean_changes!1="lon"
DSW_mean_changes&lon=lons
DSW_mean_changes&lon@units="degrees_east"

DSW_excess!0="lat"
DSW_excess&lat=lats
DSW_excess&lat@units="degrees_north"
DSW_excess!1="lon"
DSW_excess&lon=lons
DSW_excess&lon@units="degrees_east"

USW_ext_changes!0="lat"
USW_ext_changes&lat=lats
USW_ext_changes&lat@units="degrees_north"
USW_ext_changes!1="lon"
USW_ext_changes&lon=lons
USW_ext_changes&lon@units="degrees_east"

USW_mean_changes!0="lat"
USW_mean_changes&lat=lats
USW_mean_changes&lat@units="degrees_north"
USW_mean_changes!1="lon"
USW_mean_changes&lon=lons
USW_mean_changes&lon@units="degrees_east"

USW_excess!0="lat"
USW_excess&lat=lats
USW_excess&lat@units="degrees_north"
USW_excess!1="lon"
USW_excess&lon=lons
USW_excess&lon@units="degrees_east"
;print(USW_changes)

;***********************************************************
;;*******************Plot data on map***********************
;*********************************************************** 				

;;;PLOT DOWNWELLING LONGWAVE RADIATION
res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True			;Turn off individual lb's
res@lbLabelFontHeightF		= .013			;Make labels larger

res@mpMinLatF			= 30			;Plots less Antarctica - turn off for Robinson
;res@gsnCenterString		= ""
;res@gsnLeftString		= ""
;res@gsnRightString		= ""
res@cnInfoLabelOn		= False			;Turn off info label
;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
res@gsnTickMarksOn		= False			;Turn on/off all tick marks
;res@tmXBLabelFontHeightF	= 0.022
;res@tmEqualizeXYSizes		= True

res@gsnSpreadColors		= True			;Use full range of color map
res@gsnSpreadColorStart		= 5			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 20			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 5			;originally 1 Set max contour level
res@cnLevelSpacingF		= 1.0			;originally 0.2
 
res@gsnLeftString		= "Changes in downwelling longwave radiation (extremes only)"
res@gsnStringFontHeightF	= 0.02

plot(0) = gsn_csm_contour_map_ce(wks,DLW_ext_changes,res)

res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True			;Turn off individual lb's
res@lbLabelFontHeightF		= .013			;Make labels larger

res@mpMinLatF			= 30			;Plots less Antarctica - turn off for Robinson
;res@gsnCenterString		= ""
;res@gsnLeftString		= ""
;res@gsnRightString		= ""
res@cnInfoLabelOn		= False			;Turn off info label
;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
res@gsnTickMarksOn		= False			;Turn on/off all tick marks
;res@tmXBLabelFontHeightF	= 0.022
;res@tmEqualizeXYSizes		= True

res@gsnSpreadColors		= True			;Use full range of color map
res@gsnSpreadColorStart		= 5			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 20			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 5			;originally 1 Set max contour level
res@cnLevelSpacingF		= 1.0			;originally 0.2
 
res@gsnLeftString		= "Changes in mean downwelling longwave radiation"
res@gsnStringFontHeightF	= 0.02

plot(1) = gsn_csm_contour_map_ce(wks,DLW_mean_changes,res)

res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True			;Turn off individual lb's
res@lbLabelFontHeightF		= .013			;Make labels larger

res@mpMinLatF			= 30			;Plots less Antarctica - turn off for Robinson
;res@gsnCenterString		= ""
;res@gsnLeftString		= ""
;res@gsnRightString		= ""
res@cnInfoLabelOn		= False			;Turn off info label
;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
res@gsnTickMarksOn		= False			;Turn on/off all tick marks
;res@tmXBLabelFontHeightF	= 0.022
;res@tmEqualizeXYSizes		= True

res@gsnSpreadColors		= True			;Use full range of color map
res@gsnSpreadColorStart		= 5			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 20			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 5			;originally 1 Set max contour level
res@cnLevelSpacingF		= 1.0			;originally 0.2
 
res@gsnLeftString		= "Excess changes in downwelling longwave radiation"
res@gsnStringFontHeightF	= 0.02

plot(2) = gsn_csm_contour_map_ce(wks,DLW_excess,res)		


;;;PLOT UPWELLING LONGWAVE RADIATION
res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True			;Turn off individual lb's
res@lbLabelFontHeightF		= .013			;Make labels larger

res@mpMinLatF			= 30			;Plots less Antarctica - turn off for Robinson
;res@gsnCenterString		= ""
;res@gsnLeftString		= ""
;res@gsnRightString		= ""
res@cnInfoLabelOn		= False			;Turn off info label
;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
res@gsnTickMarksOn		= False			;Turn on/off all tick marks
;res@tmXBLabelFontHeightF	= 0.022
;res@tmEqualizeXYSizes		= True

res@gsnSpreadColors		= True			;Use full range of color map
res@gsnSpreadColorStart		= 5			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 20			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 5			;originally 1 Set max contour level
res@cnLevelSpacingF		= 1.0			;originally 0.2
 
res@gsnLeftString		= "Changes in upwelling longwave radiation (extremes only)"
res@gsnStringFontHeightF	= 0.02

plot(3) = gsn_csm_contour_map_ce(wks,ULW_ext_changes,res)

res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True			;Turn off individual lb's
res@lbLabelFontHeightF		= .013			;Make labels larger

res@mpMinLatF			= 30			;Plots less Antarctica - turn off for Robinson
;res@gsnCenterString		= ""
;res@gsnLeftString		= ""
;res@gsnRightString		= ""
res@cnInfoLabelOn		= False			;Turn off info label
;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
res@gsnTickMarksOn		= False			;Turn on/off all tick marks
;res@tmXBLabelFontHeightF	= 0.022
;res@tmEqualizeXYSizes		= True

res@gsnSpreadColors		= True			;Use full range of color map
res@gsnSpreadColorStart		= 5			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 20			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 5			;originally 1 Set max contour level
res@cnLevelSpacingF		= 1.0			;originally 0.2
 
res@gsnLeftString		= "Changes in mean upwelling longwave radiation"
res@gsnStringFontHeightF	= 0.02

plot(4) = gsn_csm_contour_map_ce(wks,ULW_mean_changes,res)	

res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True			;Turn off individual lb's
res@lbLabelFontHeightF		= .013			;Make labels larger

res@mpMinLatF			= 30			;Plots less Antarctica - turn off for Robinson
;res@gsnCenterString		= ""
;res@gsnLeftString		= ""
;res@gsnRightString		= ""
res@cnInfoLabelOn		= False			;Turn off info label
;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
res@gsnTickMarksOn		= False			;Turn on/off all tick marks
;res@tmXBLabelFontHeightF	= 0.022
;res@tmEqualizeXYSizes		= True

res@gsnSpreadColors		= True			;Use full range of color map
res@gsnSpreadColorStart		= 5			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 20			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 5			;originally 1 Set max contour level
res@cnLevelSpacingF		= 1.0			;originally 0.2
 
res@gsnLeftString		= "Excess changes in upwelling longwave radiation"
res@gsnStringFontHeightF	= 0.02

plot(5) = gsn_csm_contour_map_ce(wks,ULW_excess,res)		


;;;PLOT DOWNWELLING SHORTWAVE RADIATION
res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True			;Turn off individual lb's
res@lbLabelFontHeightF		= .013			;Make labels larger

res@mpMinLatF			= 30			;Plots less Antarctica - turn off for Robinson
;res@gsnCenterString		= ""
;res@gsnLeftString		= ""
;res@gsnRightString		= ""
res@cnInfoLabelOn		= False			;Turn off info label
;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
res@gsnTickMarksOn		= False			;Turn on/off all tick marks
;res@tmXBLabelFontHeightF	= 0.022
;res@tmEqualizeXYSizes		= True

res@gsnSpreadColors		= True			;Use full range of color map
res@gsnSpreadColorStart		= 5			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 20			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 5			;originally 1 Set max contour level
res@cnLevelSpacingF		= 1.0			;originally 0.2
 
res@gsnLeftString		= "Changes in downwelling shortwave radiation (extremes only)"
res@gsnStringFontHeightF	= 0.02

plot(6) = gsn_csm_contour_map_ce(wks,DSW_ext_changes,res)

res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True			;Turn off individual lb's
res@lbLabelFontHeightF		= .013			;Make labels larger

res@mpMinLatF			= 30			;Plots less Antarctica - turn off for Robinson
;res@gsnCenterString		= ""
;res@gsnLeftString		= ""
;res@gsnRightString		= ""
res@cnInfoLabelOn		= False			;Turn off info label
;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
res@gsnTickMarksOn		= False			;Turn on/off all tick marks
;res@tmXBLabelFontHeightF	= 0.022
;res@tmEqualizeXYSizes		= True

res@gsnSpreadColors		= True			;Use full range of color map
res@gsnSpreadColorStart		= 5			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 20			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 5			;originally 1 Set max contour level
res@cnLevelSpacingF		= 1.0			;originally 0.2
 
res@gsnLeftString		= "Changes in mean downwelling shortwave radiation"
res@gsnStringFontHeightF	= 0.02

plot(7) = gsn_csm_contour_map_ce(wks,DSW_mean_changes,res)

res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True			;Turn off individual lb's
res@lbLabelFontHeightF		= .013			;Make labels larger

res@mpMinLatF			= 30			;Plots less Antarctica - turn off for Robinson
;res@gsnCenterString		= ""
;res@gsnLeftString		= ""
;res@gsnRightString		= ""
res@cnInfoLabelOn		= False			;Turn off info label
;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
res@gsnTickMarksOn		= False			;Turn on/off all tick marks
;res@tmXBLabelFontHeightF	= 0.022
;res@tmEqualizeXYSizes		= True

res@gsnSpreadColors		= True			;Use full range of color map
res@gsnSpreadColorStart		= 5			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 20			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 5			;originally 1 Set max contour level
res@cnLevelSpacingF		= 1.0			;originally 0.2
 
res@gsnLeftString		= "Excess changes in downwelling shortwave radiation"
res@gsnStringFontHeightF	= 0.02

plot(8) = gsn_csm_contour_map_ce(wks,DSW_excess,res)			


;;;PLOT UPWELLING SHORTWAVE RADIATION
res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True			;Turn off individual lb's
res@lbLabelFontHeightF		= .013			;Make labels larger

res@mpMinLatF			= 30			;Plots less Antarctica - turn off for Robinson
;res@gsnCenterString		= ""
;res@gsnLeftString		= ""
;res@gsnRightString		= ""
res@cnInfoLabelOn		= False			;Turn off info label
;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
res@gsnTickMarksOn		= False			;Turn on/off all tick marks
;res@tmXBLabelFontHeightF	= 0.022
;res@tmEqualizeXYSizes		= True

res@gsnSpreadColors		= True			;Use full range of color map
res@gsnSpreadColorStart		= 5			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 20			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 5			;originally 1 Set max contour level
res@cnLevelSpacingF		= 1.0			;originally 0.2
 
res@gsnLeftString		= "Changes in upwelling shortwave radiation (extremes only)"
res@gsnStringFontHeightF	= 0.02

plot(9) = gsn_csm_contour_map_ce(wks,USW_ext_changes,res)

res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True			;Turn off individual lb's
res@lbLabelFontHeightF		= .013			;Make labels larger

res@mpMinLatF			= 30			;Plots less Antarctica - turn off for Robinson
;res@gsnCenterString		= ""
;res@gsnLeftString		= ""
;res@gsnRightString		= ""
res@cnInfoLabelOn		= False			;Turn off info label
;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
res@gsnTickMarksOn		= False			;Turn on/off all tick marks
;res@tmXBLabelFontHeightF	= 0.022
;res@tmEqualizeXYSizes		= True

res@gsnSpreadColors		= True			;Use full range of color map
res@gsnSpreadColorStart		= 5			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 20			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 5			;originally 1 Set max contour level
res@cnLevelSpacingF		= 1.0			;originally 0.2
 
res@gsnLeftString		= "Changes in mean upwelling shortwave radiation"
res@gsnStringFontHeightF	= 0.02

plot(10) = gsn_csm_contour_map_ce(wks,USW_mean_changes,res)

res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True			;Turn off individual lb's
res@lbLabelFontHeightF		= .013			;Make labels larger

res@mpMinLatF			= 30			;Plots less Antarctica - turn off for Robinson
;res@gsnCenterString		= ""
;res@gsnLeftString		= ""
;res@gsnRightString		= ""
res@cnInfoLabelOn		= False			;Turn off info label
;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
res@gsnTickMarksOn		= False			;Turn on/off all tick marks
;res@tmXBLabelFontHeightF	= 0.022
;res@tmEqualizeXYSizes		= True

res@gsnSpreadColors		= True			;Use full range of color map
res@gsnSpreadColorStart		= 5			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 20			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 5			;originally 1 Set max contour level
res@cnLevelSpacingF		= 1.0			;originally 0.2
 
res@gsnLeftString		= "Excess changes in upwelling shortwave radiation"
res@gsnStringFontHeightF	= 0.02

plot(11) = gsn_csm_contour_map_ce(wks,USW_excess,res)



	
;;;Panel the plots
pres				= True
pres@gsnPanelLabelBar		= False		;common label bar
pres@gsnFrame			= False		;don't advance frame yet
pres@lbLabelFontHeightF	= 0.01
pres@gsnMaximize		= True		;Maximize plot in frame
pres@pmLabelBarHeightF		= 0.05
pres@lbLabelAutoStride		= True		;nice label bar labels
pres@gsnPanelOrientation	= "auto"
;pres@gsnPanelCenter  		= False
pres@gsnPanelXWhiteSpacePercent= 5

pres@gsnPanelMainString		= "MPI-ESM-MR - MAM Tmin (cold tail)"
pres@gsnPanelMainFontHeightF	= 0.015

gsn_panel(wks,plot,(/4,3/),pres)		;2 rows, 1 column

frame(wks)
  
end
