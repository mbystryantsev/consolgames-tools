Attribute VB_Name = "Модуль1"
Public FileG As String

Public ris As Boolean
Public Type FontHeader
    H As Byte
    Bpp As Byte
    PCount As Integer
End Type
Public Head As FontHeader
Public tmpLine(15)

Public Imported As Boolean

Public lng As Language
Public Type Language
    lAbout As String
    lFileOpening As String
    lFileSaving As String
    lFileExporting As String
    lFileImporting As String
    lAllFiles As String
    lWidth As String
End Type
Public Lang As Boolean
Public ppnt() As Long
Public Opened As Boolean
Public Coped As Boolean

Public Buffer(15, 15) As Byte
Public Temp(15, 15) As Byte
Public BufW As Byte

Public Type PointColor
    c(3) As Long
    b(1) As Long
End Type
Public Clr As PointColor

'Public TileCount
Public T(1023, 15, 15) As Byte
Public Type vbTile
    Bpp(1023) As Byte
    W(1023) As Byte
End Type
Public Tile As vbTile
    

Public ptr As pointers
Public Type pointers
    PBegin As Long
    Pcnt As Integer
    Ncnt As Integer
    nbr() As Long
    pnt() As Long
End Type

Public fsz As Long

Public Function Get1(InByte As Byte, num As Integer) As Byte
Dim bt As String
Dim InB As Byte
InB = InByte
For n = 0 To 7
    If InB / 2 = InB \ 2 Then bt = "0" & bt Else bt = "1" & bt
    InB = InB \ 2
Next n
Get1 = Val(Mid(bt, 9 - num, 1))
End Function

Public Function Get2(InByte As Byte, num As Integer) As Byte
Dim bt As String
Dim InB As Byte
InB = InByte
For n = 0 To 7
    If InB / 2 = InB \ 2 Then bt = "0" & bt Else bt = "1" & bt
    InB = InB \ 2
Next n
If Mid(bt, 9 - num * 2, 2) = "00" Then
    Get2 = 0
ElseIf Mid(bt, 9 - num * 2, 2) = "01" Then
    Get2 = 1
ElseIf Mid(bt, 9 - num * 2, 2) = "10" Then
    Get2 = 2
Else
    Get2 = 3
End If
    
End Function

Public Sub SetP(X, Y, SetColor)
Form1.p(X + Y * 16).BackColor = Clr.c(SetColor)
T(Form1.List.ListIndex, X, Y) = SetColor
End Sub

Public Function Oc(InP)
If InP / 8 = InP \ 8 Then Oc = InP Else Oc = 8 * (Int(InP / 8 + 0.99))
If Oc = 0 Then Oc = 8
End Function

Public Function Fo(InP)
If InP / 4 = InP \ 4 Then Fo = InP Else Fo = 4 * (Int(InP / 4 + 0.99))
If Fo = 0 Then Fo = 4
End Function

Public Function Kr(InP, KrN)
On Error GoTo Er:
If InP / KrN = InP \ KrN Then Kr = InP Else Kr = KrN * (Int(InP / KrN + 0.99))
If Kr = 0 Then Kr = KrN
Exit Function
Er:
MsgBox "Error!"
End Function
Public Function Kr2(InP, KrN)
If InP / KrN = InP \ KrN Then Kr2 = InP Else Kr2 = KrN * (Int(InP / KrN))
End Function
Public Sub LoadTile(ID)
Dim n As Byte
Dim l As Byte
For n = 0 To 15
    For l = 0 To 15
        Call SetP(n, l, T(ID, n, l))
    Next l
Next n
End Sub

Public Function GetByte(GBt) As Byte
For n = 8 To 1 Step -1
    If Mid(GBt, n, 1) = 1 Then GetByte = GetByte + 2 ^ (8 - n)
Next n
End Function

Public Function DB(GB)
If GB = 0 Then DB = "00" Else If GB = 1 Then DB = "01" Else If GB = 2 Then DB = "10" Else DB = "11"
End Function
