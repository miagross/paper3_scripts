load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;Script to calculate and plot changes in heat fluxes;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

begin 

;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "MPI-ESM-MR_changes_heat_fluxes_TNn_SON"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)
plot = new(6,graphic)			;create plot array

;;;set-up map space
greymap=(/"grey"/) ; colormap with grey
gsn_merge_colormaps(wks,"posneg_1",greymap) 	;merge two color maps.. used to be hotcolr_19lev


;***********************************************************
;;******************READ IN INPUT FILES*********************
;***********************************************************

;;;HEAT FLUX DATA

QeDataDir_p1 = "/srv/ccrc/data04/z5026024/CMIP5/heat_flux_data/"
QeData_p1 = QeDataDir_p1+"hfls_day_MPI-ESM-MR_1950-1981_masked_2.5x2.5_SON.nc"
QeFile_p1 = addfile(QeData_p1,"r")

Qe_p1	= QeFile_p1->hfls		;Latent heat flux

QeDataDir_p2 = "/srv/ccrc/data04/z5026024/CMIP5/heat_flux_data/"
QeData_p2 = QeDataDir_p2+"hfls_day_MPI-ESM-MR_1982-2014_masked_2.5x2.5_SON.nc"
QeFile_p2 = addfile(QeData_p2,"r")

Qe_p2	= QeFile_p2->hfls		;Latent heat flux


QhDataDir_p1 = "/srv/ccrc/data04/z5026024/CMIP5/heat_flux_data/"
QhData_p1 = QhDataDir_p1+"hfss_day_MPI-ESM-MR_1950-1981_masked_2.5x2.5_SON.nc"
QhFile_p1 = addfile(QhData_p1,"r")

Qh_p1	= QhFile_p1->hfss	;Sensible heat flux

QhDataDir_p2 = "/srv/ccrc/data04/z5026024/CMIP5/heat_flux_data/"
QhData_p2 = QhDataDir_p2+"hfss_day_MPI-ESM-MR_1982-2014_masked_2.5x2.5_SON.nc"
QhFile_p2 = addfile(QhData_p2,"r")

Qh_p2	= QhFile_p2->hfss	;Sensible heat flux


;;;ANNUAL EXTREME TEMP DATA

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


;***********************************************************
;;*************Set up data/calculations*********************
;***********************************************************

;;;EVAPORATIVE FRACTION; EF = Qe/(Qe+Qh)
EF_p1 = Qe_p1/(Qe_p1+Qh_p1)
EF_p2 = Qe_p2/(Qe_p2+Qh_p2)

;printVarSummary(EF_p1)


;;;SET UP EMPTY ARRAYS TO STORE DATA
ext_p1_3d = new(dimsizes(ext_p1),"float",-999.9)
ext_p2_3d = new(dimsizes(ext_p2),"float",-999.9)
Qe_p1_3d = new(dimsizes(Qe_p1),"float",-999.9)
Qe_p2_3d = new(dimsizes(Qe_p2),"float",-999.9)
Qh_p1_3d = new(dimsizes(Qh_p1),"float",-999.9)
Qh_p2_3d = new(dimsizes(Qh_p2),"float",-999.9)
EF_p1_3d = new(dimsizes(EF_p1),"float",-999.9)
EF_p2_3d = new(dimsizes(EF_p1),"float",-999.9)


;;;LOOP THROUGH LAT/LON TO GET CHANGES FOR EACH GRIDBOX

do ilat=0,dimsizes(lats)-1
 Lat=lats(ilat)
 ;print(ilat+": "+Lat)
 
 do ilon=0,dimsizes(lons)-1
  Lon=lons(ilon)
  ;print(ilon+": "+Lon)
  

  ;;;ONLY USE SNOW VALUES WHERE THERE ARE EXTREME VALUES
  ;;;i.e. ONLY USE HEAT FLUX VALUES WHERE NON-MISSING IN TEMP DATA

  ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(:,ilat,ilon)))		;indices that are non-missing in temp i.e. extremes
  
  if(.not.all(ismissing(ext_p1_ind_nomiss))) then   
   ext_p1_nomiss = ext_p1(ext_p1_ind_nomiss,ilat,ilon)  
   Qe_p1_extremes_only = Qe_p1(ext_p1_ind_nomiss,ilat,ilon)		;only indclude values for time steps with non-missing temp
   Qh_p1_extremes_only = Qh_p1(ext_p1_ind_nomiss,ilat,ilon)
   EF_p1_extremes_only = EF_p1(ext_p1_ind_nomiss,ilat,ilon)
   len_ext_p1 = dimsizes(ext_p1_nomiss)
   ext_p1_3d(0:(len_ext_p1)-1,ilat,ilon) = ext_p1_nomiss
   Qe_p1_3d(0:len_ext_p1-1,ilat,ilon) = Qe_p1_extremes_only
   Qh_p1_3d(0:len_ext_p1-1,ilat,ilon) = Qh_p1_extremes_only
   EF_p1_3d(0:len_ext_p1-1,ilat,ilon) = EF_p1_extremes_only   
   delete([/ext_p1_nomiss,Qe_p1_extremes_only,Qh_p1_extremes_only,EF_p1_extremes_only/])
  end if
  
  delete([/ext_p1_ind_nomiss/])
  
  ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(:,ilat,ilon)))
     
  if(.not.all(ismissing(ext_p2_ind_nomiss))) then      
   ext_p2_nomiss = ext_p2(ext_p2_ind_nomiss,ilat,ilon)  
   Qe_p2_extremes_only = Qe_p2(ext_p2_ind_nomiss,ilat,ilon)
   Qh_p2_extremes_only = Qh_p2(ext_p2_ind_nomiss,ilat,ilon)
   EF_p2_extremes_only = EF_p2(ext_p2_ind_nomiss,ilat,ilon)
   len_ext_p2 = dimsizes(ext_p2_nomiss)   
   ext_p2_3d(0:len_ext_p2-1,ilat,ilon) = ext_p2_nomiss
   Qe_p2_3d(0:len_ext_p2-1,ilat,ilon) = Qe_p2_extremes_only   
   Qh_p2_3d(0:len_ext_p2-1,ilat,ilon) = Qh_p2_extremes_only
   EF_p2_3d(0:len_ext_p2-1,ilat,ilon) = EF_p2_extremes_only
   delete([/ext_p2_nomiss,Qe_p2_extremes_only,Qh_p2_extremes_only,EF_p2_extremes_only/])
  end if
  
  delete([/ext_p2_ind_nomiss/])
  
 end do		;ends ilon loop
end do		;ends ilat loop
 
  
;;;CALCULATE AVERAGE OVER P1 AND P2, AND THEN P2 - P1 FOR CHANGES
Qe_ext_p1_ave = dim_avg_n_Wrap(Qe_p1_3d,0)
Qe_ext_p2_ave = dim_avg_n_Wrap(Qe_p2_3d,0)

Qe_mean_p1_ave = dim_avg_n_Wrap(Qe_p1,0)
Qe_mean_p2_ave = dim_avg_n_Wrap(Qe_p2,0)

Qh_ext_p1_ave = dim_avg_n_Wrap(Qh_p1_3d,0)
Qh_ext_p2_ave = dim_avg_n_Wrap(Qh_p2_3d,0)

Qh_mean_p1_ave = dim_avg_n_Wrap(Qh_p1,0)
Qh_mean_p2_ave = dim_avg_n_Wrap(Qh_p2,0)

EF_p1_ave = dim_avg_n_Wrap(EF_p1_3d,0)
EF_p2_ave = dim_avg_n_Wrap(EF_p2_3d,0)

Qe_ext_changes = Qe_ext_p2_ave - Qe_ext_p1_ave		;changes in latent heat flux
Qe_mean_changes = Qe_mean_p2_ave - Qe_mean_p1_ave
Qe_excess = Qe_ext_changes - Qe_mean_changes
Qh_ext_changes = Qh_ext_p2_ave - Qh_ext_p1_ave		;changes in sensible heat flux
Qh_mean_changes = Qh_mean_p2_ave - Qh_mean_p1_ave
Qh_excess = Qh_ext_changes - Qh_mean_changes
EF_changes = EF_p2_ave - EF_p1_ave			;changes in evaporative fraction


Qe_ext_changes!0="lat"
Qe_ext_changes&lat=lats
Qe_ext_changes&lat@units="degrees_north"
Qe_ext_changes!1="lon"
Qe_ext_changes&lon=lons
Qe_ext_changes&lon@units="degrees_east"

Qe_mean_changes!0="lat"
Qe_mean_changes&lat=lats
Qe_mean_changes&lat@units="degrees_north"
Qe_mean_changes!1="lon"
Qe_mean_changes&lon=lons
Qe_mean_changes&lon@units="degrees_east"

Qe_excess!0="lat"
Qe_excess&lat=lats
Qe_excess&lat@units="degrees_north"
Qe_excess!1="lon"
Qe_excess&lon=lons
Qe_excess&lon@units="degrees_east"

Qh_ext_changes!0="lat"
Qh_ext_changes&lat=lats
Qh_ext_changes&lat@units="degrees_north"
Qh_ext_changes!1="lon"
Qh_ext_changes&lon=lons
Qh_ext_changes&lon@units="degrees_east"

Qh_mean_changes!0="lat"
Qh_mean_changes&lat=lats
Qh_mean_changes&lat@units="degrees_north"
Qh_mean_changes!1="lon"
Qh_mean_changes&lon=lons
Qh_mean_changes&lon@units="degrees_east"

Qh_excess!0="lat"
Qh_excess&lat=lats
Qh_excess&lat@units="degrees_north"
Qh_excess!1="lon"
Qh_excess&lon=lons
Qh_excess&lon@units="degrees_east"

EF_changes!0="lat"
EF_changes&lat=lats
EF_changes&lat@units="degrees_north"
EF_changes!1="lon"
EF_changes&lon=lons
EF_changes&lon@units="degrees_east"


;***********************************************************
;;*******************Plot data on map***********************
;*********************************************************** 				

;;;PLOT LATENT HEAT CHANGES
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
 
res@gsnLeftString		= "Changes in latent heat - extremes only"
res@gsnStringFontHeightF	= 0.02

plot(0) = gsn_csm_contour_map_ce(wks,Qe_ext_changes,res)


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
 
res@gsnLeftString		= "Changes in mean latent heat"
res@gsnStringFontHeightF	= 0.02

plot(2) = gsn_csm_contour_map_ce(wks,Qe_mean_changes,res)


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
 
res@gsnLeftString		= "Changes in excess latent heat"
res@gsnStringFontHeightF	= 0.02

plot(4) = gsn_csm_contour_map_ce(wks,Qe_excess,res)
		


;;;PLOT SENSIBLE HEAT CHANGES
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
 
res@gsnLeftString		= "Changes in sensible heat - extremes only"
res@gsnStringFontHeightF	= 0.02

plot(1) = gsn_csm_contour_map_ce(wks,Qh_ext_changes,res)


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
 
res@gsnLeftString		= "Changes in mean sensible heat"
res@gsnStringFontHeightF	= 0.02

plot(3) = gsn_csm_contour_map_ce(wks,Qh_mean_changes,res)


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
 
res@gsnLeftString		= "Changes in excess sensible heat"
res@gsnStringFontHeightF	= 0.02

plot(5) = gsn_csm_contour_map_ce(wks,Qh_excess,res)			


;;;PLOT EVAPORATIVE FRACTION CHANGES
;res				= True
;res@gsnMaximize 		= True 			;Maximize plot in frame
;res@gsnDraw			= False			;Don't draw plots
;res@gsnFrame			= False			;Don't advance frame			
;res@cnFillMode			= "CellFill"		;Turn on contour fill
;res@cnFillOn			= True			;Raster Mode
;res@cnLinesOn			= False			;Turn off contour lines

;res@lbLabelAutoStride		= True			;Control labelbar spacing
;res@lbLabelBarOn		= True			;Turn off individual lb's
;res@lbLabelFontHeightF		= .013			;Make labels larger

;res@mpMinLatF			= -60			;Plots less Antarctica - turn off for Robinson
;;res@gsnCenterString		= ""
;;res@gsnLeftString		= ""
;;res@gsnRightString		= ""
;res@cnInfoLabelOn		= False			;Turn off info label
;;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
;res@gsnTickMarksOn		= False			;Turn on/off all tick marks
;;res@tmXBLabelFontHeightF	= 0.022
;;res@tmEqualizeXYSizes		= True

;res@gsnSpreadColors		= True			;Use full range of color map
;res@gsnSpreadColorStart		= 5			;Start at color index 1..used to be 2
;res@gsnSpreadColorEnd		= 20			;Stop at 2nd color from end.. used to be 20

;res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
;res@cnMinLevelValF		= -1			;originally -1 Set min contour level
;res@cnMaxLevelValF		= 1			;originally 1 Set max contour level
;res@cnLevelSpacingF		= 0.2			;originally 0.2
 
;res@gsnLeftString		= "Changes in evaporative fraction"
;res@gsnStringFontHeightF	= 0.02

;plot(5) = gsn_csm_contour_map_ce(wks,EF_changes,res)		;latent heat changes


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

gsn_panel(wks,plot,(/3,2/),pres)		;2 rows, 1 column

frame(wks)
  
end
