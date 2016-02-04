load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12

nlat0=180
nlon0=360

StartYear=2000
EndYear=2013
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

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "rsns"
VarLongName = "surface net shortwave radiation"
VarUnit     = "Watt/m2"
Title       = "derived CERES EBAF Radiation"
Source      = "1 degree CERES EBAF Radiation"
TimeStep    = "monthly"

; ----------------  reading in CERES radiation  ---------------
;+++ rsds: sfc_sw_down_all_mon
;+++ rsus: sfc_sw_up_all_mon
;+++ rsns: sfc_net_sw_all_mon
;+++ rlds: sfc_lw_down_all_mon
;+++ rlus: sfc_lw_up_all_mon
;+++ rlns: sfc_net_lw_all_mon
;+++ rns: sfc_net_tot_all_mon

;+++ rnt: toa_net_all_mon
;+++ rsdt: toa_sw_all_mon
;+++ rlut: toa_lw_all_mon

print("reading in CERES Radiation")

datadir="$ILAMB_ROOT/DATA/" + VarName + "/CERES"

FileIn=datadir + "/original/CERES_EBAF-Surface_Ed2.7_Subset_200003-201303.nc"
;FileIn=datadir + "/original/CERES_EBAF-TOA_Ed2.8_Subset_200003-201312.nc"

if (fileexists(FileIn)) then
   print(FileIn)

   f1=addfile(FileIn, "r")

   ;tts   = f1->sfc_sw_down_all_mon
   ;tts  = f1->sfc_sw_up_all_mon
   tts  = f1->sfc_net_sw_all_mon
   ;tts  = f1->sfc_net_tot_all_mon

   tts  =where(tts.eq.0, -999, tts)
   tts  =where(tts.lt.-900, -999, tts)
   tts  =where(tts.gt.900, -999, tts)
   tts  =where(ismissing(tts), -999, tts)

   tts@_FillValue  =-999

end if

print(min(tts))
print(max(tts))
print(avg(tts))

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

   ttt=new((/nlat,nlon/), float)
   ttt = -999

   if (iiy.eq.2000 .and. iim.le.2) then
   else

      do ny=0,nlat0-1
      do nx=0,nlon0-1
      
         ; +++++++ generate data in 0.5x0.5 ++++++++
         ;ttt(ny*2:ny*2+1,nx*2:nx*2+1)=tts(ijk,ny,nx)
      
         ; +++++++ generate data in 1x1 ++++++++
         ttt(ny,nx)=tts(ijk,ny,nx)
      
      end do
      end do

      ; +++++++ start to generate data in 2.5x2.5 ++++++++
      ;temp=new((/nlat1,nlon1/), float)
      ;temp = -999
      ;
      ;do ny=0,nlat0-1
      ;do nx=0,nlon0-1
      ;   temp(ny*2:ny*2+1,nx*2:nx*2+1)=tts(ijk,ny,nx)
      ;end do
      ;end do
      ;
      ;temp@_FillValue = -999
      ;
      ;do ny=0,nlat1-1,5
      ;do nx=0,nlon1-1,5
      ;   ttt(ny/5,nx/5)=avg(temp(ny:ny+4,nx:nx+4))
      ;end do
      ;end do
      ;
      ;delete(temp)
      ; +++++++ end to generate data in 2.5x2.5 ++++++++

      ijk=ijk+1
   end if

   tmp=ttt
   do nx=0, nlon/2-1
      ttt(:,nx)=tmp(:,nlon/2+nx)
      ttt(:,nlon/2+nx)=tmp(:,nx)
   end do
   delete(tmp)

   ttt@_FillValue=-999

   ; +++++++ generate data in 0.5x0.5 ++++++++
   ;FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;       "/" + VarName + "_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 1x1 ++++++++
   FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
          "/" + VarName + "_1x1_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 2.5x2.5 ++++++++
   ;FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;       "/" + VarName + "_2.5x2.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   print(FileOut)

   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                        ttt, time, lat, lon, FileOut)

   delete(ttt)
end do
end do

end
