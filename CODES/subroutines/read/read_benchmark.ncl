;#######################################################################################################################
function read_benchmark (varID:string, Source:string, StartYear:integer, EndYear:integer)

begin

ILAMB_ROOT = getenv("ILAMB_ROOT")
SpatRes    = getenv("SPATRES")

; ++++++++ DataDir + "/" + varID + "/derived/" + varID + "*.nc" +++++++++++++
DataDir    = ILAMB_ROOT + "/DATA/"  + varID + "/" + str_upper(Source) + "/derived"

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nday=(/31,28,31,30,31,30,31,31,30,31,30,31/)

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian

;===================================================================  
; -------- read land fraction data ----------------
fina=ILAMB_ROOT + "/DATA/landfraction/MODIS/derived/landfraction_MODIS_0.5x0.5.nc"

f1 = addfile (fina, "r")
landfrac=f1->landfraction
slon0=f1->lon
slat0=f1->lat

landfrac!0="lat"
landfrac!1="lon"
landfrac&lat=slat0
landfrac&lon=slon0
landfrac&lon@units="degrees_east"
landfrac&lat@units="degrees_north"

nlat0 = dimsizes(slat0)
nlon0 = dimsizes(slon0)

; ++++ calculate area for each grid cell ++++++ ++++
area0=new((/nlat0,nlon0/), float)

dlon = abs((slon0(1)-slon0(0))*RR0)
dlat = abs((slat0(0)-slat0(1))*RR0)
  dy = Rad*dlat

do ny = 0, nlat0-1
do nx = 0, nlon0-1
   dx = Rad*cos(RR0*slat0(ny))*dlon
   area0(ny,nx)=dx*dy
end do
end do

area0!0="lat"
area0!1="lon"
area0&lat=slat0
area0&lon=slon0
area0&lon@units="degrees_east"
area0&lat@units="degrees_north"

; ++++ Generate file name ++++++ ++++
if (any(str_upper(varID@Dimens).eq.(/"DS", "D1", "D2", "D3"/))) then

   if (str_upper(varID@Dimens).eq."DS") then

      slat = -999.
      slon = -999.

      files = systemfunc ("ls " + DataDir + "/" + varID + "*.nc") 

      print(files)

      f1 = addfile (files, "r")   
      ts1=f1->$varID$
      times=f1->time

         ijk=0
      do iiy = 1850, StartYear-1
         year1=int2flt(iiy/4)
         year2=int2flt(iiy)/4.0

         if (year1.eq.year2) then
            ntim=366
         else
            ntim=365
         end if

         ijk = ijk + ntim
      end do

      time1 = int2dble(ijk) + 1

         ijk=0
      do iiy = 1850, EndYear
         year1=int2flt(iiy/4)
         year2=int2flt(iiy)/4.0

         if (year1.eq.year2) then
            ntim=366
         else
            ntim=365
         end if

         ijk = ijk + ntim
      end do

      time2 = int2dble(ijk) + 1

      ts=new((/ntot/), float)

      i50 = ind(times.ge.time1 .and. times.le.time2)

      if (str_upper(Source).eq."MAUNA.LOA") then
         ts = ts1(i50)
      else

            ijk=0
         do iiy=StartYear, EndYear
            iy = iiy-StartYear
         do iim=1, nmon
            ts(ijk) = tofloat(ts1(i50(iy)))
            ijk=ijk+1
         end do
         end do
      end if

      if (isatt(ts1,"latitude") .and. ts1@latitude.ge.-90.) then
         slat = ts1@latitude
         slon = ts1@longitude
         landf_obs = landfrac({slat},{slon})
         area_obs  = area0({slat},{slon})
      else
         slat = ts1@latitude
         slon = ts1@longitude
         landf_obs = avg(landfrac)
         area_obs  = sum(area0)
      end if

      ts@lat      = slat
      ts@lon      = slon
      ts@alt      = "N/A"

      ts@LandFrac = landf_obs
      ts@GridArea = area_obs
      ts@SiteName = "N/A"
      ts@LandType = "N/A"

      delete(f1)
      delete(ts1)
      delete(time1)
      delete(time2)
      delete(times)

   else

      if (any(str_upper(varID@Dimens).eq.(/"D2", "D3"/))) then
         files = DataDir + "/" + varID + "_" + SpatRes + ".nc"
      else
         files = systemfunc ("ls " + DataDir + "/" + varID + "*.nc") 
      end if

      print(files)

      f1 = addfile (files, "r")   
      ts1=f1->$varID$
      slat=f1->lat
      slon=f1->lon

      nlat = dimsizes(slat)
      nlon = dimsizes(slon)

      ts=new((/ntot,nlat,nlon/), float)

      do nt =0, ntot-1
         ts(nt,:,:) = ts1
      end do

      ts@lat      = slat
      ts@lon      = slon
      ts@alt      = "N/A"

      ts@LandFrac = landfrac
      ts@GridArea = area0
      ts@SiteName = "N/A"
      ts@LandType = "N/A"
   end if

else

   if (str_upper(varID@Dimens).eq."D1S") then

      iiy = StartYear
      iim = 1

      files = DataDir + "/" + sprinti("%0.4i",iiy) \
            + "/" + varID + "_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc" 

      f1 = addfile (files, "r")   
      slat=f1->lat
      slon=f1->lon

      ips  = dim_pqsort(slat, 2)

      slon = slon(ips)

      nsit = dimsizes(slat)

      if (max(slon) .gt. max(slon0) .or. min(slon) .lt. min(slon0)) then
         slon01=new((/nlon0+1/), float)

         slon01(0:nlon0-1)=slon0
         slon01(nlon0)=360.

         delete(slon0)
         slon0=slon01
         delete(slon01)

         area01=new((/nlat0,nlon0+1/), float)
         landfrac01=new((/nlat0,nlon0+1/), float)

         area01(:,0:nlon0-1)=area0
         area01(:,nlon0)    =area0(:,0)

         landfrac01(:,0:nlon0-1)=landfrac
         landfrac01(:,nlon0)    =landfrac(:,0)

         delete(area0)
         area0=area01
         delete(area01)

         delete(landfrac)
         landfrac=landfrac01
         delete(landfrac01)
      end if

      nlon0 = dimsizes(slon0)
      nlat0 = dimsizes(slat0)

      if (max(slat) .gt. max(slat0) .or. min(slat) .lt. min(slat0)) then
         slat01=new((/nlat0+2/), float)

         area02=new((/nlat0+2,nlon0/), float)
         landfrac02=new((/nlat0+2,nlon0/), float)

         slat01(1:nlat0)=slat0
         slat01(0)=-90.
         slat01(nlat0+1)=90.

         delete(slat0)
         slat0=slat01
         delete(slat01)

         area02(1:nlat0,:)=area0
         area02(0,:)      =area0(0,:)
         area02(nlat0+1,:)=area0(nlat0-1,:)

         landfrac02(1:nlat0,:)=landfrac
         landfrac02(0,:)      =landfrac(0,:)
         landfrac02(nlat0+1,:)=landfrac(nlat0-1,:)

         delete(area0)
         area0=area02
         delete(area02)

         delete(landfrac)
         landfrac=landfrac02
         delete(landfrac02)
      end if

      nlon0 = dimsizes(slon0)
      nlat0 = dimsizes(slat0)

      area0!0="lat"
      area0!1="lon"
      area0&lat=slat0
      area0&lon=slon0
      area0&lon@units="degrees_east"
      area0&lat@units="degrees_north"

      landfrac!0="lat"
      landfrac!1="lon"
      landfrac&lat=slat0
      landfrac&lon=slon0
      landfrac&lon@units="degrees_east"
      landfrac&lat@units="degrees_north"

      ts        = new((/ntot,nsit/), float)
      landf_obs = new((/nsit/), float)
      area_obs  = new((/nsit/), float)

         ijk=0
      do iiy = StartYear, EndYear
      do iim = 1, nmon
         files = DataDir + "/" + sprinti("%0.4i",iiy) \
               + "/" + varID + "_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc" 

         print(files)

         f1 = addfile (files, "r")   
         ts1=f1->$varID$

         ts(ijk,:) = ts1(ips)
         ijk = ijk + 1
      end do
      end do

      do ns = 0, nsit-1
         landf_obs(ns) = landfrac({slat(ns)},{slon(ns)})
         area_obs(ns)  = area0({slat(ns)},{slon(ns)})
      end do

      ts@lat      = slat
      ts@lon      = slon
      ts@LandFrac = landf_obs
      ts@GridArea = area_obs

      if(isatt(f1,"site_name")) then
         ts@SiteName = f1@site_name 
      else
         ts@SiteName = "N/A"
      end if

      if(isatt(f1,"IGBP_class")) then
         ts@LandType  = f1@IGBP_class
      else
         ts@LandType  = "N/A"
      end if

      if(isatt(f1,"altitude")) then
         ts@alt = f1@altitude
      else
         ts@alt = "N/A"
      end if

      delete(f1)
      delete(ts1)
      delete(ips)
      delete(area_obs)
      delete(landf_obs)
   else

      iiy = StartYear
      iim = 1

      files = DataDir + "/" + sprinti("%0.4i",iiy) \
            + "/" + varID + "_" + SpatRes + "_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc" 

      f1 = addfile (files, "r")   
      slat=f1->lat
      slon=f1->lon

      nlat = dimsizes(slat)
      nlon = dimsizes(slon)

      ts=new((/ntot,nlat,nlon/), float)

         ijk=0
      do iiy = StartYear, EndYear
      do iim = 1, nmon
         files = DataDir + "/" + sprinti("%0.4i",iiy) \
               + "/" + varID + "_" + SpatRes + "_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc" 

         print(files)

         f1 = addfile (files, "r")   
         ts1=f1->$varID$

         ts(ijk,:,:) = ts1
         ijk = ijk + 1
      end do
      end do

      if (str_lower(varID).eq."twsa") then
         ; Remove mean
         ;ts  =ts*3600*24*0.1
         tsm = dim_avg_n(ts,0)
         ts  = ts - conform_dims(dimsizes(ts),tsm,(/1,2/))
         delete(tsm)
      end if

      ts@lat      = slat
      ts@lon      = slon
      ts@alt      = "N/A"

      ts@LandFrac = landfrac
      ts@GridArea = area0
      ts@SiteName = "N/A"
      ts@LandType = "N/A"

      delete(f1)
      delete(ts1)
   end if
end if

if (isdefined("ts")) then
else
   ts = 0.0
end if

return (ts)
                                                                                     
end
