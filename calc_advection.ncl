load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Script to calculate horizontal temperature advection;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;and write out to NetCDF file;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

begin 

Data = "inmcm4"

;***********************************************************
;;******************READ IN INPUT FILES*********************
;***********************************************************

;;;WIND DATA

WindDataDir = "/srv/ccrc/data04/z5026024/CMIP5/wind_data/"

UData = WindDataDir+"uas_day_"+Data+"_1950-2099_2.5x2.5.nc"
UFile = addfile(UData,"r")
u = UFile->uas

VData = WindDataDir+"vas_day_"+Data+"_1950-2099_2.5x2.5.nc"
VFile = addfile(VData,"r")
v = VFile->vas


;;;ABSOLUTE TEMPERATURE INCL. LAND & OCEAN FOR ADVECTION CALCULATION
TempDataDir = "/srv/ccrc/data40/z5026024/CMIP5/absolute_temp_data/tas/"
TempData = TempDataDir+"tas_day_"+Data+"_1950-2099_2.5x2.5.nc"
TempFile = addfile(TempData,"r")
temp = TempFile->tas
lats = temp&lat
lons = temp&lon
time = temp&time


;***********************************************************
;;***********Calculate horizonal temp advection*************
;*******************and wind direction**********************

;;;;;;Variables must be ordered south to north (in units degC/s)

advT = advect_variable(u,v,temp,1,"advection of temperature","C/s",1)			;1 = regular/fixed grid

printVarSummary(advT)

;Tadv = advT		;degC/day


;;;MULTIPLY TEMP ADV BY 60*60*24 so units are per day, instead of per second
Tadv = advT[0]*60*60*24		;advected quantity i.e. advection of temperature
;Tgrx = advT[1]			;longitudinal gradient
;Tgry = advT[2]			;latitudinal gradient


;print(Tadv)	;advection of temperature
;print(Tgrx)	;longitudinal gradient
;print(Tgry)	;latitudinal gradient

;;;calculate wind direction
;wdir = wind_direction(u,v,0)

copy_VarMeta(temp,Tadv)


;********************************************
;;Write out netCDF file
;********************************************

;;set-up output directory and file
odir = "/srv/ccrc/data04/z5026024/CMIP5/temp_advection_data/tas_Tadv_data/Tadv_tas_day_"+Data+"_1950-2099_2.5x2.5.nc"
system("/bin/rm -f " + odir)			; remove any pre-existing file
ofile = addfile(odir,"c")			; open output netCDF file

;;add variables to output directly
ofile->lon		= lons
ofile->lat		= lats
ofile->time		= time
ofile->Tadv		= Tadv

;;create global attributes
fAtt			= True			;assign file attributes
fAtt@title		= "Climate Data Interface version 1.5.3 (http://code.zmaw.de/projects/cdi)"
;fAtt@source_file	= indata
fAtt@Conventions	= "CF-1.0"
fAtt@creation_date	= systemfunc("date")
fileattdef(ofile, fAtt)				;copy file attributes

;;copy attributes of new variable
filevarattdef(ofile, "Tadv", Tadv)

end
