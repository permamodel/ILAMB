load "/sopt/ncl/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "/sopt/ncl/lib/ncarg/nclex/gsun/gsn_csm.ncl"
load "/sopt/ncl/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/sopt/ncl/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

nmod=14
start_year=1979
end_year=2005
nyer=end_year-start_year + 1
nmon=12
ntot=nyer*nmon

nday=(/31,28,31,30,31,30,31,31,30,31,30,31/)

; the length of data shorter than 24 months (ts)
site1 = (/1,4,6,10,11,28,30,33,35,39,40,44,50,51,65,66,70,82,84,86,87,90,93,94,97,100,102,103,104,108,109,110,114,125,131,134,141,142,143,145,146,147,148,149/)
; data has err (ts)
site2 = (/3,8,12,13,16,18,29,31,38,48,57,69,71,85,92,115,116,117,130/)

; ------- read EuroFlux data -----
obsdir="/gdata/randerson2/mmu/ILAMB/datasets/BENCHMARKS/FluxNet"

SiteListName = obsdir + "/derived/sites.all"
print(SiteListName)

SiteFileName = asciiread(SiteListName,-1,"string")
print(SiteFileName)
nsit=dimsizes(SiteFileName)
print(nsit)

;---Read the values in as 1D, since we don't know rows and columns yet.
slats=new((/nsit/), float)
slons=new((/nsit/), float)
sites=new((/nsit/), string)
years=new((/nsit/), string)

ts_obs=new((/nsit,8,ntot/), float)

   ij=0
do ns=0, nsit-1

  DataFileName = obsdir + "/derived/" + SiteFileName(ns)

  if (fileexists(DataFileName)) then

     print(DataFileName)

     fdata = asciiread(DataFileName,-1,"string")
     print(fdata)
     cdata=stringtochar(fdata)
     delete(fdata)

     cfile     = stringtochar(SiteFileName(ns))
     sites(ns) = charactertostring(cfile(0:5))

     year1 = stringtoint(charactertostring(cdata(1:,0:3)))
     mont1 = stringtoint(charactertostring(cdata(1:,5:7)))
     lats1 = stringtofloat(charactertostring(cdata(1:,12:19)))
     lons1 = stringtofloat(charactertostring(cdata(1:,22:29)))
     tas = stringtofloat(charactertostring(cdata(1:,41:49)))
     pre = stringtofloat(charactertostring(cdata(1:,51:59)))
     shf = stringtofloat(charactertostring(cdata(1:,61:69)))
     lef = stringtofloat(charactertostring(cdata(1:,71:79)))
     rec = stringtofloat(charactertostring(cdata(1:,81:89)))
     nee = stringtofloat(charactertostring(cdata(1:,91:99)))
     gpp = stringtofloat(charactertostring(cdata(1:,101:109)))
     rnf = stringtofloat(charactertostring(cdata(1:,111:119)))

     tas@_FillValue=-999
     pre@_FillValue=-999
     gpp@_FillValue=-999
     nee@_FillValue=-999
     rec@_FillValue=-999
     lef@_FillValue=-999
     shf@_FillValue=-999
     rnf@_FillValue=-999

     iyear1=new((/8/), integer)
     iyear2=new((/8/), integer)

     i501=ind(.not.ismissing(tas))
     i502=ind(.not.ismissing(pre))
     i503=ind(.not.ismissing(gpp))
     i504=ind(.not.ismissing(nee))
     i505=ind(.not.ismissing(rec))
     i506=ind(.not.ismissing(lef))
     i507=ind(.not.ismissing(shf))
     i508=ind(.not.ismissing(rnf))

     if (dimsizes(i501).gt.1 .or. .not.ismissing(i501)) then
        iyear1(0) = min(year1(i501))
        iyear2(0) = max(year1(i501))
     end if

     if (dimsizes(i502).gt.1 .or. .not.ismissing(i502)) then
        iyear1(1) = min(year1(i502))
        iyear2(1) = max(year1(i502))
     end if

     if (dimsizes(i503).gt.1 .or. .not.ismissing(i503)) then
        iyear1(2) = min(year1(i503))
        iyear2(2) = max(year1(i503))
     end if

     if (dimsizes(i504).gt.1 .or. .not.ismissing(i504)) then
        iyear1(3) = min(year1(i504))
        iyear2(3) = max(year1(i504))
     end if

     if (dimsizes(i505).gt.1 .or. .not.ismissing(i505)) then
        iyear1(4) = min(year1(i505))
        iyear2(4) = max(year1(i505))
     end if

     if (dimsizes(i506).gt.1 .or. .not.ismissing(i506)) then
        iyear1(5) = min(year1(i506))
        iyear2(5) = max(year1(i506))
     end if

     if (dimsizes(i507).gt.1 .or. .not.ismissing(i507)) then
        iyear1(6) = min(year1(i507))
        iyear2(6) = max(year1(i507))
     end if

     if (dimsizes(i508).gt.1 .or. .not.ismissing(i508)) then
        iyear1(7) = min(year1(i508))
        iyear2(7) = max(year1(i508))
     end if

     iyear1@_FillValue=-999
     iyear2@_FillValue=-999

     slats(ns) = lats1(0)
     slons(ns) = lons1(0)
     years(ns) = sprinti("%0.4i",min(iyear1)) + "-" + sprinti("%0.4i",max(iyear2))

     ;i50=ind(year1.ge.start_year .and. year1.le.end_year)
     i50=ind(year1.ge.start_year .and. year1.le.end_year  .and. .not.ismissing(tas))

     ndim=dimsizes(i50)

    ; if (ndim.gt.1 .or. .not.ismissing(i50)) then
     if (ndim.gt.24) then

        year2=year1(i50)
        mont2=mont1(i50)
        tas0=tas(i50)
        pre0=pre(i50)
        gpp0=gpp(i50)
        nee0=nee(i50)
        rec0=rec(i50)
        lef0=lef(i50)
        shf0=shf(i50)
        rnf0=rnf(i50)

        do nd=0, ndim-1
           ijk=(year2(nd) - start_year)*12 + mont2(nd) - 1
           ts_obs(ns,0,ijk)=tas0(nd)
           ts_obs(ns,1,ijk)=pre0(nd)
           ts_obs(ns,2,ijk)=gpp0(nd)
           ts_obs(ns,3,ijk)=nee0(nd)
           ts_obs(ns,4,ijk)=rec0(nd)
           ts_obs(ns,5,ijk)=lef0(nd)
           ts_obs(ns,6,ijk)=shf0(nd)
           ts_obs(ns,7,ijk)=rnf0(nd)
        end do

        delete(year2)
        delete(mont2)
        delete(tas0)
        delete(pre0)
        delete(gpp0)
        delete(nee0)
        delete(rec0)
        delete(lef0)
        delete(shf0)
        delete(rnf0)
      end if

     delete(tas)
     delete(pre)
     delete(gpp)
     delete(nee)
     delete(rec)
     delete(lef)
     delete(shf)
     delete(rnf)
     delete(i50)
     delete(i501)
     delete(i502)
     delete(i503)
     delete(i504)
     delete(i505)
     delete(i506)
     delete(i507)
     delete(i508)
     delete(lats1)
     delete(lons1)
     delete(year1)
     delete(mont1)
     delete(cdata)
     delete(cfile)
     delete(iyear1)
     delete(iyear2)
  end if
end do

print(slons)
print(slats)

; correct observation error for sites listed in the site2
do kk0=0, dimsizes(site2)-1
   kk=site2(kk0)-1
   if (site2(kk0).eq.3) then
      ts_obs(kk,3,264:268) = -999
      ts_obs(kk,2,264:268) = -999
      ts_obs(kk,4,264:268) = -999
      ;print(tt1(kk,0,:))
   end if
   if (site2(kk0).eq.8) then
      ts_obs(kk,3,209:210) = -999
      ts_obs(kk,2,209:210) = -999
      ts_obs(kk,4,209:210) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.12) then
      ts_obs(kk,7,240:241) = -999
      ;print(tt8(kk,0,:))
   end if
   if (site2(kk0).eq.13) then
      ts_obs(kk,3,216:217) = -999
      ts_obs(kk,2,216:217) = -999
      ts_obs(kk,4,216:217) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.16) then
      ts_obs(kk,3,276) = -999
      ts_obs(kk,2,276) = -999
      ts_obs(kk,4,276) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.18) then
      ts_obs(kk,7,267:287) = -999
      ;print(tt8(kk,0,:))
   end if
   if (site2(kk0).eq.29) then
      ts_obs(kk,3,258) = -999
      ts_obs(kk,2,258) = -999
      ts_obs(kk,4,258) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.31) then
      ts_obs(kk,6,207:208) = -999
      ts_obs(kk,7,207:209) = -999
      ;print(tt6(kk,0,:))
      ;print(tt8(kk,0,:))
   end if
   if (site2(kk0).eq.38) then
      ts_obs(kk,6,276:277) = -999
      ;print(tt6(kk,0,:))
   end if
   if (site2(kk0).eq.48) then
      ts_obs(kk,3,276) = -999
      ts_obs(kk,2,276) = -999
      ts_obs(kk,4,276) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.57) then
      ts_obs(kk,3,307:308) = -999
      ts_obs(kk,2,307:308) = -999
      ts_obs(kk,4,307:308) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.69) then
      ts_obs(kk,3,252:260) = -999
      ts_obs(kk,2,252:260) = -999
      ts_obs(kk,4,252:260) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.71) then
      ts_obs(kk,6,292:297) = -999
      ts_obs(kk,7,303) = -999
      ;print(tt6(kk,0,:))
      ;print(tt8(kk,0,:))
   end if
   if (site2(kk0).eq.85) then
      ts_obs(kk,3,208:211) = -999
      ts_obs(kk,2,208:211) = -999
      ts_obs(kk,4,208:211) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.92) then
      ts_obs(kk,7,:) = -999
      ;print(tt8(kk,0,:))
   end if
   if (site2(kk0).eq.115) then
      ts_obs(kk,3,242:244) = -999
      ts_obs(kk,2,242:244) = -999
      ts_obs(kk,4,242:244) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.116) then
      ts_obs(kk,3,263) = -999
      ts_obs(kk,2,263) = -999
      ts_obs(kk,4,263) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.117) then
      ts_obs(kk,3,263) = -999
      ts_obs(kk,2,263) = -999
      ts_obs(kk,4,263) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.130) then
      ts_obs(kk,7,262:263) = -999
      ;print(tt8(kk,0,:))
   end if
end do

ts_obs@_FillValue=-999

k50=dim_pqsort(slats, -2)

ts_obs=ts_obs(k50,:,:)
sites=sites(k50)
slons=slons(k50)
sites=sites(k50)
years=years(k50)

nums=new((/nsit,8/), integer)

do ns=0,nsit-1
do nt=0,7
   i50=ind(.not.ismissing(ts_obs(ns,nt,:)))
   if (dimsizes(i50).gt.1 .or. .not.ismissing(i50)) then
      nums(ns,nt) = dimsizes(i50)
   else
      nums(ns,nt) = 0
   end if
   delete(i50)
end do
end do

;TableFileName = "summary_FluxNet_all.variables_full.txt"
TableFileName = "summary_FluxNet_all.variables_24mons.txt"

hd1 = "Sites"
hd2 = "Latitude"
hd3 = "Longitude"
hd4 = "Period"
hd5 = "Tas"
hd6 = "Prec"
hd7 = "GPP"
hd8 = "NEE"
hd9 = "Reco"
hd10 = "LE"
hd11 = "SH"
hd12 = "Rn"

print(TableFileName)

write_table(TableFileName, "w", [/hd1,hd2,hd3,hd4,hd5,hd6,hd7,hd8,hd9,hd10,hd11,hd12/], "%6s %10s %10s %10s %5s %5s %5s %5s %5s %5s %5s %5s")
write_table(TableFileName, "a", [/sites,slats,slons,years,nums(:,0),nums(:,1),nums(:,2),nums(:,3),nums(:,4),nums(:,5),nums(:,6),nums(:,7)/], \
            "%6s %10.2f %10.2f %10s %5i %5i %5i %5i %5i %5i %5i %5i")

print(asciiread(TableFileName,-1,"string"))

end
