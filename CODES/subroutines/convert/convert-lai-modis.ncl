load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12
nlat0=360
nlon0=720

StartYear=2000
EndYear=2005
nyer=EndYear-StartYear + 1

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

; +++++++ generate data in 0.5x0.5 ++++++++
;nlat=360
;nlon=720
;lat=fspan(-89.75,89.75,nlat)
;lon=fspan(-179.75,179.75,nlon)

; +++++++ generate data in 1x1 ++++++++
nlat=180
nlon=360
lat=fspan( -89.5, 89.5,nlat)
lon=fspan(-179.5,179.5,nlon)

; +++++++ generate data in 2.5x2.5 ++++++++
;nlat1=360
;nlon1=720
;nlat=72
;nlon=144
;lat=fspan( -88.75, 88.75,nlat)
;lon=fspan(-178.75,178.75,nlon)

; ----------------  calculating No.of days from 1850 through 1900  ---------------
   ijk=0
do iiy = 1850, 1999

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

; ----------------  reading in MODIS lai  ---------------
print("reading in MODIS LAI")

datadir="/gdata/randerson3/mmu/ILAMB/DATA/lai/MODIS"

FileIn=datadir + "/original/MODIS_LAI_ALLMONS_climo.nc"
print(FileIn)

f1=addfile(FileIn, "r")

ts0 =f1->TLAI
lat0=f1->lat
lon0=f1->lon

ts0=where(ismissing(ts0), -999, ts0)
ts0=where(ts0.gt.999,     -999, ts0)
ts0@_FillValue=-999

tmp=ts0
do nx=0, nlon/2-1
   ts0(:,:,nx)=tmp(:,:,nlon/2+nx)
   ts0(:,:,nlon/2+nx)=tmp(:,:,nx)
end do
delete(tmp)

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "lai"
VarLongName = "leaf area index"
VarUnit     = "1/10"
Title       = "derived MODIS total leaf area"
Source      = "MODIS total leaf area index"
TimeStep    = "monthly climatology"

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
      
   ts=new((/nlat,nlon/), float)
   
   ; +++++++ generate data in 0.5x0.5 ++++++++
   ;ts = ts0(iim-1,:,:)
   
   ; +++++++ generate data in 1x1 ++++++++
   do ny=0,nlat0-1,2
   do nx=0,nlon0-1,2
      if (all(ismissing(ts0(iim-1,ny:ny+1,nx:nx+1)))) then
         ts(ny/2,nx/2)=-999
      else
         ts(ny/2,nx/2)=avg(ts0(iim-1,ny:ny+1,nx:nx+1))
      end if
   end do
   end do
   
   ; +++++++ generate data in 2.5x2.5 ++++++++
   ;do ny=0,nlat0-1,5
   ;do nx=0,nlon0-1,5
   ;   if (all(ismissing(ts0(iim-1,ny:ny+4,nx:nx+4)))) then
   ;      ts(ny/5,nx/5)=-999
   ;   else
   ;      ts(ny/5,nx/5)=avg(ts0(iim-1,ny:ny+4,nx:nx+4))
   ;   end if
   ;end do
   ;end do

   ; +++++++ generate data in 0.5x0.5 ++++++++
   ;FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;        "/lai_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 1x1 ++++++++
   FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
           "/lai_1x1_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 2.5x2.5 ++++++++
   ;FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;        "/lai_2.5x2.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   print(FileOut)
   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ts, time, lat, lon, FileOut)

   ijk=ijk+1

   delete(ts)
end do
end do

end
