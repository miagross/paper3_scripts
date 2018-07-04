load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;Script to plot changes in cloud cover and temperature extremes;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin

;***********************************************************
;;********************Set up output*************************
;***********************************************************

Model = "inmcm4"
Season = "MAM"
ClimVar = "TXn"


plotfile = Model+"_"+ClimVar+"_"+Season+"_cloud_cover"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)
plot = new(3,graphic)			;create plot array

;;;set-up map space
greymap=(/"grey"/) ; colormap with grey
gsn_merge_colormaps(wks,"cmp_b2r",greymap) 	;merge two color maps.. used to be hotcolr_19lev


;***********************************************************
;;**********************Read-in input***********************
;***********************************************************

;;;READ IN TEMPERATURE DATA; EXTREMES

ExtDataDir = "/srv/ccrc/data01/z5026024/extremes_only_files/future_1961-1990_clim/"
ExtData = ExtDataDir+Model+"_"+ClimVar+"_1950-1979_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
file1 = addfile(ExtData,"r")
ext_p1 = file1->extremes
lats = ext_p1&lat
lons = ext_p1&lon

;print(lats)
;printVarSummary(temp_p1)	;shows co-ordinates if using individual grid box!

ExtData2 = ExtDataDir+Model+"_"+ClimVar+"_2070-2099_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
file2 = addfile(ExtData2,"r")
ext_p2 = file2->extremes


;;;READ IN DAILY TEMP ANOMALIES

TempDataDir = "/srv/ccrc/data40/z5026024/CMIP5/anomalies_1950-2099/split_yrs/"

if(ClimVar.eq."TXx") then
 TempData = TempDataDir+Model+"_TX_anoms_50-99_clim_1950-1979_2.5x2.5_"+Season+".nc"
 file3 = addfile(TempData,"r")
 Temp_p1 = file3->TX_anoms

 TempData2 = TempDataDir+Model+"_TX_anoms_50-99_clim_2070-2099_2.5x2.5_"+Season+".nc"
 file4 = addfile(TempData2,"r")
 Temp_p2 = file4->TX_anoms
end if

if(ClimVar.eq."TXn") then
 TempData = TempDataDir+Model+"_TX_anoms_50-99_clim_1950-1979_2.5x2.5_"+Season+".nc"
 file3 = addfile(TempData,"r")
 Temp_p1 = file3->TX_anoms

 TempData2 = TempDataDir+Model+"_TX_anoms_50-99_clim_2070-2099_2.5x2.5_"+Season+".nc"
 file4 = addfile(TempData2,"r")
 Temp_p2 = file4->TX_anoms
end if

if(ClimVar.eq."TNx") then
 TempData = TempDataDir+Model+"_TN_anoms_50-99_clim_1950-1979_2.5x2.5_"+Season+".nc"
 file3 = addfile(TempData,"r")
 Temp_p1 = file3->TN_anoms

 TempData2 = TempDataDir+Model+"_TN_anoms_50-99_clim_2070-2099_2.5x2.5_"+Season+".nc"
 file4 = addfile(TempData2,"r")
 Temp_p2 = file4->TN_anoms
end if

if(ClimVar.eq."TNn") then
 TempData = TempDataDir+Model+"_TN_anoms_50-99_clim_1950-1979_2.5x2.5_"+Season+".nc"
 file3 = addfile(TempData,"r")
 Temp_p1 = file3->TN_anoms

 TempData2 = TempDataDir+Model+"_TN_anoms_50-99_clim_2070-2099_2.5x2.5_"+Season+".nc"
 file4 = addfile(TempData2,"r")
 Temp_p2 = file4->TN_anoms
end if


;;;READ IN CLOUD COVER DATA

cloudDataDir = "/srv/ccrc/data04/z5026024/CMIP5/variables_data/"

cloudData = cloudDataDir+"clt_day_"+Model+"_1950-1979_masked_2.5x2.5_"+Season+".nc"
file5 = addfile(cloudData,"r")
cloud_p1 = file5->clt

cloudData2 = cloudDataDir+"clt_day_"+Model+"_2070-2099_masked_2.5x2.5_"+Season+".nc"
file6 = addfile(cloudData2,"r")
cloud_p2 = file6->clt


;***********************************************************
;;***************Set up data/calculations*******************
;***********************************************************

ext_p1_3d = new(dimsizes(ext_p1),"float",-999.9)		;set-up empty array to store calculations
;print(dimsizes(ext_p1_3d))
ext_p2_3d = new(dimsizes(ext_p2),"float",-999.9)
cloud_p1_3d = new(dimsizes(cloud_p1),"float",-999.9)
cloud_p2_3d = new(dimsizes(cloud_p2),"float",-999.9)

;;;LOOP THROUGH LAT/LON TO GET CHANGES FOR EACH GRIDBOX

do ilat=0,dimsizes(lats)-1
 Lat=lats(ilat)
 ;print(ilat+": "+Lat)
 
 do ilon=0,dimsizes(lons)-1
  Lon=lons(ilon)
  ;print(ilon+": "+Lon)
  
  ;;;ONLY USE cloud VALUES WHERE THERE ARE EXTREME VALUES
  ;;;i.e. ONLY USE cloud VALUES WHERE NON-MISSING IN TEMP DATA

  ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(:,ilat,ilon)))		;indices that are non-missing in temp i.e. extremes
  ;print(ext_p1_ind_nomiss)
  ;print(ilat+"  "+ilon)
  
  if(.not.all(ismissing(ext_p1_ind_nomiss))) then
   
   ext_p1_nomiss = ext_p1(ext_p1_ind_nomiss,ilat,ilon)  
   cloud_p1_extremes_only = cloud_p1(ext_p1_ind_nomiss,ilat,ilon)		;only indclude values for time steps with non-missing temp
   len_ext_p1 = dimsizes(ext_p1_nomiss)
   ext_p1_3d(0:(len_ext_p1)-1,ilat,ilon) = ext_p1_nomiss
   cloud_p1_3d(0:len_ext_p1-1,ilat,ilon) = cloud_p1_extremes_only
   
   delete([/ext_p1_nomiss,cloud_p1_extremes_only/])
  end if
  
  delete([/ext_p1_ind_nomiss/])
  
  ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(:,ilat,ilon)))
     
  if(.not.all(ismissing(ext_p2_ind_nomiss))) then   
   
   ext_p2_nomiss = ext_p2(ext_p2_ind_nomiss,ilat,ilon)  
   cloud_p2_extremes_only = cloud_p2(ext_p2_ind_nomiss,ilat,ilon)
   len_ext_p2 = dimsizes(ext_p2_nomiss)   
   ext_p2_3d(0:len_ext_p2-1,ilat,ilon) = ext_p2_nomiss
   cloud_p2_3d(0:len_ext_p2-1,ilat,ilon) = cloud_p2_extremes_only
   
   delete([/ext_p2_nomiss,cloud_p2_extremes_only/])
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

cloud_ext_p1_ave = dim_avg_n_Wrap(cloud_p1_3d,0)
cloud_ext_p2_ave = dim_avg_n_Wrap(cloud_p2_3d,0)

cloud_mean_p1_ave = dim_avg_n_Wrap(cloud_p1,0)
cloud_mean_p2_ave = dim_avg_n_Wrap(cloud_p2,0)
  
;ext_changes = ext_p2_ave - ext_p1_ave
;mean_changes = mean_p2_ave - mean_p1_ave
;excess_changes = ext_changes - mean_changes
cloud_ext_changes = cloud_ext_p2_ave - cloud_ext_p1_ave
cloud_mean_changes = cloud_mean_p2_ave - cloud_mean_p1_ave
excess_cloud = cloud_ext_changes - cloud_mean_changes

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

cloud_ext_changes!0="lat"
cloud_ext_changes&lat=lats
cloud_ext_changes&lat@units="degrees_north"
cloud_ext_changes!1="lon"
cloud_ext_changes&lon=lons
cloud_ext_changes&lon@units="degrees_east"

cloud_mean_changes!0="lat"
cloud_mean_changes&lat=lats
cloud_mean_changes&lat@units="degrees_north"
cloud_mean_changes!1="lon"
cloud_mean_changes&lon=lons
cloud_mean_changes&lon@units="degrees_east"

excess_cloud!0="lat"
excess_cloud&lat=lats
excess_cloud&lat@units="degrees_north"
excess_cloud!1="lon"
excess_cloud&lon=lons
excess_cloud&lon@units="degrees_east"



;print(ext_changes)


;***********************************************************
;;*******************Plot data on map***********************
;*********************************************************** 				

;;;PLOT cloud CHANGES - extreme days only
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
res@gsnSpreadColorStart		= 2			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 65			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -25			;originally -1 Set min contour level
res@cnMaxLevelValF		= 25			;originally 1 Set max contour level
res@cnLevelSpacingF		= 1.0			;originally 0.2
 
res@gsnLeftString		= "Changes in cloud cover from extreme days only"
res@gsnStringFontHeightF	= 0.012

plot(0) = gsn_csm_contour_map_ce(wks,cloud_ext_changes,res)


;;;PLOT cloud CHANGES - mean
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
res@gsnSpreadColorStart		= 2			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 65			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -10			;originally -1 Set min contour level
res@cnMaxLevelValF		= 10			;originally 1 Set max contour level
res@cnLevelSpacingF		= 0.5			;originally 0.2
 
res@gsnLeftString		= "Changes in mean cloud cover"
res@gsnStringFontHeightF	= 0.012

plot(1) = gsn_csm_contour_map_ce(wks,cloud_mean_changes,res)	


;;;PLOT cloud CHANGES - excess
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
res@gsnSpreadColorStart		= 2			;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 65			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -25			;originally -1 Set min contour level
res@cnMaxLevelValF		= 25			;originally 1 Set max contour level
res@cnLevelSpacingF		= 1.0			;originally 0.2
 
res@gsnLeftString		= "Changes in excess cloud cover"
res@gsnStringFontHeightF	= 0.012

plot(2) = gsn_csm_contour_map_ce(wks,excess_cloud,res)			


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

pres@gsnPanelMainString		= Model+" Tmax (cold tail) "+Season
pres@gsnPanelMainFontHeightF	= 0.015

gsn_panel(wks,plot,(/3,1/),pres)		;2 rows, 1 column

frame(wks)

end
