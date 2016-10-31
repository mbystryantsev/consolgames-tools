Attribute VB_Name = "Module1"
Public FName                                As String
Public FPath                                As String
Public pos                                  As Long
Public bte                                  As Byte
Public FLen                                 As Long
Public lin As String

Public Function DoLog(txt As String)
    Form1.Log = Form1.Log & txt & vbCrLf
End Function
