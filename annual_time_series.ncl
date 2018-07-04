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
	  
Datasets = (/"CanESM2","CNRM-CM5","CSIRO-Mk3-6-0","inmcm4","MPI-ESM-MR"/)
;Seasons = (/"SON","DJF","MAM"/)
;ClimVars = (/"TXn","TNn"/)

Season = "SON"
;Data = "CSIRO-Mk3-6-0"

ext_temp_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)
var_ext_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)
mean_temp_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)
var_mean_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)
;excess_temp_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)
;excess_var_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)

;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "annual_scatter_excess_rsds_TXn_SON"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)
plot = new(3,graphic)			;create plot array

xVals = ispan(1,dimsizes(Years),1)
ext_ann_ave = new(dimsizes(Years),"float",-999.9)
var_ext_ann_ave = new(dimsizes(Years),"float",-999.9)
var_ann_ave = new(dimsizes(Years),"float",-999.9)

;;;LOOP THROUGH DATASETS
do iDat=0,dimsizes(Datasets)-1
 Data=Datasets(iDat)
 
   ;;;READ IN ANNUAL MEAN TEMP ANOMALIES

 MeanDataDir = "/srv/ccrc/data40/z5026024/data/CMIP5/anomalies/"
 MeanData = MeanDataDir+Data+"_TX_anoms_1950-2099_2.5x2.5_ann_mean_"+Season+".nc"
 MeanFile = addfile(MeanData,"r")
 ann_mean = MeanFile->TX_anoms(:,{42:67},{40:80})

;;;START LOOPING THROUGH ANNUAL FILES
do iYr=0,dimsizes(Years)-1
 Yrs=Years(iYr)
 ;print(iYr+": "+Yrs)
 
 ;***********************************************************
 ;;*********************Read-in input************************
 ;***********************************************************

 ;;;READ IN ANNUAL EXTREME TEMP DATA

 ExtDataDir = "/srv/ccrc/data40/z5026024/data/extremes_only_files/1950-2099/annual/"
 ExtData = ExtDataDir+Data+"_TXn_"+Yrs+"_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
 ExtFile = addfile(ExtData,"r")
 
 ext = ExtFile->extremes(:,{42:67},{40:80})		;USE REGIONAL BOX LAT RANGE 45:65 LON RANGE 50:80	
 lats = ext&lat
 lons = ext&lon
 
  ;;;READ IN ANNUAL MEAN TEMP ANOMALIES

; MeanDataDir = "/srv/ccrc/data40/z5026024/data/CMIP5/anomalies/"
; MeanData = MeanDataDir+Data+_TX_anoms_1950-2099_2.5x2.5_ann_mean_"+Season+".nc"
; MeanFile = addfile(MeanData,"r")
; mean = MeanFile->TX_anoms(:,{42:67},{40:80}))
 
 
  ;;;READ IN VARIABLE DATA

 VarDataDir = "/srv/ccrc/data04/z5026024/CMIP5/annual_data/"
 VarData = VarDataDir+"rsds_day_"+Data+"_"+Yrs+"_masked_2.5x2.5_"+Season+".nc"
 VarFile = addfile(VarData,"r")
 var = VarFile->rsds(:,{42:67},{40:80})
 
 
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

 ;ext_pooled_ave = dim_avg_n(ext_3d,(/1,2/))		;(unweighted) area average at each lat/lon grid point

 ext_ann_ave(iYr) = dim_avg_n_Wrap(ext_reg_ave,0)	;average of extreme temperatures per decade (pooled over grid boxes) 
 var_ext_ann_ave(iYr) = dim_avg_n_Wrap(var_ext_reg_ave,0)
 
 ;;;CALCULATE AVERAGE ANNUAL DATA FOR OTHER VARIABLES
 var_reg_ave = wgt_areaave(var,clat,1.0,0)
 var_ann_ave(iYr) = dim_avg_n_Wrap(var_reg_ave,0)
 
 ;print(var(0,:,:))

delete([/ext,ext_3d,var,var_ext_3d,ext_reg_ave,var_ext_reg_ave,var_reg_ave/])
 
end do		;ends looping through years

;;;TAKE AVERAGE FOR ANNUAL TEMP MEAN
mean_reg_ave = wgt_areaave(ann_mean,clat,1.0,0)
mean_ann_ave = mean_reg_ave

;;;CALCULATE CLIMATOLOGICAL AVERAGE FOR FIRST 30 YEARS
clim_ave_ext = avg(ext_ann_ave(0:29))		;years 1950 - 1979
;print(clim_ave_ext)
clim_var_ave = avg(var_ext_ann_ave(0:29))

clim_ave_mean = avg(mean_ann_ave(0:29))
clim_ave_var_mean = avg(var_ann_ave(0:29))

;;;CALCULATE ANOMALY OF EXTREMES i.e. annual average of extremes relative to 1950-1979 average
ext_ann_anom = ext_ann_ave - clim_ave_ext
var_ext_ann_anom = var_ext_ann_ave - clim_var_ave

;;;AND ANOMALY OF ANNUAL MEANS i.e. annual average of mean relative to 50-79
mean_ann_anom = mean_ann_ave - clim_ave_mean
mean_var_ann_anom = var_ann_ave - clim_ave_var_mean


;;;PUT ALL DATA IN ONE MULTI-DIMENSIONAL ARRAY FOR EACH VARIABLE

ext_temp_ts(iDat,:) = ext_ann_anom
mean_temp_ts(iDat,:) = mean_ann_anom

var_ext_ts(iDat,:) = var_ext_ann_anom
var_mean_ts(iDat,:) = mean_var_ann_anom


;delete([/ext,ext_3d,var,var_ext_3d/])

;excess_temp_ts(iDat,:) = ext_temp_ts(iDat,:) - mean_temp_ts(iDat,:)
;excess_var_ts(iDat,:) = var_ext_ts(iDat,:) - var_mean_ts(iDat,:)

end do			;;end loop iDat

excess_temp_ts = ext_temp_ts - mean_temp_ts
excess_var_ts = var_ext_ts - var_mean_ts


ext_max_temp = max(ext_temp_ts)
ext_min_temp = min(ext_temp_ts)
ext_max_var = max(var_ext_ts)
ext_min_var = min(var_ext_ts)

mean_max_temp = max(mean_temp_ts)
mean_min_temp = min(mean_temp_ts)
mean_max_var = max(var_mean_ts)
mean_min_var = min(var_mean_ts)


;print(max_var)


CanESM_ext = ext_temp_ts(0,:)
CNRM_ext = ext_temp_ts(1,:)
CSIRO_ext = ext_temp_ts(2,:)
inmcm_ext = ext_temp_ts(3,:)
MPI_ext = ext_temp_ts(4,:)

CanESM_mean = mean_temp_ts(0,:)
CNRM_mean = mean_temp_ts(1,:)
CSIRO_mean = mean_temp_ts(2,:)
inmcm_mean = mean_temp_ts(3,:)
MPI_mean = mean_temp_ts(4,:)

CanESM_excess = excess_temp_ts(0,:)
CNRM_excess = excess_temp_ts(1,:)

var_ext_CanESM = var_ext_ts(0,:)
var_ext_CNRM = var_ext_ts(1,:)
var_ext_CSIRO = var_ext_ts(2,:)
var_ext_inmcm = var_ext_ts(3,:)
var_ext_MPI = var_ext_ts(4,:)

var_mean_CanESM = var_mean_ts(0,:)
var_mean_CNRM = var_mean_ts(1,:)
var_mean_CSIRO = var_mean_ts(2,:)
var_mean_inmcm = var_mean_ts(3,:)
var_mean_MPI = var_mean_ts(4,:)

var_excess_CanESM = excess_var_ts(0,:)
var_excess_CNRM= excess_var_ts(1,:)



excess_max_temp = max(excess_temp_ts)
excess_min_temp = min(excess_temp_ts)
excess_max_var = max(excess_var_ts)
excess_min_var = min(excess_var_ts)


;;;CALCULATE REGRESSION LINE (LEAST SQUARES)
;y=mx+b
;m is the slope: rc returned from regline
;b in the y-intercept: rc@yave attribute of rc returned from regline

rc_CanESM = regline(var_excess_CanESM,CanESM_excess)
;;;;PUT REGRESSION LINE AND DATA INTO AN ARRAY
data_CanESM = new((/2,dimsizes(CanESM_excess)/),typeof(CanESM_excess))
data_CanESM(0,:) = CanESM_excess
data_CanESM(1,:) = rc_CanESM*(var_excess_CanESM-rc_CanESM@xave) + rc_CanESM@yave

rc_CNRM = regline(var_excess_CNRM,CNRM_excess)
data_CNRM = new((/2,dimsizes(CNRM_excess)/),typeof(CNRM_excess))
data_CNRM(0,:) = CNRM_excess
data_CNRM(1,:) = rc_CNRM*(var_excess_CNRM-rc_CNRM@xave) + rc_CNRM@yave

;print(data_CNRM)

;;;CALCULATE SPEARMAN'S RANK CORRELATION AND P-VALUE
spc_CanESM = spcorr(var_excess_CanESM,CanESM_excess)
spc_CNRM = spcorr(var_excess_CNRM,CNRM_excess)

;print(spc_CanESM)
;print(spc_CNRM)

siglvl = 0.01		;a-priori specified sig level
pr_CanESM = rtest(spc_CanESM,150,0)

if(pr_CanESM.lt.siglvl) then
 print("rtest is significant at the "+siglvl+" significance level")
else
 print("rtest is NOT significant at the "+siglvl+" significance level")
end if


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
res@trYMaxF 		= ext_max_temp+1
res@trYMinF 		= ext_min_temp-1
res@trXMinF		= min(xVals)-1
res@trXMaxF		= max(xVals)+1 
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

res@xyLineColors	= (/"grey","steelblue1","seagreen","plum","tomato"/)
			  
;;;PLOT TEMPERATURES (as anomalies relative to 1950 - 1959)
res@tiMainString	= "Extreme temperatures (relative to 1950-'79)"
plot(0)			= gsn_csm_xy(wks,xVals,var_mean_ts,res)

;;;PLOT SNOW COVER
res@trYMaxF 		= ext_max_var+1
res@trYMinF 		= ext_min_var-1
;res@tiMainString	= "Albedo (extreme temperature days only)"
res@tiMainString	= "DW Shortwave (extreme temperature days only)"
plot(1)			= gsn_csm_xy(wks,xVals,var_ext_ts,res)

delete(res)




;;;PLOT EXTREMES ONLY

res			= True
res@gsnMaximize		= True
res@gsnDraw		= False
res@gsnFrame		= False

res@gsnXRefLine		= 0.0
res@gsnYRefLine		= 0.0
res@gsnXRefLineDashPattern = 2
res@gsnYRefLineDashPattern = 2

res@tmEqualizeXYSizes	= True
res@tmXTOn		= False
res@tmYROn		= False

res@trYMaxF = ext_max_temp+1
res@trYMinF = ext_min_temp-1
res@trXMaxF = ext_max_var+1
res@trXMinF = ext_min_var-1

res@xyMarkLineMode = "Markers"
res@xyMarker = 16
res@xyMarkerSizeF = 14

res@xyMarkerColor = "grey"
;plot(0) = gsn_csm_xy(wks,var_ext_CanESM,CanESM_ext,res)

;res@xyMarkerColor = "steelblue1"
;dum = gsn_csm_xy(wks,var_ext_CNRM,CNRM_ext,res)

;overlay(plot(0),dum)

delete(res)
;delete(dum)



;;;PLOT MEANS ONLY

res			= True
res@gsnMaximize		= True
res@gsnDraw		= False
res@gsnFrame		= False

res@gsnXRefLine		= 0.0
res@gsnYRefLine		= 0.0
res@gsnXRefLineDashPattern = 2
res@gsnYRefLineDashPattern = 2

res@tmEqualizeXYSizes	= True
res@tmXTOn		= False
res@tmYROn		= False

res@trYMaxF = mean_max_temp+1
res@trYMinF = mean_min_temp-1
res@trXMaxF = mean_max_var+1
res@trXMinF = mean_min_var-1

res@xyMarkLineModes = (/"Markers","Lines"/)
res@xyMarker = 16
res@xyMarkerSizeF = 14

res@xyMarkerColor = "grey"
;plot(1) = gsn_csm_xy(wks,var_mean_CanESM,CanESM_mean,res)

;res@xyMarkerColor = "steelblue1"
;dum = gsn_csm_xy(wks,var_mean_CNRM,CNRM_mean,res)

;overlay(plot(1),dum)

delete(res)
;delete(dum)



;;;PLOT EXCESSES
res			= True
res@gsnMaximize		= True
res@gsnDraw		= False
res@gsnFrame		= False

res@gsnXRefLine		= 0.0
res@gsnYRefLine		= 0.0
res@gsnXRefLineDashPattern = 2
res@gsnYRefLineDashPattern = 2

res@tmEqualizeXYSizes	= True
res@tmXTOn		= False
res@tmYROn		= False

res@trYMaxF = excess_max_temp+1
res@trYMinF = excess_min_temp-1
res@trXMaxF = excess_max_var+1
res@trXMinF = excess_min_var-1

res@xyMarkLineModes = (/"Markers","Lines"/)
res@xyMarker = 16
res@xyMarkerSizeF = 14

res@xyMarkerColor = "grey"
res@xyLineColor = "grey"
res@xyLineThicknessF = 2
plot(2) = gsn_csm_xy(wks,var_excess_CanESM,data_CanESM,res)

res@xyMarkerColor = "steelblue1"
res@xyLineColor = "steelblue1"
dum = gsn_csm_xy(wks,var_excess_CNRM,data_CNRM,res)

overlay(plot(2),dum)


;mkres = True
;mkres@gsMarkerIndex = 16
;mkres@gsMarkerSizeF = 5

;mkres@gsMarkerColor = "steelblue1"
;dum1 = gsn_add_polymarker(wks,plot(2),var_CNRM,CNRM,mkres)

;mkres@gsMarkerColor = "seagreen"
;dum2 = gsn_add_polymarker(wks,plot(2),var_CSIRO,CSIRO,mkres)

;mkres@gsMarkerColor = "plum"
;dum3 = gsn_add_polymarker(wks,plot(2),var_inmcm,inmcm,mkres)

;mkres@gsMarkerColor = "tomato"
;dum4 = gsn_add_polymarker(wks,plot(2),var_MPI,MPI,mkres)




;;;Panel the plots
pres				= True
;pres@gsnPanelLabelBar		= False		;common label bar
pres@gsnFrame			= False		;don't advance frame yet
;pres@lbLabelFontHeightF	= 0.01
pres@gsnMaximize		= True		;Maximize plot in frame
;pres@pmLabelBarHeightF		= 0.05
;pres@lbLabelAutoStride		= True		;nice label bar labels
pres@gsnPanelOrientation	= "auto"
;pres@gsnPanelCenter  		= False
;pres@gsnPanelXWhiteSpacePercent= 5

pres@gsnPanelBottom = 0.10

pres@gsnPanelMainString		= "SON Tmax (cold tail)"
pres@gsnPanelMainFontHeightF	= 0.015

gsn_panel(wks,plot,(/2,2/),pres)		;2 rows, 1 column



;;;manually add legend
gsres = True
gsres@gsMarkerIndex = 16
gsres@gsMarkerSizeF = 6
gsres@txFontHeightF	= 0.01
gsres@txJust = "CenterLeft"
 
gsres@gsMarkerColor = "grey"
gsn_polymarker_ndc(wks,0.25,0.06,gsres)
gsn_text_ndc(wks,"CanESM2",0.26,0.06,gsres)

gsres@gsMarkerColor = "steelblue1"
gsn_polymarker_ndc(wks,0.35,0.06,gsres)
gsn_text_ndc(wks,"CNRM-CM5",0.36,0.06,gsres)

gsres@gsMarkerColor = "seagreen"
gsn_polymarker_ndc(wks,0.46,0.06,gsres)
gsn_text_ndc(wks,"CSIRO-Mk3-6-0",0.47,0.06,gsres)

gsres@gsMarkerColor = "plum"
gsn_polymarker_ndc(wks,0.60,0.06,gsres)
gsn_text_ndc(wks,"inmcm4",0.61,0.06,gsres)

gsres@gsMarkerColor = "tomato"
gsn_polymarker_ndc(wks,0.70,0.06,gsres)
gsn_text_ndc(wks,"MPI-ESM-MR",0.71,0.06,gsres)


;draw(plot)		;use for single plot only
frame(wks)

end



