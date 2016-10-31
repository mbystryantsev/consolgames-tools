Attribute VB_Name = "Модуль1"
Public T As Table
Public Type Table
    C As Integer
    T(1 To 256) As String
    V(1 To 256) As Byte
End Type

Public Cn As Config
Public Type Config
    Path                    As String        'Путь к файлам
    Num(1 To 256)           As Integer       'Номер
    Comments(1 To 256)      As String        'Комментарии
    ID(1 To 256)            As Integer       'Идентификатор
    C                       As Integer       'Счётчик
    FN(1 To 256)            As String        'Файл
    PS(1 To 256)            As Long          'Начало таблицы поинтеров
    PE(1 To 256)            As Long          'Конец таблицы поинтеров
    TS(1 To 256)            As Long          'Начало текста
    TE(1 To 256)            As Long          'Конец текста
    Compr(1 To 256)         As Boolean       'Сжат
    IPS(1 To 256)           As Long          'Начало в архиве
    IPE(1 To 256)           As Long          'Конец в архиве
    SzPos(1 To 256)         As Long          'Указатель размера
    PSz(1 To 256)           As Integer       'Размер поинтера
End Type
Public Pth As ScriptPath
Public Type ScriptPath
    inp As String 'Входной путь
    out As String 'Выходной путь
    arc As String 'Путь к архивам
    ifl As String 'Входной файл
    scr As String 'Путь к скрипту
End Type

Public Sub LoadTable(TableFile As String)
Open TableFile For Input As 3
T.C = 0
While Not EOF(3)
    Line Input #3, lin
    If InStr(lin, "=") = 3 Then
        T.C = T.C + 1
        T.T(T.C) = Right(lin, Len(lin) - 3)
        T.V(T.C) = Val("&H" & Left(lin, 2))
    End If
Wend
Close 3
End Sub

Public Sub LoadConfig(ConfigFile As String)
Cn.C = 1
ct = 0
Dim ss As String
GoTo Beg:
Probel:
ct = ct + 1
If ct = 1 Then
    Cn.Num(Cn.C) = Val(ss)
ElseIf ct = 2 Then
    Cn.FN(Cn.C) = ss
ElseIf ct = 3 Then
    Cn.PSz(Cn.C) = Val(ss)
ElseIf ct = 4 Then
    Cn.PS(Cn.C) = Ist(ss)
ElseIf ct = 5 Then
    Cn.PE(Cn.C) = Ist(ss)
ElseIf ct = 6 Then
    Cn.TS(Cn.C) = Ist(ss)
ElseIf ct = 7 Then
    Cn.TE(Cn.C) = Ist(ss)
ElseIf ct = 8 Then
    Cn.IPS(Cn.C) = Ist(ss)
ElseIf ct = 9 Then
    Cn.IPE(Cn.C) = Ist(ss)
ElseIf ct = 10 Then
    Cn.SzPos(Cn.C) = Ist(ss)
ElseIf ct = 11 Then
    If ss = "True" Then Cn.Compr(Cn.C) = True Else Cn.Compr(Cn.C) = False
ElseIf ct = 12 Then
    Cn.ID(Cn.C) = Val(ss)
    Cn.Comments(Cn.C) = Right(lin, Len(lin) - InStrRev(lin, " ", -1))
    ss = ""
    Cn.C = Cn.C + 1
    ct = 0
End If

ss = ""
GoTo Ret


Beg:
Open ConfigFile For Input As 3
Dim flag As Boolean
Dim flag2 As Boolean
Dim Path As String
While Not EOF(3)
    ss = ""
    If flag = False Then
        Line Input #3, lin
        If Left(lin, 7) = "[FILES]" Then flag = True
    Else
        Line Input #3, lin
        If flag2 = False Then
            If Left(lin, 5) = "PATH=" Then
                Cn.Path = Right(lin, Len(lin) - 5)
            Else
                GoTo NoRead
            End If
            flag2 = True
        Else
NoRead:
            For n = 1 To Len(lin)
                s = Mid(lin, n, 1)
                If s = " " Then GoTo Probel
                ss = ss & s
                
Ret:
            Next n
        End If
    End If
Wend
Cn.C = Cn.C - 1
For n = 1 To Form1.List.ListCount
    Form1.List.RemoveItem (0)
Next n
For n = 1 To Cn.C
    txt = Right("000" & Cn.Num(n), 3) & " | " & Str(Cn.PSz(n)) & " | "
    'txt=txt &
    txt = txt & Right("00000000" & Hex(Cn.PS(n)), 8) & "-" & Right("00000000" & Hex(Cn.PE(n)), 8) & " | "
    txt = txt & Right("00000000" & Hex(Cn.TS(n)), 8) & "-" & Right("00000000" & Hex(Cn.TE(n)), 8) & " | "
    txt = txt & Right("00000000" & Hex(Cn.IPS(n)), 8) & "-" & Right("00000000" & Hex(Cn.IPE(n)), 8) & " | "
    txt = txt & Right("00000000" & Hex(Cn.SzPos(n)), 8) & " | " & Left(Str(Cn.Compr(n)) & " ", 6) & " | "
    txt = txt & Cn.FN(n)
    Form1.List.AddItem (txt)
    Form1.List.ItemData(Form1.List.ListCount - 1) = n
Next n
Close
End Sub

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
