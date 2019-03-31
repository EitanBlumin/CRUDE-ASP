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

FUNCTION isIsoDate(s_input)
    dim obj_regex

    isIsoDate = false
    if len(s_input) > 9 then ' basic check before creating RegExp
        set obj_regex = new RegExp
        obj_regex.Pattern = "^\d{4}\-\d{2}\-\d{2}(T\d{2}:\d{2}:\d{2}(Z|\+\d{4}|\-\d{4})?)?$"
        if obj_regex.Test(s_input) then
            on error resume next
            isIsoDate = not IsEmpty(CIsoDate(s_input))
            on error goto 0
        end if
        set obj_regex = nothing
    end if
END FUNCTION

' ----------------------------------------------------------------------------------------
FUNCTION CIsoDate(s_input)
    CIsoDate = CDate(replace(Mid(s_input, 1, 19) , "T", " "))
END FUNCTION

FUNCTION AutoFormatLabels(colName)
    Dim strLabel, regEx
    Set regEx = New RegExp

    ' BB code urls
    With regEx
        .Pattern = "([^A-Za-z0-9\.\$])|([A-Z])(?=[A-Z][a-z])|([^\-\$\.0-9])(?=\$?[0-9]+(?:\.[0-9]+)?)|([0-9])(?=[^\.0-9])|([a-z])(?=[A-Z])"
        .IgnoreCase = False
        .Global = True
        .MultiLine = True
    End With

    strLabel = regEx.Replace(colName, "$2$3$4$5 ")

    set regEx = nothing
    AutoFormatLabels = strLabel
END FUNCTION

' This class object would hold a collection of functions to sanitize input/output
CLASS SanitizerClass
    Private m_RegExp
        
    private sub Class_Initialize
        Set m_RegExp = New RegExp
    end sub

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
        
    ' Sanitize values that would be put inside JSON strings
    PUBLIC FUNCTION JSON(ByVal Str)
        Dim Parts(): ReDim Parts(3)
        Dim NextPartIndex: NextPartIndex = 0
        Dim AnchorIndex: AnchorIndex = 1
        Dim CharCode, Escaped
        Dim Match, MatchIndex
        Dim RegExp: Set RegExp = m_RegExp
        If RegExp Is Nothing Then
            Set RegExp = New RegExp
            Set m_RegExp = RegExp
        End If
        
        ' See https://github.com/douglascrockford/JSON-js/blob/43d7836c8ec9b31a02a31ae0c400bdae04d3650d/json2.js#L196
        RegExp.Pattern = "[\\\""\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]"
        RegExp.Global = True

        IF IsNull(Str) THEN
            JSON = "": Exit Function
        END IF

        For Each Match In RegExp.Execute(Str)
            MatchIndex = Match.FirstIndex + 1
            If NextPartIndex > UBound(Parts) Then ReDim Preserve Parts(UBound(Parts) * 2)
            Parts(NextPartIndex) = Mid(Str, AnchorIndex, MatchIndex - AnchorIndex): NextPartIndex = NextPartIndex + 1
            CharCode = AscW(Mid(Str, MatchIndex, 1))
            Select Case CharCode
                Case 34  : Escaped = "\"""
                Case 10  : Escaped = "\n"
                Case 13  : Escaped = "\r"
                Case 92  : Escaped = "\\"
                Case 8   : Escaped = "\b"
                Case Else: Escaped = "\u" & Right("0000" & Hex(CharCode), 4)
            End Select
            If NextPartIndex > UBound(Parts) Then ReDim Preserve Parts(UBound(Parts) * 2)
            Parts(NextPartIndex) = Escaped: NextPartIndex = NextPartIndex + 1
            AnchorIndex = MatchIndex + 1
        Next
        If AnchorIndex = 1 Then JSON = Str: Exit Function
        If NextPartIndex > UBound(Parts) Then ReDim Preserve Parts(UBound(Parts) * 2)
        Parts(NextPartIndex) = Mid(Str, AnchorIndex): NextPartIndex = NextPartIndex + 1
        ReDim Preserve Parts(NextPartIndex - 1)
        JSON = Join(Parts, "")
    END FUNCTION

END CLASS

Dim Sanitizer
Set Sanitizer = New SanitizerClass

%>