load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_biomes.ncl"

begin
iyear=2004
ncls=18
nlat=360
nlon=720

lat=fspan( -89.75, 89.75,nlat)
lon=fspan(-179.75,179.75,nlon)

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

datadir= getenv("ILAMB_ROOT") + "/DATA/landfraction/MODIS"

FileIn=datadir + "/original/landfraction_MODIS_IGBP_" + sprinti("%0.4i",iyear) + "_top18.dat"
print(FileIn)

temp=fbindirread(FileIn,0,(/ncls,nlat,nlon/),"float")

temp = temp/100.

temp!0="type"
temp!1="lat"
temp!2="lon"
temp&lat=lat
temp&lon=lon
temp&lon@units="degrees_east"
temp&lat@units="degrees_north"

data = 1.0 - temp(0,:,:) - temp(15,:,:) - temp(17,:,:)

FileIn=getenv("ILAMB_ROOT") + "/DATA/mask/original/mask_landsea_0.5x0.5.txt"
print(FileIn)

temp0=asciiread(FileIn,(/nlat,nlon/),"integer")

mask0=int2flt(temp0(::-1,:))
delete(temp0)

;data = where(mask0.gt.0 .and. data.le.0, 1, data)
;data = where(mask0.le.0, 0, data)

temp = where(temp.le.0, -999, temp)

temp@_FillValue = -999

data!0="lat"
data!1="lon"
data&lat=lat
data&lon=lon
data&lon@units="degrees_east"
data&lat@units="degrees_north"

;----------- Begin first plot -----------------------------------------

  wks = gsn_open_wks("eps","map_0.5x0.5_landfraction_MODIS_IGBP_2004")

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
  res1@mpFillOn              = False
  res1@mpOutlineOn           = False
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
;  res1@lbLabelStrings        = strings
  res1@lbLabelJust           = "CenterRight"
 
  res1@tmXBLabelFont         = "helvetica"
  res1@tmYLLabelFont         = "helvetica"
  res1@tmXBLabelFontHeightF  = 0.015
  res1@tmYLLabelFontHeightF  = 0.015
  res1@tmXBLabelsOn           = False
  res1@tmYLLabelsOn           = False
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
  res1@vpWidthF              = 0.30
  res1@vpHeightF             = 0.15

  res1@cnLevelSelectionMode  = "ManualLevels"
  res1@cnMinLevelValF        =  0.
  res1@cnMaxLevelValF        =  1.
  res1@cnLevelSpacingF       =  .05

;  res1@cnLevelSelectionMode  = "Explicitlevels"
;  res1@cnLevels              = (/0,1,2,3,4,5,6,7,8,9,10,11,12,13,14/)
;  res1@cnLevels              = (/0.5,1,2,4,6,8,10,12,14,16,18,20,25,30,40/)
;  res1@cnLevels              = (/1,2,4,6,8,10,12,14,16,18,20,25,30,35,40,45,50/)

  res1@lbLabelBarOn          = False

  res1@vpXF                  = 0.02
  res1@vpYF                  = 0.98
  res1@gsnCenterString       = strings(0)
  plot0 = gsn_csm_contour_map (wks,temp(0,:,:),res1)
  draw  (plot0)

  res1@vpYF                  = 0.83
  res1@gsnCenterString       = strings(1)
  plot1 = gsn_csm_contour_map (wks,temp(1,:,:),res1)
  draw  (plot1)

  res1@vpYF                  = 0.68
  res1@gsnCenterString       = strings(2)
  plot2 = gsn_csm_contour_map (wks,temp(2,:,:),res1)
  draw  (plot2)

  res1@vpYF                  = 0.53
  res1@gsnCenterString       = strings(3)
  plot3 = gsn_csm_contour_map (wks,temp(3,:,:),res1)
  draw  (plot3)

  res1@vpYF                  = 0.38
  res1@gsnCenterString       = strings(4)
  plot4 = gsn_csm_contour_map (wks,temp(4,:,:),res1)
  draw  (plot4)

  res1@lbLabelBarOn          = True
  res1@vpYF                  = 0.23
  res1@gsnCenterString       = strings(5)
  plot5 = gsn_csm_contour_map (wks,temp(5,:,:),res1)
  draw  (plot5)


  res1@lbLabelBarOn          = False

  res1@vpXF                  = 0.35
  res1@vpYF                  = 0.98
  res1@gsnCenterString       = strings(6)
  plot6 = gsn_csm_contour_map (wks,temp(6,:,:),res1)
  draw  (plot6)

  res1@vpYF                  = 0.83
  res1@gsnCenterString       = strings(7)
  plot7 = gsn_csm_contour_map (wks,temp(7,:,:),res1)
  draw  (plot7)

  res1@vpYF                  = 0.68
  res1@gsnCenterString       = strings(8)
  plot8 = gsn_csm_contour_map (wks,temp(8,:,:),res1)
  draw  (plot8)

  res1@vpYF                  = 0.53
  res1@gsnCenterString       = strings(9)
  plot9 = gsn_csm_contour_map (wks,temp(9,:,:),res1)
  draw  (plot9)

  res1@vpYF                  = 0.38
  res1@gsnCenterString       = strings(10)
  plot10 = gsn_csm_contour_map (wks,temp(10,:,:),res1)
  draw  (plot10)

  res1@lbLabelBarOn          = True
  res1@vpYF                  = 0.23
  res1@gsnCenterString       = strings(11)
  plot11 = gsn_csm_contour_map (wks,temp(11,:,:),res1)
  draw  (plot11)


  res1@lbLabelBarOn          = False

  res1@vpXF                  = 0.68
  res1@vpYF                  = 0.98
  res1@gsnCenterString       = strings(12)
  plot12 = gsn_csm_contour_map (wks,temp(12,:,:),res1)
  draw  (plot12)

  res1@vpYF                  = 0.83
  res1@gsnCenterString       = strings(13)
  plot13 = gsn_csm_contour_map (wks,temp(13,:,:),res1)
  draw  (plot13)

  res1@vpYF                  = 0.68
  res1@gsnCenterString       = strings(14)
  plot14 = gsn_csm_contour_map (wks,temp(14,:,:),res1)
  draw  (plot14)

  res1@vpYF                  = 0.53
  res1@gsnCenterString       = strings(15)
  plot15 = gsn_csm_contour_map (wks,temp(15,:,:),res1)
  draw  (plot15)

  res1@vpYF                  = 0.38
  res1@gsnCenterString       = strings(16)
  plot16 = gsn_csm_contour_map (wks,temp(16,:,:),res1)
  draw  (plot16)

  res1@lbLabelBarOn          = True
  res1@vpYF                  = 0.23
  res1@gsnCenterString       = strings(17)
  plot17 = gsn_csm_contour_map (wks,temp(17,:,:),res1)
  draw  (plot17)

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
