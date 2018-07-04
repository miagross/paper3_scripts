load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;Script to plot stime series of temperature extremes per year;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin


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

Variables = (/"snc","hfls","hfss","rlds","rlus","rsds","rsus","albedo"/)	  
Datasets = (/"CanESM2","CNRM-CM5","CSIRO-Mk3-6-0","inmcm4","MPI-ESM-MR"/)
Seasons = (/"SON","DJF","MAM"/)
ClimVars = (/"TXn"/)

;Variables = "snc"
;Seasons = "SON"

temp_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)
var_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)

xVals = ispan(1,dimsizes(Years),1)
ext_ann_ave = new(dimsizes(Years),"float",-999.9)
var_ext_ann_ave = new(dimsizes(Years),"float",-999.9)

;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "annual_scatter_TXn"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)

plot_all = new(8*3,graphic)			;create plot array... 8 variables, 3 seasons

;;;BEGIN LOOPING THROUGH SEASONS AND VARIABLES
do iSeas=0, dimsizes(Seasons)-1
 Season = Seasons(iSeas)

 plot_iSeas = new(8,graphic)			;for 8 variables

  do iVars=0, dimsizes(Variables)-1
   Var = Variables(iVars)
 
   print(Season+": "+Var)

   ;;;LOOP THROUGH DATASETS
   do iDat=0,dimsizes(Datasets)-1
    Data=Datasets(iDat)

    ;;;START LOOPING THROUGH ANNUAL FILES
    do iYr=0,dimsizes(Years)-1
     Yrs=Years(iYr)
     ;print(iYr+": "+Yrs)
 
     ;***********************************************************
     ;;*********************Read-in input************************
     ;***********************************************************

     ;;;READ IN DECADAL EXTREME TEMP DATA

     ExtDataDir = "/srv/ccrc/data40/z5026024/extremes_only_files/1950-2099/annual/"
     ExtData = ExtDataDir+Data+"_"+ClimVars+"_"+Yrs+"_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
     ExtFile = addfile(ExtData,"r")
 
     ext = ExtFile->extremes(:,{42:67},{40:80})		;USE REGIONAL BOX LAT RANGE 45:65 LON RANGE 50:80	
     lats = ext&lat
     lons = ext&lon

     ;;;READ IN VARIABLES FOR DIFFERENT PROCESSES FOR SAME MODEL
     VarDir = "/srv/ccrc/data04/z5026024/CMIP5/annual_data/"
     VarData = VarDir+Var+"_day_"+Data+"_"+Yrs+"_masked_2.5x2.5_"+Season+".nc"
     VarFile = addfile(VarData,"r")
  
     if(Var.eq."snc")then
      var = VarFile->snc(:,{42:67},{40:80})
     else if(Var.eq."hfls")then
      var = VarFile->hfls(:,{42:67},{40:80})
     else if(Var.eq."hfss")then
      var = VarFile->hfss(:,{42:67},{40:80})
     else if(Var.eq."rlds")then
      var = VarFile->rlds(:,{42:67},{40:80})
     else if(Var.eq."rlus")then
      var = VarFile->rlus(:,{42:67},{40:80})
     else if(Var.eq."rsds")then
      var = VarFile->rsds(:,{42:67},{40:80})
     else if(Var.eq."rsus")then
      var = VarFile->rsus(:,{42:67},{40:80})
     else if(Var.eq."albedo")then
      var = VarFile->rsus(:,{42:67},{40:80})
     end if
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

     ext_3d = new(dimsizes(ext),"float",-999.9)		;set-up empty array to store calculations
     ;print(dimsizes(ext_p1_3d))
     var_ext_3d = new(dimsizes(var),"float",-999.9)

     ;;;LOOP THROUGH LAT/LON TO GET CHANGES FOR EACH GRIDBOX
     do ilat=0,dimsizes(lats)-1
      Lat=lats(ilat)
      ;print(ilat+": "+Lat)
 
      do ilon=0,dimsizes(lons)-1
       Lon=lons(ilon)
       ;print(ilon+": "+Lon)
  
       ;;;ONLY USE SNOW VALUES WHERE THERE ARE EXTREME VALUES
       ;;;i.e. ONLY USE SNOW VALUES WHERE NON-MISSING IN TEMP DATA

       ext_ind_nomiss = ind(.not.ismissing(ext(:,ilat,ilon)))	;indices that are non-missing in temp i.e. extremes
       ;print(dimsizes(ext_ind_nomiss))
  
       if(.not.all(ismissing(ext_ind_nomiss))) then
   
        ext_nomiss = ext(ext_ind_nomiss,ilat,ilon)  
        var_extremes_only = var(ext_ind_nomiss,ilat,ilon)		;only indclude values for time steps with non-missing temp
        len_ext = dimsizes(ext_nomiss)
        ext_3d(0:(len_ext)-1,ilat,ilon) = ext_nomiss
        var_ext_3d(0:len_ext-1,ilat,ilon) = var_extremes_only
      
        delete([/ext_nomiss,var_extremes_only/])
       end if  
       delete([/ext_ind_nomiss/])
  
      end do		;ends ilon loop
     end do		;ends ilat loop
  
  
     ;;;TAKE AVERAGE FOR EACH YEAR FROM AREA-AVERAGED REGION
 
    ;;;first calculate regional average (area-weighted average for selected region)
    rad = 4.0*atan(1.0)/180.0
    lat = lats
    clat = cos(lat*rad)
 
    ext_reg_ave = wgt_areaave(ext_3d,clat,1.0,0)
    var_ext_reg_ave = wgt_areaave(var_ext_3d,clat,1.0,0)

    ;ext_pooled_ave = dim_avg_n(ext_3d,(/1,2/))			;(unweighted) area average at each lat/lon grid point

    ext_ann_ave(iYr) = dim_avg_n_Wrap(ext_reg_ave,0)		;average of extreme temperatures per decade (pooled over grid boxes) 
    var_ext_ann_ave(iYr) = dim_avg_n_Wrap(var_ext_reg_ave,0)

    delete([/ext,ext_3d,var,var_ext_3d,ext_reg_ave,var_ext_reg_ave/])
 
   end do		;ends loop iYr


   ;;;CALCULATE CLIMATOLOGICAL AVERAGE FOR FIRST 30 YEARS
   clim_ave_ext = avg(ext_ann_ave(0:29))		;years 1950 - 1979
   ;print(clim_ave_ext)
   clim_var_ave = avg(var_ext_ann_ave(0:29))

   ;;;CALCULATE ANOMALY OF EXTREMES i.e. annual average relative to 1950-1979 average
   ext_ann_anom = ext_ann_ave - clim_ave_ext
   var_ann_anom = var_ext_ann_ave - clim_var_ave

   ;print(ext_ann_ave)
   ;print(ext_ann_anom)

   temp_ts(iDat,:) = ext_ann_anom

   var_ts(iDat,:) = var_ann_anom

   ;max_temp = max(temp_ts)
   ;printVarSummary(temp_ts)

   ;delete([/ext,ext_3d,var,var_ext_3d/])

  end do			;;end loop iDat

  max_temp = max(temp_ts)
  min_temp = min(temp_ts)
  max_var = max(var_ts)
  min_var = min(var_ts)

  ;print(max_var)

  ;print(max(temp_ts))
  ;print(max(var_ts))
  
  ;;;make an array of timeseries for all datasets

  CanESM = temp_ts(0,:)
  CNRM = temp_ts(1,:)
  CSIRO = temp_ts(2,:)
  inmcm = temp_ts(3,:)
  MPI = temp_ts(4,:)

  var_CanESM = var_ts(0,:)
  var_CNRM = var_ts(1,:)
  var_CSIRO = var_ts(2,:)
  var_inmcm = var_ts(3,:)
  var_MPI = var_ts(4,:)
  
  ;;;CALCULATE REGRESSION LINE FOR PLOTTING
  ;y=mx+b
  ;m is the slope: rc returned from regline
  ;b in the y-intercept: rc@yave attribute of rc returned from regline

  rc_CanESM = regline(var_CanESM,CanESM)
  ;;;;PUT REGRESSION LINE AND DATA INTO AN ARRAY
  data_CanESM = new((/2,dimsizes(CanESM)/),typeof(CanESM))
  data_CanESM(0,:) = CanESM
  data_CanESM(1,:) = rc_CanESM*(var_CanESM-rc_CanESM@xave) + rc_CanESM@yave

  rc_CNRM = regline(var_CNRM,CNRM)
  data_CNRM = new((/2,dimsizes(CNRM)/),typeof(CNRM))
  data_CNRM(0,:) = CNRM
  data_CNRM(1,:) = rc_CNRM*(var_CNRM-rc_CNRM@xave) + rc_CNRM@yave
  
  rc_CSIRO = regline(var_CSIRO,CSIRO)
  data_CSIRO = new((/2,dimsizes(CSIRO)/),typeof(CSIRO))
  data_CSIRO(0,:) = CSIRO
  data_CSIRO(1,:) = rc_CSIRO*(var_CSIRO-rc_CSIRO@xave) + rc_CSIRO@yave
  
  rc_inmcm = regline(var_inmcm,inmcm)
  data_inmcm = new((/2,dimsizes(inmcm)/),typeof(inmcm))
  data_inmcm(0,:) = inmcm
  data_inmcm(1,:) = rc_inmcm*(var_inmcm-rc_inmcm@xave) + rc_inmcm@yave
  
  rc_MPI = regline(var_MPI,MPI)
  data_MPI = new((/2,dimsizes(MPI)/),typeof(MPI))
  data_MPI(0,:) = MPI
  data_MPI(1,:) = rc_MPI*(var_MPI-rc_MPI@xave) + rc_MPI@yave
  
  ;**********************************************************
  ;**********************Plot data***************************
  ;**********************************************************
   
  ;;;PLOT TIME SERIES
  ;res			= True
  ;res@gsnMaximize	= True
  ;res@gsnDraw		= False
  ;res@gsnFrame		= False

  ;res@tmXTOn		= False
  ;res@tmYROn		= False
  ;res@tmEqualizeXYSizes	= True
  ;res@trYMaxF 		= max_temp+1  
  ;res@trYMinF 		= min_temp-1
  ;res@trXMinF		= min(xVals)-1
  ;res@trXMaxF		= max(xVals)+1 
  ;res@tmXBLabelJust	= "CenterRight"
  ;res@tmXBLabelAngleF	= 90
  ;res@tmXBLabelStride	= 10
  ;res@tmXBMode		= "Explicit"
  ;res@tmXBValues	= xVals
  ;res@tmXBLabels	= (/"1950","1951","1952","1953","1954","1955","1956","1957","1958","1959",\
	;  		    "1960","1961","1962","1963","1964","1965","1966","1967","1968","1969",\
	;		    "1970","1971","1972","1953","1954","1955","1956","1957","1958","1959",\
	;		    "1980","1981","1982","1953","1954","1955","1956","1957","1958","1959",\
	;		    "1990","1991","1992","1953","1954","1955","1956","1957","1958","1959",\
	;		    "2000","2001","2002","2003","2004","2005","2006","2007","2008","2009",\
	;		    "2010","2011","2012","2013","2014","2015","2016","2017","2018","2019",\
	;	 	    "2020","2021","2022","2023","2024","2025","2026","2027","2028","2029",\
	;		    "2030","2031","2032","2033","2034","2035","2036","2037","2038","2039",\
	;		    "2040","2041","2042","2043","2044","2045","2046","2047","2048","2049",\
	;		    "2050","2051","2052","2053","2054","2055","2056","2057","2058","2059",\
	;		    "2060","2061","2062","2063","2064","2065","2066","2067","2068","2069",\
	;		    "2070","2071","2072","2073","2074","2075","2076","2077","2078","2079",\
	;		    "2080","2081","2082","2083","2084","2085","2086","2087","2088","2089",\
	;		    "2090","2091","2092","2093","2094","2095","2096","2097","2098","2099"/)

  ;res@xyLineColors	= (/"grey","steelblue1","seagreen","plum","tomato"/)
			  
  ;;;PLOT TEMPERATURES (as anomalies relative to 1950 - 1959)
  ;res@tiMainString	= "Extreme temperatures (relative to 1950-'79)"
  ;plot(0)			= gsn_csm_xy(wks,xVals,temp_ts,res)

  ;;;PLOT VARIABLES
  ;res@trYMaxF 		= max_var+1
  ;res@trYMinF 		= min_var-1
  ;res@tiMainString	= "Snow cover (extreme temperature days only)"
  ;plot(1)			= gsn_csm_xy(wks,xVals,var_ts,res)

  ;delete(res)
  

  ;;;;;;PLOT SCATTER PLOT OF CORRELATIONS FROM TIME SERIES
  res				= True
  res@gsnMaximize		= True
  res@gsnDraw			= False
  res@gsnFrame			= False

  res@gsnXRefLine		= 0.0
  res@gsnYRefLine		= 0.0
  res@gsnXRefLineDashPattern 	= 2
  res@gsnYRefLineDashPattern 	= 2

  res@tmEqualizeXYSizes		= True
  res@tmXTOn			= False
  res@tmYROn			= False
  res@tmXBLabelFontHeightF	= 0.022
  
  res@trYMaxF = max_temp+1
  res@trYMinF = min_temp-1
  if(Var.eq."albedo") then
   res@trXMaxF = 0.4
   res@trXMinF = -0.4
  else
   res@trXMaxF = max_var+1
   res@trXMinF = min_var-1
  end if

  res@xyMarkLineModes = (/"Markers","Lines"/)
  res@xyMarker = 16
  res@xyMarkerSizeF = 14

  ;res@xyMarkerColors = (/"grey","steelblue1","seagreen","plum","tomato"/)
  ;plot_iSeas(iVars) = gsn_csm_xy(wks,(/var_CanESM,var_CNRM,var_CSIRO,var_inmcm,var_MPI/),(/CanESM,CNRM,CSIRO,inmcm,MPI/),res)
  
  res@xyMarkerColor = "grey"
  res@xyLineColor = "grey"
  res@xyLineThicknessF = 1
  plot_iSeas(iVars) = gsn_csm_xy(wks,var_CanESM,data_CanESM,res)
  
  res@xyMarkerColor = "steelblue1"
  res@xyLineColor = "steelblue1"
  res@xyLineThicknessF = 1
  dum1 = gsn_csm_xy(wks,var_CNRM,data_CNRM,res)
  
  res@xyMarkerColor = "seagreen"
  res@xyLineColor = "seagreen"
  res@xyLineThicknessF = 1
  dum2 = gsn_csm_xy(wks,var_CSIRO,data_CSIRO,res)
  
  res@xyMarkerColor = "plum"
  res@xyLineColor = "plum"
  res@xyLineThicknessF = 1
  dum3 = gsn_csm_xy(wks,var_inmcm,data_inmcm,res)
  
  res@xyMarkerColor = "tomato"
  res@xyLineColor = "tomato"
  res@xyLineThicknessF = 1
  dum4 = gsn_csm_xy(wks,var_MPI,data_MPI,res)
  
  overlay(plot_iSeas(iVars),dum1)
  overlay(plot_iSeas(iVars),dum2)
  overlay(plot_iSeas(iVars),dum3)
  overlay(plot_iSeas(iVars),dum4)

  plot_all(iSeas::3) = plot_iSeas	;;iterate through 3 seasons
  
  
 end do		;END LOOP VARIABLES
 
end do		;END LOOP SEASONS


;;;;;;Panel the plots
pres				= True
;pres@gsnPanelLabelBar		= False		;common label bar
pres@gsnFrame			= False		;don't advance frame yet
;pres@lbLabelFontHeightF	= 0.01
pres@gsnMaximize		= True		;Maximize plot in frame
;pres@pmLabelBarHeightF		= 0.05
;pres@lbLabelAutoStride		= True		;nice label bar labels
pres@gsnPanelOrientation	= "auto"
;pres@gsnPanelCenter  		= False
pres@gsnPanelXWhiteSpacePercent= 5
pres@gsnPanelYWhiteSpacePercent= 5

pres@gsnPanelTop = 0.95
pres@gsnPanelBottom = 0.03

;pres@gsnPanelMainString		= "SON Tmin (cold tail)"
;pres@gsnPanelMainFontHeightF	= 0.015

gsn_panel(wks,plot_all,(/8,3/),pres)		;2 rows, 1 column



;;;manually add text and legend
gsres = True

gsres@txFontHeightF	= 0.015
gsres@txJust = "CenterCenter"
gsn_text_ndc(wks,"Tmax (cold tail)",0.5,0.98,gsres)

gsres@txFontHeightF	= 0.01
gsn_text_ndc(wks,"SON",0.39,0.957,gsres)
gsn_text_ndc(wks,"DJF",0.51,0.957,gsres)
gsn_text_ndc(wks,"MAM",0.62,0.957,gsres)

gsres@txJust = "CenterLeft"

gsn_text_ndc(wks,"snow cover",0.24,0.9,gsres)
gsn_text_ndc(wks,"latent heat",0.24,0.77,gsres)
gsn_text_ndc(wks,"sensible heat",0.24,0.67,gsres)
gsn_text_ndc(wks,"DW longwave",0.24,0.55,gsres)
gsn_text_ndc(wks,"UW longwave",0.24,0.44,gsres)
gsn_text_ndc(wks,"DW shortwave",0.24,0.32,gsres)
gsn_text_ndc(wks,"UW shortwave",0.24,0.21,gsres)
gsn_text_ndc(wks,"Albedo",0.27,0.1,gsres)

gsres@txAngleF = 90.
gsres@txFontHeightF = 0.007
gsres@txJust = "CenterCenter"
gsn_text_ndc(wks,"Temperature anomaly (°C)",0.32,0.9,gsres)


gsres@txAngleF = 0.
gsres@gsMarkerIndex = 16
gsres@gsMarkerSizeF = 6
gsres@txFontHeightF	= 0.01
gsres@txJust = "CenterLeft"
 
gsres@gsMarkerColor = "grey"
gsn_polymarker_ndc(wks,0.25,0.015,gsres)
gsn_text_ndc(wks,"CanESM2",0.26,0.015,gsres)

gsres@gsMarkerColor = "steelblue1"
gsn_polymarker_ndc(wks,0.35,0.015,gsres)
gsn_text_ndc(wks,"CNRM-CM5",0.36,0.015,gsres)

gsres@gsMarkerColor = "seagreen"
gsn_polymarker_ndc(wks,0.46,0.015,gsres)
gsn_text_ndc(wks,"CSIRO-Mk3-6-0",0.47,0.015,gsres)

gsres@gsMarkerColor = "plum"
gsn_polymarker_ndc(wks,0.60,0.015,gsres)
gsn_text_ndc(wks,"inmcm4",0.61,0.015,gsres)

gsres@gsMarkerColor = "tomato"
gsn_polymarker_ndc(wks,0.70,0.015,gsres)
gsn_text_ndc(wks,"MPI-ESM-MR",0.71,0.015,gsres)


;draw(plot)		;use for single plot only
frame(wks)

end
