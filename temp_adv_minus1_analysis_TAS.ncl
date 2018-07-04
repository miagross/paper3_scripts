load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Script to calculate horizontal temperature advection;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;and plot changes in advection;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

begin 

Dataset = (/"CanESM2","CNRM-CM5","CSIRO-Mk3-6-0","inmcm4","MPI-ESM-MR"/)
;Dataset = "CanESM2"

Seasons = (/"DJF","MAM","SON"/)
;Season = (/"DJF"/)

ClimVar = "tas_MIN"

;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "50-99_clim_tasMIN_temp_adv_minus3"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)
;plot = new(4,graphic)			;create plot array

;plot_temp = new(1,graphic) 	;1 plot for 1 temp variable
plot_var = new(1,graphic)	;5 plots for each dataset
;vector = new(5,graphic)	;overlay wind speed for 5 datasets

plot_all = new(5*3,graphic)	;5 models, 3 seasons

;;;set-up map space
greymap=(/"grey"/) ; colormap with grey
gsn_merge_colormaps(wks,"cmp_b2r",greymap) 	;merge two color maps.. used to be hotcolr_19lev/posneg_1/cmp_b2r

;;;BEGIN LOOPING THROUGH SEASONS AND DATASETS

do iSeas=0, dimsizes(Seasons)-1
 Season=Seasons(iSeas)
 
 plot_iSeas = new(5,graphic)			;5 models
 vector_iSeas = new(5,graphic)

do iDat=0, dimsizes(Dataset)-1
 Data=Dataset(iDat)
 
; print("Start looping through "+Data)
 
 
;***********************************************************
;;******************READ IN INPUT FILES*********************
;***********************************************************

  ;;;READ IN TEMPERATURE DATA; EXTREMES

  ExtDataDir = "/srv/ccrc/data01/z5026024/extremes_only_files/future_tas_1950-2099_clim/annual_exceedances/"
  
  ExtData = ExtDataDir+Data+"_"+ClimVar+"_50-99_clim_1950-1979_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  file1 = addfile(ExtData,"r")
  ext_p1 = file1->extremes
  lats = ext_p1&lat
  lons = ext_p1&lon

  ;print(lats)
  ;printVarSummary(temp_p1)	;shows co-ordinates if using individual grid box!

  ExtData2 = ExtDataDir+Data+"_"+ClimVar+"_50-99_clim_2070-2099_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  file2 = addfile(ExtData2,"r")
  ext_p2 = file2->extremes


  ;;;DAILY TEMP ANOMALIES
  
  TempDataDir = "/srv/ccrc/data40/z5026024/CMIP5/anomalies_tas/1950-2099_clim/split_yrs/"
  
   TempAnomData = TempDataDir+Data+"_tas_anoms_50-99_clim_1950-1979_2.5x2.5_"+Season+".nc"
   file3 = addfile(TempAnomData,"r")
   temp_anom_p1 = file3->tas_anoms

   TempAnomData2 = TempDataDir+Data+"_tas_anoms_50-99_clim_2070-2099_2.5x2.5_"+Season+".nc"
   file4 = addfile(TempAnomData2,"r")
   temp_anom_p2 = file4->tas_anoms
  
  
  ;;;READ IN TEMPERATURE ADVECTION FILES (ALREADY SHIFTED BY 1 DAY)

  Tadvindatadir = "/srv/ccrc/data04/z5026024/CMIP5/temp_advection_data/tas_Tadv_data/split_yrs/"
  
  Tadvindata_p1 = Tadvindatadir+"Tadv_minus3_tas_day_"+Data+"_1950-1979_2.5x2.5_"+Season+".nc"
  TadvFile_p1 = addfile(Tadvindata_p1,"r")
  Tadv_p1	= TadvFile_p1->Tadv	
  
  ;printVarSummary(Tadv_p1)	

  Tadvindata_p2 = Tadvindatadir+"Tadv_minus3_tas_day_"+Data+"_2070-2099_2.5x2.5_"+Season+".nc"
  TadvFile_p2 = addfile(Tadvindata_p2,"r")
  Tadv_p2	= TadvFile_p2->Tadv
  
  ;print(Tadv_p1(:,1,1))		


;***********************************************************
;;*************Set up data/calculations*********************
;***********************************************************

;;;SET UP EMPTY ARRAYS TO STORE DATA
ext_p1_3d = new(dimsizes(ext_p1),"float",-999.9)
ext_p2_3d = new(dimsizes(ext_p2),"float",-999.9)
Tadv_p1_3d = new(dimsizes(Tadv_p1),"float",-999.9)
Tadv_p2_3d = new(dimsizes(Tadv_p2),"float",-999.9)

;;;LOOP THROUGH LAT/LON TO GET CHANGES FOR EACH GRIDBOX

do ilat=0,dimsizes(lats)-1
 Lat=lats(ilat)
 ;print(ilat+": "+Lat)
 
 do ilon=0,dimsizes(lons)-1
  Lon=lons(ilon)
  ;print(ilon+": "+Lon)
  

  ;;;ONLY USE VALUES ON DAYS THAT HAVE EXTREME VALUES
  ;;;i.e. ONLY USE TEMP ADVECTION WHERE NON-MISSING IN TEMP DATA
  ;;;SKIP FIRST INDEX (AS ONE LESS VALUE IN TEMP ADVECTION AS MINUS 1 DAY)
  if(Season.eq."DJF") then
   ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(3:,ilat,ilon)))		;indices that are non-missing in temp i.e. extremes
  else
   ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(:,ilat,ilon)))
  end if
  
  if(.not.all(ismissing(ext_p1_ind_nomiss))) then   
   ext_p1_nomiss = ext_p1(ext_p1_ind_nomiss,ilat,ilon)  
   Tadv_p1_extremes_only = Tadv_p1(ext_p1_ind_nomiss,ilat,ilon)		;only indclude values for time steps with non-missing temp
   len_ext_p1 = dimsizes(ext_p1_nomiss)
   ext_p1_3d(0:(len_ext_p1)-1,ilat,ilon) = ext_p1_nomiss
   Tadv_p1_3d(0:len_ext_p1-1,ilat,ilon) = Tadv_p1_extremes_only
   delete([/ext_p1_nomiss,Tadv_p1_extremes_only/])
  end if
  
  delete([/ext_p1_ind_nomiss/])
  
  if(Season.eq."DJF") then
   ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(3:,ilat,ilon)))
  else
   ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(:,ilat,ilon)))
  end if
     
  if(.not.all(ismissing(ext_p2_ind_nomiss))) then      
   ext_p2_nomiss = ext_p2(ext_p2_ind_nomiss,ilat,ilon)  
   Tadv_p2_extremes_only = Tadv_p2(ext_p2_ind_nomiss,ilat,ilon)
   len_ext_p2 = dimsizes(ext_p2_nomiss)   
   ext_p2_3d(0:len_ext_p2-1,ilat,ilon) = ext_p2_nomiss
   Tadv_p2_3d(0:len_ext_p2-1,ilat,ilon) = Tadv_p2_extremes_only   

   delete([/ext_p2_nomiss,Tadv_p2_extremes_only/])
  end if
  
  delete([/ext_p2_ind_nomiss/])
  
 end do		;ends ilon loop
end do		;ends ilat loop


;;;CALCULATE AVERAGE OVER P1 AND P2, AND THEN P2 - P1 FOR CHANGES
ext_p1_ave = dim_avg_n_Wrap(ext_p1_3d,0)		;average of time at each lat/lon grid point
ext_p2_ave = dim_avg_n_Wrap(ext_p2_3d,0)

mean_p1_ave = dim_avg_n_Wrap(temp_anom_p1,0)		;mean over time from daily anomaly values
mean_p2_ave = dim_avg_n_Wrap(temp_anom_p2,0)

ext_changes = ext_p2_ave - ext_p1_ave		;changes in temp extremes
mean_changes = mean_p2_ave - mean_p1_ave	;changes in mean temp
excess_changes = ext_changes - mean_changes	;changes in extremes - changes in mean


;;;Excesses for other variables

Tadv_p1_ext_ave = dim_avg_n_Wrap(Tadv_p1_3d,0)		;average temperature advection over period 1
Tadv_p2_ext_ave = dim_avg_n_Wrap(Tadv_p2_3d,0)

Tadv_p1_ave = dim_avg_n_Wrap(Tadv_p1,0)
Tadv_p2_ave = dim_avg_n_Wrap(Tadv_p2,0)

Tadv_ext_changes = Tadv_p2_ext_ave - Tadv_p1_ext_ave
Tadv_mean_changes = Tadv_p2_ave - Tadv_p1_ave
Tadv_excess_changes = Tadv_ext_changes - Tadv_mean_changes

delete([/ext_p1,ext_p2,Tadv_p1,Tadv_p2,temp_anom_p1,temp_anom_p2/])
delete([/ext_p1_3d,ext_p2_3d,Tadv_p1_3d,Tadv_p2_3d/])
 
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

excess_changes!0="lat"
excess_changes&lat=lats
excess_changes&lat@units="degrees_north"
excess_changes!1="lon"
excess_changes&lon=lons
excess_changes&lon@units="degrees_east"

Tadv_ext_changes!0="lat"
Tadv_ext_changes&lat=lats
Tadv_ext_changes&lat@units="degrees_north"
Tadv_ext_changes!1="lon"
Tadv_ext_changes&lon=lons
Tadv_ext_changes&lon@units="degrees_east"

;print(dimsizes(Tadv_excess_changes))


;***********************************************************
;;*******************Plot data on map***********************
;*********************************************************** 				


;;;PLOT TEMPERATURE ADVECTION CHANGES (LOOP THROUGH DATASETS) w/ VECTOR FOR WIND DIRECTION
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
res@cnMinLevelValF		= -2.0			;originally -1 Set min contour level
res@cnMaxLevelValF		= 2.0			;originally 1 Set max contour level
res@cnLevelSpacingF		= 0.5			;originally 0.2
;res@cnMinLevelValF		= -0.04			;originally -1 Set min contour level
;res@cnMaxLevelValF		= 2.			;originally 1 Set max contour level
;res@cnLevelSpacingF		= 0.5/80000		;originally 0.2
 
;res@gsnLeftString		= Data
;res@gsnStringFontHeightF	= 0.01


;res_vc				= res
;res_vc@vcGlyphStyle		= "LineArrow"
;res_vc@vcLineArrowThicknessF	= 1
;res_vc@vcMinDistanceF		= 0.01
;res_vc@vcRefLengthF		= 0.05		;length of shaft of arrow
;res_vc@vcLineArrowHeadMaxSizeF	= 0.07
;;res_vc@vcLineArrowHeadMinSizeF 	= 0.07
;res_vc@gsnLeftString		= " "

;plot_var = gsn_csm_contour_map_ce(wks,Tadv_excess_changes,res)		;temperature advection changes
plot_iSeas(iDat) = gsn_csm_contour_map_ce(wks,Tadv_ext_changes,res)

;vector_iSeas(iDat) = gsn_csm_vector(wks,u_excess_changes,v_excess_changes,res_vc)
;overlay(plot_iSeas(iDat),vector_iSeas(iDat))


;plot_var(iDat) = gsn_csm_contour_map_ce(wks,Tadv_excess_changes,res)	

plot_all(iSeas::3) = plot_iSeas		;;iterate through 3 seasons	

end do			;END LOOPING THROUGH DATASETS
end do			;END LOOPING THROUGH SEASONS


;;;;;;Panel the plots
pres				= True
pres@gsnPanelLabelBar		= False		;common label bar
pres@gsnFrame			= False		;don't advance frame yet
pres@lbLabelFontHeightF	= 0.01
pres@gsnMaximize		= True		;Maximize plot in frame
pres@pmLabelBarHeightF		= 0.05
pres@lbLabelAutoStride		= True		;nice label bar labels
pres@gsnPanelOrientation	= "auto"
;pres@gsnPanelCenter  		= False
pres@gsnPanelXWhiteSpacePercent = 5
pres@gsnPanelYWhiteSpacePercent = 10

;pres@gsnPanelMainString		= "MAM Tmas (cold tail)"
;pres@gsnPanelMainFontHeightF	= 0.015

pres@gsnPanelLeft	= 0.02

gsn_panel(wks,plot_all,(/5,3/),pres)		;2 rows, 1 column

;;;add text to plot
txpres			= True
txpres@txFontHeightF	= 0.01
txpres@txFontThicknessF	= 1.4

txpres@txJust = "TopLeft"
gsn_text_ndc(wks,"CanESM2",0.01,0.70,txpres)
gsn_text_ndc(wks,"CNRM-CM5",0.01,0.62,txpres)
gsn_text_ndc(wks,"CSIRO-Mk3-6-0",0.01,0.54,txpres)
gsn_text_ndc(wks,"inmcm4",0.01,0.46,txpres)
gsn_text_ndc(wks,"MPI-ESM-MR",0.01,0.38,txpres)

txpres@txJust = "CenterCenter"
txpres@txFontHeightF	= 0.012
gsn_text_ndc(wks,"DJF",0.2,0.72,txpres)
gsn_text_ndc(wks,"MAM",0.5,0.72,txpres)
gsn_text_ndc(wks,"SON",0.83,0.72,txpres)

txpres@txFontHeightF = 0.015
gsn_text_ndc(wks,"Changes in temperature advection (3 days before extreme - TAS) (2070-2099 - 1950-1979)",0.5,0.75,txpres)

frame(wks)  
end
