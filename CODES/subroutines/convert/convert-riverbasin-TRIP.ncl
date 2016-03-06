load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

start_year = 2000
end_year   = 2005
nyer       = end_year - start_year + 1

nmon       = 12
ntot       = nyer*nmon

nlat0      = 360
nlon0      = 720

lat0=fspan(-89.75,89.75,nlat0)
lon0=fspan(-179.75,179.75,nlon0)

nday=(/31,28,31,30,31,30,31,31,30,31,30,31/)

strings = (/"Amazon", "Congo_(Zaire)", "Mississippi", "Nile", "Parana_(La_Plata_with_Uruguay)", "Ob", "Yenisey_(Jenisej)",\
            "Lena", "Niger", "Amur", "Changjiang_(Yangtze)", "Mackenzie", "Volga", "Zambeze_(Zambezi)", \
            "Lake_Eyre_(with_Cooper's_Creek)", "St.Lawrence", "Murray", "Nelson", "Orange", "Indus", "Ganges"/)

; +++++++ generate data in 0.5x0.5 ++++++++
;nlat=360
;nlon=720
;lat=fspan(-89.75,89.75,nlat)
;lon=fspan(-179.75,179.75,nlon)

; +++++++ generate data in 1x1 ++++++++
;nlat=180
;nlon=360
;lat=fspan( -89.5, 89.5,nlat)
;lon=fspan(-179.5,179.5,nlon)

; +++++++ generate data in 2.5x2.5 ++++++++
nlat1=360
nlon1=720
nlat=72
nlon=144
lat=fspan( -88.75, 88.75,nlat)
lon=fspan(-178.75,178.75,nlon)

i50 = ind(lat.lt.-60)

   ijk=0
do iiy = 1850, start_year-1

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

datadir= getenv("ILAMB_ROOT") + "/DATA/riverbasin/TRIP"

FileIn=datadir + "/original/rivnum05.bin"
print(FileIn)

temp=fbindirread(FileIn,0,(/nlat0,nlon0/),"integer")

data0 = int2flt(temp(::-1,:))

if (any(isnan_ieee(data0))) then
   replace_ieeenan (data0, -999, 0)
end if

data0!0="lat"
data0!1="lon"

data0@_FillValue = -999

;data0 = data0/100.

data=new((/nlat,nlon/), float)

; +++++++ generate data in 0.5x0.5 ++++++++
;data = data0

; +++++++ generate data in 1x1 ++++++++
;do ny=0,nlat0-1,2
;do nx=0,nlon0-1,2
;   data(ny/2,nx/2)=data0(ny,nx)
;end do
;end do

; +++++++ generate data in 2.5x2.5 ++++++++
do ny=0,nlat0-1,5
do nx=0,nlon0-1,5
   data(ny/5,nx/5)=data0(ny+2,nx+2)
end do
end do

FileIn=getenv("ILAMB_ROOT") + "/DATA/mask/original/mask_landsea_0.5x0.5.txt"
print(FileIn)

temp0=asciiread(FileIn,(/nlat,nlon/),"integer")

mask0=int2flt(temp0(::-1,:))
delete(temp0)

;data = where(mask0.gt.0 .and. data.le.0, 1, data)
;data = where(mask0.le.0, 0, data)

;data(i50,:) = 0

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "riverbasin"
VarLongName = "riverbasin"
VarUnit     = "unitless"
Title       = "derived runoff from TRIP"
Source      = "TRIP"
TimeStep    = "climatology"
type        = "climatology runoff from TRIP in 0.5x0.5"

;time = time + int2dble(nday(iim-1))

ttt = data

;ttt = where(region.eq.0, -999, ttt)

ttt@_FillValue = -999

print(max(ttt))

; +++++++ generate data in 0.5x0.5 ++++++++
;FileOut= datadir + "/derived/" + \
;       "/riverbasin_0.5x0.5.nc"

; +++++++ generate data in 1x1 ++++++++
;FileOut= datadir + "/derived/" + \
;        "/riverbasin_1x1.nc"

; +++++++ generate data in 2.5x2.5 ++++++++
FileOut= datadir + "/derived/" + \
        "/riverbasin_2.5x2.5.nc"

print(FileOut)

;tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
;                        ttt, time, lat, lon, FileOut)

delete(ttt)

ijk=ijk+1

data0 = where(data0.le.2.5, data0, -999)
data0 = where(data0.le.2, data0, -999)
;data0 = where(data0.le.110 .and. data0.ge.100, data0, -999)
;data0 = where(data0.ge.22, -999, data0)
data0@_FillValue = -999

data0!0="lat"
data0!1="lon"
data0&lat=lat0
data0&lon=lon0
data0&lon@units="degrees_east"
data0&lat@units="degrees_north"

data!0="lat"
data!1="lon"
data&lat=lat
data&lon=lon
data&lon@units="degrees_east"
data&lat@units="degrees_north"

print(min(data0))
print(max(data0))
print(avg(data0))
print(sum(data0))

print(min(data))
print(max(data))
print(avg(data))
print(sum(data))

;----------- Begin first plot -----------------------------------------

;  wks = gsn_open_wks("x11","map_global_riverbasin_TRIP_0.5x0.5")
  wks = gsn_open_wks("x11","map_congo_riverbasin_TRIP_0.5x0.5")

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

;  res1@mpShapeMode           = "FreeAspect"
  res1@mpLimitMode           = "LatLon"
  res1@mpFillOn               = False
;  res1@mpOutlineOn           = False
;  res1@mpFillColor           = "black"
;  res1@mpLandFillPattern     = "HollowFill"
  res1@mpGeophysicalLineColor      = "black"
  res1@mpCenterLonF          = 0.
  res1@mpMinLonF             = 0.
  res1@mpMaxLonF             = 50.
  res1@mpMinLatF             =  -30.
  res1@mpMaxLatF             =  10.

  res1@lbLabelAutoStride     = False
;  res1@lbOrientation         = "vertical"
  res1@lbLabelFont           = "helvetica"
  res1@lbLabelFontHeightF    = 0.011
  res1@lbLabelBarOn          = False
  res1@lbLeftMarginF         = -1.3
  res1@lbRightMarginF        = -1.1
  res1@lbTopMarginF          = 0.5
  res1@lbBottomMarginF       = -0.1
;  res1@lbLabelStride         = 2
  res1@lbLabelStride         = 1
  ;res1@lbLabelAngleF         = 45
  ;res1@lbLabelStrings        = strings
  ;res1@lbLabelJust           = "CenterRight"
 
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
  res1@vpWidthF              = 0.6
  res1@vpHeightF             = 0.6

;  res1@cnLevelSelectionMode  = "ManualLevels"
;  res1@cnMinLevelValF        =  0.
;  res1@cnMaxLevelValF        =  1.
;  res1@cnLevelSpacingF       =  .05

  res1@cnLevelSelectionMode  = "Explicitlevels"
  res1@cnLevels              = (/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21/)
;  res1@cnLevels              = (/100,101,102,103,104,105,106,107,108,109,110/)
;  res1@cnLevels              = (/0.5,1,2,4,6,8,10,12,14,16,18,20,25,30,40/)
;  res1@cnLevels              = (/1,2,4,6,8,10,12,14,16,18,20,25,30,35,40,45,50/)

  plot1 = gsn_csm_contour_map (wks,data0,res1)
;  plot1 = ColorShadeLeGeContour(plot1,-2.0,"gray",2.0,"gray")
;  plot1 = ZeroNegDashLineContour (plot1)
;  plot1 = gsn_csm_vector_scalar_map (wks,uc,vc,rc,res1)
  draw  (plot1)

  res1@vpXF                  = 0.15
  res1@vpYF                  = 0.50

;  plot2 = gsn_csm_contour_map (wks,data0,res1)
;  plot1 = ColorShadeLeGeContour(plot1,-2.0,"gray",2.0,"gray")
;  plot1 = ZeroNegDashLineContour (plot1)
;  plot1 = gsn_csm_vector_scalar_map (wks,uc,vc,rc,res1)
;  draw  (plot2)

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
