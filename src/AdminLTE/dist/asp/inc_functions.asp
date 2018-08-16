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

'==================================================================
'           Miscelleneous Helper Functions
'==================================================================

' Function to return the page title to be used as the browser window/tab title
FUNCTION GetPageTitle()

        GetPageTitle = Sanitizer.HTMLFormControl(strPageTitle) & " | " & Sanitizer.HTMLFormControl(constPortalTitle)

END FUNCTION


'==================================================================
'			Utility Sanitizer Functions
'==================================================================

' Function to pad numeric values with zeros
FUNCTION pd(n, totalDigits) 
    IF totalDigits > len(n) THEN 
        pd = String(totalDigits-len(n),"0") & n 
    ELSE 
        pd = n 
    END IF 
END FUNCTION

' Function to format a datetime value to be edible by database
FUNCTION FormatDateForDB(dt)
    FormatDateForDB = YEAR(dt) & "-" & Pd(Month(dt),2) & "-" & Pd(DAY(dt),2) & " " & Pd(Hour(dt),2) & ":" & Pd(Minute(dt),2) & ":" & Pd(Second(dt),2)
END FUNCTION

' This class object would hold a collection of functions to sanitize input/output
CLASS SanitizerClass

    ' Sanitize values that would be put inside HTML elements (for example <input ... value="value here"> or <textarea...>value here</textarea>)
    PUBLIC FUNCTION HTMLFormControl(pInput)
        IF IsNull(pInput) THEN pInput = ""
        HTMLFormControl = Server.HTMLEncode(pInput)
    END FUNCTION
 
    ' Sanitize values that would be visibly displayed to users (for example <p>value here</p> or <div>value here</div>)
    PUBLIC FUNCTION HTMLDisplay(pInput)
        IF IsNull(pInput) THEN pInput = ""
        IF NOT globalIsAdmin THEN
            HTMLDisplay = Server.HTMLEncode(pInput)
        ELSE
            HTMLDisplay = pInput
        END IF
    END FUNCTION
        
    ' Sanitize values that would be used as part of a URL querystring
    PUBLIC FUNCTION Querystring(pInput)
        IF IsNull(pInput) THEN pInput = ""
        Querystring = Server.URLEncode(pInput)
    END FUNCTION
        
    ' Sanitize values that would be used in SQL injection
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