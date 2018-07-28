<%
' Create language dictionary
' ============================
Dim dictLang
Set dictLang = Server.CreateObject("Scripting.Dictionary")

' Function to create dictionary word
SUB SetWord(ByVal strKey, ByVal strValue)
	IF NOT dictLang.Exists(strKey) THEN
		dictLang.Add strKey, strValue
	Else
		dictLang.Item(strKey) = strValue
	END IF
END SUB

' Function to get dictionary word
FUNCTION GetWord(strKey)	
	Dim strValue
	IF NOT dictLang.Exists(strKey) THEN
		strValue = strKey
	Else
		strValue = dictLang.Item(strKey)
	END IF	
	GetWord = strValue
END FUNCTION

' Initialise dictionary
SetWord "SaveChanges", 	"Save Changes"
SetWord "SearchBtn",	"Search >>"
SetWord "ResetForm",	"Reset" 
SetWord "ItemNotFound", "Item Not Found"
SetWord "NoItemsFound", "No items found"
SetWord "CantDisplayWithoutFilter", "Cannot display data without specifying filter"
SetWord "ItemUpdated", 	"Item Successfully Updated"
SetWord "ItemDeleted", 	"Item Successfully Deleted"
SetWord "ItemAdded",	"New Item Added"
SetWord "AreYouSure",   "Are you sure?"
SetWord "AreYouSureDelete", "Are you sure you want to delete?"
SetWord "HoldCtrlForMultiValue", "<br/>* You can hold Ctrl to select multiple items"
SetWord "OUName",       "Organization"
SetWord "ServerName",   "Server Name"
SetWord "ObjectName",   "Title"
SetWord "ErrorDescription", "Description" 
SetWord "LastRunDate",  "Last Run Date"
SetWord "SinceStartDate", "Active Since"
SetWord "ActionSuccessful", "Action Completed Successfully"

'==================================================================
'			DisplayLookupSelection
'			----------------------
' Usage:
' <select name="mycombo">
' <% DisplayLookupSelection "DBTableName", "DBValueCol", "DBIdentCol", valSelectedIdent, "strOrderBy" % >
' </select>
'==================================================================
SUB DisplayLookupSelection(ByVal DBTableName, ByVal DBValueCol, ByVal DBIdentCol, ByVal valSelectedIdent, ByVal strOrderBy)
	
	IF IsNull(valSelectedIdent) THEN valSelectedIdent = ""
	
	Dim sql, rs
	sql = "SELECT DISTINCT " & DBValueCol & " AS listvalue, ISNULL(" & DBIdentCol & ",'') AS listid FROM " & DBTableName & " " & strOrderBy
	SET rs = Server.CreateObject("ADODB.Recordset")
	rs.Open sql, adoConn
	
	WHILE NOT rs.EOF
	%>
	<option value="<%= rs("listid") %>" <% IF CStr(valSelectedIdent) = CStr(rs("listid")) THEN Response.Write("selected") %>><%= rs("listvalue") %></option>
	<%
		rs.MoveNext
	WEND
	rs.Close
	SET rs = Nothing

END SUB

' Function to pad numeric values with zeros
FUNCTION pd(n, totalDigits) 
    IF totalDigits > len(n) THEN 
        pd = String(totalDigits-len(n),"0") & n 
    ELSE 
        pd = n 
    END IF 
END FUNCTION

FUNCTION FormatDateForDB(dt)
    FormatDateForDB = YEAR(dt) & "-" & Pd(Month(dt),2) & "-" & Pd(DAY(dt),2) & " " & Pd(Hour(dt),2) & ":" & Pd(Minute(dt),2) & ":" & Pd(Second(dt),2)
END FUNCTION

CLASS SanitizerClass

    PUBLIC FUNCTION HTMLFormControl(pInput)
        IF IsNull(pInput) THEN pInput = ""
        HTMLFormControl = Server.HTMLEncode(pInput)
    END FUNCTION
 
    PUBLIC FUNCTION HTMLDisplay(pInput)
        IF IsNull(pInput) THEN pInput = ""
        IF NOT globalIsAdmin THEN
            HTMLDisplay = Server.HTMLEncode(pInput)
        ELSE
            HTMLDisplay = pInput
        END IF
    END FUNCTION
        
    PUBLIC FUNCTION Querystring(pInput)
        IF IsNull(pInput) THEN pInput = ""
        Querystring = Server.URLEncode(pInput)
    END FUNCTION
        
    PUBLIC FUNCTION SQL(pInput)
        IF IsNull(pInput) THEN
            SQL = "NULL"
        ELSE
            SQL = REPLACE(pInput, "'", "''")
        END IF
    END FUNCTION

END CLASS

Dim Sanitizer
Set Sanitizer = New SanitizerClass

%>