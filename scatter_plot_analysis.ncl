load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;Script to calculate pattern correlations;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin

Datasets = (/"CanESM2","CNRM-CM5","CSIRO-Mk3-6-0","inmcm4","MPI-ESM-MR"/)
Seasons = (/"SON","DJF","MAM"/)
ClimVars = (/"TXn","TNn"/)
;ClimVar = "TNn"
;Season = "MAM"

plotfile = "scatter_plot_rsds_cold_tails"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)
;plot = new(1,graphic)

plot_all = new(2*3,graphic)		;;3 seasons, 2 temp variables
dum1_all = new(2*3,graphic)
dum2_all = new(2*3,graphic)
dum3_all = new(2*3,graphic)
dum4_all = new(2*3,graphic)


Excess_Changes = new((/dimsizes(Datasets),10,16/),"float",-999.9)
Excess_Var = new((/dimsizes(Datasets),10,16/),"float",-999.9)

;max_temp = new((/2*3/),"float",-999.9)

;;;LOOP THROUGH CLIMATE VARIABLES AND SEASONS
do iClimVar=0,dimsizes(ClimVars)-1
 ClimVar = ClimVars(iClimVar)
 
 ;Excess_Changes = new((/dimsizes(Datasets),10,16/),"float",-999.9)
 ;Excess_Var = new((/dimsizes(Datasets),10,16/),"float",-999.9)

 plot_iClimVar = new(3,graphic)
 dum1 = new(3,graphic)
 dum2 = new(3,graphic)
 dum3 = new(3,graphic)
 dum4 = new(3,graphic)
 
 do iSeas=0,dimsizes(Seasons)-1
  Season = Seasons(iSeas)

  ;;;LOOP THROUGH MODELS
  do iDat=0,dimsizes(Datasets)-1
   Data=Datasets(iDat)

;***********************************************************
;;**********************Read-in input***********************
;***********************************************************

  ;;;READ IN TEMPERATURE DATA; EXTREMES

  ExtDataDir = "/srv/ccrc/data40/z5026024/data/extremes_only_files/future_analysis/"
  ExtData = ExtDataDir+Data+"_"+ClimVar+"_1950-1979_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  file1 = addfile(ExtData,"r")
  ext_p1 = file1->extremes(:,{42:67},{40:80})
  lats = ext_p1&lat
  lons = ext_p1&lon

  ;print(lats)
  ;printVarSummary(temp_p1)	;shows co-ordinates if using individual grid box!

  ExtDataDir2 = "/srv/ccrc/data40/z5026024/data/extremes_only_files/future_analysis/"
  ExtData2 = ExtDataDir2+Data+"_"+ClimVar+"_2070-2099_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
  file2 = addfile(ExtData2,"r")
  ext_p2 = file2->extremes(:,{42:67},{40:80})


  ;;;DAILY TEMP ANOMALIES

   TempDataDir = "/srv/ccrc/data40/z5026024/data/CMIP5/anomalies/seasonal/split_yrs_future_analysis/"
   TempData = TempDataDir+Data+"_TN_anoms_1950-1979_2.5x2.5_"+Season+".nc"
   file3 = addfile(TempData,"r")
   Temp_p1 = file3->TN_anoms(:,{42:67},{40:80})

   TempDataDir2 = "/srv/ccrc/data40/z5026024/data/CMIP5/anomalies/seasonal/split_yrs_future_analysis/"
   TempData2 = TempDataDir2+Data+"_TN_anoms_2070-2099_2.5x2.5_"+Season+".nc"
   file4 = addfile(TempData2,"r")
   Temp_p2 = file4->TN_anoms(:,{42:67},{40:80})



;;;READ IN SNOW DATA

VarDataDir = "/srv/ccrc/data04/z5026024/CMIP5/variables_data/"
VarData = VarDataDir+"rsds_day_"+Data+"_1950-1979_masked_2.5x2.5_"+Season+".nc"
file5 = addfile(VarData,"r")
var_p1 = file5->rsds(:,{42:67},{40:80})

;printVarSummary(snow_p1)

VarDataDir2 = "/srv/ccrc/data04/z5026024/CMIP5/variables_data/"
VarData2 = VarDataDir2+"rsds_day_"+Data+"_2070-2099_masked_2.5x2.5_"+Season+".nc"
file6 = addfile(VarData2,"r")
var_p2 = file6->rsds(:,{42:67},{40:80})


;***********************************************************
;;***************Set up data/calculations*******************
;***********************************************************

ext_p1_3d = new(dimsizes(ext_p1),"float",-999.9)		;set-up empty array to store calculations
;print(dimsizes(ext_p1_3d))
ext_p2_3d = new(dimsizes(ext_p2),"float",-999.9)
var_p1_3d = new(dimsizes(var_p1),"float",-999.9)
var_p2_3d = new(dimsizes(var_p2),"float",-999.9)

;;;LOOP THROUGH LAT/LON TO GET CHANGES FOR EACH GRIDBOX

do ilat=0,dimsizes(lats)-1
 Lat=lats(ilat)
 ;print(ilat+": "+Lat)
 
 do ilon=0,dimsizes(lons)-1
  Lon=lons(ilon)
  ;print(ilon+": "+Lon)
  
  ;;;ONLY USE SNOW VALUES WHERE THERE ARE EXTREME VALUES
  ;;;i.e. ONLY USE SNOW VALUES WHERE NON-MISSING IN TEMP DATA

  ext_p1_ind_nomiss = ind(.not.ismissing(ext_p1(:,ilat,ilon)))		;indices that are non-missing in temp i.e. extremes
  ;print(ext_p1_ind_nomiss)
  ;print(ilat+"  "+ilon)
  
  if(.not.all(ismissing(ext_p1_ind_nomiss))) then
   
   ext_p1_nomiss = ext_p1(ext_p1_ind_nomiss,ilat,ilon)  
   var_p1_extremes_only = var_p1(ext_p1_ind_nomiss,ilat,ilon)		;only indclude values for time steps with non-missing temp
   len_ext_p1 = dimsizes(ext_p1_nomiss)
   ext_p1_3d(0:(len_ext_p1)-1,ilat,ilon) = ext_p1_nomiss
   var_p1_3d(0:len_ext_p1-1,ilat,ilon) = var_p1_extremes_only
   
   delete([/ext_p1_nomiss,var_p1_extremes_only/])
  end if
  
  delete([/ext_p1_ind_nomiss/])
  
  ext_p2_ind_nomiss = ind(.not.ismissing(ext_p2(:,ilat,ilon)))
     
  if(.not.all(ismissing(ext_p2_ind_nomiss))) then   
   
   ext_p2_nomiss = ext_p2(ext_p2_ind_nomiss,ilat,ilon)  
   var_p2_extremes_only = var_p2(ext_p2_ind_nomiss,ilat,ilon)
   len_ext_p2 = dimsizes(ext_p2_nomiss)   
   ext_p2_3d(0:len_ext_p2-1,ilat,ilon) = ext_p2_nomiss
   var_p2_3d(0:len_ext_p2-1,ilat,ilon) = var_p2_extremes_only
   
   delete([/ext_p2_nomiss,var_p2_extremes_only/])
  end if
  
  delete([/ext_p2_ind_nomiss/])
  
 end do		;ends ilon loop
end do		;ends ilat loop


;;;CALCULATE AVERAGE OVER P1 AND P2, AND THEN P2 - P1 FOR CHANGES
ext_p1_ave = dim_avg_n_Wrap(ext_p1_3d,0)		;average of time at each lat/lon grid point
ext_p2_ave = dim_avg_n_Wrap(ext_p2_3d,0)
;print(ext_p1_ave)

mean_p1_ave = dim_avg_n_Wrap(Temp_p1,0)
mean_p2_ave = dim_avg_n_Wrap(Temp_p2,0)

var_ext_p1_ave = dim_avg_n_Wrap(var_p1_3d,0)
var_ext_p2_ave = dim_avg_n_Wrap(var_p2_3d,0)

var_p1_ave = dim_avg_n_Wrap(var_p1,0)
var_p2_ave = dim_avg_n_Wrap(var_p2,0)
  
ext_changes = ext_p2_ave - ext_p1_ave
mean_changes = mean_p2_ave - mean_p1_ave
excess_changes = ext_changes - mean_changes

var_ext_changes = var_ext_p2_ave - var_ext_p1_ave
var_mean_changes = var_p2_ave - var_p1_ave
excess_var = var_ext_changes - var_mean_changes

delete([/ext_p1,ext_p2,Temp_p1,Temp_p2,ext_p1_3d,ext_p2_3d,ext_p1_ave,ext_p2_ave,mean_p1_ave,mean_p2_ave/])
delete([/var_p1,var_p2,var_p1_3d,var_p2_3d,var_p1_ave,var_p2_ave,var_p1_ave,var_p2_ave/])



Excess_Changes(iDat,:,:) = excess_changes
Excess_Var(iDat,:,:) = excess_var

;max_temp = max(excess_changes)
;max_var(iSeas,iClimVar) = max(excess_var)
;min_temp = min(Excess_Changes)
;min_var = min(Excess_Var) 

end do

CanESM = Excess_Changes(0,:,:)
CNRM = Excess_Changes(1,:,:)
CSIRO = Excess_Changes(2,:,:)
inmcm = Excess_Changes(3,:,:)
MPI = Excess_Changes(4,:,:)

var_CanESM = Excess_Var(0,:,:)
var_CNRM = Excess_Var(1,:,:)
var_CSIRO = Excess_Var(2,:,:)
var_inmcm = Excess_Var(3,:,:)
var_MPI = Excess_Var(4,:,:)

max_temp = max(Excess_Changes)
max_var = max(Excess_Var)
min_temp = min(Excess_Changes)
min_var = min(Excess_Var) 


;print(max_var)
;print(max_temp)

;***********************************************************
;;**************Plot data as scatter plot*******************
;*********************************************************** 


res			= True
res@gsnMaximize		= True
res@gsnDraw		= False
res@gsnFrame		= False

res@gsnXRefLine		= 0.0
res@gsnYRefLine		= 0.0
res@gsnXRefLineDashPattern = 2
res@gsnYRefLineDashPattern = 2

res@trYMaxF = max_temp+1
res@trYMinF = min_temp-1
res@trXMaxF = max_var+1
res@trXMinF = min_var-1

res@tmEqualizeXYSizes	= True
res@tmXTOn		= False
res@tmYROn		= False
 
res@xyMarkLineMode = "Markers"
res@xyMarker = 16
res@xyMarkerSizeF = 14

res@xyMarkerColor = "grey"
plot_iClimVar(iSeas) = gsn_csm_xy(wks,var_CanESM,CanESM,res)

mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerSizeF = 5

mkres@gsMarkerColor = "steelblue1"
dum1(iSeas) = gsn_add_polymarker(wks,plot_iClimVar(iSeas),var_CNRM,CNRM,mkres)

mkres@gsMarkerColor = "seagreen"
dum2(iSeas) = gsn_add_polymarker(wks,plot_iClimVar(iSeas),var_CSIRO,CSIRO,mkres)

mkres@gsMarkerColor = "plum"
dum3(iSeas) = gsn_add_polymarker(wks,plot_iClimVar(iSeas),var_inmcm,inmcm,mkres)

mkres@gsMarkerColor = "tomato"
dum4(iSeas) = gsn_add_polymarker(wks,plot_iClimVar(iSeas),var_MPI,MPI,mkres)

dum1_all(iClimVar::2) = dum1
dum2_all(iClimVar::2) = dum2
dum3_all(iClimVar::2) = dum3
dum4_all(iClimVar::2) = dum4

plot_all(iClimVar::2) = plot_iClimVar

;delete([/max_temp,min_temp,max_var,min_var/])
delete([/CanESM,CNRM,CSIRO,inmcm,MPI/])
delete([/var_CanESM,var_CNRM,var_CSIRO,var_inmcm,var_MPI/])


 end do		;;ends iSeas loop

;delete([/Excess_Changes,Excess_Var/])
end do		;;ends iClimVar loop

;;;Panel the plots
pres				= True
;pres@gsnPanelLabelBar		= True		;common label bar
pres@gsnFrame			= False		;don't advance frame yet
;pres@lbLabelFontHeightF	= 0.01
pres@gsnMaximize		= True		;Maximize plot in frame
;pres@pmLabelBarHeightF		= 0.05
;pres@lbLabelAutoStride		= True		;nice label bar labels
;pres@pmLabelBarOrthogonalPosF	= -0.01		;move label bar down
;pres@gsnPanelOrientation	= "Portrait"
;pres@gsnPanelCenter  		= False
pres@gsnPanelXWhiteSpacePercent= 5
pres@gsnPanelYWhiteSpacePercent=5

pres@gsnPanelTop = 0.90
pres@gsnPanelBottom = 0.10

gsn_panel(wks,plot_all,(/3,2/),pres)		;3 rows, 2 column

;;add text to plots
txres					= True
txres@txFontHeightF			= 0.019
txres@FontThicknessF			= 1.4
txres@txJust				= "CenterCenter"
  
gsn_text_ndc(wks,"Scatter plots of individual grid points in 'hot spot' region",0.50,0.96,txres)

txres@txFontHeightF = 0.008
;gsn_text_ndc(wks,"Snow cover on extreme days only (%)",0.37,0.10,txres)
gsn_text_ndc(wks,"Downwelling short-wave radiation (extreme days only) (W/m^2)",0.37,0.10,txres)
txres@txAngleF	= 90.		;makes text vertical along y-axis
gsn_text_ndc(wks,"Excess changes in temperature (~S~o~N~C)",0.227,0.775,txres)

txres@txFontHeightF = 0.013
txres@txAngleF = 0
gsn_text_ndc(wks,"Tmax (cold tail)",0.38,0.9,txres)
gsn_text_ndc(wks,"Tmin (cold tail)",0.65,0.9,txres)

txres@txJust = "TopLeft"
gsn_text_ndc(wks,"SON",0.18,0.78,txres)
gsn_text_ndc(wks,"DJF",0.18,0.52,txres)
gsn_text_ndc(wks,"MAM",0.18,0.25,txres)


;;;manually add legend
gsres = True
gsres@gsMarkerIndex = 16
gsres@gsMarkerSizeF = 6
gsres@txFontHeightF	= 0.01
gsres@txJust = "CenterLeft"
 
gsres@gsMarkerColor = "grey"
gsn_polymarker_ndc(wks,0.25,0.075,gsres)
gsn_text_ndc(wks,"CanESM2",0.26,0.075,gsres)

gsres@gsMarkerColor = "steelblue1"
gsn_polymarker_ndc(wks,0.35,0.075,gsres)
gsn_text_ndc(wks,"CNRM-CM5",0.36,0.075,gsres)

gsres@gsMarkerColor = "seagreen"
gsn_polymarker_ndc(wks,0.46,0.075,gsres)
gsn_text_ndc(wks,"CSIRO-Mk3-6-0",0.47,0.075,gsres)

gsres@gsMarkerColor = "plum"
gsn_polymarker_ndc(wks,0.60,0.075,gsres)
gsn_text_ndc(wks,"inmcm4",0.61,0.075,gsres)

gsres@gsMarkerColor = "tomato"
gsn_polymarker_ndc(wks,0.70,0.075,gsres)
gsn_text_ndc(wks,"MPI-ESM-MR",0.71,0.075,gsres)

;draw(plot)
frame(wks)

end
