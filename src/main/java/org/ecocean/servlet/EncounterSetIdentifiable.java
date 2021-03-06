/*
 * The Shepherd Project - A Mark-Recapture Framework
 * Copyright (C) 2011 Jason Holmberg
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

package org.ecocean.servlet;

import org.ecocean.*;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;


//Set alternateID for this encounter/sighting
public class EncounterSetIdentifiable extends HttpServlet {

  public void init(ServletConfig config) throws ServletException {
    super.init(config);
  }


  public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    doPost(request, response);
  }


  private void setDateLastModified(Encounter enc) {
    String strOutputDateTime = ServletUtilities.getDate();
    enc.setDWCDateLastModified(strOutputDateTime);
  }


  public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String context="context0";
    context=ServletUtilities.getContext(request);
    Shepherd myShepherd = new Shepherd(context);
    //set up for response
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();
    boolean locked = false;
    boolean isOwner = true;

    /**
     if(request.getParameter("number")!=null){
     myShepherd.beginDBTransaction();
     if(myShepherd.isEncounter(request.getParameter("number"))) {
     Encounter verifyMyOwner=myShepherd.getEncounter(request.getParameter("number"));
     String locCode=verifyMyOwner.getLocationCode();

     //check if the encounter is assigned
     if((verifyMyOwner.getSubmitterID()!=null)&&(request.getRemoteUser()!=null)&&(verifyMyOwner.getSubmitterID().equals(request.getRemoteUser()))){
     isOwner=true;
     }

     //if the encounter is assigned to this user, they have permissions for it...or if they're a manager
     else if((request.isUserInRole("admin"))){
     isOwner=true;
     }
     //if they have general location code permissions for the encounter's location code
     else if(request.isUserInRole(locCode)){isOwner=true;}
     }
     myShepherd.rollbackDBTransaction();
     }
     */

    if (request.getParameter("number") != null) {
      myShepherd.beginDBTransaction();
      Encounter enc2reaccept = myShepherd.getEncounter(request.getParameter("number"));
      setDateLastModified(enc2reaccept);
      myShepherd.rollbackDBTransaction();
      myShepherd.beginDBTransaction();
      try {
        //enc2reaccept.reaccept();
        enc2reaccept.setState("unapproved");
        enc2reaccept.addComments("<p><em>" + request.getRemoteUser() + " on " + (new java.util.Date()).toString() + "</em><br>Reaccepted into visual database.</p>");
      } catch (Exception le) {
        //System.out.println("Hit locked exception on action: "+action);
        locked = true;
        le.printStackTrace();
        myShepherd.rollbackDBTransaction();
      }
      if (!locked) {
        myShepherd.commitDBTransaction();
        out.println(ServletUtilities.getHeader(request));
        out.println("<strong>Success:</strong> Encounter #" + request.getParameter("number") + " was successfully added back into the visual database.");
        out.println("<p><a href=\"http://" + CommonConfiguration.getURLLocation(request) + "/encounters/encounter.jsp?number=" + request.getParameter("number") + "\">Return to encounter #" + request.getParameter("number") + "</a></p>\n");
        List<String> allStates=CommonConfiguration.getIndexedPropertyValues("encounterState",context);
        int allStatesSize=allStates.size();
        if(allStatesSize>0){
          for(int i=0;i<allStatesSize;i++){
            String stateName=allStates.get(i);
            out.println("<p><a href=\"encounters/searchResults.jsp?state="+stateName+"\">View all "+stateName+" encounters</a></font></p>");   
          }
        }out.println("<p><a href=\"individualSearchResults.jsp\">View all individuals</a></font></p>");
        List<String> allStates2=CommonConfiguration.getIndexedPropertyValues("encounterState",context);
        int allStatesSize2=allStates2.size();
        if(allStatesSize2>0){
          for(int i=0;i<allStatesSize2;i++){
            String stateName=allStates2.get(i);
            out.println("<p><a href=\"encounters/searchResults.jsp?state="+stateName+"\">View all "+stateName+" encounters</a></font></p>");   
          }
        }
        out.println(ServletUtilities.getFooter(context));
        String message = "Encounter #" + request.getParameter("number") + " was accepted back into the visual database.";
        ServletUtilities.informInterestedParties(request, request.getParameter("number"), message,context);
      } else {
        out.println(ServletUtilities.getHeader(request));
        out.println("<strong>Failure:</strong> Encounter #" + request.getParameter("number") + " was NOT successfully added back into the visual database. This encounter is currently being modified by another user. Please try this operation again in a few seconds.");
        out.println("<p><a href=\"http://" + CommonConfiguration.getURLLocation(request) + "/encounters/encounter.jsp?number=" + request.getParameter("number") + "\">Return to encounter #" + request.getParameter("number") + "</a></p>\n");
        List<String> allStates=CommonConfiguration.getIndexedPropertyValues("encounterState",context);
        int allStatesSize=allStates.size();
        if(allStatesSize>0){
          for(int i=0;i<allStatesSize;i++){
            String stateName=allStates.get(i);
            out.println("<p><a href=\"encounters/searchResults.jsp?state="+stateName+"\">View all "+stateName+" encounters</a></font></p>");   
          }
        }out.println("<p><a href=\"individualSearchResults.jsp\">View all individuals</a></font></p>");
        List<String> allStates5=CommonConfiguration.getIndexedPropertyValues("encounterState",context);
        int allStatesSize5=allStates5.size();
        if(allStatesSize5>0){
          for(int i=0;i<allStatesSize5;i++){
            String stateName=allStates5.get(i);
            out.println("<p><a href=\"encounters/searchResults.jsp?state="+stateName+"\">View all "+stateName+" encounters</a></font></p>");   
          }
        }out.println(ServletUtilities.getFooter(context));


      }
    } else {
      out.println(ServletUtilities.getHeader(request));
      out.println("<strong>Error:</strong> I don't know which encounter you're trying to reaccept.");
      List<String> allStates=CommonConfiguration.getIndexedPropertyValues("encounterState",context);
      int allStatesSize=allStates.size();
      if(allStatesSize>0){
        for(int i=0;i<allStatesSize;i++){
          String stateName=allStates.get(i);
          out.println("<p><a href=\"encounters/searchResults.jsp?state="+stateName+"\">View all "+stateName+" encounters</a></font></p>");   
        }
      }
      out.println("<p><a href=\"individualSearchResults.jsp\">View all individuals</a></font></p>");
      List<String> allStates3=CommonConfiguration.getIndexedPropertyValues("encounterState",context);
      int allStatesSize3=allStates3.size();
      if(allStatesSize3>0){
        for(int i=0;i<allStatesSize3;i++){
          String stateName=allStates3.get(i);
          out.println("<p><a href=\"encounters/searchResults.jsp?state="+stateName+"\">View all "+stateName+" encounters</a></font></p>");   
        }
      }
      out.println(ServletUtilities.getFooter(context));

    }


    out.close();
    myShepherd.closeDBTransaction();
  }
}
	
	
