load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12
nlat=360
nlon=720

StartYear=2000
EndYear=2000
nyer=EndYear-StartYear + 1

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

slat=fspan( -89.75, 89.75,nlat)
slon=fspan(-179.75,179.75,nlon)
;slon=fspan(0.25,359.75,nlon)

; ----------------  calculating No.of days from 1850 through 1999  ---------------
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

; ----------------  reading in NCSCDv2 soilc ---------------
print("Reading in NCSCDv2 Soil Carbon")

datadir="/gdata/randerson3/mmu/ILAMB/DATA/soilc/HWSD"

FileIn=datadir + "/original/HWSD_05deg.nc"
print(FileIn)

f1=addfile(FileIn, "r")

ts = f1->SOC(::-1,:)
lat0 = f1->latitude
lon0 = f1->longitude

slat = dble2flt(lat0(::-1))
slon = dble2flt(lon0)

nlat=dimsizes(slat)
nlon=dimsizes(slon)

ts=where(ismissing(ts), -999, ts)

ts=where(ts.le.0, -999, ts)

ts@_FillValue=-999

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "soilc"
VarLongName = "Soil Carbon in top 3 m"
VarUnit     = "Kg/m2"
Title       = "derived HWSD soil carbon in 0.5x0.5"
Source      = "Area weighted soil organic carbon from HWSD"
TimeStep    = "climatology"

time = time + 1

FileOut=datadir + "/derived/soilc_0.5x0.5.nc"
print(FileOut)
tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ts, time, slat, slon, FileOut)

end
