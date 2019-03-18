<%@ LANGUAGE="VBSCRIPT" CODEPAGE="65001" %>
<!--#include file="dist/asp/inc_config.asp" -->
<%' use this meta tag instead of adovbs.inc%>
<!--METADATA TYPE="typelib" uuid="00000205-0000-0010-8000-00AA006D2EA4" -->
<%
Response.CodePage = 65001
Session.CodePage = 65001
Response.CharSet = "UTF-8"

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
adoConnCrude.Open
%><!--#include file="dist/asp/inc_crudeconstants.asp" --><%
Dim strTitle, strDataSource, strMainTable, strPrimaryKey, strModificationProcedure, strViewProcedure, strDeleteProcedure
Dim strDescription, strOrderBy, nFlags
Dim nDtModBtnStyle, nDtFlags, nDtDefaultPageSize, strDtPagingStyle
    
strMode = Request("mode")
nItemID = Request("ItemID")
IF NOT IsNumeric(nItemID) THEN nItemID = ""
strTitle = Request("Title")
strDataSource = Request("DataSource")
IF strDataSource = "" THEN strDataSource = "Default"
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
        rsItems.Open strSQL, adoConnCrude
    
        IF strMode = "add" THEN
            rsItems.AddNew
        END IF

        IF strMode = "edit" AND rsItems.EOF THEN
            strError = "Item Not Found<br/>"
            rsItems.Close    
        ELSE
            rsItems("Title") = strTitle
            rsItems("DataSource") = strDataSource
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
        If adoConnCrude.Errors.Count > 0 Then
            DIM Err
            strError = strError & " Error(s) while performing &quot;" & strMode & "&quot;:<br/>" 
            For Each Err In adoConnCrude.Errors
			    strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
            Next
            IF globalIsAdmin THEN strError = strError & "While trying to run:<br/><b>" & strSQL & "</b>"
        End If
	
	    IF strError = "" THEN 
            adoConnCrude.Close
	        Response.Redirect(constPageScriptName & "?MSG=" & strMode)
        END IF
	END IF

ELSEIF strMode = "delete" AND nItemID <> "" THEN
		
	adoConnCrude.Open
	adoConnCrude.Execute "DELETE FROM portal.DataViewField WHERE ViewID = " & nItemID & "; DELETE FROM portal.DataView WHERE ViewID = " & nItemID
	adoConnCrude.Close
	
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

<%

IF (strMode = "edit" AND nItemID <> "") OR strMode = "add" Then

IF strMode = "edit" AND nItemID <> "" Then
	strSQL = "SELECT * FROM portal.DataView WHERE ViewID = " & nItemID
	rsItems.Open strSQL, adoConnCrude
	IF NOT rsItems.EOF THEN
		strTitle = rsItems("Title")
        strDataSource = rsItems("DataSource")
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
    Dim objFlag
    nFlags = 0
    For Each objFlag In luDataViewFieldFlags.Items
        IF CBool(objFlag.DefaultValue) THEN nFlags = nFlags + CInt(objFlag.Value)
    Next
	strMode = "add"
END IF
%>
<!-- Update/Insert Form -->
<div class="container">
<div class="panel panel-primary">
<div class="box-header with-border">
    <!-- tools box -->
    <div class="box-tools pull-right">
    <a role="button" href="admin_dataviewfields.asp?ViewID=<%= nItemID %>" class="btn btn-primary btn-sm"><i class="fas fa-bars"></i> Manage Fields</a>
    &nbsp;
    <a role="button" href="dataview.asp?ViewID=<%= nItemID %>" class="btn btn-primary btn-sm"><i class="fas fa-eye"></i> Open Data View</a>
    &nbsp;
    <a role="button" class="btn btn-primary btn-sm" title="Cancel" href="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>"><i class="fas fa-times"></i></a>
    </div>

    <h3 class="box-title pull-left">
        <% IF strMode = "edit" AND nItemID <> "" THEN Response.Write "Edit" ELSE Response.Write "Add" %> Data View

    </h3><% IF strMode = "edit" AND nItemID <> "" Then %>
    
    <!-- /. tools -->
    <% END IF %>
</div>
<form class="form-horizontal" action="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>" method="post">
    <div class="box-body">
    <div class="form-group">
        <label for="inputTitle" class="col-sm-2 control-label">Title</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputTitle" placeholder="Title" data-toggle="tooltip" name="Title" title="The title will be displayed at the top of the page" value="<%= Sanitizer.HTMLFormControl(strTitle) %>" required="required">
        </div>
    </div>
    <div class="form-group summernote">
        <label for="inputDescription" class="col-sm-2 control-label">Description</label>

        <div class="col-sm-10">
        <textarea name="ViewDescription" placeholder="Description" data-toggle="tooltip" title="This richly-formatted text will be displayed below the title, before the datatable"
                    style="width: 100%; height: 200px; font-size: 14px; line-height: 18px; border: 1px solid #dddddd; padding: 10px;"><%= Sanitizer.HTMLFormControl(strDescription) %></textarea>
        </div>
    </div>
    <div class="form-group">
        <label for="inputDataSource" class="col-sm-2 control-label">Data Source</label>

        <div class="col-sm-10">
            <select class="form-control" id="inputDataSource" name="DataSource" data-toggle="tooltip" title="Choose the Connection String to use (from web.config)">
                <%
                    Dim csoNode, csoChild, csoAttr
                    Set csoNode = CONFIG_FILE_XML.GetElementsByTagName("connectionStrings").Item(0) 
                    Set csoChild = csoNode.GetElementsByTagName("add")
                    For Each csoAttr in csoChild
                    %><option value="<%= csoAttr.getAttribute("name") %>"<%
                        If csoAttr.getAttribute("name") = strDataSource then Response.Write " selected"
                        %>><%= csoAttr.getAttribute("name") %></option>
                    <% Next %>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label for="inputMainTable" class="col-sm-2 control-label">Main Table Name</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputMainTable" data-toggle="tooltip" placeholder="Main Database Table Name" title="This is the database table name from which data will be queried and modified in (unless you specified stored procedures below). It can also be a view" name="MainTable" value="<%= Sanitizer.HTMLFormControl(strMainTable) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputPrimaryKey" class="col-sm-2 control-label">Primary Key</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputPrimaryKey" data-toggle="tooltip" title="A column name which serves as a primary key in the aforementioned database table" placeholder="Primary Key (must be single numerical column)" name="PrimaryKey" value="<%= Sanitizer.HTMLFormControl(strPrimaryKey) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputOrderBy" class="col-sm-2 control-label">Order By</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputOrderBy" data-toggle="tooltip" title="Default sorting expression when querying from the database table" placeholder="Column1 ASC, Column2 DESC" name="OrderBy" value="<%= Sanitizer.HTMLFormControl(strOrderBy) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputViewProcedure" class="col-sm-2 control-label">Source Procedure</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputViewProcedure" data-toggle="tooltip" title="Execute this stored procedure instead of querying directly from a table" placeholder="Procedure for View" name="ViewProcedure" value="<%= Sanitizer.HTMLFormControl(strViewProcedure) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputModificationProcedure" class="col-sm-2 control-label">Modification Procedure</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputModificationProcedure" data-toggle="tooltip" title="Execute this stored procedure instead of modifying data directly in a table" placeholder="Procedure for Modification" name="ModificationProcedure" value="<%= Sanitizer.HTMLFormControl(strModificationProcedure) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputDeleteProcedure" class="col-sm-2 control-label">Deletion Procedure</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputDeleteProcedure" data-toggle="tooltip" title="Execute this stored procedure instead of deleting directly from a table" placeholder="Procedure for Deletion" name="DeleteProcedure" value="<%= Sanitizer.HTMLFormControl(strDeleteProcedure) %>">
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-2 control-label">Properties</label>
        
        <div class="col-sm-10">
        <div class="form-group">
        <% Dim objChild
            For Each objChild IN luDataViewFlags.Items %>
        <div class="input-group">
            <label>
            <input type="checkbox" name="Flags" value="<%= objChild.Value %>" <% IF (objChild.Value AND nFlags) > 0 THEN Response.Write "checked" %> /> 
                <i class="<%= objChild.Glyph %>"></i> <%= objChild.Label %>
            </label>
        </div>
        <% NEXT %>
        </div>
        </div>
    </div>
    <div class="form-group">
        <label for="inputDataTableModificationButtonStyle" class="col-sm-2 control-label">DataTable Row Button Style</label>

        <div class="col-sm-10">
            <select class="form-control" name="DataTableModificationButtonStyle" id="inputDataTableModificationButtonStyle" data-toggle="tooltip" title="Choose how the Add/Edit/Clone/Delete buttons would look like">
            <% For Each objChild IN luDataTableModifierButtonStyles.Items %>
                <option value="<%= objChild.Value %>" <% IF objChild.Value = nDtModBtnStyle THEN Response.Write "selected" %>><%= objChild.Label %></option>
            <% NEXT %>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label for="intpuDataTableDefaultPageSize" class="col-sm-2 control-label">DataTable Default Page Size</label>

        <div class="col-sm-10">
            <select class="form-control" name="DataTableDefaultPageSize" id="inputDataTableDefaultPageSize" data-toggle="tooltip" title="Choose the default number of rows per page (ignored when pagination is disabled)">
                <option value="10" <% IF nDtDefaultPageSize = 10 THEN Response.Write "selected" %>>10</option>
                <option value="25" <% IF nDtDefaultPageSize = 25 THEN Response.Write "selected" %>>25</option>
                <option value="50" <% IF nDtDefaultPageSize = 50 THEN Response.Write "selected" %>>50</option>
                <option value="100" <% IF nDtDefaultPageSize = 100 THEN Response.Write "selected" %>>100</option>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label for="inputDataTablePagingStyle" class="col-sm-2 control-label">DataTable Paging Style</label>

        <div class="col-sm-10">
            <select class="form-control" name="DataTablePagingStyle" id="inputDataTablePagingStyle" data-toggle="tooltip" title="Choose how the pagination buttons would look like (ignored when pagination is disabled)">
            <% For Each objChild IN luDataTablePagingStyles.Items %>
                <option value="<%= objChild.Value %>" <% IF objChild.Value = strDtPagingStyle THEN Response.Write "selected" %>><%= objChild.Label %></option>
            <% NEXT %>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-2 control-label">DataTable Options</label>
        
        <div class="col-sm-10">
        <div class="form-group">
        <% FOR Each objChild IN luDataTableFlags.Items %>
        <div class="input-group">
            <label data-toggle="tooltip" title="<%= objChild.Tooltip %>">
            <input type="checkbox" name="DataTableFlags" value="<%= objChild.Value %>" <% IF (objChild.Value AND nDtFlags) > 0 THEN Response.Write "checked" %> /> 
                <i class="<%= objChild.Glyph %>"></i> <%= objChild.Label %>
            </label>
        </div>
        <% NEXT %>
        </div>
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
        

        <!-- Items List -->
<div class="box">
<div class="box-header">
    <div class="box-title">
        <a class="btn btn-primary" role="button" href="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>?mode=add"><i class="fas fa-plus"></i> Add Data View</a>
    </div>
</div>
<div class="box-body table-responsive">
<table class="table table-border table-hover">
<thead class="bg-primary">
<tr>
    <th>ID</th>
    <th>Title</th>
    <th>Properties</th>
    <th>DataTable Options</th>
    <th>Actions</th>
</tr>
</thead>
<%
Set rsItems = Server.CreateObject("ADODB.Recordset")
strSQL = "SELECT * FROM portal.DataView ORDER BY Title ASC"
rsItems.Open strSQL, adoConnCrude

WHILE NOT rsItems.EOF

%><tr>
    <td><%= rsItems("ViewID") %></td>
    <td><a href="dataview.asp?ViewID=<%= rsItems("ViewID") %>"><%= Sanitizer.HTMLDisplay(rsItems("Title")) %></a></td>
    <td>
        <% FOR Each objChild In luDataViewFlags.Items
            IF (rsItems("Flags") AND objChild.Value) > 0 THEN %>
        <b data-toggle="tooltip" title="<%= objChild.Label %>"><i class="<%= objChild.Glyph %>"></i></b>
        &nbsp;
        <% END IF
            NEXT %>
    </td>
    <td>
        <% FOR Each objChild In luDataTableFlags.Items
            IF (rsItems("DataTableFlags") AND objChild.Value) > 0 THEN %>
        <b data-toggle="tooltip" title="<%= objChild.Label %>"><i class="<%= objChild.Glyph %>"></i></b>
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
</div>
</div>
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