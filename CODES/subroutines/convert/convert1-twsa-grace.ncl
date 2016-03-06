load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12

nlat0=180
nlon0=360

StartYear=2002
EndYear=2014
nyer=EndYear-StartYear + 1

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

lat0=fspan(-89.5,89.5,nlat0)
lon0=fspan(-179.5,179.5,nlon0)

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
do iiy = 1850, 2001

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
VarName     = "twsa"
VarLongName = "terrestrial water storage anomaly"
VarUnit     = "cm"
Title       = "derived GRACE terrestrial water storage change"
Source      = "1 degree GRACE Tellus CSR"
TimeStep    = "monthly"

; ----------------  reading in AVHRR lai  ---------------
print("reading in JPL GRACE Tellus")

datadir="$ILAMB_ROOT/DATA/" + VarName + "/GRACE"

FileIn1=datadir + "/original/CLM4.SCALE_FACTOR.DS.G300KM.RL05.DSTvSCS1409.nc"
FileIn2=datadir + "/original/GRCTellus.CSR.200204_201409.LND.RL05.DSTvSCS1409.nc"

if (fileexists(FileIn1)) then
   print(FileIn1)
   print(FileIn2)

   f1=addfile(FileIn1, "r")
   f2=addfile(FileIn2, "r")

   scals = f1->SCALE_FACTOR
   tts   = f2->lwe_thickness
   times = f2->time

   dates = cd_calendar(times, 0)

   print(dates(:,0))
   print(dates(:,1))
   print(dates(:,2))

   scals=where(ismissing(scals), -999, scals)
   tts  =where(ismissing(tts), -999, tts)

   scals@_FillValue=-999
   tts@_FillValue  =-999
end if

twsa=new((/nyer,nmon,nlat0,nlon0/), float)
twsa=-999

do nt=0,dimsizes(times)-1
   iiy=floattoint(dates(nt,0))
   iiy0=floattoint(dates(0,0))
   iim=floattoint(dates(nt,1))
   twsa(iiy-iiy0,iim-1,:,:)=tts(nt,:,:)*scals
end do

twsa@_FillValue  =-999

   ijk=0
do iiy = StartYear, EndYear
   iy=iiy-2002
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

   ttt=new((/nlat,nlon/), float)

   ttt = -999

   do ny=0,nlat0-1
   do nx=0,nlon0-1
   
   ;   ; +++++++ generate data in 0.5x0.5 ++++++++
   ;   ;ttt(ny*2:ny*2+1,nx*2:nx*2+1)=twsa(iy,iim-1,ny,nx)
   ;
      ; +++++++ generate data in 1x1 ++++++++
      ttt(ny,nx)=twsa(iy,iim-1,ny,nx)
   
   end do
   end do

   ; +++++++ start to generate data in 2.5x2.5 ++++++++
   ;temp=new((/nlat1,nlon1/), float)
   ;temp = -999
   ;
   ;do ny=0,nlat0-1
   ;do nx=0,nlon0-1
   ;   temp(ny*2:ny*2+1,nx*2:nx*2+1)=twsa(iy,iim-1,ny,nx)
   ;end do
   ;end do
   ;
   ;temp@_FillValue = -999
   ;
   ;do ny=0,nlat1-1,5
   ;do nx=0,nlon1-1,5
   ;   if (all(ismissing(temp(ny:ny+4,nx:nx+4)))) then
   ;      ttt(ny/5,nx/5)=-999
   ;   else
   ;      ttt(ny/5,nx/5)=avg(temp(ny:ny+4,nx:nx+4))
   ;   end if
   ;end do
   ;end do
   ;
   ;delete(temp)
   ; +++++++ end to generate data in 2.5x2.5 ++++++++

   ttt = ttt/(3600.0*24.0*0.1)

   tmp=ttt
   do nx=0, nlon/2-1
      ttt(:,nx)=tmp(:,nlon/2+nx)
      ttt(:,nlon/2+nx)=tmp(:,nx)
   end do
   delete(tmp)

   ttt@_FillValue=-999

   ; +++++++ generate data in 0.5x0.5 ++++++++
   ;FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;       "/" + str_lower(VarName) + "_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 1x1 ++++++++
   FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
          "/" + str_lower(VarName) + "_1x1_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 2.5x2.5 ++++++++
   ;FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;       "/" + str_lower(VarName) + "_2.5x2.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   print(FileOut)
   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ttt, time, lat, lon, FileOut)

   ijk=ijk+1

   print(ijk)
   
   delete(ttt)
end do
end do

end
