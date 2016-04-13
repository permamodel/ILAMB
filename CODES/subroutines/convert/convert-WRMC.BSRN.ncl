load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

load "$ILAMB_ROOT/CODES/subroutines/write/write_1D_MultiSites_netcdf.ncl"

nmon=12

start_year=1992
end_year=2012
nyer=end_year-start_year+1
ntot=nyer*nmon

start1_year=1992
end1_year=2012
nyer1=end1_year-start1_year + 1
ntot1=nyer1*nmon

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

VarName     = "rsns"
VarLongName = "Surface Net Shortwave Radiation"
VarUnit     = "Watt m-2"
Title       = "derived WRMC BSRN"
Source      = "WRMC.BSRN"
TimeStep    = "monthly"
type        = "BSRN"

;+++++++++++++++++++++++++ load WRMC.BSRN file names+++++++++++++++++++++++++++++

DataDir = getenv("ILAMB_DATADIR")

DataFileNameS = systemfunc("ls " + DataDir + "/" + str_lower(VarName) + "/WRMC.BSRN/original/*_1992-2012.txt")

print(DataFileNameS)

nsit=dimsizes(DataFileNameS)

;++++++++++++++++++++ Read data from netcdf files ++++++++++++++++++++++++
sites=new((/nsit/),string)
lats=new((/nsit/),float)
lons=new((/nsit/),float)

rlds=new((/nsit,ntot/),float)
rlus=new((/nsit,ntot/),float)
rsds=new((/nsit,ntot/),float)
rsus=new((/nsit,ntot/),float)

do ns=0, nsit-1

   cFileName = stringtochar(DataFileNameS(ns))
   cFileName = cFileName(::-1)
   csite     = cFileName(15:17)
   sites(ns) = charactertostring(csite(::-1))
   
   delete(cFileName)
   delete(csite)

   fdata = asciiread(DataFileNameS(ns),-1,"string")
   print(fdata)

   lat0  = stringtofloat(str_get_field(fdata(1:), 3, " "))
   lon0  = stringtofloat(str_get_field(fdata(1:), 4, " "))

   rsds(ns,:)  = stringtofloat(str_get_field(fdata(1:), 5, " "))
   rsus(ns,:)  = stringtofloat(str_get_field(fdata(1:), 6, " "))
   rlds(ns,:)  = stringtofloat(str_get_field(fdata(1:), 7, " "))
   rlus(ns,:)  = stringtofloat(str_get_field(fdata(1:), 8, " "))

   lats(ns) = lat0(0)
   lons(ns) = lon0(0)

   delete(lat0)
   delete(lon0)
   delete(fdata)
end do

print(sites)

rlds@_FillValue = -999
rlus@_FillValue = -999
rsds@_FillValue = -999
rsus@_FillValue = -999

rlns = rlds-rlus
rsns = rsds-rsus
rns = rsds-rsus+rlds-rlus

rlns = where(rlns.le.-900, -999, rlns)
rlns = where(rlns.ge. 900, -999, rlns)

rsns = where(rsns.le.-900, -999, rsns)
rsns = where(rsns.ge. 900, -999, rsns)

rns = where(rns.le.-900, -999, rns)
rns = where(rns.ge. 900, -999, rns)

rlns@_FillValue = -999
rsns@_FillValue = -999
rns@_FillValue = -999

site = sites(0)
do ns = 1, nsit-1
   site = site + "," + sites(ns)
end do

   ij=0
do iiy = 1850, start_year-1

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
do iiy = start_year, end_year
   print(iiy)

do iim=1,nmon

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      nday(1) = 29
   else
      nday(1) = 28
   end if

   times = times + nday(iim-1)

   ts = rsns(:,ijk)

   FileOut=DataDir + "/" + str_lower(VarName) + "/WRMC.BSRN/derived/" + sprinti("%0.4i",iiy) + \
           "/" + str_lower(VarName) + "_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   print(FileOut)
   tttt = write_1D_MultiSites_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ts, site, type, times, lats, lons, FileOut)

   ijk=ijk+1
   delete(ts)
end do
end do


end
