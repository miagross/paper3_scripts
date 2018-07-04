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

Var = (/"snc"/)	  
Datasets = (/"CanESM2","CNRM-CM5","CSIRO-Mk3-6-0","inmcm4","MPI-ESM-MR"/)
Seasons = (/"SON","DJF","MAM"/)
ClimVars = (/"TXn"/)

xVals = ispan(1,dimsizes(Years),1)

variance_temp = new((dimsizes(Years)),"float",-999.9)
variance_var = new(dimsizes(Years),"float",-999.9)

ext_ann_ave = new(dimsizes(Years),"float",-999.9)
var_ext_ann_ave = new(dimsizes(Years),"float",-999.9)
var_ann_ave = new(dimsizes(Years),"float",-999.9)

variance_temp_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)
variance_var_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)


ext_temp_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)
ext_var_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)
mean_temp_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)
mean_var_ts = new((/dimsizes(Datasets),dimsizes(Years)/),"float",-999.9)


;***********************************************************
;;********************Set up output*************************
;***********************************************************

plotfile = "variance_snc_TX_r2"
wks_type = "eps"
wks =gsn_open_wks(wks_type,plotfile)

plot_cor= new(3,graphic)			;create plot array... 3 variables, 3 seasons
plot_ts_temp = new(3,graphic)
plot_ts_var = new(3,graphic)

;print(plot)

;;;BEGIN LOOPING THROUGH SEASONS AND VARIABLES
do iSeas=0, dimsizes(Seasons)-1
 Season = Seasons(iSeas)

   ;;;LOOP THROUGH DATASETS
   do iDat=0,dimsizes(Datasets)-1
    Data=Datasets(iDat)
    
    ;;;READ IN ANNUAL MEAN TEMP ANOMALIES

    MeanDataDir = "/srv/ccrc/data40/z5026024/data/CMIP5/anomalies/"
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
     
     ;;;READ IN DECADAL EXTREME TEMP DATA

     ExtDataDir = "/srv/ccrc/data40/z5026024/data/extremes_only_files/1950-2099/annual/"
     ExtData = ExtDataDir+Data+"_"+ClimVars+"_"+Yrs+"_EXTREMES_ONLY_2.5x2.5_"+Season+".nc"
     ExtFile = addfile(ExtData,"r")
 
     ext = ExtFile->extremes(:,{50:65},{-125:-105})	;USE REGIONAL BOX LAT RANGE 45:65 LON RANGE 50:80	
     lats = ext&lat
     lons = ext&lon
     
     ;;;READ IN ANNUAL TEMP ANOMALIES

    TempDataDir = "/srv/ccrc/data40/z5026024/data/CMIP5/anomalies/annual_temp/"
    if(ClimVars.eq."TXn") then
     TempData = TempDataDir+Data+"_TX_anoms_"+Yrs+"_2.5x2.5_"+Season+".nc"
     TempFile = addfile(TempData,"r")
     temp = TempFile->TX_anoms(:,{50:65},{-125:-105})
     ;lats = temp&lat
    else if(ClimVars.eq."TNn") then
     TempData = TempDataDir+Data+"_TN_anoms_"+Yrs+"_2.5x2.5_"+Season+".nc"
     TempFile = addfile(TempData,"r")
     temp = TempFile->TN_anoms(:,{50:65},{-125:-105})
     ;lats = temp&lat
    end if
    end if

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
      var = VarFile->rsds(:,{45:65},{45:80})
     else if(Var.eq."rsus")then
      var = VarFile->rsus(:,{45:65},{45:80})
     else if(Var.eq."albedo")then
      var = VarFile->rsus(:,{45:65},{45:80})
     else if(Var.eq."Qnet")then
      var = VarFile->rsds(:,{45:65},{45:80})
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
    
    temp_reg_ave = wgt_areaave(temp,clat,1.0,0)
    var_reg_ave = wgt_areaave(var,clat,1.0,0)
    
    ext_reg_ave = wgt_areaave(ext_3d,clat,1.0,0)
    var_ext_reg_ave = wgt_areaave(var_ext_3d,clat,1.0,0)
    
    ;printVarSummary(temp_reg_ave)
    
    variance_temp(iYr) = variance(temp_reg_ave)
    variance_var(iYr) = variance(var_reg_ave)
    
    ext_ann_ave(iYr) = dim_avg_n_Wrap(ext_reg_ave,0)		;average of extreme temperatures per year (pooled over grid boxes) 
    var_ext_ann_ave(iYr) = dim_avg_n_Wrap(var_ext_reg_ave,0)
    
    ;;;calculate average annual data for other variables
    ;var_reg_ave = wgt_areaave(var,clat,1.0,0)
    var_ann_ave(iYr) = dim_avg_n_Wrap(var_reg_ave,0)


    
    ;print(variance_temp)

    delete([/temp,var,temp_reg_ave,var_reg_ave/])
    delete([/ext,ext_3d,var_ext_3d,ext_reg_ave,var_ext_reg_ave/])
    
   end do		;ends loop iYr
   
   ;;;TAKE AREA-WEIGHTED AVERAGE FOR ANNUAL MEAN TEMPS (ALREADY SPLIT INTO ANNUAL MEANS)
   mean_reg_ave = wgt_areaave(ann_mean,clat,1.0,0)		;spatial average
   mean_ann_ave = mean_reg_ave
   										  
   ;;;CALCULATE CLIMATOLOGICAL AVERAGE FOR FIRST 30 YEARS
   clim_temp_variance	= avg(variance_temp(0:29))		;years 1950 - 1979
   clim_var_variance	= avg(variance_var(0:29))
   
   clim_ave_ext = avg(ext_ann_ave(0:29))		;years 1950 - 1979
   clim_var_ave = avg(var_ext_ann_ave(0:29))
   
   clim_ave_mean = avg(mean_ann_ave(0:29))
   clim_ave_var_mean = avg(var_ann_ave(0:29))

   ;;;CALCULATE ANOMALIES i.e. relative to 1950-1979 average
   variance_temp_anom	= variance_temp - clim_temp_variance
   variance_var_anom	= variance_var - clim_var_variance
   
   ext_ann_anom = ext_ann_ave - clim_ave_ext
   ext_var_ann_anom = var_ext_ann_ave - clim_var_ave
   
   mean_ann_anom = mean_ann_ave - clim_ave_mean
   mean_var_ann_anom = var_ann_ave - clim_ave_var_mean

   ;;;PUT ALL DATA IN ONE MULTI_DIMENSIONAL ARRAY PER VARIABLE
    
   variance_temp_ts(iDat,:) = variance_temp_anom
   variance_var_ts(iDat,:) = variance_var_anom
   
   ext_temp_ts(iDat,:) = ext_ann_anom
   ext_var_ts(iDat,:) = ext_var_ann_anom
   
   mean_temp_ts(iDat,:) = mean_ann_anom
   mean_var_ts(iDat,:) = mean_var_ann_anom

  end do			;;end loop iDat
  
;printVarSummary(variance_var_ts)
;print(variance_var_ts)

max_temp = max(variance_temp_ts)
min_temp = min(variance_temp_ts)
max_var = max(variance_var_ts)
min_var = min(variance_var_ts)

ext_max_temp = max(ext_temp_ts)
  ext_min_temp = min(ext_temp_ts)
  ext_max_var = max(ext_var_ts)
  ext_min_var = min(ext_var_ts)
  
  mean_max_temp = max(mean_temp_ts)
  mean_min_temp = min(mean_temp_ts)
  mean_max_var = max(mean_var_ts)
  mean_min_var = min(mean_var_ts)

variance_CanESM	= variance_temp_ts(0,:)
variance_CNRM	= variance_temp_ts(1,:)
variance_CSIRO	= variance_temp_ts(2,:)
variance_inmcm	= variance_temp_ts(3,:)
variance_MPI	= variance_temp_ts(4,:)

variance_var_CanESM	= variance_var_ts(0,:)
variance_var_CNRM	= variance_var_ts(1,:)
variance_var_CSIRO	= variance_var_ts(2,:)
variance_var_inmcm	= variance_var_ts(3,:)
variance_var_MPI	= variance_var_ts(4,:)


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


 ;;;CALCULATE REGRESSION LINE FOR PLOTTING EXCESSES (ONLY)
  ;y=mx+b
  ;m is the slope: rc returned from regline
  ;b in the y-intercept: rc@yave attribute of rc returned from regline
  ;;;;PUT REGRESSION LINE AND DATA INTO AN ARRAY
  
  variance_rc_CanESM = regline(variance_var_CanESM,variance_CanESM)
  variance_data_CanESM = new((/2,dimsizes(variance_CanESM)/),typeof(variance_CanESM))
  variance_data_CanESM(0,:) = variance_CanESM
  variance_data_CanESM(1,:) = variance_rc_CanESM*(variance_var_CanESM-variance_rc_CanESM@xave) + variance_rc_CanESM@yave

  variance_rc_CNRM = regline(variance_var_CNRM,variance_CNRM)
  variance_data_CNRM = new((/2,dimsizes(variance_CNRM)/),typeof(variance_CNRM))
  variance_data_CNRM(0,:) = variance_CNRM
  variance_data_CNRM(1,:) = variance_rc_CNRM*(variance_var_CNRM-variance_rc_CNRM@xave) + variance_rc_CNRM@yave
  
  variance_rc_CSIRO = regline(variance_var_CSIRO,variance_CSIRO)
  variance_data_CSIRO = new((/2,dimsizes(variance_CSIRO)/),typeof(variance_CSIRO))
  variance_data_CSIRO(0,:) = variance_CSIRO
  variance_data_CSIRO(1,:) = variance_rc_CSIRO*(variance_var_CSIRO-variance_rc_CSIRO@xave) + variance_rc_CSIRO@yave
  
  variance_rc_inmcm = regline(variance_var_inmcm,variance_inmcm)
  variance_data_inmcm = new((/2,dimsizes(variance_inmcm)/),typeof(variance_inmcm))
  variance_data_inmcm(0,:) = variance_inmcm
  variance_data_inmcm(1,:) = variance_rc_inmcm*(variance_var_inmcm-variance_rc_inmcm@xave) + variance_rc_inmcm@yave
  
  variance_rc_MPI = regline(variance_var_MPI,variance_MPI)
  variance_data_MPI = new((/2,dimsizes(variance_MPI)/),typeof(variance_MPI))
  variance_data_MPI(0,:) = variance_MPI
  variance_data_MPI(1,:) = variance_rc_MPI*(variance_var_MPI-variance_rc_MPI@xave) + variance_rc_MPI@yave
  
  
    ;;;EXTREMES/MEAN
  
  temp_rc_CanESM = regline(ext_CanESM,mean_CanESM)
  temp_data_CanESM = new((/2,dimsizes(mean_CanESM)/),typeof(mean_CanESM))
  temp_data_CanESM(0,:) = mean_CanESM
  temp_data_CanESM(1,:) = temp_rc_CanESM*(ext_CanESM-temp_rc_CanESM@xave) + temp_rc_CanESM@yave

  temp_rc_CNRM = regline(ext_CNRM,mean_CNRM)
  temp_data_CNRM = new((/2,dimsizes(mean_CNRM)/),typeof(mean_CNRM))
  temp_data_CNRM(0,:) = mean_CNRM
  temp_data_CNRM(1,:) = temp_rc_CNRM*(ext_CNRM-temp_rc_CNRM@xave) + temp_rc_CNRM@yave
  
  temp_rc_CSIRO = regline(ext_CSIRO,mean_CSIRO)
  temp_data_CSIRO = new((/2,dimsizes(mean_CSIRO)/),typeof(mean_CSIRO))
  temp_data_CSIRO(0,:) = mean_CSIRO
  temp_data_CSIRO(1,:) = temp_rc_CSIRO*(ext_CSIRO-temp_rc_CSIRO@xave) + temp_rc_CSIRO@yave
  
  temp_rc_inmcm = regline(ext_inmcm,mean_inmcm)
  temp_data_inmcm = new((/2,dimsizes(mean_inmcm)/),typeof(mean_inmcm))
  temp_data_inmcm(0,:) = mean_inmcm
  temp_data_inmcm(1,:) = temp_rc_inmcm*(ext_inmcm-temp_rc_inmcm@xave) + temp_rc_inmcm@yave
  
  temp_rc_MPI = regline(ext_MPI,mean_MPI)
  temp_data_MPI = new((/2,dimsizes(mean_MPI)/),typeof(mean_MPI))
  temp_data_MPI(0,:) = mean_MPI
  temp_data_MPI(1,:) = temp_rc_MPI*(ext_MPI-temp_rc_MPI@xave) + temp_rc_MPI@yave
  
  
  ;;CALCULATE SPEARMAN'S RANK CORRELATION COEFFICIENT AND P-VALUE
  
  ;;;for variance
  variance_spc_CanESM 		= spcorr(variance_var_CanESM,variance_CanESM)
  variance_spc_CNRM		= spcorr(variance_var_CNRM,variance_CNRM)
  variance_spc_CSIRO		= spcorr(variance_var_CSIRO,variance_CSIRO)
  variance_spc_inmcm		= spcorr(variance_var_inmcm,variance_inmcm)
  variance_spc_MPI		= spcorr(variance_var_MPI,variance_MPI)
  
  siglvl = 0.01										;a-priori specified sig level
  variance_pr_CanESM		= rtest(variance_spc_CanESM,dimsizes(Years),0)
  variance_pr_CNRM		= rtest(variance_spc_CNRM,dimsizes(Years),0)
  variance_pr_CSIRO		= rtest(variance_spc_CSIRO,dimsizes(Years),0)
  variance_pr_inmcm		= rtest(variance_spc_inmcm,dimsizes(Years),0)
  variance_pr_MPI		= rtest(variance_spc_MPI,dimsizes(Years),0)
  
  
  ;;for extremes only
  ext_spc_CanESM 	= spcorr(ext_CanESM,mean_CanESM)
  ext_spc_CNRM		= spcorr(ext_CNRM,mean_CNRM)
  ext_spc_CSIRO		= spcorr(ext_CSIRO,mean_CSIRO)
  ext_spc_inmcm		= spcorr(ext_inmcm,mean_inmcm)
  ext_spc_MPI		= spcorr(ext_MPI,mean_MPI)
  
  siglvl = 0.01							;a-priori specified sig level
  ext_pr_CanESM		= rtest(ext_spc_CanESM,dimsizes(Years),0)
  ext_pr_CNRM		= rtest(ext_spc_CNRM,dimsizes(Years),0)
  ext_pr_CSIRO		= rtest(ext_spc_CSIRO,dimsizes(Years),0)
  ext_pr_inmcm		= rtest(ext_spc_inmcm,dimsizes(Years),0)
  ext_pr_MPI		= rtest(ext_spc_MPI,dimsizes(Years),0)
  
  

  ;**********************************************************
  ;**********************Plot data***************************
  ;**********************************************************
  

  ;;;;;;PLOT SCATTER PLOT OF CORRELATIONS FROM TIME SERIES
  
  
  ;;;PLOT TIME SERIES
  res			= True
  res@gsnMaximize	= True
  res@gsnDraw		= False
  res@gsnFrame		= False

  res@tmXTOn		= False
  res@tmYROn		= False
  res@tmEqualizeXYSizes	= True
  res@trYMaxF 		= max_temp+1  
  res@trYMinF 		= min_temp-1
  res@trXMinF		= min(xVals)-1
  res@trXMaxF		= max(xVals)+1 
  res@tmXBLabelJust	= "CenterRight"
  res@tmXBLabelAngleF	= 90
  res@tmXBLabelStride	= 10
  res@tmXBMode		= "Explicit"
  res@tmXBValues	= xVals
  res@tmXBLabels	= (/"1950","1951","1952","1953","1954","1955","1956","1957","1958","1959",\
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
  ;res@tiMainString	= "Extreme temperatures (relative to 1950-'79)"
  plot_ts_temp(iSeas)	= gsn_csm_xy(wks,xVals,variance_temp_ts,res)

  ;;;PLOT VARIABLES
  res@trYMaxF 		= max_var+1
  res@trYMinF 		= min_var-1
  ;res@tiMainString	= "Snow cover (extreme temperature days only)"
  plot_ts_var(iSeas)	= gsn_csm_xy(wks,xVals,variance_var_ts,res)
  
  
  delete(res)
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;PLOT CORRELATION
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

  ;res@trYMaxF = max_temp+2
  ;res@trYMinF = min_temp-2
  ;if(Var.eq."albedo") then
  ; res@trXMaxF = 0.4
  ; res@trXMinF = -0.4
  ;else
  ; res@trXMaxF = max_var+3
  ; res@trXMinF = min_var-3
  ;end if
  
  res@trYMaxF = max_temp+2
  res@trYMinF = min_temp-2
  ;res@trXMaxF = max_var+2
  ;res@trXMinF = min_var-2

  res@xyMarkLineModes = (/"Markers","Lines"/)
  res@xyMarker = 16
  res@xyMarkerOpacityF = 0.3
  res@xyMarkerSizeF = 12  
  ;res@xyMarkerOpacityF = 0.3
  
  res@xyMarkerColor = "grey45"
  res@xyLineColor = "grey45"
  res@xyDashPattern = "SolidLine"
  res@xyLineThicknessF = 3
  plot_cor(iSeas) = gsn_csm_xy(wks,variance_var_CanESM,variance_data_CanESM,res)
  
  res@xyMarkerColor = "steelblue1"
  res@xyLineColor = "steelblue1"
  dum1 = gsn_csm_xy(wks,variance_var_CNRM,variance_data_CNRM,res)
  
  res@xyMarkerColor = "seagreen"
  res@xyLineColor = "seagreen"
  dum2 = gsn_csm_xy(wks,variance_var_CSIRO,variance_data_CSIRO,res)
  
  res@xyMarkerColor = "plum"
  res@xyLineColor = "plum"
  dum3 = gsn_csm_xy(wks,variance_var_inmcm,variance_data_inmcm,res)
  
  res@xyMarkerColor = "tomato"
  res@xyLineColor = "tomato"
  dum4 = gsn_csm_xy(wks,variance_var_MPI,variance_data_MPI,res)
  
  overlay(plot_cor(iSeas),dum1)
  overlay(plot_cor(iSeas),dum2)
  overlay(plot_cor(iSeas),dum3)
  overlay(plot_cor(iSeas),dum4)
  
  delete(res)
  delete([/dum1,dum2,dum3,dum4/])
  
 
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
gsn_panel(wks,plot_ts_temp,(/1,3/),pres)		;2 rows, 1 column

pres@gsnPanelTop = 0.60
pres@gsnPanelBottom = 0.35
gsn_panel(wks,plot_ts_var,(/1,3/),pres)

pres@gsnPanelTop = 0.30
pres@gsnPanelBottom = 0.05
gsn_panel(wks,plot_cor,(/1,3/),pres)



;;;manually add text and legend
gsres = True

gsres@txFontHeightF	= 0.015
gsres@txJust = "CenterCenter"
gsn_text_ndc(wks,"Variance (Tmax)",0.5,0.95,gsres)

gsres@txFontHeightF	= 0.013
gsn_text_ndc(wks,"SON",0.25,0.92,gsres)
gsn_text_ndc(wks,"DJF",0.50,0.92,gsres)
gsn_text_ndc(wks,"MAM",0.75,0.92,gsres)

gsres@txJust = "CenterLeft"
gsres@txFontHeightF	= 0.01
gsn_text_ndc(wks,"Tmax variance",0.09,0.90,gsres)
gsn_text_ndc(wks,"Snow cover variance",0.09,0.60,gsres)
gsn_text_ndc(wks,"Correlations",0.09,0.30,gsres)

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
gsn_text_ndc(wks,"Tmax (~S~o~N~C)",0.11,0.2,gsres)

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
