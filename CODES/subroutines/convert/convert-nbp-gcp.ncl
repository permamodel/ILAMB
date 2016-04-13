load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_1D_SingleSite_netcdf.ncl"

begin

  DataDir = getenv("ILAMB_DATADIR") + "/nbp/GCP"

  nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

; ----------------  calculating No.of days from 1850 through 1958  ---------------

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

; ----------------  reading in GCP carbon ---------------
  print("Reading in GCP carbon flux in Pg C/yr")

  FileName = DataDir + "/original/Global_Carbon_Budget_2013_v2.3.txt"
  print(FileName)

  data_1d = asciiread(FileName,-1,"string")
  print(data_1d)

  VarUnit      = "Pg C/yr"

  Years        = stringtointeger(str_get_field(data_1d(1:), 1, " "))

  nvar         = dimsizes(str_split(data_1d(0)," "))
  temp1        = str_squeeze(str_split(data_1d(0)," "))

  VarName1     = temp1(1:nvar-1)

  delete(temp1)

  nvar         = nvar-1
  nyer         = dimsizes(Years)

  tts=new((/nvar,nyer/), float)

  do nv = 0, nvar-1
     tts(nv,:) = stringtofloat(str_get_field(data_1d(1:), nv+2, " "))
  end do

  ts = tts(4,:) - tts(1,:)

  ;ts = ts*3.67 ; convert unit from Pg C/yr to Pg CO2/yr

time=new((/nyer/), double)

do iy = 0, nyer-1
   iiy=iy+1959

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      ntim=366
   else
      ntim=365
   end if

   time(iy) = time0 + int2dble(ntim*(iy+1))
end do

print(dimsizes(time))
print(dimsizes(ts))

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "nbp"
VarLongName = "Global Net Downward Carbon Flux"
VarUnit     = "Pg C/yr"
Title       = "derived GCP Global Net Downward Carbon Flux"
Source      = "Global Carbon Project v2.3"
TimeStep    = "yearly"

lat         = -999
lon         = -999

FileOut=DataDir + "/derived/nbp_1959-2012.nc"
print(FileOut)
tttt = write_1D_SingleSite_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                                   ts, time, lat, lon, FileOut)

end
