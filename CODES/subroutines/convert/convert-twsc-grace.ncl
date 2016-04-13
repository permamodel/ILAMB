load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12

nlat0=180
nlon0=360

nlat=360
nlon=720

StartYear=2002
EndYear=2013
nyer=EndYear-StartYear + 1

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

lat=fspan(-89.75,89.75,nlat)
lon=fspan(-179.75,179.75,nlon)

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
;VarName     = "twsc"
;VarLongName = "terrestrial water storage change"
VarName     = "twsa"
VarLongName = "terrestrial water storage anomaly"
VarUnit     = "kg/m2/s"
Title       = "derived GRACE terrestrial water storage change"
Source      = "1 degree JPL GRACE Tellus"
TimeStep    = "monthly"

; ----------------  reading in AVHRR lai  ---------------
print("reading in JPL GRACE Tellus")

datadir="$ILAMB_DATADIR/twsc/GRACE"

FileIn1=datadir + "/original/CLM4.SCALE_FACTOR.DS.G300KM.RL05.DSTvSCS1401.nc"
FileIn2=datadir + "/original/GRCTellus.JPL.200204_201312.LND.RL05.DSTvSCS1401.nc"

if (fileexists(FileIn1)) then
   print(FileIn1)
   print(FileIn2)

   f1=addfile(FileIn1, "r")
   f2=addfile(FileIn2, "r")

   scals = f1->SCALE_FACTOR
   tts   = f2->lwe_thickness

   scals=where(ismissing(scals), -999, scals)
   tts  =where(ismissing(tts), -999, tts)

   scals@_FillValue=-999
   tts@_FillValue  =-999

end if

datadir="$ILAMB_DATADIR/twsa/GRACE"

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

   if (iiy.eq.2002 .and. iim.le.3) then
   else
      do ny=0,nlat0-1
      do nx=0,nlon0-1
         ttt(ny*2:ny*2+1,nx*2:nx*2+1)=tts(ijk,ny,nx)*scals(ny,nx)*10
      end do
      end do

      ttt = ttt/(3600.0*24.0*int2flt(nday(iim-1)))

      ijk=ijk+1
   end if

   tmp=ttt
   do nx=0, nlon/2-1
      ttt(:,nx)=tmp(:,nlon/2+nx)
      ttt(:,nlon/2+nx)=tmp(:,nx)
   end do
   delete(tmp)

   ttt@_FillValue=-999

   FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
          "/" + str_lower(VarName) + "_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"
   print(FileOut)
   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                        ttt, time, lat, lon, FileOut)

   delete(ttt)
end do
end do

end
