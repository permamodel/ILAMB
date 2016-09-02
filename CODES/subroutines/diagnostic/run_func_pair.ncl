procedure run_func_pair (nvpa:integer) 

begin

; ---------------------------------------------
; set additional parameters
; ---------------------------------------------

  DataDir = getenv("ILAMB_ROOT")

  lags = 0

  regs = new((/4/), float)
  reg1 = new((/4/), float)
  reg2 = new((/4/), float)

; ---------------------------------------------
; End additional parameters setting
; ---------------------------------------------

; ++++++ input control parameters from a file: ../CODES/tempfiles/input_para_pair* +++++

  TableFileName = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_pair" + sprinti("%0.2i",nvpa)

  data_1d = asciiread(str_squeeze(TableFileName),-1,"string")
  ;print(data_1d)

  funcs         = str_squeeze(str_get_field(data_1d(2), 2, ":"))

  Var1          = str_squeeze(str_get_field(data_1d(4), 2, ":"))
  VarUnit1      = str_squeeze(str_get_field(data_1d(5), 2, ":"))
  VarModel1     = str_squeeze(str_get_field(data_1d(6), 2, ":"))
  modelID1      = str_squeeze(str_get_field(data_1d(7), 2, ":"))
  expID1        = str_squeeze(str_get_field(data_1d(8), 2, ":"))
  Source1Ref    = str_get_field(data_1d(9), 2, ":")
  BenchMarkRaw1 = str_squeeze(str_get_field(data_1d(10), 2, ":"))
  ModelRaw1     = str_squeeze(str_get_field(data_1d(11), 2, ":"))

  Var2          = str_squeeze(str_get_field(data_1d(13), 2, ":"))
  VarUnit2      = str_squeeze(str_get_field(data_1d(14), 2, ":"))
  VarModel2     = str_squeeze(str_get_field(data_1d(15), 2, ":"))
  modelID2      = str_squeeze(str_get_field(data_1d(16), 2, ":"))
  expID2        = str_squeeze(str_get_field(data_1d(17), 2, ":"))
  Source2Ref    = str_get_field(data_1d(18), 2, ":")
  BenchMarkRaw2 = str_squeeze(str_get_field(data_1d(19), 2, ":"))
  ModelRaw2     = str_squeeze(str_get_field(data_1d(20), 2, ":"))

  StartYear     = stringtointeger(str_get_field(data_1d(22), 2, ":"))
  EndYear       = stringtointeger(str_get_field(data_1d(23), 2, ":"))
  SubReg        = str_get_field(data_1d(24), 2, ":")

  ModelNames    = str_squeeze(str_get_field(data_1d(27:), 1, " "))
  cmipID        = stringtointeger(str_get_field(data_1d(27:), 2, " "))
  runID         = stringtointeger(str_get_field(data_1d(27:), 3, " "))

  nmod          = dimsizes(ModelNames)

  Source1       = str_get_field(Source1Ref, 1, "(")
  Source2       = str_get_field(Source2Ref, 1, "(")

  Source1       = str_squeeze(Source1)
  Source2       = str_squeeze(Source2)

  delete(data_1d)

  ; Retrieve latitude and longitude for a defined sub-region.
  tlat=new((/1000/), float)
  tlon=new((/1000/), float)

  results = retrieve_latlon_region (SubReg, tlat, tlon)

  i50 = ind(.not.ismissing(tlon))
  j50 = ind(.not.ismissing(tlat))

  regs(0) = min(tlat(j50))
  regs(1) = max(tlat(j50))
  regs(2) = min(tlon(i50))
  regs(3) = max(tlon(i50))

  delete(i50)
  delete(j50)
  delete(tlat)
  delete(tlon)
  delete(results)

  ; ++++++++++++++++++++++++++++ read Benchmark datasets +++++++++++++++++++++++++

  DataInfo1          = retrieve_DataInfo (Var1, Source1)
  Var1@Dimens        = DataInfo1@Dimens
  Var1@LimitFlag     = DataInfo1@LimitFlag
  Var1@SubGlobe      = DataInfo1@SubGlobe
  Var1@LandOnly      = DataInfo1@LandOnly
  Var1@CarbonYearly  = DataInfo1@CarbonYearly
  Var1@CarbonMonthly = DataInfo1@CarbonMonthly
  Var1@VarModelComb  = DataInfo1@VarModelComb
  Var1@GSMLocalRefer = DataInfo1@GSMLocalRefer
  Var1@MassWeighting = DataInfo1@MassWeighting
  Var1@MassWeightingFC = DataInfo1@MassWeightingFC
  Var1@MinFC           = DataInfo1@MinFC

  DataInfo2          = retrieve_DataInfo (Var2, Source2)
  Var2@Dimens        = DataInfo2@Dimens
  Var2@LimitFlag     = DataInfo2@LimitFlag
  Var2@SubGlobe      = DataInfo2@SubGlobe
  Var2@LandOnly      = DataInfo2@LandOnly
  Var2@CarbonYearly  = DataInfo2@CarbonYearly
  Var2@CarbonMonthly = DataInfo2@CarbonMonthly
  Var2@VarModelComb  = DataInfo2@VarModelComb
  Var2@GSMLocalRefer = DataInfo2@GSMLocalRefer
  Var2@MassWeighting = DataInfo2@MassWeighting
  Var2@MassWeightingFC = DataInfo2@MassWeightingFC
  Var2@MinFC           = DataInfo2@MinFC

  print("                                                                       ")
  print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
  print("Reading Benchmark for the variable: " + str_upper(Var1))
  ts1_obs = get_benchmark (Var1, Source1, BenchMarkRaw1, StartYear, EndYear)

  print("                                                                       ")
  print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
  print("Reading Benchmark for the variable: " + str_upper(Var2))
  ts2_obs = get_benchmark (Var2, Source2, BenchMarkRaw2, StartYear, EndYear)

  slat      = ts1_obs@lat
  slon      = ts1_obs@lon

  landf_obs = ts1_obs@LandFrac
  area_obs  = ts1_obs@GridArea

  alt0      = ts1_obs@alt
  LandType0 = ts1_obs@LandType
  SiteName0 = ts1_obs@SiteName

  alts      = str_split(alt0, ",")
  LandTypes = str_split(LandType0, ",")
  SiteNames = str_split(SiteName0, ",")

  if (any(DataInfo1@Dimens.eq.(/"Ds", "D1", "D1s"/))) then
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

  delete (alt0)
  delete (LandType0)
  delete (SiteName0)

  ; +++++++++++++++++++++++++ read CMIP5 model datasets +++++++++++++++++++++++++++++

  if (str_lower(ModelNames(0)).eq."meanmodel") then
     ModelName0 = ModelNames(1:nmod-1)
     runID0     = runID(1:nmod-1)
  else
     ModelName0 = ModelNames
     runID0     = runID
  end if

  imod = ind(runID0.gt.0)

  ndim=dimsizes(ts1_obs)
  ntot=ndim(0)
  delete(ndim)

  if (SiteID.eq.1) then

     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Reading Model Simulations for the variable: " + str_upper(Var1))
     ts01_mod = get_model (DataDir, ModelName0, runID0, modelID1, expID1, Var1, VarModel1, ModelRaw1, StartYear, EndYear, slat, slon, SiteID)
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Reading Model Simulations for the variable: " + str_upper(Var2))
     ts02_mod = get_model (DataDir, ModelName0, runID0, modelID2, expID2, Var2, VarModel2, ModelRaw2, StartYear, EndYear, slat, slon, SiteID)

     landf0_mod  = ts01_mod@LandFrac
     landm0_mod  = ts01_mod@LandMask
     rawmax0_mod = ts01_mod@RawMax
     rawmin0_mod = ts01_mod@RawMin
     rawavg0_mod = ts01_mod@RawAvg
     area0_mod   = ts01_mod@GridArea

     if (str_lower(ModelNames(0)).eq."meanmodel" .and. all(imod.ge.0)) then

        ts1_mod    = new((/nmod,ntot,nsit/), float)
        ts2_mod    = new((/nmod,ntot,nsit/), float)
        area_mod   = new((/nmod,nsit/), float)
        landf_mod  = new((/nmod,nsit/), float)
        landm_mod  = new((/nmod,nsit/), float)
        rawmax_mod = new((/nmod/), float)
        rawmin_mod = new((/nmod/), float)
        rawavg_mod = new((/nmod/), float)

        ts1_mod(0,:,:)        = dim_avg_n(ts01_mod, 0)
        ts1_mod(1:nmod-1,:,:) = ts01_mod

        ts2_mod(0,:,:)        = dim_avg_n(ts02_mod, 0)
        ts2_mod(1:nmod-1,:,:) = ts02_mod

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
        ts1_mod               = ts01_mod
        ts2_mod               = ts02_mod
        area_mod              = area0_mod
        landf_mod             = landf0_mod
        landm_mod             = landm0_mod
        rawmax_mod            = rawmax0_mod
        rawmin_mod            = rawmin0_mod
        rawavg_mod            = rawavg0_mod
     end if

     delete(ts01_mod)
     delete(ts02_mod)
     delete(area0_mod)
     delete(landf0_mod)
     delete(landm0_mod)
     delete(rawmax0_mod)
     delete(rawmin0_mod)
     delete(rawavg0_mod)

  else

     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Reading Model Simulations for the variable: " + str_upper(Var1))
     ts01_mod = get_model (DataDir, ModelName0, runID0, modelID1, expID1, Var1, VarModel1, ModelRaw1, StartYear, EndYear, slat, slon, SiteID)
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Reading Model Simulations for the variable: " + str_upper(Var2))
     ts02_mod = get_model (DataDir, ModelName0, runID0, modelID2, expID2, Var2, VarModel2, ModelRaw2, StartYear, EndYear, slat, slon, SiteID)

     landf0_mod  = ts01_mod@LandFrac
     landm0_mod  = ts01_mod@LandMask
     rawmax0_mod = ts01_mod@RawMax
     rawmin0_mod = ts01_mod@RawMin
     rawavg0_mod = ts01_mod@RawAvg
     area0_mod   = ts01_mod@GridArea

     if (str_lower(ModelNames(0)).eq."meanmodel" .and. all(imod.ge.0)) then

        ts1_mod   = new((/nmod,ntot,nlat,nlon/), float)
        ts2_mod   = new((/nmod,ntot,nlat,nlon/), float)
        area_mod  = new((/nmod,nlat,nlon/), float)
        landf_mod = new((/nmod,nlat,nlon/), float)
        landm_mod  = new((/nmod,nlat,nlon/), float)
        rawmax_mod = new((/nmod/), float)
        rawmin_mod = new((/nmod/), float)
        rawavg_mod = new((/nmod/), float)

        ts1_mod(0,:,:,:)        = dim_avg_n(ts01_mod, 0)
        ts1_mod(1:nmod-1,:,:,:) = ts01_mod

        ts2_mod(0,:,:,:)        = dim_avg_n(ts02_mod, 0)
        ts2_mod(1:nmod-1,:,:,:) = ts02_mod

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
        ts1_mod                 = ts01_mod
        ts2_mod                 = ts02_mod
        area_mod                = area0_mod
        landf_mod               = landf0_mod
        landm_mod               = landm0_mod
        rawmax_mod              = rawmax0_mod
        rawmin_mod              = rawmin0_mod
        rawavg_mod              = rawavg0_mod
     end if

     delete(ts01_mod)
     delete(ts02_mod)
     delete(area0_mod)
     delete(landf0_mod)
     delete(landm0_mod)
     delete(rawmax0_mod)
     delete(rawmin0_mod)
     delete(rawavg0_mod)

  end if

  delete(imod)
  delete(runID0)
  delete(ModelName0)

  print("                                                                       ")
  print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
  print("Convert unit from CMIP5 convention (initial or default) to expected one (final)")

  result1 = retrieve_unit (Var1, Source1)
  result2 = retrieve_unit (Var2, Source2)

  if (any(str_lower(Var1).eq.(/"sst", "tas", "ts"/))) then
     ts1_obs = ts1_obs+result1
     ts1_mod = ts1_mod+result1
  else
     ts1_obs = ts1_obs*result1
     ts1_mod = ts1_mod*result1
  end if

  if (any(str_lower(Var2).eq.(/"sst", "tas", "ts"/))) then
     ts2_obs = ts2_obs+result2
     ts2_mod = ts2_mod+result2
  else
     ts2_obs = ts2_obs*result2
     ts2_mod = ts2_mod*result2
  end if

  if (isatt(ts1_obs, "lat")) then
     delete(ts1_obs@lat)
  end if

  if (isatt(ts1_obs, "lon")) then
     delete(ts1_obs@lon)
  end if

  if (isatt(ts1_obs, "alt")) then
     delete(ts1_obs@alt)
  end if

  if (isatt(ts1_obs, "LandFrac")) then
     delete(ts1_obs@LandFrac)
  end if

  if (isatt(ts1_obs, "LandType")) then
     delete(ts1_obs@LandType)
  end if

  if (isatt(ts1_obs, "SiteName")) then
     delete(ts1_obs@SiteName)
  end if

  if (isatt(ts2_obs, "lat")) then
     delete(ts2_obs@lat)
  end if

  if (isatt(ts2_obs, "lon")) then
     delete(ts2_obs@lon)
  end if

  if (isatt(ts2_obs, "alt")) then
     delete(ts2_obs@alt)
  end if

  if (isatt(ts2_obs, "LandFrac")) then
     delete(ts2_obs@LandFrac)
  end if

  if (isatt(ts2_obs, "LandType")) then
     delete(ts2_obs@LandType)
  end if

  if (isatt(ts2_obs, "SiteName")) then
     delete(ts2_obs@SiteName)
  end if

  if (isatt(ts1_mod, "LandFrac")) then
     delete(ts1_mod@LandFrac)
  end if

  if (isatt(ts2_mod, "LandFrac")) then
     delete(ts2_mod@LandFrac)
  end if

  if (isatt(ts1_mod, "LandMask")) then
     delete(ts1_mod@LandMask)
  end if

  if (isatt(ts2_mod, "LandMask")) then
     delete(ts2_mod@LandMask)
  end if

  if (isatt(ts1_mod, "RawMax")) then
     delete(ts1_mod@RawMax)
  end if

  if (isatt(ts2_mod, "RawMax")) then
     delete(ts2_mod@RawMax)
  end if

  if (isatt(ts1_mod, "RawMin")) then
     delete(ts1_mod@RawMin)
  end if

  if (isatt(ts2_mod, "RawMin")) then
     delete(ts2_mod@RawMin)
  end if

  if (isatt(ts1_mod, "RawAvg")) then
     delete(ts1_mod@RawAvg)
  end if

  if (isatt(ts2_mod, "RawAvg")) then
     delete(ts2_mod@RawAvg)
  end if

  if (isatt(ts1_mod, "GridArea")) then
     delete(ts1_mod@GridArea)
  end if

  if (isatt(ts2_mod, "GridArea")) then
     delete(ts2_mod@GridArea)
  end if

  ts1_obs@lat      = slat
  ts1_obs@lon      = slon
  ts1_obs@alt      = alts
  ts1_obs@LandFrac = landf_obs
  ts1_obs@GridArea = area_obs
  ts1_obs@LandType = LandTypes
  ts1_obs@SiteName = SiteNames

  ts2_obs@lat      = slat
  ts2_obs@lon      = slon
  ts2_obs@alt      = alts
  ts2_obs@LandFrac = landf_obs
  ts2_obs@GridArea = area_obs
  ts2_obs@LandType = LandTypes
  ts2_obs@SiteName = SiteNames

  ts1_mod@LandFrac = landf_mod
  ts1_mod@LandMask = landm_mod
  ts1_mod@RawMax   = rawmax_mod
  ts1_mod@RawMin   = rawmin_mod
  ts1_mod@RawAvg   = rawavg_mod
  ts1_mod@GridArea = area_mod

  ts2_mod@LandFrac = landf_mod
  ts2_mod@LandMask = landm_mod
  ts2_mod@RawMax   = rawmax_mod
  ts2_mod@RawMin   = rawmin_mod
  ts2_mod@RawAvg   = rawavg_mod
  ts2_mod@GridArea = area_mod

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

  delete(result1)
  delete(result2)

  if (funcs.eq."correlation_line2line") then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Running Pair variables Function: " + str_upper(funcs))
     if (SiteID.eq.1) then
     else
        correlation_line2line (DataDir, ModelNames, runID, Var1, Var2, Source1, Source2, VarUnit1, VarUnit2, ts1_obs, ts2_obs, \
                      ts1_mod, ts2_mod, StartYear, EndYear, slat, slon,reg1,reg2,lags)
     end if
  end if

  if (funcs.eq."correlation_line2map") then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Running Pair variables Function: " + str_upper(funcs))
     if (SiteID.eq.1) then
     else
        correlation_line2map (DataDir, ModelNames, runID, Var1, Var2, Source1, Source2, VarUnit1, VarUnit2, ts1_obs, ts2_obs, \
                      ts1_mod, ts2_mod, StartYear, EndYear, slat, slon,reg1,reg2,lags)
     end if
  end if

  if (funcs.eq."correlation_map2map") then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Running Pair variables Function: " + str_upper(funcs))
     if (SiteID.eq.1) then
     else
        correlation_map2map (DataDir, ModelNames, runID, Var1, Var2, Source1, Source2, VarUnit1, VarUnit2, ts1_obs, ts2_obs, \
                      ts1_mod, ts2_mod, StartYear, EndYear, slat, slon,reg1,reg2,lags)
     end if
  end if

  if (funcs.eq."function_bar") then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Running Pair variables Function: " + str_upper(funcs))
     if (SiteID.eq.1) then
     else
        function_bar (DataDir, ModelNames, runID, Var1, Var2, Source1, Source2, VarUnit1, VarUnit2, ts1_obs, ts2_obs, \
                      ts1_mod, ts2_mod, StartYear, EndYear, slat, slon,regs)
     end if
  end if

  if (funcs.eq."linear_prediction") then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Running Pair variables Function: " + str_upper(funcs))
     if (SiteID.eq.1) then
     else
     end if
  end if

end
