load "/sopt/ncl/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "/sopt/ncl/lib/ncarg/nclex/gsun/gsn_csm.ncl"
load "/sopt/ncl/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/sopt/ncl/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "/gdata/randerson2/mmu/ILAMB/CODES/subroutines/read_gbaf.ncl"
load "/gdata/randerson2/mmu/ILAMB/CODES/subroutines/read_albedo.ncl"
load "/gdata/randerson2/mmu/ILAMB/CODES/subroutines/interp_benchmark_to_cmip5.ncl"
load "/gdata/randerson2/mmu/ILAMB/CODES/subroutines/read_cmip5_vars.ncl"
load "/gdata/randerson2/mmu/ILAMB/CODES/subroutines/read_cmip5_lat.ncl"
load "/gdata/randerson2/mmu/ILAMB/CODES/subroutines/read_cmip5_lon.ncl"

begin

nmod=3
start_year=1979
end_year=2005
nyer=end_year-start_year + 1
nmon=12
ntot=nyer*nmon

nday=(/31,28,31,30,31,30,31,31,30,31,30,31/)

varID = "Tas" 

;modelID=(/"FluxNet","CLM45.ctl","CLM45.exp","CCSM4"/)
modelID=(/"bcc-csm1-1","CanESM2","CCSM4","GFDL-ESM2G","HadGEM2-CC","HadGEM2-ES","inmcm4","IPSL-CM5A-LR","IPSL-CM5A-MR",\
          "MIROC-ESM","MIROC-ESM-CHEM","MPI-ESM-LR","NorESM1-M","GBAF (MTE)","meanModel","FluxNet"/)

; the length of data shorter than 24 months (ts)
site1 = (/1,4,6,10,11,28,30,33,35,39,40,44,50,51,65,66,70,82,84,86,87,90,93,94,97,100,102,103,104,108,109,110,114,125,131,134,141,142,143,145,146,147,148,149/)
; data has err (ts)
site2 = (/3,8,12,13,16,18,29,31,38,48,57,69,71,85,92,115,116,117,130/)

regnames=(/"US-central","US-east","US-west","US-north","Europe-central","Europe-north","Asia-north","Asia-south","Australia","Africa-south","South-America"/)
slat1=(/ 32.5, 40.,  35.,  45., 38., 60.,50., -5.,-40.,-30., -5./)
slat2=(/ 47.5, 50.,  50.,  60., 60., 70.,65.,  5.,-35.,-15.,  0./)
slon1=(/-100.,-80.,-125.,-110.,-15., 15.,85.,110.,140., 20.,-60./)
slon2=(/-82.5,-65.,-115., -95., 22., 30.,95.,120.,150., 35.,-50./)

; ------- read FluxNet data -----
obsdir="/gdata/randerson2/mmu/ILAMB/datasets/BENCHMARKS/FluxNet"

SiteListName = obsdir + "/derived/sites.all"
print(SiteListName)

SiteFileName = asciiread(SiteListName,-1,"string")
print(SiteFileName)
nsit=dimsizes(SiteFileName)
print(nsit)

FileName = obsdir + "/derived/sites_info_all.txt"
print(FileName)

values_1d = asciiread(FileName,-1,"string")

ncols     = dimsizes(str_split(values_1d(1),","))
nrows     = dimsizes(values_1d)

print(ncols)
print(nrows)

site0 = str_squeeze(str_get_field(values_1d, 1, ","))
type0 = str_squeeze(str_get_field(values_1d, 2, ","))
slats = str_squeeze(str_get_field(values_1d, 3, ","))
slons = str_squeeze(str_get_field(values_1d, 4, ","))
perid = str_squeeze(str_get_field(values_1d, 5, ","))
lats0 = stringtofloat(str_get_field(values_1d, 3, ","))
lons0 = stringtofloat(str_get_field(values_1d, 4, ","))

;------------- read data from files ----------------
file1_in="datasets/ts_nee_CLM45.control+exp1_FluxNet.dat"
file2_in="datasets/ts_gpp_CLM45.control+exp1_FluxNet.dat"
file3_in="datasets/ts_reco_CLM45.control+exp1_FluxNet.dat"
file4_in="datasets/ts0_pr_CLM45.control+exp1_FluxNet.dat"
file5_in="datasets/ts_le_CLM45.control+exp1_FluxNet.dat"
file6_in="datasets/ts_sh_CLM45.control+exp1_FluxNet.dat"
file7_in="datasets/ts0_tas_CLM45.control+exp1_FluxNet.dat"
file8_in="datasets/ts_rn_CLM45.control+exp1_FluxNet.dat"

tt1=fbindirread(file1_in,0,(/nsit,nmod,ntot/),"float")
tt2=fbindirread(file2_in,0,(/nsit,nmod,ntot/),"float")
tt3=fbindirread(file3_in,0,(/nsit,nmod,ntot/),"float")
tt4=fbindirread(file4_in,0,(/nsit,nmod,ntot/),"float")
tt5=fbindirread(file5_in,0,(/nsit,nmod,ntot/),"float")
tt6=fbindirread(file6_in,0,(/nsit,nmod,ntot/),"float")
tt7=fbindirread(file7_in,0,(/nsit,nmod,ntot/),"float")
tt8=fbindirread(file8_in,0,(/nsit,nmod,ntot/),"float")

tt1 = where(tt1.le.-990, -999, tt1)
tt2 = where(tt2.le.-990, -999, tt2)
tt3 = where(tt3.le.-990, -999, tt3)
tt4 = where(tt4.le.-990, -999, tt4)
tt5 = where(tt5.le.-990, -999, tt5)
tt6 = where(tt6.le.-990, -999, tt6)
tt7 = where(tt7.le.-990, -999, tt7)
tt8 = where(tt8.le.-990, -999, tt8)

tt1@_FillValue=-999
tt2@_FillValue=-999
tt3@_FillValue=-999
tt4@_FillValue=-999
tt5@_FillValue=-999
tt6@_FillValue=-999
tt7@_FillValue=-999
tt8@_FillValue=-999

tt1=tt2-tt3

tt1 = where(ismissing(tt2), -999, tt1)

; correct observation error for sites listed in the site2
do kk0=0, dimsizes(site2)-1
   kk=site2(kk0)-1
   if (site2(kk0).eq.3) then
      tt1(kk,0,264:268) = -999
      tt2(kk,0,264:268) = -999
      tt3(kk,0,264:268) = -999
      ;print(tt1(kk,0,:))
   end if
   if (site2(kk0).eq.8) then
      tt1(kk,0,209:210) = -999
      tt2(kk,0,209:210) = -999
      tt3(kk,0,209:210) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.12) then
      tt8(kk,0,240:241) = -999
      ;print(tt8(kk,0,:))
   end if
   if (site2(kk0).eq.13) then
      tt1(kk,0,216:217) = -999
      tt2(kk,0,216:217) = -999
      tt3(kk,0,216:217) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.16) then
      tt1(kk,0,276) = -999
      tt2(kk,0,276) = -999
      tt3(kk,0,276) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.18) then
      tt8(kk,0,267:287) = -999
      ;print(tt8(kk,0,:))
   end if
   if (site2(kk0).eq.29) then
      tt1(kk,0,258) = -999
      tt2(kk,0,258) = -999
      tt3(kk,0,258) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.31) then
      tt6(kk,0,207:208) = -999
      tt8(kk,0,207:209) = -999
      ;print(tt6(kk,0,:))
      ;print(tt8(kk,0,:))
   end if
   if (site2(kk0).eq.38) then
      tt6(kk,0,276:277) = -999
      ;print(tt6(kk,0,:))
   end if
   if (site2(kk0).eq.48) then
      tt1(kk,0,276) = -999
      tt2(kk,0,276) = -999
      tt3(kk,0,276) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.57) then
      tt1(kk,0,307:308) = -999
      tt2(kk,0,307:308) = -999
      tt3(kk,0,307:308) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.69) then
      tt1(kk,0,252:260) = -999
      tt2(kk,0,252:260) = -999
      tt3(kk,0,252:260) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.71) then
      tt6(kk,0,292:297) = -999
      tt8(kk,0,303) = -999
      ;print(tt6(kk,0,:))
      ;print(tt8(kk,0,:))
   end if
   if (site2(kk0).eq.85) then
      tt1(kk,0,208:211) = -999
      tt2(kk,0,208:211) = -999
      tt3(kk,0,208:211) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.92) then
      tt8(kk,0,:) = -999
      ;print(tt8(kk,0,:))
   end if
   if (site2(kk0).eq.115) then
      tt1(kk,0,242:244) = -999
      tt2(kk,0,242:244) = -999
      tt3(kk,0,242:244) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.116) then
      tt1(kk,0,263) = -999
      tt2(kk,0,263) = -999
      tt3(kk,0,263) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.117) then
      tt1(kk,0,263) = -999
      tt2(kk,0,263) = -999
      tt3(kk,0,263) = -999
      ;print(tt3(kk,0,:))
   end if
   if (site2(kk0).eq.130) then
      tt8(kk,0,262:263) = -999
      ;print(tt8(kk,0,:))
   end if
end do

;------------- read data from files ----------------
file1_in="datasets/ts_nee_GBAF+cmip5.Historical_FluxNet.dat"
file2_in="datasets/ts_gpp_GBAF+cmip5.Historical_FluxNet.dat"
file3_in="datasets/ts_reco_GBAF+cmip5.Historical_FluxNet.dat"
file4_in="datasets/ts0_pr_GPCP2+cmip5.Historical_FluxNet.dat"
file5_in="datasets/ts_le_GBAF+cmip5.Historical_FluxNet.dat"
file6_in="datasets/ts_sh_GBAF+cmip5.Historical_FluxNet.dat"
file7_in="datasets/ts0_tas_CRU+cmip5.Historical_FluxNet.dat"
file8_in="datasets/ts_rn_CERES+cmip5.Historical_FluxNet.dat"

nmod0=14
ss1=fbindirread(file1_in,0,(/nsit,nmod0+2,ntot/),"float")
ss2=fbindirread(file2_in,0,(/nsit,nmod0+2,ntot/),"float")
ss3=fbindirread(file3_in,0,(/nsit,nmod0+2,ntot/),"float")
ss4=fbindirread(file4_in,0,(/nsit,nmod0+2,ntot/),"float")
ss5=fbindirread(file5_in,0,(/nsit,nmod0+2,ntot/),"float")
ss6=fbindirread(file6_in,0,(/nsit,nmod0+2,ntot/),"float")
ss7=fbindirread(file7_in,0,(/nsit,nmod0+2,ntot/),"float")
ss8=fbindirread(file8_in,0,(/nsit,nmod0+2,ntot/),"float")

ss1 = where(ss1.le.-990, -999, ss1)
ss2 = where(ss2.le.-990, -999, ss2)
ss3 = where(ss3.le.-990, -999, ss3)
ss4 = where(ss4.le.-990, -999, ss4)
ss5 = where(ss5.le.-990, -999, ss5)
ss6 = where(ss6.le.-990, -999, ss6)
ss7 = where(ss7.le.-990, -999, ss7)
ss8 = where(ss8.le.-990, -999, ss8)

ss1@_FillValue=-999
ss2@_FillValue=-999
ss3@_FillValue=-999
ss4@_FillValue=-999
ss5@_FillValue=-999
ss6@_FillValue=-999
ss7@_FillValue=-999
ss8@_FillValue=-999

tt4(:,0,:) = ss4(:,nmod0+1,:)
tt7(:,0,:) = ss7(:,nmod0+1,:)

;lats0(site1-1) = -999
;lons0(site1-1) = -999

lats0@_FillValue=-999
lons0@_FillValue=-999

;k501=dim_pqsort(lats0, -2)
;print(k501)

;tt1 = tt1(k501,:,:)
;tt2 = tt2(k501,:,:)
;tt3 = tt3(k501,:,:)
;tt4 = tt4(k501,:,:)
;tt5 = tt5(k501,:,:)
;tt6 = tt6(k501,:,:)

;lons0=lons0(k501)
;site0=site0(k501)
;type0=type0(k501)
;perid=perid(k501)
;corre=corre(k501)

;delete(k501)

nmod=14

sst1=new((/nsit,nmod+2,ntot/), float)
sst2=new((/nsit,nmod+2,ntot/), float)
sst3=new((/nsit,nmod+2,ntot/), float)
sst4=new((/nsit,nmod+2,ntot/), float)
sst5=new((/nsit,nmod+2,ntot/), float)
sst6=new((/nsit,nmod+2,ntot/), float)
sst7=new((/nsit,nmod+2,ntot/), float)
sst8=new((/nsit,nmod+2,ntot/), float)

sst1(:,nmod+1,:)=tt1(:,0,:)
sst2(:,nmod+1,:)=tt2(:,0,:)
sst3(:,nmod+1,:)=tt3(:,0,:)
sst4(:,nmod+1,:)=tt4(:,0,:)
sst5(:,nmod+1,:)=tt5(:,0,:)
sst6(:,nmod+1,:)=tt6(:,0,:)
sst7(:,nmod+1,:)=tt7(:,0,:)
sst8(:,nmod+1,:)=tt8(:,0,:)

sst1(:,nmod,:)=ss1(:,1,:)
sst2(:,nmod,:)=ss2(:,1,:)
sst3(:,nmod,:)=ss3(:,1,:)
sst4(:,nmod,:)=ss4(:,1,:)
sst5(:,nmod,:)=ss5(:,1,:)
sst6(:,nmod,:)=ss6(:,1,:)
sst7(:,nmod,:)=ss7(:,1,:)
sst8(:,nmod,:)=ss8(:,1,:)

sst1(:,0:nmod-1,:)=ss1(:,2:nmod+1,:)
sst2(:,0:nmod-1,:)=ss2(:,2:nmod+1,:)
sst3(:,0:nmod-1,:)=ss3(:,2:nmod+1,:)
sst4(:,0:nmod-1,:)=ss4(:,2:nmod+1,:)
sst5(:,0:nmod-1,:)=ss5(:,2:nmod+1,:)
sst6(:,0:nmod-1,:)=ss6(:,2:nmod+1,:)
sst7(:,0:nmod-1,:)=ss7(:,2:nmod+1,:)
sst8(:,0:nmod-1,:)=ss8(:,2:nmod+1,:)

delete(tt1)
delete(tt2)
delete(tt3)
delete(tt4)
delete(tt5)
delete(tt6)
delete(tt7)
delete(tt8)

tt1=sst1
tt2=sst2
tt3=sst3
tt4=sst4
tt5=sst5
tt6=sst6
tt7=sst7
tt8=sst8

delete(sst1)
delete(sst2)
delete(sst3)
delete(sst4)
delete(sst5)
delete(sst6)
delete(sst7)
delete(sst8)

tt1!0="site"
tt1!1="var"
tt1!2="time"

tt2!0="site"
tt2!1="var"
tt2!2="time"

tt3!0="site"
tt3!1="var"
tt3!2="time"

tt4!0="site"
tt4!1="var"
tt4!2="time"

tt5!0="site"
tt5!1="var"
tt5!2="time"

tt6!0="site"
tt6!1="var"
tt6!2="time"

tt7!0="site"
tt7!1="var"
tt7!2="time"

tt8!0="site"
tt8!1="var"
tt8!2="time"

do nv = 0, nmod
   tt1(:,nv,:)=where(ismissing(tt1(:,0,:)), -999, tt1(:,nv,:))
   tt2(:,nv,:)=where(ismissing(tt2(:,0,:)), -999, tt2(:,nv,:))
   tt3(:,nv,:)=where(ismissing(tt3(:,0,:)), -999, tt3(:,nv,:))
   tt4(:,nv,:)=where(ismissing(tt4(:,0,:)), -999, tt4(:,nv,:))
   tt5(:,nv,:)=where(ismissing(tt5(:,0,:)), -999, tt5(:,nv,:))
   tt6(:,nv,:)=where(ismissing(tt6(:,0,:)), -999, tt6(:,nv,:))
   tt7(:,nv,:)=where(ismissing(tt7(:,0,:)), -999, tt7(:,nv,:))
   tt8(:,nv,:)=where(ismissing(tt8(:,0,:)), -999, tt8(:,nv,:))
end do

nreg = 5

k50=ind((lats0.ge.-90. .and. lats0.le.90.) .and. (lons0.ge.-180. .and. lons0.le.180.)) ; global

;k50=ind((lats0.ge.slat1(nreg) .and. lats0.le.slat2(nreg)) .and. (lons0.ge.slon1(nreg) .and. lons0.le.slon2(nreg)))

ndim=dimsizes(k50)

;do kk=0, nsit-1
;do kk=0, dimsizes(k50)-1
;do kk0=0, dimsizes(site2)-1
;   kk=site2(kk0)-1
;   kk=130-1

   sst1=new((/nmod+2,nyer,ndim,nmon/), float)
   sst2=new((/nmod+2,nyer,ndim,nmon/), float)
   sst3=new((/nmod+2,nyer,ndim,nmon/), float)
   sst4=new((/nmod+2,nyer,ndim,nmon/), float)
   sst5=new((/nmod+2,nyer,ndim,nmon/), float)
   sst6=new((/nmod+2,nyer,ndim,nmon/), float)
   sst7=new((/nmod+2,nyer,ndim,nmon/), float)
   sst8=new((/nmod+2,nyer,ndim,nmon/), float)

      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      ;sst1(:,im,iy)=tt1(var|:,time|ijk,site|kk)
      ;sst2(:,im,iy)=tt2(var|:,time|ijk,site|kk)
      ;sst3(:,im,iy)=tt3(var|:,time|ijk,site|kk)
      ;sst4(:,im,iy)=tt4(var|:,time|ijk,site|kk)
      ;sst5(:,im,iy)=tt5(var|:,time|ijk,site|kk)
      ;sst6(:,im,iy)=tt6(var|:,time|ijk,site|kk)
      ;sst7(:,im,iy)=tt7(var|:,time|ijk,site|kk)
      ;sst8(:,im,iy)=tt8(var|:,time|ijk,site|kk)
      sst1(:,iy,:,im)=tt1(var|:,site|k50,time|ijk)
      sst2(:,iy,:,im)=tt2(var|:,site|k50,time|ijk)
      sst3(:,iy,:,im)=tt3(var|:,site|k50,time|ijk)
      sst4(:,iy,:,im)=tt4(var|:,site|k50,time|ijk)
      sst5(:,iy,:,im)=tt5(var|:,site|k50,time|ijk)
      sst6(:,iy,:,im)=tt6(var|:,site|k50,time|ijk)
      sst7(:,iy,:,im)=tt7(var|:,site|k50,time|ijk)
      sst8(:,iy,:,im)=tt8(var|:,site|k50,time|ijk)
      ijk=ijk+1
   end do
   end do

   sst1 = where(sst1.le.-990, -999, sst1)
   sst2 = where(sst2.le.-990, -999, sst2)
   sst3 = where(sst3.le.-990, -999, sst3)
   sst4 = where(sst4.le.-990, -999, sst4)
   sst5 = where(sst5.le.-990, -999, sst5)
   sst6 = where(sst6.le.-990, -999, sst6)
   sst7 = where(sst7.le.-990, -999, sst7)
   sst8 = where(sst8.le.-990, -999, sst8)

   sst1@_FillValue=-999
   sst2@_FillValue=-999
   sst3@_FillValue=-999
   sst4@_FillValue=-999
   sst5@_FillValue=-999
   sst6@_FillValue=-999
   sst7@_FillValue=-999
   sst8@_FillValue=-999

   ;st6=st6/st5
   sst5=sst5*1e-3*3600*24/2501

   st1=dim_avg(dim_avg(sst1))
   st2=dim_avg(dim_avg(sst2))
   st3=dim_avg(dim_avg(sst3))
   st4=dim_avg(dim_avg(sst4))
   st5=dim_avg(dim_avg(sst5))
   st6=dim_avg(dim_avg(sst6))
   st7=dim_avg(dim_avg(sst7))
   st8=dim_avg(dim_avg(sst8))

   st1!0="var"
   st1!1="time"
   ;st1&time=fspan(0.5,11.5,nmon)
   ;st1&time=fspan(start_year,end_year+1,ntot)
   st1&time=fspan(start_year,end_year,nyer)

   st2!0="var"
   st2!1="time"
   ;st2&time=fspan(0.5,11.5,nmon)
   ;st2&time=fspan(start_year,end_year+1,ntot)
   st2&time=fspan(start_year,end_year,nyer)

   st3!0="var"
   st3!1="time"
   ;st3&time=fspan(0.5,11.5,nmon)
   ;st3&time=fspan(start_year,end_year+1,ntot)
   st3&time=fspan(start_year,end_year,nyer)

   st4!0="var"
   st4!1="time"
   ;st4&time=fspan(0.5,11.5,nmon)
   ;st4&time=fspan(start_year,end_year+1,ntot)
   st4&time=fspan(start_year,end_year,nyer)

   st5!0="var"
   st5!1="time"
   ;st5&time=fspan(0.5,11.5,nmon)
   ;st5&time=fspan(start_year,end_year+1,ntot)
   st5&time=fspan(start_year,end_year,nyer)

   st6!0="var"
   st6!1="time"
   ;st6&time=fspan(0.5,11.5,nmon)
   ;st6&time=fspan(start_year,end_year+1,ntot)
   st6&time=fspan(start_year,end_year,nyer)

   st7!0="var"
   st7!1="time"
   ;st7&time=fspan(0.5,11.5,nmon)
   ;st7&time=fspan(start_year,end_year+1,ntot)
   st7&time=fspan(start_year,end_year,nyer)

   st8!0="var"
   st8!1="time"
   ;st8&time=fspan(0.5,11.5,nmon)
   ;st8&time=fspan(start_year,end_year+1,ntot)
   st8&time=fspan(start_year,end_year,nyer)

;  ---------  draw pictures ------------------
;  plotname="ts_CLM45_FluxNet_central.US." + sprinti("%0.2i",kk+1)
;  plotname="tsann_cmip5_FluxNet_" + regnames(nreg)
  plotname="ts_cmip5_FluxNet_60N-90N" 

  wks = gsn_open_wks("x11",plotname)

;  cmap = (/(/1., 1., 1./), (/0., 0., 0./), (/1., 0., 0./), (/1., 0., .4/), \
;           (/1., 0., .8/), (/1., .2, 1./), (/1., .6, 1./), (/.6, .8, 1./), \
;           (/.2, .8, 1./), (/.2, .8, .6/), (/.2, .8, 0./), (/.2, .4, .0/), \
;           (/.2, .4, .4/), (/.2, .4, .8/), (/.6, .4, .8/), (/.6, .8, .8/), \
;           (/.6, .8, .4/), (/1., .6, .8/)/)

  gsn_define_colormap(wks,"default")
;  gsn_define_colormap(wks,"BlAqGrYeOrRe")
;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
;  gsn_define_colormap(wks,"BlWhRe")
;  i  =  NhlNewColor(wks, 0.6, 0.6, 0.6)

; reverse the first two colors
;  setvalues wks
;    "wkForegroundColor" : (/1.,1.,1./)
;    "wkBackgroundColor" : (/0.,0.,0./)
;  end setvalues

;  --------   set  res1 ------------

  res1                        = True
  res1@gsnDraw                = False
  res1@gsnFrame               = False

  res1@tmYRLabelFont          = "helvetica"
  res1@tmYLLabelFont          = "helvetica"
  res1@tmXBLabelFont          = "helvetica"
  res1@tmYRLabelFontHeightF   = 0.015
  res1@tmYLLabelFontHeightF   = 0.015
  res1@tmXBLabelFontHeightF   = 0.015
;  res1@tiYAxisString          = "Surface CO2 (ppm)"
;  res1@tiYAxisString          = "CO (x10:S:18:N: molec/cm:S:2:N:) at Darwin (12.4:S:o:N:S, 130.9:S:o:N:E)"
  res1@tiXAxisFont            = "helvetica-Bold" 
  res1@tiYAxisFont            = "helvetica-Bold" 
  res1@tiXAxisFontHeightF     = 0.016
  res1@tiYAxisFontHeightF     = 0.016
;  res1@tmXBLabelsOn           = False
;  res1@tmYRLabelsOn           = False
;  res1@tiMainString           = "Average over [5:S:o:N:-20:S:o:N:N, 120:S:o:N:-160:S:o:N:E]" 
  res1@tiMainFont             = "helvetica-Bold" 
  res1@gsnStringFontHeightF   = 0.016
  res1@gsnStringFont          = "helvetica-Bold"
;  res1@gsnLeftString          = strings(nr)
  res1@gsnCenterString        = ""
;  res1@trYMinF                = 0.0
;  res1@trYMaxF                = 4.5
  res1@trXMinF                = 1990
  res1@trXMaxF                = 2005

;  res1@tmXBMode              = "Explicit"
;  res1@tmXBValues            = (/0,1,2,3,4,5,6,7,8,9,10,11,12/)
;  res1@tmXBLabels            = (/"J","F","M","A","M","J","J","A","S","O","N","D","J"/)

  res1@tmXBAutoPrecision     = False
  res1@tmXBPrecision         = 4
;  res1@tmYLPrecision         = 3
;  res1@tmXBMode              = "Explicit"
;  res1@tmXBValues            = (/2004,2005,2006,2007/)
;  res1@tmXBLabels            = (/"2004","2005","2006","2007"/) 

  res1@xyLabelMode           = "Custom" 
  res1@xyLineColors          = (/1,4,2,19,24,22,7,20,31,12,13,16,23,14,3,1,1/)
  res1@xyDashPatterns        = (/0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/)
  res1@xyLineLabelFontColors = (/1,2,3,4,5,6,7,20,26,3,5,6,23,14,3,1,1/)
  res1@xyLineThicknesses     = (/2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,2,2/)
  res1@xyExplicitLabels      = (/"","","","","","","","","","","","","","","","","",""/)
  res1@xyLineLabelFontHeightF = 0.01 
;  res1@gsnLeftFontHeightF     = 0.01 

  res1@tmXBLabelsOn           = True
  res1@tmYLLabelsOn           = True

  res1@vpXF                  = 0.07
  res1@vpYF                  = 0.97
  res1@vpWidthF              = 0.25
  res1@vpHeightF             = 0.25

  res1@gsnCenterString      = "NEE (g C /m~S~2~N~ /day)"
;  res1@tiYAxisString         = "Net Ecosystem Exchange (g C /m~S~2~N~ /day)"
  plot1 = gsn_csm_xy(wks,st1&time,st1,res1)
  draw (plot1)

  res1@vpXF                  = 0.40
  res1@gsnCenterString      = "GPP (g C /m~S~2~N~ /day)"
;  res1@tiYAxisString         = "Gross Primary Production (g C /m~S~2~N~ /day)"
  plot2 = gsn_csm_xy(wks,st2&time,st2,res1)
  draw (plot2)

  res1@vpXF                  = 0.73
  res1@gsnCenterString      = "Reco (g C /m~S~2~N~ /day)"
;  res1@tiYAxisString         = "Ecosystem Respiration (g C /m~S~2~N~ /day)"
  plot3 = gsn_csm_xy(wks,st3&time,st3,res1)
  draw (plot3)

  res1@vpXF                  = 0.07
  res1@vpYF                  = 0.63
  res1@gsnCenterString      = "Precip (mm/day)"
;  res1@tiYAxisString         = "Precipitation (mm/day)"
  plot4 = gsn_csm_xy(wks,st4&time,st4,res1)
  draw (plot4)

  res1@vpXF                  = 0.40
  res1@gsnCenterString      = "LE (mm/day)"
;  res1@gsnCenterString      = "LE (W/m~S~2~N~)"
;  res1@tiYAxisString         = "Latent Heat Flux (W/m~S~2~N~)"
  plot5 = gsn_csm_xy(wks,st5&time,st5,res1)
  draw (plot5)

  res1@vpXF                  = 0.73
  res1@gsnCenterString      = "SH (W/m~S~2~N~)"
;  res1@tiYAxisString         = "Sensible Heat Flux (W/m~S~2~N~)"
  plot6 = gsn_csm_xy(wks,st6&time,st6,res1)
  draw (plot6)

  res1@vpXF                  = 0.07
  res1@vpYF                  = 0.29
  res1@gsnCenterString      = "Air Temperature (~S~o~N~C)"
  plot7 = gsn_csm_xy(wks,st7&time,st7,res1)
  draw (plot7)

  res1@vpXF                  = 0.40
  res1@gsnCenterString      = "Net Radiation (W/m~S~2~N~)"
  plot8 = gsn_csm_xy(wks,st8&time,st8,res1)
  draw (plot8)

; ---------------   write text --------------------------

  res_text                    = True
  res_text@txFontHeightF      = 0.015
  res_text@txFont             = "helvetica-bold"
  res_text@txJust             = "CenterCenter"

  res_text@txFontColor        = "blue"
;  gsn_text(wks,plot7,"~F37~R",lons0(kk), lats0(kk),res_text)
;  gsn_text(wks,plot7,"~F37~R",lons0(k50(kk)), lats0(k50(kk)),res_text)

  res_text@txFontColor        = "red"
;  gsn_text(wks,plot7,"~F37~m",lons0(kk), lats0(kk),res_text)
;  gsn_text(wks,plot7,"~F37~m",lons0(k50(kk)), lats0(k50(kk)),res_text)
;  gsn_text(wks,plot7,"~F37~m",lons0,lats0,res_text)

  res_text                    = True  
  res_text@txFontHeightF      = 0.014
  res_text@txFont             = "helvetica-bold"
  res_text@txJust             = "CenterLeft" 

  res_lines                   = True 
  res_lines@gsLineDashPattern = 0  
  res_lines@gsLineThicknessF  = 1.  

  res_text@txFontHeightF      = 0.013
  res_text@txJust             = "CenterLeft" 
  xx0 = (/0.65,0.70/)
  yy0 = (/0.85, 0.85/)
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineColor       = "foreground"
  res_text@txFontColor        = "foreground"  
;  gsn_polyline(wks,plot1,xx0,yy0,res_lines) 
;  gsn_text_ndc(wks,strings(nr-1),0.57,0.85,res_text)
;  gsn_text_ndc(wks,"Surface CO (ppbv)",0.57,0.82,res_text)

  res_lines@gsLineThicknessF  = 2.  
  res_lines@gsLineThicknessF  = 2.
  xx0 = (/0.20,0.80/)
  yy0 = (/0.24, 0.24/)
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  xx0 = (/0.20,0.80/)
  yy0 = (/0.16, 0.16/)
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines) 
  xx0 = (/0.20,0.20/)
  yy0 = (/0.16, 0.24/)
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  xx0 = (/0.80,0.80/)
  yy0 = (/0.16, 0.24/)
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)

  xx0 = (/0.72,0.74/)
  yy0 = (/0.31, 0.31/)
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 2.
  res_lines@gsLineColor       = "foreground"
  res_text@txFontColor        = "foreground"
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(15),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineDashPattern = 2
  res_lines@gsLineThicknessF  = 2.
  res_lines@gsLineColor       = "foreground"
  res_text@txFontColor        = "foreground"
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(14),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 2
  res_text@txFontColor        = 2
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(0),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 19
  res_text@txFontColor        = 19
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(1),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 4
  res_text@txFontColor        = 4
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(2),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 24
  res_text@txFontColor        = 24
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(3),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 22
  res_text@txFontColor        = 22
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(4),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 7
  res_text@txFontColor        = 7
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(5),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 20
  res_text@txFontColor        = 20
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(6),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 31
  res_text@txFontColor        = 31
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(7),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 12
  res_text@txFontColor        = 12
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(8),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 13
  res_text@txFontColor        = 13
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(9),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 16
  res_text@txFontColor        = 16
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(10),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 23
  res_text@txFontColor        = 23
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(11),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 14
  res_text@txFontColor        = 14
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(12),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 2.
  res_lines@gsLineColor       = 3
  res_text@txFontColor        = 3
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,modelID(13),xx0(1)+0.01,yy0(0),res_text)

  res_lines@gsLineColor       = "foreground"
  res_text@txFontColor        = "foreground"

;  sinfo1 = "Site Name:   " + site0(kk)
;  sinfo2 = "IGBP Class:  " + type0(kk)
;  sinfo3 = "Latitude:      " + slats(kk)
;  sinfo4 = "Longitude:   " + slons(kk)
;  sinfo5 = "Data Period: " + perid(kk)

;  sinfo1 = "Site Name:   " + site0(k50(kk))
;  sinfo2 = "IGBP Class:  " + type0(k50(kk))
;  sinfo3 = "Latitude:      " + slats(k50(kk))
;  sinfo4 = "Longitude:   " + slons(k50(kk))
;  sinfo5 = "Data Period: " + perid(k50(kk))

  xx0 = (/0.71,0.73/)
  yy0 = (/0.25, 0.25/)
;  gsn_text_ndc(wks,sinfo1,xx0(1),yy0(0),res_text)
  yy0 = yy0 - 0.02
;  gsn_text_ndc(wks,sinfo2,xx0(1),yy0(0),res_text)
  yy0 = yy0 - 0.02
;  gsn_text_ndc(wks,sinfo3,xx0(1),yy0(0),res_text)
  yy0 = yy0 - 0.02
;  gsn_text_ndc(wks,sinfo4,xx0(1),yy0(0),res_text)
  yy0 = yy0 - 0.02
;  gsn_text_ndc(wks,sinfo5,xx0(1),yy0(0),res_text)

  frame(wks)

;end do

end
