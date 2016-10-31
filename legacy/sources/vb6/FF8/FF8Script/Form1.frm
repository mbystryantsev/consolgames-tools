VERSION 5.00

Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   8715
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   10770
   LinkTopic       =   "Form1"
   ScaleHeight     =   8715
   ScaleWidth      =   10770
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox filePST 
      Height          =   285
      Left            =   120
      TabIndex        =   46
      Text            =   "Text1"
      Top             =   4800
      Width           =   10575
   End
   Begin VB.TextBox ImgPos 
      Height          =   285
      Left            =   7800
      TabIndex        =   45
      Top             =   7080
      Width           =   1935
   End
   Begin VB.CommandButton PasteButton 
      Cancel          =   -1  'True
      Caption         =   "Вставить"
      Height          =   255
      Left            =   840
      TabIndex        =   44
      Top             =   7440
      Width           =   8895
   End
   Begin VB.TextBox fileIMG 
      Height          =   285
      Left            =   840
      TabIndex        =   43
      Text            =   "FF8DISC1.IMG"
      Top             =   7080
      Width           =   6855
   End
   Begin VB.CommandButton Command11 
      Caption         =   "Выполнить"
      Height          =   255
      Left            =   840
      TabIndex        =   42
      Top             =   6720
      Width           =   8895
   End
   Begin VB.TextBox FileScr 
      Height          =   285
      Left            =   840
      TabIndex        =   40
      Text            =   "FF8\Script.ini"
      Top             =   6360
      Width           =   8895
   End
   Begin VB.CommandButton Command16 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   9840
      TabIndex        =   39
      Top             =   6360
      Width           =   855
   End
   Begin VB.TextBox FileText 
      Height          =   285
      Left            =   840
      TabIndex        =   38
      Text            =   "FF8\FILES\SCRIPTS\RUS\file5734000.scr.txt"
      Top             =   1920
      Width           =   8895
   End
   Begin VB.TextBox factor 
      Height          =   285
      Left            =   6600
      TabIndex        =   37
      Text            =   "4095"
      Top             =   7800
      Width           =   495
   End
 
   Begin VB.CommandButton Command10 
      Caption         =   "Запаковать"
      Height          =   255
      Left            =   2640
      TabIndex        =   36
      Top             =   8160
      Width           =   1335
   End
   Begin VB.CommandButton Command9 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   9840
      TabIndex        =   33
      Top             =   1200
      Width           =   855
   End
   Begin VB.TextBox file8 
      Height          =   285
      Left            =   840
      TabIndex        =   31
      Text            =   "FF8\Rus.tbl"
      Top             =   1200
      Width           =   8895
   End
   Begin VB.CommandButton Command6 
      Caption         =   "Вставить текст"
      Height          =   255
      Left            =   120
      TabIndex        =   30
      Top             =   5040
      Width           =   10575
   End
   Begin VB.TextBox FSZ 
      Height          =   285
      Left            =   6600
      TabIndex        =   29
      Text            =   "Text1"
      Top             =   8160
      Width           =   975
   End
   Begin VB.TextBox Cmnts 
      Height          =   285
      Left            =   120
      Locked          =   -1  'True
      TabIndex        =   28
      Top             =   4200
      Width           =   10575
   End
   Begin VB.ListBox List 
      Height          =   1035
      ItemData        =   "Form1.frx":0000
      Left            =   120
      List            =   "Form1.frx":0002
      MultiSelect     =   2  'Расширенно
      TabIndex        =   25
      Top             =   2880
      Width           =   10575
   End
   Begin VB.CommandButton Command8 
      Caption         =   "Загрузить конфиг"
      Height          =   255
      Left            =   120
      TabIndex        =   24
      Top             =   2280
      Width           =   10575
   End
   Begin VB.CommandButton Command7 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   9840
      TabIndex        =   23
      Top             =   1560
      Width           =   855
   End
   Begin VB.TextBox file6 
      Height          =   285
      Left            =   840
      TabIndex        =   21
      Text            =   "FF8\FILES\Configs\Config.ini"
      Top             =   1560
      Width           =   8895
   End
   Begin VB.TextBox SizePnt 
      Height          =   285
      Left            =   4320
      TabIndex        =   20
      Text            =   "4"
      Top             =   5640
      Width           =   1095
   End
   Begin VB.CommandButton Command5 
      Caption         =   "Распаковать"
      Height          =   255
      Left            =   1080
      TabIndex        =   19
      Top             =   8160
      Width           =   1335
   End
   Begin VB.TextBox file5 
      Height          =   285
      Left            =   1080
      TabIndex        =   18
      Text            =   "FF8\Unpack.fhx"
      Top             =   7800
      Width           =   5415
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   9840
      TabIndex        =   14
      Top             =   840
      Width           =   855
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   9840
      TabIndex        =   13
      Top             =   480
      Width           =   855
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   9840
      TabIndex        =   12
      Top             =   120
      Width           =   855
   End
   Begin VB.TextBox file3 
      Height          =   285
      Left            =   840
      TabIndex        =   9
      Text            =   "FF8\2.tbl"
      Top             =   840
      Width           =   8895
   End
   Begin VB.TextBox file2 
      Height          =   285
      Left            =   840
      TabIndex        =   8
      Text            =   "FF8\FILES\SCRIPTS\file6.scr.txt"
      Top             =   480
      Width           =   8895
   End
   Begin VB.CheckBox ComprCheck 
      Caption         =   "Сжато"
      Height          =   255
      Left            =   7680
      TabIndex        =   7
      Top             =   7800
      Width           =   975
   End
   Begin VB.TextBox Ids 
      Height          =   285
      Left            =   4320
      Locked          =   -1  'True
      TabIndex        =   6
      Text            =   "0"
      Top             =   6000
      Width           =   1095
   End
   Begin VB.TextBox MaxPos 
      Height          =   285
      Left            =   3120
      TabIndex        =   5
      Text            =   "&Haeb0"
      Top             =   6000
      Width           =   1095
   End
   Begin VB.TextBox MinPos 
      Height          =   285
      Left            =   1800
      TabIndex        =   4
      Text            =   "&H9b08"
      Top             =   6000
      Width           =   1215
   End
   Begin VB.TextBox MaxPnt 
      Height          =   285
      Left            =   3120
      TabIndex        =   3
      Text            =   "&H9b07"
      Top             =   5640
      Width           =   1095
   End
   Begin VB.TextBox MinPnt 
      Height          =   285
      Left            =   1800
      TabIndex        =   2
      Text            =   "&H99c4"
      Top             =   5640
      Width           =   1215
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Создать скрипт"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   4560
      Width           =   10575
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   840
      TabIndex        =   0
      Text            =   "FF8\FILES\file544F000.fhx"
      Top             =   120
      Width           =   8895
   End
   Begin VB.Label Label14 
      Alignment       =   1  'Правая привязка
      Caption         =   "Сценарий:"
      Height          =   255
      Left            =   0
      TabIndex        =   41
      Top             =   6360
      Width           =   825
   End
   Begin VB.Label Label11 
      Alignment       =   2  'Центровка
      Caption         =   "-"
      Height          =   255
      Left            =   3000
      TabIndex        =   35
      Top             =   6000
      Width           =   135
   End
   Begin VB.Label Label3 
      Alignment       =   2  'Центровка
      Caption         =   "-"
      Height          =   255
      Left            =   3000
      TabIndex        =   34
      Top             =   5640
      Width           =   135
   End
   Begin VB.Label Label10 
      Alignment       =   1  'Правая привязка
      Caption         =   "Рус.табл.:"
      Height          =   255
      Left            =   -120
      TabIndex        =   32
      Top             =   1200
      Width           =   855
   End
   Begin VB.Label Label9 
      Alignment       =   2  'Центровка
      Caption         =   "Комментарии:"
      Height          =   255
      Left            =   120
      TabIndex        =   27
      Top             =   3960
      Width           =   10575
   End
   Begin VB.Label Label8 
      Caption         =   $"Form1.frx":0004
      Height          =   255
      Left            =   120
      TabIndex        =   26
      Top             =   2640
      Width           =   10575
   End
   Begin VB.Label Label7 
      Alignment       =   1  'Правая привязка
      Caption         =   "Конфиг:"
      Height          =   255
      Left            =   0
      TabIndex        =   22
      Top             =   1560
      Width           =   735
   End
   Begin VB.Label Label6 
      Alignment       =   1  'Правая привязка
      Caption         =   "Таблица:"
      Height          =   255
      Left            =   0
      TabIndex        =   17
      Top             =   840
      Width           =   735
   End
   Begin VB.Label Label5 
      Alignment       =   1  'Правая привязка
      Caption         =   "Скрипт:"
      Height          =   255
      Left            =   120
      TabIndex        =   16
      Top             =   480
      Width           =   615
   End
   Begin VB.Label Label4 
      Alignment       =   1  'Правая привязка
      Caption         =   "Файл:"
      Height          =   255
      Left            =   240
      TabIndex        =   15
      Top             =   120
      Width           =   495
   End
   Begin VB.Label Label2 
      Alignment       =   1  'Правая привязка
      Caption         =   "Блок текста:"
      Height          =   255
      Left            =   120
      TabIndex        =   11
      Top             =   6000
      Width           =   1575
   End
   Begin VB.Label Label1 
      Alignment       =   1  'Правая привязка
      Caption         =   "Таблица поинтеров:"
      Height          =   255
      Left            =   0
      TabIndex        =   10
      Top             =   5640
      Width           =   1695
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
Dim bte As Byte
If ComprCheck.Value = 0 Then
    Open file1 For Binary As 1
Else
    Open file5 For Binary As 1
End If
Open file2 For Output As 2
Open "~tmpff8scr.tmp" For Binary As 4
Call LoadTable(file3)
info = Right("00000000" & Hex(Ist(MinPnt)), 8) & Right("00000000" & Hex(Ist(MaxPnt)), 8)
info = info & Right("00000000" & Hex(Ist(MinPos)), 8) & Right("00000000" & Hex(Ist(MaxPos)), 8) & Ist(SizePnt) & Ist(ComprCheck.Value)
tmpcnt = 0
Print #2, info
If ComprCheck.Value = 0 Then
    For n = Ist(MinPos) + 1 To Ist(MaxPos) + 1
        tmpcnt = tmpcnt + 1
        Get #1, n, bte
        Put #4, tmpcnt, bte
    Next n
Else
End If
tmpcnt = 0
For n = Ist(MinPnt) + 1 To Ist(MaxPnt) + 1 Step Ist(SizePnt)
sobaka = 0
For C = 1 To Ist(SizePnt)
    Get #1, n, bte
    If bte = 0 Then sobaka = sobaka + 1
    pntpos = pntpos + bte * 256 ^ C
Next C
If sobaka = Ist(SizePnt) Then
    stroka = "@"
    GoTo Nol
End If
Read:
    If Lck = False Then
        FirstPnt = pntpos
        Lck = True
    End If ' Поинтер получен - читаем текст
    
    tmpcnt = tmpcnt + 1
    Get #4, tmpcnt, bte
    For C = 1 To T.C
        If bte = T.V(C) Then
            stroka = stroka & T.T(C)
            GoTo fnd
        End If
    Next C
    stroka = stroka & "{" & Right("00" & Hex(bte), 2) & "}"
fnd:
    If bte = 0 Then
        GoTo Nol
    ElseIf bte <= 2 Then
        stroka = stroka & vbCrLf
    End If
GoTo Read
Nol:
Print #2, stroka
stroka = ""
Next n

Close 1
Close 2
Close 4
End Sub

Private Sub Command10_Click()
Dim bt1 As Byte
Dim bt2 As Byte
Dim ubt As String
Open file5 For Binary As 1
'Open Left(file1, Len(file1) - 4) & ".pak.fhx" For Binary As 2
Open file1 For Binary As 2
'ReDim FL(LOF(1) - 1)
'Get #1, 1, FL()

Open Left(file1, Len(file1) - 4) & ".fhx.err" For Binary As 3
Open file1 For Binary As 5
For n = 4 To 1 Step -1
    Get #3, n, bte
    mwpos = mwpos + bte * 256 ^ (4 - n)
Next n
For n = 5 To mwpos
    Get #5, n, bte
    Put #2, n, bte
Next n
WPos = n
For n = 8 To 5 Step -1
    Get #3, n, bte
    mwrpos = mwrpos + bte * 256 ^ (8 - n)
Next n
mwrpos = mwrpos + 1
mwpos = mwpos + 1
pos = mwrpos

'Dim epb1 As Byte
'Dim epb2 As Byte
'For epos = 1 To 4
'    Get #3, epos, bte
'    ebuf = ebuf + bte * 256 ^ 4 - d
'Next d
'epos = epos + 2
'Get #3, epos, epb1
'Get #3, epos + 1, ebp2: epos = epos + 2
buf = &HFEA
'WPos = 1
fac = Val(factor)
'For pos = 1 To 4
'    Get #1, pos, bte
'    Put #2, pos, bte
'Next pos
'pos = 5
'WPos = 5
upos = WPos: WPos = WPos + 1                                    ' Установка позиции управляющего байта
'APB.Min = 1
'APB.Max = LOF(1) ' + 2
While pos <= LOF(1)                                             ' До конца файла
    'If pos >= 8032 Then
    '    a = b
    'End If
    ''APB.Caption = pos & "/" & LOF(1)
    'APB.Value = pos
    Get #1, pos, bte                                            ' Получаем байт
    'bte = FL(pos - 1)
    'MsgBox "Получен байт " & bte & " по адресу " & Hex(pos)
    pbt = bte
    If pos - fac <= 4 Then w = pos + 1 Else w = pos - fac       ' Установка минимального значения начального адреса поиска
    For n = w To pos - 1                                        '
        Get #1, n, bte
        'bte = FL(n - 1)
        If pbt = bte Then                                       ' Сравниваем файлы
            'MsgBox "Найдены одинаковые байты " & Hex(pbt) & "=" & Hex(bte) & " по адресу " & Hex(n)
            col = 1                                             ' Количество + 1
            'If w + 16 > pos Then f = pos Else f = w
            If n + 17 <= LOF(1) Then m = n + 17 Else m = LOF(1)
            For C = n + 1 To m                                                              ' [Сверяем байты от
                Get #1, pos + col, bte                                                      ' [позиции первого
                'bte = FL(pos + col - 1)
                q = bte                                                                     ' [схожего байта
                Get #1, C, bte                                                              ' [до его позиции + 19
                'bte = FL(C - 1)
                If Not bte = q Then Exit For                    ' Если не равны, то всё     ' [(максимальное
                col = col + 1                                                               ' [количество
            Next C                                                                          ' [повторений).
            If col >= 3 Then                                    ' Если одинаковых байтов больше 3
                If col > pkcol Then                             ' И если этот результат лучше предыдущего
                    pkn = n: pkcol = col                        ' Оставляем информацию о адресе начального байта и количестве схожих байт
                End If                                          '
                'For WPos = WPos To WPos + col
                '     put #2
                'Next WPos
            End If
        Else
        End If
    Next n
    If pkcol >= 3 Then                                          ' Если был достигнут результат больше 2
        ubt = "0" & ubt                                         ' Управляющий бит ставится в соответствующее значение
        pos = pos + pkcol - 1                                   ' Позиция тоже
        wbuf = buf - 1 + pkn
        While wbuf >= 4096
            wbuf = wbuf - 4096
        Wend
        bt1 = Val("&H" & Right(Hex(wbuf), 2))
        bt2 = Val("&H" & Left(Right("00" & Hex(wbuf), 3), 1) & Hex(pkcol - 3))
        'MsgBox Hex(bt1)
        Put #2, WPos, bt1: WPos = WPos + 1
        Put #2, WPos, bt2: WPos = WPos + 1
    Else                                                        ' Если же нет
        ubt = "1" & ubt                                         ' Ставим бит, добавляем байт
        Get #1, pos, bte                                                   '
        'bte = FL(pos - 1)
        Put #2, WPos, bte: WPos = WPos + 1
    End If
    pkcol = 0
    If Len(ubt) >= 8 Then                                       ' Если все биты управляющего байта заполнены
        Put #2, upos, GetByte(ubt): WPos = WPos + 1             ' Записываем его
        ubt = ""                                                '
        upos = WPos - 1                                         ' Ставим новый управляющий байт
    End If                                                      '
    pos = pos + 1
Wend
If Len(ubt) > 0 Then                                     ' Если все биты управляющего байта заполнены
    Put #2, upos, GetByte(Right("00000000" & ubt, 8))
End If
ubt = Hex(LOF(2) - 4)
For n = 1 To 4
    bte = Val("&H" & Mid(Right("00000000" & ubt, 8), n * 2 - 1, 2))
    Put #2, 5 - n, bte
Next n
Close 1
Close 2
Close 3
End Sub




Private Sub Command11_Click()
Dim lin As String
Open FileScr For Input As 11
While Not EOF(11)
    Line Input #11, lin
    Cnt = Cnt + 1
Wend
Close 11


Open FileScr For Input As 10
While Not EOF(10)
    cnt2 = cnt2 + 1
    'APB.Caption = cnt2 & "/" & Cnt & " [" & Int(cnt2 / Cnt * 100) & "%]"
    Line Input #10, lin
    If Len(lin) <= 0 Then GoTo skip
    If Left(lin, 1) = "'" Then GoTo skip
    s = Probel(lin, 1)
    If s = "end" Then
        Close
        Exit Sub
    ElseIf s = "pth" Then 'Присвоить путь
        If Probel(lin, 2) = "inp" Then
            Pth.inp = Probel(lin, 3)
        ElseIf Probel(lin, 2) = "out" Then
            Pth.out = Probel(lin, 3)
        ElseIf Probel(lin, 2) = "arc" Then
            Pth.arc = Probel(lin, 3)
        ElseIf Probel(lin, 2) = "scr" Then
            Pth.scr = Probel(lin, 3)
        End If
    ElseIf s = "pak" Then 'Запаковка
        If Probel(lin, 2) = "path" Then
            Pth.ifl = Probel(lin, 3)
            file5 = Pth.inp & Probel(lin, 3)
        ElseIf Probel(lin, 2) = "full" Then
            Pth.ifl = Probel(lin, 3)
            file5 = Probel(lin, 3)
        End If
        If Left(Probel(lin, 5), 1) = "/" Then
            w = Left(Pth.ifl, Len(Pth.ifl) - Val(Mid(Probel(lin, 5), 2, 1)))
            w = w & Mid(Probel(lin, 5), 3, Len(Probel(lin, 5)) - 2)
        End If
        If Probel(lin, 4) = "path" Then
            file1 = Pth.out & w
        ElseIf Probel(lin, 4) = "full" Then
            file1 = w
        End If
        'MsgBox Right(Dir(file1), Len(Pth.ifl))
        'If Right(Dir(file1), Len(Pth.ifl)) = Pth.ifl Then
            'APB.Caption = 'APB.Caption & " - Распаковка файла" & Chr(34) & Pth.ifl & Chr(34)
            Call Command10_Click
        'End If
    ElseIf s = "msg" Then 'Пауза(сообщение)
        MsgBox Right(lin, Len(lin) - 4)
    ElseIf s = "pst" Then 'Вставить скрипт
        If Probel(lin, 2) = "path" Then
            Pth.ifl = Probel(lin, 3)
            file1 = Pth.inp & Probel(lin, 3)
        ElseIf Probel(lin, 2) = "full" Then
            Pth.ifl = Probel(lin, 3)
            file1 = Probel(lin, 3)
        End If
        If Left(Probel(lin, 5), 1) = "/" Then
            w = Left(Pth.ifl, Len(Pth.ifl) - Val(Mid(Probel(lin, 5), 2, 1)))
            w = w & Mid(Probel(lin, 5), 3, Len(Probel(lin, 5)) - 2)
        Else
            w = Probel(lin, 5)
        End If
        If Probel(lin, 4) = "path" Then
            filePST = Pth.out & w
        ElseIf Probel(lin, 4) = "full" Then
            filePST = w
        End If
        If Left(Probel(lin, 12), 1) = "/" Then
            w = Left(Pth.ifl, Len(Pth.ifl) - Val(Mid(Probel(lin, 12), 2, 1)))
            w = w & Mid(Probel(lin, 12), 3, Len(Probel(lin, 12)) - 2)
        Else
            w = Probel(lin, 12)
        End If
        If Probel(lin, 11) = "path" Then
            FileText = Pth.scr & w
        ElseIf Probel(lin, 11) = "full" Then
            FileText = w
        End If
        SizePnt = Val(Probel(lin, 6))
        MinPnt = Probel(lin, 7)
        MaxPnt = Probel(lin, 8)
        MinPos = Probel(lin, 9)
        MaxPos = Probel(lin, 10)
        If Right(Dir(file1), Len(Pth.ifl)) = Pth.ifl Then
            'If Right(Dir(FileText), Len(Pth.ifl)) = Pth.ifl Then
                'APB.Caption = 'APB.Caption & " - Вставка скрипта в " & Chr(34) & filePST & Chr(34)
                Call Command6_Click
            'End If
        End If
        
    ElseIf s = "unc" Then 'Распаковать
        If Probel(lin, 2) = "path" Then
            Pth.ifl = Probel(lin, 3)
            file1 = Pth.inp & Probel(lin, 3)
        ElseIf Probel(lin, 2) = "full" Then
            Pth.ifl = Probel(lin, 3)
            file1 = Probel(lin, 3)
        End If
        If Left(Probel(lin, 5), 1) = "/" Then
            w = Left(Pth.ifl, Len(Pth.ifl) - Val(Mid(Probel(lin, 5), 2, 1)))
            w = w & Mid(Probel(lin, 5), 3, Len(Probel(lin, 5)) - 2)
        End If
        If Probel(lin, 4) = "path" Then
            file5 = Pth.out & w
        ElseIf Probel(lin, 4) = "full" Then
            file5 = w
        End If
        'MsgBox Right(Dir(file1), Len(Pth.ifl))
        If Right(Dir(file1), Len(Pth.ifl)) = Pth.ifl Then
            'APB.Caption = 'APB.Caption & " - Распаковка файла" & Chr(34) & Pth.ifl & Chr(34)
            Call Command5_Click
        End If
    ElseIf s = "ext" Then 'Извлечь скрипт
        If Probel(lin, 2) = "path" Then
            Pth.ifl = Probel(lin, 3)
            file1 = Pth.inp & Probel(lin, 3)
        ElseIf Probel(lin, 2) = "full" Then
            Pth.ifl = Probel(lin, 3)
            file1 = Probel(lin, 3)
        End If
        If Left(Probel(lin, 5), 1) = "/" Then
            w = Left(Pth.ifl, Len(Pth.ifl) - Val(Mid(Probel(lin, 5), 2, 1)))
            w = w & Mid(Probel(lin, 5), 3, Len(Probel(lin, 5)) - 2)
        Else
            w = Probel(lin, 5)
        End If
        If Probel(lin, 4) = "path" Then
            file2 = Pth.out & w
        ElseIf Probel(lin, 4) = "full" Then
            file2 = w
        End If
        SizePnt = Val(Probel(lin, 6))
        MinPnt = Probel(lin, 7)
        MaxPnt = Probel(lin, 8)
        MinPos = Probel(lin, 9)
        MaxPos = Probel(lin, 10)
        If Right(Dir(file1), Len(Pth.ifl)) = Pth.ifl Then
            'APB.Caption = 'APB.Caption & " - Извлечение скрипта из " & Chr(34) & Pth.ifl & Chr(34)
            Call Command1_Click
        End If
    ElseIf s = "pta" Then 'Вставить файл
        If Probel(lin, 2) = "path" Then
            Pth.ifl = Probel(lin, 3)
            file1 = Pth.inp & Probel(lin, 3)
        ElseIf Probel(lin, 2) = "full" Then
            Pth.ifl = Probel(lin, 3)
            file1 = Probel(lin, 3)
        End If
        If Left(Probel(lin, 5), 1) = "/" Then
            w = Left(Pth.ifl, Len(Pth.ifl) - Val(Mid(Probel(lin, 5), 2, 1)))
            w = w & Mid(Probel(lin, 5), 3, Len(Probel(lin, 5)) - 2)
        Else
            w = Probel(lin, 5)
        End If
        If Probel(lin, 4) = "path" Then
            fileIMG = Pth.out & w
        ElseIf Probel(lin, 4) = "full" Then
            fileIMG = w
        End If
        ImgPos = Probel(lin, 6)
        'If Right(Dir(file1), Len(Pth.ifl)) = Pth.ifl Then
            'APB.Caption = 'APB.Caption & " - Вставка файла " & Chr(34) & Pth.ifl & Chr(34)
            Call PasteButton_Click
        'End If
    End If
skip:
Wend
Close
End Sub

Private Sub Command12_Click()
'open file1
End Sub








Private Sub Command16_Click()

Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "Файлы настройки (*.ini)" _
        + Chr$(0) + "*.ini" + Chr$(0) + "Текстовые файлы (*.txt)" _
        + Chr$(0) + "*.txt" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие сценария"
Dial.File = ShowOpen
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
Else
    FileScr = Dial.File
End If
End Sub

Private Sub Command2_Click()
Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие файла"
Dial.File = ShowOpen
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
Else
    file1 = Dial.File
End If
End Sub

Private Sub Command3_Click()
Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Сохранение скрипта"
Dial.File = ShowSave
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
Else
    file2 = Dial.File
End If
End Sub

Private Sub Command4_Click()
Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "Файлы таблиц (*.tbl)" _
        + Chr$(0) + "*.tbl" + Chr$(0) + "Текстовые файлы (*.txt)" _
        + Chr$(0) + "*.txt" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие таблицы"
Dial.File = ShowOpen
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
Else
    file3 = Dial.File
End If
End Sub

Private Sub Command5_Click()
Open file1 For Binary As 1
Open file5 For Binary As 5
Dim siz As Long
epos = 1
'APB.Min = 1
'APB.Max = LOF(1) + 1
'Open file7 For Binary As 7
buf = 4079                                      ' Присваеваем буферу начальное значение
pos7 = 1                                        ' ?
pos = 5                                         ' Позиция чтения рана 5
For n = 4 To 1 Step -1                          ' Читаем первые 4 байта, находим размер архива
    Get #1, n, bte                              ' ^
    asz = asz + bte * 256 ^ (n - 1)             ' ^
    Put #5, n, bte                              ' ^
Next n                                          ' ^
siz = 4                                         ' Так, фигнёй страдаем :)
WPos = 5                                        ' Позиция записи равна 5
While Not pos >= LOF(1)                         ' До конца файла

'APB.Value = pos                                 ' Ну тут всё ясно =)
Get #1, pos, bte: pos = pos + 1                 ' Получаем управляющий байт
msepos = pos - 1
mrspos = WPos - 1
If epf = True Then
    mepos = pos - 1
    mrpos = WPos - 1
    epf = False
End If
siz = siz + 1                                   ' Опять фигня :)
b = AllBits(bte)                                ' ???(Старость не в радость :) )
For n = 8 To 1 Step -1                          ' Разбираем по битам
    If Mid(b, n, 1) = 1 Then                    ' Если бит равен 1, то...
        If pos > asz + 1 Then                     '   Если мы за пределами архива
            'APB.Value = 1                       '   -Прогресс бар=1
            Close 1                               '   -Закрыбаем нафиг
            Close 5
            Close 3
            GoTo absend                            '   -И ... нафиг :)
        End If                                  '  А если всё в порядке...
        Get #1, pos, bte: pos = pos + 1         '   Получаем байт из текущей позиции
        Put #5, WPos, bte: WPos = WPos + 1      '   Пишем его
        buf = buf + 1                           '   Буфер, ессно, увеличивается
        siz = siz + 1                           '   Фигня тоже :)
        If buf >= 4096 Then buf = buf - 4096    '   Если буфер перехаватал байтов, то... Делаем пластическую операцию :)
    Else                                        ' А если бит равен 0...
        If pos > asz + 1 Then                     '  ^^^
            'APB.Value = 1                       '  ^^^
            Close 1                              '  ^^^
            Close 5
            Close 3
            GoTo absend                          '  ^^^
        End If                                  '  ^^^
        Get #1, pos, PosByte1: pos = pos + 1    ' Получаем первый байт указателя
        Get #1, pos, PosByte2: pos = pos + 1    ' -''- второй -''-
        Retry = GetRByte(PosByte2) + 3          ' Находим количество повторений
        adres = GetLByte(PosByte2) * 256 + PosByte1 ' Находим позицию в буфере...
        bfs = buf - adres                       ' Находим позицию, на которую направляет адресация в буфере
        'bu = buf                                ' Чушь
        'ad = adres                              ' ^
        'bf = bfs                                ' ^
        If bfs <= 0 Then                        ' Если нас обманули, восстанавливаем справедливость
            bfs = (buf + 4096) - adres          ' ^
        End If                                  ' ^
        bf2 = bfs                               ' ?
        bfs = WPos - bfs + 1                    ' Уточняем адрес
        siz = siz + 2                           ' Фигня, она и в Африке фигня :)
        For l = 1 To Retry                      ' Согласно количеству повторений
            If WPos <= 4096 Then                '  Если буфер не заполнен
                If bfs <= 4 Then                '   И если нам нагло указывают на пустое место...
                    'For d = 1 To 4
                    '    bte = Val("&H" & Mid(Right("00000000" & Hex(pos - 3), 8), d * 2 - 1, 2))
                    '    Put #3, epos, bte: epos = epos + 1
                    'Next d
                    'epos = epos + 2
                    'Put #3, epos, PosByte1: epos = epos + 1
                    'Put #3, epos, PosByte2: epos = epos + 1
                    epf = True
                    WPos = WPos + 1           '    Просто игнорируем
                    GoTo er                     '    И пропускаем байт
                    'Exit For
                End If                          '
            End If                              '
            'If bfs <= LOF(1) Then              '
                Get #5, bfs, bte                ' Получаем байт,
                Put #5, WPos, bte: WPos = WPos + 1 ' Пишем его
er:                                             ' При пустом байте буфера
            buf = buf + 1                       ' Увеличиваем
            If buf >= 4096 Then buf = buf - 4096    ' И нормализуем буфер
            bfs = bfs + 1                       ' Позиция чтения+1
            'End If                             '
        Next l                                  '
    End If                                      '
Next n                                          '
Wend                                            '
absend:
FSZ = siz                                       '
                                           '
'APB.Value = 1                                   '
If epf = True Then
    mepos = msepos
    mrpos = mrspos
    epf = False
End If
If mepos > 0 Then
    Open file1 & ".err" For Binary As 3
    For d = 1 To 4
        bte = Val("&H" & Mid(Right("00000000" & Hex(mepos - 1), 8), d * 2 - 1, 2))
        Put #3, d, bte:
    Next d
    For d = 5 To 8
        bte = Val("&H" & Mid(Right("00000000" & Hex(mrpos), 8), (d - 4) * 2 - 1, 2))
        Put #3, d, bte:
    Next d
End If
Close 1
Close 5
Close 3
End Sub


Private Sub Command6_Click()
Call LoadTable(file8)
Open file1 For Binary As 5
Open filePST For Binary As 2
mnps = Ist(MinPos)
mxps = Ist(MaxPos)
rzps = mxps - mnps
'If ComprCheck.Value = 1 Then
'    Open Left(file5, Len(file5) - 7) & "unc.scr.fhx" For Binary As 2
'    Open file5 For Binary As 5
'Else
'    Open Left(file1, Len(file1) - 4) & ".scr.fhx" For Binary As 2
'    Open file1 For Binary As 5
'End If
For n = 1 To LOF(5)
    Get #5, n, bte
    Put #2, n, bte
Next n
For n = 1 To Val(SizePnt)
    Get #5, Ist(MinPnt) + n, bte
    Poi = Poi + bte * 256 ^ (n - 1)
Next n
'Open file2 & ".rus" For Input As 1
Open FileText For Input As 1
'LoadTable (file8)
Line Input #1, lin
ppos = Ist(MinPnt) + 1 + Val(SizePnt)
'ppos = ppos + Val(SizePnt)
pos = mnps + 1
While Not EOF(1)
    Line Input #1, lin
    If lin = "@" Then
        GoTo sob
    End If
    For n = 1 To Len(lin)
        s = Mid(lin, n, 1)
        If s = "{" Then
            If Mid(lin, n + 3, 1) = "}" Then
                bte = Val("&H" & Mid(lin, n + 1, 2))
                Put #2, pos, bte: pos = pos + 1
                n = n + 3
                GoTo fnd
            End If
        End If
        For l = 1 To T.C
            If s = T.T(l) Then
                Put #2, pos, T.V(l): pos = pos + 1
                GoTo fnd
            End If
        Next l
        bte = Asc(s)
        'MsgBox Asc(s)
        Put #2, pos, bte: pos = pos + 1
fnd:
    plen = plen + 1
    If plen > rzps Then
        Print "!"
        Close
        Exit Sub
    End If
    Next n
    If Right(lin, 1) = "\" Then 'Правка поинтера
sob:
        a = ""
        For l = 1 To Val(SizePnt)
            a = a & "00"
        Next l
        
        If ppos <= Ist(MaxPnt) Then
        For l = 1 To Val(SizePnt)
            bte = Ist("&H" & Mid(Right(a & Hex(Poi + plen), Val(SizePnt) * 2), l * 2 - 1, 2))
            'MsgBox Right(a & Hex(Poi + plen), Val(SizePnt))
            If lin = "@" Then
                For n = ppos - Val(SizePnt) To ppos - 1
                    Put #2, n, 0
                Next n
            End If
                Put #2, ppos + Val(SizePnt) - l, bte
        Next l
        ppos = ppos + Val(SizePnt)
        End If
    End If
Wend
Close 1
Close 2
Close 5
End Sub

Private Sub Command7_Click()

Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "Файлы настройки (*.ini)" _
        + Chr$(0) + "*.ini" + Chr$(0) + "Текстовые файлы (*.txt)" _
        + Chr$(0) + "*.txt" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие конфига"
Dial.File = ShowOpen
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
Else
    file6 = Dial.File
End If
End Sub

Private Sub Command8_Click()
Call LoadConfig(file6)
End Sub

Private Sub Command9_Click()
Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "Файлы таблиц (*.tbl)" _
        + Chr$(0) + "*.tbl" + Chr$(0) + "Текстовые файлы (*.txt)" _
        + Chr$(0) + "*.txt" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие таблицы"
Dial.File = ShowOpen
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
Else
    file8 = Dial.File
End If
End Sub



Private Sub List_DblClick()
If Cn.Compr(List.ItemData(List.ListIndex)) = True Then ComprCheck.Value = 1 Else ComprCheck.Value = 0
file2 = Cn.Path & "SCRIPTS\" & Left(Cn.FN(List.ItemData(List.ListIndex)), Len(Cn.FN(List.ItemData(List.ListIndex))) - 4) & ".scr.txt"
file1 = Cn.Path & Cn.FN(List.ItemData(List.ListIndex))
file5 = Cn.Path & "UNCOMPRESS\" & Left(Cn.FN(List.ItemData(List.ListIndex)), Len(Cn.FN(List.ItemData(List.ListIndex))) - 4) & ".unc.fhx"
SizePnt = Cn.PSz(List.ItemData(List.ListIndex))
MinPnt = "&H" & Hex(Cn.PS(List.ItemData(List.ListIndex)))
MaxPnt = "&H" & Hex(Cn.PE(List.ItemData(List.ListIndex)))
MinPos = "&H" & Hex(Cn.TS(List.ItemData(List.ListIndex)))
MaxPos = "&H" & Hex(Cn.TE(List.ItemData(List.ListIndex)))
Cmnts = Cn.Comments(List.ItemData(List.ListIndex))
Ids = Cn.ID(List.ItemData(List.ListIndex))
End Sub

Private Sub PasteButton_Click()
pos = Ist(ImgPos)
Open file1 For Binary As 1
Open fileIMG For Binary As 2
For n = 1 To LOF(1)
    Get #1, n, bte
    Put #2, n + pos, bte
Next n
Close 1
Close 2
End Sub
