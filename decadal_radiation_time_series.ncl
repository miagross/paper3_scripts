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

plotfile = "decadal_extremes_radiation_TNn_SON"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)
plot = new(5,graphic)			;create plot array

xVals = ispan(1,dimsizes(Years),1)
ext_dec_ave = new(dimsizes(Years),"float",-999.9)
mean_dec_ave = new(dimsizes(Years),"float",-999.9)
DLW_ext_dec_ave = new(dimsizes(Years),"float",-999.9)
ULW_ext_dec_ave = new(dimsizes(Years),"float",-999.9)
DSW_ext_dec_ave = new(dimsizes(Years),"float",-999.9)
USW_ext_dec_ave = new(dimsizes(Years),"float",-999.9)
DLW_dec_ave = new(dimsizes(Years),"float",-999.9)
ULW_dec_ave = new(dimsizes(Years),"float",-999.9)
DSW_dec_ave = new(dimsizes(Years),"float",-999.9)
USW_dec_ave = new(dimsizes(Years),"float",-999.9)

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

 
 
 ;;;RADIATION DATA

DLWDataDir = "/srv/ccrc/data04/z5026024/CMIP5/radiation_data/decadal/"
DLWData = DLWDataDir+"rlds_day_CSIRO-Mk3-6-0_"+Yrs+"_masked_2.5x2.5_SON.nc"
DLWFile = addfile(DLWData,"r")

DLW	= DLWFile->rlds(:,{45:65},{50:80})		;downwelling longwave

ULWDataDir = "/srv/ccrc/data04/z5026024/CMIP5/radiation_data/decadal/"
ULWData = ULWDataDir+"rlus_day_CSIRO-Mk3-6-0_"+Yrs+"_masked_2.5x2.5_SON.nc"
ULWFile = addfile(ULWData,"r")

ULW	= ULWFile->rlus(:,{45:65},{50:80})		;upwelling longwave

DSWDataDir = "/srv/ccrc/data04/z5026024/CMIP5/radiation_data/decadal/"
DSWData = DSWDataDir+"rsds_day_CSIRO-Mk3-6-0_"+Yrs+"_masked_2.5x2.5_SON.nc"
DSWFile = addfile(DSWData,"r")

DSW	= DSWFile->rsds(:,{45:65},{50:80})		;downwelling shortwave


USWDataDir = "/srv/ccrc/data04/z5026024/CMIP5/radiation_data/decadal/"
USWData = USWDataDir+"rsus_day_CSIRO-Mk3-6-0_"+Yrs+"_masked_2.5x2.5_SON.nc"
USWFile = addfile(USWData,"r")

USW	= USWFile->rsus(:,{45:65},{50:80})		;upwelling shortwave


 ;***********************************************************
 ;;***************Set up data/calculations*******************
 ;***********************************************************

 ext_3d = new(dimsizes(ext),"float",-999.9)		;set-up empty array to store calculations
 DLW_ext_3d = new(dimsizes(DLW),"float",-999.9)
 ULW_ext_3d = new(dimsizes(ULW),"float",-999.9)
 DSW_ext_3d = new(dimsizes(DSW),"float",-999.9)
 USW_ext_3d = new(dimsizes(USW),"float",-999.9)
 
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
    DLW_extremes_only = DLW(ext_ind_nomiss,ilat,ilon)		;only indclude values for time steps with non-missing temp
    ULW_extremes_only = ULW(ext_ind_nomiss,ilat,ilon)
    DSW_extremes_only = DSW(ext_ind_nomiss,ilat,ilon)
    USW_extremes_only = USW(ext_ind_nomiss,ilat,ilon)
    len_ext = dimsizes(ext_nomiss)
    ext_3d(0:(len_ext)-1,ilat,ilon) = ext_nomiss
    DLW_ext_3d(0:len_ext-1,ilat,ilon) = DLW_extremes_only
    ULW_ext_3d(0:len_ext-1,ilat,ilon) = ULW_extremes_only
    DSW_ext_3d(0:len_ext-1,ilat,ilon) = DSW_extremes_only
    USW_ext_3d(0:len_ext-1,ilat,ilon) = USW_extremes_only
      
    delete([/ext_nomiss,DLW_extremes_only,ULW_extremes_only,DSW_extremes_only,USW_extremes_only/])
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
 DLW_ext_reg_ave = wgt_areaave(DLW_ext_3d,clat,1.0,0)
 ULW_ext_reg_ave = wgt_areaave(ULW_ext_3d,clat,1.0,0)
 DSW_ext_reg_ave = wgt_areaave(DSW_ext_3d,clat,1.0,0)
 USW_ext_reg_ave = wgt_areaave(USW_ext_3d,clat,1.0,0)
 DLW_reg_ave = wgt_areaave(DLW,clat,1.0,0)
 ULW_reg_ave = wgt_areaave(ULW,clat,1.0,0)
 DSW_reg_ave = wgt_areaave(DSW,clat,1.0,0)
 USW_reg_ave = wgt_areaave(USW,clat,1.0,0)
 
 ext_dec_ave(iYr) = dim_avg_n_Wrap(ext_reg_ave,0)	;average of extreme temperatures per decade (pooled over grid boxes) 
 mean_dec_ave(iYr) = dim_avg_n_Wrap(mean_reg_ave,0)
 DLW_ext_dec_ave(iYr) = dim_avg_n_Wrap(DLW_ext_reg_ave,0)
 ULW_ext_dec_ave(iYr) = dim_avg_n_Wrap(ULW_ext_reg_ave,0)
 DSW_ext_dec_ave(iYr) = dim_avg_n_Wrap(DSW_ext_reg_ave,0)
 USW_ext_dec_ave(iYr) = dim_avg_n_Wrap(USW_ext_reg_ave,0)
 DLW_dec_ave(iYr) = dim_avg_n_Wrap(DLW_reg_ave,0)
 ULW_dec_ave(iYr) = dim_avg_n_Wrap(ULW_reg_ave,0)
 DSW_dec_ave(iYr) = dim_avg_n_Wrap(DSW_reg_ave,0)
 USW_dec_ave(iYr) = dim_avg_n_Wrap(USW_reg_ave,0)

 
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
DLW_excess = DLW_ext_dec_ave - DLW_dec_ave
ULW_excess = ULW_ext_dec_ave - ULW_dec_ave
DSW_excess = DSW_ext_dec_ave - DSW_dec_ave
USW_excess = USW_ext_dec_ave - USW_dec_ave

temps = new((/3,dimsizes(Years)/),float)
temps(0,:) = ext_dec_anom
temps(1,:) = mean_dec_anom
temps(2,:) = excess_temps

DLW_ts = new((/3,dimsizes(Years)/),float)
DLW_ts(0,:) = DLW_ext_dec_ave
DLW_ts(1,:) = DLW_dec_ave
DLW_ts(2,:) = DLW_excess

ULW_ts = new((/3,dimsizes(Years)/),float)
ULW_ts(0,:) = ULW_ext_dec_ave
ULW_ts(1,:) = ULW_dec_ave
ULW_ts(2,:) = ULW_excess

DSW_ts = new((/3,dimsizes(Years)/),float)
DSW_ts(0,:) = DSW_ext_dec_ave
DSW_ts(1,:) = DSW_dec_ave
DSW_ts(2,:) = DSW_excess

USW_ts = new((/3,dimsizes(Years)/),float)
USW_ts(0,:) = USW_ext_dec_ave
USW_ts(1,:) = USW_dec_ave
USW_ts(2,:) = USW_excess

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
plot(4)			= gsn_csm_xy(wks,xVals,temps,res)

;;;PLOT DLW
res@tiMainString	= "Downwelling longwave radiation"
plot(0)			= gsn_csm_xy(wks,xVals,DLW_ts,res)

;;;PLOT ULW
res@tiMainString	= "Upwelling longwave radiation"			
plot(1)			= gsn_csm_xy(wks,xVals,ULW_ts,res)

;;;PLOT DSW
res@tiMainString	= "Downwelling shortwave radiation"			
plot(2)			= gsn_csm_xy(wks,xVals,DSW_ts,res)

;;;PLOT USW
res@tiMainString	= "Upwelling shortwave radiation"			
plot(3)			= gsn_csm_xy(wks,xVals,USW_ts,res)

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

gsn_panel(wks,plot,(/3,2/),pres)		;2 rows, 1 column

;;;manually add a legend
gsres = True
gsres@txFontHeightF = 0.01
gsres@gsLineThicknessF = 1
gsres@txJust = "CenterLeft"
gsres@gsLineThicknessF = 3

gsres@gsLineColor = "tomato"
gsres@gsLineDashPattern = 2
gsn_polyline_ndc(wks,(/0.78,0.83/),(/0.6,0.6/),gsres)
gsn_text_ndc(wks,"Extremes",0.84,0.6,gsres)

gsres@gsLineColor = "seagreen"
gsres@gsLineDashPattern = 14
gsn_polyline_ndc(wks,(/0.78,0.83/),(/0.55,0.55/),gsres)
gsn_text_ndc(wks,"Mean",0.84,0.55,gsres)

gsres@gsLineColor = "steelblue1"
gsres@gsLineDashPattern = 0
gsn_polyline_ndc(wks,(/0.78,0.83/),(/0.5,0.5/),gsres)
gsn_text_ndc(wks,"Excesses",0.84,0.5,gsres)

;draw(plot)		;use for single plot only
frame(wks)

end
