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
end_year=2013
nyer=end_year-start_year + 1

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

lat=fspan(-89.75,89.75,nlat)
lon=fspan(-179.75,179.75,nlon)

datadir="/gdata/randerson3/mmu/ILAMB/DATA/sst/CRU"

; -------- read regions data ----------------
fina="$ILAMB_DATADIR/GFED_regions/basis0.5x0.5.15regions_mod+noGreenland"
region0=asciiread(fina,(/nlat,nlon/),"integer")
region=int2flt(region0(::-1,:))
delete(region0)

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

FileIn=datadir + "/original/absolute.nc"
print(FileIn)

f1=addfile(FileIn, "r")

ts0 =f1->tem
lat0=f1->lat
lon0=f1->lon

tsm = short2flt(ts0)

FileIn=datadir + "/original/HadSST.3.1.0.0.median.nc"
print(FileIn)

f2=addfile(FileIn, "r")

ts =f2->sst
time=f2->time

ts=where(ismissing(ts), 0, ts)
ts=where(ts.gt.999, 0, ts)
ts=where(ts.lt.-999, 0, ts)
ts@_FillValue=-999

delete(ts0)

ts = ts(:,::-1,:)
tsm = tsm(:,::-1,:)

lat0 = lat0(::-1)

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "sst"
VarLongName = "sea surface temperature"
VarUnit     = "K"
Title       = "derived CRU (5x5) Sea Surface Temperature"
Source      = "CRU HadSST v3.1"
TimeStep    = "monthly"

   ijk=(1979-1850)*nmon
do iiy = start_year, end_year
   print(iiy)

do iim=1,nmon

   tt1 = ts(ijk,:,:) + tsm(iim-1,:,:) + 273.16

   ttt = f2fsh (tt1, (/nlat,nlon/) )

   ttt = where(region.gt.0, -999, ttt)
   ttt@_FillValue=-999

   FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
           "/sst_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"
   print(FileOut)
   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ttt, time(ijk), lat, lon, FileOut)

   ijk=ijk+1
   print(avg(tt1))
   print(min(tt1))
   print(max(tt1))
   print(avg(ttt))
   print(min(ttt))
   print(max(ttt))

   delete(tt1)
   delete(ttt)
end do
end do
print(ijk)

end
