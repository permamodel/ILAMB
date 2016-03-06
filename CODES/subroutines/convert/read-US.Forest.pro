; ++++++++++++++ open tif file +++++++++++++++++++
; ++++++++ Biomass in alaska region++++++++
;file1="/gdata/randerson3/mmu/ILAMB/DATA/biomass/US.FOREST/original/alaska_forest_biomass_mg_per_ha.tif"

; ++++++++ Biomass in conus region++++++++
file1="/gdata/randerson3/mmu/ILAMB/DATA/biomass/US.FOREST/original/conus_forest_biomass_mg_per_ha.tif"

fid = QUERY_TIFF (file1, info)  

print, fid
print, info
print, info.NUM_IMAGES

image = Read_Tiff(file1, GEOTIFF=geotag) ; GeoTIFF info in "geotag" structure.
image = Reverse(image, 2)                ; Reverse Y direction.

print, min(image)
print, max(image)
print, mean(image)
help, image

help, geotag, /STRUCTURE
help, geotag.ModelPixelScaleTag, /STRUCTURE
help, geotag.ModelTiePointTag, /STRUCTURE

print, geotag.ModelPixelScaleTag
print, geotag.ModelTiePointTag

; Find the image dimensions. Will need later.
s = Size(image, /Dimensions)

; +++++++++ for alaska region +++++++++++
;UTM_Map = MAP_PROJ_INIT('UTM', CENTER_LAT=50.0, CENTER_LON=-154.0, /gctp)

; +++++++++ for conus region +++++++++++
UTM_Map = MAP_PROJ_INIT('UTM', CENTER_LAT=23.0, CENTER_LON=-96.0, /gctp)

; Calculate corner points from GeoTIFF structure obtained from file.
xscale = geotag.ModelPixelScaleTag[0]
yscale = geotag.ModelPixelScaleTag[1]
tp = geotag.ModelTiePointTag
tp = geotag.ModelTiePointTag

xOrigin = tp[3]
yOrigin = tp[4]

lon=fltarr(s[0])
lat=fltarr(s[1])
lon[0]=xOrigin
lat[0]=yOrigin

;for i=1,s[0]-1 do begin
;lon[i]=xorigin+xscale*i
;endfor

;for i=1,s[1]-1 do begin
;lat[i]=yorigin-yscale*i
;endfor

lon = xOrigin + xscale * Indgen(s[0])
lat = yOrigin - yscale * Indgen(s[1])

; +++++++++++ save file for alaska region+++++++++++++
;filename0='/gdata/randerson3/mmu/ILAMB/DATA/biomass/US.FOREST/original/alaska_biomass_250m.dat'
;openw,lun,filename0,/get_lun
;writeu,lun,float(image)
;free_lun,lun
;
;filename1='/gdata/randerson3/mmu/ILAMB/DATA/biomass/US.FOREST/original/alaska_y_biomass_250m.dat'
;openw,lun,filename1,/get_lun
;writeu,lun,float(lat)
;free_lun,lun
;
;filename2='/gdata/randerson3/mmu/ILAMB/DATA/biomass/US.FOREST/original/alaska_x_biomass_250m.dat'
;openw,lun,filename2,/get_lun
;writeu,lun,float(lon)
;free_lun,lun

; +++++++++++ save file for conus region+++++++++++++
filename0='/gdata/randerson3/mmu/ILAMB/DATA/biomass/US.FOREST/original/conus_biomass_250m.dat'
openw,lun,filename0,/get_lun
writeu,lun,float(image)
free_lun,lun

filename1='/gdata/randerson3/mmu/ILAMB/DATA/biomass/US.FOREST/original/conus_y_biomass_250m.dat'
openw,lun,filename1,/get_lun
writeu,lun,float(lat)
free_lun,lun

filename2='/gdata/randerson3/mmu/ILAMB/DATA/biomass/US.FOREST/original/conus_x_biomass_250m.dat'
openw,lun,filename2,/get_lun
writeu,lun,float(lon)
free_lun,lun

print, s

help, lon
help, lat

lat=transpose(lat)
help, lat

lat=rebin(lat,s[0],s[1],/sample)
lon=rebin(lon,s[0],s[1],/sample)
latitude=fltarr(s[0],s[1])
longitude=fltarr(s[0],s[1])

for i=0,s[0]-1 do begin
lat1=lat[i,*]
lon1=lon[i,*]
a = MAP_PROJ_INVERSE(lon1,lat1,map_structure=UTM_Map)
longitude[i,*]=a[0,*]
latitude[i,*]=a[1,*]
endfor

; +++++++++++ save file for alaska region+++++++++++++
;filename1='/gdata/randerson3/mmu/ILAMB/DATA/biomass/US.FOREST/original/alaska_lat_biomass_250m.dat'
;openw,lun,filename1,/get_lun
;writeu,lun,float(latitude)
;free_lun,lun
;
;filename2='/gdata/randerson3/mmu/ILAMB/DATA/biomass/US.FOREST/original/alaska_long_biomass_250m.dat'
;openw,lun,filename2,/get_lun
;writeu,lun,float(longitude)
;free_lun,lun

; +++++++++++ save file for conus region+++++++++++++
filename1='/gdata/randerson3/mmu/ILAMB/DATA/biomass/US.FOREST/original/conus_lat_biomass_250m.dat'
openw,lun,filename1,/get_lun
writeu,lun,float(latitude)
free_lun,lun
;
filename2='/gdata/randerson3/mmu/ILAMB/DATA/biomass/US.FOREST/original/conus_long_biomass_250m.dat'
openw,lun,filename2,/get_lun
writeu,lun,float(longitude)
free_lun,lun

end
