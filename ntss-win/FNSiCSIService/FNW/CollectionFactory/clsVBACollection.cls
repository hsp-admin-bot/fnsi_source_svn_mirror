VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsVBACollection"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' VBA.CollectionçÏê¨
Public Function CreateVBACollection() As Collection

   ' Define a variable of type Collection.
   Dim col As Collection

   ' Create a Collection object.
   Set col = New Collection

   ' Return the Collection object.
   Set CreateVBACollection = col
End Function

' CollectionÇ…ItemÇí«â¡
Public Function AddObject(objCol As VBA.Collection, objItem As Object)

    objCol.Add objItem

End Function

Public Function AddObject2(objCol As VBA.Collection, objItem As Object, objKey As Object)

    objCol.Add objItem, objKey

End Function

Public Function AddObject3(objCol As VBA.Collection, objItem As Object, objKey As Object, objBefore As Object)

    objCol.Add objItem, objKey, objBefore

End Function

Public Function AddObject4(objCol As VBA.Collection, objItem As Object, objKey As Object, objBefore As Object, objAfter As Object)

    objCol.Add objItem, objKey, objBefore, objAfter

End Function

Public Function AddObjectArray(objCol As VBA.Collection, objItem() As Variant)

    objCol.Add objItem

End Function

Public Function RemoveObject(objCol As VBA.Collection, objKey As Object)

    objCol.Remove objKey

End Function

Public Function ClearVBACollection(objCol As VBA.Collection)

    Set objCol = Nothing
    Set objCol = New Collection

End Function

