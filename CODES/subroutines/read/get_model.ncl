function get_model (DataDir:string, ModelNames:string, NumRun:integer, modelID:string, expID:string, \
                   VarName:string, VarModel:string, ModelRaw:string, StartYear:integer, EndYear:integer, \
                   slat:float, slon:float, SiteID:integer)

begin

nyer=EndYear-StartYear + 1
nmon=12
ntot=nyer*nmon

nday=(/31,28,31,30,31,30,31,31,30,31,30,31/)

nmod=dimsizes(ModelNames)

; +++++ Retrieve Constants +++++
constants = retrieve_constant
Rad       = constants@EarthRadius
RR0       = constants@Radian

; ------- read model simulation -----
if (SiteID.eq.1) then
   slon = where(slon.lt.0 .and. slon.ne.-999, slon+360., slon)
   i50=ind(slat.ge.-90 .and. slat.le.90)
   nsit=dimsizes(i50)
   ts_mod=new((/nmod,ntot,nsit/), float)
   landf_mod = new((/nmod,nsit/), float)
   area_mod  = new((/nmod,nsit/), float)
   landm_mod = new((/nmod,nsit/), float)
else
   if (min(slon).lt.0) then
      slon = slon + 180.
   end if
   nlat=dimsizes(slat)
   nlon=dimsizes(slon)
   ts_mod = new((/nmod,ntot,nlat,nlon/), float)
   landf_mod = new((/nmod,nlat,nlon/), float)
   area_mod  = new((/nmod,nlat,nlon/), float)
   landm_mod = new((/nmod,nlat,nlon/), float)
end if

RawMax     = new((/nmod/), float)
RawMin     = new((/nmod/), float)
RawAvg     = new((/nmod/), float)
RawGlobAvg = new((/nmod/), float)

ts_mod=-999

if (str_lower(ModelRaw).eq."yes")

   DataDirMod = getenv("ILAMB_MODELSDIR") + "/original/"

do nv=0, nmod-1

if (NumRun(nv).gt.0) then

   cmipID=ModelNames(nv)

   DataInfo     = retrieve_DataInfo (VarName, cmipID)

   CorOtherInfo = correct_wrong_others (VarName, cmipID)

   VarModel = DataInfo@VarModel

   if (str_lower(CorOtherInfo).eq."wrong") then
      VarModel = CorOtherInfo@VarName
   end if
   
   latlon = read_model_latlon (DataDirMod, cmipID, modelID, expID, "r1i1p1", VarModel)

   slat1 = latlon@lat
   slon1 = latlon@lon
   delete(latlon)

   ; ++++ read land area fraction (%) ++++

   if (any(modelID.eq.(/"Omon", "OImon"/))) then
      if (any(cmipID.eq.(/"HadGEM2-CC", "HadGEM2-ES"/))) then
         sftlf=read_model_vars(DataDirMod, "HadGEM2-ES", "fx", "1pctCO2", "r0i0p0", "sftof")
      else
         if (any(cmipID.eq.(/"MIROC-ESM", "MIROC-ESM-CHEM"/))) then
            sftlf=new((/nlat1,nlon1/), float)
            sftlf=100
         else
            sftlf=read_model_vars(DataDirMod, cmipID, "fx", "historical", "r0i0p0", "sftof")
         end if
      end if
   else
      if (any(cmipID.eq.(/"HadGEM2-CC", "HadGEM2-ES"/))) then
         sftlf=read_model_vars(DataDirMod, "HadGEM2-ES", "fx", "historical", "r1i1p1", "sftlf")
      else
         sftlf=read_model_vars(DataDirMod, cmipID, "fx", "historical", "r0i0p0", "sftlf")
      end if
   end if

   sftlf = where(sftlf.gt.100,     0, sftlf)
   sftlf = where(sftlf.le.0,       0, sftlf)
   sftlf = where(ismissing(sftlf), 0, sftlf)

   if (max(sftlf).le.1) then
      sftlf=sftlf*100
   end if

   sftlf=sftlf/100

   sftlf!0="lat"
   sftlf!1="lon"
   sftlf&lat=slat1
   sftlf&lon=slon1
   sftlf&lon@units="degrees_east"
   sftlf&lat@units="degrees_north"

   ; -------calculate area------------------------

   ndims=dimsizes(slat1)

   if (dimsizes(ndims).eq.2) then
      nlat1=ndims(0)
      nlon1=ndims(1)

      area0=new((/nlat1,nlon1/), float)

      do ny = 0, nlat1-1
      do nx = 0, nlon1-1
         if (ny.eq.0) then
            dlat = abs((slat1(1,nx)-slat1(0,nx))*RR0)
         else
            dlat = abs((slat1(ny,nx)-slat1(ny-1,nx))*RR0)
         end if
         if (nx.eq.0) then
            dlon = abs((slon1(ny,1)-slon1(ny,0))*RR0)
         else
            dlon = abs((slon1(ny,nx)-slon1(ny,nx-1))*RR0)
         end if
         dy = Rad*dlat
         dx = Rad*cos(RR0*slat1(ny,nx))*dlon
         area0(ny,nx)=dx*dy
      end do
      end do
   else
      nlat1=dimsizes(slat1)
      nlon1=dimsizes(slon1)

      area0=new((/nlat1,nlon1/), float)

      do ny = 0, nlat1-1
         if (ny.eq.0) then
            dlat = abs((slat1(1)-slat1(0))*RR0)
         else
            dlat = abs((slat1(ny)-slat1(ny-1))*RR0)
         end if
         dy = Rad*dlat
      do nx = 0, nlon1-1
         if (nx.eq.0) then
            dlon = abs((slon1(1)-slon1(0))*RR0)
         else
            dlon = abs((slon1(nx)-slon1(nx-1))*RR0)
         end if
         dx = Rad*cos(RR0*slat1(ny))*dlon
         area0(ny,nx)=dx*dy
      end do
      end do
   end if

   ts  = new((/ntot,nlat1,nlon1/), float)
   ts  = 0.0

   do nr=0, NumRun(nv)-1

      runID="r" + sprinti("%i",nr+1) + "i1p1"

      times=read_model_time (DataDirMod, cmipID, modelID, expID, runID, VarModel)

      if (times(0).ge.31) then
         times = times-15.5
      end if

      if (str_lower(VarName).eq."twsa") then
         if (any(str_lower(VarModel).eq.(/"tws", "twsa", "twsc", "twsa_per"/))) then
         else
            if (times(0).lt.31) then
               times = times+15.5
            end if
         end if
      end if

      if (ismissing(str_lower(times@calendar))) then
         times@calendar = "noleap"
      end if

      ntots = dimsizes(times) - 1

      dates = cd_calendar(times, 0)

      if (dates(0,0).gt.StartYear) then
         nt1 = 0
      else
        if (modelID.eq."Lyr") then
          nt1 = ind (dates(:,0).eq.StartYear)
        else
          nt1 := ind (dates(:,0).eq.StartYear .and. dates(:,1).eq.1)
          nt1 := nt1(0)  ; take the first date in January
        end if
      end if

      if (dates(ntots,0).lt.EndYear) then
         nt2 = ntots
      else
         if (modelID.eq."Lyr") then
            nt2 = ind (dates(:,0).eq.EndYear)
         else
            nt2 = ind (dates(:,0).eq.EndYear .and. dates(:,1).eq.nmon)
            if (ismissing(nt2)) then
               nt2 = ind (dates(:,0).eq.EndYear .and. dates(:,1).eq.nmon-1)
            end if
         end if
      end if

      j50 = ind (dates(:,0).ge.StartYear .and. dates(:,0).le.EndYear)

      ; +++ read derived variables caculated from other variables instead of directly model output +++
      if (str_lower(DataInfo@VarModelComb).eq."yes") then

         if (str_lower(VarName).eq."albedo") then
            ts1=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rsds")
            ts2=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rsus")
            ts1=where(ts1.eq.0, -999, ts1)
            ts1=ts2/ts1
            delete(ts2)
         end if

         if (str_lower(VarName).eq."nee") then
            ts1=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "gpp")
            ts2=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "ra")
            ts3=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rh")

            ; ++++ correct wrong unit for et ++++
            results = correct_wrong_unit ("gpp", cmipID)
            ts1 = ts1*results
            delete(results)

            ts1=ts1-ts2-ts3
            delete(ts2)
            delete(ts3)
         end if

         if (str_lower(VarName).eq."reco") then
            ts1=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "ra")
            ts2=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rh")
            ts1=ts1+ts2
            delete(ts2)
         end if

         if (str_lower(VarName).eq."rsns") then
            ts1=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rsds")
            ts2=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rsus")
            ts1=ts1-ts2
            delete(ts2)
         end if

         if (str_lower(VarName).eq."rlns") then
            ts1=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rlds")
            ts2=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rlus")
            ts1=ts1-ts2
            delete(ts2)
         end if

         if (str_lower(VarName).eq."rns") then
            ts1=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rsds")
            ts2=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rsus")
            ts3=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rlds")
            ts4=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rlus")
            ts1=ts1-ts2+ts3-ts4
            delete(ts2)
            delete(ts3)
            delete(ts4)
         end if

         if (str_lower(VarName).eq."rnt") then
            ts1=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rsdt")
            ts2=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rsut")
            ts3=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rldt")
            ts4=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "rlut")
            ts1=ts1-ts2+ts3-ts4
            delete(ts2)
            delete(ts3)
            delete(ts4)
         end if

         if (str_lower(VarName).eq."twsa") then
            ts1=read_model_vars (DataDirMod, cmipID, "Amon", expID, runID, "pr")
            ts2=read_model_vars (DataDirMod, cmipID, "Amon", expID, runID, "evspsbl")
            ts3=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "mrro")

            ; ++++ correct wrong unit for et ++++
            results = correct_wrong_unit ("et", cmipID)
            ts2 = ts2*results
            delete(results)

            ts1 = ts1-ts2-ts3
            delete(ts2)
            delete(ts3)

            do nt=0,ntots
               iim=floattoint(dates(nt,1))
               ts1(nt,:,:) = ts1(nt,:,:)*int2flt(nday(iim-1))
            end do

            ts1 = dim_cumsum_n(ts1, 2, 0)
            ts1m = dim_avg_n(ts1(nt1:nt2,:,:), 0)
            ts1 = ts1 - conform_dims(dimsizes(ts1),ts1m,(/1,2/))
            delete(ts1m)
         end if

         if (str_lower(VarName).eq."twsc") then
            ts1=read_model_vars (DataDirMod, cmipID, "Amon", expID, runID, "pr")
            ts2=read_model_vars (DataDirMod, cmipID, "Amon", expID, runID, "evspsbl")
            ts3=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, "mrro")

            ; ++++ correct wrong unit for et ++++
            results = correct_wrong_unit ("et", cmipID)
            ts2 = ts2*results
            delete(results)

            ts1=ts1-ts2-ts3
            delete(ts2)
            delete(ts3)
         end if

      else

         ts1=read_model_vars (DataDirMod, cmipID, modelID, expID, runID, VarModel)

         ; ++++ correct wrong unit ++++
         results = correct_wrong_unit (VarName, cmipID)

         ts1 = ts1*results
         delete(results)

         if (str_lower(VarName).eq."twsa") then
            ; Remove mean
            ts1m = dim_avg_n(ts1(nt1:nt2,:,:),0)
            ts1 = ts1 - conform_dims(dimsizes(ts1),ts1m,(/1,2/))
            delete(ts1m)
         end if

      end if

      ts1@_FillValue=-999
   
      if (str_lower(VarName@LandOnly).eq."yes") then
         do nt=0,ntots-1
            ts1(nt,:,:)=ts1(nt,:,:)*sftlf
         end do
       
      end if

      if (modelID.eq."Lyr") then

         tmp1 = ts1(j50,:,:)
         delete(ts1)

         ts1=new((/nyer,nlat1,nlon1/), float)

         if (dimsizes(j50).ne.nyer) then
            if (nyer.gt.ntots) then
               ts1(nyer-nt1+nt2-1:nyer-1,:,:)=tmp1
            else
               ts1(0:nt2-nt1,:,:)=tmp1
            end if
         else
            ts1(0:nt2-nt1,:,:)=tmp1
         end if

         delete(tmp1)
         tmp1 = ts1
         delete(ts1)

         ts1=new((/ntot,nlat1,nlon1/), float)

            ijk=0
         do iy = 0, nyer-1
         do im = 0, nmon-1
            ts1(ijk,:,:)=tmp1(iy,:,:)
            ijk=ijk+1
         end do
         end do

         delete(tmp1)

      else

         tmp1 = ts1(nt1:nt2,:,:)
         delete(ts1)

         ts1=new((/ntot,nlat1,nlon1/), float)

         if (dimsizes(j50).ne.ntot) then
            if (ntot.gt.ntots) then
               ts1(ntot+nt1-nt2-1:ntot-1,:,:)=tmp1
            else
               ts1(0:nt2-nt1,:,:)=tmp1
               if ((nt2-nt1).lt.(ntot-1)) then
                  ts1(ntot-1,:,:) = ts1(ntot-2,:,:)
               end if
            end if
         else
            ts1(0:nt2-nt1,:,:)=tmp1
         end if

         delete(tmp1)

      end if

      ts1 = where(ts1.gt.1e22,    0, ts1)
      ts1 = where(ts1.lt.-1e22,   0, ts1)
      ts1 = where(ismissing(ts1), 0, ts1)

      ts1@_FillValue=-999
   
      ; ++++ adjust Biomass, burned area and soil carbon due to inconsistent calendar with observation ++++

      if (str_lower(VarName@CarbonYearly).eq."yes") then

            ijk=0
         do iiy = StartYear, EndYear

            coefs = new((/nmon/), float)
            coefs = 1.0

            iiy@calendar = "standard"
            nt1 = (iiy-StartYear)*nmon
            nt2 = nt1 + 11

            if (isleapyear(iiy))  then
               if (any(str_lower(times@calendar).eq.(/"365", "365_day", "noleap", "no_leap"/))) then
                  coefs(1) = 366./365.
               end if
               if (any(str_lower(times@calendar).eq.(/"360", "360_day"/))) then
                  coefs    = 365./360.
                  coefs(1) = 366./360.
               end if
               if (any(str_lower(times@calendar).eq.(/"366", "366_day", "allleap", "all_leap"/))) then
                  coefs    = 365./366.
                  coefs(1) = 1.0
               end if
            else
               if (any(str_lower(times@calendar).eq.(/"360", "360_day"/))) then
                  coefs    = 365./360.
               end if
               if (any(str_lower(times@calendar).eq.(/"366", "366_day", "allleap", "all_leap"/))) then
                  coefs    = 365./366.
               end if
            end if

            do im=0, nmon-1
               ts1(ijk,:,:) = ts1(ijk,:,:)*coefs(im)
               ijk = ijk + 1
            end do

            delete(nt1)
            delete(nt2)
            delete(coefs)
         end do
      end if

      ts = ts + ts1

      delete(j50)
      delete(ts1)
      delete(times)
      delete(dates)
   end do

   area1 = area0

   area1!0="lat"
   area1!1="lon"
   area1&lat=slat1
   area1&lon=slon1
   area1&lon@units="degrees_east"
   area1&lat@units="degrees_north"

   ts=ts/int2flt(NumRun(nv))

   ts = where(ts.ge.1e20,    -999, ts)
   ts = where(ts.le.-1e20,   -999, ts)
   ts = where(ismissing(ts), -999, ts)

   if (any(isnan_ieee(ts))) then
      replace_ieeenan (ts, -999., 0)
   end if

   ts@_FillValue = -999

   TsMean = dim_avg_n(ts, 0)

   RawMax(nv) = max(TsMean)
   RawMin(nv) = min(TsMean)
   RawAvg(nv) = avg(TsMean)

   j50    = ind(slat1.ge.-60)

   if (str_lower(VarName@LandOnly).eq."yes") then
      RawGlobAvg(nv) = sum(TsMean(j50,:)*area1(j50,:))
   else
      RawGlobAvg(nv) = sum(TsMean(j50,:)*area1(j50,:)*sftlf(j50,:))/sum(area1(j50,:)*sftlf(j50,:))
   end if

   delete(j50)
   delete(TsMean)

   if (SiteID.eq.1) then
      if (SiteID@NAME.eq."SITE") then

         ts = where(ismissing(ts), 0, ts)

         ts1=new((/ntot,nsit/), float)
         landfrac = new((/nsit/), float)
         landmask = new((/nsit/), float)
         area     = new((/nsit/), float)

         ; ++++++ Calculate global total net land carbon flux (nbp) in KgC/s +++++++
         ; ++++++ (the positive means atmosphere gains from land) ++++++++++++++++++++++
         if (str_lower(VarName).eq."nbp") then
            do nt=0,ntot-1
               ts1(nt,:)=-sum(ts(nt,:,:)*area1)
            end do
            landfrac = avg(sftlf)
            landmask = 1.0
            area     = sum(area1)
         end if

         if (str_lower(VarName).eq."co2" .and. .not.ismissing(slat(0))) then

            ts!0="time"
            ts!1="lat"
            ts!2="lon"
            ts&lat=slat1
            ts&lon=slon1
            ts&lon@units="degrees_east"
            ts&lat@units="degrees_north"

            do nt=0,ntot-1
               ts1(nt,:)=ts(nt,{slat(0)},{slon(0)})
            end do
            landfrac = sftlf({slat(0)},{slon(0)})
            landmask = sftlf({slat(0)},{slon(0)})
            area     = area1({slat(0)},{slon(0)})
         end if

      else

         slon11=new((/nlon1+1/), float)

         slon11(0:nlon1-1)=slon1
         slon11(nlon1)=360.

         delete(slon1)
         slon1=slon11
         delete(slon11)

         ts1=new((/ntot,nlat1,nlon1+1/), float)
         area01=new((/nlat1,nlon1+1/), float)
         sftlf01=new((/nlat1,nlon1+1/), float)

         ts1(:,:,0:nlon1-1)=ts
         ts1(:,:,nlon1)=ts(:,:,0)

         area01(:,0:nlon1-1)=area1
         area01(:,nlon1)=area1(:,0)

         sftlf01(:,0:nlon1-1)=sftlf
         sftlf01(:,nlon1)=sftlf(:,0)

         delete(ts)
         ts=ts1
         delete(ts1)

         areat=area01
         sftlft=sftlf01

         delete(area01)
         delete(sftlf01)

         if (max(slat) .gt. max(slat1) .or. min(slat) .lt. min(slat1)) then
            ts2=new((/ntot,nlat1+2,nlon1+1/), float)
            slat11=new((/nlat1+2/), float)

            area02=new((/nlat1+2,nlon1+1/), float)
            sftlf02=new((/nlat1+2,nlon1+1/), float)

            slat11(1:nlat1)=slat1
            slat11(0)=-90.
            slat11(nlat1+1)=90.

            delete(slat1)
            slat1=slat11
            delete(slat11)

            ts2(:,1:nlat1,:)=ts
            ts2(:,0,:)=ts(:,0,:)
            ts2(:,nlat1+1,:)=ts(:,nlat1-1,:)

            area02(1:nlat1,:)=areat
            area02(0,:)=areat(0,:)
            area02(nlat1+1,:)=areat(nlat1-1,:)

            sftlf02(1:nlat1,:)=sftlft
            sftlf02(0,:)=sftlft(0,:)
            sftlf02(nlat1+1,:)=sftlft(nlat1-1,:)

            delete(ts)
            delete(areat)
            delete(sftlft)

            ts=ts2
            areat=area02
            sftlft=sftlf02

            delete(ts2)
            delete(area02)
            delete(sftlf02)

         end if

         ts!0="time"
         ts!1="lat"
         ts!2="lon"
         ts&lat=slat1
         ts&lon=slon1
         ts&lon@units="degrees_east"
         ts&lat@units="degrees_north"

         areat!0="lat"
         areat!1="lon"
         areat&lat=slat1
         areat&lon=slon1
         areat&lon@units="degrees_east"
         areat&lat@units="degrees_north"

         sftlft!0="lat"
         sftlft!1="lon"
         sftlft&lat=slat1
         sftlft&lon=slon1
         sftlft&lon@units="degrees_east"
         sftlft&lat@units="degrees_north"

         ts1      = new((/ntot,nsit/), float)
         landfrac = new((/nsit/), float)
         landmask = new((/nsit/), float)
         area     = new((/nsit/), float)

         do ns=0,nsit-1
            ts1(:,ns)    = ts(:,{slat(ns)},{slon(ns)})
            landfrac(ns) = sftlft({slat(ns)},{slon(ns)})
            landmask(ns) = sftlft({slat(ns)},{slon(ns)})
            area(ns)     = areat({slat(ns)},{slon(ns)})
         end do

         ts1=where(ismissing(ts1), -999, ts1)

         ts1@_FillValue = -999

         delete(areat)
         delete(sftlft)
      end if

      landmask = where(landmask.gt.0, 1, 0)

      ts_mod(nv,:,:)  = ts1
      landf_mod(nv,:) = landfrac
      landm_mod(nv,:) = landmask
      area_mod(nv,:)  = area

      delete(ts1)
      delete(area)
      delete(landfrac)
      delete(landmask)

   else

      ; ------------- interpolation -----------
      opt = True
      opt@critpc = 0
   
      if (str_lower(VarName@LandOnly).eq."yes") then
         ts=where(ismissing(ts), 0, ts)
      else
         ts=where(ismissing(ts), RawAvg(nv), ts)
      end if

      if (dimsizes(ndims).eq.2) then

         ts1      = new((/ntot,nlat,nlon/), float)
         landfrac = new((/nlat,nlon/), float)
         landmask = new((/nlat,nlon/), float)
         area     = new((/nlat,nlon/), float)

         do ny=0,nlat-1
         do nx=0,nlon-1
            ij = getind_latlon2d (slat1,slon1, slat(ny), slon(nx))
            ts1(:,ny,nx)    = ts(:,ij(0,0),ij(0,1))
            landfrac(ny,nx) = sftlf(ij(0,0),ij(0,1))
            landmask(ny,nx) = sftlf(ij(0,0),ij(0,1))
         end do
         end do

         do ny = 0, nlat-1
            if (ny.eq.0) then
               dlat = abs((slat(ny,1)-slat(ny,0))*RR0)
            else
               dlat = abs((slat(ny,0)-slat(ny-1,0))*RR0)
            end if
            dy = Rad*dlat
            do nx = 0, nlon-1
               if (nx.eq.0) then
                  dlon = abs((slon(ny,1)-slon(ny,0))*RR0)
               else
                  dlon = abs((slon(ny,nx)-slon(ny,nx-1))*RR0)
               end if
               dx = Rad*cos(RR0*slat(ny,nx))*dlon
               area(ny,nx)=dx*dy
            end do
         end do

         delete(ij)

      else

         landmask0 = sftlf
         landmask0 = where(landmask0.gt.0, 1, 0)

         if (any(cmipID.eq.(/"CCSM4","CESM1-BGC","GFDL-ESM2G","GFDL-ESM2M"/))) then
            opt = True
            opt@NLATo = nlat1
            slat1     = latGau(nlat1, "lat", "latitude", "degrees_north")
            ts1       = area_conserve_remap (slon1, slat1, ts,        slon, slat, opt)
            landfrac  = area_conserve_remap (slon1, slat1, sftlf,     slon, slat, opt)
            landmask  = area_conserve_remap (slon1, slat1, landmask0, slon, slat, opt)
         else
            ts1       = area_conserve_remap (slon1, slat1, ts,        slon, slat, False)
            landfrac  = area_conserve_remap (slon1, slat1, sftlf,     slon, slat, False)
            landmask  = area_conserve_remap (slon1, slat1, landmask0, slon, slat, False)
         end if

         landmask     = where(landmask.ge.1, 1, 0)

         Ts1Mean  = dim_avg_n(ts1, 0)

         CheckMax = Ts1Mean - RawMax(nv)
         CheckMin = RawMin(nv)  - Ts1Mean

         CheckMax = where(CheckMax.ge.0, 0, 1)
         CheckMin = where(CheckMin.ge.0, 0, 1)

         ;landmask = landmask * CheckMax * CheckMin

         delete(Ts1Mean)
         delete(CheckMax)
         delete(CheckMin)

         area=new((/nlat,nlon/), float)

         dlon = abs((slon(1)-slon(0))*RR0)
         dlat = abs((slat(0)-slat(1))*RR0)
         dy = Rad*dlat

         do ny = 0, nlat-1
         do nx = 0, nlon-1
            dx = Rad*cos(RR0*slat(ny))*dlon
            area(ny,nx)=dx*dy
         end do
         end do

         delete(landmask0)
      end if

      do nx=0, nlon/2-1
         ts_mod(nv,:,:,nlon/2+nx)  = (/ts1(:,:,nx)/)
         ts_mod(nv,:,:,nx)         = (/ts1(:,:,nlon/2+nx)/)
         landf_mod(nv,:,nlon/2+nx) = (/landfrac(:,nx)/)
         landf_mod(nv,:,nx)        = (/landfrac(:,nlon/2+nx)/)
         landm_mod(nv,:,nlon/2+nx) = (/landmask(:,nx)/)
         landm_mod(nv,:,nx)        = (/landmask(:,nlon/2+nx)/)
         area_mod(nv,:,nlon/2+nx)  = (/area(:,nx)/)
         area_mod(nv,:,nx)         = (/area(:,nlon/2+nx)/)
      end do

      delete(ts1)
   end if

   delete(ts)
   delete(ndims)
   delete(slat1)
   delete(slon1)
   delete(sftlf)
   delete(area0)
   delete(area1)
;   delete(landfrac)
;   delete(landmask)
;   delete(area)
;   delete(area01)
;   delete(area02)
end if
end do
else
   DataDirMod = getenv("ILAMB_MODELSDIR") + "/derived/"
end if

ts_mod@_FillValue=-999

if (any(str_lower(VarName).eq.(/"tas", "tos"/))) then
   ts_mod=where(ismissing(ts_mod), -999, ts_mod)
end if

if (SiteID.eq.1) then
   slon = where(slon.gt.180., slon-360., slon)
else
   slon = slon -180.
end if

ts_mod@LandFrac = landf_mod
ts_mod@LandMask = landm_mod
ts_mod@GridArea = area_mod
ts_mod@RawMax   = RawMax
ts_mod@RawMin   = RawMin
ts_mod@RawAvg   = RawGlobAvg

return(ts_mod)

end
