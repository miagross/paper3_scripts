load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;Script to plot stime series of temperature extremes per year;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;M.H. Gross, May 2018;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin
;;;test
;;;FOR EUR, USE (:,{45:65},{45:80})
;;;FOR NORTH AMERICA, USE (:,{50:65},{-125:-105})

Years = (/"1950","1951","1952","1953","1954","1955","1956","1957","1958","1959",\
	  "1960","1961","1962","1963","1964","1965","1966","1967","1968","1969",\
	  "1970","1971","1972","1973","1974","1975","1976","1977","1978","1979",\
	  "1980","1981","1982","1983","1984","1985","1986","1987","1988","1989",\
	  "1990","1991","1992","1993","1994","1995","1996","1997","1998","1999",\
	  "2000","2001","2002","2003","2004","2005","2006","2007","2008","2009",\
	  "2010","2011","2012","2013","2014","2015","2016","2017","2018","2019",\
	  "2020","2021","2022","2023","2024","2025","2026","2027","2028","2029",\
	  "2030","2031","2032","2033","2034","2035","2036","2037","2038","2039",\
	  "2040","2041","2042","2043","2044","2045","2046","2047","2048","2049",\
	  "2050","2051","2052","2053","2054","2055","2056","2057","2058","2059",\
	  "2060","2061","2062","2063","2064","2065","2066","2067","2068","2069",\
	  "2070","2071","2072","2073","2074","2075","2076","2077","2078","2079",\
	  "2080","2081","2082","2083","2084","2085","2086","2087","2088","2089",\
	  "2090","2091","2092","2093","2094","2095","2096","2097","2098","2099"/)

;Years = (/"1950","1951","1952","1953","1954","1955","1956","1957","1958","1959"/)
	  
Datasets = (/"CanESM2","CNRM-CM5","CSIRO-Mk3-6-0","inmcm4","MPI-ESM-MR"/)
;Datasets = "CanESM2"
;Seasons = (/"SON","DJF","MAM"/)
Season = "DJF"
ClimVars = (/"abs_tas_MIN"/)

xVals = ispan(1,dimsizes(Years),1)

ext_ind_nomiss = new((/dimsizes(Years),72,144/),"float",-999.9)
;ext_ind_nomiss = new((/dimsizes(Years),2,2/),"float",-999.9)

;print(dimsizes(Years))

;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "abs_map_mean_extreme_index_timing_"+Season
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
    
 ;;;START LOOPING THROUGH ANNUAL FILES
 do iYr=0,dimsizes(Years)-1
  Yrs=Years(iYr)
  ;print(iYr+": "+Yrs)
  ;print("Start looping through year "+Yrs)
 
  ;;***********************************************************
  ;;*********************Read-in input*************************
  ;;***********************************************************

  ;;;READ IN ANNUAL EXTREME TEMP DATA

  ;ExtDataDir = "/srv/ccrc/data01/z5026024/extremes_only_files/future_tas_1950-2099_clim/annual_exceedances/"		;50-2099 climatology
  ExtDataDir = "/srv/ccrc/data01/z5026024/extremes_only_files/absolute_tas/annual_exceedances/"			;ABSOLUTE TEMPS
  
  ;ExtData = ExtDataDir+Data+"_"+ClimVars+"_50-99_clim_"+Yrs+"_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  ExtData = ExtDataDir+Data+"_"+ClimVars+"_"+Yrs+"_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  ExtFile = addfile(ExtData,"r")
 
  ext = ExtFile->extremes
  lats = ext&lat
  lons = ext&lon
  time = ext&time
     
  ;printVarSummary(ext)
     
  ;;***********************************************************
  ;;****************Set up data/calculations*******************
  ;;***********************************************************

  ;;;LOOP THROUGH LAT/LON TO GET INDEX WITH NON-MISSING VALUE FOR EACH GRIDBOX
  do ilat=0,dimsizes(lats)-1
   Lat=lats(ilat)
   ;print(ilat+": "+Lat)
 
   do ilon=0,dimsizes(lons)-1
    Lon=lons(ilon)
    ;print(ilon+": "+Lon)
       
    ;indx = .not.ismissing(ext(:,ilat,ilon))      
    ;print(indx)
    ext_ind_nomiss(iYr,ilat,ilon) = maxind(ext(:,ilat,ilon))	;get the index of the maximum value for each grid cell
       
    ;delete([/ext_ind_nomiss/])
  
   end do		;ends ilon loop
  end do		;ends ilat loop
     
  ;print(Yrs+" "+ext_ind_nomiss(iYr,:,:))
  ;print(Yrs+" "+ext_ind_nomiss(iYr))

  delete([/ext,time/])
    
  ;print("Finished looping through lats/lons for year "+Yrs)
 
 end do							;;;;ends loop iYr
   
 print("Done with looping through years, go to next model")
 
 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;;;;;;;;;;;;CALCULATE SOME STATISTICS FOR PLOTTING;;;;;;;;;;;;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 p1_ind = ext_ind_nomiss(0:29,:,:)
 p2_ind = ext_ind_nomiss(120:149,:,:)
 
 p1_stat = new((/72,144/),"float",-999.9)
 p2_stat = new((/72,144/),"float",-999.9)
 
 ;;;;;;LOOP THROUGH LATS/LONS TO CALCULATE STATS FOR EACH GRID CELL
 do ilat=0,dimsizes(lats)-1
  Lat=lats(ilat)
  ;print(ilat+": "+Lat)
 
  do ilon=0,dimsizes(lons)-1
   Lon=lons(ilon)
   ;print(ilon+": "+Lon)
 
   opt = True
   opt@PrintStat = False
 
   p1_ind_stats = stat_dispersion(p1_ind(:,ilat,ilon),opt)
   p2_ind_stats = stat_dispersion(p2_ind(:,ilat,ilon),opt)
 
   ;printVarSummary(p1_ind_stats)
 
   p1_stat(ilat,ilon) = p1_ind_stats(0)			;mean
   p2_stat(ilat,ilon) = p2_ind_stats(0)
   
   ;p1_stat(ilat,ilon) = p1_ind_stats(10)		;upper quartile
   ;p2_stat(ilat,ilon) = p2_ind_stats(10)
   
   ;p1_stat(ilat,ilon) = p1_ind_stats(6)		;lower quartile
   ;p2_stat(ilat,ilon) = p2_ind_stats(6)
   
   ;p1_stat(ilat,ilon) = p1_ind_stats(8)		;median
   ;p2_stat(ilat,ilon) = p2_ind_stats(8)
 
  end do
 end do
  
 ;printVarSummary(p1_stat)
  
 ;;;;;ALTERNATE METHOD FOR CALCULATE AVERAGE INDEX OVER EACH PERIOD  
 ;p1_stat = dim_avg_n_Wrap(p1_ind,0)			;average of index number for period 1950-1979
 ;p2_stat = dim_avg_n_Wrap(p2_ind,0)			;average of index number for period 2070-2099	
 
 ;;;;;CALCULATE DIFFERENCE BETWEEN FUTURE AND PAST  
 ind_diff = p2_stat - p1_stat
   
 ;print(ind_diff)
   
 ind_diff!0 = "lat"
 ind_diff&lat = lats
 ind_diff&lat@units = "degrees_north"
 ind_diff!1 = "lon"
 ind_diff&lon = lons
 ind_diff&lon@units = "degrees_east"
         
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

 res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
 res@cnMinLevelValF		= -30.0			;originally -1 Set min contour level
 res@cnMaxLevelValF		= 30.0			;originally 1 Set max contour level
 res@cnLevelSpacingF		= 0.5			;originally 0.2
 
 ;res@gsnLeftString		= ClimVar
 res@gsnStringFontHeightF	= 0.03

 plot(iDat) = gsn_csm_contour_map_ce(wks,ind_diff,res)		;extreme temperature changes
 
 ;;;CREATE POINTS FOR BOX
 ;;;IF HOT SPOT REGION IS (:,{47:70},{45:100}) ...(:,{47:70},{-125:-95})
 ;;;USE EU lon (xpts) 46,99 and lat (ypts) 48,69 
 ;;;USE NA lon (xpts) -124,-96 and lat (ypts) 48,69  
 ;;;FOR EXACT BOX MEASUREMENTS

 ;;;EURASIA REGION
 xpts_EUR = (/46.0, 99.0, 99.0, 46.0, 46.0/)
 ypts_EUR = (/69.0, 69.0, 48.0, 48.0, 69.0/)

 ;;;NORTH AMERICAN REGION
 xpts_NA = (/-124.0, -96.0, -96.0, -124.0, -124.0/)
 ypts_NA = (/69.0, 69.0, 48.0, 48.0, 69.0/)

 ;;;ADD THE BOX
 ;resp = True
 ;resp@gsLineColor	= "black"
 ;resp@gsLineThicknessF	= 2.0

 ;dum_EUR = new(5,graphic)
 ;dum_NA = new(5,graphic)

 ;;;draw each line separately, each line must contain two points
 ;do i=0, 3
 ; dum_EUR(i) = gsn_add_polyline(wks,plot(iDat),xpts_EUR(i:i+1),ypts_EUR(i:i+1),resp)
 ; dum_NA(i) = gsn_add_polyline(wks,plot(iDat),xpts_NA(i:i+1),ypts_NA(i:i+1),resp)
 ;end do
  
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
gsn_text_ndc(wks,"Change in timing of extremes (2070-2099 - 1950-1979) for "+Season+" - absolute temps",0.5,0.96,txpres)

txpres@txFontHeightF 	= 0.01
gsn_text_ndc(wks,"Difference in index number (days)",0.5,0.093,txpres)

txpres@txJust		= "topLeft"
txpres@txFontHeightF	= 0.012
gsn_text_ndc(wks,"CanESM2",0.065,0.79,txpres)
gsn_text_ndc(wks,"CNRM-CM5",0.065,0.63,txpres)
gsn_text_ndc(wks,"CSIRO-Mk3-6-0",0.065,0.47,txpres)
gsn_text_ndc(wks,"inmcm4",0.065,0.29,txpres)
gsn_text_ndc(wks,"MPI-ESM-MR",0.065,0.13,txpres)


;draw(plot)
frame(wks)

end
