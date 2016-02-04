load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12
nlat=360
nlon=720

start_year=1979
end_year=2012
nyer=end_year-start_year + 1

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

; ----------------  calculating No.of days from 1850 through 1900  ---------------
   ijk=0
do iiy = 1850, 1900

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      ntim=366
   else
      ntim=365
   end if

   ijk = ijk + ntim
end do

time0 = int2dble(ijk)

; ----------------  reading in CRU temperature  ---------------
print("reading in tas")

datadir="/gdata/randerson3/mmu/ILAMB/DATA/tas/CRU"

FileIn=datadir + "/original/cru_ts3.21.1901.2012.tmp.dat.nc"
print(FileIn)

f1=addfile(FileIn, "r")

ts0 =f1->tmp
lat0=f1->lat
lon0=f1->lon
time=f1->time

ts   = dble2flt(ts0) + 273.16
lat  = dble2flt(lat0)
lon  = dble2flt(lon0)
time = time + time0

ts=where(ismissing(ts), -999, ts)
ts=where(ts.gt.999, -999, ts)
ts@_FillValue=-999

delete(ts0)
delete(lat0)
delete(lon0)

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "tas"
VarLongName = "surface air temperature"
VarUnit     = "K"
Title       = "derived CRU high resolution (0.5x0.5) Mean Temperature"
Source      = "CRU TS3.21 Mean Temperature"
TimeStep    = "monthly"

   ijk=(1978-1900)*nmon
do iiy = start_year, end_year
   print(iiy)

do iim=1,nmon

   FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
           "/tas_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"
   print(FileOut)
   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ts(ijk,:,:), time(ijk), lat, lon, FileOut)

   ijk=ijk+1
end do
end do

end
