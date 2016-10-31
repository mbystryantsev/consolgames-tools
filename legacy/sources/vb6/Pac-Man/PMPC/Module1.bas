Attribute VB_Name = "Модуль1"
Public proj
Public fil() As Byte
Public Word
Public FL() As Byte
Public UByte As Byte
Public PosByte1 As Byte
Public PosByte2 As Byte
Public UBits As String
Public Buffer As Integer
Public BPos As Integer
Public Retry As Integer
Public tmpbte As Byte


Public T As Table
Public Type Table
    c As Integer
    T(1 To 256) As String
    V(1 To 256) As Byte
End Type
'Public n As Long
'Public c As Long
'Public l As Long
Public Type ChangeZapret
    PBits As Boolean
    PByte As Boolean
End Type
Public Zapret As ChangeZapret
Public bte As Byte
Public Pos, WPos As Long


Public Declare Function GetOpenFileName Lib "comdlg32.dll" Alias "GetOpenFileNameA" (pOpenfilename As OPENFILENAME) As Long ' Объявление функций
Public Declare Function GetSaveFileName Lib "comdlg32.dll" Alias "GetSaveFileNameA" (pOpenfilename As OPENFILENAME) As Long
Public OFName           As OPENFILENAME
Public Type OPENFILENAME
    lStructSize         As Long
    hwndOwner           As Long
    hInstance           As Long
    lpstrFilter         As String
    lpstrCustomFilter   As String
    nMaxCustFilter      As Long
    nFilterIndex        As Long
    lpstrFile           As String
    nMaxFile            As Long
    lpstrFileTitle      As String
    nMaxFileTitle       As Long
    lpstrInitialDir     As String
    lpstrTitle          As String
    flags               As Long
    nFileOffset         As Integer
    nFileExtension      As Integer
    lpstrDefExt         As String
    lCustData           As Long
    lpfnHook            As Long
    lpTemplateName      As String
End Type
Public Dial             As DIALOG
Public Type DIALOG                              '
    Form                As Long                 ' Форма, вызвавшая диалог
    Filter              As String               ' Фильтр
    Title               As String               ' Заголовок
    Dir                 As String               ' Начальная директория
    Backup              As String
    File                As String
End Type

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

Public Function UB(GettingPointer As Integer, GettingRetry As Integer, GettingSize As Byte) As String
Dim TempBit As String
Dim GttByte As Integer
Dim Bits1 As String
Dim Bits2 As String
GttByte = GettingPointer
'AllBits = ""
For n = 1 To GettingSize
    If GttByte / 2 = GttByte \ 2 Then TempBit = "0" Else TempBit = "1"
    Bits1 = TempBit & Bits1
    GttByte = GttByte \ 2
Next n
GttByte = GettingRetry
For n = 1 To 16 - GettingSize
    If GttByte / 2 = GttByte \ 2 Then TempBit = "0" Else TempBit = "1"
    Bits2 = TempBit & Bits2
    GttByte = GttByte \ 2
Next n
UB = Bits2 & Bits1
End Function
Public Function GetBit(GettingByte As Byte, BitNum As Integer) As Boolean
Dim GttByte As Byte
GttByte = GettingByte
For n = 1 To BitNum
    GetBit = (GttByte / 2 <> GttByte \ 2)
    GttByte = GttByte \ 2
Next n
End Function

Public Function GetByte(GettingBits As String) As Byte
Dim GttBits As String
GttBits = GettingBits
'Dim TempLen, Cnt As Integer
'If Len(GttBits) > 8 Then TempLen = 8 Else TempLen = Len(GttBits)
For n = 8 To 1 Step -1
    If Mid(GttBits, n, 1) = 1 Then GetByte = GetByte + 2 ^ cnt
    cnt = cnt + 1
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
    If Mid(GAllBits, n, 1) = 1 Then GetLByte = GetLByte + 2 ^ cnt
    cnt = cnt + 1
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
    If Mid(GAllBits, n, 1) = 1 Then GetRByte = GetRByte + 2 ^ cnt
    cnt = cnt + 1
Next n
End Function

Public Function DoLogNot(LogText As String)
'    Form1.Log = Form1.Log & LogText
End Function

Public Function DoLog(LogText As String)
    'Form1.Log = Form1.Log & LogText & vbCrLf
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



Public Sub LoadTable(TableFile As String)

Open TableFile For Input As 3
T.c = 0
While Not EOF(3)
    Line Input #3, lin
    If InStr(lin, "=") = 3 Then
        T.c = T.c + 1
        T.T(T.c) = Right(lin, Len(lin) - 3)
        T.V(T.c) = Val("&H" & Left(lin, 2))
    End If
Wend
Close 3
End Sub

Public Function Nul(NullTxt As String) As String
NTxt = Ist(NullTxt)
Nul = Right("00000000" & Hex(NTxt), 8)
End Function
Public Function Probel(GettingString As String, PNum As Integer) As String
q = 1
For n = 1 To PNum - 1
    q = InStr(q, GettingString, " ")
    q = q + 1
Next n
For n = q To Len(GettingString)
    If Mid(GettingString, n, 1) = " " Then Exit For
    Probel = Probel & Mid(GettingString, n, 1)
Next n
End Function


Public Function ShowOpen() As String 'Подпрограмма. Обозначение всего чего нужно и вызов окна
    OFName.lStructSize = Len(OFName)
    OFName.hwndOwner = FormIndex
    OFName.hInstance = App.hInstance
    OFName.lpstrFilter = Dial.Filter 'фильтр
    OFName.lpstrFile = Space$(254)
    OFName.nMaxFile = 255
    OFName.lpstrFileTitle = Space$(254)
    OFName.nMaxFileTitle = 255
    OFName.lpstrInitialDir = Dial.Dir 'Начальная директория
    OFName.lpstrTitle = Dial.Title
    OFName.flags = 0

    If GetOpenFileName(OFName) Then 'Если была нажата кнопка Отмена или возникла ошибка, то в переменную ShowOpen возврашается  "" , иначе путь к файлу
        ShowOpen = Trim$(OFName.lpstrFile)
    Else
        ShowOpen = ""
    End If
End Function

'Private
Public Function ShowSave() As String ' Здесь всё аналогично
    OFName.lStructSize = Len(OFName)
    OFName.hwndOwner = FormIndex
    OFName.hInstance = App.hInstance
    OFName.lpstrFilter = Dial.Filter
    OFName.lpstrFile = Space$(254)
    OFName.nMaxFile = 255
    OFName.lpstrFileTitle = Space$(254)
    OFName.nMaxFileTitle = 255
    OFName.lpstrInitialDir = Dial.Dir
    OFName.lpstrTitle = Dial.Title
    OFName.flags = 0

    If GetSaveFileName(OFName) Then
        ShowSave = Trim$(OFName.lpstrFile)
    Else
        ShowSave = ""
    End If
End Function





