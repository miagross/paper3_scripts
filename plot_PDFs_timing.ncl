load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;Script to plot stime series of temperature extremes per year;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin

;;;FOR EUR, USE (:,{47:70},{45:100})
;;;FOR NORTH AMERICA, USE (:,{47:70},{-125:-95})

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
Season = "SON"
ClimVars = (/"tas_MIN"/)

xVals = ispan(1,dimsizes(Years),1)

ext_ind_nomiss = new((/dimsizes(Years),9,22/),"float",-999.9)
;ext_ind_nomiss = new((/dimsizes(Years),2,2/),"float",-999.9)

;print(dimsizes(Years))

;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "pdfs_NA_extremes_timing_"+Season
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)

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

  ExtDataDir = "/srv/ccrc/data01/z5026024/extremes_only_files/future_tas/annual_exceedances/"
  ExtData = ExtDataDir+Data+"_"+ClimVars+"_"+Yrs+"_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  ExtFile = addfile(ExtData,"r")
 
  ext = ExtFile->extremes(:,{47:70},{-125:-95})
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
    ext_ind_nomiss(iYr,ilat,ilon) = maxind(ext(:,ilat,ilon))	;indices that are non-missing in temp i.e. extremes
       
    ;delete([/ext_ind_nomiss/])
  
   end do		;ends ilon loop
  end do		;ends ilat loop
     
  ;print(Yrs+" "+ext_ind_nomiss(iYr,:,:))
  ;print(Yrs+" "+ext_ind_nomiss(iYr))

  ;delete([/ext/])
    
  ;print("Finished looping through lats/lons for year "+Yrs)
 
 end do							;;;;ends loop iYr
   
 print("Done with looping through years, go to next model")
 
 ;;;CALCULATE AREA-WEIGHTED AVERAGE OF REGION
 
 p1_ind = ext_ind_nomiss(0:29,:,:)			;first 30 years 1950-1979
 p2_ind = ext_ind_nomiss(120:149,:,:)			;last 30 years 2070-2099
 
 ;;;CALCULATE WEIGHTED AREA-AVERAGE
 rad = 4.0*atan(1.0)/180.0
 lat = lats
 clat = cos(lat*rad)
  
 p1_area_ave = wgt_areaave(p1_ind,clat,1.0,0)
 p2_area_ave = wgt_areaave(p2_ind,clat,1.0,0)
 
 ;printVarSummary(p1_area_ave)
 
 ;opt		= True
 ;opt@bin_min	= 2
 ;opt@bin_max	= 20
 
 p1_pdf = pdfx(p1_area_ave,0,False)		;0 is default bin size 25
 p2_pdf = pdfx(p2_area_ave,0,False)
 
 
 ;;;;;;;PREPARE DATA FOR PLOTTING
 
 nVar	= 2		;;;2 time periods i.e. 2 PDFs
 nBin	= p1_pdf@nbins	;;;retrive number of bins
 
 xx	= new((/nVar,nBin/),typeof(p1_pdf))
 
 xx(0,:) = p1_pdf@bin_center	;;assign appropriate "x" axis values
 xx(1,:) = p2_pdf@bin_center
 
 yy	= new((/nVar,nBin/),typeof(p1_pdf))
 
 yy(0,:) = (/p1_pdf/)*0.01	;;conver $ to absolute
 yy(1,:) = (/p2_pdf/)*0.01
 
 
   
 ;;***********************************************************
 ;;***********************Plot PDFs***************************
 ;;*********************************************************** 				

 ;;;PLOT PDFs of BOTH TIME PERIODS

 res				= True
 res@gsnMaximize 		= True 			;Maximize plot in frame
 res@gsnDraw			= False			;Don't draw plots
 res@gsnFrame			= False			;Don't advance frame			
 
 res@tmYLAutoPrecision		= False			;no auto precision
 res@tmYLPrecision		= 2			;set the precision
 res@tmYLLabelFontHeightF	= 0.04     
 res@tmEqualizeXYSizes		= True
 res@tmLabelAutoStride		= True
 
 res@xyDashPattern		= 0
 res@xyLineThicknessF		= 2
 res@xyLineColors		= (/"red","blue"/)
 res@gsnXRefLineDashPattern	= 2
 res@gsnXRefLine		= 0.0
  
 plot(iDat) = gsn_csm_xy(wks,xx,yy,res)		;extreme temperature changes
  
end do			;ends loop iDat

print("Finished looping through datasets, panel the plots")


;;;;;;;;;;;;;;;;;;;;;PANEL THE PLOTS;;;;;;;;;;;;;;;;;;;;;;;;

pres				= True
pres@gsnFrame			= False			;don't advance frame yet
pres@gsnMaximize		= True			;maximize plot in frame
pres@gsnPanelCenter		= False			;right-bounded
pres@gsnPaperOrientation	= "portrait"
 
pres@gsnPanelYWhiteSpacePercent = 5
pres@gsnPanelXWhiteSpacePercent = 5

pres@gsnPanelTop = 0.95
pres@gsnPanelBottom = 0.05
 
gsn_panel(wks,plot,(/5,1/),pres)

;;;add text to plot
txpres			= True
txpres@txFontThicknessF	= 1.4

txpres@txJust		= "CenterCenter"
txpres@txFontHeightF	= 0.015
gsn_text_ndc(wks,"PDFs of timing of extremes for NA ("+Season+") - anomalies",0.5,0.97,txpres)

txpres@txJust		= "topLeft"
txpres@txFontHeightF	= 0.012
gsn_text_ndc(wks,"CanESM2",0.27,0.85,txpres)
gsn_text_ndc(wks,"CNRM-CM5",0.27,0.68,txpres)
gsn_text_ndc(wks,"CSIRO-Mk3-6-0",0.27,0.52,txpres)
gsn_text_ndc(wks,"inmcm4",0.27,0.33,txpres)
gsn_text_ndc(wks,"MPI-ESM-MR",0.27,0.16,txpres)

txpres@txJust		= "CenterCenter"
txpres@txFontHeightF 	= 0.01
txpres@txFontColor	= "Red"
gsn_text_ndc(wks,"Past period (1950-1979)",0.30,0.05,txpres)
txpres@txFontColor	= "Blue"
gsn_text_ndc(wks,"Future period (2070-2099)",0.70,0.05,txpres)


;draw(plot)
frame(wks)

end
