load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

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
;nlat1=360
;nlon1=720
;nlat=72
;nlon=144
;lat=fspan( -88.75, 88.75,nlat)
;lon=fspan(-178.75,178.75,nlon)

slat=flt2dble(lat)
slon=flt2dble(lon)

; -------area------------------------
;R=6378137.0
R=6371220.0d
pai=3.1415926/180.0

;---------- tropics ----------
nlon0=32143
nlat0=11551

;---------- compute area ----------
area=new((/nlat,nlon/), double)

do ny = 0, nlat-1
   if (ny.eq.0) then
      dlat = abs((slat(1)-slat(0))*0.01745d)
   else
      dlat = abs((slat(ny)-slat(ny-1))*0.01745d)
   end if
   dy = R*dlat
do nx = 0, nlon-1
   if (nx.eq.0) then
      dlon = abs((slon(1)-slon(0))*0.01745d)
   else
      dlon = abs((slon(nx)-slon(nx-1))*0.01745d)
   end if
   dx = R*cos(0.01745d*slat(ny))*dlon
   area(ny,nx)=dx*dy
end do
end do

; ----- read raw data ------
filename0="/gdata/randerson3/mmu/ILAMB/DATA/biomass/GEOCARBON/original/carbon_tropics_1km.dat"
Bmass00=fbindirread(filename0,0,(/nlat0,nlon0/),"float")

filename1="/gdata/randerson3/mmu/ILAMB/DATA/biomass/GEOCARBON/original/lat_tropics_1km.dat"
slat0=fbindirread(filename1,0,(/nlat0/),"double")

filename2="/gdata/randerson3/mmu/ILAMB/DATA/biomass/GEOCARBON/original/lon_tropics_1km.dat"
slon0=fbindirread(filename2,0,(/nlon0/),"double")

slat0=slat0(::-1)
Bmass0=flt2dble(Bmass00(:,:))
delete(Bmass00)

print(max(Bmass00))
print(min(Bmass00))
print(avg(Bmass00))

print(max(Bmass0))
print(min(Bmass0))
print(avg(Bmass0))

; -------area0------------------------

area0=new((/nlat0,nlon0/), double)

do ny = 0, nlat0-1
   if (ny.eq.0) then
      dlat = abs((slat0(1)-slat0(0))*0.01745d)
   else
      dlat = abs((slat0(ny)-slat0(ny-1))*0.01745d)
   end if
   dy = R*dlat
do nx = 0, nlon0-1
   if (nx.eq.0) then
      dlon = abs((slon0(1)-slon0(0))*0.01745d)
   else
      dlon = abs((slon0(nx)-slon0(nx-1))*0.01745d)
   end if
   dx = R*cos(0.01745d*slat0(ny))*dlon
   area0(ny,nx)=dx*dy
end do
end do

Bmass0=Bmass0*area0/10.0d

Bmass1=new((/nlat,nlon/), double)
Bmass1=0.0d

do ny=0, nlat0-1
do nx=0, nlon0-1
   ;+++++ to generate data in 0.5x0.5 ++++
   iy=doubletoint(slat0(ny)*2+90.*2)
   ix=doubletoint(slon0(nx)*2+180.*2)
   Bmass1(iy,ix)=Bmass1(iy,ix)+Bmass0(ny,nx)

   ;+++++ to generate data in 1x1 ++++
   ;iy=doubletoint(slat0(ny)+90.)
   ;ix=doubletoint(slon0(nx)+180.)
   ;Bmass1(iy,ix)=Bmass1(iy,ix)+Bmass0(ny,nx)

   ;+++++ to generate data in 2.5x2.5 ++++
   ;iy=doubletoint(slat0(ny)/2.5+90./2.5)
   ;ix=doubletoint(slon0(nx)/2.5+180./2.5)
   ;Bmass1(iy,ix)=Bmass1(iy,ix)+Bmass0(ny,nx)
end do
end do

; +++++++ start to generate data in 2.5x2.5 ++++++++
;temp=new((/nlat1,nlon1/), double)
;temp = 0.0d
;
;do ny=0, nlat0-1
;do nx=0, nlon0-1
;   iy=doubletoint(slat0(ny)*2+90*2)
;   ix=doubletoint(slon0(nx)*2+180*2)
;   temp(iy,ix)=temp(iy,ix)+Bmass0(ny,nx)
;end do
;end do
;
;temp@_FillValue = -999
;
;do ny=0,nlat1-1,5
;do nx=0,nlon1-1,5
;   Bmass1(ny/5,nx/5)=sum(temp(ny:ny+4,nx:nx+4))
;end do
;end do
;
;delete(temp)
; +++++++ end to generate data in 2.5x2.5 ++++++++

Bmass0=Bmass0/area0
Bmass1=Bmass1/area

; +++++++ save data in 0.5x0.5 ++++++++
file0_out="/gdata/randerson3/mmu/ILAMB/DATA/biomass/GEOCARBON/original/carbon_tropics_0.5x0.5.dat"

; +++++++ save data in 1x1 ++++++++
;file0_out="/gdata/randerson3/mmu/ILAMB/DATA/biomass/GEOCARBON/original/carbon_tropics_1x1.dat"

; +++++++ save data in 2.5x2.5 ++++++++
;file0_out="/gdata/randerson3/mmu/ILAMB/DATA/biomass/GEOCARBON/original/carbon_tropics_2.5x2.5.dat"

fbindirwrite(file0_out, Bmass1)

end
