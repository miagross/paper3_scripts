load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Script to plot trend differences;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;for TXx, TXn, TNx and TNn;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin

ClimVars = (/"TX","TN"/)		
 do ivar=0, dimsizes(ClimVars)-1
 var = ClimVars(ivar)
 
 ;;;set-up output
 plotfile = "/srv/ccrc/data04/z5026024/plots/MAM_mean_trends_u+w_"+var
 wks_type = "eps"
 ;wks_type@wksPaperSize = "A4"
 wks = gsn_open_wks(wks_type,plotfile)
 
 ;;;set-up map space
 greymap=(/"grey"/) ; colormap with grey
 gsn_merge_colormaps(wks,"posneg_1",greymap) ; merge two color maps.. used to be hotcolr_19lev,m then posneg_1

 Dataset = (/"HadGHCND","ACCESS1-0","ACCESS1-3","bcc-csm1-1","BNU-ESM","CanESM2","CCSM4","CMCC-CESM",\
 	    "CMCC-CM","CNRM-CM5","CSIRO-Mk3-6-0","GFDL-CM3","GFDL-ESM2G","GFDL-ESM2M","HadGEM2-CC",\
	    "HadGEM2-ES","inmcm4","IPSL-CM5A-LR","IPSL-CM5A-MR","IPSL-CM5B-LR","MIROC5",\
	    "MIROC-ESM-CHEM","MIROC-ESM","MPI-ESM-LR","MPI-ESM-MR","MRI-CGCM3","NorESM1-M"/)
 ;Dataset = (/"HadGEM2-CC","HadGEM2-ES"/)
 
 ;set-up array 
 ndata = dimsizes(Dataset) 			;; count number of datasets
 plot_datasets	= new( ndata+1,graphic)		;;each variable has 8 datasets, plus ensemble mean
 ;rc = new(dimsizes(Dataset)-1,"float")
 Ensemble = new ((/ndata-1,73,96/),"float",-999.9)
 
  ;***********************************************************
  ;;*********************Read-in input************************
  ;***********************************************************
 
  do idat=0,dimsizes(Dataset)-1
  Data=Dataset(idat)
  print(idat+": "+Data)
 
  ;plots_idat	= new(4,graphic)
  ;plots_idat	= new(4,graphic)	;for 4 variables

  ;;;read-in input file
  indatadir = "/srv/ccrc/data04/z5026024/trend_files/seasonal/"
  indata = indatadir+Data+"_"+var+"_1950-2014_mean_trend_MAM.nc"

  file1 = addfile(indata,"r")
  vars = file1->variance				
  lats = vars&lat
   
  ;print(lats)

  print ("Read in "+var+" - start plotting")
  
  ;; remember HadGHCND field for calculating pettern correlations of the models
  if(Data.eq."HadGHCND")then
   HadGHCND = vars			;so we can test correlation with each CMIP5 model with HadGHCND
  end if
  
  w = cos(0.01745329*lats)					;weighting
  ;print(w)

  ;; add dataset in Ensemble array for Ensemble mean calculation
  if(Data.ne."HadGHCND")then
    Ensemble(idat-1,:,:) = vars
  end if
  ;***********************************************************
  ;;*********************Plot maps****************************
  ;***********************************************************

 res				= True
 res@gsnMaximize 		= True 			;Maximize plot in frame
 res@gsnDraw			= False			;Don't draw plots
 res@gsnFrame			= False			
 res@cnFillMode			= "CellFill"		;Turn on contour fill
 res@cnFillOn			= True			;Raster Mode
 res@cnLinesOn			= False			;Turn off contour lines

 res@lbLabelAutoStride		= True			;Control labelbar spacing
 res@lbLabelBarOn		= False			;Turn off individual lb's
 res@lbLabelFontHeightF		= .013			;Make labels larger

 res@mpMinLatF			= -60			;Plots less Antarctica - turn off for Robinson
 
 ;;Robinson plots
 ;res@mpProjection		= "Robinson"
 ;;res@mpOutlineOn		= True			;turn on map outlines
 ;res@mpGridAndLimbOn		= True			;turn on lat/lon lines
 ;res@mpGridLineDashPattern	= 2	
 ;res@mpGridLatSpacingF		= 30			;spacing of lat/lon grid lines
 ;res@mpGridLonSpacingF		= 45
 ;;res@mpOutlineDrawOrder	= "PostDraw"		;draw the map outline last
 ;;res@mpGridandLimbDrawOrder	= "PreDraw"		;draw grid first (under the maps)
 ;res@mpGridMaskMode		= "MaskNotOcean"	;don't draw over land of inland water bodies
 ;res@mpPerimOn			= False			;turn off box around plot

 res@gsnCenterString		= ""
; res@gsnLeftString		= ""
; res@gsnRightString		= ""
 res@cnInfoLabelOn		= False			;Turn off info label
 ;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
 res@gsnTickMarksOn		= False			;Turn on/off all tick marks
 ;res@tmXBLabelFontHeightF	= 0.022
 ;res@tmEqualizeXYSizes		= True

 

 ;res@cnFillPalette		= cmap(::-1,:)		;Reverse color map
 ;res@cnFillColors		= (/"maroon2","blue1","royalblue1","deepskyblue2","cyan4",\
 ;				"seagreen","green3","green1","greenyellow","yellow1","darkgoldenrod1",\
 ;				"darkorange","darkorange1","tomato","orangered1","red1","red2","red4"/)
 res@gsnSpreadColors		= True			;Use full range of color map
 res@gsnSpreadColorStart	= 5			;Normally 5
 res@gsnSpreadColorEnd		= 20			;Normally 20


 res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
 res@cnMinLevelValF		= -0.6			;originally -1 Set min contour level..std dev use -0.1..mean-0.6
 res@cnMaxLevelValF		= 0.6			;originally 1 Set max contour level.. std dev use 0..1..mean0.6
 res@cnLevelSpacingF		= 0.1			;originally 0.2..std dev use 0.02.. mean use 0.1
 
 res@gsnLeftString		= Data
 if(Data.ne."HadGHCND")then
   ;pc = pattern_cor(HadGHCND,vars,1.0,0)		;1.0=unweighted,0=centered 1=uncentered
   pc = pattern_cor(HadGHCND,vars,w,1)			;weighted, uncentered
   res@gsnRightString		= decimalPlaces(pc,2,True)
 end if
 if(Data.eq."HadGHCND")then
  pc = pattern_cor(HadGHCND,vars,1.0,1)
  res@gsnRightString		= decimalPlaces(pc,2,True)
 end if

 res@gsnStringFontHeightF	= 0.03

 plot_datasets(idat) = gsn_csm_contour_map_ce(wks,vars,res)
 ;plots_all(idat::4) = plots_idat		;for every 4 datasets
 ;plots_all(idat::1) = plots_idat		;for 1 dataset
 
  ;***********************************************************
  ;;*************Add in stippling for significant*************
  ;**************************grid cells************************
 
 
; ;;;stippling
;  if(any(prob.le.0.05)) then
;  ;;print("At least one GP significant - calculate stippling positions...")
;  prob_1D = ndtooned(prob)
;  dsizes_p = dimsizes(prob)
;  lats = prob&lat
;  lons = prob&lon
;  indices_p = ind_resolve(ind(prob_1D.le.0.1),dsizes_p)
;  ;print(dimsizes(indices_p))
;  lonind = indices_p(:,1)
;  latind = indices_p(:,0)
;  lonsig = lons(lonind)
;  latsig = lats(latind)
; 
;  ;;add polymarkers
;  gsres = True
;  gsres@gsMarkerIndex = 17	;stippling
;  gsres@gsMarkerSizeF = 0.0025
;  gsres@gsMarkerColor = 1
;  plot_sig(ivar) = gsn_add_polymarker(wks,plots_idat(ivar),lonsig,latsig,gsres)
;  plot_sig_all(idat::4) = plot_sig
; end if
; 
; delete(indices_p)
; delete(lonind)
; delete(latind)
; delete(lonsig)
; delete(latsig)
; 
; plots_all(idat::4) = plots_idat




end do				;; end loop idat

;print(pc)

EnsMean = dim_avg_n(Ensemble,0)
copy_VarCoords(vars,EnsMean)
res@gsnLeftString	= "Ensemble Mean"
;pc_ens = pattern_cor(HadGHCND,EnsMean,1.0,0)		;unweighted/(un)centered
pc_ens = pattern_cor(HadGHCND,EnsMean,w,1)		;weighted/uncentered
res@gsnRightString	= decimalPlaces(pc_ens,2,True)
plot_datasets(ndata) = gsn_csm_contour_map_ce(wks,EnsMean,res)




;;;Panel the plots
pres1				= True
pres1@gsnPanelLabelBar		= True		;common label bar
pres1@gsnFrame			= False		;don't advance frame yet
pres1@lbLabelFontHeightF	= 0.01
pres1@gsnMaximize		= True		;Maximize plot in frame
pres1@pmLabelBarHeightF		= 0.05
pres1@lbLabelAutoStride		= True		;nice label bar labels
pres1@pmLabelBarOrthogonalPosF	= -0.01	;move label bar down
;pres1@gsnPanelOrientation	= "Portrait"
;pres1@gsnPanelCenter  		= False
pres1@gsnPanelXWhiteSpacePercent= 4		;turn on unless Robinson
pres1@gsnPanelYWhiteSpacePercent= 10		;usually 10; Robinson 5

;gsn_panel(wks,plots_all,(/4,4/),pres1)
;gsn_panel(wks,plot_datasets,(/7,4/),pres1)		;(/rows,columns/)

txres = True
txres@txJust = "BottomLeft"
txres@txFontHeightF = 0.04
txres@txFont = 22

;drawNDCGrid(wks)

;;;add text to plots
txpres				= True		;text mods desired
txpres@txFontHeightF		= 0.014		;font smaller. default is big.
txpres@txFontThicknessF		= 1.4
txpres@txJust			= "topLeft"	;justification of text coordinates

if(var.eq."TX") then
    pres1@txString		= "MAM Tmax trend in mean"
    ;gsn_text_ndc(wks,"Tmax~B~high",0.1,1,txpres)
 end if
 if(var.eq."TN") then
    pres1@txString		= "MAM Tmin trend in mean"
    ;gsn_text_ndc(wks,"Tmin~B~high",0,1,txpres)
 end if  

 
 gsn_panel(wks,plot_datasets,(/7,4/),pres1)		;(/rows,columns/)


;;;add text for correlation for each plot


txpres@txJust = "CenterCenter"
gsn_text_ndc(wks,"[~S~o~N~C] / decade",0.5,0.047,txpres) 	;yaxis used to be 0.270 ... 0.275 ... robinson uses 0.235

;;;now advance frame for all plots
frame(wks)
end do
end	
