load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;Script to mask  data to only include land areas;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;read-in input file
indatadir = "/srv/ccrc/data01/z5026024/snow_cover_data/"
indata = indatadir+"snc_day_CSIRO-Mk3-6-0_1950-2099_2.5x2.5.nc"
ifile = addfile(indata,"r")

var	= ifile->snc
lats	= ifile->lat
lons	= ifile->lon
time	= ifile->time


;;;mask ocean grid points, so only use land data
lsm_file = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")	;read in land/sea mask basemap file
lsm = landsea_mask(lsm_file->LSMASK,lats,lons)
landmask = mask(var,lsm.eq.0,False)					;mask out all ocean points from lsm

copy_VarMeta(var,landmask)

;;;write-out netCDF file
odir = "/srv/ccrc/data01/z5026024/snow_cover_data/snc_day_CSIRO-Mk3-6-0_1950-2099_masked_2.5x2.5.nc"
system("/bin/rm -f " + odir)			; remove any pre-existing file
ofile = addfile(odir,"c")			; open output netCDF file
;ofile@creation_date = systemfunc("date")

;;add variables to output directly
ofile->lon		= lons
ofile->lat		= lats
ofile->time		= time
ofile->snc		= landmask

;;create global attributes
fAtt			= True			;assign file attributes
fAtt@title		= "Climate Data Interface version 1.5.3 (http://code.zmaw.de/projects/cdi)"
fAtt@source_file	= indata
fAtt@Conventions	= "CF-1.0"
fAtt@creation_date	= systemfunc("date")
fileattdef(ofile, fAtt)				;copy file attributes

;;copy attributes of new variable
filevarattdef(ofile, "snc", landmask)
