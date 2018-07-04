load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;Script to plot time series of temperature extremes per year;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin

;;;FOR EUR, USE (:,{45:65},{45:80})
;;;FOR NORTH AMERICA, USE (:,{50:65},{-125:-105})


Years = (/"1950","1951","1952","1953","1954","1955","1956","1957","1958","1959",\
	  "1960","1961","1962","1963","1964","1965","1966","1967","1968","1969",\
	  "1970","1971","1972","1953","1954","1955","1956","1957","1958","1959",\
	  "1980","1981","1982","1953","1954","1955","1956","1957","1958","1959",\
	  "1990","1991","1992","1953","1954","1955","1956","1957","1958","1959",\
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

Var = (/"snc"/)	  
Datasets = (/"CanESM2","CNRM-CM5","CSIRO-Mk3-6-0","inmcm4","MPI-ESM-MR"/)
;Seasons = (/"SON","DJF","MAM"/)
;ClimVars = (/"TXn"/)

Data = "CanESM2"
Season = "SON"

xVals = ispan(1,dimsizes(Years),1)
;yVals = new((/dimsizes(Years),5/),"float",-999.9)

MeanVals = new(dimsizes(Years),"float",-999.9)
MaxVals = new(dimsizes(Years),"float",-999.9)
MinVals = new(dimsizes(Years),"float",-999.9)

var_MeanVals = new(dimsizes(Years),"float",-999.9)
var_MaxVals = new(dimsizes(Years),"float",-999.9)
var_MinVals = new(dimsizes(Years),"float",-999.9)

;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "snc_ts"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)

;plot_temp = new(3,graphic)			;create plot array... 3 variables, 3 seasons

plot = new(2,graphic)

;;;BEGIN LOOPING THROUGH SEASONS AND VARIABLES
;do iSeas=0, dimsizes(Seasons)-1
; Season = Seasons(iSeas)
 
 ;;;START LOOPING THROUGH ANNUAL FILES
    do iYr=0,dimsizes(Years)-1
     Yrs=Years(iYr)
     ;print(iYr+": "+Yrs)
 
  ;;;READ IN ANNUAL TEMP ANOMALIES

    TempDataDir = "/srv/ccrc/data40/z5026024/CMIP5/anomalies/annual_temp/"
    TempData = TempDataDir+Data+"_TX_anoms_"+Yrs+"_2.5x2.5_"+Season+".nc"
    TempFile = addfile(TempData,"r")
    temp = TempFile->TX_anoms(:,{45:65},{45:80})
        
    ;;;READ IN VARIABLES FOR DIFFERENT PROCESSES FOR SAME MODEL
     VarDir = "/srv/ccrc/data04/z5026024/CMIP5/annual_data/"
     VarData = VarDir+Var+"_day_"+Data+"_"+Yrs+"_masked_2.5x2.5_"+Season+".nc"
     VarFile = addfile(VarData,"r")
  
     if(Var.eq."snc")then
      var = VarFile->snc(:,{45:65},{45:80})
     else if(Var.eq."hfls")then
      var = VarFile->hfls(:,{45:65},{45:80})
     else if(Var.eq."hfss")then
      var = VarFile->hfss(:,{45:65},{45:80})
     else if(Var.eq."rlds")then
      var = VarFile->rlds(:,{45:65},{45:80})
     else if(Var.eq."rlus")then
      var = VarFile->rlus(:,{45:65},{45:80})
     else if(Var.eq."rsds")then
      var = VarFile->rsds(:,{45:65},{45:80})
     else if(Var.eq."rsus")then
      var = VarFile->rsus(:,{45:65},{45:80})
     else if(Var.eq."albedo")then
      var = VarFile->rsus(:,{45:65},{45:80})
     else if(Var.eq."Qnet")then
      var = VarFile->rsds(:,{45:65},{45:80})
     end if
     end if
     end if
     end if
     end if
     end if
     end if
     end if
     end if
     

    ;************************************************************
    ;;*******************Calculate statistics********************
    ;************************for boxplot************************* 
  
    opt		= True
    opt@PrintStat = False
   
    temp_stats	= stat_dispersion(temp,opt)
    var_stats	= stat_dispersion(var,opt)
    
    ;;;extract stats for boxplot for each dataset
    ;yVals(iYr,0)	= temp_stats(2)		;min
    ;yVals(iYr,1)	= temp_stats(6)		;lower quartile
    ;yVals(iYr,2)	= temp_stats(0)		;mean
    ;yVals(iYr,3)	= temp_stats(10)	;upper quartile
    ;yVals(iYr,4)	= temp_stats(14)	;max
    
    MeanVals(iYr)	= temp_stats(0)
    MaxVals(iYr)	= temp_stats(26)	;upper 1%
    MinVals(iYr)	= temp_stats(23)	;lower 1%
    
    var_MeanVals(iYr)	= var_stats(0)
    var_MaxVals(iYr)	= var_stats(26)
    var_MinVals(iYr)	= var_stats(23)
    
    
    delete([/temp,opt,temp_stats,var,var_stats/])
    
    end do		;END LOOP iYr
    
    print(var_MaxVals)
    
    ;printVarSummary(MeanVals)
    
  ;***********************************************************
  ;;***********************Plot data**************************
  ;***********************************************************

   
  ;;;PLOT TIME SERIES
  res			= True
  res@gsnMaximize	= True
  res@gsnDraw		= False
  res@gsnFrame		= False

  res@tmXTOn		= False
  res@tmYROn		= False
  res@tmEqualizeXYSizes	= True
  res@trYMaxF 		= 25  
  res@trYMinF 		= -25
  res@trXMinF		= min(xVals)-1
  res@trXMaxF		= max(xVals)+1 
  res@tiYAxisString	= "Tmax (deg C)"
  res@tmXBLabelJust	= "CenterRight"
  res@tmXBLabelAngleF	= 90
  res@tmXBLabelStride	= 10
  res@tmXBMode		= "Explicit"
  res@tmXBValues	= xVals
  res@tmXBLabels	= (/"1950","1951","1952","1953","1954","1955","1956","1957","1958","1959",\
	  		    "1960","1961","1962","1963","1964","1965","1966","1967","1968","1969",\
			    "1970","1971","1972","1953","1954","1955","1956","1957","1958","1959",\
			    "1980","1981","1982","1953","1954","1955","1956","1957","1958","1959",\
			    "1990","1991","1992","1953","1954","1955","1956","1957","1958","1959",\
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
			    
  res@xyMarkLineMode = "Lines"
  res@xyMarkerColor = "grey45"
  
  plot(0) = gsn_csm_xy(wks,xVals,MeanVals,res)
  
  polyres = True
  polyres@gsMarkerIndex = 1
  polyres@gsMarkerSizeF = 0.02
  
  ;centers = new(dimsizes(MeanVals),graphic)
  ;max_min_bar = new(dimsizes(MeanVals),graphic)

  
  ;max_bar = (/MeanVals,MaxVals/)
  ;print(max_bar)
  
  dum = gsn_add_polyline(wks,plot(0),xVals,MaxVals,polyres)
  dum2 = gsn_add_polyline(wks,plot(0),xVals,MinVals,polyres)
  
  
  ;;;loop through points
  ;do t=0,dimsizes(MeanVals)-1
  ; Mean=MeanVals(t)
  ; Max=MaxVals(t)
  ; Min=MinVals(t)
  ; X=xVals(t)
   
   ;printVarSummary(Mean)
   ;printVarSummary(Max)
   ;printVarSummary(X)
   
  ;;;add polymarker as the center of the max/min bar located at each data point
  ;centers(t) = gsn_add_polymarker(wks,plot,xVals,MeanVals,polyres)
  
  ;;;add polyline in 2 segments (2 lines from mean to min/max value)
  ;Max = (/MeanVals(t),MaxVals(t)/)
  ;print(Max)
  ;max_min_bar(t) = gsn_add_polyline(wks,plot,(/X,X/),(/Yrs,Max/),polyres)


  res@tiYAxisString	= "Snow cover fraction (%)"
  res@xyMarkerColor = "blue"
  res@trYMaxF 		= 110  
  res@trYMinF 		= -10
  
  plot(1) = gsn_csm_xy(wks,xVals,var_MeanVals,res)
  dum_var = gsn_add_polyline(wks,plot(1),xVals,var_MaxVals,polyres)
  dum2_var = gsn_add_polyline(wks,plot(1),xVals,var_MinVals,polyres)
  
  ;end do
  
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

gsn_panel(wks,plot,(/2,1/),pres)		;2 rows, 1 column
  
  ;draw(plot)
  frame(wks)
  
end
