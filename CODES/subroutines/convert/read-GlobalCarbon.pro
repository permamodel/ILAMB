; +++++++++++++ open tif file +++++++++++++++
;---------- africa ---------
;file1="/gdata/randerson3/mmu/ILAMB/DATA/biomass/GLOBAL.CARBON/original/africa_carbon_1km.tif"

;---------- america ---------
;file1="/gdata/randerson3/mmu/ILAMB/DATA/biomass/GLOBAL.CARBON/original/america_carbon_1km.tif"

;---------- asia ---------
file1="/gdata/randerson3/mmu/ILAMB/DATA/biomass/GLOBAL.CARBON/original/asia_carbon_1km.tif"

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

;---------- africa ---------
;UTM_Map = MAP_PROJ_INIT('UTM', CENTER_LAT=22.09454379350000, CENTER_LON=-17.92081630350000, ELLIPSOID='WGS 84', /gctp)

;---------- america ---------
;UTM_Map = MAP_PROJ_INIT('UTM', CENTER_LAT=31.23695977333335, CENTER_LON=-112.85505926333335, ELLIPSOID='WGS 84', /gctp)

;---------- asia ---------
UTM_Map = MAP_PROJ_INIT('UTM', CENTER_LAT=39.992988675, CENTER_LON=60.004227815, ELLIPSOID='WGS 84', /gctp)

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

lon = xOrigin + xscale * Indgen(s[0])
lat = yOrigin - yscale * Indgen(s[1])

help, lat
help, lon

; ++++++++ save data in original 1km resolution ++++++++++++
;---------- africa ---------
;filename0='/gdata/randerson3/mmu/ILAMB/DATA/biomass/GLOBAL.CARBON/original/carbon_africa_1km.dat'
;openw,lun,filename0,/get_lun
;writeu,lun,image
;free_lun,lun
;
;filename1='/gdata/randerson3/mmu/ILAMB/DATA/biomass/GLOBAL.CARBON/original/lat_africa_1km.dat'
;openw,lun,filename1,/get_lun
;writeu,lun,lat
;free_lun,lun
;
;filename2='/gdata/randerson3/mmu/ILAMB/DATA/biomass/GLOBAL.CARBON/original/lon_africa_1km.dat'
;openw,lun,filename2,/get_lun
;writeu,lun,lon
;free_lun,lun

;---------- america ---------
;filename0='/gdata/randerson3/mmu/ILAMB/DATA/biomass/GLOBAL.CARBON/original/carbon_america_1km.dat'
;openw,lun,filename0,/get_lun
;writeu,lun,image
;free_lun,lun
;
;filename1='/gdata/randerson3/mmu/ILAMB/DATA/biomass/GLOBAL.CARBON/original/lat_america_1km.dat'
;openw,lun,filename1,/get_lun
;writeu,lun,lat
;free_lun,lun
;
;filename2='/gdata/randerson3/mmu/ILAMB/DATA/biomass/GLOBAL.CARBON/original/lon_america_1km.dat'
;openw,lun,filename2,/get_lun
;writeu,lun,lon
;free_lun,lun

;---------- asia ---------
filename0='/gdata/randerson3/mmu/ILAMB/DATA/biomass/GLOBAL.CARBON/original/carbon_asia_1km.dat'
openw,lun,filename0,/get_lun
writeu,lun,image
free_lun,lun

filename1='/gdata/randerson3/mmu/ILAMB/DATA/biomass/GLOBAL.CARBON/original/lat_asia_1km.dat'
openw,lun,filename1,/get_lun
writeu,lun,lat
free_lun,lun

filename2='/gdata/randerson3/mmu/ILAMB/DATA/biomass/GLOBAL.CARBON/original/lon_asia_1km.dat'
openw,lun,filename2,/get_lun
writeu,lun,lon
free_lun,lun

print, s

help, lon
help, lat

end
