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

varID="gpp"

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
VarLongName = "gross primary production"
VarUnit     = "KgC/m2/s"
Title       = "derived GBAF in 0.5x0.5"
Source      = "Global Biosphere Amtospher Flux (GBAF)"
TimeStep    = "monthly"

DataDir1 = "/gdata/randerson3/mmu/ILAMB/DATA/reco/GBAF"
DataDir2 = "/gdata/randerson3/mmu/ILAMB/DATA/" + str_lower(varID) + "/GBAF"

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
   print("reading in GBAF Respiration")

   FileIn1  = DataDir1 + "/original/" + sprinti("%0.4i",iiy) + \
           "/EnsembleTER_MR_May09_" + sprinti("%0.4i",iiy) + ".nc"
   print(FileIn1)

   f1=addfile(FileIn1, "r")

   ts1 =f1->EnsembleTER_MR_May09

   ts1=ts1*ts1@scale_factor + ts1@add_offset

   ts1=where(ismissing(ts1), -999, ts1)
   ts1=where(ts1.le.-999,    -999, ts1)
   ts1=where(ts1.ge.999,     -999, ts1)

   FileIn2  = DataDir2 + "/original/" + sprinti("%0.4i",iiy) + \
           "/EnsembleGPP_GL_May09_" + sprinti("%0.4i",iiy) + ".nc"
   print(FileIn2)

   f2=addfile(FileIn2, "r")

   ts0 =f2->EnsembleGPP_GL_May09
   lat0=f2->latitude
   lon0=f2->longitude

   nlat0 = dimsizes(lat0)
   nlon0 = dimsizes(lon0)

   ts=short2flt(ts0)

   ts=ts*ts0@DataScaleFactor + ts0@DataOffsetValue

   ts=ts*1.0e-3/(3600*24)

   ts=where(ismissing(ts), 0, ts)
   ts=where(ts.le.0,       0, ts)
   ts=where(ts.ge.999,     0, ts)

   ts=where(ismissing(ts1), -999, ts)
   ts=where(ts1.le.-999,    -999, ts)

   ts@_FillValue=-999

do iim=1,nmon

   tts=new((/nlat,nlon/), float)

   tts = -999

   tts(0:nlat0-1,:) = ts(iim-1,:,:)
   tts = tts(::-1,:)

   tts@_FillValue=-999

   delete(tts@time)

   time = time + int2dble(nday(iim-1))

   FileOut=DataDir2 + "/derived/" + sprinti("%0.4i",iiy) + \
           "/" + str_lower(varID) + "_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"
   print(FileOut)
   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           tts, time, lat, lon, FileOut)

   ijk=ijk+1

   delete(tts)
end do
   delete(ts)
   delete(ts0)
   delete(ts1)
end do

end
