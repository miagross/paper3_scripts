;***********************************************************
;;*********Script to calculate 3 moments and plot***********
;;*****************box & whisker plots**********************
;***********************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;***********************************************************

begin


ClimVars 	=(/"TX","TN"/)
  
	
do ivar=0, dimsizes(ClimVars)-1
  var = ClimVars(ivar)

  ;;;set-up output
  ;plotfile = "/srv/ccrc/data04/z5026024/plots/boxplot_Had_JRA_"+var
  plotfile = "boxplot_remapcon_"+var
  wks_type = "png"
  wks = gsn_open_wks(wks_type,plotfile)
  
   ;Dataset = (/"HadGHCND","ACCESS1-0","ACCESS1-3","bcc-csm1-1","BNU-ESM","CanESM2","CCSM4","CMCC-CESM","CMCC-CM","CNRM-CM5",\
  ;		"CSIRO-Mk3-6-0","GFDL-CM3","GFDL-ESM2G","GFDL-ESM2M","inmcm4","IPSL-CM5A-LR",\
;		"IPSL-CM5A-MR","IPSL-CM5B-LR","MIROC5","MIROC-ESM-CHEM","MIROC-ESM","MPI-ESM-LR","MPI-ESM-MR","MRI-CGCM3","NorESM1-M"/)
  Dataset = (/"ACCESS1-0","MIROC-ESM-CHEM","MRI-CGCM3"/)
  
  ;;;set up arrays for x- and y-values
  xVals=ispan(1,dimsizes(Dataset),1)				;numeric vector; number of datasets used
     
  yVals = new((/dimsizes(Dataset),5/), "float", -999.) 		;2D array of y-values and positions for box plot (for 5 datasets) 
  
  ;minVal1 = new(dimsizes(Dataset),"float")			;1D array of outlier polymarkers
  ;maxVal1 = new(dimsizes(Dataset),"float")
 
  ;***********************************************************
  ;;*********************Read-in input************************
  ;***********************************************************

  do idat=0,dimsizes(Dataset)-1
    Data=Dataset(idat)
    print(idat+": "+Data)
 
    InDataDir = "/srv/ccrc/data04/z5026024/CMIP5/remapping_tests/"
    InData = InDataDir+"v2_"+Data+"_"+var+"_1950-2014_anoms_masked_smoothed.nc"
  
    file1 = addfile(InData,"r")
 
    if (var.eq."TX") then
     data = file1->TX_anoms
    end if
    if (var.eq."TN") then
     data = file1->TN_anoms
    end if
   
    print ("Data read in - start calculations")
  
  
    ;************************************************************
    ;;*******************Calculate statistics********************
    ;************************for boxplot************************* 
  
    opt		= True
    opt@PrintStat = False
   
    anom_stats	= stat_dispersion(data,opt)
     
    ;;;extract stats for boxplot for each dataset
    yVals(idat,0)	= anom_stats(23)	;lower 1.0% of data, 1th percentile
    yVals(idat,1)	= anom_stats(6)		;lower quartile
    yVals(idat,2)	= anom_stats(0)		;mean value
    yVals(idat,3)	= anom_stats(10)	;upper quartile
    yVals(idat,4)	= anom_stats(26)	;upper 1.0% of data, 99th percentile
    
    ;;;for outliers (as polymarkers on plot)
    ;minVal1(iYrs)	= anom1_stats(2)	;minimum value   
    ;maxVal1(iYrs)	= anom1_stats(14)  	;maximum value   
   
    delete([/data, opt, anom_stats/])
   
    end do	;ends loop Datasets
           
   print(yVals)
     
  ;***********************************************************
  ;;***********************Plot data**************************
  ;***********************************************************

   
  res				= True
  res@tiMainString		= var
  res@trYMinF			= -20
  res@trYMaxF			= 20
   
  res@tmXBLabelsOn		= True
  res@tmXBLabels		= Dataset		;labels for each box
  res@tmXBLabelAngleF		= 90.
  ;res@tmXBLabelDirection	= 0			;vertical labels
  res@tmXBLabelFontHeightF 	= 0.01
  res@tmXBMajorLengthF		= 0.01
  ;res@tmXTMinorOn		= False			;turn off minor tickmarks
  
  ;res@tmXBMode			= "Manual"		;set to manual so can adjust tickmark spacing
  ;res@tmXBTickSpacingF		= 2
  res@gsnMaximize		= True			;maximize box plot in frame
  res@tmEqualizeXYSizes		= True			;all four tickmark axes same font height and tick lengths
  res@vpHeightF			= 0.5			;change aspect ratio of plot
  res@vpWidthF			= 0.75
  
  opt				= True
  opt@boxWidth			= .5
  
  llres				= True
  llres@gsLineThicknessF	= 3.5		;line thickness of boxplot
  
  plot = boxplot(wks,xVals,yVals,opt,res,False)
  
  
  ;***********************************************************
  ;;****************Add polymarkers to boxplot****************
  ;***********************************************************
  
  ;mres			= True			;marker mode desired
  
  ;mres@gsMarkerIndex	= 1			;polymarker style dot
  ;mres@gsMarkerSizeF	= 20.			;polymarker size
  
  ;mres@gsMarkerColor	= "black"		;HadGHCND 
  ;minVal_pm1		= gsn_add_polymarker(wks,plot1,xVals,minVal1,mres)
  ;maxVal_pm1		= gsn_add_polymarker(wks,plot1,xVals,maxVal1,mres) 
  
  ;;mres@gsMarkerColor	= "blue"		;ERA-Interim 
  ;;mres@gsMarkerColor	= "red"			;NCEP2
  ;mres@gsMarkerColor	= "green"		;JRA-55 	
  ;minVal_pm2		= gsn_add_polymarker(wks,plot1,xVals,minVal2,mres)
  ;maxVal_pm2		= gsn_add_polymarker(wks,plot1,xVals,maxVal2,mres) 
  
 
  
  ;;;add text
  ;txres			= True
  ;txres@txJust		= "CenterLeft"
  ;txres@txFontHeightF	= 0.01
  ;txres@txFontColor	= "black"
  
  ;gsn_text_ndc(wks,"HadGHCND",0.03,0.81,txres)
  ;if(prob_mean(0).ge.0.95) then
  ;  gsn_text_ndc(wks,"Trend (mean) = "+decimalPlaces(trend_mean(0),3,True)+"*",0.03,0.78,txres)
  ;else
  ;  gsn_text_ndc(wks,"Trend (mean) = "+decimalPlaces(trend_mean(0),3,True),0.03,0.78,txres)
  ;end if
  ;if(prob_upper(0).ge.0.95) then  
  ;  gsn_text_ndc(wks,"Trend (upper 1%) = "+decimalPlaces(trend_upper(0),3,True)+"*",0.03,0.75,txres)
  ;else
  ;  gsn_text_ndc(wks,"Trend (upper 1%) = "+decimalPlaces(trend_upper(0),3,True),0.03,0.75,txres)
  ;end if
  ;if(prob_lower(0).ge.0.95) then
  ;  gsn_text_ndc(wks,"Trend (lower 1%) = "+decimalPlaces(trend_lower(0),3,True)+"*",0.03,0.72,txres)
  ;else
  ;  gsn_text_ndc(wks,"Trend (lower 1%) = "+decimalPlaces(trend_lower(0),3,True),0.03,0.72,txres)
  ;end if
  
  
   ;draw(wks)   
  draw(plot)
  frame(wks)  
  
;end do		;;end loop Datasets
end do		;;end loop ClimVars

end
