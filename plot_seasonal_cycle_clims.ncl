load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;Script to plot stime series of temperature extremes per year;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;M.H. Gross, May 2018;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin


Datasets = (/"CanESM2","CNRM-CM5","CSIRO-Mk3-6-0","inmcm4","MPI-ESM-MR"/)
;Datasets = "CNRM-CM5"

;ClimVars = (/"tas_min"/)

;xVals = ispan(1,dimsizes(Years),1)


;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "seasonal_cycle_changes_plots"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)

;;;set-up map space
greymap=(/"grey"/) ; colormap with grey
gsn_merge_colormaps(wks,"cmp_b2r",greymap) 	;merge two color maps.. used to be hotcolr_19lev

plot = new(5,graphic)			;create plot array... 3 variables, 3 seasons


;;;BEGIN LOOPING THROUGH SEASONS AND VARIABLES
;;;LOOP THROUGH DATASETS
do iDat=0,dimsizes(Datasets)-1
 Data=Datasets(iDat)
  
 
  ;;***********************************************************
  ;;*********************Read-in input*************************
  ;;***********************************************************

  ;;;READ IN ANNUAL EXTREME TEMP DATA

  ClimDataDir = "/srv/ccrc/data40/z5026024/CMIP5/"
  
  ClimData_p1 = ClimDataDir+"clims_"+Data+"_tas_anoms_test_clim_1950-1979_2.5x2.5.nc.nc"
  ClimFile_p1 = addfile(ClimData_p1,"r")
 
  max_clim_p1 = ClimFile_p1->max_clim
  min_clim_p1 = ClimFile_p1->min_clim
  lats = max_clim_p1&lat
  lons = max_clim_p1&lon
  
  ClimData_p2 = ClimDataDir+"clims_"+Data+"_tas_anoms_test_clim_2070-2099_2.5x2.5.nc.nc"
  ClimFile_p2 = addfile(ClimData_p2,"r")
 
  max_clim_p2 = ClimFile_p2->max_clim
  min_clim_p2 = ClimFile_p2->min_clim

         
  ;;***********************************************************
  ;;****************Set up data/calculations*******************
  ;;***********************************************************
  
  delta_seasonality = (max_clim_p2 - min_clim_p2) - (max_clim_p1 - min_clim_p1) 	;changes in seasonality
  ;delta_seasonality = min_clim_p2 - min_clim_p1		;changes in minimum temp from climatology
  ;delta_seasonality = max_clim_p2 - max_clim_p1		;changes in maximum temp from climatology

 
 
 
   
 delta_seasonality!0 = "lat"
 delta_seasonality&lat = lats
 delta_seasonality&lat@units = "degrees_north"
 delta_seasonality!1 = "lon"
 delta_seasonality&lon = lons
 delta_seasonality&lon@units = "degrees_east"
         
 ;;***********************************************************
 ;;********************Plot data on map***********************
 ;;*********************************************************** 				

 ;;;PLOT EXCESS CHANGES IN TEMPERATURE (LOOP THROUGH CLIMATE VARIALBES)

 res				= True
 res@gsnMaximize 		= True 			;Maximize plot in frame
 res@gsnDraw			= False			;Don't draw plots
 res@gsnFrame			= False			;Don't advance frame			
 res@cnFillMode			= "CellFill"		;Turn on contour fill
 res@cnFillOn			= True			;Raster Mode
 res@cnLinesOn			= False			;Turn off contour lines
 
 res@cnLineLabelsOn		= False

 res@lbLabelAutoStride		= True			;Control labelbar spacing
 res@lbLabelBarOn		= False			;Turn off individual lb's
 res@lbLabelFontHeightF		= .016			;Make labels larger

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
 
 ;;;for MAX/MIN CHANGES
 ;res@gsnSpreadColorStart	= 35  			;Start at color index 1..used to be 2
 ;res@gsnSpreadColorEnd		= 65			;Stop at 2nd color from end.. used to be 20

 res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
 res@cnMinLevelValF		= -5.0			;originally -1 Set min contour level
 res@cnMaxLevelValF		= 5.0			;originally 1 Set max contour level
 res@cnLevelSpacingF		= 0.5			;originally 0.2
 
 ;;;for MAX/MIN CHANGES
 ;res@cnMinLevelValF		= 0.0			;originally -1 Set min contour level
 ;res@cnMaxLevelValF		= 8.0			;originally 1 Set max contour level
 ;res@cnLevelSpacingF		= 0.5

 
 ;res@gsnLeftString		= ClimVar
 res@gsnStringFontHeightF	= 0.03

 plot(iDat) = gsn_csm_contour_map_ce(wks,delta_seasonality,res)		;extreme temperature changes
 
  
end do			;ends loop iDat

print("Finished looping through datasets, panel the plots")


;;;;;;;;;;;;;;;;;;;;;PANEL THE PLOTS;;;;;;;;;;;;;;;;;;;;;;;;

pres				= True
pres@gsnPanelLabelBar		= True		;common label bar
pres@gsnFrame			= False		;don't advance frame yet
pres@lbLabelFontHeightF		= 0.01
pres@gsnMaximize		= True		;Maximize plot in frame
pres@pmLabelBarHeightF		= 0.05
pres@lbLabelAutoStride		= True		;nice label bar labels
pres@pmLabelBarOrthogonalPosF	= -0.01		;move label bar down
;pres@gsnPanelOrientation	= "Portrait"
;pres@gsnPanelCenter  		= False
pres@gsnPanelXWhiteSpacePercent= 5
pres@gsnPanelYWhiteSpacePercent = 5
;pres@gsnPanelDebug		= True
pres@gsnPanelTop = 0.95
pres@gsnPanelBottom = 0.05		;0.18 for 7 variables..0.25 for 8 variables
;pres@gsnPanelLeft = 0.1
;pres@gsnPanelRight = 0.8

gsn_panel(wks,plot,(/5,1/),pres)

;;;add text to plot
txpres			= True
txpres@txFontThicknessF	= 1.4

txpres@txJust		= "CenterCenter"
txpres@txFontHeightF	= 0.015
gsn_text_ndc(wks,"Change in seasonality(2070-2099 - 1950-1979)",0.5,0.96,txpres)

txpres@txFontHeightF 	= 0.01
gsn_text_ndc(wks,"deg C",0.5,0.093,txpres)

txpres@txJust		= "topLeft"
txpres@txFontHeightF	= 0.012
gsn_text_ndc(wks,"CanESM2",0.069,0.79,txpres)
gsn_text_ndc(wks,"CNRM-CM5",0.069,0.63,txpres)
gsn_text_ndc(wks,"CSIRO-Mk3-6-0",0.060,0.47,txpres)
gsn_text_ndc(wks,"inmcm4",0.069,0.29,txpres)
gsn_text_ndc(wks,"MPI-ESM-MR",0.069,0.13,txpres)


;draw(plot)
frame(wks)

end
