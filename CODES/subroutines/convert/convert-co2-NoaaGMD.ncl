load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

load "$ILAMB_ROOT/CODES/subroutines/write/write_1D_MultiSites_netcdf.ncl"

nmon=12

StartYear=1968
EndYear=2012
nyer=EndYear-StartYear+1
ntot=nyer*nmon

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

DataDir = getenv("ILAMB_DATADIR")

;+++++++++++++++++++++++ read NOAA GMD CO2 site geo information ++++++++++++
filename =DataDir + "/co2/NOAA.GMD/original/Sites_GeoInfo_NOAA.GMD.data"

print(filename)

fdata = asciiread(filename,-1,"string")
print(fdata)
cdata=stringtochar(fdata)

AllSite = str_squeeze(charactertostring(cdata(2:,0:6)))
AllStat = charactertostring(cdata(2:,8:31))
AllLats = stringtofloat(charactertostring(cdata(2:,32:39)))
AllLons = stringtofloat(charactertostring(cdata(2:,42:49)))
AllAlts = stringtofloat(charactertostring(cdata(2:,52:59)))

delete(cdata)
delete(fdata)

;+++++++++++++++++++++++ read NOAA GMD monthly CO2 ++++++++++++

DataFileNameS = systemfunc("ls " + DataDir + "/co2/NOAA.GMD/original/co2_*_month.txt")

print(DataFileNameS)

nsit=dimsizes(DataFileNameS)

;++++++++++++++++++++ Read data from netcdf files ++++++++++++++++++++++++
sites=new((/nsit/),string)
stats=new((/nsit/),string)
lats=new((/nsit/),float)
lons=new((/nsit/),float)
alts=new((/nsit/),float)
co2=new((/nsit,ntot/),float)

co2 = -999

   ij=0
do ns=0, nsit-1

   fdata = asciiread(DataFileNameS(ns),-1,"string")
   print(fdata)

   AllData  = str_squeeze(str_get_field(fdata, 1, " "))
  
   i50 = ind(AllData.eq."#")

   ndim = dimsizes(i50)

   i501 = i50(ndim-1)+1

   SiteName  = str_squeeze(str_get_field(DataFileNameS(ns), 2, "_"))
   years     = stringtointeger(str_get_field(fdata(i501:), 2, " "))
   months    = stringtointeger(str_get_field(fdata(i501:), 3, " "))
   CO2Data   = stringtofloat(str_get_field(fdata(i501:), 4, " "))

   j50 = ind(str_lower(SiteName).eq.str_lower(AllSite))

   if (.not.ismissing(j50)) then
      sites(ij) = AllSite(j50)
      stats(ij) = AllStat(j50)
      lats(ij)  = AllLats(j50)
      lons(ij)  = AllLons(j50)
      alts(ij)  = AllAlts(j50)

      do nd = 0, dimsizes(years)-1
         nt = (years(nd)-StartYear)*nmon + months(nd)-1
         co2(ij,nt) = CO2Data(nd)
      end do

      ij = ij + 1
   end if

   delete(i50)
   delete(j50)
   delete(i501)

   delete(SiteName)
   delete(years)
   delete(months)
   delete(CO2Data)
   delete(AllData)
   delete(fdata)
end do

nsit = ij

site1=sites(0:nsit-1)
stat1=stats(0:nsit-1)
lat1=lats(0:nsit-1)
lon1=lons(0:nsit-1)
alt1=alts(0:nsit-1)
co21=co2(0:nsit-1,:)

delete(sites)
delete(stats)
delete(lats)
delete(lons)
delete(alts)
delete(co2)

sites=site1
stats=stat1
lats=lat1
lons=lon1
alts=alt1
co2=co21

delete(site1)
delete(stat1)
delete(lat1)
delete(lon1)
delete(alt1)
delete(co21)

print(sites)
print(stats)
print(lats)
print(lons)
print(alts)

co2@_FillValue=-999

; +++++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "co2"
VarLongName = "Surface Carbon Dioxide Concentration"
VarUnit     = "ppm"
Title       = "derived NOAA GMD Site Observations"
Source      = "NOAA GMD"
TimeStep    = "monthly"

site = sites(0)
type = sprintf("%6.1f", alts(0)) 
do ns = 1, nsit-1
   site = site + "," + sites(ns)
   type = type + "," + sprintf("%6.1f", alts(ns))
end do

   ij=0
do iiy = 1850, StartYear-1

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      ntim = 366
   else
      ntim = 365
   end if

   ij = ij + ntim
end do

times = int2dble(ij)

   ijk=0
do iiy = StartYear, EndYear
do iim=1,nmon

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      nday(1) = 29
   else
      nday(1) = 28
   end if

   times = times + nday(iim-1)

   ts = co2(:,ijk)

   FileOut = DataDir + "/co2/NOAA.GMD/derived/" + sprinti("%0.4i",iiy) + \
           "/" + str_lower(VarName) + "_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"
   print(FileOut)
   tttt = write_1D_MultiSites_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ts, site, type, times, lats, lons, FileOut)

   ijk=ijk+1
   delete(ts)
end do
end do


end
