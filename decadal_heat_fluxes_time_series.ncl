load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;Script to plot time series of temperature extremes per decade;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin

;ClimVars = (/"TXn","TNn"/)

Years = (/"1950-1959","1960-1969","1970-1979","1980-1989","1990-1999","2000-2009","2010-2019","2020-2029",\
         "2030-2039","2040-2049","2050-2059","2060-2069","2070-2079","2080-2089","2090-2099"/)

;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "decadal_extremes_heat_fluxes_TNn_SON"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)
plot = new(4,graphic)			;create plot array

xVals = ispan(1,dimsizes(Years),1)
ext_dec_ave = new(dimsizes(Years),"float",-999.9)
mean_dec_ave = new(dimsizes(Years),"float",-999.9)
Qe_ext_dec_ave = new(dimsizes(Years),"float",-999.9)
Qh_ext_dec_ave = new(dimsizes(Years),"float",-999.9)
EF_ext_dec_ave = new(dimsizes(Years),"float",-999.9)
Qe_dec_ave = new(dimsizes(Years),"float",-999.9)
Qh_dec_ave = new(dimsizes(Years),"float",-999.9)
EF_dec_ave = new(dimsizes(Years),"float",-999.9)

;;;START LOOPING THROUGH DECADAL FILES
do iYr=0,dimsizes(Years)-1
 Yrs=Years(iYr)
 ;print(iYr+": "+Yrs)

 ;***********************************************************
 ;;*********************Read-in input************************
 ;***********************************************************

 ;;;READ IN DECADAL EXTREME TEMP DATA

 ExtDataDir = "/srv/ccrc/data04/z5026024/extremes_only_files/1950-2100/"
 ExtData = ExtDataDir+"CSIRO-Mk3-6-0_TNn_"+Yrs+"_masked_EXTREMES_ONLY_2.5x2.5_SON.nc"
 ExtFile = addfile(ExtData,"r")
 
 ext = ExtFile->extremes(:,{45:65},{50:80})		;USE REGIONAL BOX LAT RANGE 45:65 LON RANGE 50:80	
 lats = ext&lat
 lons = ext&lon
 
 
 ;;;READ IN ANNUAL MEAN TEMP ANOMALIES

 MeanDataDir = "/srv/ccrc/data04/z5026024/CMIP5/2.5x2.5_grid_temp_data/"
 MeanData = MeanDataDir+"v3_CSIRO-Mk3-6-0_TN_anoms_"+Yrs+"_masked_2.5x2.5_ann_mean_SON.nc"
 MeanFile = addfile(MeanData,"r")
 mean = MeanFile->TN_anoms(:,{45:65},{50:80})

 
 
 ;;;HEAT FLUX DATA

 QeDataDir = "/srv/ccrc/data04/z5026024/CMIP5/heat_flux_data/hfls/decadal/"
 QeData = QeDataDir+"hfls_day_CSIRO-Mk3-6-0_"+Yrs+"_masked_2.5x2.5_SON.nc"
 QeFile = addfile(QeData,"r")

 Qe	= QeFile->hfls(:,{45:65},{50:80})		;latent heat flux

 QhDataDir = "/srv/ccrc/data04/z5026024/CMIP5/heat_flux_data/hfss/decadal/"
 QhData = QhDataDir+"hfss_day_CSIRO-Mk3-6-0_"+Yrs+"_masked_2.5x2.5_SON.nc"
 QhFile = addfile(QhData,"r")

 Qh	= QhFile->hfss(:,{45:65},{50:80})		;sensible heat flux

 ;***********************************************************
 ;;***************Set up data/calculations*******************
 ;***********************************************************

 ;;;EVAPORATIVE FRACTION; EF = Qe/(Qe+Qh)
 EF = Qe/(Qe+Qh)

 ext_3d = new(dimsizes(ext),"float",-999.9)		;set-up empty array to store calculations
 Qe_ext_3d = new(dimsizes(Qe),"float",-999.9)
 Qh_ext_3d = new(dimsizes(Qh),"float",-999.9)
 EF_ext_3d = new(dimsizes(EF),"float",-999.9)

 
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
    Qe_extremes_only = Qe(ext_ind_nomiss,ilat,ilon)		;only indclude values for time steps with non-missing temp
    Qh_extremes_only = Qh(ext_ind_nomiss,ilat,ilon)
    EF_extremes_only = EF(ext_ind_nomiss,ilat,ilon)
    len_ext = dimsizes(ext_nomiss)
    ext_3d(0:(len_ext)-1,ilat,ilon) = ext_nomiss
    Qe_ext_3d(0:len_ext-1,ilat,ilon) = Qe_extremes_only
    Qh_ext_3d(0:len_ext-1,ilat,ilon) = Qh_extremes_only
    EF_ext_3d(0:len_ext-1,ilat,ilon) = EF_extremes_only

      
    delete([/ext_nomiss,Qe_extremes_only,Qh_extremes_only,EF_extremes_only/])
   end if  
   delete([/ext_ind_nomiss/])
  
  end do		;ends ilon loop
 end do		;ends ilat loop


 ;;;TAKE AVERAGE FOR EACH DECADE FROM AREA-AVERAGED REGION
 
 ;;;calculate regional average (area-weighted average for selected region)
 rad = 4.0*atan(1.0)/180.0
 lat = lats
 clat = cos(lat*rad)
 
 ext_reg_ave = wgt_areaave(ext_3d,clat,1.0,0)
 mean_reg_ave = wgt_areaave(mean,clat,1.0,0)
 Qe_ext_reg_ave = wgt_areaave(Qe_ext_3d,clat,1.0,0)
 Qh_ext_reg_ave = wgt_areaave(Qh_ext_3d,clat,1.0,0)
 EF_ext_reg_ave = wgt_areaave(EF_ext_3d,clat,1.0,0)
 Qe_reg_ave = wgt_areaave(Qe,clat,1.0,0)
 Qh_reg_ave = wgt_areaave(Qh,clat,1.0,0)
 EF_reg_ave = wgt_areaave(EF,clat,1.0,0)
 
 ext_dec_ave(iYr) = dim_avg_n_Wrap(ext_reg_ave,0)	;average of extreme temperatures per decade (pooled over grid boxes) 
 mean_dec_ave(iYr) = dim_avg_n_Wrap(mean_reg_ave,0)
 Qe_ext_dec_ave(iYr) = dim_avg_n_Wrap(Qe_ext_reg_ave,0)
 Qh_ext_dec_ave(iYr) = dim_avg_n_Wrap(Qh_ext_reg_ave,0)
 EF_ext_dec_ave(iYr) = dim_avg_n_Wrap(EF_ext_reg_ave,0)
 Qe_dec_ave(iYr) = dim_avg_n_Wrap(Qe_reg_ave,0)
 Qh_dec_ave(iYr) = dim_avg_n_Wrap(Qh_reg_ave,0)
 EF_dec_ave(iYr) = dim_avg_n_Wrap(EF_reg_ave,0)

 
end do		;ends looping through years

;print(snow_ext_dec_ave)

;;;CALCULATE AVERAGE FOR FIRST 30 YEARS
clim_ave_ext = avg(ext_dec_ave(0:2))
clim_ave_mean = avg(mean_dec_ave(0:2))
;print(clim_ave_ext)

;;;CALCULATE ANOMALY OF EXTREMES i.e. decadal average relative to 1950-1979 average
ext_dec_anom = ext_dec_ave - clim_ave_ext
mean_dec_anom = mean_dec_ave - clim_ave_mean

;;TAKE DIFFERENCE IN DECADAL ANOMALIES TO GET "EXCESS" TEMPS
excess_temps = ext_dec_anom - mean_dec_anom
;print(excess_temps)
Qe_excess = Qe_ext_dec_ave - Qe_dec_ave
Qh_excess = Qh_ext_dec_ave - Qh_dec_ave
EF_excess = EF_ext_dec_ave - EF_dec_ave

temps = new((/3,dimsizes(Years)/),float)
temps(0,:) = ext_dec_anom
temps(1,:) = mean_dec_anom
temps(2,:) = excess_temps

Qe_ts = new((/3,dimsizes(Years)/),float)
Qe_ts(0,:) = Qe_ext_dec_ave
Qe_ts(1,:) = Qe_dec_ave
Qe_ts(2,:) = Qe_excess

Qh_ts = new((/3,dimsizes(Years)/),float)
Qh_ts(0,:) = Qh_ext_dec_ave
Qh_ts(1,:) = Qh_dec_ave
Qh_ts(2,:) = Qh_excess

EF_ts = new((/3,dimsizes(Years)/),float)
EF_ts(0,:) = EF_ext_dec_ave
EF_ts(1,:) = EF_dec_ave
EF_ts(2,:) = EF_excess


;**********************************************************
;**********************Plot data***************************
;**********************************************************

res			= True
res@gsnMaximize		= True
res@gsnDraw		= False
res@gsnFrame		= False

res@tmEqualizeXYSizes	= True
res@trXMinF		= min(xVals)-1
res@trXMaxF		= max(xVals)+1 
res@tmXBLabelJust	= "CenterRight"
res@tmXBLabelAngleF	= 90
res@tmXBLabelStride	= 2
res@tmXBMode		= "Explicit"
res@tmXBValues		= xVals
res@tmXBLabels		= (/"1950-'59","1960-'69","1970-'79","1980-'89","1990-'99","2000-'09","2010-'19","2020-29'","2030-'39",\
			   "2040-'49","2050-'59","2060-'69","2070-'79","2080-'89","2090-'99"/)
			   
res@xyLineColors	= (/"tomato","seagreen","steelblue1"/)			;extremes, mean, excesses
res@xyDashPatterns	= (/14,16,0/)
res@xyLineThicknesses 	= (/2.5,2.5,2.5/)

;;;PLOT TEMPERATURES (as anomalies relative to 1950 - 1959)
res@tiMainString	= "Temperature anomalies (relative to 1950-'79)"
plot(3)			= gsn_csm_xy(wks,xVals,temps,res)

;;;PLOT Qe
res@tiMainString	= "Latent heat flux (W/m^2)"
plot(0)			= gsn_csm_xy(wks,xVals,Qe_ts,res)

;;;PLOT Qh
res@tiMainString	= "Sensible heat flux (W/m^2)"			
plot(1)			= gsn_csm_xy(wks,xVals,Qh_ts,res)

;;;PLOT EF
res@tiMainString	= "Evaporative fraction"			
plot(2)			= gsn_csm_xy(wks,xVals,EF_ts,res)


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
pres@gsnPanelYWhiteSpacePercent = 5

pres@gsnPanelMainString		= "SON Tmin (cold tail)"
pres@gsnPanelMainFontHeightF	= 0.015

gsn_panel(wks,plot,(/2,2/),pres)		;2 rows, 1 column

;;;manually add a legend
gsres = True
gsres@txFontHeightF = 0.01
gsres@gsLineThicknessF = 1
gsres@txJust = "CenterLeft"
gsres@gsLineThicknessF = 3

gsres@gsLineColor = "tomato"
gsres@gsLineDashPattern = 2
gsn_polyline_ndc(wks,(/0.30,0.35/),(/0.48,0.48/),gsres)
gsn_text_ndc(wks,"Extremes",0.36,0.48,gsres)

gsres@gsLineColor = "seagreen"
gsres@gsLineDashPattern = 14
gsn_polyline_ndc(wks,(/0.45,0.50/),(/0.48,0.48/),gsres)
gsn_text_ndc(wks,"Mean",0.51,0.48,gsres)

gsres@gsLineColor = "steelblue1"
gsres@gsLineDashPattern = 0
gsn_polyline_ndc(wks,(/0.60,0.65/),(/0.48,0.48/),gsres)
gsn_text_ndc(wks,"Excesses",0.66,0.48,gsres)

;draw(plot)		;use for single plot only
frame(wks)

end
