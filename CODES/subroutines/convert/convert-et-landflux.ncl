load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12
nlat=360
nlon=720

StartYear=1989
EndYear=2005
nyer=EndYear-StartYear + 1

varID="et"

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

lat=new((/nlat/), float)
lon=new((/nlon/), float)

lat = fspan(-89.75,89.75,nlat)
lon = fspan(-179.75,179.75, nlon)

DataDir = "/gdata/randerson3/mmu/ILAMB/DATA/" + str_lower(varID) + "/LandFlux"

; ----------------  calculating No.of days from 1850 through 1988  ---------------
   ijk=0
do iiy = 1850, 1988

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      ntim=366
   else
      ntim=365
   end if

   ijk = ijk + ntim
end do

time = int2dble(ijk)

; ----------------  reading in LandFlux EVAL data  ---------------
print("reading in LandFlux EVAL " + varID)

FileIn = DataDir + "/original/LandFluxEVAL.merged.89-05.monthly.all.nc"

print(FileIn)

f1=addfile(FileIn, "r")
 
tmp =f1->ET_mean
lat1 =f1->lat
lon1 =f1->lon

tmp1 = dble2flt(tmp)

tmp1 = where(tmp1.le.-900, -999, tmp1)
tmp1 = where(ismissing(tmp1), -999, tmp1)

tmp1@_FillValue = -999

tmp1 = tmp1/(3600*24)

nlat1 = dimsizes(lat1)
nlon1 = dimsizes(lon1)

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = varID
VarLongName = "Evapotranspiration"
VarUnit     = "Kg/m2/s"
Title       = "derived LandFlx EVAL ET in 0.5x0.5"
Source      = "LandFlux EVAL ET in 1x1"
TimeStep    = "monthly"

   ijk=0
do iiy = StartYear, EndYear
   print(iiy)

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      nday(1)=29
   else
      nday(1)=28
   end if

do iim=1,nmon

   ts=new((/nlat,nlon/), float)

   ts = -999

   do ny=0,nlat1-1
      ny1=ny*2
      ny2=ny1+1
   do nx=0,nlon1-1
      nx1=nx*2
      nx2=nx1+1
      ts(ny1:ny2,nx1:nx2)=tmp1(ijk,ny,nx)
   end do
   end do

   ts@_FillValue = -999

   time = time + int2dble(nday(iim-1))

   FileOut=DataDir + "/derived/" + sprinti("%0.4i",iiy) + \
           "/" + str_lower(varID) + "_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"
   print(FileOut)

   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ts, time, lat, lon, FileOut)

   ijk=ijk+1

   delete(ts)
end do
end do

end
