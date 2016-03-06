load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12

nlat0=180
nlon0=360

StartYear=1984
EndYear=2007
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

; ----------------  calculating No.of days from 1850 through 1983  ---------------
   ijk=0
do iiy = 1850, 1983

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
VarLongName = "Surface all sky net shortwave radiation"
VarUnit     = "Watt m-2"
Title       = "derived GEWEX SRB Radiation"
Source      = "1 degree GEWEX SRB Radiation"
TimeStep    = "monthly"

; ----------------  reading in GEWEX SRB radiation  ---------------
;+++ rsds: sw_sfc_dn
;+++ rsus: sw_sfc_up
;+++ rlds: lw_sfc_dn
;+++ rlus: lw_sfc_up

;+++ rsdt: sw_toa_dn
;+++ rsut: sw_toa_up
;+++ rlut: sw_toa_up

print("reading in GEWEX SRB Radiation")

datadir0="$ILAMB_ROOT/DATA/rns/GEWEX.SRB"

datadir="$ILAMB_ROOT/DATA/" + VarName + "/GEWEX.SRB"

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

   FileIn1=datadir0 + "/original/" + sprinti("%0.4i",iiy) + "/srb_rel3.0_shortwave_monthly_utc_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"
   FileIn2=datadir0 + "/original/" + sprinti("%0.4i",iiy) + "/srb_rel3.1_longwave_monthly_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   if (fileexists(FileIn1)) then
      print(FileIn1)
      print(FileIn2)

      f1=addfile(FileIn1, "r")
      f2=addfile(FileIn2, "r")

      rsds   = f1->sw_sfc_dn
      rsus   = f1->sw_sfc_up
      rsdt   = f1->sw_toa_dn
      rsut   = f1->sw_toa_up

      rlds   = f2->lw_sfc_dn
      rlus   = f2->lw_sfc_up
      rlut   = f2->lw_toa_up

      rlds = where(rlds.eq.0, -999, rlds)
      rlus = where(rlus.eq.0, -999, rlus)
      rlut = where(rlut.eq.0, -999, rlut)

      rsds = where(rsds.eq.0, -999, rsds)
      rsdt = where(rsdt.eq.0, -999, rsdt)
      rsus = where(rsus.eq.0, -999, rsus)
      rsut = where(rsut.eq.0, -999, rsut)

      rsds@_FillValue  =-999
      rsus@_FillValue  =-999
      rsut@_FillValue  =-999
      rsdt@_FillValue  =-999
      rlds@_FillValue  =-999
      rlus@_FillValue  =-999
      rlut@_FillValue  =-999

      rsns   = rsds - rsus
      rlns   = rlds - rlus

      rns    = rsds - rsus + rlds - rlus
      rnt    = rsdt - rsut - rlut

      rsns@_FillValue  =-999
      rlns@_FillValue  =-999
      rns@_FillValue   =-999
      rnt@_FillValue   =-999

      albedo = rsus/rsds

      tts = rsns(0,:,:)

      tts@_FillValue  =-999
   end if

   print(min(tts))
   print(max(tts))
   print(avg(tts))

   time = time + int2dble(nday(iim-1))

   ttt=new((/nlat,nlon/), float)

   ttt = -999

   do ny=0,nlat0-1
   do nx=0,nlon0-1
   
      ; +++++++ generate data in 0.5x0.5 ++++++++
      ;ttt(ny*2:ny*2+1,nx*2:nx*2+1)=tts(ny,nx)
   
      ; +++++++ generate data in 1x1 ++++++++
      ttt(ny,nx)=tts(ny,nx)
   
   end do
   end do

   ; +++++++ start to generate data in 2.5x2.5 ++++++++
   ;temp=new((/nlat1,nlon1/), float)
   ;temp = -999
   ;
   ;do ny=0,nlat0-1
   ;do nx=0,nlon0-1
   ;   temp(ny*2:ny*2+1,nx*2:nx*2+1)=tts(ny,nx)
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

   tmp = ttt
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

   delete(tts)
   delete(ttt)
end do
end do

end
