load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12

nlat0=3600
nlon0=7200

StartYear=2000
EndYear=2014
nyer=EndYear-StartYear + 1

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

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
;nlat1=360
;nlon1=720
;nlat=72
;nlon=144
;lat=fspan( -88.75, 88.75,nlat)
;lon=fspan(-178.75,178.75,nlon)

; ----------------  calculating No.of days from 1850 through 1900  ---------------
   ijk=0
do iiy = 1850, StartYear-1

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
VarName     = "albedo"
VarLongName = "albedo"
VarUnit     = "unitless"
Title       = "derived MODIS MCD43C3"
Source      = "0.05 degree MODIS MCD43C3"
TimeStep    = "monthly"

; ----------------  reading in Albedo  ---------------
print("reading in Albedo")

datadir = "/gdata/randerson3/mmu/ILAMB/DATA/albedo/MODIS"

do iiy = StartYear, EndYear
   print(iiy)

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      nday(1)=29
      ntim   = 366
   else
      nday(1)=28
      ntim   = 366
   end if

   ijk=1
do iim=1,nmon

   time = time + int2dble(nday(iim-1))

   ; +++++++ generate data in 0.5x0.5 ++++++++
   FileIn=datadir + "/derived.v5.err/" + sprinti("%0.4i",iiy) + \
         "/" + VarName + "_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 1x1 ++++++++
   ;FileIn=datadir + "/derived.v5.err/" + sprinti("%0.4i",iiy) + \
   ;      "/" + VarName + "_1x1_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 2.5x2.5 ++++++++
   ;FileIn=datadir + "/derived.v5.err/" + sprinti("%0.4i",iiy) + \
   ;      "/" + VarName + "_2.5x2.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   print(FileIn)

   if (fileexists(FileIn)) then

      print(FileIn)

      ;setfileoption("bin","ReadByteOrder","BigEndian")

      fin=addfile(FileIn,"r")

      ttt=fin->albedo
      lat=fin->lat
      lon=fin->lon

      nlat = dimsizes(lat)
      nlon = dimsizes(lon)

      ttt@_FillValue = -999

      ttt = where(ttt.le.0, 0, ttt) 
      ttt = where(ismissing(ttt), 0, ttt) 

      ;tmp=ttt
      ;do nx=0, nlon/2-1
      ;   ttt(:,nx)=tmp(:,nlon/2+nx)
      ;   ttt(:,nlon/2+nx)=tmp(:,nx)
      ;end do
      ;delete(tmp)

      ttt@_FillValue=-999

      ; +++++++ generate data in 0.5x0.5 ++++++++
      FileOut=datadir + "/derived.v5/" + sprinti("%0.4i",iiy) + \
             "/" + VarName + "_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

      ; +++++++ generate data in 1x1 ++++++++
      ;FileOut=datadir + "/derived.v5/" + sprinti("%0.4i",iiy) + \
      ;       "/" + VarName + "_1x1_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

      ; +++++++ generate data in 2.5x2.5 ++++++++
      ;FileOut=datadir + "/derived.v5/" + sprinti("%0.4i",iiy) + \
      ;       "/" + VarName + "_2.5x2.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

      print(FileOut)

      tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ttt, time, lat, lon, FileOut)

      delete(ttt)
      delete(tttt)
   end if
end do
end do

end
