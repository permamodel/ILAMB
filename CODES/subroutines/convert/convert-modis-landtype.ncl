load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_biomes.ncl"

begin
iyear=2004
ncls=18

nlat0=360
nlon0=720

; ++++ the horizonal resolution 0.5x0.5 ++++
;nlat=360
;nlon=720
;lat=fspan( -89.75, 89.75,nlat)
;lon=fspan(-179.75,179.75,nlon)

; ++++ the horizonal resolution 1x1 ++++
nlat=180
nlon=360
lat=fspan( -89.5, 89.5,nlat)
lon=fspan(-179.5,179.5,nlon)

; ++++ the horizonal resolution 2.5x2.5 ++++
;nlat=72
;nlon=144
;lat=fspan( -88.75, 88.75,nlat)
;lon=fspan(-178.75,178.75,nlon)

i50 = ind(lat.lt.-60)
j51 = ind(lat.ge. 50)
j52 = ind(lat.lt. 50)

strings=new((/18/), string)

strings(0)  = "water"
strings(1)  = "evergreen needleleaf forest"
strings(2)  = "evergreen broadleaf forest"
strings(3)  = "deciduous needleleaf forest"
strings(4)  = "deciduous broadleaf forest"
strings(5)  = "mixed forests"
strings(6)  = "closed shrubland"
strings(7)  = "open shrublands"
strings(8)  = "woody savannas"
strings(9)  = "savannas"
strings(10) = "grasslands"
strings(11) = "permanent wetlands"
strings(12) = "croplands"
strings(13) = "urban and built-up"
strings(14) = "cropland/natural vegetation mosaic"
strings(15) = "snow and ice"
strings(16) = "barren or sparsely vegetated"
strings(17) = "unclassified + fill values"

   ijk=0
do iiy = 1850, iyear-1

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      ntim=366
   else
      ntim=365
   end if

   ijk = ijk + ntim
end do

time = int2dble(ijk)

datadir= getenv("ILAMB_DATADIR") + "/landfraction/MODIS"

FileIn=datadir + "/original/landfraction_MODIS_IGBP_" + sprinti("%0.4i",iyear) + "_top18.dat"
print(FileIn)

temp0=fbindirread(FileIn,0,(/ncls,nlat0,nlon0/),"float")

temp = new((/18,nlat,nlon/), float)

do ns=0,ncls-1
do ny=0,nlat0-1,2
do nx=0,nlon0-1,2
   temp(ns,ny/2,nx/2) = avg(temp0(ns,ny:ny+1,nx:nx+1))
end do
end do
end do

temp!0="type"
temp!1="lat"
temp!2="lon"

print(max(temp))

class = new((/7,nlat,nlon/), float)

class = -999

; ++++ water+snow+ice  +++++
tmp = temp(0,:,:)+temp(15,:,:)
class(0,:,:) = tmp
delete(tmp)

; ++++  desert +++++
tmp = where (temp(16,:,:).ge.50, temp(16,:,:), 0)
temp(16,:,:) = where (temp(16,:,:).ge.50, 0, temp(16,:,:))
class(1,:,:) = tmp
delete(tmp)

; ++++  tundra +++++
;tmp = where (temp(7,:,:).ge.50, temp(7,:,:), 0)
;temp(7,:,:) = where (temp(7,:,:).ge.50, 0, temp(7,:,:))
;tmp = temp(7,:,:)
;tmp(j52,:) = 0
;temp(7,j51,:) = 0
;class(2,:,:) = tmp
;delete(tmp)

; ++++  tropical forest +++++
tmp = temp(2,:,:)
class(2,:,:) = tmp
delete(tmp)

; ++++  boreal and temperate forest +++++
tmp = temp(1,:,:)+temp(3,:,:)+temp(4,:,:)+temp(5,:,:)
class(3,:,:) = tmp
delete(tmp)

; ++++  shrublands +++++
tmp = temp(6,:,:)+temp(7,:,:)+temp(16,:,:)
class(4,:,:) = tmp
delete(tmp)

; ++++  savana +++++
tmp = temp(8,:,:)+temp(9,:,:)
class(5,:,:) = tmp
delete(tmp)

; ++++  grass/crop lands +++++
tmp = temp(10,:,:)+temp(11,:,:)+temp(12,:,:)+temp(13,:,:)+temp(14,:,:)
class(6,:,:) = tmp
delete(tmp)

classtypes=new((/7/), string)
classtypes(0) = "water/snow"
classtypes(1) = "desert"
;classtypes(2) = "tundra"
classtypes(2) = "tropical forest"
classtypes(3) = "boreal/temperate forest"
classtypes(4) = "shrublands"
classtypes(5) = "savana"
classtypes(6) = "crop/grass lands"

types=new((/nlat,nlon/), float)

class0 = class

;class = where(class.ge.50, class, -999)

do ny=0,nlat-1
do nx=0,nlon-1
;   types(ny,nx)=int2flt(maxind(class(:,ny,nx)))
   types(ny,nx)=int2flt(maxind(class(:,ny,nx))) + 0.5
end do
end do

;FileIn=getenv("ILAMB_ROOT") + "/DATA/mask/original/mask_landsea_0.5x0.5.txt"
;print(FileIn)
;
;temp0=asciiread(FileIn,(/nlat,nlon/),"integer")
;
;mask0=int2flt(temp0(::-1,:))
;delete(temp0)

types(i50,:) = 0

type = classtypes(0)

do nc=1,6
   type = type + ", " + classtypes(nc)
end do

print(type)

data1 = ndtooned(class(6,:,:))
data2 = ndtooned(types)

print(dimsizes(ind(data1.ge.50)))
print(dimsizes(ind(data2.eq.6)))

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "biomes"
VarLongName = "land type"
VarUnit     = "unitless"
Title       = "derived biomes in 1x1"
Source      = "MODIS (MOD12C1) IGBP in 2004"
TimeStep    = "annual"
;type        = "all areas excep water, snow, ice and unclassified types from MODIS (MOD12C1) IGBP"

datadir= getenv("ILAMB_DATADIR") + "/biomes/MODIS"

FileOut=datadir + "/derived/" + "biomes_MODIS_1x1.nc"
print(FileOut)
;tttt = write_2D_biomes (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
;                       types, type, time, lat, lon, FileOut)

types = where(class0(0,:,:).ge.50, -999, types)
types@_FillValue = -999

types!0="lat"
types!1="lon"
types&lat=lat
types&lon=lon
types&lon@units="degrees_east"
types&lat@units="degrees_north"

;----------- Begin first plot -----------------------------------------

  wks = gsn_open_wks("eps","map_reclass.all_1x1_landtype_MODIS_IGBP_2004")

;  cmap = (/(/1., 1., 1./), (/0., 0., 0./), (/1., 0., 0./), (/1., 0., .4/), \
;           (/1., 0., .8/), (/1., .2, 1./), (/1., .6, 1./), (/.6, .8, 1./), \
;           (/.2, .8, 1./), (/.2, .8, .6/), (/.2, .8, 0./), (/.2, .4, .0/), \
;           (/.2, .4, .4/), (/.2, .4, .8/), (/.6, .4, .8/), (/.6, .8, .8/), \
;           (/.6, .8, .4/), (/1., .6, .8/)/)

  gsn_define_colormap(wks,"amwg") 
;  gsn_define_colormap(wks,"BlAqGrYeOrRe") 
;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
;  gsn_define_colormap(wks,"BlWhRe")
;  i  =  NhlNewColor(wks, 0.6, 0.6, 0.6)

;  --------   set  res1 ------------
  res1                      = True
  res1@gsnDraw              = False 
  res1@gsnFrame             = False

  res1@cnFillOn             = True
  res1@cnLinesOn            = False
  res1@cnLineLabelsOn       = False
  res1@cnInfoLabelOn        = False

  res1@cnLineLabelFont       = "helvetica"
  res1@cnLineLabelFontHeightF= 0.01
  res1@cnLabelMasking        = True
;  res1@cnLineLabelCounts       = 9
  res1@cnLineLabelDensityF      = 1.0
  res1@cnLineLabelInterval       = 1.
  res1@cnLineDashSegLenF      =  0.2
;  res1@cnLineThicknessF      =  0.5

; res1@gsnScalarContour     = True
  res1@cnFillDrawOrder  = "Predraw"

  res1@mpShapeMode           = "FreeAspect"
;  res1@mpLimitMode           = "LatLon"
  res1@mpFillOn               = False
;  res1@mpOutlineOn           = False
;  res1@mpFillColor           = "black"
;  res1@mpLandFillPattern     = "HollowFill"
  res1@mpGeophysicalLineColor      = "black"
  res1@mpCenterLonF          = 0.
  res1@mpMinLonF             =-180.
  res1@mpMaxLonF             = 180.
  res1@mpMinLatF             = -90.
  res1@mpMaxLatF             =  90.

  res1@lbLabelAutoStride     = False
;  res1@lbOrientation         = "vertical"
  res1@lbLabelFont           = "helvetica"
  res1@lbLabelFontHeightF    = 0.011
;  res1@lbLabelBarOn          = False
  res1@lbLeftMarginF         = -0.8
  res1@lbRightMarginF        = -0.8
  res1@lbTopMarginF          = 0.5
  res1@lbBottomMarginF       = -0.1
;  res1@lbLabelStride         = 2
  res1@lbLabelStride         = 1
  res1@lbLabelAngleF         = 45
  res1@lbLabelStrings        = classtypes(1:)
  res1@lbLabelJust           = "CenterRight"
 
  res1@tmXBLabelFont         = "helvetica"
  res1@tmYLLabelFont         = "helvetica"
  res1@tmXBLabelFontHeightF  = 0.015
  res1@tmYLLabelFontHeightF  = 0.015
;  res1@tmXBLabelsOn           = False
;  res1@tmYLLabelsOn           = False
;  res1@tmXBLabelStride       = 2
;  res1@tmYLLabelStride       = 1

;  res1@gsnScalarContour     = True
  res1@gsnSpreadColors      = True
  res1@gsnSpreadColorStart =  2
  res1@gsnSpreadColorEnd    = 200
  res1@gsnStringFontHeightF  =0.014
  res1@gsnStringFont         ="helvetica-bold"
  res1@tiMainFont            ="helvetica-bold"
  res1@tiMainFontHeightF     =0.015

; ---------------   precip-1 --------------------------

  res1@gsnCenterString       = ""
  res1@gsnLeftString         = ""
  res1@gsnRightString        = ""
  res1@vpXF                  = 0.15
  res1@vpYF                  = 0.90
  res1@vpWidthF              = 0.8
  res1@vpHeightF             = 0.4

;  res1@cnLevelSelectionMode  = "ManualLevels"
;  res1@cnMinLevelValF        =  0.
;  res1@cnMaxLevelValF        =  1.
;  res1@cnLevelSpacingF       =  .05

  res1@cnLevelSelectionMode  = "Explicitlevels"
  res1@cnLevels              = (/1,2,3,4,5,6/)
;  res1@cnLevels              = (/0.5,1,2,4,6,8,10,12,14,16,18,20,25,30,40/)
;  res1@cnLevels              = (/1,2,4,6,8,10,12,14,16,18,20,25,30,35,40,45,50/)

  plot1 = gsn_csm_contour_map (wks,types,res1)
  draw  (plot1)

; ---------------   write text --------------------------

  txres               = True  
  txres@txFontHeightF = 0.018
;  gsn_text_ndc(wks,":F22:UMD", .52,.04,txres)
;  gsn_text_ndc(wks,":F22:Winter (Nov-Apr))", .75,.28,txres)
;  gsn_text_ndc(wks,":F22:20-80 days Variance", .75,.25,txres)
;  gsn_text_ndc(wks,":F22:Eastward Component", .75,.22,txres)
;  gsn_text_ndc(wks,":F22:[10:S:o:N:S-10:S:o:N:N, 140:S:o:N:E-180:S:o:N:]", .77,.05,txres)


; --------------- End  ploting --------------------------

  frame(wks)   ; Advance the frame.

end
