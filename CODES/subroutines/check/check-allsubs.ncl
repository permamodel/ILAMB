procedure CheckPoint_box (DataDir:string, ModelNames:string, runID:integer, varID: string, \
                          Source:string, Unit:string, ts_obs:float, ts_mod:float, StartYear:integer, \
                          EndYear:integer, slat:float, slon:float, latlon:float, SiteID:integer, SubReg:string)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

MODELTYPE = getenv("MODELTYPE")

nlat0 = 360
nlon0 = 720

nlat = dimsizes(slat)
nlon = dimsizes(slon)

nsit=dimsizes(latlon(0,:))

; retrieve latitude and longitude for a plot region.
tlat=new((/1000/), float)
tlon=new((/1000/), float)
tlat = -999
tlon = -999

results = retrieve_latlon_region (SubReg, tlat, tlon)

tlat@_FillValue = -999
tlon@_FillValue = -999

j50 = ind(.not.ismissing(tlat))
i50 = ind(.not.ismissing(tlon))

rlat = tlat(j50)
rlon = tlon(i50)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------convert unit of burned area from %/yr back to %/mon ------------------------
if (str_lower(varID).eq."burntarea") then
   results = retrieve_unit (varID, Source)
else
   results = 1.
end if

ts0_obs = ts_obs/results
ts0_mod = ts_mod/results
delete(results)

; -------- read land fraction data ----------------
fina=getenv("ILAMB_DATADIR") + "/landfraction/MODIS/derived/landfraction_MODIS_0.5x0.5.nc"

f1 = addfile (fina, "r")
landf=f1->landfraction
slat0=f1->lat
slon0=f1->lon

region = where(landf.gt.0,1,0)
landf  = where(landf.gt.0,landf,-999)

landf@_FillValue = -999

nlat0 = dimsizes(slat0)
nlon0 = dimsizes(slon0)

if (str_lower(varID).eq."sst") then
   region=where(region.eq.0, 1, 0)
else
   region=where(region.gt.0.5, 1, 0)
end if

region=where(region.ge.1, 1, 0)

;if (nlat0.ne.nlat .or. nlon0.ne.nlon .or. abs(slat0(0)-slat(0)).ge.0.25 .or. abs(slat0(nlat0-1)-slat(nlat-1)).ge.0.25 \
;    .or. abs(slon0(0)-slon(0)).ge.0.25 .or. abs(slon0(nlon0-1)-slon(nlon-1)).ge.0.25) then
;
;   region1  = area_conserve_remap (slon0, slat0, region, slon, slat, False)
;
;   delete(region)
;   region=where(region1.ge.0.5, 1, 0)
;   delete(region1)
;end if

if (any(str_upper(SiteID@NAME).eq.(/"SITE","SITES"/))) then
   latlon(1,:) = where(latlon(1,:).gt.180, latlon(1,:)-360, latlon(1,:))
else
   latlon(1,:) = where(latlon(1,:).gt.180, latlon(1,:)-360, latlon(1,:))
   latlon(3,:) = where(latlon(3,:).gt.180, latlon(3,:)-360, latlon(3,:))
end if

; ------- Set Model Data as missing where the Benchmark is missing -----
ts0_obs@_FillValue=-999
ts0_mod@_FillValue=-999

do nv = 0, nmod-1
   ts0_mod(nv,:,:,:) = where(ismissing(ts0_obs), -999, ts0_mod(nv,:,:,:))
end do

ts0_obs!0="time"
ts0_obs!1="lat"
ts0_obs!2="lon"
ts0_obs&lat=slat
ts0_obs&lon=slon
ts0_obs&lon@units="degrees_east"
ts0_obs&lat@units="degrees_north"

ts0_mod!0="model"
ts0_mod!1="time"
ts0_mod!2="lat"
ts0_mod!3="lon"
ts0_mod&lat=slat
ts0_mod&lon=slon
ts0_mod&lon@units="degrees_east"
ts0_mod&lat@units="degrees_north"

tts=new((/nmod+1, nsit, ntot/), float)

tts = -999

if (any(str_upper(SiteID@NAME).eq.(/"SITE","SITES"/))) then
   do ns=0,nsit-1
      tts(0,ns,:)=ts0_obs(:,{latlon(0,ns)},{latlon(1,ns)})
      tts(1:nmod,ns,:)=ts0_mod(:,:,{latlon(0,ns)},{latlon(1,ns)})
   end do
else
   do ns=0,nsit-1
      i50 = ind(slon.ge.latlon(1,ns) .and. slon.le.latlon(3,ns))
      j50 = ind(slat.ge.latlon(0,ns) .and. slat.le.latlon(2,ns))
      if (dimsizes(i50).ge.2 .or. .not.ismissing(i50)) then
         if (dimsizes(j50).ge.2 .or. .not.ismissing(j50)) then
            do nt = 0, ntot-1
               tts(0,ns,nt)=avg(ts0_obs(nt,j50,i50))
               do nv = 0, nmod-1
                  tts(nv+1,ns,nt)=avg(ts0_mod(nv,nt,j50,i50))
               end do
            end do
            delete(i50)
            delete(j50)
         end if
      end if
   end do
end if

tts@_FillValue = -999

; +++ remove the long-term trend with the 2nd polynomaial from each time series +++
tts0=new((/nmod+1, nsit, ntot/), float)

xx = fspan(1.,int2flt(nyer),ntot)
nn = 3

do nv = 0, nmod
do ns = 0, nsit-1

   yy01 = tts(nv,ns,:)

   cc0  = lspoly(xx,yy01, 1, nn)
   yy02 = cc0(0) + cc0(1)*xx + cc0(2)*xx^2
   yy02 = yy01-yy02
   delete(cc0)

   tts0(nv,ns,:) = yy02

   delete(yy01)
   delete(yy02)

end do
end do

; +++ calculate annual cycle for each detrended time series +++

ttt=new((/nmod+1, nsit, nmon, nyer/), float)

   ijk=0
do iy = 0, nyer-1
do im = 0, nmon-1
   ttt(:,:,im,iy) = tts0(:,:,ijk)
   ijk=ijk+1
end do
end do

tta = dim_avg(ttt)
delete(ttt)
delete(tts0)

anual= new((/nmod+1, nsit/), float)
bias = new((/nmod+1, nsit/), float)
rmse = new((/nmod+1, nsit/), float)

anual= -999
bias = -999
rmse = -999

anual = dim_avg(tts)

AnualObs = dim_avg(ts0_obs(lat|:,lon|:,time|:))

if (str_lower(varID).eq."burntarea") then
   AnualObs = AnualObs*12
end if

AnualObs = where(region.le.0, -999, AnualObs)

do nv = 1, nmod
   bias(nv,:) = dim_avg(tts(nv,:,:)) - dim_avg(tts(0,:,:))
   rmse(nv,:) = dim_rmsd(tts(nv,:,:), tts(0,:,:))
end do

anual = where(ismissing(anual), -999, anual)
bias  = where(ismissing(bias),  -999, bias)
rmse  = where(ismissing(rmse),  -999, rmse)

ModelNameList=new((/nmod+1/), string)
ModelNameList(0)=Source
ModelNameList(1:nmod)=ModelNames

if (str_upper(Source).eq."NOAA.GMD") then
   AnualObs@LabelBarOn = "NO"
   AnualObs@PlotType   = "ZONAL"
else
   AnualObs@LabelBarOn = "YES"
   AnualObs@PlotType   = "GLOBAL"
end if

; ++++++++++ set up parameters for drawing +++++++++++

results = retrieve_DrawInfo (varID, "annualmean", Source)

cnlevels = results@cnlevels
lblabels = results@lblabels
XLab     = results@XLab
YLab     = results@YLab
CLab     = results@CLab

MinLon   = min(rlon)
MaxLon   = max(rlon)
MinLat   = min(rlat)
MaxLat   = max(rlat)

if (str_lower(varID@SubGlobe).eq."yes" .and. any(str_lower(SubReg).eq.(/"global","global.large"/))) then
   MinLon   = results@MinLon
   MaxLon   = results@MaxLon
   MinLat   = results@MinLat
   MaxLat   = results@MaxLat
end if

tta!0="mod"
tta!1="reg"
tta!2="time"
tta&time=fspan(1,nmon,nmon)

tts!0="mod"
tts!1="reg"
tts!2="time"
tts&time=fspan(StartYear,EndYear+1,ntot)

AnualObs!0="lat"
AnualObs!1="lon"
AnualObs&lat=slat
AnualObs&lon=slon
AnualObs&lon@units="degrees_east"
AnualObs&lat@units="degrees_north"

tta@_FillValue=-999
tts@_FillValue=-999
AnualObs@_FillValue=-999


TableFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(varID) + "/check/locations_" + str_lower(varID) \
         + "_" + str_upper(Source) + ".txt"

print(TableFileName)

if (any(str_upper(SiteID@NAME).eq.(/"SITE", "SITES"/))) then
   header1 = "Total checked points for " + str_lower(varID) + " from " + str_upper(Source)
   header2 = "  KeyWords: SITE"
   write_table(TableFileName, "w", [/header1/], "%s")
   write_table(TableFileName, "a", [/header2/], "%s")
   write_table(TableFileName, "a", [/"Latitude", "Longitude"/], "%11s %11s")
   write_table(TableFileName, "a", [/latlon(0,0:nsit-1),latlon(1,0:nsit-1)/], "%11.2f %11.2f")
else
   header1 = "Total checked points regions for " + str_lower(varID) + " from " + str_upper(Source)
   header2 = "  KeyWords: REGION"
   write_table(TableFileName, "w", [/header1/], "%s")
   write_table(TableFileName, "a", [/header2/], "%s")
   write_table(TableFileName, "a", [/"MinLat", "MinLon", "MaxLat", "MaxLon"/], "%11s %11s %11s %11s")
   write_table(TableFileName, "a", [/latlon(0,0:nsit-1),latlon(1,0:nsit-1),latlon(2,0:nsit-1),latlon(3,0:nsit-1)/], \
                                     "%11.2f %11.2f %11.2f %11.2f")
end if

;print(asciiread(TableFileName,-1,"string"))

delete(header1)
delete(header2)

;  --------  Draw global annual mean ------------

AnualObs@_FillValue = -999

ShortName = ""
clat      = -999
clon      = -999

PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(varID) + "/check/annualmean_" + str_lower(varID) \
             + "_" + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

titles       = "Annual Mean for " + str_upper(varID) + " (" + Unit + "): " + Source

titles@SubTitle = "Click on a region to show time series"

Draw_Map_Check (PlotFileName, AnualObs, slat, slon, titles, cnlevels,lblabels, ShortName, clon, clat, \
                MinLon, MaxLon, MinLat, MaxLat, latlon, SiteID)

;  --------  Draw seasonal cycle and time series for each region ------------

if (str_lower(varID).eq."burntarea") then
   Unit = str_sub_str(Unit, "yr", "month")
end if

do ns=0, nsit-1

  PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(varID) + "/check/check_point" + sprinti("%i",ns+1) \
               + "_" + str_lower(varID) + "_cmip5.vs." + str_upper(Source) \
               + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
  print(PlotFileName)

  if (latlon(1,ns).gt.180) then
     stringx = str_squeeze(sprintf("%8.2f", 360-latlon(1,ns))) + "W"
  else
     stringx = str_squeeze(sprintf("%8.2f", latlon(1,ns))) + "E"
  end if

  if (latlon(0,ns).ge.0) then
     stringy = str_squeeze(sprintf("%8.2f", latlon(0,ns))) + "N"
  else
     stringy = str_squeeze(sprintf("%8.2f", abs(latlon(0,ns)))) + "S"
  end if

  if (any(str_upper(SiteID@NAME).eq.(/"SITE","SITES"/))) then
     stringxy = "Site (" + stringy + ", " + stringx + ")"
  else
     if (latlon(3,ns).gt.180) then
        stringx1 = str_squeeze(sprintf("%8.2f", 360-latlon(3,ns))) + "W"
     else
        stringx1 = str_squeeze(sprintf("%8.2f", latlon(3,ns))) + "E"
     end if

     if (latlon(2,ns).ge.0) then
        stringy1 = str_squeeze(sprintf("%8.2f", latlon(2,ns))) + "N"
     else
        stringy1 = str_squeeze(sprintf("%8.2f", abs(latlon(2,ns)))) + "S"
     end if

     stringxy = "Region (" + stringy + "-" + stringy1 + ", " + stringx + "-" + stringx1 + ")"
  end if

  tta@Header   = stringxy
  tta@YTitle   = str_upper(varID) + " (" + Unit + ")"

  tts@Header   = ""
  tts@YTitle   = str_upper(varID) + " (" + Unit + ")"

  header = (/"Model", "Annual", "Bias", "RMSE"/)

  write_table("temp.data","w",[/header(0),header(1),header(2),header(3)/], "%10s %9s %9s %9s")
  write_table("temp.data","a",[/ModelNameList,anual(:,ns), bias(:,ns), rmse(:,ns)/], "%10s %9.2f %9.2f %9.2f")

  infos = asciiread("temp.data",-1,"string")

  Draw_TS_Check (PlotFileName, tta(:,nr,:), tts(:,nr,:), infos)

end do

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure CheckPoint_site (DataDir:string, ModelNames:string, runID:integer, varID: string, \
                           Source:string, Unit:string, ts_obs:float, ts_mod:float, StartYear:integer, \
                           EndYear:integer, slat:float, slon:float, latlon:float, SiteID:integer, SubReg:string)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

MODELTYPE = getenv("MODELTYPE")

nsit=dimsizes(latlon(0,:))

if (any(str_upper(SiteID@NAME).eq.(/"SITE","SITES"/))) then
   latlon(1,:) = where(latlon(1,:).gt.180, latlon(1,:)-360, latlon(1,:))
else
   latlon(1,:) = where(latlon(1,:).gt.180, latlon(1,:)-360, latlon(1,:))
   latlon(3,:) = where(latlon(3,:).gt.180, latlon(3,:)-360, latlon(3,:))
end if

; retrieve latitude and longitude for a plot region.
tlat=new((/1000/), float)
tlon=new((/1000/), float)
tlat = -999
tlon = -999

results = retrieve_latlon_region (SubReg, tlat, tlon)

tlat@_FillValue = -999
tlon@_FillValue = -999

j50 = ind(.not.ismissing(tlat))
i50 = ind(.not.ismissing(tlon))

rlat = tlat(j50)
rlon = tlon(i50)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------convert unit of burned area from %/yr back to %/mon ------------------------
if (str_lower(varID).eq."burntarea") then
   results = retrieve_unit (varID, Source)
else
   results = 1.
end if

ts0_obs = ts_obs/results
ts0_mod = ts_mod/results
delete(results)

ts0_obs@_FillValue=-999
ts0_mod@_FillValue=-999

ts0_obs!0="time"
ts0_obs!1="site"

ts0_mod!0="mod"
ts0_mod!1="time"
ts0_mod!2="site"

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

alt       = ts_obs@alt
LandType  = ts_obs@LandType
SiteName  = ts_obs@SiteName

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

if (nmod.eq.1) then
   LandFracMod = landf_mod(0,:)
   LandFracMod = where(LandFracMod.gt.0, 1, 0)
else
   tempMod     = landf_mod
   tempMod     = where(tempMod.gt.0, 1, 0)
   LandFracMod = dim_sum_n(tempMod, 0)
   delete(tempMod)
end if

; ------- Choose data only in the selected sub-region ------------------------
i50 = ind((slon.ge.min(rlon) .and. slon.le.max(rlon)) .and. (slat.ge.min(rlat) .and. slat.le.max(rlat)))

temp = dim_avg(ts0_obs(site|i50,time|:))

;if (str_upper(MODELTYPE).eq."CLM") then
;   i51 = ind(.not.ismissing(temp) .and. LandFracMod(i50).eq.nmod)
;else
;   i51 = ind(.not.ismissing(temp))
;end if

if (str_upper(MODELTYPE).eq."CLM") then
   i51 = ind(.not.ismissing(temp) .and. LandFracMod(i50).eq.nmod)
else
   if (str_upper(Source).eq."WRMC.BSRN") then
      i51 = ind(.not.ismissing(temp) .and. LandFracMod(i50).eq.nmod)
   else
      i51 = ind(.not.ismissing(temp))
   end if
end if

nsit = dimsizes(i51)

delete(temp)

; ------- Set Model Data as missing where the Benchmark is missing -----
tts=new((/nmod+1, nsit, ntot/), float)

tts = -999

do nv = 0, nmod-1
   ts0_mod(nv,:,:) = where(ismissing(ts0_obs), -999, ts0_mod(nv,:,:))
end do

if (any(str_upper(SiteID@NAME).eq.(/"SITE","SITES"/))) then
   temp = dim_avg(ts0_obs(site|i50(i51),time|:))
   i52  = ind(.not.ismissing(temp) .and. temp.ne.-999)
   nsit = dimsizes(i52)
   if (dimsizes(i52).ge.2 .or. .not.ismissing(i52)) then
      tts(0,0:nsit-1,:)      = ts0_obs(site|i50(i51(i52)),time|:)
      tts(1:nmod,0:nsit-1,:) = ts0_mod(mod|:,site|i50(i51(i52)),time|:)
      slats           = slat(i50(i51(i52)))
      slons           = slon(i50(i51(i52)))
      latlons         = latlon(:,i50(i51(i52)))

      ;alts            = alt(i50(i51(i52)))
      ;LandTypes       = LandType(i50(i51(i52)))
      SiteNames       = SiteName(i50(i51(i52)))
   else
      latlons = new((/4/), float)
      slats   = -999.0
      slons   = -999.0
      latlons = -999.0

      alts      = -999.0
      LandTypes = "N/A"
      SiteNames = "N/A"
   end if
   delete(i52)
   delete(temp)
else
   do ns=0,nsit-1
      j50 = ind((slon.ge.latlon(1,ns) .and. slat.le.latlon(3,ns)) .and. (slat.ge.latlon(0,ns) .and. slat.le.latlon(2,ns)))
      slats=slat
      slons=slon
      latlons=latlon

      alts      = -999.0
      LandTypes = "N/A"
      SiteNames = "N/A"

      if (dimsizes(j50).ge.2 .or. .not.ismissing(j50)) then
         tts(0,ns,:)=dim_avg(ts0_obs(:,j50))
         tts(1:nmod,ns,:)=dim_avg(ts0_mod(:,:,j50))
      end if
      delete(j50)
   end do
end if

delete(i50)
delete(i51)

temp = tts(:,0:nsit-1,:)

delete(tts)

tts = temp

delete(temp)

tts@_FillValue = -999

; +++ remove the long-term trend with the 2nd polynomaial from each time series +++
tts0=new((/nmod+1, nsit, ntot/), float)

xx = fspan(1.,int2flt(nyer),ntot)
nn = 3

do nv = 0, nmod
do ns = 0, nsit-1

   yy01 = tts(nv,ns,:)

   cc0  = lspoly(xx,yy01, 1, nn)
   yy02 = cc0(0) + cc0(1)*xx + cc0(2)*xx^2
   yy02 = yy01-yy02
   delete(cc0)

   tts0(nv,ns,:) = yy02

   delete(yy01)
   delete(yy02)

end do
end do

; +++ calculate annual cycle for each detrended time series +++
ttt=new((/nmod+1, nsit, nmon, nyer/), float)

   ijk=0
do iy = 0, nyer-1
do im = 0, nmon-1
   ttt(:,:,im,iy) = tts0(:,:,ijk)
   ijk=ijk+1
end do
end do

tta = dim_avg(ttt)
delete(ttt)
delete(tts0)

anual= new((/nmod+1, nsit/), float)
bias = new((/nmod+1, nsit/), float)
rmse = new((/nmod+1, nsit/), float)

anual= -999
bias = -999
rmse = -999

anual = dim_avg(tts)

AnualObs = anual(0,:)

do nv = 1, nmod
   bias(nv,:) = dim_avg(tts(nv,:,:)) - dim_avg(tts(0,:,:))
   rmse(nv,:) = dim_rmsd(tts(nv,:,:), tts(0,:,:))
end do

anual = where(ismissing(anual), -999, anual)
bias  = where(ismissing(bias),  -999, bias)
rmse  = where(ismissing(rmse),  -999, rmse)

tta!0="mod"
tta!1="reg"
tta!2="time"
tta&time=fspan(1,nmon,nmon)

tts!0="mod"
tts!1="reg"
tts!2="time"
tts&time=fspan(StartYear,EndYear+1,ntot)

tta@_FillValue=-999
tts@_FillValue=-999

tt1 = tta
tt2 = tts

tt1!0="mod"
tt1!1="reg"
tt1!2="time"
tt1&time=fspan(1,nmon,nmon)

tt2!0="mod"
tt2!1="reg"
tt2!2="time"
tt2&time=fspan(StartYear,EndYear+1,ntot)

tt1@_FillValue    = -999
tt2@_FillValue    = -999

ModelNameList=new((/nmod+1/), string)
ModelNameList(0)=Source
ModelNameList(1:nmod)=ModelNames

AnualObs@_FillValue = -999

AnualObs@DrawType   = "GLOBAL"

if (str_upper(Source).eq."NOAA.GMD") then
   AnualObs@LabelBarOn = "NO"
else
   AnualObs@LabelBarOn = "YES"
end if

; ++++++++++ set up parameters for drawing +++++++++++

results = retrieve_DrawInfo (varID, "annualmean", Source)

cnlevels = results@cnlevels
lblabels = results@lblabels
XLab     = results@XLab
YLab     = results@YLab
CLab     = results@CLab

MinLon   = min(rlon)
MaxLon   = max(rlon)
MinLat   = min(rlat)
MaxLat   = max(rlat)

if (str_lower(varID@SubGlobe).eq."yes" .and. any(str_lower(SubReg).eq.(/"global","global.large"/))) then
   MinLon   = results@MinLon
   MaxLon   = results@MaxLon
   MinLat   = results@MinLat
   MaxLat   = results@MaxLat
end if

ShortName = ""
clat      = -999
clon      = -999

TableFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(varID) + "/check/locations_" + str_lower(varID) \
         + "_" + str_upper(Source) + ".txt"

print(TableFileName)

if (any(str_upper(SiteID@NAME).eq.(/"SITE", "SITES"/))) then
   header1 = "Total checked points for " + str_lower(varID) + " from " + str_upper(Source)
   header2 = "  KeyWords: SITE"
   write_table(TableFileName, "w", [/header1/], "%s")
   write_table(TableFileName, "a", [/header2/], "%s")
   write_table(TableFileName, "a", [/"Site_Name", "Latitude", "Longitude"/], "%11s %11s %11s")
   write_table(TableFileName, "a", [/SiteNames(0:nsit-1),latlons(0,0:nsit-1),latlons(1,0:nsit-1)/], "%11s %11.2f %11.2f")
else
   header1 = "Total checked points regions for " + str_lower(varID) + " from " + str_upper(Source)
   header2 = "  KeyWords: REGION"
   write_table(TableFileName, "w", [/header1/], "%s")
   write_table(TableFileName, "a", [/header2/], "%s")
   write_table(TableFileName, "a", [/"MinLat", "MinLon", "MaxLat", "MaxLon"/], "%11s %11s %11s %11s")
   write_table(TableFileName, "a", [/latlons(0,0:nsit-1),latlons(1,0:nsit-1),latlons(2,0:nsit-1),latlons(3,0:nsit-1)/], \
                                     "%11.2f %11.2f %11.2f %11.2f")
end if

;print(asciiread(TableFileName,-1,"string"))

delete(header1)
delete(header2)

;  --------  Draw global annual mean ------------

PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(varID) + "/check/annualmean_" + str_lower(varID) \
             + "_" + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

titles          = "Annual Mean for " + str_upper(varID) + " (" + Unit + "): " + Source
titles@SubTitle = "Click on a dot to show time series"

;Draw_Map_Site_Check (PlotFileName, AnualObs, slat, slon, titles, cnlevels, lblabels, ShortName, \
;                     clon, clat, MinLon, MaxLon, MinLat, MaxLat, latlon, SiteID)

i50 = ind(.not.ismissing(AnualObs))

if (dimsizes(i50).gt.1 .or. .not.ismissing(i50)) then
   Draw_Map_Check (PlotFileName, AnualObs, slats, slons, titles, cnlevels,lblabels, ShortName, clon, clat, \
                   MinLon, MaxLon, MinLat, MaxLat, latlons, SiteID)
end if

delete(i50)

;  --------  Draw seasonal cycle and time series for each region ------------

do ns=0, nsit-1
if (any(.not.ismissing(tts(:,ns,:)))) then

  stringx = str_squeeze(sprintf("%8.2f", latlons(1,ns))) + "E"
  if (latlons(1,ns).lt.0) then
     stringx = str_squeeze(sprintf("%8.2f", abs(latlons(1,ns)))) + "W"
  end if

  if (latlons(0,ns).ge.0) then
     stringy = str_squeeze(sprintf("%8.2f", latlons(0,ns))) + "N"
  else
     stringy = str_squeeze(sprintf("%8.2f", abs(latlons(0,ns)))) + "S"
  end if

  if (any(str_upper(SiteID@NAME).eq.(/"SITE","SITES"/))) then
     ;stringxy = "Site (" + stringy + ", " + stringx + ")"
     stringxy = SiteNames(ns) + " (" + stringy + ", " + stringx + ")"
  else
     stringx1 = str_squeeze(sprintf("%8.2f", latlons(3,ns))) + "E"
     if (latlons(3,ns).lt.0) then
        stringx1 = str_squeeze(sprintf("%8.2f", abs(latlons(3,ns)))) + "W"
     end if

     if (latlons(2,ns).ge.0) then
        stringy1 = str_squeeze(sprintf("%8.2f", latlons(2,ns))) + "N"
     else
        stringy1 = str_squeeze(sprintf("%8.2f", abs(latlons(2,ns)))) + "S"
     end if

     stringxy = "Region (" + stringy + "-" + stringy1 + ", " + stringx + "-" + stringx1 + ")"
  end if

  tt1@Header   = stringxy
  tt1@YTitle   = str_upper(varID) + " (" + Unit + ")"

  tt2@Header   = ""
  tt2@YTitle   = str_upper(varID) + " (" + Unit + ")"

  header = (/"Model", "Annual", "Bias", "RMSE"/)

  write_table("temp.data","w",[/header(0),header(1),header(2),header(3)/], "%10s %9s %9s %9s")
  write_table("temp.data","a",[/ModelNameList,anual(:,ns), bias(:,ns), rmse(:,ns)/], "%10s %9.2f %9.2f %9.2f")

  infos = asciiread("temp.data",-1,"string")

  do nv = 0, nmod
     if (.not.ismissing(anual(0,ns))) then
  
       tt1          = -999
       tt2          = -999
  
       if (nv.eq.0) then
          tt1          = tta
          tt2          = tts
          ModelName0   = "CMIP5"
       else
          tt1( 0,ns,:) = tta( 0,ns,:)
          tt2( 0,ns,:) = tts( 0,ns,:)
          tt1(nv,ns,:) = tta(nv,ns,:)
          tt2(nv,ns,:) = tts(nv,ns,:)
          ModelName0   = ModelNameList(nv)
       end if
  
       tt1@_FillValue = -999
       tt2@_FillValue = -999

       PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(varID) + "/check/check_point" + sprinti("%i",ns+1) \
                    + "_" + str_lower(varID) + "_" + ModelName0 + ".vs." + str_upper(Source) \
                    + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
       print(PlotFileName)
  
       Draw_TS_Check (PlotFileName, tt1(:,ns,:), tt2(:,ns,:), infos)
  
    end if
  end do

end if
end do

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure CheckRegion_belt (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, \
                        Unit:string, ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer,    \
                        slat:float, slon:float, SubReg1:string, SubReg2:string, SiteID)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

MODELTYPE = getenv("MODELTYPE")

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID
   
ModelNameList(0) = str_upper(Source)
ModelNameList(1:nmod) = ModelNames

if (str_lower(SubReg2).eq."global") then
   SubReg2 = "global.large"
end if

; -------- Retrieve sub-region for diagnostic analysis ----------------
tlat=new((/1000/), float)
tlon=new((/1000/), float)

results = retrieve_latlon_region (SubReg2, tlat, tlon)

i50 = ind(.not.ismissing(tlon))
j50 = ind(.not.ismissing(tlat))

rlon = tlon(i50)
rlat = tlat(j50)

nlon = dimsizes(rlon)
nlat = dimsizes(rlat)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- read biome regions data ----------------
fina=getenv("ILAMB_DATADIR") + "/biomes/GFED/derived/biomes_0.5x0.5.nc"

f1 = addfile (fina, "r")
region0=f1->biomes
slat0=f1->lat
slon0=f1->lon

; ++++ force grids of "biome region" the same as sub-region ++++
i50 = ind(slon0.ge.min(rlon) .and. slon0.le.max(rlon))
j50 = ind(slat0.ge.min(rlat) .and. slat0.le.max(rlat))

region    = region0(j50,i50)
delete(i50)
delete(j50)

delete(slat0)
delete(slon0)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac
landm_mod = ts_mod@LandMask

area_obs  = ts_obs@gridarea
area_mod  = ts_mod@gridarea

landf_obs = where(landf_obs.le.0, -999, landf_obs)
landf_mod = where(landf_mod.le.0, -999, landf_mod)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

; -------- read biome regions data ----------------

SubRegName = retrieve_latlon_belt (Source, SubReg1)

nreg       = dimsizes(SubRegName)

LatLon = SubRegName@LatLon

MinLat = LatLon(0,:)
MaxLat = LatLon(1,:)
MinLon = LatLon(2,:)
MaxLon = LatLon(3,:)

ShortName = SubRegName
LongName  = SubRegName@LongName

; ++++ force grids of "biome region" the same as sub-region ++++

i51 = ind(MinLon.lt.min(rlon))
i52 = ind(MaxLon.gt.max(rlon))
j51 = ind(MinLat.lt.min(rlat))
j52 = ind(MaxLat.gt.max(rlat))

if (dimsizes(i51).gt.1 .or. .not.ismissing(i51)) then
   MinLon(i51) = min(rlon)
end if

if (dimsizes(i52).gt.1 .or. .not.ismissing(i52)) then
   MaxLon(i52) = max(rlon)
end if

if (dimsizes(j51).gt.1 .or. .not.ismissing(j51)) then
   MinLat(j51) = min(rlat)
end if

if (dimsizes(j52).gt.1 .or. .not.ismissing(j52)) then
   MaxLat(j52) = max(rlat)
end if

delete(i51)
delete(i52)
delete(j51)
delete(j52)

latlon=new((/4,nreg/), float)
clat=new((/nreg/), float)
clon=new((/nreg/), float)

latlon = -999
clat   = -999
clon   = -999

latlon@_FillValue = -999
clat@_FillValue   = -999
clon@_FillValue   = -999

clon = (MinLon+MaxLon)/2.0
clat = (MinLat+MaxLat)/2.0

latlon(0, :) = MinLat
latlon(1, :) = MaxLat
latlon(2, :) = MinLon
latlon(3, :) = MaxLon

ts_obs@_FillValue=-999
ts_mod@_FillValue=-999

score=new((/nmod+1,nreg/), float)

tts=new((/nmod+1, nreg, ntot/), float)

score = -999
tts   = -999

tts@_FillValue = -999

; ----------- Deal with site dataset -------------
if (SiteID.eq.1 .and. dimsizes(ind(.not.ismissing(slat))).gt.1) then

   if (nmod.eq.1) then
      LandFracMod = landf_mod(0,:)
      LandFracMod = where(LandFracMod.gt.0, 1, 0)
   else
      tempMod     = landf_mod
      tempMod     = where(tempMod.gt.0, 1, 0)
      LandFracMod = dim_sum_n(tempMod, 0)
      delete(tempMod)
   end if

   ; ------- Choose data only in the selected sub-region ------------------------
   i50 = ind((slon.ge.min(rlon) .and. slon.le.max(rlon)) .and. (slat.ge.min(rlat) .and. slat.le.max(rlat)))

   ts_obs!0="time"
   ts_obs!1="site"

   temp = dim_avg(ts_obs(site|i50,time|:))

   ;if (str_upper(MODELTYPE).eq."CLM") then
   ;   i51 = ind(.not.ismissing(temp) .and. LandFracMod(i50).eq.nmod)
   ;else
   ;   i51 = ind(.not.ismissing(temp))
   ;end if

   if (str_upper(MODELTYPE).eq."CLM") then
      i51 = ind(.not.ismissing(temp) .and. LandFracMod(i50).eq.nmod)
   else
      if (str_upper(Source).eq."WRMC.BSRN") then
         i51 = ind(.not.ismissing(temp) .and. LandFracMod(i50).eq.nmod)
      else
         i51 = ind(.not.ismissing(temp))
      end if
   end if

   nsit = dimsizes(i51)

   delete(temp)

   AnualM     = new((/nmod+1,nsit/), float)

   ; ------- Set Model Data as missing where the Benchmark is missing -----
   if (dimsizes(i51).eq.1 .and. .not.ismissing(i51)) then

      ts0_obs    = ts_obs(:,i50(i51))
      ts0_mod    = ts_mod(:,:,i50(i51))
      slat0      = slat(i50(i51))
      slon0      = slon(i50(i51))

      ts0_obs@_FillValue = -999
      ts0_mod@_FillValue = -999

      do nv = 0, nmod-1
         ts0_mod(nv,:) = where(ismissing(ts0_obs), -999, ts0_mod(nv,:))
      end do

      AnualM(0,0)      = dim_avg(ts0_obs)
      AnualM(1:nmod,0) = dim_avg(ts0_mod)

      do nr = 1, nreg

         j50 = ind((slat0.ge.MinLat(nr-1).and.slat0.le.MaxLat(nr-1)) .and. (slon0.ge.MinLon(nr-1).and.slon0.le.MaxLon(nr-1)))

         if (dimsizes(j50).gt.1 .or. .not.ismissing(j50)) then
            tts(0,nr-1,:)=ts0_obs
            tts(1:nmod,nr-1,:)=ts0_mod(:,:)
         end if

         delete(j50)
      end do

      delete(reg0)
      ;delete(slat0)
      ;delete(slon0)
      delete(ts0_obs)
      delete(ts0_mod)

   else

      ts0_obs    = ts_obs(:,i50(i51))
      ts0_mod    = ts_mod(:,:,i50(i51))
      slat0      = slat(i50(i51))
      slon0      = slon(i50(i51))

      ts0_obs@_FillValue = -999
      ts0_mod@_FillValue = -999

      do nv = 0, nmod-1
         ts0_mod(nv,:,:) = where(ismissing(ts0_obs), -999, ts0_mod(nv,:,:))
      end do

      ts0_obs!0="time"
      ts0_obs!1="reg"

      ts0_mod!0="mod"
      ts0_mod!1="time"
      ts0_mod!2="reg"

      AnualM(0,:)      = dim_avg(ts0_obs(reg|:,time|:))
      AnualM(1:nmod,:) = dim_avg(ts0_mod(mod|:,reg|:,time|:))

      reg0=new((/dimsizes(slat0)/), float)

      do nr = 1, nreg

         j50 = ind((slat0.ge.MinLat(nr-1).and.slat0.le.MaxLat(nr-1)) .and. (slon0.ge.MinLon(nr-1).and.slon0.le.MaxLon(nr-1)))

         if (dimsizes(j50).gt.1) then
            tts(0,nr-1,:)      = dim_avg(ts0_obs(:,j50))
            tts(1:nmod,nr-1,:) = dim_avg(ts0_mod(:,:,j50))
         else
            if (dimsizes(j50).eq.1 .and. .not.ismissing(j50)) then
               tts(0,nr-1,:)      = ts0_obs(:,j50)
               tts(1:nmod,nr-1,:) = ts0_mod(:,:,j50)
            end if
         end if

         delete(j50)
      end do

      delete(reg0)
      ;delete(slat0)
      ;delete(slon0)
      delete(ts0_obs)
      delete(ts0_mod)

   end if

   delete(i50)
   delete(i51)
   delete(LandFracMod)

else if (SiteID.eq.0) then

   ; ------- Choose data only in the selected sub-region ------------------------
   i50 = ind(slon.ge.min(rlon) .and. slon.le.max(rlon))
   j50 = ind(slat.ge.min(rlat) .and. slat.le.max(rlat))

   ts0_obs    = ts_obs(:,j50,i50)
   ts0_mod    = ts_mod(:,:,j50,i50)

   landf0_obs = landf_obs(j50,i50)
   landf0_mod = landf_mod(:,j50,i50)
   landm0_mod = landm_mod(:,j50,i50)

   area0_obs  = area_obs(j50,i50)
   area0_mod  = area_mod(:,j50,i50)

   delete(i50)
   delete(j50)

   ts0_obs!0="time"
   ts0_obs!1="lat"
   ts0_obs!2="lon"

   if (str_lower(varID@SubGlobe).eq."yes") then
      ts0_obs=where(ts0_obs.le.0, -999, ts0_obs)
   else
      do nt=0,ntot-1
         ts0_obs(nt,:,:) =where(region.gt.0, ts0_obs(nt,:,:), -999)
      end do
   end if

   ts0_obs@_FillValue=-999

   region1=dim_avg(ts0_obs(lat|:,lon|:,time|:))

   region1=where(.not.ismissing(region1),1,0)

   ;if (str_lower(varID@CarbonYearly).eq."yes") then
   ;   region1=where(region1.gt.0,1,0)
   ;else
   ;   region1=where(.not.ismissing(region1),1,0)
   ;end if

   do nt=0,ntot-1
      ts0_obs(nt,:,:) =where(region1.gt.0, ts0_obs(nt,:,:), -999)
   end do

   ; ----------- Deal with grid dataset -------------

   area = area0_obs

   AnualM=new((/nmod+1,nlat,nlon/), float)

   tt0=new((/nlat,nlon,nmon,nyer/), float)

      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      tt0(:,:,im,iy) = ts0_obs(ijk,:,:)
      ijk=ijk+1
   end do
   end do

   tt0@_FillValue=-999

   if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
      at0 = sqrt(dim_avg(tt0*tt0))
   else
      at0 = dim_avg(tt0)
   end if

   do im=0,nmon-1
      at0(:,:,im) = where(ismissing(landf0_obs), -999, at0(:,:,im))
   end do

   ; ------- convert unit from per cell area to per land area ------------------------
   if (str_lower(varID@LandOnly).eq."yes") then
      AnualM(0,:,:) = dim_avg(at0)/landf0_obs
   else
      AnualM(0,:,:)    = dim_avg(at0)
   end if

   do nv=0, nmod-1
      if (runID(nv).gt.0) then

         area = area0_mod(nv,:,:)

         tt1=new((/nlat,nlon,nmon,nyer/), float)

            ijk=0
         do iy=0,nyer-1
         do im=0,nmon-1
            tt1(:,:,im,iy) = ts0_mod(nv,ijk,:,:)
            ijk=ijk+1
         end do
         end do

         if (str_lower(varID@SubGlobe).eq."yes") then
            tt1=where(ismissing(tt0), -999, tt1)
         end if

         tt1@_FillValue=-999

         ; ------- Set Model Data as missing where the Benchmark is missing -----

         if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
            at1 = sqrt(dim_avg(tt1*tt1))
         else
            at1 = dim_avg(tt1)
         end if

         landfOM = where(landf0_obs.gt.0.0 .and. landf0_mod(0,:,:).gt.0.0, landf0_mod(0,:,:), -999)
         ;landfOM = where(landf0_obs.gt.0.15 .and. landf0_mod(0,:,:).gt.0.15, landf0_obs, -999)
         landfOM = where(landm0_mod(0,:,:).gt.0, landfOM, -999)

         landfOM@_FillValue=-999

         do im=0,nmon-1
            at1(:,:,im) = where(ismissing(landfOM), -999, at1(:,:,im))
         end do

         do nr = 1, nreg

            i50 = ind(rlon.ge.MinLon(nr-1).and.rlon.le.MaxLon(nr-1))
            j50 = ind(rlat.ge.MinLat(nr-1).and.rlat.le.MaxLat(nr-1))
      
            score(0,nr-1)    = sum(dim_avg(at0(j50,i50,:))*area(j50,i50)*region1(j50,i50))/sum(area(j50,i50)*region1(j50,i50))
            score(nv+1,nr-1) = sum(dim_avg(at1(j50,i50,:))*area(j50,i50)*region1(j50,i50))/sum(area(j50,i50)*region1(j50,i50))

               ijk=0
            do iy = 0, nyer-1
            do im = 0, nmon-1
               tts(0,nr-1,ijk)    = sum(tt0(j50,i50,im,iy)*region1(j50,i50)*area(j50,i50))/sum(area(j50,i50)*region1(j50,i50))
               tts(nv+1,nr-1,ijk) = sum(tt1(j50,i50,im,iy)*region1(j50,i50)*area(j50,i50))/sum(area(j50,i50)*region1(j50,i50))
               ijk=ijk+1
            end do
            end do

            delete(i50)
            delete(j50)
         end do

         ; ------- convert unit from per cell area to per land area ------------------------
         if (str_lower(varID@LandOnly).eq."yes") then
            AnualM(nv+1,:,:) = dim_avg(at1)/landfOM
         else
            AnualM(nv+1,:,:) = dim_avg(at1)
         end if

         delete(at1)
         delete(tt1)
         delete(area)
         delete(landfOM)
      end if
   end do

   AnualM!0="mod"
   AnualM!1="lat"
   AnualM!2="lon"
   AnualM&lat=rlat
   AnualM&lon=rlon
   AnualM&lon@units="degrees_east"
   AnualM&lat@units="degrees_north"

   ; -------convert unit of burned area from %/yr back to %/mon ------------------------
   if (str_lower(varID).eq."burntarea") then
      UnitCoef = retrieve_unit (varID, Source)
      tts = tts/UnitCoef
      delete(UnitCoef)
   end if

   delete(region1)
   delete(ts0_obs)
   delete(ts0_mod)
end if
end if

tts@_FillValue = -999

; +++ remove the long-term trend with the 2nd polynomaial from each time series +++
tts0=new((/nmod+1, nreg, ntot/), float)

xx = fspan(1.,int2flt(nyer),ntot)
nn = 3

do nv = 0, nmod
do ns = 0, nreg-1

   yy01 = tts(nv,ns,:)

   cc0  = lspoly(xx,yy01, 1, nn)
   yy02 = cc0(0) + cc0(1)*xx + cc0(2)*xx^2
   yy02 = yy01-yy02
   delete(cc0)

   tts0(nv,ns,:) = yy02

   delete(yy01)
   delete(yy02)

end do
end do

; +++ calculate annual cycle for each detrended time series +++
ttt=new((/nmod+1, nreg, nmon, nyer/), float)

   ijk=0
do iy = 0, nyer-1
do im = 0, nmon-1
   ttt(:,:,im,iy) = tts0(:,:,ijk)
   ijk=ijk+1
end do
end do

ttt@_FillValue = -999

tta = dim_avg(ttt)
delete(ttt)
delete(tts0)

anual= new((/nmod+1, nreg/), float)
bias = new((/nmod+1, nreg/), float)
rmse = new((/nmod+1, nreg/), float)

anual= -999
bias = -999
rmse = -999

anual = dim_avg(tta)

do nv = 1, nmod
   bias(nv,:) = dim_avg(tta(nv,:,:)) - dim_avg(tta(0,:,:))
   rmse(nv,:) = dim_rmsd(tta(nv,:,:), tta(0,:,:))
end do

anual = where(ismissing(anual), -999, anual)
bias  = where(ismissing(bias),  -999, bias)
rmse  = where(ismissing(rmse),  -999, rmse)

;  --------  Draw Biome Types ------------

if (any(str_lower(SubReg1).eq.(/"zonal","meridional"/))) then
   region = 0.0
   do nr=1, nreg
      i50 = ind(rlon.ge.MinLon(nr-1).and.rlon.le.MaxLon(nr-1))
      j50 = ind(rlat.ge.MinLat(nr-1).and.rlat.le.MaxLat(nr-1))
    
      region(j50,i50) = nr
       
      delete(i50)
      delete(j50)
   end do
end if

region = where(region.le.0, -999, region)
region@_FillValue   = -999

delete(MinLon)
delete(MaxLon)
delete(MinLat)
delete(MaxLat)

ModelNameList=new((/nmod+1/), string)
ModelNameList(0)=Source
ModelNameList(1:nmod)=ModelNames

; -------Save sub-region information for later use ------------------------
TableFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(varID) + "/biomes/locations_" + str_lower(varID) \
              + "_" + str_upper(Source) + ".txt"

header1 = "Total sub-region analysis for " + str_lower(varID) + " from " + str_upper(Source)
header2 = "  KeyWords: REGION"
write_table(TableFileName, "w", [/header1/], "%s")
write_table(TableFileName, "a", [/header2/], "%s")
write_table(TableFileName, "a", [/"Region Name", "MinLat", "MinLon", "MaxLat", "MaxLon", "Annual OBS"/], "%40s %11s %11s %11s %11s %11s")
write_table(TableFileName, "a", [/SubRegName,latlon(0,:),latlon(2,:),latlon(1,:),latlon(3,:), anual(0,:)/], \
                                        "%40s %11.2f %11.2f %11.2f %11.2f %11.2f")

; ++++++++++ set up parameters for drawing +++++++++++

results = retrieve_DrawInfo (varID, "annualmean", Source)

cnlevels = results@cnlevels
lblabels = results@lblabels
XLab     = results@XLab
YLab     = results@YLab
CLab     = results@CLab

MinLon   = min(rlon)
MaxLon   = max(rlon) 
MinLat   = min(rlat)
MaxLat   = max(rlat)

if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg2).eq."global") then
   MinLon   = results@MinLon
   MaxLon   = results@MaxLon
   MinLat   = results@MinLat
   MaxLat   = results@MaxLat
end if

tta!0="mod"
tta!1="reg"
tta!2="time"
tta&time=fspan(1,nmon,nmon)

tts!0="mod"
tts!1="reg"
tts!2="time"
tts&time=fspan(StartYear,EndYear+1,ntot)

tt1 = tta
tt2 = tts

tt1!0="mod"
tt1!1="reg"
tt1!2="time"
tt1&time=fspan(1,nmon,nmon)

tt2!0="mod"
tt2!1="reg"
tt2!2="time"
tt2&time=fspan(StartYear,EndYear+1,ntot)

tt1@_FillValue    = -999
tt2@_FillValue    = -999
anual@_FillValue  = -999
AnualM@_FillValue = -999

AnualM = 0

SiteID0 = SiteID
SiteID0@NAME = str_upper(SubReg1)

delete(cnlevels)
delete(lblabels)

lblabels=new((/nreg+1/), string)

cnlevels         = fspan(1,nreg,nreg)
lblabels(0)      = "n/a"
lblabels(1:nreg) = LongName

;region@NAME = ShortName
;region@Lons = clon
;region@Lats = clat

AnualM@DATA     = region
AnualM@cnlevels = cnlevels
AnualM@lblabels = lblabels 

if (str_upper(Source).eq."NOAA.GMD") then
   AnualM@LabelBarOn = "NO"
   AnualM@DrawType   = "ZONAL"
else
   AnualM@LabelBarOn = "YES"
   AnualM@DrawType   = "GLOBAL"
end if

PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(varID) + "/biomes/map_biomes_" + str_upper(SubReg1)

titles       = "Zonal Mean Analysis"

Draw_Map (PlotFileName, region, rlat, rlon, titles, cnlevels, lblabels, XLab, YLab, CLab, \
          MinLon, MaxLon, MinLat, MaxLat, 0)

;  --------  Draw global annual mean ------------

;delete(cnlevels)
;delete(lblabels)

;cnlevels = results@cnlevels
;lblabels = results@lblabels

if (dimsizes(ind(.not.ismissing(anual(0,:)))).gt.1 .or. .not.ismissing(ind(.not.ismissing(anual(0,:))))) then

  do nv = 0, nmod
     PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(varID) + "/biomes/annualmean_" + str_lower(varID) \
                  + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                  + "-" + sprinti("%0.4i",EndYear)
     print(PlotFileName)

     if (str_lower(varID).eq."twsa") then
        titles       = "Std Dev for " + str_upper(varID) + " (" + Unit + "): " + ModelNameList(nv)
     else
        titles       = "Annual Mean for " + str_upper(varID) + " (" + Unit + "): " + ModelNameList(nv)
     end if

     titles@SubTitle = "Click on a region to show time series"

     if (SiteID.eq.1) then
        Draw_Map_Check (PlotFileName, AnualM(nv,:), slat0, slon0, titles, cnlevels,lblabels, LongName, clon, clat, \
                        MinLon, MaxLon, MinLat, MaxLat, latlon, SiteID0)
     else
        Draw_Map_Check (PlotFileName, AnualM(nv,:,:), slat, slon, titles, cnlevels,lblabels, LongName, clon, clat, \
                        MinLon, MaxLon, MinLat, MaxLat, latlon, SiteID0)
     end if
  end do

end if

;  --------  Draw seasonal cycle and time series for each region ------------

if (str_lower(varID).eq."burntarea") then
   Unit = str_sub_str(Unit, "yr", "month")
end if

do nv = 0, nmod
   do nr=0, nreg-1
   if (.not.ismissing(anual(0,nr))) then

     tt1          = -999
     tt2          = -999

     if (nv.eq.0) then
        tt1          = tta
        tt2          = tts
        ModelName0   = "CMIP5"
     else
        tt1( 0,nr,:) = tta( 0,nr,:)
        tt2( 0,nr,:) = tts( 0,nr,:)
        tt1(nv,nr,:) = tta(nv,nr,:)
        tt2(nv,nr,:) = tts(nv,nr,:)
        ModelName0   = ModelNameList(nv)
     end if

     tt1@_FillValue = -999
     tt2@_FillValue = -999

     PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(varID) + "/biomes/check_subreg" + sprinti("%i",nr+1) \
                  + "_" + str_lower(varID) + "_" + ModelName0 + ".vs." + str_upper(Source) \
                  + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

     ;tt1@Header   = ShortName(nr) + " (" + LongName(nr) + ")"
     tt1@Header   = LongName(nr)
     tt1@YTitle   = str_upper(varID) + " (" + Unit + ")"

     tt2@Header   = ""
     tt2@YTitle   = str_upper(varID) + " (" + Unit + ")"

     header = (/"Model", "Annual", "Bias", "RMSE"/)

     write_table("temp.data","w",[/header(0),header(1),header(2),header(3)/], "%10s %9s %9s %9s")
     write_table("temp.data","a",[/ModelNameList,anual(:,nr), bias(:,nr), rmse(:,nr)/], "%10s %9.2f %9.2f %9.2f")

     infos = asciiread("temp.data",-1,"string")

     Draw_TS_Check (PlotFileName, tt1(:,nr,:), tt2(:,nr,:), infos)

  end if
  end do
end do

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure CheckRegion_biome (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, \
                        Unit:string, ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer,    \
                        slat:float, slon:float, SubReg1:string, SubReg2:string, SiteID)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

MODELTYPE = getenv("MODELTYPE")

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID
   
ModelNameList(0) = str_upper(Source)
ModelNameList(1:nmod) = ModelNames

; -------- Retrieve sub-region for diagnostic analysis ----------------
tlat=new((/1000/), float)
tlon=new((/1000/), float)

results = retrieve_latlon_region (SubReg2, tlat, tlon)

i50 = ind(.not.ismissing(tlon))
j50 = ind(.not.ismissing(tlat))

rlon = tlon(i50)
rlat = tlat(j50)

nlon = dimsizes(rlon)
nlat = dimsizes(rlat)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac
landm_mod = ts_mod@LandMask

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

landf_obs = where(landf_obs.le.0, -999, landf_obs)
landf_mod = where(landf_mod.le.0, -999, landf_mod)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

; -------- read biome regions data ----------------
fina=getenv("ILAMB_DATADIR") + "/biomes/" + str_upper(SubReg1) + "/derived/biomes_0.5x0.5.nc"

f1 = addfile (fina, "r")
region0=f1->biomes
slat0=f1->lat
slon0=f1->lon

tmp        = str_split(f1@class,",")
SubRegName = tmp(1:)
delete(tmp)

nreg       = dimsizes(SubRegName)

ShortName=new((/nreg/), string)
LongName =new((/nreg/), string)

do nr=0, nreg-1
   ShortName(nr) = str_squeeze(str_get_field(SubRegName(nr), 1, ":"))
   LongName(nr)  = str_squeeze(str_get_field(SubRegName(nr), 2, ":"))
end do

SubRegName = ShortName + ":" + LongName

; ++++ force grids of "biome region" the same as sub-region ++++
i50 = ind(slon0.ge.min(rlon) .and. slon0.le.max(rlon))
j50 = ind(slat0.ge.min(rlat) .and. slat0.le.max(rlat))

region    = region0(j50,i50)
delete(i50)
delete(j50)

delete(slat0)
delete(slon0)

latlon=new((/4,nreg/), float)
clat=new((/nreg/), float)
clon=new((/nreg/), float)

latlon = -999
clat   = -999
clon   = -999

latlon@_FillValue = -999
clat@_FillValue   = -999
clon@_FillValue   = -999

reg1D = ndtooned(region)

   ijk = 0
do nr=1, nreg

   k50 = ind(reg1D.eq.nr)
 
   if (dimsizes(k50).gt.1) then
      lats=new((/nlat,nlon/), float)
      lons=new((/nlat,nlon/), float)

      ;- Retrieve latitude and longitude for a region -
      tlat=new((/1000/), float)
      tlon=new((/1000/), float)

      results = retrieve_latlon_region (ShortName(nr-1), tlat, tlon)

      i50 = ind(.not.ismissing(tlon))
      j50 = ind(.not.ismissing(tlat))

      clon(nr-1) = avg(tlon(i50))
      clat(nr-1) = avg(tlat(j50))

      latlon(0, nr-1) = min(tlat(j50))
      latlon(1, nr-1) = max(tlat(j50))
      latlon(2, nr-1) = min(tlon(i50))
      latlon(3, nr-1) = max(tlon(i50))

      delete(i50)
      delete(j50)
      delete(tlat)
      delete(tlon)
      delete(results)
   end if
   delete(k50)
end do

delete(reg1D)

ts_obs@_FillValue=-999
ts_mod@_FillValue=-999

region!0="lat"
region!1="lon"
region&lat=rlat
region&lon=rlon
region&lon@units="degrees_east"
region&lat@units="degrees_north"

score=new((/nmod+1,nreg/), float)
tts=new((/nmod+1, nreg, ntot/), float)

score = -999
tts   = -999

tts@_FillValue = -999

; ----------- Deal with site dataset -------------
if (SiteID.eq.1 .and. dimsizes(ind(.not.ismissing(slat))).gt.1) then

   if (nmod.eq.1) then
      LandFracMod = landf_mod(0,:)
      LandFracMod = where(LandFracMod.gt.0, 1, 0)
   else
      tempMod     = landf_mod
      tempMod     = where(tempMod.gt.0, 1, 0)
      LandFracMod = dim_sum_n(tempMod, 0)
      delete(tempMod)
   end if

   ; ------- Choose data only in the selected sub-region ------------------------
   i50 = ind((slon.ge.min(rlon) .and. slon.le.max(rlon)) .and. (slat.ge.min(rlat) .and. slat.le.max(rlat)))

   ts_obs!0="time"
   ts_obs!1="site"

   temp = dim_avg(ts_obs(site|i50,time|:))

   ;if (str_upper(MODELTYPE).eq."CLM") then
   ;   i51 = ind(.not.ismissing(temp) .and. LandFracMod(i50).eq.nmod)
   ;else
   ;   i51 = ind(.not.ismissing(temp))
   ;end if

   if (str_upper(MODELTYPE).eq."CLM") then
      i51 = ind(.not.ismissing(temp) .and. LandFracMod(i50).eq.nmod)
   else
      if (str_upper(Source).eq."WRMC.BSRN") then
         i51 = ind(.not.ismissing(temp) .and. LandFracMod(i50).eq.nmod)
      else
         i51 = ind(.not.ismissing(temp))
      end if
   end if

   nsit = dimsizes(i51)

   delete(temp)

   AnualM     = new((/nmod+1,nsit/), float)

   ; ------- Set Model Data as missing where the Benchmark is missing -----
   if (dimsizes(i51).eq.1 .and. .not.ismissing(i51)) then

      ts0_obs    = ts_obs(:,i50(i51))
      ts0_mod    = ts_mod(:,:,i50(i51))
      slat0      = slat(i50(i51))
      slon0      = slon(i50(i51))

      ts0_obs@_FillValue = -999
      ts0_mod@_FillValue = -999

      do nv = 0, nmod-1
         ts0_mod(nv,:) = where(ismissing(ts0_obs), -999, ts0_mod(nv,:))
      end do

      AnualM(0,0)      = dim_avg(ts0_obs)
      AnualM(1:nmod,0) = dim_avg(ts0_mod)

      reg0 = region({slat0},{slon0})

      do nr = 1, nreg

         j50 = ind(reg0.eq.nr)

         if (dimsizes(j50).gt.1 .or. .not.ismissing(j50)) then
            tts(0,nr-1,:)=ts0_obs
            tts(1:nmod,nr-1,:)=ts0_mod(:,:)
         end if

         delete(j50)
      end do

      delete(reg0)
      ;delete(slat0)
      ;delete(slon0)
      delete(ts0_obs)
      delete(ts0_mod)

   else

      ts0_obs    = ts_obs(:,i50(i51))
      ts0_mod    = ts_mod(:,:,i50(i51))
      slat0      = slat(i50(i51))
      slon0      = slon(i50(i51))

      ts0_obs@_FillValue = -999
      ts0_mod@_FillValue = -999

      do nv = 0, nmod-1
         ts0_mod(nv,:,:) = where(ismissing(ts0_obs), -999, ts0_mod(nv,:,:))
      end do

      ts0_obs!0="time"
      ts0_obs!1="reg"

      ts0_mod!0="mod"
      ts0_mod!1="time"
      ts0_mod!2="reg"

      AnualM(0,:)      = dim_avg(ts0_obs(reg|:,time|:))
      AnualM(1:nmod,:) = dim_avg(ts0_mod(mod|:,reg|:,time|:))

      reg0=new((/dimsizes(slat0)/), float)

      do nr = 0, dimsizes(slat0)-1
         reg0(nr) = region({slat0(nr)},{slon0(nr)})
      end do

      do nr = 1, nreg

         j50 = ind(reg0.eq.nr)

         if (dimsizes(j50).gt.1) then
            tts(0,nr-1,:)      = dim_avg(ts0_obs(:,j50))
            tts(1:nmod,nr-1,:) = dim_avg(ts0_mod(:,:,j50))
         else
            if (dimsizes(j50).eq.1 .and. .not.ismissing(j50)) then
               tts(0,nr-1,:)      = ts0_obs(:,j50)
               tts(1:nmod,nr-1,:) = ts0_mod(:,:,j50)
            end if
         end if

         delete(j50)
      end do

      delete(reg0)
      ;delete(slat0)
      ;delete(slon0)
      delete(ts0_obs)
      delete(ts0_mod)

   end if

   delete(i50)
   delete(i51)
   delete(LandFracMod)

else if (SiteID.eq.0) then

   ; ------- Choose data only in the selected sub-region ------------------------
   i50 = ind(slon.ge.min(rlon) .and. slon.le.max(rlon))
   j50 = ind(slat.ge.min(rlat) .and. slat.le.max(rlat))

   ts0_obs    = ts_obs(:,j50,i50)
   ts0_mod    = ts_mod(:,:,j50,i50)

   landf0_obs = landf_obs(j50,i50)
   landf0_mod = landf_mod(:,j50,i50)
   landm0_mod = landm_mod(:,j50,i50)

   area0_obs  = area_obs(j50,i50)
   area0_mod  = area_mod(:,j50,i50)

   delete(i50)
   delete(j50)

   ts0_obs!0="time"
   ts0_obs!1="lat"
   ts0_obs!2="lon"

   if (str_lower(varID@SubGlobe).eq."yes") then
      ts0_obs=where(ts0_obs.le.0, -999, ts0_obs)
   else
      do nt=0,ntot-1
         ts0_obs(nt,:,:) =where(region.gt.0, ts0_obs(nt,:,:), -999)
      end do
   end if

   ts0_obs@_FillValue=-999

   region1=dim_avg(ts0_obs(lat|:,lon|:,time|:))

   region1=where(.not.ismissing(region1),1,0)

   ;if (str_lower(varID@CarbonYearly).eq."yes") then
   ;   region1=where(region1.gt.0,1,0)
   ;else
   ;   region1=where(.not.ismissing(region1),1,0)
   ;end if

   do nt=0,ntot-1
      ts0_obs(nt,:,:) =where(region1.gt.0, ts0_obs(nt,:,:), -999)
   end do

   ; ----------- Deal with grid dataset -------------

   area = area0_obs

   AnualM=new((/nmod+1,nlat,nlon/), float)

   tt0=new((/nlat,nlon,nmon,nyer/), float)

      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      tt0(:,:,im,iy) = ts0_obs(ijk,:,:)
      ijk=ijk+1
   end do
   end do

   tt0@_FillValue=-999

   if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
      at0 = sqrt(dim_avg(tt0*tt0))
   else
      at0 = dim_avg(tt0)
   end if

   do im=0,nmon-1
      at0(:,:,im) = where(ismissing(landf0_obs), -999, at0(:,:,im))
   end do

   ; ------- convert unit from per cell area to per land area ------------------------
   if (str_lower(varID@LandOnly).eq."yes") then
      AnualM(0,:,:) = dim_avg(at0)/landf0_obs
   else
      AnualM(0,:,:)    = dim_avg(at0)
   end if

   do nv=0, nmod-1
      if (runID(nv).gt.0) then

         area = area0_mod(nv,:,:)

         tt1=new((/nlat,nlon,nmon,nyer/), float)

            ijk=0
         do iy=0,nyer-1
         do im=0,nmon-1
            tt1(:,:,im,iy) = ts0_mod(nv,ijk,:,:)
            ijk=ijk+1
         end do
         end do

         if (str_lower(varID@SubGlobe).eq."yes") then
            tt1=where(ismissing(tt0), -999, tt1)
         end if

         tt1@_FillValue=-999

         ; ------- Set Model Data as missing where the Benchmark is missing -----

         if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
            at1 = sqrt(dim_avg(tt1*tt1))
         else
            at1 = dim_avg(tt1)
         end if

         landfOM = where(landf0_obs.gt.0.0 .and. landf0_mod(0,:,:).gt.0.0, landf0_mod(0,:,:), -999)
         ;landfOM = where(landf0_obs.gt.0.15 .and. landf0_mod(0,:,:).gt.0.15, landf0_obs, -999)
         landfOM = where(landm0_mod(0,:,:).gt.0, landfOM, -999)

         landfOM@_FillValue=-999

         do im=0,nmon-1
            at1(:,:,im) = where(ismissing(landfOM), -999, at1(:,:,im))
         end do

         do nr = 1, nreg

            reg = where(region.eq.nr, 1, -999)

            reg@_FillValue = -999

            score(0,nr-1)    = sum(dim_avg(at0)*area*reg)/sum(area*reg)
            score(nv+1,nr-1) = sum(dim_avg(at1)*area*reg)/sum(area*reg)

               ijk=0
            do iy = 0, nyer-1
            do im = 0, nmon-1
               tts(0,nr-1,ijk)    = sum(tt0(:,:,im,iy)*reg*area)/sum(area*reg)
               tts(nv+1,nr-1,ijk) = sum(tt1(:,:,im,iy)*reg*area)/sum(area*reg)
               ijk=ijk+1
            end do
            end do

            delete(reg)
         end do

         ; ------- convert unit from per cell area to per land area ------------------------
         if (str_lower(varID@LandOnly).eq."yes") then
            AnualM(nv+1,:,:) = dim_avg(at1)/landfOM
         else
            AnualM(nv+1,:,:) = dim_avg(at1)
         end if

         delete(at1)
         delete(tt1)
         delete(area)
         delete(landfOM)
      end if
   end do

   AnualM!0="mod"
   AnualM!1="lat"
   AnualM!2="lon"
   AnualM&lat=rlat
   AnualM&lon=rlon
   AnualM&lon@units="degrees_east"
   AnualM&lat@units="degrees_north"

   ; -------convert unit of burned area from %/yr back to %/mon ------------------------
   if (str_lower(varID).eq."burntarea") then
      UnitCoef = retrieve_unit (varID, Source)
      tts = tts/UnitCoef
      delete(UnitCoef)
   end if

   delete(region1)
   delete(ts0_obs)
   delete(ts0_mod)
end if
end if

tts@_FillValue = -999

; +++ remove the long-term trend with the 2nd polynomaial from each time series +++
tts0=new((/nmod+1, nreg, ntot/), float)

xx = fspan(1.,int2flt(nyer),ntot)
nn = 3

do nv = 0, nmod
do ns = 0, nreg-1

   yy01 = tts(nv,ns,:)

   cc0  = lspoly(xx,yy01, 1, nn)
   yy02 = cc0(0) + cc0(1)*xx + cc0(2)*xx^2
   yy02 = yy01-yy02
   delete(cc0)

   tts0(nv,ns,:) = yy02

   delete(yy01)
   delete(yy02)

end do
end do

; +++ calculate annual cycle for each detrended time series +++
ttt=new((/nmod+1, nreg, nmon, nyer/), float)

   ijk=0
do iy = 0, nyer-1
do im = 0, nmon-1
   ttt(:,:,im,iy) = tts0(:,:,ijk)
   ijk=ijk+1
end do
end do

ttt@_FillValue = -999

tta = dim_avg(ttt)
delete(ttt)

anual= new((/nmod+1, nreg/), float)
bias = new((/nmod+1, nreg/), float)
rmse = new((/nmod+1, nreg/), float)

anual= -999
bias = -999
rmse = -999

anual = dim_avg(tts)

do nv = 1, nmod
   bias(nv,:) = dim_avg(tts(nv,:,:)) - dim_avg(tts(0,:,:))
   rmse(nv,:) = dim_rmsd(tts(nv,:,:), tts(0,:,:))
end do

anual = where(ismissing(anual), -999, anual)
bias  = where(ismissing(bias),  -999, bias)
rmse  = where(ismissing(rmse),  -999, rmse)

ModelNameList=new((/nmod+1/), string)
ModelNameList(0)=Source
ModelNameList(1:nmod)=ModelNames

; -------Save sub-region information for later use ------------------------
TableFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(varID) + "/biomes/locations_" + str_lower(varID) \
              + "_" + str_upper(Source) + ".txt"

header1 = "Total sub-region analysis for " + str_lower(varID) + " from " + str_upper(Source)
header2 = "  KeyWords: REGION"
write_table(TableFileName, "w", [/header1/], "%s")
write_table(TableFileName, "a", [/header2/], "%s")
write_table(TableFileName, "a", [/"Region Name", "MinLat", "MinLon", "MaxLat", "MaxLon", "Annual OBS"/], "%40s %11s %11s %11s %11s %11s")
write_table(TableFileName, "a", [/SubRegName,latlon(0,:),latlon(2,:),latlon(1,:),latlon(3,:), anual(0,:)/], \
                                        "%40s %11.2f %11.2f %11.2f %11.2f %11.2f")

; ++++++++++ set up parameters for drawing +++++++++++

results = retrieve_DrawInfo (varID, "annualmean", Source)

cnlevels = results@cnlevels
lblabels = results@lblabels
XLab     = results@XLab
YLab     = results@YLab
CLab     = results@CLab

MinLon   = min(rlon)
MaxLon   = max(rlon) 
MinLat   = min(rlat)
MaxLat   = max(rlat)

if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg2).eq."global") then
   MinLon   = results@MinLon
   MaxLon   = results@MaxLon
   MinLat   = results@MinLat
   MaxLat   = results@MaxLat
end if

tta!0="mod"
tta!1="reg"
tta!2="time"
tta&time=fspan(1,nmon,nmon)

tts!0="mod"
tts!1="reg"
tts!2="time"
tts&time=fspan(StartYear,EndYear+1,ntot)

tt1 = tta
tt2 = tts

tt1!0="mod"
tt1!1="reg"
tt1!2="time"
tt1&time=fspan(1,nmon,nmon)

tt2!0="mod"
tt2!1="reg"
tt2!2="time"
tt2&time=fspan(StartYear,EndYear+1,ntot)

tt1@_FillValue    = -999
tt2@_FillValue    = -999
anual@_FillValue  = -999
AnualM@_FillValue = -999

SiteID0 = SiteID
SiteID0@NAME = "GLOBAL"

if (str_upper(Source).eq."NOAA.GMD") then
   AnualM@LabelBarOn = "NO"
   AnualM@PlotType   = "ZONAL"
else
   AnualM@LabelBarOn = "YES"
   AnualM@PlotType   = "GLOBAL"
end if

;  --------  Draw Biome Types ------------

region = where(region.le.0, -999, region)
region@_FillValue   = -999

delete(cnlevels)
delete(lblabels)

lblabels=new((/nreg+1/), string)

cnlevels         = fspan(1,nreg,nreg)
lblabels(0)      = "n/a"
lblabels(1:nreg) = ShortName

region@NAME = ShortName
region@Lons = clon
region@Lats = clat

PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(varID) + "/biomes/map_biomes_" + str_upper(SubReg1)

titles       = "Biome Regions from " + str_upper(SubReg1)

Draw_Map (PlotFileName, region, rlat, rlon, titles, cnlevels, lblabels, XLab, YLab, CLab, \
          MinLon, MaxLon, MinLat, MaxLat, 0)

;  --------  Draw global annual mean ------------

delete(cnlevels)
delete(lblabels)

cnlevels = results@cnlevels
lblabels = results@lblabels

if (dimsizes(ind(.not.ismissing(anual(0,:)))).gt.1 .or. .not.ismissing(ind(.not.ismissing(anual(0,:))))) then

  do nv = 0, nmod
     PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(varID) + "/biomes/annualmean_" + str_lower(varID) \
                  + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                  + "-" + sprinti("%0.4i",EndYear)
     print(PlotFileName)

     if (str_lower(varID).eq."twsa") then
        titles       = "Std Dev for " + str_upper(varID) + " (" + Unit + "): " + ModelNameList(nv)
     else
        titles       = "Annual Mean for " + str_upper(varID) + " (" + Unit + "): " + ModelNameList(nv)
     end if

     titles@SubTitle = "Click on a region to show time series"

     if (SiteID.eq.1) then
        Draw_Map_Check (PlotFileName, AnualM(nv,:), slat0, slon0, titles, cnlevels,lblabels, ShortName, clon, clat, \
                        MinLon, MaxLon, MinLat, MaxLat, latlon, SiteID0)
     else
        Draw_Map_Check (PlotFileName, AnualM(nv,:,:), slat, slon, titles, cnlevels,lblabels, ShortName, clon, clat, \
                        MinLon, MaxLon, MinLat, MaxLat, latlon, SiteID0)
     end if
  end do

end if

;  --------  Draw seasonal cycle and time series for each region ------------

if (str_lower(varID).eq."burntarea") then
   Unit = str_sub_str(Unit, "yr", "month")
end if

do nv = 0, nmod
   do nr=0, nreg-1
   if (.not.ismissing(anual(0,nr))) then

     tt1          = -999
     tt2          = -999

     if (nv.eq.0) then
        tt1          = tta
        tt2          = tts
        ModelName0   = "CMIP5"
     else
        tt1( 0,nr,:) = tta( 0,nr,:)
        tt2( 0,nr,:) = tts( 0,nr,:)
        tt1(nv,nr,:) = tta(nv,nr,:)
        tt2(nv,nr,:) = tts(nv,nr,:)
        ModelName0   = ModelNameList(nv)
     end if

     tt1@_FillValue = -999
     tt2@_FillValue = -999

     PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(varID) + "/biomes/check_subreg" + sprinti("%i",nr+1) \
                  + "_" + str_lower(varID) + "_" + ModelName0 + ".vs." + str_upper(Source) \
                  + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

     tt1@Header   = ShortName(nr) + " (" + LongName(nr) + ")"
     tt1@YTitle   = str_upper(varID) + " (" + Unit + ")"

     tt2@Header   = ""
     tt2@YTitle   = str_upper(varID) + " (" + Unit + ")"

     header = (/"Model", "Annual", "Bias", "RMSE"/)

     write_table("temp.data","w",[/header(0),header(1),header(2),header(3)/], "%10s %9s %9s %9s")
     write_table("temp.data","a",[/ModelNameList,anual(:,nr), bias(:,nr), rmse(:,nr)/], "%10s %9.2f %9.2f %9.2f")

     infos = asciiread("temp.data",-1,"string")

     Draw_TS_Check (PlotFileName, tt1(:,nr,:), tt2(:,nr,:), infos)

  end if
  end do
end do

end
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
