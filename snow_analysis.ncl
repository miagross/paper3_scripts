load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;Script to plot changes in snow cover and temperature extremes;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin

;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "MPI-ESM-MR_changes_TNn_SON_snow_cover"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)
plot = new(3,graphic)			;create plot array

;;;set-up map space
greymap=(/"grey"/) ; colormap with grey
gsn_merge_colormaps(wks,"posneg_1",greymap) 	;merge two color maps.. used to be hotcolr_19lev


;***********************************************************
;;**********************Read-in input***********************
;***********************************************************

;;;READ IN ANNUAL EXTREME TEMP DATA

ExtDataDir = "/srv/ccrc/data04/z5026024/extremes_only_files/"
ExtData = ExtDataDir+"MPI-ESM-MR_TNn_1950-1981_masked_EXTREMES_ONLY_2.5x2.5_SON.nc"
file1 = addfile(ExtData,"r")
ext_p1 = file1->extremes
lats = ext_p1&lat
lons = ext_p1&lon

;print(lats)
;printVarSummary(temp_p1)	;shows co-ordinates if using individual grid box!

ExtDataDir2 = "/srv/ccrc/data04/z5026024/extremes_only_files/"
ExtData2 = ExtDataDir2+"MPI-ESM-MR_TNn_1982-2014_masked_EXTREMES_ONLY_2.5x2.5_SON.nc"
file2 = addfile(ExtData2,"r")
ext_p2 = file2->extremes


;;;READ IN ANNUAL MEAN TEMP ANOMALIES

MeanDataDir = "/srv/ccrc/data04/z5026024/CMIP5/2.5x2.5_grid_temp_data/"
MeanData = MeanDataDir+"MPI-ESM-MR_TN_anoms_1950-1981_masked_2.5x2.5_ann_mean_SON.nc"
file3 = addfile(MeanData,"r")
mean_p1 = file3->TN_anoms

MeanDataDir2 = "/srv/ccrc/data04/z5026024/CMIP5/2.5x2.5_grid_temp_data/"
MeanData2 = MeanDataDir2+"MPI-ESM-MR_TN_anoms_1982-2014_masked_2.5x2.5_ann_mean_SON.nc"
file4 = addfile(MeanData2,"r")
mean_p2 = file4->TN_anoms


;;;READ IN SNOW DATA

SnowDataDir = "/srv/ccrc/data04/z5026024/CMIP5/snow_cover_data/"
SnowData = SnowDataDir+"snc_day_MPI-ESM-MR_1950-1981_masked_2.5x2.5_SON.nc"
file5 = addfile(SnowData,"r")
snow_p1 = file5->snc

;printVarSummary(snow_p1)

SnowDataDir2 = "/srv/ccrc/data04/z5026024/CMIP5/snow_cover_data/"
SnowData2 = SnowDataDir2+"snc_day_MPI-ESM-MR_1982-2014_masked_2.5x2.5_SON.nc"
file6 = addfile(SnowData2,"r")
snow_p2 = file6->snc


;***********************************************************
;;***************Set up data/calculations*******************
;***********************************************************

ext_p1_3d = new(dimsizes(ext_p1),"float",-999.9)		;set-up empty array to store calculations
;print(dimsizes(ext_p1_3d))
ext_p2_3d = new(dimsizes(ext_p2),"float",-999.9)
snow_p1_3d = new(dimsizes(snow_p1),"float",-999.9)
snow_p2_3d = new(dimsizes(snow_p2),"float",-999.9)

;;;LOOP THROUGH LAT/LON TO GET CHANGES FOR EACH GRIDBOX

do ilat=0,dimsizes(lats)-1
 Lat=lats(ilat)
 ;print(ilat+": "+Lat)
 
 do ilon=0,dimsizes(lons)-1
  Lon=lons(ilon)
  ;print(ilon+": "+Lon)
  
  ;;;ONLY USE SNOW VALUES WHERE THERE ARE EXTREME VALUES
  ;;;i.e. ONLY USE SNOW VALUES WHERE NON-MISSING IN TEMP DATA

  ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(:,ilat,ilon)))		;indices that are non-missing in temp i.e. extremes
  ;print(ext_p1_ind_nomiss)
  ;print(ilat+"  "+ilon)
  
  if(.not.all(ismissing(ext_p1_ind_nomiss))) then
   
   ext_p1_nomiss = ext_p1(ext_p1_ind_nomiss,ilat,ilon)  
   snow_p1_extremes_only = snow_p1(ext_p1_ind_nomiss,ilat,ilon)		;only indclude values for time steps with non-missing temp
   len_ext_p1 = dimsizes(ext_p1_nomiss)
   ext_p1_3d(0:(len_ext_p1)-1,ilat,ilon) = ext_p1_nomiss
   snow_p1_3d(0:len_ext_p1-1,ilat,ilon) = snow_p1_extremes_only
   
   delete([/ext_p1_nomiss,snow_p1_extremes_only/])
  end if
  
  delete([/ext_p1_ind_nomiss/])
  
  ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(:,ilat,ilon)))
     
  if(.not.all(ismissing(ext_p2_ind_nomiss))) then   
   
   ext_p2_nomiss = ext_p2(ext_p2_ind_nomiss,ilat,ilon)  
   snow_p2_extremes_only = snow_p2(ext_p2_ind_nomiss,ilat,ilon)
   len_ext_p2 = dimsizes(ext_p2_nomiss)   
   ext_p2_3d(0:len_ext_p2-1,ilat,ilon) = ext_p2_nomiss
   snow_p2_3d(0:len_ext_p2-1,ilat,ilon) = snow_p2_extremes_only
   
   delete([/ext_p2_nomiss,snow_p2_extremes_only/])
  end if
  
  delete([/ext_p2_ind_nomiss/])
  
 end do		;ends ilon loop
end do		;ends ilat loop


;;;CALCULATE AVERAGE OVER P1 AND P2, AND THEN P2 - P1 FOR CHANGES
;ext_p1_ave = dim_avg_n_Wrap(ext_p1_3d,0)		;average of time at each lat/lon grid point
;ext_p2_ave = dim_avg_n_Wrap(ext_p2_3d,0)
;print(ext_p1_ave)

;mean_p1_ave = dim_avg_n_Wrap(mean_p1,0)
;mean_p2_ave = dim_avg_n_Wrap(mean_p2,0)

snow_ext_p1_ave = dim_avg_n_Wrap(snow_p1_3d,0)
snow_ext_p2_ave = dim_avg_n_Wrap(snow_p2_3d,0)

snow_mean_p1_ave = dim_avg_n_Wrap(snow_p1,0)
snow_mean_p2_ave = dim_avg_n_Wrap(snow_p2,0)
  
;ext_changes = ext_p2_ave - ext_p1_ave
;mean_changes = mean_p2_ave - mean_p1_ave
;excess_changes = ext_changes - mean_changes
snow_ext_changes = snow_ext_p2_ave - snow_ext_p1_ave
snow_mean_changes = snow_mean_p2_ave - snow_mean_p1_ave
excess_snow = snow_ext_changes - snow_mean_changes

;ext_changes!0="lat"			;name the dimension
;ext_changes&lat=lats			;assign the coordinate variable
;ext_changes&lat@units="degrees_north"
;ext_changes!1="lon"
;ext_changes&lon=lons
;ext_changes&lon@units="degrees_east"

;mean_changes!0="lat"
;mean_changes&lat=lats
;mean_changes&lat@units="degrees_north"
;mean_changes!1="lon"
;mean_changes&lon=lons
;mean_changes&lon@units="degrees_east"

;excess_changes!0="lat"
;excess_changes&lat=lats
;excess_changes&lat@units="degrees_north"
;excess_changes!1="lon"
;excess_changes&lon=lons
;excess_changes&lon@units="degrees_east"

snow_ext_changes!0="lat"
snow_ext_changes&lat=lats
snow_ext_changes&lat@units="degrees_north"
snow_ext_changes!1="lon"
snow_ext_changes&lon=lons
snow_ext_changes&lon@units="degrees_east"

snow_mean_changes!0="lat"
snow_mean_changes&lat=lats
snow_mean_changes&lat@units="degrees_north"
snow_mean_changes!1="lon"
snow_mean_changes&lon=lons
snow_mean_changes&lon@units="degrees_east"

excess_snow!0="lat"
excess_snow&lat=lats
excess_snow&lat@units="degrees_north"
excess_snow!1="lon"
excess_snow&lon=lons
excess_snow&lon@units="degrees_east"



;print(ext_changes)


;***********************************************************
;;*******************Plot data on map***********************
;*********************************************************** 				

;;;PLOT SNOW CHANGES - extreme days only
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
res@gsnSpreadColorStart		= 4			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 16			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 2			;originally 1 Set max contour level
res@cnLevelSpacingF		= 0.5			;originally 0.2
 
res@gsnLeftString		= "Changes in snow cover from extreme days only"
res@gsnStringFontHeightF	= 0.012

plot(0) = gsn_csm_contour_map_ce(wks,snow_ext_changes,res)


;;;PLOT SNOW CHANGES - mean
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
res@gsnSpreadColorStart		= 4			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 16			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 2			;originally 1 Set max contour level
res@cnLevelSpacingF		= 0.5			;originally 0.2
 
res@gsnLeftString		= "Changes in mean snow cover"
res@gsnStringFontHeightF	= 0.012

plot(1) = gsn_csm_contour_map_ce(wks,snow_mean_changes,res)	


;;;PLOT SNOW CHANGES - mean
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
res@gsnSpreadColorStart		= 4			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 16			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -5			;originally -1 Set min contour level
res@cnMaxLevelValF		= 2			;originally 1 Set max contour level
res@cnLevelSpacingF		= 0.5			;originally 0.2
 
res@gsnLeftString		= "Changes in excess snow cover"
res@gsnStringFontHeightF	= 0.012

plot(2) = gsn_csm_contour_map_ce(wks,excess_snow,res)			


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

pres@gsnPanelMainString		= "MPI-ESM-MR - SON Tmin (cold tail)"
pres@gsnPanelMainFontHeightF	= 0.015

gsn_panel(wks,plot,(/3,1/),pres)		;2 rows, 1 column

frame(wks)

end
