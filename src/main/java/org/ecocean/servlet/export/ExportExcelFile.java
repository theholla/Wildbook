package org.ecocean.servlet.export;
import javax.servlet.*;
import javax.servlet.http.*;

import java.io.*;
import java.util.*;
import java.text.SimpleDateFormat;

import org.ecocean.*;
import org.ecocean.genetics.*;
import org.ecocean.servlet.ServletUtilities;

import javax.jdo.*;

import java.lang.reflect.Method;
import java.lang.StringBuffer;

import jxl.write.*;
import jxl.Workbook;


public class ExportExcelFile extends HttpServlet{
  
  private static final int BYTES_DOWNLOAD = 1024;

  
  public void init(ServletConfig config) throws ServletException {
      super.init(config);
    }

  
  public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException,IOException {
      doPost(request, response);
  }
    


  public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
    
    //set the response
    
    String context="context0";
    context=ServletUtilities.getContext(request);
    Shepherd myShepherd = new Shepherd(context);
    

    String query = request.getParameter("query");
    String[] headers = request.getParameterValues("headers");
    String[] columns = request.getParameterValues("columns");
    Collection c = (Collection) myShepherd.getPM().newQuery(query).execute();
    Vector v = new Vector(c);
    //Class cls = v.get(0).getClass();

    String filename = request.getParameter("filename");
    if (filename == null) {
        Calendar cal = Calendar.getInstance();
        SimpleDateFormat df = new SimpleDateFormat("yyyyMMddHHmmss");
        filename = "export-" + df.format(cal.getTime()) + ".xls";
    }
    String sheetname = request.getParameter("sheetname");
    if (sheetname == null) sheetname = "Export";

    File excelFile = new File("/tmp/" + filename);
    FileOutputStream exfos = new FileOutputStream(excelFile);
    OutputStreamWriter exout = new OutputStreamWriter(exfos);
    //WritableCellFormat floatFormat = new WritableCellFormat(NumberFormats.FLOAT);
    //WritableCellFormat integerFormat = new WritableCellFormat(NumberFormats.INTEGER);
    WritableWorkbook workbook = Workbook.createWorkbook(excelFile);
    WritableSheet sheet = workbook.createSheet(sheetname, 0);

    int sheetRow = 0;

    if ((headers != null) && (headers.length > 0)) {
        int col = 0;
        for (int i = 0 ; i < headers.length ; i++) {
           Label l = new Label(col, sheetRow, headers[i]);
            try {
                sheet.addCell(l);
            } catch (Exception addex) {
                System.out.println("exception adding cell: " + addex.toString());
            }
            col++;
        }
        sheetRow++;
    }

    for (Object obj : v) {
        int col = 0;
        for (int i = 0 ; i < columns.length ; i++) {
            Method prop = null;
            try {
                String mname = "get" + columns[i].substring(0,1).toUpperCase() + columns[i].substring(1);
                prop = obj.getClass().getMethod(mname, null); //, new Class[] { HttpServletRequest.class, JSONObject.class });
            } catch (NoSuchMethodException nsm) {
System.out.println("no such method for column " + columns[i] + "?");
                continue;
            }
            Object r = null;
            try {
                r = prop.invoke(obj);
            } catch (Exception ex) {
                r = "Exception: " + ex.toString();
            }
            String val = r.toString();
            Label l = new Label(col, sheetRow, val);
            try {
                sheet.addCell(l);
            } catch (Exception addex) {
                System.out.println("exception adding cell: " + addex.toString());
            }
            col++;
        }
        sheetRow++;
    }

    try {
        workbook.write();
        workbook.close();
    } catch (Exception wex) {
        System.out.println("exception writing excel: " + wex.toString());
    }

    response.setContentType("application/vnd.ms-excel");
    response.setHeader("Content-Disposition", "filename=" + filename);
 
    InputStream is = new FileInputStream(excelFile);
    OutputStream os = response.getOutputStream();
    byte[] buf = new byte[1000];
    for (int n = is.read(buf) ; n > -1 ; n = is.read(buf)) {
        os.write(buf, 0, n);
    }
    os.flush();
    os.close();
    is.close();


  }

}