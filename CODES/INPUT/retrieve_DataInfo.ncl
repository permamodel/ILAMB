function retrieve_DataInfo (VarName:string, Source:string)

; This function is used to retrieve information for a given benchmark source and variable.
;
; input and output variables and corresponding meanings:
;
;      VarName: input, shortname of a variable
;       Source: input, shortname of a benchmark data source or a model name
;    LimitFlag: input, cutoff model data by benchmark
;                      Yes: cutoff
;                       No: do not cutoff
;     LandOnly: input, use the unit of land or gridcell area
;                      Yes: land area only
;                       No: whole gridcell area 
;     SubGlobe: input, benchmark is global or sub-global data
;                      Yes: sub global data
;                       No: global data
;     CarbonYearly: input, carbon related variable in yearly time step
;                      Yes: yearly time step
;                       No: others
;     CarbonMonthly: input, carbon related variable in monthly time step
;                      Yes: monthly time step
;                       No: others
;     GSMLocalRefer: input, a switch to use local or global mean reference for global score metrics
;                      Yes: use local reference
;                       No: use global mean reference
;     MassWeighting: input, a switch to mass or area weighting for global mean score
;                      Yes: use mass weighting
;                       No: use area weighting
;     MassWeightingFC: input, a switch to use raw or adjusted mass for mass weighting
;                      Yes: use raw mass
;                       No: use adjusted mass
;        MinFC:  input, adjusted factor coefficient for minimum
;     DataNAME: output, the long name of the source
;    Reference: output, the reference of the data
;     LongName: output, the long name of the variable
;     Category: output, the category of the variable
;     VarModel: output, the variable name for model simulations
;    ModelComp: output, the model component
;       Dimens: output, D3s: 3D time series
;                       D2s: 2D time series
;                       D1s: 1D time series
;                       D3:  3D climatology
;                       D2:  2D climatology
;                       D1:  1D climatology
;                       Ds:  single time series
;         TRes: output, temporal resolution, monthly, yearly or climatology
;      StartYr: output, start year of the data
;        EndYr: output, end year of the data

begin

  ModelType = getenv("MODELTYPE")
  ModelType = str_squeeze(ModelType)

  VarName   = str_squeeze(VarName)
  Source    = str_squeeze(Source)

  ; ++++++++++++++ List all categories here ++++++++++++++++++
  CateInfo = retrieve_others ("Category", "")

  CatNames = CateInfo@Category
  delete(CateInfo)

  ; ++++++++++++++ default parameters for the data ++++++++++++++++++

  DataInfo      = VarName          ; short name of a variable
  DataName      = Source           ; long name of source
  LimitFlag     = "YES"            ; cutoff model data by benchmark
  LandOnly      = "NO"             ; use the unit of land or gridcell area
  SubGlobe      = "NO"             ; benchmark is global or sub-global data
  CarbonVar     = "NO"             ; benchmark is not carbon related variable
  CarbonYearly  = "NO"             ; carbon related variable in yearly time step
  CarbonMonthly = "NO"             ; carbon related variable in monthly time step
  GSMLocalRefer = "NO"             ; a switch to use local or global mean reference for global score metrics
  MassWeighting = "NO"             ; a switch to use mass or area weighting for global mean score
  MassWeightingFC = "NO"           ; a switch to use raw or adjusted mass for mass weighting
  MinFC           = 1.0            ; adjusted factor coefficient for minimum
  Reference     = "N/A"            ; reference for source
  LongName      = VarName          ; long name of a variable
  Category      = "others"         ; categroy name for a variable
  VarModel      = VarName          ; variable name for model simulation
  VarModelComb  = "NO"             ; If the variable for model simulation is the result based on multi-variables 
  ModelComp     = "Amon"           ; name of model component
  Dimens        = "D2s"            ; dimensions
  TRes          = "monthly"        ; temporal resolution
  StartYr       = "2000"           ; Start year of the data 
  EndYr         = "2005"           ; End year of the data

  ; +++ create information for a benchmark source +++++++++++++++++

  if (str_lower(Source).eq."ameriflux") then
     DataName  = "Ameriflux Sites"
     Dimens    = "D1s"    
     TRes      = "monthly"  
     StartYr   = "1996"    
     EndYr     = "2005"     
  end if

  if (str_lower(Source).eq."avhrr") then
     DataName  = Source 
     Dimens    = "D2s"  
     TRes      = "monthly" 
     StartYr   = "1982"  
     EndYr     = "2011"  
  end if

  if (str_lower(Source).eq."ceres") then
     DataName  = Source  
     Dimens    = "D2s" 
     TRes      = "monthly"
     StartYr   = "2000" 
     EndYr     = "2013" 
  end if

  if (str_lower(Source).eq."cru") then
     DataName  = Source  
     Dimens    = "D2s" 
     TRes      = "monthly" 
     StartYr   = "1980"   
     EndYr     = "2013"  
  end if

  if (str_lower(Source).eq."ecv") then
     DataName  = Source 
     Dimens    = "D2s"  
     TRes      = "monthly" 
     StartYr   = "1979"  
     EndYr     = "2010"  
  end if

  if (str_lower(Source).eq."era") then
     DataName  = Source 
     Dimens    = "D2s"  
     TRes      = "monthly" 
     StartYr   = "1979"  
     EndYr     = "2014"  
  end if

  if (str_lower(Source).eq."fluxnet") then
     DataName  = "Fluxnet Sites"
     Dimens    = "D1s"    
     TRes      = "monthly" 
     StartYr   = "1996"   
     EndYr     = "2005"    
  end if

  ; The FOONET benchmark; a test.
  ; if (str_lower(Source).eq."foonet") then
  ;   DataName  = "FOONET sites"
  ;   Dimens    = "D1s"
  ;   TRes      = "monthly"
  ;   StartYr   = "1996"
  ;   EndYr     = "2005"
  ; end if
  
  if (str_lower(Source).eq."fluxnet-mte") then
     DataName  = "Fluxnet Global MTE"
     Dimens    = "D2s"    
     TRes      = "monthly" 
     StartYr   = "1982"     
     EndYr     = "2008"  
  end if

  if (str_lower(Source).eq."grdc") then
     DataName  = "Global Runoff Data Center"
     Dimens    = "D2s"    
     TRes      = "monthly" 
     StartYr   = "2000"     
     EndYr     = "2005"  
  end if

  if (str_lower(Source).eq."hoffman") then
     DataName  = "Khatiwala/Hoffman (1850-2010)"
     Dimens    = "Ds" 
     TRes      = "yearly" 
     StartYr   = "1850"  
     EndYr     = "2010"  
  end if

  if (str_lower(Source).eq."hwsd") then
     DataName  = "Global top 1m Soil Carbon"
     Dimens    = "D2"    
     TRes      = "climatology"
     StartYr   = "1996"    
     EndYr     = "2005"  
  end if

  if (str_lower(Source).eq."gbaf") then
     DataName  = "Global Bio-Atmosphere Flux"
     Dimens    = "D2s"    
     TRes      = "monthly" 
     StartYr   = "1982"     
     EndYr     = "2008"  
  end if

  if (str_lower(Source).eq."gcp") then
     DataName  = "Global Carbon Project (1959-present)"
     Dimens    = "Ds" 
     TRes      = "yearly" 
     StartYr   = "1959" 
     EndYr     = "2012" 
  end if

  if (str_lower(Source).eq."geocarbon") then
     DataName  = "Global Forest Biomass"
     Dimens    = "D2"      
     TRes      = "climatology" 
     StartYr   = "1996"    
     EndYr     = "2005"   
  end if

  if (str_lower(Source).eq."gewex.srb") then
     DataName  = Source 
     Dimens    = "D2s"  
     TRes      = "monthly" 
     StartYr   = "1984" 
     EndYr     = "2007" 
  end if

  if (str_lower(Source).eq."gfed3") then
     DataName  = Source 
     Dimens    = "D2s"  
     TRes      = "monthly" 
     StartYr   = "1997" 
     EndYr     = "2011" 
  end if

  if (str_lower(Source).eq."gleam") then
     DataName  = Source  
     Dimens    = "D2s"  
     TRes      = "monthly" 
     StartYr   = "1980"      
     EndYr     = "2011"  
  end if

  if (str_lower(Source).eq."global.carbon") then
     DataName  = "Pan Tropical Forest"
     Dimens    = "D2"      
     TRes      = "climatology" 
     StartYr   = "1996"    
     EndYr     = "2005"   
  end if

  if (str_lower(Source).eq."gpcc") then
     DataName  = Source  
     Dimens    = "D2s"   
     TRes      = "monthly" 
     StartYr   = "1980"   
     EndYr     = "2010"  
  end if

  if (str_lower(Source).eq."gpcp2") then
     DataName  = Source  
     Dimens    = "D2s"   
     TRes      = "monthly" 
     StartYr   = "1980"   
     EndYr     = "2012"  
  end if

  if (str_lower(Source).eq."grace") then
     DataName  = Source 
     Dimens    = "D2s"   
     TRes      = "monthly"  
     StartYr   = "2003"    
     EndYr     = "2013"  
  end if

  if (str_lower(Source).eq."landflux") then
     DataName  = Source   
     Dimens    = "D2s"    
     TRes      = "monthly"  
     StartYr   = "1989"     
     EndYr     = "2005"   
  end if

  if (str_lower(Source).eq."modis") then
     DataName  = Source  
     Dimens    = "D2s"    
     TRes      = "monthly" 
     StartYr   = "2000"     
     EndYr     = "2005"  
  end if

  if (str_lower(Source).eq."nbcd2000") then
     DataName  = "Contiguous U.S."
     Dimens    = "D2"   
     TRes      = "climatology"
     StartYr   = "1996"   
     EndYr     = "2005"   
  end if

  if (str_lower(Source).eq."ncscdv22") then
     DataName  = "Northern Circumpolar top 1m Soil Carbon"
     Dimens    = "D2"        
     TRes      = "climatology"
     StartYr   = "1996"  
     EndYr     = "2005"  
  end if

  if (str_lower(Source).eq."noaa.io2") then
     DataName  = Source   
     Dimens    = "D2s" 
     TRes      = "monthly"  
     StartYr   = "1982"   
     EndYr     = "2013"      
  end if

  if (str_lower(Source).eq."noaa.gmd") then
     ;DataName  = "Annual Cycle " + Source
     DataName  = "Annual Cycle at NOAA GMD Surface Stations"
     Dimens    = "D1s"  
     TRes      = "monthly" 
     StartYr   = "1980"  
     EndYr     = "2012"   
  end if

  if (str_lower(Source).eq."mauna.loa") then
     DataName  = "Annual Mean Time Series at Mauna Loa"
     Dimens    = "Ds"    
     TRes      = "monthly" 
     StartYr   = "1959"    
     EndYr     = "2013"   
  end if

  ; 'PBS' is the source for Kang's `tsl` and `snd` benchmarks.
  if (str_lower(Source).eq."pbs") then
    DataName  = Source ; Better description?
    Dimens    = "D1s"
    TRes      = "monthly"
    StartYr   = "2001"
    EndYr     = "2014"
  end if

  if (str_lower(Source).eq."us.forest") then
     DataName  = "Contiguous U.S. + Alaska"
     Dimens    = "D2"   
     TRes      = "climatology" 
     StartYr   = "1996"   
     EndYr     = "2005"   
  end if

  if (str_lower(Source).eq."wrmc.bsrn") then
     DataName  = Source   
     Dimens    = "D1s"     
     TRes      = "monthly"  
     StartYr   = "1992"     
     EndYr     = "2012"     
  end if

  ; +++ create information for a variable +++++++++++++++++

  if (str_lower(VarName).eq."albedo") then
     LongName     = "Albedo"
     VarModel     = "rsds"
     ModelComp    = "Amon"    
     Category     = CatNames(2)
     VarModelComb = "YES"
     if (str_lower(Source).eq."ceres") then
        Reference  = "Kato et al. (2013)"
     end if
     if (str_lower(Source).eq."modis") then
        Reference  = "Schaaf et al. (2011)"
        StartYr   = "2000"
        EndYr     = "2005"
     end if
     if (str_lower(Source).eq."gewex.srb") then
        Reference  = "Stackhouse et al. (2011)"
     end if
  end if

  if (str_lower(VarName).eq."biomass") then
     LongName      = "Aboveground Live Biomass"
     ; VarModel      = "cVeg"
     if (str_lower(ModelType).eq."mstmip") then
        VarModel     = "cWood"
     else
        VarModel     = "cVeg"
     end if
     ModelComp     = "Lmon"    
     Category      = CatNames(0)
     LandOnly      = "YES" 
     SubGlobe      = "YES" 
     CarbonYearly  = "YES"
     LimitFlag     = "NO" 
     GSMLocalRefer = "YES"
     MassWeighting = "YES"
     if (str_lower(Source).eq."global.carbon") then
        Reference  = "Saatchi et al. (2011)"
     end if
     if (str_lower(Source).eq."nbcd2000") then
        Reference  = "Kellndorfer et al. (2000)"
     end if
     if (str_lower(Source).eq."geocarbon") then
        Reference  = "Avitabile et al. (2015)"
     end if
     if (str_lower(Source).eq."us.forest") then
        Reference  = "Blackard et al. (2008)"
     end if
  end if

  if (str_lower(VarName).eq."burntarea") then
     LongName      = "Burned Area"
     VarModel      = VarName
     ModelComp     = "Lmon"    
     Category      = CatNames(0)
     CarbonYearly  = "YES"
     LimitFlag     = "NO" 
     GSMLocalRefer = "YES"
     MassWeighting = "YES"
     if (str_lower(Source).eq."gfed3") then
        Reference = "Giglio et al. (2010)"
        LandOnly  = "YES"
     end if
  end if

  if (str_lower(VarName).eq."co2") then
     LongName  = "Carbon Dioxide"
     VarModel  = VarName
     ModelComp = "Amon"    
     Category  = CatNames(0)
     if (str_lower(Source).eq."noaa.gmd") then
        Reference  = "Dlugokencky et al. (2013)"
     end if
     if (str_lower(Source).eq."mauna.loa") then
        Reference  = "Keeling et al. (2005)"
     end if
  end if

  if (str_lower(VarName).eq."et") then
     LongName      = "Evapotranspiration"
     VarModel      = "evspsbl"
     ModelComp     = "Amon"    
     Category      = CatNames(1)
     GSMLocalRefer = "YES"
     MassWeighting = "YES"
     if (str_lower(Source).eq."gleam") then
        Reference  = "Miralles et al. (2011)"
     end if
     if (str_lower(Source).eq."landflux") then
        Reference  = "Mueller et al. (2013)"
     end if
     if (str_lower(Source).eq."modis") then
        Reference  = "Mu et al. (2011)"
        StartYr    = "2000"     
        EndYr      = "2013"  
     end if
  end if

  if (str_lower(VarName).eq."gpp") then
     LongName      = "Gross Primary Productivity"
     VarModel      = VarName
     ModelComp     = "Lmon"    
     Category      = CatNames(0)
     GSMLocalRefer = "YES"
     MassWeighting = "YES"
     if (str_lower(Source).eq."fluxnet") then
        Reference  ="Lasslop et al. (2010)"
     end if
     ; if (str_lower(Source).eq."foonet") then ; for the FOONET benchmark; a test
     ;    Reference  ="PBS team (2016)"
     ; end if
     if (any(str_lower(Source).eq.(/"fluxnet-mte", "gbaf"/))) then
        Reference     = "Jung et al. (2009)"
        LandOnly      = "YES" 
        CarbonMonthly = "YES"
        LimitFlag     = "NO" 
     end if
  end if

  if (str_lower(VarName).eq."lai") then
     LongName      = "Leaf Area Index"
     VarModel      = VarName
     ModelComp     = "Lmon"    
     Category      = CatNames(0)
     GSMLocalRefer = "YES"
     MassWeighting = "YES"
     if (str_lower(Source).eq."avhrr") then
        Reference  = "Myneni et al. (1997)"
     end if
     if (str_lower(Source).eq."modis") then
        Reference  = "De Kauwe et al. (2011)"
     end if
  end if

  if (str_lower(VarName).eq."le") then
     LongName      = "Latent Heat"
     VarModel      = "hfls"
     ModelComp     = "Amon"    
     Category      = CatNames(1)
     GSMLocalRefer = "YES"
     MassWeighting = "YES"
     if (str_lower(Source).eq."fluxnet") then
        Reference  = "Lasslop et al. (2010)"
     end if
     if (any(str_lower(Source).eq.(/"fluxnet-mte", "gbaf"/))) then
        Reference  = "Jung et al. (2010)"
     end if
     if (str_lower(Source).eq."modis") then
        Reference  = "Mu et al. (2011)"
     end if
  end if

  if (str_lower(VarName).eq."nbp") then
     LongName      = "Global Net Ecosystem Carbon Balance"
     VarModel      = VarName
     ModelComp     = "Lmon"    
     Category      = CatNames(0)
     CarbonYearly  = "YES"
     GSMLocalRefer = "YES"
     MassWeighting = "YES"
     if (str_lower(Source).eq."gcp") then
        Reference  = "Le Quere et al. (2012)"
     end if
     if (str_lower(Source).eq."hoffman") then
        Reference  = "Hoffman et al. (2013)"
     end if
  end if

  if (str_lower(VarName).eq."nee") then
     LongName      = "Net Ecosystem Exchange"
     ModelComp     = "Lmon"    
     Category      = CatNames(0)
     if (str_lower(ModelType).eq."mstmip") then
        VarModel        = "nep"
     else
        VarModel        = "gpp"
        VarModelComb    = "YES"
     end if
     GSMLocalRefer   = "YES"
     MassWeighting   = "YES"
     MassWeightingFC = "YES"
     MinFC           = 1.2
     if (str_lower(Source).eq."fluxnet") then
        Reference  ="Lasslop et al. (2010)"
     end if
     if (any(str_lower(Source).eq.(/"fluxnet-mte", "gbaf"/))) then
        Reference     = "Jung et al. (2009)"
        LandOnly      = "YES"
        CarbonMonthly = "YES"
        LimitFlag     = "NO" 
     end if
  end if

  if (str_lower(VarName).eq."pr") then
     LongName      = "Precipitation"
     VarModel      = VarName
     ModelComp     = "Amon"    
     Category      = CatNames(3)
     GSMLocalRefer = "YES"
     MassWeighting = "YES"
     if (str_lower(Source).eq."fluxnet") then
        Reference  ="Lasslop et al. (2010)"
     end if
     if (str_lower(Source).eq."gpcc") then
        Reference  = "Schneider et al. (2010)"
     end if
     if (str_lower(Source).eq."gpcp2") then
        Reference  = "Adler et al. (2012)"
     end if
  end if

  if (str_lower(VarName).eq."reco") then
     LongName      = "Ecosystem Respiration"
     VarModel      = "ra"
     ModelComp     = "Lmon"    
     Category      = CatNames(0)
     VarModelComb  = "YES"
     GSMLocalRefer = "YES"
     MassWeighting = "YES"
     if (str_lower(Source).eq."fluxnet") then
        Reference  ="Lasslop et al. (2010)"
     end if
     if (any(str_lower(Source).eq.(/"fluxnet-mte", "gbaf"/))) then
        Reference     = "Jung et al. (2009)"
        LandOnly      = "YES"
        CarbonMonthly = "YES"
        LimitFlag     = "NO" 
     end if
  end if

  if (str_lower(VarName).eq."rhums") then
     LongName      = "Surface Relative Humidity"
     VarModel      = "hurs"
     ModelComp     = "Amon"    
     Category      = CatNames(3)
     ;GSMLocalRefer = "YES"
     ;MassWeighting = "YES"
     if (str_lower(Source).eq."era") then
        Reference  ="Dee et al. (2011)"
     end if
  end if

  if (str_lower(VarName).eq."rlds") then
     LongName  = "Surface Downward LW Radiation"
     VarModel  = VarName
     ModelComp = "Amon"    
     Category  = CatNames(3)
     if (str_lower(Source).eq."ceres") then
        Reference  ="Kato et al. (2013)"
     end if
     if (str_lower(Source).eq."wrmc.bsrn") then
        Reference  ="Konig-Langl et al. (2013)"
     end if
     if (str_lower(Source).eq."gewex.srb") then
        Reference  ="Stackhouse et al. (2011)"
     end if
  end if

  if (str_lower(VarName).eq."rlns") then
     LongName     = "Surface Net LW Radiation"
     VarModel     = "rlds"
     ModelComp    = "Amon"    
     Category     = CatNames(2)
     VarModelComb = "YES"
     MinFC        = 1.2
     if (str_lower(Source).eq."ceres") then
        Reference  ="Kato et al. (2013)"
     end if
     if (str_lower(Source).eq."wrmc.bsrn") then
        Reference  ="Konig-Langl et al. (2013)"
     end if
     if (str_lower(Source).eq."gewex.srb") then
        Reference  ="Stackhouse et al. (2011)"
     end if
  end if

  if (str_lower(VarName).eq."rlus") then
     LongName  = "Surface Upward LW Radiation"
     VarModel  = VarName
     ModelComp = "Amon"    
     Category  = CatNames(2)
     if (str_lower(Source).eq."ceres") then
        Reference  ="Kato et al. (2013)"
     end if
     if (str_lower(Source).eq."wrmc.bsrn") then
        Reference  ="Konig-Langl et al. (2013)"
     end if
     if (str_lower(Source).eq."gewex.srb") then
        Reference  ="Stackhouse et al. (2011)"
     end if
  end if

  if (str_lower(VarName).eq."rlut") then
     LongName  = "TOA Upward LW Radiation"
     VarModel  = VarName
     ModelComp = "Amon"    
     Category  = CatNames(2)
     if (str_lower(Source).eq."ceres") then
        Reference  ="Loeb et al. (2009)"
     end if
     if (str_lower(Source).eq."gewex.srb") then
        Reference  ="Stackhouse et al. (2011)"
     end if
  end if

  if (str_lower(VarName).eq."rns") then
     LongName     = "Surface Net Radiation"
     VarModel     = "rsds"
     ModelComp    = "Amon"    
     Category     = CatNames(2)
     VarModelComb = "YES"
     MinFC        = 1.2
     if (str_lower(Source).eq."ceres") then
        Reference  ="Kato et al. (2013)"
     end if
     if (str_lower(Source).eq."fluxnet") then
        Reference  ="Lasslop et al. (2010)"
     end if
     if (str_lower(Source).eq."wrmc.bsrn") then
        Reference  ="Konig-Langl et al. (2013)"
     end if
     if (str_lower(Source).eq."gewex.srb") then
        Reference  ="Stackhouse et al. (2011)"
     end if
  end if

  if (str_lower(VarName).eq."rnt") then
     LongName     = "TOA Net Radiation"
     VarModel     = "rlut"
     ModelComp    = "Amon"    
     Category     = CatNames(2)
     VarModelComb = "YES"
     MinFC        = 1.2
     if (str_lower(Source).eq."ceres") then
        Reference  ="Loeb et al. (2009)"
     end if
     if (str_lower(Source).eq."gewex.srb") then
        Reference  ="Stackhouse et al. (2011)"
     end if
  end if

  if (str_lower(VarName).eq."rsds") then
     LongName  = "Surface Downward SW Radiation"
     VarModel  = VarName
     ModelComp = "Amon"    
     Category  = CatNames(3)
     if (str_lower(Source).eq."ceres") then
        Reference  ="Kato et al. (2013)"
     end if
     if (str_lower(Source).eq."fluxnet") then
        Reference  ="Lasslop et al. (2010)"
     end if
     if (str_lower(Source).eq."wrmc.bsrn") then
        Reference  ="Konig-Langl et al. (2013)"
     end if
     if (str_lower(Source).eq."gewex.srb") then
        Reference  ="Stackhouse et al. (2011)"
     end if
  end if

  if (str_lower(VarName).eq."rsns") then
     LongName     = "Surface Net SW Radiation"
     VarModel     = "rsds"
     ModelComp    = "Amon"    
     Category     = CatNames(2)
     VarModelComb = "YES"
     MinFC        = 1.2
     if (str_lower(Source).eq."ceres") then
        Reference  ="Kato et al. (2013)"
     end if
     if (str_lower(Source).eq."wrmc.bsrn") then
        Reference  ="Konig-Langl et al. (2013)"
     end if
     if (str_lower(Source).eq."gewex.srb") then
        Reference  ="Stackhouse et al. (2011)"
     end if
  end if

  if (str_lower(VarName).eq."rsus") then
     LongName  = "Surface Upward SW Radiation"
     VarModel  = VarName
     ModelComp = "Amon"    
     Category  = CatNames(2)
     if (str_lower(Source).eq."ceres") then
        Reference  ="Kato et al. (2013)"
     end if
     if (str_lower(Source).eq."wrmc.bsrn") then
        Reference  ="Konig-Langl et al. (2013)"
     end if
     if (str_lower(Source).eq."gewex.srb") then
        Reference  ="Stackhouse et al. (2011)"
     end if
  end if

  if (str_lower(VarName).eq."rsut") then
     LongName  = "TOA Upward SW Radiation"
     VarModel  = VarName
     ModelComp = "Amon"    
     Category  = CatNames(2)
     if (str_lower(Source).eq."ceres") then
        Reference  ="Loeb et al. (2009)"
     end if
     if (str_lower(Source).eq."gewex.srb") then
        Reference  ="Stackhouse et al. (2011)"
     end if
  end if

  if (str_lower(VarName).eq."runoff") then
     LongName  = "Runoff"
     VarModel  = "mrro"
     ModelComp = "Lmon"    
     Category  = CatNames(1)
     if (str_lower(Source).eq."grdc") then
        Reference  ="Fekete et al. (2002)"
     end if
     if (str_lower(Source).eq."usgs") then
        Reference  ="N/A"
     end if
  end if

  if (str_lower(VarName).eq."sh") then
     LongName      = "Sensible Heat"
     VarModel      = "hfss"
     ModelComp     = "Amon"    
     Category      = CatNames(2)
     GSMLocalRefer = "YES"
     MassWeighting = "YES"
     if (str_lower(Source).eq."fluxnet") then
        Reference  ="Lasslop et al. (2010)"
     end if
     if (any(str_lower(Source).eq.(/"fluxnet-mte", "gbaf"/))) then
        Reference  ="Jung et al. (2010)"
     end if
  end if

  ; Kang's `snd` benchmark.
  if (str_lower(VarName).eq."snd") then
    LongName  = "Snow Depth"
    VarModel = VarName
    ModelComp = "Lmon"
    Category  = CatNames(1)  ; hydrology
    SubGlobe  = "YES"
    LandOnly  = "YES"
    if (str_lower(Source).eq."pbs") then
      Reference  ="Wang et al. (2016)"
    end if
  end if

  if (str_lower(VarName).eq."soilc") then
     LongName      = "Soil Carbon"
     VarModel      = "cSoil"
     ModelComp     = "Lmon"    
     Category      = CatNames(0)
     LandOnly      = "YES"
     CarbonYearly  = "YES"
     LimitFlag     = "NO"
     GSMLocalRefer = "YES"
     MassWeighting = "YES"
     if (str_lower(Source).eq."hwsd") then
        Reference  = "Todd-Brown et al. (2013)"
     end if
     if (str_lower(Source).eq."ncscdv22") then
        Reference  = "Hugelius et al. (2013)"
        SubGlobe   = "YES"
     end if
  end if

  if (str_lower(VarName).eq."soilm") then
     LongName  = "Top 5cm Soil Moisture"
     VarModel  = "mrsos"
     ModelComp = "Lmon"    
     Category  = CatNames(1)
     if (str_lower(Source).eq."ecv") then
        Reference  ="Liu et al. (2012)"
     end if
     if (str_lower(Source).eq."ismn") then
        Reference  ="N/A"
     end if
     if (str_lower(Source).eq."nldas2-mosaic") then
        Reference  ="N/A"
     end if
     if (str_lower(Source).eq."nldas2-noah") then
        Reference  ="N/A"
     end if
     if (str_lower(Source).eq."nldas2-vic") then
        Reference  ="N/A"
     end if
  end if

  if (str_lower(VarName).eq."soilt") then
     LongName  = "Soil Temperature"
     VarModel  = "tsl"
     ModelComp = "Lmon"    
     Category  = CatNames(4)
     if (str_lower(Source).eq."modis") then
        Reference  ="N/A"
     end if
  end if

  if (str_lower(VarName).eq."sst") then
     LongName  = "Sea Surface Temperature"
     VarModel  = "tos"
     ModelComp = "Omon"    
     Category  = CatNames(3)
     if (str_lower(Source).eq."cru") then
        Reference  ="Kennedy et al. (2011)"
     end if
     if (str_lower(Source).eq."noaa.io2") then
        Reference  ="Reynolds et al. (2002)"
     end if
  end if

  if (str_lower(VarName).eq."tas") then
     LongName  = "Surface Air Temperature"
     VarModel  = VarName
     ModelComp = "Amon"    
     Category  = CatNames(3)
     MinFC     = 1.2
     if (str_lower(Source).eq."cru") then
        Reference  ="Harris et al. (2013)"
     end if
     if (str_lower(Source).eq."fluxnet") then
        Reference  ="Lasslop et al. (2010)"
     end if
  end if

  if (str_lower(VarName).eq."ts") then
     LongName  = "Surface Temperature"
     VarModel  = "tsl"
     ModelComp = "Lmon"    
     Category  = CatNames(4)
     if (str_lower(Source).eq."modis") then
        Reference  ="N/A"
     end if
  end if

  ; Kang's `tsl` benchmark.
  if (str_lower(VarName).eq."tsl") then
    LongName  = "Temperature of Soil"
    VarModel = VarName
    ModelComp = "Lmon"
    Category  = CatNames(4) ; not sure -- see `soilt` above
    SubGlobe  = "YES"
    LandOnly  = "YES"
    if (str_lower(Source).eq."pbs") then
      Reference  ="Wang et al. (2016)"
    end if
  end if

  if (str_lower(VarName).eq."twsa") then
     LongName        = "Terrestrial Water Storage Anomaly"
     ModelComp       = "Lmon"    
     Category        = CatNames(1)
     if (str_lower(ModelType).eq."clm") then
        VarModel     = "tws"
        VarModelComb = "NO"
     else
        VarModel     = "mrro"
        VarModelComb = "YES"
     end if
     if (str_lower(Source).eq."grace") then
        Reference  ="Landerer et al. (2012)"
     end if
  end if

  if (str_lower(VarName).eq."twsa_per") then
     LongName        = "Terrestrial Water Storage Anomaly"
     VarModel        = "twsa_per"
     ModelComp       = "Lmon"    
     Category        = CatNames(1)
     if (str_lower(ModelType).eq."clm") then
        VarModel     = "tws"
        VarModelComb = "NO"
     else
        VarModel     = "mrro"
        VarModelComb = "YES"
     end if
     if (str_lower(Source).eq."grace") then
        Reference  ="Landerer et al. (2012)"
     end if
  end if

  if (str_lower(VarName).eq."twsc") then
     LongName        = "Terrestrial Water Storage Change"
     VarModel        = "mrro"
     ModelComp       = "Lmon"    
     Category        = CatNames(1)
     if (str_lower(ModelType).eq."clm") then
        VarModel     = "tws"
        VarModelComb = "NO"
     else
        VarModel     = "mrro"
        VarModelComb = "YES"
     end if
     if (str_lower(Source).eq."grace") then
        Reference  ="Landerer et al. (2012)"
     end if
  end if

  ; +++ create output information for a given benchmark source and variable +++++++++++++++++

  DataInfo@DataName      = DataName         ; long name of a given source
  DataInfo@LimitFlag     = LimitFlag        ; cutoff model data by benchmark
  DataInfo@LandOnly      = LandOnly         ; use the unit of land or gridcell area 
  DataInfo@SubGlobe      = SubGlobe         ; benchmark is global or sub-global data
  DataInfo@CarbonYearly  = CarbonYearly     ; Carbon related variable in yearly time step
  DataInfo@CarbonMonthly = CarbonMonthly    ; Carbon related variable in monthly time step
  DataInfo@GSMLocalRefer = GSMLocalRefer    ; a switch to use local or global mean reference for global score metrics
  DataInfo@MassWeighting = MassWeighting    ; a switch to mass or area weighting for global mean score
  DataInfo@MassWeightingFC = MassWeightingFC; a switch to use raw or adjusted mass for mass weighting
  DataInfo@MinFC         = MinFC            ; adjusted factor coefficient for minimum
  DataInfo@Reference     = Reference        ; reference for a given source
  DataInfo@LongName      = LongName         ; long name of a given variable
  DataInfo@Category      = Category         ; category name of a given variable
  DataInfo@VarModel      = VarModel         ; variable name for model simulation
  DataInfo@ModelComp     = ModelComp        ; name of model component
  DataInfo@Dimens        = Dimens           ; dimensions
  DataInfo@TRes          = TRes             ; temporal resolution
  DataInfo@StartYr       = StartYr          ; Start year of the data
  DataInfo@EndYr         = EndYr            ; End year of the data
  DataInfo@VarModelComb  = VarModelComb     ; If the variable for model simulation is the result based on multi-variables

  return (DataInfo)

end
