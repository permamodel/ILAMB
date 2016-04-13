load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_1D_SingleSite_netcdf.ncl"

begin

  StartYr = 1959
  EndYr   = 2013
  nmon    = 12
  nyer    = EndYr - StartYr + 1
  ntot    = nyer*nmon

  DataDir = getenv("ILAMB_DATADIR") + "/co2/MAUNA.LOA"

  nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

; ----------------  calculating No.of days from 1850 through 1999  ---------------

   ijk=0
do iiy = 1850, 1958

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      ntim=366
   else
      ntim=365
   end if

   ijk = ijk + ntim
end do

time0 = int2dble(ijk)

; ----------------  reading CO2 at Mauna Loa ---------------
  print("Reading in CO2 at Mauna Loa")

  FileName = DataDir + "/original/co2_1958-2014.txt"
  print(FileName)

  data_1d = asciiread(FileName,-1,"string")
  print(data_1d)

  VarUnit = "ppm"

  years   = stringtointeger(str_get_field(data_1d, 1, " "))
  month   = stringtointeger(str_get_field(data_1d, 2, " "))
  data1   = stringtofloat(str_get_field(data_1d,   5, " "))

  i50     = ind(years.ge.StartYr .and. years.le.EndYr)

  ndim    = dimsizes(i50)

  tts=new((/nmon,nyer/), float)

  tts = -999

  do nd = 0, ndim-1
     iy = years(i50(nd))-StartYr
     im = month(i50(nd))-1
     ;print(im)
     ;print(iy)
     tts(im,iy) = data1(i50(nd))
  end do

  ts=new((/ntot/), float)

     ijk = 0
  do iy = 0, nyer-1
  do im = 0, nmon-1
     ts(ijk) = tts(im,iy)
     ijk = ijk + 1
  end do
  end do

  ts@_FillValue = -999

time=new((/ntot/), double)

   ijk = 0
   nt = 0
do iy = 0, nyer-1
   iiy=iy+1959

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      nday(1)=29
   else
      nday(1)=28
   end if

   do im = 0, nmon-1
      time(nt) = time0 + int2dble(ijk)
      ijk = ijk + nday(im)
      nt = nt + 1
   end do
end do

print(dimsizes(time))
print(dimsizes(ts))

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "co2"
VarLongName = "Carbon Dioxide at Mauna Loa"
VarUnit     = "ppm"
Title       = "derived monthly observed Mauna Loa CO2"
Source      = "NOAA/ESRL Mauna Loa CO2 observation"
TimeStep    = "monthly"

lat         = 19.54
lon         =-155.58

FileOut=DataDir + "/derived/co2_1959-2013.nc"
print(FileOut)
tttt = write_1D_SingleSite_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                                   ts, time, lat, lon, FileOut)

end
