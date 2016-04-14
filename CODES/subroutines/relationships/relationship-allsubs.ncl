procedure correlation_line2line (DataDir:string, ModelNames:string, runID:integer, var1ID:string, var2ID:string, \
                Source1:string, Source2:string, Unit1:string, Unit2:string, ts1_obs:float, ts2_obs:float, \
                ts1_mod:float, ts2_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,\
                reg1:float, reg2:float, lags:integer)

begin

nyer = EndYear-StartYear + 1
nmon = 12
ntot = nyer*nmon

nmod=dimsizes(ModelNames)

nlat=dimsizes(slat)
nlon=dimsizes(slon)

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

; --------------- set a region for var1ID ----------------
j501=ind(slat.ge.reg1(0) .and. slat.le.reg1(1))
i501=ind(slon.ge.reg1(2) .and. slon.le.reg1(3))

; --------------- set a region for var2ID ----------------
j502=ind(slat.ge.reg2(0) .and. slat.le.reg2(1))
i502=ind(slon.ge.reg2(2) .and. slon.le.reg2(3))

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_mod = ts2_mod@LandFrac
landm_mod = ts2_mod@LandMask
area_mod  = ts2_mod@GridArea

landf_obs = ts2_obs@LandFrac
area_obs  = ts2_obs@GridArea
slat0     = ts2_obs@lat
slon0     = ts2_obs@lon

region    = where(landf_obs.gt.0,1,0)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

nlat0 = dimsizes(slat0)
nlon0 = dimsizes(slon0)

nlat0 = dimsizes(slat0)
nlon0 = dimsizes(slon0)

region01 = region
region02 = region
delete(region)

if (str_lower(var1ID).eq."sst") then
   region01=where(region01.eq.0, 1, 0)
else
   region01=where(region01.gt.0.5, 1, 0)
end if

if (str_lower(var2ID).eq."sst") then
   region02=where(region02.eq.0, 1, 0)
else
   region02=where(region02.gt.0.5, 1, 0)
end if

ts1_obs!0="time"
ts1_obs!1="lat"
ts1_obs!2="lon"

ts2_obs!0="time"
ts2_obs!1="lat"
ts2_obs!2="lon"

; ------- convert unit from per cell area to per land area ------------------------
;if (any(str_lower(var1ID).eq.(/"biomass", "burntarea", "gpp", "nbp", "nee", "reco", "soilc"/))) then
;   do nt=0,ntot-1
;      ts1_obs(nt,:,:) = ts1_obs(nt,:,:)/landfOM
;      do nv=0,nmod-1
;         ts1_mod(nv,nt,:,:) = ts1_mod(nv,nt,:,:)/landfOM
;      end do
;   end do
;end if

; ------- convert unit from per cell area to per land area ------------------------
;if (any(str_lower(var2ID).eq.(/"biomass", "burntarea", "gpp", "nbp", "nee", "reco", "soilc"/))) then
;   do nt=0,ntot-1
;      ts2_obs(nt,:,:) = ts2_obs(nt,:,:)/landfOM
;      do nv=0,nmod-1
;         ts2_mod(nv,nt,:,:) = ts2_mod(nv,nt,:,:)/landfOM
;      end do
;   end do
;end if

;area = area*landfOM

; ------- Set Model Data as missing where the Benchmark is missing -----

if (str_lower(var1ID).eq."soilc") then
   ts1_obs=where(ts1_obs.le.0, -999, ts1_obs)
else
      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      ts1_obs(ijk,:,:) =where(region01.gt.0, ts1_obs(ijk,:,:), -999)
      ijk=ijk+1
   end do
   end do
end if

if (str_lower(var2ID).eq."soilc") then
   ts2_obs=where(ts2_obs.le.0, -999, ts2_obs)
else
      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      ts2_obs(ijk,:,:) =where(region02.gt.0, ts2_obs(ijk,:,:), -999)
      ijk=ijk+1
   end do
   end do
end if

ts1_obs@_FillValue=-999
ts2_obs@_FillValue=-999

region1=dim_avg(ts1_obs(lat|:,lon|:,time|:))
region2=dim_avg(ts2_obs(lat|:,lon|:,time|:))

if (any(str_lower(var1ID).eq.(/"albedo","biomass","burntarea","gpp","reco","runoff","le","sh","pr","soilc"/))) then
   region1 = where(region1.gt.0, 1, 0)
else
   region1 = where(.not.ismissing(region1), 1, 0)
end if

if (any(str_lower(var2ID).eq.(/"albedo","biomass","burntarea","gpp","reco","runoff","le","sh","pr","soilc"/))) then
   region2 = where(region2.gt.0, 1, 0)
else
   region2 = where(.not.ismissing(region2), 1, 0)
end if

region = where(region1.gt.0.and.region2.gt.0, 1, 0)
delete(region1)
delete(region2)

   ijk = 0
do iy=0,nyer-1
do im=0,nmon-1
   ts1_obs(ijk,:,:) =where(region.gt.0, ts1_obs(ijk,:,:), -999)
   ts2_obs(ijk,:,:) =where(region.gt.0, ts2_obs(ijk,:,:), -999)
   ijk = ijk + 1
end do
end do

temp=ts1_obs
temp=where(ismissing(temp), 0, 1)

numb=sum(temp)
delete(temp)

ts1=new((/ntot/), float)
ts2=new((/ntot/), float)

do nt =0, ntot-1
   ts1(nt) = avg(ts1_obs(nt,j501,i501))
   ts2(nt) = avg(ts2_obs(nt,j502,i502))
end do

ts0@_FillValue=-999

;------------- Calculate correlation coefficient -----------
tt_mod=new((/nmod+1,2*abs(lags)+1/), float)

xx=fspan(1.,int2flt(ntot),ntot)
n=3

if (dimsizes(ind(.not.ismissing(ts1))).lt.2 .or. dimsizes(ind(.not.ismissing(ts2))).lt.2) then
   tt_mod(0,:) = x_lead_y(lags)
else

   xx1=ts1
   xx1=rmAnnCycle1D(xx1)

   cc= lspoly(xx,xx1, 1, n)
   xx2 = cc(0) + cc(1)*xx + cc(2)*xx^2
   delete(cc)

   xx1=xx1-xx2

   yy1=ts2
   yy1=rmAnnCycle1D(yy1)

   cc= lspoly(xx,yy1, 1, n)
   yy2 = cc(0) + cc(1)*xx + cc(2)*xx^2
   delete(cc)

   yy1=yy1-yy2

   x_lead_y = esccr(xx1,yy1,abs(lags))
   y_lead_x = esccr(yy1,xx1,abs(lags))

   tt_mod(0,0:lags)       = x_lead_y(::-1)
   tt_mod(0,lags+1:2*lags) = y_lead_x

   delete(xx1)
   delete(xx2)
   delete(yy1)
   delete(yy2)
   delete(x_lead_y)
   delete(y_lead_x)
end if

delete(ts1)
delete(ts2)

do nv=0, nmod-1
if (runID(nv).gt.0) then

   landfOM = where(landf_obs.gt.0. .and. landf_mod(nv,:,:).gt.0., landf_mod(nv,:,:), -999)
   landfOM = where(landm_mod(nv,:,:).gt.0, landfOM, -999)

   landfOM@_FillValue=-999

   ;ts1_mod=where(ismissing(ts1_obs), -999, ts1_mod)
   ;ts2_mod=where(ismissing(ts2_obs), -999, ts2_mod)

   ts1_mod@_FillValue=-999
   ts2_mod@_FillValue=-999

   ts1=new((/ntot/), float)
   ts2=new((/ntot/), float)

   do nt =0, ntot-1
      ts1_mod(nv,nt,:,:)=where(ismissing(landfOM), -999, ts1_mod(nv,nt,:,:))
      ts2_mod(nv,nt,:,:)=where(ismissing(landfOM), -999, ts2_mod(nv,nt,:,:))
      ts1(nt) = avg(ts1_mod(nv,nt,j501,i501))
      ts2(nt) = avg(ts2_mod(nv,nt,j502,i502))
   end do

   if (dimsizes(ind(.not.ismissing(ts1))).lt.2 .or. dimsizes(ind(.not.ismissing(ts2))).lt.2) then
      tt_mod(nv+1,:)=-999
   else

      xx1=ts1
      xx1=rmAnnCycle1D(xx1)

      cc= lspoly(xx,xx1, 1, n)
      xx2 = cc(0) + cc(1)*xx + cc(2)*xx^2
      delete(cc)

      xx1=xx1-xx2

      yy1=ts2
      yy1=rmAnnCycle1D(yy1)

      cc= lspoly(xx,yy1, 1, n)
      yy2 = cc(0) + cc(1)*xx + cc(2)*xx^2
      delete(cc)

      yy1=yy1-yy2

      x_lead_y          = esccr(xx1,yy1,abs(lags))
      y_lead_x          = esccr(yy1,xx1,abs(lags))

      tt_mod(nv+1,0:lags)       = x_lead_y(::-1)
      tt_mod(nv+1,lags+1:2*lags) = y_lead_x

      delete(xx1)
      delete(xx2)
      delete(yy1)
      delete(yy2)
      delete(x_lead_y)
      delete(y_lead_x)
   end if
   delete(ts1)
   delete(ts2)
   delete(landfOM)
end if
end do

delete(xx)

;----------- Draw  Correlation Plots -----------------------------------------

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID

ModelNameList(0) = "Benchmark"
ModelNameList(1:nmod) = ModelNames

Ymin   =-1.0
Ymax   = 1.0
Xmin   =-abs(lags)
Xmax   = abs(lags)

xxx  = fspan(-abs(lags), abs(lags), 2*abs(lags)+1)

tt_mod!0="mod"
tt_mod!1="time"
tt_mod&time=xxx

tt_mod@XTitle = "Negatives: " + VarName1 + " Leads " + VarName2
tt_mod@YTitle = "Correlation Coefficient"

delete(xxx)

PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/relationships/correlation_line2line_CMIP5" \
             + "_" + str_lower(var1ID) + ".vs." + str_lower(var2ID) + "_" + sprinti("%0.4i",StartYear) \
             + "-" + sprinti("%0.4i",EndYear)

Draw_Plot_XY (PlotFileName, tt_mod, ModelNameList, Xmin, Xmax, Ymin, Ymax)

end

; ################################################################################################################################
procedure correlation_line2map (DataDir:string, ModelNames:string, runID:integer, var1ID:string, var2ID:string, \
                Source1:string, Source2:string, Unit1:string, Unit2:string, ts1_obs:float, ts2_obs:float, \
                ts1_mod:float, ts2_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,\
                reg1:float, reg2:float, lags:integer)

begin

nyer = EndYear-StartYear + 1
nmon = 12
ntot = nyer*nmon

nmod=dimsizes(ModelNames)

nlat=dimsizes(slat)
nlon=dimsizes(slon)

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

; --------------- set a region for var1ID ----------------
j50=ind(slat.ge.reg1(0) .and. slat.le.reg1(1))
i50=ind(slon.ge.reg1(2) .and. slon.le.reg1(3))

; --------------- set a region for var2ID ----------------
MinLat = reg2(0)
MaxLat = reg2(1)
MinLon = reg2(2)
MaxLon = reg2(3)
XLab   = 2
CLab   = 4

ts1_obs = where(ismissing(ts1_obs), -999, ts1_obs)
ts2_obs = where(ismissing(ts2_obs), -999, ts2_obs)
ts1_mod = where(ismissing(ts1_mod), -999, ts1_mod)
ts2_mod = where(ismissing(ts2_mod), -999, ts2_mod)

ts1_obs = where(ts1_obs.ge.999, -999, ts1_obs)
ts2_obs = where(ts2_obs.ge.999, -999, ts2_obs)
ts1_mod = where(ts1_mod.ge.999, -999, ts1_mod)
ts2_mod = where(ts2_mod.ge.999, -999, ts2_mod)

ts1_obs = where(ts1_obs.le.-999, -999, ts1_obs)
ts2_obs = where(ts2_obs.le.-999, -999, ts2_obs)
ts1_mod = where(ts1_mod.le.-999, -999, ts1_mod)
ts2_mod = where(ts2_mod.le.-999, -999, ts2_mod)

ts1_obs@_FillValue = -999
ts2_obs@_FillValue = -999
ts1_mod@_FillValue = -999
ts2_mod@_FillValue = -999

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_mod = ts2_mod@LandFrac
landm_mod = ts2_mod@LandMask
area_mod  = ts2_mod@GridArea

landf_obs = ts2_obs@LandFrac
area_obs  = ts2_obs@GridArea
slat0     = ts2_obs@lat
slon0     = ts2_obs@lon

region    = where(landf_obs.gt.0,1,0)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

nlat0 = dimsizes(slat0)
nlon0 = dimsizes(slon0)

region01=region
region02=region
delete(region)

if (str_lower(var1ID).eq."sst") then
   region01=where(region01.eq.0, 1, 0)
else
   region01=where(region01.gt.0.5, 1, 0)
end if

if (str_lower(var2ID).eq."sst") then
   region02=where(region02.eq.0, 1, 0)
else
   region02=where(region02.gt.0.5, 1, 0)
end if

ts1_obs!0="time"
ts1_obs!1="lat"
ts1_obs!2="lon"

ts2_obs!0="time"
ts2_obs!1="lat"
ts2_obs!2="lon"

; ------- convert unit from per cell area to per land area ------------------------
;if (any(str_lower(var1ID).eq.(/"biomass", "burntarea", "gpp", "nbp", "nee", "reco", "soilc"/))) then
;   do nt=0,ntot-1
;      ts1_obs(nt,:,:) = ts1_obs(nt,:,:)/landfOM
;      do nv=0,nmod-1
;         ts1_mod(nv,nt,:,:) = ts1_mod(nv,nt,:,:)/landfOM
;      end do
;   end do
;end if

; ------- convert unit from per cell area to per land area ------------------------
;if (any(str_lower(var2ID).eq.(/"biomass", "burntarea", "gpp", "nbp", "nee", "reco", "soilc"/))) then
;   do nt=0,ntot-1
;      ts2_obs(nt,:,:) = ts2_obs(nt,:,:)/landfOM
;      do nv=0,nmod-1
;         ts2_mod(nv,nt,:,:) = ts2_mod(nv,nt,:,:)/landfOM
;      end do
;   end do
;end if

;area = area*landfOM

; ------- Set Model Data as missing where the Benchmark is missing -----
if (str_lower(var1ID).eq."soilc") then
   ts1_obs=where(ts1_obs.le.0, -999, ts1_obs)
else
      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      ts1_obs(ijk,:,:) =where(region01.gt.0, ts1_obs(ijk,:,:), -999)
      ijk=ijk+1
   end do
   end do
end if

if (str_lower(var2ID).eq."soilc") then
   ts2_obs=where(ts2_obs.le.0, -999, ts2_obs)
else
      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      ts2_obs(ijk,:,:) =where(region02.gt.0, ts2_obs(ijk,:,:), -999)
      ijk=ijk+1
   end do
   end do
end if

ts1_obs@_FillValue=-999
ts2_obs@_FillValue=-999

region1=dim_avg(ts1_obs(lat|:,lon|:,time|:))
region2=dim_avg(ts2_obs(lat|:,lon|:,time|:))

if (any(str_lower(var1ID).eq.(/"albedo","biomass","burntarea","gpp","reco","runoff","le","sh","pr","soilc"/))) then
   region1 = where(region1.gt.0, 1, 0)
else
   region1 = where(.not.ismissing(region1), 1, 0)
end if

if (any(str_lower(var2ID).eq.(/"albedo","biomass","burntarea","gpp","reco","runoff","le","sh","pr","soilc"/))) then
   region2 = where(region2.gt.0, 1, 0)
else
   region2 = where(.not.ismissing(region2), 1, 0)
end if

region = where(region1.gt.0.and.region2.gt.0, 1, 0)
delete(region1)
delete(region2)

   ijk = 0
do iy=0,nyer-1
do im=0,nmon-1
   ts1_obs(ijk,:,:) =where(ismissing(landf_obs), -999, ts1_obs(ijk,:,:))
   ts2_obs(ijk,:,:) =where(ismissing(landf_obs), -999, ts2_obs(ijk,:,:))
   ijk = ijk + 1
end do
end do

temp=ts1_obs
temp=where(ismissing(temp), 0, 1)

numb=sum(temp)
delete(temp)

ts0=new((/ntot/), float)

do nt =0, ntot-1
   ts0(nt) = avg(ts1_obs(nt,j50,i50))
end do

ts0@_FillValue=-999

;------------- removing long-term trend -----------
tt_mod=new((/nmod+1,nlat,nlon/), float)

xx=fspan(1.,int2flt(ntot),ntot)
n=3

do ny=0,nlat-1
do nx=0,nlon-1
if (dimsizes(ind(.not.ismissing(ts2_obs(:,ny,nx)))).lt.12) then
   tt_mod(0,ny,nx)=-999
else

   xx1=ts0
   xx1=where(ismissing(xx1), 0, xx1)
   xx1=rmAnnCycle1D(xx1)

   cc= lspoly(xx,xx1, 1, n)
   xx2 = cc(0) + cc(1)*xx + cc(2)*xx^2
   delete(cc)

   xx1=xx1-xx2

   yy1=ts2_obs(:,ny,nx)
   yy1=where(ismissing(yy1), 0, yy1)
   yy1=rmAnnCycle1D(yy1)

   cc= lspoly(xx,yy1, 1, n)
   yy2 = cc(0) + cc(1)*xx + cc(2)*xx^2
   delete(cc)

   yy1=yy1-yy2

   if (lags.gt.0) then
      x_lead_y          = esccr(xx1,yy1,abs(lags))
   else
      x_lead_y          = esccr(yy1,xx1,abs(lags))
   end if
   tt_mod(0,ny,nx) = x_lead_y(lags)

   delete(xx1)
   delete(xx2)
   delete(yy1)
   delete(yy2)
   delete(x_lead_y)
end if
end do
end do

delete(ts0)

do nv=0, nmod-1
if (runID(nv).gt.0) then

   landfOM = where(landf_obs.gt.0. .and. landf_mod(nv,:,:).gt.0., landf_mod(nv,:,:), -999)
   landfOM = where(landm_mod(nv,:,:).gt.0, landfOM, -999)

   landfOM@_FillValue=-999

   ;ts1_mod(nv,:,:,:)=where(ismissing(ts1_obs), -999, ts1_mod(nv,:,:,:))
   ;ts2_mod(nv,:,:,:)=where(ismissing(ts2_obs), -999, ts2_mod(nv,:,:,:))

   ts1_mod@_FillValue=-999
   ts2_mod@_FillValue=-999

   ts1=new((/ntot/), float)

   do nt =0, ntot-1
      ts1_mod(nv,nt,:,:) =where(ismissing(landfOM), -999, ts1_mod(nv,nt,:,:))
      ts2_mod(nv,nt,:,:) =where(ismissing(landfOM), -999, ts2_mod(nv,nt,:,:))
      ts1(nt) = avg(ts1_mod(nv,nt,j50,i50))
   end do

   do ny=0,nlat-1
   do nx=0,nlon-1
      if (dimsizes(ind(.not.ismissing(ts2_mod(nv,:,ny,nx)))).lt.12) then
         tt_mod(nv+1,ny,nx)=-999
      else

         xx1=ts1
         xx1=where(ismissing(xx1), 0, xx1)
         xx1=rmAnnCycle1D(xx1)

         cc= lspoly(xx,xx1, 1, n)
         xx2 = cc(0) + cc(1)*xx + cc(2)*xx^2
         delete(cc)

         xx1=xx1-xx2

         yy1=ts2_mod(nv,:,ny,nx)
         yy1=where(ismissing(yy1), 0, yy1)
         yy1 = rmAnnCycle1D(yy1)

         cc= lspoly(xx,yy1, 1, n)
         yy2 = cc(0) + cc(1)*xx + cc(2)*xx^2
         delete(cc)

         yy1=yy1-yy2

         if (lags.gt.0) then
            x_lead_y          = esccr(xx1,yy1,abs(lags))
         else
            x_lead_y          = esccr(yy1,xx1,abs(lags))
         end if

         tt_mod(nv+1,ny,nx) = x_lead_y(lags)

         delete(xx1)
         delete(xx2)
         delete(yy1)
         delete(yy2)
         delete(x_lead_y)
      end if
   end do
   end do

   delete(ts1)
   delete(landfOM)
end if
end do

delete(xx)

;----------- Begin drawing plots -----------------------------------------

DataInfo1 = retrieve_DataInfo (var1ID, "")
DataInfo2 = retrieve_DataInfo (var2ID, "")
VarName1  = DataInfo1@LongName
VarName2  = DataInfo2@LongName
delete(DataInfo1)
delete(DataInfo2)

delete(i50)
delete(j50)

tt_mod@_FillValue = -999

tt_mod!0="mod"
tt_mod!1="lat"
tt_mod!2="lon"
tt_mod&lat=slat
tt_mod&lon=slon
tt_mod&lon@units="degrees_east"
tt_mod&lat@units="degrees_north"

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID

ModelNameList(0) = "Benchmark"
ModelNameList(1:nmod) = ModelNames

; ++++++++++ set up parameters for drawing +++++++++++

results = retrieve_DrawInfo (var1ID, "correlation", Source1)

cnlevels = results@cnlevels
lblabels = results@lblabels
XLab     = results@XLab
YLab     = results@YLab
CLab     = results@CLab

MinLon   = min(slon)
MaxLon   = max(slon)
MinLat   = min(slat)
MaxLat   = max(slat)

XLab     = 1
YLab     = 1

; ++++++++++ Draw Plots +++++++++++

do nv = 0, nmod

if (runIDS(nv).gt.0) then

  tt_mod(nv,:,:) = where (region.le.0, -999, tt_mod(nv,:,:))
  tt_mod@_FillValue = -999

  PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/relationships/correlation_line2map_" + ModelNameList(nv) \
               + "_" + str_lower(var1ID) + ".vs." + str_lower(var2ID) + "_" + sprinti("%0.4i",StartYear) \
               + "-" + sprinti("%0.4i",EndYear)

  titles       = VarName1 + " Leads " + VarName2 + " by " + sprinti("%0.2i",lags) + " months from " + ModelNameList(nv)

  Draw_Map (PlotFileName, tt_mod(nv,:,:), slat, slon, titles, cnlevels, lblabels, XLab, YLab, CLab, \
            MinLon, MaxLon, MinLat, MaxLat, 0)

end if
end do
delete(tt_mod)

end

; ################################################################################################################################
procedure correlation_map2map (DataDir:string, ModelNames:string, runID:integer, var1ID:string, var2ID:string, \
                Source1:string, Source2:string, Unit1:string, Unit2:string, ts1_obs:float, ts2_obs:float, \
                ts1_mod:float, ts2_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,\
                reg1:float, reg2:float, lags:integer)

begin

nyer = EndYear-StartYear + 1
nmon = 12
ntot = nyer*nmon

nmod=dimsizes(ModelNames)

nlat=dimsizes(slat)
nlon=dimsizes(slon)

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

; --------------- set a region for var1ID ----------------
j50=ind(slat.ge.reg1(0) .and. slat.le.reg1(1))
i50=ind(slon.ge.reg1(2) .and. slon.le.reg1(3))

; --------------- set a region for var2ID ----------------
MinLat = reg1(0)
MaxLat = reg1(1)
MinLon = reg1(2)
MaxLon = reg1(3)
XLab   = 2
CLab   = 4

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_mod = ts2_mod@LandFrac
landm_mod = ts2_mod@LandMask
area_mod  = ts2_mod@GridArea

landf_obs = ts2_obs@LandFrac
area_obs  = ts2_obs@GridArea
slat0     = ts2_obs@lat
slon0     = ts2_obs@lon

region    = where(landf_obs.gt.0,1,0)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

nlat0 = dimsizes(slat0)
nlon0 = dimsizes(slon0)

region01=region
region02=region
delete(region)

if (str_lower(var1ID).eq."sst") then
   region01=where(region01.eq.0, 1, 0)
else
   region01=where(region01.gt.0.5, 1, 0)
end if

if (str_lower(var2ID).eq."sst") then
   region02=where(region02.eq.0, 1, 0)
else
   region02=where(region02.gt.0.5, 1, 0)
end if

ts1_obs!0="time"
ts1_obs!1="lat"
ts1_obs!2="lon"

ts2_obs!0="time"
ts2_obs!1="lat"
ts2_obs!2="lon"

; ------- convert unit from per cell area to per land area ------------------------
;if (any(str_lower(var1ID).eq.(/"biomass", "burntarea", "gpp", "nbp", "nee", "reco", "soilc"/))) then
;   do nt=0,ntot-1
;      ts1_obs(nt,:,:) = ts1_obs(nt,:,:)/landfOM
;      do nv=0,nmod-1
;         ts1_mod(nv,nt,:,:) = ts1_mod(nv,nt,:,:)/landfOM
;      end do
;   end do
;end if

; ------- convert unit from per cell area to per land area ------------------------
;if (any(str_lower(var2ID).eq.(/"biomass", "burntarea", "gpp", "nbp", "nee", "reco", "soilc"/))) then
;   do nt=0,ntot-1
;      ts2_obs(nt,:,:) = ts2_obs(nt,:,:)/landfOM
;      do nv=0,nmod-1
;         ts2_mod(nv,nt,:,:) = ts2_mod(nv,nt,:,:)/landfOM
;      end do
;   end do
;end if

;area = area*landfOM

; ------- Set Model Data as missing where the Benchmark is missing -----
if (str_lower(var1ID).eq."soilc") then
   ts1_obs=where(ts1_obs.le.0, -999, ts1_obs)
else
      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      ts1_obs(ijk,:,:) =where(region01.gt.0, ts1_obs(ijk,:,:), -999)
      ijk=ijk+1
   end do
   end do
end if

if (str_lower(var2ID).eq."soilc") then
   ts2_obs=where(ts2_obs.le.0, -999, ts2_obs)
else
      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      ts2_obs(ijk,:,:) =where(region02.gt.0, ts2_obs(ijk,:,:), -999)
      ijk=ijk+1
   end do
   end do
end if

ts1_obs@_FillValue=-999
ts2_obs@_FillValue=-999

region1=dim_avg(ts1_obs(lat|:,lon|:,time|:))
region2=dim_avg(ts2_obs(lat|:,lon|:,time|:))

if (any(str_lower(var1ID).eq.(/"albedo","biomass","burntarea","gpp","reco","runoff","le","sh","pr","soilc"/))) then
   region1 = where(region1.gt.0, 1, 0)
else
   region1 = where(.not.ismissing(region1), 1, 0)
end if

if (any(str_lower(var2ID).eq.(/"albedo","biomass","burntarea","gpp","reco","runoff","le","sh","pr","soilc"/))) then
   region2 = where(region2.gt.0, 1, 0)
else
   region2 = where(.not.ismissing(region2), 1, 0)
end if

region = where(region1.gt.0.and.region2.gt.0, 1, 0)
delete(region1)
delete(region2)

   ijk = 0
do iy=0,nyer-1
do im=0,nmon-1
   ts1_obs(ijk,:,:) =where(region.gt.0, ts1_obs(ijk,:,:), -999)
   ts2_obs(ijk,:,:) =where(region.gt.0, ts2_obs(ijk,:,:), -999)
   ijk = ijk + 1
end do
end do

temp=ts1_obs
temp=where(ismissing(temp), 0, 1)

numb=sum(temp)
delete(temp)

;------------- removing long-term trend -----------
tt_mod=new((/nmod+1,nlat,nlon/), float)

xx=fspan(1.,int2flt(ntot),ntot)
n=3

do ny=0,nlat-1
do nx=0,nlon-1
if (dimsizes(ind(.not.ismissing(ts1_obs(:,ny,nx)))).lt.2 .or. dimsizes(ind(.not.ismissing(ts2_obs(:,ny,nx)))).lt.2) then
   tt_mod(0,ny,nx)=-999
else

   xx1=ts1_obs(:,ny,nx)
   xx1=rmAnnCycle1D(xx1)

   cc= lspoly(xx,xx1, 1, n)
   xx2 = cc(0) + cc(1)*xx + cc(2)*xx^2
   delete(cc)

   xx1=xx1-xx2

   yy1=ts2_obs(:,ny,nx)
   yy1=rmAnnCycle1D(yy1)

   cc= lspoly(xx,yy1, 1, n)
   yy2 = cc(0) + cc(1)*xx + cc(2)*xx^2
   delete(cc)

   yy1=yy1-yy2

   if (lags.gt.0) then
      x_lead_y          = esccr(xx1,yy1,abs(lags))
   else
      x_lead_y          = esccr(yy1,xx1,abs(lags))
   end if
   tt_mod(0,ny,nx) = x_lead_y(lags)

   delete(xx1)
   delete(xx2)
   delete(yy1)
   delete(yy2)
   delete(x_lead_y)
end if
end do
end do

do nv=0, nmod-1
if (runID(nv).gt.0) then

   landfOM = where(landf_obs.gt.0. .and. landf_mod(nv,:,:).gt.0., landf_mod(nv,:,:), -999)
   landfOM = where(landm_mod(nv,:,:).gt.0, landfOM, -999)

   landfOM@_FillValue=-999

   ;ts1_mod(nv,:,:,:)=where(ismissing(ts1_obs), -999, ts1_mod(nv,:,:,:))
   ;ts2_mod(nv,:,:,:)=where(ismissing(ts2_obs), -999, ts2_mod(nv,:,:,:))

   do nt =0, ntot-1
      ts1_mod(nv,nt,:,:) =where(ismissing(landfOM), -999, ts1_mod(nv,nt,:,:))
      ts2_mod(nv,nt,:,:) =where(ismissing(landfOM), -999, ts2_mod(nv,nt,:,:))
   end do

   ts1_mod@_FillValue=-999
   ts2_mod@_FillValue=-999

   do ny=0,nlat-1
   do nx=0,nlon-1
      if (dimsizes(ind(.not.ismissing(ts1_mod(nv,:,ny,nx)))).lt.2 .or. dimsizes(ind(.not.ismissing(ts2_mod(nv,:,ny,nx)))).lt.2) then
         tt_mod(nv+1,ny,nx)=-999
      else

         xx1=ts1_mod(nv,:,ny,nx)
         xx1=rmAnnCycle1D(xx1)

         cc= lspoly(xx,xx1, 1, n)
         xx2 = cc(0) + cc(1)*xx + cc(2)*xx^2
         delete(cc)

         xx1=xx1-xx2

         yy1=ts2_mod(nv,:,ny,nx)
         yy1=rmAnnCycle1D(yy1)

         cc= lspoly(xx,yy1, 1, n)
         yy2 = cc(0) + cc(1)*xx + cc(2)*xx^2
         delete(cc)

         yy1=yy1-yy2

         if (lags.gt.0) then
            x_lead_y          = esccr(xx1,yy1,abs(lags))
         else
            x_lead_y          = esccr(yy1,xx1,abs(lags))
         end if

         tt_mod(nv+1,ny,nx) = x_lead_y(lags)

         delete(xx1)
         delete(xx2)
         delete(yy1)
         delete(yy2)
      end if
   end do
   end do
   delete(landfOM)
end if
end do

delete(xx)

;----------- Begin drawing plots -----------------------------------------

DataInfo1 = retrieve_DataInfo (var1ID, "")
DataInfo2 = retrieve_DataInfo (var2ID, "")
VarName1  = DataInfo1@LongName
VarName2  = DataInfo2@LongName
delete(DataInfo1)
delete(DataInfo2)

delete(i50)
delete(j50)

tt_mod@_FillValue = -999

tt_mod!0="mod"
tt_mod!1="lat"
tt_mod!2="lon"
tt_mod&lat=slat
tt_mod&lon=slon
tt_mod&lon@units="degrees_east"
tt_mod&lat@units="degrees_north"

ModelNameList=new((/nmod+1/), string)
runIDS=new((/nmod+1/), integer)

runIDS(0)=1
runIDS(1:nmod)=runID

ModelNameList(0) = "Benchmark"
ModelNameList(1:nmod) = ModelNames

; ++++++++++ set up parameters for drawing +++++++++++

results = retrieve_DrawInfo (var1ID, "correlation", Source1)

cnlevels = results@cnlevels
lblabels = results@lblabels
XLab     = results@XLab
YLab     = results@YLab
CLab     = results@CLab

MinLon   = min(slon)
MaxLon   = max(slon)
MinLat   = min(slat)
MaxLat   = max(slat)

XLab     = 1
YLab     = 1

; ++++++++++ Draw Plots +++++++++++

do nv = 0, nmod

if (runIDS(nv).gt.0) then

  tt_mod(nv,:,:) = where (region.le.0, -999, tt_mod(nv,:,:))
  tt_mod@_FillValue = -999

  PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/relationships/correlation_map2map_" + ModelNameList(nv) \
               + "_" + str_lower(var1ID) + ".vs." + str_lower(var2ID) + "_" + sprinti("%0.4i",StartYear) \
               + "-" + sprinti("%0.4i",EndYear)

  titles       = VarName1 + " Leads " + VarName2 + " by " + sprinti("%0.2i",lags) + " months from " + ModelNameList(nv)

  Draw_Map (PlotFileName, tt_mod(nv,:,:), slat, slon, titles, cnlevels, lblabels, XLab, YLab, CLab, \
            MinLon, MaxLon, MinLat, MaxLat, 0)

end if
end do
delete(tt_mod)

end

; ################################################################################################################################
procedure function_bar (DataDir:string, ModelNames:string, runID:integer, var1ID:string, var2ID:string, \
              Source1:string, Source2:string, Unit1:string, Unit2:string, ts1_obs:float, ts2_obs:float, \
              ts1_mod:float, ts2_mod:float, StartYear:integer, EndYear:integer, slat:float, slon:float,\
              regs:float)

begin

nyer = EndYear-StartYear + 1
nmon = 12
ntot = nyer*nmon

nmod=dimsizes(ModelNames)

nlat=dimsizes(slat)
nlon=dimsizes(slon)

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

runIDS=new((/nmod+1/), integer)
ModelNameList=new((/nmod+1/), string)

runIDS(0)=1
runIDS(1:nmod)=runID

ModelNameList(0)="Benchmark"
ModelNameList(1:nmod)=ModelNames

; -------- retrieve land fraction and area data for BENCHMARK and MODEL ----------------
landf_obs = ts2_obs@LandFrac
area_obs  = ts2_obs@GridArea
slat0     = ts2_obs@lat
slon0     = ts2_obs@lon

landf_mod = ts2_mod@LandFrac
landm_mod = ts2_mod@LandMask
area_mod  = ts2_mod@GridArea

region    = where(landf_obs.gt.0,1,0)

landf_obs@_FillValue = -999
landf_mod@_FillValue = -999

nlat0 = dimsizes(slat0)
nlon0 = dimsizes(slon0)

region01=region
region02=region

if (str_lower(var1ID).eq."sst") then
   region01=where(region01.eq.0, 1, 0)
else
   region01=where(region01.gt.0.5, 1, 0)
end if

if (str_lower(var2ID).eq."sst") then
   region02=where(region02.eq.0, 1, 0)
else
   region02=where(region02.gt.0.5, 1, 0)
end if

ts1_obs!0="time"
ts1_obs!1="lat"
ts1_obs!2="lon"

ts2_obs!0="time"
ts2_obs!1="lat"
ts2_obs!2="lon"

;landfOM = where(landf_obs.gt.0.50, landf_obs, -999)
landfOM = where(landf_obs.gt.0.0 .and. landf_mod(0,:,:).gt.0.0, landf_mod(0,:,:), -999)
landfOM = where(landm_mod(0,:,:).gt.0, landfOM, -999)

landfOM@_FillValue=-999

do nt =0, ntot-1
   ts1_obs(nt,:,:) = where(ismissing(landfOM), -999, ts1_obs(nt,:,:))
   ts2_obs(nt,:,:) = where(ismissing(landfOM), -999, ts2_obs(nt,:,:))
end do

delete(landfOM)

; ------- convert unit from per cell area to per land area ------------------------
;if (var1ID@LandOnly.eq.1) then
;   do nt=0,ntot-1
;      ts1_obs(nt,:,:) = ts1_obs(nt,:,:)/landf
;      do nv=0,nmod-1
;         ts1_mod(nv,nt,:,:) = ts1_mod(nv,nt,:,:)/landf
;      end do
;   end do
;end if

; ------- convert unit from per cell area to per land area ------------------------
;if (var2ID@LandOnly.eq.1) then
;   do nt=0,ntot-1
;      ts2_obs(nt,:,:) = ts2_obs(nt,:,:)/landf
;      do nv=0,nmod-1
;         ts2_mod(nv,nt,:,:) = ts2_mod(nv,nt,:,:)/landf
;      end do
;   end do
;end if

;area = area*landf

; ------- Set Model Data as missing where the Benchmark is missing -----
tt1_mod=new((/nmod+1,nlat,nlon/), float)
tt2_mod=new((/nmod+1,nlat,nlon/), float)

if (str_lower(var1ID).eq."soilc") then
   ts1_obs=where(ts1_obs.le.0, -999, ts1_obs)
else
      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      ts1_obs(ijk,:,:) =where(region01.gt.0, ts1_obs(ijk,:,:), -999)
      ijk=ijk+1
   end do
   end do
end if

if (str_lower(var2ID).eq."soilc") then
   ts2_obs=where(ts2_obs.le.0, -999, ts2_obs)
else
      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      ts2_obs(ijk,:,:) =where(region02.gt.0, ts2_obs(ijk,:,:), -999)
      ijk=ijk+1
   end do
   end do
end if

ts1_obs@_FillValue=-999
ts2_obs@_FillValue=-999

region1=dim_avg(ts1_obs(lat|:,lon|:,time|:))
region2=dim_avg(ts2_obs(lat|:,lon|:,time|:))

;if (any(str_lower(var1ID).eq.(/"albedo","biomass","burntarea","gpp","reco","runoff","le","sh","pr","soilc"/))) then
;   region1 = where(region1.gt.0, 1, 0)
;else
   region1 = where(.not.ismissing(region1), 1, 0)
;end if

;if (any(str_lower(var2ID).eq.(/"albedo","biomass","burntarea","gpp","reco","runoff","le","sh","pr","soilc"/))) then
;   region2 = where(region2.gt.0, 1, 0)
;else
   region2 = where(.not.ismissing(region2), 1, 0)
;end if

region = where(region1.gt.0.and.region2.gt.0, 1, 0)
delete(region1)
delete(region2)

tt01=new((/nlat,nlon,nyer,nmon/), float)
tt02=new((/nlat,nlon,nyer,nmon/), float)

   ijk=0
do iy=0,nyer-1
do im=0,nmon-1
   tt01(:,:,iy,im)=ts1_obs(ijk,:,:)
   tt02(:,:,iy,im)=ts2_obs(ijk,:,:)
   ijk=ijk+1
end do
end do

do iy=0,nyer-1
do im=0,nmon-1
   tt01(:,:,iy,im) =where(region.gt.0, tt01(:,:,iy,im), -999)
   tt02(:,:,iy,im) =where(region.gt.0, tt02(:,:,iy,im), -999)
end do
end do

tt01@_FillValue=-999
tt02@_FillValue=-999

temp=tt01
temp=where(ismissing(temp), 0, 1)

numb=sum(temp)
delete(temp)

;if (any(str_lower(var1ID).eq.(/"biomass","burntarea","nee","reco","soilc"/))) then
;   if (str_lower(var1ID).eq."burntarea") then
;      at01=dim_sum(tt01)
;      tt1_mod(0,:,:)=dim_avg(at01)*area*1.e-10
;   end if
;   if (any(str_lower(var1ID).eq.(/"biomass","soilc"/))) then
;      at01=dim_avg(tt01)
;      tt1_mod(0,:,:)=dim_avg(at01)*area*1.e-9
;   end if
;   if (any(str_lower(var1ID).eq.(/"gpp","nee","reco"/))) then
;      at01=dim_avg(tt01)
;      tt1_mod(0,:,:)=dim_avg(at01)*area*365*1.e-12
;   end if
;else
   at01=dim_avg(tt01)
   tt1_mod(0,:,:)=dim_avg(at01)
;end if

;if (any(str_lower(var2ID).eq.(/"biomass","burntarea","nee","reco","soilc"/))) then
;   if (str_lower(var2ID).eq."burntarea") then
;      at02=dim_sum(tt02)
;      tt2_mod(0,:,:)=dim_avg(at02)*area*1.e-10
;   end if
;   if (any(str_lower(var2ID).eq.(/"biomass","soilc"/))) then
;      at02=dim_avg(tt02)
;      tt2_mod(0,:,:)=dim_avg(at02)*area*1.e-9
;   end if
;   if (any(str_lower(var2ID).eq.(/"gpp","nee","reco"/))) then
;      at02=dim_avg(tt02)
;      tt2_mod(0,:,:)=dim_avg(at02)*area*365*1.e-12
;   end if
;else
   at02=dim_avg(tt02)
   tt2_mod(0,:,:)=dim_avg(at02)
;end if

do nv=0, nmod-1
if (runID(nv).gt.0) then

   landfOM = where(landf_obs.gt.0.0 .and. landf_mod(nv,:,:).gt.0.0, landf_mod(nv,:,:), -999)
   landfOM = where(landm_mod(nv,:,:).gt.0, landfOM, -999)

   landfOM@_FillValue=-999

   do nt =0, ntot-1
      ts1_mod(nv,nt,:,:) =where(ismissing(landfOM), -999, ts1_mod(nv,nt,:,:))
      ts2_mod(nv,nt,:,:) =where(ismissing(landfOM), -999, ts2_mod(nv,nt,:,:))
   end do

   tt1=new((/nlat,nlon,nyer,nmon/), float)
   tt2=new((/nlat,nlon,nyer,nmon/), float)

      ijk=0
   do iy=0,nyer-1
   do im=0,nmon-1
      tt1(:,:,iy,im)=ts1_mod(nv,ijk,:,:)
      tt2(:,:,iy,im)=ts2_mod(nv,ijk,:,:)
      ijk=ijk+1
   end do
   end do

   ;tt1=where(ismissing(tt01), -999, tt1)
   ;tt2=where(ismissing(tt02), -999, tt2)

   tt1@_FillValue=-999
   tt2@_FillValue=-999

;   if (any(str_lower(var1ID).eq.(/"biomass","burntarea","nee","reco","soilc"/))) then
;      if (str_lower(var1ID).eq."burntarea") then
;         at1=dim_sum(tt1)
;         tt1_mod(nv+1,:,:)=dim_avg(at1)*area*1.e-10
;      end if
;      if (any(str_lower(var1ID).eq.(/"biomass","soilc"/))) then
;         at1=dim_avg(tt1)
;         tt1_mod(nv+1,:,:)=dim_avg(at1)*area*1.e-9
;      end if
;      if (any(str_lower(var1ID).eq.(/"gpp","nee","reco"/))) then
;         at1=dim_avg(tt1)
;         tt1_mod(nv+1,:,:)=dim_avg(at1)*area*365*1.e-12
;      end if
;   else
      at1=dim_avg(tt1)
      tt1_mod(nv+1,:,:)=dim_avg(at1)
;   end if

;   if (any(str_lower(var2ID).eq.(/"biomass","burntarea","nee","reco","soilc"/))) then
;      if (str_lower(var2ID).eq."burntarea") then
;         at2=dim_sum(tt2)
;         tt2_mod(nv+1,:,:)=dim_avg(at2)*area*1.e-10
;      end if
;      if (any(str_lower(var2ID).eq.(/"biomass","soilc"/))) then
;         at2=dim_avg(tt2)
;         tt2_mod(nv+1,:,:)=dim_avg(at2)*area*1.e-9
;      end if
;      if (any(str_lower(var2ID).eq.(/"gpp","nee","reco"/))) then
;         at2=dim_avg(tt2)
;         tt2_mod(nv+1,:,:)=dim_avg(at2)*area*365*1.e-12
;      end if
;   else
      at2=dim_avg(tt2)
      tt2_mod(nv+1,:,:)=dim_avg(at2)
;   end if

   delete(at1)
   delete(at2)
   delete(tt1)
   delete(tt2)
   delete(landfOM)
end if
end do

delete(at01)
delete(at02)
delete(tt01)
delete(tt02)

;FileNameOut1 = getenv("ILAMB_OUTPUTDIR") + "/relationships/annualmean1_" \
;               + "_" + str_lower(var1ID) + ".vs." + str_lower(var2ID) + "_" + sprinti("%0.4i",StartYear) \
;               + "-" + sprinti("%0.4i",EndYear) + ".dat"
;
;fbindirwrite(FileNameOut1, tt1_mod)
;
;FileNameOut2 = getenv("ILAMB_OUTPUTDIR") + "/relationships/annualmean2_" \
;               + "_" + str_lower(var1ID) + ".vs." + str_lower(var2ID) + "_" + sprinti("%0.4i",StartYear) \
;               + "-" + sprinti("%0.4i",EndYear) + ".dat"
;
;fbindirwrite(FileNameOut2, tt2_mod)

; ++++++++++ retrieve parameters for Function Bar +++++++++++

results = retrieve_DrawInfo (var1ID, "FunctionBar", Source1)

Xmin   = results@MinLon
Xmax   = results@MaxLon
Ymin   = results@MinLat
Xt     = results@MaxLat

nums=floattoint((Xmax-Xmin)/Xt)-1

j50=ind(slat.ge.regs(0) .and. slat.le.regs(1))
i50=ind(slon.ge.regs(2) .and. slon.le.regs(3))

xxx=new((/nmod+1,nums/), float)
yyy=new((/nmod+1,nums/), float)
numbs=new((/nmod+1,nums/), float)

tt1_mod@_FillValue = -999
tt2_mod@_FillValue = -999

numbs = 0.

do nd=0,nmod

   tmp1=ndtooned(tt1_mod(nd,j50,i50))
   tmp2=ndtooned(tt2_mod(nd,j50,i50))

   tmp1@_FillValue=-999
   tmp2@_FillValue=-999

      tx1=Xmin
   do nb=0,nums-1
      tx2=tx1+Xt
      k50=ind(tmp1.ge.tx1 .and. tmp1.lt.tx2 .and. .not.ismissing(tmp1) .and. .not.ismissing(tmp2))
      if (dimsizes(k50).gt.1 .or. .not.ismissing(k50)) then
         ;xxx(nd,nb)=avg(tmp1(k50))
         xxx(nd,nb)=tx2
         yyy(nd,nb)=avg(tmp2(k50))
         numbs(nd,nb)=dimsizes(k50)
      else
         xxx(nd,nb)=-999
         yyy(nd,nb)=-999
      end if
      tx1=tx2
      delete(k50)
   end do

   delete(tmp1)
   delete(tmp2)
end do

delete(i50)
delete(j50)

xxx@_FillValue=-999
yyy@_FillValue=-999

DataInfo1 = retrieve_DataInfo (var1ID, "")
DataInfo2 = retrieve_DataInfo (var2ID, "")
VarName1  = DataInfo1@LongName
VarName2  = DataInfo2@LongName
delete(DataInfo1)
delete(DataInfo2)
 
result1  = retrieve_unit (var1ID, Source1)
result2  = retrieve_unit (var2ID, Source2)

Unit1 = result1@FinalPlots
Unit2 = result2@FinalPlots

delete(result1)
delete(result2)

;if (any(str_lower(var1ID).eq.(/"biomass","burntarea","nee","reco","soilc"/))) then
;   Unit1 = str_sub_str(Unit1, "month", "yr")
;   Unit1 = str_sub_str(Unit1, "day", "yr")
;   Unit1 = str_sub_str(str_upper(Unit1), "/M2", "")
;   Unit2 = str_sub_str(str_upper(Unit2), "/M2", "")
;end if
;
;if (any(str_lower(var2ID).eq.(/"biomass","burntarea","nee","reco","soilc"/))) then
;   Unit2 = str_sub_str(Unit2, "month", "yr")
;   Unit2 = str_sub_str(Unit2, "day", "yr")
;   Unit1 = str_sub_str(str_upper(Unit1), "/M2", "")
;   Unit2 = str_sub_str(str_upper(Unit2), "/M2", "")
;end if

; ++++++++++ set up parameters for drawing +++++++++++

results = retrieve_DrawInfo (var1ID, "FunctionBar", Source1)

cnlevels = results@cnlevels
lblabels = results@lblabels
XLab     = results@XLab
YLab     = results@YLab
CLab     = results@CLab

MinLon   = results@MinLon
MaxLon   = results@MaxLon
MinLat   = results@MinLat
MaxLat   = max(yyy)*1.2


do nv = 0, nmod
if (runIDS(nv).gt.0) then

  TableFileName = getenv("ILAMB_OUTPUTDIR") + "/relationships/function_bar_" + ModelNameList(nv) \
               + "_" + str_lower(var1ID) + ".vs." + str_lower(var2ID) + "_" + sprinti("%0.4i",StartYear) \
               + "-" + sprinti("%0.4i",EndYear) + ".txt"
  
  header = "Function Bar for " + str_upper(var1ID) + " against " + str_upper(var2ID) + " from " + ModelNameList(nv)
  Svar1  = str_upper(var1ID) + "(" + str_upper(Source1) + "; " + Unit1 + ")"
  Svar2  = str_upper(var2ID) + "(" + str_upper(Source2) + "; " + Unit2 + ")"
  
  print(TableFileName)
  write_table(TableFileName,"w", [/header/], "%s")
  write_table(TableFileName,"a",[/Svar1,Svar2/], "%20s %30s")
  write_table(TableFileName,"a",[/xxx(nv,:), yyy(nv,:)/], "%20.2f %20.2f")

  TableFileName = getenv("ILAMB_OUTPUTDIR") + "/relationships/function_bar_numb_" + ModelNameList(nv) \
               + "_" + str_lower(var1ID) + ".vs." + str_lower(var2ID) + "_" + sprinti("%0.4i",StartYear) \
               + "-" + sprinti("%0.4i",EndYear) + ".txt"
  
  header = "Total numbers of grid cells for " + str_upper(var1ID) + " against " + str_upper(var2ID) + " from " + ModelNameList(nv)
  Svar1  = str_upper(var1ID) + "(" + str_upper(Source1) + "; " + Unit1 + ")"
  Svar2  = str_upper(var2ID) + "(" + str_upper(Source2) + "; " + Unit2 + ")"
  
  print(TableFileName)
  write_table(TableFileName,"w", [/header/], "%s")
  write_table(TableFileName,"a",[/Svar1,Svar2/], "%20s %30s")
  write_table(TableFileName,"a",[/numbs(nv,:), numbs(nv,:)/], "%20.2f %20.2f")

  PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/relationships/function_bar_" + ModelNameList(nv) \
               + "_" + str_lower(var1ID) + ".vs." + str_lower(var2ID) + "_" + sprinti("%0.4i",StartYear) \
               + "-" + sprinti("%0.4i",EndYear)

; --------------- Drawing plots --------------------------

  ;+++ Filtered out data less than 1 percent of grid cells for benchmark +++
  ;numbs(nv,:) = numbs(nv,:)*100/sum(numbs(nv,:))
  xxx(nv,:)   = where(numbs(nv,:).lt.50., -999, xxx(nv,:))
  yyy(nv,:)   = where(numbs(nv,:).lt.50., -999, yyy(nv,:))

  titles       = ModelNameList(nv)
  XTitle       = VarName1 + " (" + Unit1 + ")"
  YTitle       = VarName2 + " (" + Unit2 + ")"

  Draw_Function_Bar (PlotFileName, xxx(nv,:), yyy(nv,:), titles, XTitle, YTitle, XLab, YLab, CLab, \
                     MinLon, MaxLon, MinLat, MaxLat)

end if
end do

end

; ################################################################################################################################
procedure score_var2var (nvpa:integer)

begin

DataDir = getenv("ILAMB_ROOT")

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian
EE0       = constants@EulerNumb

; ++++++ input control parameters from a file: ../CODES/tempfiles/input_para_pair* +++++

do nvp =1, nvpa

  ControlFileName = DataDir + "/CODES/tempfiles/input_para_pair" + sprinti("%0.2i",nvp)

  data_1d = asciiread(str_squeeze(ControlFileName),-1,"string")

  funcs         = str_squeeze(str_get_field(data_1d(2), 2, ":"))

  Var1          = str_squeeze(str_get_field(data_1d(4), 2, ":"))
  Source1Ref    = str_get_field(data_1d(9), 2, ":")
  Var2          = str_squeeze(str_get_field(data_1d(13), 2, ":"))
  Source2Ref    = str_get_field(data_1d(18), 2, ":")

  StartYear     = stringtointeger(str_get_field(data_1d(22), 2, ":"))
  EndYear       = stringtointeger(str_get_field(data_1d(23), 2, ":"))
  SubReg        = str_get_field(data_1d(24), 2, ":")

  ModelNames    = str_squeeze(str_get_field(data_1d(27:), 1, " "))
  runID         = stringtointeger(str_get_field(data_1d(27:), 3, " "))

  nmod          = dimsizes(ModelNames)

  Source1       = str_get_field(Source1Ref, 1, "(")
  Source2       = str_get_field(Source2Ref, 1, "(")

  Source1       = str_squeeze(Source1)
  Source2       = str_squeeze(Source2)

  delete(data_1d)

  runIDs=new((/nmod+1/), integer)
  ModelNameList=new((/nmod+1/), string)

  runIDs(0)=1
  runIDs(1:nmod)=runID

  ModelNameList(0)="Benchmark"
  ModelNameList(1:nmod)=ModelNames

  numbs1=new((/nmod+1,1000/), float)
  numbs2=new((/nmod+1,1000/), float)

  var1raw=new((/nmod+1,1000/), float)
  var2raw=new((/nmod+1,1000/), float)
  var2fit=new((/nmod+1,1000/), float)

  numbs1 = 0.0
  numbs2 = 0.0

  var1raw = -999
  var2raw = -999
  var2fit = -999

  do nd = 0, nmod
     if (runIDs(nd).gt.0) then

        TableFileName = getenv("ILAMB_OUTPUTDIR") + "/relationships/function_bar_numb_" + ModelNameList(nd) \
                      + "_" + str_lower(Var1) + ".vs." + str_lower(Var2) + "_" + sprinti("%0.4i",StartYear) \
                      + "-" + sprinti("%0.4i",EndYear) + ".txt"

        data1d   = asciiread(str_squeeze(TableFileName),-1,"string")

        numb1   = stringtofloat(str_get_field(data1d(2:), 1, " "))
        numb2   = stringtofloat(str_get_field(data1d(2:), 2, " "))

        delete(data1d)

        TableFileName = getenv("ILAMB_OUTPUTDIR") + "/relationships/" + funcs + "_" + ModelNameList(nd) \
               + "_" + str_lower(Var1) + ".vs." + str_lower(Var2) + "_" + sprinti("%0.4i",StartYear) \
               + "-" + sprinti("%0.4i",EndYear) + ".txt"
        print(TableFileName)

        data1d   = asciiread(str_squeeze(TableFileName),-1,"string")

        string1  = str_squeeze(str_get_field(data1d(1), 1, ")"))
        string2  = str_squeeze(str_get_field(data1d(1), 2, ")"))
        Var1Unit = str_lower(str_squeeze(str_get_field(string1, 1, ";")))
        Var2Unit = str_lower(str_squeeze(str_get_field(string2, 1, ";")))

        Value1   = stringtofloat(str_get_field(data1d(2:), 1, " "))
        Value2   = stringtofloat(str_get_field(data1d(2:), 2, " "))

        ndim = dimsizes(Value1)

        Value1@_FillValue = -999
        Value2@_FillValue = -999

        Value2 = where(ismissing(Value2), 0, Value2)

        i50=ind(.not.ismissing(Value1))

        xi=Value1(i50)
        yi=Value2(i50)

        xo  = xi

        yo = csa1(xi, yi, 4, xo)
        var2fit(nd,i50)  = yo

        var1raw(nd,0:ndim-1)  = Value1
        var2raw(nd,0:ndim-1)  = Value2

        numbs1(nd,0:ndim-1)  = numb1
        numbs2(nd,0:ndim-1)  = numb2

        delete(i50)
        delete(xi)
        delete(yi)
        delete(xo)
        delete(yo)

        delete(numb1)
        delete(numb2)
        delete(Value1)
        delete(Value2)
        delete(data1d)
     end if
  end do

  ;+++ Filtered out data less than 1 percent of grid cells for benchmark +++
  do nd = 0, nmod
     ;numbs1(nd,:)  = numbs1(nd,:)*100/sum(numbs1(nd,:))
     numbs2(nd,:) = where(numbs1(nd,:).lt.50., -999, numbs2(nd,:))
     var1raw(nd,:) = where(numbs1(nd,:).lt.50., -999, var1raw(nd,:))
     var2raw(nd,:) = where(numbs1(nd,:).lt.50., -999, var2raw(nd,:))
  end do

  numbs2@_FillValue  = -999
  var1raw@_FillValue = -999
  var2raw@_FillValue = -999
  var2fit@_FillValue = -999

  ;++++++++++++++++++++++++ Calculate Score for Variable to Variable +++++++++++++++++++++++++++

  score    = new((/nmod+1/), float)
  score    = -999
  score(0) = 1

  j50  = ind(.not.ismissing(var1raw(0,:)))

  ;var2raw(:,j50) = runave(var2raw(:,j50), 3, 2)

  ; ++++ normalized by the peak values +++++
  ;var2fit(0,:) = var2fit(0,:)/max(var2fit(0,:))
  ;var2raw(0,:) = var2raw(0,:)/max(var2raw(0,:))

  ;Area_OBS = sum(var2fit(0,j50))
  ;Area_OBS = sum(var2raw(0,j50))
  Area_OBS = sqrt(avg(var2raw(0,:)*var2raw(0,:)))
  ;Area_OBS = sum(abs(var2raw(0,:)))

  do nd = 1, nmod
     if (runIDs(nd).gt.0) then

        ; ++++ normalized by the peak values +++++
        ;var2fit(nd,:) = var2fit(nd,:)/max(var2fit(nd,:))
        ;var2raw(nd,:) = var2raw(nd,:)/max(var2raw(nd,:))

        ;tmp = var2fit(nd,j50) - var2fit(0, j50)
        tmp = var2raw(nd,j50) - var2raw(0, j50)

        tmp@_FillValue = -999

        tmp1 = where(tmp.gt.0, tmp, 0)
        tmp2 = where(tmp.lt.0, tmp, 0)

        Area_plus = sum(tmp1)
        Area_minu = sum(tmp2)
        Area_Diff = dim_rmsd(var2raw(nd, :), var2raw(0, :))
        ;Area_Diff = sum(abs(var2raw(nd, :) - var2raw(0, :)))

        ;score(nd) = (Area_OBS - Area_plus + Area_minu)/Area_OBS
        score(nd) = 1-Area_Diff/Area_OBS

        ;score(nd) = where(score(nd).lt.0, 0, score(nd))

        delete(tmp)
        delete(tmp1)
        delete(tmp2)
     end if
  end do

  score = exp(score)/EE0
 
  ;++++++++++++++++++++++++ Save Score for Variable to Variable +++++++++++++++++++++++++++

  TableFileName = getenv("ILAMB_OUTPUTDIR") + "/v2vscore/v2vscore_pair" + sprinti("%0.2i",nvp) + ".txt"

  header = "V2V Score for " + str_upper(Var1) + " against " + str_upper(Var2)
  Svar1  = str_upper(Var1) + "(" + str_upper(Source1) + ")"
  Svar2  = str_upper(Var2) + "(" + str_upper(Source2) + ")"

  print(TableFileName)
  write_table(TableFileName,"w", [/header/], "%s")
  write_table(TableFileName,"a",[/Svar1,Svar2/], "%16s %25s")
  write_table(TableFileName,"a",[/ModelNames,score(1:nmod)/], "%16s %10.2f")

  ;++++++++++++++++++++++++ Draw Score for Variable to Variable +++++++++++++++++++++++++++

  PlotFileName = getenv("ILAMB_OUTPUTDIR") + "/v2vscore/v2vscore_pair" + sprinti("%0.2i",nvp)
  titles       = "Var2Var Score for " + Var1 + " to " + Var2

  Draw_Score (PlotFileName, score, ModelNameList, titles)

  delete(j50)
  delete(score)
  delete(var1raw)
  delete(var2raw)
  delete(var2fit)
     
  delete(runID)
  delete(runIDs)
  delete(ModelNames)
  delete(ModelNameList)
end do

end

; ################################################################################################################################
