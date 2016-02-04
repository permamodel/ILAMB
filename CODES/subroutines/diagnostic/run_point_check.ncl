procedure run_point_check (nck:integer) 

begin

; ---------------------------------------------
; set additional parameters
; ---------------------------------------------

  DataDir = getenv("ILAMB_ROOT")

; ---------------------------------------------
; End additional parameters setting
; ---------------------------------------------
; ################################################################################################################################

; ++++++ input control parameters from a file: ../CODES/tempfiles/input_para_check* +++++

  TableFileName = DataDir + "/CODES/tempfiles/input_para_check" + sprinti("%0.2i",nck)

  data_1d = asciiread(str_squeeze(TableFileName),-1,"string")
  ;print(data_1d)

  VarName      = str_squeeze(str_get_field(data_1d(1), 2, ":"))
  VarUnit      = str_squeeze(str_get_field(data_1d(2), 2, ":"))
  VarModel     = str_squeeze(str_get_field(data_1d(3), 2, ":"))
  modelID      = str_squeeze(str_get_field(data_1d(4), 2, ":"))
  expID        = str_squeeze(str_get_field(data_1d(5), 2, ":"))

  SourceRef    = str_get_field(data_1d(6), 2, ":")
  BenchMarkRaw = str_squeeze(str_get_field(data_1d(7), 2, ":"))
  ModelRaw     = str_squeeze(str_get_field(data_1d(8), 2, ":"))
  StartYear    = stringtointeger(str_get_field(data_1d(9), 2, ":"))
  EndYear      = stringtointeger(str_get_field(data_1d(10), 2, ":"))
  SubReg       = str_get_field(data_1d(11), 2, ":")
  KeyWord      = str_get_field(data_1d(12), 2, ":")
  ModelNames   = str_squeeze(str_get_field(data_1d(15:), 1, " "))
  cmipID       = stringtointeger(str_get_field(data_1d(15:), 2, " "))
  runID        = stringtointeger(str_get_field(data_1d(15:), 3, " "))

  Source       = str_get_field(SourceRef, 1, "(")

  nmod         = dimsizes(ModelNames)
  nkey         = dimsizes(str_split(KeyWord,","))
  KeyWords     = str_squeeze(str_split(KeyWord,","))

  delete(data_1d)
  delete(KeyWord)

  DataInfo              = retrieve_DataInfo (VarName, Source)
  VarName@Dimens        = DataInfo@Dimens
  VarName@LimitFlag     = DataInfo@LimitFlag
  VarName@SubGlobe      = DataInfo@SubGlobe
  VarName@LandOnly      = DataInfo@LandOnly
  VarName@CarbonYearly  = DataInfo@CarbonYearly
  VarName@CarbonMonthly = DataInfo@CarbonMonthly
  VarName@VarModelComb  = DataInfo@VarModelComb
  VarName@GSMLocalRefer = DataInfo@GSMLocalRefer
  VarName@MassWeighting = DataInfo@MassWeighting
  VarName@MassWeightingFC = DataInfo@MassWeightingFC
  VarName@MinFC           = DataInfo@MinFC

  Source = str_squeeze(Source)
  SubReg = str_squeeze(SubReg)

  if (str_upper(Source).eq."NOAA.GMD" .and. str_upper(SubReg).eq."GLOBAL") then
     SubReg = "global.large"
  end if

  ; ++++++++++++++++++++++++++++ read Benchmark datasets +++++++++++++++++++++++++
  print("                                                                       ")
  print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
  print("Reading Benchmark for the variable: " + str_upper(VarName))
  ts_obs = get_benchmark (VarName, Source, BenchMarkRaw, StartYear, EndYear)

  slat      = ts_obs@lat
  slon      = ts_obs@lon

  landf_obs = ts_obs@LandFrac
  area_obs  = ts_obs@GridArea

  alt0      = ts_obs@alt
  LandType0 = ts_obs@LandType
  SiteName0 = ts_obs@SiteName

  alts      = str_split(alt0, ",")
  LandTypes = str_split(LandType0, ",")
  SiteNames = str_split(SiteName0, ",")

  if (any(DataInfo@Dimens.eq.(/"Ds", "D1", "D1s"/))) then
     if (dimsizes(slat).gt.1) then
        SiteID      = 1
        SiteID@NAME = "SITES"
        nsit        = dimsizes(slat)
     else
        SiteID      = 1
        SiteID@NAME = "SITE"
        nsit        = 1
     end if
  else
     SiteID      = 0
     SiteID@NAME = "REGION"
     nlat        = dimsizes(slat)
     nlon        = dimsizes(slon)
  end if

  delete(alt0)
  delete(LandType0)
  delete(SiteName0)

  ; +++++++++++++++++++++++++ read CMIP5 model datasets +++++++++++++++++++++++++++++

  if (str_lower(ModelNames(0)).eq."meanmodel") then
     ModelName0 = ModelNames(1:nmod-1)
     runID0     = runID(1:nmod-1)
  else
     ModelName0 = ModelNames
     runID0     = runID
  end if

  imod = ind(runID0.gt.0)

  ndim=dimsizes(ts_obs)
  ntot=ndim(0)
  delete(ndim)

  if (SiteID.eq.1) then

     if (str_lower(ModelRaw).eq."yes") then
        print("                                                                       ")
        print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
        print("Reading Model Simulations for the variable: " + str_upper(VarName))
        undef("ts_mod")
        ts0_mod = get_model (DataDir, ModelName0, runID0, modelID, expID, VarName, VarModel, ModelRaw, StartYear, EndYear, slat, slon, SiteID)
     end if

     landf0_mod  = ts0_mod@LandFrac
     landm0_mod  = ts0_mod@LandMask
     rawmax0_mod = ts0_mod@RawMax
     rawmin0_mod = ts0_mod@RawMin
     rawavg0_mod = ts0_mod@RawAvg
     area0_mod   = ts0_mod@GridArea

     if (str_lower(ModelNames(0)).eq."meanmodel" .and. all(imod.ge.0)) then

        ts_mod     = new((/nmod,ntot,nsit/), float)
        area_mod   = new((/nmod,nsit/), float)
        landf_mod  = new((/nmod,nsit/), float)
        landm_mod  = new((/nmod,nsit/), float)
        rawmax_mod = new((/nmod/), float)
        rawmin_mod = new((/nmod/), float)
        rawavg_mod = new((/nmod/), float)

        ts_mod(0,:,:)        = dim_avg_n(ts0_mod, 0)
        ts_mod(1:nmod-1,:,:) = ts0_mod

        area_mod(0,:)         = dim_avg_n(area0_mod, 0)
        area_mod(1:nmod-1,:)  = area0_mod
        landf_mod(0,:)        = dim_avg_n(landf0_mod, 0)
        landf_mod(1:nmod-1,:) = landf0_mod
        landm_mod(0,:)        = dim_avg_n(landm0_mod, 0)
        landm_mod(1:nmod-1,:) = landm0_mod
        rawmax_mod(0)         = dim_avg_n(rawmax0_mod, 0)
        rawmax_mod(1:nmod-1)  = rawmax0_mod
        rawmin_mod(0)         = dim_avg_n(rawmin0_mod, 0)
        rawmin_mod(1:nmod-1)  = rawmin0_mod
        rawavg_mod(0)         = dim_avg_n(rawavg0_mod, 0)
        rawavg_mod(1:nmod-1)  = rawavg0_mod
     else
        ts_mod                = ts0_mod
        area_mod              = area0_mod
        landf_mod             = landf0_mod
        landm_mod             = landm0_mod
        rawmax_mod            = rawmax0_mod
        rawmin_mod            = rawmin0_mod
        rawavg_mod            = rawavg0_mod
     end if

     delete(ts0_mod)
     delete(area0_mod)
     delete(landf0_mod)
     delete(landm0_mod)
     delete(rawmax0_mod)
     delete(rawmin0_mod)
     delete(rawavg0_mod)

  else

     if (str_lower(ModelRaw).eq."yes") then
        print("                                                                       ")
        print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
        print("Reading Model Simulations for the variable: " + str_upper(VarName))
        undef("ts_mod")
        ts0_mod = get_model (DataDir, ModelName0, runID0, modelID, expID, VarName, VarModel, ModelRaw, StartYear, EndYear, slat, slon, SiteID)
     end if

     landf0_mod  = ts0_mod@LandFrac
     landm0_mod  = ts0_mod@LandMask
     rawmax0_mod = ts0_mod@RawMax
     rawmin0_mod = ts0_mod@RawMin
     rawavg0_mod = ts0_mod@RawAvg
     area0_mod   = ts0_mod@GridArea

     if (str_lower(ModelNames(0)).eq."meanmodel" .and. all(imod.ge.0)) then

        ts_mod    = new((/nmod,ntot,nlat,nlon/), float)
        area_mod  = new((/nmod,nlat,nlon/), float)
        landf_mod = new((/nmod,nlat,nlon/), float)
        landm_mod  = new((/nmod,nlat,nlon/), float)
        rawmax_mod = new((/nmod/), float)
        rawmin_mod = new((/nmod/), float)
        rawavg_mod = new((/nmod/), float)

        ts_mod(0,:,:,:)         = dim_avg_n(ts0_mod, 0)
        ts_mod(1:nmod-1,:,:,:)  = ts0_mod
        area_mod(0,:,:)         = dim_avg_n(area0_mod, 0)
        area_mod(1:nmod-1,:,:)  = area0_mod
        landf_mod(0,:,:)        = dim_avg_n(landf0_mod, 0)
        landf_mod(1:nmod-1,:,:) = landf0_mod
        landm_mod(0,:,:)        = dim_avg_n(landm0_mod, 0)
        landm_mod(1:nmod-1,:,:) = landm0_mod
        rawmax_mod(0)           = dim_avg_n(rawmax0_mod, 0)
        rawmax_mod(1:nmod-1)    = rawmax0_mod
        rawmin_mod(0)           = dim_avg_n(rawmin0_mod, 0)
        rawmin_mod(1:nmod-1)    = rawmin0_mod
        rawavg_mod(0)           = dim_avg_n(rawavg0_mod, 0)
        rawavg_mod(1:nmod-1)    = rawavg0_mod
     else
        ts_mod                  = ts0_mod
        area_mod                = area0_mod
        landf_mod               = landf0_mod
        landm_mod               = landm0_mod
        rawmax_mod              = rawmax0_mod
        rawmin_mod              = rawmin0_mod
        rawavg_mod              = rawavg0_mod

     end if

     delete(ts0_mod)
     delete(area0_mod)
     delete(landf0_mod)
     delete(landm0_mod)
     delete(rawmax0_mod)
     delete(rawmin0_mod)
     delete(rawavg0_mod)

  end if

  if (isatt(ts_obs, "lat")) then
     delete(ts_obs@lat)
  end if

  if (isatt(ts_obs, "lon")) then
     delete(ts_obs@lon)
  end if

  if (isatt(ts_obs, "alt")) then
     delete(ts_obs@alt)
  end if

  if (isatt(ts_obs, "LandFrac")) then
     delete(ts_obs@LandFrac)
  end if

  if (isatt(ts_obs, "LandType")) then
     delete(ts_obs@LandType)
  end if

  if (isatt(ts_obs, "LandType")) then
     delete(ts_obs@LandType)
  end if

  if (isatt(ts_obs, "SiteName")) then
     delete(ts_obs@SiteName)
  end if

  if (isatt(ts_mod, "LandFrac")) then
     delete(ts_mod@LandFrac)
  end if

  if (isatt(ts_mod, "LandMask")) then
     delete(ts_mod@LandMask)
  end if

  if (isatt(ts_mod, "RawMax")) then
     delete(ts_mod@RawMax)
  end if

  if (isatt(ts_mod, "RawMin")) then
     delete(ts_mod@RawMin)
  end if

  if (isatt(ts_mod, "RawAvg")) then
     delete(ts_mod@RawAvg)
  end if

  if (isatt(ts_mod, "GridArea")) then
     delete(ts_mod@GridArea)
  end if

  ts_obs@lat      = slat
  ts_obs@lon      = slon
  ts_obs@alt      = alts
  ts_obs@LandFrac = landf_obs
  ts_obs@GridArea = area_obs
  ts_obs@LandType = LandTypes
  ts_obs@SiteName = SiteNames

  ts_mod@LandFrac = landf_mod
  ts_mod@LandMask = landm_mod
  ts_mod@RawMax   = rawmax_mod
  ts_mod@RawMin   = rawmin_mod
  ts_mod@RawAvg   = rawavg_mod
  ts_mod@GridArea = area_mod

  delete(alts)
  delete(landf_obs)
  delete(landf_mod)
  delete(landm_mod)
  delete(rawmax_mod)
  delete(rawmin_mod)
  delete(rawavg_mod)
  delete(area_obs)
  delete(area_mod)
  delete(LandTypes)
  delete(SiteNames)

  delete(imod)
  delete(runID0)
  delete(ModelName0)

  print("                                                                       ")
  print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
  print("Convert unit from CMIP5 convention (initial or default) to expected one (final)")

  results = retrieve_unit (VarName, Source)

  if (any(str_lower(VarName).eq.(/"sst", "tas", "ts"/))) then
     ts_obs = ts_obs+results
     ts_mod = ts_mod+results
  else
     ts_obs = ts_obs*results
     ts_mod = ts_mod*results
  end if

  delete(results)

  if (SiteID.eq.0 .and. str_upper(SiteID@NAME).eq."REGION") then
     latlon = retrieve_box_or_point (Source)
  else
     slon = where(slon.gt.180, slon-360, slon)
     latlon=new((/4,nsit/), float)
     latlon(0,:) = slat ; latitudes of points or minimum latiudes of regions
     latlon(1,:) = slon ; longitudes of points or minimum longitudes of regions
  end if

  ts_obs@_FillValue=-999
  ts_mod@_FillValue=-999

  if (any(str_upper(SiteID@NAME).eq.(/"SITE", "SITES"/))) then
     CheckPoint_site (DataDir, ModelNames, runID, VarName, Source, VarUnit, ts_obs, ts_mod, StartYear, EndYear, \
                     slat, slon, latlon(:,0:nsit-1), SiteID, SubReg)
  else
     CheckPoint_box (DataDir, ModelNames, runID, VarName, Source, VarUnit, ts_obs, ts_mod, StartYear, EndYear, \
                slat, slon, latlon(:,0:nsit-1), SiteID, SubReg)
  end if

end
