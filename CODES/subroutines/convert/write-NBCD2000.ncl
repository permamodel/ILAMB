load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12

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

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "biomass"
VarLongName = "aboveground live biomass"
VarUnit     = "Kg C per m2"
Title       = "derived Continental US 48 states Biomass (NBCD2000)"
Source      = "250-m Continental US 48 states Biomass (NBCD2000)"
TimeStep    = "climatology"

; ----------------  reading in biomass  ---------------
print("reading original data")

datadir = "/gdata/randerson3/mmu/ILAMB/DATA/biomass/NBCD2000"

; -------- read BioMass data ----------------
filename1 = datadir + "/original/biomass_0.5x0.5.dat"
;filename1 = datadir + "/original/biomass_1x1.dat"
;filename1 = datadir + "/original/biomass_2.5x2.5.dat"
Bmass1 = fbindirread(filename1,0,(/nlat,nlon/),"double")

BMass=doubletofloat(Bmass1)

BMass@_FillValue=-999

; +++++++ generate data in 0.5x0.5 ++++++++
FileOut=datadir + "/derived/" + VarName + "_0.5x0.5_new" + ".nc"

; +++++++ generate data in 1x1 ++++++++
;FileOut=datadir + "/derived/" + VarName + "_1x1" + ".nc"

; +++++++ generate data in 2.5x2.5 ++++++++
;FileOut=datadir + "/derived/" + VarName + "_2.5x2.5" + ".nc"

print(FileOut)

tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                        BMass, time, lat, lon, FileOut)

end
