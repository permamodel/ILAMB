load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nlon0=18570
nlat0=11704

; ----- set up paras for Albers Equal-Area map projection ------
R=6371220.0
pai=3.1415926/180.0

phi1=29.5*pai
phi2=44.5*pai

phi0=23.0*pai
r0=-96.0*pai

;phi0=0.0
;r0=0.0

n=(sin(phi1)+sin(phi2))/2
C=cos(phi1)*cos(phi1)+2.0*n*sin(phi1)
rou0=R*sqrt(C-2.0*n*sin(phi0))/n

print(n)

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

slat=flt2dble(lat)
slon=flt2dble(lon)

area=new((/nlat,nlon/), double)

do ny = 0, nlat-1
   if (ny.eq.0) then
      dlat = abs((slat(1)-slat(0))*0.01745)
   else
      dlat = abs((slat(ny)-slat(ny-1))*0.01745)
   end if
   dy = R*dlat
do nx = 0, nlon-1
   if (nx.eq.0) then
      dlon = abs((slon(1)-slon(0))*0.01745)
   else
      dlon = abs((slon(nx)-slon(nx-1))*0.01745)
   end if
   dx = R*cos(0.01745*slat(ny))*dlon
   area(ny,nx)=dx*dy
end do
end do

filename0="/gdata/randerson3/mmu/ILAMB/DATA/biomass/NBCD2000/original/biomass_250m.dat"
Bmass0=fbindirread(filename0,0,(/nlat0,nlon0/),"float")

print("total of Bmass")
print(sum(Bmass0*250*250*1.0e-13))

Bmass=flt2dble(Bmass0(::-1,:))*250.0*250.0*1.0e-1
delete(Bmass0)

print("total of Bmass")
print(sum(Bmass)*1.0e-12)

slat0=new((/nlat0,nlon0/), float)
slon0=new((/nlat0,nlon0/), float)

mean0=new((/nlat,nlon/), double)
mean0=0.0d

do ny=0, nlat0-1
do nx=0, nlon0-1
   x=-2368238.668859472498298+int2flt(nx)*250.0
   y=3175723.645394477527589-int2flt(ny)*250.0
   rou=sqrt(x*x+(rou0-y)*(rou0-y))
   sita=atan(x/(rou0-y))
   slon0(ny,nx)=r0+sita/n
   slat0(ny,nx)=asin((C-(rou*n/R)*(rou*n/R))/(2.0*n))
   slat0(ny,nx)=slat0(ny,nx)/pai
   slon0(ny,nx)=slon0(ny,nx)/pai

   ;+++++ to generate data in 0.5x0.5 ++++
   ;iy=floattoint(slat0(ny,nx)*2+90.*2)
   ;ix=floattoint(slon0(ny,nx)*2+180.*2)

   ;+++++ to generate data in 1x1 ++++
   ;iy=floattoint(slat0(ny,nx)+90.)
   ;ix=floattoint(slon0(ny,nx)+180.)

   ;+++++ to generate data in 2.5x2.5 ++++
   iy=floattoint(slat0(ny,nx)/2.5+90./2.5)
   ix=floattoint(slon0(ny,nx)/2.5+180./2.5)

   mean0(iy,ix)=mean0(iy,ix)+Bmass(ny,nx)
end do
end do

; +++++++ start to generate data in 2.5x2.5 ++++++++
;temp=new((/nlat1,nlon1/), double)
;temp = 0.0d
;
;do ny=0, nlat0-1
;do nx=0, nlon0-1
;   x=-2368238.668859472498298+int2flt(nx)*250.0
;   y=3175723.645394477527589-int2flt(ny)*250.0
;   rou=sqrt(x*x+(rou0-y)*(rou0-y))
;   sita=atan(x/(rou0-y))
;   slon0(ny,nx)=r0+sita/n
;   slat0(ny,nx)=asin((C-(rou*n/R)*(rou*n/R))/(2.0*n))
;   slat0(ny,nx)=slat0(ny,nx)/pai
;   slon0(ny,nx)=slon0(ny,nx)/pai
;
;   ;+++++ to generate data in 0.5x0.5 ++++
;   iy=floattoint(slat0(ny,nx)*2+90.*2)
;   ix=floattoint(slon0(ny,nx)*2+180.*2)
;   temp(iy,ix)=temp(iy,ix)+Bmass0(ny,nx)
;end do
;end do
;
;temp@_FillValue = -999
;
;do ny=0,nlat1-1,5
;do nx=0,nlon1-1,5
;   mean0(ny/5,nx/5)=sum(temp(ny:ny+4,nx:nx+4))
;end do
;end do
;
;delete(temp)
; +++++++ end to generate data in 2.5x2.5 ++++++++

mean0=mean0/area

; +++++++ save data in 0.5x0.5 ++++++++
;file0_out="/gdata/randerson3/mmu/ILAMB/DATA/biomass/NBCD2000/original/biomass_0.5x0.5.dat"

; +++++++ save data in 1x1 ++++++++
;file0_out="/gdata/randerson3/mmu/ILAMB/DATA/biomass/NBCD2000/original/biomass_1x1.dat"

; +++++++ save data in 2.5x2.5 ++++++++
file0_out="/gdata/randerson3/mmu/ILAMB/DATA/biomass/NBCD2000/original/biomass_2.5x2.5.dat"

fbindirwrite(file0_out, mean0)

end
