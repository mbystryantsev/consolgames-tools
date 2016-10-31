Attribute VB_Name = "Модуль1"
Public Type TypeProject
    InputROM As String
    OutputROM As String
    Emulator As String
End Type
Public Type TypeGroup
    DefineGroup As String
    PointerUse As Boolean
    PointerSize As Byte
    Interval As Integer
    Division As Byte
    Type As Byte
    Motorola As Boolean
    Signed As Boolean
    Shl1 As Boolean
    Method As Byte
    Difference As Long
    CharSet As String
    Table1 As String
    Table2 As String
End Type
Public Type TypeTextBlock
    PtrTableStart As Long
End Type
Public Type TypeStrng
    Text() As String
    StringPointer() As Long
End Type
    
Public Project As TypeProject
Public Group() As TypeGroup
Public TextBlock() As TypeTextBlock
Public Strng() As TypeStrng

Public Type TypeTile
    Til(15, 15) As Byte
    w As Byte
    H As Byte
End Type
Public Tile() As TypeTile
Public Type TypeTable
    Text As String
    Value As Long
    Width As Byte
    Height As Byte
    Tile As Integer
End Type
'Public Table(65535) As TypeTable
Public Table() As TypeTable
Public Type TypecTable
    TileDif As Long
    Width As Byte
    Height As Byte
    cnt As Integer
End Type
Public cTable As TypecTable


Public Pallete(255) As Long

Public Sub AddItem(AddArray(), Item)
'--Увеличение массива на 1
    Dim TempArray()
    TempArray = AddArray
    ReDim AddArray(LBound(AddArray) To UBound(AddArray) + 1)
    For n = LBound(AddArray) To UBound(AddArray) - 1
        TempArray(n) = AddArray(n)
    Next n
    AddArray(n) = Item
End Sub
Public Sub AddItem2(AddArray(), Item, Value)
'--Увеличение массива на 1
    Dim TempArray()
    TempArray = AddArray
    ReDim AddArray(LBound(AddArray) To UBound(AddArray), LBound(AddArray, 2) To UBound(AddArray, 2) + 1)
    For n = LBound(AddArray, 2) To UBound(AddArray, 2) - 1
        TempArray(Value, n) = AddArray(Value, n)
    Next n
    AddArray(Value, n) = Item
End Sub
Public Function Ist(IstTxt As String) As Long
Dim w As Long
txt = IstTxt
If Left(txt, 2) <> "&H" Then
    If Left(txt, 2) <> "&h" Then
        Ist = Val(txt)
        Exit Function
    End If
End If
txt = Right(txt, Len(txt) - 2)
For n = Len(txt) To 1 Step -1
    w = w + Val("&H" & Mid(txt, n, 1)) * 16 ^ (Len(txt) - n)
Next n
Ist = w
End Function

Public Function Probel(GettingString As String, PNum As Integer, symbol As String) As String
q = 1
For n = 1 To PNum - 1
    q = InStr(q, GettingString, symbol)
    q = q + Len(symbol)
Next n
For n = q To Len(GettingString)
    If Mid(GettingString, n, Len(symbol)) = symbol Then Exit For
    Probel = Probel & Mid(GettingString, n, Len(symbol))
Next n
End Function

Public Sub Locate(symbol, X, Y, Scl)
Hr = Tile(symbol).H
wr = Tile(symbol).w
If Hr > 16 Then Hr = 16
If wr > 16 Then wr = 16
For n = 0 To Hr - 1
    For m = 0 To wr - 1
        Call SetP(m + X, n + Y, Tile(symbol).Til(n, m), Scl)
    Next m
Next n
End Sub

Public Sub LoadTable(Tbl)
ReDim Table(3, 0)
Dim cnt
    Open Tbl For Input As 1
    Line Input #1, s
    'If
    'If s = "ends" Then GoTo ends:
    
    Exit Sub
ends:
    
End Sub

Public Sub SetP(X, Y, C, Scl)
If Scl = 0 Then Scl = 1
For n = 0 To Scl - 1
    For m = 0 To Scl - 1
        Form1.Picture1.PSet (X * 15 * Scl + n * 15, Y * 15 * Scl + m * 15), Pallete(C)
    Next m
Next n
End Sub

Public Function DlgOpen()
Dial.Backup = Dial.file

Dial.Form = Form1.hWnd
Dial.Filter = "All Files" & " (*.*)" + Chr$(0) + "*.*"
Dial.Title = "FileOpening"
Dial.file = ShowOpen
If Not InStr(1, Dial.file, "\") = 0 Then
    Dial.Dir = Right(Dial.file, Len(Dial.file) - InStrRev(Dial.file, "\"))
End If
If Dial.file = "" Then
    Dial.file = Dial.Backup
Else
    DlgOpen = Dial.file
End If
End Function

Public Function GetBits(byt, pos, num, BitRev, BytRev) As String
bt = byt
nrev = BitRev
nrv = BytRev
If nrev >= 0 Then nrev = 1 Else nrev = -1
If nrv >= 0 Then nrv = 1 Else nrv = -1
'If rev = 1 Then rev = -1 Else rev = 1
For n = 0 To 7
    If nrev = -1 Then
        If bt / 2 = bt \ 2 Then s = s & "0" Else s = s & "1"
    Else
        If bt / 2 = bt \ 2 Then s = "0" & s Else s = "1" & s
    End If
    bt = bt \ 2
Next n
If nrv = 1 Then
    For n = pos To pos + num - 1 Step 1
        GetBits = GetBits & Mid(s, n, 1)
    Next n
Else
    For n = 9 - pos - num + 1 To 9 - pos Step 1
        If n = 0 Then n = 1
        GetBits = GetBits & Mid(s, n, 1)
    Next n
End If
If GetBits = "" Then
    For n = 1 To num
        GetBits = GetBits & "0"
    Next n
End If
End Function

Public Function GetByte(byt)
For n = Len(byt) To 1 Step -1
    If Mid(byt, n, 1) = "1" Then GetByte = GetByte + 2 ^ (Len(byt) - n)
Next n
End Function

Public Sub LocS(symbol, X, Y)
For n = 0 To cTable.cnt
    If Table(n).Text = symbol Then
        Call Locate(Table(n).Tile, X, Y, Val(Form1.lScale))
        Exit Sub
    End If
Next n
End Sub

Public Sub LocLine(lin, X, Y)
Dim nX
nX = X
Dim pos
Dim num
Dim flag As Boolean
pos = 1
Retry:
Form1.Picture1.Refresh
flag = False
For n = 0 To cTable.cnt - 1
    If Table(n).Text = Mid(lin, pos, Len(Table(n).Text)) Then
        If flag = True Then
            If Len(Table(num).Text) < Len(Table(n).Text) And pos + Len(Table(n).Text) <= Len(lin) Then
                num = n
            End If
        Else
            num = n
            flag = True
        End If
    End If
Next n
If flag = True Then
    pos = pos + Len(Table(num).Text)
    Call Locate(Table(num).Tile, nX, Y, Form1.lScale)
    nX = nX + Table(num).Width
Else
    pos = pos + 1
End If
If pos > Len(lin) Then Exit Sub
GoTo Retry:
End Sub

Public Function GetSCount(lin, symbol)

End Function
Public Sub Add(AddArray() As TypeTable)
'--Увеличение массива на 1
    Dim TempArray() As TypeTable
    TempArray = AddArray
    ReDim AddArray(LBound(AddArray) To UBound(AddArray) + 1)
    For n = LBound(AddArray) To UBound(AddArray) - 1
         AddArray(n) = TempArray(n)
    Next n
End Sub
