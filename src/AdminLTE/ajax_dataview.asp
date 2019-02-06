<%@ LANGUAGE="VBSCRIPT" CODEPAGE="1255" %>
<!--#include file="dist/asp/inc_config.asp" -->
<%' use this meta tag instead of adovbs.inc%>
<!--METADATA TYPE="typelib" uuid="00000205-0000-0010-8000-00AA006D2EA4" -->
<%
Response.CodePage = 65001
Session.CodePage = 65001
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
Dim strMode, adoConnSrc, adoConnSource, cmdStoredProc, nItemID, nIndex, blnFound, nColSpan, blnRequiredFieldsFilled, strFormIDString
Dim blnRTEEnabled, blnShowForm, blnShowList, blnAllowUpdate, blnAllowInsert, blnAllowDelete, blnAllowClone, blnAllowSearch, strOrderBy, strSearchFilter, strCurrFilter
Dim strLastOptGroup, blnOptGroupStarted, strJsonOutput
Set rsItems = Server.CreateObject("ADODB.Recordset")
strMode = Request("mode")

Dim myRegEx
SET myRegEx = New RegExp
myRegEx.IgnoreCase = True
myRegEx.Global = True
    
IF (strMode = "add" OR strMode = "edit") AND Request.Form <> "" THEN
    Dim bytecount, bytes, stream, jsonPayload

    bytecount = Request.TotalBytes
    bytes = Request.BinaryRead(bytecount)

    Set stream = Server.CreateObject("ADODB.Stream")
    stream.Type = 1    ' adTypeBinary              
    stream.Open()
    stream.Write(bytes)
    stream.Position = 0                             
    stream.Type = 2   ' adTypeText                
    stream.Charset = "utf-8"
    Set jsonPayload = stream.ReadText()
    stream.Close()
    'Response.Write jsonPayload  
END IF

adoConn.Open

IF strMode = "dataviewcontents" AND Request("ViewID") <> "" AND IsNumeric(Request("ViewID")) THEN
    nItemID = Request("ViewID")

    strJsonOutput = ""

    SET cmdStoredProc = Server.CreateObject("ADODB.Command")
    cmdStoredProc.ActiveConnection = adoConn
    cmdStoredProc.CommandText = "portal.GetDataViewContentsCommand"
    cmdStoredProc.CommandType = adCmdStoredProc  
    cmdStoredProc.Parameters.Refresh
    
	cmdStoredProc.Parameters(1).Value = nItemID

    ON ERROR RESUME NEXT
	
    SET rsItems = cmdStoredProc.Execute
	
    IF Err.Number <> 0 THEN
	    strError = "ERROR at " & Err.Source & ":<br>" & REPLACE(Err.Description, """", "\""")
    ELSE
        IF NOT rsItems.EOF THEN
            strSQL = rsItems("Command")
            adoConnSource = GetConfigValue("connectionStrings", "name", "connectionString", rsItems("DataSource"), adoConStr)
        END IF
        rsItems.Close
    END IF
    
    Set adoConnSrc = Server.CreateObject("ADODB.Connection")
    adoConnSrc.ConnectionString = adoConnSource
    adoConnSrc.CommandTimeout = 0
    adoConnSrc.Open

    IF strError = "" AND strSQL <> "" THEN
        SET rsItems = Nothing
        SET rsItems = Server.CreateObject("ADODB.Recordset")
        rsItems.Open strSQL, adoConnSrc
        
        IF Err.Number <> 0 THEN
	        strError = "ERROR at " & Err.Source & ":<br>" & REPLACE(Err.Description, """", "\""") 
        ELSE
            WHILE NOT rsItems.EOF
                strJsonOutput = strJsonOutput & rsItems("Json")
                rsItems.MoveNext  
            WEND

            rsItems.Close
        END IF
	END IF
    ON ERROR GOTO 0
	
    SET cmdStoredProc = Nothing
    
    IF strJsonOutput = "" THEN strJsonOutput = "[ ]" 

    Response.Write "{ ""data"": " & strJsonOutput

    IF strError <> "" THEN Response.Write ", ""error"": """ & strError & """"

    Response.Write " }"
END IF

Set rsItems = Nothing
adoConn.Close
Set adoConn = Nothing
%>