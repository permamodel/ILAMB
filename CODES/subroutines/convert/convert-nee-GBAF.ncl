load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12
nlat=360
nlon=720

StartYear=1982
EndYear=2008
nyer=EndYear-StartYear + 1

varID="nee"

lat=new((/nlat/), float)
lon=new((/nlon/), float)

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

lat=fspan(-89.75,89.75,nlat)
lon=fspan(-179.75,179.75,nlon)

; ----------------  calculating No.of days from 1850 through 1981  ---------------
   ijk=0
do iiy = 1850, 1981

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
VarName     = varID
VarLongName = "net ecosystem exchange"
VarUnit     = "KgC/m2/s"
Title       = "derived GBAF in 0.5x0.5"
Source      = "Global Biosphere Amtospher Flux (GBAF)"
TimeStep    = "monthly"

DataDir = "/gdata/randerson3/mmu/ILAMB/DATA/" + str_lower(varID) + "/GBAF"

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

   ; ----------------  reading in FluxNet-MTE data  ---------------
   print("reading in GBAF " + varID)

   FileIn  = DataDir + "/original/" + sprinti("%0.4i",iiy) + \
           "/EnsembleNEE_May09_" + sprinti("%0.4i",iiy) + ".nc"
   print(FileIn)

   f1=addfile(FileIn, "r")

   ts =f1->EnsembleNEE_May09
   lat0=f1->latitude
   lon0=f1->longitude

   nlat0 = dimsizes(lat0)
   nlon0 = dimsizes(lon0)

   ts=ts*ts@scale_factor + ts@add_offset

   ts=ts*1.0e-3/(3600*24)

   ; flip the direction (positive mean into land)
   ts=-ts

   ts=where(ismissing(ts), -999, ts)
   ts=where(ts.le.-999, -999, ts)
   ts=where(ts.ge.999, -999, ts)
   ts@_FillValue=-999

do iim=1,nmon

   tts=new((/nlat,nlon/), float)

   tts = -999

   tts(0:nlat0-1,:) = ts(iim-1,:,:)
   tts = tts(::-1,:)

   tts@_FillValue=-999

   time = time + int2dble(nday(iim-1))

   FileOut=DataDir + "/derived/" + sprinti("%0.4i",iiy) + \
           "/" + str_lower(varID) + "_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"
   print(FileOut)
   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           tts, time, lat, lon, FileOut)

   ijk=ijk+1

   delete(tts)
end do
   delete(ts)
end do

end
