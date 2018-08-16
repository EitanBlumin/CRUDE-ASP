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
    
Dim blnFound, blnRequiredFieldsFilled, strViewIDString, strViewQueryString
Dim blnRTEEnabled, blnShowForm, blnShowList, blnShowCharts, blnAllowUpdate, blnAllowInsert, blnAllowDelete, blnAllowClone, blnAllowSearch, strOrderBy, strSearchFilter, strCurrFilter
Dim blnDtInfo, blnDtColumnFooter, blnDtQuickSearch, blnDtSort, blnDtPagination, blnDtPageSizeSelection, blnDtStateSave
Dim nDtModBtnStyle, nDtFlags, nDtDefaultPageSize, strDtPagingStyle
Dim strLastOptGroup, blnOptGroupStarted
Set rsItems = Server.CreateObject("ADODB.Recordset")

Dim myRegEx
SET myRegEx = New RegExp
myRegEx.IgnoreCase = True
myRegEx.Global = True


'[ConfigVars]
' Init Form Variables from DB. This will be deleted when generated as a seperate file.
DIM nViewID, rsFields, arrViewFields, nColSpan
DIM nFieldsNum, nViewFlags, strPageTitle, strPrimaryKey, strMainTableName, strDataViewDescription, strFilterBackLink
Dim strFilterField, blnFilterRequired, cmdStoredProc, strViewProcedure, strModificationProcedure, strDeleteProcedure, varCurrFieldValue
Dim paramPK, paramMode, paramFilter, paramOrderBy, blnRequired, blnReadOnly, nDtModBtnStyleIndex, blnShowRowActions

strError = ""
strSearchFilter = ""
strPageTitle = "Data View"

nItemID = Request("ItemID")
IF NOT IsNumeric(nItemID) THEN nItemID = ""
strMode = Request("mode")
IF strMode = "" THEN strMode = "none"

nViewID = Request("ViewID")

IF nViewID <> "" AND IsNumeric(nViewID) THEN
	strSQL = "SELECT * FROM portal.DataView WHERE ViewID = " & nViewID
	rsItems.Open strSQL, adoConn
	IF NOT rsItems.EOF THEN
		strPageTitle = rsItems("Title")
        strDataViewDescription = rsItems("ViewDescription")
        strViewProcedure = rsItems("ViewProcedure")
        strModificationProcedure = rsItems("ModificationProcedure")
        strDeleteProcedure = rsItems("DeleteProcedure")
        strMainTableName = rsItems("MainTable")
        strOrderBy = rsItems("OrderBy")
        strPrimaryKey = rsItems("PrimaryKey")
        nViewFlags = rsItems("Flags")
        nDtModBtnStyle = rsItems("DataTableModifierButtonStyle")
        nDtDefaultPageSize = rsItems("DataTableDefaultPageSize")
        nDtFlags = rsItems("DataTableFlags")
        strDtPagingStyle = rsItems("DataTablePagingStyle")
    
        blnAllowUpdate = CBool((nViewFlags AND 1) > 0)
        blnAllowInsert = CBool((nViewFlags AND 2) > 0)
        blnAllowDelete = CBool((nViewFlags AND 4) > 0)
        blnAllowClone = CBool((nViewFlags AND 8) > 0)

        blnShowRowActions = CBool(blnAllowUpdate OR blnAllowDelete OR blnAllowClone)

        blnShowForm = CBool((nViewFlags AND 16) > 0)
        blnShowList = CBool((nViewFlags AND 32) > 0)
        blnAllowSearch = CBool((nViewFlags AND 64) > 0)
        blnRTEEnabled = CBool((nViewFlags AND 128) > 0)
        blnShowCharts = CBool((nViewFlags AND 256) > 0)

        blnDtInfo = CBool((nDtFlags AND 1) > 0)
        blnDtColumnFooter = CBool((nDtFlags AND 2) > 0)
        blnDtQuickSearch = CBool((nDtFlags AND 4) > 0)
        blnDtSort = CBool((nDtFlags AND 8) > 0)
        blnDtPagination = CBool((nDtFlags AND 16) > 0)
        blnDtPageSizeSelection = CBool((nDtFlags AND 32) > 0)
        blnDtStateSave = CBool((nDtFlags AND 64) > 0)

        FOR nIndex = 0 TO UBound(arrDataTableModifierButtonStyles, 2)
            IF nDtModBtnStyle = arrDataTableModifierButtonStyles(dtbsValue, nIndex) THEN
                nDtModBtnStyleIndex = nIndex
            END IF
        NEXT
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
strViewQueryString = "&ViewID=" & nViewID
IF strFilteredValue <> "" THEN strViewQueryString = strViewQueryString & "&seek_" & Sanitizer.Querystring(strFilterField) & "=" & Sanitizer.Querystring(strFilteredValue)

'***************************
' Data Manipulation Section
'***************************
IF ((strMode = "add" AND blnAllowInsert) OR (strMode = "edit" AND blnAllowUpdate AND nItemID <> "")) AND Request.Form("postback") = "true" THEN
    Response.Write "<!-- Data Manipulation Start -->" & vbCrLf
	' If stored procedure
    IF NOT IsNull(strModificationProcedure) AND strModificationProcedure <> "" THEN
        strSQL = strModificationProcedure

	    SET cmdStoredProc = Server.CreateObject("ADODB.Command")
	    cmdStoredProc.ActiveConnection = adoConn
	    cmdStoredProc.CommandText = strSQL
	    cmdStoredProc.CommandType = adCmdStoredProc
    
        cmdStoredProc.Parameters.Refresh
        ' Parameter 0 is the return value
        ' Parameter 1 should be @Mode.
        cmdStoredProc.Parameters(1).Value = strMode
        
        ' Parameter 2 should be the PK.
        IF nItemID = "" THEN nItemID = Null
        cmdStoredProc.Parameters(2).Value = nItemID

    Else
	    strSQL = "SELECT * FROM " & strMainTableName

        IF strMode = "edit" AND nItemID <> "" AND IsNumeric(nItemID) THEN
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
            strError = "Item Not Found<br/>"
        END IF
    END IF

    IF strError = "" THEN
	Dim nParamID
    nParamID = 2
    ON ERROR RESUME NEXT

		FOR nIndex = 0 TO UBound(arrViewFields, 2) 'AND False
			IF arrViewFields(dvfcFieldType, nIndex) <> 10 AND (arrViewFields(dvfcFieldFlags, nIndex) AND 4) = 0 THEN ' not "link" or read-only
                
                IF Request("inputField_" & nIndex) = "" AND (arrViewFields(dvfcFieldFlags, nIndex) AND 2) > 0 THEN
                    strError = strError & "<b>" & Sanitizer.HTMLDisplay(arrViewFields(dvfcFieldLabel, nIndex)) & "</b> is required but has not been filled.<br/>"
                ELSE
                    Select Case arrViewFields(dvfcFieldType, nIndex)
                        Case 12, 1, 2, 6, 14 '"password", "text", "textarea", "multicombo", "rte"
                            varCurrFieldValue = Request("inputField_" & nIndex)
                        Case Else
                            IF Len(Request("inputField_" & nIndex)) = 0 AND (arrViewFields(dvfcFieldFlags, nIndex) AND 2) = 0 THEN ' if empty and not required, enter NULL
                                varCurrFieldValue = NULL
                                Response.Write "<!-- setting " & arrViewFields(dvfcFieldSource, nIndex) & " = NULL -->" & vbCrLf
                            ELSE
				                varCurrFieldValue = Request("inputField_" & nIndex)
                                Response.Write "<!-- " & arrViewFields(dvfcFieldSource, nIndex) & " is NOT NULL (" & Len(Request("inputField_" & nIndex)) & ", " & (arrViewFields(dvfcFieldFlags, nIndex) AND 2) & ") = " & varCurrFieldValue & " -->" & vbCrLf
                            END IF
                    End Select

                    IF NOT IsNull(strModificationProcedure) AND strModificationProcedure <> "" THEN
                        nParamID = nParamID + 1
                        Response.Write "<!-- Setting parameter " & nParamID & " = " & varCurrFieldValue & "-->" & vbCrlf
                        cmdStoredProc.Parameters(nParamID).Value = varCurrFieldValue
                    ELSE
                        Response.Write "<!-- setting " & arrViewFields(dvfcFieldSource, nIndex) & " = """ & varCurrFieldValue & """ (isnull: " & IsNull(varCurrFieldValue) & ") ErrCount: " & adoConn.Errors.Count & " -->" & vbCrLf
                        rsItems(arrViewFields(dvfcFieldSource, nIndex)) = varCurrFieldValue
                    END IF
                END IF
			END IF
		NEXT
        
        IF strError = "" THEN
            IF NOT IsNull(strModificationProcedure) AND strModificationProcedure <> "" THEN
	            cmdStoredProc.Execute
	
	            IF Err.Number <> 0 THEN
		            strError = strError & Err.Description & "<br/>"
	            END IF
	
	            SET cmdStoredProc = Nothing
            ELSE
                'strError = strError & "Attempting rs.Update<br/>"
                'Response.Write "<!-- ErrCount before Update: " & adoConn.Errors.Count & " -->" & vbCrLf
                rsItems.Update
                'Response.Write "<!-- ErrCount after Update: " & adoConn.Errors.Count & " -->" & vbCrLf
                rsItems.Close    
                'Response.Write "<!-- ErrCount after Close: " & adoConn.Errors.Count & " -->" & vbCrLf
            END IF
        ELSE
            rsItems.Close    
        END IF

	END IF

    ON ERROR GOTO 0

    ' check for errors
    If adoConn.Errors.Count > 0 Then
        DIM Err
        strError = strError & " Error(s) while performing """ & strMode & """:<br/>" 
        For Each Err In adoConn.Errors
			strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
        Next
        IF globalIsAdmin THEN strError = strError & "While trying to run:<br/><b>" & strSQL & "</b>"
    End If
	
	IF strError = "" THEN 
        adoConn.Close
	    Response.Redirect(constPageScriptName & "?MSG=" & strMode & strViewQueryString)
    END IF

ELSEIF strMode = "delete" AND nItemID <> "" AND IsNumeric(nItemID) AND blnAllowDelete THEN
	
	' If stored procedure
    IF NOT IsNull(strDeleteProcedure) AND strDeleteProcedure <> "" THEN
        strSQL = strDeleteProcedure

	    SET cmdStoredProc = Server.CreateObject("ADODB.Command")
	    cmdStoredProc.ActiveConnection = adoConn
	    cmdStoredProc.CommandText = strSQL
	    cmdStoredProc.CommandType = adCmdStoredProc
    
        cmdStoredProc.Parameters.Refresh
        ' Parameter 0 is the return value
        ' Parameter 1 should be the PK.
        IF nItemID = "" THEN nItemID = Null
        cmdStoredProc.Parameters(1).Value = nItemID
    
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
        Response.Redirect(constPageScriptName & "?MSG=delete" & strViewQueryString)
    End If
END IF


'***************
' Page Contents
'***************
%>
<!DOCTYPE html>
<html>
<head>
  <title><%= Sanitizer.HTMLFormControl(constPortalTitle) %></title>
<!--#include file="dist/asp/inc_meta.asp" -->
</head>
<body class="<%= globalBodyClass %>"" ng-app="CrudeApp" ng-controller="CrudeCtrl">
<div class="wrapper">
<!--#include file="dist/asp/inc_header.asp" -->

  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <%= Sanitizer.HTMLDisplay(strPageTitle) %>
      </h1>

      <ol class="breadcrumb">
        <li><a href="default.asp"><i class="fas fa-tachometer-alt"></i> Home</a></li>
        <li class="active"><%= Sanitizer.HTMLDisplay(strPageTitle) %></li>
      </ol>

    </section>

    <!-- Main content -->
    <section class="content container-fluid">

<!--<div class="row">
    <div class="col col-sm-12">
        <a class="btn btn-primary" role="button" href="#"><i class="fas fa-arrow-left"></i> Back</a>
    </div>
</div>-->
<div class="row">
    <div class="col col-sm-12"><br />
        <small><%= Sanitizer.HTMLDisplay(strDataViewDescription) %></small>
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
            <a class="btn btn-danger btn-sm" ng-show="selectedModalMode != 'add'" role="button" href="#" ng-click="dvDelete(row)" aria-label="Delete" title="Delete" data-toggle="modal" data-target="#modal-delete"><i class="far fa-trash-alt"></i> Delete</a>
                &nbsp;
            <a role="button" class="btn btn-default btn-sm" data-dismiss="modal" aria-label="Close" title="Close"><span aria-hidden="true">&times;</span></a>
            </span></h4>
        </div>
        <form action="<%= constPageScriptName & "?ViewID=" & Sanitizer.Querystring(nViewID) %>" method="post">
            <div class="modal-body"><%
            FOR nIndex = 0 TO UBound(arrViewFields, 2)
                ' Check if "Show in Form" enabled
                IF (arrViewFields(dvfcFieldFlags,nIndex) AND 1) > 0 THEN 
                    blnRequired = CBool((arrViewFields(dvfcFieldFlags, nIndex) AND 2) > 0)
                    blnReadOnly = CBool((arrViewFields(dvfcFieldFlags, nIndex) AND 4) > 0)
                %>
                <div class="form-group" data-toggle="tooltip" title="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldDescription, nIndex)) %>">
                    <label for="inputLabel_<%= nIndex %>" class="control-label"><%= Sanitizer.HTMLDisplay(arrViewFields(dvfcFieldLabel, nIndex)) %></label>
            <%
        Select Case arrViewFields(dvfcFieldType,nIndex)
			Case 2 '"textarea"
			%><textarea class="form-control form-control-sm" name="inputField_<%= nIndex %>" placeholder="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>" rows="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcHeight, nIndex)) %>" cols="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcWidth, nIndex)) %>"<% IF blnRequired THEN Response.Write(" required") %> ng-model="row['<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>']"<% IF blnRequired THEN Response.Write(" required") %><% IF blnReadOnly THEN Response.Write(" readonly") %>></textarea>
			<%
			Case 14 '"rte"
			%><textarea name="inputField_<%= nIndex %>" class="textarea__" <% IF blnRequired THEN Response.Write(" required") %><% IF blnReadOnly THEN Response.Write(" readonly") %>>{{ row['<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>'] }}</textarea>
			<%
			Case 5, 6 '"combo", "multicombo"
				strSQL = "SELECT DISTINCT "
                IF arrViewFields(dvfcLinkedTableGroupField, nIndex) <> "" THEN strSQL = strSQL & Sanitizer.SQL(arrViewFields(dvfcLinkedTableGroupField, nIndex)) & " AS grouplabel, "
                IF arrViewFields(dvfcLinkedTableTitleField, nIndex) <> "" THEN strSQL = strSQL & Sanitizer.SQL(arrViewFields(dvfcLinkedTableTitleField, nIndex)) & " AS fieldtitle, "
				strSQL = strSQL & arrViewFields(dvfcLinkedTableValueField, nIndex) & " AS fieldvalue FROM " & Sanitizer.SQL(arrViewFields(dvfcLinkedTable, nIndex)) & " " & arrViewFields(dvfcLinkedTableAddition, nIndex)
				strSQL = strSQL & " ORDER BY 1"
                IF arrViewFields(dvfcLinkedTableTitleField, nIndex) <> "" OR arrViewFields(dvfcLinkedTableGroupField, nIndex) <> "" THEN strSQL = strSQL & ", 2"
			
				'Response.Write(strSQL)
				IF arrViewFields(dvfcLinkedTable, nIndex) <> "" AND arrViewFields(dvfcLinkedTableValueField, nIndex) <> "" THEN
				%>
				<select class="form-control form-control-sm" name="inputField_<%= nIndex %>" ng-model="row['<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>']"<% IF blnRequired THEN Response.Write(" ng-required=""true""") %> <%
				IF arrViewFields(dvfcFieldType, nIndex) = "multicombo" THEN
					Response.Write("multiple")
					IF IsNumeric(arrViewFields(dvfcHeight, nIndex)) AND arrViewFields(dvfcHeight, nIndex) > 0 THEN Response.Write(" size=""" & Sanitizer.HTMLFormControl(arrViewFields(dvfcHeight, nIndex)) & """")
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
                        %><optgroup label="<%= Sanitizer.HTMLFormControl(rsFields("grouplabel")) %>">
                            <%
                            END IF
                        END IF
				%><option value="<%= rsFields("fieldvalue") %>"><%
						IF arrViewFields(dvfcLinkedTableTitleField, nIndex) <> "" THEN
							Response.Write Sanitizer.HTMLFormControl(rsFields("fieldtitle"))
						Else
							Response.Write Sanitizer.HTMLFormControl(rsFields("fieldvalue"))
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
			%><input class="form-control" type="date" name="inputField_<%= nIndex %>" value="{{row['<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>']}}"<% IF blnRequired THEN Response.Write(" required") %><% IF blnReadOnly THEN Response.Write(" readonly") %> <%
				IF arrViewFields(dvfcFieldType, nIndex) = "date" THEN
				 Response.Write("size=""10"" maxlength=""10""")
				Else
				 Response.Write("size=""16"" maxlength=""25""")
				END IF %>>
			<%
		    Case 13 '"time"
		    %><input class="form-control form-control-sm" type="time" name="inputField_<%= nIndex %>" value="{{row['<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>'].substr(0,8)}}"<% IF blnRequired THEN Response.Write(" required") %><% IF blnReadOnly THEN Response.Write(" readonly") %> step="1">
		    <%
			Case 9 '"boolean"
				%><input type="radio" class="form-check-input" name="inputField_<%= nIndex %>" id="inputField_<%= nIndex %>1" value="1" ng-model="row['<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>']"<% IF blnReadOnly THEN Response.Write(" readonly") %>><label for="inputField_<%= nIndex %>1" class="form-check-label">Yes</label>
				&nbsp;
				<input type="radio" class="form-check-input" name="inputField_<%= nIndex %>" id="inputField_<%= nIndex %>0" value="0" ng-model="row['<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>']"<% IF blnReadOnly THEN Response.Write(" readonly") %>><label for="inputField_<%= nIndex %>0" class="form-check-label">No</label>
				<%
			Case 10 '"link"
				%><span ng-model="row['<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>']"></span>
                 <%
			Case 12 '"password"
			%>
			<input class="form-control form-control-sm" type="password" name="inputField_<%= nIndex %>" placeholder="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>" value="" size="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcWidth, nIndex)) %>" maxlength="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcMaxLength, nIndex)) %>"<% IF blnRequired THEN Response.Write(" required") %><% IF blnReadOnly THEN Response.Write(" readonly") %>>
			<%
			Case 3, 4 '"int", "double"
			%>
			<input class="form-control form-control-sm" type="number" name="inputField_<%= nIndex %>" placeholder="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>" value="{{ row['<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>'] }}" size="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcWidth, nIndex)) %>" maxlength="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcMaxLength, nIndex)) %>"<% IF blnRequired THEN Response.Write(" required") %><% IF blnReadOnly THEN Response.Write(" readonly") %>>
			<%
			Case 15 '"email"
			%>
			<input class="form-control form-control-sm" type="email" placeholder="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>" name="inputField_<%= nIndex %>" ng-model="row['<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>']" size="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcWidth, nIndex)) %>" maxlength="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcMaxLength, nIndex)) %>"<% IF blnRequired THEN Response.Write(" required") %><% IF blnReadOnly THEN Response.Write(" readonly") %>>
			<%
			Case Else
			%>
			<input class="form-control form-control-sm" type="text" placeholder="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>" name="inputField_<%= nIndex %>" ng-model="row['<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>']" size="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcWidth, nIndex)) %>" maxlength="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcMaxLength, nIndex)) %>"<% IF blnRequired THEN Response.Write(" required") %><% IF blnReadOnly THEN Response.Write(" readonly") %>>
			<%
		End Select
		%>
                </div><%
                END IF
             NEXT %>
            </div>
            <div class="modal-footer">
            <input type="hidden" name="postback" value="true" />
            <input type="hidden" name="ItemID" value="{{ row._ItemID }}" />
            <input type="hidden" name="mode" value="{{ selectedModalMode }}" />
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
        <h4 class="modal-title">Deleting Item
            <span class="box-tools pull-right">
            <a role="button" class="btn btn-default btn-sm" data-dismiss="modal" aria-label="Close" title="Close"><span aria-hidden="true">&times;</span></a>
            </span></h4>
        </div>
        <form action="<%= constPageScriptName & "?ViewID=" & nViewID %>" method="post">
            <div class="modal-body">
                <p>Are you sure you want to delete this item?</p>
                <%
            FOR nIndex = 0 TO UBound(arrViewFields, 2)
                IF (arrViewFields(dvfcFieldFlags,nIndex) AND 8) > 0 THEN %>
                <div class="row">
                    <div class="col col-md-5 col-sm-3" data-toggle="tooltip" title="<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldDescription, nIndex)) %>"><b><%= Sanitizer.HTMLDisplay(arrViewFields(dvfcFieldLabel, nIndex)) %>:</b></div>
                    <div class="col col-md-7 col-sm-9"><% 
                    Select Case arrViewFields(dvfcFieldType,nIndex)
			            Case 5, 6 '"combo", "multicombo"
                        %>{{ row['_resolved_<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>'] }}<%
		                Case 13 '"time"
                            Response.Write "{{ row['" & Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) & "'].substr(0,8) }}"
                        Case Else
                        %>{{ row['<%= Sanitizer.HTMLFormControl(arrViewFields(dvfcFieldLabel, nIndex)) %>'] }}<%
		            End Select %></div>
                </div>
                <% END IF
            NEXT %>
            </div>
            <div class="modal-footer">
            <input type="hidden" name="postback" value="true" />
            <input type="hidden" name="ItemID" value="{{ row._ItemID }}" />
            <input type="hidden" name="mode" value="delete" />
            <button type="button" class="btn btn-default pull-left" data-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-danger">Delete</button>
            </div>
        </form>
    </div>
    </div>
</div>
<!-- /.modal -->
        <!-- Items List -->

<div class="box">
<div class="box-header">
 <a class="<%= arrDataTableModifierButtonStyles(dtbsClass, nDtModBtnStyleIndex) %>" role="button" href="#" ng-click="dvAdd(null)" title="Add" data-toggle="modal" data-target="#modal-edit"><% IF arrDataTableModifierButtonStyles(dtbsShowGlyph,nDtModBtnStyleIndex) THEN  %><i class="fas fa-plus"></i> <% END IF %>Add</a>
</div>
<div class="box-body">
<table datatable="ng" id="DataViewMainTable" dt-options="dtOptions" class="table table-hover table-bordered table-striped">
<thead>
<tr><%
    nColSpan = 1

    FOR nIndex = 0 TO UBound(arrViewFields, 2)
        IF (arrViewFields(dvfcFieldFlags,nIndex) AND 8) > 0 THEN
        nColSpan = nColSpan + 1 %>
    <th><%= Sanitizer.HTMLDisplay(arrViewFields(dvfcFieldLabel, nIndex)) %></th><%
        END IF
     NEXT
    IF blnShowRowActions THEN %><th>Actions</th><% END IF %>
</tr>
</thead>
<tbody>
    <tr ng-repeat="row in dataviewContents.data"><%
Dim nIndex2, strCurrLabelBind
    FOR nIndex = 0 TO UBound(arrViewFields, 2)
        IF (arrViewFields(dvfcFieldFlags,nIndex) AND 8) > 0 THEN

            Select Case arrViewFields(dvfcFieldType,nIndex)
			    Case 5, 6 '"combo", "multicombo"
                    strCurrLabelBind = "row['_resolved_" & arrViewFields(dvfcFieldLabel, nIndex) & "']"
		        Case 13 '"time"
                    strCurrLabelBind = "row['" & arrViewFields(dvfcFieldLabel, nIndex) & "'].substr(0,8)"
                 Case Else
                    strCurrLabelBind = "row['" & arrViewFields(dvfcFieldLabel, nIndex) & "']"
		    End Select
            
            ' if has URI
            IF arrViewFields(dvfcUriPath, nIndex) <> "" THEN
			%><td><a ng-bind="<%= strCurrLabelBind %>" href="<%= arrViewFields(dvfcUriPath, nIndex) %>" class="<%
                FOR nIndex2 = 0 TO UBound(arrDataViewUriStyles, 2)
                    IF arrDataViewUriStyles(dvusValue, nIndex2) = arrViewFields(dvfcUriStyle, nIndex) THEN Response.Write arrDataViewUriStyles(dvusClass, nIndex2)
                NEXT
                 %>"></a></td><%
            ELSE
			%><td ng-bind="<%= strCurrLabelBind %>"></td><%
            END IF
        END IF
     NEXT
                
     IF blnShowRowActions THEN %>
        <td>
            <% IF blnAllowUpdate THEN %><a class="<%= arrDataTableModifierButtonStyles(dtbsClass, nDtModBtnStyleIndex) %>" role="button" href="#" ng-click="dvEdit(row)" title="Edit" data-toggle="modal" data-target="#modal-edit"><% IF arrDataTableModifierButtonStyles(dtbsShowGlyph,nDtModBtnStyleIndex) THEN  %><i class="fas fa-edit"></i> <% END IF %><% IF arrDataTableModifierButtonStyles(dtbsShowText,nDtModBtnStyleIndex) THEN Response.Write "Edit" %></a>&nbsp;<% END IF %>
            <% IF blnAllowClone THEN %><a class="<%= arrDataTableModifierButtonStyles(dtbsClass, nDtModBtnStyleIndex) %>" role="button" href="#" ng-click="dvClone(row)" title="Clone" data-toggle="modal" data-target="#modal-edit"><% IF arrDataTableModifierButtonStyles(dtbsShowGlyph,nDtModBtnStyleIndex) THEN  %><i class="far fa-clone"></i> <% END IF %><% IF arrDataTableModifierButtonStyles(dtbsShowText,nDtModBtnStyleIndex) THEN Response.Write "Clone" %></a>&nbsp;<% END IF %>
            <% IF blnAllowDelete THEN %><a class="<%= arrDataTableModifierButtonStyles(dtbsClass, nDtModBtnStyleIndex) %>" role="button" href="#" ng-click="dvDelete(row)" title="Delete" data-toggle="modal" data-target="#modal-delete"><% IF arrDataTableModifierButtonStyles(dtbsShowGlyph,nDtModBtnStyleIndex) THEN  %><i class="far fa-trash-alt"></i> <% END IF %><% IF arrDataTableModifierButtonStyles(dtbsShowText,nDtModBtnStyleIndex) THEN Response.Write "Delete" %></a><% END IF %>
        </td><%
     END IF %>
    </tr>
</tbody><% IF blnDtColumnFooter THEN %>
<tfoot>
<tr><%
    FOR nIndex = 0 TO UBound(arrViewFields, 2)
        IF (arrViewFields(dvfcFieldFlags,nIndex) AND 8) > 0 THEN %>
    <th><%= Sanitizer.HTMLDisplay(arrViewFields(dvfcFieldLabel, nIndex)) %></th><%
        END IF
     NEXT %><th>Actions</th>
</tr>
</tfoot><% END IF %>
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
    $scope.row = {};
    $scope.dtOptions = {
            sPaginationType: '<%= strDtPagingStyle %>',<% IF NOT blnDtSort THEN %>
            bSort: false,<% END IF %><% IF NOT blnDtQuickSearch THEN %>
            bFilter: false,<% END IF %><% IF NOT blnDtInfo THEN %>
            bInfo: false,<% END IF %><% IF NOT blnDtPageSizeSelection THEN %>
            bLengthChange: false,<% END IF %><% IF NOT blnDtPagination THEN %>
            bPaginate: false,<% END IF %><% IF blnDtStateSave THEN %>
            bStateSave: true,<% END IF %>
            displayLength: <%= nDtDefaultPageSize %>,
            aoColumnDefs: [
                {
                    aTargets: [-1],
                    bSortable: false,
                    bSearchable: false
                }
            ]
        };

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
        $scope.row = null;
    }

    $scope.dvEdit = function(r) {
        $scope.selectedModalTitle = "Editing Item " + r._ItemID;
        $scope.selectedModalMode = "edit";
        $scope.row = angular.copy(r);
//        $('.textarea').each(function() {
//            console.log(this.innerHTML);
//            console.log($editor);
//            $editor.html(r.Tooltip);
//        });
    }

    $scope.dvClone = function(r) {
        $scope.selectedModalTitle = "Adding New Item";
        $scope.selectedModalMode = "add"; 
        $scope.row = angular.copy(r);
        $scope.row._ItemID = null;
    }

    $scope.dvDelete = function(r) {
        $scope.deletingModalTitle = "Deleting Item " + r._ItemID;
        $scope.row = angular.copy(r);
    }

    $scope.getAjaxData();
});
</script>
</body>
</html>