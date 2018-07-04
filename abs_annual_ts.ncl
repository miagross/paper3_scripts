load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;Script to plot stime series of temperature extremes per year;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin

;;;FOR EUR, USE (:,{45:65},{45:80})
;;;FOR NORTH AMERICA, USE (:,{50:65},{-125:-105})


;Years = (/"1950","1951","1952","1953","1954","1955","1956","1957","1958","1959",\
;	  "1960","1961","1962","1963","1964","1965","1966","1967","1968","1969",\
;	  "1970","1971","1972","1973","1974","1975","1976","1977","1978","1979",\
;	  "1980","1981","1982","1983","1984","1985","1986","1987","1988","1989",\
;	  "1990","1991","1992","1993","1994","1995","1996","1997","1998","1999",\
;	  "2000","2001","2002","2003","2004","2005","2006","2007","2008","2009",\
;	  "2010","2011","2012","2013","2014","2015","2016","2017","2018","2019",\
;	  "2020","2021","2022","2023","2024","2025","2026","2027","2028","2029",\
;	  "2030","2031","2032","2033","2034","2035","2036","2037","2038","2039",\
;	  "2040","2041","2042","2043","2044","2045","2046","2047","2048","2049",\
;	  "2050","2051","2052","2053","2054","2055","2056","2057","2058","2059",\
;	  "2060","2061","2062","2063","2064","2065","2066","2067","2068","2069",\
;	  "2070","2071","2072","2073","2074","2075","2076","2077","2078","2079",\
;	  "2080","2081","2082","2083","2084","2085","2086","2087","2088","2089",\
;	  "2090","2091","2092","2093","2094","2095","2096","2097","2098","2099"/)

Years = (/"2090"/)
;Datasets = (/"CanESM2","CNRM-CM5","CSIRO-Mk3-6-0","inmcm4","MPI-ESM-MR"/)
Datasets = "CanESM2"
;Seasons = (/"SON","DJF","MAM"/)
Season = "SON"
ClimVars = (/"tas_cold"/)

ext_temp_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)

xVals = ispan(1,dimsizes(Years),1)
;ext_ann_ave = new((/dimsizes(Years),12,36/),"float",-999.9)

ext_ind_nomiss = new((/dimsizes(Years),72,144/),"float",-999.9)
;dsizes = new(dimsizes(Years),"float",-999.9)
;printVarSummary(ext_ind_nomiss)

;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "anom_annual_time_series_"+Datasets+"_"+Season
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)

plot= new(1,graphic)			;create plot array... 3 variables, 3 seasons


;;;BEGIN LOOPING THROUGH SEASONS AND VARIABLES
;do iSeas=0, dimsizes(Seasons)-1
 ;Season = Seasons(iSeas)

   ;;;LOOP THROUGH DATASETS
   do iDat=0,dimsizes(Datasets)-1
    Data=Datasets(iDat)
    

    ;;;START LOOPING THROUGH ANNUAL FILES
    do iYr=0,dimsizes(Years)-1
     Yrs=Years(iYr)
    ; ;print(iYr+": "+Yrs)
 
     ;***********************************************************
     ;;*********************Read-in input************************
     ;***********************************************************

     ;;;READ IN ANNUAL EXTREME TEMP DATA

     ExtDataDir = "/srv/ccrc/data01/z5026024/extremes_only_files/future_tas/annual_exceedances/"
     ExtData = ExtDataDir+Data+"_"+ClimVars+"_"+Yrs+"_EXTREMES_ONLY_stationary_2.5x2.5_"+Season+".nc"
     ExtFile = addfile(ExtData,"r")
 
     ext = ExtFile->extremes		;USE REGIONAL BOX LAT RANGE 45:65 LON RANGE 50:80	
     lats = ext&lat
     lons = ext&lon
     time = ext&time
     
     ;printVarSummary(ext)
     ;print(lons)
 
     ;***********************************************************
     ;;***************Set up data/calculations*******************
     ;***********************************************************

     ext_3d = new(dimsizes(ext),"float",-999.9)		;set-up empty array to store calculations
     ;print(dimsizes(ext_p1_3d))
     
     ;;;LOOP THROUGH LAT/LON TO GET CHANGES FOR EACH GRIDBOX
     do ilat=0,dimsizes(lats)-1
      Lat=lats(ilat)
      ;print(ilat+": "+Lat)
 
      do ilon=0,dimsizes(lons)-1
       Lon=lons(ilon)
       ;print(ilon+": "+Lon)
       
       ;print(ext(iYr,3,95))
       
  
       ;;;ONLY USE SNOW VALUES WHERE THERE ARE EXTREME VALUES
       ;;;i.e. ONLY USE SNOW VALUES WHERE NON-MISSING IN TEMP DATA
       ;print(dimsizes(ext_ind_nomiss(:,ilat,ilon)))
       ;print(dimsizes(ext(:,ilat,ilon)))
       
       ;print(.not.ismissing(ext(:,ilat,ilon)))
       
       idx = .not.ismissing(ext(:,ilat,ilon))
       
       ext_ind_nomiss(iYr,ilat,ilon) = ind(idx(0))	;indices that are non-missing in temp i.e. extremes
       
       ;;;replace missing value in an array with zeros
       ;ext_ind_nomiss@_FillValue = -2147483647
       ;if(all(ismissing(ext_ind_nomiss))) then
       ; ext_ind_nomiss(ind(ismissing(ext_ind_nomiss))) = 0
       ;end if
       
       ;n_miss = num(ext_ind_nomiss)
       ;print(n_miss)
       
       
       ;dsizes(iYr) = dimsizes(ext_ind_nomiss)
       ;print(ext_ind_nomiss)
       ;print(dsizes)
  
       ;if(.not.all(ismissing(ext_ind_nomiss))) then
   
        ;ext_nomiss = ext(ext_ind_nomiss,ilat,ilon)  
        ;len_ext = dimsizes(ext_nomiss)
        ;ext_3d(0:(len_ext)-1,ilat,ilon) = ext_nomiss
	
	;print(ext_nomiss)
      
        ;delete([/ext_nomiss/])
       ;end if  
       ;delete([/ext_ind_nomiss/])
  
      end do		;ends ilon loop
     end do		;ends ilat loop
     
;print(Yrs+" "+ext_ind_nomiss(iYr,:,:))
;print(Yrs+" "+dsizes(iYr))

    ;delete([/ext,ext_3d/])
    
 
   end do		;ends loop iYr
  end do		;ends loop iDat
 ;end do			;ends loop iSeas
 
 print("Ready to start plotting")
  
  ;print(ext_ind_nomiss)

;printVarSummary(ext)
  ;**********************************************************
  ;**********************Plot data***************************
  ;**********************************************************
  
;**********************************************************
;**********************Plot data***************************
;**********************************************************

;;;BELOW(COMMENTED OUT) IS FOR TIME SERIES XY PLOT
res			= True
res@gsnMaximize		= True
res@gsnDraw		= False
res@gsnFrame		= False

res@tmXTOn		= False
res@tmYROn		= False
res@tmEqualizeXYSizes	= True
res@trYMaxF 		= 92
res@trYMinF 		= 0
res@trXMinF		= min(xVals)-2
res@trXMaxF		= max(xVals)+2 
res@tmXBLabelJust	= "CenterRight"
res@tmXBLabelAngleF	= 90
res@tmXBLabelStride	= 10
res@tmXBMode		= "Explicit"
res@tmXBValues		= xVals
res@tmXBLabels		= (/"1950","1951","1952","1953","1954","1955","1956","1957","1958","1959",\
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

;res@xyLineColors	= (/"grey","steelblue1","seagreen","plum","tomato"/)

res@xyMarkLineMode = "Markers"
			  
;;;PLOT TEMPERATURES (as anomalies relative to 1950 - 1959)
;res@tiMainString	= "Extreme temperatures (relative to 1950-'79)"
plot			= gsn_csm_xy(wks,xVals,ext_ind_nomiss,res)


draw(plot)
frame(wks)

end
