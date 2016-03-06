load "/sopt/ncl/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "/sopt/ncl/lib/ncarg/nclex/gsun/gsn_csm.ncl"
load "/sopt/ncl/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/sopt/ncl/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "/gdata/randerson3/mmu/ILAMB/CODES/subroutines/write/write_2D_biomass_netcdf.ncl"

begin

nlat=360
nlon=720

slat=fspan(-89.75,89.75,nlat)
slon=fspan(-179.75,179.75,nlon)

; ----------------  reading in GFED3.1  ---------------
print("reading original data")

datadir="/gdata/randerson3/mmu/ILAMB/DATA/Biomass/Global.Carbon/derived"

; -------- read BioMass data ----------------
filename1="GlobalCarbon/carbon_africa_0.5x0.5.dat"
Bmass1=fbindirread(filename1,0,(/nlat,nlon/),"double")

filename2="GlobalCarbon/carbon_america_0.5x0.5.dat"
Bmass2=fbindirread(filename2,0,(/nlat,nlon/),"double")

filename3="GlobalCarbon/carbon_asia_0.5x0.5.dat"
Bmass3=fbindirread(filename3,0,(/nlat,nlon/),"double")

Bmass=doubletofloat(Bmass1+Bmass2+Bmass3)

BMass=dble2flt(Bmass)

file_out= datadir + "/biomass_0.5x0.5.nc"
print(file_out)
tttt = write_2D_biomass_netcdf (BMass, slat, slon, file_out)

end
