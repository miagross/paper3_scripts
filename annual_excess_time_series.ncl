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

Var = (/"rsds"/)	  
Datasets = (/"CanESM2","CNRM-CM5","CSIRO-Mk3-6-0","inmcm4","MPI-ESM-MR"/)
Seasons = (/"SON","DJF","MAM"/)
ClimVars = (/"TXn"/)

ext_temp_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)
ext_var_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)
mean_temp_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)
mean_var_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)

xVals = ispan(1,dimsizes(Years),1)
ext_ann_ave = new(dimsizes(Years),"float",-999.9)
var_ext_ann_ave = new(dimsizes(Years),"float",-999.9)
var_ann_ave = new(dimsizes(Years),"float",-999.9)

;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "annual_scatter_excess_rsds_TXn_r2"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)

plot_ext= new(3,graphic)			;create plot array... 3 variables, 3 seasons
plot_mean = new(3,graphic)
plot_excess = new(3,graphic)


;print(plot)

;;;BEGIN LOOPING THROUGH SEASONS AND VARIABLES
do iSeas=0, dimsizes(Seasons)-1
 Season = Seasons(iSeas)

 ;plot_iSeas = new(3,graphic)			;for 3 variables

   ;;;LOOP THROUGH DATASETS
   do iDat=0,dimsizes(Datasets)-1
    Data=Datasets(iDat)
    
    ;;;READ IN ANNUAL MEAN TEMP ANOMALIES

    MeanDataDir = "/srv/ccrc/data40/z5026024/CMIP5/anomalies/"
    if(ClimVars.eq."TXn") then
     MeanData = MeanDataDir+Data+"_TX_anoms_1950-2099_2.5x2.5_ann_mean_"+Season+".nc"
     MeanFile = addfile(MeanData,"r")
     ann_mean = MeanFile->TX_anoms(:,{50:65},{-125:-105})
    else if(ClimVars.eq."TNn") then
     MeanData = MeanDataDir+Data+"_TN_anoms_1950-2099_2.5x2.5_ann_mean_"+Season+".nc"
     MeanFile = addfile(MeanData,"r")
     ann_mean = MeanFile->TN_anoms(:,{50:65},{-125:-105})
    end if
    end if
    

    ;;;START LOOPING THROUGH ANNUAL FILES
    do iYr=0,dimsizes(Years)-1
     Yrs=Years(iYr)
     ;print(iYr+": "+Yrs)
 
     ;***********************************************************
     ;;*********************Read-in input************************
     ;***********************************************************

     ;;;READ IN ANNUAL EXTREME TEMP DATA

     ExtDataDir = "/srv/ccrc/data40/z5026024/extremes_only_files/1950-2099/annual/"
     ExtData = ExtDataDir+Data+"_"+ClimVars+"_"+Yrs+"_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
     ExtFile = addfile(ExtData,"r")
 
     ext = ExtFile->extremes(:,{50:65},{-125:-105})	;USE REGIONAL BOX LAT RANGE 45:65 LON RANGE 50:80	
     lats = ext&lat
     lons = ext&lon

     ;;;READ IN VARIABLES FOR DIFFERENT PROCESSES FOR SAME MODEL
     VarDir = "/srv/ccrc/data04/z5026024/CMIP5/annual_data/"
     VarData = VarDir+Var+"_day_"+Data+"_"+Yrs+"_masked_2.5x2.5_"+Season+".nc"
     VarFile = addfile(VarData,"r")
  
     if(Var.eq."snc")then
      var = VarFile->snc(:,{50:65},{-125:-105})
     else if(Var.eq."hfls")then
      var = VarFile->hfls(:,{45:65},{45:80})
     else if(Var.eq."hfss")then
      var = VarFile->hfss(:,{45:65},{45:80})
     else if(Var.eq."rlds")then
      var = VarFile->rlds(:,{45:65},{45:80})
     else if(Var.eq."rlus")then
      var = VarFile->rlus(:,{45:65},{45:80})
     else if(Var.eq."rsds")then
      var = VarFile->rsds(:,{50:65},{-125:-105})
     else if(Var.eq."rsus")then
      var = VarFile->rsus(:,{45:65},{45:80})
     else if(Var.eq."albedo")then
      var = VarFile->rsus(:,{50:65},{-125:-105})
     else if(Var.eq."Qnet")then
      var = VarFile->rsds(:,{50:65},{-125:-105})
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
  
  
     ;;;TAKE AVERAGE FOR EACH YEAR FROM AREA-AVERAGED REGION
 
    ;;;first calculate regional average (area-weighted average for selected region)
    rad = 4.0*atan(1.0)/180.0
    lat = lats
    clat = cos(lat*rad)
 
    ext_reg_ave = wgt_areaave(ext_3d,clat,1.0,0)
    var_ext_reg_ave = wgt_areaave(var_ext_3d,clat,1.0,0)

    ext_ann_ave(iYr) = dim_avg_n_Wrap(ext_reg_ave,0)		;average of extreme temperatures per year (pooled over grid boxes) 
    var_ext_ann_ave(iYr) = dim_avg_n_Wrap(var_ext_reg_ave,0)
    
    ;;;calculate average annual data for other variables
    var_reg_ave = wgt_areaave(var,clat,1.0,0)
    var_ann_ave(iYr) = dim_avg_n_Wrap(var_reg_ave,0)
    
    delete([/ext,ext_3d,var,var_ext_3d,ext_reg_ave,var_ext_reg_ave,var_reg_ave/])
 
   end do		;ends loop iYr

   
   ;;;TAKE AREA-WEIGHTED AVERAGE FOR ANNUAL MEAN TEMPS (ALREADY SPLIT INTO ANNUAL MEANS)
   mean_reg_ave = wgt_areaave(ann_mean,clat,1.0,0)		;spatial average
   mean_ann_ave = mean_reg_ave
   					
  
   ;;;CALCULATE CLIMATOLOGICAL AVERAGE FOR FIRST 30 YEARS
   clim_ave_ext = avg(ext_ann_ave(0:29))		;years 1950 - 1979
   clim_var_ave = avg(var_ext_ann_ave(0:29))
   
   clim_ave_mean = avg(mean_ann_ave(0:29))
   clim_ave_var_mean = avg(var_ann_ave(0:29))

   ;;;CALCULATE ANOMALY OF EXTREMES i.e. annual average (extremes & mean) relative to 1950-1979 average
   ext_ann_anom = ext_ann_ave - clim_ave_ext
   ext_var_ann_anom = var_ext_ann_ave - clim_var_ave
   
   mean_ann_anom = mean_ann_ave - clim_ave_mean
   mean_var_ann_anom = var_ann_ave - clim_ave_var_mean

   ;print(ext_ann_ave)
   ;print(ext_ann_anom)

   
   ;;;PUT ALL DATA IN ONE MULTI_DIMENSIONAL ARRAY PER VARIABLE

   ext_temp_ts(iDat,:) = ext_ann_anom
   ext_var_ts(iDat,:) = ext_var_ann_anom
   
   mean_temp_ts(iDat,:) = mean_ann_anom
   mean_var_ts(iDat,:) = mean_var_ann_anom

   ;printVarSummary(ext_temp_ts)
   ;delete([/ext,ext_3d,var,var_ext_3d/])

  end do			;;end loop iDat
  
  
  ;;;CALCULATE 'EXCESSES' i.e. extremes - mean
  
  excess_temp_ts = ext_temp_ts - mean_temp_ts
  excess_var_ts = ext_var_ts - mean_var_ts
  
  ;;;GET THE MAX/MIN VALUE FOR EACH VARIABLE FOR PLOTTING

  ext_max_temp = max(ext_temp_ts)
  ext_min_temp = min(ext_temp_ts)
  ext_max_var = max(ext_var_ts)
  ext_min_var = min(ext_var_ts)
  
  mean_max_temp = max(mean_temp_ts)
  mean_min_temp = min(mean_temp_ts)
  mean_max_var = max(mean_var_ts)
  mean_min_var = min(mean_var_ts)
  
  excess_max_temp = max(excess_temp_ts)
  excess_min_temp = min(excess_temp_ts)
  excess_max_var = max(excess_var_ts)
  excess_min_var = min(excess_var_ts)

  ;;;make an array of timeseries for individual datasets

  ext_CanESM = ext_temp_ts(0,:)
  ext_CNRM = ext_temp_ts(1,:)
  ext_CSIRO = ext_temp_ts(2,:)
  ext_inmcm = ext_temp_ts(3,:)
  ext_MPI = ext_temp_ts(4,:)
  
  mean_CanESM = mean_temp_ts(0,:)
  mean_CNRM = mean_temp_ts(1,:)
  mean_CSIRO = mean_temp_ts(2,:)
  mean_inmcm = mean_temp_ts(3,:)
  mean_MPI = mean_temp_ts(4,:)
  
  excess_CanESM = excess_temp_ts(0,:)
  excess_CNRM = excess_temp_ts(1,:)
  excess_CSIRO = excess_temp_ts(2,:)
  excess_inmcm = excess_temp_ts(3,:)
  excess_MPI = excess_temp_ts(4,:)

  ext_var_CanESM = ext_var_ts(0,:)
  ext_var_CNRM = ext_var_ts(1,:)
  ext_var_CSIRO = ext_var_ts(2,:)
  ext_var_inmcm = ext_var_ts(3,:)
  ext_var_MPI = ext_var_ts(4,:)
  
  mean_var_CanESM = mean_var_ts(0,:)
  mean_var_CNRM = mean_var_ts(1,:)
  mean_var_CSIRO = mean_var_ts(2,:)
  mean_var_inmcm = mean_var_ts(3,:)
  mean_var_MPI = mean_var_ts(4,:)
  
  excess_var_CanESM = excess_var_ts(0,:)
  excess_var_CNRM = excess_var_ts(1,:)
  excess_var_CSIRO = excess_var_ts(2,:)
  excess_var_inmcm = excess_var_ts(3,:)
  excess_var_MPI = excess_var_ts(4,:)
  
  
  ;;;CALCULATE REGRESSION LINE FOR PLOTTING EXCESSES (ONLY)
  ;y=mx+b
  ;m is the slope: rc returned from regline
  ;b in the y-intercept: rc@yave attribute of rc returned from regline
  ;;;;PUT REGRESSION LINE AND DATA INTO AN ARRAY
  
  ;;;EXTREMES ONLY
  
  ext_rc_CanESM = regline(ext_var_CanESM,ext_CanESM)
  ext_data_CanESM = new((/2,dimsizes(ext_CanESM)/),typeof(ext_CanESM))
  ext_data_CanESM(0,:) = ext_CanESM
  ext_data_CanESM(1,:) = ext_rc_CanESM*(ext_var_CanESM-ext_rc_CanESM@xave) + ext_rc_CanESM@yave

  ext_rc_CNRM = regline(ext_var_CNRM,ext_CNRM)
  ext_data_CNRM = new((/2,dimsizes(ext_CNRM)/),typeof(ext_CNRM))
  ext_data_CNRM(0,:) = ext_CNRM
  ext_data_CNRM(1,:) = ext_rc_CNRM*(ext_var_CNRM-ext_rc_CNRM@xave) + ext_rc_CNRM@yave
  
  ext_rc_CSIRO = regline(ext_var_CSIRO,ext_CSIRO)
  ext_data_CSIRO = new((/2,dimsizes(ext_CSIRO)/),typeof(ext_CSIRO))
  ext_data_CSIRO(0,:) = ext_CSIRO
  ext_data_CSIRO(1,:) = ext_rc_CSIRO*(ext_var_CSIRO-ext_rc_CSIRO@xave) + ext_rc_CSIRO@yave
  
  ext_rc_inmcm = regline(ext_var_inmcm,ext_inmcm)
  ext_data_inmcm = new((/2,dimsizes(ext_inmcm)/),typeof(ext_inmcm))
  ext_data_inmcm(0,:) = ext_inmcm
  ext_data_inmcm(1,:) = ext_rc_inmcm*(ext_var_inmcm-ext_rc_inmcm@xave) + ext_rc_inmcm@yave
  
  ext_rc_MPI = regline(ext_var_MPI,ext_MPI)
  ext_data_MPI = new((/2,dimsizes(ext_MPI)/),typeof(ext_MPI))
  ext_data_MPI(0,:) = ext_MPI
  ext_data_MPI(1,:) = ext_rc_MPI*(ext_var_MPI-ext_rc_MPI@xave) + ext_rc_MPI@yave
  
  
  ;;;MEAN ONLY
  
  mean_rc_CanESM = regline(mean_var_CanESM,mean_CanESM)
  mean_data_CanESM = new((/2,dimsizes(mean_CanESM)/),typeof(mean_CanESM))
  mean_data_CanESM(0,:) = mean_CanESM
  mean_data_CanESM(1,:) = mean_rc_CanESM*(mean_var_CanESM-mean_rc_CanESM@xave) + mean_rc_CanESM@yave

  mean_rc_CNRM = regline(mean_var_CNRM,mean_CNRM)
  mean_data_CNRM = new((/2,dimsizes(mean_CNRM)/),typeof(mean_CNRM))
  mean_data_CNRM(0,:) = mean_CNRM
  mean_data_CNRM(1,:) = mean_rc_CNRM*(mean_var_CNRM-mean_rc_CNRM@xave) + mean_rc_CNRM@yave
  
  mean_rc_CSIRO = regline(mean_var_CSIRO,mean_CSIRO)
  mean_data_CSIRO = new((/2,dimsizes(mean_CSIRO)/),typeof(mean_CSIRO))
  mean_data_CSIRO(0,:) = mean_CSIRO
  mean_data_CSIRO(1,:) = mean_rc_CSIRO*(mean_var_CSIRO-mean_rc_CSIRO@xave) + mean_rc_CSIRO@yave
  
  mean_rc_inmcm = regline(mean_var_inmcm,mean_inmcm)
  mean_data_inmcm = new((/2,dimsizes(mean_inmcm)/),typeof(mean_inmcm))
  mean_data_inmcm(0,:) = mean_inmcm
  mean_data_inmcm(1,:) = mean_rc_inmcm*(mean_var_inmcm-mean_rc_inmcm@xave) + mean_rc_inmcm@yave
  
  mean_rc_MPI = regline(mean_var_MPI,mean_MPI)
  mean_data_MPI = new((/2,dimsizes(mean_MPI)/),typeof(mean_MPI))
  mean_data_MPI(0,:) = mean_MPI
  mean_data_MPI(1,:) = mean_rc_MPI*(mean_var_MPI-mean_rc_MPI@xave) + mean_rc_MPI@yave
  
  
  ;;;EXCESSES
  
  rc_CanESM = regline(excess_var_CanESM,excess_CanESM)
  data_CanESM = new((/2,dimsizes(excess_CanESM)/),typeof(excess_CanESM))
  data_CanESM(0,:) = excess_CanESM
  data_CanESM(1,:) = rc_CanESM*(excess_var_CanESM-rc_CanESM@xave) + rc_CanESM@yave

  rc_CNRM = regline(excess_var_CNRM,excess_CNRM)
  data_CNRM = new((/2,dimsizes(excess_CNRM)/),typeof(excess_CNRM))
  data_CNRM(0,:) = excess_CNRM
  data_CNRM(1,:) = rc_CNRM*(excess_var_CNRM-rc_CNRM@xave) + rc_CNRM@yave
  
  rc_CSIRO = regline(excess_var_CSIRO,excess_CSIRO)
  data_CSIRO = new((/2,dimsizes(excess_CSIRO)/),typeof(excess_CSIRO))
  data_CSIRO(0,:) = excess_CSIRO
  data_CSIRO(1,:) = rc_CSIRO*(excess_var_CSIRO-rc_CSIRO@xave) + rc_CSIRO@yave
  
  rc_inmcm = regline(excess_var_inmcm,excess_inmcm)
  data_inmcm = new((/2,dimsizes(excess_inmcm)/),typeof(excess_inmcm))
  data_inmcm(0,:) = excess_inmcm
  data_inmcm(1,:) = rc_inmcm*(excess_var_inmcm-rc_inmcm@xave) + rc_inmcm@yave
  
  rc_MPI = regline(excess_var_MPI,excess_MPI)
  data_MPI = new((/2,dimsizes(excess_MPI)/),typeof(excess_MPI))
  data_MPI(0,:) = excess_MPI
  data_MPI(1,:) = rc_MPI*(excess_var_MPI-rc_MPI@xave) + rc_MPI@yave
  
  
    
  ;;;CALCULATE SPEARMAN'S RANK CORRELATION COEFFICIENT AND P-VALUE
  
  ;;;for extremes only
  ext_spc_CanESM 	= spcorr(ext_var_CanESM,ext_CanESM)
  ext_spc_CNRM		= spcorr(ext_var_CNRM,ext_CNRM)
  ext_spc_CSIRO		= spcorr(ext_var_CSIRO,ext_CSIRO)
  ext_spc_inmcm		= spcorr(ext_var_inmcm,ext_inmcm)
  ext_spc_MPI		= spcorr(ext_var_MPI,ext_MPI)
  
  siglvl = 0.01							;a-priori specified sig level
  ext_pr_CanESM		= rtest(ext_spc_CanESM,dimsizes(Years),0)
  ext_pr_CNRM		= rtest(ext_spc_CNRM,dimsizes(Years),0)
  ext_pr_CSIRO		= rtest(ext_spc_CSIRO,dimsizes(Years),0)
  ext_pr_inmcm		= rtest(ext_spc_inmcm,dimsizes(Years),0)
  ext_pr_MPI		= rtest(ext_spc_MPI,dimsizes(Years),0)
  
  ;;;means
  mean_spc_CanESM	= spcorr(mean_var_CanESM,mean_CanESM)
  mean_spc_CNRM		= spcorr(mean_var_CNRM,mean_CNRM)
  mean_spc_CSIRO	= spcorr(mean_var_CSIRO,mean_CSIRO)
  mean_spc_inmcm	= spcorr(mean_var_inmcm,mean_inmcm)
  mean_spc_MPI		= spcorr(mean_var_MPI,mean_MPI)
  
  siglvl = 0.01							;a-priori specified sig level
  mean_pr_CanESM	= rtest(mean_spc_CanESM,dimsizes(Years),0)
  mean_pr_CNRM		= rtest(mean_spc_CNRM,dimsizes(Years),0)
  mean_pr_CSIRO		= rtest(mean_spc_CSIRO,dimsizes(Years),0)
  mean_pr_inmcm		= rtest(mean_spc_inmcm,dimsizes(Years),0)
  mean_pr_MPI		= rtest(mean_spc_MPI,dimsizes(Years),0)
    
  ;;;excesses
  spc_CanESM		= spcorr(excess_var_CanESM,excess_CanESM)
  spc_CNRM		= spcorr(excess_var_CNRM,excess_CNRM)
  spc_CSIRO		= spcorr(excess_var_CSIRO,excess_CSIRO)
  spc_inmcm		= spcorr(excess_var_inmcm,excess_inmcm)
  spc_MPI		= spcorr(excess_var_MPI,excess_MPI)
  
  siglvl = 0.01							;a-priori specified sig level
  pr_CanESM		= rtest(spc_CanESM,dimsizes(Years),0)
  pr_CNRM		= rtest(spc_CNRM,dimsizes(Years),0)
  pr_CSIRO		= rtest(spc_CSIRO,dimsizes(Years),0)
  pr_inmcm		= rtest(spc_inmcm,dimsizes(Years),0)
  pr_MPI		= rtest(spc_MPI,dimsizes(Years),0)
  
  ;print(mean_spc_CanESM)
  ;print(mean_pr_CanESM)
  
  ;if(ext_pr_CanESM.lt.siglvl) then
  ; print("rtest is significant at the "+siglvl+" significance level")
  ;else
  ; print("rtest is NOT significant at the "+siglvl+" significance level")
  ;end if



  ;**********************************************************
  ;**********************Plot data***************************
  ;**********************************************************
   
   
  ;;;;;;PLOT SCATTER PLOT OF CORRELATIONS FROM TIME SERIES
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;PLOT EXTREMES ONLY
  res				= True
  res@gsnMaximize		= True
  res@gsnDraw			= False
  res@gsnFrame			= False

  res@gsnXRefLine		= 0.0
  res@gsnYRefLine		= 0.0
  res@gsnXRefLineDashPattern 	= 2
  res@gsnYRefLineDashPattern 	= 2

  res@tmEqualizeXYSizes		= True
  res@tmXTOn			= False
  res@tmYROn			= False
  res@tmXBLabelFontHeightF	= 0.022

  res@trYMaxF = ext_max_temp+2
  res@trYMinF = ext_min_temp-2
  if(Var.eq."albedo") then
   res@trXMaxF = 0.4
   res@trXMinF = -0.4
  else
   res@trXMaxF = ext_max_var+3
   res@trXMinF = ext_min_var-3
  end if

  res@xyMarkLineModes = (/"Markers","Lines"/)
  res@xyMarker = 16
  res@xyMarkerOpacityF = 0.3
  res@xyMarkerSizeF = 12  
  ;res@xyMarkerOpacityF = 0.3
  
  res@xyMarkerColor = "grey45"
  res@xyLineColor = "grey45"
  res@xyDashPattern = "SolidLine"
  res@xyLineThicknessF = 3
  plot_ext(iSeas) = gsn_csm_xy(wks,ext_var_CanESM,ext_data_CanESM,res)
  
  res@xyMarkerColor = "steelblue1"
  res@xyLineColor = "steelblue1"
  dum1 = gsn_csm_xy(wks,ext_var_CNRM,ext_data_CNRM,res)
  
  res@xyMarkerColor = "seagreen"
  res@xyLineColor = "seagreen"
  dum2 = gsn_csm_xy(wks,ext_var_CSIRO,ext_data_CSIRO,res)
  
  res@xyMarkerColor = "plum"
  res@xyLineColor = "plum"
  dum3 = gsn_csm_xy(wks,ext_var_inmcm,ext_data_inmcm,res)
  
  res@xyMarkerColor = "tomato"
  res@xyMarkerColor = "tomato"
  res@xyLineColor = "tomato"
  dum4 = gsn_csm_xy(wks,ext_var_MPI,ext_data_MPI,res)
  
  overlay(plot_ext(iSeas),dum1)
  overlay(plot_ext(iSeas),dum2)
  overlay(plot_ext(iSeas),dum3)
  overlay(plot_ext(iSeas),dum4)
  
  delete(res)
  delete([/dum1,dum2,dum3,dum4/])
  
  
  ;;;ADD TEXT FOR CORRELATION COEFFICIENT AND P-VALUE
  txres = True
  txres@txFontHeightF	= 0.01
  txres@txJust = "TopLeft"
  
  yval = 0.905

  txres@txFontColor = "grey45"
  
  if(Season.eq."SON") then
   xval = 0.16
  else if(Season.eq."DJF") then
   xval = 0.41
  else if(Season.eq."MAM") then
   xval = 0.66
  end if
  end if
  end if

  if(ext_pr_CanESM.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(ext_spc_CanESM,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(ext_spc_CanESM,2,True),xval,yval,txres)
  end if
  
  txres@txFontColor = "steelblue1"
  
  if(Season.eq."SON") then
   xval = 0.20
  else if(Season.eq."DJF") then
   xval = 0.45
  else if(Season.eq."MAM") then
   xval = 0.70
  end if
  end if
  end if
  
  if(ext_pr_CNRM.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(ext_spc_CNRM,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(ext_spc_CNRM,2,True),xval,yval,txres)
  end if
  
  txres@txFontColor = "seagreen"
  
  if(Season.eq."SON") then
   xval = 0.24
  else if(Season.eq."DJF") then
   xval = 0.49
  else if(Season.eq."MAM") then
   xval = 0.74
  end if
  end if
  end if
  
  if(ext_pr_CSIRO.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(ext_spc_CSIRO,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(ext_spc_CSIRO,2,True),xval,yval,txres)
  end if
  
  txres@txFontColor = "plum"
  
  if(Season.eq."SON") then
   xval = 0.28
  else if(Season.eq."DJF") then
   xval = 0.53
  else if(Season.eq."MAM") then
   xval = 0.78
  end if
  end if
  end if
  
  if(ext_pr_inmcm.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(ext_spc_inmcm,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(ext_spc_inmcm,2,True),xval,yval,txres)
  end if
  
  txres@txFontColor = "tomato"
  
  if(Season.eq."SON") then
   xval = 0.32
  else if(Season.eq."DJF") then
   xval = 0.57
  else if(Season.eq."MAM") then
   xval = 0.82
  end if
  end if
  end if
  
  if(ext_pr_MPI.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(ext_spc_MPI,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(ext_spc_MPI,2,True),xval,yval,txres)
  end if

  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;PLOT MEAN ONLY
  res				= True
  res@gsnMaximize		= True
  res@gsnDraw			= False
  res@gsnFrame			= False

  res@gsnXRefLine		= 0.0
  res@gsnYRefLine		= 0.0
  res@gsnXRefLineDashPattern 	= 2
  res@gsnYRefLineDashPattern 	= 2

  res@tmEqualizeXYSizes		= True
  res@tmXTOn			= False
  res@tmYROn			= False
  res@tmXBLabelFontHeightF	= 0.022

  res@trYMaxF = mean_max_temp+1
  res@trYMinF = mean_min_temp-1
  if(Var.eq."albedo") then
   res@trXMaxF = 0.2
   res@trXMinF = -0.2
  else
   res@trXMaxF = mean_max_var+1
   res@trXMinF = mean_min_var-1
  end if

  res@xyMarkLineModes = (/"Markers","Lines"/)
  res@xyMarker = 16
  res@xyMarkerOpacityF = 0.3
  res@xyMarkerSizeF = 12  
  
  res@xyMarkerColor = "grey45"
  res@xyLineColor = "grey45"
  res@xyDashPattern = "SolidLine"
  res@xyLineThicknessF = 3
  plot_mean(iSeas) = gsn_csm_xy(wks,mean_var_CanESM,mean_data_CanESM,res)
  
  res@xyMarkerColor = "steelblue1"
  res@xyLineColor = "steelblue1"
  dum1 = gsn_csm_xy(wks,mean_var_CNRM,mean_data_CNRM,res)
  
  res@xyMarkerColor = "seagreen"
  res@xyLineColor = "seagreen"
  dum2 = gsn_csm_xy(wks,mean_var_CSIRO,mean_data_CSIRO,res)
  
  res@xyMarkerColor = "plum"
  res@xyLineColor = "plum"
  dum3 = gsn_csm_xy(wks,mean_var_inmcm,mean_data_inmcm,res)
  
  res@xyMarkerColor = "tomato"
  res@xyLineColor = "tomato"
  dum4 = gsn_csm_xy(wks,mean_var_MPI,mean_data_MPI,res)
  
  overlay(plot_mean(iSeas),dum1)
  overlay(plot_mean(iSeas),dum2)
  overlay(plot_mean(iSeas),dum3)
  overlay(plot_mean(iSeas),dum4)
  
  delete(res)
  delete([/dum1,dum2,dum3,dum4/])
  
  
  ;;;ADD TEXT FOR CORRELATION COEFFICIENT AND P-VALUE
  txres = True
  txres@txFontHeightF	= 0.01
  txres@txJust = "TopLeft"
  
  yval = 0.605

  txres@txFontColor = "grey45"
  
  if(Season.eq."SON") then
   xval = 0.16
  else if(Season.eq."DJF") then
   xval = 0.41
  else if(Season.eq."MAM") then
   xval = 0.66
  end if
  end if
  end if

  if(mean_pr_CanESM.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(mean_spc_CanESM,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(mean_spc_CanESM,2,True),xval,yval,txres)
  end if
  
  txres@txFontColor = "steelblue1"
  
  if(Season.eq."SON") then
   xval = 0.20
  else if(Season.eq."DJF") then
   xval = 0.45
  else if(Season.eq."MAM") then
   xval = 0.70
  end if
  end if
  end if
  
  if(mean_pr_CNRM.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(mean_spc_CNRM,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(mean_spc_CNRM,2,True),xval,yval,txres)
  end if
  
  txres@txFontColor = "seagreen"
  
  if(Season.eq."SON") then
   xval = 0.24
  else if(Season.eq."DJF") then
   xval = 0.49
  else if(Season.eq."MAM") then
   xval = 0.74
  end if
  end if
  end if
  
  if(mean_pr_CSIRO.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(mean_spc_CSIRO,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(mean_spc_CSIRO,2,True),xval,yval,txres)
  end if
  
  txres@txFontColor = "plum"
  
  if(Season.eq."SON") then
   xval = 0.28
  else if(Season.eq."DJF") then
   xval = 0.53
  else if(Season.eq."MAM") then
   xval = 0.78
  end if
  end if
  end if
  
  if(mean_pr_inmcm.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(mean_spc_inmcm,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(mean_spc_inmcm,2,True),xval,yval,txres)
  end if
  
  txres@txFontColor = "tomato"
  
  if(Season.eq."SON") then
   xval = 0.32
  else if(Season.eq."DJF") then
   xval = 0.57
  else if(Season.eq."MAM") then
   xval = 0.82
  end if
  end if
  end if
  
  if(mean_pr_MPI.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(mean_spc_MPI,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(mean_spc_MPI,2,True),xval,yval,txres)
  end if
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;PLOT EXCESSES
  res				= True
  res@gsnMaximize		= True
  res@gsnDraw			= False
  res@gsnFrame			= False

  res@gsnXRefLine		= 0.0
  res@gsnYRefLine		= 0.0
  res@gsnXRefLineDashPattern 	= 2
  res@gsnYRefLineDashPattern 	= 2

  res@tmEqualizeXYSizes		= True
  res@tmXTOn			= False
  res@tmYROn			= False
  res@tmXBLabelFontHeightF	= 0.022

  res@trYMaxF = excess_max_temp+1
  res@trYMinF = excess_min_temp-1
  if(Var.eq."albedo") then
   res@trXMaxF = 0.4
   res@trXMinF = -0.4
  else
   res@trXMaxF = excess_max_var+3
   res@trXMinF = excess_min_var-3
  end if

  res@xyMarkLineModes = (/"Markers","Lines"/)
  res@xyMarker = 16
  res@xyMarkerSizeF = 12
  res@xyMarkerOpacityF = 0.3
  
  ;res@xyMarkerColors = (/"grey","steelblue1","seagreen","plum","tomato"/)
  res@xyMarkerColor = "grey45"
  res@xyLineColor = "grey45"
  res@xyDashPattern = "SolidLine"
  res@xyLineThicknessF = 3
  plot_excess(iSeas) = gsn_csm_xy(wks,excess_var_CanESM,data_CanESM,res)
  
  res@xyMarkerColor = "steelblue1"
  res@xyLineColor = "steelblue1"
  dum1 = gsn_csm_xy(wks,excess_var_CNRM,data_CNRM,res)
  
  res@xyMarkerColor = "seagreen"
  res@xyLineColor = "seagreen"
  dum2 = gsn_csm_xy(wks,excess_var_CSIRO,data_CSIRO,res)
  
  res@xyMarkerColor = "plum"
  res@xyLineColor = "plum"
  dum3 = gsn_csm_xy(wks,excess_var_inmcm,data_inmcm,res)
  
  res@xyMarkerColor = "tomato"
  res@xyLineColor = "tomato"
  dum4 = gsn_csm_xy(wks,excess_var_MPI,data_MPI,res)
  
  overlay(plot_excess(iSeas),dum1)
  overlay(plot_excess(iSeas),dum2)
  overlay(plot_excess(iSeas),dum3)
  overlay(plot_excess(iSeas),dum4)
  
  ;;;ADD TEXT FOR CORRELATION COEFFICIENT AND P-VALUE
  txres = True
  txres@txFontHeightF	= 0.01
  txres@txJust = "TopLeft"
  
  yval = 0.305

  txres@txFontColor = "grey45"
  
  if(Season.eq."SON") then
   xval = 0.16
  else if(Season.eq."DJF") then
   xval = 0.41
  else if(Season.eq."MAM") then
   xval = 0.66
  end if
  end if
  end if

  if(pr_CanESM.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(spc_CanESM,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(spc_CanESM,2,True),xval,yval,txres)
  end if
  
  txres@txFontColor = "steelblue1"
  
  if(Season.eq."SON") then
   xval = 0.20
  else if(Season.eq."DJF") then
   xval = 0.45
  else if(Season.eq."MAM") then
   xval = 0.70
  end if
  end if
  end if
  
  if(pr_CNRM.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(spc_CNRM,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(spc_CNRM,2,True),xval,yval,txres)
  end if
  
  txres@txFontColor = "seagreen"
  
  if(Season.eq."SON") then
   xval = 0.24
  else if(Season.eq."DJF") then
   xval = 0.49
  else if(Season.eq."MAM") then
   xval = 0.74
  end if
  end if
  end if
  
  if(pr_CSIRO.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(spc_CSIRO,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(spc_CSIRO,2,True),xval,yval,txres)
  end if
  
  txres@txFontColor = "plum"
  
  if(Season.eq."SON") then
   xval = 0.28
  else if(Season.eq."DJF") then
   xval = 0.53
  else if(Season.eq."MAM") then
   xval = 0.78
  end if
  end if
  end if
  
  if(pr_inmcm.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(spc_inmcm,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(spc_inmcm,2,True),xval,yval,txres)
  end if
  
  txres@txFontColor = "tomato"
  
  if(Season.eq."SON") then
   xval = 0.32
  else if(Season.eq."DJF") then
   xval = 0.57
  else if(Season.eq."MAM") then
   xval = 0.82
  end if
  end if
  end if
  
  if(pr_MPI.lt.siglvl) then
   gsn_text_ndc(wks,""+decimalPlaces(spc_MPI,2,True)+"*",xval,yval,txres)
  else
   gsn_text_ndc(wks,""+decimalPlaces(spc_MPI,2,True),xval,yval,txres)
  end if
  

; end do		;END LOOP VARIABLES
 
end do		;END LOOP SEASONS


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

;pres@gsnPanelTop = 0.95
;pres@gsnPanelBottom = 0.03

;pres@gsnPanelMainString		= "SON Tmin (cold tail)"
;pres@gsnPanelMainFontHeightF	= 0.015

pres@gsnPanelTop = 0.90
pres@gsnPanelBottom = 0.65
gsn_panel(wks,plot_ext,(/1,3/),pres)		;2 rows, 1 column

pres@gsnPanelTop = 0.60
pres@gsnPanelBottom = 0.35
gsn_panel(wks,plot_mean,(/1,3/),pres)

pres@gsnPanelTop = 0.30
pres@gsnPanelBottom = 0.05
gsn_panel(wks,plot_excess,(/1,3/),pres)


;;;manually add text and legend
gsres = True

gsres@txFontHeightF	= 0.015
gsres@txJust = "CenterCenter"
gsn_text_ndc(wks,"Tmax (cold tail)",0.5,0.98,gsres)

gsres@txFontHeightF	= 0.013
gsn_text_ndc(wks,"SON",0.25,0.95,gsres)
gsn_text_ndc(wks,"DJF",0.50,0.95,gsres)
gsn_text_ndc(wks,"MAM",0.75,0.95,gsres)

gsres@txJust = "CenterLeft"
gsres@txFontHeightF	= 0.01
gsn_text_ndc(wks,"Extremes",0.09,0.90,gsres)
gsn_text_ndc(wks,"Mean",0.09,0.60,gsres)
gsn_text_ndc(wks,"Excess",0.09,0.30,gsres)

gsres@txAngleF = 0.
gsres@gsMarkerIndex = 16
gsres@gsMarkerSizeF = 6
gsres@txFontHeightF	= 0.01
gsres@txJust = "CenterLeft"
 
gsres@gsMarkerColor = "grey45"
gsn_polymarker_ndc(wks,0.25,0.015,gsres)
gsn_text_ndc(wks,"CanESM2",0.26,0.015,gsres)

gsres@gsMarkerColor = "steelblue1"
gsn_polymarker_ndc(wks,0.35,0.015,gsres)
gsn_text_ndc(wks,"CNRM-CM5",0.36,0.015,gsres)

gsres@gsMarkerColor = "seagreen"
gsn_polymarker_ndc(wks,0.46,0.015,gsres)
gsn_text_ndc(wks,"CSIRO-Mk3-6-0",0.47,0.015,gsres)

gsres@gsMarkerColor = "plum"
gsn_polymarker_ndc(wks,0.60,0.015,gsres)
gsn_text_ndc(wks,"inmcm4",0.61,0.015,gsres)

gsres@gsMarkerColor = "tomato"
gsn_polymarker_ndc(wks,0.70,0.015,gsres)
gsn_text_ndc(wks,"MPI-ESM-MR",0.71,0.015,gsres)

gsres@txAngleF = 90.
gsres@txFontHeightF = 0.008
gsres@txJust = "CenterCenter"
gsn_text_ndc(wks,"Temperature anomaly (~S~o~N~C)",0.108,0.78,gsres)

gsres@txAngleF = 0.
if(Var.eq."snc") then
 gsn_text_ndc(wks,"snow cover (%)",0.25,0.05,gsres)
else if(Var.eq."albedo") then
 gsn_text_ndc(wks,"albedo",0.25,0.05,gsres)
else if(Var.eq."hfss") then
 gsn_text_ndc(wks,"sensible heat (W/m~S~2~N~)",0.25,0.05,gsres)
else if(Var.eq."hfls") then 
 gsn_text_ndc(wks,"latent heat (W/m~S~2~N~)",0.25,0.05,gsres)
else if(Var.eq."rlds") then
 gsn_text_ndc(wks,"downwelling longwave radiation (W/m~S~2~N~)",0.25,0.05,gsres)
else if(Var.eq."rlus") then
 gsn_text_ndc(wks,"upwelling longwave radiation (W/m~S~2~N~)",0.25,0.05,gsres)
else if(Var.eq."rsds") then
 gsn_text_ndc(wks,"downwelling shortwave radiation (W/m~S~2~N~)",0.25,0.05,gsres)
else if(Var.eq."rsus") then
 gsn_text_ndc(wks,"upwelling shortwave radiation (W/m~S~2~N~)",0.25,0.05,gsres)
else if(Var.eq."Qnet") then
 gsn_text_ndc(wks,"net radiation (W/m~S~2~N~)",0.25,0.05,gsres)
end if
end if
end if
end if
end if
end if
end if
end if
end if


;draw(plot)		;use for single plot only
frame(wks)

end
