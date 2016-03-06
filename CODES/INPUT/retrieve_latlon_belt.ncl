function retrieve_latlon_belt (Source:string, KeyWord:string)

; This function is used to retrieve biome regions or belts used for time series analysis .
;
; input and output variables and corresponding meaning:
;
;       Source:  input, the shortname of a benchmark data source 
;      KeyWord:  input, the name of a kind of analysis like zonal mean etc. 
;      RegName: output, names of biome regions or belts
;       LatLon: output, latitude and longitude for a series of biome regions or belts

begin

SpatRes   = getenv("SPATRES")
SpatRes   = str_lower(str_squeeze(SpatRes))

KeyWord  = str_squeeze(KeyWord)

DX = 0.5  ; resolution in longitude
DY = 0.5  ; resolution in latitude

lat = (/ -89.75,   89.75/)
lon = (/-179.75,  179.75/)

if (str_lower(SpatRes).eq."1x1") then
   DX = 1.0  ; resolution in longitude
   DY = 1.0  ; resolution in latitude

   lat = (/ -89.5,   89.5/)
   lon = (/-179.5,  179.5/)
end if

if (str_lower(SpatRes).eq."2.5x2.5") then
   DX = 2.5  ; resolution in longitude
   DY = 2.5  ; resolution in latitude

   lat = (/ -88.75,   88.75/)
   lon = (/-178.75,  178.75/)
end if

nlat = floattoint((lat(1)-lat(0))/DY) + 1
nlon = floattoint((lon(1)-lon(0))/DX) + 1

latitude  = fspan(lat(0), lat(1), nlat)
longitude = fspan(lon(0), lon(1), nlon)

KeyWord = str_squeeze(KeyWord)

if (any(str_lower(Source).eq.(/"noaa.gmd", "fluxnet"/))) then
  ; ++++++ default set for 9 latitude belts for NOAA GMD CO2
  ; ++++++  belt1,  belt2, ......
  MinLat = (/ -90.0, -70.0, -50.0, -30.0, -10.0,  10.0,  30.0,  50.0,  70.0/) ; maximum latiudes of regions
  MaxLat = (/ -70.0, -50.0, -30.0, -10.0,  10.0,  30.0,  50.0,  70.0,  90.0/) ; minimum latiudes of regions
  MinLon = (/-180.0,-180.0,-180.0,-180.0,-180.0,-180.0,-180.0,-180.0,-180.0/) ; minimum longitudes of regions
  MaxLon = (/ 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0/) ; maximum longitudes of regions

  nsit = dimsizes(MinLat)

  LongName  = new((/nsit/), string)
  ShortName = new((/nsit/), string)

  do ns =0, nsit-1

     if (MinLat(ns).lt.0) then
        TmpStr1 = sprintf("%.0f",floor(abs(MinLat(ns))+0.5)) + "S"
     else
        TmpStr1 = sprintf("%.0f",floor(MinLat(ns)+0.5)) + "N"
     end if

     if (MaxLat(ns).lt.0) then
        TmpStr2 = sprintf("%.0f",floor(abs(MaxLat(ns))+0.5)) + "S"
     else
        TmpStr2 = sprintf("%.0f",floor(MaxLat(ns)+0.5)) + "N"
     end if

     LongName(ns)  = TmpStr1 + "-" + TmpStr2
     ShortName(ns) = "belt" + sprinti("%i",ns)
  end do

  latlon = new((/4, nsit/), float)

  latlon(0,0:nsit-1) = MinLat
  latlon(1,0:nsit-1) = MaxLat
  latlon(2,0:nsit-1) = MinLon
  latlon(3,0:nsit-1) = MaxLon

  RegName = ShortName

  RegName@LongName = LongName
  RegName@LatLon   = latlon

else

  ; +++ Here is an example to show how to define specific regions ++++

  if (any(str_lower(KeyWord).eq.(/"zonal","zonalmean"/))) then

     nsit = nlat-1

     MinLat = latitude(0:nlat-2)
     MaxLat = latitude(1:nlat-1)
     MinLon = min(longitude)
     MaxLon = max(longitude)

     ShortName = "ZonalMean"
     LongName  = "Zonal Mean"

  end if

  if (any(str_lower(KeyWord).eq.(/"meridional","meridionalmean"/))) then

     nsit = nlon-1

     MinLat = min(latitude)
     MaxLat = max(latitude)
     MinLon = longitude(0:nlon-2)
     MaxLon = longitude(1:nlon-1)

     ShortName = "MeridianalMean"
     LongName  = "Meridiannal Mean"

  end if

end if

  latlon(0,0:nsit-1) = MinLat
  latlon(1,0:nsit-1) = MaxLat
  latlon(2,0:nsit-1) = MinLon
  latlon(3,0:nsit-1) = MaxLon

  RegName = ShortName

  RegName@LongName = LongName
  RegName@LatLon   = latlon

  return (RegName)

end
