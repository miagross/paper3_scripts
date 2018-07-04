load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Script to plot trend differences;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;for TXx, TXn, TNx and TNn;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin

 ;;;set-up output
 plotfile = "/srv/ccrc/data04/z5026024/plots/snw_CSIRO-Mk3-6-0_1950-2014"
 wks_type = "eps"
 ;wks_type@wksPaperSize = "A4"
 wks = gsn_open_wks(wks_type,plotfile)
 
 ;;;set-up map space
 greymap=(/"grey"/) ; colormap with grey
 gsn_merge_colormaps(wks,"posneg_1",greymap) ; merge two color maps.. used to be hotcolr_19lev
 
 ;;create plot array
 plot_datasets	= new(1,graphic)

 ;Dataset = (/"HadGHCND","ACCESS1-0","ACCESS1-3","bcc-csm1-1","BNU-ESM","CanESM2","CCSM4","CMCC-CESM",\
 ;	    "CMCC-CM","CNRM-CM5","CSIRO-Mk3-6-0","GFDL-CM3","GFDL-ESM2G","GFDL-ESM2M","HadGEM2-CC",\
;	    "HadGEM2-ES","inmcm4","IPSL-CM5A-LR","IPSL-CM5A-MR","IPSL-CM5B-LR","MIROC5",\
;	    "MIROC-ESM-CHEM","MIROC-ESM","MPI-ESM-LR","MPI-ESM-MR","MRI-CGCM3","NorESM1-M"/)
 Dataset = "CSIRO-Mk3-6-0"
 
 ;set-up array 
 ;ndata = dimsizes(Dataset) 			;; count number of datasets
 ;plot_datasets	= new( ndata+1,graphic)		;;each variable has 8 datasets, plus ensemble mean
 ;;rc = new(dimsizes(Dataset)-1,"float")
 ;Ensemble = new ((/ndata-1,73,96/),"float",-999.9)
 
  ;***********************************************************
  ;;*********************Read-in input************************
  ;***********************************************************
 
  do idat=0,dimsizes(Dataset)-1
  Data=Dataset(idat)
  print(idat+": "+Data)
 
  ;plots_idat	= new(4,graphic)
  ;plots_idat	= new(4,graphic)	;for 4 variables

  ;;;read-in input file
  indatadir = "/srv/ccrc/data04/z5026024/CMIP5/"
  indata = indatadir+"snw_day_"+Data+"_1950-2014_masked_ave.nc"

  file1 = addfile(indata,"r")
  snow = file1->snw					;use for L-trend - trend in mean plots
  ;lats = file1->location(:,0)
  ;lats = loc&lat
  
  ;print(lats)

  ;file2 = addfile(indata2,"r")
  ;loc = file2->trend_difference
  ;prob = file2->p_value
  
  ;; remember HadGHCND field for calculating pettern correlations of the models
  ;if(Data.eq."HadGHCND")then
  ; HadGHCND = loc			;so we can test correlation with each CMIP5 model with HadGHCND
  ;end if
  
  ;w = cos(0.01745329*lats)					;weighting
  ;print(w)

  ;; add dataset in Ensemble array for Ensemble mean calculation
  ;if(Data.ne."HadGHCND")then
  ;  Ensemble(idat-1,:,:) = loc
  ;end if
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
 

 res@gsnCenterString		= ""
; res@gsnLeftString		= ""
; res@gsnRightString		= ""
 res@cnInfoLabelOn		= False			;Turn off info label
 ;res@pmTickMarkDisplayMode	= "Always"		;Uses in-built NCL tickmarks
 res@gsnTickMarksOn		= False			;Turn on/off all tick marks
 ;res@tmXBLabelFontHeightF	= 0.022
 ;res@tmEqualizeXYSizes		= True

 
 res@gsnSpreadColors		= True			;Use full range of color map
 res@gsnSpreadColorStart	= 5			;Start at color index 1..used to be 2
 res@gsnSpreadColorEnd		= 20			;Stop at 2nd color from end.. used to be 20


 res@cnLevelSelectionMode	= "ManualLevels"	;Set manual contour levels
 res@cnMinLevelValF		= 0			;originally -1 Set min contour level
 res@cnMaxLevelValF		= 20			;originally 1 Set max contour level
 res@cnLevelSpacingF		= 1			;originally 0.2
 
 ;res@gsnLeftString		= Data
 ;if(Data.ne."HadGHCND")then
 ;  ;pc = pattern_cor(HadGHCND,loc,1.0,0)		;1.0=unweighted,0=centered 1=uncentered
 ;  pc = pattern_cor(HadGHCND,loc,w,1)			;weighted, uncentered
 ;  res@gsnRightString		= decimalPlaces(pc,2,True)
 ;end if
 ;if(Data.eq."HadGHCND")then
 ; pc = pattern_cor(HadGHCND,loc,1.0,1)
 ; res@gsnRightString		= decimalPlaces(pc,2,True)
 ;end if

 res@gsnStringFontHeightF	= 0.03

 plot_datasets(idat) = gsn_csm_contour_map_ce(wks,snow,res)
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

;EnsMean = dim_avg_n(Ensemble,0)
;copy_VarCoords(loc,EnsMean)
;res@gsnLeftString	= "Ensemble Mean"
;;pc_ens = pattern_cor(HadGHCND,EnsMean,1.0,0)		;unweighted/(un)centered
;pc_ens = pattern_cor(HadGHCND,EnsMean,w,1)		;weighted/uncentered
;res@gsnRightString	= decimalPlaces(pc_ens,2,True)
;plot_datasets(ndata) = gsn_csm_contour_map_ce(wks,EnsMean,res)




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


 
 gsn_panel(wks,plot_datasets,(/1,1/),pres1)		;(/rows,columns/)


;;;add text for correlation for each plot


txpres@txJust = "CenterCenter"
gsn_text_ndc(wks,"[~S~o~N~C] / decade",0.5,0.047,txpres) 	;yaxis used to be 0.270 ... 0.275 ... robinson uses 0.235

;;;now advance frame for all plots
frame(wks)

end	
