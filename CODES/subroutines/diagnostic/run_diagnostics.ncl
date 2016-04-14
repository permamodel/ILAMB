procedure run_diagnostics (VarName:string) 

begin

; ---------------------------------------------
; Set additional paratmeters
; ---------------------------------------------

DataDir = getenv("ILAMB_ROOT")

; ---------------------------------------------
; End additional parameters setting
; ---------------------------------------------
; ################################################################################################################################

; ++++++ Retrieve all parameters for diagnostics for a single variable: ../CODES/tempfiles/input_para_* +++++

print("                                                                       ")
print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
print("Searching All Data Sources for the Variable: " + VarName)

InputFiles = DataDir + "/CODES/tempfiles/input_para_" + str_lower(VarName)

FileList = systemfunc ("ls " + InputFiles + "*")

FileList = str_squeeze(FileList)

nsur     = dimsizes(FileList)

if (nsur.gt.1) then
   Sources        = new((/nsur/), string)
   do ns = 0, nsur-1
      Sourcet0    = str_split(FileList(ns),"/")
      nlast0      = dimsizes(Sourcet0)
      Sourcet1    = str_split(Sourcet0(nlast0-1),"_")
      nlast1      = dimsizes(Sourcet1)
      Sources(ns) = Sourcet1(nlast1-1)
      delete(Sourcet0)
      delete(Sourcet1)
   end do
else
   Sourcet0 = str_split(FileList,"/")
   nlast0   = dimsizes(Sourcet0)
   Sourcet1 = str_split(Sourcet0(nlast0-1),"_")
   nlast1   = dimsizes(Sourcet1)
   Sources  = Sourcet1(nlast1-1)
   delete(Sourcet0)
   delete(Sourcet1)
end if

delete(FileList)

; ---------------------------------------------
; Set additional arrays
; ---------------------------------------------
StartYears = new((/nsur/), integer)
EndYears   = new((/nsur/), integer)

results   = retrieve_others("Metrics", "-999")
KeyWords  = results@Category

delete(results)

nkeys = dimsizes(KeyWords)

nKeyWords   = new((/nkeys/), integer)

nKeyWords   = 0

do ns=0,nsur-1

  TableFileName = DataDir + "/CODES/tempfiles/input_para_" + str_lower(VarName) + "_" + str_upper(Sources(ns))

  data_1d = asciiread(str_squeeze(TableFileName),-1,"string")
  ;print(data_1d)

  Var          = str_squeeze(str_get_field(data_1d(1), 2, ":"))
  VarUnit      = str_squeeze(str_get_field(data_1d(2), 2, ":"))
  VarModel     = str_squeeze(str_get_field(data_1d(3), 2, ":"))
  modelID      = str_squeeze(str_get_field(data_1d(4), 2, ":"))
  expID        = str_squeeze(str_get_field(data_1d(5), 2, ":"))

  SourceRef    = str_get_field(data_1d(6), 2, ":")
  BenchMarkRaw = str_squeeze(str_get_field(data_1d(7), 2, ":"))
  ModelRaw     = str_squeeze(str_get_field(data_1d(8), 2, ":"))
  StartYear    = stringtointeger(str_get_field(data_1d(9), 2, ":"))
  EndYear      = stringtointeger(str_get_field(data_1d(10), 2, ":"))
  SubReg1      = str_squeeze(str_get_field(data_1d(11), 2, ":"))
  SubReg2      = str_squeeze(str_get_field(data_1d(12), 2, ":"))
  KeyWord0     = str_get_field(data_1d(13), 2, ":")
  ModelNames   = str_squeeze(str_get_field(data_1d(16:), 1, " "))
  cmipID       = stringtointeger(str_get_field(data_1d(16:), 2, " "))
  runID        = stringtointeger(str_get_field(data_1d(16:), 3, " "))

  nmod         = dimsizes(ModelNames)
  nkey         = dimsizes(str_split(KeyWord0,","))
  Source       = str_squeeze(str_get_field(SourceRef, 1, "("))
  KeyWord      = str_squeeze(str_split(KeyWord0,","))

  StartYears(ns) = StartYear
  EndYears(ns)   = EndYear

  ;if (nkey.gt.nkeys) then
  ;   delete(KeyWords)
  ;   KeyWords = KeyWord
  ;   nkeys    = nkey
  ;end if

  do nk=0,nkey-1
     i50 = ind(str_lower(str_squeeze(KeyWord(nk))).eq.str_lower(str_squeeze(KeyWords)))
     if (.not.ismissing(i50)) then
        nKeyWords(i50) = 1
     end if
     delete(i50)
  end do

  delete(data_1d)
  delete(KeyWord0)

  ; +++++ Install required Data readme files++++
  ReadmeInitial = getenv("ILAMB_DATADIR") + "/" + VarName + "/" + str_upper(Source) + "/original/readme"
  ReadmeFinal   = getenv("ILAMB_OUTPUTDIR") + "/readme/readme_" + str_lower(VarName) + "_" + str_upper(Source)

  system ("/bin/cp -f " + ReadmeInitial + " " + ReadmeFinal)

  DataInfo = retrieve_DataInfo (VarName, Source)
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
  VarName@MinFC         = DataInfo@MinFC

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
     SiteID      = 1
     if (dimsizes(slat).gt.1) then
        SiteID@NAME = "SITES"
     else
        SiteID@NAME = "SITE"
     end if
  else
     SiteID      = 0
     SiteID@NAME = "REGION"
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

     nsit = dimsizes(slat)

     if (str_lower(ModelRaw).eq."yes") then
        print("                                                                       ")
        print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
        print("Reading Model Simulations for the variable: " + str_upper(VarName))
        undef("ts_mod")
        ts0_mod = get_model (DataDir, ModelName0, runID0, modelID, expID, VarName, VarModel, ModelRaw, StartYear, EndYear, slat, slon, SiteID)

        landf0_mod  = ts0_mod@LandFrac
        landm0_mod  = ts0_mod@LandMask
        rawmax0_mod = ts0_mod@RawMax
        rawmin0_mod = ts0_mod@RawMin
        rawavg0_mod = ts0_mod@RawAvg
        area0_mod   = ts0_mod@GridArea

        if (isdouble(ts0_mod)) then
           temp=doubletofloat(ts0_mod)
           delete(ts0_mod)
           ts0_mod = temp
           delete(temp)
        end if
     end if

     if (str_lower(ModelNames(0)).eq."meanmodel" .and. all(imod.ge.0)) then

        ts_mod     = new((/nmod,ntot,nsit/), float)
        area_mod   = new((/nmod,nsit/), float)
        landf_mod  = new((/nmod,nsit/), float)
        landm_mod  = new((/nmod,nsit/), float)
        rawmax_mod = new((/nmod/), float)
        rawmin_mod = new((/nmod/), float)
        rawavg_mod = new((/nmod/), float)

        ts_mod(0,:,:)         = dim_avg_n(ts0_mod, 0)
        ts_mod(1:nmod-1,:,:)  = ts0_mod
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

     nlat = dimsizes(slat)
     nlon = dimsizes(slon)
     
     if (str_lower(ModelRaw).eq."yes") then
        print("                                                                       ")
        print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
        print("Reading Model Simulations for the variable: " + str_upper(VarName))
        undef("ts_mod")
        ts0_mod = get_model (DataDir, ModelName0, runID0, modelID, expID, VarName, VarModel, ModelRaw, StartYear, EndYear, slat, slon, SiteID)

        landf0_mod  = ts0_mod@LandFrac
        landm0_mod  = ts0_mod@LandMask
        rawmax0_mod = ts0_mod@RawMax
        rawmin0_mod = ts0_mod@RawMin
        rawavg0_mod = ts0_mod@RawAvg
        area0_mod   = ts0_mod@GridArea

        if (isdouble(ts0_mod)) then
           temp=doubletofloat(ts0_mod)
           delete(ts0_mod)
           ts0_mod = temp
           delete(temp)
        end if
     end if

     if (str_lower(ModelNames(0)).eq."meanmodel" .and. all(imod.ge.0)) then

        ts_mod     = new((/nmod,ntot,nlat,nlon/), float)
        area_mod   = new((/nmod,nlat,nlon/), float)
        landf_mod  = new((/nmod,nlat,nlon/), float)
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

  delete(imod)
  delete(runID0)
  delete(ModelName0)

  print("                                                                       ")
  print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
  print("Convert unit from CMIP5 convention (initial or default) to expected one (final)")

  UnitCoef = retrieve_unit (VarName, Source)

  if (any(str_lower(VarName).eq.(/"sst", "tas", "ts"/))) then
     ts_obs     = ts_obs+UnitCoef
     ts_mod     = ts_mod+UnitCoef
     rawavg_mod = rawavg_mod+UnitCoef
  else
     ts_obs     = ts_obs*UnitCoef
     ts_mod     = ts_mod*UnitCoef
     rawavg_mod = rawavg_mod*UnitCoef
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
  delete(UnitCoef)
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

  if (.not.ismissing(SubReg1) .and. .not.(str_is_blank(SubReg1)) .and. dimsizes(ind(.not.ismissing(slat))).gt.1) then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Running Sub-region Diagnostics for the variable: " + str_upper(VarName))

     if (any(str_lower(SubReg1).eq.(/"zonal","meridional","season"/))) then
        CheckRegion_belt (DataDir, ModelNames, runID, VarName, Source, VarUnit, ts_obs, \
                          ts_mod, StartYear, EndYear, slat, slon, SubReg1, "Global", SiteID)
     else
        CheckRegion_biome (DataDir, ModelNames, runID, VarName, Source, VarUnit, ts_obs, \
                         ts_mod, StartYear, EndYear, slat, slon, SubReg1, "Global", SiteID)
     end if
  end if

  if (.not.ismissing(ind(str_lower(KeyWord).eq."annualmean"))) then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Running ANNUALMEAN Diagnostics for the variable: " + str_upper(VarName))
     if (SiteID.eq.1) then
         AnnualMean_site (DataDir, ModelNames, runID, VarName, Source, VarUnit,\
                          ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     else
         AnnualMean (DataDir, ModelNames, runID, VarName, Source, VarUnit,\
                     ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     end if
  end if

  if (.not.ismissing(ind(str_lower(KeyWord).eq."bias"))) then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Running BIAS Diagnostics for the variable: " + str_upper(VarName))
     if (SiteID.eq.1) then
         Bias_site (DataDir, ModelNames, runID, VarName, Source, VarUnit,\
                    ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     else
         Bias (DataDir, ModelNames, runID, VarName, Source, VarUnit,\
               ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     end if
  end if

  if (.not.ismissing(ind(str_lower(KeyWord).eq."rmse"))) then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Running RMSE Diagnostics for the variable: " + str_upper(VarName))
     if (SiteID.eq.1) then
         RMSE_site (DataDir, ModelNames, runID, VarName, Source, VarUnit,\
                    ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     else
         RMSE (DataDir, ModelNames, runID, VarName, Source, VarUnit,\
               ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     end if
  end if

  if (.not.ismissing(ind(str_lower(KeyWord).eq."globalbiasscore"))) then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Running Global Bias Score Diagnostics for the variable: " + str_upper(VarName))
     if (SiteID.eq.1) then
         GlobalBiasScore_site (DataDir, ModelNames, runID, VarName, Source, VarUnit,\
                    ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     else
         GlobalBiasScore (DataDir, ModelNames, runID, VarName, Source, VarUnit,\
                    ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     end if
  end if

  if (.not.ismissing(ind(str_lower(KeyWord).eq."rmsescore"))) then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Running RMSE Score Diagnostics for the variable: " + str_upper(VarName))
     if (SiteID.eq.1) then
         RmseScore_site (DataDir, ModelNames, runID, VarName, Source, VarUnit,\
                    ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     else
         RmseScore (DataDir, ModelNames, runID, VarName, Source, VarUnit,\
               ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     end if
  end if

  if (.not.ismissing(ind(str_lower(KeyWord).eq."phasescore"))) then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Calculating PHASESCORE for the variable: " + str_upper(VarName))
     if (SiteID.eq.1) then
         PhaseScore_site (DataDir, ModelNames, runID, VarName, Source, VarUnit,\
                          ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     else
         PhaseScore (DataDir, ModelNames, runID, VarName, Source, VarUnit, \
                     ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     end if
  end if

  if (.not.ismissing(ind(str_lower(KeyWord).eq."taylorscore"))) then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Calculating TAYLORSCORE for the variable: " + str_upper(VarName))
     if (SiteID.eq.1) then
         TaylorScore_site (DataDir, ModelNames, runID, VarName, Source, VarUnit,\
                           ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     else
         TaylorScore (DataDir, ModelNames, runID, VarName, Source, VarUnit, \
                      ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     end if
  end if

  if (.not.ismissing(ind(str_lower(KeyWord).eq."interannualscore"))) then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Calculating INTERANNUALSCORE for the variable: " + str_upper(VarName))
     if (SiteID.eq.1) then
         InterannualScore_site (DataDir, ModelNames, runID, VarName, Source, VarUnit,\
                                ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     else
         InterannualScore (DataDir, ModelNames, runID, VarName, Source, VarUnit, \
                           ts_obs, ts_mod, StartYear, EndYear, slat, slon, SubReg2, SiteID)
     end if
  end if

  if (.not.ismissing(ind(str_lower(KeyWord).eq."overallscore"))) then
     print("                                                                       ")
     print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
     print("Calculating OVERALLSCORE for the variable: " + str_upper(VarName))
     OverAllScore (ModelNames, runID, VarName, KeyWord, Source, StartYear, EndYear)
  end if

  delete(slat)
  delete(slon)
  delete(ts_obs)
  delete(ts_mod)
  delete(DataInfo)
  delete(KeyWord)
end do

j50 = ind(nKeyWords.gt.0)

TempStr = KeyWords(j50)

delete(KeyWords)

KeyWords = TempStr

delete(j50)
delete(TempStr)

; +++++++++++++++++++++++ run summary after diagnostics ++++++++++++++++++++++++
print("                                                                       ")
print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
print("Summarizing All Diagnostics for the variable: " + str_upper(VarName))
summary (ModelNames, VarName, Sources, VarUnit, KeyWords, StartYears, EndYears)

end
