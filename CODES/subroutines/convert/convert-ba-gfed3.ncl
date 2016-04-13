load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/read/read_benchmark_old.ncl"
load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

; +++++ Set Constants Values +++++
Rad = 6371220.0
RR0 = 0.01745
EE0 = 2.7183

nmon=12
nlat0=360
nlon0=720

start_year=1997
end_year=2011
nyer=end_year-start_year + 1

ntot=nyer*nmon

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

lat0=fspan(-89.75,89.75,nlat0)
lon0=fspan(-179.75,179.75,nlon0)

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

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "desert"

datadir= getenv("ILAMB_DATADIR") + "/biomes/MODIS"

; +++++++ read desert data in 0.5x0.5 ++++++++
;FileIn=datadir + "/derived/" + "desert_0.5x0.5.nc"

; +++++++ read desert data in 1x1 ++++++++
;FileIn=datadir + "/derived/" + "desert_1x1.nc"

; +++++++ read desert data in 2.5x2.5 ++++++++
FileIn=datadir + "/derived/" + "desert_2.5x2.5.nc"

f1=addfile(FileIn,"r")
print(f1)

desert=f1->desert

delete(f1)

; ----------------  calculating No.of days from 1850 through 1900  ---------------
   ijk=0
do iiy = 1850, 1996

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

; ----------------  reading in GFED3.1  ---------------
print("reading in GFED3.1 original Burned Area")

datadir="$ILAMB_DATADIR/burntArea/GFED3"

; ------------ obs ----------------------
BenchMarkRaw = "yes"

ts0=new((/ntot,nlat0,nlon0/), float)

ts0 = read_gfed3_ba ( datadir, "burntArea", BenchMarkRaw, start_year, end_year, lat0, lon0)

; -------area0------------------------
area0=new((/nlat0,nlon0/), float)

dlon = abs((lon0(1)-lon0(0))*RR0)
dlat = abs((lat0(0)-lat0(1))*RR0)
  dy = Rad*dlat

do ny = 0, nlat0-1
do nx = 0, nlon0-1
   dx = Rad*cos(RR0*lat0(ny))*dlon
   area0(ny,nx)=dx*dy
end do
end do

; -------area------------------------
area=new((/nlat,nlon/), float)

dlon = abs((lon(1)-lon(0))*RR0)
dlat = abs((lat(0)-lat(1))*RR0)
  dy = Rad*dlat

do ny = 0, nlat-1
do nx = 0, nlon-1
   dx = Rad*cos(RR0*lat(ny))*dlon
   area(ny,nx)=dx*dy
end do
end do

do nt=0, ntot-1
   ts0(nt,:,:)=100*ts0(nt,:,:)/area0
end do

ts0=where(ts0.lt.0, -999, ts0)
ts0=where(ismissing(ts0), -999, ts0)

ts0@_FillValue = -999

ts=new((/ntot,nlat,nlon/), float)

; +++++++ generate data in 0.5x0.5 ++++++++
;ts = ts0

   ijk=0
do iiy = start_year, end_year
do iim = 1, nmon

   ; +++++++ generate data in 1x1 ++++++++
   ;do ny=0,nlat0-1,2
   ;do nx=0,nlon0-1,2
   ;   if (all(ismissing(ts0(ijk,ny:ny+1,nx:nx+1)))) then
   ;      ts(ijk,ny/2,nx/2)=-999
   ;   else
   ;      ts(ijk,ny/2,nx/2)=avg(ts0(ijk,ny:ny+1,nx:nx+1))
   ;   end if
   ;end do
   ;end do

   ; +++++++ generate data in 2.5x2.5 ++++++++
   do ny=0,nlat0-1,5
   do nx=0,nlon0-1,5
      if (all(ismissing(ts0(ijk,ny:ny+4,nx:nx+4)))) then
         ts(ijk,ny/5,nx/5)=-999
      else
         ts(ijk,ny/5,nx/5)=avg(ts0(ijk,ny:ny+4,nx:nx+4))
      end if
   end do
   end do

   ijk=ijk+1
end do
end do

ts!0="time"
ts!1="lat"
ts!2="lon"

atm=dim_avg_n(ts, 0)

region=where(atm.ge.0, 1, 0)

region=where((atm.eq.0 .and. desert.ge.70), 0, region)

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "burntArea"
VarLongName = "Burned Area Fraction"
VarUnit     = "%"
Title       = "derived GFED3 burned area fracttion"
Source      = "0.5 degree GFED3.1 burned area"
TimeStep    = "monthly"

   ijk=0
do iiy = start_year, end_year

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      nday(1)=29
   else
      nday(1)=28
   end if

do iim = 1, nmon

   time = time + int2dble(nday(iim-1))

   ttt = ts(ijk,:,:)

   ttt = where(region.eq.0, -999, ttt)

   ttt@_FillValue = -999

   print(max(ttt))

   ; +++++++ generate data in 0.5x0.5 ++++++++
   ;FileOut= datadir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;        "/burntArea_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 1x1 ++++++++
   ;FileOut= datadir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;        "/burntArea_1x1_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 2.5x2.5 ++++++++
   FileOut= datadir + "/derived/" + sprinti("%0.4i",iiy) + \
           "/burntArea_2.5x2.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   print(FileOut)

   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ttt, time, lat, lon, FileOut)

   delete(ttt)

   ijk=ijk+1

end do
end do

end
