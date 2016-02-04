load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12
nlat0=720
nlon0=1440

StartYear=1980
EndYear=2011
nyer=EndYear-StartYear + 1

varID="et"

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

lat0 = fspan(-89.875,89.875,nlat0)
lon0 = fspan(-179.875,179.875, nlon0)

; +++++++ generate data in 0.5x0.5 ++++++++
nlat=360
nlon=720
lat=fspan(-89.75,89.75,nlat)
lon=fspan(-179.75,179.75,nlon)

; +++++++ generate data in 1x1 ++++++++
;nlat=180
;nlon=360
;lat=fspan( -89.5, 89.5,nlat)
;lon=fspan(-179.5,179.5,nlon)

; +++++++ generate data in 2.5x2.5 ++++++++
;nlat1=360
;nlon1=720
;nlat=72
;nlon=144
;lat=fspan( -88.75, 88.75,nlat)
;lon=fspan(-178.75,178.75,nlon)

; ----------------  calculating No.of days from 1850 through 1981  ---------------
   ijk=0
do iiy = 1850, 1979

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

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = varID
VarLongName = "Evapotranspiration"
VarUnit     = "Kg/m2/s"
Title       = "derived GLEAM ET"
Source      = "GLEAM ET in 0.25x0.25"
TimeStep    = "monthly"

DataDir = "/gdata/randerson3/mmu/ILAMB/DATA/" + str_lower(varID) + "/GLEAM"

do iiy = StartYear, EndYear
   print(iiy)

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      nday(1)=29
   else
      nday(1)=28
   end if

   ; ----------------  reading in FluxNet-MTE data  ---------------
   print("reading in GLEAM " + varID)

   FileIn=DataDir + "/original/" + sprinti("%0.4i",iiy) + \
         "/E_" + sprinti("%0.4i",iiy) + ".nc"
   print(FileIn)

   f1=addfile(FileIn, "r")
 
   tmp = f1->E

   tmp1 = dble2flt(tmp(:,:,::-1))

   tmp1 = where(tmp1.le.-9, 0, tmp1)
   tmp1 = where(ismissing(tmp1), 0, tmp1)

   tmp1@_FillValue = -999

   tmp1 = tmp1/(3600*24)

   tmp1@_FillValue = -999

   nt1=0
do iim=1,nmon

   ts=new((/nlat,nlon/), float)

   ts = -999

   nt2 = nt1 + nday(iim-1) - 1

   print(dimsizes(tmp1))
   print(nt1)
   print(nt2)

   ; +++++++ generate data in 0.5x0.5 ++++++++
   do ny=0,nlat0-1,2
   do nx=0,nlon0-1,2
      if (all(ismissing(tmp1(nt1:nt2,nx:nx+1,ny:ny+1)))) then
         ts(ny/2,nx/2)=-999
      else
         ts(ny/2,nx/2)=avg(tmp1(nt1:nt2,nx:nx+1,ny:ny+1))
      end if
   end do
   end do

   ; +++++++ generate data in 1x1 ++++++++
   ;do ny=0,nlat0-1,4
   ;do nx=0,nlon0-1,4
   ;   if (all(ismissing(tmp1(nt1:nt2,nx:nx+3,ny:ny+3)))) then
   ;      ts(ny/4,nx/4)=-999
   ;   else
   ;      ts(ny/4,nx/4)=avg(tmp1(nt1:nt2,nx:nx+3,ny:ny+3))
   ;   end if
   ;end do
   ;end do

   ; +++++++ generate data in 2.5x2.5 ++++++++
   ;do ny=0,nlat0-1,10
   ;do nx=0,nlon0-1,10
   ;   if (all(ismissing(tmp1(nt1:nt2,nx:nx+9,ny:ny+9)))) then
   ;      ts(ny/10,nx/10)=-999
   ;   else
   ;      ts(ny/10,nx/10)=avg(tmp1(nt1:nt2,nx:nx+9,ny:ny+9))
   ;   end if
   ;end do
   ;end do

   ts = where(ts.le.0, -999, ts)

   ts@_FillValue = -999

   time = time + int2dble(nday(iim-1))

   ; +++++++ read desert data in 0.5x0.5 ++++++++
   FileOut=DataDir + "/derived/" + sprinti("%0.4i",iiy) + \
           "/" + str_lower(varID) + "_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ read desert data in 1x1 ++++++++
   ;FileOut=DataDir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;        "/" + str_lower(varID) + "_1x1_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ read desert data in 2.5x2.5 ++++++++
   ;FileOut=DataDir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;        "/" + str_lower(varID) + "_2.5x2.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   print(FileOut)

   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ts, time, lat, lon, FileOut)

   nt1 = nt2 + 1

   delete(ts)
end do

   delete(tmp)
   delete(tmp1)
end do

end
