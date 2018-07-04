load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Script to plot trend differences;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;for TXx, TXn, TNx and TNn;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin

;***********************************************************
;;*************Set up output/Read-in input******************
;***********************************************************

plotfile = "gridbox_15-61_TNn"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)

;;;READ IN TEMPERATURE DATA

TempDataDir = "/srv/ccrc/data04/z5026024/"
TempData = TempDataDir+"CSIRO-Mk3-6-0_TNn_1950-2014_LTREND_diff_masked_smoothed_EXTREMES_MAM.nc"
file1 = addfile(TempData,"r")
temp = file1->extremes(:,15,61)		;only uses one grid box (time,lat,lon), e.g. 16,61 (Kazakhstan)

;printVarSummary(temp)	;shows co-ordinates if using individual grid box!


;;;READ IN SNOW DATA

SnowDataDir = "/srv/ccrc/data04/z5026024/CMIP5/snow_cover_data/"
SnowData = SnowDataDir+"snc_day_CSIRO-Mk3-6-0_1950-2014_masked_MAM.nc"
file3 = addfile(SnowData,"r")
snow_p1 = file3->snc(:,15,61)

;time = file3 ->time
;printVarSummary(time)
;date = cd_calendar(time,0)
;printVarSummary(date)

;printVarSummary(snow_p1)

;SnowDataDir2 = "/srv/ccrc/data04/z5026024/CMIP5/snow_cover_data/"
;SnowData2 = SnowDataDir2+"snc_day_CSIRO-Mk3-6-0_1982-2014_MAM.nc"
;file4 = addfile(SnowData2,"r")
;snow_p1 = file4->snc	


;***********************************************************
;;***************Set up data/calculations*******************
;***********************************************************

;;;ONLY USE SNOW VALUES WHERE THERE ARE EXTREME VALUES
;;;i.e. ONLY USE SNOW VALUES WHERE NON-MISSING IN TEMP DATA

temp_nomiss = ind(.not.ismissing(temp))	;indices that are non-missing in temp i.e. extremes
;print(temp_missing)

snow_extreme_only = snow_p1(temp_nomiss)	;only indclude values for time steps with non-missing temp
;print(snow_extreme_only)

;;;how to test if the snow_extreme_only values are from same index as temp_missing ?!?

TEMP = temp(temp_nomiss)
SNOW = snow_extreme_only
 
print(TEMP)
;print(SNOW)


;***********************************************************
;;***********************Plot data**************************
;*********************************************************** 				

res = True

res@xyMarkLineMode = "Markers"

plot_ts = gsn_csm_xy(wks,SNOW,TEMP,res)	;plots snow cover against temperature

;Draw
;frame(wks)

end
