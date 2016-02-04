load "/sopt/ncl/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "/sopt/ncl/lib/ncarg/nclex/gsun/gsn_csm.ncl"
load "/sopt/ncl/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/sopt/ncl/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

nvar=8
nyer=15
nmon=12
ntot=nyer*nmon

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

obsdir="/gdata/randerson2/mmu/ILAMB/datasets/BENCHMARKS/EuroFlux"

;++++++++ read EuroFlux site info ++++++++++++
SiteFileName=obsdir + "/" + "SitesList.csv"

values_1d = asciiread(SiteFileName,-1,"string")

ncol     = dimsizes(str_split(values_1d(1),","))
nsit     = dimsizes(values_1d(1:))

print(ncol)
print(nsit)

site = str_get_field(values_1d(1:), 1, ",")

slat = stringtofloat(str_get_field(values_1d(1:), 4, ","))
slon = stringtofloat(str_get_field(values_1d(1:), 5, ","))

delete(values_1d)

print(slat)
print(slon)
print(site)

;------ deal with site codes -------
do ns=0, nsit-1
   if (ns.eq.26 .or. ns.eq.27) then
      cSite=new((/5/), character)
      cData = stringtochar(site(ns))
      cSite(0:1) = cData(4:5)
      cSite(2:4) = cData(7:9)
      site(ns) = charactertostring(cSite)
      delete(cSite)
      delete(cData)
   else
      cSite=new((/5/), character)
      cData = stringtochar(site(ns))
      cSite(0:1) = cData(0:1)
      cSite(2:4) = cData(3:5)
      site(ns) = charactertostring(cSite)
      delete(cSite)
      delete(cData)
   end if
end do

print(site)

sfile=new((/nsit/),string)

;---Read the values in as 1D, since we don't know rows and columns yet.

ts_obs=new((/nsit,nvar,nyer,nmon/), float)

   ij=0
do ns=0, nsit-1

   ts1_obs=new((/nyer,nmon/), float)
   ts2_obs=new((/nyer,nmon/), float)
   ts3_obs=new((/nyer,nmon/), float)
   ts4_obs=new((/nyer,nmon/), float)
   ts5_obs=new((/nyer,nmon/), float)
   ts6_obs=new((/nyer,nmon/), float)
   ts7_obs=new((/nyer,nmon/), float)
   ts8_obs=new((/nyer,nmon/), float)

do iiy=1996, 2010
   iy=iiy-1996

   DataFileName = "empty"

   DataDirName1 = obsdir + "/original/Data/L4/" + "CEIP_EC_L4_" + site(ns) + "_" + sprinti("%0.4i",iiy) + "_v01"
   DataDirName2 = obsdir + "/original/Data/L4/" + "CEIP_EC_L4_" + site(ns) + "_" + sprinti("%0.4i",iiy) + "_v02"

   DataFileName1 = DataDirName1 + "/"  + "CEIP_EC_L4_m_" + site(ns) + "_" + sprinti("%0.4i",iiy) + "_v01.txt"
   DataFileName2 = DataDirName2 + "/"  + "CEIP_EC_L4_m_" + site(ns) + "_" + sprinti("%0.4i",iiy) + "_v02.txt"

   if (fileexists(DataFileName1)) then
      DataFileName = DataFileName1
   end if

   if (fileexists(DataFileName2)) then
      DataFileName = DataFileName2
   end if

   if (fileexists(DataFileName)) then
      print(DataFileName)

      values_1d = asciiread(DataFileName,-1,"string")

      ncols     = dimsizes(str_split(values_1d(1),","))
      nrows     = dimsizes(values_1d(1:))

      print(ncols)
      print(nrows)
        
      month = stringtointeger(str_get_field(values_1d(1:), 1, ","))
      day = stringtointeger(str_get_field(values_1d(1:),   2, ","))
      data1 = stringtofloat(str_get_field(values_1d(1:),   3, ","))
      data2 = stringtofloat(str_get_field(values_1d(1:),   5, ","))
      data3 = stringtofloat(str_get_field(values_1d(1:),  11, ","))
      data4 = stringtofloat(str_get_field(values_1d(1:),  13, ","))
      data5 = stringtofloat(str_get_field(values_1d(1:),  15, ","))
      data6 = stringtofloat(str_get_field(values_1d(1:),  18, ","))
      data7 = stringtofloat(str_get_field(values_1d(1:),  22, ","))
      data8 = stringtofloat(str_get_field(values_1d(1:),  24, ","))

      data1=where(data1.eq.-9999, -999, data1)
      data2=where(data2.eq.-9999, -999, data2)
      data3=where(data3.eq.-9999, -999, data3)
      data4=where(data4.eq.-9999, -999, data4)
      data5=where(data5.eq.-9999, -999, data5)
      data6=where(data6.eq.-9999, -999, data6)
      data7=where(data7.eq.-9999, -999, data7)
      data8=where(data8.eq.-9999, -999, data8)

      data1@_FillValue=-999
      data2@_FillValue=-999
      data3@_FillValue=-999
      data4@_FillValue=-999
      data5@_FillValue=-999
      data6@_FillValue=-999
      data7@_FillValue=-999
      data8@_FillValue=-999

      ;do im=0, nmon-1
      ;   iim=im+1
      ;  
      ;   i50=ind(month.eq.iim)
      ;   if (any(.not.ismissing(i50))) then
      ;      ts1_obs(im)=data1(i50)
      ;      ts2_obs(im)=data2(i50)
      ;      ts3_obs(im)=data3(i50)
      ;      ts4_obs(im)=data4(i50)
      ;      ts5_obs(im)=data5(i50)
      ;      ts6_obs(im)=data6(i50)
      ;      ts7_obs(im)=data7(i50)
      ;      ts8_obs(im)=data8(i50)
      ;   else
      ;      ts1_obs(im)=-999
      ;      ts2_obs(im)=-999
      ;      ts3_obs(im)=-999
      ;      ts4_obs(im)=-999
      ;      ts5_obs(im)=-999
      ;      ts6_obs(im)=-999
      ;      ts7_obs(im)=-999
      ;      ts8_obs(im)=-999
      ;   end if
      ;   print(dimsizes(i50))
      ;   delete(i50)
      ;end do

      ts1_obs(iy,:)=data1
      ts2_obs(iy,:)=data2
      ts3_obs(iy,:)=data3
      ts4_obs(iy,:)=data4
      ts5_obs(iy,:)=data5
      ts6_obs(iy,:)=data6
      ts7_obs(iy,:)=data7
      ts8_obs(iy,:)=data8

      delete(day)
      delete(month)
      delete(data1)
      delete(data2)
      delete(data3)
      delete(data4)
      delete(data5)
      delete(data6)
      delete(data7)
      delete(data8)
      delete(values_1d)
   end if
end do

   i60 = ind(any(.not.ismissing(ndtooned(ts1_obs))) .and. any(.not.ismissing(ndtooned(ts2_obs))) \
       .and. any(.not.ismissing(ndtooned(ts3_obs))) .and. any(.not.ismissing(ndtooned(ts4_obs))) \
       .and. any(.not.ismissing(ndtooned(ts5_obs))) .and. any(.not.ismissing(ndtooned(ts6_obs))) \
       .and. any(.not.ismissing(ndtooned(ts7_obs))) .and. any(.not.ismissing(ndtooned(ts8_obs))) )

   if (any(.not.ismissing(i60))) then

      sdata=new((/ntot+1/), string)

      file_out=obsdir + "/derived/L4/all_or_MDS/" + site(ns) + "_" \
              + sprinti("%0.4i",1996) + "-" + sprinti("%0.4i",2010) + ".txt"
      sfile(ij)= site(ns) + ",  " + sprintf("%10.2f", slat(ns)) + "," \
               + sprintf("%10.2f", slon(ns)) + ",  " + sprinti("%0.4i",1996) +  "-" \
               + sprinti("%0.4i",2010) + ",  " + sprinti("%5i",dimsizes(ndtooned(ts1_obs)))
        
      sdata(0)= "Year" +  "  " + "Month" + "  " + "Latitude" + "  " + "Longitude" \
              + "Rg_f" +  "  " + "Ta_f" + "  " + "Precip" + "  " + "H_f" \
              + "LE_f" +  "  " + "Reco_or" + "  " + "NEE_or_fMDS" + "  " + "GPP_or_MDS"
         ijk=1
      do iy=0, nyer-1
         iiy=iy+1996
      do im=0, nmon-1
         iim=im+1
        
         sdata(ijk)= sprinti("%0.4i",iiy) +  "  " + sprinti("%0.2i",iim) + "  "  \
                   + sprintf("%10.2f", slat(ns)) + sprintf("%10.2f", slon(ns)) \
                   + sprintf("%10.4f", ts1_obs(iy,im)) + sprintf("%10.4f", ts2_obs(iy,im)) \
                   + sprintf("%10.4f", ts3_obs(iy,im)) + sprintf("%10.4f", ts4_obs(iy,im)) \
                   + sprintf("%10.4f", ts5_obs(iy,im)) + sprintf("%10.4f", ts6_obs(iy,im)) \
                   + sprintf("%10.4f", ts7_obs(iy,im)) + sprintf("%10.4f", ts8_obs(iy,im)) 
         ijk=ijk+1
      end do
      end do

      asciiwrite(file_out,sdata(0:ijk-1))

      ij=ij+1

  end if

  delete(i60)

  delete(ts1_obs)
  delete(ts2_obs)
  delete(ts3_obs)
  delete(ts4_obs)
  delete(ts5_obs)
  delete(ts6_obs)
  delete(ts7_obs)
  delete(ts8_obs)
end do

file0_out=obsdir + "/derived/L4/all_or_MDS/" + "sites_info_all_or_MDS.txt"
asciiwrite(file0_out,sfile(0:ij-1))

end
