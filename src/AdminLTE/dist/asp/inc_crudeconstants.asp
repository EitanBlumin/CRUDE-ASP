<%
class DataViewLookupClassExtendable
    private dictProperties
    public Count
    
    public property Get UBound
        UBound = Count - 1
    end property
    
    public property Get Items
        SET Items = dictProperties.Items
    end property

    private sub Class_Initialize
        Count = 0
        Set dictProperties = Server.CreateObject("Scripting.Dictionary")
    end sub

    public default function GetProp(pKey)
	    IF NOT dictProperties.Exists(pKey) THEN
		    GetProp = Null
	    Else
		    GetProp = dictProperties.Item(pKey)
	    END IF	
    end function

    public sub SetProp(pKey, pItem)
	    IF NOT dictProperties.Exists(pKey) THEN
		    dictProperties.Add pKey, pItem
            Count = Count + 1
	    Else
		    SET dictProperties.Item(pKey) = pItem
	    END IF
    end sub

end class

class DataViewLookupClass
    public Value
    public Label
    public Glyph
    public DefaultValue
    public Tooltip
    public CSSClass
    public ShowText
    public ShowGlyph
    public Wrappers
    public Identifier
    
    public default function Init(pValue, pLabel)
        Value = pValue
        Label = pLabel
        SET Init = me
    end function

end class
    
class DataViewLookupCollectionClass
    private dictObj
    public Count
    
    public property Get UBound
        UBound = Count - 1
    end property
    
    public property Get Items
        Items = dictObj.Items
    end property
    
    public property Get Keys
        SET Keys = dictObj.Keys
    end property

    private sub Class_Initialize
        Count = 0
        Set dictObj = Server.CreateObject("Scripting.Dictionary")
    end sub

    public default function GetItem(pKey)

	    IF NOT dictObj.Exists(CStr(pKey)) THEN
		    SET GetItem = Nothing
	    Else
		    SET GetItem = dictObj.Item(CStr(pKey))
	    END IF	
    end function

    public sub AddItem(pKey, pItem)
	    IF NOT dictObj.Exists(CStr(pKey)) THEN
		    dictObj.Add CStr(pKey), pItem
            Count = Count + 1
	    Else
		    SET dictObj.Item(CStr(pKey)) = pItem
	    END IF
    end sub

end class

Dim luTmpObject, luTmpIndex

SET rsItems = Server.CreateObject("ADODB.Recordset")

'==============================
' Data View Flags
'==============================

Dim arrDataViewFlags
Const dvfValue = 0
Const dvfLabel = 1
Const dvfGlyph = 2
Const dvfDefault = 3

strSQL = "SELECT * FROM portal.DataViewFlags ORDER BY FlagValue ASC; " & vbCrLf & _
         "SELECT * FROM portal.DataViewDataTableFlags ORDER BY FlagValue ASC; " & vbCrLf & _
         "SELECT * FROM portal.DataViewModifierButtonStyles ORDER BY StyleValue ASC; " & vbCrLf & _
         "SELECT * FROM portal.DataViewPagingTypes ORDER BY StyleValue ASC; " & vbCrLf & _
         "SELECT * FROM portal.DataViewFieldFlags ORDER BY FlagValue ASC; " & vbCrLf & _
         "SELECT * FROM portal.DataViewFieldTypes ORDER BY TypeValue ASC;" & vbCrLf & _
         "SELECT * FROM portal.DataViewUriStyles ORDER BY StyleValue ASC; "
rsItems.Open strSQL, adoConnCrudeStr

arrDataViewFlags = rsItems.GetRows()

SET rsItems = rsItems.NextRecordset()

Dim luDataViewFlags
SET luDataViewFlags = new DataViewLookupCollectionClass
FOR luTmpIndex = 0 TO UBound(arrDataViewFlags, 2)
    SET luTmpObject = (new DataViewLookupClass)(arrDataViewFlags(dvfValue, luTmpIndex), arrDataViewFlags(dvfLabel, luTmpIndex))
    luTmpObject.Glyph = arrDataViewFlags(dvfGlyph, luTmpIndex)
    luTmpObject.DefaultValue = arrDataViewFlags(dvfDefault, luTmpIndex)

    luDataViewFlags.AddItem arrDataViewFlags(dvfValue, luTmpIndex), luTmpObject
NEXT

SET luTmpObject = Nothing

'==============================
' Data Table Flags
'==============================

Dim arrDataTableFlags
Const dtfValue = 0
Const dtfLabel = 1
Const dtfTooltip = 2
Const dtfGlyph = 3
Const dtfDefault = 4

arrDataTableFlags = rsItems.GetRows()
    
SET rsItems = rsItems.NextRecordset()
    
Dim luDataTableFlags
SET luDataTableFlags = new DataViewLookupCollectionClass
FOR luTmpIndex = 0 TO UBound(arrDataTableFlags, 2)
    SET luTmpObject = (new DataViewLookupClass)(arrDataTableFlags(dtfValue, luTmpIndex), arrDataTableFlags(dtfLabel, luTmpIndex))
    luTmpObject.Tooltip = arrDataTableFlags(dtfTooltip, luTmpIndex)
    luTmpObject.Glyph = arrDataTableFlags(dtfGlyph, luTmpIndex)
    luTmpObject.DefaultValue = arrDataTableFlags(dtfDefault, luTmpIndex)

    luDataTableFlags.AddItem arrDataTableFlags(dtfValue, luTmpIndex), luTmpObject
NEXT

SET luTmpObject = Nothing

'==============================
' Data Table Button Styles
'==============================

Dim arrDataTableModifierButtonStyles
Const dtbsValue = 0
Const dtbsLabel = 1
Const dtbsClass = 2
Const dtbsShowText = 3
Const dtbsShowGlyph = 4
Const dtbsDefault = 5

arrDataTableModifierButtonStyles = rsItems.GetRows()
    
SET rsItems = rsItems.NextRecordset()
    
Dim luDataTableModifierButtonStyles
SET luDataTableModifierButtonStyles = new DataViewLookupCollectionClass
FOR luTmpIndex = 0 TO UBound(arrDataTableModifierButtonStyles, 2)
    SET luTmpObject = (new DataViewLookupClass)(arrDataTableModifierButtonStyles(dtbsValue, luTmpIndex), arrDataTableModifierButtonStyles(dtbsLabel, luTmpIndex))
    luTmpObject.CSSClass = arrDataTableModifierButtonStyles(dtbsClass, luTmpIndex)
    luTmpObject.ShowText = arrDataTableModifierButtonStyles(dtbsShowText, luTmpIndex)
    luTmpObject.ShowGlyph = arrDataTableModifierButtonStyles(dtbsShowGlyph, luTmpIndex)
    luTmpObject.DefaultValue = arrDataTableModifierButtonStyles(dtbsDefault, luTmpIndex)

    luDataTableModifierButtonStyles.AddItem arrDataTableModifierButtonStyles(dtbsValue, luTmpIndex), luTmpObject
NEXT

SET luTmpObject = Nothing
    
'==============================
' Data Table Paging Styles
'==============================

Dim arrDataTablePagingStyles
Const dtpsValue = 0
Const dtpsLabel = 1
Const dtpsDefault = 2

arrDataTablePagingStyles = rsItems.GetRows()
    
SET rsItems = rsItems.NextRecordset()

Dim luDataTablePagingStyles
SET luDataTablePagingStyles = new DataViewLookupCollectionClass
FOR luTmpIndex = 0 TO UBound(arrDataTablePagingStyles, 2)
    SET luTmpObject = (new DataViewLookupClass)(arrDataTablePagingStyles(dtpsValue, luTmpIndex), arrDataTablePagingStyles(dtpsLabel, luTmpIndex))
    luTmpObject.DefaultValue = arrDataTablePagingStyles(dtpsDefault, luTmpIndex)

    luDataTablePagingStyles.AddItem arrDataTablePagingStyles(dtpsValue, luTmpIndex), luTmpObject
NEXT

SET luTmpObject = Nothing
    
'==============================
' Data View Field Flags
'==============================

Dim arrDataViewFieldFlags
Const dvffValue = 0
Const dvffLabel = 1
Const dvffGlyph = 2
Const dvffDefault = 3

arrDataViewFieldFlags = rsItems.GetRows()
    
SET rsItems = rsItems.NextRecordset()

Dim luDataViewFieldFlags
SET luDataViewFieldFlags = new DataViewLookupCollectionClass
FOR luTmpIndex = 0 TO UBound(arrDataViewFieldFlags, 2)
    SET luTmpObject = (new DataViewLookupClass)(arrDataViewFieldFlags(dvffValue, luTmpIndex), arrDataViewFieldFlags(dvffLabel, luTmpIndex))
    luTmpObject.Glyph = arrDataViewFieldFlags(dvffGlyph, luTmpIndex)
    luTmpObject.DefaultValue = arrDataViewFieldFlags(dvffDefault, luTmpIndex)

    luDataViewFieldFlags.AddItem arrDataViewFieldFlags(dvffValue, luTmpIndex), luTmpObject
NEXT

SET luTmpObject = Nothing

'==============================
' Data View Field Types
'==============================

Dim arrDataViewFieldTypes
Const dvftValue = 0
Const dvftLabel = 1
Const dvftWrappers = 2
Const dvftIdentifier = 3

arrDataViewFieldTypes = rsItems.GetRows()
    
SET rsItems = rsItems.NextRecordset()

Dim luDataViewFieldTypes
SET luDataViewFieldTypes = new DataViewLookupCollectionClass
FOR luTmpIndex = 0 TO UBound(arrDataViewFieldTypes, 2)
    SET luTmpObject = (new DataViewLookupClass)(arrDataViewFieldTypes(dvftValue, luTmpIndex), arrDataViewFieldTypes(dvftLabel, luTmpIndex))
    luTmpObject.Wrappers = arrDataViewFieldTypes(dvftWrappers, luTmpIndex)
    luTmpObject.Identifier = arrDataViewFieldTypes(dvftIdentifier, luTmpIndex)
    'Response.Write "DV Field Type: " & arrDataViewFieldTypes(dvftValue, luTmpIndex) & " (" & luTmpObject.Label & ")<br>" & vbCrLf
    luDataViewFieldTypes.AddItem arrDataViewFieldTypes(dvftValue, luTmpIndex), luTmpObject
NEXT

SET luTmpObject = Nothing
    
'==============================
' Uri Link Styles
'==============================

Dim arrDataViewUriStyles
Const dvusValue = 0
Const dvusLabel = 1
Const dvusClass = 2
Const dvusGlyph = 3
Const dvusDefault = 4

arrDataViewUriStyles = rsItems.GetRows()
    
SET rsItems = rsItems.NextRecordset()
    
Dim luDataViewUriStyles
SET luDataViewUriStyles = new DataViewLookupCollectionClass
FOR luTmpIndex = 0 TO UBound(arrDataTableModifierButtonStyles, 2)
    SET luTmpObject = (new DataViewLookupClass)(arrDataViewUriStyles(dvusValue, luTmpIndex), arrDataViewUriStyles(dvusLabel, luTmpIndex))
    luTmpObject.CSSClass = arrDataViewUriStyles(dvusClass, luTmpIndex)
    luTmpObject.Glyph = arrDataViewUriStyles(dvusGlyph, luTmpIndex)
    luTmpObject.DefaultValue = arrDataViewUriStyles(dvusDefault, luTmpIndex)

    luDataViewUriStyles.AddItem arrDataViewUriStyles(dvusValue, luTmpIndex), luTmpObject
NEXT

SET luTmpObject = Nothing
    
'==============================
' Data View Field Columns
'==============================

Const dvfcViewID = 0
Const dvfcFieldID = 1
Const dvfcFieldLabel = 2
Const dvfcFieldSource = 3
Const dvfcFieldType = 4
Const dvfcFieldFlags = 5
Const dvfcFieldOrder = 6
Const dvfcDefaultValue = 7
Const dvfcMaxLength = 8
Const dvfcUriPath = 9
Const dvfcUriStyle = 10
Const dvfcLinkedTable = 11
Const dvfcLinkedTableGroupField = 12
Const dvfcLinkedTableTitleField = 13
Const dvfcLinkedTableValueField = 14
Const dvfcLinkedTableAddition = 15
Const dvfcWidth = 16
Const dvfcHeight = 17
Const dvfcFieldDescription = 18
    
FUNCTION InitDataViewFields (pViewID, pDBConnection)
    Dim tmpCollection, tmpObj, tmpColumn, tmpIndex, tmpRs

    SET tmpCollection = new DataViewLookupCollectionClass

    IF pViewID <> "" AND IsNumeric(pViewID) THEN
        SET tmpRs = Server.CreateObject("ADODB.Command")
        tmpRs.ActiveConnection = pDBConnection
        tmpRs.CommandText = "SELECT * FROM portal.DataViewField WHERE ViewID = ? ORDER BY FieldOrder ASC"
    
        SET tmpRs = tmpRs.Execute (,pViewID,adOptionUnspecified)

        'tmpRs.Open "SELECT * FROM portal.DataViewField WHERE ViewID = " & pViewID & " ORDER BY FieldOrder ASC", pDBConnection
        tmpIndex = 0
        WHILE NOT tmpRs.EOF
            SET tmpObj = new DataViewLookupClassExtendable

            For Each tmpColumn IN tmpRs.Fields
                tmpObj.SetProp tmpColumn.Name, tmpColumn.Value
            Next

            tmpCollection.AddItem tmpIndex, tmpObj
            tmpIndex = tmpIndex + 1

		    tmpRs.MoveNext()
        WEND
        tmpRs.Close
        SET tmpRs = Nothing
    END IF

    SET InitDataViewFields = tmpCollection
END FUNCTION

FUNCTION InitDataViewActions (pViewID, pIsInline, pDBConnection)
    Dim tmpCollection, tmpObj, tmpColumn, tmpIndex, tmpRs, tmpParams(1)
    tmpParams(0) = pViewID
    tmpParams(1) = CBool(pIsInline)
    SET tmpCollection = new DataViewLookupCollectionClass

    IF pViewID <> "" AND IsNumeric(pViewID) THEN
        SET tmpRs = Server.CreateObject("ADODB.Command")
        tmpRs.ActiveConnection = pDBConnection
        tmpRs.CommandText = "SELECT * FROM portal.DataViewAction WHERE ViewID = ? AND IsPerRow = ? ORDER BY ParentActionID ASC, ActionOrder ASC"
        SET tmpRs = tmpRs.Execute (,tmpParams,adOptionUnspecified)

        tmpIndex = 0
        WHILE NOT tmpRs.EOF
            SET tmpObj = new DataViewLookupClassExtendable

            For Each tmpColumn IN tmpRs.Fields
                tmpObj.SetProp tmpColumn.Name, tmpColumn.Value
            Next

            tmpCollection.AddItem tmpIndex, tmpObj
            tmpIndex = tmpIndex + 1

		    tmpRs.MoveNext()
        WEND
        tmpRs.Close
        SET tmpRs = Nothing
    END IF

    SET InitDataViewActions = tmpCollection
END FUNCTION

SET rsItems = Server.CreateObject("ADODB.Recordset")

%>