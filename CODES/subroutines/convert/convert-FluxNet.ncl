load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

load "$ILAMB_ROOT/CODES/subroutines/write/write_1D_MultiSites_netcdf.ncl"

nmon=12

start_year=1996
end_year=2005
nyer=end_year-start_year+1
ntot=nyer*nmon

start1_year=1979
end1_year=2005
nyer1=end1_year-start1_year + 1
ntot1=nyer1*nmon

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

; +++++++++++++++++++++++ list sites with wrong data +++++++++++++++++++++++++++++++++++
; the length of data shorter than 24 months (ts)
site1 = (/1,4,6,10,11,28,30,33,35,39,40,44,50,51,65,66,70,82,84,86,87,90,93,94,97,\
          100,102,103,104,108,109,110,114,125,131,134,141,142,143,145,146,147,148,149/)

; data has err (ts)
site2 = (/3,8,12,13,16,18,29,31,38,48,57,69,71,85,92,115,116,117,130/)

;+++++++++++++++++++++++++ load FluxNet file names+++++++++++++++++++++++++++++

DataDir = getenv("ILAMB_ROOT")

DataFileNameS = systemfunc("ls " + DataDir + "/DATA/nee/FLUXNET/original/*.monthly.nc")

print(DataFileNameS)

nsit=dimsizes(DataFileNameS)

;++++++++++++++++++++ Read data from netcdf files ++++++++++++++++++++++++
sites=new((/nsit/),string)
types=new((/nsit/),string)
lats=new((/nsit/),float)
lons=new((/nsit/),float)

tas=new((/nsit,ntot/),float)
pre=new((/nsit,ntot/),float)
gpp=new((/nsit,ntot/),float)
nee=new((/nsit,ntot/),float)
rec=new((/nsit,ntot/),float)
lef=new((/nsit,ntot/),float)
shf=new((/nsit,ntot/),float)
rsd=new((/nsit,ntot/),float)
rsn=new((/nsit,ntot/),float)

ncol  = dimsizes(str_split(DataFileNameS(0),"/"))

   ij=0
do ns=0, nsit-1

   tas1=new((/ntot1/),float)
   pre1=new((/ntot1/),float)
   gpp1=new((/ntot1/),float)
   nee1=new((/ntot1/),float)
   rec1=new((/ntot1/),float)
   lef1=new((/ntot1/),float)
   shf1=new((/ntot1/),float)
   rsd1=new((/ntot1/),float)
   rsn1=new((/ntot1/),float)

   DataFileName  = str_get_field(DataFileNameS(ns), ncol, "/")
   SiteName      = str_squeeze(str_get_field(DataFileName, 1, "."))
   year1         = stringtointeger(str_get_field(DataFileName, 2, "."))
   year2         = stringtointeger(str_get_field(DataFileName, 3, "."))

   print(SiteName)
   print(year1)
   print(year2)

   fin = addfile (DataFileNameS(ns), "r")

   month0=fin->month
   year0=fin->year

   tas0=fin->Tair_f
   pre0=fin->precip
   gpp0=fin->GPP_f
   nee0=fin->NEE_f
   rec0=fin->Reco
   lef0=fin->LE_f
   shf0=fin->H_f
   rsd0=fin->Rg_f
   rsn0=fin->Rn_f

   att_names = getvaratts(fin)

   site=fin@$att_names(7)$
   type=fin@$att_names(11)$
   lat=stringtofloat(fin@$att_names(18)$)
   lon=stringtofloat(fin@$att_names(19)$)

   gpp0=gpp0*1.0e-9*12
   nee0=nee0*1.0e-9*12
   rec0=rec0*1.0e-9*12
   pre0=pre0*48/(3600*24)
   tas0=tas0 + 273.16

   year =round(year0, 3)
   month=round(month0,3)

   delete(year0)
   delete(month0)

   print(att_names)
   print(site)
   print(type)
   print(lat)
   print(lon)

   tas0=where(tas0.eq.-9999, -999, tas0)
   pre0=where(pre0.eq.-9999, -999, pre0)
   gpp0=where(gpp0.eq.-9999, -999, gpp0)
   nee0=where(nee0.eq.-9999, -999,-nee0)
   rec0=where(rec0.eq.-9999, -999, rec0)
   lef0=where(lef0.eq.-9999, -999, lef0)
   shf0=where(shf0.eq.-9999, -999, shf0)
   rsd0=where(rsd0.eq.-9999, -999, rsd0)
   rsn0=where(rsn0.eq.-9999, -999, rsn0)

   tas0@_FillValue=-999
   pre0@_FillValue=-999
   gpp0@_FillValue=-999
   nee0@_FillValue=-999
   rec0@_FillValue=-999
   lef0@_FillValue=-999
   shf0@_FillValue=-999
   rsd0@_FillValue=-999
   rsn0@_FillValue=-999

   print(dimsizes(year))
   print(dimsizes(tas0))

   i50=ind(year.ge.start1_year .and. year.le.end1_year)

   ndim=dimsizes(i50)

   if (ndim.ge.2) then

      year0=year(i50)
      month0=month(i50)
      tas00=tas0(i50)
      pre00=pre0(i50)
      gpp00=gpp0(i50)
      nee00=nee0(i50)
      rec00=rec0(i50)
      lef00=lef0(i50)
      shf00=shf0(i50)
      rsd00=rsd0(i50)
      rsn00=rsn0(i50)

      do nd=0, ndim-1
         ijk=(year0(nd) - start1_year)*12 + month0(nd) - 1
         tas1(ijk)=tas00(nd)
         pre1(ijk)=pre00(nd)
         gpp1(ijk)=gpp00(nd)
         nee1(ijk)=nee00(nd)
         rec1(ijk)=rec00(nd)
         lef1(ijk)=lef00(nd)
         shf1(ijk)=shf00(nd)
         rsd1(ijk)=rsd00(nd)
         rsn1(ijk)=rsn00(nd)
      end do

      ; correct observation error for sites listed in the site2
      kk0 = ns + 1
      if (kk0.eq.3) then
         gpp1(264:268) = -999
         nee1(264:268) = -999
         rec1(264:268) = -999
      end if
      if (kk0.eq.8) then
         gpp1(209:210) = -999
         nee1(209:210) = -999
         rec1(209:210) = -999
      end if
      if (kk0.eq.12) then
         rsn1(240:241) = -999
      end if
      if (kk0.eq.13) then
         gpp1(216:217) = -999
         nee1(216:217) = -999
         rec1(216:217) = -999
      end if
      if (kk0.eq.16) then
         gpp1(276) = -999
         nee1(276) = -999
         rec1(276) = -999
      end if
      if (kk0.eq.18) then
         rsn1(267:287) = -999
      end if
      if (kk0.eq.29) then
         gpp1(258) = -999
         nee1(258) = -999
         rec1(258) = -999
      end if
      if (kk0.eq.31) then
         shf1(207:208) = -999
         rsn1(207:209) = -999
      end if
      if (kk0.eq.38) then
         shf1(276:277) = -999
      end if
      if (kk0.eq.48) then
         gpp1(276) = -999
         nee1(276) = -999
         rec1(276) = -999
      end if
      if (kk0.eq.57) then
         gpp1(307:308) = -999
         nee1(307:308) = -999
         rec1(307:308) = -999
      end if
      if (kk0.eq.69) then
         gpp1(252:260) = -999
         nee1(252:260) = -999
         rec1(252:260) = -999
      end if
      if (kk0.eq.71) then
         shf1(292:297) = -999
         rsn1(303)     = -999
      end if
      if (kk0.eq.85) then
         gpp1(208:211) = -999
         nee1(208:211) = -999
         rec1(208:211) = -999
      end if
      if (kk0.eq.92) then
         rsn1(:) = -999
      end if
      if (kk0.eq.115) then
         gpp1(242:244) = -999
         nee1(242:244) = -999
         rec1(242:244) = -999
      end if
      if (kk0.eq.116) then
         gpp1(263) = -999
         nee1(263) = -999
         rec1(263) = -999
      end if
      if (kk0.eq.117) then
         gpp1(263) = -999
         nee1(263) = -999
         rec1(263) = -999
      end if
      if (kk0.eq.130) then
         rsn1(262:263) = -999
      end if

      tas1@_FillValue=-999
      pre1@_FillValue=-999
      gpp1@_FillValue=-999
      nee1@_FillValue=-999
      rec1@_FillValue=-999
      lef1@_FillValue=-999
      shf1@_FillValue=-999
      rsd1@_FillValue=-999
      rsn1@_FillValue=-999

      nt1 = (start_year-start1_year)*nmon

      j50 = ind(.not.ismissing(tas1(nt1:ntot1-1)))

      if (dimsizes(j50).ge.24) then
         tas(ij,:) = tas1(nt1:ntot1-1)
         pre(ij,:) = pre1(nt1:ntot1-1)
         gpp(ij,:) = gpp1(nt1:ntot1-1)
         nee(ij,:) = nee1(nt1:ntot1-1)
         rec(ij,:) = rec1(nt1:ntot1-1)
         lef(ij,:) = lef1(nt1:ntot1-1)
         shf(ij,:) = shf1(nt1:ntot1-1)
         rsd(ij,:) = rsd1(nt1:ntot1-1)
         rsn(ij,:) = rsn1(nt1:ntot1-1)

         sites(ij) = site
         types(ij) = type
         lats(ij)  = lat
         lons(ij)  = lon

         ij = ij +1
      end if

      delete(j50)
      delete(year0)
      delete(month0)
      delete(tas00)
      delete(pre00)
      delete(gpp00)
      delete(nee00)
      delete(rec00)
      delete(lef00)
      delete(shf00)
      delete(rsd00)
      delete(rsn00)
   end if

   delete(i50)

   delete(tas0)
   delete(pre0)
   delete(gpp0)
   delete(nee0)
   delete(rec0)
   delete(lef0)
   delete(shf0)
   delete(rsd0)
   delete(rsn0)

   delete(tas1)
   delete(pre1)
   delete(gpp1)
   delete(nee1)
   delete(rec1)
   delete(lef1)
   delete(shf1)
   delete(rsd1)
   delete(rsn1)

   delete(fin)
   delete(lat)
   delete(lon)
   delete(type)
   delete(site)
   delete(year)
   delete(year1)
   delete(year2)
   delete(month)
   delete(att_names)
end do

nsit = ij
print(nsit)

tas@_FillValue=-999
pre@_FillValue=-999
gpp@_FillValue=-999
nee@_FillValue=-999
rec@_FillValue=-999
lef@_FillValue=-999
shf@_FillValue=-999
rsd@_FillValue=-999
rsn@_FillValue=-999

tas0=tas(0:nsit-1,:)
pre0=pre(0:nsit-1,:)
gpp0=gpp(0:nsit-1,:)
nee0=nee(0:nsit-1,:)
rec0=rec(0:nsit-1,:)
lef0=lef(0:nsit-1,:)
shf0=shf(0:nsit-1,:)
rsd0=rsd(0:nsit-1,:)
rsn0=rsn(0:nsit-1,:)
lats0=lats(0:nsit-1)
lons0=lons(0:nsit-1)
types0=types(0:nsit-1)
sites0=sites(0:nsit-1)

delete(tas)
delete(pre)
delete(gpp)
delete(nee)
delete(rec)
delete(lef)
delete(shf)
delete(rsd)
delete(rsn)
delete(lats)
delete(lons)
delete(types)
delete(sites)

k50=dim_pqsort(lats0, 2)

tas=tas0(k50,:)
pre=pre0(k50,:)
gpp=gpp0(k50,:)
nee=nee0(k50,:)
rec=rec0(k50,:)
lef=lef0(k50,:)
shf=shf0(k50,:)
rsd=rsd0(k50,:)
rsn=rsn0(k50,:)
lons=lons0(k50)
lats=lats0
types=types0(k50)
sites=sites0(k50)

delete(tas0)
delete(pre0)
delete(gpp0)
delete(nee0)
delete(rec0)
delete(lef0)
delete(shf0)
delete(rsd0)
delete(rsn0)
delete(sites0)
delete(lats0)
delete(lons0)

; +++++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "pr"
VarLongName = "precipitation"
VarUnit     = "Kg m-2 s-1"
Title       = "derived FluxNet"
Source      = "FluxNet"
TimeStep    = "monthly"

site = sites(0)
type = types(0)
do ns = 1, nsit-1
   site = site + "," + sites(ns)
   type = type + "," + types(ns)
end do

print(site)
print(type)

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

   ts = pre(:,ijk)

   FileOut=DataDir + "/DATA/pr/FLUXNET/derived/" + sprinti("%0.4i",iiy) + \
           "/" + str_lower(VarName) + "_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   print(FileOut)
   tttt = write_1D_MultiSites_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ts, site, type, times, lats, lons, FileOut)

   ijk=ijk+1
   delete(ts)
end do
end do


end
