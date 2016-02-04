load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_biomes.ncl"

begin

ncls=18

nlat0=3600
nlon0=7200

; +++++++ generate data in 0.5x0.5 ++++++++
;nlat=360
;nlon=720
;lat=fspan(-89.75,89.75,nlat)
;lon=fspan(-179.75,179.75,nlon)

; +++++++ generate data in 1x1 ++++++++
nlat=180
nlon=360
lat=fspan( -89.5, 89.5,nlat)
lon=fspan(-179.5,179.5,nlon)

; +++++++ generate data in 2.5x2.5 ++++++++
;nlat1=360
;nlon1=720
;nlat=72
;nlon=144
;lat=fspan( -88.75, 88.75,nlat)
;lon=fspan(-178.75,178.75,nlon)

i50 = ind(lat.lt.-60)

   ijk=0
do iiy = 1850, 2005

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

; -------------------------------

datadir= getenv("ILAMB_ROOT") + "/DATA/MODIS/"

temp=new((/ncls,nlat0,nlon0/), float)
types=new((/18/), string)

temp = 0.0

do iiy = 2003, 2012

   FileName = getenv("ILAMB_ROOT") + "/DATA/MODIS/MCD12C1/" + sprinti("%0.4i",iiy) + "/MCD12C1.A" + sprinti("%0.4i",iiy)

   FileIn = systemfunc("ls " + FileName + "*.hdf")

   if (fileexists(FileIn)) then
      print(FileIn)

      f1=addfile(FileIn,"r")
      print(f1)

      ;tmp=f1->Majority_Land_Cover_Type_1
      tmp=f1->Land_Cover_Type_1_Percent

      print(dimsizes(tmp))
      print(getvaratts(tmp))

      tmp1=byte2flt(tmp(::-1,:,:))
      print(dimsizes(tmp1))
      print(getvaratts(tmp1))
      print(tmp1(0,0,:))
      tmp1@_FillValue=-999.
      print(tmp1(0,0,:))

      ; +++++++ generate data in 0.5x0.5 ++++++++
      ;do nz=0,ncls-1
      ;do ny=0,3600-1,10
      ;do nx=0,7200-1,10
      ;   temp(nz,ny/10,nx/10)=temp(nz,ny/10,nx/10) + avg(tmp1(ny:ny+9,nx:nx+9,nz))
      ;end do
      ;end do
      ;end do

      ; +++++++ generate data in 1x1 ++++++++
      do nz=0,ncls-1
      do ny=0,3600-1,20
      do nx=0,7200-1,20
         if (all(ismissing(tmp1(ny:ny+19,nx:nx+19,nz)))) then
            temp(nz,ny/20,nx/20)=-999
         else
            temp(nz,ny/20,nx/20)=temp(nz,ny/20,nx/20) + avg(tmp1(ny:ny+19,nx:nx+19,nz))
         end if
      end do
      end do
      end do

      ; +++++++ generate data in 2.5x2.5 ++++++++
      ;do nz=0,ncls-1
      ;do ny=0,3600-1,50
      ;do nx=0,7200-1,50
      ;   if (all(ismissing(tmp1(ny:ny+49,nx:nx+49,nz)))) then
      ;      temp(nz,ny/50,nx/50)=-999
      ;   else
      ;      temp(nz,ny/50,nx/50)=temp(nz,ny/50,nx/50) + avg(tmp1(ny:ny+49,nx:nx+49,nz))
      ;   end if
      ;end do
      ;end do
      ;end do

      types(0)=tmp@Layer_0
      types(1)=tmp@Layer_1
      types(2)=tmp@Layer_2
      types(3)=tmp@Layer_3
      types(4)=tmp@Layer_4
      types(5)=tmp@Layer_5
      types(6)=tmp@Layer_6
      types(7)=tmp@Layer_7
      types(8)=tmp@Layer_8
      types(9)=tmp@Layer_9
      types(10)=tmp@Layer_10
      types(11)=tmp@Layer_11
      types(12)=tmp@Layer_12
      types(13)=tmp@Layer_13
      types(14)=tmp@Layer_14
      types(15)=tmp@Layer_15
      types(16)=tmp@Layer_16
      types(17)=tmp@Layer_17

      delete(tmp)
      delete(tmp1)
   end if
end do

temp = temp/10

print(types)

data=new((/nlat,nlon/), float)

do ny=0,nlat-1
do nx=0,nlon-1
   data(ny,nx)=int2flt(maxind(temp(:,ny,nx)))
end do
end do

type = types(0)
do ns = 1, ncls-1
   type = type + "," + types(ns)
end do

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "biomes"
VarLongName = "biomes"
VarUnit     = "unitless"
Title       = "derived MODIS IGBP 18 Land types"
Source      = "MODIS MOD12C1 product"
TimeStep    = "annual"

datadir= getenv("ILAMB_ROOT") + "/DATA/biomes/MODIS"

; +++++++ save data in 0.5x0.5 ++++++++
;FileOut=datadir + "/derived/" + "biomes_0.5x0.5.nc"

; +++++++ save data in 1x1 ++++++++
FileOut=datadir + "/derived/" + "biomes_1x1.nc"

; +++++++ save data in 2.5x2.5 ++++++++
;FileOut=datadir + "/derived/" + "biomes_2.5x2.5.nc"

print(FileOut)
tttt = write_2D_biomes (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                       data, type, time, lat, lon, FileOut)

data!0="lat"
data!1="lon"
data&lat=lat
data&lon=lon
data&lon@units="degrees_east"
data&lat@units="degrees_north"

;----------- Begin first plot -----------------------------------------

  wks = gsn_open_wks("x11","map_Global_IGBP_biomes_18types_2003-2012")

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
  res1@lbLabelAngleF         = 45
  res1@lbLabelStrings        = types
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

  res1@cnLevelSelectionMode  = "Explicitlevels"
  res1@cnLevels              = (/0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17/)

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
