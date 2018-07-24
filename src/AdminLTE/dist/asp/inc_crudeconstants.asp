<%
SET rsItems = Server.CreateObject("ADODB.Recordset")

'==============================
' Data View Flags
'==============================

Dim arrDataViewFlags
Const dvfValue = 0
Const dvfLabel = 1
Const dvfGlyph = 2
Const dvfDefault = 3

strSQL = "SELECT * FROM portal.DataViewFlags ORDER BY FlagValue ASC"
rsItems.Open strSQL, adoConn

arrDataViewFlags = rsItems.GetRows()

rsItems.Close

'==============================
' Data View Field Flags
'==============================

Dim arrDataViewFieldFlags
Const dvffValue = 0
Const dvffLabel = 1
Const dvffGlyph = 2
Const dvffDefault = 3

strSQL = "SELECT * FROM portal.DataViewFieldFlags ORDER BY FlagValue ASC"
rsItems.Open strSQL, adoConn

arrDataViewFieldFlags = rsItems.GetRows()

rsItems.Close

'==============================
' Data View Field Types
'==============================

Dim arrDataViewFieldTypes
Const dvftValue = 0
Const dvftLabel = 1
Const dvftWrappers = 2

strSQL = "SELECT * FROM portal.DataViewFieldTypes ORDER BY TypeValue ASC"
rsItems.Open strSQL, adoConn

arrDataViewFieldTypes = rsItems.GetRows()

rsItems.Close
    
'==============================
' Uri Link Styles
'==============================

Dim arrDataViewUriStyles
Const dvusValue = 0
Const dvusLabel = 1
Const dvusGlyph = 2
Const dvusDefault = 3

strSQL = "SELECT * FROM portal.DataViewUriStyles ORDER BY StyleValue ASC"
rsItems.Open strSQL, adoConn

arrDataViewUriStyles = rsItems.GetRows()

rsItems.Close

%>