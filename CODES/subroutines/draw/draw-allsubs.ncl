procedure Draw_LatLon_Time (PlotFileName:string, AnualObs:float, titles:string, \
                    cnlevels:float, lblabels:string, XLab:integer, YLab:integer, CLab:integer,   \
                    cLats:float, Times:float)

begin

  PlotType = getenv("PLOTTYPE")
  PlotType = str_lower(str_squeeze(PlotType))

  nlevels =dimsizes(cnlevels)

  print(PlotFileName)

  wks = gsn_open_wks(PlotType, PlotFileName)

;  --------   set  res1 ------------
  res1                       = True
  res1@gsnDraw               = False 
  res1@gsnFrame              = False

  if (isStrSubset(str_lower(PlotFileName), "bias" ) .and. .not.isStrSubset(str_lower(PlotFileName), "globalbiasscore" )) then
     gsn_define_colormap(wks,"BlWhRe")
     colors                     = floattoint(fspan(2, 101, nlevels+1))
     res1@gsnSpreadColorEnd    = 101
  else
     if (isStrSubset(str_lower(PlotFileName), "annualmean" )) then
        gsn_define_colormap(wks,"BlRe")
        colors                     = floattoint(fspan(2, 96, nlevels+1))
        res1@gsnSpreadColorEnd    = 96
     else
        gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
        colors                    = floattoint(fspan(2, 200, nlevels+1))
        res1@gsnSpreadColorEnd    = 200
     end if
  end if

  res1@tmYLLabelFontHeightF  = 0.011
  res1@tmXBLabelFontHeightF  = 0.011
  res1@tiXAxisFontHeightF    = 0.011
  res1@tiYAxisFontHeightF    = 0.011
  res1@tiXAxisFont           = "helvetica-Bold" 
  res1@tiYAxisFont           = "helvetica-Bold" 
  res1@tmYLLabelFont         = "helvetica"
  res1@tmXBLabelFont         = "helvetica"
  res1@tmXBLabelStride       = XLab
  res1@tmYLLabelStride       = YLab

  res1@gsnStringFontHeightF  = 0.011
  res1@tiMainFontHeightF     = 0.011
  res1@gsnStringFont         = "helvetica-bold"
  res1@tiMainFont            = "helvetica-bold"

  res1@vpWidthF              = 0.50
  res1@vpHeightF             = 0.25
  res1@vpYF                  = 0.80

  res1@tiMainString          = ""
  res1@gsnCenterString       = titles

;  res1@trXMinF               = 0.5
;  res1@trXMaxF               = 11.5

  res1@tmXBMode              = "Explicit"
  res1@tmXBValues            = Times
  res1@tmXBLabels            = Times@lblabels

  res1@tmYLMode              = "Explicit"
  res1@tmYLValues            = cLats
  res1@tmYLLabels            = cLats@lblabels

  res1@cnFillOn              = True
  res1@cnLinesOn             = False
  res1@cnLineLabelsOn        = False
  res1@cnInfoLabelOn         = False
  res1@cnFillMode            = "RasterFill"

  res1@cnLevelSelectionMode  = "Explicitlevels"
  res1@cnLevels              = cnlevels

  res1@cnLineLabelFont       = "helvetica"
  res1@cnLineLabelFontHeightF= 0.01
  res1@cnLabelMasking        = True
  res1@cnLineLabelDensityF   = 1.0
  res1@cnLineLabelInterval   = 1.
  res1@cnLineDashSegLenF     =  0.2

  res1@lbLabelBarOn          = False

  res1@gsnAddCyclic          = False
  res1@gsnSpreadColors       = True
  res1@gsnSpreadColorStart   =  2

  plot = gsn_csm_contour (wks,AnualObs,res1)
;  plot = gsn_csm_lat_time (wks,AnualObs,res1)

; --- Draw Lable Bar -------

  nboxes = dimsizes(lblabels)

  getvalues plot
    "vpHeightF" : vph
    "vpWidthF"  : vpw
  end getvalues

  lbres                    = True
  lbres@lbAutoManage       = True
  lbres@lbLabelAutoStride  = False
  lbres@lbFillBackground   = 0
  lbres@lbPerimFill        = "SolidFill"
  lbres@vpWidthF           = 0.12 * vpw
  lbres@vpHeightF          = 1.00 * vph
  lbres@lbBoxMajorExtentF  = 0.80
  lbres@lbFillColors       = colors
  lbres@lbMonoFillPattern  = True
  lbres@lbLabelFontHeightF = 0.20
  lbres@lbLabelJust        = "CenterLeft"
;  lbres@lbPerimOn          = False

  lbid = gsn_create_labelbar(wks,nboxes,lblabels,lbres)

  amres                  = True
  amres@amJust           = "BottomCenter"
  amres@amParallelPosF   = 0.57
  amres@amOrthogonalPosF = 0.50
  annoid = gsn_add_annotation(plot,lbid,amres)

  draw  (plot)

; ---   write text ----

;  if (isatt(AnualObs, "NAME") .and. isatt(AnualObs, "Lats")) then
;
;     res_text                    = True
;     res_text@txFont             = "helvetica-bold"
;     res_text@txJust             = "CenterCenter"
;     res_text@txFontColor        = "foreground"
;     res_text@txFontHeightF      = 0.010
;
;     gsn_text(wks,plot, AnualObs@NAME, AnualObs@Lons, AnualObs@Lats, res_text)
;  end if

  frame(wks)

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Draw_Map (PlotFileName:string, AnualObs: float, slat:float, slon:float, titles:string, \
                    cnlevels:float, lblabels:string, XLab:integer, YLab:integer, CLab:integer,   \
                    MinLon:float, MaxLon:float, MinLat:float, MaxLat:float, SiteID)

begin

  PlotType = getenv("PLOTTYPE")
  PlotType = str_lower(str_squeeze(PlotType))

  nlevels =dimsizes(cnlevels)

  print(PlotFileName)

  wks = gsn_open_wks(PlotType, PlotFileName)

;  --------   set  res1 ------------
  res1                       = True
  res1@gsnDraw               = False 
  res1@gsnFrame              = False

  if (isStrSubset(str_lower(PlotFileName), "bias" ) .and. .not.isStrSubset(str_lower(PlotFileName), "globalbiasscore" )) then
     gsn_define_colormap(wks,"BlWhRe")
     colors                     = floattoint(fspan(2, 101, nlevels+1))
     res1@gsnSpreadColorEnd     = 101
  else
     gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
     colors                    = floattoint(fspan(2, 200, nlevels+1))
     res1@gsnSpreadColorEnd     = 200
  end if

  res1@mpDataBaseVersion     = "Ncarg4_1"
  res1@mpDataSetName         = "Earth..4"
  res1@mpDataResolution      = "FinestResolution"

  res1@mpLimitMode           = "LatLon"
  res1@mpFillOn              = False
  res1@mpCenterLonF          = 0.
  res1@mpMinLonF             = MinLon
  res1@mpMaxLonF             = MaxLon
  res1@mpMinLatF             = MinLat
  res1@mpMaxLatF             = MaxLat
  res1@mpOutlineOn           = True

  res1@tmYLLabelFontHeightF  = 0.011
  res1@tmXBLabelFontHeightF  = 0.011
  res1@tiXAxisFontHeightF    = 0.011
  res1@tiYAxisFontHeightF    = 0.011
  res1@tiXAxisFont           = "helvetica-Bold" 
  res1@tiYAxisFont           = "helvetica-Bold" 
  res1@tmYLLabelFont         = "helvetica"
  res1@tmXBLabelFont         = "helvetica"
  res1@tmXBLabelStride       = XLab
  res1@tmYLLabelStride       = YLab

  res1@gsnStringFontHeightF  = 0.011
  res1@tiMainFontHeightF     = 0.011
  res1@gsnStringFont         = "helvetica-bold"
  res1@tiMainFont            = "helvetica-bold"

  res1@vpWidthF              = 0.50
  res1@vpHeightF             = 0.25
  res1@vpYF                  = 0.80

  res1@tiMainString          = ""
  res1@gsnCenterString       = titles

  if (SiteID.eq.1) then

     plot = gsn_csm_map (wks,res1)

     mkres = True

     dum_fill                = new(nlevels+1,graphic)
     dum_hollow              = new(nlevels+1,graphic)

     mkres@gsMarkerThicknessF   = 1.0 

     ii = ind(AnualObs.lt.cnlevels(0))
     if (dimsizes(ii).ge.2 .or. .not.ismissing(ii)) then
        mkres@gsMarkerIndex = 16 
        mkres@gsMarkerSizeF = 0.0075
        mkres@gsMarkerColor = colors(0)
        dum_fill(0) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)
     end if
     delete(ii)

     do i=0,nlevels-2
        ii = ind(AnualObs.ge.cnlevels(i) .and. AnualObs.lt.cnlevels(i+1))
        if (dimsizes(ii).ge.2 .or. .not.ismissing(ii)) then
           mkres@gsMarkerIndex = 16 
           mkres@gsMarkerSizeF = 0.006
           mkres@gsMarkerColor = colors(i+1)
           dum_fill(i+1) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)
        end if
        delete(ii)
     end do

     ii = ind(AnualObs.ge.cnlevels(nlevels-1))
     if (dimsizes(ii).ge.2 .or. .not.ismissing(ii)) then
        mkres@gsMarkerIndex = 16 
        mkres@gsMarkerSizeF = 0.006
        mkres@gsMarkerColor = colors(nlevels)
        dum_fill(nlevels) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)
     end if
     delete(ii)

  else

     res1@cnFillOn              = True
     res1@cnLinesOn             = False
     res1@cnLineLabelsOn        = False
     res1@cnInfoLabelOn         = False
     res1@cnFillMode            = "RasterFill"

     res1@cnLevelSelectionMode  = "Explicitlevels"
     res1@cnLevels              = cnlevels

     res1@cnLineLabelFont       = "helvetica"
     res1@cnLineLabelFontHeightF= 0.01
     res1@cnLabelMasking        = True
     res1@cnLineLabelDensityF   = 1.0
     res1@cnLineLabelInterval   = 1.
     res1@cnLineDashSegLenF     =  0.2

     res1@lbLabelBarOn          = False

     res1@gsnAddCyclic          = False
     res1@gsnSpreadColors       = True
     res1@gsnSpreadColorStart   =  2

     plot = gsn_csm_contour_map (wks,AnualObs,res1)

  end if

; --- Draw Lable Bar -------

  nboxes = dimsizes(lblabels)

  getvalues plot
    "vpHeightF" : vph
    "vpWidthF"  : vpw
  end getvalues

  lbres                    = True
  lbres@lbAutoManage       = True
  lbres@lbLabelAutoStride  = False
  lbres@lbFillBackground   = 0
  lbres@lbPerimFill        = "SolidFill"
  lbres@vpWidthF           = 0.12 * vpw
  lbres@vpHeightF          = 1.00 * vph
  lbres@lbBoxMajorExtentF  = 0.80
  lbres@lbFillColors       = colors
  lbres@lbMonoFillPattern  = True
  lbres@lbLabelFontHeightF = 0.18
  lbres@lbLabelJust        = "CenterLeft"
;  lbres@lbPerimOn          = False

  lbid = gsn_create_labelbar(wks,nboxes,lblabels,lbres)

  amres                  = True
  amres@amJust           = "BottomCenter"
  amres@amParallelPosF   = 0.57
  amres@amOrthogonalPosF = 0.50
  annoid = gsn_add_annotation(plot,lbid,amres)

  draw  (plot)

; ---   write text ----

  if (isatt(AnualObs, "NAME") .and. isatt(AnualObs, "Lats")) then

     res_text                    = True
     res_text@txFont             = "helvetica-bold"
     res_text@txJust             = "CenterCenter"
     res_text@txFontColor        = "foreground"
     res_text@txFontHeightF      = 0.010

     gsn_text(wks,plot, AnualObs@NAME, AnualObs@Lons, AnualObs@Lats, res_text)
  end if

  frame(wks)

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Draw_Map_Site (PlotFileName:string, AnualObs: float, slat:float, slon:float, titles:string, \
                         cnlevels:float, lblabels:string, XLab:integer, YLab:integer, CLab:integer, MinLon:float, \
                         MaxLon:float, MinLat:float, MaxLat:float)

begin

  PlotType = getenv("PLOTTYPE")
  PlotType = str_lower(str_squeeze(PlotType))

  nlevels =dimsizes(cnlevels)

  print(PlotFileName)

  wks = gsn_open_wks(PlotType, PlotFileName)

  if (isStrSubset(str_lower(PlotFileName), "bias" ) .and. .not.isStrSubset(str_lower(PlotFileName), "globalbiasscore" )) then
     gsn_define_colormap(wks,"BlWhRe")
     colors                     = floattoint(fspan(2, 101, nlevels+1))
  else
     gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
     colors                     = floattoint(fspan(2, 200, nlevels+1))
  end if

;  --------   set  res1 ------------
  res1                       = True
  res1@gsnDraw               = False 
  res1@gsnFrame              = False

  res1@mpDataBaseVersion     = "Ncarg4_1"
  res1@mpDataSetName         = "Earth..4"
  res1@mpDataResolution      = "FinestResolution"

  res1@mpLimitMode           = "LatLon"
  res1@mpFillOn              = False
  res1@mpCenterLonF          = 0.
  res1@mpMinLonF             = MinLon
  res1@mpMaxLonF             = MaxLon
  res1@mpMinLatF             = MinLat
  res1@mpMaxLatF             = MaxLat

  res1@tmYLLabelFontHeightF  = 0.011
  res1@tmXBLabelFontHeightF  = 0.011
  res1@tiXAxisFontHeightF    = 0.011
  res1@tiYAxisFontHeightF    = 0.011
  res1@tiXAxisFont           = "helvetica-Bold" 
  res1@tiYAxisFont           = "helvetica-Bold" 
  res1@tmYLLabelFont         = "helvetica"
  res1@tmXBLabelFont         = "helvetica"
  res1@tmXBLabelStride       = XLab
  res1@tmYLLabelStride       = YLab

  res1@gsnAddCyclic          = False
  res1@gsnStringFontHeightF  = 0.011
  res1@tiMainFontHeightF     = 0.011
  res1@gsnStringFont         = "helvetica-bold"
  res1@tiMainFont            = "helvetica-bold"

  res1@vpWidthF              = 0.50
  res1@vpHeightF             = 0.25
  res1@vpYF                  = 0.80

  res1@tiMainString          = ""
  res1@gsnCenterString       = titles

  plot = gsn_csm_map (wks,res1)

  mkres = True

  dum_fill                   = new(nlevels+1,graphic)
  dum_hollow                 = new(nlevels+1,graphic)

  mkres@gsMarkerThicknessF   = 1.0 

  sizes                      = fspan(0,15,nlevels)/1000.

  ii = ind(AnualObs.lt.cnlevels(0))
  if (dimsizes(ii).ge.2 .or. .not.ismissing(ii)) then
     mkres@gsMarkerIndex = 16 
     mkres@gsMarkerSizeF = 0.0075
     mkres@gsMarkerColor = colors(0)

     dum_fill(0) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)

  end if
  delete(ii)

  do i=0,nlevels-2
    ii = ind(AnualObs.ge.cnlevels(i) .and. AnualObs.lt.cnlevels(i+1))
    if (dimsizes(ii).ge.2 .or. .not.ismissing(ii)) then
    
       mkres@gsMarkerIndex = 16 
       mkres@gsMarkerSizeF = 0.006
       mkres@gsMarkerColor = colors(i+1)

       dum_fill(i+1) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)

    end if
    delete(ii)
  end do

  ii = ind(AnualObs.ge.cnlevels(nlevels-1))
  if (dimsizes(ii).ge.2 .or. .not.ismissing(ii)) then
     mkres@gsMarkerIndex = 16 
     mkres@gsMarkerSizeF = 0.006
     mkres@gsMarkerColor = colors(nlevels)

     dum_fill(nlevels) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)

  end if
  delete(ii)

  getvalues plot
    "vpHeightF" : vph
    "vpWidthF"  : vpw
  end getvalues

  nboxes = dimsizes(lblabels)

  lbres                    = True
  lbres@lbAutoManage       = True
  lbres@lbFillBackground   = 0
  lbres@lbPerimFill        = "SolidFill"
  lbres@vpWidthF           = 0.09 * vpw
  lbres@vpHeightF          = 1.0 * vph
  lbres@lbBoxMajorExtentF  = 0.80
  lbres@lbFillColors       = colors
  lbres@lbMonoFillPattern  = True
  lbres@lbLabelFontHeightF = 0.18
  lbres@lbLabelJust        = "CenterLeft"
;  lbres@lbPerimOn          = False

  lbid = gsn_create_labelbar(wks,nboxes,lblabels,lbres)

  amres                  = True
  amres@amJust           = "BottomCenter"
  amres@amParallelPosF   = 0.55
  amres@amOrthogonalPosF = 0.50
  annoid = gsn_add_annotation(plot,lbid,amres)

  draw  (plot)

  ; ---------------   write text --------------------------

  FontHeightF                 = 0.008

  res_text                    = True
  res_text@txFontThicknessF   = 2.0
  res_text@txFont             = "helvetica-bold"
  res_text@txJust             = "CenterCenter"

  res_text@txFontHeightF      = 0.009
  res_text@txJust             = "CenterLeft"

  xxx=0.75
  yyy=0.58
  do i = 0, nlevels-1
     res_text@txFontColor        = colors(i)
     ;res_text@txFontHeightF      = int2flt(iim)/500.
     if (cnlevels(i).eq.max(cnlevels)) then
        gsn_text_ndc(wks,"~F37~Z~F22~ >" + str_squeeze(sprintf("%6.2f", cnlevels(i))),xxx+0.02,yyy,res_text)
     else
        if (cnlevels(i).eq.min(cnlevels)) then
           gsn_text_ndc(wks,"~F37~Z~F22~ <" + str_squeeze(sprintf("%6.2f", cnlevels(i))),xxx+0.02,yyy,res_text)
        else
           gsn_text_ndc(wks,"~F37~Z~F22~  " + str_squeeze(sprintf("%6.2f", cnlevels(i))),xxx+0.02,yyy,res_text)
        end if
     end if
     yyy=yyy+0.225/int2flt(nlevels+1)
  end do

  frame(wks)

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Draw_Map_Check (PlotFileName:string, AnualObs:float, slat:float, slon:float, \
                    titles:string, cnlevels:float, lblabels:string, ShortName:string,  \
                    clon:float, clat:float, MinLon:float, MaxLon:float, MinLat:float,  \
                    MaxLat:float, latlon:float, SiteID:integer)

begin

  PlotType = getenv("PLOTTYPE")
  PlotType = str_lower(str_squeeze(PlotType))

  nlevels =dimsizes(cnlevels)

  wks = gsn_open_wks(PlotType, PlotFileName)

  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

  colors                     = floattoint(fspan(2, 200, nlevels+1))

;  --------   set  res1 ------------
  res1                       = True
  res1@gsnDraw               = False 
  res1@gsnFrame              = False

  res1@mpDataBaseVersion     = "Ncarg4_1"
  res1@mpDataSetName         = "Earth..4"
  res1@mpDataResolution      = "FinestResolution"

  res1@mpLimitMode           = "LatLon"
  res1@mpFillOn              = False
  res1@mpCenterLonF          = 0.
  res1@mpMinLonF             = MinLon
  res1@mpMaxLonF             = MaxLon
  res1@mpMinLatF             = MinLat
  res1@mpMaxLatF             = MaxLat

  res1@tmYLLabelFontHeightF  = 0.011
  res1@tmXBLabelFontHeightF  = 0.011
  res1@tiXAxisFontHeightF    = 0.011
  res1@tiYAxisFontHeightF    = 0.011
  res1@tiXAxisFont           = "helvetica-Bold" 
  res1@tiYAxisFont           = "helvetica-Bold" 
  res1@tmYLLabelFont         = "helvetica"
  res1@tmXBLabelFont         = "helvetica"
;  res1@tmXBLabelStride       = XLab
;  res1@tmYLLabelStride       = YLab

  res1@tmXBLabelsOn          = False
  res1@tmYLLabelsOn          = False
  res1@tmXBOn                = False
  res1@tmXTOn                = False
  res1@tmYLOn                = False
  res1@tmYROn                = False

  res1@gsnStringFontHeightF  = 0.011
  res1@tiMainFontHeightF     = 0.011
  res1@gsnStringFont         = "helvetica-bold"
  res1@tiMainFont            = "helvetica-bold"

  res1@vpWidthF              = 0.50
  res1@vpHeightF             = 0.25
  res1@vpYF                  = 0.80

  if (SiteID.eq.1) then

     plot = gsn_csm_map (wks,res1)

     mkres = True

     dum_fill                   = new(nlevels+1,graphic)
     dum_hollow                 = new(nlevels+1,graphic)

     mkres@gsMarkerThicknessF   = 1.0 

     ii = ind(AnualObs.lt.cnlevels(0))
     if (dimsizes(ii).ge.2 .or. .not.ismissing(ii)) then
        mkres@gsMarkerIndex = 16 
        mkres@gsMarkerSizeF = 0.0075
        mkres@gsMarkerColor = colors(0)

        dum_fill(0) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)
     end if
     delete(ii)

     do i=0,nlevels-2
        ii = ind(AnualObs.ge.cnlevels(i) .and. AnualObs.lt.cnlevels(i+1))
        if (dimsizes(ii).ge.2 .or. .not.ismissing(ii)) then
    
           mkres@gsMarkerIndex = 16 
           mkres@gsMarkerSizeF = 0.006
           mkres@gsMarkerColor = colors(i+1)

           dum_fill(i+1) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)
        end if
        delete(ii)
     end do

     ii = ind(AnualObs.ge.cnlevels(nlevels-1))
     if (dimsizes(ii).ge.2 .or. .not.ismissing(ii)) then
        mkres@gsMarkerIndex = 16 
        mkres@gsMarkerSizeF = 0.006
        mkres@gsMarkerColor = colors(nlevels)

        dum_fill(nlevels) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)
     end if
     delete(ii)
  else

     res1@cnFillOn              = True
     res1@cnLinesOn             = False
     res1@cnLineLabelsOn        = False
     res1@cnInfoLabelOn         = False
     res1@cnFillMode            = "RasterFill"

     res1@cnLevelSelectionMode  = "Explicitlevels"
     res1@cnLevels              = cnlevels

     res1@cnLineLabelFont       = "helvetica"
     res1@cnLineLabelFontHeightF= 0.01
     res1@cnLabelMasking        = True
     res1@cnLineLabelDensityF   = 1.0
     res1@cnLineLabelInterval   = 1.
     res1@cnLineDashSegLenF     =  0.2

     res1@lbLabelBarOn          = False

     res1@gsnAddCyclic          = False
     res1@gsnSpreadColors       = True
     res1@gsnSpreadColorStart   =  2
     res1@gsnSpreadColorEnd     = 200

     plot = gsn_csm_contour_map (wks,AnualObs,res1)
  end if


  if (isatt(AnualObs, "DATA")) then

     nlevels2 =dimsizes(AnualObs@cnlevels)

     colors2                     = floattoint(fspan(2, 200, nlevels2+1))
   
   ;  --------   set  res2 ------------
     res2                       = True
     res2@gsnDraw               = False 
     res2@gsnFrame              = False
   
     res2@mpDataBaseVersion     = "Ncarg4_1"
     res2@mpDataSetName         = "Earth..4"
     res2@mpDataResolution      = "FinestResolution"
   
     res2@mpLimitMode           = "LatLon"
     res2@mpFillOn              = False
     res2@mpCenterLonF          = 0.
     res2@mpMinLonF             = MinLon
     res2@mpMaxLonF             = MaxLon
     res2@mpMinLatF             = MinLat
     res2@mpMaxLatF             = MaxLat
     res2@mpOutlineOn           = True
   
     res1@vpWidthF              = 0.50
     res2@vpHeightF             = 0.25
     res2@vpYF                  = 0.80
   
     res2@tiMainString          = ""
     res2@gsnCenterString       = ""

     res2@cnFillOn              = True
     res2@cnLinesOn             = False
     res2@cnLineLabelsOn        = False
     res2@cnInfoLabelOn         = False
     res2@cnFillMode            = "RasterFill"

     res2@cnLevelSelectionMode  = "Explicitlevels"
     res2@cnLevels              = AnualObs@cnlevels

     res2@cnLineLabelFont       = "helvetica"
     res2@cnLineLabelFontHeightF= 0.01
     res2@cnLabelMasking        = True
     res2@cnLineLabelDensityF   = 1.0
     res2@cnLineLabelInterval   = 1.
     res2@cnLineDashSegLenF     =  0.2

     res2@lbLabelBarOn          = False
     res2@tmXBLabelsOn          = False
     res2@tmYLLabelsOn          = False

     res2@gsnAddCyclic          = False
     res2@gsnSpreadColors       = True
     res2@gsnSpreadColorStart   =  2
     res2@gsnSpreadColorEnd     = 200

     plot1 = plot

     plot = gsn_csm_contour_map (wks,AnualObs@DATA,res2)
     ;plot = gsn_csm_contour_map_overlay (wks,AnualObs@DATA,AnualObs,res2,res1)

     overlay(plot,plot1)

  end if


; ++++ Draw Label Bars ++++
  getvalues plot
    "vpHeightF" : vph
    "vpWidthF"  : vpw
  end getvalues

  nboxes = dimsizes(lblabels)

  lbres                    = True
  lbres@lbAutoManage       = True
  lbres@lbFillBackground   = 0
  lbres@lbPerimFill        = "SolidFill"
  lbres@vpWidthF           = 0.09 * vpw
  lbres@vpHeightF          = 0.7 * vph
  lbres@lbBoxMajorExtentF  = 0.8
  lbres@lbFillColors       = colors
  lbres@lbMonoFillPattern  = True
  lbres@lbLabelFontHeightF = 0.18
  lbres@lbLabelJust        = "CenterLeft"
;  lbres@lbPerimOn          = False

  lbid = gsn_create_labelbar(wks,nboxes,lblabels,lbres)

  amres                  = True
  amres@amJust           = "BottomCenter"
  amres@amParallelPosF   =-0.45
  amres@amOrthogonalPosF = 0.47

  if (str_upper(AnualObs@LabelBarOn) .eq. "YES") then
     annoid = gsn_add_annotation(plot,lbid,amres)
  end if

  draw  (plot)

; ---------------   write text --------------------------

  res_text                    = True
  res_text@txFontHeightF      = 0.007
  res_text@txFont             = "helvetica-bold"
  res_text@txJust             = "CenterCenter"

  res_lines                   = True
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 2.
  res_text@txFontColor        = "dark green"
  res_lines@gsLineColor       = "dark green"

  res_text@txJust             = "CenterRight"

  res_text@txFontColor        = "foreground"
  gsn_text(wks,plot, titles, MaxLon-5.0, MinLat+5.0,res_text)
;  gsn_text(wks,plot, titles, (MinLon+MaxLon)/2, MinLat+5.0,res_text)

  res_text@txFontColor        = "red"
  if (isatt(titles, "SubTitle")) then
     gsn_text(wks,plot, titles@SubTitle, MaxLon-5.0, MinLat+15.0,res_text)
  end if

  res_text@txFontColor        = "foreground"
  res_text@txJust             = "CenterCenter"
  res_text@txFontHeightF      = 0.010

  if (str_upper(SiteID@NAME).eq."GLOBAL") then
     gsn_text(wks,plot, ShortName, clon, clat,res_text)
  end if

;  if (str_upper(SiteID@NAME).eq."SITE") then
;     gsn_text(wks,plot,"~F37~R",latlon(1,:), latlon(0,:),res_text) 
;  end if

  if (any(str_upper(SiteID@NAME).eq.(/"ZONAL", "MERIDIONAL"/))) then
     gsn_text(wks,plot,"~F37~R",slon, slat,res_text) 
  end if

  if (str_upper(SiteID@NAME).eq."REGION") then
     do ns =0, nsit-1
           xxx = (/latlon(1,ns),latlon(1,ns)/)
           yyy = (/latlon(0,ns),latlon(2,ns)/)
        gsn_polyline(wks,plot,xxx,yyy,res_lines)
           xxx = (/latlon(3,ns),latlon(3,ns)/)
           yyy = (/latlon(0,ns),latlon(2,ns)/)
        gsn_polyline(wks,plot,xxx,yyy,res_lines)
           xxx = (/latlon(1,ns),latlon(3,ns)/)
           yyy = (/latlon(0,ns),latlon(0,ns)/)
        gsn_polyline(wks,plot,xxx,yyy,res_lines)
           xxx = (/latlon(1,ns),latlon(3,ns)/)
           yyy = (/latlon(2,ns),latlon(2,ns)/)
        gsn_polyline(wks,plot,xxx,yyy,res_lines)
     end do
        delete(xxx)
        delete(yyy)
  end if

  frame(wks)

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Draw_Plot_XY (PlotFileName:string, corr:float, ModelNameList:string, \
                        Xmin:float, Xmax:float, Ymin:float, Ymax:float)

begin

  PlotType = getenv("PLOTTYPE")
  PlotType = str_lower(str_squeeze(PlotType))

  nmod = dimsizes(ModelNameList) - 1

  print(PlotFileName)

  wks = gsn_open_wks(PlotType, PlotFileName)

  gsn_define_colormap(wks,"default")

;  --------   set  res1 ------------
  res1                       = True
  res1@gsnDraw               = False
  res1@gsnFrame              = False

  res1@xyMarkLineModes       = "Lines"
  res1@xyLabelMode           = "Custom"

;  res1@tmLabelAutoStride     = True

  colors                     = floattoint(fspan(1, nmod+1, nmod+1))
  res1@xyMarkerColors        = colors
  res1@xyLineColors          = colors

  res1@tiXAxisFont           = "helvetica-Bold"
  res1@tiYAxisFont           = "helvetica-Bold"
  res1@tiXAxisFontHeightF    = 0.011
  res1@tiYAxisFontHeightF    = 0.011
  res1@tmXBLabelFont         = "helvetica"
  res1@tmYLLabelFont         = "helvetica"
  res1@tmXBLabelFontHeightF  = 0.011
  res1@tmYLLabelFontHeightF  = 0.011
  res1@tmXBLabelStride       = 1
  res1@tmYLLabelStride       = 1
  res1@tmXBLabelsOn          = True

  res1@gsnStringFontHeightF  =0.011
  res1@gsnStringFont         ="helvetica-bold"

  res1@tiMainFont            ="helvetica-bold"
  res1@tiMainFontHeightF     =0.011

  res1@tiMainString          = ""
  res1@tiMainFont            = "helvetica-Bold"

  res1@trYMinF               = Ymin
  res1@trYMaxF               = Ymax
  res1@trXMinF               = Xmin
  res1@trXMaxF               = Xmax

  res1@vpXF                  = 0.10
  res1@vpYF                  = 0.80
  res1@vpWidthF              = 0.80
  res1@vpHeightF             = 0.10

; ---------------   precip-1 --------------------------
  res1@tiXAxisString         = corr@XTitles
  res1@tiYAxisString         = corr@YTiles

  plot  = gsn_csm_xy (wks,xxx,corr,res1)
  draw(plot)

  delete (colors)

  res_text                    = True
  res_text@txFontHeightF      = 0.012
  res_text@txFont             = "helvetica-bold"
  res_text@txJust             = "CenterLeft"

  res_lines                   = True
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 1.

  xx0 = (/0.,1./)
  yy0 = (/0.0, 0.0/)
  gsn_polyline(wks,plot,xx0,yy0,res_lines)

  res_text@txJust             = "CenterLeft"
  xx0 = (/0.65,0.70/)
  yy0 = (/0.85, 0.85/)
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineColor       = 1.0
  res_text@txFontColor        = 1.0

  res_lines@gsLineThicknessF  = 2.
  res_lines@gsLineDashPattern = 2
  colors                      = floattoint(fspan(1, nmod+1, nmod+1))

  xx0 = (/0.11, 0.11/)
  yy0 = (/0.63, 0.63/)

     ij=0
  do n1=1, 4
     xx0 = (/0.13, 0.13/)
     yy0 = (/0.63, 0.63/)
  do n2=1, ceil(int2flt(nmod)/4.0)
     xx1 = xx0 + 0.20*int2flt(n1-1)
     yy1 = yy0 - 0.02*int2flt(n2-1)
     if (ij.le.(nmod-1)) then
        res_lines@gsLineColor       = colors(ij)
        res_text@txFontColor        = colors(ij)
        gsn_text_ndc(wks,ModelNameList(ij+1),xx1(1)+0.01,yy1(0),res_text)
     end if
     ij=ij+1
  end do
  end do

  delete(xx0)
  delete(xx1)
  delete(yy0)
  delete(yy1)

  frame(wks)

end 

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Draw_Map_CheckPoint (PlotFileName:string, AnualObs:float, titles:string, cnlevels:float, \
                    lblabels:string, ShortName:string, clon:float, clat:float, MinLon:float, \
                    MaxLon:float, MinLat:float, MaxLat:float, latlon:float, SiteID:integer)

begin

  PlotType = getenv("PLOTTYPE")
  PlotType = str_lower(str_squeeze(PlotType))

  nlevels =dimsizes(cnlevels)

  print(PlotFileName)

  wks = gsn_open_wks(PlotType, PlotFileName)

  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

  colors                     = floattoint(fspan(2, 200, nlevels+1))

;  --------   set  res1 ------------
  res1                       = True
  res1@gsnDraw               = False 
  res1@gsnFrame              = False
  res1@cnFillDrawOrder       = "Predraw"

  res1@cnFillOn              = True
  res1@cnLinesOn             = False
  res1@cnLineLabelsOn        = False
  res1@cnInfoLabelOn         = False
  res1@cnFillMode            = "RasterFill"

  res1@cnLevelSelectionMode  = "Explicitlevels"
  res1@cnLevels              = cnlevels

  res1@cnLineLabelFont       = "helvetica"
  res1@cnLineLabelFontHeightF= 0.01
  res1@cnLabelMasking        = True
  res1@cnLineLabelDensityF   = 1.0
  res1@cnLineLabelInterval   = 1.
  res1@cnLineDashSegLenF     =  0.2

  res1@mpDataBaseVersion     = "Ncarg4_1"
  res1@mpDataSetName         = "Earth..4"
  res1@mpDataResolution      = "FinestResolution"

  res1@mpLimitMode           = "LatLon"
  res1@mpFillOn              = False
  res1@mpCenterLonF          = 0.
  res1@mpMinLonF             = MinLon
  res1@mpMaxLonF             = MaxLon
  res1@mpMinLatF             = MinLat
  res1@mpMaxLatF             = MaxLat

  res1@lbOrientation         = "vertical"
  res1@lbLabelFont           = "helvetica"
  res1@lbLabelAlignment      = "BoxCenters"
  res1@lbLabelStrings        = lblabels
  res1@lbLabelFontHeightF    = 0.009
  res1@lbLabelAutoStride     = False
  res1@lbLabelStride         = CLab
  res1@lbLabelBarOn          = False

  res1@tmYLLabelFontHeightF  = 0.011
  res1@tmXBLabelFontHeightF  = 0.011
  res1@tiXAxisFontHeightF    = 0.011
  res1@tiYAxisFontHeightF    = 0.011
  res1@tiXAxisFont           = "helvetica-Bold" 
  res1@tiYAxisFont           = "helvetica-Bold" 
  res1@tmYLLabelFont         = "helvetica"
  res1@tmXBLabelFont         = "helvetica"
  res1@tmXBLabelStride       = XLab
  res1@tmYLLabelStride       = YLab

  res1@tmXBLabelsOn          = False
  res1@tmYLLabelsOn          = False
  res1@tmXBOn                = False
  res1@tmXTOn                = False
  res1@tmYLOn                = False
  res1@tmYROn                = False

  res1@gsnAddCyclic          = False
  res1@gsnSpreadColors       = True
  res1@gsnSpreadColorStart   =  2
  res1@gsnSpreadColorEnd     = 200

  res1@gsnStringFontHeightF  = 0.011
  res1@tiMainFontHeightF     = 0.011
  res1@gsnStringFont         = "helvetica-bold"
  res1@tiMainFont            = "helvetica-bold"

  res1@vpWidthF              = 0.50
  res1@vpHeightF             = 0.25
  res1@vpYF                  = 0.80

  plot = gsn_csm_contour_map (wks,AnualObs,res1)

  getvalues plot
    "vpHeightF" : vph
    "vpWidthF"  : vpw
  end getvalues

  nboxes = dimsizes(lblabels)

  lbres                    = True
  lbres@lbAutoManage       = True
  lbres@lbFillBackground   = 0
  lbres@lbPerimFill        = "SolidFill"
  lbres@vpWidthF           = 0.09 * vpw
  lbres@vpHeightF          = 0.7 * vph
  lbres@lbBoxMajorExtentF  = 0.8
  lbres@lbFillColors       = colors
  lbres@lbMonoFillPattern  = True
  lbres@lbLabelFontHeightF = 0.18
  lbres@lbLabelJust        = "CenterLeft"
;  lbres@lbPerimOn          = False

  lbid = gsn_create_labelbar(wks,nboxes,lblabels,lbres)

  amres                  = True
  amres@amJust           = "BottomCenter"
  amres@amParallelPosF   =-0.45
  amres@amOrthogonalPosF = 0.47
  annoid = gsn_add_annotation(plot,lbid,amres)

  draw  (plot)

; ---------------   write text --------------------------

  res_text                    = True
  res_text@txFontHeightF      = 0.018
  res_text@txFont             = "helvetica-bold"
  res_text@txJust             = "CenterCenter"

  res_lines                   = True
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 2.
  res_text@txFontColor        = "dark green"
  res_lines@gsLineColor       = "dark green"

  res_text@txFontHeightF      = 0.009
  res_text@txJust             = "CenterLeft"

  res_text@txFontColor        = "foreground"
  gsn_text(wks,plot, titles, (MinLon+MaxLon)/2+5.0, MinLat+5.0,res_text)

  res_text@txFontColor        = "red"

  if (isatt(titles, "SubTitle")) then
     gsn_text(wks,plot, titles@SubTitle, (MinLon+MaxLon)/2+5.0, MinLat+5.0,res_text)
  end if

  res_text@txJust             = "CenterCenter"
  res_text@txFontHeightF      = 0.010

  if (str_upper(SiteID@NAME).eq."GLOBAL") then
     gsn_text(wks,plot, ShortName, clon, clat,res_text)
  end if

  if (str_upper(SiteID@NAME).eq."SITE") then
     gsn_text(wks,plot,"~F37~R",latlon(1,:), latlon(0,:),res_text) 
  end if

  if (str_upper(SiteID@NAME).eq."REGION") then
     do ns =0, nsit-1
           xxx = (/latlon(1,ns),latlon(1,ns)/)
           yyy = (/latlon(0,ns),latlon(2,ns)/)
        gsn_polyline(wks,plot,xxx,yyy,res_lines)
           xxx = (/latlon(3,ns),latlon(3,ns)/)
           yyy = (/latlon(0,ns),latlon(2,ns)/)
        gsn_polyline(wks,plot,xxx,yyy,res_lines)
           xxx = (/latlon(1,ns),latlon(3,ns)/)
           yyy = (/latlon(0,ns),latlon(0,ns)/)
        gsn_polyline(wks,plot,xxx,yyy,res_lines)
           xxx = (/latlon(1,ns),latlon(3,ns)/)
           yyy = (/latlon(2,ns),latlon(2,ns)/)
        gsn_polyline(wks,plot,xxx,yyy,res_lines)
     end do
        delete(xxx)
        delete(yyy)
  end if

  frame(wks)

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Draw_Map_Site_Check (PlotFileName:string, AnualObs: float, slat:float, slon:float, titles:string, \
                         cnlevels:float, lblabels:string, ShortName:string, clon:float, clat:float, MinLon:float, \
                         MaxLon:float, MinLat:float, MaxLat:float, latlon:float, SiteID:integer)

begin

  PlotType = getenv("PLOTTYPE")
  PlotType = str_lower(str_squeeze(PlotType))

  nlevels =dimsizes(cnlevels)

  print(PlotFileName)

  wks = gsn_open_wks(PlotType, PlotFileName)

  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

  colors                     = floattoint(fspan(2, 200, nlevels+1))

;  --------   set  res1 ------------
  res1                       = True
  res1@gsnDraw               = False 
  res1@gsnFrame              = False

  res1@mpDataBaseVersion     = "Ncarg4_1"
  res1@mpDataSetName         = "Earth..4"
  res1@mpDataResolution      = "FinestResolution"

  res1@mpLimitMode           = "LatLon"
  res1@mpFillOn              = False
  res1@mpCenterLonF          = 0.
  res1@mpMinLonF             = MinLon
  res1@mpMaxLonF             = MaxLon
  res1@mpMinLatF             = MinLat
  res1@mpMaxLatF             = MaxLat

  res1@tmYLLabelFontHeightF  = 0.011
  res1@tmXBLabelFontHeightF  = 0.011
  res1@tiXAxisFontHeightF    = 0.011
  res1@tiYAxisFontHeightF    = 0.011
  res1@tiXAxisFont           = "helvetica-Bold" 
  res1@tiYAxisFont           = "helvetica-Bold" 
  res1@tmYLLabelFont         = "helvetica"
  res1@tmXBLabelFont         = "helvetica"

  res1@gsnAddCyclic          = False
  res1@gsnStringFontHeightF  = 0.011
  res1@tiMainFontHeightF     = 0.011
  res1@gsnStringFont         = "helvetica-bold"
  res1@tiMainFont            = "helvetica-bold"

  res1@tmXBLabelsOn          = False
  res1@tmYLLabelsOn          = False
  res1@tmXBOn                = False
  res1@tmXTOn                = False
  res1@tmYLOn                = False
  res1@tmYROn                = False

  res1@vpWidthF              = 0.50
  res1@vpHeightF             = 0.25
  res1@vpYF                  = 0.80

  plot = gsn_csm_map (wks,res1)

  mkres = True

  dum_fill                   = new(nlevels+1,graphic)
  dum_hollow                 = new(nlevels+1,graphic)

  mkres@gsMarkerThicknessF   = 1.0 

  sizes                      = fspan(0,15,nlevels)/1000.

  ii = ind(AnualObs.lt.cnlevels(0))
  if (dimsizes(ii).ge.2 .or. .not.ismissing(ii)) then
     mkres@gsMarkerIndex = 16 
     mkres@gsMarkerSizeF = 0.0075
     mkres@gsMarkerColor = colors(0)

     dum_fill(0) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)

     ;mkres@gsMarkerIndex = 4 
     ;mkres@gsMarkerColor = 1
     ;dum_hollow(0) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)
  end if
  delete(ii)

  do i=1,nlevels-2
    ii = ind(AnualObs.ge.cnlevels(i) .and. AnualObs.lt.cnlevels(i+1))
    if (dimsizes(ii).ge.2 .or. .not.ismissing(ii)) then
    
       mkres@gsMarkerIndex = 16 
       mkres@gsMarkerSizeF = 0.006
       mkres@gsMarkerColor = colors(i+1)

       dum_fill(i+1) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)

       ;mkres@gsMarkerIndex = 4           ; Hollow dots
       ;mkres@gsMarkerColor = 1
       ;dum_hollow(i+1) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)
    end if
    delete(ii)
  end do

  ii = ind(AnualObs.ge.cnlevels(nlevels-1))
  if (dimsizes(ii).ge.2 .or. .not.ismissing(ii)) then
     mkres@gsMarkerIndex = 16 
     mkres@gsMarkerSizeF = 0.006
     mkres@gsMarkerColor = colors(nlevels)

     dum_fill(nlevels) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)

     ;mkres@gsMarkerIndex = 4 
     ;mkres@gsMarkerColor = 1
     ;dum_hollow(nlevels) = gsn_add_polymarker(wks,plot,slon(ii),slat(ii),mkres)
  end if
  delete(ii)

  getvalues plot
    "vpHeightF" : vph
    "vpWidthF"  : vpw
  end getvalues

  nboxes = dimsizes(lblabels)

  lbres                    = True
  lbres@lbAutoManage       = True
  lbres@lbFillBackground   = 0
  lbres@lbPerimFill        = "SolidFill"
  lbres@vpWidthF           = 0.09 * vpw
  lbres@vpHeightF          = 0.70 * vph
  lbres@lbBoxMajorExtentF  = 0.80
  lbres@lbFillColors       = colors(0:nlevels-1)
  lbres@lbMonoFillPattern  = True
  lbres@lbLabelFontHeightF = 0.18
  lbres@lbLabelJust        = "CenterLeft"
;  lbres@lbPerimOn          = False

  lbid = gsn_create_labelbar(wks,nboxes,lblabels,lbres)

  amres                  = True
  amres@amJust           = "BottomCenter"
  amres@amParallelPosF   =-0.45
  amres@amOrthogonalPosF = 0.47
  annoid = gsn_add_annotation(plot,lbid,amres)

  draw  (plot)

; ---------------   write text --------------------------

  res_text                    = True
  res_text@txFontHeightF      = 0.018
  res_text@txFont             = "helvetica-bold"
  res_text@txJust             = "CenterCenter"
  
  res_lines                   = True
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 2.
  res_text@txFontColor        = "dark green"
  res_lines@gsLineColor       = "dark green"
  
  res_text@txFontHeightF      = 0.009
  res_text@txJust             = "CenterLeft"
  
  res_text@txFontColor        = "foreground"
  gsn_text(wks,plot, titles, (MinLon+MaxLon)/2+5.0, MinLat+5.0,res_text)
  
  if (str_upper(SiteID@NAME).eq."GLOBAL") then
     gsn_text(wks,plot, ShortName, clon, clat,res_text)
  end if

  if (str_upper(SiteID@NAME).eq."SITE") then
     gsn_text(wks,plot,"~F37~R",latlon(1,:), latlon(0,:),res_text) 
  else if (str_upper(SiteID@NAME).eq."REGION") then
     do ns =0, nsit-1
           xxx = (/latlon(1,ns),latlon(1,ns)/)
           yyy = (/latlon(0,ns),latlon(2,ns)/)
        gsn_polyline(wks,plot,xxx,yyy,res_lines)
           xxx = (/latlon(3,ns),latlon(3,ns)/)
           yyy = (/latlon(0,ns),latlon(2,ns)/)
        gsn_polyline(wks,plot,xxx,yyy,res_lines)
           xxx = (/latlon(1,ns),latlon(3,ns)/)
           yyy = (/latlon(0,ns),latlon(0,ns)/)
        gsn_polyline(wks,plot,xxx,yyy,res_lines)
           xxx = (/latlon(1,ns),latlon(3,ns)/)
           yyy = (/latlon(2,ns),latlon(2,ns)/)
        gsn_polyline(wks,plot,xxx,yyy,res_lines)
     end do
        delete(xxx)
        delete(yyy)
  end if
  end if

  frame(wks)

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Draw_TS_Check (PlotFileName:string, tta: float, tts:float, infos:string)

begin

  PlotType = getenv("PLOTTYPE")
  PlotType = str_lower(str_squeeze(PlotType))

  print(PlotFileName)

  ndim = dimsizes(tta)

  nmod = ndim(0) - 1

  delete(ndim)

  ;+++ switch Benchmark and MeanModel to the last +++

  temp1 = tta
  temp2 = tts

  tta(0:nmod-2,:) = temp1(2:nmod,:)
  tta(nmod-1,:)   = temp1(1,:)
  tta(nmod,:)     = temp1(0,:)

  tts(0:nmod-2,:) = temp2(2:nmod,:)
  tts(nmod-1,:)   = temp2(1,:)
  tts(nmod,:)     = temp2(0,:)

  delete(temp1)
  delete(temp2)

  wks = gsn_open_wks(PlotType, PlotFileName)

  gsn_define_colormap(wks,"default")

;  --------   set  res2 ------------

  res2                        = True
  res2@gsnDraw                = False
  res2@gsnFrame               = False

  res2@tmYRLabelFont          = "helvetica"
  res2@tmYLLabelFont          = "helvetica"
  res2@tmXBLabelFont          = "helvetica"
  res2@tmYRLabelFontHeightF   = 0.011
  res2@tmYLLabelFontHeightF   = 0.011
  res2@tmXBLabelFontHeightF   = 0.011
  res2@tiXAxisFont            = "helvetica-Bold" 
  res2@tiYAxisFont            = "helvetica-Bold" 
  res2@tiXAxisFontHeightF     = 0.011
  res2@tiYAxisFontHeightF     = 0.011
  res2@tiMainFont             = "helvetica-Bold" 
  res2@gsnStringFontHeightF   = 0.011
  res2@gsnStringFont          = "helvetica-Bold"

  ;res2@tmXBPrecision         = 2
  ;res2@tmXBAutoPrecision     = False

  res2@gsnCenterString       = tta@Header
  res2@tiYAxisString         = tta@YTitle

  colors                     = floattoint(fspan(1, nmod+1, nmod+1))
  patterns = new((/nmod+1/), integer)
  thicks   = new((/nmod+1/), integer)
  linelabs = new((/nmod+1/), string)

  ;+++ switch Benchmark and MeanModel to the last +++
  color1 = colors

  colors(0:nmod-2) = color1(2:nmod)
  colors(nmod-1)   = color1(1)
  colors(nmod)     = color1(0)

  delete(color1)

  patterns = 0
  thicks   = 2
  linelabs = ""

  res2@xyLabelMode           = "Custom" 
  res2@xyLineColors          = colors
  res2@xyDashPatterns        = patterns
  res2@xyLineLabelFontColors = colors
  res2@xyLineThicknesses     = thicks
  res2@xyExplicitLabels      = linelabs

  res2@trXMinF               = 1
  res2@trXMaxF               = 12

  res2@tmXBMode              = "Explicit"
  res2@tmXBValues            = (/1,2,3,4,5,6,7,8,9,10,11,12/)
  res2@tmXBLabels            = (/"J","F","M","A","M","J","J","A","S","O","N","D"/)

  res2@vpXF                  = 0.15
  res2@vpYF                  = 0.90
  res2@vpHeightF             = 0.30
  res2@vpWidthF              = 0.30

  plot1 = gsn_csm_xy(wks,tta&time,tta,res2)
  draw (plot1)

;  --------   set  res3 ------------
  res3                        = True
  res3@gsnDraw                = False
  res3@gsnFrame               = False

  res3@tmYRLabelFont          = "helvetica"
  res3@tmYLLabelFont          = "helvetica"
  res3@tmXBLabelFont          = "helvetica"
  res3@tmYRLabelFontHeightF   = 0.011
  res3@tmYLLabelFontHeightF   = 0.011
  res3@tmXBLabelFontHeightF   = 0.011
  res3@tiXAxisFont            = "helvetica-Bold" 
  res3@tiYAxisFont            = "helvetica-Bold" 
  res3@tiXAxisFontHeightF     = 0.011
  res3@tiYAxisFontHeightF     = 0.011
  res3@tiMainFont             = "helvetica-Bold" 
  res3@gsnStringFontHeightF   = 0.011
  res3@gsnStringFont          = "helvetica-Bold"

  res3@xyLabelMode           = "Custom" 
  res3@xyLineColors          = colors
  res3@xyDashPatterns        = patterns
  res3@xyLineLabelFontColors = colors
  res3@xyLineThicknesses     = thicks
  res3@xyExplicitLabels      = linelabs

  res3@gsnCenterString       = tts@Header
  res3@tiYAxisString         = tts@YTitle

  res3@tmXBMode              = "Automatic"
  res3@tmXBAutoPrecision     = False
  ;res3@tmXBMode              = "Manual"
  ;res3@tmXBPrecision         = 4

  if (dimsizes(tts&time)/12.le.3) then
     res3@tmXBLabelStride     = 2
  end if

  res3@vpXF                  = 0.15
  res3@vpYF                  = 0.53
  res3@vpHeightF             = 0.20
  res3@vpWidthF              = 0.80

  res3@trXMinF               = min(tts&time)
  res3@trXMaxF               = max(tts&time)

  plot2 = gsn_csm_xy(wks,tts&time,tts,res3)
  draw (plot2)

  delete(colors)

  res_text                    = True  
  res_text@txFontHeightF      = 0.012
  res_text@txFont             = "helvetica-bold"
  res_text@txJust             = "CenterRight" 

  res_lines                   = True 

  xx0 = (/0.65,0.70/)
  yy0 = (/0.85, 0.85/)
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 2.  

  colors                      = floattoint(fspan(1, nmod+1, nmod+1))

  x00 = 0.90
  y00 = 0.90

  yd0 = 0.3/int2flt(nmod+3)

  res_text@txFontColor        = colors(0)
  gsn_text_ndc(wks,infos(0),x00,y00,res_text)

  y00 = y00 - yd0

  do nv =1, nmod+1
     res_text@txFontColor        = colors(nv-1)
     gsn_text_ndc(wks,infos(nv),x00,y00,res_text)
     y00 = y00 - yd0
  end do

  frame(wks)

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Draw_Function_Bar (PlotFileName:string, xxx:float, yyy:float, Titles:string, XTitle:string, YTitle:string, \
                    XLab:integer, YLab:integer, CLab:integer, MinLon:float, MaxLon:float, MinLat:float, MaxLat:float)

begin

  PlotType = getenv("PLOTTYPE")
  PlotType = str_lower(str_squeeze(PlotType))

  print(PlotFileName)

  wks = gsn_open_wks(PlotType, PlotFileName)

  gsn_define_colormap(wks,"default")

;  --------   set  res1 ------------
  res1                       = True
  res1@gsnDraw               = False
  res1@gsnFrame              = False

  res1@xyMarkLineModes       = "Lines"

  res1@xyLabelMode            = "Custom"
  res1@xyDashPatterns         = (/0,0,0/)
  res1@xyLineLabelFontColors  = (/1,1,1/)
  res1@xyLineThicknesses      = (/1,1,1/)
  res1@xyLineColors           = (/2,2,2/)
  res1@xyExplicitLabels       = (/"","",""/)

  res1@tiXAxisFont           = "helvetica-Bold"
  res1@tiYAxisFont           = "helvetica-Bold"
  res1@tiXAxisFontHeightF    = 0.011
  res1@tiYAxisFontHeightF    = 0.011
  res1@tmXBLabelFont         = "helvetica"
  res1@tmYLLabelFont         = "helvetica"
  res1@tmXBLabelFontHeightF  = 0.011
  res1@tmYLLabelFontHeightF  = 0.011
  res1@tmXBLabelStride       = 1
  res1@tmYLLabelStride       = 1
  res1@tmXBLabelsOn          = True

  res1@gsnStringFontHeightF  =0.011
  res1@gsnStringFont         ="helvetica-bold"

  res1@tiMainFont            ="helvetica-bold"
  res1@tiMainFontHeightF     =0.011

  res1@tiMainFont            = "helvetica-Bold"

  res1@gsnXYBarChart         = True
  res1@gsnXYBarChartBarWidth = 100

  res1@gsnYRefLine           = 0.

  res1@gsnAboveYRefLineColor       = "red"
  res1@gsnBelowYRefLineColor       = "blue"
;  res1@gsnAboveYRefLineBarPatterns = (/1,3,4/)
  res1@gsnAboveYRefLineBarPatterns = (/4,4,4/)
  res1@gsnBelowYRefLineBarPatterns = (/14,14,14/)

  res1@gsnCenterString       = Titles
  res1@tiXAxisString         = XTitle
  res1@tiYAxisString         = YTitle

  res1@vpXF                  = 0.30
  res1@vpYF                  = 0.90
  res1@vpWidthF              = 0.40
  res1@vpHeightF             = 0.40

  res1@trYMinF               = MinLat
  res1@trYMaxF               = MaxLat
  res1@trXMinF               = MinLon
  res1@trXMaxF               = MaxLon

  plot1  = gsn_csm_xy (wks,xxx,yyy,res1)
  draw(plot1)

  frame(wks)

end 

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Draw_Bar (PlotFileName:string, ModelNameList:string, score:float, ts1:float, ts2:float, \
                    titles:string, XLab:integer, YLab:integer, CLab:integer, MinLon:float, MaxLon:float, \
                    MinLat:float, MaxLat:float, Key:string)

begin

  PlotType = getenv("PLOTTYPE")
  PlotType = str_lower(str_squeeze(PlotType))

  nmod = dimsizes(ModelNameList) - 1

  print(PlotFileName)

  wks = gsn_open_wks(PlotType, PlotFileName)

  gsn_define_colormap(wks,"default")

;  --------   set  res1 ------------

  res1                        = True
  res1@gsnDraw                = False
  res1@gsnFrame               = False

  res1@tmYRLabelFont          = "helvetica"
  res1@tmYLLabelFont          = "helvetica"
  res1@tmXBLabelFont          = "helvetica"
  res1@tmYRLabelFontHeightF   = 0.011
  res1@tmYLLabelFontHeightF   = 0.011
  res1@tmXBLabelFontHeightF   = 0.011
  res1@tiXAxisFont            = "helvetica-Bold" 
  res1@tiYAxisFont            = "helvetica-Bold" 
  res1@tiXAxisFontHeightF     = 0.011
  res1@tiYAxisFontHeightF     = 0.011
  res1@tiMainFont             = "helvetica-Bold" 
  res1@gsnStringFontHeightF   = 0.011
  res1@gsnStringFont          = "helvetica-Bold"

  res1@tiYAxisString          = titles

  res1@tmXBMode              = "Explicit"
  res1@tmXBValues            = floattoint(fspan(1, nmod+1, nmod+1))
  res1@tmXBLabels            = ModelNameList
  res1@tmXBLabelJust         = "CenterRight"
  res1@tmXBLabelAngleF       = 45.

  ;res1@tmXBPrecision         = 2
  ;res1@tmXBAutoPrecision     = False

  ;titles                     = header
  ;res1@gsnCenterString         = titles

  res1@gsnXYBarChart         = True
  res1@gsnXYBarChartBarWidth = 0.5

  res1@gsnYRefLine           = 0.

  res1@gsnAboveYRefLineColor       = "red"
  res1@gsnBelowYRefLineColor       = "blue"
;  res1@gsnAboveYRefLineBarPatterns = (/4,4,4/)
;  res1@gsnBelowYRefLineBarPatterns = (/14,14,14/)

  res1@trYMinF               = MinLat
  res1@trYMaxF               = MaxLat
  res1@trXMinF               = MinLon
  res1@trXMaxF               = MaxLon

; ++++++++++++++++ Draw Plot 1 +++++++++++

  res1@vpXF                  = 0.25
  res1@vpYF                  = 0.97
  res1@vpHeightF             = 0.20
  res1@vpWidthF              = 0.50

  plot1 = gsn_csm_xy(wks,score&mod,score,res1)
  draw (plot1)

if (str_lower(Key).eq."line") then

  StartYear = min(ts1&time)
  EndYear   = max(ts1&time)

  titles0 = titles

  if (str_lower(ModelNameList(0)).eq."mauna.loa") then
     titles0 = str_sub_str(titles0, "annual", "")
     titles0 = str_sub_str(titles0, "mean", "")
     titles0 = str_sub_str(titles0, "Annual", "")
     titles0 = str_sub_str(titles0, "Mean", "")
     titles0 = str_sub_str(titles0, "for", "")
  end if

; ++++++++++++++++ Draw Plot 2 +++++++++++
  res2                        = True
  res2@gsnDraw                = False
  res2@gsnFrame               = False
  res2@xyMarkLineModes        = "Lines"
  res2@gsnXYBarChart          = False

  res2@tmYRLabelFont          = "helvetica"
  res2@tmYLLabelFont          = "helvetica"
  res2@tmXBLabelFont          = "helvetica"
  res2@tmYRLabelFontHeightF   = 0.011
  res2@tmYLLabelFontHeightF   = 0.011
  res2@tmXBLabelFontHeightF   = 0.011
  res2@tiXAxisFont            = "helvetica-Bold" 
  res2@tiYAxisFont            = "helvetica-Bold" 
  res2@tiXAxisFontHeightF     = 0.011

  res2@tmXBMode              = "Automatic"

  colors                     = floattoint(fspan(1, nmod+1, nmod+1))
  patterns = new((/nmod+1/), integer)
  thicks   = new((/nmod+1/), integer)
  linelabs = new((/nmod+1/), string)

  patterns = 0
  thicks   = 2
  linelabs = ""

  res2@xyLabelMode           = "Custom" 
  res2@xyLineColors          = colors
  res2@xyDashPatterns        = patterns
  res2@xyLineLabelFontColors = colors
  res2@xyLineThicknesses     = thicks
  res2@xyExplicitLabels      = linelabs

  res2@vpXF                  = 0.25
  res2@vpYF                  = 0.62
  res2@vpHeightF             = 0.20
  res2@vpWidthF              = 0.40

  res2@trXMinF               = StartYear
  res2@trXMaxF               = EndYear

  res2@tmXBMode              = "Automatic"
  res2@tmXBAutoPrecision     = False
  ;res2@tmXBPrecision         = 4

  res2@tiXAxisString         = ""
  res2@tiYAxisString         = titles0
  res2@gsnCenterString       = ""

  plot2 = gsn_csm_xy(wks,ts1&time,ts1,res2)
  draw (plot2)

  delete(colors)

  res_text                    = True  
  res_text@txFontHeightF      = 0.012
  res_text@txFont             = "helvetica-bold"
  res_text@txJust             = "CenterRight" 

  res_lines                   = True 

  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 2.  

  colors                      = floattoint(fspan(1, nmod+1, nmod+1))

  res_text@txJust             = "CenterLeft" 
  res_text@txFontHeightF      = 0.01

  xx0 = (/0.67, 0.67/)
  yy0 = (/0.57, 0.57/)

  yyd = 0.3/int2flt(nmod+1)

     ij = 0
  do n1=1, nmod+1
     xx1 = xx0(0)
     yy1 = yy0(0) - yyd*int2flt(n1-1)
     res_lines@gsLineColor       = colors(ij)
     res_text@txFontColor        = colors(ij)
     gsn_text_ndc(wks,ModelNameList(ij),xx1,yy1,res_text)
     ij=ij+1
  end do


  StartYear = floattoint(min(ts2&time))
  EndYear   = floattoint(max(ts2&time))

  titles1 = titles

  if (any(str_lower(ModelNameList(0)).eq.(/"gcp","hoffman"/))) then
     titles1 = str_sub_str(titles1, "Annual", "Cumulative")
     titles1 = str_sub_str(titles1, "annual", "Cumulative")
     titles1 = str_sub_str(titles1, "/yr", "")
  end if

  ;if (str_lower(ModelNameList(0)).eq."mauna.loa") then
  ;   titles1 = titles0
  ;end if

  if (str_lower(ModelNameList(0)).eq."mauna.loa") then
     titles1 = str_sub_str(titles1, "annual", "")
     titles1 = str_sub_str(titles1, "Annual", "")
     titles1 = str_sub_str(titles1, "mean", "")
     titles1 = str_sub_str(titles1, "Mean", "")
     titles1 = str_sub_str(titles1, "for", "")
     titles1 = titles1 + " Refers to " + sprinti("%0.4i",floattoint(StartYear))
  end if

; ++++++++++++++++ Draw Plot 3 +++++++++++
  res3                        = True
  res3@gsnDraw                = False
  res3@gsnFrame               = False
  res3@xyMarkLineModes       = "Lines"
  res3@gsnXYBarChart         = False

  res3@tmYRLabelFont          = "helvetica"
  res3@tmYLLabelFont          = "helvetica"
  res3@tmXBLabelFont          = "helvetica"
  res3@tmYRLabelFontHeightF   = 0.011
  res3@tmYLLabelFontHeightF   = 0.011
  res3@tmXBLabelFontHeightF   = 0.011
  res3@tiXAxisFont            = "helvetica-Bold" 
  res3@tiYAxisFont            = "helvetica-Bold" 
  res3@tiXAxisFontHeightF     = 0.011

  res3@tmXBMode              = "Automatic"

  colors                     = floattoint(fspan(1, nmod+1, nmod+1))
  patterns = new((/nmod+1/), integer)
  thicks   = new((/nmod+1/), integer)
  linelabs = new((/nmod+1/), string)

  patterns = 0
  thicks   = 2
  linelabs = ""

  res3@xyLabelMode           = "Custom" 
  res3@xyLineColors          = colors
  res3@xyDashPatterns        = patterns
  res3@xyLineLabelFontColors = colors
  res3@xyLineThicknesses     = thicks
  res3@xyExplicitLabels      = linelabs

  res3@tiXAxisString         = ""
  res3@tiYAxisString         = titles1

  res3@gsnCenterString       = ""

  res3@vpXF                  = 0.25
  res3@vpYF                  = 0.37
  res3@vpHeightF             = 0.20
  res3@vpWidthF              = 0.40

  ;if (any(str_lower(ModelNameList(0)).eq.(/"hoffman", "gcp"/))) then
      res3@trXMinF               = StartYear
      res3@trXMaxF               = EndYear
      res3@tmXBMode              = "Automatic"
      res3@tmXBAutoPrecision     = False
      ;res3@tmXBPrecision         = 4
  ;end if

  ;if (str_lower(ModelNameList(0)).eq."mauna.loa") then
  ;   res3@trXMinF               = 1
  ;   res3@trXMaxF               = 12
  ;   res3@tmXBMode              = "Explicit"
  ;   res3@tmXBValues            = (/1,2,3,4,5,6,7,8,9,10,11,12/)
  ;   res3@tmXBLabels            = (/"J","F","M","A","M","J","J","A","S","O","N","D"/)
  ;end if

  plot3 = gsn_csm_xy(wks,ts2&time,ts2,res3)
  draw (plot3)

  delete(colors)
end if

  frame(wks)

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Draw_Score (PlotFileName:string, score: float, ModelNameList:string, titles:string)

begin

  PlotType = getenv("PLOTTYPE")
  PlotType = str_lower(str_squeeze(PlotType))

  nmod           = dimsizes(ModelNameList) - 1
  colors         = floattoint(fspan(1, nmod+1, nmod+1))

  scores         = score
  ModelNameLists = ModelNameList

  score0         = score(1:nmod)
  color0         = colors(1:nmod)
  ModelNameList0 = ModelNameList(1:nmod)

  i50            = dim_pqsort(score0, 2)
  color0         = color0(i50)
  ModelNameList0 = ModelNameList0(i50)

  scores(1:nmod)         =  score0
  colors(1:nmod)         =  color0
  ModelNameLists(1:nmod) =  ModelNameList0

  delete(color0)
  delete(score0)
  delete( ModelNameList0)

  scores@_FillValue = -999

  ts = fspan(1, nmod+1, nmod+1)
  ts = 0.0

  ts = where(ismissing(scores), -999, ts)

  ts@_FillValue = -999

  ts!0="mod"
  ts&mod=fspan(1, nmod+1, nmod+1)

  wks = gsn_open_wks(PlotType, PlotFileName)

  gsn_define_colormap(wks,"default")

;  --------   set  resource ------------
  ressource                        = True
  ressource@gsnDraw                = False
  ressource@gsnFrame               = False

  ressource@tmYRLabelFont          = "helvetica"
  ressource@tmYLLabelFont          = "helvetica"
  ressource@tmXBLabelFont          = "helvetica"
  ressource@tmYRLabelFontHeightF   = 0.011
  ressource@tmYLLabelFontHeightF   = 0.011
  ressource@tmXBLabelFontHeightF   = 0.011
  ressource@tiXAxisFont            = "helvetica-Bold" 
  ressource@tiYAxisFont            = "helvetica-Bold" 
  ressource@tiXAxisFontHeightF     = 0.011
  ressource@tiYAxisFontHeightF     = 0.011
  ressource@tmYLOn                 = False
  ressource@tmYROn                 = False
  ressource@tmXBLabelsOn           = False
  ressource@tiMainFont             = "helvetica-Bold" 
  ressource@gsnStringFontHeightF   = 0.011
  ressource@gsnStringFont          = "helvetica-Bold"
  ressource@gsnCenterString        = ""

  ;ressource@tmXBMode               = "Explicit"
  ;ressource@tmXBValues             = ts&mod
  ;ressource@tmXBLabels             = ModelNameList
  ;ressource@tmXBLabelJust          = "BottomRight"
  ;ressource@tmXBLabelAngleF        = 45
  ;ressource@tmXBLabelFontColor     = colors

  sizes = scores
  sizes = where(sizes.le.0, 0.000001, sizes)
  sizes = where(ismissing(sizes), 0.000001, sizes)

  MarkerSizes = 0.04*sizes
  ;MarkerSizes = 0.04
  delete(sizes)

  ressource@xyMarkerSizes          = MarkerSizes
  ressource@xyMonoMarkerColor      = False

  Markers = floattoint(MarkerSizes)
  Markers = 16

  ressource@xyMarkers              = Markers

  ressource@xyMarkerColors        = colors
  ressource@xyLineColors          = colors

  ressource@vpXF                  = 0.10
  ressource@vpYF                  = 0.80
  ressource@vpWidthF              = 0.80
  ressource@vpHeightF             = 0.10

  ressource@trYMinF                =-1.0
  ressource@trYMaxF                = 1.0
  ressource@trXMinF                = 2
  ressource@trXMaxF                = nmod+1

  ressource@xyMarkLineMode         = "Markers"
  ;ressource@xyMarker              = 16

  ressource@gsnCenterString       = titles

  plot = gsn_csm_xy(wks,transpose((/ts&mod,ts&mod/)),transpose((/ts,ts/)),ressource)

  MarkerSizes = 0.005
  ressource@xyMarkerSizes         = MarkerSizes

  colors                          = 0
  ressource@xyMarkerColors        = colors
  ressource@xyLineColors          = colors

  plot1 = gsn_csm_xy(wks,transpose((/ts&mod,ts&mod/)),transpose((/ts,ts/)),ressource)

  overlay(plot,plot1)
  draw (plot)
  delete (colors)

  res_text                    = True  
  res_text@txFontHeightF      = 0.011
  res_text@txFont             = "helvetica-bold"

  res_lines                   = True 
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 1.  

  xx0 = (/1,nmod+1/)
  yy0 = (/0, 0/)
  gsn_polyline(wks,plot,xx0,yy0,res_lines) 

  res_text@txJust             = "CenterRight" 
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 2.
  res_lines@gsLineDashPattern = 2

  res_text@txJust             = "CenterRight"
  res_text@txAngleF           = 45
  res_lines@gsLineDashPattern = 0

  colors                      = floattoint(fspan(1, nmod+1, nmod+1))

  color0                      = colors(1:nmod)
  color0                      = color0(i50)
  colors(1:nmod)              = color0
  delete(color0)

  ;xx0 = (/0.11, 0.11/)
  ;yy0 = (/0.63, 0.63/)
  ;
  ;   ij=0
  ;do n1=1, 4
  ;   xx0 = (/0.13, 0.13/)
  ;   yy0 = (/0.63, 0.63/)
  ;do n2=1, ceil(int2flt(nmod+1)/4.0)
  ;   xx1 = xx0 + 0.20*int2flt(n1-1)
  ;   yy1 = yy0 - 0.02*int2flt(n2-1)
  ;   if (ij.le.(nmod)) then
  ;      res_lines@gsLineColor       = colors(ij)
  ;      res_text@txFontColor        = colors(ij)
  ;      gsn_text_ndc(wks,ModelNameList(ij),xx1(1)+0.01,yy1(0),res_text)
  ;   end if
  ;   ij=ij+1
  ;end do
  ;end do

  xx1                      = fspan(0.1, 0.9, nmod)
  yy1 = xx1
  yy1 = 0.67

  do nd=1, nmod
     res_lines@gsLineColor       = colors(nd)
     res_text@txFontColor        = colors(nd)
     gsn_text_ndc(wks,ModelNameLists(nd),xx1(nd-1),yy1(nd-1),res_text)
  end do

  res_text@txFontThicknessF   = 2.0
  res_text@txFont             = "helvetica-bold"
  res_text@txJust             = "CenterCenter"

  xxx = fspan(0.25, 0.75, 10)
  yyy = xxx
  yyy = 0.54

  res_text@txFontColor        = 1
  res_text@txAngleF           = 0
  res_text@txFontHeightF      = 0.015

  gsn_text_ndc(wks,"Scores ", xxx(5),yyy(5)+0.03,res_text)

  res_text@txFontThicknessF   = 1.0

  do i = 1, 10
     res_text@txFontHeightF      = 0.04*int2flt(i)/10.
     gsn_text_ndc(wks,"~F37~Z~F22~",xxx(i-1),yyy(i-1),res_text)
     res_text@txFontHeightF      = 0.013
     gsn_text_ndc(wks,str_squeeze(sprintf("%6.2f", int2flt(i)/10)),xxx(i-1),yyy(i-1)-0.04,res_text)
  end do

  delete(i50)
  delete(xx0)
  delete(xx1)
  delete(xxx)
  delete(yy0)
  delete(yy1)
  delete(yyy)
  delete(colors)

  delete(scores)
  delete(ModelNameLists)

  frame(wks)

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Draw_Taylor_Diagram (PlotFileName:string, score: float, ratio:float, cc:float, ModelNameList:string, titles:string)

begin

  PlotType = getenv("PLOTTYPE")
  PlotType = str_lower(str_squeeze(PlotType))

  nmod = dimsizes(ModelNameList) - 1

  ts = fspan(1, nmod+1, nmod+1)
  ts = 0.0

  print(PlotFileName)

  wks = gsn_open_wks(PlotType, PlotFileName)

  gsn_define_colormap(wks,"default")

;  --------   set  resource ------------
  ressource                        = True
  ressource@gsnDraw                = False
  ressource@gsnFrame               = False

  ressource@tmYRLabelFont          = "helvetica"
  ressource@tmYLLabelFont          = "helvetica"
  ressource@tmXBLabelFont          = "helvetica"
  ressource@tmYRLabelFontHeightF   = 0.011
  ressource@tmYLLabelFontHeightF   = 0.011
  ressource@tmXBLabelFontHeightF   = 0.011
  ressource@tiXAxisFont            = "helvetica-Bold" 
  ressource@tiYAxisFont            = "helvetica-Bold" 
  ressource@tiXAxisFontHeightF     = 0.011
  ressource@tiYAxisFontHeightF     = 0.011
  ressource@tmYLOn                 = False
  ressource@tmYROn                 = False
  ressource@tiMainFont             = "helvetica-Bold" 
  ressource@gsnStringFontHeightF   = 0.011
  ressource@gsnStringFont          = "helvetica-Bold"
  ressource@gsnCenterString        = ""

  sizes = score
  sizes = where(sizes.le.0, 0.000001, sizes)
  sizes = where(ismissing(sizes), 0.000001, sizes)

  MarkerSizes = 0.04*sizes(1:nmod)
  MarkerSizes = 0.01

  Markers = floattoint(MarkerSizes)
  Markers = 16

  colors                           = floattoint(fspan(2, nmod+1, nmod))

  ressource@vpXF                   = 0.10
  ressource@vpYF                   = 0.95
  ressource@vpWidthF               = 0.60
  ressource@vpHeightF              = 0.60

  ressource@gsnCenterString        = titles

  ressource@caseLabelsFontHeightF  = 0.0
  ressource@varLabelsFontHeightF   = 0.0
  ressource@Colors                 = colors
  ressource@Markers                = Markers
  if (max(ratio).gt.3) then
     ressource@stnRad                 = (/ 0.5, 1.5, 2.0, 2.5, 3.0,3.5,4.0,4.5,5.0/)
  else
     if (max(ratio).gt.1.5) then
        ressource@stnRad                 = (/ 0.5, 1.5, 2.0, 2.5, 3.0/)
     else
        ressource@stnRad                 = (/ 0.25, 0.5, 0.75, 1.0, 1.25, 1.5/)
     end if
  end if
  ressource@ccRays                 = (/ 0.3, 0.6, 0.9 /)
  ressource@centerDiffRMS          = False
  ressource@taylorFrame            = False 
  ressource@taylorDraw             = False

  plot  = taylor_diagram(wks,ratio(1:nmod,:),cc(1:nmod,:),ressource)

  draw (plot)
  delete (colors)

  res_text                    = True  
  res_text@txFontHeightF      = 0.012
  res_text@txFont             = "helvetica-bold"
  res_text@txJust             = "CenterLeft" 

  res_lines                   = True 
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 1.  

  xx0 = (/0.,1./)
  yy0 = (/0.0, 0.0/)
  gsn_polyline(wks,plot,xx0,yy0,res_lines) 

  res_text@txJust             = "CenterLeft" 
  xx0 = (/0.65,0.70/)
  yy0 = (/0.85, 0.85/)
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineColor       = 1.0
  res_text@txFontColor        = 1.0
;  gsn_polyline(wks,plot1,xx0,yy0,res_lines) 
;  gsn_text_ndc(wks,strings(nr-1),0.57,0.85,res_text)
;  gsn_text_ndc(wks,"Surface CO (ppbv)",0.57,0.82,res_text)

  res_lines@gsLineThicknessF  = 2.
  res_lines@gsLineDashPattern = 2

  colors                      = floattoint(fspan(2, nmod+1, nmod))

  xx0 = (/0.11, 0.11/)
  yy0 = (/0.10, 0.10/)

     ij=1
  do n1=1, 4
     xx0 = (/0.13, 0.13/)
     yy0 = (/0.10, 0.10/)
  do n2=1, ceil(int2flt(nmod+1)/4.0)
     xx1 = xx0 + 0.20*int2flt(n1-1)
     yy1 = yy0 - 0.02*int2flt(n2-1)
     if (ij.le.(nmod)) then
        res_lines@gsLineColor       = colors(ij-1)
        res_text@txFontColor        = colors(ij-1)
        gsn_text_ndc(wks,ModelNameList(ij),xx1(1)+0.01,yy1(0),res_text)
     end if
     ij=ij+1
  end do
  end do

;  delete(xx0)
;  delete(xx1)
;  delete(yy0)
;  delete(yy1)
  delete(colors)

  frame(wks)

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Draw_Table_Scores (PlotFileName:string, ModelNameList:string, runIDS:integer, tt_mod:float, cnlevels1:float, \
                             cnlevels2:float, lblabels1:string, lblabels2:string, titles1:string, titles2:string, cLats:float) 

begin

  PlotType = getenv("PLOTTYPE")
  PlotType = str_lower(str_squeeze(PlotType))

  nmod = dimsizes(ModelNameList) - 1

  ts = fspan(1, nmod+1, nmod+1)
  ts = 0.0

  print(PlotFileName)

  opt = True
  opt@pltType = PlotType
  opt@color0  = "dodgerblue"

;  --------   set  resource ------------
  ressource                        = True
  ressource@gsnDraw                = False
  ressource@gsnFrame               = False

  ressource@tmYRLabelFont          = "helvetica"
  ressource@tmYLLabelFont          = "helvetica"
  ressource@tmXBLabelFont          = "helvetica"
  ressource@tmYRLabelFontHeightF   = 0.011
  ressource@tmYLLabelFontHeightF   = 0.011
  ressource@tmXBLabelFontHeightF   = 0.011
  ressource@tiXAxisFont            = "helvetica-Bold" 
  ressource@tiYAxisFont            = "helvetica-Bold" 
  ressource@tiXAxisFontHeightF     = 0.011
  ressource@tiYAxisFontHeightF     = 0.011
  ressource@tmYLOn                 = False
  ressource@tmYROn                 = False
  ressource@tiMainFont             = "helvetica-Bold" 
  ressource@gsnStringFontHeightF   = 0.011
  ressource@gsnStringFont          = "helvetica-Bold"
  ressource@gsnCenterString        = ""

  ;sizes = score
  sizes = 1.0
  ;sizes = where(sizes.le.0, 0.000001, sizes)
  ;sizes = where(ismissing(sizes), 0.000001, sizes)

  ;MarkerSizes = 0.04*sizes(1:nmod)
  MarkerSizes = 0.01

  Markers = floattoint(MarkerSizes)
  Markers = 16

  colors                           = floattoint(fspan(2, nmod+1, nmod))

  ressource@vpXF                   = 0.10
  ressource@vpYF                   = 0.95
  ressource@vpWidthF               = 0.60
  ressource@vpHeightF              = 0.60

  ressource@gsnCenterString        = titles1

  ressource@caseLabelsFontHeightF  = 0.0
  ressource@varLabelsFontHeightF   = 0.0
  ressource@Colors                 = colors
  ressource@Markers                = Markers
;  if (max(ratio).gt.3) then
;     ressource@stnRad                 = (/ 0.5, 1.5, 2.0, 2.5, 3.0,3.5,4.0,4.5,5.0/)
;  else
;     if (max(ratio).gt.1.5) then
;        ressource@stnRad                 = (/ 0.5, 1.5, 2.0, 2.5, 3.0/)
;     else
;        ressource@stnRad                 = (/ 0.25, 0.5, 0.75, 1.0, 1.25, 1.5/)
;     end if
;  end if
;  ressource@ccRays                 = (/ 0.3, 0.6, 0.9 /)
;  ressource@centerDiffRMS          = False
;  ressource@taylorFrame            = False 
;  ressource@taylorDraw             = False

  cases      = (/"Case A"/)	
  nCase      = dimsizes(cases)
  nreg       = dimsizes(cLats)
  nmod       = dimsizes(ModelNameList)
  ;table4     = random_normal( 1.0, 0.25,(/nCase, nreg, nmod/))

  taylor_metrics_table (PlotFileName, ModelNameList, cases, cLats, tt_mod, opt)	

  ;draw (plot)
  delete (colors)

  res_text                    = True  
  res_text@txFontHeightF      = 0.012
  res_text@txFont             = "helvetica-bold"
  res_text@txJust             = "CenterLeft" 

  res_lines                   = True 
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 1.  

  xx0 = (/0.,1./)
  yy0 = (/0.0, 0.0/)
  ;gsn_polyline(wks,plot,xx0,yy0,res_lines) 

  res_text@txJust             = "CenterLeft" 
  xx0 = (/0.65,0.70/)
  yy0 = (/0.85, 0.85/)
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineColor       = 1.0
  res_text@txFontColor        = 1.0
;  gsn_polyline(wks,plot1,xx0,yy0,res_lines) 
;  gsn_text_ndc(wks,strings(nr-1),0.57,0.85,res_text)
;  gsn_text_ndc(wks,"Surface CO (ppbv)",0.57,0.82,res_text)

  res_lines@gsLineThicknessF  = 2.
  res_lines@gsLineDashPattern = 2

  colors                      = floattoint(fspan(2, nmod+1, nmod))

  xx0 = (/0.11, 0.11/)
  yy0 = (/0.10, 0.10/)

     ij=1
  do n1=1, 4
     xx0 = (/0.13, 0.13/)
     yy0 = (/0.10, 0.10/)
  do n2=1, ceil(int2flt(nmod+1)/4.0)
     xx1 = xx0 + 0.20*int2flt(n1-1)
     yy1 = yy0 - 0.02*int2flt(n2-1)
     if (ij.le.(nmod)) then
        res_lines@gsLineColor       = colors(ij-1)
        res_text@txFontColor        = colors(ij-1)
        ;gsn_text_ndc(wks,ModelNameList(ij),xx1(1)+0.01,yy1(0),res_text)
     end if
     ij=ij+1
  end do
  end do

;  delete(xx0)
;  delete(xx1)
;  delete(yy0)
;  delete(yy1)
  delete(colors)

;  frame(wks)

end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
