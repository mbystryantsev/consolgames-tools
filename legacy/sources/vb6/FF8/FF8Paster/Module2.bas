Attribute VB_Name = "Модуль2"

Public UByte As Byte
Public PosByte1 As Byte
Public PosByte2 As Byte
Public UBits As String
Public Buffer As Integer
Public BPos As Integer
Public Retry As Integer
Public tmpbte As Byte


'Public n As Long
'Public c As Long
'Public l As Long
Public Type ChangeZapret
    PBits As Boolean
    PByte As Boolean
End Type
Public Zapret As ChangeZapret
Public bte As Byte
Public pos, WPos As Long

Public Function AllBits(GettingByte As Byte) As String
Dim TempBit As String
Dim GttByte As Byte
GttByte = GettingByte
AllBits = ""
For n = 1 To 8
    If GttByte / 2 = GttByte \ 2 Then TempBit = "0" Else TempBit = "1"
    AllBits = TempBit & AllBits
    GttByte = GttByte \ 2
Next n
End Function

Public Function GetBit(GettingByte As Byte, BitNum As Integer) As Boolean
Dim GttByte As Byte
GttByte = GettingByte
For n = 1 To BitNum
    If GttByte / 2 = GttByte \ 2 Then GetBit = False Else GetBit = True
    GttByte = GttByte \ 2
Next n
End Function

Public Function GetByte(GettingBits As String) As Byte
Dim GttBits As Byte
GttBits = GettingBits
Dim TempLen, Cnt As Integer
If Len(GttBits) > 8 Then TempLen = 8 Else TempLen = Len(GttBits)
For n = TempLen To 1 Step -1
    If Mid(GttBits, n, 1) = 1 Then GetByte = GetByte + 2 ^ Cnt
    Cnt = Cnt + 1
Next n
End Function
Public Function GetLByte(GettingByte As Byte) As Byte
Dim GttByte As Byte
GttByte = GettingByte
Dim TempBit As String
GAllBits = ""
For n = 1 To 8
    If GttByte / 2 = GttByte \ 2 Then TempBit = "0" Else TempBit = "1"
    GAllBits = TempBit & GAllBits
    GttByte = GttByte \ 2
Next n
For n = 4 To 1 Step -1
    If Mid(GAllBits, n, 1) = 1 Then GetLByte = GetLByte + 2 ^ Cnt
    Cnt = Cnt + 1
Next n
End Function
Public Function GetRByte(GettingByte As Byte) As Byte
Dim GttByte As Byte
GttByte = GettingByte
Dim TempBit As String
GAllBits = ""
For n = 1 To 8
    If GttByte / 2 = GttByte \ 2 Then TempBit = "0" Else TempBit = "1"
    GAllBits = TempBit & GAllBits
    GttByte = GttByte \ 2
Next n
For n = 8 To 5 Step -1
    If Mid(GAllBits, n, 1) = 1 Then GetRByte = GetRByte + 2 ^ Cnt
    Cnt = Cnt + 1
Next n
End Function


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

