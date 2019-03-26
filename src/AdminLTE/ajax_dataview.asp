<%@ LANGUAGE="VBSCRIPT" CODEPAGE="65001" %>
<!--#include file="dist/asp/inc_config.asp" -->
<%' use this meta tag instead of adovbs.inc%>
<!--METADATA TYPE="typelib" uuid="00000205-0000-0010-8000-00AA006D2EA4" -->
<%
Response.CodePage = 65001
Session.CodePage = 65001
Response.CharSet = "UTF-8"
Response.Expires = -1
Response.ExpiresAbsolute = Now() - 2
Response.AddHeader "pragma","no-cache"
Response.AddHeader "cache-control","private"
Response.AddHeader "Access-Control-Allow-Origin", "*"
Response.AddHeader "Content-type", "application/json; charset=UTF-8"
Response.CacheControl = "No-Store"

'************************
' Initialization Section
'************************

' Variable Definition
Dim strMode, adoConnCrudeSrc, adoConnCrudeSource, cmdStoredProc, nItemID, nIndex, blnFound, nColSpan, blnRequiredFieldsFilled, strFormIDString
Dim blnDtInfo, blnDtColumnFooter, blnDtQuickSearch, blnDtSort, blnDtPagination, blnDtPageSizeSelection, blnDtStateSave
Dim nDtModBtnStyle, nDtFlags, nDtDefaultPageSize, strDtPagingStyle, strRowReorderCol
Dim blnRTEEnabled, blnShowForm, blnShowList, blnAllowUpdate, blnAllowInsert, blnAllowDelete, blnAllowClone, blnShowCharts, blnAllowCNamee, blnAllowSearch, strOrderBy, strSearchFilter, strCurrFilter
Dim strLastOptGroup, blnOptGroupStarted, strJsonOutput, strMsgOutput
Dim nViewID, dvFields, arrViewFields
Dim nFieldsNum, nViewFlags, strPrimaryKey, strDataSource, strMainTableName, strDataViewDescription, strFilterBackLink
Dim strFilterField, blnFilterRequired, strViewProcedure, strModificationProcedure, strDeleteProcedure, varCurrFieldValue
Dim paramPK, paramMode, paramFilter, paramOrderBy, blnRequired, blnReadOnly, nDtModBtnStyleIndex, blnShowRowActions
Set rsItems = Server.CreateObject("ADODB.Recordset")
strMode = Request("mode")

Dim myRegEx
SET myRegEx = New RegExp
myRegEx.IgnoreCase = True
myRegEx.Global = True
    
'IF (strMode = "add" OR strMode = "edit") AND Request.Form <> "" THEN
'    Dim bytecount, bytes, stream, jsonPayload
'
'    bytecount = Request.TotalBytes
'    bytes = Request.BinaryRead(bytecount)
'
'    Set stream = Server.CreateObject("ADODB.Stream")
'    stream.Type = 1    ' adTypeBinary              
'    stream.Open()
'    stream.Write(bytes)
'    stream.Position = 0                             
'    stream.Type = 2   ' adTypeText                
'    stream.Charset = "utf-8"
'    Set jsonPayload = stream.ReadText()
'    stream.Close()
'    'Response.Write jsonPayload  
'END IF
SET adoConnCrude = adoConn
adoConnCrude.Open
    
%><!--#include file="dist/asp/inc_crudeconstants.asp" --><%

nViewID = Request("ViewID")

IF strError = "" AND nViewID <> "" AND IsNumeric(nViewID) THEN
    SET rsItems = Server.CreateObject("ADODB.Command")
    rsItems.ActiveConnection = adoConnCrude
    rsItems.CommandText = "SELECT * FROM portal.DataView WHERE ViewID = ?"
	SET rsItems = rsItems.Execute (,nViewID,adOptionUnspecified)
	IF NOT rsItems.EOF THEN
        strDataSource = rsItems("DataSource")
        strModificationProcedure = rsItems("ModificationProcedure")
        strDeleteProcedure = rsItems("DeleteProcedure")
        strMainTableName = rsItems("MainTable")
        strRowReorderCol = rsItems("RowReorderColumn")
        strPrimaryKey = rsItems("PrimaryKey")
        nViewFlags = rsItems("Flags")
    
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
    
		SET dvFields = InitDataViewFields(nViewID, adoConnCrude)
	ELSE
		strError = GetWord("ViewID Not Found!")
		nViewID = ""
	END IF
	rsItems.Close
END IF

IF strMode = "getSiteNav" THEN
    strSQL = "SELECT [Json] = portal.GetNavigationRecursive(NULL)"
    rsItems.Open strSQL, adoConnCrude
    IF NOT rsItems.EOF THEN
        Response.Write rsItems("Json")
    ELSE
        Response.Write "[ ]"
    END IF
    rsItems.Close
ELSEIF strError = "" AND (strMode = "add" OR strMode = "edit" OR strMode = "delete" OR strMode = "delete_multiple" OR strMode = "reorder") AND Request.Form("postback") <> "" AND Request("ViewID") <> "" AND IsNumeric(Request("ViewID")) THEN
    nItemID = Request("DT_RowID")
    IF NOT IsNumeric(nItemID) AND strMode <> "delete_multiple" AND strMode <> "reorder" THEN nItemID = ""
    
    IF strDataSource <> "" THEN
        adoConnCrudeSource = GetConfigValue("connectionStrings", "name", "connectionString", strDataSource, adoConStr)

        IF adoConnCrudeSource = "" THEN strError = GetWord("No connection string found for data source") & " " & strDataSource
    ELSE
        strError = GetWord("No Data Source specified!")
    END IF

    IF strError = "" THEN
        Set adoConnCrudeSrc = Server.CreateObject("ADODB.Connection")
        adoConnCrudeSrc.ConnectionString = adoConnCrudeSource
        adoConnCrudeSrc.CommandTimeout = 0

        ON ERROR RESUME NEXT

        adoConnCrudeSrc.Open

        IF adoConnCrudeSrc.Errors.Count > 0 THEN
	        strError = "ERROR while trying to open data source " & strDataSource & ":<br>"
            For Each Err In adoConnCrudeSrc.Errors
		        strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
            Next
        'ELSE
        '        Response.Write "<!-- Opened ConnString (" & strDataSource & ") " & adoConnCrudeSource & " -->" 
        END IF

        ON ERROR GOTO 0
    END IF

    '***************************
    ' Data Manipulation Section
    '***************************
    strMsgOutput = ""

    IF strError = "" AND ((strMode = "add" AND blnAllowInsert) OR (strMode = "edit" AND blnAllowUpdate AND nItemID <> "")) THEN
        'strMsgOutput = strMsgOutput & "<!-- Data Manipulation Start -->" & vbCrLf
	    ' If stored procedure
        IF NOT IsNull(strModificationProcedure) AND strModificationProcedure <> "" THEN
            strSQL = strModificationProcedure

	        SET cmdStoredProc = Server.CreateObject("ADODB.Command")
	        cmdStoredProc.ActiveConnection = adoConnCrudeSrc
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
            rsItems.Open strSQL, adoConnCrudeSrc

            IF strMode = "add" THEN
                rsItems.AddNew
            END IF

            IF strMode = "edit" AND rsItems.EOF THEN
                strError = "Item Not Found<br/>"
            END IF
        END IF

        IF strError = "" THEN
	    Dim nParamID
        DIM Err
        nParamID = 2
        'ON ERROR RESUME NEXT
            
		    FOR nIndex = 0 TO dvFields.UBound 'AND False
			    IF dvFields(nIndex)("FieldType") <> 10 AND (dvFields(nIndex)("FieldFlags") AND 4) = 0 THEN ' not "link" or read-only
                    IF dvFields(nIndex)("FieldType") <> 9 AND Request("Field_" & dvFields(nIndex)("FieldID")) = "" AND (dvFields(nIndex)("FieldFlags") AND 2) > 0 THEN
                        strError = strError & "<b>" & Sanitizer.HTMLDisplay(dvFields(nIndex)("FieldLabel")) & "</b> is required but has not been filled.<br/>"
                    ELSE
                        Select Case dvFields(nIndex)("FieldType")
                            Case 12, 1, 2, 6, 14 '"password", "text", "textarea", "multicombo", "rte"
                                varCurrFieldValue = Request("Field_" & dvFields(nIndex)("FieldID"))
                            Case 9, 22, 23, 26 '"boolean"
                                varCurrFieldValue = CBool(Request("Field_" & dvFields(nIndex)("FieldID")))
                            Case 13 '"time"
                                IF Len(Request("Field_" & dvFields(nIndex)("FieldID"))) = 0 AND (dvFields(nIndex)("FieldFlags") AND 2) = 0 THEN ' if empty and not required, enter NULL
                                    varCurrFieldValue = NULL
                                    'strMsgOutput = strMsgOutput & "<!-- setting [time] field " & dvFields(nIndex)("FieldSource") & " = NULL -->" & vbCrLf
                                ELSE
				                    varCurrFieldValue = Mid(Request("Field_" & dvFields(nIndex)("FieldID")), 1, 8)
                                    'strMsgOutput = strMsgOutput & "<!-- [time] field " & dvFields(nIndex)("FieldSource") & " is NOT NULL (" & Len(Request("Field_" & dvFields(nIndex)("FieldID"))) & ", " & (dvFields(nIndex)("FieldFlags") AND 2) & ") = " & varCurrFieldValue & " -->" & vbCrLf
                                END IF
                            Case 27, 28, 29 '"bitwise"
                                IF Len(Request("Field_" & dvFields(nIndex)("FieldID"))) = 0 THEN ' if empty, enter 0
                                    varCurrFieldValue = 0
                                    'strMsgOutput = strMsgOutput & "<!-- setting " & dvFields(nIndex)("FieldSource") & " = NULL -->" & vbCrLf
                                ELSE
                                    Dim arrValues, currVal
                                    arrValues = Split(Request("Field_" & dvFields(nIndex)("FieldID")), ",")
    
                                    varCurrFieldValue = 0

                                    For Each currVal In arrValues
                                        IF IsNumeric(currVal) THEN varCurrFieldValue = varCurrFieldValue + CLng(currVal)
                                    'strMsgOutput = strMsgOutput & "<!-- " & dvFields(nIndex)("FieldSource") & " is NOT NULL (" & Len(Request("Field_" & dvFields(nIndex)("FieldID"))) & ", " & (dvFields(nIndex)("FieldFlags") AND 2) & ") = " & varCurrFieldValue & " -->" & vbCrLf
                                    Next
                                END IF
                            Case Else
                                IF Len(Request("Field_" & dvFields(nIndex)("FieldID"))) = 0 AND (dvFields(nIndex)("FieldFlags") AND 2) = 0 THEN ' if empty and not required, enter NULL
                                    varCurrFieldValue = NULL
                                    'strMsgOutput = strMsgOutput & "<!-- setting " & dvFields(nIndex)("FieldSource") & " = NULL -->" & vbCrLf
                                ELSE
				                    varCurrFieldValue = Request("Field_" & dvFields(nIndex)("FieldID"))
                                    'strMsgOutput = strMsgOutput & "<!-- " & dvFields(nIndex)("FieldSource") & " is NOT NULL (" & Len(Request("Field_" & dvFields(nIndex)("FieldID"))) & ", " & (dvFields(nIndex)("FieldFlags") AND 2) & ") = " & varCurrFieldValue & " -->" & vbCrLf
                                END IF
                        End Select

                        IF NOT IsNull(strModificationProcedure) AND strModificationProcedure <> "" THEN
                            nParamID = nParamID + 1
                            'strMsgOutput = strMsgOutput & "<!-- Setting parameter " & nParamID & " = " & varCurrFieldValue & "-->" & vbCrlf
                            cmdStoredProc.Parameters(nParamID).Value = varCurrFieldValue
                        ELSE
                            'strMsgOutput = strMsgOutput & "<!-- setting " & dvFields(nIndex)("FieldSource") & " = """ & varCurrFieldValue & """ (isnull: " & IsNull(varCurrFieldValue) & ") ErrCount: " & adoConnCrude.Errors.Count & " -->" & vbCrLf
                            'Response.Write dvFields(nIndex)("FieldSource") & ": " & varCurrFieldValue & "<br/>" & vbCrLf
                            rsItems(dvFields(nIndex)("FieldSource")) = varCurrFieldValue
                        END IF
                    END IF
			    END IF
		    NEXT
        
            IF strError = "" THEN
                IF NOT IsNull(strModificationProcedure) AND strModificationProcedure <> "" THEN
                    ON ERROR RESUME NEXT
	                    cmdStoredProc.Execute
	                    IF adoConnCrudeSrc.Errors.Count > 0 THEN
		                    strError = strError & " Executed Stored Procedure " & strModificationProcedure & " With Errors:</br>"
                            For Each Err In adoConnCrudeSrc.Errors
			                    strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & "<br/>"
                            Next
    		            END IF
                    ON ERROR GOTO 0

	                SET cmdStoredProc = Nothing
                ELSE
                    'strError = strError & "Attempting rs.Update<br/>"
                    'Response.Write "<!-- ErrCount before Update: " & adoConnCrudeSrc.Errors.Count & " -->" & vbCrLf
                    ON ERROR RESUME NEXT
                        rsItems.Update
                        'Response.Write "<!-- ErrCount after Update: " & adoConnCrudeSrc.Errors.Count & " -->" & vbCrLf
	                    IF adoConnCrudeSrc.Errors.Count > 0 THEN
		                    strError = strError & " Database Operation Error while performing """ & UCase(strMode) & """:</br>"
                            For Each Err In adoConnCrudeSrc.Errors
			                    strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & "<br/>"
                            Next
                        ELSE
                            rsItems.Close    
    		            END IF
                    'Response.Write "<!-- ErrCount after Close: " & adoConnCrudeSrc.Errors.Count & " -->" & vbCrLf
                    ON ERROR GOTO 0

                END IF
            'ELSE
            '    Response.Write vbCrLf & "ERROR: " & strError & vbCrLf
                
            '    rsItems.Close    
            END IF

	    END IF

        'ON ERROR GOTO 0

        ' check for errors
        'If adoConnCrudeSrc.Errors.Count > 0 Then
        '    DIM Err
        '    strError = strError & " Error(s) while performing """ & strMode & """:<br/>" 
        '    For Each Err In adoConnCrudeSrc.Errors
		'	    strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
        '    Next
        '    IF globalIsAdmin THEN strError = strError & "While trying to run:<br/><b>" & strSQL & "</b>"
        'END IF
	
	    IF strError = "" THEN 
            strMsgOutput = strMsgOutput & UCase(strMode) & " successful!"
            adoConnCrudeSrc.Close
            adoConnCrude.Close
	        'Response.Redirect(constPageScriptName & "?MSG=" & strMode & strViewQueryString)
        END IF

    ELSEIF strError = "" AND strMode = "delete" AND nItemID <> "" AND IsNumeric(nItemID) AND blnAllowDelete THEN
	
	    ' If stored procedure
        IF NOT IsNull(strDeleteProcedure) AND strDeleteProcedure <> "" THEN
            strSQL = strDeleteProcedure

	        SET cmdStoredProc = Server.CreateObject("ADODB.Command")
	        cmdStoredProc.ActiveConnection = adoConnCrudeSrc
	        cmdStoredProc.CommandText = strSQL
	        cmdStoredProc.CommandType = adCmdStoredProc
    
            cmdStoredProc.Parameters.Refresh
            ' Parameter 0 is the return value
            ' Parameter 1 should be the PK.
            IF nItemID = "" THEN nItemID = Null
            cmdStoredProc.Parameters(1).Value = nItemID
    
            ON ERROR RESUME NEXT

	        cmdStoredProc.Execute
    
            IF adoConnCrudeSrc.Errors.Count > 0 THEN
	            strError = "ERROR while trying to delete using data source " & strDataSource & ":<br/>"
                For Each Err In adoConnCrudeSrc.Errors
		            strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
                Next
            ELSE
                strMsgOutput = strMsgOutput & "Successfully Deleted: " & nItemID
            END IF
	
	        SET cmdStoredProc = Nothing

            ON ERROR GOTO 0
        Else
            strSQL = "DELETE FROM " & strMainTableName & " WHERE " & strPrimaryKey & " = " & nItemID
	        adoConnCrudeSrc.Execute strSQL
        End If

	    IF strError = "" Then
    	    adoConnCrudeSrc.Close
            adoConnCrude.Close
            'Response.Redirect(constPageScriptName & "?MSG=delete" & strViewQueryString)
        End If
    ELSEIF strError = "" AND strMode = "delete_multiple" AND nItemID <> "" AND blnAllowDelete THEN
    
	    ' If stored procedure
        IF NOT IsNull(strDeleteProcedure) AND strDeleteProcedure <> "" THEN
            strSQL = strDeleteProcedure

	        SET cmdStoredProc = Server.CreateObject("ADODB.Command")
	        cmdStoredProc.ActiveConnection = adoConnCrudeSrc
	        cmdStoredProc.CommandText = strSQL
	        cmdStoredProc.CommandType = adCmdStoredProc
    
            cmdStoredProc.Parameters.Refresh
            ' Parameter 0 is the return value
            ' Parameter 1 should be the PK.
            IF nItemID = "" THEN nItemID = Null
            cmdStoredProc.Parameters(1).Value = nItemID
    
            ON ERROR RESUME NEXT

	        cmdStoredProc.Execute
    
            IF adoConnCrudeSrc.Errors.Count > 0 THEN
	            strError = "ERROR while trying to delete using data source " & strDataSource & ":<br/>"
                For Each Err In adoConnCrudeSrc.Errors
		            strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
                Next
            ELSE
                strMsgOutput = strMsgOutput & "Successfully Deleted: " & nItemID
            END IF
	
	        SET cmdStoredProc = Nothing

            ON ERROR GOTO 0
        Else
            strSQL = "DELETE FROM " & strMainTableName & " WHERE " & strPrimaryKey & " IN("
    
            Dim arrIdsToDelete, nSingleItemID
            arrIdsToDelete = Split(nItemID,",")
        
            FOR nIndex = 0 To UBound(arrIdsToDelete)
                IF arrIdsToDelete(nIndex) <> "" AND IsNumeric(arrIdsToDelete(nIndex)) THEN
                    IF nIndex > 0 THEN strSQL = strSQL & ", "
                    strSQL = strSQL & arrIdsToDelete(nIndex)
                END IF
            NEXT

            strSQL = strSQL & ")"
            
            ON ERROR RESUME NEXT
    
	        adoConnCrudeSrc.Execute strSQL
    
            IF adoConnCrudeSrc.Errors.Count > 0 THEN
	            strError = "ERROR while trying to delete multiple rows using data source " & strDataSource & ":<br/>"
                For Each Err In adoConnCrudeSrc.Errors
		            strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
                Next
            ELSE
                strMsgOutput = strMsgOutput & "Successfully Deleted: " & nItemID
            END IF
        End If

	    IF strError = "" Then
    	    adoConnCrudeSrc.Close
            adoConnCrude.Close
            'Response.Redirect(constPageScriptName & "?MSG=delete" & strViewQueryString)
        End If
    
    ELSEIF strError = "" AND strMainTableName <> "" AND Request.Form("DT_RowId") <> "" AND strMode = "reorder" AND strRowReorderCol <> "" AND NOT IsNull(strRowReorderCol) THEN
    
        'Response.Status = "500 Server Error"
        'Response.Write "<div class='alert alert-danger'><h1><i class='fas fa-times-circle'></i> ERROR</h1>"
        'Response.Write "<BR/>NOT YET IMPLEMENTED"
        Dim RowIds, currRowId, objReorderDom, objReorder, objRow, objattRowIndex, objReorderPI
        RowIds = Split(Request("DT_RowId"), ",")
        
        'Instantiate the Microsoft XMLDOM
        Set objReorderDom = server.CreateObject("Microsoft.XMLDOM")
        objReorderDom.preserveWhiteSpace = True

        'Columns root element and append it to the XML document.
        Set objReorder = objReorderDom.createElement("Reorder")
        objReorderDom.appendChild objReorder   

        nColIndex = 0
    
        FOR EACH currRowId IN RowIds
            Set objRow = objReorderDom.createElement("Row")

            'Create "Id" attribute
            Set objattRowIndex = objReorderDom.createAttribute("Id")
            objattRowIndex.Text = Trim(currRowId)
            objRow.setAttributeNode objattRowIndex
    
            'Set new value
            objRow.Text = Request("DT_RowId[" & Trim(currRowId) & "]")

            'Append "Column" element as a child container element "Columns".'
            objReorder.appendChild objRow
        NEXT
    
        'Create the xml processing instruction - and append to XML doc
        Set objReorderPI = objReorderDom.createProcessingInstruction("xml", "version='1.0'")
        objReorderDom.insertBefore objReorderPI, objReorderDom.childNodes(0)

        Dim sRowsReOrder
        sRowsReOrder = objReorderDom.selectSingleNode("/").xml
    
        SET rsItems = Server.CreateObject("ADODB.Command")
        rsItems.ActiveConnection = adoConnCrudeSrc
        rsItems.CommandText = "DECLARE @Dat XML = ?;" & vbCrLf & _
        " WITH RowData AS (" & vbCrLf & _
        " SELECT XX.x.value('(@Id)[1]','varchar(1000)') AS RowId, XX.x.value('(text())[1]','varchar(1000)') AS NewValue" & vbCrLf & _
        " FROM @Dat.nodes('/Reorder/Row') AS XX(X) )" & vbCrLf & _
        " UPDATE T SET [" & strRowReorderCol & "] = RowData.NewValue" & vbCrLf & _
        " FROM RowData INNER JOIN " & strMainTableName & " AS T" & vbCrLf & _
        " ON RowData.RowId = T.[" & strPrimaryKey & "]"

	    SET rsItems = rsItems.Execute (,sRowsReOrder,adOptionUnspecified)
    
        IF adoConnCrudeSrc.Errors.Count > 0 THEN
	        strError = "ERROR while trying to delete reorder rows using data source " & strDataSource & ":<br/>"
            For Each Err In adoConnCrudeSrc.Errors
		        strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & "<br/>"
            Next
        ELSE
            strMsgOutput = strMsgOutput & "Successfully Reordered: " & nItemID
        END IF

	    IF strError = "" Then
    	    adoConnCrudeSrc.Close
            adoConnCrude.Close
            'Response.Redirect(constPageScriptName & "?MSG=delete" & strViewQueryString)
        End If
    ELSE
        strError = "Invalid Input"
    END IF

    ' Write output in JSON
    
    IF strError <> "" THEN
        Response.Status = "500 Server Error"
        Response.Write "<div class='alert alert-danger'><h1><i class='fas fa-times-circle'></i> ERROR</h1>"
        Response.Write "<BR/>" & strError

    ELSE

        Response.Write "{ ""data"": """

        Response.Write "<div class='alert alert-success'><h1><i class='fas fa-check-circle'></i> SUCCESS</h1>"
        Response.Write "<BR/>" & Sanitizer.JSON(strMsgOutput)

        Response.Write "</div>"" }"
    
    END IF
    'END IF
ELSEIF strError = "" AND strMode = "dataviewcontents" AND Request("ViewID") <> "" AND IsNumeric(Request("ViewID")) THEN
    nItemID = Request("ViewID")

    strJsonOutput = ""
    
    SET cmdStoredProc = Server.CreateObject("ADODB.Command")
    cmdStoredProc.ActiveConnection = adoConnCrude
    cmdStoredProc.CommandText = "portal.GetDataViewContentsCommand"
    cmdStoredProc.CommandType = adCmdStoredProc  
    cmdStoredProc.Parameters.Refresh
    
	cmdStoredProc.Parameters(1).Value = nItemID

    ON ERROR RESUME NEXT
	
    SET rsItems = cmdStoredProc.Execute
	
    IF adoConnCrude.Errors.Count > 0 THEN
	    strError = "ERROR while trying to get dataview metadata:<br/>"
        For Each Err In adoConnCrude.Errors
		    strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
        Next
    ELSE
        IF NOT rsItems.EOF THEN
            strSQL = rsItems("Command")
            strDataSource = rsItems("DataSource")
        END IF
        rsItems.Close
    END IF
    
    IF strDataSource <> "" THEN
        adoConnCrudeSource = GetConfigValue("connectionStrings", "name", "connectionString", strDataSource, adoConStr)

        IF adoConnCrudeSource = "" THEN strError = GetWord("No connection string found for data source") & " " & strDataSource
    ELSE
        strError = GetWord("No Data Source specified!")
    END IF

    IF strError = "" THEN
        Set adoConnCrudeSrc = Server.CreateObject("ADODB.Connection")
        adoConnCrudeSrc.ConnectionString = adoConnCrudeSource
        adoConnCrudeSrc.CommandTimeout = 0

        ON ERROR RESUME NEXT

        adoConnCrudeSrc.Open

        IF adoConnCrudeSrc.Errors.Count > 0 THEN
	        strError = "ERROR while trying to open data source " & strDataSource & " for dataview:<br>"
            For Each Err In adoConnCrudeSrc.Errors
		        strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
            Next
        'ELSE
        '        Response.Write "<!-- Opened ConnString (" & strDataSource & ") " & adoConnCrudeSource & " -->" 
        END IF

        ON ERROR GOTO 0
    END IF

    SET cmdStoredProc = Nothing
    SET rsItems = Nothing
    
    IF strError = "" AND strSQL <> "" THEN
        SET rsItems = Server.CreateObject("ADODB.Recordset")
        rsItems.Open strSQL, adoConnCrudeSrc
        
        IF adoConnCrudeSrc.Errors.Count > 0 THEN
	        strError = "ERROR while running command at data source """ & strDataSource & """:<br/>"
            For Each Err In adoConnCrudeSrc.Errors
		        strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
            Next
        ELSE
            WHILE NOT rsItems.EOF
                strJsonOutput = strJsonOutput & rsItems("Json")
                rsItems.MoveNext  
            WEND

            rsItems.Close
        END IF
	END IF

    ON ERROR GOTO 0
	
    IF strJsonOutput = "" THEN strJsonOutput = "[ ]"

    IF strError <> "" THEN
        Response.Status = "500 Server Error"
        Response.Write strError
    ELSE
        Response.Write "{ ""data"": " & strJsonOutput
        Response.Write " }"
    END IF
ELSEIF strError = "" AND strMode = "datatable" THEN
    nItemID = Request("ViewID")
    
    Dim nDraw, recordsTotal, recordsFiltered, nLength, nRowIndex, nRowStart, blnRegExSearch, dtRowClass, strParams

    ' Draw must be returned as is to response
    nDraw = Request("draw")

    ' Length tells us how many rows max are expected in the response
    IF IsNumeric(Request("length")) AND Request("length") <> "" THEN
        nLength = CInt(Request("length"))
    ELSE
        nLength = 10
    END IF
    
    ' nRowStart would be the row index out of total rows, plus the requested offset (which is the "start" parameter)
    ' it must be limited by recordsFiltered
    IF IsNumeric(Request("start")) AND Request("start") <> "" THEN
        nRowStart = CInt(Request("start"))
    ELSE
        nRowStart = 0
    END IF
    
    IF Request("search[regex]") <> "" THEN
        blnRegExSearch = CBool(Request("search[regex]"))
    ELSE
        blnRegExSearch = False
    END IF

    recordsTotal = 0
    recordsFiltered = 0

    strJsonOutput = ""

    Dim objDom, objColumns, objColumn, objattRegEx, objattDataSrc, objattColIndex, objattName, objPI
    Dim nColIndex

    'Instantiate the Microsoft XMLDOM
    Set objDom = server.CreateObject("Microsoft.XMLDOM")
    objDom.preserveWhiteSpace = True

    'Columns root element and append it to the XML document.
    Set objColumns = objDom.createElement("Columns")
    objDom.appendChild objColumns   

    nColIndex = 1

    WHILE Request("columns[" & nColIndex & "][searchable]") <> ""
        Set objColumn = objDom.createElement("Column")

        'Create "ColIndex" attribute'
        Set objattColIndex = objDom.createAttribute("ColIndex")
        objattColIndex.Text = nColIndex
        objColumn.setAttributeNode objattColIndex
    
        'Create "Name" attribute'
        Set objattName = objDom.createAttribute("Name")
        objattName.Text = Request("columns[" & nColIndex & "][name]")
        objColumn.setAttributeNode objattName

        'Create "DataSrc" attribute'
        Set objattDataSrc = objDom.createAttribute("DataSrc")
        objattDataSrc.Text = Request("columns[" & nColIndex & "][data]")
        objColumn.setAttributeNode objattDataSrc

        'Create "RegEx" attribute'
        Set objattRegEx = objDom.createAttribute("RegEx")
        objattRegEx.Text = Request("columns[" & nColIndex & "][search][regex]")
        objColumn.setAttributeNode objattRegEx

        IF Request("columns[" & nColIndex & "][search][value]") <> "" THEN objColumn.Text = Request("columns[" & nColIndex & "][search][value]")

        'Append "Column" element as a child container element "Columns".'
        objColumns.appendChild objColumn

        nColIndex = nColIndex + 1
    WEND

    'Create the xml processing instruction - and append to XML doc
    Set objPI = objDom.createProcessingInstruction("xml", "version='1.0'")
    objDom.insertBefore objPI, objDom.childNodes(0)

    Dim sColumnsOptions
    sColumnsOptions = objDom.selectSingleNode("/").xml
    
    Dim objOrder, objattDirection

    'Instantiate the Microsoft XMLDOM
    Set objDom = server.CreateObject("Microsoft.XMLDOM")
    objDom.preserveWhiteSpace = True

    'Columns root element and append it to the XML document.
    Set objOrder = objDom.createElement("Order")
    objDom.appendChild objOrder   

    nColIndex = 0

    WHILE Request("order[" & nColIndex & "][column]") <> ""
        Set objColumn = objDom.createElement("Column")

        'Create "ColIndex" attribute'
        Set objattColIndex = objDom.createAttribute("ColIndex")
        objattColIndex.Text = Request("order[" & nColIndex & "][column]")
        objColumn.setAttributeNode objattColIndex
    
        'Create "Direction" attribute'
        Set objattDirection = objDom.createAttribute("Direction")
        objattDirection.Text = Request("order[" & nColIndex & "][dir]")
        objColumn.setAttributeNode objattDirection

        'Append "Column" element as a child container element "Columns".'
        objOrder.appendChild objColumn

        nColIndex = nColIndex + 1
    WEND

    'Create the xml processing instruction - and append to XML doc
    Set objPI = objDom.createProcessingInstruction("xml", "version='1.0'")
    objDom.insertBefore objPI, objDom.childNodes(0)

    Dim sColumnsOrder
    IF nColIndex > 0 THEN
        sColumnsOrder = objDom.selectSingleNode("/").xml
    ELSE
        sColumnsOrder = Null
    END IF

    SET cmdStoredProc = Server.CreateObject("ADODB.Command")
    cmdStoredProc.ActiveConnection = adoConnCrude
    cmdStoredProc.CommandText = "portal.GetDataViewDataTableCommand"
    cmdStoredProc.CommandType = adCmdStoredProc  
    cmdStoredProc.Parameters.Refresh
    
	cmdStoredProc.Parameters(1).Value = nItemID
	cmdStoredProc.Parameters(2).Value = nDraw
	cmdStoredProc.Parameters(3).Value = nRowStart
	cmdStoredProc.Parameters(4).Value = nLength
	cmdStoredProc.Parameters(5).Value = Request("search[value]")
	cmdStoredProc.Parameters(6).Value = blnRegExSearch
	cmdStoredProc.Parameters(7).Value = sColumnsOptions
	cmdStoredProc.Parameters(8).Value = sColumnsOrder

    ON ERROR RESUME NEXT
	
    SET rsItems = cmdStoredProc.Execute
	
    IF adoConnCrude.Errors.Count > 0 THEN
	    strError = "ERROR while trying to get datatable metadata:<br>"
        For Each Err In adoConnCrude.Errors
		    strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
        Next
    ELSE
        IF NOT rsItems.EOF THEN
            strSQL = rsItems("Command")
            strDataSource = rsItems("DataSource")
        ELSE
            strError = GetWord("Nothing Returned for ViewID") & " " & nItemID
        END IF
        rsItems.Close
    END IF
    
    IF strDataSource <> "" THEN
        adoConnCrudeSource = GetConfigValue("connectionStrings", "name", "connectionString", strDataSource, adoConStr)

        IF adoConnCrudeSource = "" THEN strError = GetWord("No connection string found for data source") & " " & strDataSource
    ELSEIF strError = "" THEN
        strError = GetWord("No Data Source specified!")
    END IF

    IF strError = "" THEN
        Set adoConnCrudeSrc = Server.CreateObject("ADODB.Connection")
        adoConnCrudeSrc.ConnectionString = adoConnCrudeSource
        adoConnCrudeSrc.CommandTimeout = 0

        ON ERROR RESUME NEXT

        adoConnCrudeSrc.Open

        IF adoConnCrudeSrc.Errors.Count > 0 THEN
	        strError = "ERROR while trying to open data source " & strDataSource & " for datatable:<br>(" & adoConnCrudeSource & ")"
            For Each Err In adoConnCrudeSrc.Errors
		        strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
            Next
        'ELSE
        '        Response.Write "<!-- Opened ConnString (" & strDataSource & ") " & adoConnCrudeSource & " -->" 
        END IF

        ON ERROR GOTO 0
    END IF

    'Response.Write vbCrLf & "DataSource: " & strDataSource & vbCrLf & "ConnString: " & adoConnCrudeSource & vbCrLf & "SQL: " & strSQL

    SET cmdStoredProc = Nothing
    SET rsItems = Nothing
    
    IF strError = "" AND strSQL <> "" THEN
        Dim paramColumnOptions, paramStart, paramLength, paramSearch

        SET cmdStoredProc = Server.CreateObject("ADODB.Command")
        cmdStoredProc.ActiveConnection = adoConnCrudeSrc
        cmdStoredProc.CommandText = strSQL
        'cmdStoredProc.CommandType = adCmdText

        'cmdStoredProc.Parameters.Append(cmdStoredProc.CreateParameter("@ColumnsOption", adVarWChar, , Len(sColumnsOptions) + 1, sColumnsOptions))
        'cmdStoredProc.Parameters.Append(cmdStoredProc.CreateParameter("@Start", adInteger, , , nRowStart))
        'cmdStoredProc.Parameters.Append(cmdStoredProc.CreateParameter("@Length", adInteger, , , nLength))
        'cmdStoredProc.Parameters.Append(cmdStoredProc.CreateParameter("@SearchValue", adVarWChar, , Len(Request("search[value]")) + 1, Request("search[value]")))
        Dim params(3)
        params(0) = sColumnsOptions
        params(1) = nRowStart
        params(2) = nLength
        params(3) = Request("search[value]")
        'cmdStoredProc.Parameters.Refresh
    
	    'cmdStoredProc.Parameters(1).Value = sColumnsOptions
	    'cmdStoredProc.Parameters(2).Value = nRowStart
	    'cmdStoredProc.Parameters(3).Value = nLength
	    'cmdStoredProc.Parameters(4).Value = Request("search[value]")

        ON ERROR RESUME NEXT
	
        SET rsItems = cmdStoredProc.Execute (,params,adOptionUnspecified)
        
        IF adoConnCrudeSrc.Errors.Count > 0 THEN
	        strError = "ERROR while trying to retrieve datatable:<br>"
            For Each Err In adoConnCrudeSrc.Errors
		        strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & "<br/>"
                IF globalIsAdmin THEN strError = strError & strSQL & "<br/>"
            Next
        ELSE
            ON ERROR GOTO 0

	        'Response.Write adoConnCrudeSource & "<br>"
	        'Response.Write strSQL & "<br><br>"

            IF NOT rsItems.EOF THEN
                recordsTotal = rsItems("recordsTotal")
                recordsFiltered = rsItems("recordsFiltered")

                SET rsItems = rsItems.NextRecordset
            END IF
            WHILE NOT rsItems.EOF
                strJsonOutput = strJsonOutput & rsItems("JsonData")
                rsItems.MoveNext  
            WEND

            rsItems.Close
        END IF
	END IF

    ON ERROR GOTO 0
	
    IF strJsonOutput = "" THEN strJsonOutput = "[ ]" 
    IF nDraw = "" THEN nDraw = 1

    Response.Write "{ ""draw"": " & nDraw & ", ""recordsTotal"": " & recordsTotal & ", ""recordsFiltered"": " & recordsFiltered & ", ""data"": " & strJsonOutput

    IF strError <> "" THEN Response.Write ", ""error"": """ &Sanitizer.JSON(strError) & """"

    Response.Write " }"
END IF

Set rsItems = Nothing
Set adoConnCrude = Nothing
%>