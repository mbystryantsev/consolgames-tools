VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Pack-Man - LZ77 archiver for PM2:TNA(SEGA)"
   ClientHeight    =   5280
   ClientLeft      =   45
   ClientTop       =   315
   ClientWidth     =   5670
   Icon            =   "Form1.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5280
   ScaleWidth      =   5670
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command7 
      Caption         =   "Распаковать!"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   14.25
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   465
      Left            =   2880
      TabIndex        =   34
      Top             =   1560
      Width           =   2655
   End
   Begin VB.TextBox MaxPoi 
      Height          =   285
      Left            =   2760
      TabIndex        =   30
      Top             =   4200
      Width           =   1215
   End
   Begin VB.TextBox MinPoi 
      Height          =   285
      Left            =   1320
      TabIndex        =   29
      Top             =   4200
      Width           =   1215
   End
   Begin VB.CommandButton Command6 
      Caption         =   "Пересчитать!"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   14.25
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   120
      TabIndex        =   28
      Top             =   4560
      Width           =   5415
   End
   Begin VB.TextBox MaxBlk 
      Height          =   285
      Left            =   2760
      MaxLength       =   10
      TabIndex        =   24
      Text            =   "&H1F0000"
      Top             =   2880
      Width           =   1215
   End
   Begin VB.TextBox MinBlk 
      Height          =   285
      Left            =   1200
      MaxLength       =   10
      TabIndex        =   23
      Text            =   "&H1E7B60"
      Top             =   2880
      Width           =   1215
   End
   Begin VB.CommandButton Command5 
      Caption         =   "Выполнить!"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   14.25
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   465
      Left            =   120
      TabIndex        =   21
      Top             =   3240
      Width           =   5415
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Обзор..."
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   8.25
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   4560
      TabIndex        =   20
      Top             =   2520
      Width           =   975
   End
   Begin VB.TextBox fileSCR 
      Height          =   285
      Left            =   720
      TabIndex        =   18
      Text            =   "PM\run2.scr.txt"
      Top             =   2520
      Width           =   3735
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Обзор..."
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   8.25
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   4560
      TabIndex        =   17
      Top             =   120
      Width           =   975
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Обзор..."
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   8.25
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   4560
      TabIndex        =   14
      Top             =   600
      Width           =   975
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Запаковать!"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   14.25
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   465
      Left            =   120
      TabIndex        =   12
      Top             =   1560
      Width           =   2775
   End
   Begin VB.HScrollBar HScroll 
      Height          =   135
      LargeChange     =   60
      Left            =   4440
      Max             =   2048
      Min             =   1
      SmallChange     =   30
      TabIndex        =   11
      Top             =   1440
      Value           =   2048
      Width           =   1095
   End
   Begin VB.TextBox Level 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   4440
      TabIndex        =   9
      Text            =   "2048"
      ToolTipText     =   "Степень сжатия. Чем больше - тем лучше и медленней сжатие."
      Top             =   1200
      Width           =   1095
   End
   Begin VB.TextBox Rt 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   3720
      MaxLength       =   2
      TabIndex        =   7
      Text            =   "5"
      ToolTipText     =   "Количество бит, отводящихся под количество повторений."
      Top             =   1200
      Width           =   495
   End
   Begin VB.TextBox Uk 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   3120
      MaxLength       =   2
      TabIndex        =   6
      Text            =   "11"
      ToolTipText     =   "Количество бит, отводящихся под указатель."
      Top             =   1200
      Width           =   495
   End
   Begin VB.TextBox Size 
      Height          =   285
      Left            =   1560
      MaxLength       =   10
      TabIndex        =   3
      Text            =   "600"
      ToolTipText     =   "Ограничение по размеру архива. Нужно, чтобы не испортить данные в РОМЕ, следующие за архивом."
      Top             =   1200
      Width           =   1215
   End
   Begin VB.TextBox Adres 
      Height          =   285
      Left            =   120
      MaxLength       =   10
      TabIndex        =   2
      Text            =   "&H"
      ToolTipText     =   "Адрес для вставки архива. Если хотите создать отдельный файл - пишите ""0"". Чтобы указать hex-адрес, надо приписать впереди ""&H""."
      Top             =   1200
      Width           =   1215
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   720
      TabIndex        =   1
      Text            =   "PM\GF\End\00187411.sgf"
      Top             =   600
      Width           =   3735
   End
   Begin VB.TextBox file2 
      ForeColor       =   &H00000080&
      Height          =   285
      Left            =   720
      TabIndex        =   0
      Text            =   "PM\PM.bin"
      Top             =   120
      Width           =   3735
   End
   Begin VB.Label Label11 
      Alignment       =   2  'Центровка
      Caption         =   "на"
      Height          =   255
      Left            =   2520
      TabIndex        =   33
      Top             =   4200
      Width           =   255
   End
   Begin VB.Label Label10 
      Caption         =   "конечный."
      Height          =   255
      Left            =   4080
      TabIndex        =   32
      Top             =   4200
      Width           =   1215
   End
   Begin VB.Label Label7 
      Alignment       =   1  'Правая привязка
      Caption         =   "Исходный"
      Height          =   255
      Left            =   120
      TabIndex        =   31
      Top             =   4200
      Width           =   1095
   End
   Begin VB.Label Pr3 
      Alignment       =   2  'Центровка
      Caption         =   "Рекалькулятор поинтеров Pack-Man"
      Height          =   255
      Left            =   120
      TabIndex        =   27
      Top             =   5040
      Width           =   5415
   End
   Begin VB.Line Line2 
      Index           =   1
      X1              =   120
      X2              =   5520
      Y1              =   4080
      Y2              =   4080
   End
   Begin VB.Label Label9 
      Alignment       =   2  'Центровка
      Caption         =   "—"
      Height          =   255
      Left            =   2400
      TabIndex        =   26
      Top             =   2880
      Width           =   375
   End
   Begin VB.Label Label8 
      Alignment       =   1  'Правая привязка
      Caption         =   "Блок:"
      Height          =   255
      Left            =   600
      TabIndex        =   25
      Top             =   2880
      Width           =   495
   End
   Begin VB.Label Pr2 
      Alignment       =   2  'Центровка
      Caption         =   "Обработчик скриптов Pack-Man"
      Height          =   255
      Left            =   120
      TabIndex        =   22
      Top             =   3720
      Width           =   5415
   End
   Begin VB.Line Line2 
      Index           =   0
      X1              =   120
      X2              =   5520
      Y1              =   2400
      Y2              =   2400
   End
   Begin VB.Label Label5 
      Alignment       =   1  'Правая привязка
      Caption         =   "Скрипт:"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   8.25
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   0
      TabIndex        =   19
      Top             =   2520
      Width           =   735
   End
   Begin VB.Label Label6 
      Alignment       =   1  'Правая привязка
      Caption         =   "Файл:"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   9
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   0
      TabIndex        =   16
      Top             =   600
      Width           =   615
   End
   Begin VB.Label Labe6 
      Alignment       =   1  'Правая привязка
      Caption         =   "РОМ:"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   9
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   0
      TabIndex        =   15
      Top             =   120
      Width           =   615
   End
   Begin VB.Label Pr 
      Alignment       =   2  'Центровка
      Caption         =   "LZ77 архиватор для игры 'Pac-Man 2: The New Adventures'"
      Height          =   255
      Left            =   120
      TabIndex        =   13
      Top             =   2040
      Width           =   5415
   End
   Begin VB.Label Label4 
      Alignment       =   2  'Центровка
      Caption         =   "Сжатие:"
      Height          =   255
      Left            =   4440
      TabIndex        =   10
      ToolTipText     =   "Степень сжатия. Чем больше - тем лучше и медленней сжатие."
      Top             =   960
      Width           =   1095
   End
   Begin VB.Label Label3 
      Alignment       =   2  'Центровка
      Caption         =   "Параметры:"
      Height          =   255
      Left            =   3120
      TabIndex        =   8
      ToolTipText     =   "Количество бит, отводящихся под указатель и под количество повторений."
      Top             =   960
      Width           =   1095
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Центровка
      Caption         =   "Макс. размер:"
      Height          =   255
      Left            =   1560
      TabIndex        =   5
      ToolTipText     =   "Ограничение по размеру архива. Нужно, чтобы не испортить данные в РОМЕ, следующие за архивом."
      Top             =   960
      Width           =   1215
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Центровка
      Caption         =   "Адрес:"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      ToolTipText     =   "Адрес для вставки архива. Если хотите создать отдельный файл - пишите ""0"". Чтобы указать hex-адрес, надо приписать впереди ""&H""."
      Top             =   960
      Width           =   1215
   End
   Begin VB.Line Line1 
      X1              =   120
      X2              =   5520
      Y1              =   480
      Y2              =   480
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
'Косметика :)
'If Dir(file1) <> "" And MsgBox("") = 7 Then Exit Sub
If Dir(file1) = "" Then MsgBox "Указанного вами файла для запаковки не существует!", vbCritical, "Ошибка пути файла!": Exit Sub
If Dir(file2) = "" Then
    If MsgBox("Указанного вами файла для вставки не существует, хотите создать его?", vbYesNo, "Ошибка пути файла!") = 7 Then
        Exit Sub
    End If
End If
Open file1 For Binary As 1
Dim LofF As Long
LofF = LOF(1)
Dim Max As Long
Dim Lev As Integer                              'Уровень сжатия
Dim PSz As Byte                                 'Размер указателя
Dim RSz As Byte                                 'Количество повторений
Dim UPos As Long                                'Позиция управляющего байта
Dim Pos As Long                                 'Позиция чтения
Dim WPos As Long                                'Позиция записи
Dim NPos As Long                                'Позиция лучшего результата повторений
Dim bte1 As Byte                                'Байт
Dim bte2 As Byte
Dim bte As Byte
Dim UByte As String                             'Биты управляющего байта
Dim n As Long                                   'Переменные
Dim c As Long                                   'для
Dim l As Long                                   'циклов
Dim FP As Long                                  'Начало чтения
'Dim PC As Long                                  'Прибавка к позиции
Dim SCnt As Integer                             'Счётчик повторений
Dim NSCnt As Integer                            'Максимальное кол-во повторений(лучший результат счётчика)
Dim btes As String
Dim MaxSz As Long

If ScrReg = True Then
    MaxSz = Val(Size)
    Size = 2097152
End If


ReDim Arc(Val(Size) - 1)                        'Максимальный размер архива
ReDim Fil(LofF - 1)                             'Загружаемый файл

Get #1, 1, Fil()                                'Загружаем файл
Close 1
PSz = Val(Uk)
Max = Val(Size)
RSz = Val(Rt)
Lev = Val(Level)
Arc(0) = PSz                                    'Первый байт - байт параметров
UByte = "1"                                     'Т.к. нам неоткуда брать байты
Arc(2) = Fil(0)                                 'пишем первый байт
'Arc(3) = Fil(1)
'Arc(4) = Fil(2)
'Arc(5) = Fil(3)
'Arc(6) = Fil(4)
'Arc(7) = Fil(5)
'Arc(8) = Fil(7)
'Arc(9) = Fil(8)
UPos = 1: Pos = 1: WPos = 3                     'Выставляем позиции
Begin:                                          'Собственно, запаковка
Pr = Pos & "/" & LofF & " [" & Int(Pos / LofF * 100 + 1) & "%]": Pr.Refresh
FP = Pos - Lev: NSCnt = 0                       'Начало чтения согласно ограничениям
If FP < 0 Then FP = 0
For n = FP To Pos - 1                           'От начала чтения до текущей позиции - 1

    SCnt = 0:                                   'Обнуляем счётчик повторений
ReadNext:
    If Pos + SCnt < LofF Then
        If Fil(n + SCnt) = Fil(Pos + SCnt) Then      'Если байты совпали
            SCnt = SCnt + 1                         'Кол-во повторений +1
            GoTo ReadNext                           'Читаем следующий
        End If
    End If
    If SCnt > NSCnt And SCnt > 2 Then           'Если новый результат лучше предыдущего лучшего
        NSCnt = SCnt                            'записываем его
        NPos = n
        If NSCnt >= 2 ^ PSz Then Exit For
    End If
Next n
If NSCnt > 2 Then                               'Если результат стоит того
    If NSCnt >= 2 ^ RSz Then NSCnt = 0
    If Pos - NPos >= 2 ^ PSz Then
        btes = UB(0, NSCnt, PSz)
    Else
        btes = UB(Pos - NPos, NSCnt, PSz)
    End If
    bte1 = GetByte(Left(btes, 8))               'Составляем управляющий байт
    bte2 = GetByte(Right(btes, 8))
    Arc(WPos) = bte1: Arc(WPos + 1) = bte2
    WPos = WPos + 2
    If NSCnt = 0 Then
        Pos = Pos + 2 ^ RSz
    Else
        Pos = Pos + NSCnt
    End If
    UByte = "0" & UByte
Else                                            'А если не стоит
    If WPos >= Max Then
        Beep
        Pr = "Ошибка! Размер архива больше указанного максимального размера!"
        Exit Sub
    End If
    Arc(WPos) = Fil(Pos): WPos = WPos + 1       'То просто пишем один байт
    Pos = Pos + 1
    UByte = "1" & UByte
End If
If Len(UByte) >= 7 Then                         'Если управляющий байт готов
    Arc(UPos) = GetByte("1" & UByte)            'Пишем его
    UByte = "": UPos = WPos: WPos = WPos + 1
End If
If Pos >= LofF Then                             'Если всё
    If Len(UByte) > 0 Then
        Arc(UPos) = GetByte(Right("00000000" & "1" & UByte, 8))
    End If
    Arc(WPos) = 0
    GoTo Paste
End If
GoTo Begin
Paste:
If ScrReg = True Then
RetINI:
    If WPos > ASz Then
        If Ist(MaxBlk) - BlockPos < WPos Then
            MsgBox "PM Error 2"
            Exit Sub
            'MinBlk = InputBox("")
            'MaxBlk = InputBox("")
            GoTo RetINI
        End If
        MinPoi = Adres
        MaxPoi = BlockPos
        Adres = BlockPos
        BPAdd = WPos
        Call Command6_Click
    End If
Size = ASz
End If
Open file2 For Binary As 2
Pos = 0
For n = Ist(Adres) + 1 To Ist(Adres) + 1 + WPos
    Put #2, n, Arc(Pos): Pos = Pos + 1
Next n
Close 2
Pr = "Готово!"
Pr.Refresh
MinPoi = Adres
Beep
End Sub


Private Sub Command2_Click()

Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие РОМа"
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
Dial.Filter = "РОМы SEGA (*.gen, *.bin, *.smd)" _
        + Chr$(0) + "*.bin;*.gen;*.smd" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие РОМа"
Dial.File = ShowOpen
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
Dial.Filter = "Текстовые файлы (*.txt)" _
        + Chr$(0) + "*.txt" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие РОМа"
Dial.File = ShowOpen
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
Else
    fileSCR = Dial.File
End If
End Sub

Private Sub Command5_Click()
Dim nLines As Integer
Dim lin As String
Dim Prb As String
Dim Prb2 As String
Dim path As String
Dim cnt As Integer
Dim InpFile As String
Dim ade As Long

ScrReg = True
Open fileSCR For Input As 10
While Not EOF(10)
    Line Input #10, lin
    nLines = nLines + 1
Wend
Close 10
Open fileSCR For Input As 10
While Not EOF(10)
    cnt = cnt + 1
    Pr2 = cnt & "/" & nLines & " [" & Int((cnt / nLines) * 100 + 0.5) & "%]"
    Pr2.Refresh
    Line Input #10, lin
    Prb = Probel(lin, 1)
    If Left(Prb, 1) = "'" Then
    ElseIf Prb = "end" Then 'Конец
        GoTo endsb
    ElseIf Prb = "set" Then 'Установка
        Prb2 = Probel(lin, 2)
        If Prb2 = "rom" Then
            file2 = Probel(lin, 3)
        ElseIf Prb2 = "path" Then
            path = Probel(lin, 3)
        ElseIf Prb2 = "opt" Then
            Uk = Val(Probel(lin, 3))
        ElseIf Prb2 = "level" Then
            Level = Val(Probel(lin, 3))
        ElseIf Prb2 = "min" Then
            MinBlk = Probel(lin, 3)
            BlockPos = MinBlk
        ElseIf Prb2 = "max" Then
            MaxBlk = Probel(lin, 3)
        ElseIf Prb2 = "pst" Then
            InpFile = Probel(lin, 3)
        End If
    ElseIf Prb = "arc" Then 'Запаковка
        file1 = path & Probel(lin, 2)
        Adres = Probel(lin, 3)
        If Adres = "*" Then
            Adres = "&H" & Mid(Right(file1, 12), 1, 8)
        End If
        ASz = Val(Probel(lin, 4))
        Call Command1_Click
    'ElseIf Prb = "pst" Then
    '    If Probel(lin, 3) = "*" Then
    '        ade = Ist("&H" & Mid(Right(Probel(lin, 2), 12), 1, 8))
    '    Else
    '        ade = Ist(Probel(lin, 3))
    '    End If
    '    Call Paste(InpFile, file2, ade, Val(Probel(lin, 4)))
    End If
Wend
endsb:
ScrReg = False
Close 10
Pr2.Caption = "Готово!"
End Sub

Private Sub Command6_Click()
Dim cnt As Integer
Dim LofF As Long
Dim PntTxt As String
Dim nPntTxt As String
Open file2 For Binary As 12
LofF = LOF(12)
ReDim nFil(LofF)
Dim byt(1 To 4) As Byte
Dim nbyt(1 To 4) As Byte
Get #12, 1, nFil()
'Close 12
'nFil(5) = nFil(6)

PreSearch:
'MsgBox Hex(Ist(MinPoi))
PntTxt = Nul("&H" & Hex(Ist(MinPoi)))
For n = 1 To 7 Step 2
    s = Mid(PntTxt, n, 2)
    byt((n + 1) / 2) = Val("&H" & s)
Next n
nPntTxt = Nul("&H" & Hex(Ist(MaxPoi)))
For n = 1 To 7 Step 2
    s = Mid(nPntTxt, n, 2)
    nbyt((n + 1) / 2) = Val("&H" & s)
Next n
Search:
'byt(1) = byt(1)
'byt(2) = byt(2)
'byt(3) = byt(3)
'byt(4) = byt(4)

For n = 0 To LofF - 4 Step 2
cnt = 1
cn:
If cnt = 5 Then
    For c = n To n + 3
        'nFil(c) = byt((n - c) + 1)
        Put #12, c + 1, nbyt((c - n) + 1)
    Next c
    Pr3 = n & "/" & LofF & " [" & Int((n / LofF) * 100 + 0.5) & "]%"
    Pr3.Refresh
GoTo nn
End If
'If n >= 55620 Then
'    a = a
'End If
If byt(cnt) = nFil(n + cnt - 1) Then
    cnt = cnt + 1
    GoTo cn:
Else
    cnt = 1
End If
'byt(4) = 1
nn:
Next n
'Open file2 For Binary As 12
'For n = 0 To LofF
'    Put #12, n + 1, nFil(n)
'Next n
Close 12
Pr3 = "Готово!"
Pr3.Refresh
If ScrReg = True Then
    BlockPos = BlockPos + BPAdd + 1
End If
End Sub

Private Sub Command7_Click()
Open file2 For Binary As 1
ReDim Fil(LOF(1) - 1)
ReDim Arc(1048575)
Dim sz As Long 'Размер файла
Dim Lv As Integer 'Степень сжатия
Close 1
Dim UByte As Byte
Pos = Ist(Adres) + 1
Lv = Fil(Pos - 1)
'
UByte = Fil(Pos): Pos = Pos + 1
If UByte = 0 Then a = d
If GetBit(UByte, 8) = 1 Then
Else
    Arc(sz) = Fil(Pos): Pos = Pos + 1: sz = sz + 1
End If
UByte = UByte \ 2
GoTo Retry:
End Sub

Private Sub Form_Load()
'Me.Hide
'Form2.Show
End Sub

Private Sub HScroll_Change()
Level = HScroll
End Sub

Private Sub HScroll_Scroll()
Level = HScroll
End Sub

Private Sub Level_LostFocus()
If Val(Level) > 2 ^ Val(Uk) Then Level = 2 ^ Val(Uk)
If Val(Level) < 1 Then Level = 1
HScroll = Val(Level)
End Sub


Private Sub Rt_LostFocus()
If Val(Rt) > 15 Then Rt = 15
If Val(Rt) < 1 Then Rt = 1
Uk = 16 - Val(Rt)
End Sub

Private Sub Uk_LostFocus()
If Val(Uk) > 15 Then Uk = 15
If Val(Uk) < 1 Then Uk = 1
Rt = 16 - Val(Uk)
HScroll.Max = 2 ^ Val(Uk)
End Sub

Public Sub Paste(IFl As String, OFl As String, AD As Long, sz As Long)
Open IFl For Binary As 21
Open OFl For Binary As 22
Dim bte As Byte
For n = BlockPos + 1 To BlockPos + sz + 1
    Get #21, AD + (n - BlockPos), bte
    Put #22, n, bte
Next n
MinPoi = AD
MaxPoi = BlockPos
Adres = BlockPos
BPAdd = sz
Close 21
Close 22
Call Command6_Click
End Sub
