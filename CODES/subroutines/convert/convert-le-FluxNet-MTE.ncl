load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12
nlat0=360
nlon0=720

StartYear=1982
EndYear=2008
nyer=EndYear-StartYear + 1

ntot = nyer*nmon

varID="le"

lat0=new((/nlat0/), float)
lon0=new((/nlon0/), float)

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

; ----------------  calculating No.of days from 1850 through 1981  ---------------
   ijk=0
do iiy = 1850, 1981

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

datadir="/gdata/randerson3/mmu/ILAMB/DATA/le/FLUXNET-MTE"

FileIn=datadir + "/original/MR_LHF.nc"
print(FileIn)

f1=addfile(FileIn, "r")

ts0 =f1->LHF
lat0=f1->LAT
lon0=f1->LON

;ts0=ts0*1.0e-3/(3600*24)

ts0=where(ismissing(ts0), -999, ts0)
ts0=where(ts0.le.-999,    -999, ts0)
ts0=where(ts0.ge.999,     -999, ts0)
ts0@_FillValue=-999

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = varID
VarLongName = "latent heat flux"
VarUnit     = "W/m2"
Title       = "derived FluxNet MTE"
Source      = "FluxNet MTE"
TimeStep    = "monthly"

DataDir = "/gdata/randerson3/mmu/ILAMB/DATA/" + str_lower(varID) + "/FLUXNET-MTE"

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
   ts=-999

   ; +++++++ generate data in 0.5x0.5 ++++++++
   ;ts = ts0(ijk,:,:)

   ; +++++++ generate data in 1x1 ++++++++
   do ny=0,nlat0-1,2
   do nx=0,nlon0-1,2
      if (all(ismissing(ts0(ijk,ny:ny+1,nx:nx+1)))) then
         ts(ny/2,nx/2)=-999
      else
         ts(ny/2,nx/2)=avg(ts0(ijk,ny:ny+1,nx:nx+1))
      end if
   end do
   end do

   ; +++++++ generate data in 2.5x2.5 ++++++++
   ;do ny=0,nlat0-1,5
   ;do nx=0,nlon0-1,5
   ;   if (all(ismissing(ts0(ijk,ny:ny+4,nx:nx+4)))) then
   ;      ts(ny/5,nx/5)=-999
   ;   else
   ;      ts(ny/5,nx/5)=avg(ts0(ijk,ny:ny+4,nx:nx+4))
   ;   end if
   ;end do
   ;end do

   ts@_FillValue=-999

   ; +++++++ generate data in 0.5x0.5 ++++++++
   ;FileOut=DataDir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;        "/" + str_lower(varID) + "_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 1x1 ++++++++
   FileOut=DataDir + "/derived/" + sprinti("%0.4i",iiy) + \
           "/" + str_lower(varID) + "_1x1_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

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

end
