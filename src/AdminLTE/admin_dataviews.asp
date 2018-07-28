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
Const constPageTitle = "Manage Data Views"

' Init Variables
'=======================
Dim strSQL, rsItems, nItemID, strMode, nCount, nIndex

' Open DB Connection
'=======================
adoConn.Open
%><!--#include file="dist/asp/inc_crudeconstants.asp" --><%
Dim strTitle, strMainTable, strPrimaryKey, strModificationProcedure, strViewProcedure, strDeleteProcedure
Dim strDescription, strOrderBy, nFlags
    
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
nFlags = 0

For nIndex = 1 TO Request.Form("Flags").Count
    nFlags= nFlags + CInt(Request.Form("Flags")(nIndex))
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
            rsItems("FieldOrder") = nOrdering
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
  <title><%= constPortalTitle %></title>
<!--#include file="dist/asp/inc_meta.asp" -->
</head>
<body class="hold-transition skin-blue sidebar-mini fixed">
<div class="wrapper">
<!--#include file="dist/asp/inc_header.asp" -->

  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <%= constPageTitle %>
      </h1>

      <ol class="breadcrumb">
        <li><a href="default.asp"><i class="fas fa-tachometer-alt"></i> Home</a></li>
        <li class="active"><%= Sanitizer.HTMLDisplay(constPageTitle) %></li>
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
		nFlags = rsItems("Flags")
		strDescription = rsItems("ViewDescription")
		strOrderBy = rsItems("OrderBy")
        strModificationProcedure = rsItems("ModificationProcedure")
        strViewProcedure = rsItems("ViewProcedure")
        strDeleteProcedure = rsItems("DeleteProcedure")
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
        <input type="text" class="form-control" id="inputTitle" placeholder="Title" name="Title" value="<%= Sanitizer.HTMLFormControl(strTitle) %>" required="required">
        </div>
    </div>
    <div class="form-group">
        <div class="col-sm-12">
        <label for="inputDescription" class="control-label">Description</label>

        <textarea class="textarea" name="ViewDescription" placeholder="Description"
                    style="width: 100%; height: 200px; font-size: 14px; line-height: 18px; border: 1px solid #dddddd; padding: 10px;"><%= Sanitizer.HTMLFormControl(strDescription) %></textarea>
    </div></div>
    <div class="form-group">
        <label for="inputMainTable" class="col-sm-3 control-label">Main Table Name</label>

        <div class="col-sm-9">
        <input type="text" class="form-control" id="inputMainTable" placeholder="Main Table Name" name="MainTable" value="<%= Sanitizer.HTMLFormControl(strMainTable) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputPrimaryKey" class="col-sm-3 control-label">Primary Key</label>

        <div class="col-sm-9">
        <input type="text" class="form-control" id="inputPrimaryKey" placeholder="Primary Key (must be single numerical column)" name="PrimaryKey" value="<%= Sanitizer.HTMLFormControl(strPrimaryKey) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputOrderBy" class="col-sm-3 control-label">Order By</label>

        <div class="col-sm-9">
        <input type="text" class="form-control" id="inputOrderBy" placeholder="Column1 ASC, Column2 DESC" name="OrderBy" value="<%= Sanitizer.HTMLFormControl(strOrderBy) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputViewProcedure" class="col-sm-3 control-label">Source Procedure</label>

        <div class="col-sm-9">
        <input type="text" class="form-control" id="inputViewProcedure" placeholder="Procedure for View" name="ViewProcedure" value="<%= Sanitizer.HTMLFormControl(strViewProcedure) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputModificationProcedure" class="col-sm-3 control-label">Modification Procedure</label>

        <div class="col-sm-9">
        <input type="text" class="form-control" id="inputModificationProcedure" placeholder="Procedure for Modification" name="ModificationProcedure" value="<%= Sanitizer.HTMLFormControl(strModificationProcedure) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputDeleteProcedure" class="col-sm-3 control-label">Deletion Procedure</label>

        <div class="col-sm-9">
        <input type="text" class="form-control" id="inputDeleteProcedure" placeholder="Procedure for Deletion" name="DeleteProcedure" value="<%= Sanitizer.HTMLFormControl(strDeleteProcedure) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputFlags" class="col-sm-3 control-label">Properties</label>
        
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
        <a class="btn btn-primary" role="button" href="<%= constPageScriptName %>?mode=add"><i class="fas fa-plus"></i> Add Data View</a>
    </div>
</div>

        <!-- Items List -->
        
<table class="table table-hover">
<tr>
    <th>ID</th>
    <th>Title</th>
    <th>Properties</th>
    <th>Actions</th>
</tr>
<%
Set rsItems = Server.CreateObject("ADODB.Recordset")
strSQL = "SELECT * FROM portal.DataView ORDER BY Title ASC"
rsItems.Open strSQL, adoConn

WHILE NOT rsItems.EOF

%><tr>
    <td><%= rsItems("ViewID") %></td>
    <td><a href="dataview.asp?ViewID=<%= rsItems("ViewID") %>"><%= rsItems("Title") %></a></td>
    <td>
        <% FOR nIndex = 1 TO UBound(arrDataViewFlags, 2)
            IF (rsItems("Flags") AND arrDataViewFlags(dvfValue, nIndex)) THEN %>
        <b title="<%= arrDataViewFlags(dvfLabel, nIndex) %>"><i class="<%= arrDataViewFlags(dvfGlyph, nIndex) %>"></i></b>
        &nbsp;
        <% END IF
            NEXT %>
    </td>
    <td>
        <a title="Manage Fields" class="btn btn-primary" href="admin_dataviewfields.asp?ViewID=<%= rsItems("ViewID") %>"><i class="fas fa-bars"></i> Manage Fields</a>
        &nbsp;
        <a title="Edit" class="btn btn-primary" href="<%= constPageScriptName %>?mode=edit&ItemID=<%= rsItems("ViewID") %>"><i class="fas fa-edit"></i> Edit</a>
        &nbsp;
        <a title="Delete" class="btn btn-primary" href="<%= constPageScriptName %>?mode=delete&ItemID=<%= rsItems("ViewID") %>"><i class="far fa-trash-alt"></i> Delete</a>
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