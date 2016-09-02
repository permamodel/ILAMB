function html_head (VarName:string, Sources:string)

begin

if (dimsizes(Sources).gt.1) then
   do ns=0,dimsizes(Sources)-1
      if (ns.eq.0) then
         Source=Sources(ns)
      else
         Source=Source + ", " + Sources(ns)
      end if
   end do
else
   Source=Sources
end if

header = new((/15/), string)

header(0) = "<html>"
header(1) = "<header>"
header(2) = "<title>Output for ILAMB Diagnostics</title>"
header(3) = "</header>"
header(4) = "<body>"
header(5) = "<center>"
header(6) = "<BR>"
header(7) = "<BR>"
header(8) = "<TABLE width='900' BORDER='0'  !BGCOLOR='#dbedc0'>"
header(9) = "<tr>"
header(10) = "   <td align='center' width='50'><font size='3' color='#000080'>  </font><br></td>"
header(11) = "   <td align='center' width='860'><font size='3' color='black' face='Verdana'><B>Diagnostic Summary for " + VarName + \
             ": Model vs. " + Source + " </B></font><br></td>"
header(12) = "<td align='center' width='50'><font size='3' color='#000080'>  </font><br></td>"
header(13) = "</tr>"
header(14) = "</TABLE>"

return(header)

end

; ################################################################################################################################
function html_tail ()

begin

tail = new((/6/), string)

tail(0) = "                 "
tail(1) = "<br>"
tail(2) = "<br>"
tail(3) = "</center>"
tail(4) = "</body>"
tail(5) = "</html>"

return(tail)

end

; ################################################################################################################################
procedure create_ilamb_main ()

begin

body = new((/100/), string)

numb       = 0
body(numb) = "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0 Transitional//EN'>"
numb       = numb + 1
body(numb) = "                  "
numb       = numb + 1
body(numb) = "<html>"
numb       = numb + 1
body(numb) = "<header>"
numb       = numb + 1
body(numb) = "<title>ILAMB Diagnostics Output Webpage</title>"
numb       = numb + 1
body(numb) = "</header>"
numb       = numb + 1
body(numb) = "                  "
numb       = numb + 1
body(numb) = "<!-- frames -->"
numb       = numb + 1
body(numb) = "<frameset rows='*,60' frameborder='0' border='0' framespacing='0'>"
;body(numb) = "<frameset rows='60,*,60' frameborder='0' border='0' framespacing='0'>"
numb       = numb + 1
;body(numb) = "<frame name='home-top' src='ilamb-top.html' marginwidth='0' marginheight='0' scrolling='no' frameborder='no' >"
;numb       = numb + 1
body(numb) = "<frame name='home-content' src='ilamb-summary.html' marginwidth='0' marginheight='0' scrolling='auto' frameborder='no' >"
numb       = numb + 1
body(numb) = "<frame name='home-bottom' src='ilamb-bottom.html' marginwidth='0' marginheight='0' scrolling='no' frameborder='no'>"
numb       = numb + 1
body(numb) = "</frameset>"
numb       = numb + 1
body(numb) = "                 "
numb       = numb + 1
body(numb) = "</html>"
numb       = numb + 1

HtmlFileName = getenv("ILAMB_OUTPUTDIR") + "/www/ilamb.html"

asciiwrite(HtmlFileName,body(0:numb-1))

end

; ################################################################################################################################
procedure create_ilamb_bottom ()

begin

quote = str_get_dq()

body = new((/100/), string)

numb       = 0
body(numb) = "<HTML>"
numb       = numb + 1
body(numb) = "                  "
numb       = numb + 1
body(numb) = "<body bgcolor='#ffffff' text='#000000' link='#0000ff' vlink='#ff00ff'>"
numb       = numb + 1
body(numb) = "<style type=" + quote + "text/css" + quote + ">"
numb       = numb + 1
body(numb) = "  <!--"
numb       = numb + 1
body(numb) = "    a:active {  text-decoration: underline; color: #aa0000}"
numb       = numb + 1
body(numb) = "    a:link {  text-decoration: none; color: #3333cc}"
numb       = numb + 1
body(numb) = "    a:visited {  text-decoration: none; color: #aa2233}"
numb       = numb + 1
body(numb) = "    a:hover {  text-decoration: underline; color: #3333CC}"
numb       = numb + 1
body(numb) = "  -->"
numb       = numb + 1
body(numb) = "  </style>"
numb       = numb + 1
body(numb) = "                         "
numb       = numb + 1
body(numb) = "<TITLE>Link to ILAMB Diagnostics Home Page </TITLE>"
numb       = numb + 1
body(numb) = "                  "
numb       = numb + 1
body(numb) = "<body>"
numb       = numb + 1
body(numb) = "<div class='divline'>"
numb       = numb + 1
body(numb) = "<table border=0 cellpadding=0 cellspacing=0 width=100% align='center' valign='center'>"
numb       = numb + 1
body(numb) = "<tr><td valign='center' align='center' height=1 bgcolor='red'></td></tr>"
numb       = numb + 1
body(numb) = "<tr><td valign='center' align='center' height=10 bgcolor='lightblue'></td></tr>"
numb       = numb + 1
body(numb) = "<tr><td valign='center' align='center' height=1 bgcolor='red'></td></tr>"
numb       = numb + 1
body(numb) = "                 "
numb       = numb + 1
body(numb) = "<tr><td>"
numb       = numb + 1
body(numb) = "<table width=100% height=5>"
numb       = numb + 1
body(numb) = "                 "
numb       = numb + 1
body(numb) = "<tr>"
numb       = numb + 1
body(numb) = "<td align='left' valign='center' width=50% height=10><font size=1 face='Verdana'><I><B>"
numb       = numb + 1
body(numb) = "<a href='http://www.ess.uci.edu' TARGET='_blank'>Earth System Science</a><BR>"
numb       = numb + 1
body(numb) = "<a href='http://www.uci.edu' TARGET='_blank'>University of California Irvine</a><BR>"
numb       = numb + 1
body(numb) = "240C Rowland Hall, Irvine, CA 92697-3100</B></I><BR></font>"
numb       = numb + 1
body(numb) = "</td>"
numb       = numb + 1
body(numb) = "                "
numb       = numb + 1
body(numb) = "<td align='right' valign='center' width=50% height=10><font size=1 face='Verdana'>"
numb       = numb + 1
body(numb) = "<B><I>Email:<a href='mailto:mmu@uci.edu' TARGET='_blank'>mmu@uci.edu</a><BR>"
numb       = numb + 1
body(numb) = "URL:<a href='http://redwood.ess.uci.edu/mingquan/www/ILAMB/index.html' TARGET='_blank'>http://redwood.ess.uci.edu</a><BR>"
numb       = numb + 1
body(numb) = "Phone: (949) 824-1474; Fax: (949) 824-3874</I></B><BR></font>"
numb       = numb + 1
body(numb) = "</td></tr>"
numb       = numb + 1
body(numb) = "                    "
numb       = numb + 1
body(numb) = "<tr><td></td></tr>"
numb       = numb + 1
body(numb) = "</table>"
numb       = numb + 1
body(numb) = "</td></tr>"
numb       = numb + 1
body(numb) = "             "
numb       = numb + 1
body(numb) = "</table>"
numb       = numb + 1
body(numb) = "</body"
numb       = numb + 1
body(numb) = "</div>"
numb       = numb + 1
body(numb) = "</HTML"
numb       = numb + 1

HtmlFileName = getenv("ILAMB_OUTPUTDIR") + "/www/ilamb-bottom.html"

asciiwrite(HtmlFileName,body(0:numb-1))

end

; ################################################################################################################################
function create_category_weights (CatName[*]:string, CatData[*]:integer)

begin

quote = str_get_dq()

nkey=dimsizes(CatName)

HtmlCatWgt = getenv("ILAMB_OUTPUTDIR") + "/www/weights_overall_category.html"

body = new((/10000/), string)

num0 = 0
body(num0) = "<html>"
num0 = num0 + 1
body(num0) = "<header>"
num0 = num0 + 1
body(num0) = "<title>Output for ILAMB Diagnostics</title>"
num0 = num0 + 1
body(num0) = "</header>"
num0 = num0 + 1
body(num0) = "<body>"
num0 = num0 + 1

body(num0) = "                           "
num0 = num0 + 1
body(num0) = "<TABLE width='500' BORDER='0'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "    <td align='center' height='20'></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "<td align='center' width='500'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='3' color='black' face='Verdana'> <B>Contributions from Categories</B></font></td></table></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "    <td align='center' height='10'></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "<TABLE width='500' BORDER='1'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1

body(num0) = "<tr>"
num0 = num0 + 1

body(num0) = "<td align='center' width='300'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'> <B>Category</B></font></td></table></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'> <B>Contribution</B></font></td></table></td>"
num0 = num0 + 1

body(num0) = "</tr>"
num0 = num0 + 1

body(num0) = "<tr bgcolor=" + quote + "#dbedc0" + quote + ">"
num0 = num0 + 1
body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'>" + CatName(0) + \
                "</font></td></table></td>"
num0 = num0 + 1
body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'>" + \
                sprinti("%4i", CatData(0)) + "</font></td></table></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1

body(num0) = "<tr bgcolor=" + quote + "#81BEF7" + quote + ">"
num0 = num0 + 1
body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'>" + CatName(1) + \
                "</font></td></table></td>"
num0 = num0 + 1
body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'>" + \
                sprinti("%4i", CatData(1)) + "</font></td></table></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1

body(num0) = "<tr bgcolor=" + quote + "#F5BCA9" + quote + ">"
num0 = num0 + 1
body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'>" + CatName(2) + \
                "</font></td></table></td>"
num0 = num0 + 1
body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'>" + \
                sprinti("%4i", CatData(2)) + "</font></td></table></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1

body(num0) = "<tr bgcolor=" + quote + "#A4A4A4" + quote + ">"
num0 = num0 + 1
body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'>" + CatName(3) + \
                "</font></td></table></td>"
num0 = num0 + 1
body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'>" + \
                sprinti("%4i", CatData(3)) + "</font></td></table></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1

body(num0) = "</table>"
num0 = num0 + 1
body(num0) = "<BR>"
num0 = num0 + 1

body(num0) = "                 "
num0 = num0 + 1
body(num0) = "</body>"
num0 = num0 + 1
body(num0) = "</html>"
num0 = num0 + 1

asciiwrite(HtmlCatWgt,body(0:num0-1))

return (HtmlCatWgt)

end

; ################################################################################################################################
function create_scoring_metrics (CatName:string, CatData:integer, VarNames:string, AllVarName:string, AllSourceName:string,  \
                                 AllCertainty:integer, AllScale:integer, AllOverall:integer, KeyWords:string, CatsID:integer,\
                                 AllSourceID:integer, AllKeyWordID:string, bgcolors:string)

begin

quote = str_get_dq()

ncat=dimsizes(CatName)
nvar=dimsizes(VarNames)
nkey=dimsizes(KeyWords)

swide  = sprinti("%i",(nkey+3+3)*100)

AllShortVarName   = str_squeeze(str_get_field(AllVarName, 1, "("))

HtmlCatWgt = getenv("ILAMB_OUTPUTDIR") + "/www/table_scoring_metrics.html"

body = new((/10000/), string)

num0 = 0
body(num0) = "<html>"
num0 = num0 + 1
body(num0) = "<header>"
num0 = num0 + 1
body(num0) = "<title>Output of ILAMB Diagnostics</title>"
num0 = num0 + 1
body(num0) = "</header>"
num0 = num0 + 1
body(num0) = "<body>"
num0 = num0 + 1

body(num0) = "                           "
num0 = num0 + 1
body(num0) = "<TABLE width='" + swide + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "    <td align='center' height='20'></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "<td align='center' width='" + swide + "'><font size='3' color='black' face='Verdana'> <B>Scoring Metrics, Data and Overall Diagnostic Info</B></font></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "    <td align='center' height='10'></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "<TABLE width='" + swide + "' BORDER='1'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1

body(num0) = "<tr>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='2' color='#000080' face='Verdana'> <B>Category</B></font></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='2' color='#000080' face='Verdana'> <B>Variable</B></font></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='2' color='#000080' face='Verdana'> <B>Source</B></font></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='2' color='#000080' face='Verdana'> <B>Certainty of Data</B></font></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='2' color='#000080' face='Verdana'> <B>Scale Appropriateness and Coverage</B></font></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='2' color='#000080' face='Verdana'> <B>Overall Constraint and Process</B></font></td>"
num0 = num0 + 1

do nk = 0, nkey-1
   KeyLongName = retrieve_LongName (KeyWords(nk))
   body(num0) = "<td align='center' width='100'><font size='2' color='#000080' face='Verdana'> <B>" + KeyLongName + "</B></font></td>"
   num0 = num0 + 1
end do

body(num0) = "</tr>"
num0 = num0 + 1

do nc=0,ncat-1

   i50 = ind(.not.ismissing(CatsID(nc,:)) .and. CatsID(nc,:).ne.-999)

   if (dimsizes(i50).gt.1 .or. .not.ismissing(i50)) then

         numbs = 0
      do nv=0,dimsizes(i50)-1
         if (dimsizes(i50).gt.1) then
            j50 = CatsID(nc,i50(nv))
         else
            j50 = CatsID(nc,i50)
         end if

         ks50 = ind(.not.ismissing(AllSourceID(j50,:)) .and. AllSourceID(j50,:).ne.-999)
         k50  = AllSourceID(j50,ks50)
         numbs = numbs + dimsizes(k50)
         delete(j50)
         delete(k50)
         delete(ks50)
      end do

      do nv=0,dimsizes(i50)-1
         if (dimsizes(i50).gt.1) then
            j50 = CatsID(nc,i50(nv))
         else
            j50 = CatsID(nc,i50)
         end if

         ks50 = ind(.not.ismissing(AllSourceID(j50,:)) .and. AllSourceID(j50,:).ne.-999)
         k50  = AllSourceID(j50,ks50)

         if (dimsizes(k50).gt.1 .or. .not.ismissing(k50)) then

            do ns=0,dimsizes(k50)-1

               if (dimsizes(k50).gt.1) then
                  p50 = k50(ns)
               else
                  p50 = k50
               end if

               body(num0) = "<tr bgcolor=" + quote + bgcolors(nc) + quote + ">"
               num0 = num0 + 1

               ; +++++ Create Category's Name +++++
               if (nv.eq.0 .and. ns.eq.0) then
                  body(num0) = "<td align='center' width='100' rowspan='" + sprinti("%3i", numbs) + "'><font size='2' color='#000080' face='Verdana'>" \
                             + CatName(nc) + "</font></td>"
                  num0 = num0 + 1
               end if

               ; +++++ Create Variable's Name +++++
               if (ns.eq.0) then
                  body(num0) = "<td align='center' width='100' rowspan='" + sprinti("%2i", dimsizes(k50)) + "'><font size='2' color='#000080' face='Verdana'>" \
                             + AllVarName(k50(0)) + "</font></td>"
                  num0 = num0 + 1
               end if

               ; +++++ Create Source's Name, Data of Certainty and Scale +++++

               Source = str_squeeze(str_get_field(AllSourceName(p50),  1, "("))

               body(num0) = "<td align='center' width='100'><font size='1' color='#000080' face='Verdana'><a class='msout' onmouseout=" + quote \
                          + "this.className='msout';s" + quote + " onmouseover=" + quote + "this.className='msover';" + quote + " href='../readme/readme_" \
                          + str_lower(VarNames(j50)) + "_" + str_upper(Source) + "'> " + AllSourceName(p50) + "</a></font></td>"
               num0 = num0 + 1
               body(num0) = "<td align='center' width='100'><font size='2' color='#000080' face='Verdana'>" \
                          + sprinti("%4i", AllCertainty(p50)) + "</font></td>"
               num0 = num0 + 1
               body(num0) = "<td align='center' width='100'><font size='2' color='#000080' face='Verdana'>" \
                          + sprinti("%4i", AllScale(p50)) + "</font></td>"
               num0 = num0 + 1

               ; +++++ Create Source Data Overall scoring+++++
               if (ns.eq.0) then
                  body(num0) = "<td align='center' width='100' rowspan='" + sprinti("%2i", dimsizes(k50)) + "'><font size='2' color='#000080' face='Verdana'>" \
                             + sprinti("%4i", AllOverall(k50(0))) + "</font></td>"
                  num0 = num0 + 1
               end if

               do nk=0,nkey-1
                  body(num0) = "<td align='center' width='100'><font size='1' color='#000080' face='Verdana'>" \
                             + AllKeyWordID(j50, ns, nk) + "</font></td>"
                  num0 = num0 + 1
               end do

               body(num0) = "</tr>"
               num0 = num0 + 1

               delete(p50)
            end do
         end if
         delete(j50)
         delete(k50)
         delete(ks50)
      end do
   end if
   delete(i50)
end do

body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "<TABLE width='" + swide + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0)= "<td align='left'><font size='2'" + \
            " color='red' face='Verdana'><B>Notes:</B></font>" + \
            "<font size='2' color='black' face='Verdana'>  4 Categories are divided: </font>" + \
            "<font size='2' color='green' face='Verdana'>" + CatName(0) + ", </font>" + \
            "<font size='2' color='blue' face='Verdana'>" + CatName(1) + ", </font>" + \
            "<font size='2' color='red' face='Verdana'>" + CatName(2) + ", </font>" + \
            "<font size='2' color='gray' face='Verdana'>and " + CatName(3) + ". </font></td>"
num0 = num0 + 1
body(num0) = "</tr></table>"
num0 = num0 + 1

body(num0) = "                 "
num0 = num0 + 1
body(num0) = "</body>"
num0 = num0 + 1
body(num0) = "</html>"
num0 = num0 + 1

asciiwrite(HtmlCatWgt,body(0:num0-1))

return (HtmlCatWgt)

end

; ################################################################################################################################
function create_avail_models (CatName:string, CatsID:integer, VarNames:string, ModelNames:string, NumEnsUsedID:integer, NumEnsAvailID:integer, bgcolors:string)

begin

quote = str_get_dq()

nvar=dimsizes(VarNames)
nmod=dimsizes(ModelNames)

ndim=dimsizes(CatsID)
ncat=ndim(0)

delete(ndim)

swide  = sprinti("%i",(nmod+1)*100)

; ++++++ Create the html file +++++

HtmlNumEns = getenv("ILAMB_OUTPUTDIR") + "/www/table_avail_models.html"

body = new((/10000/), string)

num0 = 0
body(num0) = "<html>"
num0 = num0 + 1
body(num0) = "<header>"
num0 = num0 + 1
body(num0) = "<title>Output of ILAMB Diagnostics</title>"
num0 = num0 + 1
body(num0) = "</header>"
num0 = num0 + 1
body(num0) = "<body>"
num0 = num0 + 1

body(num0) = "                           "
num0 = num0 + 1
body(num0) = "<TABLE width='" + swide + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "    <td align='center' height='20'></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "<td align='center' width='" + swide + "'><font size='3' color='black' face='Verdana'> <B>Number of Ensembles Used and Available for Each Variable and Each Model</B></font></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "    <td align='center' height='10'></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "<TABLE width='" + swide + "' BORDER='1'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1

body(num0) = "<tr>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='2' color='#000080' face='Verdana'> <B>Variable</B></font></td>"
num0 = num0 + 1

do nd = 0, nmod-1
   body(num0) = "<td align='center' width='100'><font size='2' color='#000080' face='Verdana'> <B>" + ModelNames(nd) + "</B></font></td>"
   num0 = num0 + 1
end do

body(num0) = "</tr>"
num0 = num0 + 1

do nc=0,ncat-1

   i50 = ind(.not.ismissing(CatsID(nc,:)) .and. CatsID(nc,:).ne.-999)

   if (dimsizes(i50).gt.1 .or. .not.ismissing(i50)) then

      do nv=0,dimsizes(i50)-1

         if (dimsizes(i50).gt.1) then
            j50 = CatsID(nc,i50(nv))
         else
            j50 = CatsID(nc,i50)
         end if

         body(num0) = "<tr bgcolor=" + quote + bgcolors(nc) + quote + ">"
         num0 = num0 + 1

         DataInfo = retrieve_DataInfo (VarNames(j50), "")
         VarLongName = DataInfo@LongName
         delete(DataInfo)

         body(num0) = "<td align='center' width='100'><font size='2' color='#000080' face='Verdana'>" \
                    + VarNames(j50) + " (" + VarLongName + ")</font></td>"
         num0 = num0 + 1

         do nd = 0, nmod-1
            body(num0) = "<td align='center' width='100'><font size='2' color='#000080' face='Verdana'>" \
                       + sprinti("%2i", NumEnsUsedID(j50,nd)) + " (" + sprinti("%2i", NumEnsAvailID(j50,nd)) + " )" + "</font></td>"
            num0 = num0 + 1
         end do

         body(num0) = "</tr>"
         num0 = num0 + 1

         delete(j50)
      end do
   end if
   delete(i50)
end do

body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "<TABLE width='" + swide + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0)= "<td align='left'><font size='2'" + \
            " color='red' face='Verdana'><B>Notes:</B></font>" + \
            "<font size='2' color='black' face='Verdana'> Number of ensembles used and number of ensembles available (in bracket), 4 Categories are divided: </font>" + \
            "<font size='2' color='green' face='Verdana'>" + CatName(0) + ", </font>" + \
            "<font size='2' color='blue' face='Verdana'>" + CatName(1) + ", </font>" + \
            "<font size='2' color='red' face='Verdana'>" + CatName(2) + ", </font>" + \
            "<font size='2' color='gray' face='Verdana'>and " + CatName(3) + ". </font></td>" 
num0 = num0 + 1
body(num0) = "</tr></table>"
num0 = num0 + 1

body(num0) = "                 "
num0 = num0 + 1
body(num0) = "</body>"
num0 = num0 + 1
body(num0) = "</html>"
num0 = num0 + 1

asciiwrite(HtmlNumEns,body(0:num0-1))

return (HtmlNumEns)

end

; ################################################################################################################################
procedure create_check_plots (HtmlPlotsName:string, VarName:string, Sources:string, PlotsFileNames:string, \
                              latlon:float, Keys:string, SubReg:string)

begin

; Retrieve latitude and longitude for global region.
tlon=new((/1000/), float)
tlat=new((/1000/), float)

results = retrieve_latlon_region ("Global", tlat, tlon)

i50 = ind(.not.ismissing(tlon))
j50 = ind(.not.ismissing(tlat))

LonMin0 = min(tlon(i50))
LonMax0 = max(tlon(i50))
LatMin0 = min(tlat(j50))
LatMax0 = max(tlat(j50))

delete(i50)
delete(j50)

; Retrieve latitude and longitude for a specific region.
results = retrieve_latlon_region (SubReg, tlat, tlon)

i50 = ind(.not.ismissing(tlon))
j50 = ind(.not.ismissing(tlat))

LonMin = min(tlon(i50))
LonMax = max(tlon(i50))
LatMin = min(tlat(j50))
LatMax = max(tlat(j50))

delete(i50)
delete(j50)
delete(tlat)
delete(tlon)
delete(results)

widex0  =  800
widey0  =  320
radius  =  5

if (str_lower(SubReg).eq."global.large") then
   widey0  =  360
end if

DX  = LonMax-LonMin
DX0 = LonMax0-LonMin0
DY  = LatMax-LatMin
DY0 = LatMax0-LatMin0

widex = widex0
widey = widey0
widey = floattoint(int2flt(widex)*DY/DX)
widey = floattoint(int2flt(widey0)*(DY*DX0)/(DX*DY0))

; ++++++++++++ Create codes for html file ++++++++++++++
quote = str_get_dq()

swidex  = sprinti("%i",widex)
swidey  = sprinti("%i",widey)
sradius = sprinti("%i",radius)

body = new((/10000/), string)

num0 = 0
body(num0) = "                           "
num0 = num0 + 1
body(num0) = "<html>"
 num0 = num0 + 1
body(num0) = "<head>"
num0 = num0 + 1
body(num0) = "        <title>ILAMB Diagnostics</title>"
num0 = num0 + 1
body(num0) = "</head>"
num0 = num0 + 1
body(num0) = "                            "
num0 = num0 + 1

i50 = ind(.not.ismissing(PlotsFileNames))

if (dimsizes(i50).ge.2) then

   nsit = dimsizes(i50) - 1

   latlon0=new((/4,nsit/), float)
   PlotsFileNames0=new((/nsit+1/), string)

   PlotsFileNames0 = PlotsFileNames(i50)

   if (nsit.eq.1) then
      latlon0(:,0)       = latlon(:,i50(1)-1)
   else
      latlon0(:,:)       = latlon(:,i50(1:)-1)
   end if
      
   PlotsMapFile = PlotsFileNames0(0)

   body(num0) = "<img src=" + quote + PlotsMapFile + quote + " width=" + quote + swidex + quote + " height=" \
              + quote + swidey + quote + " alt=" + quote + "Global" + quote + " usemap=" + quote + "#GlobalMap" + quote + ">"
   num0 = num0 + 1
   body(num0) = "                          "
   num0 = num0 + 1
   body(num0) = "<map name='GlobalMap'>"
   num0 = num0 + 1

   if (dimsizes(Keys).eq.1 .and. str_upper(Keys).eq."SITE") then
      do ns =0, nsit-1
         wide1x = floattoint(widex*((LonMax + latlon0(1,ns))/(LonMax-LonMin)) + 0.5)
         wide1y = floattoint(widey*((LatMax - latlon0(0,ns))/(LatMax-LatMin)) + 0.5)
         swide1x=sprinti("%i",wide1x)
         swide1y=sprinti("%i",wide1y)
         siteinf = "Site (" + sprintf("%10.2f",latlon0(1,ns)) +"," + sprintf("%10.2f",latlon0(0,ns)) + ")"
         siteinf = str_squeeze(siteinf)
         siteinf = str_sub_str(siteinf, " ", "")
         body(num0) = "   <area shape=" + quote + "circle" + quote + " coords=" + quote + swide1x + "," + swide1y + "," \
                    + sradius + quote +  " href=" + quote + PlotsFileNames0(ns+1) + quote + " alt=" + quote + siteinf + quote + ">"
         num0 = num0 + 1
      end do
   else
      do ns =0, nsit-1
         wide1x = floattoint(widex*((LonMax + latlon0(1,ns))/(LonMax-LonMin)) + 0.5)
         wide2x = floattoint(widex*((LonMax + latlon0(3,ns))/(LonMax-LonMin)) + 0.5)
         wide1y = floattoint(widey*((LatMax - latlon0(0,ns))/(LatMax-LatMin)) + 0.5)
         wide2y = floattoint(widey*((LatMax - latlon0(2,ns))/(LatMax-LatMin)) + 0.5)
         swide1x=sprinti("%i",wide1x)
         swide2x=sprinti("%i",wide2x)
         swide1y=sprinti("%i",wide1y)
         swide2y=sprinti("%i",wide2y)
         siteinf = "Region (" + sprintf("%10.2f",latlon0(1,ns)) + "->" + sprintf("%10.2f",latlon0(3,ns)) + "," \
                 + sprintf("%10.2f",latlon0(0,ns)) + "->" + sprintf("%10.2f",latlon0(2,ns)) + ")"
         siteinf = str_squeeze(siteinf)
         siteinf = str_sub_str(siteinf, " ", "")
         body(num0) = "   <area shape=" + quote + "rect" + quote + " coords=" + quote + swide1x + "," \
                    + swide1y + "," + swide2x + "," + swide2y + quote +  " href=" + quote + PlotsFileNames0(ns+1) \
                    + quote + " alt=" + quote + siteinf + quote + ">"
         num0 = num0 + 1
      end do
   end if

   body(num0) = "</map>"
   num0 = num0 + 1
end if

body(num0) = "                                   "
num0 = num0 + 1
body(num0) = "</html>"
num0 = num0 + 1

asciiwrite(HtmlPlotsName,body(0:num0-1))

end

; ################################################################################################################################
procedure create_table_weights (VarName:string, Source:string, MetrixName[*]:string, WgtData[*]:integer)

begin

quote = str_get_dq()

nkey=dimsizes(MetrixName)

HtmlTableWgt = getenv("ILAMB_OUTPUTDIR") + "/www/weights_" + str_lower(VarName) + "_" + str_upper(Source) + ".html"

body = new((/10000/), string)

num0 = 0
body(num0) = "<html>"
num0 = num0 + 1
body(num0) = "<header>"
num0 = num0 + 1
body(num0) = "<title>Output for ILAMB Diagnostics</title>"
num0 = num0 + 1
body(num0) = "</header>"
num0 = num0 + 1
body(num0) = "<body>"
num0 = num0 + 1

body(num0) = "                           "
num0 = num0 + 1
body(num0) = "<TABLE width='500' BORDER='0'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "    <td align='center' height='20'></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "<td align='center' width='500'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='3' color='black' face='Verdana'> <B>Scoring Metrics for Overall Score</B></font></td></table></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "    <td align='center' height='10'></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "<TABLE width='500' BORDER='1'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1

body(num0) = "<tr>"
num0 = num0 + 1

body(num0) = "<td align='center' width='300'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'> <B>Scoring Metrics</B></font></td></table></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'> <B>Contribution</B></font></td></table></td>"
num0 = num0 + 1

body(num0) = "</tr>"
num0 = num0 + 1

if (any(WgtData.gt.0)) then
   do nk=0, nkey-1
      body(num0) = "<tr>"
      num0 = num0 + 1

      body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'>" + MetrixName(nk) + \
                "</font></td></table></td>"
      num0 = num0 + 1

      body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'>" + \
                sprinti("%4i", WgtData(nk)) + "</font></td></table></td>"
      num0 = num0 + 1

      body(num0) = "</tr>"
      num0 = num0 + 1
   end do
end if

body(num0) = "</table>"
num0 = num0 + 1
body(num0) = "<BR>"
num0 = num0 + 1

body(num0) = "                 "
num0 = num0 + 1
body(num0) = "</body>"
num0 = num0 + 1
body(num0) = "</html>"
num0 = num0 + 1

asciiwrite(HtmlTableWgt,body(0:num0-1))

end

; ################################################################################################################################
procedure create_table (HtmlTableName:string, HtmlPlotsName:string, VarNames:string, VarUnits:string, Sources:string, \
                        Refers:string, ModelNames:string, KeyWords:string, Values:float, PlotsFileNames:string, \
                        Period:string, SubReg1:string, SubReg2:string, nck:integer)

begin

DataDir = getenv("ILAMB_ROOT")
DataDir0 = getenv("ILAMB_OUTPUTDIR") + ""

DataInfo = retrieve_DataInfo (VarNames, Sources)

if (.not.ismissing(SubReg1) .and. .not.(str_is_blank(SubReg1)) .or. nck.ge.1) then
   if (any(str_lower(DataInfo@Dimens).eq.(/"d1","d2","d3","ds"/))) then
      SubRegDiag = "no"
   else
      SubRegDiag = "yes"
   end if
else
   SubRegDiag = "no"
end if

if ((str_lower(Sources).eq."noaa.gmd") .and. (str_lower(SubReg2).eq."global")) then
   SubReg2 = "global.large"
end if

DataInfo    = retrieve_DataInfo ( VarNames, Sources)
VarLongName = DataInfo@LongName
delete(DataInfo)

StartYear   = stringtoint(str_get_field(Period, 1, "-"))
EndYear     = stringtoint(str_get_field(Period, 2, "-"))

quote = str_get_dq()

nkey=dimsizes(KeyWords)
nmod=dimsizes(ModelNames)

Values@_FillValue = -999

Key1 = new((/100/), string)
Key2 = new((/100/), string)

   nk1=0
   nk2=0
do nk=0,nkey-1
   KeyLongName = retrieve_LongName (KeyWords(nk))
   KeyLongName = str_squeeze(str_sub_str(KeyLongName, "Score", ""))
   if (any(str_lower(KeyWords(nk)).eq.(/"annualmean", "bias", "rmse", "phase"/))) then
      if (str_lower(KeyWords(nk)).eq."phase") then
         Key1(nk1) = KeyLongName + " (months)"
      else
         Key1(nk1) = KeyLongName + " (" + VarUnits(nk) + ")"
      end if
      nk1=nk1+1
   else
      Key2(nk2) = KeyLongName
      nk2=nk2+1
   end if
end do

Keys1=Key1(0:nk1-1)
Keys2=Key2(0:nk2-1)

delete(Key1)
delete(Key2)

;++++++++++++ Read Sub-region analysis from saved data files ++++++++++++

HtmlPlotsNameReg = new((/nmod/), string)

if (str_lower(SubRegDiag).eq."yes") then

   DataDirPlot1 = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames) + "/biomes"
   DataDirPlot2 = "../" + str_lower(VarNames) + "/biomes"

   PlotFileName1 = DataDirPlot1 + "/map_biomes_" + str_upper(SubReg1) + ".png" 
  
   PlotFileName2 = DataDirPlot2 + "/plots/PNG" + "/map_biomes_" + str_upper(SubReg1) + ".png"

   if (fileexists(PlotFileName1)) then
      PlotsNameReg = PlotFileName2
   else
      PlotsNameReg = ""
   end if

   FileName = DataDirPlot1 + "/locations_" + str_lower(VarNames) \
            + "_" + str_upper(Sources) + ".txt"

   if (fileexists(FileName)) then
      print(FileName)

      data_1d  = asciiread(str_squeeze(FileName),-1,"string")
      ;print(data_1d)

      cdata    = stringtochar(data_1d)

      Keys     = charactertostring(cdata(3:, 0:40))
      lat1     = stringtofloat(charactertostring(cdata(3:,45:52)))
      lon1     = stringtofloat(charactertostring(cdata(3:,57:63)))
      lat2     = stringtofloat(charactertostring(cdata(3:,69:75)))
      lon2     = stringtofloat(charactertostring(cdata(3:,81:87)))
      Vars     = stringtofloat(charactertostring(cdata(3:,93:99)))

      lon1     = where(lon1.gt.180, lon1-360, lon1) 
      lon2     = where(lon2.gt.180, lon2-360, lon2) 

      nsit     = dimsizes(lat1)
      latlon   = new((/4,nsit/), float)

      latlon(0,:) = lat1
      latlon(1,:) = lon1
      latlon(2,:) = lat2
      latlon(3,:) = lon2

      delete(lat1)
      delete(lon1)
      delete(lat2)
      delete(lon2)

      delete(cdata)
      delete(data_1d)

      PlotsFileNamesReg = new((/nmod,nsit+1/), string)

      DataDirPlot1 = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames) + "/biomes"
      DataDirPlot2 = "../" + str_lower(VarNames) + "/biomes"

      do nd = 0, nmod-1

         if (nd.eq.0) then
            ModelName1   = str_upper(Sources)
            ModelName2   = "CMIP5"
         else
            ModelName1   = ModelNames(nd)
            ModelName2   = ModelNames(nd)
         end if

         PlotFileName1 = DataDirPlot1 + "/annualmean" + "_" + str_lower(VarNames) + "_" + ModelName1 \
                       + ".vs." + str_upper(Sources) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
  
         PlotFileName2 = DataDirPlot2 + "/plots/PNG" + "/annualmean" + "_" + str_lower(VarNames) + "_" + ModelName1 \
                       + ".vs." + str_upper(Sources) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"

         if (fileexists(PlotFileName1)) then
            PlotsFileNamesReg(nd,0) = PlotFileName2
         end if

         do ns=0,nsit-1
            PlotFileName1 = DataDirPlot1 + "/check_subreg" + sprinti("%i",ns+1) + "_" + str_lower(VarNames) \
                          + "_" + ModelName2 + ".vs." + str_upper(Sources) + "_" + sprinti("%0.4i",StartYear) \
                          + "-" + sprinti("%0.4i",EndYear) + ".png"

            PlotFileName2 = DataDirPlot2 + "/plots/PNG" + "/check_subreg" + sprinti("%i",ns+1) + "_" + str_lower(VarNames) \
                          + "_" + ModelName2 + ".vs." + str_upper(Sources) + "_" + sprinti("%0.4i",StartYear) + "-" \
                          + sprinti("%0.4i",EndYear) + ".png"

            if (fileexists(PlotFileName1)) then
               PlotsFileNamesReg(nd,ns+1) = PlotFileName2
            end if
         end do

         HtmlPlotsNameReg(nd) = DataDir0 + "/www/plot_subreg" + "_" + str_lower(VarNames) + "_" + str_upper(Sources) + "_" + ModelName2 + ".html"

         create_check_plots (HtmlPlotsNameReg(nd), VarLongName, Sources, PlotsFileNamesReg(nd,0:nsit), latlon, Keys, SubReg2)
         HtmlPlotsNameReg(nd) = str_sub_str(HtmlPlotsNameReg(nd), getenv("ILAMB_OUTPUTDIR") + "/www/", "")
      end do

      delete(latlon)
   else
      HtmlPlotsNameReg = ""
   end if
else
   HtmlPlotsNameReg = ""
end if

;++++++++++++ Read Time Series Comparison from saved data files ++++++++++++
; ++++++ input control parameters from a file: ../CODES/tempfiles/input_para_check* +++++

HtmlPlotsNameSite = new((/nmod/), string)

if (nck.ge.1) then

   PlotsFileNamesSite = new((/nmod, 1000/), string)

   ;++++ read data from saved files ++++

   FileName1 = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_check" + sprinti("%0.2i",nck)
   print(FileName1)

   data_1d  = asciiread(str_squeeze(FileName1),-1,"string")
   ;print(data_1d)

   VarNameSite = str_squeeze(str_get_field(data_1d(1), 2, ":"))
   VarUnitSite = str_squeeze(str_get_field(data_1d(2), 2, ":"))
   SourceRef   = str_squeeze(str_get_field(data_1d(6), 2, ":"))

   SourceSite  = str_squeeze(str_get_field(SourceRef, 1, "("))

   StartYear    = stringtointeger(str_get_field(data_1d(9),  2, ":"))
   EndYear      = stringtointeger(str_get_field(data_1d(10), 2, ":"))

   delete(data_1d)

   if (str_upper(SourceSite).eq.str_upper(Sources)) then

      nck0 = nck

      FileName2 = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNameSite) + "/check/locations_" + str_lower(VarNameSite) \
              + "_" + str_upper(SourceSite) + ".txt"
      print(FileName2)

      TableFileNameSite1 = FileName2
      TableFileNameSite2 = "../" + str_lower(VarNameSite) + "/check/tables/locations_" + str_lower(VarNameSite) \
              + "_" + str_upper(SourceSite) + ".txt"

      data_1d  = asciiread(str_squeeze(FileName2),-1,"string")
      ;print(data_1d)

      KeySite     = str_squeeze(str_get_field(data_1d(1), 2, ":"))

      lat1     = stringtofloat(str_get_field(data_1d(3:), 2, " "))
      lon1     = stringtofloat(str_get_field(data_1d(3:), 3, " "))

      lon1     = where(lon1.gt.180, lon1-360, lon1) 

      nsit     = dimsizes(lat1)
      latlon   = new((/4,nsit/), float)

      latlon(0,:) = lat1
      latlon(1,:) = lon1

      if (str_upper(KeySite).eq."REGION") then
         lat2        = stringtofloat(str_get_field(data_1d(3:), 3, " "))
         lon2        = stringtofloat(str_get_field(data_1d(3:), 4, " "))
         lon2        = where(lon2.gt.180, lon2-360, lon2) 
         latlon(2,:) = lat2
         latlon(3,:) = lon2
         delete(lat2)
         delete(lon2)
      end if

      delete(lat1)
      delete(lon1)

      delete(data_1d)

      DataDirPlot1 = DataDir0 + "/" + str_lower(VarNameSite) + "/check"
      DataDirPlot2 = "../" + str_lower(VarNameSite) + "/check"

      PlotFileName1 = DataDirPlot1 + "/annualmean" + "_" + str_lower(VarNameSite) + "_" + \
                      str_upper(SourceSite) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
  
      PlotFileName2 = DataDirPlot2 + "/plots/PNG" + "/annualmean" + "_" + str_lower(VarNameSite) + "_" + \
                      str_upper(SourceSite) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"

      if (fileexists(PlotFileName1)) then
         PlotsFileNamesSite(:,0) = PlotFileName2
      end if

      do nd = 0, nmod-1

         if (nd.eq.0) then
            ModelName   = "CMIP5"
         else
            ModelName   = ModelNames(nd)
         end if

         do ns=0,nsit-1
            PlotFileName1 = DataDirPlot1 + "/check_point" + sprinti("%i",ns+1) + "_" + str_lower(VarNameSite) + "_" + ModelName \
                          + ".vs." + str_upper(SourceSite) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"

            PlotFileName2 = DataDirPlot2 + "/plots/PNG" + "/check_point" + sprinti("%i",ns+1) + "_" + str_lower(VarNameSite) + "_" + ModelName \
                          + ".vs." + str_upper(SourceSite) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"

            if (fileexists(PlotFileName1)) then
               PlotsFileNamesSite(nd,ns+1) = PlotFileName2
            end if
         end do

         DataInfo        = retrieve_DataInfo (VarNameSite, SourceSite)
         VarLongNameSite = DataInfo@LongName
         delete(DataInfo)

         HtmlPlotsNameSite(nd) = DataDir0 + "/www/plot_check" + "_" + str_lower(VarNameSite) + "_" + str_upper(SourceSite) + "_" + ModelName + ".html"
    
         create_check_plots (HtmlPlotsNameSite(nd), VarLongNameSite, SourceSite, PlotsFileNamesSite(nd,0:nsit), latlon, KeySite, SubReg2)
         HtmlPlotsNameSite(nd) = str_sub_str(HtmlPlotsNameSite(nd), getenv("ILAMB_OUTPUTDIR") + "/www/", "")

      end do

      delete(latlon)
   else
      nck0 = 0
      HtmlPlotsNameSite = ""
   end if
else
   nck0 = 0
   HtmlPlotsNameSite = ""
end if

; ++++++ Create a html file name of a metric weighting ++++++++ 
if (str_lower(SubRegDiag).eq."yes") then
   if (.not.ismissing(SubReg1) .and. .not.(str_is_blank(SubReg1))) then
      if (nck0.ge.1) then
         swide12 = sprinti("%i",(nk1+nk2+2)*100)
         swide   = sprinti("%i",200)
         swide1  = sprinti("%i",nk1*100)
         swide2  = sprinti("%i",nk2*100)
      else
         swide12 = sprinti("%i",(nk1+nk2+1)*100)
         swide   = sprinti("%i",100)
         swide1  = sprinti("%i",nk1*100)
         swide2  = sprinti("%i",nk2*100)
      end if
   else
      if (nck0.ge.1) then
         swide12 = sprinti("%i",(nk1+nk2+1)*100)
         swide   = sprinti("%i",100)
         swide1  = sprinti("%i",nk1*100)
         swide2  = sprinti("%i",nk2*100)
      else
         swide12 = sprinti("%i",(nk1+nk2)*100)
         swide1  = sprinti("%i",nk1*100)
         swide2  = sprinti("%i",nk2*100)
      end if
   end if
else
   swide12 = sprinti("%i",(nk1+nk2)*100)
   swide1  = sprinti("%i",nk1*100)
   swide2  = sprinti("%i",nk2*100)
end if

HtmlTableWgt = "weights_" + str_lower(VarNames) + "_" + str_upper(Sources) + ".html"

body = new((/10000/), string)

header = html_head(VarLongName, Sources)
tailer = html_tail

num1 = dimsizes(header)
num2 = dimsizes(tailer)

body(0:num1-1)=header

num0 = num1

body(num0) = "                           "
num0 = num0 + 1
body(num0) = "<TABLE width='" + swide12 + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "    <td align='center' height='0'></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "<BR>"
num0 = num0 + 1

body(num0) = "<TABLE width='" + swide12 + "' BORDER='1'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1

body(num0) = "<tr>"
num0 = num0 + 1

;body(num0) = "<TABLE width='" + swide12 + "' BORDER='1'  !BGCOLOR='#dbedc0'>"
;num0 = num0 + 1

body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1' color='#000080' face='Verdana'> <B></B></font></td></table></td>"
num0 = num0 + 1

if (nk1.ge.1) then
   body(num0) = "<td align='center' width='" + swide1 + "'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1' color='#000080' face='Verdana'> <B>Global Patterns</B></font></td></table></td>"
   num0 = num0 + 1
end if

if (str_lower(SubRegDiag).eq."yes") then
   body(num0) = "<td align='center' width='" + swide + "'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1' color='#000080' face='Verdana'> <B>Regional and Seasonal Patterns</B></font></td></table></td>"
   num0 = num0 + 1
end if

if (nk2.ge.1) then
   body(num0) = "<td align='center' width='" + swide2 + "'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1' color='#000080' face='Verdana'> <B>Scoring</B> (" \
              + "<a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + HtmlTableWgt \
              + "'>Info</a>)</font></td></table></td>"
   num0 = num0 + 1
end if

body(num0) = "</tr>"
num0 = num0 + 1

body(num0) = "<tr>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
             " color='#000080' face='Verdana'> <B></B></font></td></table></td>"
num0 = num0 + 1

if (nk1.ge.1) then
   body(num0) = "<td><table><tr>"
   num0 = num0 + 1
   do nk=0, nk1-1
      body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                  " color='#000080' face='Verdana'><a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
                  " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + HtmlPlotsName(nk) + \
                  "'><B>" + Keys1(nk) + "</B></a></font></td></table></td>"
      num0 = num0 + 1
   end do
   body(num0) = "</tr></table></td>"
   num0 = num0 + 1
end if

if (str_lower(SubRegDiag).eq."yes") then
   body(num0) = "<td><table><tr>"
   num0 = num0 + 1
   if (.not.ismissing(SubReg1) .and. .not.(str_is_blank(SubReg1))) then
      if (.not.(str_is_blank(PlotsNameReg))) then
         body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                      " color='#000080' face='Verdana'><a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
                      " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + PlotsNameReg + \
                      "'>Regional</a> Means</font></td></table></td>"
;                      "'><B>" + str_upper(SubReg1) + "</B></a>" + " Regions</font></td></table></td>"
         num0 = num0 + 1
      else
         body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1' color='#000080' face='Verdana'>" \
                    + "Regional Means</font></td></table></td>"
;                    +  str_upper(SubReg1) + " Regions</font></td></table></td>"
         num0 = num0 + 1
      end if
   end if

   if (nck0.ge.1) then
      if (.not.(str_is_blank(TableFileNameSite1))) then
         body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                      " color='#000080' face='Verdana'><a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
                      " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + TableFileNameSite2 + \
                      "'>Individual</a> Sites</font></td></table></td>"
;                      "'><B>" + str_upper(SubReg1) + "</B></a>" + " Regions</font></td></table></td>"
         num0 = num0 + 1
      else
         body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1' color='#000080' face='Verdana'>" \
                    + "Individual Sites</B></font></td></table></td>"
         num0 = num0 + 1
      end if
   end if
   body(num0) = "</tr></table></td>"
   num0 = num0 + 1
end if

if (nk2.ge.1) then
   body(num0) = "<td><table><tr>"
   num0 = num0 + 1
   do nk=0, nk2-1
      body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                  " color='#000080' face='Verdana'><a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
                  " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + HtmlPlotsName(nk+nk1) + \
                  "'><B>" + Keys2(nk) + "</B></a></font></td></table></td>"
      num0 = num0 + 1
   end do
   body(num0) = "</tr></table></td>"
   num0 = num0 + 1
end if

body(num0) = "</tr>"
num0 = num0 + 1

do nd=0, nmod-1

   body(num0) = "<tr>"
   num0 = num0 + 1

   if (str_lower(ModelNames(nd)).eq."benchmark") then
      body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                   " color='#000080' face='Verdana'><B>" + ModelNames(nd) + "&nbsp;</B><a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
                   " onmouseover=" + quote + "this.className='msover';" + quote + " href='../readme/readme_" + str_lower(VarNames(0)) + \
                   "_" + str_upper(Sources) + "'> [" + Refers + "]</a></font></td></table></td>"
   else
      body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                 " color='#000080' face='Verdana'><B>" + ModelNames(nd) + "</B></font></td></table></td>"
   end if

   num0 = num0 + 1

   if (nk1.ge.1) then
      body(num0) = "<td><table><tr>"
      num0 = num0 + 1

      do nk=0, nk1-1

         if (ismissing(Values(nk,nd))) then
            body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                        " color='#000080' face='Verdana'><B>" + "-" + "</B></font></td></table></td>"
         else
            if (max(abs(Values(0,:))).ge.10) then
               body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                         " color='#000080' face='Verdana'><a href='" + PlotsFileNames(nk,nd) + "'><B>" + sprintf("%8.1f", Values(nk,nd)) + \
                         "</B></a></font></td></table></td>"
            else
               body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                         " color='#000080' face='Verdana'><a href='" + PlotsFileNames(nk,nd) + "'><B>" + sprintf("%8.2f", Values(nk,nd)) + \
                         "</B></a></font></td></table></td>"
            end if
         end if

         num0 = num0 + 1
      end do

      body(num0) = "</tr></table></td>"
      num0 = num0 + 1
   end if

   if (str_lower(SubRegDiag).eq."yes") then
      body(num0) = "<td><table><tr>"
      num0 = num0 + 1
      if (.not.ismissing(SubReg1) .and. .not.(str_is_blank(SubReg1))) then
         if (.not.(str_is_blank(HtmlPlotsNameReg(nd)))) then
            body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                         " color='#000080' face='Verdana'>access to <a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
                         " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + HtmlPlotsNameReg(nd) + \
                         "'><B>plots</B></a></font></td></table></td>"
            num0 = num0 + 1
         else
            body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                      " color='#000080' face='Verdana'><B>" + "-" + "</B></font></td></table></td>"
            num0 = num0 + 1
         end if
      end if

      if (nck0.ge.1) then
         if (.not.(str_is_blank(HtmlPlotsNameSite(nd)))) then
            body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                         " color='#000080' face='Verdana'>access to <a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
                         " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + HtmlPlotsNameSite(nd) + \
                         "'><B>plots</B></a></font></td></table></td>"
            num0 = num0 + 1
         else
            body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                      " color='#000080' face='Verdana'><B>" + "-" + "</B></font></td></table></td>"
            num0 = num0 + 1
         end if
      end if

      body(num0) = "</tr></table></td>"
      num0 = num0 + 1
   end if

   if (nk2.ge.1) then
      body(num0) = "<td><table><tr>"
      num0 = num0 + 1

      do nk=0, nk2-1

         if (ismissing(Values(nk+nk1,nd))) then
            body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                        " color='#000080' face='Verdana'><B>" + "-" + "</B></font></td></table></td>"
         else
            body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                        " color='#000080' face='Verdana'><a href='" + PlotsFileNames(nk+nk1,nd) + "'><B>" + sprintf("%8.2f", Values(nk+nk1,nd)) + \
                        "</B></a></font></td></table></td>"
         end if

         num0 = num0 + 1
      end do

      body(num0) = "</tr></table></td>"
      num0 = num0 + 1
   end if

   body(num0) = "</tr>"
   num0 = num0 + 1
   body(num0) = "                    "
   num0 = num0 + 1
end do
body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "<TABLE width='" + swide12 + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "<td align='left'><font size='2'" \
           + " color='red' face='Verdana'><B>" + "Notes: In calculating overall score, rmse score contributes double" \
           + " in comparison with all other scores. " + "</B></font></td>"
num0 = num0 + 1

body(num0) = "</tr></table>"
num0 = num0 + 1

body(num0) = "<BR>"
num0 = num0 + 1
body(num0) = "<BR>"
num0 = num0 + 1

body(num0:num0+num2-1)=tailer

num0=num0+num2

asciiwrite(HtmlTableName,body(0:num0-1))

end

; ################################################################################################################################
function  create_html_table (HtmlTableName:string, HtmlPlotsName:string, VarName:string, Sources:string, \
                             KeyWords:string, StartYears:integer, EndYears:integer, ModelNames:string,   \
                             Refers:string, wgt:float, SubReg1:string, SubReg2:string, nck:integer)
begin

DataDir  = getenv("ILAMB_ROOT")
DataDir0 = getenv("ILAMB_OUTPUTDIR") + ""

;results   = retrieve_others("Metrics", "-999")
;KeyWord0  = results@Category
;nkey      = dimsizes(KeyWord0)
;
;delete(results)
;delete(KeyWord0)

nsur=dimsizes(Sources)
nmod=dimsizes(ModelNames)
nkey=dimsizes(KeyWords)

if (nsur.gt.1) then
   do ns=0,nsur-1
      if (ns.eq.0) then
         Source0=Sources(ns)
      else
         Source0=Source0 + "+" + Sources(ns)
      end if
   end do
   StartYear0 = min(StartYears)
   EndYear0   = max(EndYears)
else
   Source0    = Sources
   StartYear0 = StartYears
   EndYear0   = EndYears
end if

DataDirPlot = DataDir0 + "/" + str_lower(VarName) + "/summary"

HtmlTableNames = new((/100/), string)
ModelNamess    = new((/100,nkey,nmod+1/), string)
PlotsFileNames = new((/100,nkey,nmod+1/), string)
Periods        = new((/100/), string)
VarUnits       = new((/100,nkey/), string)
Sources0       = new((/nsur+1/), string)
Value          = new((/100,nkey,nmod+1/), float)
wgt0           = new((/100,nkey/), float)

MetrixName = new((/100,nkey/), string)
WgtData    = new((/100,nkey/), integer)

Sources0(0:nsur-1)  = Sources
Sources0(nsur)      = Source0

Value=-999

MetrixName = "N/A"
WgtData    = -999

do ns=0,nsur-1

   if (nsur.gt.1) then
      Source    = Sources(ns)
      StartYear = StartYears(ns)
      EndYear   = EndYears(ns)
   else
      Source    = Sources
      StartYear = StartYears
      EndYear   = EndYears
   end if

   TableFileName = DataDirPlot + "/summary_" + str_lower(VarName) + "_" + "CMIP5" + ".vs." + str_upper(Source) + "_" + \
                   sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".txt"

   if (fileexists(TableFileName)) then
      print(TableFileName)

      data_1d = asciiread(TableFileName,-1,"string")
      ;print(data_1d)

      Sources0(ns) = str_get_field(data_1d(3), 2, ":")
      Periods(ns)  = str_get_field(data_1d(4), 2, ":")

      nkey0        = dimsizes(str_split(data_1d(6)," ")) - 1

      KeyWord0 = new((/nkey0/), string)

      do nk=0,nkey0-1
         KeyWord0(nk)      = str_get_field(data_1d(6), nk+2, " ")
         VarUnits(ns,nk)   = str_get_field(data_1d(8), nk+2, " ")
      end do

      ModelName0   = str_squeeze(str_get_field(data_1d(9:), 1, " "))

      nmod0=dimsizes(ModelName0)

      do nk=0,nkey0-1

         wgt0(ns, nk)             = stringtofloat(str_get_field(data_1d(7 ), nk+2, " "))
         Value(ns, nk, 0:nmod0-1) = stringtofloat(str_get_field(data_1d(9:), nk+2, " "))

         if (nkey0.gt.1) then
            KeyWord = KeyWord0(nk)
         else
            KeyWord = KeyWord0
         end if

         KeyWord=str_squeeze(KeyWord)

         DataDirPlot1 = DataDir0 + "/" + str_lower(VarName) + "/" + str_lower(KeyWord)
         DataDirPlot2 = "../" + str_lower(VarName) + "/" + str_lower(KeyWord)

         if (any(str_lower(KeyWord).eq.(/"overallscore", "taylorscore"/))) then
            ModelNamess(ns,nk,0) = Source
            ModelNamess(ns,nk,1) = "CMIP5"
            ModelName      = ModelNamess(ns,nk,1)
            PlotsFileName1 = DataDirPlot1 + "/" + str_lower(KeyWord) + "_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                             str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
            PlotsFileName2 = DataDirPlot2 + "/plots/PNG/" + str_lower(KeyWord) + "_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                             str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
            if (fileexists(PlotsFileName1)) then
               PlotsFileNames(ns,nk,1:nmod) = PlotsFileName2
            end if
         else
            ModelNamess(ns,nk,0)=Source
            ModelNamess(ns,nk,1:nmod)=ModelNames
            do nd=0,nmod
               if (any(str_upper(Source).eq.(/"GCP", "HOFFMAN", "MAUNA.LOA"/))) then
                  if (str_lower(KeyWord).eq."annualmean") then
                     ModelName      = ModelNamess(ns,nk,nd)
                  else
                     ModelName      = "CMIP5"
                  end if
               else
                  if (str_upper(Source).eq."NOAA.GMD" .and. any(KeyWord.eq.(/"phase", "phasescore", "rmse", "rmsescore"/))) then
                     ModelName      = "CMIP5"
                  else
                     ModelName      = ModelNamess(ns,nk,nd)
                  end if
               end if
               PlotsFileName1 = DataDirPlot1 + "/" + str_lower(KeyWord) + "_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                                str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
               PlotsFileName2 = DataDirPlot2 + "/plots/PNG/" + str_lower(KeyWord) + "_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                                str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
               if (fileexists(PlotsFileName1)) then
                  PlotsFileNames(ns,nk,nd)  = PlotsFileName2
               end if
            end do
         end if

         DataDirPlot1 = DataDir0 + "/" + str_lower(VarName) + "/overallscore"
         DataDirPlot2 = "../" + str_lower(VarName) + "/overallscore"

         i50 = ind(str_lower(KeyWords).eq."overallscore")

         ModelNamess(nsur,i50,0) = Source0
         ModelNamess(nsur,i50,1) = "CMIP5"
         ModelName            = ModelNamess(nsur,i50,1)
         PlotsFileName1 = DataDirPlot1 + "/overallscore_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                          str_upper(Source0) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
         PlotsFileName2 = DataDirPlot2 + "/plots/PNG/overallscore_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                          str_upper(Source0) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
         if (fileexists(PlotsFileName1)) then
            PlotsFileNames(nsur,i50,1:nmod) = PlotsFileName2
         end if

         delete(i50)
      end do

      delete(KeyWord0)
      delete(data_1d)
   end if

   TableFileName = DataDir0 + "/" + str_lower(VarName) + "/overallscore/weights_" + str_lower(VarName) + "_CMIP5.vs." \
                 + str_upper(Source) + ".txt"

   if (fileexists(TableFileName)) then
      print(TableFileName)

      data_1d = asciiread(TableFileName,-1,"string")
      ;print(data_1d)

      MetrixName0 = str_get_field(data_1d(2:), 1, ":")
      WgtData0    = stringtointeger(str_get_field(data_1d(2:), 2, ":"))

      nkey0 = dimsizes(MetrixName0)

      MetrixName(ns,0:nkey0-1) = MetrixName0
      WgtData(ns,0:nkey0-1)    = WgtData0

      delete(nkey0)
      delete(data_1d)
      delete(WgtData0)
      delete(MetrixName0)
   else
      WgtData(ns,:)            = 0
   end if
end do

Source    = Source0
StartYear = StartYear0
EndYear   = EndYear0

TableFileName = DataDirPlot + "/summary_" + str_lower(VarName) + "_" + "CMIP5" + ".vs." + str_upper(Source) + "_" + \
                sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".txt"

if (fileexists(TableFileName)) then

   print(TableFileName)

   data_1d = asciiread(TableFileName,-1,"string")
   ;print(data_1d)

   VarUnit        = str_squeeze(str_get_field(data_1d(2), 2, ":"))
   Sources0(nsur) = str_get_field(data_1d(3), 2, ":")
   Periods(nsur)  = str_get_field(data_1d(4), 2, ":")

   nkey0        = dimsizes(str_split(data_1d(6)," ")) - 1

   KeyWords0 = new((/nkey0/), string)

   do nk=0,nkey0-1
      KeyWords0(nk)      = str_get_field(data_1d(6), nk+2, " ")
      VarUnits(nsur,nk)  = str_get_field(data_1d(8), nk+2, " ")
   end do

   ModelNames0  = str_squeeze(str_get_field(data_1d(9:), 1, " "))

   nmod0=dimsizes(ModelNames0)

   do nk=0,nkey0-1

      wgt0(nsur, nk)             = stringtofloat(str_get_field(data_1d(7 ), nk+2, " "))
      Value(nsur, nk, 0:nmod0-1) = stringtofloat(str_get_field(data_1d(9:), nk+2, " "))

   end do

   delete(data_1d)
end if

Value@_FillVlue = -999

do ns=0, nsur-1

   HtmlTableWgt = getenv("ILAMB_OUTPUTDIR") + "/www/weights_" + str_lower(VarName) + "_" + str_upper(Sources(ns)) + ".html"

   ; ++++++ create a table of weighting for each variable and each source  ++++++
   i50 = ind(WgtData(ns,:).ge.0)
   if (dimsizes(i50).gt.1 .or. .not.ismissing(i50))
      create_table_weights (VarName, Sources(ns), MetrixName(ns,i50), WgtData(ns,i50))
   end if
   delete(i50)

   KeyID = new((/nkey0/), integer)

   KeyID = 1

   do nk=0,nkey0-1
      ij50 = ind(Value(ns,nk,:).eq.-999)
      if (dimsizes(ij50).eq.nmod+1) then
         KeyID(nk) = 0
      end if
      delete(ij50)
   end do

   j50 = ind(KeyID.eq.1)

   ; ++++++ create a table of diagnostics for each variable and each source ++++++
   create_table (HtmlTableName(ns), HtmlPlotsName(ns,j50), VarName, VarUnits(ns,j50), Sources(ns), Refers(ns), ModelNames0, KeyWords0(j50), Value(ns,j50,:), \
                 PlotsFileNames(ns,j50,:), Periods(ns), SubReg1, SubReg2, nck(ns))
   delete(j50)
   delete(KeyID)
end do

; ++++++++ Weightings here are based on numbers of observations +++++++
if (nsur.eq.1) then
   wgt(0:nkey0-1) = wgt0(0,0:nkey0-1)
else
   wgt(0:nsur-1, 0:nkey0-1) = wgt0(0:nsur-1,0:nkey0-1)
end if

return(Value(0:nsur-1,nkey0-1,1:nmod0-1))

end

; ################################################################################################################################
procedure create_table_sources (HtmlTableName:string, HtmlTableNameSources:string, VarNames:string, Sources:string, Refers:string, wgts:float)

begin

DataDir  = getenv("ILAMB_ROOT")
DataDir0 = getenv("ILAMB_OUTPUTDIR") + ""

quote = str_get_dq()

nsur=dimsizes(Sources)

body = new((/10000/), string)
Sources0 = new((/nsur/), string)

Sources0=Sources

if (nsur.eq.1) then
   DataInfo = retrieve_DataInfo (VarNames, Sources)
   Sources0 = DataInfo@DataName
   delete(DataInfo)
else
   do ns=0,nsur-1
      DataInfo     = retrieve_DataInfo (VarNames, Sources(ns))
      Sources0(ns) = DataInfo@DataName
      delete(DataInfo)
   end do
end if

header = html_head(VarNames(0), Sources)
tailer = html_tail

num1 = dimsizes(header)
num2 = dimsizes(tailer)

body(0:num1-1)=header

num0 = num1

body(num0) = "                           "
num0 = num0 + 1
body(num0) = "<TABLE width='300' BORDER='0'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "    <td align='center' height='10'></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "<TABLE width='800' BORDER='1'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1

body(num0) = "<tr>"
num0 = num0 + 1

body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'> <B>Dataset</B></font></td></table></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'> <B>Reference</B></font></td></table></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'> <B>Contribution</B></font></td></table></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'> <B>Analysis</B></font></td></table></td>"
num0 = num0 + 1

body(num0) = "</tr>"
num0 = num0 + 1

do ns=0, nsur-1
   body(num0) = "<tr>"
   num0 = num0 + 1

   body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'> <B>" + Sources0(ns) + \
                "</B></font></td></table></td>"
   num0 = num0 + 1

   body(num0)= "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2'" + \
               " color='#000080' face='Verdana'><a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
               " onmouseover=" + quote + "this.className='msover';" + quote + " href='../readme/readme_" + str_lower(VarNames(0)) + \
               "_" + str_upper(Sources(ns)) + "'><B>" + Refers(ns) + "</B></a></font></td></table></td>"
   num0 = num0 + 1

   body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'> <B>" + \
                sprintf("%4.0f", wgts(ns)) + "</B></font></td></table></td>"
   num0 = num0 + 1

   body(num0) = "<td align='center' width='200'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='2' color='#000080' face='Verdana'>" \
              + "access to <a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + " onmouseover=" + quote + "this.className='msover';" \
              + quote + " href='" + HtmlTableNameSources(ns) + "'>" + "<B>plots</B></a></font></td></table></td>"
   num0 = num0 + 1

   body(num0) = "</tr>"
   num0 = num0 + 1
end do

body(num0) = "</table>"
num0 = num0 + 1
body(num0) = "<BR>"
num0 = num0 + 1

body(num0:num0+num2-1)=tailer

num0=num0+num2

asciiwrite(HtmlTableName,body(0:num0-1))

end

; ################################################################################################################################
procedure create_plots (HtmlPlotsName:string, Var1Name:string, Var2Name:string, Source1:string, Source2:string, \
                        ModelNames:string, PlotsFileNames:string)

begin

quote = str_get_dq()

if (dimsizes(ind(.not.ismissing(PlotsFileNames))).le.6) then
   ntep=2
   wide=600
else
   ntep=3
   wide=400
end if

wides=wide*ntep

swide=sprinti("%3i",wide)
swides=sprinti("%3i",wides)

body = new((/10000/), string)

tailer = html_tail

num1=0
num2 = dimsizes(tailer)

num0 = num1
body(num0) = "                           "
num0 = num0 + 1
body(num0) = "<TABLE width='" + swides + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
 num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "    <td align='center' height='20'></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1

i50 = ind(.not.ismissing(PlotsFileNames))
  
nmod1 = dimsizes(i50)
   
if (nmod1.ge.2 .or. .not.ismissing(i50)) then
      
    PlotsFileNames0 = PlotsFileNames(i50)

    body(num0) = "                           "
    num0 = num0 + 1
    body(num0) = "<TABLE width='" + swides + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
    num0 = num0 + 1
    body(num0) = "<tr>"
    num0 = num0 + 1
    if (str_lower(Var1Name).eq.str_lower(Var2Name))
       body(num0) = "   <td align='center' width='" + swides + "'><font size='3' color='black' face='Verdana'><B>Models vs. " \
                  + Source1 + "</B></font></td>"
    else
       body(num0) = "   <td align='center' width='" + swides + "'><font size='3' color='black' face='Verdana'><B>" \
                  + Var2Name + " vs. " + Var1Name + "</B></font></td>"
    end if
    num0 = num0 + 1
    body(num0) = "</tr>"
    num0 = num0 + 1
    body(num0) = "</table>"
    num0 = num0 + 1

    body(num0) = "                                   "
    num0 = num0 + 1
    body(num0) = "<TABLE width='" + swides + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
    num0 = num0 + 1

    do nd=0, nmod1-1, ntep
       body(num0) = "<tr>"
       num0 = num0 + 1

       do nd1=nd,nd+ntep-1
          if (nd1.le.(nmod1-1)) then
             body(num0) = "<td align='center' width='" + swide + "'><table bordercolor='#8b73ca' border='0'><td align='center'><img src="\
                        + PlotsFileNames0(nd1) + "  border='0' width='" + swide + "'></td></table></td>"
             num0 = num0 + 1
         end if
       end do

       body(num0) = "</tr>"
       num0 = num0 + 1
   end do
   delete(PlotsFileNames0)
end if
delete(i50)

body(num0) = "</table>"
num0 = num0 + 1
body(num0) = "<BR>"
num0 = num0 + 1

body(num0:num0+num2-1)=tailer

num0=num0+num2

asciiwrite(HtmlPlotsName,body(0:num0-1))

end

; ################################################################################################################################
procedure create_plots_all (HtmlPlotsName:string, VarName:string, Sources:string, ModelNames:string, \
                        KeyWord:string, PlotsFileNames:string)

begin

quote = str_get_dq()

nsur=dimsizes(Sources)
ndim=dimsizes(ModelNames)
nmod=ndim(2)
delete(ndim)

if (dimsizes(ind(.not.ismissing(PlotsFileNames(0,:)))).le.6) then
   ntep=2
   wide=600
else
   ntep=3
   wide=400
end if

wides=wide*ntep

swide=sprinti("%3i",wide)
swides=sprinti("%3i",wides)

body = new((/10000/), string)

tailer = html_tail

num1=0
num2 = dimsizes(tailer)

num0 = num1
body(num0) = "                           "
num0 = num0 + 1
body(num0) = "<TABLE width='" + swides + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
 num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "    <td align='center' height='20'></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1

if (nsur.eq.2) then
    nsur=1
end if

do ns=0, nsur-1

   i50 = ind(.not.ismissing(PlotsFileNames(ns,:)))
  
   nmod1 = dimsizes(i50)
   
   if (nmod1.ge.2 .or. .not.ismissing(i50)) then
      
      PlotsFileNames0 = PlotsFileNames(ns,i50)

      body(num0) = "                           "
      num0 = num0 + 1
      body(num0) = "<TABLE width='" + swides + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
      num0 = num0 + 1
      body(num0) = "<tr>"
      num0 = num0 + 1
      body(num0) = "   <td align='center' width='" + swides + "'><font size='3' color='black' face='Verdana'><B>Model vs. " + Sources(ns) + "</B></font></td>"
      num0 = num0 + 1
      body(num0) = "</tr>"
      num0 = num0 + 1
      body(num0) = "</table>"
      num0 = num0 + 1

      body(num0) = "                                   "
      num0 = num0 + 1
      body(num0) = "<TABLE width='" + swides + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
      num0 = num0 + 1

      do nd=0, nmod1-1, ntep
         body(num0) = "<tr>"
         num0 = num0 + 1

         do nd1=nd,nd+ntep-1
            if (nd1.le.(nmod1-1)) then
               body(num0) = "<td align='center' width='" + swide + "'><table bordercolor='#8b73ca' border='0'><td align='center'><img src="\
                            + PlotsFileNames0(nd1) + "  border='0' width='" + swide + "'></td></table></td>"
               num0 = num0 + 1
            end if
         end do

         body(num0) = "</tr>"
         num0 = num0 + 1
      end do
      delete(PlotsFileNames0)
   end if
   delete(i50)

   body(num0) = "</table>"
   num0 = num0 + 1
   body(num0) = "<BR>"
   num0 = num0 + 1
end do

body(num0:num0+num2-1)=tailer

num0=num0+num2

asciiwrite(HtmlPlotsName,body(0:num0-1))

end

; ################################################################################################################################
function  create_html_plots (VarName:string, Sources:string, KeyWords:string, StartYears:integer,\ 
                             EndYears:integer, ModelNames:string)

begin

DataDir  = getenv("ILAMB_ROOT")
DataDir0 = getenv("ILAMB_OUTPUTDIR") + ""

;results  = retrieve_others("Metrics", "-999")
;KeyWord  = results@Category
;
;nkeys = dimsizes(KeyWord)
;
;delete(results)
;delete(KeyWord)

nsur    = dimsizes(Sources)
nmod    = dimsizes(ModelNames)
nkey    = dimsizes(KeyWords)

Sources0       = new((/nsur+1/), string)
ModelNames0    = new((/nsur+1,nkey,nmod+1/), string)
PlotsFileNames = new((/nsur+1,nkey,nmod+1/), string)

HtmlPlotsNames = new((/nsur,nkey/), string)

if (nsur.gt.1) then
   do ns=0,nsur-1
      if (ns.eq.0) then
         Source0 = Sources(ns)
      else
         Source0 = Source0 + "+" + Sources(ns)
      end if
   end do
   StartYear0 = min(StartYears)
   EndYear0   = max(EndYears)
else
   Source0    = Sources
   StartYear0 = StartYears
   EndYear0   = EndYears
end if

Sources0(0:nsur-1)  = Sources
Sources0(nsur)      = Source0

do nk=0,nkey-1
do ns=0,nsur-1

   if (nsur.gt.1) then
      Source = Sources(ns)
      StartYear = StartYears(ns)
      EndYear   = EndYears(ns)
   else
      Source = Sources
      StartYear = StartYears
      EndYear   = EndYears
   end if

   if (nkey.gt.1) then
      KeyWord = KeyWords(nk)
   else
      KeyWord = KeyWords
   end if

   DataDirPlot1 = DataDir0 + "/" + str_lower(VarName) + "/" + str_lower(KeyWord)
   DataDirPlot2 = "../" + str_lower(VarName) + "/" + str_lower(KeyWord)

   if (any(KeyWord.eq.(/"overallscore", "taylorscore"/))) then
      ModelNames0(ns,nk,0) = Source
      ModelNames0(ns,nk,1) = "CMIP5"
      ModelName      = ModelNames0(ns,nk,1)
      PlotsFileName1 = DataDirPlot1 + "/" + str_lower(KeyWord) + "_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                       str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
      PlotsFileName2 = DataDirPlot2 + "/plots/PNG/" + str_lower(KeyWord) + "_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                       str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
      if (fileexists(PlotsFileName1)) then
         PlotsFileNames(ns,nk,1) = PlotsFileName2
      end if
   else
      ModelNames0(ns,nk,0)=Source
      ModelNames0(ns,nk,1:nmod)=ModelNames
      do nd=0,nmod
         if (any(str_upper(Source).eq.(/"GCP", "HOFFMAN", "MAUNA.LOA"/))) then
            ModelName      = "CMIP5"
         else
            if (str_upper(Source).eq."NOAA.GMD" .and. any(KeyWord.eq.(/"phase", "phasescore", "rmse", "rmsescore"/))) then
               ModelName      = "CMIP5"
            else
               ModelName      = ModelNames0(ns,nk,nd)
            end if
         end if
         PlotsFileName1 = DataDirPlot1 + "/" + str_lower(KeyWord) + "_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                          str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
         PlotsFileName2 = DataDirPlot2 + "/plots/PNG/" + str_lower(KeyWord) + "_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                          str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
         if (fileexists(PlotsFileName1)) then
            if (any(str_upper(Source).eq.(/"GCP", "HOFFMAN", "MAUNA.LOA"/))) then
               PlotsFileNames(ns,nk,1)   = PlotsFileName2
            else
               if (str_upper(Source).eq."NOAA.GMD" .and. any(KeyWord.eq.(/"phase", "phasescore", "rmse", "rmsescore"/))) then
                  PlotsFileNames(ns,nk,1)   = PlotsFileName2
               else
                  PlotsFileNames(ns,nk,nd)  = PlotsFileName2
               end if
            end if
         end if
      end do
   end if
end do
end do

DataDirPlot1 = DataDir0 + "/" + str_lower(VarName) + "/overallscore"
DataDirPlot2 = "../" + str_lower(VarName) + "/overallscore"

i50 = ind(str_lower(KeyWords).eq."overallscore")

ModelNames0(nsur,i50,0) = Source0
ModelNames0(nsur,i50,1) = "CMIP5"
ModelName            = ModelNames0(nsur,i50,1)
PlotsFileName1 = DataDirPlot1 + "/overallscore_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                 str_upper(Source0) + "_" + sprinti("%0.4i",StartYear0) + "-" + sprinti("%0.4i",EndYear) + ".png"
PlotsFileName2 = DataDirPlot2 + "/plots/PNG/overallscore_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                 str_upper(Source0) + "_" + sprinti("%0.4i",StartYear0) + "-" + sprinti("%0.4i",EndYear) + ".png"
if (fileexists(PlotsFileName1)) then
   PlotsFileNames(nsur,i50,1) = PlotsFileName2
end if

delete(i50)

do nk=0,nkey-1

   HtmlPlotsName = DataDir0 + "/www/plot_" + str_lower(KeyWords(nk)) + "_" + str_lower(VarName) + "_" + Sources + ".html"

   do ns=0,nsur-1
      create_plots (HtmlPlotsName(ns), VarName, VarName, Sources0(ns), Sources0(ns), ModelNames0(ns,nk,:), PlotsFileNames(ns,nk,:))
   end do

   HtmlPlotsNames(:,nk) = HtmlPlotsName

end do

return(HtmlPlotsNames)

end

; ####"###########################################################################################################################
function  create_html_plots_all (VarName:string, Sources:string, KeyWords:string, StartYears:integer,\ 
                                 EndYears:integer, ModelNames:string)

begin

DataDir  = getenv("ILAMB_ROOT")
DataDir0 = getenv("ILAMB_OUTPUTDIR") + ""

nsur    = dimsizes(Sources)
nmod    = dimsizes(ModelNames)
nkey    = dimsizes(KeyWords)

Sources0       = new((/nsur+1/), string)
ModelNames0    = new((/nsur+1,nkey,nmod+1/), string)
PlotsFileNames = new((/nsur+1,nkey,nmod+1/), string)

HtmlPlotsNames = new((/nkey/), string)

if (nsur.gt.1) then
   do ns=0,nsur-1
      if (ns.eq.0) then
         Source0 = Sources(ns)
      else
         Source0 = Source0 + "+" + Sources(ns)
      end if
   end do
   StartYear0 = min(StartYears)
   EndYear0   = max(EndYears)
else
   Source0    = Sources
   StartYear0 = StartYears
   EndYear0   = EndYears
end if

Sources0(0:nsur-1)  = Sources
Sources0(nsur)      = Source0

do nk=0,nkey-1
do ns=0,nsur-1

   if (nsur.gt.1) then
      Source    = Sources(ns)
      StartYear = StartYears(ns)
      EndYear   = EndYears(ns)
   else
      Source    = Sources
      StartYear = StartYears(ns)
      EndYear   = EndYears(ns)
   end if

   if (nkey.gt.1) then
      KeyWord = str_lower(KeyWords(nk))
   else
      KeyWord = str_lower(KeyWords)
   end if

   DataDirPlot1 = DataDir0 + "/" + str_lower(VarName) + "/" + str_lower(KeyWord)
   DataDirPlot2 = "../" + str_lower(VarName) + "/" + str_lower(KeyWord)

   if (any(KeyWord.eq.(/"overallscore", "taylorscore"/))) then
      ModelNames0(ns,nk,0) = Source
      ModelNames0(ns,nk,1) = "CMIP5"
      ModelName      = ModelNames0(ns,nk,1)
      PlotsFileName1 = DataDirPlot1 + "/" + str_lower(KeyWord) + "_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                       str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
      PlotsFileName2 = DataDirPlot2 + "/plots/PNG/" + str_lower(KeyWord) + "_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                       str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
      if (fileexists(PlotsFileName1)) then
         PlotsFileNames(ns,nk,1) = PlotsFileName2
      end if
   else
      ModelNames0(ns,nk,0)=Source
      ModelNames0(ns,nk,1:nmod)=ModelNames
      do nd=0,nmod
         if (any(str_upper(Source).eq.(/"GCP", "HOFFMAN", "MAUNA.LOA"/))) then
            ModelName      = "CMIP5"
         else
            if (str_upper(Source).eq."NOAA.GMD" .and. any(KeyWord.eq.(/"phase", "phasescore", "rmse", "rmsescore"/))) then
               ModelName      = "CMIP5"
            else
               ModelName      = ModelNames0(ns,nk,nd)
            end if
         end if
         PlotsFileName1 = DataDirPlot1 + "/" + str_lower(KeyWord) + "_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                          str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
         PlotsFileName2 = DataDirPlot2 + "/plots/PNG/" + str_lower(KeyWord) + "_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                          str_upper(Source) + "_" + sprinti("%0.4i",StartYear) + "-" + sprinti("%0.4i",EndYear) + ".png"
         if (fileexists(PlotsFileName1)) then
            if (any(str_upper(Source).eq.(/"GCP", "HOFFMAN", "MAUNA.LOA"/))) then
               PlotsFileNames(ns,nk,1)  = PlotsFileName2
            else
               if (str_upper(Source).eq."NOAA.GMD" .and. any(KeyWord.eq.(/"phase", "phasescore", "rmse", "rmsescore"/))) then
                  PlotsFileNames(ns,nk,1)  = PlotsFileName2
               else
                  PlotsFileNames(ns,nk,nd)  = PlotsFileName2
               end if
            end if
         end if
      end do
   end if
end do
end do

DataDirPlot1 = DataDir0 + "/" + str_lower(VarName) + "/overallscore"
DataDirPlot2 = "../" + str_lower(VarName) + "/overallscore"

i50 = ind(str_lower(KeyWords).eq."overallscore")

ModelNames0(nsur,i50,0) = Source0
ModelNames0(nsur,i50,1) = "CMIP5"
ModelName            = ModelNames0(nsur,i50,1)
PlotsFileName1 = DataDirPlot1 + "/overallscore_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                 str_upper(Source0) + "_" + sprinti("%0.4i",StartYear0) + "-" + sprinti("%0.4i",EndYear) + ".png"
PlotsFileName2 = DataDirPlot2 + "/plots/PNG/overallscore_" + str_lower(VarName) + "_" + ModelName + ".vs." + \
                 str_upper(Source0) + "_" + sprinti("%0.4i",StartYear0) + "-" + sprinti("%0.4i",EndYear) + ".png"
if (fileexists(PlotsFileName1)) then
   PlotsFileNames(nsur,i50,1) = PlotsFileName2
end if

delete(i50)

do nk=0,nkey-1

   HtmlPlotsName = DataDir0 + "/www/plot_" + str_lower(KeyWords(nk)) + "_" + str_lower(VarName) + ".html"

   create_plots_all (HtmlPlotsName, VarName, Sources0, ModelNames0, KeyWords(nk), PlotsFileNames(:,nk,:))

   HtmlPlotsNames(nk) = HtmlPlotsName

end do

return(HtmlPlotsNames)

end

; ################################################################################################################################
function top_menu_head ()

begin

header = new((/100/), string)

num0 = 0
header(num0) = "<html>"
num0 = num0 + 1
header(num0) = "<head>"
num0 = num0 + 1
header(num0) = "<title>Output for ILAMB Diagnostics</title>"
num0 = num0 + 1
header(num0) = "<meta http-equiv='Content-Type' content='text/html'; charset='english'>"
num0 = num0 + 1
header(num0) = "<base TARGET='home-content'>"
num0 = num0 + 1
header(num0) = "</head>"
num0 = num0 + 1
header(num0) = "<SCRIPT LANGUAGE='JavaScript'>"
num0 = num0 + 1
header(num0) = "        //"
num0 = num0 + 1
header(num0) = "        <!--"
num0 = num0 + 1
header(num0) = "        // the string that should scroll"
num0 = num0 + 1
header(num0) = "        //This part can be modified to your own needs"
num0 = num0 + 1
header(num0) = "        var scrlStr = 'Output for ILAMB Diagnostics'"
num0 = num0 + 1
header(num0) = "        // the width of the scrolling area"
num0 = num0 + 1
header(num0) = "        var width = 150;"
num0 = num0 + 1
header(num0) = "        var strLen = scrlStr.length;"
num0 = num0 + 1
header(num0) = "        var pos = 1 - width;"
num0 = num0 + 1
header(num0) = "        function scroll(){"
num0 = num0 + 1
header(num0) = "                var scroll = '';"
num0 = num0 + 1
header(num0) = "                pos++;"
num0 = num0 + 1
header(num0) = "                if (pos == strLen)"
num0 = num0 + 1
header(num0) = "                       pos = 1 - width;"
num0 = num0 + 1
header(num0) = "                if (pos<0) {"
num0 = num0 + 1
header(num0) = "                        for (var i=1; i<=Math.abs(pos); i++)"
num0 = num0 + 1
header(num0) = "                                scroll = scroll + ' '; "
num0 = num0 + 1
header(num0) = "                   scroll = scroll + scrlStr.substring(0, width - i + 1);"
num0 = num0 + 1
header(num0) = "                }"
num0 = num0 + 1
header(num0) = "                else"
num0 = num0 + 1
header(num0) = "                        scroll = scroll + scrlStr.substring(pos, pos + width);"
num0 = num0 + 1
header(num0) = "                window.status = scroll;"
num0 = num0 + 1
header(num0) = "                setTimeout('scroll()',100);"
num0 = num0 + 1
header(num0) = "        }"
num0 = num0 + 1
header(num0) = "//-->"
num0 = num0 + 1
header(num0) = "</SCRIPT>"
num0 = num0 + 1

return(header(0:num0-1))

end

; ################################################################################################################################
procedure create_top_menu (HtmlTopName:string, VarNames:string, KeyWords:string, HtmlPlotsNames:string, HtmlTableNames:string)

begin

KeyWord1  = (/"annualmean","bias","rmse","phase","globalbiasscore","rmsescore","phasescore","taylorscore",\
              "interannualscore","overallscore","summary"/)

KeyWord2   = (/"Annual Mean","Bias","RMSE","Phase Difference", "Global Bias","RMSE","Seasonal Cycle", "Spatial Distribution",\
               "Interannual Variability","Overall","Summary"/)

quote = str_get_dq()

nkey = dimsizes(KeyWord1)

nvar=dimsizes(VarNames)

HtmlPlotsNames0 = new((/nvar,nkey/), string)
KeyWords0       = new((/nvar,nkey/), string)

do nv = 0, nvar-1
do nk = 0, nkey-1
   do nk1 = 0, nkey-1
      if (.not.ismissing(str_match(str_lower(HtmlPlotsNames(nv,nk1)), str_lower(KeyWord1(nk))))) then
         HtmlPlotsNames0(nv,nk) = HtmlPlotsNames (nv, nk1)
         KeyWords0(nv,nk) = KeyWords(nv, nk1)
      end if
   end do
end do
end do

body = new((/10000/), string)

header = top_menu_head

num0 = dimsizes(header)

body(0:num0-1)=header

body(num0) = "                           "
num0 = num0 + 1
body(num0) = "<body bgcolor='#ffffff'>"
num0 = num0 + 1
body(num0) = "<div ID='applet' LEFT: 0px; 'class='divline' align='left' valign='top' width='900' " + \
             "border='0' cellspacing='0' cellpadding='0'>"
num0 = num0 + 1
body(num0) = "<table valign='top' border='0' cellspacing='0' cellpadding='0' width='100%' " + \
             "style='margin-left: 0em' style='margin-top: 0em'>"
num0 = num0 + 1
body(num0) = "<tr><td align='left' valign='top' border='0' cellspacing='0' cellpadding='0'>"
num0 = num0 + 1
body(num0) = "                           "
num0 = num0 + 1

body(num0) = "<applet Code='apPopupMenu' Archive='apPopupMenu.jar' Width='900' Height='30'>"
num0 = num0 + 1
body(num0) = "<param name='Copyright' value='Apycom'>"
num0 = num0 + 1
body(num0) = "<param name='isHorizontal' value='true'>"
num0 = num0 + 1
body(num0) = "<param name='buttonType' value='5'>"
num0 = num0 + 1
body(num0) = "<param name='3dborder' value='true'>"
num0 = num0 + 1
body(num0) = "<param name='solidArrows' value='true'>"
num0 = num0 + 1
body(num0) = "<param name='systemSubFont' value='true'>"
num0 = num0 + 1
body(num0) = "<param name='backPic' value=''>"
num0 = num0 + 1
body(num0) = "<param name='backHighColor' value='ffa851'>"
num0 = num0 + 1
body(num0) = "<param name='backColor' value='3775ff'>"
num0 = num0 + 1
body(num0) = "<param name='fontColor' value='ffffff'>"
num0 = num0 + 1
body(num0) = "<param name='font' value='Arial,12,1'>"
num0 = num0 + 1
body(num0) = "<param name='menuItems' value='"
num0 = num0 + 1

do nk=0, nkey-1
   body(num0) = "          {" + KeyWord2(nk) + "}"
   num0 = num0 + 1

   if (str_lower(KeyWord1(nk)).eq."summary") then
      body(num0) = "          {|tables}"
      num0 = num0 + 1
      body(num0) = "          {||overall,ilamb-summary.html,home-content}"
      num0 = num0 + 1
      do nv =0, nvar-1
         if (.not.ismissing(HtmlTableNames(nv))) then
            body(num0) = "          {||-}"
            num0 = num0 + 1
            body(num0) = "          {||" + VarNames(nv) + "," + HtmlTableNames(nv) + ",home-content}"
            num0 = num0 + 1
         end if
      end do
      body(num0) = "          {|-}"
      num0 = num0 + 1
      body(num0) = "          {|plot,ilamb-overall.html,home-content}"
      num0 = num0 + 1
   else
         ijk=0
      do nv=0, nvar-1
         i50=ind(str_lower(KeyWords0(nv,:)).eq.str_lower(KeyWord1(nk)))
         if (dimsizes(i50).gt.1) then
            j50 = i50(0)
            delete(i50)
            i50 = j50
            delete(j50)
         end if
         if (.not.ismissing(i50) .and. .not.ismissing(HtmlPlotsNames0(nv,i50))) then
            ijk=ijk+1
            body(num0) = "          {|" + VarNames(nv) + "," +  HtmlPlotsNames0(nv,i50) + ",home-content}"
            num0 = num0 + 1
            if (ijk.lt.dimsizes(ind(.not.ismissing(HtmlPlotsNames0(:,nk))))) then
                body(num0) = "          {|-}"
                num0 = num0 + 1
            end if
         end if
         delete(i50)
      end do
   end if
end do

body(num0) = "          '>"
num0 = num0 + 1
body(num0) = "</applet>"
num0 = num0 + 1
body(num0) = "                 "
num0 = num0 + 1
body(num0) = "</td></tr>"
num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1
body(num0) = "                   "
num0 = num0 + 1
body(num0) = "<table border='0' cellpadding='0' cellspacing='0' width='100%' align='center' valign='center'>"
num0 = num0 + 1
body(num0) = "<tr><td valign='center' align='center' height=1 bgcolor='red'></td></tr>"
num0 = num0 + 1
body(num0) = "<tr><td valign='center' align='center' height=10 bgcolor='lightblue'></td></tr>"
num0 = num0 + 1
body(num0) = "<tr><td valign='center' align='center' height=1 bgcolor='red'></td></tr>"
num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1
body(num0) = "                           "
num0 = num0 + 1
body(num0) = "</div>"
num0 = num0 + 1
body(num0) = "</body>"
num0 = num0 + 1
body(num0) = "                           "
num0 = num0 + 1
body(num0) = "</html>"
num0 = num0 + 1

asciiwrite(HtmlTopName,body(0:num0-1))

end

; ################################################################################################################################
procedure create_main_page (HtmlPageName:string, VarNames:string, HtmlTableNames:string, Values:float, \
                            nvpa:integer, nchk:integer, WgtVars:float)

begin

DataDir   = getenv("ILAMB_ROOT")
DataDir0  = getenv("ILAMB_OUTPUTDIR") + ""

nvar=dimsizes(VarNames)

; ++++++++ Set background color for each category ++++++++++++
bgcolors = (/"#dbedc0", "#81BEF7", "#F5BCA9", "#A4A4A4", "#FFFFFF"/)

Values@_FillValue=-999

;+++++++++++++++++++++++ Collect infor for Categories ++++++++++++++++++++++++++++++++++++++

results      = retrieve_others ("Category", "")
CatShortName = results@Category
delete(results)

ncat = dimsizes(CatShortName)

CatName  = new((/ncat/), string)
CatsID   = new((/ncat,nvar/), integer)
numbs    = new((/ncat/), integer)

numbs    = 0
CatsID   = -999

CatsID@_FillValue = -999

do nc=0,ncat-1
   CatName(nc) = retrieve_LongName (CatShortName(nc))
end do

do nv = 0, nvar-1
   do nc = 0, ncat-1
      DataInfo = retrieve_DataInfo (VarNames(nv), "")
      Category = DataInfo@Category
      delete(DataInfo)
      if (str_lower(Category).eq.str_lower(CatShortName(nc))) then
         CatsID(nc,nv) = nv
         numbs(nc)     = numbs(nc) + 1
      end if
   end do
end do

; ++++++++++ Read Weightings for categories +++++++++++

TableFileName = getenv("ILAMB_OUTPUTDIR") + "/summary/weights_category.txt"

if (fileexists(TableFileName)) then
   print(TableFileName)

   data_1d = asciiread(TableFileName,-1,"string")
   ;print(data_1d)

   LongCatName = str_get_field(data_1d(2:), 1, ":")
   CatData     = stringtointeger(str_get_field(data_1d(2:), 2, ":"))

   delete(data_1d)
else
   LongCatName = CatName
   CatData     = new((/ncat/), float)
   CatData     = 0.
end if

; +++++++ read scoring metrics from the file: $ILAMB_ROOT/CODES/INPUT/table_scoring_metrics.txt +++++++

; ++++++++++ Find the file name ++++++++++
FileList = systemfunc ("ls " + DataDir + "/CODES/INPUT/table_scoring_metrics.txt")

if (fileexists(FileList)) then

   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; ++++ Read the file ++++
   data_1d = asciiread(FileList,-1,"string")

   print("                                                                       ")
   print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
   print("HERE ARE Weighting Coeffients for All Available Data: ")

   ; ++++ Obtain Weighting Coefficients for All Variables and Sources ++++
   AllVarName    = str_get_field(data_1d(4:), 1, ",")
   AllSourceName = str_squeeze(str_get_field(data_1d(4:), 2, ","))
   AllCertainty  = stringtoint(str_get_field(data_1d(4:), 3, ","))
   AllScale      = stringtoint(str_get_field(data_1d(4:), 4, ","))
   AllOverall    = stringtoint(str_get_field(data_1d(4:), 5, ","))

   AllShortVarName   = str_get_field(AllVarName, 1, "(")
   AllLongVarName    = str_get_field(AllVarName, 2, "(")

   AllLongVarName    = str_sub_str(AllLongVarName, ")", "")

   AllShortVarName   = str_squeeze (AllShortVarName)
   AllLongVarName    = str_squeeze (AllLongVarName)

   AllShortSourceName = str_get_field(AllSourceName,  1, "(")
   AllLongSourceInfo  = str_get_field(AllSourceName,  2, "(")

   AllLongSourceInfo  = str_sub_str(AllLongSourceInfo, ")", "")

   AllLongSourceName  = str_get_field(AllLongSourceInfo,  1, "[")
   AllSourceReference = str_get_field(AllLongSourceInfo,  2, "[")

   AllSourceReference = str_sub_str(AllSourceReference, "]", "")

   AllShortSourceName = str_squeeze (AllShortSourceName)
   AllLongSourceName  = str_squeeze (AllLongSourceName)
   AllSourceReference = str_squeeze (AllSourceReference)

   AllScoreName  = str_split(data_1d(0)," ")
   AllScoreName  = str_squeeze(AllScoreName) + "Score"

   nscr          = dimsizes(AllScoreName)
   nsus          = dimsizes(AllSourceName)

   AllScoreID    = new((/nsus,nscr/), integer)

   do ijk = 1, nscr
      AllScoreMode  = str_get_field(data_1d(4:), ijk+5, ",")
      AllScoreMode  = str_squeeze(AllScoreMode)
      AllScoreMode  = str_lower(AllScoreMode)
      AllScoreID (:,ijk-1) = where(AllScoreMode.eq."no", 0, 1)
   end do

   delete(ijk)
   delete(data_1d)

end if

delete(FileList)

; ++++++ Retrieve all parameters for diagnostics for a single variable: ../CODES/tempfiles/input_para_* +++++
NumEnsAvailID = new((/nvar,100/), integer)
NumEnsUsedID  = new((/nvar,100/), integer)

NumEnsAvailID = 0
NumEnsUsedID  = 0
KeyWords  = ""
nkeys     = 0

do nv = 0, nvar-1

   InputFiles = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_" + str_lower(VarNames(nv))

   FileList = systemfunc ("ls " + InputFiles + "*")

   FileList = str_squeeze(FileList)

   do ns = 0, dimsizes(FileList) - 1

      if (dimsizes(FileList).gt.1) then
         FileName = str_squeeze(FileList(ns))
      else
         FileName = str_squeeze(FileList)
      end if

      data_1d = asciiread(FileName,-1,"string")

      VarModel     = str_squeeze(str_get_field(data_1d(3), 2, ":"))
      modelID      = str_squeeze(str_get_field(data_1d(4), 2, ":"))
      expID        = str_squeeze(str_get_field(data_1d(5), 2, ":"))
      ModelRaw     = str_squeeze(str_get_field(data_1d(8), 2, ":"))
      cmipID       = stringtointeger(str_get_field(data_1d(16:), 2, " "))

      KeyWord0     = str_get_field(data_1d(13), 2, ":")

      nkey         = dimsizes(str_split(KeyWord0,","))
      KeyWord      = str_squeeze(str_split(KeyWord0,","))

      if (ns.eq.0) then

         ModelNames            = str_squeeze(str_get_field(data_1d(16:), 1, " "))
         nmod                  = dimsizes(ModelNames)
         NumEnsUsedID(nv,0:nmod-1) = stringtointeger(str_get_field(data_1d(16:), 3, " "))

         ; ++++++ Check # of Ensembles Availability ++++++

         if (str_lower(ModelNames(0)).eq."meanmodel" .and. cmipID(0).ge.1) then
            nrun0 = check_No_of_ensembles (ModelNames(1:nmod-1), ModelRaw, modelID, expID, VarModel)
         else
            nrun0 = check_No_of_ensembles (ModelNames(0:nmod-1), ModelRaw, modelID, expID, VarModel)
         end if

         if (str_lower(ModelNames(0)).eq."meanmodel" .and. cmipID(0).ge.1) then
            NumEnsAvailID(nv,0) = 1
            NumEnsAvailID(nv,1:nmod-1) = nrun0
         else
            NumEnsAvailID(nv,0:nmod-1) = nrun0
         end if

         delete(nrun0)
      end if

      if (nkey.gt.nkeys) then
         delete(KeyWords)
         KeyWords = KeyWord
         nkeys    = nkey
      end if

      delete(expID)
      delete(cmipID)
      delete(modelID)
      delete(data_1d)
      delete(KeyWord)
      delete(KeyWord0)
   end do
   delete(FileList)
end do

if (.not.isdefined("AllVarName")) then
   AllVarName         = new((/1000/), string)
   AllSourceName      = new((/1000/), string)
   AllCertainty       = new((/1000/), integer)
   AllScale           = new((/1000/), integer)
   AllOverall         = new((/1000/), integer)

   AllVarName         = "-999"
   AllSourceName      = "-999"
   AllCertainty       = 0
   AllScale           = 0
   AllOverall         = 0
   AllShortVarName    = AllVarName
   AllShortSourceName = AllSourceName
end if

AllSourceID     = new((/nvar,10/), integer)
AllKeyWordID    = new((/nvar,10,nkeys/), string)

AllSourceID     = -999
AllKeyWordID    = -999

   ijk = 0
do nv = 0, nvar-1

   print("                                                                       ")
   print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
   print("Searching All Data Sources for the Variable: " + VarNames(nv))

   InputFiles = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_" + str_lower(VarNames(nv))

   FileList = systemfunc ("ls " + InputFiles + "*")

   FileList = str_squeeze(FileList)

   nsur     = dimsizes(FileList)

   if (nsur.gt.1) then
      do ns = 0, nsur-1
         Sourcet0 = str_split(FileList(ns),"/")
         nlast0   = dimsizes(Sourcet0)
         Sourcet1 = str_split(Sourcet0(nlast0-1),"_")
         nlast1   = dimsizes(Sourcet1)
         Source   = Sourcet1(nlast1-1)
 
         i50      = ind(str_lower(AllShortVarName).eq.str_lower(VarNames(nv)) .and. str_upper(AllShortSourceName).eq.str_upper(Source))

         if (.not.ismissing(i50)) then
            AllSourceID(nv,ns)  = i50
         else
            AllSourceID(nv,ns)  = ijk

            DataInfo = retrieve_DataInfo (VarNames(nv), Source)

            AllVarName(ijk)    = VarNames(nv) + " (" + DataInfo@LongName + ")"
            AllSourceName(ijk) = Source + " (" + DataInfo@DataName + " [" + DataInfo@Reference + "]" + ")"
            AllCertainty(ijk)  = 1
            AllScale(ijk)      = 1
            AllOverall(ijk)    = 1
            delete(DataInfo)
         end if

         delete(i50)
         delete(Sourcet0)
         delete(Sourcet1)

         TableFileName = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_" + str_lower(VarNames(nv)) + "_" + str_upper(Source)

         data_1d = asciiread(str_squeeze(TableFileName),-1,"string")

         KeyWord0     = str_get_field(data_1d(13), 2, ":")

         nkey         = dimsizes(str_split(KeyWord0,","))
         KeyWord      = str_squeeze(str_split(KeyWord0,","))

         do nk = 0, nkeys-1
            j50 = ind(str_lower(KeyWord).eq.str_lower(KeyWords(nk)))
            if (.not.ismissing(j50)) then
               AllKeyWordID(nv,ns,nk) = "YES"
            else
               AllKeyWordID(nv,ns,nk) = "NO"
            end if
            delete(j50)
         end do

         delete(data_1d)
         delete(KeyWord)
         delete(KeyWord0)

         ijk =ijk + 1
      end do

   else

      Sourcet0 = str_split(FileList,"/")
      nlast0   = dimsizes(Sourcet0)
      Sourcet1 = str_split(Sourcet0(nlast0-1),"_")
      nlast1   = dimsizes(Sourcet1)
      Source  = Sourcet1(nlast1-1)

      i50      = ind(str_lower(AllShortVarName).eq.str_lower(VarNames(nv)) .and. str_upper(AllShortSourceName).eq.str_upper(Source))
      if (.not.ismissing(i50)) then
         AllSourceID(nv,0)  = i50
      else
         AllSourceID(nv,0)  = ijk

         DataInfo = retrieve_DataInfo (VarNames(nv), Source)

         AllVarName(ijk)    = VarNames(nv) + " (" + DataInfo@LongName + ")"
         AllSourceName(ijk) = Source + " (" + DataInfo@DataName + " [" + DataInfo@Reference + "]" + ")"
         AllCertainty(ijk)  = 1
         AllScale(ijk)      = 1
         AllOverall(ijk)    = 1
         delete(DataInfo)
      end if

      delete(i50)
      delete(Sourcet0)
      delete(Sourcet1)

      TableFileName = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_" + str_lower(VarNames(nv)) + "_" + str_upper(Source)
      data_1d = asciiread(str_squeeze(TableFileName),-1,"string")

      KeyWord0     = str_get_field(data_1d(13), 2, ":")
      nkey         = dimsizes(str_split(KeyWord0,","))
      KeyWord      = str_squeeze(str_split(KeyWord0,","))

      do nk = 0, nkeys-1
         j50 = ind(str_lower(KeyWord).eq.str_lower(KeyWords(nk)))
         if (.not.ismissing(j50)) then
            AllKeyWordID(nv,0,nk) = "YES"
         else
            AllKeyWordID(nv,0,nk) = "NO"
         end if
         delete(j50)
      end do

      delete(data_1d)
      delete(KeyWord)
      delete(KeyWord0)

      ijk =ijk + 1

   end if

   delete(FileList)
end do

delete(ijk)

;+++++++++++++++++++++++ Create html for the category's contribution ++++++++++++++++++++++++++++++++++++++
HtmlCatWgt = create_category_weights (LongCatName, CatData)
HtmlCatWgt = str_sub_str(HtmlCatWgt, getenv("ILAMB_OUTPUTDIR") + "/www/", "")

;+++++++++++++++++++++++ Create html for the scoring metrics table ++++++++++++++++++++++++++++++++++++++
HtmlScoring = create_scoring_metrics (LongCatName, CatData, VarNames, AllVarName, AllSourceName, AllCertainty, AllScale, \
                                      AllOverall, KeyWords, CatsID, AllSourceID, AllKeyWordID, bgcolors)
HtmlScoring = str_sub_str(HtmlScoring, getenv("ILAMB_OUTPUTDIR") + "/www/", "")

;+++++++++++++++++++++++ Create html for Model Availability ++++++++++++++++++++++++++++++++++++++
HtmlNumEns = create_avail_models (CatName, CatsID, VarNames, ModelNames, NumEnsUsedID, NumEnsAvailID, bgcolors)
HtmlNumEns = str_sub_str(HtmlNumEns, getenv("ILAMB_OUTPUTDIR") + "/www/", "")

delete(ModelNames)

;+++++++++++++++++++++++ read overall score from summary file ++++++++++++++++++++++++++++++++++++++
TableFileNameAll = DataDir0 + "/summary/overallscore_all.txt"
TableFileNameGV  = DataDir0 + "/summary/overallscore_GlobalVariables.txt"
TableFileNameVV  = DataDir0 + "/summary/overallscore_Variable2Variable.txt"

TableWeightNameGV= "../summary/tables/weights_allvariables.txt"
TableWeightNameVV= "../summary/tables/weights_allvar2var.txt"

if (fileexists(TableFileNameAll)) then
   print(TableFileNameAll)

   data_1d = asciiread(TableFileNameAll,-1,"string")

   ModelNames  = str_squeeze(str_get_field(data_1d(3:), 1, " "))

   nmod=dimsizes(ModelNames)

   ValueAll = stringtofloat(str_get_field(data_1d(3:), 2, " "))

   AllPlotName = "../summary/plots/PNG/overallscore_all.png"

   delete(data_1d)
else
   ValueAll = -999
end if

if (fileexists(TableFileNameGV)) then
   print(TableFileNameGV)

   data_1d = asciiread(TableFileNameGV,-1,"string")

   ModelNames  = str_squeeze(str_get_field(data_1d(3:), 1, " "))

   nmod=dimsizes(ModelNames)

   ValueGV = stringtofloat(str_get_field(data_1d(3:), 2, " "))

   GVPlotName = "../summary/plots/PNG/overallscore_GlobalVariables.png"

   delete(data_1d)
else
   ValueGV = -999
end if

if (fileexists(TableFileNameVV)) then
   print(TableFileNameVV)

   data_1d = asciiread(TableFileNameVV,-1,"string")

   ModelNames  = str_squeeze(str_get_field(data_1d(3:), 1, " "))

   nmod=dimsizes(ModelNames)

   ValueVV = stringtofloat(str_get_field(data_1d(3:), 2, " "))

   VVPlotName = "../summary/plots/PNG/overallscore_Variable2Variable.png"

   delete(data_1d)
else
   ValueVV = -999
end if

ValueAll@_FillValue=-999
ValueGV@_FillValue=-999
ValueVV@_FillValue=-999

;+++++++++++++++++++++++ create html file ++++++++++++++++++++++++++++++++++++++
body = new((/10000/), string)

swide  = sprinti("%i",(nmod+1)*100)
swide1 = sprinti("%i",6*100)

quote = str_get_dq()

num0 = 0

body(num0) = "<HTML>"
num0       = num0 + 1
body(num0) = "<body>"
num0       = num0 + 1
body(num0) = "                         "
num0       = num0 + 1
body(num0) = "<TITLE>ILAMB Diagnostics Main Page </TITLE>"
num0       = num0 + 1
body(num0) = "                  "
num0       = num0 + 1
body(num0) = "<body>"
num0       = num0 + 1
body(num0) = "                           "
   num0 = num0 + 1
body(num0) = "<TABLE width='" + swide + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
   num0 = num0 + 1
body(num0) = "<tr>"
   num0 = num0 + 1
body(num0) = "    <td align='center' height='20'></td>"
   num0 = num0 + 1
body(num0) = "</tr>"
   num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1

; ++++++ Create a table for ILAMB Doc here +++++

body(num0) = "                           "
num0 = num0 + 1
body(num0) = "<TABLE width='" + swide + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1  
body(num0) = "   <td align='left' width='" + swide + "'><font size='3' color='black' face='Verdana'><B>Metric Document, Scoring Metrics, Data, Model and Overall Diagnostic Information</B></font></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "<TABLE width='" + swide + "' BORDER='1'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1

body(num0) = "<tr>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='1'" + \
           " color='#000080' face='Verdana'><B>Metric Document</B></font></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='1'" + \
           " color='#000080' face='Verdana'><B>Rules for Scoring System</B></font></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='1'" + \
           " color='#000080' face='Verdana'><B>Scoring Metrics, Data and Overall Info</B></font></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='1'" + \
           " color='#000080' face='Verdana'><B>Model Data Availability</B></font></td>"
num0 = num0 + 1

body(num0) = "</tr>"
num0 = num0 + 1

body(num0) = "<tr>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='1'" + \ 
           " color='#000080' face='Verdana'>Click <a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
           " onmouseover=" + quote + "this.className='msover';" + quote + " href='../readme/ILAMB_metrics_document.pdf'" + \
           "><B>Here</B></a></font></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='1'" + \ 
           " color='#000080' face='Verdana'>Click <a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
           " onmouseover=" + quote + "this.className='msover';" + quote + " href='../readme/ILAMB_carbon_profile_info.pdf'" + \
           "><B>Here</B></a></font></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='1'" + \ 
           " color='#000080' face='Verdana'>Click <a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
           " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + HtmlScoring + \
           "'><B>Here</B></a></font></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><font size='1'" + \ 
           " color='#000080' face='Verdana'>Click <a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
           " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + HtmlNumEns + \
           "'><B>Here</B></a></font></td>"
num0 = num0 + 1

body(num0) = "</tr>"
num0 = num0 + 1

body(num0) = "</table>"
num0 = num0 + 1
body(num0) = "<BR><BR>"
num0 = num0 + 1

; ++++++ Summarize Overall Scores for each model here +++++

if (any(.not.ismissing(ValueGV)) .or. any(.not.ismissing(ValueVV))) then

   body(num0) = "                           "
   num0 = num0 + 1
   body(num0) = "<TABLE width='" + swide + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
   num0 = num0 + 1
   body(num0) = "<tr>"
   num0 = num0 + 1  
   body(num0) = "   <td align='left' width='" + swide + "'><font size='3' color='black' face='Verdana'><B>Overall Scores</B></font></td>"
   num0 = num0 + 1
   body(num0) = "</tr>"
   num0 = num0 + 1
   body(num0) = "</table>"
   num0 = num0 + 1

   body(num0) = "<TABLE width='" + swide + "' BORDER='1'  !BGCOLOR='#dbedc0'>"
   num0 = num0 + 1

   body(num0) = "<tr>"
   num0 = num0 + 1

   body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
             " color='#000080' face='Verdana'><B></B></font></td></table></td>"
   num0 = num0 + 1

   do nd=0, nmod-1
      body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                 " color='#000080' face='Verdana'><B>" + ModelNames(nd) + "</B></font></td></table></td>"
      num0 = num0 + 1
   end do

   body(num0) = "</tr>"
   num0 = num0 + 1

   if (any(.not.ismissing(ValueGV))) then

      body(num0) = "<tr>"
      num0 = num0 + 1

      body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \ 
                 " color='#000080' face='Verdana'><a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
                 " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + GVPlotName + \
                 "'><B>Global Variables</B></a></font></td></table></td>"
      num0 = num0 + 1

      do nd=0, nmod-1

         if (ismissing(ValueGV(nd))) then 
            body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                      " color='#000080' face='Verdana'><B>" + "-" + "</B></font></td></table></td>"
         else
            body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                      " color='#000080' face='Verdana'><B>" + sprintf("%5.2f", ValueGV(nd)) + "</B></font></td></table></td>"
         end if

         num0 = num0 + 1
      end do

      body(num0) = "</tr>"
      num0 = num0 + 1
   end if

   if (any(.not.ismissing(ValueVV))) then

      body(num0) = "<tr>"
      num0 = num0 + 1

      body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \ 
                 " color='#000080' face='Verdana'><a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
                 " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + VVPlotName + \
                 "'><B>Variable to Variable</B></a></font></td></table></td>"
      num0 = num0 + 1

      do nd=0, nmod-1

         if (ismissing(ValueVV(nd))) then 
            body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                      " color='#000080' face='Verdana'><B>" + "-" + "</B></font></td></table></td>"
         else
            body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                      " color='#000080' face='Verdana'><B>" + sprintf("%5.2f", ValueVV(nd)) + "</B></font></td></table></td>"
         end if

         num0 = num0 + 1
      end do

      body(num0) = "</tr>"
      num0 = num0 + 1
   end if

   body(num0) = "<tr>"
   num0 = num0 + 1

   body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \ 
              " color='#000080' face='Verdana'><a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
              " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + AllPlotName + \
              "'><B>Overall</B></a></font></td></table></td>"
   num0 = num0 + 1

   do nd=0, nmod-1

      if (ismissing(ValueAll(nd))) then 
         body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                   " color='#000080' face='Verdana'><B>" + "-" + "</B></font></td></table></td>"
      else
         body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                   " color='#000080' face='Verdana'><B>" + sprintf("%5.2f", ValueAll(nd)) + "</B></font></td></table></td>"
      end if

      num0 = num0 + 1
   end do

   body(num0) = "</tr>"
   num0 = num0 + 1
end if
body(num0) = "</table>"
num0 = num0 + 1
body(num0) = "<BR><BR>"
num0 = num0 + 1

body(num0) = "                           "
num0 = num0 + 1
body(num0) = "<TABLE width='" + swide + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1  
body(num0) = "   <td align='left' width='" + swide + "'><font size='3' color='black' face='Verdana'><B>Global Variables</B> (<a class='msout' onmouseout=" + quote \
           + "this.className='msout';s" + quote + " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + TableWeightNameGV + "'>Info</a> for Weightings" \
           + ")</font></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "                           "
num0 = num0 + 1

body(num0) = "<TABLE width='" + swide + "' BORDER='1'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1

body(num0) = "<tr>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
             " color='#000080' face='Verdana'><B></B></font></td></table></td>"
num0 = num0 + 1

do nd=0, nmod-1
   body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
               " color='#000080' face='Verdana'><B>" + ModelNames(nd) + "</B></font></td></table></td>"
   num0 = num0 + 1
end do

body(num0) = "</tr>"
num0 = num0 + 1

body(num0) = "                                      "
num0 = num0 + 1

; +++++++ Organize all variables for each category ++++++++
do nc=0, ncat-1
if (numbs(nc).gt.0) then
   i50 = ind(.not.ismissing(CatsID(nc,:)))
do ij=0, numbs(nc)-1

   nv = CatsID(nc,i50(ij))

   body(num0) = "<tr bgcolor=" + quote + bgcolors(nc) + quote + ">"
   num0 = num0 + 1

   DataInfo    = retrieve_DataInfo (VarNames(nv), "")
   VarLongName = DataInfo@LongName
   delete(DataInfo)

   body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \ 
                 " color='#000080' face='Verdana'><a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
                      " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + HtmlTableNames(nv) + \
                     "'><B>" + VarLongName + "</B></a></font></td></table></td>"
   num0 = num0 + 1

   do nd=0, nmod-1

      if (ismissing(Values(nv,nd))) then 
         body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                      " color='#000080' face='Verdana'><B>" + "-" + "</B></font></td></table></td>"
      else
         body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                      " color='#000080' face='Verdana'><B>" + sprintf("%5.2f", Values(nv,nd)) + "</B></font></td></table></td>"
      end if

      num0 = num0 + 1
   end do

   body(num0) = "</tr>"
   num0 = num0 + 1
   body(num0) = "                    "
   num0 = num0 + 1
end do

   body(num0) = "<tr bgcolor=" + quote + bgcolors(nc) + quote + ">"
   num0 = num0 + 1

   body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                 " color='#000080' face='Verdana'><B>Summary</B></font></td></table></td>"
   num0 = num0 + 1

   do nd=0, nmod-1

      vals = Values(CatsID(nc,i50), nd)
      wgts = WgtVars(CatsID(nc,i50))
      wgts = where(vals.eq.-999, 0, wgts)
      
      wgts   = wgts/sum(wgts)
      Value0 = sum(vals*wgts)

      delete(vals)
      delete(wgts)

      if (ismissing(Value0)) then 
         body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                      " color='#000080' face='Verdana'><B>" + "-" + "</B></font></td></table></td>"
      else
         body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                      " color='#000080' face='Verdana'><B>" + sprintf("%5.2f", Value0) + "</B></font></td></table></td>"
      end if

      num0 = num0 + 1
   end do

   body(num0) = "</tr>"
   num0 = num0 + 1
   body(num0) = "                    "
   num0 = num0 + 1

   delete(i50)
end if
end do

; ++++++ write out Overall Score +++++++
body(num0) = "<tr>"
num0 = num0 + 1

body(num0) = "<td align='center' width='60'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \ 
             " color='#000080' face='Verdana'><a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
                  " onmouseover=" + quote + "this.className='msover';" + quote + " href='ilamb-overall.html'" + \
                  "><B>Overall</B></a></font></td></table></td>"

num0 = num0 + 1
do nd=0, nmod-1

   if (ismissing(ValueGV(nd))) then
      body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                  " color='#000080' face='Verdana'><B>" + "-" + "</B></font></td></table></td>"
   else
      body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                  " color='#000080' face='Verdana'><B>" + sprintf("%5.2f", ValueGV(nd)) + "</B></font></td></table></td>"
   end if

   num0 = num0 + 1
end do

body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "<TABLE width='" + swide + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0)= "<td align='left'><font size='2'" + \
            " color='red' face='Verdana'><B>Notes:</B></font>" + \
            "<font size='2' color='black' face='Verdana'>  4 Categories are divided: </font>" + \
            "<font size='2' color='green' face='Verdana'>" + CatName(0) + ", </font>" + \
            "<font size='2' color='blue' face='Verdana'>" + CatName(1) + ", </font>" + \
            "<font size='2' color='red' face='Verdana'>" + CatName(2) + ", </font>" + \
            "<font size='2' color='gray' face='Verdana'>and " + CatName(3) + ". </font></td>"
num0 = num0 + 1
body(num0) = "</tr></table>"
num0 = num0 + 1

body(num0) = "                    "
num0 = num0 + 1


; ++++++ input control parameters from a file: ../CODES/tempfiles/input_para_pair* +++++

if (nvpa.ge.1) then

undef("ModelNames")
undef("PlotsFileNames")

FuncList   = new((/nvpa/), string)
Var1List   = new((/nvpa/), string)
Var2List   = new((/nvpa/), string)
Var1Unit   = new((/nvpa/), string)
Var2Unit   = new((/nvpa/), string)
Source1    = new((/nvpa/), string)
Source2    = new((/nvpa/), string)
ModelNames = new((/nvpa, 101/), string)
PlotsFileNames = new((/nvpa, 101/), string)
HtmlPlotsNames = new((/nvpa/), string)
StartYear    = new((/nvpa/), integer)
EndYear      = new((/nvpa/), integer)
v2vscores    = new((/nvpa, 101/), string)

v2vscores = "-999"

nmodx = 0

do nvp =0, nvpa-1

  FileName = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_pair" + sprinti("%0.2i",nvp+1)
  print(FileName)

  data_1d  = asciiread(str_squeeze(FileName),-1,"string")
  ;print(data_1d)

  FuncList(nvp) = str_squeeze(str_get_field(data_1d(2), 2, ":"))
  Var1List(nvp) = str_squeeze(str_get_field(data_1d(4), 2, ":"))
  Source1Ref    = str_get_field(data_1d(9), 2, ":")
  Var2List(nvp) = str_squeeze(str_get_field(data_1d(13), 2, ":"))
  Source2Ref    = str_get_field(data_1d(18), 2, ":")

  Source1(nvp)  = str_squeeze(str_get_field(Source1Ref, 1, "("))
  Source2(nvp)  = str_squeeze(str_get_field(Source2Ref, 1, "("))

  StartYear(nvp)= stringtointeger(str_get_field(data_1d(22), 2, ":"))
  EndYear(nvp)  = stringtointeger(str_get_field(data_1d(23), 2, ":"))

  ModelName     = str_squeeze(str_get_field(data_1d(27:), 1, " "))

  nmod=dimsizes(ModelName)

  ModelNames(nvp,0)      = "Benchmark"
  ModelNames(nvp,1:nmod) = ModelName

  nmodx = where(nmod.gt.nmodx, nmod, nmodx)

  TableFileName = DataDir0 + "/v2vscore/v2vscore_pair" + sprinti("%0.2i",nvp+1) + ".txt"
  print(TableFileName)

  data1d = asciiread(TableFileName,-1,"string")

  v2vscores(nvp,1:nmod) = str_squeeze(str_get_field(data1d(2:), 2, " "))

  v2vscores(nvp,0) = "1"

  delete(data1d)
  delete(data_1d)
  delete(ModelName)
end do

v2vscores@_FillValue = "-999"

;++++ search plot file names for all pairs of variables ++++
do nk=0,nvpa-1
do nd=0,nmodx
   DataDirPlot1 = DataDir0 + "/relationships/"
   DataDirPlot2 = "../relationships/" + str_lower(FuncList(nk))

   ModelName      = ModelNames(nk,nd)
   PlotsFileName1 = DataDirPlot1 + "/" + str_lower(FuncList(nk)) + "_" + ModelName + "_" + str_lower(Var1List(nk)) + ".vs." + \
                    str_lower(Var2List(nk)) + "_" + sprinti("%0.4i",StartYear(nk)) + "-" + sprinti("%0.4i",EndYear(nk)) + ".png"
   PlotsFileName2 = DataDirPlot2 + "/plots/PNG/" + str_lower(FuncList(nk)) + "_" + ModelName + "_" + str_lower(Var1List(nk)) + ".vs." + \
                    str_lower(Var2List(nk)) + "_" + sprinti("%0.4i",StartYear(nk)) + "-" + sprinti("%0.4i",EndYear(nk)) + ".png"
   if (fileexists(PlotsFileName1)) then
      PlotsFileNames(nk,nd) = PlotsFileName2
   end if
end do
end do

;++++ create html for single pair of variables ++++
do nk=0,nvpa-1

   DataInfo1    = retrieve_DataInfo (Var1List(nk), "")
   DataInfo2    = retrieve_DataInfo (Var2List(nk), "")
   VarLongName1 = DataInfo1@LongName
   VarLongName2 = DataInfo2@LongName
   delete(DataInfo1)
   delete(DataInfo2)

   HtmlPlotsName = DataDir0 + "/www/plot_" + str_lower(FuncList(nk)) + "_" + str_lower(Var1List(nk)) + ".vs." + str_lower(Var2List(nk)) + ".html"

   create_plots (HtmlPlotsName, VarLongName1, VarLongName2, Source1(nk), Source2(nk), ModelNames(nk,:), PlotsFileNames(nk,:))
   HtmlPlotsName = str_sub_str(HtmlPlotsName, getenv("ILAMB_OUTPUTDIR") + "/www/", "")
   HtmlPlotsNames(nk) = HtmlPlotsName

end do

body(num0) = "<br>"
num0 = num0 + 1
body(num0) = "<br>"
num0 = num0 + 1

;++++ create html for all pairs of variables ++++
body(num0) = "                           "
num0 = num0 + 1
body(num0) = "<TABLE width='" + swide1 + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "   <td align='left' width='" + swide1 + "'><font size='3' color='black' face='Verdana'><B>Variable to Variable Relationships</B> (<a class='msout' onmouseout=" + quote \
           + "this.className='msout';s" + quote + " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + TableWeightNameVV + "'>Info</a> for Weightings" \
           + ")</font></td>"

num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "                           "
num0 = num0 + 1

body(num0) = "<TABLE width='" + swide1 + "' BORDER='1'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1

body(num0) = "<tr>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
             " color='#000080' face='Verdana'><B></B></font></td></table></td>"
num0 = num0 + 1

body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
             " color='#000080' face='Verdana'><B>Relationship</B></font></td></table></td>"
num0 = num0 + 1

do nd=0, nmod

   ;VarName = VarName + " (" + VarUnit + ")"

   body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                 " color='#000080' face='Verdana'><B>" + ModelNames(0, nd) + "</B></font></td></table></td>"
   num0 = num0 + 1
end do

body(num0) = "</tr>"
num0 = num0 + 1

body(num0) = "                                      "
num0 = num0 + 1

do nv=0, nvpa-1

   DataInfo1    = retrieve_DataInfo (Var1List(nv), Source1(nv))
   DataInfo2    = retrieve_DataInfo (Var2List(nv), Source2(nv))
   VarLongName1 = DataInfo1@LongName
   VarLongName2 = DataInfo2@LongName
   delete(DataInfo1)
   delete(DataInfo2)

   result1     = retrieve_unit (Var1List(nv), Source1(nv))
   result2     = retrieve_unit (Var2List(nv), Source2(nv))

   VarUnit1    = result1@FinalTable
   VarUnit2    = result2@FinalTable

   delete(result1)
   delete(result2)

   body(num0) = "<tr>"
   num0 = num0 + 1

   body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
               " color='#000080' face='Verdana'><a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
                      " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + HtmlPlotsNames(nv) + \
                     "'><B>" + VarLongName1 + " vs. " + VarLongName2 + "</B></font></a></td></table></td>"
   num0 = num0 + 1

   body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                " color='#000080' face='Verdana'><B>" + FuncList(nv) + "</B></font></td></table></td>"
   num0 = num0 + 1

   do nd=0, nmod

      if (ismissing(PlotsFileNames(nv,nd))) then
         body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                      " color='#000080' face='Verdana'><B>" + "-" + "</B></font></td></table></td>"
      else
         body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                      " color='#000080' face='Verdana'><a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
                      " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + PlotsFileNames(nv,nd) + \
                      "'><B>" + v2vscores(nv,nd) + "</B></a></font></td></table></td>"
      end if

      num0 = num0 + 1
   end do

   body(num0) = "</tr>"
   num0 = num0 + 1
   body(num0) = "                    "
   num0 = num0 + 1
end do

if (any(.not.ismissing(ValueVV))) then

   body(num0) = "<tr>"
   num0 = num0 + 1

   body(num0) = "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \ 
              " color='#000080' face='Verdana'><a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + \
              " onmouseover=" + quote + "this.className='msover';" + quote + " href='" + VVPlotName + \
              "'><B>Overall</B></a></font></td></table></td>"
   num0 = num0 + 1

   body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
             " color='#000080' face='Verdana'></font></td></table></td>"
   num0 = num0 + 1
   body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
             " color='#000080' face='Verdana'></font></td></table></td>"
   num0 = num0 + 1

   do nd=0, nmod-1

      if (ismissing(ValueVV(nd))) then 
         body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                   " color='#000080' face='Verdana'><B>" + "-" + "</B></font></td></table></td>"
      else
         body(num0)= "<td align='center' width='100'><table bordercolor='#8b73ca' border='0'><td align='center'><font size='1'" + \
                   " color='#000080' face='Verdana'><B>" + sprintf("%5.2f", ValueVV(nd)) + "</B></font></td></table></td>"
      end if

      num0 = num0 + 1
   end do

   body(num0) = "</tr>"
   num0 = num0 + 1
end if

body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "                    "
num0 = num0 + 1

delete(EndYear)
delete(StartYear)
delete(v2vscores)

end if

body(num0) = "<BR><BR>"
num0 = num0 + 1

body(num0) = "<div class='divline'>"
num0       = num0 + 1
body(num0) = "<table border=0 cellpadding=0 cellspacing=0 width=100% align='center' valign='center'>"
num0       = num0 + 1
body(num0) = "<tr><td valign='center' align='center' height=1 bgcolor='red'></td></tr>"
num0       = num0 + 1
body(num0) = "<tr><td valign='center' align='center' height=10 bgcolor='lightblue'></td></tr>"
num0       = num0 + 1
body(num0) = "<tr><td valign='center' align='center' height=1 bgcolor='red'></td></tr>"
num0       = num0 + 1
body(num0) = "                 "
num0       = num0 + 1
body(num0) = "<tr><td>"
num0       = num0 + 1
body(num0) = "<table width=100% height=5>"
num0       = num0 + 1
body(num0) = "                 "
num0       = num0 + 1
body(num0) = "<tr>"
num0       = num0 + 1
body(num0) = "<td align='left' valign='center' width=50% height=10><font size=1 face='Verdana'><I><B>"
num0       = num0 + 1
body(num0) = "<a href='http://www.ess.uci.edu' TARGET='_blank'>Earth System Science</a><BR>"
num0       = num0 + 1
body(num0) = "<a href='http://www.uci.edu' TARGET='_blank'>University of California Irvine</a><BR>"
num0       = num0 + 1
body(num0) = "240C Rowland Hall, Irvine, CA 92697-3100</B></I><BR></font>"
num0       = num0 + 1
body(num0) = "</td>"
num0       = num0 + 1
body(num0) = "                "
num0       = num0 + 1
body(num0) = "<td align='right' valign='center' width=50% height=10><font size=1 face='Verdana'>"
num0       = num0 + 1
body(num0) = "<B><I>Email:<a href='mailto:mmu@uci.edu' TARGET='_blank'>mmu@uci.edu</a><BR>"
num0       = num0 + 1
body(num0) = "URL:<a href='http://redwood.ess.uci.edu/mingquan/www/ILAMB/index.html' TARGET='_blank'>http://redwood.ess.uci.edu</a><BR>"
num0       = num0 + 1
body(num0) = "Phone: (949) 824-1474; Fax: (949) 824-3874</I></B><BR></font>"
num0       = num0 + 1
body(num0) = "</td></tr>"
num0       = num0 + 1
body(num0) = "                    "
num0       = num0 + 1
body(num0) = "<tr><td></td></tr>"
num0       = num0 + 1
body(num0) = "</table>"
num0       = num0 + 1
body(num0) = "</td></tr>"
num0       = num0 + 1
body(num0) = "             "
num0       = num0 + 1
body(num0) = "</table>"
num0       = num0 + 1
body(num0) = "</body"
num0       = num0 + 1
body(num0) = "</div>"
num0       = num0 + 1
body(num0) = "</HTML"
num0       = num0 + 1

num0=num0

asciiwrite(HtmlPageName,body(0:num0-1))

end

; ################################################################################################################################
procedure create_ilamb_overall (HtmlPlotsName:string)

begin

DataDir  = getenv("ILAMB_ROOT")
DataDir0 = ".."

quote = str_get_dq()

wide=800
swide=sprinti("%3i",wide)

ntep=1

wides=wide*ntep
swides=sprinti("%3i",wides)

PlotsFileName = DataDir0 + "/summary/plots/PNG/overallscore_all.png"

body = new((/10000/), string)

num0 = 0
body(num0) = "<html>"
num0 = num0 + 1
body(num0) = "<head><title>Output for ILAMB Diagnostics</title></head>"
num0 = num0 + 1
body(num0) = "<body>"
num0 = num0 + 1
body(num0) = "                           "
   num0 = num0 + 1
body(num0) = "<TABLE width='" + swides + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
   num0 = num0 + 1
body(num0) = "<tr>"
   num0 = num0 + 1
body(num0) = "    <td align='center' height='20'></td>"
   num0 = num0 + 1
body(num0) = "</tr>"
   num0 = num0 + 1
body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "                           "
num0 = num0 + 1
body(num0) = "<TABLE width='" + swides + "' BORDER='0'  !BGCOLOR='#dbedc0'>"
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "   <td align='center' width='" + swide + "'><font size='3' color='black' face='Verdana'><B>Overall Score for Each Model</B></font></td>"
num0 = num0 + 1
body(num0) = "</tr>"
num0 = num0 + 1

body(num0) = "                       "
num0 = num0 + 1
body(num0) = "<tr>"
num0 = num0 + 1
body(num0) = "<td align='center' width='" + swide + "'><table bordercolor='#8b73ca' border='0'><td align='center'> " + \
              "<a class='msout' onmouseout=" + quote + "this.className='msout';s" + quote + " onmouseover=" + quote + "this.className='msover';" + quote + \
              " href='ilamb-summary.html'><img src='" + PlotsFileName + "'  border='0' width='" + swide + "'></a></td></table></td>"
num0 = num0 + 1

body(num0) = "</tr>"
num0 = num0 + 1

body(num0) = "</table>"
num0 = num0 + 1

body(num0) = "</body>"
num0 = num0 + 1

body(num0) = "</html>"
num0 = num0 + 1

body(num0) = ""
num0 = num0 + 1

asciiwrite(HtmlPlotsName,body(0:num0-1))

end

; ################################################################################################################################
procedure create_html (VarNames:string, nvpa:integer, nchk:integer)

begin

DataDir   = getenv("ILAMB_ROOT")
DataDir0  = "../"

;create_ilamb_main
;create_ilamb_bottom

nvar=dimsizes(VarNames)

results     = retrieve_others("Metrics", "-999")
AllKeyWords = results@Category

delete(results)

nallkeys    = dimsizes(AllKeyWords)
nKeyWords   = new((/nallkeys/), integer)

print("                                                                       ")
print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
print("Creating HTML files for output from diagnostics")

;++++ Retrieve Variable Names with Individual Site ++++

VarListSite    = new((/nvar/), string)
SourceListSite = new((/nvar/), string)

do nck =0, nchk-1
   FileName1 = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_check" + sprinti("%0.2i",nck+1)
   print(FileName1)

   data_1d  = asciiread(str_squeeze(FileName1),-1,"string")
   ;print(data_1d)

   VarListSite(nck)    = str_squeeze(str_get_field(data_1d(1), 2, ":"))
   TempString          = str_squeeze(str_get_field(data_1d(6), 2, ":"))
   SourceListSite(nck) = str_squeeze(str_get_field(TempString, 1, "("))
   delete(data_1d)
   delete(TempString)
end do

; ++++++ Set additonal arrays  +++++

HtmlTableNames = new((/nvar/), string)
HtmlPlotsNames = new((/nvar,100,100/), string)
HtmlPlotsNames0= new((/nvar,100/), string)
KeyWords0      = new((/nvar,100/), string)
ModelNames0    = new((/nvar,100/), string)
Values         = new((/nvar,100/), float)

WgtVars        = new((/nvar/), float)

WgtVars = 0.0

do nv=0,nvar-1

   if (nvar.gt.1) then
      VarName=VarNames(nv)
   else
      VarName=VarNames
   end if

   print("                                                                       ")
   print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
   print("Searching All Data Sources for the Variable: " + VarName)

   InputFiles = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_" + str_lower(VarName)

   FileList = systemfunc ("ls " + InputFiles + "*")

   FileList = str_squeeze(FileList)

   nsur     = dimsizes(FileList)

   if (nsur.gt.1) then

      Sources        = new((/nsur/), string)
      ncks           = new((/nsur/), integer)
      do ns = 0, nsur-1
         Sourcet0    = str_split(FileList(ns),"/")
         nlast0      = dimsizes(Sourcet0)
         Sourcet1    = str_split(Sourcet0(nlast0-1),"_")
         nlast1      = dimsizes(Sourcet1)
         Sources(ns) = Sourcet1(nlast1-1)

         i50 = ind((str_lower(VarListSite).eq.str_lower(VarName)).and.(str_lower(SourceListSite).eq.str_lower(Sources(ns))))

         if (.not.ismissing(i50)) then
            ncks(ns) = i50 + 1
         else
            ncks(ns) = 0
         end if

         delete(i50)
         delete(Sourcet0)
         delete(Sourcet1)
      end do

   else

      Sourcet0 = str_split(FileList,"/")
      nlast0   = dimsizes(Sourcet0)
      Sourcet1 = str_split(Sourcet0(nlast0-1),"_")
      nlast1   = dimsizes(Sourcet1)
      Sources  = Sourcet1(nlast1-1)

      i50 = ind(str_lower(VarListSite).eq.str_lower(VarName))

      if (.not.ismissing(i50)) then
         ncks = i50 + 1
      else
         ncks = 0
      end if

      delete(i50)
      delete(Sourcet0)
      delete(Sourcet1)
   end if

   delete(FileList)

   ;+++++++++++++ create the reference for each benchmark ++++++++++++++++
   Refers   = new((/nsur/), string)

   do ns=0,nsur-1
      DataInfo   = retrieve_DataInfo (VarName, Sources(ns))
      Refers(ns) = DataInfo@Reference
      delete(DataInfo)
   end do

   ; ++++++ Read parameters from the input file: ../CODES/tempfiles/input_para_* +++++
   StartYears  = new((/nsur/), integer)
   EndYears    = new((/nsur/), integer)

   nKeyWords   = 0

   do ns=0,nsur-1

      TableFileName= getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_" + str_lower(VarName) + "_" + str_upper(Sources(ns))

      data_1d      = asciiread(TableFileName,-1,"string")

      VarUnit      = str_squeeze(str_get_field(data_1d(2), 2, ":"))
      SourceRef    = str_get_field(data_1d(6), 2, ":")
      StartYear    = stringtointeger(str_get_field(data_1d(9), 2, ":"))
      EndYear      = stringtointeger(str_get_field(data_1d(10), 2, ":"))
      SubReg1      = str_squeeze(str_get_field(data_1d(11), 2, ":"))
      SubReg2      = str_squeeze(str_get_field(data_1d(12), 2, ":"))
      KeyWord0     = str_get_field(data_1d(13), 2, ":")
      ModelNames   = str_squeeze(str_get_field(data_1d(16:), 1, " "))
      cmipID       = stringtointeger(str_get_field(data_1d(16:), 2, " "))

      nmod         = dimsizes(ModelNames)
      nkey         = dimsizes(str_split(KeyWord0,","))
      KeyWord      = str_squeeze(str_split(KeyWord0,","))

      StartYears(ns) = StartYear
      EndYears(ns)   = EndYear

      ;if (nkey.gt.nkeys) then
      ;   delete(KeyWords)
      ;   KeyWords = KeyWord
      ;   nkeys    = nkey
      ;end if

      do nk=0,nkey-1
         i50 = ind(str_lower(str_squeeze(KeyWord(nk))).eq.str_lower(str_squeeze(AllKeyWords)))
         if (.not.ismissing(i50)) then
            nKeyWords(i50) = 1
         end if
         delete(i50)
      end do

      if (ns.eq.(nsur-1)) then

         j50      = ind(nKeyWords.gt.0)
         KeyWords = AllKeyWords(j50)

         nkeys    = dimsizes(KeyWords)

         KeyWords0(nv,0:nkeys-1) = KeyWords
         KeyWords0(nv,nkeys)     = "summary"

         delete(j50)
      end if

      delete(data_1d)
      delete(KeyWord)
      delete(KeyWord0)
      delete(EndYear)
      delete(StartYear)
   end do

   nkey = nkeys  

   ;results   = retrieve_others("Metrics", "-999")
   ;TempStr   = results@Category

   ;nkey      = dimsizes(TempStr)

   ;delete(results)
   ;delete(TempStr)

   ;+++++++++++++ create html files for plots ++++++++++++++++

   HtmlPlotsName = new((/nsur,nkey/), string)
   
   if (nsur.gt.1) then

      HtmlPlotsName = create_html_plots (VarName, Sources, KeyWords, StartYears, EndYears, ModelNames)
      HtmlPlotsName0= create_html_plots_all (VarName, Sources, KeyWords, StartYears, EndYears, ModelNames)

      HtmlPlotsName = str_sub_str(HtmlPlotsName, getenv("ILAMB_OUTPUTDIR") + "/www/", "")
      HtmlPlotsName0= str_sub_str(HtmlPlotsName0,getenv("ILAMB_OUTPUTDIR") + "/www/", "")

      do ns=0,nsur-1
         HtmlPlotsNames(nv,ns,0:dimsizes(HtmlPlotsName(0,:))-1) = HtmlPlotsName(ns,:)
      end do

   else

      HtmlPlotsName0 = create_html_plots_all (VarName, Sources, KeyWords, StartYears, EndYears, ModelNames)
      HtmlPlotsName0 = str_sub_str(HtmlPlotsName0,getenv("ILAMB_OUTPUTDIR") + "/www/", "")
      HtmlPlotsName(0,:) = HtmlPlotsName0
      HtmlPlotsNames(nv,0,0:dimsizes(HtmlPlotsName0)-1) = HtmlPlotsName0

   end if

   HtmlPlotsNames0(nv,0:dimsizes(HtmlPlotsName0)-1) = HtmlPlotsName0
   
   ;+++++++++++++ create html files for tables ++++++++++++++++

   if (nsur.gt.1) then
      Value0         = new((/nsur, nmod/), float)
      WgtVar         = new((/nsur, nkey/), float)

      HtmlTableNameSources = getenv("ILAMB_OUTPUTDIR") + "/www/table_" + str_lower(VarName) + "_" + Sources + ".html"
      Value0 = create_html_table (HtmlTableNameSources, HtmlPlotsName, VarName, Sources, \
                        KeyWords, StartYears, EndYears, ModelNames, Refers, WgtVar, SubReg1, SubReg2, ncks)
      HtmlTableNameSources = str_sub_str(HtmlTableNameSources, getenv("ILAMB_OUTPUTDIR") + "/www/", "")

      WgtVar!0="source"
      WgtVar!1="key"

      ; +++++ Weightings here are based on numbers of observations ++++++
      wgts = WgtVar(0:nsur-1,nkey-1)

      ; ++++++++++ read Weightings for Sources +++++++++++

      TableFileName = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarName) + "/overallscore/weights_" + str_lower(VarName) + "_Sources.txt"

      if (fileexists(TableFileName)) then
         print(TableFileName)

         data_2d = asciiread(TableFileName,-1,"string")
         ;print(data_2d)

         wgts     = stringtointeger(str_get_field(data_2d(2:), 2, ":"))

         delete(data_2d)
      end if

      ; +++++ Weightings here are based on presetted values (default) ++++++
      ;do ns = 0, nsur-1
      ;   wgts(ns) = retrieve_weight (Sources(ns))
      ;end do

      ;wgts = wgts/sum(wgts)

      do nd=0,nmod-1
         Values(nv,nd) = dim_sum(Value0(:,nd)*wgts)/sum(wgts)
      end do

      HtmlTableName = getenv("ILAMB_OUTPUTDIR") + "/www/table_" + str_lower(VarName) + ".html"
      create_table_sources (HtmlTableName, HtmlTableNameSources, VarName, Sources, Refers, wgts)

      ; +++++ Weightings here are based on numbers of observations ++++++
      WgtVars(nv) = dim_sum(WgtVar(key|nkey-1,source|:))

      ; +++++ Weightings here are modified by presetted values (default) ++++++
      DataInfo = retrieve_DataInfo (VarName, "")
      CatName  = DataInfo@Category
      delete(DataInfo)

      Coef   = retrieve_weight (VarName, "-999")

      WgtVars(nv) = Coef

      delete(Coef)
      delete(CatName)

      delete(Value0)
      delete(wgts)
      delete(WgtVar)
      delete(HtmlTableNameSources)
   else
      WgtVar         = new((/nkey/), float)
      HtmlTableName = getenv("ILAMB_OUTPUTDIR") + "/www/table_" + str_lower(VarName) + ".html"
      Values(nv,0:nmod-1) = create_html_table (HtmlTableName, HtmlPlotsName, VarName, Sources, \
                            KeyWords, StartYears, EndYears, ModelNames, Refers, WgtVar, SubReg1, SubReg2, ncks)

      ; +++++ Weightings here are based on numbers of observations ++++++
      WgtVars(nv) = WgtVar(nkey-1)

      ; +++++ Weightings here are modified by presetted values (default) ++++++
      DataInfo = retrieve_DataInfo (VarName, "")
      CatName  = DataInfo@Category
      delete(DataInfo)

      Coef   = retrieve_weight (VarName, "-999")

      WgtVars(nv) = Coef

      delete(Coef)
      delete(CatName)

      delete(WgtVar)
   end if

   HtmlTableName = str_sub_str(HtmlTableName, getenv("ILAMB_OUTPUTDIR") + "/www/", "")
   HtmlTableNames(nv) = HtmlTableName

   delete(ncks)
   delete(cmipID)
   delete(StartYears)
   delete(EndYears)
   delete(Refers)
   delete(Sources)
   delete(KeyWords)
   delete(HtmlTableName)
   delete(HtmlPlotsName)
   delete(HtmlPlotsName0)
end do

;++++++++ If you want all variables with the same contributions, uncomment the following line ++++++++
;WgtVars=1.0

WgtVars=WgtVars/sum(WgtVars)

HtmlPageName = getenv("ILAMB_OUTPUTDIR") + "/www/ilamb-overall.html"
create_ilamb_overall (HtmlPageName)

;HtmlPageName = getenv("ILAMB_OUTPUTDIR") + "/www/ilamb-summary.html"
HtmlPageName = getenv("ILAMB_OUTPUTDIR") + "/www/ilamb.html"
create_main_page (HtmlPageName, VarNames, HtmlTableNames, Values, nvpa, nchk, WgtVars)

;HtmlTopName = getenv("ILAMB_OUTPUTDIR") + "/www/ilamb-top.html"
;create_top_menu (HtmlTopName, VarNames, KeyWords0, HtmlPlotsNames0, HtmlTableNames)

end

; ################################################################################################################################

