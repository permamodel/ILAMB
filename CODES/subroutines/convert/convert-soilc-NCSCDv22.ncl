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

; ----------------  reading in MODIS lai  ---------------
print("Reading in NCSCDv2 Soil Carbon")

datadir="/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22"

FileIn1=datadir + "/original/NCSCDv22_SOCC_30cm_hg_WGS84_05_deg.nc"
FileIn2=datadir + "/original/NCSCDv22_SOCC_100cm_hg_WGS84_05_deg.nc"
FileIn3=datadir + "/original/NCSCDv22_SOCC_200cm_hg_WGS84_05_deg.nc"
FileIn4=datadir + "/original/NCSCDv22_SOCC_300cm_hg_WGS84_05_deg.nc"
print(FileIn1)
print(FileIn2)
print(FileIn3)
print(FileIn4)

f1=addfile(FileIn1, "r")
f2=addfile(FileIn2, "r")
f3=addfile(FileIn3, "r")
f4=addfile(FileIn4, "r")

ts01 = f1->NCSCDv22_SOCC_0_30cm_hg
ts02 = f2->NCSCDv22_SOCC_0_100cm_hg
ts03 = f3->NCSCDv22_SOCC_100_200cm_hg
ts04 = f4->NCSCDv22_SOCC_200_300cm_hg
lat0 = f1->lat
lon0 = f1->lon

slat1 = dble2flt(lat0(::-1))
slon1 = dble2flt(lon0)

nlat1=dimsizes(slat1)
nlon1=dimsizes(slon1)

ts1=new((/nlat,nlon/), float)
ts2=new((/nlat,nlon/), float)
ts3=new((/nlat,nlon/), float)
ts4=new((/nlat,nlon/), float)

ts1(0:nlat1-1,:) = int2flt(ts01)
ts2(0:nlat1-1,:) = int2flt(ts02)
ts3(0:nlat1-1,:) = int2flt(ts03)
ts4(0:nlat1-1,:) = int2flt(ts04)

ts1 = ts1(::-1,:)/10
ts2 = ts2(::-1,:)/10
ts3 = ts3(::-1,:)/10
ts4 = ts4(::-1,:)/10

ts1=where(ismissing(ts1), 0, ts1)
ts2=where(ismissing(ts2), 0, ts2)
ts3=where(ismissing(ts3), 0, ts3)
ts4=where(ismissing(ts4), 0, ts4)

;ts = ts1 + ts2 + ts3 + ts4
ts = ts2 

ts=where(ts.eq.6553.5, -999, ts)

ts@_FillValue=-999

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "soilc"
;VarLongName = "Soil Carbon in top 3 m"
VarLongName = "Soil Carbon in top 1 m"
VarUnit     = "Kg/m2"
Title       = "derived NCSCDv2.2 in 0.5x0.5"
Source      = "The Northern Circumpolar Soi Carbon Database v2.2 (NCSCDv22)"
TimeStep    = "climatology"

time = time + 1

FileOut=datadir + "/derived/soilc_0.5x0.5.nc"
print(FileOut)
tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ts, time, slat, slon, FileOut)

end
