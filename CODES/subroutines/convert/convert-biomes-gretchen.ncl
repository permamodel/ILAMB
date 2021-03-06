load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_biomes.ncl"

begin
ncls=15
nlat0=180
nlon0=360
nlat=360
nlon=720

lat=fspan(-89.75, 89.75,nlat)
lon=fspan(-179.75,179.75,nlon)

strings=new((/15/), string)

strings(0) = "WATE: Water"
strings(1) = "BONA: Boreal North America"
strings(2) = "TENA: Temperate North America"
strings(3) = "CEAM: Central America"
strings(4) = "NHSA: Northern Hemisphere South America"
strings(5) = "SHSA: Southern Hemisphere South America"
strings(6) = "EURO: Europe"
strings(7) = "MIDE: Middle East"
strings(8) = "NHAF: Northern Hemisphere Africa"
strings(9) = "SHAF: Southern Hemisphere Africa"
strings(10) = "BOAS: Boreal Asia"
strings(11) = "CEAS: Central Asia"
strings(12) = "SEAS: Southeast Asia"
strings(13) = "EQAS: Equatorial Asia"
strings(14) = "AUST: Australia"

   ijk=0
do iiy = 1850, 2003

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

datadir= getenv("ILAMB_DATADIR") + "/biomes/GFED"

FileIn=datadir + "/original/basis0.5x0.5.15regions_mod+noGreenland"
print(FileIn)

temp=asciiread(FileIn,(/nlat,nlon/),"integer")

data1=int2flt(temp(::-1,:))
delete(temp)


datadir= getenv("ILAMB_DATADIR") + "/biomes/Gretchen_GFED_Regions"

FileIn=datadir + "/original/AtmosphericPulseRegions.txt"
print(FileIn)

data_1d = asciiread(FileIn,-1,"string")

data_2d=new((/nlat0,nlon0/), string)

do ny=0,nlat0-1
   data_2d(ny,:) = str_split(data_1d(ny),",")
end do

print(dimsizes(data_2d))

data_2d = where(str_lower(data_2d).eq."nan", "-999", data_2d)

data0  = stringtofloat(data_2d)

data2=new((/nlat,nlon/), float)

do ny=0,nlat0-1
do nx=0,nlon0-1
   data2(2*ny:2*ny+1,2*nx:2*nx+1) = data0(ny,nx)
end do
end do

data = where(data1.eq.0, -999, data2)

data@_FillValue = -999

type = strings(0)
do ns = 1, ncls-1
   type = type + "," + strings(ns)
end do

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "biomes"
VarLongName = "biomes"
VarUnit     = "unitless"
Title       = "derived GFED 15 regions in 0.5x0.5"
Source      = "GFED product"
TimeStep    = "annual"

FileOut=datadir + "/derived/" + "biomes_0.5x0.5.nc"
print(FileOut)
;tttt = write_2D_biomes (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
;                       data, type, time, lat, lon, FileOut)

data!0="lat"
data!1="lon"
data&lat=lat
data&lon=lon
data&lon@units="degrees_east"
data&lat@units="degrees_north"

;----------- Begin first plot -----------------------------------------

  wks = gsn_open_wks("eps","map_0.5x0.5_GFED_biomes_22types")

;  cmap = (/(/1., 1., 1./), (/0., 0., 0./), (/1., 0., 0./), (/1., 0., .4/), \
;           (/1., 0., .8/), (/1., .2, 1./), (/1., .6, 1./), (/.6, .8, 1./), \
;           (/.2, .8, 1./), (/.2, .8, .6/), (/.2, .8, 0./), (/.2, .4, .0/), \
;           (/.2, .4, .4/), (/.2, .4, .8/), (/.6, .4, .8/), (/.6, .8, .8/), \
;           (/.6, .8, .4/), (/1., .6, .8/)/)

;  gsn_define_colormap(wks,"BlAqGrYeOrRe") 
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
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
;  res1@lbLabelAngleF         = 45
;  res1@lbLabelStrings        = strings
;  res1@lbLabelJust           = "CenterRight"

 
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

  res1@cnLevelSelectionMode  = "ManualLevels"
  res1@cnMinLevelValF        =  1
  res1@cnMaxLevelValF        =  22
  res1@cnLevelSpacingF       =  1

;  res1@cnLevelSelectionMode  = "Explicitlevels"
;  res1@cnLevels              = (/0,1,2,3,4,5,6,7,8,9,10,11,12,13,14/)
;  res1@cnLevels              = (/0.5,1,2,4,6,8,10,12,14,16,18,20,25,30,40/)
;  res1@cnLevels              = (/1,2,4,6,8,10,12,14,16,18,20,25,30,35,40,45,50/)

  plot1 = gsn_csm_contour_map (wks,data,res1)
;  plot1 = ColorShadeLeGeContour(plot1,-2.0,"gray",2.0,"gray")
;  plot1 = ZeroNegDashLineContour (plot1)
;  plot1 = gsn_csm_vector_scalar_map (wks,uc,vc,rc,res1)
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
