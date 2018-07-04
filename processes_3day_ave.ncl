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

var_name = "snc"

ClimVar = "tas_MIN"

;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "50-99_clim_tasmin_snow_cover_3day_ave"
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
 
  ;print("Start looping through "+Data)
  
  ;***********************************************************
  ;;******************READ IN INPUT FILES*********************
  ;***********************************************************

  ;;;READ IN TEMPERATURE DATA; EXTREMES

  ExtDataDir = "/srv/ccrc/data01/z5026024/extremes_only_files/future_tas_1950-2099_clim/annual_exceedances/"
  ;ExtDataDir = "/srv/ccrc/data01/z5026024/extremes_only_files/absolute_tas/annual_exceedances/"
  
  ExtData = ExtDataDir+Data+"_"+ClimVar+"_50-99_clim_1950-1979_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  ;ExtData = ExtDataDir+Data+"_"+ClimVar+"_1950-1979_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  file1 = addfile(ExtData,"r")
  ext_p1 = file1->extremes
  lats = ext_p1&lat
  lons = ext_p1&lon

  ;print(lats)
  ;printVarSummary(temp_p1)	;shows co-ordinates if using individual grid box!

  ExtData2 = ExtDataDir+Data+"_"+ClimVar+"_50-99_clim_2070-2099_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  ;ExtData2 = ExtDataDir+Data+"_"+ClimVar+"_2070-2099_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  file2 = addfile(ExtData2,"r")
  ext_p2 = file2->extremes


  ;;;DAILY TEMP ANOMALIES
  
  ;TempDataDir = "/srv/ccrc/data40/z5026024/CMIP5/anomalies_tas/1950-2099_clim/split_yrs/"
  
  ;TempAnomData = TempDataDir+Data+"_tas_anoms_50-99_clim_1950-1979_2.5x2.5_"+Season+".nc"
  ;file3 = addfile(TempAnomData,"r")
  ;temp_anom_p1 = file3->tas_anoms

  ;TempAnomData2 = TempDataDir+Data+"_tas_anoms_50-99_clim_2070-2099_2.5x2.5_"+Season+".nc"
  ;file4 = addfile(TempAnomData2,"r")
  ;temp_anom_p2 = file4->tas_anoms
  
  
  ;;;READ IN OTHER VARIABLE FILES (ALREADY SHIFTED BY 1 DAY, 2 DAYS, 3 DAYS)

  VarInDataDir = "/srv/ccrc/data01/z5026024/snow_cover_data/split_yrs/"
  
  VarInData_p1_1day = VarInDataDir+var_name+"_day_"+Data+"_1950-1979_2.5x2.5_"+Season+".nc"
  VarFile_p1_1day = addfile(VarInData_p1_1day,"r")
  Var_p1_1day	= VarFile_p1_1day->snc	
  
  Var_time_p1 = Var_p1_1day&time
  Var_lat = Var_p1_1day&lat
  Var_lon = Var_p1_1day&lon	

  VarInData_p2_1day = VarInDataDir+var_name+"_day_"+Data+"_2070-2099_2.5x2.5_"+Season+".nc"
  VarFile_p2_1day = addfile(VarInData_p2_1day,"r")
  Var_p2_1day	= VarFile_p2_1day->snc
  
  Var_time_p2 = Var_p2_1day&time
  


  VarInData_p1_2day = VarInDataDir+var_name+"_minus1_day_"+Data+"_1950-1979_2.5x2.5_"+Season+".nc"
  VarFile_p1_2day = addfile(VarInData_p1_2day,"r")
  Var_p1_2day	= VarFile_p1_2day->snc	
  
  VarInData_p2_2day = VarInDataDir+var_name+"_minus1_day_"+Data+"_2070-2099_2.5x2.5_"+Season+".nc"
  VarFile_p2_2day = addfile(VarInData_p2_2day,"r")
  Var_p2_2day	= VarFile_p2_2day->snc
  
  
  
  VarInData_p1_3day = VarInDataDir+var_name+"_minus2_day_"+Data+"_1950-1979_2.5x2.5_"+Season+".nc"
  VarFile_p1_3day = addfile(VarInData_p1_3day,"r")
  Var_p1_3day	= VarFile_p1_3day->snc		

  VarInData_p2_3day = VarInDataDir+var_name+"_minus2_day_"+Data+"_2070-2099_2.5x2.5_"+Season+".nc"
  VarFile_p2_3day = addfile(VarInData_p2_3day,"r")
  Var_p2_3day	= VarFile_p2_3day->snc
  
  		
  ;***********************************************************
  ;;*************Set up data/calculations*********************
  ;***********************************************************

  ;;;SET UP EMPTY ARRAYS TO STORE DATA
  ext_p1_3d = new(dimsizes(ext_p1),"float",-999.9)
  ext_p2_3d = new(dimsizes(ext_p2),"float",-999.9)
  Var_p1_3d_1day = new(dimsizes(Var_p1_1day),"float",-999.9)
  Var_p2_3d_1day = new(dimsizes(Var_p2_1day),"float",-999.9)
  Var_p1_3d_2day = new(dimsizes(Var_p1_1day),"float",-999.9)
  Var_p2_3d_2day = new(dimsizes(Var_p2_1day),"float",-999.9)
  Var_p1_3d_3day = new(dimsizes(Var_p1_1day),"float",-999.9)
  Var_p2_3d_3day = new(dimsizes(Var_p2_1day),"float",-999.9)

  ;;;LOOP THROUGH LAT/LON TO GET CHANGES FOR EACH GRIDBOX

  do ilat=0,dimsizes(lats)-1
   Lat=lats(ilat)
   ;print(ilat+": "+Lat)
 
   do ilon=0,dimsizes(lons)-1
    Lon=lons(ilon)
    ;print(ilon+": "+Lon)
  
    ;;;ONLY USE VALUES ON DAYS THAT HAVE EXTREME VALUES
  
    ;;;SKIP FIRST INDEX (AS ONE LESS VALUE AT START OF TEMP ADVECTION AS MINUS 1 DAY)
    ;if(Season.eq."DJF") then
    ; ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(1:,ilat,ilon)))		;indices that are non-missing in temp i.e. extremes
    ;else
     ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(:,ilat,ilon)))
    ;end if
  
    if(.not.all(ismissing(ext_p1_ind_nomiss))) then   
     ext_p1_nomiss = ext_p1(ext_p1_ind_nomiss,ilat,ilon)  
     Var_p1_extremes_only_1day = Var_p1_1day(ext_p1_ind_nomiss,ilat,ilon)		;only indclude values for time steps with non-missing temp
     len_ext_p1 = dimsizes(ext_p1_nomiss)
     ext_p1_3d(0:(len_ext_p1)-1,ilat,ilon) = ext_p1_nomiss
     Var_p1_3d_1day(0:len_ext_p1-1,ilat,ilon) = Var_p1_extremes_only_1day
     delete([/ext_p1_nomiss,Var_p1_extremes_only_1day/])
    end if
  
    delete([/ext_p1_ind_nomiss/])
  
    ;if(Season.eq."DJF") then
    ; ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(1:,ilat,ilon)))
    ;else
     ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(:,ilat,ilon)))
    ;end if
     
    if(.not.all(ismissing(ext_p2_ind_nomiss))) then      
     ext_p2_nomiss = ext_p2(ext_p2_ind_nomiss,ilat,ilon)  
     Var_p2_extremes_only_1day = Var_p2_1day(ext_p2_ind_nomiss,ilat,ilon)
     len_ext_p2 = dimsizes(ext_p2_nomiss)   
     ext_p2_3d(0:len_ext_p2-1,ilat,ilon) = ext_p2_nomiss
     Var_p2_3d_1day(0:len_ext_p2-1,ilat,ilon) = Var_p2_extremes_only_1day   

     delete([/ext_p2_nomiss,Var_p2_extremes_only_1day/])
    end if
  
    delete([/ext_p2_ind_nomiss/])
  
  
    ;;;SKIP FIRST INDEX (AS TWO LESS VALUE AT START OF TEMP ADVECTION AS MINUS 2 DAY)
    if(Season.eq."DJF") then
     ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(1:,ilat,ilon)))		;indices that are non-missing in temp i.e. extremes
    else
     ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(:,ilat,ilon)))
    end if
  
    if(.not.all(ismissing(ext_p1_ind_nomiss))) then   
     ext_p1_nomiss = ext_p1(ext_p1_ind_nomiss,ilat,ilon)  
     Var_p1_extremes_only_2day = Var_p1_2day(ext_p1_ind_nomiss,ilat,ilon)		;only indclude values for time steps with non-missing temp
     len_ext_p1 = dimsizes(ext_p1_nomiss)
     ext_p1_3d(0:(len_ext_p1)-1,ilat,ilon) = ext_p1_nomiss
     Var_p1_3d_2day(0:len_ext_p1-1,ilat,ilon) = Var_p1_extremes_only_2day
     delete([/ext_p1_nomiss,Var_p1_extremes_only_2day/])
    end if
  
    delete([/ext_p1_ind_nomiss/])
  
    if(Season.eq."DJF") then
     ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(1:,ilat,ilon)))
    else
     ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(:,ilat,ilon)))
    end if
     
    if(.not.all(ismissing(ext_p2_ind_nomiss))) then      
     ext_p2_nomiss = ext_p2(ext_p2_ind_nomiss,ilat,ilon)  
     Var_p2_extremes_only_2day = Var_p2_2day(ext_p2_ind_nomiss,ilat,ilon)
     len_ext_p2 = dimsizes(ext_p2_nomiss)   
     ext_p2_3d(0:len_ext_p2-1,ilat,ilon) = ext_p2_nomiss
     Var_p2_3d_2day(0:len_ext_p2-1,ilat,ilon) = Var_p2_extremes_only_2day   

     delete([/ext_p2_nomiss,Var_p2_extremes_only_2day/])
    end if
  
    delete([/ext_p2_ind_nomiss/])
  
  
    ;;;SKIP FIRST INDEX (AS THREE LESS VALUE AT START OF TEMP ADVECTION AS MINUS 3 DAY)
    if(Season.eq."DJF") then
     ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(2:,ilat,ilon)))		;indices that are non-missing in temp i.e. extremes
    else
     ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(:,ilat,ilon)))
    end if
  
    if(.not.all(ismissing(ext_p1_ind_nomiss))) then   
     ext_p1_nomiss = ext_p1(ext_p1_ind_nomiss,ilat,ilon)  
     Var_p1_extremes_only_3day = Var_p1_3day(ext_p1_ind_nomiss,ilat,ilon)		;only indclude values for time steps with non-missing temp
     len_ext_p1 = dimsizes(ext_p1_nomiss)
     ext_p1_3d(0:(len_ext_p1)-1,ilat,ilon) = ext_p1_nomiss
     Var_p1_3d_3day(0:len_ext_p1-1,ilat,ilon) = Var_p1_extremes_only_3day
     delete([/ext_p1_nomiss,Var_p1_extremes_only_3day/])
    end if
  
    delete([/ext_p1_ind_nomiss/])
  
    if(Season.eq."DJF") then
     ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(2:,ilat,ilon)))
    else
     ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(:,ilat,ilon)))
    end if
     
    if(.not.all(ismissing(ext_p2_ind_nomiss))) then      
     ext_p2_nomiss = ext_p2(ext_p2_ind_nomiss,ilat,ilon)  
     Var_p2_extremes_only_3day = Var_p2_3day(ext_p2_ind_nomiss,ilat,ilon)
     len_ext_p2 = dimsizes(ext_p2_nomiss)   
     ext_p2_3d(0:len_ext_p2-1,ilat,ilon) = ext_p2_nomiss
     Var_p2_3d_3day(0:len_ext_p2-1,ilat,ilon) = Var_p2_extremes_only_3day   

     delete([/ext_p2_nomiss,Var_p2_extremes_only_3day/])
    end if
  
    delete([/ext_p2_ind_nomiss/])
  
   end do		;ends ilon loop
  end do		;ends ilat loop

  ;printVarSummary(Tadv_p1_3d_1day)

  ;;;CALCULATE AVERAGE TEMP ADVECTION OVER 3 DAY PERIOD PRIOD TO DAY OF EXTREME

  avg3days_p1 = new((/3,dimsizes(Var_time_p1),dimsizes(Var_lat),dimsizes(Var_lon)/),"float",-999.9)

  ;printVarSummary(avg3days_p1)

  avg3days_p1(0,:,:,:) = Var_p1_3d_1day
  avg3days_p1(1,:,:,:) = Var_p1_3d_2day
  avg3days_p1(2,:,:,:) = Var_p1_3d_3day

  Var_p1_3day_ave = dim_avg_n(avg3days_p1,0)


  avg3days_p2 = new((/3,dimsizes(Var_time_p2),dimsizes(Var_lat),dimsizes(Var_lon)/),"float",-999.9)

  avg3days_p2(0,:,:,:) = Var_p2_3d_1day
  avg3days_p2(1,:,:,:) = Var_p2_3d_2day
  avg3days_p2(2,:,:,:) = Var_p2_3d_3day

  Var_p2_3day_ave = dim_avg_n(avg3days_p2,0)


  ;;;CALCULATE AVERAGE OVER P1 AND P2, AND THEN P2 - P1 FOR CHANGES
  ;ext_p1_ave = dim_avg_n_Wrap(ext_p1_3d,0)		;average of time at each lat/lon grid point
  ;ext_p2_ave = dim_avg_n_Wrap(ext_p2_3d,0)

  ;mean_p1_ave = dim_avg_n_Wrap(temp_anom_p1,0)		;mean over time from daily anomaly values 
  ;mean_p2_ave = dim_avg_n_Wrap(temp_anom_p2,0)

  ;ext_changes = ext_p2_ave - ext_p1_ave		;changes in temp extremes
  ;mean_changes = mean_p2_ave - mean_p1_ave	;changes in mean temp
  ;excess_changes = ext_changes - mean_changes	;changes in extremes - changes in mean


  ;;;Excesses for other variables

  Var_p1_ext_ave = dim_avg_n_Wrap(Var_p1_3day_ave,0)		;average temperature advection over period 1
  Var_p2_ext_ave = dim_avg_n_Wrap(Var_p2_3day_ave,0)

  ;Var_p1_ave = dim_avg_n_Wrap(Var_p1 ,0)
  ;Var_p2_ave = dim_avg_n_Wrap(Var_p2,0)

  Var_ext_changes = Var_p2_ext_ave - Var_p1_ext_ave
  ;Var_mean_changes = Var_p2_ave - Var_p1_ave
  ;Var_excess_changes = Var_ext_changes - Var_mean_changes

  delete([/Var_p1_1day, Var_p1_2day, Var_p1_3day, Var_p2_1day, Var_p2_2day, Var_p2_3day, Var_time_p1, Var_time_p2/])
  delete([/ext_p1,ext_p2, ext_p1_3d, ext_p2_3d, Var_p1_3d_1day, Var_p1_3d_2day, Var_p1_3d_3day, Var_p2_3d_1day, Var_p2_3d_2day, Var_p2_3d_3day/])
  delete([/avg3days_p1,avg3days_p2, Var_p1_3day_ave, Var_p2_3day_ave/])

  Var_ext_changes!0="lat"
  Var_ext_changes&lat=lats
  Var_ext_changes&lat@units="degrees_north"
  Var_ext_changes!1="lon"
  Var_ext_changes&lon=lons
  Var_ext_changes&lon@units="degrees_east"

  ;print(dimsizes(Tadv_excess_changes))


  ;***********************************************************
  ;;*******************Plot data on map***********************
  ;*********************************************************** 				


  ;;;PLOT TEMPERATURE ADVECTION CHANGES (LOOP THROUGH DATASETS) w/ VECTOR FOR WIND DIRECTION
  res				= True
  res@gsnMaximize 		= True 			;Maximize plot in frame
  res@gsnDraw			= False			;Don't draw plots
  res@gsnFrame			= False			;Don't advance frame			
  res@cnFillMode		= "CellFill"		;Turn on contour fill
  res@cnFillOn			= True			;Raster Mode
  res@cnLinesOn			= False			;Turn off contour lines

  res@lbLabelAutoStride		= True			;Control labelbar spacing
  res@lbLabelBarOn		= True		;Turn off individual lb's
  res@lbLabelFontHeightF	= .013			;Make labels larger

  res@mpMinLatF			= 30			;Plots less Antarctica - turn off for Robinson
  ;res@gsnCenterString		= ""
  ;res@gsnLeftString		= ""
  ;res@gsnRightString		= ""
  res@cnInfoLabelOn		= False			;Turn off info label
  ;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
  res@gsnTickMarksOn		= False			;Turn on/off all tick marks
  ;res@tmXBLabelFontHeightF	= 0.022
  ;res@tmEqualizeXYSizes	= True

  res@gsnSpreadColors		= True			;Use full range of color map
  res@gsnSpreadColorStart	= 2				;Start at color index 1..used to be 2
  res@gsnSpreadColorEnd		= 65			;Stop at 2nd color from end.. used to be 20

  res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
  
  if(var_name.eq."clt") then
   res@cnMinLevelValF		= -5.0			;originally -1 Set min contour level
   res@cnMaxLevelValF		= 5.0			;originally 1 Set max contour level
  end if
  
  if(var_name.eq."snc") then
   res@cnMinLevelValF		= -10.0			;originally -1 Set min contour level
   res@cnMaxLevelValF		= 10.0			;originally 1 Set max contour level
  end if
  
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

  ;plot_var = gsn_csm_contour_map_ce(wks,Var_excess_changes,res)		;temperature advection changes
  plot_iSeas(iDat) = gsn_csm_contour_map_ce(wks,Var_ext_changes,res)

  ;vector_iSeas(iDat) = gsn_csm_vector(wks,u_excess_changes,v_excess_changes,res_vc)
  ;overlay(plot_iSeas(iDat),vector_iSeas(iDat))

  ;plot_var(iDat) = gsn_csm_contour_map_ce(wks,Var_excess_changes,res)	

  plot_all(iSeas::3) = plot_iSeas		;;iterate through 3 seasons	

  print("Done with "+Data)
 end do			;END LOOPING THROUGH DATASETS

 print("Done with "+Season)
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
gsn_text_ndc(wks,"Changes in snow cover (3 day average including day of extreme - tas anom (150 yr clim) (2070-2099 - 1950-1979)",0.5,0.75,txpres)

frame(wks)  
end
