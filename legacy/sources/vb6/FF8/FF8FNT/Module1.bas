Attribute VB_Name = "Модуль1"
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

