load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Script to get wap variable and plot subsidence;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

begin 

Data = "CSIRO-Mk3-6-0"
Season = "SON"
ClimVar = "TXn"

;***********************************************************
;;******************READ IN INPUT FILES*********************
;***********************************************************

  ;;;READ IN TEMPERATURE DATA; EXTREMES

  ExtDataDir = "/srv/ccrc/data40/z5026024/data/extremes_only_files/future_analysis/"
  ExtData = ExtDataDir+Data+"_"+ClimVar+"_1950-1979_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  file1 = addfile(ExtData,"r")
  ext_p1 = file1->extremes
  ;lats = ext_p1&lat
  ;lons = ext_p1&lon

  ;print(lats)
  ;printVarSummary(temp_p1)	;shows co-ordinates if using individual grid box!

  ExtDataDir2 = "/srv/ccrc/data40/z5026024/data/extremes_only_files/future_analysis/"
  ExtData2 = ExtDataDir2+Data+"_"+ClimVar+"_2070-2099_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  file2 = addfile(ExtData2,"r")
  ext_p2 = file2->extremes


;;;WAP VARIABLE

wapDir = "/srv/ccrc/data04/z5026024/CMIP5/variables_data/"
wapData = wapDir+"wap_day_"+Data+"_1950-1979_2.5x2.5_"+Season+".nc"

file3 = addfile(wapData,"r")
wap_p1 = file3->wap(:,1:1,:,:)		;850 hPa (2nd dimension)
;plev = wap&plev				;850 hPa

wapData2 = wapDir+"wap_day_"+Data+"_2070-2099_2.5x2.5_"+Season+".nc"
file4 = addfile(wapData2,"r"0
wap_p2 = file4->wap(:,1:1,:,:)

;print(plev)
;printVarSummary(wap)

end
