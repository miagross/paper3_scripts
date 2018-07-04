load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;Script to calculate pattern correlations;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;and plot;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin

Datasets = (/"CanESM2","CNRM-CM5","CSIRO-Mk3-6-0","inmcm4","MPI-ESM-MR"/)
Season = (/"SON"/)
ClimVar = (/"tas_cold"/)
Var = "snc"

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


;;;SET UP OUTPUT
plotfile = "correlations_"+Var+"_"+ClimVar+"_"+Season
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)

;;;SET UP MAP SPACE
greymap=(/"grey"/) ; colormap with grey
gsn_merge_colormaps(wks,"cmp_b2r",greymap) 	;merge two color maps.. used to be hotcolr_19lev

plot_all = new(5,graphic)		;;5 models

;Excess_Changes = new((/dimsizes(Datasets),12,36/),"float",-999.9)
;Excess_Var = new((/dimsizes(Datasets),12,36/),"float",-999.9)

;;;STORE ARRAYS FOR CALCULATIONS
ext_ann_ave = new((/dimsizes(Years),72,144/),"float",-999.9)
var_ext_ann_ave = new((/dimsizes(Years),72,144/),"float",-999.9)
temp_ann_ave = new((/dimsizes(Years),72,144/),"float",-999.9)
var_ann_ave = new((/dimsizes(Years),72,144/),"float",-999.9)

;;;LOOP THROUGH CLIMATE VARIABLES AND SEASONS
;do iClimVar=0,dimsizes(ClimVars)-1
; ClimVar = ClimVars(iClimVar)
 
; do iSeas=0,dimsizes(Seasons)-1
;  Season = Seasons(iSeas)

  ;;;LOOP THROUGH MODELS
  do iDat=0,dimsizes(Datasets)-1
   Data=Datasets(iDat)
   
   ;;;START LOOPING THROUGH ANNUAL FILES
    do iYr=0,dimsizes(Years)-1
     Yrs=Years(iYr)
     ;print(iYr+": "+Yrs)
 
     ;***********************************************************
     ;;*********************Read-in input************************
     ;***********************************************************

     ;;;READ IN ANNUAL EXTREME TEMP DATA

     ExtDataDir = "/srv/ccrc/data01/z5026024/extremes_only_files/future_tas/annual/"
     ExtData = ExtDataDir+Data+"_"+ClimVar+"_"+Yrs+"_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
     ExtFile = addfile(ExtData,"r")
 
     ext = ExtFile->extremes			
     lats = ext&lat
     lons = ext&lon
     ;printVarSummary(ext)
     
     ;;;DAILY ANNUAL TEMP ANOMALIES

     TempDataDir = "/srv/ccrc/data40/z5026024/CMIP5/anomalies_tas/annual/"
   
     TempData = TempDataDir+Data+"_tas_anoms_"+Yrs+"_2.5x2.5_"+Season+".nc"
     TempFile = addfile(TempData,"r")
     temp = TempFile->tas_anoms


     ;;;READ IN VARIABLES FOR DIFFERENT PROCESSES FOR SAME MODEL
     VarDir = "/srv/ccrc/data04/z5026024/CMIP5/annual_data/"
     VarData = VarDir+Var+"_day_"+Data+"_"+Yrs+"_masked_2.5x2.5_"+Season+".nc"
     VarFile = addfile(VarData,"r")
  
     if(Var.eq."snc")then
      var = VarFile->snc
     else if(Var.eq."hfls")then
      var = VarFile->hfls
     else if(Var.eq."hfss")then
      var = VarFile->hfss
     else if(Var.eq."rlds")then
      var = VarFile->rlds
     else if(Var.eq."rlus")then
      var = VarFile->rlus
     else if(Var.eq."rsds")then
      var = VarFile->rsds
     else if(Var.eq."rsus")then
      var = VarFile->rsus
     else if(Var.eq."albedo")then
      var = VarFile->rsus
     else if(Var.eq."Qnet")then
      var = VarFile->rsds
     end if
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
  
  
     ;;;TAKE ANNUAL AVERAGE (SO ONE VALUE PER GRID CELL)
 
    ext_ann_ave(iYr,:,:) = dim_avg_n_Wrap(ext_3d,0)		;average of extreme temperatures per year (pooled over grid boxes) 
    var_ext_ann_ave(iYr,:,:) = dim_avg_n_Wrap(var_ext_3d,0)
    temp_ann_ave(iYr,:,:) = dim_avg_n_Wrap(temp,0)
    var_ann_ave(iYr,:,:) = dim_avg_n_Wrap(var,0)
    
    copy_VarCoords(ext_ann_ave,ext_3d)
    ;copy_VarCoords(var_ext_ann_ave,var_ext_3d)
    ;copy_VarCoords(temp_ann_ave,temp)
    ;copy_VarCoords(var_ann_ave,var)
    
    delete([/ext,ext_3d,var,var_ext_3d,temp/])
 
   end do		;ends loop iYr
   
   ;;;CALCULATE CLIMATOLOGICAL AVERAGE FOR FIRST 30 YEARS (FOR EACH GRID CELL)
   clim_ave_ext		= avg(ext_ann_ave(0:29,:,:))
   clim_ave_var_ext	= avg(var_ext_ann_ave(0:29,:,:))
   clim_ave_temp 	= avg(temp_ann_ave(0:29,:,:))
   clim_ave_var 	= avg(var_ann_ave(0:29,:,:))
   
   ;;;CALCULATE ANOMALY RELATIVE TO CLIMATOLOGY
   ext_ann_anom = ext_ann_ave - clim_ave_ext
   var_ext_ann_anom = var_ext_ann_ave - clim_ave_var_ext
   temp_ann_anom = temp_ann_ave - clim_ave_temp
   var_ann_anom = var_ann_ave - clim_ave_var
   
   ;;;CALCULATE EXCESSES
   excess_temp = ext_ann_anom - temp_ann_anom
   excess_var = var_ext_ann_anom - var_ann_anom
   
   ;printVarSummary(excess_temp)
   
   mk_excess_temp = trend_manken(excess_temp,False,0)
   
   print(mk_excess_temp)
   
   ;excess_temp!0 = "lat"
   ;excess_temp&lat = lats
   ;excess_temp&lat@units = "degrees_north"
   ;excess_temp!1 = "lon"
   ;excess_temp&lon = lons
   ;excess_temp&lon@units = "degrees_east"
   
   ;excess_var!0 = "lat"
   ;excess_var&lat = lats
   ;excess_var&lat@units = "degrees_north"
   ;excess_var!1 = "lon"
   ;excess_var&lon = lons
   ;excess_var&lon@units = "degrees_east"
     
   ;;;CALCULATE CORRELATION OF TEMP/VAR EXCESSES FOR EACH GRID CELL
   ;;;Spearman's rank correlation coefficient and P-value (Pearson's r)
   
   spc_excess = spcorr_n(excess_temp,excess_var,0)   
   ;printVarSummary(spc_excess)
   ;printVarSummary(ext_ann_ave(0,:,:))
   
   siglvl = 0.01
   pr_excess = rtest(spc_excess,dimsizes(Years),0)		;rtest determines the statistical significant of a linear correlation coefficient
   
   copy_VarCoords(spc_excess,ext_ann_ave(0,:,:))
   copy_VarCoords(pr_excess,ext_ann_ave(0,:,:))
   
   
   spc_excess!0 = "lat"
   spc_excess&lat = lats
   spc_excess&lat@units = "degrees_north"
   spc_excess!1 = "lon"
   spc_excess&lon = lons
   spc_excess&lon@units = "degrees_east"
   
   pr_excess!0 = "lat"
   pr_excess&lat = lats
   pr_excess&lat@units = "degrees_north"
   pr_excess!1 = "lon"
   pr_excess&lon = lons
   pr_excess&lon@units = "degrees_east"
   
   ;**********************************************************
   ;**********************Plot data***************************
   ;**********************************************************
   
   ;;;PLOT EXCESS CHANGES IN TEMPERATURE (LOOP THROUGH CLIMATE VARIALBES)

   res				= True
   res@gsnMaximize 		= True 			;Maximize plot in frame
   res@gsnDraw			= False			;Don't draw plots
   res@gsnFrame			= False			;Don't advance frame			
   res@cnFillMode		= "CellFill"		;Turn on contour fill
   res@cnFillOn			= True			;Raster Mode
   res@cnLinesOn		= False			;Turn off contour lines

   res@lbLabelAutoStride	= True			;Control labelbar spacing
   res@lbLabelBarOn		= False			;Turn off individual lb's
   res@lbLabelFontHeightF	= .016			;Make labels larger

   res@mpMinLatF		= 30			;Plots from Northern Hemisphere
   ;res@gsnCenterString		= ""
    ;res@gsnLeftString		= ""
   ;res@gsnRightString		= ""
   res@cnInfoLabelOn		= False			;Turn off info label
   ;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
   res@gsnTickMarksOn		= False			;Turn on/off all tick marks
   ;res@tmXBLabelFontHeightF	= 0.022
   ;res@tmEqualizeXYSizes	= True

   res@gsnSpreadColors		= True			;Use full range of color map
   res@gsnSpreadColorStart	= 2  			;Start at color index 1..used to be 2
   res@gsnSpreadColorEnd	= 65			;Stop at 2nd color from end.. used to be 20

   res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
   res@cnMinLevelValF		= -1.0			;originally -1 Set min contour level
   res@cnMaxLevelValF		= 1.0			;originally 1 Set max contour level
   res@cnLevelSpacingF		= 0.2			;originally 0.2
 
   ;res@gsnLeftString		= ClimVar
   res@gsnStringFontHeightF	= 0.03

   plot_all(iDat) = gsn_csm_contour_map_ce(wks,spc_excess,res)		;extreme temperature changes
  
  
   ;;;ADD STIPPLING FOR SIGNIFICANT GRID CELLS
   if(any(pr_excess.le.siglvl)) then
    prob_1D = ndtooned(pr_excess)
    dsizes_p = dimsizes(pr_excess)
    lats = pr_excess&lat
    lons = pr_excess&lon
    indices_p = ind_resolve(ind(prob_1D.le.siglvl),dsizes_p)
    ;print(dimsizes(indices_p))
    lonind = indices_p(:,1)
    latind = indices_p(:,0)
    lonsig = lons(lonind)
    latsig = lats(latind)
   
    ;;;ADD PLYMARKERS
    gsres = True
    gsres@gsMarkerSizeIndex = 17		;stippling
    gsres@MarkerSizeF = 0.0025
    gsres@gsMarkerColor = 1
    ;plot_sig(iDat) = gsn_add_polymarker(wks,plot_all(iDat),lonsig,latsig,gsres)
   end if
  
   delete([/indices_p,lonind,latind,lonsig,latsig/])
   
  end do	;ends loop iDat
  
 ;end do		;ends loop iSeas
;end do		;ends loop iClimVar 


;**********************************************************
;**********************Panel the plot**********************
;**********************************************************

pres				= True
pres@gsnFrame			= False		;don't advance frame yet
pres@gsnMaximize		= True

pres@gsnPanelLabelBar		= True		;common label bar
;pres@lbLabelFontHeightF		= 0.01
;pres@pmLabelBarHeightF		= 0.05
;pres@lbLabelAutoStride		= True
;pres@pmLabelBarOrthogonalPosF	= -0.01		;move label bar down

;pres@gsnPanelXWhiteSpacePercent	= 5
;pres@gsnPanelYWhiteSpacePercent	= 5

pres@gsnPanelMainString		= "Correlations of excess temperature and snow cover over 1950 - 2099 - SON"
pres@gsnPanelMainFontHeightF	= 0.015

gsn_panel(wks,plot_all,(/5,1/),pres)		;5 rows,1 column

frame(wks)

end
