function retrieve_box_or_point (Source:string)

; This function is used to retrieve a box region or points used for time series analysis .
;
; input and output variables and corresponding meaning:
;
;       Source:  input, shortname of a benchmark data source 
;       latlon: output, latitude and longitude for a series of boxes or points

begin

  Source  = str_squeeze(Source)

  ; ++++++ default set for 2 box regions Box1 and Box2
  ; ++++++  Box1,  Box2, ......
  MinLat = (/5.0,  -15.0/) ; latitudes of points or minimum latiudes of regions
  MaxLat = (/25.0,  25.0/) ; longitudes of points or minimum longitudes of regions
  MinLon = (/15.0,  -5.0/) ; latitudes of points or maximum latiudes of regions
  MaxLon = (/35.0,  35.0/) ; longitudes of points or maximum longitudes of regions

  ; +++ Here is an example to show how to define specific boxes ++++
  if (str_lower(Source).eq."gfed3") then
     MinLat = (/5.0,  -15.0/) ; latitudes of points or minimum latiudes of regions
     MaxLat = (/25.0,  25.0/) ; longitudes of points or minimum longitudes of regions
     MinLon = (/15.0,  -5.0/) ; latitudes of points or maximum latiudes of regions
     MaxLon = (/35.0,  35.0/) ; longitudes of points or maximum longitudes of regions
  end if

  nsit = dimsizes(MinLat)

  latlon = new((/4, nsit/), float)

  latlon(0,0:nsit-1) = MinLat
  latlon(1,0:nsit-1) = MaxLat
  latlon(2,0:nsit-1) = MinLon
  latlon(3,0:nsit-1) = MaxLon

  return (latlon)

end
