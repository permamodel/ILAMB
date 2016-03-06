load "/usr/local/ncarg/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "/usr/local/ncarg/lib/ncarg/nclex/gsun/gsn_csm.ncl"
load "/usr/local/ncarg/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/usr/local/ncarg/lib/ncarg/nclscripts/csm/shea_util.ncl"

external GAMAP "/usr/local/functions/fortran/read_bpch_4D.so"

begin

nvar=2
nreg=9
nyer=13
nmon=12
nlon=72
nlat=46
nlev=47
ntot=nyer*nmon

nday=(/31,29,31,30,31,30,31,31,30,31,30,31/)

slat=fspan(-90.,90.,nlat)
slon=fspan(-180.,175.,nlon)

strings=new((/nreg/), string)
strings(0) = "90S-70S"
strings(1) = "70S-50S"
strings(2) = "50S-30S"
strings(3) = "30S-10S"
strings(4) = "10S-10N"
strings(5) = "10N-30N"
strings(6) = "30N-50N"
strings(7) = "50N-70N"
strings(8) = "70N-90N"

;+++++++++++++++++++++++ read NOAA stations information ++++++++++++
miss_sta=(/"LEF"/)

obsdir = "/data_d/datasets/observedCO2/noaa_gmd/"

filename = obsdir + "station.noaa.txt"
print(filename)

fdata = asciiread(filename,-1,"string")
print(fdata)
cdata=stringtochar(fdata)
delete(fdata)

dist1   = charactertostring(cdata(3:,0:3))
stat1   = charactertostring(cdata(3:,8:13))
lats1   = stringtofloat(charactertostring(cdata(3:,56:61)))
lons1   = stringtofloat(charactertostring(cdata(3:,72:78)))
alts1   = stringtofloat(charactertostring(cdata(3:,89:92)))

i50   = ind(dist1.eq."NOAA")
dist2  = dist1(i50)
sta2  = stat1(i50)
lats2  = lats1(i50)
lons2  = lons1(i50)
alts2  = alts1(i50)
print(dist2)
print(sta2)
delete(cdata)
cdata=stringtochar(sta2)
print(cdata)
delete(i50)

stat02   = charactertostring(cdata(:,0:2))
print(stat02)

i50   = ind(stat02.ne.miss_sta(0))
dist  = dist2(i50)
stat  = sta2(i50)
lats  = lats2(i50)
lons  = lons2(i50)
alts  = alts2(i50)
stat0 = stat02(i50)

ndim=dimsizes(lats)
print(ndim)

delete(i50)
delete(dist1)
delete(stat1)
delete(lats1)
delete(lons1)
delete(alts1)
delete(dist2)
delete(sta2)
delete(lats2)
delete(lons2)
delete(alts2)
delete(cdata)

;lats(47)=lats(47)-5.0   ; correct CGO data
;lons(47)=lons(47)-10.0  ; correct CGO data

;+++++++++++++++++++++++ read NOAA monthly data ++++++++++++
cco=new((/nmon,nyer,ndim/), float)
cco0=new((/ntot,ndim/), float)

do nd=0,ndim-1
   if (stat0(nd).eq."POC") then
      filename=obsdir + "flask/month/" + changeCase(stat(nd),"low") + "_01D1_mm.co2"
   else
      filename=obsdir + "flask/month/" + changeCase(stat0(nd),"low") + "_01D0_mm.co2"
   end if
      print(filename)

   fdata = asciiread(filename,-1,"string")
   print(fdata)
   cdata=stringtochar(fdata)
   delete(fdata)

   dist1   = charactertostring(cdata(38:,0:2))
   year1   = stringtoint(charactertostring(cdata(38:,4:7)))
   mont1   = stringtoint(charactertostring(cdata(38:,9:10)))
   data1   = stringtofloat(charactertostring(cdata(38:,12:19)))
   print(year1)
   print(mont1)
   delete(cdata)

   i50   = ind((year1.ge.1997).and.(year1.le.2009))
   year  = year1(i50)
   mont  = mont1(i50)
   data  = data1(i50)

   ntim=dimsizes(year)
   do nt=0,ntim-1
      cco(mont(nt)-1,year(nt)-1997,nd)=data(nt)
   end do

   delete(i50)
   delete(year)
   delete(mont)
   delete(data)
   delete(dist1)
   delete(year1)
   delete(mont1)
   delete(data1)
end do

   ijk=0
do iy=0,nyer-1
do im=0,nmon-1
   cco0(ijk,:)=cco(im,iy,:)
   ijk=ijk+1
end do
end do
delete(cco)

; ------------- read data ----------------------------
cco1=new((/ntot,ndim/), float)

datadir1 = "/media/LaCie/output.geoschem/v9-01-01.co2/GFEDv3.1/prasadOH_merra_monthly/"

category="IJ-AVG-$"
tracer = 1

   ijk=0
do iy=0,nyer-1
   iiy=iy+1997

   co1=new((/nmon,nlev,nlat,nlon/), float)

   filename1=datadir1 + sprinti("%0.4i",iiy) + "/ctm.bpch." + sprinti("%0.4i",iiy)

   print(filename1)
   GAMAP:: READ_BPCH_4D (filename1, category, tracer, nlon,nlat,nlev,nmon, co1)

   co1=co1*1.0e6

   co1!0="time"
   co1!1="lev"
   co1!2="lat"
   co1!3="lon"
   ;co1&lev=levs
   co1&lat=slat
   co1&lon=slon
   co1&lon@units="degrees_east"
   co1&lat@units="degrees_north"

   do im=0,nmon-1
   do nd=0,ndim-1
;     if (alts(nd).le.levs(0)) then
        cco1(ijk,nd)=co1(im,0,{lats(nd)},{lons(nd)})
;     else
;       cco1(:,nd)=co1(:,{alts(nd)},{lats(nd)},{lons(nd)})
;       cco2(:,nd)=co2(:,{alts(nd)},{lats(nd)},{lons(nd)})
;     end if
   end do
       ijk=ijk+1
   end do

   delete(co1)
end do

cco1@_FillValue=-999

;cco1=where(ismissing(cco0), -999, cco1)

;------------- obtain 9 latitude band ts -----------
ttt=new((/nvar,ntot,ndim/), float)

ttt(0,:,:) =cco0
ttt(1,:,:) =cco1

ttt!0="var"
ttt!1="time"
ttt!2="station"

;------------- removing long-term trend -----------
do nv=0,nvar-1
do nd=0,ndim-1
   tmp0=cco0(:,nd)
   tmp1=ttt(nv,:,nd)

   i50=ind(.not.ismissing(tmp0))

   ntim=dimsizes(i50)
   print(ntim)

   xx=fspan(1.,int2flt(ntim),ntim)
   n=3

   yy1=tmp1(i50)
   tmp1=-999

   cc= lspoly(xx,yy1, 1, n)
;   yy2 = cc(0) + cc(1)*xx
   yy2 = cc(0) + cc(1)*xx + cc(2)*xx^2
   delete(cc)

   tmp1(i50)=yy1-yy2
   delete(yy1)
   delete(yy2)

;   ttt(nv,:,nd)=tmp1
   delete(xx)
   delete(i50)
   delete(tmp0)
   delete(tmp1)
end do
end do

;------------- removing annual cycle -----------
tt1=new((/nvar,ndim,nmon,nyer/), float)

   ijk=0
do iy=0,nyer-1
do im=0,nmon-1
   tt1(:,:,im,iy)=ttt(:,ijk,:)
   ijk=ijk+1
end do
end do

at1=dim_avg(tt1)

   ijk=0
do iy=0,nyer-1
do im=0,nmon-1
;   ttt(:,ijk,:) =tt1(:,:,im,iy)-at1(:,:,im)
   ijk=ijk+1
end do
end do

;------------- averaging at 9-latitutde band -----------
sss=new((/nreg,nvar,ntot/), float)

i50   = ind((lats.ge.-90.).and.(lats.lt.-70.))
sss(0,:,:)=dim_avg(ttt(var|:,time|:,station|i50))
delete(i50)

i50   = ind((lats.ge.-70.).and.(lats.lt.-50.))
sss(1,:,:)=dim_avg(ttt(var|:,time|:,station|i50))
delete(i50)

i50   = ind((lats.ge.-50.).and.(lats.lt.-30.))
sss(2,:,:)=dim_avg(ttt(var|:,time|:,station|i50))
delete(i50)

i50   = ind((lats.ge.-30.).and.(lats.lt.-10.))
sss(3,:,:)=dim_avg(ttt(var|:,time|:,station|i50))
delete(i50)

i50   = ind((lats.ge.-10.).and.(lats.le.10.))
sss(4,:,:)=dim_avg(ttt(var|:,time|:,station|i50))
delete(i50)

i50   = ind((lats.gt.10.).and.(lats.le.30.))
sss(5,:,:)=dim_avg(ttt(var|:,time|:,station|i50))
delete(i50)

i50   = ind((lats.gt.30.).and.(lats.le.50.))
sss(6,:,:)=dim_avg(ttt(var|:,time|:,station|i50))
delete(i50)

i50   = ind((lats.gt.50.).and.(lats.le.70.))
sss(7,:,:)=dim_avg(ttt(var|:,time|:,station|i50))
delete(i50)

i50   = ind((lats.gt.70.).and.(lats.le.90.))
sss(8,:,:)=dim_avg(ttt(var|:,time|:,station|i50))
delete(i50)

;---- processing statistics and diagnostics ----------
mxlag=0
x_lead_y          = esccr(sss(:,0,:),sss(:,1,:),mxlag)
corr1=x_lead_y (:,0)
delete(x_lead_y)

stdev=dim_stddev(sss)
stdev1=stdev(:,1)/stdev(:,0)
print(stdev1)

meanco=new((/nreg+1/), string)

   nr=0
   meanco(nr)="Latitude"  + "   GFEDv2  "  +  "   GFEDv3.1   " +  "   GFEDv3.2   "

do nr=0,nreg-1
   meanco(nr+1)= strings(nr) + "    " + sprintf("%8.4f", corr1(nr)) + sprintf("%8.4f", stdev1(nr))
end do

print(meanco)

;file_out="co2_corr+stdev_GFEDv3.2.vs.noaa_1997-2009_2nd.polynomial.txt"
;file_out="co2_corr+stdev_GFEDv2.vs.GFEDv3.2_1997-2008_NoAC+2nd.polynomial.txt"
;asciiwrite(file_out,meanco)

sss!0="region"
sss!1="var"
sss!2="time"
sss&time=fspan(1997,2010,ntot)

;sss(:,0,:)=-999
;sss(:,1,:)=-999
;sss(:,2,:)=-999

;  ---------  draw pictures ------------------

  plotname="ts_co2_gfedv3.vs.noaa.1997-2009"
;  plotname="ts_co2_gfedv3.vs.noaa.1997-2009_detrend"
;  plotname="ts_co2_gfedv3.vs.noaa.1997-2009_NoAC+detrend"

  wks = gsn_open_wks("x11",plotname)

;  cmap = (/(/1., 1., 1./), (/0., 0., 0./), (/1., 0., 0./), (/1., 0., .4/), \
;           (/1., 0., .8/), (/1., .2, 1./), (/1., .6, 1./), (/.6, .8, 1./), \
;           (/.2, .8, 1./), (/.2, .8, .6/), (/.2, .8, 0./), (/.2, .4, .0/), \
;           (/.2, .4, .4/), (/.2, .4, .8/), (/.6, .4, .8/), (/.6, .8, .8/), \
;           (/.6, .8, .4/), (/1., .6, .8/)/)

;  gsn_define_colormap(wks,"BlAqGrYeOrRe")
;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
;  gsn_define_colormap(wks,"BlWhRe")
;  i  =  NhlNewColor(wks, 0.6, 0.6, 0.6)

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
  res1@tiYAxisString          = "Surface CO2 (ppm)"
;  res1@tiYAxisString          = "CO (x10:S:18:N: molec/cm:S:2:N:) at Darwin (12.4:S:o:N:S, 130.9:S:o:N:E)"
  res1@tiXAxisFont            = "helvetica-Bold" 
  res1@tiYAxisFont            = "helvetica-Bold" 
  res1@tiXAxisFontHeightF     = 0.012
  res1@tiYAxisFontHeightF     = 0.012
  res1@tmXBLabelsOn           = False
;  res1@tmYRLabelsOn           = False
;  res1@tiMainString           = "Average over [5:S:o:N:-20:S:o:N:N, 120:S:o:N:-160:S:o:N:E]" 
  res1@tiMainFont             = "helvetica-Bold" 
  res1@gsnStringFontHeightF   = 0.016
  res1@gsnStringFont          = "helvetica-Bold"
;  res1@gsnLeftString          = strings(nr)
  res1@gsnCenterString        = ""
;  res1@trYMinF                = 0.0
;  res1@trYMaxF                = 4.5
  res1@trXMinF                = 1997
  res1@trXMaxF                = 2010

;  res1@tmXBAutoPrecision     = False
  res1@tmXBPrecision         = 4
;  res1@tmXBMode              = "Explicit"
;  res1@tmXBValues            = (/2004,2005,2006,2007/)
;  res1@tmXBLabels            = (/"2004","2005","2006","2007"/) 

  res1@xyLabelMode           = "Custom" 
  res1@xyLineColors          = (/1,2,4,19,2,4,19/)
  res1@xyDashPatterns        = (/0,0,0,0,2,2,2/)
  res1@xyLineLabelFontColors = (/1,2,4,19,2,4,19/)
  res1@xyLineThicknesses     = (/1,1,1,1,1,1,1/)
  res1@xyExplicitLabels      = (/"","","","","","",""/)
  res1@xyLineLabelFontHeightF = 0.01 
;  res1@gsnLeftFontHeightF     = 0.01 


  res1@vpXF                  = 0.10
  res1@vpYF                  = 0.99
  res1@vpWidthF              = 0.40
  res1@vpHeightF             = 0.18

  plot1 = gsn_csm_xy(wks,sss&time,sss(0,:,:),res1)
  draw (plot1)

  res1@vpYF                  = 0.80
  plot2 = gsn_csm_xy(wks,sss&time,sss(1,:,:),res1)
  draw (plot2)

  res1@vpYF                  = 0.61
  plot3 = gsn_csm_xy(wks,sss&time,sss(2,:,:),res1)
  draw (plot3)

  res1@vpYF                  = 0.42
  plot4 = gsn_csm_xy(wks,sss&time,sss(3,:,:),res1)
  draw (plot4)

  res1@tmXBLabelsOn          = True
  res1@vpYF                  = 0.23
  plot5 = gsn_csm_xy(wks,sss&time,sss(4,:,:),res1)
  draw (plot5)



  res1@tiYAxisString         = ""
  res1@tmXBLabelsOn          = False
  res1@vpXF                  = 0.58
  res1@vpYF                  = 0.99
  plot6 = gsn_csm_xy(wks,sss&time,sss(5,:,:),res1)
  draw (plot6)

  res1@vpYF                  = 0.80
  plot7 = gsn_csm_xy(wks,sss&time,sss(6,:,:),res1)
  draw (plot7)

  res1@vpYF                  = 0.61
  plot8 = gsn_csm_xy(wks,sss&time,sss(7,:,:),res1)
  draw (plot8)

  res1@tmXBLabelsOn          = True
  res1@vpYF                  = 0.42
  plot9 = gsn_csm_xy(wks,sss&time,sss(8,:,:),res1)
  draw (plot9)


  res_text                    = True  
  res_text@txFontHeightF      = 0.012
  res_text@txFont             = "helvetica-bold"
  res_text@txJust             = "CenterLeft" 

  res_lines                   = True 
  res_lines@gsLineDashPattern = 0  
  res_lines@gsLineThicknessF  = 1.  

  xx0 = (/1997.,2009./)
  yy0 = (/0.0, 0.0/)
  gsn_polyline(wks,plot1,xx0,yy0,res_lines) 
  gsn_polyline(wks,plot2,xx0,yy0,res_lines) 
  gsn_polyline(wks,plot3,xx0,yy0,res_lines) 
  gsn_polyline(wks,plot4,xx0,yy0,res_lines) 
  gsn_polyline(wks,plot5,xx0,yy0,res_lines) 
  gsn_polyline(wks,plot6,xx0,yy0,res_lines) 
  gsn_polyline(wks,plot7,xx0,yy0,res_lines) 
  gsn_polyline(wks,plot8,xx0,yy0,res_lines) 
  gsn_polyline(wks,plot9,xx0,yy0,res_lines) 

;  gsn_text_ndc(wks,"90:S:o:N:S-70:S:o:N:S",0.11,0.97,res_text)
;  gsn_text_ndc(wks,"70:S:o:N:S-50:S:o:N:S",0.11,0.78,res_text)
;  gsn_text_ndc(wks,"50:S:o:N:S-30:S:o:N:S",0.11,0.59,res_text)
;  gsn_text_ndc(wks,"30:S:o:N:S-10:S:o:N:S",0.11,0.40,res_text)
;  gsn_text_ndc(wks,"10:S:o:N:S-10:S:o:N:N",0.11,0.21,res_text)
;  gsn_text_ndc(wks,"10:S:o:N:N-30:S:o:N:N",0.59,0.97,res_text)
;  gsn_text_ndc(wks,"30:S:o:N:N-50:S:o:N:N",0.59,0.78,res_text)
;  gsn_text_ndc(wks,"50:S:o:N:N-70:S:o:N:N",0.59,0.59,res_text)
;  gsn_text_ndc(wks,"70:S:o:N:N-90:S:o:N:N",0.59,0.40,res_text)

  res_text@txJust             = "CenterRight" 
  gsn_text_ndc(wks,"90:S:o:N:S-70:S:o:N:S",0.49,0.97,res_text)
  gsn_text_ndc(wks,"70:S:o:N:S-50:S:o:N:S",0.49,0.78,res_text)
  gsn_text_ndc(wks,"50:S:o:N:S-30:S:o:N:S",0.49,0.59,res_text)
  gsn_text_ndc(wks,"30:S:o:N:S-10:S:o:N:S",0.49,0.40,res_text)
  gsn_text_ndc(wks,"10:S:o:N:S-10:S:o:N:N",0.49,0.21,res_text)
  gsn_text_ndc(wks,"10:S:o:N:N-30:S:o:N:N",0.97,0.97,res_text)
  gsn_text_ndc(wks,"30:S:o:N:N-50:S:o:N:N",0.97,0.78,res_text)
  gsn_text_ndc(wks,"50:S:o:N:N-70:S:o:N:N",0.97,0.59,res_text)
  gsn_text_ndc(wks,"70:S:o:N:N-90:S:o:N:N",0.97,0.40,res_text)

  res_text@txJust             = "CenterRight" 
;  gsn_text_ndc(wks,stringy(1),0.49,0.97,res_text)
;  gsn_text_ndc(wks,stringy(2),0.49,0.78,res_text)
;  gsn_text_ndc(wks,stringy(3),0.49,0.59,res_text)
;  gsn_text_ndc(wks,stringy(4),0.49,0.40,res_text)
;  gsn_text_ndc(wks,stringy(5),0.49,0.21,res_text)
;  gsn_text_ndc(wks,stringy(6),0.97,0.97,res_text)
;  gsn_text_ndc(wks,stringy(7),0.97,0.78,res_text)
;  gsn_text_ndc(wks,stringy(8),0.97,0.59,res_text)
;  gsn_text_ndc(wks,stringy(9),0.97,0.40,res_text)

  res_text@txJust             = "CenterLeft" 
  xx0 = (/0.55,0.60/)
  yy0 = (/0.85, 0.85/)
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineColor       = "foreground"
  res_text@txFontColor        = "foreground"  
;  gsn_polyline(wks,plot1,xx0,yy0,res_lines) 
;  gsn_text_ndc(wks,strings(nr-1),0.57,0.85,res_text)
;  gsn_text_ndc(wks,"Surface CO (ppbv)",0.57,0.82,res_text)

  xx0 = (/0.55,0.58/)
  yy0 = (/0.16, 0.16/)
  res_lines@gsLineThicknessF  = 1.  
  res_lines@gsLineColor       = "foreground"
  res_text@txFontColor        = "foreground"  
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines) 
;  gsn_text_ndc(wks,"NOAA GMD",xx0(1)+0.02,yy0(0),res_text)

  yy0 = (/0.13, 0.13/)
  res_lines@gsLineThicknessF  = 1.  
  res_lines@gsLineColor       = 2
  res_text@txFontColor        = 2  
  gsn_polyline_ndc(wks,xx0,yy0,res_lines) 
  gsn_text_ndc(wks,"GFEDv2_GEOS4",xx0(1)+0.02,yy0(0),res_text)

  yy0 = (/0.10, 0.10/)
  res_lines@gsLineColor       = 4
  res_text@txFontColor        = 4  
  gsn_polyline_ndc(wks,xx0,yy0,res_lines) 
  gsn_text_ndc(wks,"GFEDv3.1_GEOS4",xx0(1)+0.02,yy0(0),res_text)

  yy0 = (/0.07, 0.07/)
  res_lines@gsLineColor       = 19
  res_text@txFontColor        = 19
  gsn_polyline_ndc(wks,xx0,yy0,res_lines) 
  gsn_text_ndc(wks,"GFEDv3.2_GEOS4",xx0(1)+0.02,yy0(0),res_text)

  xx0 = (/0.80,0.83/)
  res_lines@gsLineDashPattern = 2
  yy0 = (/0.13, 0.13/)
  res_lines@gsLineThicknessF  = 1.  
  res_lines@gsLineColor       = 2
  res_text@txFontColor        = 2  
  gsn_polyline_ndc(wks,xx0,yy0,res_lines) 
  gsn_text_ndc(wks,"GFEDv2_GEOS5",xx0(1)+0.02,yy0(0),res_text)

  yy0 = (/0.10, 0.10/)
  res_lines@gsLineColor       = 4
  res_text@txFontColor        = 4  
  gsn_polyline_ndc(wks,xx0,yy0,res_lines) 
  gsn_text_ndc(wks,"GFEDv3.1_GEOS5",xx0(1)+0.02,yy0(0),res_text)

  yy0 = (/0.07, 0.07/)
  res_lines@gsLineColor       = 19
  res_text@txFontColor        = 19
  gsn_polyline_ndc(wks,xx0,yy0,res_lines) 
  gsn_text_ndc(wks,"GFEDv3.2_GEOS5",xx0(1)+0.02,yy0(0),res_text)

  yy0 = (/0.07, 0.07/)
  res_text@txFontHeightF      = 0.015
  res_lines@gsLineColor       = 1
  res_text@txFontColor        = 1  
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines) 
;  gsn_text_ndc(wks,"Original OH, without CH4, detrended",xx0(1)-0.1,yy0(0)-0.02,res_text)

  frame(wks)

end 

