procedure AnnualMean (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, Unit:string,\
                      ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                      SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

MODELTYPE = getenv("MODELTYPE")

SpatRes   = getenv("SPATRES")
SpatRes   = str_lower(str_squeeze(SpatRes))

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID

ModelNameList(0) = str_upper(Source)
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac
landm_mod = ts_mod@LandMask

RawMax_mod = ts_mod@RawMax
RawMin_mod = ts_mod@RawMin
RawAvg_mod = ts_mod@RawAvg

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

region    = where(landf_obs.gt.0,1,0)

landf_obs = where(landf_obs.le.0, -999, landf_obs)
landf_mod = where(landf_mod.le.0, -999, landf_mod)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

; ------- Choose data only in the selected sub-region ------------------------
i50 = ind(slon.ge.min(rlon) .and. slon.le.max(rlon))
j50 = ind(slat.ge.min(rlat) .and. slat.le.max(rlat))

nlon = dimsizes(i50)
nlat = dimsizes(j50)

ts0_obs    = ts_obs(:,j50,i50)
ts0_mod    = ts_mod(:,:,j50,i50)

landf0_obs = landf_obs(j50,i50)
landf0_mod = landf_mod(:,j50,i50)
landm0_mod = landm_mod(:,j50,i50)

area0_obs  = area_obs(j50,i50)
area0_mod  = area_mod(:,j50,i50)

region0    = region(j50,i50)

delete(i50)
delete(j50)

if (str_lower(varID).eq."sst") then
   region0 = where(region0.eq.0, 1, 0)
else
   region0 = where(region0.gt.0, 1, 0)
end if

; ------- Set Model Data as missing where the Benchmark is missing -----
score  = new((/nmod+1/), float)
tt_mod = new((/nmod+1,nlat,nlon/), float)

score  = -999
tt_mod = -999

if (str_lower(varID@SubGlobe).eq."yes") then
   ts0_obs=where(ts0_obs.le.0, -999, ts0_obs)
else
   do nt=0,ntot-1
      ts0_obs(nt,:,:) =where(region0.gt.0, ts0_obs(nt,:,:), -999)
   end do
end if

ts0_obs@_FillValue =-999

ts0_obs!0="time"
ts0_obs!1="lat"
ts0_obs!2="lon"

ts0_mod!0="mod"
ts0_mod!1="time"
ts0_mod!2="lat"
ts0_mod!3="lon"

region1=dim_avg(ts0_obs(lat|:,lon|:,time|:))

region1=where(.not.ismissing(region1),1,0)

;if (str_lower(varID@CarbonYearly).eq."yes") then
;   region1=where(region1.gt.0,1,0)
;else
;   region1=where(.not.ismissing(region1),1,0)
;end if

tt0=ts0_obs(lat|:,lon|:,time|:)

do nt=0,ntot-1
   tt0(:,:,nt) =where(region1.gt.0, tt0(:,:,nt), -999)
end do

tt0@_FillValue=-999

temp=tt0
temp=where(ismissing(temp), 0, 1)

numb = sum(temp)

delete(temp)

numb = where (numb.gt.1, numb, 0)

if (.not.ismissing(avg(tt0))) then

   area = area0_obs

   landfOM = where(landf0_obs.gt.0.0 .and. landf0_mod(0,:,:).gt.0.0, landf0_mod(0,:,:), -999)
   ;landfOM = where(landf0_obs.gt.0.15 .and. landf0_mod(0,:,:).gt.0.15, landf0_obs, -999)
   landfOM = where(landm0_mod(0,:,:).gt.0, landfOM, -999)

   landfOM@_FillValue=-999

   TempReg = landfOM
   TempReg@_FillValue=-999

   if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
      at0 = sqrt(dim_avg(tt0*tt0))
   else
      at0 = dim_avg(tt0)
   end if

   ;if (str_lower(varID@LimitFlag).eq."yes") then
   ;   at0 = where(ismissing(landf0_obs), -999, at0)
   ;end if

   if (str_lower(varID@CarbonMonthly).eq."yes") then
      score(0)    = sum(at0*area*365*1e-15)
   else
      if (str_lower(varID@CarbonYearly).eq."yes") then
         score(0)    = sum(at0*area*1e-12)
      else
         score(0)    = sum(at0*area*TempReg)/sum(area*TempReg)
      end if
   end if

   at0 = where(ismissing(landfOM), -999, at0)

   ;if (str_lower(varID@LimitFlag).eq."no") then
   ;   at0 = where(ismissing(landf0_obs), -999, at0)
   ;end if

   ; ------- convert unit from per cell area to per land area ------------------------
   ;if (str_lower(varID@LandOnly).eq."yes") then
   ;   tt_mod(0,:,:) = at0/landf0_obs
   ;else
   ;   tt_mod(0,:,:)    = at0
   ;end if

   tt_mod(0,:,:)    = at0

   delete(area)
   delete(landfOM)
   delete(TempReg)

   do nv=0, nmod-1
   if (runID(nv).gt.0) then

      area = area0_mod(nv,:,:)

      TempReg = region1
      TempReg = where(landm0_mod(nv,:,:).gt.0, TempReg, 0)

      landfOM = where(landf0_obs.gt.0.0 .and. landf0_mod(nv,:,:).gt.0.0, landf0_mod(nv,:,:), -999)
      landfOM = where(landm0_mod(nv,:,:).gt.0, landfOM, -999)

      landfOM@_FillValue=-999

      TempReg = landfOM
      TempReg@_FillValue=-999

      tt1=ts0_mod(lat|:,lon|:,time|:,mod|nv)

      if (str_lower(varID@SubGlobe).eq."yes") then
         tt1=where(ismissing(tt0), -999, tt1)
      end if

      tt1@_FillValue = -999

      if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
         at1 = sqrt(dim_avg(tt1*tt1))
      else
         at1 = dim_avg(tt1)
      end if

      ;if (str_lower(varID@LimitFlag).eq."yes") then
      ;   at1 = where(ismissing(landfOM), -999, at1)
      ;end if

      ;if (str_lower(ODELTYPE).eq."clm" .and. str_lower(varID@LimitFlag).eq."yes") then

      if (str_lower(varID@LimitFlag).eq."yes" .or. str_lower(varID@SubGlobe).eq."yes") then

         if (str_lower(varID@CarbonMonthly).eq."yes") then
            score(nv+1) = sum(at1*area*365*1e-15)
         else
            if (str_lower(varID@CarbonYearly).eq."yes") then
               score(nv+1) = sum(at1*area*1e-12)
            else
               score(nv+1) = sum(at1*area*TempReg)/sum(area*TempReg)
            end if
         end if

      else

         if (str_lower(varID@CarbonMonthly).eq."yes") then
            score(nv+1) = RawAvg_mod(nv)*365*1e-15
         else
            if (str_lower(varID@CarbonYearly).eq."yes") then
               score(nv+1) = RawAvg_mod(nv)*1e-12
            else
               score(nv+1) = RawAvg_mod(nv)
            end if
         end if

      end if

      ;if (str_lower(varID@LimitFlag).eq."no") then
      ;   at1 = where(ismissing(landfOM), -999, at1)
      ;end if

      at1 = where(ismissing(landfOM), -999, at1)

      ; ------- convert unit from per cell area to per land area ------------------------
      ;if (str_lower(varID@LandOnly).eq."yes") then
      ;   tt_mod(nv+1,:,:) = at1/landfOM
      ;else
      ;   tt_mod(nv+1,:,:) = at1
      ;end if

      tt_mod(nv+1,:,:) = at1

      delete(at1)
      delete(tt1)
      delete(area)
      delete(landfOM)
      delete(TempReg)
   end if
   end do

   tt_mod@_FillValue = -999

   score@_FillValue  = -999
   tt_mod@_FillValue = -999

   ; ++++++++++ retrieve the units +++++++++++
   UnitInfo  = retrieve_unit (varID, Source)

   UnitTable = UnitInfo@FinalTable
   UnitPlots = UnitInfo@FinalPlots

   ; ++++++++++ set up parameters for drawing +++++++++++

   DrawInfo = retrieve_DrawInfo (varID, "annualmean", Source)

   cnlevels = DrawInfo@cnlevels
   lblabels = DrawInfo@lblabels
   XLab     = DrawInfo@XLab
   YLab     = DrawInfo@YLab
   CLab     = DrawInfo@CLab

   MinLon   = min(rlon)
   MaxLon   = max(rlon)
   MinLat   = min(rlat)
   MaxLat   = max(rlat)

   if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
      MinLon   = DrawInfo@MinLon
      MaxLon   = DrawInfo@MaxLon
      MinLat   = DrawInfo@MinLat
      MaxLat   = DrawInfo@MaxLat
   end if

   XLab     = 1
   YLab     = 1

   ; ++++++++++ Create a txt file and save results +++++++++++

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/annualmean/annualmean_" + str_lower(varID) \
                 + "_" + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                 + sprinti("%0.4i",EndYear) + ".txt"

   print(TableFileName)

   if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
      header       = "Std Dev for " + str_upper(varID) + " (" + UnitTable + "): Model against " + Source + ", " + \
                      sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
   else
      header       = "Annual Mean for " + str_upper(varID) + " (" + UnitTable + "): Model against " + Source + ", " + \
                      sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
   end if

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList(0:nmod),score(0:nmod)/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   tt_mod!0="mod"
   tt_mod!1="lat"
   tt_mod!2="lon"
   tt_mod&lat=rlat
   tt_mod&lon=rlon
   tt_mod&lat@units="degrees_north"
   tt_mod&lon@units="degrees_east"

   ; ++++++++++ Draw global distribution of Annual Mean +++++++++++

   do nv=0, nmod
   if (runIDS(nv).gt.0) then

      PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/annualmean/annualmean_" + str_lower(varID) \
                   + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                   + "-" + sprinti("%0.4i",EndYear)

      if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
         titles       = "Std Dev for " + str_upper(varID) + " (" + UnitPlots + "): " + ModelNameList(nv) + ", " + \
                         sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      else
         titles       = "Annual Mean for " + str_upper(varID) + " (" + UnitPlots + "): " + ModelNameList(nv) + ", " + \
                         sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      end if

      Draw_Map (PlotFileName, tt_mod(nv,:,:), rlat, rlon, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                MinLon, MaxLon, MinLat, MaxLat, SiteID)
   end if
   end do
end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure AnnualMean_belt (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, Unit:string,\
                           ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                           SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

MODELTYPE = getenv("MODELTYPE")

SpatRes   = getenv("SPATRES")
SpatRes   = str_lower(str_squeeze(SpatRes))

nmod=dimsizes(ModelNames)

nsit=dimsizes(ind(slat.ne.-999))

nlon = dimsizes(slon)
nlat = dimsizes(slat)

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID
   
ModelNameList(0) = str_upper(Source)
ModelNameList(1:nmod) = ModelNames

;if (str_lower(SubReg2).eq."global") then
;   SubReg2 = "global.large"
;end if

; -------- Retrieve sub-region for diagnostic analysis ----------------
i50 = ind(.not.ismissing(slon))
j50 = ind(.not.ismissing(slat))

rlon = slon(i50)
rlat = slat(j50)

delete(i50)
delete(j50)

delete(slat)
delete(slon)

; -------- read biome regions data ----------------
fina=DataDir + "/DATA/biomes/GFED/derived/biomes_" + SpatRes + ".nc"

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

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

landf_obs = where(landf_obs.le.0, -999, landf_obs)
landf_mod = where(landf_mod.le.0, -999, landf_mod)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

; -------- read biome regions data ----------------

SubRegName = retrieve_latlon_belt (Source, SubReg)

nreg       = dimsizes(SubRegName)

LatLon = SubRegName@LatLon

MinLat = LatLon(0,:)
MaxLat = LatLon(1,:)
MinLon = LatLon(2,:)
MaxLon = LatLon(3,:)

ShortName = SubRegName
LongName  = SubRegName@LongName

; ++++ force grids of "biome region" the same as sub-region ++++

i61 = ind(MinLon.lt.min(rlon))
i62 = ind(MaxLon.gt.max(rlon))
j61 = ind(MinLat.lt.min(rlat))
j62 = ind(MaxLat.gt.max(rlat))

if (dimsizes(i61).gt.1 .or. .not.ismissing(i61)) then
   MinLon(i61) = min(rlon)
end if

if (dimsizes(i62).gt.1 .or. .not.ismissing(i62)) then
   MaxLon(i62) = max(rlon)
end if

if (dimsizes(j61).gt.1 .or. .not.ismissing(j61)) then
   MinLat(j61) = min(rlat)
end if

if (dimsizes(j62).gt.1 .or. .not.ismissing(j62)) then
   MaxLat(j62) = max(rlat)
end if

delete(i61)
delete(i62)
delete(j61)
delete(j62)

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

scores = new((/nmod+1,nreg/), float)
masses = new((/nmod+1,nreg/), float)

tts    = new((/nmod+1, nreg, ntot/), float)

score = -999
tts   = -999

tts@_FillValue = -999

; ----------- Deal with site dataset -------------
if (SiteID.eq.1 .and. nsit.gt.1) then

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
   ;i50 = ind((slon.ge.min(rlon) .and. slon.le.max(rlon)) .and. (slat.ge.min(rlat) .and. slat.le.max(rlat)))

   ts_obs!0="time"
   ts_obs!1="site"

   temp = dim_avg(ts_obs(site|:,time|:))

   ;if (str_upper(MODELTYPE).eq."CLM") then
   ;   i51 = ind(.not.ismissing(temp) .and. LandFracMod.eq.nmod)
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

      ts0_obs    = ts_obs(:,i51)
      ts0_mod    = ts_mod(:,:,i51)
      slat0      = slat(i51)
      slon0      = slon(i51)

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

      ts0_obs    = ts_obs(:,i51)
      ts0_mod    = ts_mod(:,:,i51)
      slat0      = slat(i51)
      slon0      = slon(i51)

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

anual = dim_avg(tts)

do nv = 1, nmod
   bias(nv,:) = dim_avg(tts(nv,:,:)) - dim_avg(tts(0,:,:))
   rmse(nv,:) = dim_rmsd(tts(nv,:,:), tts(0,:,:))
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
TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/biomes/locations_" + str_lower(varID) \
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

delete(cnlevels)
delete(lblabels)

cnlevels = fspan(1,nreg,nreg)
lblabels = ShortName

region@NAME = ShortName
region@Lons = clon
region@Lats = clat

PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/annualmean/map_biomes_" + str_upper(SubReg1)

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
     PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/biomes/annualmean_" + str_lower(varID) \
                  + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                  + "-" + sprinti("%0.4i",EndYear)
     print(PlotFileName)

     if (str_lower(varID).eq."twsa") then
        titles       = "Std Dev for " + str_upper(varID) + " (" + Unit + "): " + ModelNameList(nv)
     else
        titles       = "Annual Mean for " + str_upper(varID) + " (" + Unit + "): " + ModelNameList(nv)
     end if

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

     if (nv.eq.0) then
        tt1          = -999
        tt2          = -999
        tt1          = tta
        tt2          = tts
        ModelName0   = "CMIP5"
     else
        tt1          = -999
        tt2          = -999
        tt1( 0,nr,:) = tta( 0,nr,:)
        tt2( 0,nr,:) = tts( 0,nr,:)
        tt1(nv,nr,:) = tta(nv,nr,:)
        tt2(nv,nr,:) = tts(nv,nr,:)
        ModelName0   = ModelNameList(nv)
     end if

     tt1@_FillValue = -999
     tt2@_FillValue = -999

     PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/biomes/check_subreg" + sprinti("%i",nr+1) \
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
procedure AnnualMean_site (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, Unit:string,\
                           ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                           SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

nsit=dimsizes(ind(slat.ne.-999))

MODELTYPE = getenv("MODELTYPE")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID

ModelNameList(0) = str_upper(Source)
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

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

; ++++++++++ retrieve the units +++++++++++
DataInfo  = retrieve_unit (varID, Source)

UnitTable = DataInfo@FinalTable
UnitPlots = DataInfo@FinalPlots
delete(DataInfo)

; ------- Choose data only in the selected sub-region ------------------------

if (SiteID@NAME.eq."SITES") then

   ts_obs!0="time"
   ts_obs!1="site"   

   if (any(str_lower(Source).eq.(/"noaa.gmd"/))) then

      temp = dim_avg(ts_obs(site|:,time|:)) 

      if (str_upper(MODELTYPE).eq."CLM") then
         i51 = ind(.not.ismissing(temp) .and. LandFracMod.eq.nmod)
      else
         i51 = ind(.not.ismissing(temp))
      end if
   
      delete(temp)

      if (dimsizes(i51).gt.1 .or. .not.ismissing(i51)) then

         nsit0 = dimsizes(i51)

         ts0_obs = new((/ntot, nsit0/), float)
         ts0_mod = new((/nmod, ntot, nsit0/), float)
         slat0   = new((/nsit0/), float)
         slon0   = new((/nsit0/), float)

         if (nsit0.eq.1) then
            ts0_obs(:,0)   = ts_obs(:,i51)
            ts0_mod(:,:,0) = ts_mod(:,:,i51)
            slat0(0)       = slat(i51)
            slon0(0)       = slon(i51)
         else
            ts0_obs(:,0:nsit0-1)   = ts_obs(:,i51)
            ts0_mod(:,:,0:nsit0-1) = ts_mod(:,:,i51)
            slat0(0:nsit0-1)       = slat(i51)
            slon0(0:nsit0-1)       = slon(i51)
         end if

         slon0=where(slon0.gt.180, slon0-360, slon0)

         ts0_obs@_FillValue=-999
         ts0_mod@_FillValue=-999

         ; -------- read biome regions data ----------------

         SubRegName = retrieve_latlon_belt (Source, "zonalmean")

         nreg       = dimsizes(SubRegName)

         LatLon = SubRegName@LatLon

         MinLat = LatLon(0,:)
         MaxLat = LatLon(1,:)
         MinLon = LatLon(2,:)
         MaxLon = LatLon(3,:)

         ShortName = SubRegName
         LongName  = SubRegName@LongName

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

         score = new((/nmod+1/), float)
         tts   = new((/nmod+1, nreg, ntot/), float)

         score = -999
         tts   = -999

         tts@_FillValue = -999

         tt0=new((/nsit0,ntot/), float)

         do nt=0,ntot-1
            tt0(:,nt)=ts0_obs(nt,:)
         end do

         tt0@_FillValue=-999

         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

         numb = where(numb.gt.1, numb, 0)

         score(0) = avg(tt0)

         do nv=0, nmod-1
            if (runID(nv).gt.0) then

               tt1=new((/nsit0,ntot/), float)

               do nt=0,ntot-1
                  tt1(:,nt)=ts0_mod(nv,nt,:)
               end do

               tt1=where(ismissing(tt0), -999, tt1)

               tt1@_FillValue=-999

               reg0=new((/dimsizes(slat0)/), float)

               do nr = 0, nreg-1

                  j50 = ind((slat0.ge.MinLat(nr).and.slat0.le.MaxLat(nr)) .and. (slon0.ge.MinLon(nr).and.slon0.le.MaxLon(nr)))

                  if (dimsizes(j50).gt.1) then
                     tts(0,nr,:)      = dim_avg_n(tt0(j50,:), 0)
                     tts(nv+1,nr,:)   = dim_avg_n(tt1(j50,:), 0)
                  else
                     if (dimsizes(j50).eq.1 .and. .not.ismissing(j50)) then
                        tts(0,nr,:)      = (/tt0(j50, :)/)
                        tts(nv+1,nr,:)   = (/tt1(j50, :)/)
                     end if
                  end if

                  delete(j50)
               end do

               score(nv+1)=avg(tt1)

               delete(tt1)
               delete(reg0)
            end if
         end do

         tts@_FillValue = -999

         ; +++ Remove long-term trend from each time series +++
         tts0    = new((/nmod+1, nreg, ntot/), float)

         tts0    = -999 

         xx = fspan(1.,int2flt(nyer),ntot)
         nn = 3

         do nv = 0, nmod
         do ns = 0, nreg-1

            if (dimsizes(.not.ismissing(tts(nv,ns,:))).gt.3) then

               yy01 = tts(nv,ns,:)

               cc0  = lspoly(xx,yy01, 1, nn)
               yy02 = cc0(0) + cc0(1)*xx + cc0(2)*xx^2
               yy02 = yy01-yy02
               delete(cc0)

               tts0(nv,ns,:) = yy02

               delete(yy01)
               delete(yy02)
            end if

         end do
         end do

         ; +++ calculate annual cycle for each time series +++
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

         tt1 = tta
         tt2 = tts

         tt1@_FillValue    = -999
         tt2@_FillValue    = -999

          score = 0.0

         ; ++++++++++ Create a txt file and save results +++++++++++

         TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/annualmean/annualmean_" + str_lower(varID) \
                       + "_" + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                       + sprinti("%0.4i",EndYear) + ".txt"

         print(TableFileName)

         header       = "Annual Mean for " + str_upper(varID) + " (" + UnitTable + "): Model against " + Source + ", " + \
                         sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         write_table(TableFileName, "w", [/header/], "%s")
         write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
         write_table(TableFileName,"a",[/ModelNameList(0:nmod),score(0:nmod)/], "%16s %10.2f")

         ;print(asciiread(TableFileName,-1,"string"))

         ; ++++++++++ set up parameters for drawing +++++++++++

         DrawInfo = retrieve_DrawInfo (varID, "annualmean", Source)

         cnlevels = DrawInfo@cnlevels
         lblabels = DrawInfo@lblabels
         XLab     = DrawInfo@XLab
         YLab     = DrawInfo@YLab
         CLab     = DrawInfo@CLab

         SubRegName = retrieve_latlon_belt (Source, "zonalmean")

         nreg       = dimsizes(SubRegName)

         LatLon = SubRegName@LatLon

         MinLat = LatLon(0,:)
         MaxLat = LatLon(1,:)
         MinLon = LatLon(2,:)
         MaxLon = LatLon(3,:)

         cLats  = (MinLat+MaxLat)/2

         do ns =0, nreg-1
            if (cLats(ns).lt.0) then
               TmpStr1 = sprintf("%.0f",floor(abs(cLats(ns)))) + "S"
            else
               TmpStr1 = sprintf("%.0f",floor(cLats(ns))) + "N"
            end if

            LongName(ns)  = TmpStr1
         end do

         cLats@lblabels = LongName

         Times=fspan(1,int2flt(nmon),nmon)
         Times@lblabels = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

         tt1!0="mod"
         tt1!1="lat"
         tt1!2="time"
         tt1&lat=cLats
         tt1&lat@units="degrees_north"
         tt1&time=fspan(1,int2flt(nmon),nmon)

         tt2!0="mod"
         tt2!1="lat"
         tt2!2="time"
         tt2&lat=cLats
         tt2&lat@units="degrees_north"
         tt2&time=fspan(StartYear,EndYear+1,ntot)

         ;if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
         ;   MinLon   = DrawInfo@MinLon
         ;   MaxLon   = DrawInfo@MaxLon
         ;   MinLat   = DrawInfo@MinLat
         ;   MaxLat   = DrawInfo@MaxLat
         ;end if

         XLab     = 1
         YLab     = 1

         ;tt1 = where(ismissing(tt1), 360, tt1)

         ; ++++++++++ Draw global distribution of Annual Mean +++++++++++
         do nv = 0, nmod
            if (runIDS(nv).gt.0) then

               PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/annualmean/annualmean_" + str_lower(varID) \
                            + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                            + "-" + sprinti("%0.4i",EndYear)

               titles = "Annual Cycle for " + str_upper(varID) + " (" + UnitPlots + "): " + ModelNameList(nv) \
                      + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

               Draw_LatLon_Time (PlotFileName, tt1(nv,:,:), titles, cnlevels, lblabels, XLab, YLab, CLab, \
                         cLats, Times)
            end if
         end do

         delete(tt1)
         delete(tt2)
         delete(tta)
         delete(tts)
         delete(ttt)
         delete(tts0)
         delete(ts0_obs)
         delete(ts0_mod)
      end if

      delete(i51)
  
   else

      i50 = ind((slon.ge.min(rlon) .and. slon.le.max(rlon)) .and. (slat.ge.min(rlat) .and. slat.le.max(rlat)))

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
   
      delete(temp)

      if (dimsizes(i51).gt.1 .or. .not.ismissing(i51)) then

         nsit0 = dimsizes(i51)

         ts0_obs = new((/ntot, nsit0/), float)
         ts0_mod = new((/nmod, ntot, nsit0/), float)
         slat0   = new((/nsit0/), float)
         slon0   = new((/nsit0/), float)

         if (nsit0.eq.1) then
            ts0_obs(:,0)   = ts_obs(:,i50(i51))
            ts0_mod(:,:,0) = ts_mod(:,:,i50(i51))
            slat0(0)       = slat(i50(i51))
            slon0(0)       = slon(i50(i51))
         else
            ts0_obs(:,0:nsit0-1)   = ts_obs(:,i50(i51))
            ts0_mod(:,:,0:nsit0-1) = ts_mod(:,:,i50(i51))
            slat0(0:nsit0-1)       = slat(i50(i51))
            slon0(0:nsit0-1)       = slon(i50(i51))
         end if

         score=new((/nmod+1/), float)
         tt_mod=new((/nmod+1,nsit0/), float)

         score  = -999
         tt_mod = -999

         slon0=where(slon0.gt.180, slon0-360, slon0)

         tt0=new((/nsit0,ntot/), float)

         do nt=0,ntot-1
            tt0(:,nt)=ts0_obs(nt,:)
         end do

         tt0@_FillValue=-999

         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

         numb = where(numb.gt.1, numb, 0)

         at0=dim_avg(tt0)
         score(0)=avg(at0)
         tt_mod(0,:)=at0

         do nv=0, nmod-1
            if (runID(nv).gt.0) then

               tt1=new((/nsit0,ntot/), float)

               do nt=0,ntot-1
                  tt1(:,nt)=ts0_mod(nv,nt,:)
               end do

               tt1=where(ismissing(tt0), -999, tt1)

               tt1@_FillValue=-999

               at1=dim_avg(tt1)
               score(nv+1)=avg(at1)
               tt_mod(nv+1,:)=at1

               delete(at1)
               delete(tt1)
            end if
         end do

         tt_mod!0="mod"
         tt_mod!1="site"

         score@_FillValue = -999
         tt_mod@_FillValue = -999

         ; ++++++++++ Create a txt file and save results +++++++++++

         TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/annualmean/annualmean_" + str_lower(varID) \
                       + "_" + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                       + sprinti("%0.4i",EndYear) + ".txt"

         print(TableFileName)

         header       = "Annual Mean for " + str_upper(varID) + " (" + UnitTable + "): Model against " + Source + ", " + \
                         sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         write_table(TableFileName, "w", [/header/], "%s")
         write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
         write_table(TableFileName,"a",[/ModelNameList(0:nmod),score(0:nmod)/], "%16s %10.2f")

         ;print(asciiread(TableFileName,-1,"string"))

         ; ++++++++++ set up parameters for drawing +++++++++++

         DrawInfo = retrieve_DrawInfo (varID, "annualmean", Source)

         cnlevels = DrawInfo@cnlevels
         lblabels = DrawInfo@lblabels
         XLab     = DrawInfo@XLab
         YLab     = DrawInfo@YLab
         CLab     = DrawInfo@CLab

         MinLon   = min(rlon)
         MaxLon   = max(rlon)
         MinLat   = min(rlat)
         MaxLat   = max(rlat)

         if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
            MinLon   = DrawInfo@MinLon
            MaxLon   = DrawInfo@MaxLon
            MinLat   = DrawInfo@MinLat
            MaxLat   = DrawInfo@MaxLat
         end if

         XLab     = 1
         YLab     = 1

         ; ++++++++++ Draw global distribution of Annual Mean +++++++++++
         do nv = 0, nmod
            if (runIDS(nv).gt.0) then

               tt_mod@_FillValue = -999

               PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/annualmean/annualmean_" + str_lower(varID) \
                            + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                            + "-" + sprinti("%0.4i",EndYear)

               titles = "Annual Mean for " + str_upper(varID) + " (" + UnitPlots + "): " + ModelNameList(nv) + ", " + \
                         sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

               Draw_Map (PlotFileName, tt_mod(nv,:), slat0, slon0, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                         MinLon, MaxLon, MinLat, MaxLat, SiteID)
            end if
         end do

      end if

      delete(i50)
      delete(i51)
   end if


else

   if (any(str_lower(Source).eq.(/"gcp", "hoffman"/))) then

      score=new((/nmod+1/), float)
      tt_mod=new((/nmod+1,nyer/), float)

      score  = -999
      tt_mod = -999

      tt0=new((/nyer,nmon/), float)

         ijk=0
      do iy=0,nyer-1
      do im=0,nmon-1
         tt0(iy,im)=ts_obs(ijk)
         ijk=ijk+1
      end do
      end do

      tt0@_FillValue=-999

      numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

      numb = where(numb.gt.1, numb, 0)

      at0=dim_avg(tt0)

      score(0)=avg(at0)
      tt_mod(0,:)=at0

      do nv=0, nmod-1
      if (runID(nv).gt.0) then

         tt1=new((/nyer,nmon/), float)

            ijk=0
         do iy=0,nyer-1
         do im=0,nmon-1
            tt1(iy,im)=ts_mod(nv,ijk,0)
            ijk=ijk+1
         end do
         end do

         tt1=where(ismissing(tt0), -999, tt1)

         tt1@_FillValue=-999

         at1=dim_avg(tt1)

         score(nv+1)=avg(at1)
         tt_mod(nv+1,:)=at1

         delete(at1)
         delete(tt1)
      end if
      end do

      tta_mod = tt_mod

      do iy=1,nyer-1
         tta_mod(:,iy) = tta_mod(:,iy-1) + tta_mod(:,iy)
      end do

      do iy=0,nyer-1
         tta_mod(:,iy) = tta_mod(:,iy) - tta_mod(:,0)
      end do

      tt1_mod = tt_mod
      tt2_mod = tta_mod

      tt1_mod = -999
      tt2_mod = -999

      score!0="mod"
      score&mod=fspan(1,nmod+1,nmod+1)

      tt_mod!0="mod"
      tt_mod!1="time"
      tt_mod&time=fspan(StartYear,EndYear,nyer)

      tta_mod!0="mod"
      tta_mod!1="time"
      tta_mod&time=fspan(StartYear,EndYear,nyer)

      tt1_mod!0="mod"
      tt1_mod!1="time"
      tt1_mod&time=fspan(StartYear,EndYear,nyer)

      tt2_mod!0="mod"
      tt2_mod!1="time"
      tt2_mod&time=fspan(StartYear,EndYear,nyer)
      
   else

      score  = new((/nmod+1/), float)
      tt_mod = new((/nmod+1,nyer/), float)
      tta_mod= new((/nmod+1,nyer/), float)

      score  = -999
      tt_mod = -999

      xx = fspan(1.,int2flt(nyer),ntot)
      nn = 3

      yy01 = ts_obs(:)

      cc0  = lspoly(xx,yy01, 1, nn)
      yy02 = cc0(0) + cc0(1)*xx + cc0(2)*xx^2
      yy02 = yy01-yy02
      delete(cc0)

      tt01=new((/nmon,nyer/), float)
      tt02=new((/nmon,nyer/), float)

         ijk=0
      do iy=0,nyer-1
      do im=0,nmon-1
         tt01(im,iy)=yy01(ijk)
         tt02(im,iy)=yy02(ijk)
         ijk=ijk+1
      end do
      end do

      tt01@_FillValue=-999
      tt02@_FillValue=-999

      numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(yy01)))))

      numb = where(numb.ge.1, numb, 0)

      at01=dim_avg(tt01)
      at02=dim_avg(tt02)

      score(0)     = avg(at01)
      tt_mod(0,:)  = dim_avg_n(tt01, 0)

      ;tta_mod(0,:)=at02
      tta_mod(0,:) = tt_mod(0,:) - tt_mod(0,0)

      do nv=0, nmod-1
      if (runID(nv).gt.0) then

         yy11 = ts_mod(nv,:,0)

         yy11@_FillValue=-999

         if (dimsizes(ind(.not.ismissing(yy11))).ge.2) then

            cc1  = lspoly(xx,yy11, 1, nn)
            yy12 = cc1(0) + cc1(1)*xx + cc1(2)*xx^2
            yy12 = yy11-yy12
            delete(cc1)

            tt11=new((/nmon,nyer/), float)
            tt12=new((/nmon,nyer/), float)

               ijk=0
            do iy=0,nyer-1
            do im=0,nmon-1
               tt11(im,iy)=yy11(ijk)
               tt12(im,iy)=yy12(ijk)
               ijk=ijk+1
            end do
            end do

            tt11@_FillValue=-999
            tt12@_FillValue=-999

            tt11=where(ismissing(tt01), -999, tt11)
            tt12=where(ismissing(tt01), -999, tt12)

            at11=dim_avg(tt11)
            at12=dim_avg(tt12)

            score(nv+1)     = (/avg(at11)/)
            tt_mod(nv+1,:)  = (/dim_avg_n(tt11, 0)/)

            ;tta_mod(nv+1,:) = (/at12/)
            tta_mod(nv+1,:) = tt_mod(nv+1,:) - tt_mod(nv+1,0)

            delete(at11)
            delete(at12)
            delete(tt11)
            delete(tt12)
            delete(yy12)
         end if
         delete(yy11)
      end if
      end do

      delete(xx)
      delete(at01)
      delete(at02)
      delete(tt01)
      delete(tt02)
      delete(yy01)
      delete(yy02)

      tt1_mod = tt_mod
      tt2_mod = tta_mod

      tt1_mod = -999
      tt2_mod = -999

      score!0="mod"
      score&mod=fspan(1,nmod+1,nmod+1)

      tt_mod!0="mod"
      tt_mod!1="time"
      tt_mod&time=fspan(StartYear,EndYear,nyer)

      tta_mod!0="mod"
      tta_mod!1="time"
      tta_mod&time=fspan(StartYear,EndYear,nyer)
      ;tta_mod&time=fspan(1,12,nmon)

      tt1_mod!0="mod"
      tt1_mod!1="time"
      tt1_mod&time=fspan(StartYear,EndYear,nyer)

      tt2_mod!0="mod"
      tt2_mod!1="time"
      tt2_mod&time=fspan(StartYear,EndYear,nyer)
      ;tt2_mod&time=fspan(1,12,nmon)
      
   end if

   score@_FillValue = -999

   ; ++++++++++ Create a txt file and save results +++++++++++

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/annualmean/annualmean_" + str_lower(varID) \
                 + "_" + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                 + sprinti("%0.4i",EndYear) + ".txt"

   print(TableFileName)

   header       = "Annual Mean for " + str_upper(varID) + " (" + UnitTable + "): Model against " + Source + ", " + \
                  sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList(0:nmod),score(0:nmod)/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   ; ++++++++++ set up parameters for drawing +++++++++++

   DrawInfo = retrieve_DrawInfo (varID, "annualmean", Source)

   cnlevels = DrawInfo@cnlevels
   lblabels = DrawInfo@lblabels
   XLab     = DrawInfo@XLab
   YLab     = DrawInfo@YLab
   CLab     = DrawInfo@CLab

   MinLon   = DrawInfo@MinLon
   MaxLon   = DrawInfo@MaxLon
   MinLat   = DrawInfo@MinLat
   MaxLat   = DrawInfo@MaxLat

   XLab     = 1
   YLab     = 1

   ; ++++++++++ Draw global distribution of Annual Mean +++++++++++
   do nv = 0, nmod

      if (runIDS(nv).gt.0) then

         if (nv.eq.0) then
            tt1_mod = -999
            tt2_mod = -999
            tt1_mod = tt_mod
            tt2_mod = tta_mod
            ModelName0 = "CMIP5"
         else
            tt1_mod = -999
            tt2_mod = -999
            tt1_mod(0,:) = tt_mod(0,:)
            tt2_mod(0,:) = tta_mod(0,:)
            tt1_mod(nv,:) = tt_mod(nv,:)
            tt2_mod(nv,:) = tta_mod(nv,:)
            ModelName0 = ModelNameList(nv)
         end if

         tt1_mod@_FillValue = -999
         tt2_mod@_FillValue = -999

         PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/annualmean/annualmean_" + str_lower(varID) \
                      + "_" + ModelName0 + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                      + "-" + sprinti("%0.4i",EndYear)

         titles       = "Annual Mean for " + str_upper(varID) + " (" + UnitPlots + ")"

         Draw_Bar (PlotFileName, ModelNameList, score, tt1_mod, tt2_mod, titles, \
                   XLab, YLab, CLab, MinLon, MaxLon, MinLat, MaxLat, "Line")
      end if
   end do

end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Bias (DataDir:string, ModelNames:string, runID:integer, varID:string, Source:string, Unit:string,\
               ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
               SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

MODELTYPE = getenv("MODELTYPE")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID

ModelNameList(0) = str_upper(Source)
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac
landm_mod = ts_mod@LandMask

RawMax_mod = ts_mod@RawMax
RawMin_mod = ts_mod@RawMin
RawAvg_mod = ts_mod@RawAvg

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

region    = where(landf_obs.gt.0,1,0)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

; ------- Choose data only in the selected sub-region ------------------------
i50 = ind(slon.ge.min(rlon) .and. slon.le.max(rlon))
j50 = ind(slat.ge.min(rlat) .and. slat.le.max(rlat))

nlon = dimsizes(i50)
nlat = dimsizes(j50)

ts0_obs    = ts_obs(:,j50,i50)
ts0_mod    = ts_mod(:,:,j50,i50)

landf0_obs = landf_obs(j50,i50)
landf0_mod = landf_mod(:,j50,i50)
landm0_mod = landm_mod(:,j50,i50)

area0_obs  = area_obs(j50,i50)
area0_mod  = area_mod(:,j50,i50)

region0    = region(j50,i50)

delete(i50)
delete(j50)

if (str_lower(varID).eq."sst") then
   region0=where(region0.eq.0, 1, 0)
else
   region0=where(region0.gt.0.5, 1, 0)
end if

; ------- Set Model Data as missing where the Benchmark is missing -----
score=new((/nmod+1/), float)
tt_mod=new((/nmod+1,nlat,nlon/), float)

score  = -999
tt_mod = -999

if (str_lower(varID@SubGlobe).eq."yes") then
   ts0_obs=where(ts0_obs.le.0, -999, ts0_obs)
else
   do nt=0,ntot-1
      ts0_obs(nt,:,:) =where(region0.gt.0, ts0_obs(nt,:,:), -999)
   end do
end if

ts0_obs@_FillValue=-999

ts0_obs!0="time"
ts0_obs!1="lat"
ts0_obs!2="lon"

ts0_mod!0="mod"
ts0_mod!1="time"
ts0_mod!2="lat"
ts0_mod!3="lon"

region1=dim_avg(ts0_obs(lat|:,lon|:,time|:))

region1=where(.not.ismissing(region1),1,0)

;if (str_lower(varID@CarbonYearly).eq."yes") then
;   region1=where(region1.gt.0,1,0)
;else
;   region1=where(.not.ismissing(region1),1,0)
;end if

tt0=ts0_obs(lat|:,lon|:,time|:)

do nt=0,ntot-1
   tt0(:,:,nt) =where(region1.gt.0, tt0(:,:,nt), -999)
end do

tt0@_FillValue=-999

temp=tt0
temp=where(ismissing(temp), 0, 1)

numb=sum(temp)

delete(temp)

numb = where (numb.gt.1, numb, 0)

if (.not.ismissing(avg(tt0))) then

   if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
      at0 = sqrt(dim_avg(tt0*tt0))
   else
      at0 = dim_avg(tt0)
   end if

   do nv=0, nmod-1
   if (runID(nv).gt.0) then

      area = area0_mod(nv,:,:)

      TempReg = region1
      TempReg = where(landm0_mod(nv,:,:).gt.0, TempReg, 0)

      landfOM = where(landf0_obs.gt.0.0 .and. landf0_mod(nv,:,:).gt.0.0, landf0_mod(nv,:,:), -999)
      landfOM = where(landm0_mod(nv,:,:).gt.0, landfOM, -999)

      landfOM@_FillValue=-999

      TempReg = landfOM
      TempReg@_FillValue=-999

      tt1=ts0_mod(lat|:,lon|:,time|:,mod|nv)

      if (str_lower(varID@SubGlobe).eq."yes") then
         tt1=where(ismissing(tt0), -999, tt1)
      end if

      tt1@_FillValue = -999

      if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
         at1 = sqrt(dim_avg(tt1*tt1))
      else
         at1 = dim_avg(tt1)
      end if

      ;if (str_lower(varID@LimitFlag).eq."yes") then
      ;   at1 = where(ismissing(landfOM), -999, at1)
      ;end if

      ;if (str_lower(MODELTYPE).eq."clm" .and. str_lower(varID@LimitFlag).eq."yes") then

      if (str_lower(varID@LimitFlag).eq."yes" .or. str_lower(varID@SubGlobe).eq."yes") then

         if (str_lower(varID@CarbonMonthly).eq."yes") then
            score(nv+1) = sum(at1*area*365*1e-15) - sum(at0*area*365*1e-15)
         else
            if (str_lower(varID@CarbonYearly).eq."yes") then
               score(nv+1) = sum(at1*area*1e-12) - sum(at0*area*1e-12)
            else
               score(nv+1) = sum(at1*area*TempReg)/sum(area*TempReg) - sum(at0*area*TempReg)/sum(area*TempReg)
            end if
         end if

      else

         if (str_lower(varID@CarbonMonthly).eq."yes") then
            score(nv+1) = RawAvg_mod(nv)*365*1e-15 - sum(at0*area*365*1e-15)
         else
            if (str_lower(varID@CarbonYearly).eq."yes") then
               score(nv+1) = RawAvg_mod(nv)*1e-12 - sum(at0*area*1e-12)
            else
               score(nv+1) = RawAvg_mod(nv) - sum(at0*area*TempReg)/sum(area*TempReg)
           end if
         end if

      end if

      ;if (str_lower(varID@LimitFlag).eq."no") then
      ;   at1 = where(ismissing(landfOM), -999, at1)
      ;end if

      at1 = where(ismissing(landfOM), -999, at1)

      ; ------- convert unit from per cell area to per land area ------------------------
      ;if (str_lower(varID@LandOnly).eq."yes") then
      ;   tt_mod(nv+1,:,:) = (at1-at0)/landfOM
      ;else
      ;   tt_mod(nv+1,:,:) = at1-at0
      ;end if

      tt_mod(nv+1,:,:) = at1-at0

      delete(at1)
      delete(tt1)
      delete(area)
      delete(landfOM)
      delete(TempReg)
   end if
   end do

   tt_mod@_FillValue = -999

   score@_FillValue  = -999
   tt_mod@_FillValue = -999

   ; ++++++++++ retrieve the units +++++++++++
   UnitInfo  = retrieve_unit (varID, Source)

   UnitTable = UnitInfo@FinalTable
   UnitPlots = UnitInfo@FinalPlots
   delete(UnitInfo)

   ; ++++++++++ Set up parameters for drawing +++++++++++

   DrawInfo = retrieve_DrawInfo (varID, "bias", Source)

   cnlevels = DrawInfo@cnlevels
   lblabels = DrawInfo@lblabels
   XLab     = DrawInfo@XLab
   YLab     = DrawInfo@YLab
   CLab     = DrawInfo@CLab

   MinLon   = min(rlon)
   MaxLon   = max(rlon)
   MinLat   = min(rlat)
   MaxLat   = max(rlat)

   if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
       MinLon   = DrawInfo@MinLon
       MaxLon   = DrawInfo@MaxLon
       MinLat   = DrawInfo@MinLat
       MaxLat   = DrawInfo@MaxLat
   end if

   XLab     = 1
   YLab     = 1

   ; ++++++++++ Create a txt file and save results +++++++++++

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/bias/bias_" + str_lower(varID) \
                 + "_" + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                 + "-" + sprinti("%0.4i",EndYear) + ".txt"

   print(TableFileName)

   if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
      header       = "Bias (std dev) for " + str_upper(varID) + " (" + UnitTable + "): Model against " \ 
                   +  Source + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
   else
      header       = "Bias for " + str_upper(varID) + " (" + UnitTable + "): Model against " + Source + ", " + \
                      sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
   end if

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList(0:nmod),score(0:nmod)/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   tt_mod!0="mod"
   tt_mod!1="lat"
   tt_mod!2="lon"
   tt_mod&lat=rlat
   tt_mod&lon=rlon
   tt_mod&lon@units="degrees_east"
   tt_mod&lat@units="degrees_north"

   ; ++++++++++ Draw global distribution of Bias +++++++++++

   do nv=1, nmod
   if (runIDS(nv).gt.0) then

      PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/bias/bias_" + str_lower(varID) \
                   + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                   + "-" + sprinti("%0.4i",EndYear)

      if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
         titles       = "Bias (std dev) for " + str_upper(varID) + " (" + UnitPlots + "): " + ModelNameList(nv) + " against " \
                      + Source + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      else
         titles       = "Bias for " + str_upper(varID) + " (" + UnitPlots + "): " + ModelNameList(nv) + " against " + Source \
                      + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      end if

      Draw_Map (PlotFileName, tt_mod(nv,:,:), rlat, rlon, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                MinLon, MaxLon, MinLat, MaxLat, SiteID)

   end if
   end do
end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Bias_site (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, Unit:string,\
                     ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                     SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

nsit=dimsizes(ind(slat.ne.-999))

MODELTYPE = getenv("MODELTYPE")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID

ModelNameList(0) = str_upper(Source)
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

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

; ++++++++++ retrieve the units +++++++++++
UnitInfo  = retrieve_unit (varID, Source)

UnitTable = UnitInfo@FinalTable
UnitPlots = UnitInfo@FinalPlots

; ------- Choose data only in the selected sub-region ------------------------

if (SiteID@NAME.eq."SITES") then

   ts_obs!0="time"
   ts_obs!1="site"   

   if (any(str_lower(Source).eq.(/"noaa.gmd"/))) then

      temp = dim_avg(ts_obs(site|:,time|:)) 

      if (str_upper(MODELTYPE).eq."CLM") then
         i51 = ind(.not.ismissing(temp) .and. LandFracMod.eq.nmod)
      else
         i51 = ind(.not.ismissing(temp))
      end if
   
      delete(temp)

      if (dimsizes(i51).gt.1 .or. .not.ismissing(i51)) then

         nsit0 = dimsizes(i51)

         ts0_obs = new((/ntot, nsit0/), float)
         ts0_mod = new((/nmod, ntot, nsit0/), float)
         slat0   = new((/nsit0/), float)
         slon0   = new((/nsit0/), float)

         if (nsit0.eq.1) then
            ts0_obs(:,0)   = ts_obs(:,i51)
            ts0_mod(:,:,0) = ts_mod(:,:,i51)
            slat0(0)       = slat(i51)
            slon0(0)       = slon(i51)
         else
            ts0_obs(:,0:nsit0-1)   = ts_obs(:,i51)
            ts0_mod(:,:,0:nsit0-1) = ts_mod(:,:,i51)
            slat0(0:nsit0-1)       = slat(i51)
            slon0(0:nsit0-1)       = slon(i51)
         end if

         ts0_obs@_FillValue=-999
         ts0_mod@_FillValue=-999

         ; -------- read biome regions data ----------------

         SubRegName = retrieve_latlon_belt (Source, "zonalmean")

         nreg       = dimsizes(SubRegName)

         LatLon = SubRegName@LatLon

         MinLat = LatLon(0,:)
         MaxLat = LatLon(1,:)
         MinLon = LatLon(2,:)
         MaxLon = LatLon(3,:)

         ShortName = SubRegName
         LongName  = SubRegName@LongName

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

         score   = new((/nmod+1/), float)
         tts     = new((/nmod+1, nreg, ntot/), float)

         score = -999
         tts   = -999

         tts@_FillValue = -999

         slon0=where(slon0.gt.180, slon0-360, slon0)

         tt0=new((/nsit0,ntot/), float)

         do nt=0,ntot-1
            tt0(:,nt)=ts0_obs(nt,:)
         end do

         tt0@_FillValue=-999

         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

         numb = where(numb.gt.1, numb, 0)

         score(0) = avg(tt0)

         do nv=0, nmod-1
            if (runID(nv).gt.0) then

               tt1=new((/nsit0,ntot/), float)

               do nt=0,ntot-1
                  tt1(:,nt)=ts0_mod(nv,nt,:)
               end do

               tt1=where(ismissing(tt0), -999, tt1)

               tt1@_FillValue=-999

               reg0=new((/dimsizes(slat0)/), float)

               do nr = 1, nreg

                  j50 = ind((slat0.ge.MinLat(nr-1).and.slat0.le.MaxLat(nr-1)) .and. (slon0.ge.MinLon(nr-1).and.slon0.le.MaxLon(nr-1)))

                  if (dimsizes(j50).gt.1) then
                     tts(0,nr-1,:)      = dim_avg_n(tt0(j50,:), 0)
                     tts(nv+1,nr-1,:)   = dim_avg_n(tt1(j50,:), 0)
                  else
                     if (dimsizes(j50).eq.1 .and. .not.ismissing(j50)) then
                        tts(0,nr-1,:)      = (/tt0(j50,:)/)
                        tts(nv+1,nr-1,:)   = (/tt1(j50,:)/)
                     end if
                  end if

                  delete(j50)
               end do

               score(nv+1) = avg(tt1)

               delete(tt1)
               delete(reg0)
            end if
         end do

         tts@_FillValue = -999

         ; +++ Remove long-term trend from each time series +++
         tts0    = new((/nmod+1, nreg, ntot/), float)

         tts0    = -999 

         xx = fspan(1.,int2flt(nyer),ntot)
         nn = 3

         do nv = 0, nmod
         do ns = 0, nreg-1

            if (dimsizes(.not.ismissing(tts(nv,ns,:))).gt.3) then

               yy01 = tts(nv,ns,:)

               cc0  = lspoly(xx,yy01, 1, nn)
               yy02 = cc0(0) + cc0(1)*xx + cc0(2)*xx^2
               yy02 = yy01-yy02
               delete(cc0)

               tts0(nv,ns,:) = yy02

               delete(yy01)
               delete(yy02)
            end if

         end do
         end do

         ; +++ calculate annual cycle for each time series +++
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

         do nv=1, nmod
            tta(nv,:,:) = tta(nv,:,:) - tta(0,:,:)
         end do

         tta(0,:,:) = tta(0,:,:) - tta(0,:,:)

         score = 0.0

         tt1 = tta
         tt2 = tts

         tt1@_FillValue    = -999
         tt2@_FillValue    = -999

         ; ++++++++++ Create a txt file and save results +++++++++++

         TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/bias/bias_" + str_lower(varID) \
                       + "_" + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                       + sprinti("%0.4i",EndYear) + ".txt"

         print(TableFileName)

         header       = "Bias for " + str_upper(varID) + " (" + UnitTable + "): Model against " + Source + ", " + \
                         sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         write_table(TableFileName, "w", [/header/], "%s")
         write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
         write_table(TableFileName,"a",[/ModelNameList(0:nmod),score(0:nmod)/], "%16s %10.2f")

         ;print(asciiread(TableFileName,-1,"string"))

         ; ++++++++++ set up parameters for drawing +++++++++++

         DrawInfo = retrieve_DrawInfo (varID, "annualmean", Source)

         cnlevels = DrawInfo@cnlevels
         lblabels = DrawInfo@lblabels
         XLab     = DrawInfo@XLab
         YLab     = DrawInfo@YLab
         CLab     = DrawInfo@CLab

         SubRegName = retrieve_latlon_belt (Source, "zonalmean")

         nreg       = dimsizes(SubRegName)

         LatLon = SubRegName@LatLon

         MinLat = LatLon(0,:)
         MaxLat = LatLon(1,:)
         MinLon = LatLon(2,:)
         MaxLon = LatLon(3,:)

         cLats  = (MinLat+MaxLat)/2

         do ns =0, nreg-1
            if (cLats(ns).lt.0) then
               TmpStr1 = sprintf("%.0f",floor(abs(cLats(ns)))) + "S"
            else
               TmpStr1 = sprintf("%.0f",floor(cLats(ns))) + "N"
            end if

            LongName(ns)  = TmpStr1
         end do

         cLats@lblabels = LongName

         ;Times=fspan(0,int2flt(nmon+1),nmon+1)
         ;Times@lblabels = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","Jan"/)

         Times=fspan(1,int2flt(nmon),nmon)
         Times@lblabels = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

         tt1!0="mod"
         tt1!1="lat"
         tt1!2="time"
         tt1&lat=cLats
         tt1&lat@units="degrees_north"
         tt1&time=fspan(1,int2flt(nmon),nmon)

         tt2!0="mod"
         tt2!1="lat"
         tt2!2="time"
         tt2&lat=cLats
         tt2&lat@units="degrees_north"
         tt2&time=fspan(StartYear,EndYear+1,ntot)

         ;if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
         ;   MinLon   = DrawInfo@MinLon
         ;   MaxLon   = DrawInfo@MaxLon
         ;   MinLat   = DrawInfo@MinLat
         ;   MaxLat   = DrawInfo@MaxLat
         ;end if

         XLab     = 1
         YLab     = 1

         ; ++++++++++ Draw global distribution of Annual Mean +++++++++++
         do nv = 1, nmod
            if (runIDS(nv).gt.0) then

               PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/bias/bias_" + str_lower(varID) \
                            + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                            + "-" + sprinti("%0.4i",EndYear)

               titles = "Bias for " + str_upper(varID) + " (" + UnitPlots + "): " + ModelNameList(nv) \
                      + " against " + Source + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

               Draw_LatLon_Time (PlotFileName, tt1(nv,:,:), titles, cnlevels, lblabels, XLab, YLab, CLab, \
                         cLats, Times)
            end if
         end do

         delete(tt1)
         delete(tt2)
         delete(tta)
         delete(tts)
         delete(ttt)
         delete(tts0)
         delete(ts0_obs)
         delete(ts0_mod)
      end if

      delete(i51)
  
   else

      i50 = ind((slon.ge.min(rlon) .and. slon.le.max(rlon)) .and. (slat.ge.min(rlat) .and. slat.le.max(rlat)))

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
  
      delete(temp)

      if (dimsizes(i51).gt.1 .or. .not.ismissing(i51)) then

         nsit0 = dimsizes(i51)

         ts0_obs = new((/ntot, nsit0/), float)
         ts0_mod = new((/nmod, ntot, nsit0/), float)
         slat0   = new((/nsit0/), float)
         slon0   = new((/nsit0/), float)

         if (nsit0.eq.1) then
            ts0_obs(:,0)   = ts_obs(:,i50(i51))
            ts0_mod(:,:,0) = ts_mod(:,:,i50(i51))
            slat0(0)       = slat(i50(i51))
            slon0(0)       = slon(i50(i51))
         else
            ts0_obs(:,0:nsit0-1)   = ts_obs(:,i50(i51))
            ts0_mod(:,:,0:nsit0-1) = ts_mod(:,:,i50(i51))
            slat0(0:nsit0-1)       = slat(i50(i51))
            slon0(0:nsit0-1)       = slon(i50(i51))
         end if

         score=new((/nmod+1/), float)
         tt_mod=new((/nmod+1,nsit0/), float)

         score  = -999
         tt_mod = -999

         slon0=where(slon0.gt.180, slon0-360, slon0)

         tt0=new((/nsit0,ntot/), float)

         do nt=0,ntot-1
            tt0(:,nt)=ts0_obs(nt,:)
         end do

         tt0@_FillValue=-999

         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

         numb = where (numb.gt.1, numb, 0)

         at0=dim_avg(tt0)
         score(0)= -999
         tt_mod(0,:)=-999

         do nv=0, nmod-1
            if (runID(nv).gt.0) then

               tt1=new((/nsit0,ntot/), float)

               do nt=0,ntot-1
                  tt1(:,nt)=ts0_mod(nv,nt,:)
               end do

               tt1=where(ismissing(tt0), -999, tt1)

               tt1@_FillValue=-999

               at1=dim_avg(tt1)
               score(nv+1)=avg(at1) - avg(at0)
               tt_mod(nv+1,:)=at1 - at0

               delete(at1)
               delete(tt1)

            end if
         end do

         tt_mod!0="mod"
         tt_mod!1="site"

         score!0="mod"
         score&mod=fspan(1,nmod+1,nmod+1)

         score@_FillValue  = -999
         tt_mod@_FillValue = -999

         ; ++++++++++ Create a txt file and save results +++++++++++

         TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/bias/bias_" + str_lower(varID)    \
                       + "_" + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                       + "-" + sprinti("%0.4i",EndYear) + ".txt"

         print(TableFileName)

         header       = "Bias for " + str_upper(varID) + " (" + UnitTable + "): Model against " + Source + ", " + \
                         sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         write_table(TableFileName, "w", [/header/], "%s")
         write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
         write_table(TableFileName,"a",[/ModelNameList(0:nmod),score(0:nmod)/], "%16s %10.2f")

         ;print(asciiread(TableFileName,-1,"string"))

         ; ++++++++++ set up parameters for drawing +++++++++++

         DrawInfo = retrieve_DrawInfo (varID, "bias", Source)

         cnlevels = DrawInfo@cnlevels
         lblabels = DrawInfo@lblabels
         XLab     = DrawInfo@XLab
         YLab     = DrawInfo@YLab
         CLab     = DrawInfo@CLab

         MinLon   = min(rlon)
         MaxLon   = max(rlon)
         MinLat   = min(rlat)
         MaxLat   = max(rlat)

         if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
            MinLon   = DrawInfo@MinLon
            MaxLon   = DrawInfo@MaxLon
            MinLat   = DrawInfo@MinLat
            MaxLat   = DrawInfo@MaxLat
         end if

         XLab     = 1
         YLab     = 1

         ; ++++++++++ Draw global distribution of Bias +++++++++++
         do nv = 1, nmod
            if (runIDS(nv).gt.0) then

               PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/bias/bias_" + str_lower(varID)  \
                       + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                       + "-" + sprinti("%0.4i",EndYear)

               titles       = "Bias for " + str_upper(varID) + " (" + UnitPlots + "): " + ModelNameList(nv) + " against " + Source \
                       + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

               Draw_Map (PlotFileName, tt_mod(nv,:), slat0, slon0, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                         MinLon, MaxLon, MinLat, MaxLat, SiteID)

            end if
         end do

      end if

      delete(i50)
      delete(i51)
   end if


else

   score=new((/nmod+1/), float)
   tt_mod=new((/nmod+1,nyer/), float)

   score  = -999
   tt_mod = -999

   tt0=new((/nyer,nmon/), float)

      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      tt0(iy,im)=ts_obs(ijk)
      ijk=ijk+1
   end do
   end do

   tt0@_FillValue=-999

   numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

   numb = where (numb.gt.1, numb, 0)

   at0=dim_avg(tt0)

   ;if (any(str_lower(varID).eq.(/"burntarea", "nbp"/))) then
   ;   at0=dim_sum(tt0)
   ;end if

   score(0)=-999
   tt_mod(0,:)=at0

   do nv=0, nmod-1
   if (runID(nv).gt.0) then

      tt1=new((/nyer,nmon/), float)

         ijk=0
      do iy=0,nyer-1
      do im=0,nmon-1
         tt1(iy,im)=ts_mod(nv,ijk,0)
         ijk=ijk+1
      end do
      end do

      tt1=where(ismissing(tt0), -999, tt1)

      tt1@_FillValue=-999

      at1=dim_avg(tt1)

      ;if (any(str_lower(varID).eq.(/"burntarea", "nbp"/))) then
      ;   at1=dim_sum(tt1)
      ;end if

      score(nv+1)=avg(at1) - avg(at0)
      tt_mod(nv+1,:)=at1 - at0

      delete(at1)
      delete(tt1)

   end if
   end do

   score!0="mod"
   score&mod=fspan(1,nmod+1,nmod+1)

   tt_mod!0="mod"
   tt_mod!1="time"
   tt_mod&time=fspan(StartYear,EndYear,nyer)

   score@_FillValue  = -999
   tt_mod@_FillValue = -999

   ; ++++++++++ Create a txt file and save results +++++++++++

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/bias/bias_" + str_lower(varID)    \
                 + "_" + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                 + "-" + sprinti("%0.4i",EndYear) + ".txt"

    print(TableFileName)

    header       = "Bias for " + str_upper(varID) + " (" + UnitTable + "): Model against " + Source + ", " + \
                   sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

    write_table(TableFileName, "w", [/header/], "%s")
    write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
    write_table(TableFileName,"a",[/ModelNameList(0:nmod),score(0:nmod)/], "%16s %10.2f")

    ;print(asciiread(TableFileName,-1,"string"))

    ; ++++++++++ set up parameters for drawing +++++++++++

    DrawInfo = retrieve_DrawInfo (varID, "bias", Source)

    cnlevels = DrawInfo@cnlevels
    lblabels = DrawInfo@lblabels
    XLab     = DrawInfo@XLab
    YLab     = DrawInfo@YLab
    CLab     = DrawInfo@CLab

    MinLon   = DrawInfo@MinLon
    MaxLon   = DrawInfo@MaxLon
    MinLat   = DrawInfo@MinLat
    MaxLat   = DrawInfo@MaxLat

    XLab     = 1
    YLab     = 1

    ; ++++++++++ Draw global distribution of Bias +++++++++++

    PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/bias/bias_" + str_lower(varID) \
                 + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                 + "-" + sprinti("%0.4i",EndYear)

    titles       = "Bias for " + str_upper(varID) + " (" + UnitPlots + ")"

    Draw_Bar (PlotFileName, ModelNameList, score, tt_mod, tt_mod, titles, \
             XLab, YLab, CLab, MinLon, MaxLon, MinLat, MaxLat, "NoLine")

end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure GlobalBiasScore (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, Unit:string,\
                           ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                           SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

nmod=dimsizes(ModelNames)

MODELTYPE = getenv("MODELTYPE")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)      = 0
runIDS(1:nmod) = runID

ModelNameList(0)      = str_upper(Source)
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac
landm_mod = ts_mod@LandMask

RawMax_mod = ts_mod@RawMax
RawMin_mod = ts_mod@RawMin
RawAvg_mod = ts_mod@RawAvg

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

region    = where(landf_obs.gt.0,1,0)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

; ------- Choose data only in the selected sub-region ------------------------
i50 = ind(slon.ge.min(rlon) .and. slon.le.max(rlon))
j50 = ind(slat.ge.min(rlat) .and. slat.le.max(rlat))

nlon = dimsizes(i50)
nlat = dimsizes(j50)

ts0_obs    = ts_obs(:,j50,i50)
ts0_mod    = ts_mod(:,:,j50,i50)

landf0_obs = landf_obs(j50,i50)
landf0_mod = landf_mod(:,j50,i50)
landm0_mod = landm_mod(:,j50,i50)

area0_obs  = area_obs(j50,i50)
area0_mod  = area_mod(:,j50,i50)

region0    = region(j50,i50)

delete(i50)
delete(j50)

if (str_lower(varID).eq."sst") then
   region0=where(region0.eq.0, 1, 0)
else
   region0=where(region0.gt.0.5, 1, 0)
end if

; ------- Set Model Data as missing where the Benchmark is missing -----
score=new((/nmod+1/), float)

score = -999

if (str_lower(varID@SubGlobe).eq."yes") then
   ts0_obs=where(ts0_obs.le.0, -999, ts0_obs)
else
   do nt=0,ntot-1
      ts0_obs(nt,:,:) =where(region0.gt.0, ts0_obs(nt,:,:), -999)
   end do
end if

ts0_obs@_FillValue=-999

ts0_obs!0="time"
ts0_obs!1="lat"
ts0_obs!2="lon"

ts0_mod!0="model"
ts0_mod!1="time"
ts0_mod!2="lat"
ts0_mod!3="lon"

region1=dim_avg(ts0_obs(lat|:,lon|:,time|:))

region1=where(.not.ismissing(region1),1,0)

;if (str_lower(varID@CarbonYearly).eq."yes") then
;   region1=where(region1.gt.0,1,0)
;else
;   region1=where(.not.ismissing(region1),1,0)
;end if

tt0 = ts0_obs(lat|:, lon|:, time|:)

do nt=0,ntot-1
   tt0(:,:,nt) =where(region1.gt.0, tt0(:,:,nt), -999)
end do

tt0@_FillValue=-999

at0=dim_avg(tt0)

if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
   at0 = sqrt(dim_avg(tt0*tt0))
else
   at0 = dim_avg(tt0)
 end if

at0@_FillValue=-999

temp=tt0
temp=where(ismissing(temp), 0, 1)

numb=sum(temp)

delete(temp)

numb = where (numb.gt.1, numb, 0)

; ------- read CMIP5 model simulation -----
score=new((/nmod+1/), float)
tt_mod=new((/nmod+1,nlat,nlon/), float)

score =-999
tt_mod=-999

att = at0
delete(at0)

if (.not.ismissing(avg(tt0))) then

   do nv=0, nmod-1
   if (runID(nv).gt.0) then

      at0 = att

      area = area0_mod(nv,:,:)

      TempReg = region1
      TempReg = where(landm0_mod(nv,:,:).gt.0, TempReg, 0)

      landfOM = where(landf0_obs.gt.0.0 .and. landf0_mod(nv,:,:).gt.0.0, landf0_mod(nv,:,:), -999)
      landfOM = where(landm0_mod(nv,:,:).gt.0, landfOM, -999)

      landfOM@_FillValue=-999

      TempReg = landfOM
      TempReg@_FillValue=-999

      tt1 = ts0_mod(lat|:, lon|:, time|:, model|nv)

      if (str_lower(varID@SubGlobe).eq."yes") then
         tt1=where(ismissing(tt0), -999, tt1)
      end if

      tt1@_FillValue=-999

      if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
         at1 = sqrt(dim_avg(tt1*tt1))
      else
         at1 = dim_avg(tt1)
      end if

      at0=where(ismissing(landfOM), -999, at0)
      at1=where(ismissing(landfOM), -999, at1)

      at0@_FillValue=-999
      at1@_FillValue=-999

      ; -------convert unit from per cell area to per land area ------------------------
      ;if (str_lower(varID@LandOnly).eq."yes") then
      ;   at0 = at0/landfOM
      ;   at1 = at1/landfOM
      ;end if

      ;area = area*landfOM

      atObs = at0
      atObs@_FillValue=-999
      atObsM=sum(atObs*area*TempReg)/sum(area*TempReg)

      tmp=at0

      MinObs = min(atObs)
      if (MinObs.lt.0 .and. MinObs.ne.-999) then
         atObs1 = atObs-MinObs*varID@MinFC
      else
         atObs1 = atObs
      end if

      if (atObsM.eq.0) then
         tmp=-999
      else

         ;if (str_lower(varID@GSMLocalRefer).eq."yes") then
            ; +++++ Use local reference to calculate global bias score ++++
            atObs0 = atObs1
            atObs0 = where(atObs0.eq.0, -999, atObs0)
            atObs0@_FillValue = -999
            tmp = 1-abs((at1-at0)/atObs0)
            tmp = where(atObs1.eq.0, 0, tmp)
         ;else
         ;   ; +++++ Use global mean reference to calculate global bias score ++++
         ;   tmp = 1-abs((at1-at0)/atObsM)
         ;end if

      end if

      tmp@_FillValue = -999

      tmp = exp(tmp)/EE0

      ;tmp=where(tmp.le.0, 0, tmp)
      ;tmp=where(atObs.eq.0, -1, tmp)
      ;tmp=where(region1.le.0, -999, tmp)

      if (str_lower(varID@MassWeighting).eq."yes") then
         ; +++++ Calculate Global Mean Scores weighted by Mass ++++
         if (str_lower(varID@MassWeightingFC).eq."yes") then
            score(nv+1)=sum(tmp*atObs1*area*TempReg)/sum(atObs1*area*TempReg)
         else
            score(nv+1)=sum(tmp*abs(atObs)*area*TempReg)/sum(abs(atObs)*area*TempReg)
         end if
      else
         ; +++++ Calculate Global Mean Scores weighted by Area ++++
         score(nv+1)=sum(tmp*area*TempReg)/sum(area*TempReg)
      end if

      tt_mod(nv+1,:,:)=tmp

      delete(tmp)
      delete(tt1)
      delete(at0)
      delete(at1)
      delete(area)
      delete(atObs0)
      delete(atObs1)
      delete(landfOM)
      delete(TempReg)
   end if
   end do

   score@_FillValue = -999
   tt_mod@_FillValue = -999

   ; ++++++++++ set up parameters for drawing +++++++++++
   DrawInfo = retrieve_DrawInfo (varID, "globalbiasscore", Source)

   cnlevels = DrawInfo@cnlevels
   lblabels = DrawInfo@lblabels
   XLab     = DrawInfo@XLab
   YLab     = DrawInfo@YLab
   CLab     = DrawInfo@CLab

   MinLon   = min(rlon)
   MaxLon   = max(rlon)
   MinLat   = min(rlat)
   MaxLat   = max(rlat)

   if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
      MinLon   = DrawInfo@MinLon
      MaxLon   = DrawInfo@MaxLon
      MinLat   = DrawInfo@MinLat
      MaxLat   = DrawInfo@MaxLat
   end if

   XLab     = 1
   YLab     = 1

   ; ++++++++++ Create a txt file and save results +++++++++++

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/globalbiasscore/globalbiasscore_" \
                 + str_lower(varID) + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear)  \
                 + "-" + sprinti("%0.4i",EndYear) + ".txt"

   print(TableFileName)

   if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
      header       = "Global Bias Score (std dev) for " + str_upper(varID) + ": Model against " \
                   +  Source + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
   else
      header       = "Global Bias Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                      sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
   end if

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList(0:nmod),score/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   tt_mod!0="mod"
   tt_mod!1="lat"
   tt_mod!2="lon"
   tt_mod&lat=rlat
   tt_mod&lon=rlon
   tt_mod&lon@units="degrees_east"
   tt_mod&lat@units="degrees_north"

   ;----------- Draw Global Distribution of Bias Score -----------------------------------------

   do nv = 1, nmod
   if (runIDS(nv).gt.0) then

      PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/globalbiasscore/globalbiasscore_" \
                   + str_lower(varID) + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" \
                   + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

      if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
         titles       = "Global Bias Score (std dev) for " + str_upper(varID) + ": " + ModelNameList(nv) + " against " \
                      +  Source + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      else
         titles       = "Global Bias Score for " + str_upper(varID) + ": " + ModelNameList(nv) + " against " + Source \
                      + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      end if

      Draw_Map (PlotFileName, tt_mod(nv,:,:), rlat, rlon, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                MinLon, MaxLon, MinLat, MaxLat, SiteID)

   end if
   end do

   ;----------- Draw Global Mean Bias Score ----------------------------------------

   PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/globalbiasscore/globalbiasscore_" \
                + str_lower(varID) + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear)  \
                + "-" + sprinti("%0.4i",EndYear)

   titles       = "Global Bias Score for " + str_upper(varID) + " against " + str_upper(Source) + ", " + \
                   sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   Draw_Score (PlotFileName, score, ModelNameList, titles)
end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure GlobalBiasScore_site (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, Unit:string,\
                                ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                                SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

nsit=dimsizes(ind(slat.ne.-999))

MODELTYPE = getenv("MODELTYPE")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)      = 0
runIDS(1:nmod) = runID

ModelNameList(0)      = str_upper(Source)
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

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

if (str_lower(varID).eq."co2") then
   ts_obs = ts_obs - 285.
   ts_mod = ts_mod - 285.
end if

; ------- Choose data only in the selected sub-region ------------------------

if (SiteID@NAME.eq."SITES") then

   ts_obs!0="time"
   ts_obs!1="site"   

   if (any(str_lower(Source).eq.(/"noaa.gmd"/))) then

      temp = dim_avg(ts_obs(site|:,time|:)) 

      if (str_upper(MODELTYPE).eq."CLM") then
         i51 = ind(.not.ismissing(temp) .and. LandFracMod.eq.nmod)
      else
         i51 = ind(.not.ismissing(temp))
      end if
   
      delete(temp)

      if (dimsizes(i51).gt.1 .or. .not.ismissing(i51)) then

         nsit0 = dimsizes(i51)

         ts0_obs = new((/ntot, nsit0/), float)
         ts0_mod = new((/nmod, ntot, nsit0/), float)
         slat0   = new((/nsit0/), float)
         slon0   = new((/nsit0/), float)

         if (nsit0.eq.1) then
            ts0_obs(:,0)   = ts_obs(:,i51)
            ts0_mod(:,:,0) = ts_mod(:,:,i51)
            slat0(0)       = slat(i51)
            slon0(0)       = slon(i51)
         else
            ts0_obs(:,0:nsit0-1)   = ts_obs(:,i51)
            ts0_mod(:,:,0:nsit0-1) = ts_mod(:,:,i51)
            slat0(0:nsit0-1)       = slat(i51)
            slon0(0:nsit0-1)       = slon(i51)
         end if

         ts0_obs@_FillValue=-999
         ts0_mod@_FillValue=-999

         ; -------- read biome regions data ----------------

         SubRegName = retrieve_latlon_belt (Source, "zonalmean")

         nreg       = dimsizes(SubRegName)

         LatLon = SubRegName@LatLon

         MinLat = LatLon(0,:)
         MaxLat = LatLon(1,:)
         MinLon = LatLon(2,:)
         MaxLon = LatLon(3,:)

         ShortName = SubRegName
         LongName  = SubRegName@LongName

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

         score   = new((/nmod+1/), float)
         tts     = new((/nmod+1, nreg, ntot/), float)

         score = -999
         tts   = -999

         tts@_FillValue = -999

         slon0=where(slon0.gt.180, slon0-360, slon0)

         tt0=new((/nsit0,ntot/), float)

         do nt=0,ntot-1
            tt0(:,nt)=ts0_obs(nt,:)
         end do

         tt0@_FillValue=-999

         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

         numb = where(numb.gt.1, numb, 0)

         score(0) = avg(tt0)

         do nv=0, nmod-1
            if (runID(nv).gt.0) then

               tt1=new((/nsit0,ntot/), float)

               do nt=0,ntot-1
                  tt1(:,nt)=ts0_mod(nv,nt,:)
               end do

               tt1=where(ismissing(tt0), -999, tt1)

               tt1@_FillValue=-999

               reg0=new((/dimsizes(slat0)/), float)

               do nr = 1, nreg

                  j50 = ind((slat0.ge.MinLat(nr-1).and.slat0.le.MaxLat(nr-1)) .and. (slon0.ge.MinLon(nr-1).and.slon0.le.MaxLon(nr-1)))

                  if (dimsizes(j50).gt.1) then
                     tts(0,nr-1,:)      = dim_avg_n(tt0(j50,:), 0)
                     tts(nv+1,nr-1,:)   = dim_avg_n(tt1(j50,:), 0)
                  else
                     if (dimsizes(j50).eq.1 .and. .not.ismissing(j50)) then
                        tts(0,nr-1,:)      = (/tt0(j50,:)/)
                        tts(nv+1,nr-1,:)   = (/tt1(j50,:)/)
                     end if
                  end if

                  delete(j50)
               end do

               score(nv+1) = avg(tt1)

               delete(tt1)
               delete(reg0)
            end if
         end do

         tts@_FillValue = -999

         ; +++ Remove long-term trend from each time series +++
         tts0    = new((/nmod+1, nreg, ntot/), float)

         tts0    = -999 

         xx = fspan(1.,int2flt(nyer),ntot)
         nn = 3

         do nv = 0, nmod
         do ns = 0, nreg-1

            if (dimsizes(.not.ismissing(tts(nv,ns,:))).gt.3) then

               yy01 = tts(nv,ns,:)

               cc0  = lspoly(xx,yy01, 1, nn)
               yy02 = cc0(0) + cc0(1)*xx + cc0(2)*xx^2
               yy02 = yy01-yy02
               delete(cc0)

               tts0(nv,ns,:) = yy02

               delete(yy01)
               delete(yy02)
            end if

         end do
         end do

         ; +++ calculate annual cycle for each time series +++
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

         score=new((/nmod+1/), float)
         tt_mod=new((/nmod+1,nsit0/), float)

         score  = -999
         tt_mod = -999

         ts0_obs!0="time"
         ts0_obs!1="site"

         ts0_mod!0="model"
         ts0_mod!1="time"
         ts0_mod!2="site"

         tt0 = ts0_obs(site|:, time|:)

         tt0@_FillValue=-999

         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

         numb = where (numb.gt.1, numb, 0)

         atObs  = dim_avg(tt0)
         atObsM = dim_avg(atObs)

         atObs1  = atObs

         do nv=0, nmod-1
            if (runID(nv).gt.0) then

               tt1 = ts0_mod(site|:, time|:, model|nv)

               tt1=where(ismissing(tt0), -999, tt1)

               tt1@_FillValue=-999

               tmp=new((/nsit0/), float)
               tmp = -999

               do ns=0,nsit0-1
                  tmp0=tt0(ns,:)
                  tmp1=tt1(ns,:)
                  tmp0=where((.not.ismissing(tmp0) .and. .not.ismissing(tmp1)), tmp0, -999)
                  tmp1=where((.not.ismissing(tmp0) .and. .not.ismissing(tmp1)), tmp1, -999)
                  tmp0@_FillValue=-999
                  tmp1@_FillValue=-999
                  j50 = ind(.not.ismissing(tmp0))
                  if (dimsizes(j50).ge.2 .or. .not.ismissing(j50)) then
                     at0=dim_avg(tmp0(j50))
                     at1=dim_avg(tmp1(j50))
                     if (atObsM.eq.0) then
                        tmp(ns) = -999
                     else

                        ;if (str_lower(varID@GSMLocalRefer).eq."yes") then
                        ; +++++ Use local reference to calculate global bias score ++++
                        MinObs = min(atObs)
                        if (MinObs.le.0 .and. MinObs.ne.-999) then
                           atObs1(ns) = atObs(ns)-MinObs*varID@MinFC
                        else
                           atObs1(ns) = atObs(ns)
                        end if
                        atObs0 = atObs1(ns)
                        atObs0 = where(atObs0.eq.0, -999, atObs0)
                        atObs0@_FillValue = -999
                        tmp(ns) = 1-abs((at1-at0)/atObs0)
                        tmp(ns) = where(atObs1(ns).eq.0, 0, tmp(ns))
                        delete(atObs0)
                        ;else
                        ;   ; +++++ Use global mean reference to calculate global bias score ++++
                        ;   tmp(ns) = 1-abs((at1-at0)/atObsM)
                        ;end if

                     end if
                     delete(at0)
                     delete(at1)
                  end if
                  delete(j50)
                  delete(tmp0)
                  delete(tmp1)
               end do

               tmp@_FillValue=-999

               tmp = exp(tmp)/EE0

               if (str_lower(varID@MassWeighting).eq."yes") then
                  ; +++++ Calculate Global Mean Scores weighted by Mass ++++
                  if (str_lower(varID@MassWeightingFC).eq."yes") then
                     score(nv+1)=dim_sum(tmp*atObs1)/dim_sum(atObs1)
                  else
                     score(nv+1)=dim_sum(tmp*abs(atObs))/dim_sum(abs(atObs))
                  end if
               else
                  ; +++++ Calculate Global Mean Scores weighted by Area ++++
                  score(nv+1)=dim_avg(tmp)
               end if

               tt_mod(nv+1,:) = tmp

               delete(tt1)
               delete(tmp)
            end if
         end do

         tt_mod!0="mod"
         tt_mod!1="site"

         score@_FillValue=-999
         tt_mod@_FillValue = -999

         ; -------- read biome regions data ----------------

         SubRegName = retrieve_latlon_belt (Source, "zonalmean")

         nreg       = dimsizes(SubRegName)

         LatLon = SubRegName@LatLon

         MinLat = LatLon(0,:)
         MaxLat = LatLon(1,:)
         MinLon = LatLon(2,:)
         MaxLon = LatLon(3,:)

         cLats  = (MinLat+MaxLat)/2

         do ns =0, nreg-1
            if (cLats(ns).lt.0) then
               TmpStr1 = sprintf("%.0f",floor(abs(cLats(ns)))) + "S"
            else
               TmpStr1 = sprintf("%.0f",floor(cLats(ns))) + "N"
            end if

            LongName(ns)  = TmpStr1
         end do

         cLats@lblabels = LongName

         ;Times=fspan(0,int2flt(nmon+1),nmon+1)
         ;Times@lblabels = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","Jan"/)

         Times  = fspan(0.5,nmon-0.5,nmon)
         Times@lblabels = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

         DrawInfo = retrieve_DrawInfo (varID, "globalbiasscore", Source)

         cnlevels = DrawInfo@cnlevels
         lblabels = DrawInfo@lblabels
         XLab     = DrawInfo@XLab
         YLab     = DrawInfo@YLab
         CLab     = DrawInfo@CLab

         ; ++++++++++ Draw global distribution of Global Bias Score +++++++++++

         tt_mod@_FillValue = -999

         tt_mod!0="mod"
         tt_mod!1="lat"   
         tt_mod&lat=cLats
         tt_mod&mod=fspan(1,int2flt(nmod+1),nmod+1)

         PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/globalbiasscore/globalbiasscore_" + str_lower(varID) \
                      + "_cmip5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                      + "-" + sprinti("%0.4i",EndYear)

         titles = "Global Bias Score for " + str_upper(varID) + " (" + UnitPlots + "): CMIP5, " + \
                    sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         ;Draw_Table_Scores (PlotFileName, ModelNameList, runIDS, ttt_mod, cnlevels1, cnlevels2, lblabels1, lblabels2, \
         ;                   titles1, titles2, LongName)

         nmodels = fspan(1.,int2flt(nmod+1),nmod+1)

         Draw_LatLon_Time (PlotFileName, tt_mod, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                           nmodels, Times)

         delete(tta)
         delete(tts)
         delete(ttt)
         delete(tts0)
         delete(ts0_obs)
         delete(ts0_mod)
      end if

      delete(i51)
  
   else

      i50 = ind((slon.ge.min(rlon) .and. slon.le.max(rlon)) .and. (slat.ge.min(rlat) .and. slat.le.max(rlat)))

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
   
      delete(temp)

      if (dimsizes(i51).gt.1 .or. .not.ismissing(i51)) then

         nsit0 = dimsizes(i51)

         ts0_obs = new((/ntot, nsit0/), float)
         ts0_mod = new((/nmod, ntot, nsit0/), float)
         slat0   = new((/nsit0/), float)
         slon0   = new((/nsit0/), float)

         ;if (nsit0.eq.1) then
         ;   ts0_obs(:,0)   = ts_obs(:,i50(i51))
         ;   ts0_mod(:,:,0) = ts_mod(:,:,i50(i51))
         ;   slat0(0)       = slat(i50(i51))
         ;   slon0(0)       = slon(i50(i51))
         ;else
         ts0_obs(:,0:nsit0-1)   = ts_obs(:,i50(i51))
         ts0_mod(:,:,0:nsit0-1) = ts_mod(:,:,i50(i51))
         slat0(0:nsit0-1)       = slat(i50(i51))
         slon0(0:nsit0-1)       = slon(i50(i51))
         ;end if

         score=new((/nmod+1/), float)
         tt_mod=new((/nmod+1,nsit0/), float)

         score  = -999
         tt_mod = -999

         slon0=where(slon0.gt.180, slon0-360, slon0)

         ts0_obs!0="time"
         ts0_obs!1="site"

         ts0_mod!0="model"
         ts0_mod!1="time"
         ts0_mod!2="site"

         tt0 = ts0_obs(site|:, time|:)

         tt0@_FillValue=-999

         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

         numb = where (numb.gt.1, numb, 0)

         atObs  = dim_avg(tt0)
         atObsM = dim_avg(atObs)

         atObs1  = atObs

         do nv=0, nmod-1
            if (runID(nv).gt.0) then

               tt1 = ts0_mod(site|:, time|:, model|nv)

               tt1=where(ismissing(tt0), -999, tt1)

               tt1@_FillValue=-999

               tmp=new((/nsit0/), float)
               tmp = -999

               do ns=0,nsit0-1
                  tmp0=tt0(ns,:)
                  tmp1=tt1(ns,:)
                  tmp0=where((.not.ismissing(tmp0) .and. .not.ismissing(tmp1)), tmp0, -999)
                  tmp1=where((.not.ismissing(tmp0) .and. .not.ismissing(tmp1)), tmp1, -999)
                  tmp0@_FillValue=-999
                  tmp1@_FillValue=-999
                  j50 = ind(.not.ismissing(tmp0))
                  if (dimsizes(j50).ge.2 .or. .not.ismissing(j50)) then
                     at0=dim_avg(tmp0(j50))
                     at1=dim_avg(tmp1(j50))
                     if (atObsM.eq.0) then
                        tmp(ns) = -999
                     else

                        ;if (str_lower(varID@GSMLocalRefer).eq."yes") then
                        ; +++++ Use local reference to calculate global bias score ++++
                        MinObs = min(atObs)
                        if (MinObs.le.0 .and. MinObs.ne.-999) then
                           atObs1(ns) = atObs(ns)-MinObs*varID@MinFC
                        else
                           atObs1(ns) = atObs(ns)
                        end if
                        atObs0 = atObs1(ns)
                        atObs0 = where(atObs0.eq.0, -999, atObs0)
                        atObs0@_FillValue = -999
                        tmp(ns) = 1-abs((at1-at0)/atObs0)
                        tmp(ns) = where(atObs1(ns).eq.0, 0, tmp(ns))
                        delete(atObs0)
                        ;else
                        ;   ; +++++ Use global mean reference to calculate global bias score ++++
                        ;   tmp(ns) = 1-abs((at1-at0)/atObsM)
                        ;end if

                     end if
                     delete(at0)
                     delete(at1)
                  end if
                  delete(j50)
                  delete(tmp0)
                  delete(tmp1)
               end do

               tmp@_FillValue=-999

               tmp = exp(tmp)/EE0

               if (str_lower(varID@MassWeighting).eq."yes") then
                  ; +++++ Calculate Global Mean Scores weighted by Mass ++++
                  if (str_lower(varID@MassWeightingFC).eq."yes") then
                     score(nv+1)=dim_sum(tmp*atObs1)/dim_sum(atObs1)
                  else
                     score(nv+1)=dim_sum(tmp*abs(atObs))/dim_sum(abs(atObs))
                  end if
               else
                  ; +++++ Calculate Global Mean Scores weighted by Area ++++
                  score(nv+1)=dim_avg(tmp)
               end if

               tt_mod(nv+1,:) = tmp

               delete(tt1)
               delete(tmp)
            end if
         end do

         tt_mod!0="mod"
         tt_mod!1="site"

         score@_FillValue=-999
         tt_mod@_FillValue = -999

         score=where(ismissing(score), -999, score)

         ; ++++++++++ Create a txt file and save results +++++++++++

         TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/globalbiasscore/globalbiasscore_" \
                       + str_lower(varID) + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear)  \
                       + "-" + sprinti("%0.4i",EndYear) + ".txt"
   
         print(TableFileName)

         header      = "Global Bias Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                        sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         write_table(TableFileName, "w", [/header/], "%s")
         write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
         write_table(TableFileName,"a",[/ModelNameList(0:nmod),score/], "%16s %10.2f")
   
         ;print(asciiread(TableFileName,-1,"string"))

         ; ++++++++++ set up parameters for drawing +++++++++++

         DrawInfo = retrieve_DrawInfo (varID, "globalbiasscore", Source)

         cnlevels = DrawInfo@cnlevels
         lblabels = DrawInfo@lblabels
         XLab     = DrawInfo@XLab
         YLab     = DrawInfo@YLab
         CLab     = DrawInfo@CLab

         MinLon   = min(rlon)
         MaxLon   = max(rlon)
         MinLat   = min(rlat)
         MaxLat   = max(rlat)

        if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
           MinLon   = DrawInfo@MinLon
           MaxLon   = DrawInfo@MaxLon
           MinLat   = DrawInfo@MinLat
           MaxLat   = DrawInfo@MaxLat
        end if

        XLab     = 1
        YLab     = 1

        ;----------- Draw Global Distribution of Global Bias Score -----------------------------------------
        do nv = 0, nmod
           if (runIDS(nv).gt.0) then
 
              PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/globalbiasscore/globalbiasscore_" \
                           + str_lower(varID) + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" \
                           + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
 
              titles       = "Global Bias Score for " + str_upper(varID) + ": " + ModelNameList(nv) + ", " + \
                              sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
 
              Draw_Map (PlotFileName, tt_mod(nv,:), slat0, slon0, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                       MinLon, MaxLon, MinLat, MaxLat, SiteID)

           end if
        end do

        ;----------- Draw Global Mean Global Bias Score -----------------------------------------

        PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/globalbiasscore/globalbiasscore_" \
                     + str_lower(varID) + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear)  \
                     + "-" + sprinti("%0.4i",EndYear)
 
        titles       = "Global Bias Score for " + str_upper(varID) + " against " + str_upper(Source) + ", " + \
                        sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

        Draw_Score (PlotFileName, score, ModelNameList, titles)

     end if

      delete(i50)
      delete(i51)
   end if

else

   score=new((/nmod+1/), float)
   tt_mod=new((/nmod+1/), float)

   score  = -999
   tt_mod = -999

   tt0=ts_obs

   tt0@_FillValue=-999

   numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

   numb = where (numb.gt.1, numb, 0)

   if (any(str_lower(Source).eq.(/"gcp", "hoffman"/))) then

      tta = tt0

      do iy=1,nyer-1
         tta(iy) = tta(iy-1) + tta(iy)
      end do

      do iy=0,nyer-1
         tta(iy) = tta(iy) - tta(0)
      end do

      ;tt0=tta
      delete(tta)

      ;at0=tt0(nyer-1)

      at0   = dim_avg(tt0)

      atObs = sqrt(dim_avg(tt0*tt0))

      ;if (str_lower(Source).eq."hoffman") then
      ;   atObs = 60.
      ;else
      ;   atObs = 30.
      ;end if
   else
      at0   = dim_avg(tt0)
      atObs = dim_avg(tt0-285)
      ;atObs = at0
   end if

   do nv=0, nmod-1
   if (runID(nv).gt.0) then

      tt1=ts_mod(nv,:,0)

      tt1=where(ismissing(tt0), -999, tt1)

      tt1@_FillValue=-999

      if (any(str_lower(Source).eq.(/"gcp", "hoffman"/))) then

         tta = tt1

         do iy=1,nyer-1
            tta(iy) = tta(iy-1) + tta(iy)
         end do

         do iy=0,nyer-1
            tta(iy) = tta(iy) - tta(0)
         end do

         ;tt1=tta
         delete(tta)

         ;at1=tt1(nyer-1)

         at1=dim_avg(tt1)

      else
         at1=dim_avg(tt1)
      end if

      tt_mod(nv+1) = 1-abs((at1-at0)/atObs)

      tt_mod@_FillValue=-999

      ;tt_mod(nv+1) = where(tt_mod(nv+1).le.0, 0, tt_mod(nv+1))

      tt_mod(nv+1) = exp(tt_mod(nv+1))/EE0

      score(nv+1)=tt_mod(nv+1)

      delete(tt1)
   end if
   end do

   score!0="mod"
   score&mod=fspan(1,nmod+1,nmod+1)

   tt_mod!0="mod"
   tt_mod&mod=fspan(1,nmod+1,nmod+1)

   score@_FillValue=-999
   tt_mod@_FillValue=-999

   ; ++++++++++ Create a txt file and save results +++++++++++

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/globalbiasscore/globalbiasscore_" \
                 + str_lower(varID) + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear)  \
                 + "-" + sprinti("%0.4i",EndYear) + ".txt"
   
    print(TableFileName)

    header      = "Global Bias Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                  sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

    write_table(TableFileName, "w", [/header/], "%s")
    write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
    write_table(TableFileName,"a",[/ModelNameList(0:nmod),score/], "%16s %10.2f")
   
    ;print(asciiread(TableFileName,-1,"string"))

    ; ++++++++++ set up parameters for drawing +++++++++++

    DrawInfo = retrieve_DrawInfo (varID, "globalbiasscore", Source)

    cnlevels = DrawInfo@cnlevels
    lblabels = DrawInfo@lblabels
    XLab     = DrawInfo@XLab
    YLab     = DrawInfo@YLab
    CLab     = DrawInfo@CLab

    MinLon   = DrawInfo@MinLon
    MaxLon   = DrawInfo@MaxLon
    MinLat   = DrawInfo@MinLat
    MaxLat   = DrawInfo@MaxLat

    XLab     = 1
    YLab     = 1

    ;----------- Draw Global Distribution of Global Bias Score -----------------------------------------

    ;PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/globalbiasscore/globalbiasscore_" \
    ;             + str_lower(varID) + "_CMIP5.vs." + str_upper(Source) + "_" \
    ;             + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
    ;
    ;titles       = "Global Bias Score of " + str_upper(varID) + " for " + ModelNameList(nv) + " against " + str_upper(Source)
    ;
    ;Draw_Bar (PlotFileName, ModelNameList, score, tt_mod, tt_mod, titles, \
    ;         XLab, YLab, CLab, MinLon, MaxLon, MinLat, MaxLat, "NoLine")

    ;----------- Draw Global Mean Global Bias Score -----------------------------------------

    PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/globalbiasscore/globalbiasscore_" \
                 + str_lower(varID) + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear)  \
                 + "-" + sprinti("%0.4i",EndYear)
 
    titles       = "Global Bias Score for " + str_upper(varID) + " against " + str_upper(Source) + ", " + \
                    sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

    Draw_Score (PlotFileName, score, ModelNameList, titles)
end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure InterannualScore (DataDir:string, ModelNames:string, runID:integer, varID:string, Source:string, Unit:string, \
                            ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                            SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

MODELTYPE = getenv("MODELTYPE")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=0
runIDS(1:nmod)=runID

ModelNameList(0) = Source
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac
landm_mod = ts_mod@LandMask

RawMax_mod = ts_mod@RawMax
RawMin_mod = ts_mod@RawMin
RawAvg_mod = ts_mod@RawAvg

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

region    = where(landf_obs.gt.0,1,0)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

; ------- Choose data only in the selected sub-region ------------------------
i50 = ind(slon.ge.min(rlon) .and. slon.le.max(rlon))
j50 = ind(slat.ge.min(rlat) .and. slat.le.max(rlat))

nlon = dimsizes(i50)
nlat = dimsizes(j50)

ts0_obs    = ts_obs(:,j50,i50)
ts0_mod    = ts_mod(:,:,j50,i50)

landf0_obs = landf_obs(j50,i50)
landf0_mod = landf_mod(:,j50,i50)
landm0_mod = landm_mod(:,j50,i50)

area0_obs  = area_obs(j50,i50)
area0_mod  = area_mod(:,j50,i50)

region0    = region(j50,i50)

delete(i50)
delete(j50)

if (str_lower(varID).eq."sst") then
   region0=where(region0.eq.0, 1, 0)
else
   region0=where(region0.gt.0.5, 1, 0)
end if

; ------- Set Model Data as missing where the Benchmark is missing -----

if (str_lower(varID@SubGlobe).eq."yes") then
   ts0_obs=where(ts0_obs.le.0, -999, ts0_obs)
else
   do nt=0,ntot-1
      ts0_obs(nt,:,:) =where(region0.gt.0, ts0_obs(nt,:,:), -999)
   end do
end if

ts0_obs@_FillValue=-999

ts0_obs!0="time"
ts0_obs!1="lat"
ts0_obs!2="lon"

region1=dim_avg(ts0_obs(lat|:,lon|:,time|:))

region1=where(.not.ismissing(region1),1,0)

;if (str_lower(varID@CarbonYearly).eq."yes") then
;   region1=where(region1.gt.0,1,0)
;else
;   region1=where(.not.ismissing(region1),1,0)
;end if

tt0=new((/nlat,nlon,nyer,nmon/), float)

   ijk=0
do iy=0,nyer-1
do im=0,nmon-1
   tt0(:,:,iy,im) = ts0_obs(ijk,:,:)
   ijk=ijk+1
end do
end do

do iy=0,nyer-1
do im=0,nmon-1
   tt0(:,:,iy,im) = where(region1.gt.0, tt0(:,:,iy,im), -999)
end do
end do

tt0@_FillValue = -999

temp=tt0
temp=where(ismissing(temp), 0, 1)

numb=sum(temp)

delete(temp)

numb = where (numb.gt.1, numb, 0)

; ------- read CMIP5 model simulation -----
score=new((/nmod+1/), float)
tt_mod=new((/nmod+1,nlat,nlon/), float)

score =-999
tt_mod=-999

if (.not.ismissing(avg(tt0))) then
do nv=0, nmod-1
if (runID(nv).gt.0) then

   area = area0_mod(nv,:,:)

   TempReg = region1
   TempReg = where(landm0_mod(nv,:,:).gt.0, TempReg, 0)

   landfOM = where(landf0_obs.gt.0.0 .and. landf0_mod(nv,:,:).gt.0.0, landf0_mod(nv,:,:), -999)
   landfOM = where(landm0_mod(nv,:,:).gt.0, landfOM, -999)

   landfOM@_FillValue=-999

   TempReg = landfOM
   TempReg@_FillValue=-999

   tt1=new((/nlat,nlon,nyer,nmon/), float)

      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      tt1(:,:,iy,im)=ts0_mod(nv,ijk,:,:)
      ijk=ijk+1
   end do
   end do

   if (str_lower(varID@SubGlobe).eq."yes") then
      tt1=where(ismissing(tt0), -999, tt1)
   end if

   tt1@_FillValue = -999

   at0=dim_avg(tt0)
   at1=dim_avg(tt1)

   do iy=0,nyer-1
      at0(:,:,iy)=where(ismissing(landfOM), -999, at0(:,:,iy))
      at1(:,:,iy)=where(ismissing(landfOM), -999, at1(:,:,iy))
   end do

   at0@_FillValue=-999
   at1@_FillValue=-999

   ; -------convert unit from per cell area to per land area ------------------------
   ;if (str_lower(varID@LandOnly).eq."yes") then
   ;   do iy=0,nyer-1
   ;      at0(:,:,iy) = at0(:,:,iy)/landfOM
   ;      at1(:,:,iy) = at1(:,:,iy)/landfOM
   ;   end do
   ;end if

   ;area = area*landfOM

   atObs  = dim_avg(at0)
   stdev0 = dim_stddev(at0)
   stdev1 = dim_stddev(at1)

   stdevObs=stdev0
   ;stdev0=where(stdev0.eq.0, -999, stdev0)

   stdev0@_FillValue=-999
   stdev1@_FillValue=-999

   stdObsM=sum(stdevObs*area*TempReg)/sum(area*TempReg)

   tmp=stdev0
   if (stdObsM.eq.0) then
      tmp=-999
   else

      ;if (str_lower(varID@GSMLocalRefer).eq."yes") then
          ; +++++ Use local reference to calculate interannual score ++++
          stdevObs1 = stdevObs
          stdevObs1 = where(stdevObs1.eq.0, -999, stdevObs1)
          stdevObs1@_FillValue = -999
          tmp=1-abs((stdev1-stdev0)/stdevObs1)
          tmp = where(stdevObs.eq.0, 0, tmp)
          delete(stdevObs1)
      ;else
      ;   ; +++++ Use global mean reference to calculate interannual score ++++
      ;   tmp=1-abs((stdev1-stdev0)/stdObsM)
      ;end if


   end if

   tmp@_FillValue = -999

   tmp = exp(tmp)/EE0

   ;tmp = where(tmp.le.0, 0, tmp)
   ;;tmp = where(stdevObs.eq.0, 0, tmp)
   ;tmp = where(region1.le.0, -999, tmp)

   MinObs = min(atObs)
   if (MinObs.le.0 .and. MinObs.ne.-999) then
      atObs1 = atObs - MinObs*varID@MinFC
   else
      atObs1 = atObs
   end if

   if (str_lower(varID@MassWeighting).eq."yes") then
      ; +++++ Calculate Global Mean Scores weighted by Mass ++++
      if (str_lower(varID@MassWeightingFC).eq."yes") then
          score(nv+1)=sum(tmp*atObs1*area*TempReg)/sum(atObs1*area*TempReg)
      else
          score(nv+1)=sum(tmp*abs(atObs)*area*TempReg)/sum(abs(atObs)*area*TempReg)
      end if
   else
      ; +++++ Calculate Global Mean Scores weighted by Area ++++
      score(nv+1)=sum(tmp*area*TempReg)/sum(area*TempReg)
   end if

   tt_mod(nv+1,:,:)=tmp

   delete(at0)
   delete(at1)
   delete(tmp)
   delete(tt1)
   delete(area)
   delete(atObs)
   delete(atObs1)
   delete(landfOM)
   delete(stdev0)
   delete(stdev1)
   delete(stdevObs)
   delete(TempReg)
end if
end do

   score@_FillValue  = -999
   tt_mod@_FillValue = -999

   ; ++++++++++ set up parameters for drawing +++++++++++
   DrawInfo = retrieve_DrawInfo (varID, "interannualscore", Source)

   cnlevels = DrawInfo@cnlevels
   lblabels = DrawInfo@lblabels
   XLab     = DrawInfo@XLab
   YLab     = DrawInfo@YLab
   CLab     = DrawInfo@CLab

   MinLon   = min(rlon)
   MaxLon   = max(rlon)
   MinLat   = min(rlat)
   MaxLat   = max(rlat)

   if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
      MinLon   = DrawInfo@MinLon
      MaxLon   = DrawInfo@MaxLon
      MinLat   = DrawInfo@MinLat
      MaxLat   = DrawInfo@MaxLat
   end if

   XLab     = 1
   YLab     = 1

   ; ++++++++++ Create a txt file and save results +++++++++++

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/interannualscore/interannualscore_" \
                + str_lower(varID) + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                + "-" + sprinti("%0.4i",EndYear) + ".txt"

   print(TableFileName)

   header      = "Interannual Variability Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                 sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList,score/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   tt_mod!0="mod"
   tt_mod!1="lat"
   tt_mod!2="lon"
   tt_mod&lat=rlat
   tt_mod&lon=rlon
   tt_mod&lon@units="degrees_east"
   tt_mod&lat@units="degrees_north"

   ;----------- Draw Global Distribution of Interannual Variability Score -----------------------------------------

   do nv = 1, nmod
   if (runIDS(nv).gt.0) then

      PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/interannualscore/interannualscore_" \
                   + str_lower(varID) + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" \
                   + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

      titles       = "Interannual Variability Score for " + str_upper(varID) + ": " + ModelNameList(nv) + " against " + Source \
                   + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

      Draw_Map (PlotFileName, tt_mod(nv,:,:), rlat, rlon, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                MinLon, MaxLon, MinLat, MaxLat, SiteID)

   end if
   end do

   ;----------- Draw Global Mean Interannual Variability Score -----------------------------------------

   PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/interannualscore/interannualscore_" \
                + str_lower(varID) + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                + "-" + sprinti("%0.4i",EndYear)

   titles       = "Interannual Variability Score for " + str_upper(varID) + " against " + str_upper(Source) + ", " + \
                   sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   Draw_Score (PlotFileName, score, ModelNameList, titles)
end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure InterannualScore_site (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, Unit:string,\
                                 ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                                 SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

nsit=dimsizes(ind(slat.ne.-999))

MODELTYPE = getenv("MODELTYPE")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID

ModelNameList(0) = str_upper(Source)
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

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

if (nsit.gt.1) then

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

   nsit0 = dimsizes(i51)

   delete(temp)

if (nsit0.gt.1 .or. .not.ismissing(i51)) then

   ts0_obs = new((/ntot, nsit0/), float)
   ts0_mod = new((/nmod, ntot, nsit0/), float)
   slat0   = new((/nsit0/), float)
   slon0   = new((/nsit0/), float)

   if (nsit0.eq.1) then
      ts0_obs(:,0)   = ts_obs(:,i50(i51))
      ts0_mod(:,:,0) = ts_mod(:,:,i50(i51))
      slat0(0)       = slat(i50(i51))
      slon0(0)       = slon(i50(i51))
   else
      ts0_obs(:,0:nsit0-1)   = ts_obs(:,i50(i51))
      ts0_mod(:,:,0:nsit0-1) = ts_mod(:,:,i50(i51))
      slat0(0:nsit0-1)       = slat(i50(i51))
      slon0(0:nsit0-1)       = slon(i50(i51))
   end if

   score=new((/nmod+1/), float)
   tt_mod=new((/nmod+1,nsit0/), float)

   score  = -999
   tt_mod = -999

   slon0=where(slon0.gt.180, slon0-360, slon0)

   tt0=new((/nsit0,nyer,nmon/), float)

      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      tt0(:,iy,im)=ts0_obs(ijk,:)
      ijk=ijk+1
   end do
   end do

   tt0@_FillValue=-999

   numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

   numb = where (numb.gt.1, numb, 0)

   at0   = dim_avg(tt0)
   atObs = dim_avg(at0)

   stdObsM = dim_avg(dim_stddev(at0))

   MinObs = min(atObs)
   if (MinObs.le.0 .and. MinObs.ne.-999) then
      atObs1 = atObs - MinObs*varID@MinFC
   else
      atObs1 = atObs
   end if

   do nv=0, nmod-1
   if (runID(nv).gt.0) then

      tt1=new((/nsit0,nyer,nmon/), float)
      tmp=new((/nsit0/), float)

      tmp = -999
      tmp@_FillValue=-999

         ijk=0
      do iy=0,nyer-1
      do im=0,nmon-1
         tt1(:,iy,im)=ts0_mod(nv,ijk,:)
         ijk=ijk+1
      end do
      end do

      tt1=where(ismissing(tt0), -999, tt1)

      tt1@_FillValue=-999

      at1=dim_avg(tt1)

      do ns=0,nsit0-1
         tmp0=at0(ns,:)
         tmp1=at1(ns,:)
         tmp0=where((.not.ismissing(tmp0) .and. .not.ismissing(tmp1)), tmp0, -999)
         tmp1=where((.not.ismissing(tmp0) .and. .not.ismissing(tmp1)), tmp1, -999)
         j50 = ind(.not.ismissing(tmp0))
         if (dimsizes(j50).ge.2 .or. .not.ismissing(j50)) then
            ss0=dim_stddev(tmp0(j50))
            ss1=dim_stddev(tmp1(j50))
            as0=dim_avg(tmp0(j50))
            as1=dim_avg(tmp1(j50))
            if (stdObsM.eq.0) then
               tmp(ns)=-999
            else

               ;if (str_lower(varID@GSMLocalRefer).eq."yes") then
                  ; +++++ Use local reference to calculate interannual score ++++
                  stdevObs1 = ss0
                  stdevObs1 = where(stdevObs1.eq.0, -999, stdevObs1)
                  stdevObs1@_FillValue = -999
                  tmp(ns) = 1-abs((ss1-ss0)/stdevObs1)
                  tmp(ns) = where(ss0.eq.0, 0, tmp(ns))
                  delete(stdevObs1)
               ;else
               ;   ; +++++ Use global mean reference to calculate interannual score ++++
               ;   tmp(ns) = 1.0-abs((ss1-ss0)/stdObsM)
               ;end if

            end if
            delete(ss0)
            delete(ss1)
            delete(as0)
            delete(as1)
         end if
         delete(j50)
         delete(tmp0)
         delete(tmp1)
      end do

      ;tmp = where(tmp.le.0, 0, tmp)
      tmp = exp(tmp)/EE0

      tt_mod(nv+1, :) = tmp

      tt_mod@_FillValue=-999

      if (str_lower(varID@MassWeighting).eq."yes") then
         ; +++++ Calculate Global Mean Scores weighted by Mass ++++
         if (str_lower(varID@MassWeightingFC).eq."yes") then
            score(nv+1)=dim_sum(tmp*atObs1)/dim_sum(atObs1)
         else
            score(nv+1)=dim_sum(tmp*abs(atObs))/dim_sum(abs(atObs))
         end if
      else
         ; +++++ Calculate Global Mean Scores weighted by Area ++++
         score(nv+1)=dim_avg(tmp)
      end if

      delete(at1)
      delete(tt1)
      delete(tmp)
   end if
   end do

   tt_mod!0="mod"
   tt_mod!1="site"

   score@_FillValue = -999
   tt_mod@_FillValue = -999

   ; ++++++++++ Create a txt file and save results +++++++++++

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/interannualscore/interannualscore_" \
                 + str_lower(varID) + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                 + "-" + sprinti("%0.4i",EndYear) + ".txt"
   
   print(TableFileName)

   header      = "Interannual Variability Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                 sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList(0:nmod),score/], "%16s %10.2f")
   
   ;print(asciiread(TableFileName,-1,"string"))

   ; ++++++++++ set up parameters for drawing +++++++++++

   DrawInfo = retrieve_DrawInfo (varID, "interannualscore", Source)

   cnlevels = DrawInfo@cnlevels
   lblabels = DrawInfo@lblabels
   XLab     = DrawInfo@XLab
   YLab     = DrawInfo@YLab
   CLab     = DrawInfo@CLab

   MinLon   = min(rlon)
   MaxLon   = max(rlon)
   MinLat   = min(rlat)
   MaxLat   = max(rlat)

   if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
      MinLon   = DrawInfo@MinLon
      MaxLon   = DrawInfo@MaxLon
      MinLat   = DrawInfo@MinLat
      MaxLat   = DrawInfo@MaxLat
   end if

   XLab     = 1
   YLab     = 1

   ;----------- Draw Global Distribution of Interannual Variability Score -----------------------------------------

   do nv = 1, nmod
      if (runIDS(nv).gt.0) then

         PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/interannualscore/interannualscore_" \
                      + str_lower(varID) + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" \
                      + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         titles       = "Interannual Variability Score for " + str_upper(varID) + ": " + ModelNameList(nv) + " against " + Source \
                      + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         Draw_Map (PlotFileName, tt_mod(nv,:), slat0, slon0, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                   MinLon, MaxLon, MinLat, MaxLat, SiteID)

      end if
   end do

   ;----------- Draw Global Mean Interannual Variability Score -----------------------------------------

   PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/interannualscore/interannualscore_" \
                + str_lower(varID) + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                + "-" + sprinti("%0.4i",EndYear)

   titles       = "Interannual Variability Score for " + str_upper(varID) + " against " + str_upper(Source) + ", " + \
                  sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   Draw_Score (PlotFileName, score, ModelNameList, titles)
end if

else

   score=new((/nmod+1/), float)
   tt_mod=new((/nmod+1/), float)

   score  = -999
   tt_mod = -999

   tt0=new((/nyer,nmon/), float)

      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      tt0(iy,im)=ts_obs(ijk)
      ijk=ijk+1
   end do
   end do

   tt0@_FillValue=-999

   numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

   numb = where (numb.gt.1, numb, 0)

   at0=dim_avg(tt0)

   ;if (any(str_lower(varID).eq.(/"burntarea", "nbp"/))) then
   ;   at0=dim_sum(tt0)
   ;end if

   do nv=0, nmod-1
   if (runID(nv).gt.0) then

      tt1=new((/nyer,nmon/), float)

         ijk=0
      do iy=0,nyer-1
      do im=0,nmon-1
         tt1(iy,im)=ts_mod(nv,ijk,0)
         ijk=ijk+1
      end do
      end do

      tt1=where(ismissing(tt0), -999, tt1)

      tt1@_FillValue=-999

      at1=dim_avg(tt1)

      ;if (any(str_lower(varID).eq.(/"burntarea", "nbp"/))) then
      ;   at1=dim_sum(tt1)
      ;end if

      tmp0=at0
      tmp1=at1
      tmp0=where((.not.ismissing(tmp0) .and. .not.ismissing(tmp1)), tmp0, -999)
      tmp1=where((.not.ismissing(tmp0) .and. .not.ismissing(tmp1)), tmp1, -999)
      j50 = ind(.not.ismissing(tmp0))
      if (dimsizes(j50).ge.2 .or. .not.ismissing(j50)) then
         ss0=dim_stddev(tmp0(j50))
         ss1=dim_stddev(tmp1(j50))
         as0=dim_avg(tmp0(j50))
         as1=dim_avg(tmp1(j50))
         if (ss0.eq.0) then
            score(nv+1)=-999
         else
            score(nv+1)=1.0-abs((ss1-ss0)/ss0)
         end if
         ;score(nv+1)=where(score(nv+1).le.0, 0, score(nv+1))
         score(nv+1)=exp(score(nv+1))/EE0
         tt_mod(nv+1)=score(nv+1)
         delete(ss0)
         delete(ss1)
         delete(as0)
         delete(as1)
      end if
      delete(j50)
      delete(tmp0)
      delete(tmp1)

      tt_mod@_FillValue=-999

      delete(at1)
      delete(tt1)

   end if
   end do

   score!0="mod"
   score&mod=fspan(1,nmod+1,nmod+1)

   tt_mod!0="mod"
   tt_mod&mod=fspan(1,nmod+1,nmod+1)

   score@_FillValue = -999
   tt_mod@_FillValue = -999

   ; ++++++++++ Create a txt file and save results +++++++++++

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/interannualscore/interannualscore_" \
                 + str_lower(varID) + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                 + "-" + sprinti("%0.4i",EndYear) + ".txt"
   
   print(TableFileName)

   header      = "Interannual Variability Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                 sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList(0:nmod),score/], "%16s %10.2f")
   
   ;print(asciiread(TableFileName,-1,"string"))

   ; ++++++++++ set up parameters for drawing +++++++++++

   DrawInfo = retrieve_DrawInfo (varID, "interannualscore", Source)

   cnlevels = DrawInfo@cnlevels
   lblabels = DrawInfo@lblabels
   XLab     = DrawInfo@XLab
   YLab     = DrawInfo@YLab
   CLab     = DrawInfo@CLab

   MinLon   = DrawInfo@MinLon
   MaxLon   = DrawInfo@MaxLon
   MinLat   = DrawInfo@MinLat
   MaxLat   = DrawInfo@MaxLat

   XLab     = 1
   YLab     = 1

   ;----------- Draw Global Distribution of Interannual Variability Score -----------------------------------------

   ;PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/interannualscore/interannualscore_" + str_lower(varID) \
   ;             + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
   ;             + "-" + sprinti("%0.4i",EndYear)
   ; 
   ;titles      = "Interannual Variability Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
   ;              sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
   ;
   ;Draw_Bar (PlotFileName, ModelNameList, score, tt_mod, tt_mod, titles, \
   ;          XLab, YLab, CLab, MinLon, MaxLon, MinLat, MaxLat, "NoLine")

   ;----------- Draw Global Mean Interannual Variability Score -----------------------------------------

   PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/interannualscore/interannualscore_" \
                + str_lower(varID) + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                + "-" + sprinti("%0.4i",EndYear)

   titles       = "Interannual Score for " + str_upper(varID) + " against " + str_upper(Source) + ", " + \
                  sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   Draw_Score (PlotFileName, score, ModelNameList, titles)
end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure OverAllScore (ModelNames:string, runID:integer, varID:string, KeyWords:string, Source:string, StartYear:integer, EndYear:integer)

begin

DataDir = getenv("ILAMB_ROOT")

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

MODELTYPE = getenv("MODELTYPE")

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=0
runIDS(1:nmod)=runID

ModelNameList(0) = Source
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

KeyWords0 = KeyWords

; ++++ remove all keywords (metrics) not for overall score calculation ++++ 
i50 = ind(str_lower(KeyWords0).eq."overallscore")
i51 = ind(str_lower(KeyWords0).eq."annualmean")
i52 = ind(str_lower(KeyWords0).eq."bias")
i53 = ind(str_lower(KeyWords0).eq."phase")
i54 = ind(str_lower(KeyWords0).eq."rmse")
i55 = ind(str_lower(KeyWords0).eq."trend")

if (.not.ismissing(i50)) then
   KeyWords0(i50) = "-999"
end if

if (.not.ismissing(i51)) then
   KeyWords0(i51) = "-999"
end if

if (.not.ismissing(i52)) then
   KeyWords0(i52) = "-999"
end if

if (.not.ismissing(i53)) then
   KeyWords0(i53) = "-999"
end if

if (.not.ismissing(i54)) then
   KeyWords0(i54) = "-999"
end if

if (.not.ismissing(i55)) then
   KeyWords0(i55) = "-999"
end if

delete(i50)
delete(i51)
delete(i52)
delete(i53)
delete(i54)
delete(i55)

; +++++++ calculate overall score +++++++++++

k50 = ind(str_lower(KeyWords0).ne."-999")

if (dimsizes(k50).gt.1 .or. .not.ismissing(k50)) then

   ShortKeyNames = str_squeeze(KeyWords0(k50))
   ShortKeyNames = str_lower(ShortKeyNames)

   nkey = dimsizes(ShortKeyNames)

   LongKeyNames = new((/nkey/), string)
   wgts         = new((/nkey/), float)

   LongKeyNames = "N/A"
   wgts         = 0.

   score=new((/nmod+1/), float)
   wtt=new((/nmod+1/), float)

   score=0.0
   numb=0.0
   wtt=0.0

   ijk = 0
   do nk =0, nkey-1

      ; +++++++ read metric score from saved files +++++++++++
      FileName  = DataDir + "/OUTPUT/" + str_lower(varID) + "/" + ShortKeyNames(nk) + "/" + ShortKeyNames(nk) + "_" + str_lower(varID) \
                + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".txt"

      if (fileexists(FileName)) then
         print(FileName)

         ;print(asciiread(FileName,-1,"string"))

         LongKeyNames(ijk) = retrieve_LongName(ShortKeyNames(nk))

         wts               = retrieve_weight (ShortKeyNames(nk), "-999")
         wgts(ijk)         = wts

         data_1d = asciiread(FileName,-1,"string")
         numb0   = stringtofloat(str_get_field(data_1d(1), 2, ":"))
         score0  = stringtofloat(str_get_field(data_1d(2:), 2, " "))
         score0@_FillValue=-999
         i50 = ind(.not.ismissing(score0))
         if (dimsizes(i50).gt.1 .or. .not.ismissing(i50)) then
            score(i50)=score(i50)+score0(i50)*wts
            numb=numb+numb0
            wtt(i50)=wtt(i50)+wts
         end if
         ijk = ijk+1
         delete(i50)
         delete(numb0)
         delete(score0)
         delete(data_1d)
      end if
   end do

   if (any(wtt.gt.0)) then
      do nv=0, nmod
         if (wtt(nv).gt.0) then
            score(nv)=score(nv)/wtt(nv)
         else
            score(nv)=-999
         end if
      end do
   else
      score=-999
   end if

   score(0) = -999

if (ijk.gt.0) then

   ; ++++++++++ re-order the metrics from high to low using contributions +++++++++++

   ip = dim_pqsort(wgts(0:ijk-1), -1)

   wgts(0:ijk-1)         = wgts(ip)
   LongKeyNames(0:ijk-1) = LongKeyNames(ip)

   delete(ip)

   ; ++++++++++ set up parameters for drawing +++++++++++

   DrawInfo = retrieve_DrawInfo (varID, "overallscore", Source)

   cnlevels = DrawInfo@cnlevels
   lblabels = DrawInfo@lblabels

   ; ++++++++++ Create a txt file and save OverAll Score +++++++++++

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/overallscore/overallscore_" + str_lower(varID) \
                 + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".txt"

   print(TableFileName)

   header      = "Overall Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                 sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList,score/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   ; ++++++++++ Create a txt file and save Weighting for Overall Score +++++++++++

   ;wgts(0:ijk-1) = wgts(0:ijk-1)*100/sum(wgts(0:ijk-1))

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/overallscore/weights_" + str_lower(varID) + "_CMIP5.vs." \
                 + str_upper(Source) + ".txt"

   print(TableFileName)

   header = "Contributions from scoring metrics for Overall Score for the variable " + str_upper(varID) + " against " + str_upper(Source)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"KayeWords", "Weights"/], "%34s %16s")
   write_table(TableFileName,"a",[/LongKeyNames(0:ijk-1)+":",wgts(0:ijk-1)/], "%34s %16.0f")

   ;print(asciiread(TableFileName,-1,"string"))

   ;----------- Draw Overall Score -----------------------------------------

   PlotFileName = "../OUTPUT/" + str_lower(varID) + "/overallscore/overallscore_" + str_lower(varID) \
                + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   titles       = "Overallscore for " + str_upper(varID) + " against " + str_upper(Source) + ", " + \
                   sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   Draw_Score (PlotFileName, score, ModelNameList, titles)
end if
end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure PhaseScore (DataDir:string, ModelNames:string, runID:integer, varID:string, Source:string, Unit:string, \
                      ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                      SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

MODELTYPE = getenv("MODELTYPE")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID

ModelNameList(0) = Source
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac
landm_mod = ts_mod@LandMask

RawMax_mod = ts_mod@RawMax
RawMin_mod = ts_mod@RawMin
RawAvg_mod = ts_mod@RawAvg

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

region    = where(landf_obs.gt.0,1,0)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

; ------- Choose data only in the selected sub-region ------------------------
i50 = ind(slon.ge.min(rlon) .and. slon.le.max(rlon))
j50 = ind(slat.ge.min(rlat) .and. slat.le.max(rlat))

nlon = dimsizes(i50)
nlat = dimsizes(j50)

ts0_obs    = ts_obs(:,j50,i50)
ts0_mod    = ts_mod(:,:,j50,i50)

landf0_obs = landf_obs(j50,i50)
landf0_mod = landf_mod(:,j50,i50)
landm0_mod = landm_mod(:,j50,i50)

area0_obs  = area_obs(j50,i50)
area0_mod  = area_mod(:,j50,i50)

region0    = region(j50,i50)

delete(i50)
delete(j50)

if (str_lower(varID).eq."sst") then
   region0=where(region0.eq.0, 1, 0)
else
   region0=where(region0.gt.0.5, 1, 0)
end if

; ------- Set Model Data as missing where the Benchmark is missing -----

if (str_lower(varID@SubGlobe).eq."yes") then
   ts0_obs=where(ts0_obs.le.0, -999, ts0_obs)
else
   do nt=0,ntot-1
      ts0_obs(nt,:,:) =where(region0.gt.0, ts0_obs(nt,:,:), -999)
   end do
end if

ts0_obs@_FillValue=-999

ts0_obs!0="time"
ts0_obs!1="lat"
ts0_obs!2="lon"

region1=dim_avg(ts0_obs(lat|:,lon|:,time|:))

region1=where(.not.ismissing(region1),1,0)

;if (str_lower(varID@CarbonYearly).eq."yes") then
;   region1=where(region1.gt.0,1,0)
;else
;   region1=where(.not.ismissing(region1),1,0)
;end if

tt0=new((/nlat,nlon,nmon,nyer/), float)

   ijk=0
do iy=0,nyer-1
do im=0,nmon-1
   tt0(:,:,im,iy)=ts0_obs(ijk,:,:)
   ijk=ijk+1
end do
end do

do iy=0,nyer-1
do im=0,nmon-1
   tt0(:,:,im,iy) =where(region1.gt.0, tt0(:,:,im,iy), -999)
end do
end do

tt0@_FillValue=-999

temp=tt0
temp=where(ismissing(temp), 0, 1)

numb=sum(temp)

delete(temp)

numb = where (numb.gt.1, numb, 0)

; ------- read CMIP5 model simulation -----
score1=new((/nmod+1/), float)
score2=new((/nmod+1/), float)
tt1_mod=new((/nmod+1,nlat,nlon/), float)
tt2_mod=new((/nmod+1,nlat,nlon/), float)

mean0=new((/nlat,nlon/), float)

score1 =-999
score2 =-999
tt1_mod=-999
tt2_mod=-999

mean0=-999

if (.not.ismissing(avg(tt0))) then

   landfOM = where(landf0_obs.gt.0.0 .and. landf0_mod(0,:,:).gt.0.0, landf0_obs, -999)
   landfOM@_FillValue=-999

   at0=dim_avg(tt0)

   do im=0,nmon-1
      at0(:,:,im)=where(ismissing(landfOM), -999, at0(:,:,im))
   end do

   ; -------convert unit from per cell area to per land area ------------------------
   ;if (str_lower(varID@LandOnly).eq."yes") then
   ;   do im=0,nmon-1
   ;      at0(:,:,im) = at0(:,:,im)/landfOM
   ;   end do
   ;end if

   atObs=dim_avg(at0)

   MinObs = min(atObs)
   if (MinObs.le.0 .and. MinObs.ne.-999) then
      atObs1 = atObs - MinObs*varID@MinFC
   else
      atObs1 = atObs
   end if

   att=new((/nlat,nlon,nmon*3/), float)

   att(:,:,0:11)=at0
   att(:,:,12:23)=at0
   att(:,:,24:35)=at0

   ;att=runave(att,3,2)

   ;at0=att(:,:,12:23)

   do ny=0, nlat-1
   do nx=0, nlon-1
      if (ismissing(sum(at0(ny,nx,:)))) then
      else
         mean0(ny,nx)=int2flt(maxind(at0(ny,nx,:))+1)
      end if
   end do
   end do

   mean0=where(mean0.le.0, -999, mean0)
   mean0@_FillValue=-999

   angle0=new((/nlat,nlon/), float)

   angle0 = -999

   do ny=0, nlat-1
   do nx=0, nlon-1
      if (.not.ismissing(mean0(ny,nx))) then
         angle0(ny,nx)=360.0*mean0(ny,nx)/12.0
      end if
   end do
   end do

   angle0 = where (region1.le.0, -999, angle0)
   mean0  = where (region1.le.0, -999, mean0)

   angle0@_FillValue=-999

   score1(0)      = 0.0
   tt1_mod(0,:,:) = mean0

do nv=0, nmod-1
if (runID(nv).gt.0) then

   area = area0_mod(nv,:,:)

   TempReg = region1
   TempReg = where(landm0_mod(nv,:,:).gt.0, TempReg, 0)

   landfOM = where(landf0_obs.gt.0.0 .and. landf0_mod(nv,:,:).gt.0.0, landf0_mod(nv,:,:), -999)
   landfOM = where(landm0_mod(nv,:,:).gt.0, landfOM, -999)

   landfOM@_FillValue=-999

   TempReg = landfOM
   TempReg@_FillValue=-999

   tt1=new((/nlat,nlon,nmon,nyer/), float)

      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      tt1(:,:,im,iy)=ts0_mod(nv,ijk,:,:)
      ijk=ijk+1
   end do
   end do

   if (str_lower(varID@SubGlobe).eq."yes") then
      tt1=where(ismissing(tt0), -999, tt1)
   end if

   tt1@_FillValue=-999

   at1=dim_avg(tt1)

   do im=0,nmon-1
      at1(:,:,im)=where(ismissing(landfOM), -999, at1(:,:,im))
   end do

   ; -------convert unit from per cell area to per land area ------------------------
   ;if (str_lower(varID@LandOnly).eq."yes") then
   ;   do im=0,nmon-1
   ;      at1(:,:,im) = at1(:,:,im)/landfOM
   ;   end do
   ;end if

   ;area = area*landfOM

   att(:,:,0:11) =at1
   att(:,:,12:23)=at1
   att(:,:,24:35)=at1

   ;att=runave(att,3,2)

   ;at1=att(:,:,12:23)

   mean1=new((/nlat,nlon/), float)

   mean1=-999

   do ny=0, nlat-1
   do nx=0, nlon-1
      if (ismissing(sum(at1(ny,nx,:)))) then
      else
         mean1(ny,nx)=int2flt(maxind(at1(ny,nx,:))+1)
      end if
   end do
   end do

   mean1=where(mean1.le.0, -999, mean1)
   mean1@_FillValue=-999

   angle1=new((/nlat,nlon/), float)

   angle1 = -999

   do ny=0, nlat-1
   do nx=0, nlon-1
      if (.not.ismissing(mean1(ny,nx))) then
         angle1(ny,nx)=360.0*mean1(ny,nx)/12.0
      end if
   end do
   end do

   angle1 = angle1 - angle0

   angle1@_FillValue=-999

   mean0@_FillValue=-999
   mean1@_FillValue=-999

   mean1=mean1-mean0

   angle1=where(angle1.gt.180,  angle1-360, angle1)
   angle1=where(angle1.lt.-180, angle1+360, angle1)

   angle1 = angle1*RR0

   mean1=where(mean1.gt.6,  mean1-12, mean1)
   mean1=where(mean1.lt.-6, mean1+12, mean1)

   angle1 = where (TempReg.le.0, -999, angle1)
   mean1  = where (TempReg.le.0, -999, mean1)

   tt1_mod(nv+1,:,:) = mean1
   tt2_mod(nv+1,:,:) = (1+cos(angle1))/2

   if (str_lower(varID@MassWeighting).eq."yes") then
      ; +++++ Calculate Global Mean Scores weighted by Mass ++++
      if (str_lower(varID@MassWeightingFC).eq."yes") then
         score1(nv+1)=sum(mean1*atObs1*area*TempReg)/sum(atObs1*area*TempReg)
         score2(nv+1)=(1+sum(cos(angle1)*atObs1*area*TempReg)/sum(atObs1*area*TempReg))/2
      else
         score1(nv+1)=sum(mean1*abs(atObs)*area*TempReg)/sum(abs(atObs)*area*TempReg)
         score2(nv+1)=(1+sum(cos(angle1)*abs(atObs)*area*TempReg)/sum(abs(atObs)*area*TempReg))/2
      end if
   else
      ; +++++ Calculate Global Mean Scores weighted by Area ++++
      score1(nv+1)=sum(mean1*area*TempReg)/sum(area*TempReg)
      score2(nv+1)=(1+sum(cos(angle1)*area*TempReg)/sum(area*TempReg))/2
   end if

   delete(at1)
   delete(tt1)
   delete(area)
   delete(mean1)
   delete(angle1)
   delete(landfOM)
   delete(TempReg)
end if
end do

   score1@_FillValue  = -999
   score2@_FillValue  = -999
   tt1_mod@_FillValue = -999
   tt2_mod@_FillValue = -999

   ; ++++++++++ set up parameters for drawing +++++++++++

   DrawInfo = retrieve_DrawInfo (varID, "phasescore", Source)

   cnlevels = DrawInfo@cnlevels
   lblabels = DrawInfo@lblabels
   XLab     = DrawInfo@XLab
   YLab     = DrawInfo@YLab
   CLab     = DrawInfo@CLab

   MinLon   = min(rlon)
   MaxLon   = max(rlon)
   MinLat   = min(rlat)
   MaxLat   = max(rlat)

   if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
      MinLon   = DrawInfo@MinLon
      MaxLon   = DrawInfo@MaxLon
      MinLat   = DrawInfo@MinLat
      MaxLat   = DrawInfo@MaxLat
   end if

   CLab     = 1
   XLab     = 1
   YLab     = 1

   ; ++++++++++ Create a txt file and save results +++++++++++

   ; ++++++++++ Save global mean Phase Difference +++++++++++
   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phase/phase_" + str_lower(varID) \
                 + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                 + sprinti("%0.4i",EndYear) + ".txt"

   print(TableFileName)

   header      = "Phase Change (months) for " + str_upper(varID) + ": Model against " + Source + ", " + \
                 sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList,score1/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   ; ++++++++++ Save global mean Phase Scores +++++++++++
   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phasescore/phasescore_" + str_lower(varID) \
                 + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                 + sprinti("%0.4i",EndYear) + ".txt"

   print(TableFileName)

   header      = "Seasonal Cycle Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                 sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList,score2/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   tt1_mod!0="mod"
   tt1_mod!1="lat"
   tt1_mod!2="lon"
   tt1_mod&lat=rlat
   tt1_mod&lon=rlon
   tt1_mod&lon@units="degrees_east"
   tt1_mod&lat@units="degrees_north"

   tt2_mod!0="mod"
   tt2_mod!1="lat"
   tt2_mod!2="lon"
   tt2_mod&lat=rlat
   tt2_mod&lon=rlon
   tt2_mod&lon@units="degrees_east"
   tt2_mod&lat@units="degrees_north"

   ; ++++++++++ Draw global distribution of Phase Difference +++++++++++

   do nv = 0, nmod
   if (runIDS(nv).gt.0) then

      ; ++++++++++ Draw global distribution of Phase Difference +++++++++++
      PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phase/phase_" + str_lower(varID)  \ 
                   + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \ 
                   + "-" + sprinti("%0.4i",EndYear)

      if (nv.eq.0) then
         delete(cnlevels)
         delete(lblabels)
         cnlevels     = (/1.,2.,3.,4.,5.,6.,7.,8.,9.,10.,11.,12./)
         lblabels     = (/"n/a","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
         titles       = "Peak month for " + str_upper(varID) + ": " + ModelNameList(nv) + ", " + \
                         sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      else
         delete(cnlevels)
         delete(lblabels)
         cnlevels  = (/-5.5,-4.5,-3.5,-2.5,-1.5,-0.5,0.5,1.5,2.5,3.5,4.5,5.5/)
         lblabels  = (/"-6","-5","-4","-3","-2","-1","0","1","2","3","4","5","6"/)

         titles       = "Difference of peak month for " + str_upper(varID) + ": " + ModelNameList(nv) + " against " + Source \
                      + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      end if

      Draw_Map (PlotFileName, tt1_mod(nv,:,:), rlat, rlon, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                MinLon, MaxLon, MinLat, MaxLat, SiteID)


      ; ++++++++++ Draw global distribution of Phase Scores +++++++++++
      PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phasescore/phasescore_" + str_lower(varID)  \ 
                   + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \ 
                   + "-" + sprinti("%0.4i",EndYear)

      if (nv.gt.0) then
         delete(cnlevels)
         delete(lblabels)
         cnlevels     = DrawInfo@cnlevels
         lblabels     = DrawInfo@lblabels

         titles       = "Seasonal Cycle Score for " + str_upper(varID) + ": " + ModelNameList(nv) + " against " + Source \
                      + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         Draw_Map (PlotFileName, tt2_mod(nv,:,:), rlat, rlon, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                   MinLon, MaxLon, MinLat, MaxLat, SiteID)
      end if

   end if
   end do

   ;----------- Draw Global Mean Seasonal Cycle Score -----------------------------------------

   PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phasescore/phasescore_" + str_lower(varID) \
                + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   titles       = "Seasonal Cycle Score for " + str_lower(varID) + " against " + str_upper(Source) + ", " + \
                  sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   Draw_Score (PlotFileName, score2, ModelNameList, titles)
end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure PhaseScore_site (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, Unit:string,\
                           ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                           SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

nsit=dimsizes(ind(slat.ne.-999))

MODELTYPE = getenv("MODELTYPE")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID

ModelNameList(0) = Source
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

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

if (SiteID@NAME.eq."SITES") then

   ts_obs!0="time"
   ts_obs!1="site"   

   if (any(str_lower(Source).eq.(/"noaa.gmd"/))) then

      temp = dim_avg(ts_obs(site|:,time|:)) 

      if (str_upper(MODELTYPE).eq."CLM") then
         i51 = ind(.not.ismissing(temp) .and. LandFracMod.eq.nmod)
      else
         i51 = ind(.not.ismissing(temp))
      end if
   
      delete(temp)

      if (dimsizes(i51).gt.1 .or. .not.ismissing(i51)) then

         nsit0 = dimsizes(i51)

         ts0_obs = new((/ntot, nsit0/), float)
         ts0_mod = new((/nmod, ntot, nsit0/), float)
         slat0   = new((/nsit0/), float)
         slon0   = new((/nsit0/), float)

         if (nsit0.eq.1) then
            ts0_obs(:,0)   = ts_obs(:,i51)
            ts0_mod(:,:,0) = ts_mod(:,:,i51)
            slat0(0)       = slat(i51)
            slon0(0)       = slon(i51)
         else
            ts0_obs(:,0:nsit0-1)   = ts_obs(:,i51)
            ts0_mod(:,:,0:nsit0-1) = ts_mod(:,:,i51)
            slat0(0:nsit0-1)       = slat(i51)
            slon0(0:nsit0-1)       = slon(i51)
         end if

         ts0_obs@_FillValue=-999
         ts0_mod@_FillValue=-999

         ; -------- read biome regions data ----------------

         SubRegName = retrieve_latlon_belt (Source, "zonalmean")

         nreg       = dimsizes(SubRegName)

         LatLon = SubRegName@LatLon

         MinLat = LatLon(0,:)
         MaxLat = LatLon(1,:)
         MinLon = LatLon(2,:)
         MaxLon = LatLon(3,:)

         ShortName = SubRegName
         LongName  = SubRegName@LongName

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

         tts     = new((/nmod+1, nreg, ntot/), float)

         tts   = -999

         tts@_FillValue = -999

         slon0=where(slon0.gt.180, slon0-360, slon0)

         tt0=new((/nsit0,ntot/), float)

         do nt=0,ntot-1
            tt0(:,nt)=ts0_obs(nt,:)
         end do

         tt0@_FillValue=-999

         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

         numb = where(numb.gt.1, numb, 0)

         do nv=0, nmod-1
            if (runID(nv).gt.0) then

               tt1=new((/nsit0,ntot/), float)

               do nt=0,ntot-1
                  tt1(:,nt)=ts0_mod(nv,nt,:)
               end do

               tt1=where(ismissing(tt0), -999, tt1)

               tt1@_FillValue=-999

               reg0=new((/dimsizes(slat0)/), float)

               do nr = 1, nreg

                  j50 = ind((slat0.ge.MinLat(nr-1).and.slat0.le.MaxLat(nr-1)) .and. (slon0.ge.MinLon(nr-1).and.slon0.le.MaxLon(nr-1)))

                  if (dimsizes(j50).gt.1) then
                     tts(0,nr-1,:)      = dim_avg_n(tt0(j50,:), 0)
                     tts(nv+1,nr-1,:)   = dim_avg_n(tt1(j50,:), 0)
                  else
                     if (dimsizes(j50).eq.1 .and. .not.ismissing(j50)) then
                        tts(0,nr-1,:)   = (/tt0(j50, :)/)
                        tts(nv+1,nr-1,:)= (/tt1(j50, :)/)
                     end if
                  end if

                  delete(j50)
               end do

               delete(tt1)
               delete(reg0)
            end if
         end do

         tts@_FillValue = -999

         ; +++ Remove long-term trend from each time series +++
         tts0    = new((/nmod+1, nreg, ntot/), float)

         tts0    = -999 

         xx = fspan(1.,int2flt(nyer),ntot)
         nn = 3

         do nv = 0, nmod
         do ns = 0, nreg-1

            if (dimsizes(.not.ismissing(tts(nv,ns,:))).gt.3) then

               yy01 = tts(nv,ns,:)

               cc0  = lspoly(xx,yy01, 1, nn)
               yy02 = cc0(0) + cc0(1)*xx + cc0(2)*xx^2
               yy02 = yy01-yy02
               delete(cc0)

               tts0(nv,ns,:) = yy02

               delete(yy01)
               delete(yy02)
            end if

         end do
         end do

         ; +++ calculate annual cycle for each time series +++
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

         ; ------- Calculate phase shift and phase scores for each model -----
         score1=new((/nmod+1/), float)
         score2=new((/nmod+1/), float)
         tt1_mod=new((/nmod+1,nreg/), float)
         tt2_mod=new((/nmod+1,nreg/), float)
      
         mean0=new((/nreg/), float)
      
         mean0   = -999
         score1  = -999
         score2  = -999
         tt1_mod = -999
         tt2_mod = -999
      
         at0  = tta(0,:,:)
      
         at0@_FillValue=-999
      
         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(at0)))))
      
         numb = where (numb.gt.1, numb, 0)
      
         atObs=dim_avg(at0)
      
         MinObs = min(atObs)
         if (MinObs.le.0 .and. MinObs.ne.-999) then
            atObs1 = atObs - MinObs*varID@MinFC
         else
            atObs1 = atObs
         end if
      
         att=new((/nreg,nmon*3/), float)
      
         att(:,0:11)=at0
         att(:,12:23)=at0
         att(:,24:35)=at0
      
         ;att=runave(att,3,2)
      
         ;at0=att(:,12:23)
      
         do ns=0, nreg-1
            if (ismissing(sum(at0(ns,:)))) then
            else
               mean0(ns)=maxind(at0(ns,:))+1
            end if
         end do
      
         mean0=where(mean0.le.0, -999, mean0)
         mean0@_FillValue=-999
      
         angle0=new((/nreg/), float)
      
         angle0 = -999
      
         do ns=0, nreg-1
            if (.not.ismissing(mean0(ns))) then
               angle0(ns)=360.0*mean0(ns)/12.0
            end if
         end do
      
         score1(0)    = 0.0
         tt1_mod(0,:) = mean0
      
         angle0@_FillValue=-999
      
         do nv=1, nmod
         if (runIDS(nv).gt.0) then
      
            mean1=new((/nreg/), float)
      
            at1 = tta(nv,:,:)
      
            att(:,0:11) =at1
            att(:,12:23)=at1
            att(:,24:35)=at1
      
            ;att=runave(att,3,2)
      
            ;at1=att(:,12:23)
      
            mean1=new((/nreg/), float)
      
            do ns=0, nreg-1
               if (ismissing(sum(at1(ns,:)))) then
               else
                  mean1(ns)=maxind(at1(ns,:))+1
               end if
            end do
      
            mean1=where(mean1.le.0, -999, mean1)
            mean1@_FillValue=-999
      
            angle1=new((/nreg/), float)
      
            angle1 = -999
      
            do ns=0, nreg-1
               if (.not.ismissing(mean1(ns))) then
                  angle1(ns)=360.0*mean1(ns)/12.0
               end if
            end do
      
            angle1 = angle1 - angle0
      
            angle1@_FillValue=-999
      
            ;mean1=mean1-mean0
      
            mean1@_FillValue=-999
      
            angle1=where(angle1.gt.180,  angle1-360, angle1)
            angle1=where(angle1.lt.-180, angle1+360, angle1)
      
            angle1 = angle1*RR0
      
            ;mean1 = where(mean1.gt.6,  mean1-12, mean1)
            ;mean1 = where(mean1.lt.-6, mean1+12, mean1)
      
            ;mean1 = where(mean0.gt.0, mean1, -999)
      
            mean1@_FillValue=-999
      
            if (str_lower(varID@MassWeighting).eq."yes") then
               ; +++++ Calculate Global Mean Scores weighted by Mass ++++
               if (str_lower(varID@MassWeightingFC).eq."yes") then
                  score1(nv)=sum(mean1*atObs1)/sum(atObs1)
                  score2(nv)=(1+sum(cos(angle1)*atObs1)/sum(atObs1))/2
               else
                  score1(nv)=sum(mean1*abs(atObs))/sum(abs(atObs))
                  score2(nv)=(1+sum(cos(angle1)*abs(atObs))/sum(abs(atObs)))/2
               end if
            else
               ; +++++ Calculate Global Mean Scores weighted by Area ++++
               score1(nv)=avg(mean1)
               score2(nv)=(1+avg(cos(angle1)))/2
            end if
      
            tt1_mod(nv,:) = mean1
            tt2_mod(nv,:) = (1+cos(angle1))/2
      
            delete(at1)
            delete(mean1)
            delete(angle1)
         end if
         end do
      
         score1@_FillValue=-999
         score2@_FillValue=-999
         tt1_mod@_FillValue = -999
         tt2_mod@_FillValue = -999

         ; ++++++++++ Create a txt file and save results +++++++++++

         ; ++++++++++ Save global mean Phase Difference +++++++++++
         TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phase/phase_" + str_lower(varID) \
                       + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                       + sprinti("%0.4i",EndYear) + ".txt"

         print(TableFileName)

         header      = "Phase Change (months) for " + str_upper(varID) + ": Model against " + Source + ", " + \
                       sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         write_table(TableFileName, "w", [/header/], "%s")
         write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
         write_table(TableFileName,"a",[/ModelNameList,score1/], "%16s %10.2f")

         ;print(asciiread(TableFileName,-1,"string"))

         ; ++++++++++ Save global mean Phase Scores +++++++++++
         TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phasescore/phasescore_" + str_lower(varID) \
                       + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                       + sprinti("%0.4i",EndYear) + ".txt"

         print(TableFileName)

         header      = "Seasonal Cycle Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                       sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         write_table(TableFileName, "w", [/header/], "%s")
         write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
         write_table(TableFileName,"a",[/ModelNameList,score2/], "%16s %10.2f")

         ;print(asciiread(TableFileName,-1,"string"))

         ; ++++++++++ set up parameters for drawing +++++++++++

         DrawInfo = retrieve_DrawInfo (varID, "phasescore", Source)

         ;cnlevels = DrawInfo@cnlevels
         ;lblabels = DrawInfo@lblabels
         XLab     = DrawInfo@XLab
         YLab     = DrawInfo@YLab
         CLab     = DrawInfo@CLab

         SubRegName = retrieve_latlon_belt (Source, "zonalmean")

         nreg       = dimsizes(SubRegName)

         LatLon = SubRegName@LatLon

         MinLat = LatLon(0,:)
         MaxLat = LatLon(1,:)
         MinLon = LatLon(2,:)
         MaxLon = LatLon(3,:)

         cLats  = (MinLat+MaxLat)/2

         do ns =0, nreg-1
            if (cLats(ns).lt.0) then
               TmpStr1 = sprintf("%.0f",floor(abs(cLats(ns)))) + "S"
            else
               TmpStr1 = sprintf("%.0f",floor(cLats(ns))) + "N"
            end if

            LongName(ns)  = TmpStr1
         end do

         cLats@lblabels = LongName

         nmodels = fspan(1.,int2flt(nmod+1),nmod+1)
         nmodels@lblabels = ModelNameList(::-1)

         tt1_mod = tt1_mod(::-1,:)
         tt2_mod = tt2_mod(::-1,:)

         ;if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
         ;   MinLon   = DrawInfo@MinLon
         ;   MaxLon   = DrawInfo@MaxLon
         ;   MinLat   = DrawInfo@MinLat
         ;   MaxLat   = DrawInfo@MaxLat
         ;end if

         tt1_mod@_FillValue = -999
         tt2_mod@_FillValue = -999

         tt1_mod!0="mod"
         tt1_mod!1="lat"   
         tt1_mod&lat=cLats
         tt1_mod&lat@units="degrees_north"
         tt1_mod&mod=nmodels

         tt2_mod!0="mod"
         tt2_mod!1="lat"   
         tt2_mod&lat=cLats
         tt2_mod&lat@units="degrees_north"
         tt2_mod&mod=nmodels

         ; ++++++++++ Draw global distribution of Phase Difference +++++++++++
         PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phase/phase_" + str_lower(varID)  \
                      + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                      + "-" + sprinti("%0.4i",EndYear)

         cnlevels    = (/1.,2.,3.,4.,5.,6.,7.,8.,9.,10.,11.,12./)
         lblabels    = (/"n/a","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
         titles      = "Peak month for " + str_upper(varID) + ": CMIP5, " + \
                               sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         ;cnlevels     = (/-6.,-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5.,6./)
         ;lblabels     = (/"n/a","-6","-5","-4","-3","-2","-1","0","1","2","3","4","5","6"/)

         ;titles       = "Difference of peak month for " + str_upper(varID) + ", " \
         ;             + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         ;Draw_Table_Scores (PlotFileName, ModelNameList, runIDS, ttt_mod, cnlevels1, cnlevels2, lblabels1, lblabels2, \
         ;                   titles1, titles2, LongName)

         Draw_LatLon_Time (PlotFileName, tt1_mod, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                           nmodels, cLats)

         ; ++++++++++ Draw global distribution of Seasonal Cycle Scores +++++++++++
         PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phasescore/phasescore_" + str_lower(varID)  \
                      + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                      + "-" + sprinti("%0.4i",EndYear)

         delete(cnlevels)
         delete(lblabels)

         cnlevels     = DrawInfo@cnlevels
         lblabels     = DrawInfo@lblabels

         titles       = "Seasonal Cycle Score for " + str_upper(varID) + ", " \
                      + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         ;Draw_Table_Scores (PlotFileName, ModelNameList, runIDS, ttt_mod, cnlevels1, cnlevels2, lblabels1, lblabels2, \
         ;                   titles1, titles2, LongName)

         Draw_LatLon_Time (PlotFileName, tt2_mod, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                           nmodels, cLats)

         ;----------- Draw Global Mean Seasonal Cycle Score -----------------------------------------

         ;PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phasescore/phasescore_" + str_lower(varID) \
         ;             + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
         ;
         ;titles       = "Seasonal Cycle Score for " + str_upper(varID) + " against " + str_upper(Source) + ", " + \
         ;                sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
         ;
         ;Draw_Score (PlotFileName, score2, ModelNameList, titles)

         delete(tta)
         delete(tts)
         delete(ttt)
         delete(tts0)
         delete(ts0_obs)
         delete(ts0_mod)
      end if

      delete(i51)
  
   else

      i50 = ind((slon.ge.min(rlon) .and. slon.le.max(rlon)) .and. (slat.ge.min(rlat) .and. slat.le.max(rlat)))

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
   
      delete(temp)

      if (dimsizes(i51).gt.1 .or. .not.ismissing(i51)) then
      
         nsit0 = dimsizes(i51)
      
         ts0_obs = new((/ntot, nsit0/), float)
         ts0_mod = new((/nmod, ntot, nsit0/), float)
         slat0   = new((/nsit0/), float)
         slon0   = new((/nsit0/), float)
      
         if (nsit0.eq.1) then
            ts0_obs(:,0)   = ts_obs(:,i50(i51))
            ts0_mod(:,:,0) = ts_mod(:,:,i50(i51))
            slat0(0)       = slat(i50(i51))
            slon0(0)       = slon(i50(i51))
         else
            ts0_obs(:,0:nsit0-1)   = ts_obs(:,i50(i51))
            ts0_mod(:,:,0:nsit0-1) = ts_mod(:,:,i50(i51))
            slat0(0:nsit0-1)       = slat(i50(i51))
            slon0(0:nsit0-1)       = slon(i50(i51))
         end if
      
         ; ------- Set Model Data as missing where the Benchmark is missing -----
         score1=new((/nmod+1/), float)
         score2=new((/nmod+1/), float)
         tt1_mod=new((/nmod+1,nsit0/), float)
         tt2_mod=new((/nmod+1,nsit0/), float)
      
         mean0=new((/nsit0/), float)
      
         mean0   = -999
         score1  = -999
         score2  = -999
         tt1_mod = -999
         tt2_mod = -999
      
         tt0=new((/nsit0,nmon,nyer/), float)
      
            ijk=0
         do iy=0,nyer-1
         do im=0,nmon-1
            tt0(:,im,iy)=ts0_obs(ijk,:)
            ijk=ijk+1
         end do
         end do
      
         tt0@_FillValue=-999
      
         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))
      
         numb = where (numb.gt.1, numb, 0)
      
         at0=dim_avg(tt0)
         atObs=dim_avg(at0)
      
         MinObs = min(atObs)
         if (MinObs.le.0 .and. MinObs.ne.-999) then
            atObs1 = atObs - MinObs*varID@MinFC
         else
            atObs1 = atObs
         end if
      
         att=new((/nsit0,nmon*3/), float)
      
         att(:,0:11)=at0
         att(:,12:23)=at0
         att(:,24:35)=at0
      
         ;att=runave(att,3,2)
      
         ;at0=att(:,12:23)
      
         do ns=0, nsit0-1
            if (ismissing(sum(at0(ns,:)))) then
            else
               mean0(ns)=maxind(at0(ns,:))+1
            end if
         end do
      
         mean0=where(mean0.le.0, -999, mean0)
         mean0@_FillValue=-999
      
         angle0=new((/nsit0/), float)
      
         angle0 = -999
      
         do ns=0, nsit0-1
            if (.not.ismissing(mean0(ns))) then
               angle0(ns)=360.0*mean0(ns)/12.0
            end if
         end do
      
         score1(0)    = 0.0
         tt1_mod(0,:) = mean0
      
         angle0@_FillValue=-999
      
         do nv=0, nmod-1
         if (runID(nv).gt.0) then
      
            tt1=new((/nsit0,nmon,nyer/), float)
            mean1=new((/nsit0/), float)
      
               ijk=0
            do iy=0,nyer-1
            do im=0,nmon-1
               tt1(:,im,iy)=ts0_mod(nv,ijk,:)
               ijk=ijk+1
            end do
            end do
      
            tt1=where(ismissing(tt0), -999, tt1)
      
            tt1@_FillValue=-999
      
            at1=dim_avg(tt1)
      
            att(:,0:11) =at1
            att(:,12:23)=at1
            att(:,24:35)=at1
      
            ;att=runave(att,3,2)
      
            ;at1=att(:,12:23)
      
            mean1=new((/nsit0/), float)
      
            do ns=0, nsit0-1
               if (ismissing(sum(at1(ns,:)))) then
               else
                  mean1(ns)=maxind(at1(ns,:))+1
               end if
            end do
      
            mean1=where(mean1.le.0, -999, mean1)
            mean1@_FillValue=-999
      
            angle1=new((/nsit0/), float)
      
            angle1 = -999
      
            do ns=0, nsit0-1
               if (.not.ismissing(mean1(ns))) then
                  angle1(ns)=360.0*mean1(ns)/12.0
               end if
            end do
      
            angle1 = angle1 - angle0
      
            angle1@_FillValue=-999
      
            mean1=mean1-mean0
      
            mean1@_FillValue=-999
      
            angle1=where(angle1.gt.180,  angle1-360, angle1)
            angle1=where(angle1.lt.-180, angle1+360, angle1)
      
            angle1 = angle1*RR0
      
            mean1 = where(mean1.gt.6,  mean1-12, mean1)
            mean1 = where(mean1.lt.-6, mean1+12, mean1)
      
            mean1 = where(mean0.gt.0, mean1, -999)
      
            mean1@_FillValue=-999
      
            if (str_lower(varID@MassWeighting).eq."yes") then
               ; +++++ Calculate Global Mean Scores weighted by Mass ++++
               if (str_lower(varID@MassWeightingFC).eq."yes") then
                  score1(nv+1)=sum(mean1*atObs1)/sum(atObs1)
                  score2(nv+1)=(1+sum(cos(angle1)*atObs1)/sum(atObs1))/2
               else
                  score1(nv+1)=sum(mean1*abs(atObs))/sum(abs(atObs))
                  score2(nv+1)=(1+sum(cos(angle1)*abs(atObs))/sum(abs(atObs)))/2
               end if
            else
               ; +++++ Calculate Global Mean Scores weighted by Area ++++
               score1(nv+1)=avg(mean1)
               score2(nv+1)=(1+avg(cos(angle1)))/2
            end if
      
            tt1_mod(nv+1,:) = mean1
            tt2_mod(nv+1,:) = (1+cos(angle1))/2
      
            delete(tt1)
            delete(at1)
            delete(mean1)
            delete(angle1)
         end if
         end do
      
         score1@_FillValue=-999
         score2@_FillValue=-999
         tt1_mod@_FillValue = -999
         tt2_mod@_FillValue = -999
      
         ; ++++++++++ set up parameters for drawing +++++++++++
      
         DrawInfo = retrieve_DrawInfo (varID, "phasescore", Source)
      
         cnlevels = DrawInfo@cnlevels
         lblabels = DrawInfo@lblabels
         XLab     = DrawInfo@XLab
         YLab     = DrawInfo@YLab
         CLab     = DrawInfo@CLab
      
         MinLon   = min(rlon)
         MaxLon   = max(rlon)
         MinLat   = min(rlat)
         MaxLat   = max(rlat)
      
         if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
            MinLon   = DrawInfo@MinLon
            MaxLon   = DrawInfo@MaxLon
            MinLat   = DrawInfo@MinLat
            MaxLat   = DrawInfo@MaxLat
         end if
      
         XLab     = 1
         YLab     = 1
      
         ; ++++++++++ Create a txt file and save results +++++++++++
      
         ; ++++++++++ Save global mean Phase Difference +++++++++++
         TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phase/phase_" + str_lower(varID) \
                       + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                       + sprinti("%0.4i",EndYear) + ".txt"
      
         print(TableFileName)
      
         header      = "Phase Change (months) for " + str_upper(varID) + ": Model against " + Source + ", " + \
                       sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      
         write_table(TableFileName, "w", [/header/], "%s")
         write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
         write_table(TableFileName,"a",[/ModelNameList,score1/], "%16s %10.2f")
      
         ;print(asciiread(TableFileName,-1,"string"))
      
         ; ++++++++++ Save global mean Phase Scores +++++++++++
         TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phasescore/phasescore_" + str_lower(varID) \
                       + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                       + sprinti("%0.4i",EndYear) + ".txt"
      
         print(TableFileName)
      
         header      = "Seasonal Cycle Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                       sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      
         write_table(TableFileName, "w", [/header/], "%s")
         write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
         write_table(TableFileName,"a",[/ModelNameList,score2/], "%16s %10.2f")
      
         ;print(asciiread(TableFileName,-1,"string"))
      
         tt1_mod!0="mod"
         tt1_mod!1="site"
      
         tt2_mod!0="mod"
         tt2_mod!1="site"
      
         ; ++++++++++ Draw global distribution of Phase Difference and Phase Score +++++++++++
      
         do nv = 0, nmod
         if (runIDS(nv).gt.0) then
      
            ; ++++++++++ Draw global distribution of Phase Difference +++++++++++
            PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phase/phase_" + str_lower(varID)  \ 
                         + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \ 
                         + "-" + sprinti("%0.4i",EndYear)
      
            if (nv.eq.0) then
               delete(cnlevels)
               delete(lblabels)
               cnlevels     = (/1.,2.,3.,4.,5.,6.,7.,8.,9.,10.,11.,12./)
               lblabels     = (/"n/a","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
               titles       = "Peak month for " + str_upper(varID) + ": " + ModelNameList(nv) + ", " + \
                               sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
            else
               delete(cnlevels)
               delete(lblabels)
               ;cnlevels  = (/-6.,-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5.,6./)
               ;lblabels  = (/"n/a","-6","-5","-4","-3","-2","-1","0","1","2","3","4","5","6"/)
               cnlevels  = (/-5.5,-4.5,-3.5,-2.5,-1.5,-0.5,0.5,1.5,2.5,3.5,4.5,5.5/)
               lblabels  = (/"-6","-5","-4","-3","-2","-1","0","1","2","3","4","5","6"/)
      
               titles       = "Difference of peak month for " + str_upper(varID) + ": " + ModelNameList(nv) + " against " + Source \
                            + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
            end if
      
            Draw_Map (PlotFileName, tt1_mod(nv,:), slat0, slon0, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                      MinLon, MaxLon, MinLat, MaxLat, SiteID)
      
            ; ++++++++++ Draw global distribution of Seasonal Cycle Scores +++++++++++
            PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phasescore/phasescore_" + str_lower(varID)  \ 
                         + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \ 
                         + "-" + sprinti("%0.4i",EndYear)
      
            if (nv.gt.0) then
               delete(cnlevels)
               delete(lblabels)
               cnlevels     = DrawInfo@cnlevels
               lblabels     = DrawInfo@lblabels
      
               titles       = "Seasonal Cycle Score for " + str_upper(varID) + ": " + ModelNameList(nv) + " against " + Source \
                            + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      
               Draw_Map (PlotFileName, tt2_mod(nv,:), slat0, slon0, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                         MinLon, MaxLon, MinLat, MaxLat, SiteID)
            end if
      
         end if
         end do
      
         ;----------- Draw Global Mean Seasonal Cycle Score -----------------------------------------
      
         PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phasescore/phasescore_" + str_lower(varID) \
                      + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      
         titles       = "Seasonal Cycle Score for " + str_upper(varID) + " against " + str_upper(Source) + ", " + \
                         sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      
         Draw_Score (PlotFileName, score2, ModelNameList, titles)

      end if

      delete(i50)
      delete(i51)
   end if

else

   ts0_obs = ts_obs
   ts0_mod = ts_mod

   ; ------- Set Model Data as missing where the Benchmark is missing -----
   score1=new((/nmod+1/), float)
   score2=new((/nmod+1/), float)
   tt1_mod=new((/nmod+1/), float)
   tt2_mod=new((/nmod+1/), float)

   score1  = -999.
   score2  = -999.
   tt1_mod = -999.
   tt2_mod = -999.

   tt0=new((/nmon,nyer/), float)

      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      tt0(im,iy)=ts0_obs(ijk)
      ijk=ijk+1
   end do
   end do

   tt0@_FillValue=-999

   numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

   numb = where (numb.gt.1, numb, 0)

   at0=dim_avg(tt0)
   atObs=dim_avg(at0)

   att=new((/nmon*3/), float)

   att(0:11)=at0
   att(12:23)=at0
   att(24:35)=at0

   ;att=runave(att,3,2)
   ;at0=att(:,12:23)

   if (ismissing(sum(at0))) then
      mean0 = -999.
   else
      mean0 = int2flt(maxind(at0)+1)
   end if

   mean0=where(mean0.le.0., -999., mean0)
   mean0@_FillValue=-999

   angle0 = -999.

   if (.not.ismissing(mean0)) then
      angle0=360.0*mean0/12.0
   end if

   score1(0)    = 0.0
   tt1_mod(0) = mean0

   angle0@_FillValue=-999

   do nv=0, nmod-1
   if (runID(nv).gt.0) then

      tt1=new((/nmon,nyer/), float)

         ijk=0
      do iy=0,nyer-1
      do im=0,nmon-1
         tt1(im,iy)=ts0_mod(nv,ijk,0)
         ijk=ijk+1
      end do
      end do

      tt1=where(ismissing(tt0), -999, tt1)

      tt1@_FillValue=-999

      at1=dim_avg(tt1)

      att(0:11) =at1
      att(12:23)=at1
      att(24:35)=at1

      ;att=runave(att,3,2)
      ;at1=att(:,12:23)

      if (ismissing(sum(at1))) then
         mean1 = -999.
      else
         mean1 = int2flt(maxind(at1)+1)
      end if

      mean1=where(mean1.le.0, -999, mean1)
      mean1@_FillValue=-999

      angle1 = -999.

      if (.not.ismissing(mean1)) then
         angle1=360.0*mean1/12.0
      end if

      angle1 = angle1 - angle0
      angle1@_FillValue=-999

      mean1=mean1-mean0
      mean1@_FillValue=-999

      angle1=where(angle1.gt.180,  angle1-360, angle1)
      angle1=where(angle1.lt.-180, angle1+360, angle1)

      angle1 = angle1*RR0

      mean1 = where(mean1.gt.6,  mean1-12, mean1)
      mean1 = where(mean1.lt.-6, mean1+12, mean1)

      mean1 = where(mean0.gt.0, mean1, -999)

      mean1@_FillValue=-999

      if (str_lower(varID@MassWeighting).eq."yes") then
         ; +++++ Calculate Global Mean Scores weighted by Mass ++++
         score1(nv+1)=sum(mean1*abs(atObs))/sum(abs(atObs))
         score2(nv+1)=(1+sum(cos(angle1)*abs(atObs))/sum(abs(atObs)))/2
      else
         ; +++++ Calculate Global Mean Scores weighted by Area ++++
         score1(nv+1)=avg(mean1)
         score2(nv+1)=(1+avg(cos(angle1)))/2
      end if

      tt1_mod(nv+1) = mean1
      tt2_mod(nv+1) = (1+cos(angle1))/2

      delete(tt1)
      delete(at1)
      delete(mean1)
      delete(angle1)
   end if
   end do

   score1@_FillValue=-999
   score2@_FillValue=-999
   tt1_mod@_FillValue = -999
   tt2_mod@_FillValue = -999

   ; ++++++++++ set up parameters for drawing +++++++++++

   DrawInfo = retrieve_DrawInfo (varID, "phasescore", Source)

   cnlevels = DrawInfo@cnlevels
   lblabels = DrawInfo@lblabels
   XLab     = DrawInfo@XLab
   YLab     = DrawInfo@YLab
   CLab     = DrawInfo@CLab

   MinLon   = min(rlon)
   MaxLon   = max(rlon)
   MinLat   = min(rlat)
   MaxLat   = max(rlat)

   if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
      MinLon   = DrawInfo@MinLon
      MaxLon   = DrawInfo@MaxLon
      MinLat   = DrawInfo@MinLat
      MaxLat   = DrawInfo@MaxLat
   end if

   XLab     = 1
   YLab     = 1

   ; ++++++++++ Create a txt file and save results +++++++++++

   ; ++++++++++ Save global mean Phase Difference +++++++++++
   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phase/phase_" + str_lower(varID) \
                 + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                 + sprinti("%0.4i",EndYear) + ".txt"

   print(TableFileName)

   header      = "Phase Change (months) for " + str_upper(varID) + ": Model against " + Source + ", " + \
                 sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList,score1/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   ; ++++++++++ Save global mean Phase Scores +++++++++++
   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phasescore/phasescore_" + str_lower(varID) \
                 + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                 + sprinti("%0.4i",EndYear) + ".txt"

   print(TableFileName)

   header      = "Seasonal Cycle Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                 sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList,score2/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   score1!0="mod"
   score1&mod=fspan(1,nmod+1,nmod+1)

   score2!0="mod"
   score2&mod=fspan(1,nmod+1,nmod+1)

   tt1_mod!0="mod"
   tt1_mod&mod=fspan(1,nmod+1,nmod+1)

   tt2_mod!0="mod"
   tt2_mod&mod=fspan(1,nmod+1,nmod+1)

   ; ++++++++++ Draw global distribution of Phase Difference and Phase Score +++++++++++

   ; ++++++++++ Draw global distribution of Phase Difference +++++++++++
   PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phase/phase_" + str_lower(varID)  \ 
                + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \ 
                + "-" + sprinti("%0.4i",EndYear)

   delete(cnlevels)
   delete(lblabels)

   ;cnlevels  = (/-6.,-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5.,6./)
   ;lblabels  = (/"n/a","-6","-5","-4","-3","-2","-1","0","1","2","3","4","5",">=6"/)
   cnlevels  = (/-5.5,-4.5,-3.5,-2.5,-1.5,-0.5,0.5,1.5,2.5,3.5,4.5,5.5/)
   lblabels  = (/"-6","-5","-4","-3","-2","-1","0","1","2","3","4","5","6"/)

   titles       = "Difference of peak month for " + str_upper(varID) + ": " + ModelNameList(nv) + " against " + Source \
                + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   Draw_Bar (PlotFileName, ModelNameList, score1, tt1_mod, tt1_mod, titles, \
            XLab, YLab, CLab, MinLon, MaxLon, MinLat, MaxLat, "NoLine")

   ;----------- Draw Global Mean Seasonal Cycle Score -----------------------------------------

   PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/phasescore/phasescore_" + str_lower(varID) \
                + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   titles       = "Seasonal Cycle Score for " + str_upper(varID) + " against " + str_upper(Source) + ", " + \
                   sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   Draw_Score (PlotFileName, score2, ModelNameList, titles)

end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure RMSE (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, Unit:string,\
                ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

MODELTYPE = getenv("MODELTYPE")

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=0
runIDS(1:nmod)=runID

ModelNameList(0) = str_upper(Source)
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac
landm_mod = ts_mod@LandMask

RawMax_mod = ts_mod@RawMax
RawMin_mod = ts_mod@RawMin
RawAvg_mod = ts_mod@RawAvg

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

region    = where(landf_obs.gt.0,1,0)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

; ------- Choose data only in the selected sub-region ------------------------
i50 = ind(slon.ge.min(rlon) .and. slon.le.max(rlon))
j50 = ind(slat.ge.min(rlat) .and. slat.le.max(rlat))

nlon = dimsizes(i50)
nlat = dimsizes(j50)

ts0_obs    = ts_obs(:,j50,i50)
ts0_mod    = ts_mod(:,:,j50,i50)

landf0_obs = landf_obs(j50,i50)
landf0_mod = landf_mod(:,j50,i50)
landm0_mod = landm_mod(:,j50,i50)

area0_obs  = area_obs(j50,i50)
area0_mod  = area_mod(:,j50,i50)

region0    = region(j50,i50)

delete(i50)
delete(j50)

if (str_lower(varID).eq."sst") then
   region0=where(region0.eq.0, 1, 0)
else
   region0=where(region0.gt.0.5, 1, 0)
end if

; -------convert unit of burned area from %/yr back to %/mon ------------------------
if (str_lower(varID).eq."burntarea") then
   results = retrieve_unit (varID, Source)
   ts0_obs = ts0_obs/results
   ts0_mod = ts0_mod/results
   delete(results)
end if

; ------- Set Model Data as missing where the Benchmark is missing -----
score=new((/nmod+1/), float)
tt_mod=new((/nmod+1,nlat,nlon/), float)

score = -999
tt_mod= -999

if (str_lower(varID@SubGlobe).eq."yes") then
   ts0_obs=where(ts0_obs.le.0, -999, ts0_obs)
else
   do nt=0,ntot-1
      ts0_obs(nt,:,:) =where(region0.gt.0, ts0_obs(nt,:,:), -999)
   end do
end if

ts0_obs@_FillValue=-999

ts0_obs!0="time"
ts0_obs!1="lat"
ts0_obs!2="lon"

region1=dim_avg(ts0_obs(lat|:,lon|:,time|:))

region1=where(.not.ismissing(region1),1,0)

;if (str_lower(varID@CarbonYearly).eq."yes") then
;   region1=where(region1.gt.0,1,0)
;else
;   region1=where(.not.ismissing(region1),1,0)
;end if

tt0=new((/nlat,nlon,nmon,nyer/), float)

   ijk=0
do iy=0,nyer-1
do im=0,nmon-1
   tt0(:,:,im,iy)=ts0_obs(ijk,:,:)
   ijk=ijk+1
end do
end do

   ijk=0
do iy=0,nyer-1
do im=0,nmon-1
   tt0(:,:,im,iy) =where(region1.gt.0, tt0(:,:,im,iy), -999)
   ijk=ijk+1
end do
end do

tt0@_FillValue=-999

temp=tt0
temp=where(ismissing(temp), 0, 1)

numb=sum(temp)

delete(temp)

numb = where (numb.gt.1, numb, 0)

if (.not.ismissing(avg(tt0))) then
do nv=0, nmod-1
if (runID(nv).gt.0) then

   area = area0_mod(nv,:,:)

   TempReg = region1
   TempReg = where(landm0_mod(nv,:,:).gt.0, TempReg, 0)

   landfOM = where(landf0_obs.gt.0.0 .and. landf0_mod(nv,:,:).gt.0.0, landf0_mod(nv,:,:), -999)
   landfOM = where(landm0_mod(nv,:,:).gt.0, landfOM, -999)

   landfOM@_FillValue=-999

   TempReg = landfOM
   TempReg@_FillValue=-999

   tt1=new((/nlat,nlon,nmon,nyer/), float)

      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      tt1(:,:,im,iy)=ts0_mod(nv,ijk,:,:)
      ijk=ijk+1
   end do
   end do

   if (str_lower(varID@SubGlobe).eq."yes") then
      tt1=where(ismissing(tt0), -999, tt1)
   end if

   tt1@_FillValue=-999

   tmp0=dim_avg(tt0)
   tmp1=dim_avg(tt1)

   ; -------convert unit from per cell area to per land area ------------------------
   ;if (str_lower(varID@LandOnly).eq."yes") then
   ;   tmp0 = tmp0/landfOM
   ;   tmp1 = tmp1/landfOM
   ;end if

   ;area = area*landfOM

   ;if (str_lower(varID@LimitFlag).eq."yes") then
   ;   tmp0=where(ismissing(landfOM), -999, tmp0)
   ;   tmp1=where(ismissing(landfOM), -999, tmp1)
   ;end if

   do im = 0, nmon-1
      tmp0(:,:,im)=where(ismissing(landfOM), -999, tmp0(:,:,im))
      tmp1(:,:,im)=where(ismissing(landfOM), -999, tmp1(:,:,im))
   end do

   tmp0@_FillValue=-999
   tmp1@_FillValue=-999

   tmp=dim_rmsd(tmp0,tmp1)

   ;if (str_lower(varID@LandOnly).eq."yes") then
   ;   tmp = tmp/landfOM
   ;end if

   if (str_lower(varID@CarbonMonthly).eq."yes") then
      score(nv+1)=sum(tmp*area*365*1e-15)/12
   else
      if (str_lower(varID@CarbonYearly).eq."yes") then
         score(nv+1)=sum(tmp*area*1e-12)
      else
         score(nv+1) = sum(tmp*area*TempReg)/sum(area*TempReg)
      end if
   end if

   if (str_lower(varID@LimitFlag).eq."no") then
      tmp=where(ismissing(landfOM), -999, tmp)
   end if

   tmp@_FillValue=-999

   tt_mod(nv+1,:,:)=tmp

   delete(tt1)
   delete(tmp)
   delete(tmp0)
   delete(tmp1)
   delete(landfOM)
   delete(TempReg)
end if
end do

   score@_FillValue  = -999
   tt_mod@_FillValue = -999

   ; ++++++++++ retrieve the units +++++++++++
   UnitInfo  = retrieve_unit (varID, Source)

   UnitTable = UnitInfo@FinalTable
   UnitPlots = UnitInfo@FinalPlots

   ; ++++++++++ Units for RMSE need be changed from per yr to per month +++++++++++
   UnitTable = str_sub_str(UnitTable, "yr", "mon")
   UnitPlots = str_sub_str(UnitPlots, "yr", "mon")

   ; ++++++++++ set up parameters for drawing +++++++++++

   DrawInfo = retrieve_DrawInfo (varID, "rmse", Source)

   cnlevels = DrawInfo@cnlevels
   lblabels = DrawInfo@lblabels
   XLab     = DrawInfo@XLab
   YLab     = DrawInfo@YLab
   CLab     = DrawInfo@CLab

   MinLon   = min(rlon)
   MaxLon   = max(rlon)
   MinLat   = min(rlat)
   MaxLat   = max(rlat)

   if (any(str_lower(Source).eq.(/"nbcd2000", "us.forest"/)) \
      .and. str_lower(SubReg).eq."global") then
      MinLon   = DrawInfo@MinLon
      MaxLon   = DrawInfo@MaxLon
      MinLat   = DrawInfo@MinLat
      MaxLat   = DrawInfo@MaxLat
   end if

   XLab     = 1
   YLab     = 1

   ; ++++++++++ Create a txt file and save results +++++++++++

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmse/rmse_" + str_lower(varID) + "_" \
                 + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                 + sprinti("%0.4i",EndYear) + ".txt"

   print(TableFileName)

   header      = "RMSE for " + str_upper(varID) + " (" + UnitTable + "): Model against " + Source + ", " + \
                 sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList(0:nmod),score(0:nmod)/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   tt_mod!0="mod"
   tt_mod!1="lat"
   tt_mod!2="lon"
   tt_mod&lat=rlat
   tt_mod&lon=rlon
   tt_mod&lon@units="degrees_east"
   tt_mod&lat@units="degrees_north"

   ; ++++++++++ Draw global distribution of RMSE +++++++++++

   do nv = 1, nmod
   if (runIDS(nv).gt.0) then

      PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmse/rmse_" + str_lower(varID) + "_" \
                   + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                   + "-" + sprinti("%0.4i",EndYear)

      UnitPlots    = str_sub_str(UnitPlots, "yr", "month") 

      titles       = "RMSE for " + str_upper(varID) + " (" + UnitPlots + "): " + ModelNameList(nv) + " against " + Source \
                   + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

      Draw_Map (PlotFileName, tt_mod(nv,:,:), rlat, rlon, titles, cnlevels, lblabels, XLab, YLab, CLab, \
               MinLon, MaxLon, MinLat, MaxLat, SiteID)

   end if
   end do
end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure RMSE_site (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, Unit:string,\
                     ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                     SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

nsit=dimsizes(ind(slat.ne.-999))

MODELTYPE = getenv("MODELTYPE")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID

ModelNameList(0) = str_upper(Source)
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)
delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

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

; ++++++++++ retrieve the units +++++++++++
UnitInfo  = retrieve_unit (varID, Source)

UnitTable = UnitInfo@FinalTable
UnitPlots = UnitInfo@FinalPlots

; ------- Choose data only in the selected sub-region ------------------------ 

if (nsit.gt.1) then

   ts_obs!0="time"
   ts_obs!1="site"   

   if (any(str_lower(Source).eq.(/"noaa.gmd"/))) then

      temp = dim_avg(ts_obs(site|:,time|:)) 

      if (str_upper(MODELTYPE).eq."CLM") then
         i51 = ind(.not.ismissing(temp) .and. LandFracMod.eq.nmod)
      else
         i51 = ind(.not.ismissing(temp))
      end if
   
      delete(temp)

      if (dimsizes(i51).gt.1 .or. .not.ismissing(i51)) then

         nsit0 = dimsizes(i51)

         ts0_obs = new((/ntot, nsit0/), float)
         ts0_mod = new((/nmod, ntot, nsit0/), float)
         slat0   = new((/nsit0/), float)
         slon0   = new((/nsit0/), float)

         if (nsit0.eq.1) then
            ts0_obs(:,0)   = ts_obs(:,i51)
            ts0_mod(:,:,0) = ts_mod(:,:,i51)
            slat0(0)       = slat(i51)
            slon0(0)       = slon(i51)
         else
            ts0_obs(:,0:nsit0-1)   = ts_obs(:,i51)
            ts0_mod(:,:,0:nsit0-1) = ts_mod(:,:,i51)
            slat0(0:nsit0-1)       = slat(i51)
            slon0(0:nsit0-1)       = slon(i51)
         end if

         ts0_obs@_FillValue=-999
         ts0_mod@_FillValue=-999

         ; -------- read biome regions data ----------------

         SubRegName = retrieve_latlon_belt (Source, "zonalmean")

         nreg       = dimsizes(SubRegName)

         LatLon = SubRegName@LatLon

         MinLat = LatLon(0,:)
         MaxLat = LatLon(1,:)
         MinLon = LatLon(2,:)
         MaxLon = LatLon(3,:)

         ShortName = SubRegName
         LongName  = SubRegName@LongName

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

         tts     = new((/nmod+1, nreg, ntot/), float)

         tts   = -999

         tts@_FillValue = -999

         slon0=where(slon0.gt.180, slon0-360, slon0)

         tt0=new((/nsit0,ntot/), float)

         do nt=0,ntot-1
            tt0(:,nt)=ts0_obs(nt,:)
         end do

         tt0@_FillValue=-999

         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

         numb = where(numb.gt.1, numb, 0)

         do nv=0, nmod-1
            if (runID(nv).gt.0) then

               tt1=new((/nsit0,ntot/), float)

               do nt=0,ntot-1
                  tt1(:,nt)=ts0_mod(nv,nt,:)
               end do

               tt1=where(ismissing(tt0), -999, tt1)

               tt1@_FillValue=-999

               reg0=new((/dimsizes(slat0)/), float)

               do nr = 1, nreg

                  j50 = ind((slat0.ge.MinLat(nr-1).and.slat0.le.MaxLat(nr-1)) .and. (slon0.ge.MinLon(nr-1).and.slon0.le.MaxLon(nr-1)))

                  if (dimsizes(j50).gt.1) then
                     tts(0,nr-1,:)      = dim_avg_n(tt0(j50,:), 0)
                     tts(nv+1,nr-1,:)   = dim_avg_n(tt1(j50,:), 0)
                  else
                     if (dimsizes(j50).eq.1 .and. .not.ismissing(j50)) then
                        tts(0,nr-1,:)   = (/tt0(j50, :)/)
                        tts(nv+1,nr-1,:)= (/tt1(j50, :)/)
                     end if
                  end if

                  delete(j50)
               end do

               delete(tt1)
               delete(reg0)
            end if
         end do

         tts@_FillValue = -999

         ; +++ Remove long-term trend from each time series +++
         tts0    = new((/nmod+1, nreg, ntot/), float)

         tts0    = -999 

         xx = fspan(1.,int2flt(nyer),ntot)
         nn = 3

         do nv = 0, nmod
         do ns = 0, nreg-1

            if (dimsizes(.not.ismissing(tts(nv,ns,:))).gt.3) then

               yy01 = tts(nv,ns,:)

               cc0  = lspoly(xx,yy01, 1, nn)
               yy02 = cc0(0) + cc0(1)*xx + cc0(2)*xx^2
               yy02 = yy01-yy02
               delete(cc0)

               tts0(nv,ns,:) = yy02

               delete(yy01)
               delete(yy02)
            end if

         end do
         end do

         ; +++ calculate annual cycle for each time series +++
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

         score=new((/nmod+1/), float)
         tt_mod=new((/nmod+1,nreg/), float)

         score  = -999
         tt_mod = -999

         do nv=1, nmod
         if (runIDS(nv).gt.0) then

            tmp0=tta(0,:,:)
            tmp1=tta(nv,:,:)

            tmp=new((/nreg/), float)

            tmp = -999

            do ns=0,nreg-1
               j50 = ind(.not.ismissing(tmp0(ns,:)))
               if (dimsizes(j50).ge.2 .or. .not.ismissing(j50)) then
                  tmp(ns)=dim_rmsd(tmp0(ns,j50),tmp1(ns,j50))
               end if
               delete(j50)
            end do

            tmp@_FillValue=-999

            tt_mod(nv,:) = tmp
            score(nv)=avg(tmp)

            delete(tmp)
            delete(tmp0)
            delete(tmp1)
         end if
         end do

         ; ++++++++++ Create a txt file and save results +++++++++++

         TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmse/rmse_" + str_lower(varID) \
                       + "_" + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                       + sprinti("%0.4i",EndYear) + ".txt"

         print(TableFileName)

         header       = "RMSE for " + str_upper(varID) + " (" + UnitTable + "): Model against " + Source + ", " + \
                         sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         write_table(TableFileName, "w", [/header/], "%s")
         write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
         write_table(TableFileName,"a",[/ModelNameList(0:nmod),score(0:nmod)/], "%16s %10.2f")

         ;print(asciiread(TableFileName,-1,"string"))

         ; ++++++++++ set up parameters for drawing +++++++++++

         DrawInfo  = retrieve_DrawInfo (varID, "RMSE", Source)

         cnlevels = DrawInfo@cnlevels
         lblabels = DrawInfo@lblabels

         XLab      = 1
         YLab      = 1
         CLab      = 1

         SubRegName = retrieve_latlon_belt (Source, "zonalmean")

         nreg       = dimsizes(SubRegName)

         LatLon = SubRegName@LatLon

         MinLat = LatLon(0,:)
         MaxLat = LatLon(1,:)
         MinLon = LatLon(2,:)
         MaxLon = LatLon(3,:)

         cLats  = (MinLat+MaxLat)/2

         do ns =0, nreg-1
            if (cLats(ns).lt.0) then
               TmpStr1 = sprintf("%.0f",floor(abs(cLats(ns)))) + "S"
            else
               TmpStr1 = sprintf("%.0f",floor(cLats(ns))) + "N"
            end if

            LongName(ns)  = TmpStr1
         end do

         cLats@lblabels = LongName

         nmodels = fspan(1.,int2flt(nmod+1),nmod+1)
         nmodels@lblabels = ModelNameList(::-1)

         tt_mod = tt_mod(::-1,:)

         tt_mod@_FillValue = -999

         tt_mod!0="mod"
         tt_mod!1="lat"   
         tt_mod&mod=nmodels
         tt_mod&lat=cLats
         tt_mod&lat@units="degrees_north"

         ; ++++++++++ Draw global distribution of Annual Mean +++++++++++

         PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmse/rmse_" + str_lower(varID) \
                      + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                      + "-" + sprinti("%0.4i",EndYear)

         titles = "RMSE for " + str_upper(varID) + " (" + UnitTable + "), " \
                + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         ;Draw_Table_Scores (PlotFileName, ModelNameList, runIDS, ttt_mod, cnlevels1, cnlevels2, lblabels1, lblabels2, \
         ;                   titles1, titles2, cLats)

         Draw_LatLon_Time (PlotFileName, tt_mod, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                           nmodels, cLats)

         delete(tta)
         delete(tts)
         delete(ttt)
         delete(tts0)
         delete(ts0_obs)
         delete(ts0_mod)
      end if

      delete(i51)

   else

      i50 = ind((slon.ge.min(rlon) .and. slon.le.max(rlon)) .and. (slat.ge.min(rlat) .and. slat.le.max(rlat)))

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
   
      delete(temp)

      if (dimsizes(i51).gt.1 .or. .not.ismissing(i51)) then
      
         nsit0 = dimsizes(i51)
      
         ts0_obs = new((/ntot, nsit0/), float)
         ts0_mod = new((/nmod, ntot, nsit0/), float)
         slat0   = new((/nsit0/), float)
         slon0   = new((/nsit0/), float)
      
         if (nsit0.eq.1) then
            ts0_obs(:,0)   = ts_obs(:,i50(i51))
            ts0_mod(:,:,0) = ts_mod(:,:,i50(i51))
            slat0(0)       = slat(i50(i51))
            slon0(0)       = slon(i50(i51))
         else
            ts0_obs(:,0:nsit0-1)   = ts_obs(:,i50(i51))
            ts0_mod(:,:,0:nsit0-1) = ts_mod(:,:,i50(i51))
            slat0(0:nsit0-1)       = slat(i50(i51))
            slon0(0:nsit0-1)       = slon(i50(i51))
         end if
      
         ; -------convert unit of burned area from %/yr back to %/mon ------------------------
         if (str_lower(varID).eq."burntarea") then
            results = retrieve_unit (varID, Source)
            ts0_obs = ts0_obs/results
            ts0_mod = ts0_mod/results
            delete(results)
         end if
      
         score=new((/nmod+1/), float)
         tt_mod=new((/nmod+1,nsit0/), float)
      
         score  = -999
         tt_mod = -999
      
         slon0=where(slon0.gt.180, slon0-360, slon0)
      
         tt0=new((/nsit0,nmon,nyer/), float)
      
            ijk=0
         do iy=0,nyer-1
         do im=0,nmon-1
            tt0(:,im,iy)=ts0_obs(ijk,:)
            ijk=ijk+1
         end do
         end do
      
         tt0@_FillValue=-999
      
         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))
      
         numb = where (numb.gt.1, numb, 0)
      
         do nv=0, nmod-1
         if (runID(nv).gt.0) then
      
            tt1=new((/nsit0,nmon,nyer/), float)
      
               ijk=0
            do iy=0,nyer-1
            do im=0,nmon-1
               tt1(:,im,iy)=ts0_mod(nv,ijk,:)
               ijk=ijk+1
            end do
            end do
      
            tt1@_FillValue=-999
      
            tmp0=dim_avg(tt0)
            tmp1=dim_avg(tt1)
      
            tmp=new((/nsit0/), float)
      
            tmp = -999
      
            do ns=0,nsit0-1
               j50 = ind(.not.ismissing(tmp0(ns,:)))
               if (dimsizes(j50).ge.2 .or. .not.ismissing(j50)) then
                  tmp(ns)=dim_rmsd(tmp0(ns,j50),tmp1(ns,j50))
               end if
               delete(j50)
            end do
      
            tmp@_FillValue=-999
      
            tt_mod(nv+1,:) = tmp
            score(nv+1)=avg(tmp)
      
            delete(tt1)
            delete(tmp)
            delete(tmp0)
            delete(tmp1)
         end if
         end do
      
         tt_mod!0="mod"
         tt_mod!1="site"
      
         score=where(ismissing(score), -999, score)
      
         score@_FillValue=-999
      
         ; ++++++++++ set up parameters for drawing +++++++++++
      
         DrawInfo = retrieve_DrawInfo (varID, "rmse", Source)
      
         cnlevels = DrawInfo@cnlevels
         lblabels = DrawInfo@lblabels
         XLab     = DrawInfo@XLab
         YLab     = DrawInfo@YLab
         CLab     = DrawInfo@CLab
      
         MinLon   = min(rlon)
         MaxLon   = max(rlon)
         MinLat   = min(rlat)
         MaxLat   = max(rlat)
      
         if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
            MinLon   = DrawInfo@MinLon
            MaxLon   = DrawInfo@MaxLon
            MinLat   = DrawInfo@MinLat
            MaxLat   = DrawInfo@MaxLat
         end if
      
         XLab     = 1
         YLab     = 1
      
         ; ++++++++++ Create a txt file and save results +++++++++++
      
         TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmse/rmse_" + str_lower(varID) + "_" \
                       + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                       + sprinti("%0.4i",EndYear) + ".txt"
      
         print(TableFileName)
      
         header      = "RMSE for " + str_upper(varID) + " (" + UnitTable + "): Model against " + Source + ", " + \
                       sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      
         write_table(TableFileName, "w", [/header/], "%s")
         write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
         write_table(TableFileName,"a",[/ModelNameList(0:nmod),score(0:nmod)/], "%16s %10.2f")
      
         ;print(asciiread(TableFileName,-1,"string"))
      
         ; ++++++++++ Draw global distribution of RMSE +++++++++++
      
         do nv = 1, nmod
      
            if (runIDS(nv).gt.0) then
      
               PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmse/rmse_" + str_lower(varID) + "_" \
                            + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                            + "-" + sprinti("%0.4i",EndYear)
      
               titles       = "RMSE for " + str_upper(varID) + " (" + UnitPlots + "): " + ModelNameList(nv) + " against " + Source \
                            + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      
               Draw_Map (PlotFileName, tt_mod(nv,:), slat0, slon0, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                         MinLon, MaxLon, MinLat, MaxLat, SiteID)
            end if
         end do
      
      end if

      delete(i50)
      delete(i51)
   end if

else

   score=new((/nmod+1/), float)
   tt_mod=new((/nmod+1,nyer/), float)

   score  = -999
   tt_mod = -999

   tt0=new((/nyer,nmon/), float)

      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      tt0(iy,im)=ts_obs(ijk)
      ijk=ijk+1
   end do
   end do

   tt0@_FillValue=-999

   numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

   numb = where (numb.gt.1, numb, 0)

   at0=dim_avg(tt0)

   ;if (any(str_lower(varID).eq.(/"burntarea", "nbp"/))) then
   ;   at0=dim_sum(tt0)
   ;end if

   tt_mod(0,:)=at0

   do nv=0, nmod-1
   if (runID(nv).gt.0) then

      tt1=new((/nyer,nmon/), float)

         ijk=0
      do iy=0,nyer-1
      do im=0,nmon-1
         tt1(iy,im)=ts_mod(nv,ijk,0)
         ijk=ijk+1
      end do
      end do

      tt1=where(ismissing(tt0), -999, tt1)

      tt1@_FillValue=-999

      at1=dim_avg(tt1)

      ;if (any(str_lower(varID).eq.(/"burntarea", "nbp"/))) then
      ;   at1=dim_sum(tt1)
      ;end if

      score(nv+1)=dim_rmsd(at1, at0)
      tt_mod(nv+1,:)=at1

      delete(at1)
      delete(tt1)

   end if
   end do

   score!0="mod"
   score&mod=fspan(1,nmod+1,nmod+1)

   tt_mod!0="mod"
   tt_mod!1="time"
   tt_mod&time=fspan(StartYear,EndYear,nyer)

   score@_FillValue  = -999
   tt_mod@_FillValue = -999

   ; ++++++++++ Create a txt file and save results +++++++++++

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmse/rmse_" + str_lower(varID) + "_" \
                 + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                 + sprinti("%0.4i",EndYear) + ".txt"

   print(TableFileName)

   header      = "RMSE for " + str_upper(varID) + " (" + UnitTable + "): Model against " + Source + ", " + \
                 sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList(0:nmod),score(0:nmod)/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   ; ++++++++++ set up parameters for drawing +++++++++++

   DrawInfo = retrieve_DrawInfo (varID, "rmse", Source)

   cnlevels = DrawInfo@cnlevels
   lblabels = DrawInfo@lblabels
   XLab     = DrawInfo@XLab
   YLab     = DrawInfo@YLab
   CLab     = DrawInfo@CLab

   MinLon   = DrawInfo@MinLon
   MaxLon   = DrawInfo@MaxLon
   MinLat   = DrawInfo@MinLat
   MaxLat   = DrawInfo@MaxLat

   XLab     = 1
   YLab     = 1

   ; ++++++++++ Draw global distribution of RMSE +++++++++++

   PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmse/rmse_" + str_lower(varID) \
                + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                + "-" + sprinti("%0.4i",EndYear)

   titles       = "RMSE for " + str_upper(varID) + " (" + UnitTable + "): Model against " + Source + ", " + \
                  sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   Draw_Bar (PlotFileName, ModelNameList, score, tt_mod, tt_mod, titles, \
             XLab, YLab, CLab, MinLon, MaxLon, MinLat, MaxLat, "NoLine")

end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure RmseScore (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, Unit:string,\
                     ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                     SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

MODELTYPE = getenv("MODELTYPE")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=0 
runIDS(1:nmod)=runID

ModelNameList(0) = str_upper(Source)
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac
landm_mod = ts_mod@LandMask

RawMax_mod = ts_mod@RawMax
RawMin_mod = ts_mod@RawMin
RawAvg_mod = ts_mod@RawAvg

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

region    = where(landf_obs.gt.0,1,0)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

; ------- Choose data only in the selected sub-region ------------------------
i50 = ind(slon.ge.min(rlon) .and. slon.le.max(rlon))
j50 = ind(slat.ge.min(rlat) .and. slat.le.max(rlat))

nlon = dimsizes(i50)
nlat = dimsizes(j50)

ts0_obs    = ts_obs(:,j50,i50)
ts0_mod    = ts_mod(:,:,j50,i50)

landf0_obs = landf_obs(j50,i50)
landf0_mod = landf_mod(:,j50,i50)
landm0_mod = landm_mod(:,j50,i50)

area0_obs  = area_obs(j50,i50)
area0_mod  = area_mod(:,j50,i50)

region0    = region(j50,i50)

delete(i50)
delete(j50)

if (str_lower(varID).eq."sst") then
   region0=where(region0.eq.0, 1, 0)
else
   region0=where(region0.gt.0.5, 1, 0)
end if

; -------convert unit of burned area from %/yr back to %/mon ------------------------
if (str_lower(varID).eq."burntarea") then
   results = retrieve_unit (varID, Source)
   ts0_obs = ts0_obs/results
   ts0_mod = ts0_mod/results
   delete(results)
end if

; ------- Set Model Data as missing where the Benchmark is missing -----
score=new((/nmod+1/), float)
tt_mod=new((/nmod+1,nlat,nlon/), float)

score  = -999
tt_mod = -999

if (str_lower(varID@SubGlobe).eq."yes") then
   ts0_obs=where(ts0_obs.le.0, -999, ts0_obs)
else
   do nt=0,ntot-1
      ts0_obs(nt,:,:) =where(region0.gt.0, ts0_obs(nt,:,:), -999)
   end do
end if

ts_obs@_FillValue=-999

ts0_obs!0="time"
ts0_obs!1="lat"
ts0_obs!2="lon"

region1=dim_avg(ts0_obs(lat|:,lon|:,time|:))

region1=where(.not.ismissing(region1),1,0)

;if (str_lower(varID@CarbonYearly).eq."yes") then
;   region1=where(region1.gt.0,1,0)
;else
;   region1=where(.not.ismissing(region1),1,0)
;end if

tt0=new((/nlat,nlon,nmon,nyer/), float)

   ijk=0
do iy=0,nyer-1
do im=0,nmon-1
   tt0(:,:,im,iy)=ts0_obs(ijk,:,:)
   ijk=ijk+1
end do
end do

do iy=0,nyer-1
do im=0,nmon-1
   tt0(:,:,im,iy) =where(region1.gt.0, tt0(:,:,im,iy), -999)
end do
end do

tt0@_FillValue=-999

temp=tt0
temp=where(ismissing(temp), 0, 1)

numb=sum(temp)

delete(temp)

numb = where (numb.gt.1, numb, 0)

tmp0  = dim_avg(tt0)
temp0 = ndtooned(tmp0)

snum=int2flt(dim_num_n(.not.ismissing(tmp0),2))-1
snum=where(snum.le.0, -999, snum)
snum@_FillValue=-999

delete(tmp0)
delete(temp0)
 
if (.not.ismissing(avg(tt0))) then
do nv=0, nmod-1
if (runID(nv).gt.0) then

   area = area0_mod(nv,:,:)

   TempReg = region1
   TempReg = where(landm0_mod(nv,:,:).gt.0, TempReg, 0)

   landfOM = where(landf0_obs.gt.0.0 .and. landf0_mod(nv,:,:).gt.0.0, landf0_mod(nv,:,:), -999)
   landfOM = where(landm0_mod(nv,:,:).gt.0, landfOM, -999)

   landfOM@_FillValue=-999

   TempReg = landfOM
   TempReg@_FillValue=-999

   tt1=new((/nlat,nlon,nmon,nyer/), float)

      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      tt1(:,:,im,iy)=ts0_mod(nv,ijk,:,:)
      ijk=ijk+1
   end do
   end do

   if (str_lower(varID@SubGlobe).eq."yes") then
      tt1=where(ismissing(tt0), -999, tt1)
   end if

   tt1@_FillValue=-999

   tmp0=dim_avg(tt0)
   tmp1=dim_avg(tt1)

   do im=0,nmon-1
      tmp0(:,:,im)=where(ismissing(landfOM), -999, tmp0(:,:,im))
      tmp1(:,:,im)=where(ismissing(landfOM), -999, tmp1(:,:,im))
   end do

   ; -------convert unit from per cell area to per land area ------------------------
   ;if (str_lower(varID@LandOnly).eq."yes") then
   ;   do im=0,nmon-1
   ;      tmp0(:,:,im) = tmp0(:,:,im)/landfOM
   ;      tmp1(:,:,im) = tmp1(:,:,im)/landfOM
   ;   end do
   ;end if

   ;area = area*landfOM

   atObs = dim_avg(tmp0)

   MinObs = min(atObs)
   if (MinObs.le.0 .and. MinObs.ne.-999) then
      atObs1 = atObs - MinObs*varID@MinFC
   else
      atObs1 = atObs
   end if

   sigma0=sqrt(dim_sum(tmp0*tmp0)/snum)

   sigmaObs=sigma0
   ;sigma0=where(sigma0.eq.0, -999, sigma0)

   sigma0@_FillValue=-999

   sigObsM = sum(sigmaObs*area*TempReg)/sum(area*TempReg)

   tmp = dim_rmsd(tmp0, tmp1)

   tmprmse = sum(tmp*area*TempReg)/sum(area*TempReg)

   if (sigObsM.eq.0) then
      tmp=-999
   else

      ;if (str_lower(varID@GSMLocalRefer).eq."yes") then
          ; +++++ Use local reference to calculate RMSE score ++++
          sigmaObs1 = sigmaObs
          sigmaObs1 = where(sigmaObs1.eq.0, -999, sigmaObs1)
          sigmaObs1@_FillValue = -999
          tmp = 1-tmp/sigmaObs1
          tmp = where(sigmaObs.eq.0, 0, tmp)
          delete(sigmaObs1)
      ;else
      ;   ; +++++ Use global mean reference to calculate RSME score ++++
      ;   tmp = 1-tmp/sigObsM
      ;end if

   end if

   tmp@_FillValue=-999

   tmp = exp(tmp)/EE0

   ;tmp = where(tmp.le.0, 0, tmp)
   ;;tmp = where(sigmaObs.eq.0, 0, tmp)
   ;tmp = where (region1.le.0, -999, tmp)

   if (str_lower(varID@MassWeighting).eq."yes") then
      ; +++++ Calculate Global Mean Scores weighted by Mass ++++
      if (str_lower(varID@MassWeightingFC).eq."yes") then
         score(nv+1)=sum(tmp*atObs1*area*TempReg)/sum(atObs1*area*TempReg)
      else
         score(nv+1)=sum(tmp*abs(atObs)*area*TempReg)/sum(abs(atObs)*area*TempReg)
      end if 
   else
      ; +++++ Calculate Global Mean Scores weighted by Area ++++
      score(nv+1)=sum(tmp*area*TempReg)/sum(area*TempReg)
   end if

   tt_mod(nv+1,:,:) = tmp

   ; ++++++ Calculate Global RMSE Scores +++++
   ;temp1 = ndtooned(tmp1)
   ;temp1@_FillValue=-999
   ;
   ;i50    = ind((.not.ismissing(temp0)).and.(.not.ismissing(temp1)))
   ;
   ;sigma1t=sqrt(dim_sum(temp0*temp0)/(int2flt(dimsizes(i50))-1))
   ;
   ;tmpscore = 1 - tmprmse/sigma1t
   ;
   ;tmpscore = where(tmpscore.le.0, 0, tmpscore)
   ;
   ;score(nv+1) = tmpscore
   
   delete(tt1)
   delete(tmp)
   delete(tmp0)
   delete(tmp1)
   delete(area)
   delete(landfOM)
   delete(tmprmse)
   delete(sigma0)
   delete(sigmaObs)
   delete(TempReg)
end if
end do

   score@_FillValue=-999
   tt_mod@_FillValue=-999

   ; ++++++++++ retrieve the units +++++++++++
   UnitInfo  = retrieve_unit (varID, Source)

   UnitTable = UnitInfo@FinalTable
   UnitPlots = UnitInfo@FinalPlots

   ; ++++++++++ set up parameters for drawing +++++++++++

   DrawInfo = retrieve_DrawInfo (varID, "rmsescore", Source)

   cnlevels = DrawInfo@cnlevels
   lblabels = DrawInfo@lblabels
   XLab     = DrawInfo@XLab
   YLab     = DrawInfo@YLab
   CLab     = DrawInfo@CLab

   MinLon   = min(rlon)
   MaxLon   = max(rlon)
   MinLat   = min(rlat)
   MaxLat   = max(rlat)

   if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
      MinLon   = DrawInfo@MinLon
      MaxLon   = DrawInfo@MaxLon
      MinLat   = DrawInfo@MinLat
      MaxLat   = DrawInfo@MaxLat
   end if

   XLab     = 1
   YLab     = 1

   ; ++++++++++ Create a txt file and save results +++++++++++

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmsescore/rmsescore_" + str_lower(varID) + "_" \
                 + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                 + sprinti("%0.4i",EndYear) + ".txt"

   print(TableFileName)

   header      = "RMSE Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                 sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList(0:nmod),score/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   tt_mod!0="mod"
   tt_mod!1="lat"
   tt_mod!2="lon"
   tt_mod&lat=rlat
   tt_mod&lon=rlon
   tt_mod&lon@units="degrees_east"
   tt_mod&lat@units="degrees_north"

   ;----------- Draw Global Distribution of RmseScore -----------------------------------------

   do nv = 1, nmod
   if (runIDS(nv).gt.0) then

      PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmsescore/rmsescore_" \
                   + str_lower(varID) + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" \
                   + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

      titles       = "RMSE Score for " + str_upper(varID) + ": " + ModelNameList(nv) + " against " + Source \
                   + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

      Draw_Map (PlotFileName, tt_mod(nv,:,:), rlat, rlon, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                MinLon, MaxLon, MinLat, MaxLat, SiteID)

   end if
   end do

   ;----------- Draw Global Mean RmseScore -----------------------------------------

   PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmsescore/rmsescore_" + str_lower(varID) \
                + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                + sprinti("%0.4i",EndYear)

   titles       = "RMSE Score for " + str_upper(varID) + " against " + str_upper(Source) + ", " + \
                   sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   Draw_Score (PlotFileName, score, ModelNameList, titles)
end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure RmseScore_site (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, Unit:string,\
                          ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                          SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

nsit=dimsizes(ind(slat.ne.-999))

MODELTYPE = getenv("MODELTYPE")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID

ModelNameList(0) = str_upper(Source)
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

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

;if (nsit.gt.1) then
if (SiteID@NAME.eq."SITES") then

   ts_obs!0="time"
   ts_obs!1="site"   

   if (any(str_lower(Source).eq.(/"noaa.gmd"/))) then

      temp = dim_avg(ts_obs(site|:,time|:)) 

      if (str_upper(MODELTYPE).eq."CLM") then
         i51 = ind(.not.ismissing(temp) .and. LandFracMod.eq.nmod)
      else
         i51 = ind(.not.ismissing(temp))
      end if
   
      delete(temp)

      if (dimsizes(i51).gt.1 .or. .not.ismissing(i51)) then

         nsit0 = dimsizes(i51)

         ts0_obs = new((/ntot, nsit0/), float)
         ts0_mod = new((/nmod, ntot, nsit0/), float)
         slat0   = new((/nsit0/), float)
         slon0   = new((/nsit0/), float)

         if (nsit0.eq.1) then
            ts0_obs(:,0)   = ts_obs(:,i51)
            ts0_mod(:,:,0) = ts_mod(:,:,i51)
            slat0(0)       = slat(i51)
            slon0(0)       = slon(i51)
         else
            ts0_obs(:,0:nsit0-1)   = ts_obs(:,i51)
            ts0_mod(:,:,0:nsit0-1) = ts_mod(:,:,i51)
            slat0(0:nsit0-1)       = slat(i51)
            slon0(0:nsit0-1)       = slon(i51)
         end if

         ts0_obs@_FillValue=-999
         ts0_mod@_FillValue=-999

         ; -------- read biome regions data ----------------

         SubRegName = retrieve_latlon_belt (Source, "zonalmean")

         nreg       = dimsizes(SubRegName)

         LatLon = SubRegName@LatLon

         MinLat = LatLon(0,:)
         MaxLat = LatLon(1,:)
         MinLon = LatLon(2,:)
         MaxLon = LatLon(3,:)

         ShortName = SubRegName
         LongName  = SubRegName@LongName

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

         tts     = new((/nmod+1, nreg, ntot/), float)

         tts   = -999

         tts@_FillValue = -999

         slon0=where(slon0.gt.180, slon0-360, slon0)

         tt0=new((/nsit0,ntot/), float)

         do nt=0,ntot-1
            tt0(:,nt)=ts0_obs(nt,:)
         end do

         tt0@_FillValue=-999

         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

         numb = where(numb.gt.1, numb, 0)

         do nv=0, nmod-1
            if (runID(nv).gt.0) then

               tt1=new((/nsit0,ntot/), float)

               do nt=0,ntot-1
                  tt1(:,nt)=ts0_mod(nv,nt,:)
               end do

               tt1=where(ismissing(tt0), -999, tt1)

               tt1@_FillValue=-999

               reg0=new((/dimsizes(slat0)/), float)

               do nr = 1, nreg

                  j50 = ind((slat0.ge.MinLat(nr-1).and.slat0.le.MaxLat(nr-1)) .and. (slon0.ge.MinLon(nr-1).and.slon0.le.MaxLon(nr-1)))

                  if (dimsizes(j50).gt.1) then
                     tts(0,nr-1,:)       = dim_avg_n(tt0(j50,:), 0)
                     tts(nv+1,nr-1,:)    = dim_avg_n(tt1(j50,:), 0)
                  else
                     if (dimsizes(j50).eq.1 .and. .not.ismissing(j50)) then
                        tts(0,nr-1,:)    = (/tt0(j50, :)/)
                        tts(nv+1,nr-1,:) = (/tt1(j50, :)/)
                     end if
                  end if

                  delete(j50)
               end do

               delete(tt1)
               delete(reg0)
            end if
         end do

         tts@_FillValue = -999

         ; +++ Remove long-term trend from each time series +++
         tts0    = new((/nmod+1, nreg, ntot/), float)

         tts0    = -999 

         xx = fspan(1.,int2flt(nyer),ntot)
         nn = 3

         do nv = 0, nmod
         do ns = 0, nreg-1

            if (dimsizes(.not.ismissing(tts(nv,ns,:))).gt.3) then

               yy01 = tts(nv,ns,:)

               cc0  = lspoly(xx,yy01, 1, nn)
               yy02 = cc0(0) + cc0(1)*xx + cc0(2)*xx^2
               yy02 = yy01-yy02
               delete(cc0)

               tts0(nv,ns,:) = yy02

               delete(yy01)
               delete(yy02)
            end if

         end do
         end do

         ; +++ calculate annual cycle for each time series +++
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

         score=new((/nmod+1/), float)
         tt_mod=new((/nmod+1,nreg/), float)

         score  = -999
         tt_mod = -999

         at0 = tta(0,:,:)
      
         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(at0)))))
      
         numb = where (numb.gt.1, numb, 0)
      
         atObs = dim_avg(at0)
      
         MinObs = min(atObs)
         if (MinObs.le.0 .and. MinObs.ne.-999) then
            atObs1 = atObs - MinObs*varID@MinFC
         else
            atObs1 = atObs
         end if
      
         snum=int2flt(dim_num_n(.not.ismissing(at0),1))-1
         snum=where(snum.le.0, -999, snum)
         snum@_FillValue=-999
      
         sigma0=sqrt(dim_sum(at0*at0)/snum)
      
         sigmaObs=sigma0
         ;sigma0=where(sigma0.eq.0, -999, sigma0)
      
         sigma0@_FillValue=-999
      
         sigObsM = dim_avg(sigmaObs)
      
         do nv=1, nmod
         if (runIDS(nv).gt.0) then
      
            at1=tta(nv,:,:)
      
            tmp = dim_rmsd(at0, at1)
      
            tmprmse = avg(tmp)
      
            if (sigObsM.eq.0) then
               tmp = -999
            else
               ;if (str_lower(varID@GSMLocalRefer).eq."yes") then
                   ; +++++ Use local reference to calculate RMSE score ++++
                   sigmaObs1 = sigmaObs
                   sigmaObs1 = where(sigmaObs1.eq.0, -999, sigmaObs1)
                   sigmaObs1@_FillValue = -999
                   tmp = 1-tmp/sigmaObs1
                   tmp = where(sigmaObs.eq.0, 0, tmp)
                   delete(sigmaObs1)
               ;else
               ;   ; +++++ Use global mean reference to calculate RMSE score ++++
               ;    tmp = 1-tmp/sigObsM
               ;end if
      
            end if
      
            ;tmp = where(tmp.le.0, 0, tmp)
            ;tmp = where(sigmaObs.eq.0, 0, tmp)
      
            tmp@_FillValue=-999
      
            tmp = exp(tmp)/EE0
      
            if (str_lower(varID@MassWeighting).eq."yes") then
               ; +++++ Calculate Global Mean Scores weighted by Mass ++++
               if (str_lower(varID@MassWeightingFC).eq."yes") then
                  score(nv)=dim_sum(tmp*atObs1)/dim_sum(atObs1)
               else
                  score(nv)=dim_sum(tmp*abs(atObs))/dim_sum(abs(atObs))
               end if
            else
               ; +++++ Calculate Global Mean Scores weighted by Area ++++
               score(nv)=dim_avg(tmp)
            end if
      
            tt_mod(nv,:)=tmp
      
            ; ++++++ Calculate Global RMSE Scores +++++
            ;temp1 = ndtooned(tmp1)
            ;temp1@_FillValue=-999
            ;
            ;j50   = ind((.not.ismissing(temp0)).and.(.not.ismissing(temp1)))
            ;
            ;;tmpscore = 1 - dim_rmsd(temp0(j50),temp1(j50))/dim_stddev(temp0(j50))
            ;
            ;sigma1t=sqrt(dim_sum(temp0*temp0)/(int2flt(dimsizes(j50))))
            ;
            ;tmpscore = 1 - tmprmse/sigma1t
            ;
            ;tmpscore = where(tmpscore.le.0, 0, tmpscore)
      
            ;;score(nv+1) = tmpscore
         
            delete(at1)
            delete(tmp)
            delete(tmprmse)
         end if
         end do
      
         delete(snum)
         delete(at0)
         delete(sigma0)
         delete(sigmaObs)

         tt_mod@_FillValue    = -999

         ; ++++++++++ Create a txt file and save results +++++++++++

         TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmsescore/rmsescore_" + str_lower(varID) \
                       + "_" + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                       + sprinti("%0.4i",EndYear) + ".txt"

         print(TableFileName)

         header      = "RMSE Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                       sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         write_table(TableFileName, "w", [/header/], "%s")
         write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
         write_table(TableFileName,"a",[/ModelNameList(0:nmod),score(0:nmod)/], "%16s %10.2f")

         ;print(asciiread(TableFileName,-1,"string"))

         ; ++++++++++ set up parameters for drawing +++++++++++

         DrawInfo  = retrieve_DrawInfo (varID, "rmsescore", Source)

         cnlevels = DrawInfo@cnlevels
         lblabels = DrawInfo@lblabels

         SubRegName = retrieve_latlon_belt (Source, "zonalmean")

         nreg       = dimsizes(SubRegName)

         LatLon = SubRegName@LatLon

         MinLat = LatLon(0,:)
         MaxLat = LatLon(1,:)
         MinLon = LatLon(2,:)
         MaxLon = LatLon(3,:)

         cLats  = (MinLat+MaxLat)/2

         do ns =0, nreg-1
            if (cLats(ns).lt.0) then
               TmpStr1 = sprintf("%.0f",floor(abs(cLats(ns)))) + "S"
            else
               TmpStr1 = sprintf("%.0f",floor(cLats(ns))) + "N"
            end if

            LongName(ns)  = TmpStr1
         end do

         cLats@lblabels = LongName

         nmodels = fspan(1.,int2flt(nmod+1),nmod+1)
         nmodels@lblabels = ModelNameList(::-1)

         tt_mod = tt_mod(::-1,:)

         CLab         = 1
         XLab         = 1
         YLab         = 1

         ; ++++++++++ Draw global distribution of RMSE Score +++++++++++

         tt_mod@_FillValue = -999

         tt_mod!0="mod"
         tt_mod!1="lat"
         tt_mod&mod=nmodels
         tt_mod&lat=cLats
         tt_mod&lat@units="degrees_north"

         PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmsescore/rmsescore_" + str_lower(varID) \
                      + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) \
                      + "-" + sprinti("%0.4i",EndYear)

         titles       = "RMSE Score for " + str_upper(varID) + ": Model against " + Source \
                      + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

         ;Draw_Table_Scores (PlotFileName, ModelNameList, runIDS, ttt_mod, cnlevels1, cnlevels2, lblabels1, lblabels2, \
         ;                   titles1, titles2, cLats)

         Draw_LatLon_Time (PlotFileName, tt_mod, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                           nmodels, cLats)

         delete(tta)
         delete(tts)
         delete(ttt)
         delete(tts0)
         delete(ts0_obs)
         delete(ts0_mod)
      end if

      delete(i51)

   else

      i50 = ind((slon.ge.min(rlon) .and. slon.le.max(rlon)) .and. (slat.ge.min(rlat) .and. slat.le.max(rlat)))

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
   
      delete(temp)
  
      if (dimsizes(i51).gt.1 .or. .not.ismissing(i51)) then
      
         nsit0 = dimsizes(i51)
      
         ts0_obs = new((/ntot, nsit0/), float)
         ts0_mod = new((/nmod, ntot, nsit0/), float)
         slat0   = new((/nsit0/), float)
         slon0   = new((/nsit0/), float)
      
         if (nsit0.eq.1) then
            ts0_obs(:,0)   = ts_obs(:,i50(i51))
            ts0_mod(:,:,0) = ts_mod(:,:,i50(i51))
            slat0(0)       = slat(i50(i51))
            slon0(0)       = slon(i50(i51))
         else
            ts0_obs(:,0:nsit0-1)   = ts_obs(:,i50(i51))
            ts0_mod(:,:,0:nsit0-1) = ts_mod(:,:,i50(i51))
            slat0(0:nsit0-1)       = slat(i50(i51))
            slon0(0:nsit0-1)       = slon(i50(i51))
         end if
      
         ; -------convert unit of burned area from %/yr back to %/mon ------------------------
         if (str_lower(varID).eq."burntarea") then
            results = retrieve_unit (varID, Source)
            ts0_obs = ts0_obs/results
            ts0_mod = ts0_mod/results
            delete(results)
         end if
      
         score=new((/nmod+1/), float)
         tt_mod=new((/nmod+1,nsit0/), float)
      
         score  = -999
         tt_mod = -999
      
         slon0=where(slon0.gt.180, slon0-360, slon0)
      
         tt0=new((/nsit0,nmon,nyer/), float)
      
            ijk=0
         do iy=0,nyer-1
         do im=0,nmon-1
            tt0(:,im,iy)=ts0_obs(ijk,:)
            ijk=ijk+1
         end do
         end do
      
         tt0@_FillValue=-999
      
         numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))
      
         numb = where (numb.gt.1, numb, 0)
      
         tmp0  = dim_avg(tt0)
         atObs = dim_avg(tmp0)
         temp0 = ndtooned(tmp0)
      
         MinObs = min(atObs)
         if (MinObs.le.0 .and. MinObs.ne.-999) then
            atObs1 = atObs - MinObs*varID@MinFC
         else
            atObs1 = atObs
         end if
      
         snum=int2flt(dim_num_n(.not.ismissing(tmp0),1))-1
         snum=where(snum.le.0, -999, snum)
         snum@_FillValue=-999
      
         sigma0=sqrt(dim_sum(tmp0*tmp0)/snum)
      
         sigmaObs=sigma0
         ;sigma0=where(sigma0.eq.0, -999, sigma0)
      
         sigma0@_FillValue=-999
      
         sigObsM = dim_avg(sigmaObs)
      
         do nv=0, nmod-1
         if (runID(nv).gt.0) then
      
            tt1=new((/nsit0,nmon,nyer/), float)
      
               ijk=0
            do iy=0,nyer-1
            do im=0,nmon-1
               tt1(:,im,iy)=ts0_mod(nv,ijk,:)
               ijk=ijk+1
            end do
            end do
      
            tt1=where(ismissing(tt0), -999, tt1)
      
            tt1@_FillValue=-999
      
            tmp1=dim_avg(tt1)
      
            tmp = dim_rmsd(tmp0, tmp1)
      
            tmprmse = avg(tmp)
      
            if (sigObsM.eq.0) then
               tmp = -999
            else
      
               ;if (str_lower(varID@GSMLocalRefer).eq."yes") then
                   ; +++++ Use local reference to calculate RMSE score ++++
                   sigmaObs1 = sigmaObs
                   sigmaObs1 = where(sigmaObs1.eq.0, -999, sigmaObs1)
                   sigmaObs1@_FillValue = -999
                   tmp = 1-tmp/sigmaObs1
                   tmp = where(sigmaObs.eq.0, 0, tmp)
                   delete(sigmaObs1)
               ;else
               ;   ; +++++ Use global mean reference to calculate RMSE score ++++
               ;    tmp = 1-tmp/sigObsM
               ;end if
      
            end if
      
            ;tmp = where(tmp.le.0, 0, tmp)
            ;tmp = where(sigmaObs.eq.0, 0, tmp)
      
            tmp@_FillValue=-999
            tmp1@_FillValue=-999
      
            tmp = exp(tmp)/EE0
      
            if (str_lower(varID@MassWeighting).eq."yes") then
               ; +++++ Calculate Global Mean Scores weighted by Mass ++++
               if (str_lower(varID@MassWeightingFC).eq."yes") then
                  score(nv+1)=dim_sum(tmp*atObs1)/dim_sum(atObs1)
               else
                  score(nv+1)=dim_sum(tmp*abs(atObs))/dim_sum(abs(atObs))
               end if
            else
               ; +++++ Calculate Global Mean Scores weighted by Area ++++
               score(nv+1)=dim_avg(tmp)
            end if
      
            tt_mod(nv+1,:)=tmp
      
            ; ++++++ Calculate Global RMSE Scores +++++
            ;temp1 = ndtooned(tmp1)
            ;temp1@_FillValue=-999
            ;
            ;j50   = ind((.not.ismissing(temp0)).and.(.not.ismissing(temp1)))
            ;
            ;;tmpscore = 1 - dim_rmsd(temp0(j50),temp1(j50))/dim_stddev(temp0(j50))
            ;
            ;sigma1t=sqrt(dim_sum(temp0*temp0)/(int2flt(dimsizes(j50))))
            ;
            ;tmpscore = 1 - tmprmse/sigma1t
            ;
            ;tmpscore = where(tmpscore.le.0, 0, tmpscore)
      
            ;;score(nv+1) = tmpscore
         
            delete(tt1)
            delete(tmp)
            delete(tmp1)
            delete(tmprmse)
         end if
         end do
      
         delete(snum)
         delete(tmp0)
         delete(temp0)
         delete(sigma0)
         delete(sigmaObs)
      
         tt_mod!0="mod"
         tt_mod!1="site"
      
         score@_FillValue=-999
         tt_mod@_FillValue=-999
      
         score!0="mod"
         score&mod=fspan(1,nmod+1,nmod+1)
      
         ; ++++++++++ Create a txt file and save results +++++++++++
      
         TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmsescore/rmsescore_" + str_lower(varID) + "_" \
                       + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                       + sprinti("%0.4i",EndYear) + ".txt"
      
         print(TableFileName)
      
         header      = "RMSE Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                       sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      
         write_table(TableFileName, "w", [/header/], "%s")
         write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
         write_table(TableFileName,"a",[/ModelNameList(0:nmod),score/], "%16s %10.2f")
      
         ;print(asciiread(TableFileName,-1,"string"))
      
         ; ++++++++++ set up parameters for drawing +++++++++++
      
         DrawInfo = retrieve_DrawInfo (varID, "rmsescore", Source)
      
         cnlevels = DrawInfo@cnlevels
         lblabels = DrawInfo@lblabels
         XLab     = DrawInfo@XLab
         YLab     = DrawInfo@YLab
         CLab     = DrawInfo@CLab
      
         MinLon   = min(rlon)
         MaxLon   = max(rlon)
         MinLat   = min(rlat)
         MaxLat   = max(rlat)
      
         if (str_lower(varID@SubGlobe).eq."yes" .and. str_lower(SubReg).eq."global") then
            MinLon   = DrawInfo@MinLon
            MaxLon   = DrawInfo@MaxLon
            MinLat   = DrawInfo@MinLat
            MaxLat   = DrawInfo@MaxLat
         end if
      
         XLab     = 1
         YLab     = 1
      
         ;----------- Draw Global distribution of RmseScore -----------------------------------------
      
         do nv = 1, nmod
      
            if (runIDS(nv).gt.0) then
      
               tt_mod@_FillValue = -999
      
               PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmsescore/rmsescore_" \
                            + str_lower(varID) + "_" + ModelNameList(nv) + ".vs." + str_upper(Source) + "_" \
                            + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      
               titles       = "RMSE Score for " + str_upper(varID) + ": " + ModelNameList(nv) + " against " + Source \
                            + ", " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      
               Draw_Map (PlotFileName, tt_mod(nv,:), slat0, slon0, titles, cnlevels, lblabels, XLab, YLab, CLab, \
                         MinLon, MaxLon, MinLat, MaxLat, SiteID)
      
            end if
         end do
      
         ;----------- Draw Global Mean Rmse Score -----------------------------------------
      
         PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmsescore/rmsescore_" + str_lower(varID) \
                      + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                      + sprinti("%0.4i",EndYear)
      
         titles       = "RMSE Score for " + str_upper(varID) + " against " + str_upper(Source) + ", " + \
                         sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
      
         Draw_Score (PlotFileName, score, ModelNameList, titles)

      end if

      delete(i50)
      delete(i51)
   end if

else

   score=new((/nmod+1/), float)
   tt_mod=new((/nmod+1,nyer/), float)

   score  = -999
   tt_mod = -999

   tt0=new((/nyer,nmon/), float)

      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      tt0(iy,im)=ts_obs(ijk)
      ijk=ijk+1
   end do
   end do

   tt0@_FillValue=-999

   numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

   numb = where (numb.gt.1, numb, 0)

   tmp0=dim_avg(tt0)

   sigma0=sqrt(dim_sum(tmp0*tmp0)/(int2flt(dimsizes(ind(.not.ismissing(tmp0))))-1))

   sigma0@_FillValue=-999

   do nv=0, nmod-1
   if (runID(nv).gt.0) then

      tt1=new((/nyer,nmon/), float)

         ijk=0
      do iy=0,nyer-1
      do im=0,nmon-1
         tt1(iy,im)=ts_mod(nv,ijk,0)
         ijk=ijk+1
      end do
      end do

      tt1=where(ismissing(tt0), -999, tt1)

      tt1@_FillValue=-999

      tmp1=dim_avg(tt1)

      ;if (any(str_lower(varID).eq.(/"burntarea", "nbp"/))) then
      ;   tmp0=dim_sum(tt0)
      ;   tmp1=dim_sum(tt1)
      ;end if

      tmp = dim_rmsd(tmp0, tmp1)

      tmp = 1-tmp/sigma0

      tmp = exp(tmp)/EE0

      ;tmp=where(tmp.le.0, 0, tmp)

      score(nv+1)=tmp

      tt_mod(0,:)    = tmp0
      tt_mod(nv+1,:) = tmp1
   
      delete(tt1)
      delete(tmp)
      delete(tmp1)
   end if
   end do

   delete(tmp0)
   delete(sigma0)

   score!0="mod"
   score&mod=fspan(1,nmod+1,nmod+1)

   tt_mod!0="mod"
   tt_mod!1="time"
   tt_mod&time=fspan(StartYear,EndYear,nyer)

   score@_FillValue=-999
   tt_mod@_FillValue=-999

   ; ++++++++++ Create a txt file and save results +++++++++++

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmsescore/rmsescore_" + str_lower(varID) + "_" \
                 + "CMIP5" + ".vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                 + sprinti("%0.4i",EndYear) + ".txt"

   print(TableFileName)

   header      = "Rmse Score for " + str_upper(varID) + ": Model against " + Source + ", " + \
                 sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList(0:nmod),score/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   ; ++++++++++ set up parameters for drawing +++++++++++

   DrawInfo = retrieve_DrawInfo (varID, "rmsescore", Source)

   cnlevels = DrawInfo@cnlevels
   lblabels = DrawInfo@lblabels
   XLab     = DrawInfo@XLab
   YLab     = DrawInfo@YLab
   CLab     = DrawInfo@CLab

   MinLon   = DrawInfo@MinLon
   MaxLon   = DrawInfo@MaxLon
   MinLat   = DrawInfo@MinLat
   MaxLat   = DrawInfo@MaxLat

   XLab     = 1
   YLab     = 1

   ;----------- Draw Global Mean Rmse Score -----------------------------------------

   PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/rmsescore/rmsescore_" + str_lower(varID) \
                + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                + sprinti("%0.4i",EndYear)

   titles       = "RMSE Score for " + str_upper(varID) + " against " + str_upper(Source) + ", " + \
                   sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   Draw_Score (PlotFileName, score, ModelNameList, titles)

end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure summary (ModelNames:string, varID:string, Sources:string, VarUnit:string, \
                   KeyWords:string, StartYears:integer, EndYears:integer)

begin

MODELTYPE = getenv("MODELTYPE")
DataDir   = getenv("ILAMB_ROOT")

nmod      = dimsizes(ModelNames)
nkey     = dimsizes(KeyWords)
nsur      = dimsizes(Sources)

ModelNameList=new((/nmod+1/), string)
ModelNameList(0)="Benchmark"
ModelNameList(1:nmod)=ModelNames

; +++++++ read annualmean from file saved +++++++++++
if (nsur.gt.1) then
   LongSourceNames = new((/nsur/), string)
   numbs           = new((/nkey/), float)
   numb0           = new((/nkey,nsur/), float)
   scores          = new((/nkey, nmod+1/), float)
   score0          = new((/nkey, nmod+1, nsur/), float)
   Unit0           = new((/nkey, nsur/), string)
   wt              = new((/nsur/), float)

   scores          = -999.
   score0          = -999.
   wt              = 0.0
   Unit0           = "N/A"

   numbs           = 0.
   numb0           = 0.

   scores@_FillValue=-999.
   score0@_FillValue=-999.

   do ns=0,nsur-1
      do nk=0,nkey-1
         FileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/" + str_lower(KeyWords(nk)) \
                  + "/" + str_lower(KeyWords(nk)) + "_" + str_lower(varID) + "_" + "CMIP5.vs." + str_upper(Sources(ns)) \
                  + "_" + sprinti("%0.4i",StartYears(ns)) + "-" + sprinti("%0.4i",EndYears(ns)) + ".txt"

         if (fileexists(FileName)) then
            print(FileName)
            ;print(asciiread(FileName,-1,"string"))

            data_1d = asciiread(FileName,-1,"string")
            numb0(nk,ns) = stringtofloat(str_get_field(data_1d(1), 2, ":"))
            score0(nk,:,ns) = stringtofloat(str_get_field(data_1d(2:), 2, " "))

            strings = str_squeeze(str_get_field(data_1d(0), 2, "("))
            if (.not.ismissing(strings)) then
               Unit0(nk,ns) = str_get_field(strings, 1, ")")
            end if

            delete(strings)
            delete(data_1d)
         end if

         ; +++++++ retrieve weighting for sources +++++++++++
         if (any(.not.ismissing(score0(nkey-1,:,ns)))) then
            results          = retrieve_weight (varID, Sources(ns))
            wt(ns)           = results@Certainty * results@Scale

            delete(results)
         end if
         DataInfo            = retrieve_DataInfo (varID, Sources(ns))
         LongSourceNames(ns) = DataInfo@DataName
         delete(DataInfo)
      end do

      ; ++++ retrieve the unit ++++++
      UnitInfo = retrieve_unit(varID, Sources(ns))
      VarUnit  = UnitInfo@FinalTable

      ; $$$$$$$$$$$$$$$$$$$$$$ Remove metrics with all missing Data $$$$$$$$$$$$$$$$$$$$$$$

      score0@_FillValue=-999

      ;KeyID = new((/nkeys/), integer)
      ;
      ;KeyID = 1
      ;
      ;do j=0, nkeys-1
      ;   j50 = ind(ismissing(score0(j,:,ns)))
      ;   if (dimsizes(j50).eq.nmod+1) then
      ;      KeyID(j) = 0
      ;   end if
      ;   delete(j50)
      ;end do
      ;
      ;i50 = ind(KeyID.eq.1)
      ;
      ;nkey    = dimsizes(i50)

      ; $$$$$$$$$$$$$$$$$$$$$$ create and save summary for individual variable $$$$$$$$$$$$$$$$$$$$$$$

      header=new((/6/), string)

      TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/summary/summary_" + str_lower(varID) + "_" + "CMIP5.vs." + \
                      str_upper(Sources(ns)) + "_" + sprinti("%0.4i",StartYears(ns)) + "-" + sprinti("%0.4i",EndYears(ns)) + ".txt"

      print(TableFileName)

      header(0) = "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      header(1) = "Variable Name: " + str_upper(varID) 
      header(2) = "Variable Unit: " + str_upper(VarUnit) 
      header(3) = "       Source: " + str_upper(Sources(ns))
      header(4) = "       Period: " + sprinti("%0.4i",StartYears(ns)) + "-" + sprinti("%0.4i",EndYears(ns))
      header(5) = "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

      FORMAT1 = str_concat(conform_dims(nkey+1,"%16s",-1))
      FORMAT2 = "%16s" + str_concat(conform_dims(nkey,"%16.2f",-1))

      ; +++++++++  save header of a table ++++++++++++++
      label1  = "Model_Name"  
      dtmp    = True   
      ctitles = NewList("lifo")

      do j=nkey-1,0,1
         ;j = i50(jj)
         ListPush(ctitles,(/KeyWords(j)/))
      end do    

      str1 = unique_string("test")
      dtmp@$str1$ = label1
      ListPush(ctitles,dtmp@$str1$)

      write_table(TableFileName, "w", [/header/], "%s")
      write_table(TableFileName, "a", ctitles, FORMAT1)

      ; +++++++++  save No. of Data ++++++++++++++
      label2 = "No._of_DATA"  
      cnumbs = NewList("lifo")

      do j=nkey-1,0,1
         ;j = i50(jj)
         ListPush(cnumbs,(/numb0(j,ns)/))
      end do    

      str2 = unique_string("test")
      dtmp@$str2$ = label2
      ListPush(cnumbs,dtmp@$str2$)

      write_table(TableFileName, "a", cnumbs, FORMAT2)

      ; +++++++++  save Unit for each metrics ++++++++++++++
      label3 = "Unit"  
      cunits = NewList("lifo")

      do j=nkey-1,0,1
         ;j = i50(jj)
         ListPush(cunits,(/Unit0(j,ns)/))
      end do    

      str3 = unique_string("test")
      dtmp@$str3$ = label3
      ListPush(cunits,dtmp@$str3$)

      write_table(TableFileName, "a", cunits, FORMAT1)

      ; +++++++++  save diagnostic results  ++++++++++++++
      do nv=0,nmod
         label4 = ModelNameList(nv)
         cscores = NewList("lifo")
         str4 = unique_string("test")

         do j=nkey-1,0,1
            ;j = i50(jj)
            ListPush(cscores,(/score0(j,nv,ns)/))
         end do    

         dtmp@$str4$ = label4
         ListPush(cscores,dtmp@$str4$)

         write_table(TableFileName, "a", cscores, FORMAT2)
      end do

      print("Summary of Your selected Diagnostics")
      print(asciiread(TableFileName,-1,"string"))

      ;delete(i50)
      ;delete(KeyID)
   end do

   do nk=0,nkey-1
   do nv=0,nmod
      temp = score0(nk,nv,:)
      temp@_FillValue = -999
      i50 = ind(.not.ismissing(temp))
      if (dimsizes(i50).gt.1 .or. .not.ismissing(i50)) then
         scores(nk,nv)=sum(temp(i50)*wt(i50))/sum(wt(i50))
      else
         scores(nk,nv)=-999
      end if
      delete(i50)
      delete(temp)
   end do
   end do

   numbs=dim_sum(numb0)

   Units=Unit0(:,0)

   delete(numb0)
   delete(Unit0)
   delete(score0)

else

   numbs  = new((/nkey/), float)
   scores = new((/nkey, nmod+1/), float)
   Units  = new((/nkey/), string)

   scores = -999.
   numbs  = 0.

   Units="N/A"

   ; ++++ retrieve the unit ++++++
   UnitInfo = retrieve_unit (varID, Sources)
   VarUnit  = UnitInfo@FinalTable

   do nk=0,nkey-1
      FileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/" + str_lower(KeyWords(nk)) \ 
               + "/" + str_lower(KeyWords(nk)) + "_" + str_lower(varID) + "_" + "CMIP5.vs." + str_upper(Sources)  \
               + "_" + sprinti("%0.4i",StartYears) + "-" + sprinti("%0.4i",EndYears) + ".txt"

      if (fileexists(FileName)) then
         print(FileName)
         ;print(asciiread(FileName,-1,"string"))

         data_1d = asciiread(FileName,-1,"string")
         numbs(nk) = stringtofloat(str_get_field(data_1d(1), 2, ":"))
         scores(nk,:) = stringtofloat(str_get_field(data_1d(2:), 2, " "))

         strings = str_get_field(data_1d(0), 2, "(")
         if (.not.ismissing(strings)) then
            Units(nk) = str_get_field(strings, 1, ")")
         end if

         delete(strings)
         delete(data_1d)
      end if
   end do
end if
   
; $$$$$$$$$$$$$$$$$$$$$$ create and save mean summary for individual variable $$$$$$$$$$$$$$$$$$$$$$$

if (nsur.gt.1) then
   Source=Sources(0)
   do ns=1,nsur-1
      Source=Source + "+" + Sources(ns)
   end do
   StartYear = min(StartYears)
   EndYear   = max(EndYears)
else
   Source=Sources
   StartYear = StartYears
   EndYear   = EndYears
end if

scores@_FillValue=-999

header=new((/6/), string)

TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/summary/summary_" + str_lower(varID) \
              + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".txt"

print(TableFileName)

header(0) = "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
header(1) = "Variable Name: " + str_upper(varID) 
header(2) = "Variable Unit: " + str_upper(VarUnit) 
header(3) = "       Source: " + str_upper(Source)
header(4) = "       Period: " + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
header(5) = "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

FORMAT1 = str_concat(conform_dims(nkey+1,"%16s",-1))
FORMAT2 = "%16s" + str_concat(conform_dims(nkey,"%16.2f",-1))

; +++++++++  save header of a table ++++++++++++++
label1 = "Model_Name"  
dtmp = True   
ctitles = NewList("lifo")

do j=nkey-1,0,1
   ListPush(ctitles,(/KeyWords(j)/))
end do    

str1 = unique_string("test")
dtmp@$str1$ = label1
ListPush(ctitles,dtmp@$str1$)

write_table(TableFileName, "w", [/header/], "%s")
write_table(TableFileName, "a", ctitles, FORMAT1)

; +++++++++  save No. of Data ++++++++++++++
label2 = "No._of_DATA"  
cnumbs = NewList("lifo")

do j=nkey-1,0,1
   ListPush(cnumbs,(/numbs(j)/))
end do    

str2 = unique_string("test")
dtmp@$str2$ = label2
ListPush(cnumbs,dtmp@$str2$)

write_table(TableFileName, "a", cnumbs, FORMAT2)

; +++++++++  save Unit for each metrics ++++++++++++++
label3 = "Unit"  
cunits = NewList("lifo")

do j=nkey-1,0,1
   ListPush(cunits,(/Units(j)/))
end do    

str3 = unique_string("test")
dtmp@$str3$ = label3
ListPush(cunits,dtmp@$str3$)

write_table(TableFileName, "a", cunits, FORMAT1)

; +++++++++  save diagnostic results  ++++++++++++++
do nv=0,nmod
   label4 = ModelNameList(nv)
   cscores = NewList("lifo")
   str4 = unique_string("test")

   do j=nkey-1,0,1
      ListPush(cscores,(/scores(j,nv)/))
   end do    

   dtmp@$str4$ = label4
   ListPush(cscores,dtmp@$str4$)

   write_table(TableFileName, "a", cscores, FORMAT2)
end do

delete(header)
print("Summary of Your selected Diagnostics")
print(asciiread(TableFileName,-1,"string"))

if (nsur.gt.1) then

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/overallscore/overallscore_" + str_lower(varID) \
                 + "_" + "CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".txt"

   header = "Overall Score for " + str_upper(varID) + " against " + str_upper(Source)

   i50 = ind(str_lower(KeyWords).eq."overallscore")

   if (.not.ismissing(i50)) then
      print(TableFileName)
      write_table(TableFileName,"w", [/header/], "%s")
      write_table(TableFileName,"a",[/"No._of_DATA: ", numbs(i50)/], "%16s %10.2f")
      write_table(TableFileName,"a",[/ModelNameList,scores(i50,:)/], "%16s %10.2f")
   end if

   ;print(asciiread(TableFileName,-1,"string"))

   ; ++++++++++ Create a txt file and save Weighting for benchmark sources +++++++++++

   ;wt=wt*100/sum(wt)

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/overallscore/weights_" + str_lower(varID) + "_Sources.txt"

   print(TableFileName)

   header = "Contributions from benchmark sources for the variable " + str_upper(varID) + " against " + str_upper(Source)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"Benchmark Sources", "Weights"/], "%50s %16s") 
   write_table(TableFileName,"a",[/LongSourceNames+":",wt/], "%50s %16.0f")

   ;print(asciiread(TableFileName,-1,"string"))

   ;----------- Draw Overall Score for individual variable -----------------------------------------

   PlotFileName = "../OUTPUT/" + str_lower(varID) + "/overallscore/overallscore_" + str_lower(varID) \
                + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                + sprinti("%0.4i",EndYear)

   titles       = "Overall score for " + str_upper(varID) + " against " + str_upper(Source) + ", " + \
                  sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   Draw_Score (PlotFileName, scores(i50,:), ModelNameList, titles)
end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure TaylorScore (DataDir:string, ModelNames:string, runID:integer, varID:string, Source:string, Unit:string, \
                       ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                       SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

MODELTYPE = getenv("MODELTYPE")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=0
runIDS(1:nmod)=runID

ModelNameList(0) = Source
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac
landm_mod = ts_mod@LandMask

RawMax_mod = ts_mod@RawMax
RawMin_mod = ts_mod@RawMin
RawAvg_mod = ts_mod@RawAvg

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

region    = where(landf_obs.gt.0,1,0)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

; ------- Choose data only in the selected sub-region ------------------------
i50 = ind(slon.ge.min(rlon) .and. slon.le.max(rlon))
j50 = ind(slat.ge.min(rlat) .and. slat.le.max(rlat))

nlon = dimsizes(i50)
nlat = dimsizes(j50)

ts0_obs    = ts_obs(:,j50,i50)
ts0_mod    = ts_mod(:,:,j50,i50)

landf0_obs = landf_obs(j50,i50)
landf0_mod = landf_mod(:,j50,i50)
landm0_mod = landm_mod(:,j50,i50)

area0_obs  = area_obs(j50,i50)
area0_mod  = area_mod(:,j50,i50)

region0    = region(j50,i50)

delete(i50)
delete(j50)

if (str_lower(varID).eq."sst") then
   region0=where(region0.eq.0, 1, 0)
else
   region0=where(region0.gt.0.5, 1, 0)
end if

; ------- Set Model Data as missing where the Benchmark is missing -----

if (str_lower(varID@SubGlobe).eq."yes") then
   ts0_obs=where(ts0_obs.le.0, -999, ts0_obs)
else
   do nt=0,ntot-1
      ts0_obs(nt,:,:) =where(region0.gt.0, ts0_obs(nt,:,:), -999)
   end do
end if

ts0_obs@_FillValue=-999

ts0_obs!0="time"
ts0_obs!1="lat"
ts0_obs!2="lon"

ts0_mod!0="mod"
ts0_mod!1="time"
ts0_mod!2="lat"
ts0_mod!3="lon"

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

temp=ts0_obs
temp=where(ismissing(temp), 0, 1)

numb=sum(temp)
delete(temp)

; ------- read CMIP5 model simulation -----
ratio=new((/nmod+1,2/), float)
cc   =new((/nmod+1,2/), float)
score=new((/nmod+1/), float)

score =-999

if (.not.ismissing(avg(ts0_obs))) then
do nv=0, nmod-1
if (runID(nv).gt.0) then

   area = area0_mod(nv,:,:)

   TempReg = region1
   TempReg = where(landm0_mod(nv,:,:).gt.0, TempReg, 0)

   landfOM = where(landf0_obs.gt.0.0 .and. landf0_mod(nv,:,:).gt.0.0, landf0_mod(nv,:,:), -999)
   landfOM = where(landm0_mod(nv,:,:).gt.0, landfOM, -999)

   landfOM@_FillValue=-999

   TempReg = landfOM
   TempReg@_FillValue=-999

   tt0=ts0_obs(lat|:,lon|:,time|:)
   tt1=ts0_mod(lat|:,lon|:,time|:,mod|nv)

   tt0@_FillValue=-999
   tt1@_FillValue=-999

   if (str_lower(varID@SubGlobe).eq."yes") then
      tt1=where(ismissing(tt0), -999, tt1)
   end if

   if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
      at0 = sqrt(dim_avg(tt0*tt0))
      at1 = sqrt(dim_avg(tt1*tt1))
   else
      at0 = dim_avg(tt0)
      at1 = dim_avg(tt1)
   end if

   at0=where(ismissing(landfOM), -999, at0)
   at1=where(ismissing(landfOM), -999, at1)

   at0@_FillValue=-999
   at1@_FillValue=-999

   ; -------convert unit from per cell area to per land area ------------------------
   ;if (str_lower(varID@LandOnly).eq."yes") then
   ;   at0 = at0/landfOM
   ;   at1 = at1/landfOM
   ;end if

   ;area = area*landfOM

   ts0=ndtooned(at0)
   ts1=ndtooned(at1)
   area1d=ndtooned(area)

   ts0@_FillValue=-999
   ts1@_FillValue=-999

   i50=ind(.not.ismissing(ts0) .and. .not.ismissing(ts1))

   area1d(i50)=area1d(i50)/avg(area1d(i50))

   ts0(i50) = dim_rmvmean(ts0(i50))
   ts1(i50) = dim_rmvmean(ts1(i50))

   rmsd=dim_rmsd(ts0(i50)*area1d(i50), ts1(i50)*area1d(i50))

   mxlag=0
   corr0  = esccr(ts0(i50)*area1d(i50), ts1(i50)*area1d(i50), mxlag)
   corr=corr0(0)
   delete(corr0)

   stdev0=dim_stddev(ts0(i50)*area1d(i50))
   stdev1=dim_stddev(ts1(i50)*area1d(i50))

   cc(nv+1,:)   =corr
   ratio(nv+1,:)=stdev1/stdev0

   ;stdev0=stdev0*stdev0+avg(ts0(i50)*area1d(i50))*avg(ts0(i50)*area1d(i50))
   ;stdev1=stdev1*stdev1+avg(ts1(i50)*area1d(i50))*avg(ts1(i50)*area1d(i50))

   ;stdev0=sqrt(stdev0)
   ;stdev1=sqrt(stdev1)

   score(nv+1)=2*(1.0+corr)/((stdev0/stdev1+stdev1/stdev0)^2)

   delete(i50)
   delete(at0)
   delete(at1)
   delete(ts0)
   delete(ts1)
   delete(tt0)
   delete(tt1)
   delete(area)
   delete(area1d)
   delete(landfOM)
   delete(TempReg)
end if
end do

   cc@_FillValue    = -999
   ratio@_FillValue = -999
   score@_FillValue = -999

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/taylorscore/taylorscore_" + str_lower(varID) \
                 + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                 + sprinti("%0.4i",EndYear) + ".txt"

   if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
      header = "Taylorscore for std dev of " + str_upper(varID) + ": Model against " + str_upper(Source)
   else
      header = "Taylorscore for annual mean of " + str_upper(varID) + ": Model against " + str_upper(Source)
   end if

   print(TableFileName)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList,score/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   ;----------- Draw Spatia Taylor Score -----------------------------------------

   PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/taylorscore/taylorscore_" + str_lower(varID) \
                + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                + sprinti("%0.4i",EndYear)

   if (str_lower(varID).eq."twsa" .and. str_upper(Source).eq."GRACE") then
      titles       = "Taylor Score (std dev) for " + str_upper(varID) + ": Model against " + str_upper(Source) + ", " + \
                      sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
   else
      titles       = "Taylor Score for " + str_upper(varID) + ": Model against " + str_upper(Source) + ", " + \
                      sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)
   end if

   Draw_Taylor_Diagram (PlotFileName, score, ratio, cc, ModelNameList, titles)
end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure TaylorScore_site (DataDir:string, ModelNames:string, runID:integer, varID: string, Source:string, Unit:string,\
                            ts_obs:float, ts_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,     \
                            SubReg:string, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nmod=dimsizes(ModelNames)

nsit=dimsizes(ind(slat.ne.-999))

MODELTYPE = getenv("MODELTYPE")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=0
runIDS(1:nmod)=runID

ModelNameList(0) = Source
ModelNameList(1:nmod) = ModelNames

varID@MODEL = ModelNameList

; Retrieve latitude and longitude for a specific region.
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

nlat = dimsizes(rlat)
nlon = dimsizes(rlon)

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts_obs@LandFrac
landf_mod = ts_mod@LandFrac

area_obs  = ts_obs@GridArea
area_mod  = ts_mod@GridArea

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

nsit0 = dimsizes(i51)

delete(temp)

if (nsit0.gt.2) then

   ts0_obs = new((/ntot, nsit0/), float)
   ts0_mod = new((/nmod, ntot, nsit0/), float)
   slat0   = new((/nsit0/), float)
   slon0   = new((/nsit0/), float)

   ts0_obs(:,0:nsit0-1)   = ts_obs(:,i50(i51))
   ts0_mod(:,:,0:nsit0-1) = ts_mod(:,:,i50(i51))
   slat0(0:nsit0-1)       = slat(i50(i51))
   slon0(0:nsit0-1)       = slon(i50(i51))

   ; ------- Set Model Data as missing where the Benchmark is missing -----
   score=new((/nmod+1/), float)
   ratio=new((/nmod+1,2/), float)
   cc=new((/nmod+1,2/), float)

   score = -999

   tt0=new((/nsit0,ntot/), float)

   do nt=0,ntot-1
      tt0(:,nt)=ts0_obs(nt,:)
   end do

   tt0@_FillValue=-999

   numb=int2flt(dimsizes(ind(.not.ismissing(ndtooned(tt0)))))

   at0=dim_avg(tt0)
   at0@_FillValue=-999

   do nv=0, nmod-1
   if (runID(nv).gt.0) then

      tt1=new((/nsit0,ntot/), float)

      do nt=0,ntot-1
         tt1(:,nt)=ts0_mod(nv,nt,:)
      end do

      tt1=where(ismissing(tt0), -999, tt1)

      tt1@_FillValue=-999

      at1=dim_avg(tt1)

      at1@_FillValue=-999

      j50=ind(.not.ismissing(at0) .and. .not.ismissing(at1))

      at0(j50) = dim_rmvmean(at0(j50))
      at1(j50) = dim_rmvmean(at1(j50))

      mxlag=0
      corr0  = esccr(at0(j50), at1(j50), mxlag)
      corr=corr0(0)
      delete(corr0)

      stdev0=dim_stddev(at0(j50))
      stdev1=dim_stddev(at1(j50))

      cc(nv+1,:)   = corr
      ratio(nv+1,:)=stdev1/stdev0

      ;stdev0=stdev0*stdev0+avg(at0)*avg(at0)
      ;stdev1=stdev1*stdev1+avg(at1)*avg(at1)

      ;stdev0=sqrt(stdev0)
      ;stdev1=sqrt(stdev1)

      score(nv+1)=2*(1.0+corr)/((stdev0/stdev1+stdev1/stdev0)^2)

      delete(j50)
      delete(at1)
      delete(tt1)
      delete(corr)
      delete(stdev0)
      delete(stdev1)
   end if
   end do

   cc@_FillValue    = -999
   ratio@_FillValue = -999
   score@_FillValue = -999

   TableFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/taylorscore/taylorscore_" + str_lower(varID) \
                 + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                 + sprinti("%0.4i",EndYear) + ".txt"

   header = "Taylorscore for Annual Mean of " + str_upper(varID) + ": Model against " + str_upper(Source)

   print(TableFileName)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"No._of_DATA: ", numb/], "%16s %10.2f")
   write_table(TableFileName,"a",[/ModelNameList,score/], "%16s %10.2f")

   ;print(asciiread(TableFileName,-1,"string"))

   ;----------- Draw Spatia TaylorScore -----------------------------------------

   PlotFileName = DataDir + "/OUTPUT/" + str_lower(varID) + "/taylorscore/taylorscore_" + str_lower(varID) \
                + "_CMIP5.vs." + str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" \
                + sprinti("%0.4i",EndYear)

   titles       = "Taylor Score for " + str_upper(varID) + ": Model against " + str_upper(Source) + ", " + \
                   sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear)

   Draw_Taylor_Diagram (PlotFileName, score, ratio, cc, ModelNameList, titles)
end if

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
