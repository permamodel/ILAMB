load "/sopt/ncl/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "/sopt/ncl/lib/ncarg/nclex/gsun/gsn_csm.ncl"
load "/sopt/ncl/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/sopt/ncl/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "/gdata/randerson3/mmu/ILAMB/CODES/subroutines/write/write_AmeriFlux_netcdf.ncl"

begin

start_year=1992
end_year=2007
start_year0=1992
end_year0=2005
nmon=12

nyer=end_year - start_year + 1
nyer0=end_year0 - start_year0 + 1

ntot=nyer*nmon
ntot0=nyer0*nmon

time=ispan(1,ntot0,1)

obsdir="/gdata/randerson3/mmu/ILAMB/DATA/AmeriFlux"

;++++++++ read AmericFlux ++++++++++++
file0_out=obsdir + "/original/L4/" + "AmeriFlux_sites_info.txt"
str_temp = asciiread(file0_out,-1,"string")
cstr_temp = stringtochar(str_temp)

slats = stringtofloat(charactertostring(cstr_temp(1:,60:66)))
slons = stringtofloat(charactertostring(cstr_temp(1:,67:75)))

delete(str_temp)
delete(cstr_temp)

print(slats)
print(slons)

SiteListName = obsdir + "/original/L4/sites.list"
print(SiteListName)

SiteFileName = asciiread(SiteListName,-1,"string")
print(SiteFileName)
nsit=dimsizes(SiteFileName)
print(nsit)

;--------------- Read original values -------------.

   ij=0
do ns=0, nsit-1

  DataDirName = obsdir + "/original/L4/" + SiteFileName(ns)

  DataFileNameS = systemfunc("ls " + DataDirName + "/*_L4_m.txt")

  print(DataFileNameS)

  nfile=dimsizes(DataFileNameS)

  ts1_obs=new((/nmon,nyer/), float)
  ts2_obs=new((/nmon,nyer/), float)
  ts3_obs=new((/nmon,nyer/), float)
  ts4_obs=new((/nmon,nyer/), float)

  yr_obs=new((/nfile/), integer)

  if (dimsizes(DataFileNameS).ge.2) then

     do nfs=0, nfile-1
        DataFileName = DataFileNameS(nfs)
        cDataFileName = stringtochar(DataFileName)
        cDataFileName = cDataFileName(::-1)
        cyear=cDataFileName(10:13)
        year = stringtointeger(charactertostring(cyear(::-1)))

        print(year)

        yr_obs(nfs)=year

        iy=year-start_year

        delete(cyear)
        delete(cDataFileName)

        values_1d = asciiread(DataFileName,-1,"string")

        ncols     = dimsizes(str_split(values_1d(1),","))
        nrows     = dimsizes(values_1d(1:))

        print(ncols)
        print(nrows)

        month = stringtointeger(str_get_field(values_1d(1:), 1, ","))
        day = stringtointeger(str_get_field(values_1d(1:),   2, ","))
        data1 = stringtofloat(str_get_field(values_1d(1:),  13, ","))
        data2 = stringtofloat(str_get_field(values_1d(1:),  15, ","))
        data3 = stringtofloat(str_get_field(values_1d(1:),  22, ","))
        data4 = stringtofloat(str_get_field(values_1d(1:),  24, ","))

        data1=where(data1.eq.-9999, -999, data1)
        data2=where(data2.eq.-9999, -999, data2)
        data3=where(data3.eq.-9999, -999, data3)
        data4=where(data4.eq.-9999, -999, data4)

        data1@_FillValue=-999
        data2@_FillValue=-999
        data3@_FillValue=-999
        data4@_FillValue=-999

        do im=0, nmon-1
           iim=im+1
        
           i50=ind(month.eq.iim)
           if (any(.not.ismissing(i50))) then
              ts1_obs(im,iy)=data1(i50)
              ts2_obs(im,iy)=data2(i50)
              ts3_obs(im,iy)=data3(i50)
              ts4_obs(im,iy)=data4(i50)
           else
              ts1_obs(im,iy)=-999
              ts2_obs(im,iy)=-999
              ts3_obs(im,iy)=-999
              ts4_obs(im,iy)=-999
           end if
           print(dimsizes(i50))
           delete(i50)
        end do

        delete(day)
        delete(month)
        delete(data1)
        delete(data2)
        delete(data3)
        delete(data4)
        delete(values_1d)
     end do
  else
     if (.not.ismissing(DataFileNameS)) then
        DataFileName = DataFileNameS
        cDataFileName = stringtochar(DataFileName)
        cDataFileName = cDataFileName(::-1)
        cyear=cDataFileName(10:13)
        year = stringtointeger(charactertostring(cyear(::-1)))

        print(year)

        yr_obs(0)=year

        iy=year-start_year

        delete(cyear)
        delete(cDataFileName)

        values_1d = asciiread(DataFileName,-1,"string")

        ncols     = dimsizes(str_split(values_1d(1),","))
        nrows     = dimsizes(values_1d(1:))

        print(ncols)
        print(nrows)

        month = stringtointeger(str_get_field(values_1d(1:), 1, ","))
        day = stringtointeger(str_get_field(values_1d(1:),   2, ","))

        month = stringtointeger(str_get_field(values_1d(1:), 1, ","))
        day = stringtointeger(str_get_field(values_1d(1:),   2, ","))
        data1 = stringtofloat(str_get_field(values_1d(1:),  13, ","))
        data2 = stringtofloat(str_get_field(values_1d(1:),  15, ","))
        data3 = stringtofloat(str_get_field(values_1d(1:),  22, ","))
        data4 = stringtofloat(str_get_field(values_1d(1:),  24, ","))

        data1=where(data1.eq.-9999, -999, data1)
        data2=where(data2.eq.-9999, -999, data2)
        data3=where(data3.eq.-9999, -999, data3)
        data4=where(data4.eq.-9999, -999, data4)

        data1@_FillValue=-999
        data2@_FillValue=-999
        data3@_FillValue=-999
        data4@_FillValue=-999

        do im=0, nmon-1
           iim=im+1
        
           i50=ind(month.eq.iim)
           if (any(.not.ismissing(i50))) then
              ts1_obs(im,iy)=data1(i50)
              ts2_obs(im,iy)=data2(i50)
              ts3_obs(im,iy)=data3(i50)
              ts4_obs(im,iy)=data4(i50)
           else
              ts1_obs(im,iy)=-999
              ts2_obs(im,iy)=-999
              ts3_obs(im,iy)=-999
              ts4_obs(im,iy)=-999
           end if
           print(dimsizes(i50))
           delete(i50)
        end do

        delete(day)
        delete(month)
        delete(data1)
        delete(data2)
        delete(data3)
        delete(data4)
        delete(values_1d)
     else
        ts1_obs(:,:)=-999
        ts2_obs(:,:)=-999
        ts3_obs(:,:)=-999
        ts4_obs(:,:)=-999
        yr_obs(0)  =-999
     end if
  end if

  yr_obs@_FillValue=-999

  ts1_obs@_FillValue=-999
  ts2_obs@_FillValue=-999
  ts3_obs@_FillValue=-999
  ts4_obs@_FillValue=-999

  i60 = ind(any(.not.ismissing(ndtooned(ts1_obs))) .and. any(.not.ismissing(ndtooned(ts2_obs))) \
      .and. any(.not.ismissing(ndtooned(ts3_obs))) .and. any(.not.ismissing(ndtooned(ts4_obs))) )

  if (any(.not.ismissing(i60))) then

     ts1=new((/ntot0/), float)
     ts2=new((/ntot0/), float)
     ts3=new((/ntot0/), float)
     ts4=new((/ntot0/), float)

        kk=0
     do iy=0, nyer0-1
     do im=0, nmon-1
        ts1(kk)=ts1_obs(im,iy)
        ts2(kk)=ts2_obs(im,iy)
        ts3(kk)=ts4_obs(im,iy)
        ts4(kk)=ts3_obs(im,iy)
        kk=kk+1
     end do
     end do

     file_out=obsdir + "/derived/L4/AmeriFlux_L4_monthly_" + SiteFileName(ns) + ".nc"
     print(file_out)

     tttt = write_AmeriFlux_netcdf (ts1, ts2, ts3, ts4, slats(ns), slons(ns), time, file_out)

     ij=ij+1

     delete(ts1)
     delete(ts2)
     delete(ts3)
     delete(ts4)
  end if

  delete(i60)

  delete(yr_obs)
  delete(ts1_obs)
  delete(ts2_obs)
  delete(ts3_obs)
  delete(ts4_obs)
  delete(DataFileNameS)
end do

print(ij)

end
