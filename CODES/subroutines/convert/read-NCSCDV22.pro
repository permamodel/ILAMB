; +++++++++++++ open tif file +++++++++++++++
;---------- soil carbon at 0-30cm ---------
file1="/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/NCSCDv22_SOCC_30cm_hg_LAEA_1km.tif"

;---------- soil carbon at 30-100cm ---------
;file1="/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/NCSCDv22_SOCC_30_100cm_hg_LAEA_1km_2.tif"

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

;UTM_Map = MAP_PROJ_INIT('UTM', CENTER_LAT=22.09454379350000, CENTER_LON=-17.92081630350000, ELLIPSOID='Lambert Azimuthal', /gctp)
UTM_Map = MAP_PROJ_INIT('Lambert Azimuthal')

help, UTM_Map

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

print, xscale
print, yscale

print, xOrigin
print, yOrigin

; ++++++++ save data in original 1km resolution ++++++++++++
;---------- 0-30cm ---------
;filename0='/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/NCSCDv22_SOCC_0-30cm_hg_LAEA_1km.dat'
;filename0='/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/NCSCDv22_SOCC_0-30cm_hg_LAEA_1km.txt'
;openw,lun,filename0,/get_lun
;writeu,lun,image
;printf,lun,image
;free_lun,lun

;filename1='/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/lat_0-30cm_hg_LAEA_1km.dat'
;filename1='/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/lat_0-30cm_hg_LAEA_1km.txt'
;openw,lun,filename1,/get_lun
;writeu,lun,lat
;printf,lun,lat
;free_lun,lun

;filename2='/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/lon_0-30cm_hg_LAEA_1km.dat'
;filename2='/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/lon_0-30cm_hg_LAEA_1km.txt'
;openw,lun,filename2,/get_lun
;writeu,lun,lon
;printf,lun,lon
;free_lun,lun

;---------- 30-100cm ---------
;filename0='/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/NCSCDv22_SOCC_30-100cm_hg_LAEA_1km.dat'
;filename0='/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/NCSCDv22_SOCC_30-100cm_hg_LAEA_1km.txt'
;openw,lun,filename0,/get_lun
;writeu,lun,image
;printf, lun,image
;free_lun,lun

;filename1='/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/lat_30-100cm_hg_LAEA_1km.dat'
;filename1='/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/lat_30-100cm_hg_LAEA_1km.txt'
;openw,lun,filename1,/get_lun
;writeu,lun,lat
;printf, lun,lat
;free_lun,lun

;filename2='/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/lon_30-100cm_hg_LAEA_1km.dat'
;filename2='/gdata/randerson3/mmu/ILAMB/DATA/soilc/NCSCDV22/original/lon_30-100cm_hg_LAEA_1km.txt'
;openw,lun,filename2,/get_lun
;writeu,lun,lon
;printf, lun,lon
;free_lun,lun

print, s

help, lon
help, lat

end
