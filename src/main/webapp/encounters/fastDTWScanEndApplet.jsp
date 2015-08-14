<%--
  ~ The Shepherd Project - A Mark-Recapture Framework
  ~ Copyright (C) 2011 Jason Holmberg
  ~
  ~ This program is free software; you can redistribute it and/or
  ~ modify it under the terms of the GNU General Public License
  ~ as published by the Free Software Foundation; either version 2
  ~ of the License, or (at your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~ GNU General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
  --%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="org.ecocean.servlet.ServletUtilities,
         org.dom4j.Document, 
         org.dom4j.Element, 
         org.dom4j.io.SAXReader, 
         org.ecocean.*, 
         org.ecocean.grid.*, 
         java.io.File, 
         java.util.Arrays, 
         java.util.Iterator, 
         java.util.List, 
         java.util.Vector,
         java.util.StringTokenizer" 
  %>
<html>


<%

String context="context0";
context=ServletUtilities.getContext(request);

  session.setMaxInactiveInterval(6000);
  String num = request.getParameter("number");
  //Shepherd myShepherd = new Shepherd(context);
  //if (request.getParameter("writeThis") == null) {
  //  myShepherd = (Shepherd) session.getAttribute(request.getParameter("number"));
  //}
  //Shepherd altShepherd = new Shepherd(context);
  String sessionId = session.getId();
  boolean xmlOK = false;
  SAXReader xmlReader = new SAXReader();
  File file = new File("foo");
  String scanDate = "";
  String side2 = "";
  
  //setup data dir
  String rootWebappPath = getServletContext().getRealPath("/");
  File webappsDir = new File(rootWebappPath).getParentFile();
  File shepherdDataDir = new File(webappsDir, CommonConfiguration.getDataDirectoryName(context));
  //if(!shepherdDataDir.exists()){shepherdDataDir.mkdirs();}
  File encountersDir=new File(shepherdDataDir.getAbsolutePath()+"/encounters");
  //if(!encountersDir.exists()){encountersDir.mkdirs();}
	String encSubdir = Encounter.subdir(num);
  //File thisEncounterDir = new File(encountersDir, encSubdir);   //never used??
 
%>

<head>
  <title>Best matches for Encounter <%=num%>
  </title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <meta http-equiv="expires" content="0">
  <link
    href="http://<%=CommonConfiguration.getURLLocation(request)%>/css/ecocean.css"
    rel="stylesheet" type="text/css"/>
      <link href="../css/pageableTable.css" rel="stylesheet" type="text/css"/>
<link rel="stylesheet" href="../javascript/tablesorter/themes/blue/style.css" type="text/css" media="print, projection, screen" />
      
</head>

<style type="text/css">
  
  #tabmenu {
    color: #000;
    border-bottom: 1px solid #CDCDCD;
    margin: 12px 0px 0px 0px;
    padding: 0px;
    z-index: 1;
    padding-left: 10px
  }

  #tabmenu li {
    display: inline;
    overflow: hidden;
    list-style-type: none;
  }

  #tabmenu a, a.active {
    color: #000;
    background: #E6EEEE;
    font: 0.5em "Arial, sans-serif;
    border: 1px solid #CDCDCD;
    padding: 2px 5px 0px 5px;
    margin: 0;
    text-decoration: none;
    border-bottom: 0px solid #FFFFFF;
  }

  #tabmenu a.active {
    background: #8DBDD8;
    color: #000000;
    border-bottom: 1px solid #8DBDD8;
  }

  #tabmenu a:hover {
    color: #000;
    background: #8DBDD8;
  }

  #tabmenu a:visited {
    
  }

  #tabmenu a.active:hover {
    color: #000;
    border-bottom: 1px solid #8DBDD8;
  }
  
</style>

<body>
 
<div id="wrapper">
<div id="page">
<jsp:include page="../header.jsp" flush="true">
  <jsp:param name="isAdmin" value="<%=request.isUserInRole(\"admin\")%>" />
</jsp:include>
<div id="main">
<script type="text/javascript" src="https://www.google.com/jsapi"></script>
    
<script>
	var chartWidth=300;
	var chartHeight=300;
	// Set chart options
	var options = {'title':'FastDTW Path',
	               'width':chartWidth,
	               'height':chartHeight,
	               'pointSize': 5
	               };
	
	
	google.load('visualization', '1.1', {packages: ['line', 'corechart']});
</script>

<ul id="tabmenu">
  <li><a
    href="encounter.jsp?number=<%=request.getParameter("number")%>">Encounter
    
  </a></li>
  <%
    String fileSider = "";
    File finalXMLFile;
    if ((request.getParameter("rightSide") != null) && (request.getParameter("rightSide").equals("true"))) {
      finalXMLFile = new File(encountersDir.getAbsolutePath()+"/" + encSubdir + "/lastFullRightScan.xml");

      side2 = "right";
      fileSider = "&rightSide=true";
    } else {
      finalXMLFile = new File(encountersDir.getAbsolutePath()+"/" + encSubdir + "/lastFullScan.xml");

    }
    if (finalXMLFile.exists()) {
    	if((CommonConfiguration.getProperty("algorithms", context)!=null)&&(CommonConfiguration.getProperty("algorithms", context).indexOf("ModifiedGroth")!=-1)){
			  %>
			  <li><a
			    href="scanEndApplet.jsp?writeThis=true&number=<%=request.getParameter("number")%><%=fileSider%>">Modified
			    Groth</a></li>
			
			  <%
    	}
    }
    
    if((CommonConfiguration.getProperty("algorithms", context)!=null)&&(CommonConfiguration.getProperty("algorithms", context).indexOf("I3S")!=-1)){
		 
  %>
    <li><a href="i3sScanEndApplet.jsp?writeThis=true&number=<%=request.getParameter("number")%>&I3S=true<%=fileSider%>">I3S</a>
  </li>
  <%
    }
    if((CommonConfiguration.getProperty("algorithms", context)!=null)&&(CommonConfiguration.getProperty("algorithms", context).indexOf("FastDTW")!=-1)){
		 
  %>
  
    <li><a class="active">FastDTW</a></li>
    <%
    }
    
    if((CommonConfiguration.getProperty("algorithms", context)!=null)&&(CommonConfiguration.getProperty("algorithms", context).indexOf("Whitehead")!=-1)){
		 
    %>
  
    <li><a href="geroScanEndApplet.jsp?writeThis=true&number=<%=request.getParameter("number")%>&I3S=true<%=fileSider%>">Gero</a>
  
  <%
    }
    if((CommonConfiguration.getProperty("algorithms", context)!=null)&&(CommonConfiguration.getProperty("algorithms", context).indexOf("HolmbergIntersection")!=-1)){
		 
  %>
  <li><a href="intersectionScanEndApplet.jsp?writeThis=true&number=<%=request.getParameter("number")%>&I3S=true<%=fileSider%>">Intersection</a>
  
<%
    }
%>

</ul>

<%
  Vector initresults = new Vector();
  Document doc;
  Element root;
  String side = "left";

  if (request.getParameter("writeThis") == null) {
    //initresults=myShepherd.matches;
    if ((request.getParameter("rightSide") != null) && (request.getParameter("rightSide").equals("true"))) {
      side = "right";
    }
  } else {

//read from the written XML here if flagged
    try {
      if ((request.getParameter("rightSide") != null) && (request.getParameter("rightSide").equals("true"))) {
        //file=new File((new File(".")).getCanonicalPath()+File.separator+"webapps"+File.separator+"ROOT"+File.separator+"encounters"+File.separator+num+File.separator+"lastFullRightI3SScan.xml");
        file = new File(encountersDir.getAbsolutePath()+"/" + encSubdir + "/lastFullRightFastDTWScan.xml");

        side = "right";
      } else {
        //file=new File((new File(".")).getCanonicalPath()+File.separator+"webapps"+File.separator+"ROOT"+File.separator+"encounters"+File.separator+num+File.separator+"lastFullI3SScan.xml");
        file = new File(encountersDir.getAbsolutePath()+"/" + encSubdir + "/lastFullFastDTWScan.xml");
      }
      doc = xmlReader.read(file);
      root = doc.getRootElement();
      scanDate = root.attributeValue("scanDate");
      xmlOK = true;
    } catch (Exception ioe) {
      System.out.println("Error accessing the stored scan XML data for encounter: " + num);
      ioe.printStackTrace();
      //initresults=myShepherd.matches;
      xmlOK = false;
    }

  }
  MatchObject[] matches = new MatchObject[0];
  if (!xmlOK) {
    int resultsSize = initresults.size();
    //System.out.println(resultsSize);
    matches = new MatchObject[resultsSize];
    for (int a = 0; a < resultsSize; a++) {
      matches[a] = (MatchObject) initresults.get(a);
    }

  }
%>

<p><a href="#resultstable">See the table below for score breakdowns.</a></p>
		  <%
		  

		    String feedURL = "http://" + CommonConfiguration.getURLLocation(request) + "/TrackerFeed?number=" + num;
		    String baseURL = "/"+CommonConfiguration.getDataDirectoryName(context)+"/encounters/";
		    System.out.println("Base URL is: " + baseURL);
		    if (xmlOK) {
		      if ((request.getParameter("rightSide") != null) && (request.getParameter("rightSide").equals("true"))) {
		        feedURL = baseURL + encSubdir + "/lastFullRightFastDTWScan.xml?";
		      } else {
		        feedURL = baseURL + encSubdir + "/lastFullFastDTWScan.xml?";
		      }
		    }
		    String rightSA = "";
		    if ((request.getParameter("rightSide") != null) && (request.getParameter("rightSide").equals("true"))) {
		      rightSA = "&filePrefix=extractRight";
		    }
		    System.out.println("I made it to the Flash without exception.");
		  %>
		  <OBJECT id="sharkflash"
		          codeBase=http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0
		          height=450 width=800 classid=clsid:D27CDB6E-AE6D-11cf-96B8-444553540000>
		    <PARAM NAME="movie"
		           VALUE="tracker.swf?sessionId=<%=sessionId%>&rootURL=<%=CommonConfiguration.getURLLocation(request)%>&baseURL=<%=baseURL%>&feedurl=<%=feedURL%><%=rightSA%>">
		    <PARAM NAME="quality" VALUE="high">
		    <PARAM NAME="scale" VALUE="exactfit">
		    <PARAM NAME="bgcolor" VALUE="#ddddff">
		    <EMBED
		      src="tracker.swf?sessionId=<%=sessionId%>&rootURL=<%=CommonConfiguration.getURLLocation(request)%>&baseURL=<%=baseURL%>&feedurl=<%=feedURL%>&time=<%=System.currentTimeMillis()%><%=rightSA%>"
		      quality=high scale=exactfit bgcolor=#ddddff swLiveConnect=TRUE
		      WIDTH="800" HEIGHT="450" NAME="sharkflash" ALIGN=""
		      TYPE="application/x-shockwave-flash"
		      PLUGINSPAGE="http://www.macromedia.com/go/getflashplayer"></EMBED>
		  </OBJECT>
		</p>

<h2>FastDTW Scan Results <a
  href="<%=CommonConfiguration.getWikiLocation(context)%>scan_results"
  target="_blank"><img src="../images/information_icon_svg.gif"
                       alt="Help" border="0" align="absmiddle"></a></h2>
</p>
<p>The following encounter(s) received the best
  match values using the FastDTW algorithm against a <%=side%>-side scan of
  encounter <a href="encounter.jsp?number=<%=num%>"><%=num%></a>.</p>


<%
  if (xmlOK) {%>
<p><img src="../images/Crystal_Clear_action_flag.png" width="28px" height="28px" hspace="2" vspace="2" align="absmiddle"><strong>&nbsp;Saved
  scan data may be old and invalid. Check the date below and run a fresh
  scan for the latest results.</strong></p>

<p><em>Date of scan: <%=scanDate%>
</em></p>

<%
}
%>

<a name="resultstable" /><table class="tablesorter">
  <thead>
  
        <tr align="left" valign="top">
          <th><strong>Individual</strong></th>
          <th><strong>Encounter</strong></th>
        
		<th><strong>FastDTW Score </strong></th>
		
		<th><strong>FastDTW Path </strong></th>

    </tr>
        </thead>
        <tbody>
        <%
          if (!xmlOK) {

            MatchObject[] results = new MatchObject[1];
            results = matches;
            Arrays.sort(results, new FastDTWMatchComparator());
            for (int p = 0; p < results.length; p++) {
              //if ((results[p].matchValue != 0) || (request.getAttribute("singleComparison") != null)) {
              %>
        <tr align="left" valign="top">
         
                <td width="60" align="left"><a
                  href="http://<%=CommonConfiguration.getURLLocation(request)%>/individuals.jsp?number=<%=results[p].getIndividualName()%>"><%=results[p].getIndividualName()%>
                </a></td>
             
          <%if (results[p].encounterNumber.equals("N/A")) {%>
          <td>N/A</td>
          <%} else {%>
          <td><a
            href="http://<%=CommonConfiguration.getURLLocation(request)%>/encounters/encounter.jsp?number=<%=results[p].encounterNumber%>">Link
          </a></td>
          <%
            }
            String finalscore2 = (new Double(results[p].getRightFastDTWResult())).toString();
			String path=results[p].getFastDTWPath();
            //trim the length of finalscore
            if (finalscore2.length() > 7) {
              finalscore2 = finalscore2.substring(0, 6);
            }
          %>
          <td><%=finalscore2%>
          </td>
               <td><%=path%>&nbsp;
          </td>

		
		

        </tr>

        <%
              //end if matchValue!=0 loop
            //}
            //end for loop
          }

//or use XML output here	
        } 
        else {
          doc = xmlReader.read(file);
          root = doc.getRootElement();

          Iterator matchsets = root.elementIterator("match");
          int chartNum=0;
          while (matchsets.hasNext()) {
        	  chartNum++;
            Element match = (Element) matchsets.next();
            List encounters = match.elements("encounter");
            Element enc1 = (Element) encounters.get(0);
            Element enc2 = (Element) encounters.get(1);
        %>
        <tr align="left" valign="top">
          
                <td width="60" align="left"><a
                  href="http://<%=CommonConfiguration.getURLLocation(request)%>/individuals.jsp?number=<%=enc1.attributeValue("assignedToShark")%>"><%=enc1.attributeValue("assignedToShark")%>
                </a>
          </td>
          <%if (enc1.attributeValue("number").equals("N/A")) {%>
          <td>N/A</td>
          <%} else {%>
          <td><a
            href="http://<%=CommonConfiguration.getURLLocation(request)%>/encounters/encounter.jsp?number=<%=enc1.attributeValue("number")%>"><%=enc1.attributeValue("number")%>
          </a></td>
          <%
            }

            String finalscore = "&nbsp;";
            try {
              if (match.attributeValue("finalscore") != null) {
                finalscore = match.attributeValue("finalscore");
              }
            } catch (NullPointerException npe) {
            }

            //trim the length of finalscore
            if (finalscore.length() > 7) {
              finalscore = finalscore.substring(0, 6);
            }

          %>
          
          <td><%=finalscore %></td>
          
          
          <td>
          
          <%
          
          String dtwPath=match.attributeValue("dtwPath").replaceAll("\\[","");
          System.out.println(dtwPath);
          StringTokenizer str=new StringTokenizer(dtwPath,"(");
          
          %>
          
         
          
          
	          <!-- google chart -->
	          <script type="text/javascript">
	    
				    
				    google.setOnLoadCallback(drawChart<%=chartNum %>);
				
				      // Callback that creates and populates a data table,
				      // instantiates the pie chart, passes in the data and
				      // draws it.
				      function drawChart<%=chartNum %>() {
				
				        // Create the data table.
				        var data<%=chartNum %> = new google.visualization.DataTable();
				      	data<%=chartNum %>.addColumn('number', 'x');
				      	data<%=chartNum %>.addColumn('number', 'y');
				      	data<%=chartNum %>.addRows([
				        
						<%
						while(str.hasMoreTokens()){
							
							String token=str.nextToken();
						%>
				          [<%=token.replaceAll("\\),","").replace("]","").replaceAll("\\)","")%>],
				        <%
				      	}  
				        %>
						]);
				
				        
				
				        // Instantiate and draw our chart, passing in some options.
				        var chart<%=chartNum %> = new google.visualization.LineChart(document.getElementById('chart_div<%=chartNum %>'));
				        chart<%=chartNum %>.draw(data<%=chartNum %>, options);
				      }
	   			</script>
	   			
	   			<div id="chart_div<%=chartNum %>"></div>
	   			
          	</td>



        </tr>

        <%


            }


          }

        %>

      
</tbody>
</table>


<p>

<p>
  <%


//myShepherd.rollbackDBTransaction();
   //myShepherd = null;
    doc = null;
    root = null;
    initresults = null;
    file = null;
    xmlReader = null;
    


%>
<jsp:include page="../footer.jsp" flush="true"/>
</div>
</div>
<!-- end page --></div>
<!--end wrapper -->
</body>
</html>