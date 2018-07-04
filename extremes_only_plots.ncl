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

ClimVars = (/"TXx","TNx","TXn","TNn"/)
Seasons = (/"DJF","MAM","JJA","SON"/)

;;;begin looping through ClimVars and Variables
do iClimVar=0, dimsizes(ClimVars)-1
 ClimVar = ClimVars(iClimVar)
 
 ;do iSeas=0, dimsizes(Seasons)-1
  ;Season = Seasons(iSeas)
 
 plotfile = "MPI-ESM-MR_future_changes_"+ClimVar+"_"+Season
 wks_type = "eps"
 wks =gsn_open_wks(wks_type,plotfile)
 plot = new(3,graphic)			;create plot array
 
 ;;;set-up map space
greymap=(/"grey"/) ; colormap with grey
gsn_merge_colormaps(wks,"cmp_b2r",greymap) 	;merge two color maps.. used to be hotcolr_19lev/posneg_1


;***********************************************************
;;**********************Read-in input***********************
;***********************************************************

;;;READ IN TEMPERATURE DATA; EXTREMES

ExtDataDir = "/srv/ccrc/data40/z5026024/data/extremes_only_files/future_analysis/"
ExtData = ExtDataDir+"MPI-ESM-MR_"+ClimVar+"_1950-1979_EXTREMES_ONLY_2.5x2.5_MAM.nc"
file1 = addfile(ExtData,"r")
ext_p1 = file1->extremes
lats = ext_p1&lat
lons = ext_p1&lon

;print(lats)
;printVarSummary(temp_p1)	;shows co-ordinates if using individual grid box!

ExtDataDir2 = "/srv/ccrc/data40/z5026024/data/extremes_only_files/future_analysis/"
ExtData2 = ExtDataDir2+"MPI-ESM-MR_"+ClimVar+"_2070-2099_EXTREMES_ONLY_2.5x2.5_MAM.nc"
file2 = addfile(ExtData2,"r")
ext_p2 = file2->extremes


;;;READ IN DAILY TEMP ANOMALIES

if(ClimVar.eq."TXx") then
   TempDataDir = "/srv/ccrc/data40/z5026024/data/CMIP5/anomalies/seasonal/split_yrs_future_analysis/"
   TempData = TempDataDir+"MPI-ESM-MR_TX_anoms_1950-1979_2.5x2.5_MAM.nc"
   file3 = addfile(TempData,"r")
   Temp_p1 = file3->TX_anoms

   TempDataDir2 = "/srv/ccrc/data40/z5026024/data/CMIP5/anomalies/seasonal/split_yrs_future_analysis/"
   TempData2 = TempDataDir2+"MPI-ESM-MR_TX_anoms_2070-2099_2.5x2.5_MAM.nc"
   file4 = addfile(TempData2,"r")
   Temp_p2 = file4->TX_anoms
  end if

  if(ClimVar.eq."TXn") then
   TempDataDir = "/srv/ccrc/data40/z5026024/data/CMIP5/anomalies/seasonal/split_yrs_future_analysis/"
   TempData = TempDataDir+"MPI-ESM-MR_TX_anoms_1950-1979_2.5x2.5_MAM.nc"
   file3 = addfile(TempData,"r")
   Temp_p1 = file3->TX_anoms

   TempDataDir2 = "/srv/ccrc/data40/z5026024/data/CMIP5/anomalies/seasonal/split_yrs_future_analysis/"
   TempData2 = TempDataDir2+"MPI-ESM-MR_TX_anoms_2070-2099_2.5x2.5_MAM.nc"
   file4 = addfile(TempData2,"r")
   Temp_p2 = file4->TX_anoms
  end if

  if(ClimVar.eq."TNx") then
   TempDataDir = "/srv/ccrc/data40/z5026024/data/CMIP5/anomalies/seasonal/split_yrs_future_analysis/"
   TempData = TempDataDir+"MPI-ESM-MR_TN_anoms_1950-1979_2.5x2.5_MAM.nc"
   file3 = addfile(TempData,"r")
   Temp_p1 = file3->TN_anoms

   TempDataDir2 = "/srv/ccrc/data40/z5026024/data/CMIP5/anomalies/seasonal/split_yrs_future_analysis/"
   TempData2 = TempDataDir2+"MPI-ESM-MR_TN_anoms_2070-2099_2.5x2.5_MAM.nc"
   file4 = addfile(TempData2,"r")
   Temp_p2 = file4->TN_anoms
  end if
  
  if(ClimVar.eq."TNx") then
   TempDataDir = "/srv/ccrc/data40/z5026024/data/CMIP5/anomalies/seasonal/split_yrs_future_analysis/"
   TempData = TempDataDir+"MPI-ESM-MR_TN_anoms_1950-1979_2.5x2.5_MAM.nc"
   file3 = addfile(TempData,"r")
   Temp_p1 = file3->TN_anoms

   TempDataDir2 = "/srv/ccrc/data40/z5026024/data/CMIP5/anomalies/seasonal/split_yrs_future_analysis/"
   TempData2 = TempDataDir2+"MPI-ESM-MR_TN_anoms_2070-2099_2.5x2.5_MAM.nc"
   file4 = addfile(TempData2,"r")
   Temp_p2 = file4->TN_anoms
  end if



;***********************************************************
;;***************Set up data/calculations*******************
;***********************************************************

ext_p1_3d = new(dimsizes(ext_p1),"float",-999.9)		;set-up empty array to store calculations
;print(dimsizes(ext_p1_3d))
ext_p2_3d = new(dimsizes(ext_p2),"float",-999.9)

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
   len_ext_p1 = dimsizes(ext_p1_nomiss)
   ext_p1_3d(0:(len_ext_p1)-1,ilat,ilon) = ext_p1_nomiss
   
   delete([/ext_p1_nomiss/])
  end if
  
  delete([/ext_p1_ind_nomiss/])
  
  ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(:,ilat,ilon)))
     
  if(.not.all(ismissing(ext_p2_ind_nomiss))) then   
   
   ext_p2_nomiss = ext_p2(ext_p2_ind_nomiss,ilat,ilon)  
   len_ext_p2 = dimsizes(ext_p2_nomiss)   
   ext_p2_3d(0:len_ext_p2-1,ilat,ilon) = ext_p2_nomiss
   
   delete([/ext_p2_nomiss/])
  end if
  
  delete([/ext_p2_ind_nomiss/])
  
 end do		;ends ilon loop
end do		;ends ilat loop


;;;CALCULATE AVERAGE OVER P1 AND P2, AND THEN P2 - P1 FOR CHANGES
ext_p1_ave = dim_avg_n_Wrap(ext_p1_3d,0)		;average of time at each lat/lon grid point
ext_p2_ave = dim_avg_n_Wrap(ext_p2_3d,0)
;print(ext_p1_ave)

mean_p1_ave = dim_avg_n_Wrap(Temp_p1,0)			;mean over time from daily values
mean_p2_ave = dim_avg_n_Wrap(Temp_p2,0)

delete([/Temp_p1,Temp_p2/])

ext_changes = ext_p2_ave - ext_p1_ave
mean_changes = mean_p2_ave - mean_p1_ave
excess_changes = ext_changes - mean_changes

ext_changes!0="lat"			;name the dimension
ext_changes&lat=lats			;assign the coordinate variable
ext_changes&lat@units="degrees_north"
ext_changes!1="lon"
ext_changes&lon=lons
ext_changes&lon@units="degrees_east"

mean_changes!0="lat"
mean_changes&lat=lats
mean_changes&lat@units="degrees_north"
mean_changes!1="lon"
mean_changes&lon=lons
mean_changes&lon@units="degrees_east"

excess_changes!0="lat"
excess_changes&lat=lats
excess_changes&lat@units="degrees_north"
excess_changes!1="lon"
excess_changes&lon=lons
excess_changes&lon@units="degrees_east"

;print(ext_changes)


;***********************************************************
;;*******************Plot data on map***********************
;*********************************************************** 				

;;;PLOT EXTREMES ONLY 
res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True		;Turn off individual lb's
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
res@gsnSpreadColorStart		= 34				;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 65			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= 4.0			;originally -1 Set min contour level
res@cnMaxLevelValF		= 10.0			;originally 1 Set max contour level
res@cnLevelSpacingF		= 0.5			;originally 0.2
 
res@gsnLeftString		= "Changes in temperature extremes"
res@gsnStringFontHeightF	= 0.012

plot(0) = gsn_csm_contour_map_ce(wks,ext_changes,res)		;extreme temperature changes


;;;PLOT MEAN 
res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True		;Turn off individual lb's
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
res@gsnSpreadColorStart		= 34				;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 65			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= 4.0			;originally -1 Set min contour level
res@cnMaxLevelValF		= 10.0			;originally 1 Set max contour level
res@cnLevelSpacingF		= 0.5			;originally 0.2
 
res@gsnLeftString		= "Changes in mean temperature"
res@gsnStringFontHeightF	= 0.012

plot(1) = gsn_csm_contour_map_ce(wks,mean_changes,res)		;extreme temperature changes


;;;PLOT EXCESS CHANGES
res				= True
res@gsnMaximize 		= True 			;Maximize plot in frame
res@gsnDraw			= False			;Don't draw plots
res@gsnFrame			= False			;Don't advance frame			
res@cnFillMode			= "CellFill"		;Turn on contour fill
res@cnFillOn			= True			;Raster Mode
res@cnLinesOn			= False			;Turn off contour lines

res@lbLabelAutoStride		= True			;Control labelbar spacing
res@lbLabelBarOn		= True		;Turn off individual lb's
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
res@cnMinLevelValF		= -3.0			;originally -1 Set min contour level
res@cnMaxLevelValF		= 3.0			;originally 1 Set max contour level
res@cnLevelSpacingF		= 0.5			;originally 0.2
 
res@gsnLeftString		= "Excess changes (extreme changes - mean changes)"
res@gsnStringFontHeightF	= 0.012

plot(2) = gsn_csm_contour_map_ce(wks,excess_changes,res)		;extreme temperature changes


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

pres@gsnPanelMainFontHeightF	= 0.015

 if (ClimVar.eq."TXx") then
  pres@gsnPanelMainString		= "MPI-ESM-MR - MAM Tmax (warm tail)"
 else if(ClimVar.eq."TNx") then
  pres@gsnPanelMainString		= "MPI-ESM-MR - MAM Tmin (warm tail)"
 else if(ClimVar.eq."TXn") then
  pres@gsnPanelMainString		= "MPI-ESM-MR - MAM Tmax (cold tail)"
 else if(ClimVar.eq."TNn") then
  pres@gsnPanelMainString		= "MPI-ESM-MR - MAM Tmin (cold tail)"
 end if
 end if
 end if
 end if

gsn_panel(wks,plot,(/3,1/),pres)		;2 rows, 1 column

frame(wks)

delete([/ext_p1,ext_p2,ext_p1_3d,ext_p2_3d/])

;end do
end do
end
