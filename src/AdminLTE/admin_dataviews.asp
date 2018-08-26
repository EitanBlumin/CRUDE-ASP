<%@ LANGUAGE="VBSCRIPT" CODEPAGE="1255" %>
<!--#include file="dist/asp/inc_config.asp" -->
<%' use this meta tag instead of adovbs.inc%>
<!--METADATA TYPE="typelib" uuid="00000205-0000-0010-8000-00AA006D2EA4" -->
<%
Response.CodePage = 1255
Session.CodePage = 1255

' Local Constants
'=======================
Const constPageScriptName = "admin_dataviews.asp"
Dim strPageTitle
strPageTitle = "Manage Data Views"

' Init Variables
'=======================
Dim nItemID, strMode, nCount, nIndex

' Open DB Connection
'=======================
adoConn.Open
%><!--#include file="dist/asp/inc_crudeconstants.asp" --><%
Dim strTitle, strMainTable, strPrimaryKey, strModificationProcedure, strViewProcedure, strDeleteProcedure
Dim strDescription, strOrderBy, nFlags
Dim nDtModBtnStyle, nDtFlags, nDtDefaultPageSize, strDtPagingStyle
    
strMode = Request("mode")
nItemID = Request("ItemID")
IF NOT IsNumeric(nItemID) THEN nItemID = ""
strTitle = Request("Title")
strMainTable = Request("MainTable")
strPrimaryKey = Request("PrimaryKey")
strModificationProcedure = Request("ModificationProcedure")
strViewProcedure = Request("ViewProcedure")
strDeleteProcedure = Request("DeleteProcedure")
strDescription = Request("ViewDescription")
strOrderBy = Request("OrderBy")
nDtModBtnStyle = Request("DataTableModificationButtonStyle")
nDtDefaultPageSize = Request("DataTableDefaultPageSize")
strDtPagingStyle = Request("DataTablePagingStyle")
nDtFlags = 0
nFlags = 0

For nIndex = 1 TO Request.Form("Flags").Count
    nFlags= nFlags + CInt(Request.Form("Flags")(nIndex))
Next
For nIndex = 1 TO Request.Form("DataTableFlags").Count
    nDtFlags= nDtFlags + CInt(Request.Form("DataTableFlags")(nIndex))
Next

IF Request.Form("Title") <> "" THEN
	
    strSQL = "SELECT * FROM portal.DataView WHERE "
    
    IF strMode = "add" THEN
        strSQL = strSQL & "1=2"
    ELSEIF strMode ="edit" AND nItemID <> "" AND IsNumeric(nItemID) THEN
        strSQL = strSQL & "ViewID = " & nItemID
    ELSE
        strError = "Invalid input!"
        strSQL = ""
    END IF
    
	IF strSQL <> "" THEN
        SET rsItems = Server.CreateObject("ADODB.Recordset")
        rsItems.CursorLocation = adUseClient
        rsItems.CursorType = adOpenKeyset
        rsItems.LockType = adLockOptimistic
        rsItems.Open strSQL, adoConn
    
        IF strMode = "add" THEN
            rsItems.AddNew
        END IF

        IF strMode = "edit" AND rsItems.EOF THEN
            strError = "Item Not Found<br/>"
            rsItems.Close    
        ELSE
            rsItems("Title") = strTitle
            rsItems("MainTable") = strMainTable
            rsItems("Primarykey") = strPrimaryKey
            rsItems("ModificationProcedure") = strModificationProcedure
            rsItems("ViewProcedure") = strViewProcedure
            rsItems("DeleteProcedure") = strDeleteProcedure
            rsItems("ViewDescription") = strDescription
            rsItems("OrderBy") = strOrderBy
            rsItems("Flags") = CInt(nFlags)
            rsItems("DataTableModifierButtonStyle") = CInt(nDtModBtnStyle)
            rsItems("DataTableDefaultPageSize") = CInt(nDtDefaultPageSize)
            rsItems("DataTableFlags") = CInt(nDtFlags)
            rsItems("DataTablePagingStyle") = strDtPagingStyle
    
            ON ERROR RESUME NEXT
    
            rsItems.Update
            rsItems.Close   
            
            ON ERROR GOTO 0
        END IF

        ' check for errors
        If adoConn.Errors.Count > 0 Then
            DIM Err
            strError = strError & " Error(s) while performing &quot;" & strMode & "&quot;:<br/>" 
            For Each Err In adoConn.Errors
			    strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
            Next
            IF globalIsAdmin THEN strError = strError & "While trying to run:<br/><b>" & strSQL & "</b>"
        End If
	
	    IF strError = "" THEN 
            adoConn.Close
	        Response.Redirect(constPageScriptName & "?MSG=" & strMode)
        END IF
	END IF

ELSEIF strMode = "delete" AND nItemID <> "" THEN
		
	adoConn.Open
	adoConn.Execute "DELETE FROM portal.DataViewField WHERE ViewID = " & nItemID & "; DELETE FROM portal.DataView WHERE ViewID = " & nItemID
	adoConn.Close
	
	Response.Redirect(constPageScriptName & "?MSG=delete")
END IF
%>
<!DOCTYPE html>
<html>
<head>
  <title><%= GetPageTitle() %></title>
<!--#include file="dist/asp/inc_meta.asp" -->
</head>
<body class="<%= globalBodyClass %>">
<div class="wrapper">
<!--#include file="dist/asp/inc_header.asp" -->

  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <%= strPageTitle %>
      </h1>

      <ol class="breadcrumb">
        <li><a href="default.asp"><i class="fas fa-tachometer-alt"></i> Home</a></li>
        <li class="active"><%= Sanitizer.HTMLDisplay(strPageTitle) %></li>
      </ol>

    </section>

    <!-- Main content -->
    <section class="content container-fluid">

<div class="row">
<%
SET rsItems = Server.CreateObject("ADODB.Recordset")

IF (strMode = "edit" AND nItemID <> "") OR strMode = "add" Then

IF strMode = "edit" AND nItemID <> "" Then
	strSQL = "SELECT * FROM portal.DataView WHERE ViewID = " & nItemID
	rsItems.Open strSQL, adoConn
	IF NOT rsItems.EOF THEN
		strTitle = rsItems("Title")
		strMainTable = rsItems("MainTable")
		strPrimaryKey = rsItems("PrimaryKey")
		strOrderBy = rsItems("OrderBy")
		strDescription = rsItems("ViewDescription")
        strModificationProcedure = rsItems("ModificationProcedure")
        strViewProcedure = rsItems("ViewProcedure")
        strDeleteProcedure = rsItems("DeleteProcedure")
		nFlags = rsItems("Flags")
        nDtModBtnStyle = rsItems("DataTableModifierButtonStyle")
        nDtDefaultPageSize = rsItems("DataTableDefaultPageSize")
        nDtFlags = rsItems("DataTableFlags")
        strDtPagingStyle = rsItems("DataTablePagingStyle")
	END IF
	rsItems.Close
ELSE
	nFlags = 63
	strMode = "add"
END IF
%>
<!-- Update/Insert Form -->
<div class="col-md-6">
<div class="panel panel-primary">
<div class="box-header with-border">
    <h3 class="box-title">
        <% IF strMode = "edit" AND nItemID <> "" THEN Response.Write "Edit" ELSE Response.Write "Add" %> Data View

    </h3><% IF strMode = "edit" AND nItemID <> "" Then %>
    
    <!-- tools box -->
    <div class="pull-right box-tools">
    <a role="button" href="admin_dataviewfields.asp?ViewID=<%= nItemID %>" class="btn btn-primary btn-sm"><i class="fas fa-bars"></i> Manage Fields</a>
    &nbsp;
    <a role="button" href="dataview.asp?ViewID=<%= nItemID %>" class="btn btn-primary btn-sm"><i class="fas fa-eye"></i> Open Data View</a>
    &nbsp;
    <a role="button" class="btn btn-primary btn-sm" title="Cancel" href="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>"><i class="fas fa-times"></i></a>
    </div>
    <!-- /. tools -->
    <% END IF %>
</div>
<form class="form-horizontal" action="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>" method="post">
    <div class="panel-body">
    <div class="form-group">
        <label for="inputTitle" class="col-sm-2 control-label">Title</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputTitle" placeholder="Title" data-toggle="tooltip" name="Title" title="The title will be displayed at the top of the page" value="<%= Sanitizer.HTMLFormControl(strTitle) %>" required="required">
        </div>
    </div>
    <div class="form-group">
        <div class="col-sm-12">
        <label for="inputDescription" class="control-label">Description</label>

        <textarea class="textarea" name="ViewDescription" placeholder="Description" data-toggle="tooltip" title="This richly-formatted text will be displayed below the title, before the datatable"
                    style="width: 100%; height: 200px; font-size: 14px; line-height: 18px; border: 1px solid #dddddd; padding: 10px;"><%= Sanitizer.HTMLFormControl(strDescription) %></textarea>
    </div></div>
    <div class="form-group">
        <label for="inputMainTable" class="col-sm-3 control-label">Main Table Name</label>

        <div class="col-sm-9">
        <input type="text" class="form-control" id="inputMainTable" data-toggle="tooltip" placeholder="Main Database Table Name" title="This is the database table name from which data will be queried and modified in (unless you specified stored procedures below). It can also be a view" name="MainTable" value="<%= Sanitizer.HTMLFormControl(strMainTable) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputPrimaryKey" class="col-sm-3 control-label">Primary Key</label>

        <div class="col-sm-9">
        <input type="text" class="form-control" id="inputPrimaryKey" data-toggle="tooltip" title="A column name which serves as a primary key in the aforementioned database table" placeholder="Primary Key (must be single numerical column)" name="PrimaryKey" value="<%= Sanitizer.HTMLFormControl(strPrimaryKey) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputOrderBy" class="col-sm-3 control-label">Order By</label>

        <div class="col-sm-9">
        <input type="text" class="form-control" id="inputOrderBy" data-toggle="tooltip" title="Default sorting expression when querying from the database table" placeholder="Column1 ASC, Column2 DESC" name="OrderBy" value="<%= Sanitizer.HTMLFormControl(strOrderBy) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputViewProcedure" class="col-sm-3 control-label">Source Procedure</label>

        <div class="col-sm-9">
        <input type="text" class="form-control" id="inputViewProcedure" data-toggle="tooltip" title="Execute this stored procedure instead of querying directly from a table" placeholder="Procedure for View" name="ViewProcedure" value="<%= Sanitizer.HTMLFormControl(strViewProcedure) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputModificationProcedure" class="col-sm-3 control-label">Modification Procedure</label>

        <div class="col-sm-9">
        <input type="text" class="form-control" id="inputModificationProcedure" data-toggle="tooltip" title="Execute this stored procedure instead of modifying data directly in a table" placeholder="Procedure for Modification" name="ModificationProcedure" value="<%= Sanitizer.HTMLFormControl(strModificationProcedure) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputDeleteProcedure" class="col-sm-3 control-label">Deletion Procedure</label>

        <div class="col-sm-9">
        <input type="text" class="form-control" id="inputDeleteProcedure" data-toggle="tooltip" title="Execute this stored procedure instead of deleting directly from a table" placeholder="Procedure for Deletion" name="DeleteProcedure" value="<%= Sanitizer.HTMLFormControl(strDeleteProcedure) %>">
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-3 control-label">Properties</label>
        
        <div class="col-sm-9">
        <% FOR nIndex = 0 TO UBound(arrDataViewFlags, 2) %>
        <div class="checkbox">
            <label>
            <input type="checkbox" name="Flags" value="<%= arrDataViewFlags(dvfValue, nIndex) %>" <% IF (arrDataViewFlags(dvfValue, nIndex) AND nFlags) > 0 THEN Response.Write "checked" %> /> 
                <i class="<%= arrDataViewFlags(dvfGlyph, nIndex) %>"></i> <%= arrDataViewFlags(dvfLabel, nIndex) %>
            </label>
        </div>
        <% NEXT %>
        </div>
    </div>
    <div class="form-group">
        <label for="inputDataTableModificationButtonStyle" class="col-sm-3 control-label">DataTable Row Button Style</label>

        <div class="col-sm-9">
            <select class="form-control" name="DataTableModificationButtonStyle" id="inputDataTableModificationButtonStyle" data-toggle="tooltip" title="Choose how the Add/Edit/Clone/Delete buttons would look like">
            <% FOR nIndex = 0 TO UBound(arrDataTableModifierButtonStyles, 2) %>
                <option value="<%= arrDataTableModifierButtonStyles(dtbsValue, nIndex) %>" <% IF arrDataTableModifierButtonStyles(dtbsValue, nIndex) = nDtModBtnStyle THEN Response.Write "selected" %>><%= arrDataTableModifierButtonStyles(dtbsLabel, nIndex) %></option>
            <% NEXT %>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label for="intpuDataTableDefaultPageSize" class="col-sm-3 control-label">DataTable Default Page Size</label>

        <div class="col-sm-9">
            <select class="form-control" name="DataTableDefaultPageSize" id="inputDataTableDefaultPageSize" data-toggle="tooltip" title="Choose the default number of rows per page (ignored when pagination is disabled)">
                <option value="10" <% IF nDtDefaultPageSize = 10 THEN Response.Write "selected" %>>10</option>
                <option value="25" <% IF nDtDefaultPageSize = 25 THEN Response.Write "selected" %>>25</option>
                <option value="50" <% IF nDtDefaultPageSize = 50 THEN Response.Write "selected" %>>50</option>
                <option value="100" <% IF nDtDefaultPageSize = 100 THEN Response.Write "selected" %>>100</option>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label for="inputDataTablePagingStyle" class="col-sm-3 control-label">DataTable Paging Style</label>

        <div class="col-sm-9">
            <select class="form-control" name="DataTablePagingStyle" id="inputDataTablePagingStyle" data-toggle="tooltip" title="Choose how the pagination buttons would look like (ignored when pagination is disabled)">
            <% FOR nIndex = 0 TO UBound(arrDataTablePagingStyles, 2) %>
                <option value="<%= arrDataTablePagingStyles(dtpsValue, nIndex) %>" <% IF arrDataTablePagingStyles(dtpsValue, nIndex) = strDtPagingStyle THEN Response.Write "selected" %>><%= arrDataTablePagingStyles(dtpsLabel, nIndex) %></option>
            <% NEXT %>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-3 control-label">DataTable Options</label>
        
        <div class="col-sm-9">
        <% FOR nIndex = 0 TO UBound(arrDataTableFlags, 2) %>
        <div class="checkbox">
            <label data-toggle="tooltip" title="<%= arrDataTableFlags(dtfTooltip, nIndex) %>">
            <input type="checkbox" name="DataTableFlags" value="<%= arrDataTableFlags(dtfValue, nIndex) %>" <% IF (arrDataTableFlags(dtfValue, nIndex) AND nDtFlags) > 0 THEN Response.Write "checked" %> /> 
                <i class="<%= arrDataTableFlags(dtfGlyph, nIndex) %>"></i> <%= arrDataTableFlags(dtfLabel, nIndex) %>
            </label>
        </div>
        <% NEXT %>
        </div>
    </div>
    </div>
    <!-- /.panel-body -->
    <div class="panel-footer">
    <input type="hidden" name="ItemID" value="<%= nItemID %>" />
    <input type="hidden" name="mode" value="<%= strMode %>" />

    <a class="btn btn-default" role="button" href="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>">Cancel</a>

    <button type="submit" class="btn btn-success pull-right">Submit</button>
    </div>
    <!-- /.panel-footer -->
</form>
</div>
</div>
<!-- /.update-insert-form -->
<% END IF %>
</div>
        
<div class="row">
    <div class="col col-sm-12">
        <a class="btn btn-primary" role="button" href="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>?mode=add"><i class="fas fa-plus"></i> Add Data View</a>
    </div>
</div>

        <!-- Items List -->
        
<table class="table table-hover">
<tr>
    <th>ID</th>
    <th>Title</th>
    <th>Properties</th>
    <th>DataTable Options</th>
    <th>Actions</th>
</tr>
<%
Set rsItems = Server.CreateObject("ADODB.Recordset")
strSQL = "SELECT * FROM portal.DataView ORDER BY Title ASC"
rsItems.Open strSQL, adoConn

WHILE NOT rsItems.EOF

%><tr>
    <td><%= rsItems("ViewID") %></td>
    <td><a href="dataview.asp?ViewID=<%= rsItems("ViewID") %>"><%= Sanitizer.HTMLDisplay(rsItems("Title")) %></a></td>
    <td>
        <% FOR nIndex = 0 TO UBound(arrDataViewFlags, 2)
            IF (rsItems("Flags") AND arrDataViewFlags(dvfValue, nIndex)) > 0 THEN %>
        <b data-toggle="tooltip" title="<%= arrDataViewFlags(dvfLabel, nIndex) %>"><i class="<%= arrDataViewFlags(dvfGlyph, nIndex) %>"></i></b>
        &nbsp;
        <% END IF
            NEXT %>
    </td>
    <td>
        <% FOR nIndex = 0 TO UBound(arrDataTableFlags, 2)
            IF (rsItems("DataTableFlags") AND arrDataTableFlags(dtfValue, nIndex)) > 0 THEN %>
        <b data-toggle="tooltip" title="<%= arrDataTableFlags(dtfLabel, nIndex) %>"><i class="<%= arrDataTableFlags(dtfGlyph, nIndex) %>"></i></b>
        &nbsp;
        <% END IF
            NEXT %>
    </td>
    <td>
        <a data-toggle="tooltip" title="Manage Fields" class="btn btn-primary" href="admin_dataviewfields.asp?ViewID=<%= rsItems("ViewID") %>"><i class="fas fa-bars"></i> Manage Fields</a>
        &nbsp;
        <a data-toggle="tooltip" title="Edit" class="btn btn-primary" href="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>?mode=edit&ItemID=<%= rsItems("ViewID") %>"><i class="fas fa-edit"></i> Edit</a>
        &nbsp;
        <a data-toggle="tooltip" title="Delete" class="btn btn-primary" href="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>?mode=delete&ItemID=<%= rsItems("ViewID") %>"><i class="far fa-trash-alt"></i> Delete</a>
    </td>
  </tr>
    <% 
    rsItems.MoveNext
WEND %>
</table>

    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->

<!--#include file="dist/asp/inc_footer.asp" -->
</div>
<!-- ./wrapper -->

<!-- REQUIRED JS SCRIPTS -->
<!--#include file="dist/asp/inc_footer_jscripts.asp" -->

<!-- AdminLTE App -->
<script src="dist/js/adminlte.min.js"></script>

<!-- Optionally, you can add Slimscroll and FastClick plugins.
     Both of these plugins are recommended to enhance the
     user experience. -->
</body>
</html>