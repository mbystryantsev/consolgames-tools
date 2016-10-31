Attribute VB_Name = "Ps"
'Public clr As TileColor
'Public Type TileColor
Public clr(15) As Long
Public fil1() As Byte
Public fil2() As Byte
Public fil3() As Byte
Public Ef() As Byte
Public LofF(1 To 3)
Public Block() As Byte
Public f3pos As Long

Public Edit As EditType
Public Type EditType
    pos1 As Integer
    pos2 As Byte
    zapret As Boolean
End Type
'End Type


Public Sub PsSet(OX As Integer, OY As Integer, Color As Integer)
For n = (200 * OX) - 200 To (200 * OX) - 10 Step 10
    For c = (200 * OY) - 200 To (200 * OY) - 10 Step 10
        Form1.P.PSet (n, c), clr(Color)
    Next c
Next n
End Sub
Public Sub PsSet2(OX As Integer, OY As Integer, Color As Integer)
For n = (200 * OX) - 200 To (200 * OX) - 10 Step 10
    For c = (200 * OY) - 200 To (200 * OY) - 10 Step 10
        Form1.P2.PSet (n, c), clr(Color)
    Next c
Next n
End Sub

Public Sub WrBlock(BlockNum As Integer)
On Error GoTo er
Dim n As Integer
Dim c As Integer
Pos = BlockNum * 32 - 32
For n = Pos To Pos + 31
        'Call PsSet(c, n, GetLByte(fil2(Pos)))
        'Call PsSet(c + 1, n, GetRByte(fil2(Pos))): Pos = Pos + 1
        fil3(f3pos) = fil2(n): f3pos = f3pos + 1
Next n
Exit Sub
er:
f3pos = f3pos + 32
End Sub

Public Sub GetBlock(BlockNum As Integer)
On Error GoTo er:
Dim n As Integer
Dim c As Integer
Pos = BlockNum * 32 - 32
For n = 1 To 8
    For c = 1 To 8 Step 2
        Call PsSet(c, n, GetLByte(fil2(Pos)))
        Call PsSet(c + 1, n, GetRByte(fil2(Pos))): Pos = Pos + 1
        'fil3(f3pos) = fil2(Pos): f3pos = f3pos + 1
    Next c
Next n
Exit Sub
er:
For n = 1 To 8
    For c = 1 To 8
        Call PsSet(n, c, 0)
    Next c
Next n
For n = 1 To 8
    Call PsSet(n, n, 1)
Next n
For n = 1 To 8
    Call PsSet(9 - n, n, 1)
Next n
End Sub
Public Sub GetBlock2(BlockNum As Integer)
Dim n As Integer
Dim c As Integer
Pos = BlockNum * 32 - 32
For n = 1 To 8
    For c = 1 To 8 Step 2
        Call PsSet2(c, n, GetLByte(fil2(Pos)))
        Call PsSet2(c + 1, n, GetRByte(fil2(Pos))): Pos = Pos + 1
        'fil3(f3pos) = fil2(Pos): f3pos = f3pos + 1
    Next c
Next n
End Sub
