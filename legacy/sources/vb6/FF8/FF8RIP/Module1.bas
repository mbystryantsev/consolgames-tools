Attribute VB_Name = "Модуль1"

Public Function IntH(IntHex As Long) As Long
IntH = ((IntHex + 2047) \ 2048) * 2048
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
