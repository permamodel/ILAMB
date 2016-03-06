load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12

start_year=1901
end_year=2010
nyer=end_year-start_year + 1

ntot=nyer*nmon

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

; ----------------  reading in GPCC pr  ---------------
print("reading in pr")

datadir="/gdata/randerson3/mmu/ILAMB/DATA/pr/GPCC"

; ------- read gpcc data -----

;FileIn=datadir + "/original/precip.mon.total.v6.nc"
FileIn=datadir + "/original/precip.mon.total.2.5x2.5.v6.nc"
;FileIn=datadir + "/original/precip.mon.total.1x1.v6.nc"
print(FileIn)

f2=addfile(FileIn, "r")

lat = f2->lat
lon = f2->lon
ts  = f2->precip

lat = lat(::-1)
lon = lon - 180.

nlat = dimsizes(lat)
nlon = dimsizes(lon)
 
print(lat)
print(lon)

ts = where(ismissing(ts), -999, ts)
ts = where(ts.le.-999,    -999, ts)
ts@_FillValue=-999

tmp=ts(:,::-1,:)
do nx=0, nlon/2-1
   ts(:,:,nx)=tmp(:,:,nlon/2+nx)
   ts(:,:,nlon/2+nx)=tmp(:,:,nx)
end do

delete(tmp)

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "pr"
VarLongName = "precipitation"
VarUnit     = "Kg m-2 s-1"
Title       = "derived GPCC version 6 precipitation"
Source      = "GPCC version 6 precipitation"
TimeStep    = "monthly"

   ij=0
do iiy = 1850, start_year-1

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      ntim = 366
   else
      ntim = 365
   end if

   ij = ij + ntim
end do

time = int2dble(ij)

   ijk = 0
do iiy = start_year, end_year
do iim = 1, nmon

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      nday(1) = 29
   else
      nday(1) = 28
   end if

   time = time + int2dble(nday(iim-1))

   ttt=ts(ijk,:,:)/(24.0*3600.0*int2flt(nday(iim-1)))

   FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
           "/pr_2.5x2.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"
   print(FileOut)
   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ttt, time, lat, lon, FileOut)

   ijk = ijk+1
   delete(ttt)
   delete(tttt)
end do
end do

print(ijk)

end
