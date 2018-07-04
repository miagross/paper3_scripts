load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Script to calculate wind speed/direction;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;and plot ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

begin 

;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "wind_temp_extremes_TXn_SON"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)
plot = new(2,graphic)			;create plot array

;;;set-up map space
greymap=(/"grey"/) ; colormap with grey
gsn_merge_colormaps(wks,"cmp_b2r",greymap) 	;merge two color maps.. used to be hotcolr_19lev

;***********************************************************
;;******************READ IN INPUT FILES*********************
;***********************************************************

Vindatadir_p1 = "/srv/ccrc/data04/z5026024/CMIP5/wind_data/vas/"
Vindata_p1 = Vindatadir_p1+"vas_day_CSIRO-Mk3-6-0_1950-1981_2.5x2.5_SON.nc"
VFile_p1 = addfile(Vindata_p1,"r")

v_p1	= VFile_p1->vas		

Vindatadir_p2 = "/srv/ccrc/data04/z5026024/CMIP5/wind_data/vas/"
Vindata_p2 = Vindatadir_p2+"vas_day_CSIRO-Mk3-6-0_1982-2014_2.5x2.5_SON.nc"
VFile_p2 = addfile(Vindata_p2,"r")

v_p2	= VFile_p2->vas		

Uindatadir_p1 = "/srv/ccrc/data04/z5026024/CMIP5/wind_data/uas/"
Uindata_p1 = Uindatadir_p1+"uas_day_CSIRO-Mk3-6-0_1950-1981_2.5x2.5_SON.nc"
UFile_p1 = addfile(Uindata_p1,"r")

u_p1	= UFile_p1->uas

Uindatadir_p2 = "/srv/ccrc/data04/z5026024/CMIP5/wind_data/uas/"
Uindata_p2 = Uindatadir_p2+"uas_day_CSIRO-Mk3-6-0_1982-2014_2.5x2.5_SON.nc"
UFile_p2 = addfile(Uindata_p2,"r")

u_p2	= UFile_p2->uas


;;;ANNUAL EXTREMES ONLY TEMP ANOMALIES - LAND ONLY
ExtDataDir = "/srv/ccrc/data04/z5026024/extremes_only_files/"
ExtData = ExtDataDir+"CSIRO-Mk3-6-0_TXn_1950-1981_extremes_2.5x2.5_SON.nc"
file1 = addfile(ExtData,"r")
ext_p1 = file1->extremes
lats = ext_p1&lat
lons = ext_p1&lon

;print(lats)
;printVarSummary(temp_p1)	;shows co-ordinates if using individual grid box!

ExtDataDir2 = "/srv/ccrc/data04/z5026024/extremes_only_files/"
ExtData2 = ExtDataDir2+"CSIRO-Mk3-6-0_TXn_1982-2014_extremes_2.5x2.5_SON.nc"
file2 = addfile(ExtData2,"r")
ext_p2 = file2->extremes


;;;ANNUAL MEAN TEMP ANOMALIES - MASKED i.e. LAND ONLY
;MeanDataDir = "/srv/ccrc/data04/z5026024/CMIP5/2.5x2.5_grid_temp_data/"
;MeanData = MeanDataDir+"CSIRO-Mk3-6-0_TX_anoms_1950-1981_masked_2.5x2.5_ann_mean_MAM.nc"
;file3 = addfile(MeanData,"r")
;mean_p1 = file3->TX_anoms

;MeanDataDir2 = "/srv/ccrc/data04/z5026024/CMIP5/2.5x2.5_grid_temp_data/"
;MeanData2 = MeanDataDir2+"CSIRO-Mk3-6-0_TX_anoms_1982-2014_masked_2.5x2.5_ann_mean_MAM.nc"
;file4 = addfile(MeanData2,"r")
;mean_p2 = file4->TX_anoms


;***********************************************************
;;***********Calculate horizonal temp advection*************
;*******************and wind direction**********************

;;;calculate wind speed
wspd_p1 = wind_speed(u_p1,v_p1)
wspd_p2 = wind_speed(u_p2,v_p2)

;;;SET UP EMPTY ARRAYS TO STORE DATA
ext_p1_3d = new(dimsizes(ext_p1),"float",-999.9)
ext_p2_3d = new(dimsizes(ext_p2),"float",-999.9)
;wspd_p1_3d = new(dimsizes(u_p1),"float",-999.9)
;wspd_p2_3d = new(dimsizes(u_p1),"float",-999.9)
u_p1_3d = new(dimsizes(v_p1),"float",-999.9)
u_p2_3d = new(dimsizes(v_p1),"float",-999.9)
v_p1_3d = new(dimsizes(v_p1),"float",-999.9)
v_p2_3d = new(dimsizes(v_p1),"float",-999.9)


;;;LOOP THROUGH LAT/LON TO GET CHANGES FOR EACH GRIDBOX

do ilat=0,dimsizes(lats)-1
 Lat=lats(ilat)
 ;print(ilat+": "+Lat)
 
 do ilon=0,dimsizes(lons)-1
  Lon=lons(ilon)
  ;print(ilon+": "+Lon)
  

  ;;;ONLY USE SNOW VALUES ON DAYS THAT HAVE EXTREME VALUES
  ;;;i.e. ONLY USE TEMP ADVECTION WHERE NON-MISSING IN TEMP DATA
  
   ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(:,ilat,ilon)))		;indices that are non-missing in temp i.e. extremes
   
   ;printVarSummary(ext_p1_ind_nomiss)
  
  if(.not.all(ismissing(ext_p1_ind_nomiss))) then   
   ext_p1_nomiss = ext_p1(ext_p1_ind_nomiss,ilat,ilon) 					
   u_p1_extremes_only = u_p1(ext_p1_ind_nomiss,ilat,ilon)		
   v_p1_extremes_only = v_p1(ext_p1_ind_nomiss,ilat,ilon)
   len_ext_p1 = dimsizes(ext_p1_nomiss)					
   ext_p1_3d(0:(len_ext_p1)-1,ilat,ilon) = ext_p1_nomiss
   u_p1_3d(0:len_ext_p1-1,ilat,ilon) = u_p1_extremes_only  
   v_p1_3d(0:len_ext_p1-1,ilat,ilon) = v_p1_extremes_only 
   delete([/ext_p1_nomiss,u_p1_extremes_only,v_p1_extremes_only/])	
  end if
  
  delete([/ext_p1_ind_nomiss/])
  
  ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(:,ilat,ilon)))
     
  if(.not.all(ismissing(ext_p2_ind_nomiss))) then      
   ext_p2_nomiss = ext_p2(ext_p2_ind_nomiss,ilat,ilon)  
   u_p2_extremes_only = u_p2(ext_p2_ind_nomiss,ilat,ilon)
   v_p2_extremes_only = v_p2(ext_p2_ind_nomiss,ilat,ilon)
   len_ext_p2 = dimsizes(ext_p2_nomiss) 
   ext_p2_3d(0:len_ext_p2-1,ilat,ilon) = ext_p2_nomiss 
   u_p2_3d(0:len_ext_p2-1,ilat,ilon) = u_p2_extremes_only
   v_p2_3d(0:len_ext_p2-1,ilat,ilon) = v_p2_extremes_only
   delete([/ext_p2_nomiss,u_p2_extremes_only,v_p2_extremes_only/])
  end if
  
  delete([/ext_p2_ind_nomiss/])
  
 end do		;ends ilon loop
end do		;ends ilat loop


;;;CALCULATE AVERAGE, AND THEN P2 - P1 FOR CHANGES

ext_ave_p1 = dim_avg_n_Wrap(ext_p1_3d,0)
ext_ave_p2 = dim_avg_n_Wrap(ext_p2_3d,0)
u_ext_ave_p1 = dim_avg_n_Wrap(u_p1_3d,0)
u_ext_ave_p2 = dim_avg_n_Wrap(u_p2_3d,0)
v_ext_ave_p1 = dim_avg_n_Wrap(v_p1_3d,0)
v_ext_ave_p2 = dim_avg_n_Wrap(v_p2_3d,0)

;u_changes = u_ave_p2 - u_ave_p1
;v_changes = v_ave_p2 - v_ave_p1
;wspd_changes = wspd_ave_p2 - wspd_ave_p1
;ext_changes = temp_ave_p2 - temp_ave_p1

ext_ave_p1!0="lat"
ext_ave_p1&lat=lats
ext_ave_p1&lat@units="degrees_north"
ext_ave_p1!1="lon"
ext_ave_p1&lon=lons
ext_ave_p1&lon@units="degrees_east" 

ext_ave_p2!0="lat"
ext_ave_p2&lat=lats
ext_ave_p2&lat@units="degrees_north"
ext_ave_p2!1="lon"
ext_ave_p2&lon=lons
ext_ave_p2&lon@units="degrees_east"

u_ext_ave_p1!0="lat"
u_ext_ave_p1&lat=lats
u_ext_ave_p1&lat@units="degrees_north"
u_ext_ave_p1!1="lon"
u_ext_ave_p1&lon=lons
u_ext_ave_p1&lon@units="degrees_east" 

u_ext_ave_p2!0="lat"
u_ext_ave_p2&lat=lats
u_ext_ave_p2&lat@units="degrees_north"
u_ext_ave_p2!1="lon"
u_ext_ave_p2&lon=lons
u_ext_ave_p2&lon@units="degrees_east" 

v_ext_ave_p1!0="lat"
v_ext_ave_p1&lat=lats
v_ext_ave_p1&lat@units="degrees_north"
v_ext_ave_p1!1="lon"
v_ext_ave_p1&lon=lons
v_ext_ave_p1&lon@units="degrees_east" 

v_ext_ave_p2!0="lat"
v_ext_ave_p2&lat=lats
v_ext_ave_p2&lat@units="degrees_north"
v_ext_ave_p2!1="lon"
v_ext_ave_p2&lon=lons
v_ext_ave_p2&lon@units="degrees_east" 



;***********************************************************
;;*******************Plot data on map***********************
;*********************************************************** 				

;;;PLOT TEMP CHANGES 
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
res@cnMinLevelValF		= -22			;originally -1 Set min contour level
res@cnMaxLevelValF		= 0			;originally 1 Set max contour level
res@cnLevelSpacingF		= 0.5			;originally 0.2
 
res@gsnLeftString		= "Average over 1950-1981"
res@gsnStringFontHeightF	= 0.01

;;;plot wind direction (and magnitude) as overlayed vectors
res_vc				= res
;res_vc@gsnDraw			= False
;res_vc@gsnFrame		= False
res_vc@vcGlyphStyle		= "LineArrow"
res_vc@vcRefMagnitudeF		= 12.00
res_vc@vcRefLengthF		= 0.05
res_vc@vcMinDistanceF		= 0.015
;res_vc@vcRefAnnoExplicitMagnitudeF = 12.00
;res_vc@vcLineArrowHeadMaxSizeF	= 0.08	;default 0.05
;res_vc@vcLineArrowHeadMinSizeF	= 0.08
;res_vc@vcVectorDrawOrder	= "Predraw"
res_vc@gsnLeftString		= " "

plot(0) = gsn_csm_contour_map_ce(wks,ext_ave_p1,res)		;extreme temperature/
vector = gsn_csm_vector(wks,u_ext_ave_p1,v_ext_ave_p1,res_vc)
overlay(plot(0),vector)


;;;PERIOD 2
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
res@gsnSpreadColorStart		= 2				;Start at color index 1..used to be 2
res@gsnSpreadColorEnd		= 65			;Stop at 2nd color from end.. used to be 20

res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
res@cnMinLevelValF		= -22			;originally -1 Set min contour level
res@cnMaxLevelValF		= 0			;originally 1 Set max contour level
res@cnLevelSpacingF		= 0.5			;originally 0.2
 
res@gsnLeftString		= "Average over 1982-2014"
res@gsnStringFontHeightF	= 0.01

;;;plot wind direction (and magnitude) as overlayed vectors
res_vc				= res
;res_vc@gsnDraw			= False
;res_vc@gsnFrame		= False
res_vc@vcGlyphStyle		= "LineArrow"
res_vc@vcRefMagnitudeF		= 12.00
res_vc@vcRefLengthF		= 0.05
res_vc@vcMinDistanceF		= 0.015
;res_vc@vcRefAnnoExplicitMagnitudeF = 12.00
;res_vc@vcLineArrowHeadMaxSizeF	= 0.08	;default 0.05
;res_vc@vcLineArrowHeadMinSizeF	= 0.08
;res_vc@vcVectorDrawOrder	= "Predraw"
res_vc@gsnLeftString		= " "

plot(1) = gsn_csm_contour_map_ce(wks,ext_ave_p2,res)		;extreme temperature
vector2 = gsn_csm_vector(wks,u_ext_ave_p2,v_ext_ave_p2,res_vc)
overlay(plot(1),vector2)


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

pres@gsnPanelMainString		= "SON Tmax (cold tail) - extreme days only"
pres@gsnPanelMainFontHeightF	= 0.015

gsn_panel(wks,plot,(/2,1/),pres)		;2 rows, 1 column

frame(wks)
;maximize_output(wks,True) 
 
end


