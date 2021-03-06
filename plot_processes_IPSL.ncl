load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;Script to plot changes in different processes/variables by model;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin

;***********************************************************
;;********************Set up output*************************
;***********************************************************

Data = "IPSL-CM5A-LR"
Season = "SON"

plotfile = "processes_"+Data+"_"+Season
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)

;;;set-up map space
greymap=(/"grey"/) ; colormap with grey
gsn_merge_colormaps(wks,"cmp_b2r",greymap) 	;merge two color maps.. used to be hotcolr_19lev

ClimVar = (/"tas_cold"/)
Variables = (/"rsds","rsdscs","swcre","clt","rsdt","albedo_rs","clwvi"/)

plot_all = new(7,graphic)				;# variables, 4 temp variables
plot_temp = new(1,graphic)				;1 temp variable

 do iVars=0, dimsizes(Variables)-1
  Var = Variables(iVars)

    
  ;***********************************************************
  ;;**********************Read-in input***********************
  ;***********************************************************

  ;;;READ IN TEMPERATURE DATA; EXTREMES

  ExtDataDir = "/srv/ccrc/data01/z5026024/extremes_only_files/future_tas/"
  ExtData = ExtDataDir+Data+"_"+ClimVar+"_1950-1979_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  file1 = addfile(ExtData,"r")
  ext_p1 = file1->extremes
  lats = ext_p1&lat
  lons = ext_p1&lon

  ;print(lats)
  ;printVarSummary(temp_p1)	;shows co-ordinates if using individual grid box!

  ExtData2 = ExtDataDir+Data+"_"+ClimVar+"_2070-2099_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  file2 = addfile(ExtData2,"r")
  ext_p2 = file2->extremes


  ;;;READ IN DAILY TEMP ANOMALIES

  TempDataDir = "/srv/ccrc/data40/z5026024/CMIP5/anomalies_tas/split_yrs/"

  TempData = TempDataDir+Data+"_tas_anoms_1950-1979_2.5x2.5_"+Season+".nc"
  file3 = addfile(TempData,"r")
  Temp_p1 = file3->tas_anoms

  TempData2 = TempDataDir+Data+"_tas_anoms_2070-2099_2.5x2.5_"+Season+".nc"
  file4 = addfile(TempData2,"r")
  Temp_p2 = file4->tas_anoms


  ;;;READ IN VARIABLES FOR DIFFERENT PROCESSES FOR SAME MODEL
  VarDir = "/srv/ccrc/data04/z5026024/CMIP5/IPSL_data/split_yrs/"
  VarData_p1 = VarDir+Var+"_day_"+Data+"_1950-1979_masked_2.5x2.5_"+Season+".nc"
  file5 = addfile(VarData_p1,"r")
  
  VarData_p2 = VarDir+Var+"_day_"+Data+"_2070-2099_masked_2.5x2.5_"+Season+".nc"                                                                                                                                                                                                                                            
  file6 = addfile(VarData_p2,"r")
  
  if(Var.eq."rsds")then
   Var_p1 = file5->rsds
   Var_p2 = file6->rsds
  else if(Var.eq."rsdscs")then
   Var_p1 = file5->rsdscs
   Var_p2 = file6->rsdscs
  else if(Var.eq."swcre") then
   Var_p1 = file5->swcre
   Var_p2 = file6->swcre
  else if(Var.eq."clt")then
   Var_p1 = file5->clt
   Var_p2 = file6->clt
  else if(Var.eq."rsdt")then
   Var_p1 = file5->rsdt
   Var_p2 = file6->rsdt
  else if(Var.eq."albedo_rs")then
   Var_p1 = file5->albedo_rs
   Var_p2 = file6->albedo_rs
  else if(Var.eq."clwvi")then
   Var_p1 = file5->clwvi
   Var_p2 = file6->clwvi
  end if
  end if
  end if
  end if
  end if
  end if
  end if

 
  ;***********************************************************
  ;;***************Set up data/calculations*******************
  ;***********************************************************

  ext_p1_3d = new(dimsizes(ext_p1),"float",-999.9)		;set-up empty array to store calculations
  ext_p2_3d = new(dimsizes(ext_p2),"float",-999.9)
  var_p1_3d = new(dimsizes(Var_p1),"float",-999.9)
  var_p2_3d = new(dimsizes(Var_p2),"float",-999.9)


  ;;;LOOP THROUGH LAT/LON TO GET CHANGES FOR EACH GRIDBOX

  do ilat=0,dimsizes(lats)-1
   Lat=lats(ilat)
   ;print(ilat+": "+Lat)
 
   do ilon=0,dimsizes(lons)-1
    Lon=lons(ilon)
    ;print(ilon+": "+Lon)
  
    ;;;ONLY USE VALUES WHERE THERE ARE EXTREME TEMPERATURE VALUES
    ;;;i.e. WHERE NON-MISSING IN TEMP DATA

    ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(:,ilat,ilon)))		;indices that are non-missing in temp i.e. extremes
    ;print(ext_p1_ind_nomiss)
    ;print(ilat+"  "+ilon)
  
    if(.not.all(ismissing(ext_p1_ind_nomiss))) then
   
     ext_p1_nomiss = ext_p1(ext_p1_ind_nomiss,ilat,ilon)  
     var_p1_extremes_only = Var_p1(ext_p1_ind_nomiss,ilat,ilon)		;only indclude values for time steps with non-missing temp
     len_ext_p1 = dimsizes(ext_p1_nomiss)
     ext_p1_3d(0:(len_ext_p1)-1,ilat,ilon) = ext_p1_nomiss
     var_p1_3d(0:len_ext_p1-1,ilat,ilon) = var_p1_extremes_only
   
     delete([/ext_p1_nomiss,var_p1_extremes_only/])
    end if
  
    delete([/ext_p1_ind_nomiss/])
  
    ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(:,ilat,ilon)))
     
    if(.not.all(ismissing(ext_p2_ind_nomiss))) then   
   
     ext_p2_nomiss = ext_p2(ext_p2_ind_nomiss,ilat,ilon)  
     var_p2_extremes_only = Var_p2(ext_p2_ind_nomiss,ilat,ilon)
     len_ext_p2 = dimsizes(ext_p2_nomiss)   
     ext_p2_3d(0:len_ext_p2-1,ilat,ilon) = ext_p2_nomiss
     var_p2_3d(0:len_ext_p2-1,ilat,ilon) = var_p2_extremes_only
   
     delete([/ext_p2_nomiss,var_p2_extremes_only/])
    end if
  
    delete([/ext_p2_ind_nomiss/])
  
   end do		;ends ilon loop
  end do		;ends ilat loop


  ;;;CALCULATE AVERAGE OVER P1 AND P2, AND THEN P2 - P1 FOR CHANGES
  ext_p1_ave = dim_avg_n_Wrap(ext_p1_3d,0)		;average of time at each lat/lon grid point
  ext_p2_ave = dim_avg_n_Wrap(ext_p2_3d,0)

  mean_p1_ave = dim_avg_n_Wrap(Temp_p1,0)			;mean over time from daily values
  mean_p2_ave = dim_avg_n_Wrap(Temp_p2,0)

  ext_changes = ext_p2_ave - ext_p1_ave
  mean_changes = mean_p2_ave - mean_p1_ave
  excess_changes = ext_changes - mean_changes
  
  ;;;excesses for variables
  var_ext_p1_ave = dim_avg_n_Wrap(var_p1_3d,0)
  var_ext_p2_ave = dim_avg_n_Wrap(var_p2_3d,0)
  
  var_p1_ave = dim_avg_n_Wrap(Var_p1,0)
  var_p2_ave = dim_avg_n_Wrap(Var_p2,0)
  
  var_ext_changes = var_ext_p2_ave - var_ext_p1_ave
  var_mean_changes = var_p2_ave - var_p1_ave
  var_changes = var_ext_changes - var_mean_changes
  
  
  excess_changes!0="lat"
  excess_changes&lat=lats
  excess_changes&lat@units="degrees_north"
  excess_changes!1="lon"
  excess_changes&lon=lons
  excess_changes&lon@units="degrees_east"
  
  var_changes!0="lat"
  var_changes&lat=lats
  var_changes&lat@units="degrees_north"
  var_changes!1="lon"
  var_changes&lon=lons
  var_changes&lon@units="degrees_east"

  print("DONE CALCULATING")
  
  ;***********************************************************
  ;;*******************Plot data on map***********************
  ;*********************************************************** 				

  ;;;PLOT EXCESS CHANGES IN TEMPERATURE (LOOP THROUGH CLIMATE VARIALBES)

  res				= True
  res@gsnMaximize 		= True 			;Maximize plot in frame
  res@gsnDraw			= False			;Don't draw plots
  res@gsnFrame			= False			;Don't advance frame			
  res@cnFillMode		= "CellFill"		;Turn on contour fill
  res@cnFillOn			= True			;Raster Mode
  res@cnLinesOn			= False			;Turn off contour lines

  res@lbLabelAutoStride		= True			;Control labelbar spacing
  res@lbLabelBarOn		= True			;Turn off individual lb's
  res@lbLabelFontHeightF	= .016			;Make labels larger

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
  res@gsnSpreadColorStart	= 2  			;Start at color index 1..used to be 2
  res@gsnSpreadColorEnd		= 65			;Stop at 2nd color from end.. used to be 20

  res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
  res@cnMinLevelValF		= -3.0			;originally -1 Set min contour level
  res@cnMaxLevelValF		= 3.0			;originally 1 Set max contour level
  res@cnLevelSpacingF		= 0.5			;originally 0.2
 
  ;res@gsnLeftString		= ClimVar
  res@gsnStringFontHeightF	= 0.03

  plot_temp = gsn_csm_contour_map_ce(wks,excess_changes,res)		;extreme temperature changes
  
 
  ;;;PLOT EXCESS CHANGES IN VARIABLES (LOOP THROUGH DIFFERENT VARIABLES

  res				= True
  res@gsnMaximize 		= True 			;Maximize plot in frame
  res@gsnDraw			= False			;Don't draw plots
  res@gsnFrame			= False			;Don't advance frame			
  res@cnFillMode		= "CellFill"		;Turn on contour fill
  res@cnFillOn			= True			;Raster Mode
  res@cnLinesOn			= False			;Turn off contour lines

  res@lbLabelAutoStride		= True			;Control labelbar spacing
  res@lbLabelBarOn		= True			;Turn off individual lb's
  res@lbLabelFontHeightF	= .016			;Make labels larger

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
  res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
  
  if(Var.eq."albedo_rs") then
   res@gsnSpreadColorStart	= 2  			
   res@gsnSpreadColorEnd	= 65			
   res@cnMinLevelValF		= -0.1			
   res@cnMaxLevelValF		= 0.1			
   res@cnLevelSpacingF		= 0.01
  else if(Var.eq."clwvi") then
   res@gsnSpreadColorStart	= 2  			
   res@gsnSpreadColorEnd	= 65			
   res@cnMinLevelValF		= -0.03		
   res@cnMaxLevelValF		= 0.03			
   res@cnLevelSpacingF		= 0.005
;  else if(Var.eq."hfss") then
;   res@gsnSpreadColorStart	= 2  			
;   res@gsnSpreadColorEnd	= 65			
;   res@cnMinLevelValF		= -8.0			
;   res@cnMaxLevelValF		= 8.0			
;   res@cnLevelSpacingF		= 1.0
;  else if(Var.eq."hfls") then
;   res@gsnSpreadColorStart	= 2  			
;   res@gsnSpreadColorEnd	= 65			
;   res@cnMinLevelValF		= -8.0			
;   res@cnMaxLevelValF		= 8.0			
;   res@cnLevelSpacingF		= 1.0
  else
   res@gsnSpreadColorStart	= 2  			
   res@gsnSpreadColorEnd	= 65			
   res@cnMinLevelValF		= -16.0			
   res@cnMaxLevelValF		= 16.0			
   res@cnLevelSpacingF		= 2.0
  end if
  end if
;  end if
;  end if	
 
  ;res@gsnLeftString		= Var
  res@gsnStringFontHeightF	= 0.03

  plot_all(iVars) = gsn_csm_contour_map_ce(wks,var_changes,res)		;extreme temperature changes
  
  ;delete([/ext_p1,ext_p2,Temp_p1,Temp_p2,ext_p1_3d,ext_p2_3d,ext_p1_ave,ext_p2_ave,mean_p1_ave,mean_p2_ave/])
  ;delete([/Var_p1,Var_p2,var_p1_3d,var_p2_3d,var_ext_p1_ave,var_ext_p2_ave,var_p1_ave,var_p2_ave/])
  ;delete([/excess_changes,var_changes/])
 
  
 end do				;END LOOP FOR VARIABLES


;;;Panel the plots
pres				= True
pres@gsnPanelLabelBar		= False		;common label bar
pres@gsnFrame			= False		;don't advance frame yet
pres@lbLabelFontHeightF	= 0.01
pres@gsnMaximize		= True		;Maximize plot in frame
pres@pmLabelBarHeightF		= 0.05
pres@lbLabelAutoStride		= True		;nice label bar labels
pres@pmLabelBarOrthogonalPosF	= -0.01		;move label bar down
;pres@gsnPanelOrientation	= "Portrait"
;pres@gsnPanelCenter  		= False
pres@gsnPanelXWhiteSpacePercent= 5
pres@gsnPanelYWhiteSpacePercent = 5
;pres@gsnPanelDebug		= True
pres@gsnPanelTop = 0.96
pres@gsnPanelBottom = 0.85		;0.18 for 7 variables..0.25 for 8 variables
;pres@gsnPanelLeft = 0.1

;pres@gsnPanelMainString	= "MPI-ESM-MR SON excess changes (2070-2099 - 1950-1979)"
;pres@gsnPanelMainFontHeightF	= 0.015

pres2				= True
pres2@gsnPanelLabelBar		= False		;common label bar
pres2@gsnFrame			= False		;don't advance frame yet
pres2@lbLabelFontHeightF	= 0.01
pres2@gsnMaximize		= True		;Maximize plot in frame
pres2@pmLabelBarHeightF		= 0.05
pres2@lbLabelAutoStride		= True		;nice label bar labels
pres2@pmLabelBarOrthogonalPosF	= -0.01		;move label bar down
;pres@gsnPanelOrientation	= "Portrait"
;pres@gsnPanelCenter  		= False
pres2@gsnPanelXWhiteSpacePercent= 5
pres2@gsnPanelYWhiteSpacePercent = 15
pres2@gsnPanelTop = 0.85
;pres2@gsnPanelBottom = 0.0
;pres2@gsnPanelLeft = 0.1

gsn_panel(wks,plot_temp,(/1,1/),pres)
gsn_panel(wks,plot_all,(/7,1/),pres2)		;4 rows, 8 column

;drawNDCGrid(wks)

;;;add text to plot
txpres			= True
txpres@txFontHeightF	= 0.01
txpres@txFontThicknessF	= 1.4
txpres@txJust		= "topLeft"

gsn_text_ndc(wks,"tas (cold tail)",0.15,0.92,txpres)
gsn_text_ndc(wks,"DW SW (surface)",0.15,0.80,txpres)
gsn_text_ndc(wks,"DW SW CLEAR SKY",0.15,0.68,txpres)
gsn_text_ndc(wks,"SWCRE",0.15,0.56,txpres)
gsn_text_ndc(wks,"total cloud fraction",0.15,0.44,txpres)
gsn_text_ndc(wks,"TOA incoming SW",0.15,0.32,txpres)
gsn_text_ndc(wks,"Planetary albedo",0.15,0.20,txpres)
gsn_text_ndc(wks,"Condensed water content",0.15,0.08,txpres)

txpres@txJust = "CenterCenter"
;txpres@txFontHeightF = 0.013
;gsn_text_ndc(wks,"tas (warm tail)",0.28,0.95,txpres)
;gsn_text_ndc(wks,"tas (cold tail)",0.63,0.96,txpres)

txpres@txFontHeightF = 0.015
gsn_text_ndc(wks,Data+" excess changes (2070-2099 - 1950-1979) - "+Season,0.5,0.98,txpres)


frame(wks)
end
