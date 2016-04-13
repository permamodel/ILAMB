load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12

nlat0=2160
nlon0=4320

StartYear=1981
EndYear=2011
nyer=EndYear-StartYear + 1

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

;lat=fspan(-89.75,89.75,nlat)
;lon=fspan(-179.75,179.75,nlon)

; +++++++ generate data in 0.5x0.5 ++++++++
;nlat=360
;nlon=720
;lat=fspan(-89.75,89.75,nlat)
;lon=fspan(-179.75,179.75,nlon)

; +++++++ generate data in 1x1 ++++++++
;nlat=180
;nlon=360
;lat=fspan( -89.5, 89.5,nlat)
;lon=fspan(-179.5,179.5,nlon)

; +++++++ generate data in 2.5x2.5 ++++++++
nlat1=360
nlon1=720
nlat=72
nlon=144
lat=fspan( -88.75, 88.75,nlat)
lon=fspan(-178.75,178.75,nlon)

; ----------------  calculating No.of days from 1850 through 1900  ---------------
   ijk=0
do iiy = 1850, 1980

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
VarName     = "lai"
VarLongName = "leaf area index"
VarUnit     = "1/10"
Title       = "derived AVHRR BU leaf area index"
Source      = "1/12 degree AVHRR BU leaf area index"
TimeStep    = "monthly"

; ----------------  reading in AVHRR lai  ---------------
print("reading in AVHRR LAI")

datadir="$ILAMB_DATADIR/lai/AVHRR"

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

   FileIn=datadir + "/original/temp/lai_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".dat"

   time = time + int2dble(nday(iim-1))

   if (fileexists(FileIn)) then
      print(FileIn)

      ttt=new((/nlat,nlon/), float)

      ttt = -999

      temp=fbindirread(FileIn,0,(/nlat0,nlon0/),"float")

      temp=where(temp.lt.0, -999, temp)
      temp=where(temp.gt.7, -999, temp)

      temp@_FillValue=-999

      ; +++++++ generate data in 0.5x0.5 ++++++++
      ;do ny=0,nlat0-1,6
      ;do nx=0,nlon0-1,6
      ;   if (any(.not.ismissing(ndtooned(temp(ny:ny+5,nx:nx+5))))) then
      ;      ttt(ny/6,nx/6)=avg(temp(ny:ny+5,nx:nx+5))
      ;   end if
      ;end do
      ;end do

      ; +++++++ generate data in 1x1 ++++++++
      ;do ny=0,nlat0-1,12
      ;do nx=0,nlon0-1,12
      ;   if (any(.not.ismissing(ndtooned(temp(ny:ny+11,nx:nx+11))))) then
      ;      ttt(ny/12,nx/12)=avg(temp(ny:ny+11,nx:nx+11))
      ;   end if
      ;end do
      ;end do

      ; +++++++ generate data in 2.5x2.5 ++++++++
      do ny=0,nlat0-1,30
      do nx=0,nlon0-1,30
         if (any(.not.ismissing(ndtooned(temp(ny:ny+29,nx:nx+29))))) then
            ttt(ny/30,nx/30)=avg(temp(ny:ny+29,nx:nx+29))
         end if
      end do
      end do

      delete(temp)

      ttt@_FillValue=-999

      ; +++++++ generate data in 0.5x0.5 ++++++++
      ;FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
      ;       "/lai_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

      ; +++++++ generate data in 1x1 ++++++++
      ;FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
      ;       "/lai_1x1_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

      ; +++++++ generate data in 2.5x2.5 ++++++++
      FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
             "/lai_2.5x2.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

      print(FileOut)
      tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ttt, time, lat, lon, FileOut)

      delete(ttt)

   end if
   ijk=ijk+1
end do
end do

end
