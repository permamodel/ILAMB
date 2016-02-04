function retrieve_latlon_region (KeyWord:string, latitude:float, longitude:float)

; This function is used to retrieve latitude and longitude for a predefined region, i.e., Alaska, Amazon, etc.
;
; input and output variables and corresponding meaning:
;
;       KeyWord: intput variable, name of a region
;      latitude: output variable, latitude of the region
;     longitude: output variable, longitude of the region

begin

SpatRes   = getenv("SPATRES")
SpatRes   = str_lower(str_squeeze(SpatRes))

KeyWord = str_squeeze(KeyWord)

DX = 0.5  ; resolution in longitude
DY = 0.5  ; resolution in latitude

lat = (/ -89.75,   89.75/)
lon = (/-179.75,  179.75/)

lat = (/ -89.75,   89.75/)
lon = (/-179.75,  179.75/)

;if (str_lower(SpatRes).eq."1x1") then
;   DX = 1.0  ; resolution in longitude
;   DY = 1.0  ; resolution in latitude
;
;   lat = (/ -89.5,   89.5/)
;   lon = (/-179.5,  179.5/)
;end if

;if (str_lower(SpatRes).eq."2.5x2.5") then
;   DX = 2.5  ; resolution in longitude
;   DY = 2.5  ; resolution in latitude
;
;   lat = (/ -88.75,   88.75/)
;   lon = (/-178.75,  178.75/)
;end if

if (str_lower(KeyWord).eq."global.large") then
    lat = (/ -89.75,   89.75/)
    lon = (/-179.75,  179.75/)
end if

if (str_lower(KeyWord).eq."global") then
    lat = (/ -60.25,   80.25/)
    lon = (/-179.75,  179.75/)
end if

if (str_lower(KeyWord).eq."amazon") then
    lat = (/-12.25,  6.75/)
    lon = (/-75.25, -50.25/)
end if

if (str_lower(KeyWord).eq."alaska") then
    lat = (/  50.25,   75.25/)
    lon = (/-170.25, -130.25/)
end if

if (str_lower(KeyWord).eq."australia") then
    lat = (/-50.25, -10.25/)
    lon = (/100.25, 160.25/)
end if

if (str_lower(KeyWord).eq."bona") then
    lat = (/  49.75,  79.75/)
    lon = (/-170.25, -60.25/)
end if

if (str_lower(KeyWord).eq."tena") then
    lat = (/  30.25,  49.75/)
    lon = (/-125.25, -80.25/)
end if

if (str_lower(KeyWord).eq."ceam") then
    lat = (/   9.75,  30.25/)
    lon = (/-115.25, -80.25/)
end if

if (str_lower(KeyWord).eq."nhsa") then
    lat = (/  0.25,   9.75/)
    lon = (/-80.25, -50.25/)
end if

if (str_lower(KeyWord).eq."shsa") then
    lat = (/-59.75,   0.25/)
    lon = (/-80.25, -40.25/)
end if

if (str_lower(KeyWord).eq."euro") then
    lat = (/ 40.25, 70.25/)
    lon = (/-10.25, 30.25/)
end if

if (str_lower(KeyWord).eq."mide") then
    lat = (/ 20.25, 40.25/)
    lon = (/-10.25, 60.25/)
end if

if (str_lower(KeyWord).eq."nhaf") then
    lat = (/  0.25, 20.25/)
    lon = (/-20.25, 45.25/)
end if

if (str_lower(KeyWord).eq."shaf") then
    lat = (/-34.75,  0.25/)
    lon = (/ 10.25, 45.25/)
end if

if (str_lower(KeyWord).eq."boas") then
    lat = (/54.75,  70.25/)
    lon = (/30.25, 179.75/)
end if

if (str_lower(KeyWord).eq."ceas") then
    lat = (/30.25,  54.75/)
    lon = (/30.25, 135.25/)
end if

if (str_lower(KeyWord).eq."seas") then
    lat = (/10.25,  30.25/)
    lon = (/65.25, 120.25/)
end if

if (str_lower(KeyWord).eq."eqas") then
    lat = (/-10.25,  10.25/)
    lon = (/ 99.75, 150.25/)
end if

if (str_lower(KeyWord).eq."aust") then
    lat = (/-34.75, -10.25/)
    lon = (/124.75, 154.75/)
end if

TMPString1 = str_get_field(KeyWord, 1, ",")
TMPString2 = str_get_field(KeyWord, 2, ",")

if (TMPString2.ne."" .and. .not.ismissing(TMPString2)) then
   lat(0) = stringtofloat(str_get_field(TMPString1, 1, ":"))
   lat(1) = stringtofloat(str_get_field(TMPString1, 2, ":"))
   lon(0) = stringtofloat(str_get_field(TMPString2, 1, ":"))
   lon(1) = stringtofloat(str_get_field(TMPString2, 2, ":"))
end if

nlat = floattoint((lat(1)-lat(0))/DY) + 1
nlon = floattoint((lon(1)-lon(0))/DX) + 1

latitude(0:nlat-1)  = fspan(lat(0), lat(1), nlat)
longitude(0:nlon-1) = fspan(lon(0), lon(1), nlon)

if (dimsizes(ind(.not.ismissing(latitude))).gt.1 .and. dimsizes(ind(.not.ismissing(longitude))).gt.1 ) then
   results = 1
else
   results = 0
end if

return (results)

end
