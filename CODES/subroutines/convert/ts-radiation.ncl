load "/sopt/ncl/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "/sopt/ncl/lib/ncarg/nclex/gsun/gsn_csm.ncl"
load "/sopt/ncl/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/sopt/ncl/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "/gdata/randerson2/mmu/ILAMB/CODES/subroutines/read_gbaf.ncl"
load "/gdata/randerson2/mmu/ILAMB/CODES/subroutines/read_albedo.ncl"
load "/gdata/randerson2/mmu/ILAMB/CODES/subroutines/interp_benchmark_to_cmip5.ncl"
load "/gdata/randerson2/mmu/ILAMB/CODES/subroutines/read_cmip5_vars.ncl"
load "/gdata/randerson2/mmu/ILAMB/CODES/subroutines/read_cmip5_lat.ncl"
load "/gdata/randerson2/mmu/ILAMB/CODES/subroutines/read_cmip5_lon.ncl"

begin

nmod=14
start_year=1992
end_year=2005
nyer=end_year-start_year + 1
nmon=12
ntot=nyer*nmon

nday=(/31,28,31,30,31,30,31,31,30,31,30,31/)

varID = "LWdn" 

conf=1000.*24.0*3600.0

; ++++++ BSRN ++++++++
k51=(/4,17,22,39,48/)

; ++++++ CAVE ++++++++
k52=(/2,4,0,1,6/)

; ++++++ SURFRAD ++++++++
k53=(/0,2,3,5,6/)

;modelID=(/"bcc-csm1-1","CanESM2","CCSM4","GFDL-ESM2G","HadGEM2-CC","HadGEM2-ES","inmcm4","IPSL-CM5A-LR","IPSL-CM5A-MR",\
;          "MIROC-ESM","MIROC-ESM-CHEM","MPI-ESM-LR","NorESM1-M"/)
;
;nrun=(/3,5,1,1,1,2,1,2,1,1,1,3,3/)

modelID=(/"bcc-csm1-1","CanESM2","CCSM4","GFDL-ESM2G","HadGEM2-CC","HadGEM2-ES","inmcm4","IPSL-CM5A-LR","IPSL-CM5A-MR",\
          "MIROC-ESM","MIROC-ESM-CHEM","MPI-ESM-LR","NorESM1-M","meanModel"/)

nrun=(/3,5,6,1,2,2,1,5,1,3,1,3,3,0/)

regnames=(/"US-central","US-east","US-west","US-north","Europe-central","Europe-north","Asia-north","Asia-south","Australia","Africa-south","South-America"/)
slat1=(/ 32.5, 40.,  35.,  45., 38., 60.,50., -5.,-40.,-30., -5./)
slat2=(/ 47.5, 50.,  50.,  60., 60., 70.,65.,  5.,-35.,-15.,  0./)
slon1=(/-100.,-80.,-125.,-110.,-15., 15.,85.,110.,140., 20.,-60./)
slon2=(/-82.5,-65.,-115., -95., 22., 30.,95.,120.,150., 35.,-50./)

; ------- read BSRN data -----
obsdir="/gdata/randerson2/mmu/ILAMB/datasets/BENCHMARKS/Radiation/WRMC-BSRN"

SiteListName = obsdir + "/derived/sites.all"
print(SiteListName)

SiteFileName = asciiread(SiteListName,-1,"string")
print(SiteFileName)
nsit1=dimsizes(SiteFileName)
print(nsit1)

cSiteFileName=stringtochar(SiteFileName)
site1   = charactertostring(cSiteFileName(:,0:2))
delete(cSiteFileName)

print(site1)

;---Read the values in as 1D, since we don't know rows and columns yet.
lats1=new((/nsit1/), float)
lons1=new((/nsit1/), float)

   ij=0
do ns=0, nsit1-1

  DataFileName = obsdir + "/derived/" + SiteFileName(ns)

  if (fileexists(DataFileName)) then

     print(DataFileName)

     fdata = asciiread(DataFileName,-1,"string")
     ;print(fdata)
     cdata=stringtochar(fdata)
     delete(fdata)

     year1   = stringtoint(charactertostring(cdata(1:,0:3)))
     mont1   = stringtoint(charactertostring(cdata(1:,5:7)))
     lats0   = stringtofloat(charactertostring(cdata(1:,12:19)))
     lons0   = stringtofloat(charactertostring(cdata(1:,22:29)))

     lats1(ns)=lats0(0)
     lons1(ns)=lons0(0)

     delete(lats0)
     delete(lons0)
     delete(year1)
     delete(mont1)
  end if
end do
delete(SiteListName)
delete(SiteFileName)

site=site1(k51)
lats=lats1(k51)
lons=lons1(k51)

; ------- read CAVE data -----
obsdir="/gdata/randerson2/mmu/ILAMB/datasets/BENCHMARKS/Radiation/CAVE"

SiteListName = obsdir + "/derived/siteinfo.syn_UT.txt"
print(SiteListName)

SiteFileName = asciiread(SiteListName,-1,"string")
print(SiteFileName)
nsit2=dimsizes(SiteFileName)
print(nsit2)

cSiteFileName=stringtochar(SiteFileName)

site2 = charactertostring(cSiteFileName(:,0:14))
lats2 = stringtofloat(charactertostring(cSiteFileName(:,20:26)))
lons2 = stringtofloat(charactertostring(cSiteFileName(:,30:36)))

site2 = str_squeeze(site2)

delete(SiteListName)
delete(SiteFileName)
delete(cSiteFileName)

; ------- read SURFRAD data -----
obsdir="/gdata/randerson2/mmu/ILAMB/datasets/BENCHMARKS/Radiation/SURFRAD"

SiteListName = obsdir + "/monthly/SiteInfo.txt"
print(SiteListName)

SiteFileName = asciiread(SiteListName,-1,"string")
print(SiteFileName)

cSiteFileName=stringtochar(SiteFileName)

site3 = charactertostring(cSiteFileName(1:,0:2))
lats3 = stringtofloat(charactertostring(cSiteFileName(1:,60:65)))
lons3 = stringtofloat(charactertostring(cSiteFileName(1:,70:76)))

site3 = str_squeeze(site3)
nsit3=dimsizes(site3)
print(nsit3)

delete(SiteFileName)
delete(cSiteFileName)

;------------- read data from files ----------------
;file1_in="datasets/ts.ann_lwup_SRB+cmip5.Historical_BSRN.dat"
;file2_in="datasets/ts.ann_lwup_SRB+cmip5.Historical_CAVE.dat"
;file3_in="datasets/ts.ann_lwup_SRB+cmip5.Historical_SURFRAD.dat"

file1_in="datasets/ts_lwdn_SRB+cmip5.Historical_BSRN.dat"
file2_in="datasets/ts_lwdn_SRB+cmip5.Historical_CAVE.dat"
file3_in="datasets/ts_lwdn_SRB+cmip5.Historical_SURFRAD.dat"

ss1=new((/nsit1,nmod+2,ntot/), float)
ss2=new((/nsit2,nmod+2,ntot/), float)
ss3=new((/nsit3,nmod+2,ntot/), float)

ss1=fbindirread(file1_in,0,(/nsit1,nmod+2,ntot/),"float")
ss2=fbindirread(file2_in,0,(/nsit2,nmod+2,ntot/),"float")
ss3(:,:,36:ntot-1)=fbindirread(file3_in,0,(/nsit3,nmod+2,ntot-36/),"float")

ss1 = where(ss1.le.-990, -999, ss1)
ss2 = where(ss2.le.-990, -999, ss2)
ss3 = where(ss3.le.-990, -999, ss3)

ss1@_FillValue=-999
ss2@_FillValue=-999
ss3@_FillValue=-999

tt1=ss1(k51,0,:)
tt2=ss2(k52,0,:)
tt3=ss3(k53,0,:)

print(site1(k51))
print(site2(k52))
print(site3(k53))

do ns=0,4

   sss=new((/3,ntot/), float)

   sss(0,:)=tt1(ns,:)
   sss(1,:)=tt2(ns,:)
   sss(2,:)=tt3(ns,:)

   sss@_FillValue=-999

   sss!0="var"
   sss!1="time"
   sss&time=fspan(start_year,end_year,ntot)

   print(sss)

;  ---------  draw pictures ------------------
;  plotname="ts.ann_" + varID + "_SRB+cmip5.Historical_BSRN." + regnames(nd)
  plotname="ts_" + varID + "_BSRN+CAVE+SURFRAD_" + site(ns)

  wks = gsn_open_wks("x11",plotname)

;  cmap = (/(/1., 1., 1./), (/0., 0., 0./), (/1., 0., 0./), (/1., 0., .4/), \
;           (/1., 0., .8/), (/1., .2, 1./), (/1., .6, 1./), (/.6, .8, 1./), \
;           (/.2, .8, 1./), (/.2, .8, .6/), (/.2, .8, 0./), (/.2, .4, .0/), \
;           (/.2, .4, .4/), (/.2, .4, .8/), (/.6, .4, .8/), (/.6, .8, .8/), \
;           (/.6, .8, .4/), (/1., .6, .8/)/)

  gsn_define_colormap(wks,"default")
;  gsn_define_colormap(wks,"BlAqGrYeOrRe")
;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
;  gsn_define_colormap(wks,"BlWhRe")
;  i  =  NhlNewColor(wks, 0.6, 0.6, 0.6)

; reverse the first two colors
;  setvalues wks
;    "wkForegroundColor" : (/1.,1.,1./)
;    "wkBackgroundColor" : (/0.,0.,0./)
;  end setvalues

;  --------   set  res1 ------------

  res1                        = True
  res1@gsnDraw                = False
  res1@gsnFrame               = False

  res1@tmYRLabelFont          = "helvetica"
  res1@tmYLLabelFont          = "helvetica"
  res1@tmXBLabelFont          = "helvetica"
  res1@tmYRLabelFontHeightF   = 0.015
  res1@tmYLLabelFontHeightF   = 0.015
  res1@tmXBLabelFontHeightF   = 0.015
;  res1@tiYAxisString          = "Surface CO2 (ppm)"
;  res1@tiYAxisString          = "CO (x10:S:18:N: molec/cm:S:2:N:) at Darwin (12.4:S:o:N:S, 130.9:S:o:N:E)"
  res1@tiXAxisFont            = "helvetica-Bold" 
  res1@tiYAxisFont            = "helvetica-Bold" 
  res1@tiXAxisFontHeightF     = 0.016
  res1@tiYAxisFontHeightF     = 0.016
;  res1@tmXBLabelsOn           = False
;  res1@tmYRLabelsOn           = False
;  res1@tiMainString           = "Average over [5:S:o:N:-20:S:o:N:N, 120:S:o:N:-160:S:o:N:E]" 
  res1@tiMainFont             = "helvetica-Bold" 
  res1@gsnStringFontHeightF   = 0.016
  res1@gsnStringFont          = "helvetica-Bold"
;  res1@gsnLeftString          = strings(nr)
  res1@gsnCenterString        = ""
;  res1@trYMinF                = 0.0
;  res1@trYMaxF                = 4.5
  res1@trXMinF                = start_year
  res1@trXMaxF                = end_year

;  res1@tmXBMode              = "Explicit"
;  res1@tmXBValues            = (/1,2,3,4,5,6,7,8,9,10,11,12/)
;  res1@tmXBLabels            = (/"J","F","M","A","M","J","J","A","S","O","N","D"/)

;  res1@tmXBAutoPrecision     = False
  res1@tmXBPrecision         = 4
;  res1@tmYLPrecision         = 3
;  res1@tmXBMode              = "Explicit"
;  res1@tmXBValues            = (/2004,2005,2006,2007/)
;  res1@tmXBLabels            = (/"2004","2005","2006","2007"/) 

  res1@xyLabelMode           = "Custom" 
  res1@xyLineColors          = (/2,19,4,24,22,7,20,31,12,13,16,23,14,3,1,1/)
  res1@xyDashPatterns        = (/0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0/)
  res1@xyLineLabelFontColors = (/2,3,4,5,6,7,20,26,3,5,6,23,14,3,1,1/)
  res1@xyLineThicknesses     = (/1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2/)
  res1@xyExplicitLabels      = (/"","","","","","","","","","","","","","","","",""/)
  res1@xyLineLabelFontHeightF = 0.01 
;  res1@gsnLeftFontHeightF     = 0.01 

  res1@vpXF                  = 0.15
  res1@vpYF                  = 0.90
  res1@vpWidthF              = 0.80
  res1@vpHeightF             = 0.40

;  res1@tiYAxisString         = "Precipitation (mm/day)"
;  res1@tiYAxisString         = "2M Air Temperature (~S~o~N~C)"
;  res1@tiYAxisString         = "Net Ecosystem Exchange (g C /m~S~2~N~ /day)"
;  res1@tiYAxisString         = "Gross Primary Production (g C /m~S~2~N~ /day)"
;  res1@tiYAxisString         = "Ecosystem Respiration (g C /m~S~2~N~ /day)"
;  res1@tiYAxisString         = "Latent Heat Flux (W/m~S~2~N~)"
;  res1@tiYAxisString         = "Sensible Heat Flux (W/m~S~2~N~)"

;  res1@tiYAxisString         = "Net Radiation (W/m~S~2~N~)"
  res1@tiYAxisString         = "Downward Shortwave Radiation (W/m~S~2~N~)"

  plot1 = gsn_csm_xy(wks,sss&time,sss,res1)
  draw (plot1)

;  res1@vpXF                  = 0.55
;  plot2 = gsn_csm_xy(wks,ss2&time,ss2,res1)
;  draw (plot2)

  res1@tmXBLabelsOn          = True
  res1@vpXF                  = 0.15
  res1@vpYF                  = 0.57
;  plot3 = gsn_csm_xy(wks,ss3&time,ss3,res1)
;  draw (plot3)

  res1@vpXF                  = 0.55
;  plot4 = gsn_csm_xy(wks,ss4&time,ss4,res1)
;  draw (plot4)

  res_text                    = True  
  res_text@txFontHeightF      = 0.014
  res_text@txFont             = "helvetica-bold"
  res_text@txJust             = "CenterLeft" 

  res_lines                   = True 
  res_lines@gsLineDashPattern = 0  
  res_lines@gsLineThicknessF  = 1.  

  xx0 = (/1.,12./)
  yy0 = (/0.0, 0.0/)
;  gsn_polyline(wks,plot1,xx0,yy0,res_lines) 
;  gsn_polyline(wks,plot2,xx0,yy0,res_lines) 
;  gsn_polyline(wks,plot3,xx0,yy0,res_lines) 
;  gsn_polyline(wks,plot4,xx0,yy0,res_lines) 

  res_text@txJust             = "CenterLeft" 
;  gsn_text_ndc(wks,"(a) NEE",0.17,0.88,res_text)
;  gsn_text_ndc(wks,"(b) GPP",0.57,0.88,res_text)
;  gsn_text_ndc(wks,"(c) LE",0.17,0.55,res_text)
;  gsn_text_ndc(wks,"(d) SH",0.57,0.55,res_text)

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

  res_text@txFontHeightF      = 0.012
  res_text@txJust             = "CenterLeft" 
  xx0 = (/0.65,0.70/)
  yy0 = (/0.85, 0.85/)
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineColor       = "foreground"
  res_text@txFontColor        = "foreground"  
;  gsn_polyline(wks,plot1,xx0,yy0,res_lines) 
;  gsn_text_ndc(wks,strings(nr-1),0.57,0.85,res_text)
;  gsn_text_ndc(wks,"Surface CO (ppbv)",0.57,0.82,res_text)

  res_lines@gsLineThicknessF  = 2.  
  res_lines@gsLineThicknessF  = 2.
  xx0 = (/0.20,0.80/)
  yy0 = (/0.24, 0.24/)
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  xx0 = (/0.20,0.80/)
  yy0 = (/0.16, 0.16/)
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines) 
  xx0 = (/0.20,0.20/)
  yy0 = (/0.16, 0.24/)
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  xx0 = (/0.80,0.80/)
  yy0 = (/0.16, 0.24/)
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)

  xx0 = (/0.20,0.23/)
  yy0 = (/0.87, 0.87/)
  res_lines@gsLineThicknessF  = 2.
  res_lines@gsLineColor       = "foreground"
  res_text@txFontColor        = "foreground"
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
;  gsn_text_ndc(wks,"BSRN",xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.03
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 3.
  res_lines@gsLineColor       = 2
  res_text@txFontColor        = 2
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,"BSRN",xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.03
  res_lines@gsLineDashPattern = 0
  res_lines@gsLineThicknessF  = 3.
  res_lines@gsLineColor       = 19
  res_text@txFontColor        = 19
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,"CAVE",xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.03
  res_lines@gsLineThicknessF  = 3.
  res_lines@gsLineColor       = 4
  res_text@txFontColor        = 4
  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
  gsn_text_ndc(wks,"SURFRAD",xx0(1)+0.01,yy0(0),res_text)

  xx0 = (/0.33,0.33/)
  yy0 = (/0.23, 0.23/)
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 24
  res_text@txFontColor        = 24
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
;  gsn_text_ndc(wks,modelID(3),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 22
  res_text@txFontColor        = 22
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
;  gsn_text_ndc(wks,modelID(4),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 7
  res_text@txFontColor        = 7
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
;  gsn_text_ndc(wks,modelID(5),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 20
  res_text@txFontColor        = 20
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
;  gsn_text_ndc(wks,modelID(6),xx0(1)+0.01,yy0(0),res_text)

  xx0 = (/0.47,0.47/)
  yy0 = (/0.23, 0.23/)
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 31
  res_text@txFontColor        = 31
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
;  gsn_text_ndc(wks,modelID(7),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 12
  res_text@txFontColor        = 12
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
;  gsn_text_ndc(wks,modelID(8),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 13
  res_text@txFontColor        = 13
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
;  gsn_text_ndc(wks,modelID(9),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 16
  res_text@txFontColor        = 16
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
;  gsn_text_ndc(wks,modelID(10),xx0(1)+0.01,yy0(0),res_text)

  xx0 = (/0.64,0.64/)
  yy0 = (/0.23, 0.23/)
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 23
  res_text@txFontColor        = 23
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
;  gsn_text_ndc(wks,modelID(11),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 14
  res_text@txFontColor        = 14
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
;  gsn_text_ndc(wks,modelID(12),xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 3
  res_text@txFontColor        = 3
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
;  gsn_text_ndc(wks,"SRB",xx0(1)+0.01,yy0(0),res_text)

  yy0 = yy0 - 0.02
  res_lines@gsLineThicknessF  = 1.
  res_lines@gsLineColor       = 1
  res_text@txFontColor        = 1
;  gsn_polyline_ndc(wks,xx0,yy0,res_lines)
;  gsn_text_ndc(wks,"BSRN (solid)",xx0(1)+0.01,yy0(0),res_text)

  yy0 = (/0.155, 0.155/)
  xx0 = (/0.795,0.795/)
;  gsn_text_ndc(wks," ",xx0(1)+0.01,yy0(0),res_text)

  frame(wks)

  delete(sss)

end do

end
