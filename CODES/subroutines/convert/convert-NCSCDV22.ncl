load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

nlat=360
nlon=720

slat1=fspan(-89.75,89.75,nlat)
slon1=fspan(-179.75,179.75,nlon)

slat=flt2dble(slat1)
slon=flt2dble(slon1)

; -------area------------------------
R=6371220.0d
pai=3.1415926/180.0

nlon0=9578
nlat0=9113

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
filename0="/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/NCSCDv22_SOCC_0-30cm_hg_LAEA_1km.dat"
;filename0="/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/NCSCDv22_SOCC_30-100cm_hg_LAEA_1km.dat"
Bmass00=fbindirread(filename0,0,(/nlat0,nlon0/),"float")

filename1="/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/lat_0-30cm_hg_LAEA_1km.dat"
;filename1="/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/lat_30-100cm_hg_LAEA_1km.dat"
slat0=fbindirread(filename1,0,(/nlat0/),"double")

filename2="/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/lon_0-30cm_hg_LAEA_1km.dat"
;filename2="/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/lon_30-100cm_hg_LAEA_1km.dat"
slon0=fbindirread(filename2,0,(/nlon0/),"double")

slat0=slat0(::-1)
Bmass0=flt2dble(Bmass00(:,:))
delete(Bmass00)

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

area0=1.0d

Bmass0=Bmass0*area0

Bmass1=new((/nlat,nlon/), double)
Bmass1=0.0d

do ny=0, nlat0-1
do nx=0, nlon0-1
   iy=doubletoint(slat0(ny)*2+90*2)
   ix=doubletoint(slon0(nx)*2+180*2)
   Bmass1(iy,ix)=Bmass1(iy,ix)+Bmass0(ny,nx)
end do
end do

Bmass0=Bmass0/area0
Bmass1=Bmass1/area

print(sum(Bmass0*area0))
print(sum(Bmass1*area))

;file0_out="/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/NCSCDv22_SOCC_0-30cm_0.5x0.5.dat"
;file0_out="/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/NCSCDv22_SOCC_30-100cm_0.5x0.5.dat"
;fbindirwrite(file0_out, Bmass1)

end
