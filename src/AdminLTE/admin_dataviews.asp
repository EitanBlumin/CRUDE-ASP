<%@ LANGUAGE="VBSCRIPT" CODEPAGE="65001" %>
<!--#include file="config_inc.asp" -->
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
<!--#include file="inc_metadata.asp" -->
</head>
<body>
<!--#include file="inc_nav.asp" -->
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="default.asp"><i class="fas fa-tachometer-alt"></i> Home</a></li>
        <li class="breadcrumb-item active"><%= Sanitizer.HTMLDisplay(strPageTitle) %></li>
      </ol>
    </nav>
    
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
	nFlags = 63
	strMode = "add"
END IF
%>
<!-- Update/Insert Form -->
<div class="container">
<div class="card">
<div class="card-header">
    <h3 class="card-title float-left">
        <% IF strMode = "edit" AND nItemID <> "" THEN Response.Write "Edit" ELSE Response.Write "Add" %> Data View

    </h3><% IF strMode = "edit" AND nItemID <> "" Then %>
    
    <!-- tools box -->
    <div class="ml-auto float-right">
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
    <div class="card-body">
    <div class="input-group">
        <label for="inputTitle" class="col-sm-2 control-label">Title</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputTitle" placeholder="Title" data-toggle="tooltip" name="Title" title="The title will be displayed at the top of the page" value="<%= Sanitizer.HTMLFormControl(strTitle) %>" required="required">
        </div>
    </div>
    <div class="input-group summernote">
        <label for="inputDescription" class="col-sm-2 control-label">Description</label>

        <div class="col-sm-10">
        <textarea name="ViewDescription" placeholder="Description" data-toggle="tooltip" title="This richly-formatted text will be displayed below the title, before the datatable"
                    style="width: 100%; height: 200px; font-size: 14px; line-height: 18px; border: 1px solid #dddddd; padding: 10px;"><%= Sanitizer.HTMLFormControl(strDescription) %></textarea>
        </div>
    </div>
    <div class="input-group">
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
    <div class="input-group">
        <label for="inputMainTable" class="col-sm-2 control-label">Main Table Name</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputMainTable" data-toggle="tooltip" placeholder="Main Database Table Name" title="This is the database table name from which data will be queried and modified in (unless you specified stored procedures below). It can also be a view" name="MainTable" value="<%= Sanitizer.HTMLFormControl(strMainTable) %>">
        </div>
    </div>
    <div class="input-group">
        <label for="inputPrimaryKey" class="col-sm-2 control-label">Primary Key</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputPrimaryKey" data-toggle="tooltip" title="A column name which serves as a primary key in the aforementioned database table" placeholder="Primary Key (must be single numerical column)" name="PrimaryKey" value="<%= Sanitizer.HTMLFormControl(strPrimaryKey) %>">
        </div>
    </div>
    <div class="input-group">
        <label for="inputOrderBy" class="col-sm-2 control-label">Order By</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputOrderBy" data-toggle="tooltip" title="Default sorting expression when querying from the database table" placeholder="Column1 ASC, Column2 DESC" name="OrderBy" value="<%= Sanitizer.HTMLFormControl(strOrderBy) %>">
        </div>
    </div>
    <div class="input-group">
        <label for="inputViewProcedure" class="col-sm-2 control-label">Source Procedure</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputViewProcedure" data-toggle="tooltip" title="Execute this stored procedure instead of querying directly from a table" placeholder="Procedure for View" name="ViewProcedure" value="<%= Sanitizer.HTMLFormControl(strViewProcedure) %>">
        </div>
    </div>
    <div class="input-group">
        <label for="inputModificationProcedure" class="col-sm-2 control-label">Modification Procedure</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputModificationProcedure" data-toggle="tooltip" title="Execute this stored procedure instead of modifying data directly in a table" placeholder="Procedure for Modification" name="ModificationProcedure" value="<%= Sanitizer.HTMLFormControl(strModificationProcedure) %>">
        </div>
    </div>
    <div class="input-group">
        <label for="inputDeleteProcedure" class="col-sm-2 control-label">Deletion Procedure</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputDeleteProcedure" data-toggle="tooltip" title="Execute this stored procedure instead of deleting directly from a table" placeholder="Procedure for Deletion" name="DeleteProcedure" value="<%= Sanitizer.HTMLFormControl(strDeleteProcedure) %>">
        </div>
    </div>
    <div class="input-group">
        <label class="col-sm-2 control-label">Properties</label>
        
        <div class="col-sm-10">
        <% FOR nIndex = 0 TO luDataViewFlags.UBound %>
        <div class="input-group">
            <label>
            <input type="checkbox" name="Flags" value="<%= luDataViewFlags(nIndex).Value %>" <% IF (luDataViewFlags(nIndex).Value AND nFlags) > 0 THEN Response.Write "checked" %> /> 
                <i class="<%= luDataViewFlags(nIndex).Glyph %>"></i> <%= luDataViewFlags(nIndex).Label %>
            </label>
        </div>
        <% NEXT %>
        </div>
    </div>
    <div class="input-group">
        <label for="inputDataTableModificationButtonStyle" class="col-sm-2 control-label">DataTable Row Button Style</label>

        <div class="col-sm-10">
            <select class="form-control" name="DataTableModificationButtonStyle" id="inputDataTableModificationButtonStyle" data-toggle="tooltip" title="Choose how the Add/Edit/Clone/Delete buttons would look like">
            <% FOR nIndex = 0 TO luDataTableModifierButtonStyles.UBound %>
                <option value="<%= luDataTableModifierButtonStyles(nIndex).Value %>" <% IF luDataTableModifierButtonStyles(nIndex).Value = nDtModBtnStyle THEN Response.Write "selected" %>><%= luDataTableModifierButtonStyles(nIndex).Label %></option>
            <% NEXT %>
            </select>
        </div>
    </div>
    <div class="input-group">
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
    <div class="input-group">
        <label for="inputDataTablePagingStyle" class="col-sm-2 control-label">DataTable Paging Style</label>

        <div class="col-sm-10">
            <select class="form-control" name="DataTablePagingStyle" id="inputDataTablePagingStyle" data-toggle="tooltip" title="Choose how the pagination buttons would look like (ignored when pagination is disabled)">
            <% FOR nIndex = 0 TO UBound(arrDataTablePagingStyles, 2) %>
                <option value="<%= arrDataTablePagingStyles(dtpsValue, nIndex) %>" <% IF arrDataTablePagingStyles(dtpsValue, nIndex) = strDtPagingStyle THEN Response.Write "selected" %>><%= arrDataTablePagingStyles(dtpsLabel, nIndex) %></option>
            <% NEXT %>
            </select>
        </div>
    </div>
    <div class="input-group">
        <label class="col-sm-2 control-label">DataTable Options</label>
        
        <div class="col-sm-10">
        <% FOR nIndex = 0 TO UBound(arrDataTableFlags, 2) %>
        <div class="input-group">
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
    <div class="card-footer">
    <input type="hidden" name="ItemID" value="<%= nItemID %>" />
    <input type="hidden" name="mode" value="<%= strMode %>" />

    <a class="btn btn-secondary" role="button" href="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>">Cancel</a>

    <button type="submit" class="btn btn-success float-right">Submit</button>
    </div>
    <!-- /.panel-footer -->
</form>
</div>
</div>
<!-- /.update-insert-form -->
<% END IF %>
        
<div class="row">
    <div class="col col-sm-12">
        <a class="btn btn-primary" role="button" href="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>?mode=add"><i class="fas fa-plus"></i> Add Data View</a>
    </div>
</div>

        <!-- Items List -->
<div class="table-responsive">
<table class="table table-hover">
<tr class="table-primary">
    <th>ID</th>
    <th>Title</th>
    <th>Properties</th>
    <th>DataTable Options</th>
    <th>Actions</th>
</tr>
<%
Set rsItems = Server.CreateObject("ADODB.Recordset")
strSQL = "SELECT * FROM portal.DataView ORDER BY Title ASC"
rsItems.Open strSQL, adoConnCrude

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
</div>
<!--#include file="inc_footer.asp" -->
</body>
</html>