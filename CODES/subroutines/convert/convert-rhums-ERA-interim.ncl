load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12

nlat0=241
nlon0=480

nlat1=720
nlon1=1440

StartYear=1979
EndYear=2014
nyer=EndYear-StartYear + 1

ntot = nyer*nmon

varID="rhums"

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

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
;nlat=72
;nlon=144
;lat=fspan( -88.75, 88.75,nlat)
;lon=fspan(-178.75,178.75,nlon)

; ----------------  calculating No.of days from 1850 through 1981  ---------------
   ijk=0
do iiy = 1850, 1978

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

; ----------------  reading in FluxNet-MTE data  ---------------
print("reading in FluxNet-MTE " + varID)

datadir="/gdata/randerson3/mmu/ILAMB/DATA/rhums/ERA"

FileIn1=datadir + "/original/d2m-ERA-interim-197901-201412.nc"
FileIn2=datadir + "/original/t2m-ERA-interim-197901-201412.nc"

print(FileIn1)
print(FileIn2)

f1=addfile(FileIn1, "r")
f2=addfile(FileIn2, "r")

ts1 =f1->d2m
ts2 =f2->t2m

d2m = short2flt(ts1)
t2m = short2flt(ts2)

d2m = d2m(:,::-1,:)
t2m = t2m(:,::-1,:)

rhum0 = relhum_ttd (t2m, d2m, 0)

lat0=f1->latitude
lon0=f1->longitude

temp = rhum0

do nx=0,nlon0/2-1
   rhum0(:,:,nx) = temp(:,:,nx+nlon0/2)
   rhum0(:,:,nx+nlon0/2) = temp(:,:,nx)
end do

lat0 = lat0(::-1)
lon0 = lon0 - 180.0

; interpolate from 0.75x0.75 to 0.5x0.5
;rhum = f2fsh (rhum0, (/nlat,nlon/) ) 

rhum = area_conserve_remap (lon0, lat0, rhum0, lon, lat, False)

delete(temp)

rhum=where(ismissing(rhum), -999, rhum)
rhum=where(rhum.le.-999,    -999, rhum)
rhum=where(rhum.ge.999,     -999, rhum)
rhum@_FillValue=-999

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = varID
VarLongName = "2m Relative Humidity"
VarUnit     = "%"
Title       = "derived ERA interim"
Source      = "ERA interim"
TimeStep    = "monthly"

DataDir = "/gdata/randerson3/mmu/ILAMB/DATA/" + str_lower(varID) + "/ERA"

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

   time = time + int2dble(nday(iim-1))

   ts = rhum(ijk,:,:)

   print(max(rhum0(ijk,:,:)))
   print(min(rhum0(ijk,:,:)))
   print(avg(rhum0(ijk,:,:)))

   print(max(rhum(ijk,:,:)))
   print(min(rhum(ijk,:,:)))
   print(avg(rhum(ijk,:,:)))

   ;ts=new((/nlat,nlon/), float)
   ;ts=-999
   ;
   ; +++++++ generate data in 0.5x0.5 ++++++++
   ;do ny=0,nlat1-1,2
   ;do nx=0,nlon1-1,2
   ;   if (all(ismissing(rhum(ijk,ny:ny+1,nx:nx+1)))) then
   ;      ts(ny/2,nx/2)=-999
   ;   else
   ;      ts(ny/2,nx/2)=avg(rhum(ijk,ny:ny+1,nx:nx+1))
   ;   end if
   ;end do
   ;end do
   ;
   ; +++++++ generate data in 1x1 ++++++++
   ;do ny=0,nlat0-1,4
   ;do nx=0,nlon0-1,4
   ;   if (all(ismissing(rhum(ijk,ny:ny+3,nx:nx+3)))) then
   ;      ts(ny/4,nx/4)=-999
   ;   else
   ;      ts(ny/4,nx/4)=avg(rhum(ijk,ny:ny+3,nx:nx+3))
   ;   end if
   ;end do
   ;end do
   ;
   ; +++++++ generate data in 2.5x2.5 ++++++++
   ;do ny=0,nlat0-1,10
   ;do nx=0,nlon0-1,10
   ;   if (all(ismissing(rhum(ijk,ny:ny+9,nx:nx+9)))) then
   ;      ts(ny/10,nx/10)=-999
   ;   else
   ;      ts(ny/10,nx/10)=avg(rhum(ijk,ny:ny+9,nx:nx+9))
   ;   end if
   ;end do
   ;end do

   ts@_FillValue=-999

   ; +++++++ generate data in 0.5x0.5 ++++++++
   FileOut=DataDir + "/derived/" + sprinti("%0.4i",iiy) + \
           "/" + str_lower(varID) + "_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 1x1 ++++++++
   ;FileOut=DataDir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;        "/" + str_lower(varID) + "_1x1_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 2.5x2.5 ++++++++
   ;FileOut=DataDir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;        "/" + str_lower(varID) + "_2.5x2.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   print(FileOut)
   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ts, time, lat, lon, FileOut)

   ijk=ijk+1

   delete(ts)
end do
end do

print(max(rhum0))
print(min(rhum0))
print(avg(rhum0))

print(max(rhum))
print(min(rhum))
print(avg(rhum))

end
