<%@ LANGUAGE="VBSCRIPT" CODEPAGE="1255" %>
<!--#include file="dist/asp/inc_config.asp" -->
<%' use this meta tag instead of adovbs.inc%>
<!--METADATA TYPE="typelib" uuid="00000205-0000-0010-8000-00AA006D2EA4" -->
<%
Response.CodePage = 1255
Session.CodePage = 1255

' Local Constants
'=======================
Const constPageScriptName = "dataview.asp"

' Init Variables
'=======================
Dim strSQL, rsItems, nItemID, strMode, nCount, nIndex

' Open DB Connection
'=======================
adoConn.Open
%><!--#include file="dist/asp/inc_crudeconstants.asp" --><%
    
Dim blnFound, blnRequiredFieldsFilled, strViewIDString
Dim blnRTEEnabled, blnShowForm, blnShowList, blnAllowUpdate, blnAllowInsert, blnAllowDelete, blnAllowClone, blnAllowSearch, strOrderBy, strSearchFilter, strCurrFilter
Dim strLastOptGroup, blnOptGroupStarted
Set rsItems = Server.CreateObject("ADODB.Recordset")

Dim myRegEx
SET myRegEx = New RegExp
myRegEx.IgnoreCase = True
myRegEx.Global = True


'[ConfigVars]
' Init Form Variables from DB. This will be deleted when generated as a seperate file.
DIM nViewID, rsFields, arrViewFields, nColSpan
DIM nFieldsNum, nViewFlags, strPageTitle, strPrimaryKey, strMainTableName, strScriptName, strDataViewDescription, strFilterBackLink
Dim strFilterField, blnFilterRequired, cmdStoredProc, strViewProcedure, strModificationProcedure, strDeleteProcedure, varCurrFieldValue
Dim paramPK, paramMode, paramFilter, paramOrderBy

strError = ""
strSearchFilter = ""
strPageTitle = "Data View"

strMode = Request("mode")
IF strMode = "" THEN strMode = "none"

nViewID = Request("ViewID")
strScriptName = "dataview.asp"

IF nViewID <> "" AND IsNumeric(nViewID) THEN
	strSQL = "SELECT * FROM portal.DataView WHERE ViewID = " & nViewID
	rsItems.Open strSQL, adoConn
	IF NOT rsItems.EOF THEN
		strPageTitle = rsItems("Title")
        strDataViewDescription = rsItems("ViewDescription")

		SET rsFields = Server.CreateObject("ADODB.Recordset")
		rsFields.Open "SELECT * FROM portal.DataViewField WHERE ViewID = " & nViewID & " ORDER BY FieldOrder ASC", adoConStr
		IF NOT rsFields.EOF THEN
			arrViewFields = rsFields.GetRows()
		END IF
		rsFields.Close
		SET rsFields = Nothing
		
	ELSE
		strError = "ViewID Not Found!"
		nViewID = ""
	END IF
	rsItems.Close
ELSE
	strError = "ViewID Invalid!"
END IF

Dim strFilteredValue : strFilteredValue = Request(strFilterField & nViewID)
    

'***************************
' Data Manipulation Section
'***************************
IF ((strMode = "add" AND blnAllowInsert AND blnRequiredFieldsFilled) OR (strMode = "edit" AND blnAllowUpdate AND nItemID <> "" AND blnRequiredFieldsFilled)) AND Request.Form("postback") = "true" THEN
	
	' If stored procedure
    IF NOT IsNull(strModificationProcedure) AND strModificationProcedure <> "" THEN
        strSQL = strModificationProcedure

	    SET cmdStoredProc = Server.CreateObject("ADODB.Command")
	    cmdStoredProc.ActiveConnection = adoConn
	    cmdStoredProc.CommandText = strSQL
	    cmdStoredProc.CommandType = adCmdStoredProc

        SET paramMode = cmdStoredProc.CreateParameter("@Mode", adLongVarWChar, adParamInput, 10)
        paramMode.Value = strMode
	    cmdStoredProc.Parameters.Append paramMode
	
        SET paramPK = cmdStoredProc.CreateParameter("@" & strPrimaryKey, adBigInt, adParamInput)
        IF nItemID = "" THEN nItemID = Null
        paramPK.Value = nItemID
	    cmdStoredProc.Parameters.Append paramPK
    Else
	    strSQL = "SELECT * FROM " & strMainTableName

        IF strMode = "edit" THEN
		    strSQL = strSQL & " WHERE " & strPrimaryKey & " = " & nItemID
        ELSE
		    strSQL = strSQL & " WHERE 1=2"
        END IF
    
        rsItems.CursorLocation = adUseClient
        rsItems.CursorType = adOpenKeyset
        rsItems.LockType = adLockOptimistic
        rsItems.Open strSQL, adoConn

        IF strMode = "add" THEN
            rsItems.AddNew
        END IF

        IF strMode = "edit" AND rsItems.EOF THEN
            strError = GetWord("Item Not Found")
        END IF
    END IF

    IF strError = "" THEN
	
    ON ERROR RESUME NEXT

		FOR nIndex = 1 TO UBound(arrViewFields, 2)
			IF arrViewFields(dvfcFieldType, nIndex) <> "link" AND NOT (arrViewFields(dvfcFieldFlags, nIndex) AND 4) > 0 THEN
                
                IF rsItems(arrViewFields(dvfcFieldLabel, nIndex)) = "" AND (arrViewFields(dvfcFieldFlags, nIndex) AND 4) > 0 THEN
                    strError = GetWord("Not all required fields were filled")
                ELSE
                    Select Case arrViewFields(dvfcFieldType, nIndex)
                        Case "password", "text", "textarea", "multicombo", "rte"
                            varCurrFieldValue = rsItems(arrViewFields(dvfcFieldLabel, nIndex))
                        Case Else
                            IF rsItems(arrViewFields(dvfcFieldLabel, nIndex)) = "" AND NOT (arrViewFields(dvfcFieldFlags, nIndex) AND 4) = 0 THEN
                                varCurrFieldValue = Null
                            ELSE
				                varCurrFieldValue = rsItems(arrViewFields(dvfcFieldLabel, nIndex))
                            END IF
                    End Select

                    IF NOT IsNull(strModificationProcedure) AND strModificationProcedure <> "" THEN
                        'Response.Write "Creating parameter for " & arrViewFields(nIndex,fName) & " = " & rsItems(arrViewFields(dvfcFieldLabel, nIndex)) & "<br/>" & vbCrlf

                        Select Case arrViewFields(dvfcFieldType, nIndex)
                            Case "date"
                                SET arrViewFields(nIndex,fProcParam) = cmdStoredProc.CreateParameter("@p_" & nIndex, adDBDate, adParamInput)
                            Case "datetime"
                                SET arrViewFields(nIndex,fProcParam) = cmdStoredProc.CreateParameter("@p_" & nIndex, adDBTimeStamp, adParamInput)
                            Case "boolean"
                                SET arrViewFields(nIndex,fProcParam) = cmdStoredProc.CreateParameter("@p_" & nIndex, adBoolean, adParamInput)
                            Case "int"
                                SET arrViewFields(nIndex,fProcParam) = cmdStoredProc.CreateParameter("@p_" & nIndex, adInteger, adParamInput)
                            Case "double"
                                SET arrViewFields(nIndex,fProcParam) = cmdStoredProc.CreateParameter("@p_" & nIndex, adDouble, adParamInput)
                            Case "combo"
                                SET arrViewFields(nIndex,fProcParam) = cmdStoredProc.CreateParameter("@p_" & nIndex, adLongVarChar, adParamInput, 4000)
                            Case Else
                                SET arrViewFields(nIndex,fProcParam) = cmdStoredProc.CreateParameter("@p_" & nIndex, adLongVarWChar, adParamInput, 4000)
                        End Select

                        arrViewFields(nIndex,fProcParam).Value = varCurrFieldValue
	                    cmdStoredProc.Parameters.Append arrViewFields(nIndex,fProcParam)
                    ELSE
                        rsItems(arrViewFields(dvfcFieldLabel, nIndex)) = varCurrFieldValue
                    END IF
                END IF
			END IF
		NEXT
        
        IF NOT IsNull(strModificationProcedure) AND strModificationProcedure <> "" THEN
	        cmdStoredProc.Execute
	
	        IF Err.Number <> 0 THEN
		        strError = Err.Description
	        END IF
	
	        SET cmdStoredProc = Nothing
        ELSE
            rsItems.Update
        END IF

	END IF

    ON ERROR GOTO 0

    ' check for errors
    If adoConn.Errors.Count > 0 Then
        DIM Err
        strError = strError & " Error(s) while performing '" & strMode & "':<br/>" 
        For Each Err In adoConn.Errors
			strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | " & Err.NativeError & "<br/>"
        Next
        strError = strError & "While trying to run:<br/><b>" & strSQL & "</b>"
    End If
	
    adoConn.Close
	
	IF strError = "" THEN Response.Redirect(strScriptName & "?MSG=" & strMode & strFormIDString)

ELSEIF strMode = "delete" AND nItemID <> "" AND blnAllowDelete THEN
	
	' If stored procedure
    IF NOT IsNull(strDeleteProcedure) AND strDeleteProcedure <> "" THEN
        strSQL = strDeleteProcedure

	    SET cmdStoredProc = Server.CreateObject("ADODB.Command")
	    cmdStoredProc.ActiveConnection = adoConn
	    cmdStoredProc.CommandText = strSQL
	    cmdStoredProc.CommandType = adCmdStoredProc

        SET paramPK = cmdStoredProc.CreateParameter("@" & strPrimaryKey, adBigInt, adParamInput)
        IF nItemID = "" THEN nItemID = Null
        paramPK.Value = nItemID
	    cmdStoredProc.Parameters.Append paramPK
    
        ON ERROR RESUME NEXT

	    cmdStoredProc.Execute

	    IF Err.Number <> 0 THEN
		    strError = Err.Description
	    END IF
	
	    SET cmdStoredProc = Nothing

        ON ERROR GOTO 0
    Else
        strSQL = "DELETE FROM " & strMainTableName & " WHERE " & strPrimaryKey & " = " & nItemID
	    adoConn.Execute strSQL
    End If

	IF strError = "" Then
    	adoConn.Close
        Response.Redirect(strScriptName & "?MSG=delete" & strFormIDString)
    End If
END IF
ELSE
    Response.Write "<!-- Error: " & strError & " -->"
END IF


'***************
' Page Contents
'***************
%>
<!DOCTYPE html>
<html>
<head>
  <title><%= constPortalTitle %></title>
<!--#include file="dist/asp/inc_meta.asp" -->
</head>
<body class="hold-transition skin-blue sidebar-mini fixed" ng-app="CrudeApp" ng-controller="CrudeCtrl">
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
        <li class="active"><%= strPageTitle %></li>
      </ol>

    </section>

    <!-- Main content -->
    <section class="content container-fluid">

<div class="row">
    <div class="col col-sm-12">
        <a class="btn btn-primary" role="button" href="#"><i class="fas fa-arrow-left"></i> Back</a>
    </div>
</div>
<div class="row">
    <div class="col col-sm-12"><br />
        <small><%= strDataViewDescription %></small>
    </div>
</div>
        <!-- Data Manipulation Modals -->
        
<!-- Edit/Update/Clone Modal -->
<div class="modal fade" id="modal-edit" role="dialog">
    <div class="modal-dialog">
    <div class="modal-content">
        <div class="modal-header bg-primary">
        <h4 class="modal-title">{{ selectedModalTitle }}
            <span class="box-tools pull-right">
            <a class="btn btn-danger btn-sm" ng-show="selectedModalMode != 'add'" role="button" href="javascript:void(0)" ng-click="dvDelete(selectedRow)" aria-label="Delete" title="Delete" data-toggle="modal" data-target="#modal-delete"><i class="far fa-trash-alt"></i> Delete</a>
                &nbsp;
            <a role="button" class="btn btn-default btn-sm" data-dismiss="modal" aria-label="Close" title="Close"><span aria-hidden="true">&times;</span></a>
            </span></h4>
        </div>
        <form action="<%= constPageScriptName %>" method="post">
            <div class="modal-body"><%
                Dim blnRequired
            FOR nIndex = 0 TO UBound(arrViewFields, 2)
                IF (arrViewFields(dvfcFieldFlags,nIndex) AND 1) > 0 THEN 
                    blnRequired = CBool((arrViewFields(dvfcFieldFlags, nIndex) AND 2) > 0)
                %>
                <div class="form-group">
                    <label for="inputLabel_<%= nIndex %>" class="control-label"><%= arrViewFields(dvfcFieldLabel, nIndex) %></label>
            <%
        Select Case arrViewFields(dvfcFieldType,nIndex)
			Case 2 '"textarea"
			%><textarea class="form-control form-control-sm" name="inputField_<%= nIndex %>" placeholder="<%= arrViewFields(dvfcFieldLabel, nIndex) %>" rows="<%= arrViewFields(dvfcHeight, nIndex) %>" cols="<%= arrViewFields(dvfcWidth, nIndex) %>"<% IF blnRequired THEN Response.Write(" required") %> ng-model="selectedRow['<%= arrViewFields(dvfcFieldLabel, nIndex) %>']"></textarea>
			<%
			Case 14 '"rte"
			%><textarea name="inputField_<%= nIndex %>" id="summernote" <% IF blnRequired THEN Response.Write(" required") %> ng-model="selectedRow['<%= arrViewFields(dvfcFieldLabel, nIndex) %>']"></textarea>
			<%
			Case 5, 6 '"combo", "multicombo"
				strSQL = "SELECT DISTINCT "
                IF arrViewFields(dvfcLinkedTableGroupField, nIndex) <> "" THEN strSQL = strSQL & arrViewFields(dvfcLinkedTableGroupField, nIndex) & " AS grouplabel, "
                IF arrViewFields(dvfcLinkedTableTitleField, nIndex) <> "" THEN strSQL = strSQL & arrViewFields(dvfcLinkedTableTitleField, nIndex) & " AS fieldtitle, "
				strSQL = strSQL & arrViewFields(dvfcLinkedTableValueField, nIndex) & " AS fieldvalue FROM " & arrViewFields(dvfcLinkedTable, nIndex) & arrViewFields(dvfcLinkedTableAddition, nIndex)
				strSQL = strSQL & " ORDER BY 1"
                IF arrViewFields(dvfcLinkedTableTitleField, nIndex) <> "" OR arrViewFields(dvfcLinkedTableGroupField, nIndex) <> "" THEN strSQL = strSQL & ", 2"
			
				'Response.Write(strSQL)
				IF arrViewFields(dvfcLinkedTable, nIndex) <> "" AND arrViewFields(dvfcLinkedTableValueField, nIndex) <> "" THEN
				%>
				<select class="form-control form-control-sm" name="inputField_<%= nIndex %>" ng-model="selectedRow['<%= arrViewFields(dvfcFieldLabel, nIndex) %>']" <%
				IF arrViewFields(dvfcFieldType, nIndex) = "multicombo" THEN
					Response.Write("multiple")
					IF IsNumeric(arrViewFields(dvfcHeight, nIndex)) AND arrViewFields(dvfcHeight, nIndex) > 0 THEN Response.Write(" size=" & arrViewFields(dvfcHeight, nIndex))
				END IF %>>
				<%
					SET rsFields = Server.CreateObject("ADODB.Recordset")
					rsFields.Open strSQL, adoConn
					
                    blnOptGroupStarted = False
					strLastOptGroup = ""
					WHILE NOT rsFields.EOF
                        IF arrViewFields(dvfcLinkedTableGroupField, nIndex) <> "" THEN
                            IF strLastOptGroup <> rsFields("grouplabel") THEN
                                strLastOptGroup = rsFields("grouplabel")
                                IF blnOptGroupStarted THEN
                                    Response.Write "</optgroup>"
                                END IF
                            blnOptGroupStarted = True
                        %><optgroup label="<%= Replace(rsFields("grouplabel"), """", "&quot;") %>">
                            <%
                            END IF
                        END IF
				%><option value="<%= rsFields("fieldvalue") %>"><%
						IF arrViewFields(dvfcLinkedTableTitleField, nIndex) <> "" THEN
							Response.Write(rsFields("fieldtitle"))
						Else
							Response.Write(rsFields("fieldvalue"))
						END IF
						%></option>
				<%
						rsFields.MoveNext
					WEND
					IF blnOptGroupStarted THEN
                    %>
                      </optgroup>
                    <%
                    END IF
					rsFields.Close
					SET rsFields = Nothing
				%>
				</select>
				<%
				    IF arrViewFields(dvfcFieldType, nIndex) = "multicombo" THEN Response.Write "<small class=""form-text form-text-sm text-muted"">Hold Ctrl to select multiple values</small>"
				END IF
			Case 7, 8 '"date", "datetime"
			%><input class="form-control" type="<%= arrViewFields(dvfcFieldType, nIndex) %>" name="inputField_<%= nIndex %>" ng-model="selectedRow['<%= arrViewFields(dvfcFieldLabel, nIndex) %>']"<% IF blnRequired THEN Response.Write(" required") %> <%
				IF arrViewFields(dvfcFieldType, nIndex) = "date" THEN
				 Response.Write("size=""10"" maxlength=""10""")
				Else
				 Response.Write("size=""16"" maxlength=""25""")
				END IF %>>
			<%
		    Case 13 '"time"
		    %><input class="form-control form-control-sm" type="time" name="inputField_<%= nIndex %>" ng-model="selectedRow['<%= arrViewFields(dvfcFieldLabel, nIndex) %>']"<% IF blnRequired THEN Response.Write(" required") %> step="1">
		    <%
			Case 9 '"boolean"
				%><input type="radio" class="form-check-input" name="inputField_<%= nIndex %>" id="inputField_<%= nIndex %>1" value="1" ng-model="selectedRow['<%= arrViewFields(dvfcFieldLabel, nIndex) %>']"><label for="inputField_<%= nIndex %>1" class="form-check-label">Yes</label>
				&nbsp;
				<input type="radio" class="form-check-input" name="inputField_<%= nIndex %>" id="inputField_<%= nIndex %>0" value="0" ng-model="selectedRow['<%= arrViewFields(dvfcFieldLabel, nIndex) %>']"><label for="inputField_<%= nIndex %>0" class="form-check-label">No</label>
				<%
			Case 10 '"link"
				%><span ng-model="selectedRow['<%= arrViewFields(dvfcFieldLabel, nIndex) %>']"></span>
                 <%
			Case 12 '"password"
			%>
			<input class="form-control form-control-sm" type="password" name="inputField_<%= nIndex %>" placeholder="<%= arrViewFields(dvfcFieldLabel, nIndex) %>" value="" size="<%= arrViewFields(dvfcWidth, nIndex) %>" maxlength="<%= arrViewFields(dvfcMaxLength, nIndex) %>"<% IF blnRequired THEN Response.Write(" required") %>>
			<%
			Case 3, 4 '"int", "double"
			%>
			<input class="form-control form-control-sm" type="number" name="inputField_<%= nIndex %>" placeholder="<%= arrViewFields(dvfcFieldLabel, nIndex) %>" ng-model="selectedRow['<%= arrViewFields(dvfcFieldLabel, nIndex) %>']" size="<%= arrViewFields(dvfcWidth, nIndex) %>" maxlength="<%= arrViewFields(dvfcMaxLength, nIndex) %>"<% IF blnRequired THEN Response.Write(" required") %>>
			<%
			Case 15 '"email"
			%>
			<input class="form-control form-control-sm" type="email" placeholder="<%= arrViewFields(dvfcFieldLabel, nIndex) %>" name="inputField_<%= nIndex %>" ng-model="selectedRow['<%= arrViewFields(dvfcFieldLabel, nIndex) %>']" size="<%= arrViewFields(dvfcWidth, nIndex) %>" maxlength="<%= arrViewFields(dvfcMaxLength, nIndex) %>"<% IF blnRequired THEN Response.Write(" required") %>>
			<%
			Case Else
			%>
			<input class="form-control form-control-sm" type="text" placeholder="<%= arrViewFields(dvfcFieldLabel, nIndex) %>" name="inputField_<%= nIndex %>" ng-model="selectedRow['<%= arrViewFields(dvfcFieldLabel, nIndex) %>']" size="<%= arrViewFields(dvfcWidth, nIndex) %>" maxlength="<%= arrViewFields(dvfcMaxLength, nIndex) %>"<% IF blnRequired THEN Response.Write(" required") %>>
			<%
		End Select
		%>
                </div><%
                END IF
             NEXT %>
            </div>
            <div class="modal-footer">
            <input type="hidden" name="ItemID" ng-model="selectedRow._ItemID" />
            <input type="hidden" name="mode" ng-model="selectedModalMode" />
            <button type="button" class="btn btn-default pull-left" data-dismiss="modal">Close</button>
            <button type="submit" class="btn btn-success">Save changes</button>
            </div>
        </form>
    </div>
    <!-- /.modal-content -->
    </div>
    <!-- /.modal-dialog -->
</div>
<!-- /.modal -->

<!-- Deletion Modal -->
<div class="modal fade" id="modal-delete" role="dialog">
    <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
        <div class="modal-header bg-primary">
        <h4 class="modal-title">{{ deletingModalTitle }}
            <span class="box-tools pull-right">
            <a role="button" class="btn btn-default btn-sm" data-dismiss="modal" aria-label="Close" title="Close"><span aria-hidden="true">&times;</span></a>
            </span></h4>
        </div>
        <div class="modal-body">
            Are you sure you want to delete this item?
        </div>
        <div class="modal-footer">
        <button type="button" class="btn btn-default pull-left" data-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-danger" ng-click="doDelete(selectedRow._ItemID)">Delete</button>
        </div>
    </div>
    </div>
</div>
<!-- /.modal -->
        <!-- Items List -->

<div class="box">
<div class="box-body">
<div class="box-header">
 <a class="btn btn-primary btn-sm" role="button" href="javascript:void(0)" ng-click="dvAdd(null)" title="Add" data-toggle="modal" data-target="#modal-edit"><i class="fas fa-plus"></i> Add</a>
</div>
<table datatable="ng" id="DataViewMainTable" class="table table-hover table-bordered table-striped">
<thead>
<tr><%
    nColSpan = 1

    FOR nIndex = 0 TO UBound(arrViewFields, 2)
        IF (arrViewFields(dvfcFieldFlags,nIndex) AND 8) > 0 THEN
        nColSpan = nColSpan + 1 %>
    <th><%= arrViewFields(dvfcFieldLabel, nIndex) %></th><%
        END IF
     NEXT %><th>Actions</th>
</tr>
</thead>
<tbody>
    <tr ng-repeat="row in dataviewContents.data"><%
    FOR nIndex = 0 TO UBound(arrViewFields, 2)
        IF (arrViewFields(dvfcFieldFlags,nIndex) AND 8) > 0 THEN
        Select Case arrViewFields(dvfcFieldType,nIndex)
			Case 5, 6 '"combo", "multicombo"
			%><td ng-bind="row['<%= arrViewFields(dvfcFieldLabel, nIndex) %>']"></td><%
             Case Else
			%><td ng-bind="row['<%= arrViewFields(dvfcFieldLabel, nIndex) %>']"></td><%
		End Select
        END IF
     NEXT %>
        <td>
            <a class="btn btn-primary btn-sm" role="button" href="javascript:void(0)" ng-click="dvEdit(row)" title="Edit" data-toggle="modal" data-target="#modal-edit"><i class="fas fa-edit"></i> Edit</a>
            &nbsp;<a class="btn btn-primary btn-sm" role="button" href="javascript:void(0)" ng-click="dvClone(row)" title="Clone" data-toggle="modal" data-target="#modal-edit"><i class="far fa-clone"></i> Clone</a>
            &nbsp;<a class="btn btn-primary btn-sm" role="button" href="javascript:void(0)" ng-click="dvDelete(row)" title="Delete" data-toggle="modal" data-target="#modal-delete"><i class="far fa-trash-alt"></i> Delete</a>
        </td>
    </tr>
</tbody>
</table>
</div>
<!-- /.box-body -->
</div>
<!-- /.box -->

    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->

<!--#include file="dist/asp/inc_footer.asp" -->
</div>
<!-- ./wrapper -->

<!-- REQUIRED JS SCRIPTS -->
<!--#include file="dist/asp/inc_footer_jscripts.asp" -->
    <!-- Angular -->
    <script src="bower_components/angular/angular.min.js"></script>
    <script src="bower_components/angular-datatables/dist/angular-datatables.min.js"></script>

<!-- AdminLTE App -->
<script src="dist/js/adminlte.min.js"></script>

<!-- Optionally, you can add Slimscroll and FastClick plugins.
     Both of these plugins are recommended to enhance the
     user experience. -->
<!-- page script -->
<script>
var app = angular.module("CrudeApp", ['datatables']);
app.filter("trust", ['$sce', function($sce) {
  return function(htmlCode){
    return $sce.trustAsHtml(htmlCode);
  }
}]);
app.controller("CrudeCtrl", function($scope, $http, $interval, $window) {  
    $scope.selectedModalTitle = "Adding...";
    $scope.deletingModalTitle = "Deleting...";
    $scope.selectedModalMode = "add"; 
    $scope.selectedRow = {};

    $scope.getAjaxData = function () {

      $http.get("ajax_dataview.asp?mode=dataviewcontents&ViewID=<%= nViewID %>")
      .then(function(response) {
            $scope.dataviewContents = response.data;
            console.log("loaded ajax data. num of rows: " + $scope.dataviewContents.data.length);
      }, function(response) {
            alert("Something went wrong: " + response.status + " " + response.statusText);
        });
    }
    
    $scope.setTitle = function(newTitle) {
        $window.document.title = newTitle;
    }
    
    $scope.dvAdd = function() {
        $scope.selectedModalTitle = "Adding New Item";
        $scope.selectedModalMode = "add"; 
        $scope.selectedRow = null;
    }

    $scope.dvEdit = function(r) {
        $scope.selectedModalTitle = "Editing Item " + r._ItemID;
        $scope.selectedModalMode = "edit";
        $scope.selectedRow = angular.copy(r);
    }

    $scope.dvClone = function(r) {
        $scope.selectedModalTitle = "Adding New Item";
        $scope.selectedModalMode = "add"; 
        $scope.selectedRow = angular.copy(r);
        $scope.selectedRow._ItemID = null;
    }

    $scope.dvDelete = function(r) {
        $scope.deletingModalTitle = "Deleting Item " + r._ItemID;
        $scope.selectedRow = angular.copy(r);
    }

    $scope.getAjaxData();
});
</script>
</body>
</html>