VERSION 5.00
Object = "{63E5F280-E28C-11D4-BF3F-A7DE75CE211C}#1.0#0"; "AdvProgressBar.ocx"
Begin VB.Form Form1 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Анализатор текста -- Совет: Пользуйтесь всплывающими подсказками."
   ClientHeight    =   7410
   ClientLeft      =   45
   ClientTop       =   315
   ClientWidth     =   10455
   ForeColor       =   &H00000000&
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7410
   ScaleWidth      =   10455
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command15 
      Caption         =   "Command15"
      Height          =   255
      Left            =   2880
      TabIndex        =   53
      Top             =   5760
      Width           =   1095
   End
   Begin VB.CommandButton Command14 
      Caption         =   "Command14"
      Height          =   255
      Left            =   4440
      TabIndex        =   52
      Top             =   5760
      Width           =   1095
   End
   Begin VB.TextBox DicWriAdrEnd 
      Height          =   285
      Left            =   1080
      TabIndex        =   51
      Text            =   "3f80f"
      Top             =   5760
      Width           =   855
   End
   Begin VB.TextBox DicWriCou 
      Height          =   285
      Left            =   2040
      TabIndex        =   50
      Text            =   "80"
      Top             =   5760
      Width           =   735
   End
   Begin VB.TextBox DicWriAdrBeg 
      Height          =   285
      Left            =   120
      TabIndex        =   49
      Text            =   "3f770"
      Top             =   5760
      Width           =   855
   End
   Begin VB.CheckBox AutoOprCheck 
      Caption         =   "Автоопределение"
      Height          =   255
      Left            =   7680
      TabIndex        =   48
      Top             =   1560
      Value           =   1  'Отмечено
      Width           =   1695
   End
   Begin VB.CheckBox FastCheck 
      Caption         =   "Ускорить процесс"
      Height          =   255
      Left            =   7680
      TabIndex        =   47
      Top             =   2160
      Value           =   1  'Отмечено
      Width           =   2055
   End
   Begin VB.TextBox MinEconomy 
      Height          =   285
      Left            =   3600
      TabIndex        =   46
      Text            =   "1"
      Top             =   2160
      Width           =   1215
   End
   Begin VB.TextBox MinLineLen 
      Height          =   285
      Left            =   3600
      TabIndex        =   30
      Text            =   "2"
      Top             =   1920
      Width           =   1215
   End
   Begin VB.TextBox MaxLineLen 
      Height          =   285
      Left            =   3600
      TabIndex        =   27
      Text            =   "2"
      Top             =   1680
      Width           =   1215
   End
   Begin VB.TextBox DCount 
      Height          =   285
      Left            =   3600
      TabIndex        =   5
      Text            =   "80"
      Top             =   1440
      Width           =   1215
   End
   Begin VB.CommandButton Command11 
      Caption         =   "?"
      Enabled         =   0   'False
      Height          =   255
      Left            =   7080
      TabIndex        =   43
      Top             =   1800
      Width           =   375
   End
   Begin VB.CommandButton Command13 
      Caption         =   "Генерировать"
      Height          =   255
      Left            =   5760
      TabIndex        =   44
      Top             =   1800
      Width           =   1335
   End
   Begin VB.CommandButton Command12 
      Caption         =   "Очистить"
      Height          =   195
      Left            =   120
      TabIndex        =   42
      Top             =   960
      Width           =   1335
   End
   Begin AdvanceProgressBar.AdvProgressBar APB 
      Height          =   255
      Left            =   120
      Top             =   2520
      Width           =   10215
      _ExtentX        =   18018
      _ExtentY        =   450
      Appearance      =   1
      BackColor       =   -2147483633
      BorderStyle     =   1
      Caption         =   ""
      Enabled         =   -1  'True
      FloodColor      =   192
      ForeColor       =   16777215
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      HelpContextID   =   0
      Max             =   100
      Min             =   0
      OLEDropMode     =   0
      Orientation     =   0
      Style           =   1
      Object.WhatsThisHelpID =   0
   End
   Begin VB.CommandButton Command10 
      Caption         =   "Определить..."
      Height          =   255
      Left            =   7680
      TabIndex        =   40
      Top             =   1200
      Width           =   2535
   End
   Begin VB.TextBox MemSize 
      Height          =   285
      Left            =   9240
      TabIndex        =   38
      Text            =   "16777216"
      Top             =   840
      Width           =   975
   End
   Begin VB.TextBox StopByte 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   5760
      MaxLength       =   2
      TabIndex        =   10
      Text            =   "00"
      Top             =   1440
      Width           =   375
   End
   Begin VB.CommandButton Command6 
      Caption         =   "?"
      Enabled         =   0   'False
      Height          =   255
      Left            =   7080
      TabIndex        =   21
      Top             =   1200
      Width           =   375
   End
   Begin VB.CommandButton Command2 
      Caption         =   "..."
      Enabled         =   0   'False
      Height          =   255
      Left            =   6720
      TabIndex        =   13
      Top             =   1200
      Width           =   375
   End
   Begin VB.CommandButton Command7 
      Caption         =   "?"
      Enabled         =   0   'False
      Height          =   255
      Left            =   7080
      TabIndex        =   22
      Top             =   960
      Width           =   375
   End
   Begin VB.CommandButton Command3 
      Caption         =   "..."
      Enabled         =   0   'False
      Height          =   255
      Left            =   6720
      TabIndex        =   17
      Top             =   960
      Width           =   375
   End
   Begin VB.TextBox AllDCount 
      Enabled         =   0   'False
      Height          =   285
      Left            =   3600
      TabIndex        =   35
      Top             =   960
      Width           =   1215
   End
   Begin VB.CommandButton Command9 
      Caption         =   "+"
      Height          =   255
      Left            =   1200
      TabIndex        =   34
      Top             =   720
      Width           =   255
   End
   Begin VB.TextBox sAdr 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   120
      MaxLength       =   4
      TabIndex        =   2
      Text            =   "30"
      Top             =   720
      Width           =   495
   End
   Begin VB.TextBox LenTwo 
      Alignment       =   2  'Центровка
      Enabled         =   0   'False
      Height          =   285
      Left            =   6720
      MaxLength       =   2
      TabIndex        =   25
      Text            =   "00"
      Top             =   1440
      Width           =   735
   End
   Begin VB.CommandButton Command8 
      Caption         =   "?"
      Enabled         =   0   'False
      Height          =   255
      Left            =   7080
      TabIndex        =   23
      Top             =   720
      Width           =   375
   End
   Begin VB.CommandButton Command5 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   8280
      TabIndex        =   20
      Top             =   120
      Width           =   975
   End
   Begin VB.CommandButton Command4 
      Caption         =   "..."
      Height          =   255
      Left            =   6720
      TabIndex        =   19
      Top             =   720
      Width           =   375
   End
   Begin VB.CheckBox Check1 
      Caption         =   "Двойное сжатие:"
      Height          =   255
      Left            =   5040
      TabIndex        =   16
      Top             =   960
      Width           =   1695
   End
   Begin VB.TextBox Interval 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   10680
      TabIndex        =   14
      Text            =   "0"
      Top             =   2760
      Width           =   495
   End
   Begin VB.CheckBox StopTableChk 
      Caption         =   "Стоп-таблица:"
      Height          =   255
      Left            =   5040
      TabIndex        =   12
      Top             =   1200
      Width           =   1575
   End
   Begin VB.TextBox AllText 
      Height          =   2895
      Left            =   120
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Оба
      TabIndex        =   7
      Top             =   2760
      Width           =   10215
   End
   Begin VB.TextBox DSize 
      Enabled         =   0   'False
      Height          =   285
      Left            =   3600
      TabIndex        =   4
      Top             =   720
      Width           =   1215
   End
   Begin VB.TextBox eAdr 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   720
      MaxLength       =   4
      TabIndex        =   3
      Text            =   "7F"
      Top             =   720
      Width           =   495
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Старт!"
      Height          =   255
      Left            =   9360
      TabIndex        =   1
      Top             =   120
      Width           =   975
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "LNB\KRUPTAR\text2.txt"
      Top             =   120
      Width           =   8055
   End
   Begin VB.CheckBox TwoBytes 
      Caption         =   "Два байта"
      Height          =   195
      Left            =   240
      TabIndex        =   6
      Top             =   1200
      Value           =   1  'Отмечено
      Width           =   1095
   End
   Begin VB.ListBox TList 
      Height          =   1035
      ItemData        =   "Form1.frx":0000
      Left            =   120
      List            =   "Form1.frx":0002
      TabIndex        =   33
      Top             =   1440
      Width           =   1335
   End
   Begin VB.Label Label16 
      Alignment       =   1  'Правая привязка
      Caption         =   "Минимальная экономия:"
      Height          =   255
      Left            =   1560
      TabIndex        =   45
      ToolTipText     =   "Элементы, у которых количество сэкономленных байт будет меньше этого значения, будут игнорироваться."
      Top             =   2160
      Width           =   1935
   End
   Begin VB.Label Label3 
      Alignment       =   1  'Правая привязка
      Caption         =   "Стоп-байт"
      Height          =   255
      Left            =   5040
      TabIndex        =   11
      Top             =   1440
      Width           =   735
   End
   Begin VB.Label Label14 
      Caption         =   "Кол-во элементов:"
      Height          =   255
      Left            =   7680
      TabIndex        =   39
      ToolTipText     =   $"Form1.frx":0004
      Top             =   840
      Width           =   1455
   End
   Begin VB.Label Label11 
      Alignment       =   1  'Правая привязка
      Caption         =   "Количество результатов:"
      Height          =   255
      Left            =   1560
      TabIndex        =   36
      ToolTipText     =   "Количество наилучших результатов."
      Top             =   1440
      Width           =   1935
   End
   Begin VB.Label Label10 
      Alignment       =   2  'Центровка
      Caption         =   "-"
      Height          =   255
      Left            =   600
      TabIndex        =   32
      Top             =   720
      Width           =   135
   End
   Begin VB.Label Label12 
      Alignment       =   1  'Правая привязка
      Caption         =   "Мин. длина элемента:"
      Height          =   255
      Left            =   1800
      TabIndex        =   31
      ToolTipText     =   "Минимальная длина элемента.  Элементы с длиной меньше этого значения будут игнорироваться."
      Top             =   1920
      Width           =   1695
   End
   Begin VB.Label Label7 
      Alignment       =   1  'Правая привязка
      Caption         =   "Макс. длина элемента:"
      Height          =   255
      Left            =   1680
      TabIndex        =   26
      ToolTipText     =   "Максимальная длина элемента. Элементы с длиной больше этого значения будут игнорироваться."
      Top             =   1680
      Width           =   1815
   End
   Begin VB.Label Label6 
      Alignment       =   1  'Правая привязка
      Caption         =   "Длина:"
      Enabled         =   0   'False
      Height          =   255
      Left            =   6120
      TabIndex        =   24
      Top             =   1440
      Width           =   615
   End
   Begin VB.Label Label5 
      Alignment       =   1  'Правая привязка
      Caption         =   "Таблица:"
      Height          =   255
      Left            =   5880
      TabIndex        =   18
      Top             =   720
      Width           =   735
   End
   Begin VB.Label Label4 
      Alignment       =   1  'Правая привязка
      Caption         =   "Интервал:"
      Height          =   255
      Left            =   10440
      TabIndex        =   15
      Top             =   2520
      Width           =   855
   End
   Begin VB.Label Label2 
      Alignment       =   1  'Правая привязка
      Caption         =   "Количество элементов:"
      Enabled         =   0   'False
      Height          =   255
      Left            =   1680
      TabIndex        =   9
      Top             =   960
      Width           =   1815
   End
   Begin VB.Label Label1 
      Alignment       =   1  'Правая привязка
      Caption         =   "Размер словаря(байт):"
      Enabled         =   0   'False
      Height          =   255
      Left            =   1680
      TabIndex        =   8
      Top             =   720
      Width           =   1815
   End
   Begin VB.Label Label8 
      Alignment       =   2  'Центровка
      BorderStyle     =   1  'Фиксировано один
      Caption         =   "Параметры словаря:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   204
         Weight          =   700
         Underline       =   -1  'True
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00404040&
      Height          =   2055
      Left            =   1440
      TabIndex        =   28
      Top             =   480
      Width           =   3495
   End
   Begin VB.Label Label13 
      Alignment       =   2  'Центровка
      BorderStyle     =   1  'Фиксировано один
      Caption         =   "Таблицы:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   204
         Weight          =   700
         Underline       =   -1  'True
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00404040&
      Height          =   2055
      Left            =   4920
      TabIndex        =   37
      Top             =   480
      Width           =   2655
   End
   Begin VB.Label Label9 
      Alignment       =   2  'Центровка
      BackStyle       =   0  'Прозрачно
      BorderStyle     =   1  'Фиксировано один
      Caption         =   "Таблица:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   204
         Weight          =   700
         Underline       =   -1  'True
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00404040&
      Height          =   2055
      Left            =   120
      TabIndex        =   29
      Top             =   480
      Width           =   1335
   End
   Begin VB.Label Label15 
      Alignment       =   2  'Центровка
      BorderStyle     =   1  'Фиксировано один
      Caption         =   "Выделение памяти:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   204
         Weight          =   700
         Underline       =   -1  'True
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00404040&
      Height          =   2055
      Left            =   7560
      TabIndex        =   41
      Top             =   480
      Width           =   2775
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Check1_Click()
If Command3.Enabled = False Then
    Command3.Enabled = True
    If TwoTable.en = True Then Command7.Enabled = True
Else
    Command3.Enabled = False
    Command7.Enabled = False
End If
End Sub

Private Sub Command1_Click()
If AutoOprCheck.Value = 1 Then
    Call Command10_Click
End If

Open file1 For Input As 1
While Not EOF(1)
Line Input #1, lin
lns = lns + 1
Wend
Close
ReDim Temp(1 To Val(MemSize))
ReDim iCount(1 To Val(MemSize))
ReDim Gold(1 To Val(MemSize))
ReDim Flag(1 To Val(MemSize))
ReDim NewWord(1 To Val(MemSize))
'                                                   [1/4]
If FastCheck.Value = 1 Then '_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_==Fast!!!
'MsgBox "Ещё не готово!"
Open file1 For Input As 1
APB.Max = lns ^ 2 '\ 10000 + 10 'lns
APB.Min = 1
WordCount = 1
If Val(MaxLineLen) > 0 Then t = Val(MaxLineLen) Else t = Len(lin)
If Val(MinLineLen) <= 0 Then
    If TwoBytes.Value = 1 Then r = 5 Else r = 3
Else
    r = Val(MinLineLen)
End If
ReDim NewWord(r To t, Val(MemSize))
ReDim NewCount(r To t) As Integer
ReDim NewiCount(r To t, Val(MemSize))
For n = r To t
    NewCount(n) = 1
Next n
While Not EOF(1)
Line Input #1, lin
lnt = lnt + 1
APB.Value = lns * lnt 'Sqr((Val(MemSize) * WordCount)) ' \ 1000 'WordCount 'lnt
APB.Caption = Cnt & "/[" & MemSize & "]  -  Строки: " & lnt & "/" & lns & "    [1/4]"
For n = t To r Step -1
    For c = 1 To Len(lin) - n + 1
        word = Mid(lin, c, n)
        If word = "должен" Then
            a = b
        ElseIf word = " должен" Then
            a = b
        ElseIf word = "должен " Then
            a = b
        End If
        For l = 1 To NewCount(Len(word))
             If NewWord(Len(word), l) = word Then
                NewiCount(Len(word), l) = NewiCount(Len(word), l) + 1
                GoTo foundFast
            End If
        Next l
            Cnt = Cnt + 1
            NewiCount(Len(word), NewCount(Len(word))) = 1
            NewWord(Len(word), NewCount(Len(word))) = word
            'MsgBox NewWord(Len(word), WordCount)
            NewCount(Len(word)) = NewCount(Len(word)) + 1
            If Cnt = Val(MemSize) Then GoTo EndPhase1a
foundFast:
    Next c
Next n
Wend
EndPhase1a:
Cnt = 0
For n = r To t
    NewCount(n) = NewCount(n) - 1
Next n
For n = t To r Step -1
    For c = 1 To NewCount(n)
        'For l = 1 To NewiCount(n, c)
            Cnt = Cnt + 1
            Temp(Cnt) = NewWord(n, c)
            iCount(Cnt) = NewiCount(n, c)
        'Next l
    Next c
Next n
WordCount = Cnt
Cnt = 0
ReDim NewiCount(0)
ReDim NewCount(0)
ReDim NewWord(1 To Val(MemSize))
Else            '_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
Open file1 For Input As 1
APB.Max = lns ^ 2 '\ 10000 + 10 'lns
APB.Min = 1
WordCount = 1
If Val(MaxLineLen) > 0 Then t = Val(MaxLineLen) Else t = Len(lin)
If Val(MinLineLen) <= 0 Then
    If TwoBytes.Value = 1 Then r = 5 Else r = 3
Else
    r = Val(MinLineLen)
End If
While Not EOF(1)
Line Input #1, lin
lnt = lnt + 1
APB.Value = lns * lnt 'Sqr((Val(MemSize) * WordCount)) ' \ 1000 'WordCount 'lnt
APB.Caption = WordCount & "/[" & MemSize & "]  -  Строки: " & lnt & "/" & lns & "    [1/4]"
For n = t To r Step -1
    For c = 1 To Len(lin) - n + 1
        word = Mid(lin, c, n)
        For l = 1 To WordCount
             If Temp(l) = word Then
                iCount(l) = iCount(l) + 1
                GoTo found
            End If
        Next l
            iCount(WordCount) = 1
            Temp(WordCount) = word
            WordCount = WordCount + 1
            If WordCount = Val(MemSize) Then GoTo EndPhase1b
found:
    Next c
Next n
Wend
EndPhase1b:
WordCount = WordCount - 1
End If
'                                                   [2/4] Сортировка по длине.
Close
If TwoBytes.Value = 1 Then btl = 2 Else btl = 1
'--
'MsgBox 1
'GoTo skip2
ReDim LenWord(1 To WordCount)
ReDim LenCount(1 To WordCount)
ReDim Flag(1 To WordCount)
Cnt = 1
APB.Value = r
APB.Min = r
APB.Max = t + 0.01
For c = t To r Step -1
    APB.Value = c
    APB.Caption = r & "/" & t & "  -  [2/4]"
    For n = 1 To WordCount
        If LenWord(Cnt) = "должен" Then
            a = b
        End If
        If LenWord(Cnt) = " должен" Then
            a = b
        End If
        If LenWord(Cnt) = "должен " Then
            a = b
        End If
        If Len(Temp(n)) = c And Flag(n) = False Then
            Flag(n) = True
            LenWord(Cnt) = Temp(n): LenCount(Cnt) = iCount(n)
            'MsgBox LenWord(Cnt)
            Cnt = Cnt + 1
        End If
    Next n
Next c
Cnt = Cnt - 1
For n = 1 To Cnt
    Temp(n) = LenWord(n)
    iCount(n) = LenCount(n)
Next n
ReDim Flag(1 To WordCount)
ReDim LenWord(0)
ReDim LenCount(0)
Cnt = 0
skip2:
'--
For n = 1 To WordCount
    If Temp(n) = "должен" Then
        a = b
    End If
    Gold(n) = (Len(Temp(n)) - btl) * iCount(n) - Len(Temp(n)) 'iCount(n) * (Len(Temp(n)) - btl) - Len(Temp(n))
Next n
'--
'                                                   [3/4] Сортировка по экономии
Dim MxEl As Long
ReDim NewiCount(1 To WordCount)
ReDim NewGold(1 To WordCount)
ReDim Flag(1 To WordCount)
APB.Min = 1
APB.Max = WordCount + 1
While Cnt < WordCount 'For c = 1 To WordCount
APB.Value = Cnt + 1
APB.Caption = Cnt & "/" & WordCount & "    [3/4]"
    For n = WordCount To 1 Step -1
        If Flag(n) = False Then
            If mx < Gold(n) Then
                MxEl = n
                mx = Gold(n)
            End If
        End If
    Next n
    Flag(MxEl) = True
    Cnt = Cnt + 1
    NewGold(Cnt) = Gold(MxEl)
    NewiCount(Cnt) = iCount(MxEl)
    NewWord(Cnt) = Temp(MxEl)
    'Flag(Cnt) = True
    For n = WordCount To 1 Step -1
        If Flag(n) = False Then
            If Gold(n) = mx Then
                Cnt = Cnt + 1
                NewGold(Cnt) = Gold(n)
                NewiCount(Cnt) = iCount(n)
                NewWord(Cnt) = Temp(n)
                Flag(n) = True
            End If
        End If
    Next n
    If mx <= Val(MinEconomy) Then GoTo wendEnd
    mx = 0
Wend 'Next n
wendEnd:
APB.Caption = ""
APB.Value = 1
'--
'ReDim LenWord(1 To Val(MemSize))
'Dim LenFlag(1 To 2048) As Boolean
'Dim LenCnt(1 To 2048) As Integer
'ReDim LenGold(1 To Val(MemSize)) As Integer
'ReDim LenSort(1 To 128, 1 To 2048)
'APB.Min = 1
'APB.Max = NewGold(1) * 2 + 1
'    APB.Caption = "Сорт"
'For n = NewGold(1) To 1 Step -1
'    APB.Value = APB.Value + 1
'    For c = 1 To Cnt 'r To t
'        If NewGold(c) = n Then
'            LenSort(n, LenCnt(n)) = c
'            LenCnt(n) = LenCnt(n) + 1
'        ElseIf NewGold(c) < n Then
'            Exit For
'        End If
'    Next c
'Next n
'For n = NewGold(1) To 1 Step -1
'    APB.Value = APB.Value + 1
'    For l = 1 To LenCnt(n)
'        For c = 1 To LenCnt(n)
'            If mx < NewGold(LenSort(n, c)) Then
'                MxEl = c
'                mx = Gold(n)
'            End If
'        Next c
'        lncnt = lncnt + 1
'        LenFlag(lncnt) = True
'        LenWord(lncnt) = NewWord(MxEl)
'        LenGold(lncnt) = NewGold(MxEl)
'    Next l
'Next n
'APB.Caption = ""
'APB.Value = 1
'=-
Open file1 For Input As 1
'Open "~txtlnbtatemp.txt" For Output As 2
ReDim NewFlag(1 To WordCount)
APB.Max = lns + 1
APB.Min = 1
'For n = 1 To Cnt
'    If NewFlag(n) = True Then MsgBox "!!!"
'Next n
'                                                   [4/4]
ReDim wline(lns) As String
ReDim FilterCount(1 To WordCount) As Integer
ReDim Opened(1 To WordCount) As Boolean
n = 0
While Not EOF(1)
    n = n + 1
    Line Input #1, wline(n)
Wend
Close
APB.Value = APB.Value + 1
APB.Caption = APB.Value - 1 & "/" & lns & "    [4/4]"
For n = 1 To WordCount
    For c = 1 To lns
'If NewWord(n) = "должен " Or NewWord(n) = "должен " Or NewWord(n) = "должен " Then
'    a = b
'End If
pos = 1
Stad3:
        If NewWord(n) = "" Then GoTo Stad3Next
        'MsgBox wline(c)
        inst = InStr(pos, wline(c), NewWord(n))
        If inst > 0 Then
            pos = pos + inst
            FilterCount(n) = FilterCount(n) + 1
            If NewiCount(n) = FilterCount(n) Then
                NewFlag(n) = True
                linCnt = linCnt + 1
                For l = 1 To lns
Stad3adv:
                    inst = InStr(wline(l), NewWord(n))
                    If inst > 0 Then
                        wline(l) = Left(wline(l), inst - 1) & Right(wline(l), Len(wline(l)) - inst + 1 - Len(NewWord(n)))
                        'linCnt = linCnt + 1
                        GoTo Stad3adv
                    End If
                Next l
                Exit For
            End If
            'MsgBox lin
            GoTo Stad3
        'Else
        '    NewFlag(n) = False
        End If
    Next c
Stad3Next:
Next n
'- Подсчёт
Dim sss As Long
For n = 1 To Cnt
    If NewFlag(n) = True Then sss = sss + 1
Next n
'-
'GoTo dssd
'ReDim Temp(1 To sss)
'ReDim iCount(1 To sss)
'APB.Min = 1
'APB.Max = Cnt
'For c = 1 To Cnt
'APB.value = c
'APB.Caption = c & "/" & WordCount & "    [4/3]"
'    For n = 1 To Cnt
'        If Flag(n) = False Then
'            If mx < Gold(n) Then
'                MxEl = n
'                mx = Gold(n)
'            End If
'        End If
'    Next n
'    Flag(MxEl) = True
'    Cnt = Cnt + 1
'    NewiCount(Cnt) = iCount(MxEl)
'    NewWord(Cnt) = Temp(MxEl)
'    mx = 0
'Next c
'APB.Caption = ""
'APB.value = 1
'dssd:
'MsgBox "End!"
Dim cnt2 As Long
'DCount = 100
If Val(DCount) <= 0 Then s = Cnt Else s = Val(DCount)
'For n = 1 To s
n = 0
AllText = ""
While cnt2 < s
    If n = WordCount Then GoTo EndSub
    n = n + 1
    If NewFlag(n) = True Then
        cnt2 = cnt2 + 1
        AllText = AllText & cnt2 & "). " & Chr(34) & NewWord(n) & Chr(34) & "  ->  [" & NewiCount(n) & "] Экономия: " & NewGold(n) & vbCrLf
        'MsgBox NewWord(n) & " " & n & " _ " & NewiCount(n)
    End If
Wend
EndSub:
n = 0
'Next n
APB.Caption = ""
APB.Value = 1
End Sub

Private Sub Command10_Click()

Open file1 For Input As 1
While Not EOF(1)
Line Input #1, lin
lns = lns + 1
Wend
Close
Open file1 For Input As 1
APB.Max = lns
APB.Min = 1
Tmp = 0
If Val(MaxLineLen) > 0 Then t = Val(MaxLineLen) Else t = Len(lin)
If Val(MinLineLen) <= 0 Then
    If TwoBytes.Value = 1 Then r = 5 Else r = 2
Else
    r = Val(MinLineLen)
End If
While Not EOF(1)
Line Input #1, lin
lnt = lnt + 1
APB.Value = lnt
APB.Caption = Tmp
For n = t To r Step -1
    For c = 1 To Len(lin) - n + 1
        Tmp = Tmp + 1
    Next c
Next n
Wend
Close
MemSize = Tmp
MemRec = Tmp
APB.Value = 1
APB.Caption = ""
End Sub


Private Sub Command11_Click()
TableView.Caption = "Сгенерированная таблица"
Call ShowMeTable("GenTable")
End Sub

Private Sub Command12_Click()
For n = 1 To TList.ListCount
    TList.RemoveItem (0)
Next n
End Sub

Private Sub Command13_Click()
'For n = 1 To Val(AllDCount)
'    GenTable.strng(1)=
If Val(DCount) <= 0 Then s = Cnt Else s = Val(DCount)
ReDim GenTable.Value(1 To s)
ReDim GenTable.strng(1 To s)
Dim cnt2 As Long
While cnt2 < s
    If n = WordCount Then Exit Sub 'GoTo EndSub
    n = n + 1
    If NewFlag(n) = True Then
        cnt2 = cnt2 + 1
        GenTable.strng(cnt2) = NewWord(n)
        GenTable.Value(cnt2) = Val(Adr.sAdr1(adrn)) * 256 + Val(Adr.sAdr2(adrn)) + cnt2 - 1
        'AllText = AllText & cnt2 & "). " & Chr(34) & NewWord(n) & Chr(34) & "  ->  [" & NewiCount(n) & "] Экономия: " & NewGold(n) & vbCrLf
        'MsgBox Hex(GenTable.Value(cnt2)) & "=" & GenTable.strng(cnt2)
        GenTable.count = cnt2
    End If
Wend
'GenTable.count = cnt2
End Sub

Private Sub Command15_Click()

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
    Exit Sub
Else
    file2 = Dial.File
End If

Open file2 For Binary As 1
'MsgBox "Открыт."
pos = Val("&H" & DicWriAdrBeg) + 1
For n = 1 To GenTable.count
    'If pos + Len(GenTable.strng(n)) > Val("&H" & DicWriAdrBeg) Then Exit Sub
    For c = 1 To Len(GenTable.strng(n))
        tw = Mid(GenTable.strng(n), c, 1)
        For l = 1 To Table.count
            If Table.Table(l) = tw Then
                bte = Table.Value(l)
                Put #1, pos, bte: pos = pos + 1
                MsgBox "Пишу по таблице " & Hex(bte) & "(" & tw & ")" & " по адресу " & Hex(pos - 2)
                GoTo est
            End If
        Next l
        bte = Asc(tw)
        Put #1, pos, bte: pos = pos + 1
        MsgBox "Пишу без таблицы " & Hex(bte) & " по адресу " & Hex(pos - 2)
est:
    Next c
Next n
Close
End Sub

Private Sub Command2_Click()
StopTable.File = ""
Dial.Backup = Dial.File
Dial.Form = Me.hWnd
Dial.Filter = "Файлы таблиц (*.tbl)" _
        + Chr$(0) + "*.tbl" + Chr$(0) + "Текстовые файлы (*.txt)" _
        + Chr$(0) + "*.txt" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие файла"
Dial.File = ShowOpen
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
    Exit Sub
Else
    StopTable.File = Dial.File
End If
If StopTable.File = "" Then Exit Sub

StopTable.count = 0
Open StopTable.File For Input As 1
While Not EOF(1)
    Line Input #1, lin
    If Len(lin) > 0 Then
        If Len(lin) = 1 Then
            StopTable.count = StopTable.count + 1
            StopTable.Temp(StopTable.count) = lin
        ElseIf InStr(lin, "=") > 0 Then
            If Not Len(lin) = InStr(lin, "=") Then
                If Len(Right(lin, Len(lin) - InStr(lin, "="))) = 1 Then
                    StopTable.count = StopTable.count + 1
                    StopTable.Temp(StopTable.count) = Right(lin, Len(lin) - InStr(lin, "="))
                End If
            End If
        End If
    End If
Wend
Close
ReDim StopTable.Table(1 To StopTable.count)
For n = 1 To StopTable.count
    StopTable.Table(n) = StopTable.Temp(n)
Next n
If StopTable.count > 0 Then
    Command6.Enabled = True
    StopTable.en = True
End If
End Sub

Private Sub Command3_Click()
TwoTable.File = ""
Dial.Backup = Dial.File
Dial.Form = Me.hWnd
Dial.Filter = "Файлы таблиц (*.tbl)" _
        + Chr$(0) + "*.tbl" + Chr$(0) + "Текстовые файлы (*.txt)" _
        + Chr$(0) + "*.txt" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие файла"
Dial.File = ShowOpen
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
    Exit Sub
Else
    TwoTable.File = Dial.File
End If
If TwoTable.File = "" Then Exit Sub

ReDim TwoTable.Length(2048)
TwoTable.count = 0
Open TwoTable.File For Input As 1
While Not EOF(1)
    Line Input #1, lin
    If Len(lin) > 0 Then
        If Len(lin) = 1 Then
            TwoTable.count = TwoTable.count + 1
            TwoTable.Temp(TwoTable.count) = lin
            'MsgBox TwoTable.Temp(TwoTable.Count)
        ElseIf InStr(lin, "=") > 0 Then
            If Not Len(lin) = InStr(lin, "=") Then
                TwoTable.count = TwoTable.count + 1
                TwoTable.Length(TwoTable.count) = (InStr(lin, "=") - 1) \ 2
                If (InStr(lin, "=") - 1) \ 2 <> (InStr(lin, "=") - 1) / 2 Then TwoTable.Length(TwoTable.count) = TwoTable.Length(TwoTable.count) + 1
                TwoTable.Temp(TwoTable.count) = Right(lin, Len(lin) - InStr(lin, "="))
                'MsgBox TwoTable.Temp(TwoTable.Count)
            End If
        End If
    End If
Wend
Close
ReDim TwoTable.Table(1 To TwoTable.count)
For n = 1 To TwoTable.count
    If TwoTable.Length(n) = 0 Then TwoTable.Length(n) = Val(LenTwo)
    TwoTable.Table(n) = TwoTable.Temp(n)
Next n
If TwoTable.count > 0 Then
    Command7.Enabled = True
    TwoTable.en = True
End If
End Sub

Private Sub Command4_Click()
Table.File = ""
Dial.Backup = Dial.File
Dial.Form = Me.hWnd
Dial.Filter = "Файлы таблиц (*.tbl)" _
        + Chr$(0) + "*.tbl" + Chr$(0) + "Текстовые файлы (*.txt)" _
        + Chr$(0) + "*.txt" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие файла"
Dial.File = ShowOpen
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
    Exit Sub
Else
    Table.File = Dial.File
End If
If Table.File = "" Then Exit Sub
Table.count = 0
Open Table.File For Input As 1
While Not EOF(1)
    Line Input #1, lin
    If Len(lin) > 0 Then
        If Len(lin) = 1 Then
            Table.count = Table.count + 1
            Table.Temp(Table.count) = lin
            'MsgBox Table.Temp(Table.Count)
        ElseIf InStr(lin, "=") > 0 Then
            If Not Len(lin) = InStr(lin, "=") Then
                Table.count = Table.count + 1
                Table.Temp(Table.count) = Right(lin, Len(lin) - InStr(lin, "="))
                Table.temp2(Table.count) = Val("&H" & Left(lin, InStr(lin, "=") - 1))
                'MsgBox Table.Temp(Table.Count)
            End If
        End If
    End If
Wend
Close
ReDim Table.Table(1 To Table.count)
ReDim Table.Value(1 To Table.count)
For n = 1 To Table.count
    Table.Table(n) = Table.Temp(n)
    Table.Value(n) = Table.temp2(n)
Next n
If Table.count > 0 Then Command8.Enabled = True
End Sub

Private Sub Command5_Click()
Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "Текстовые файлы (*.txt)" _
        + Chr$(0) + "*.txt" + Chr$(0) + "Все файлы (*.*)" _
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

Private Sub Command6_Click()
TableView.Caption = "Стоп-таблица таблица"
Call ShowMeTable("StopTable")
End Sub

Private Sub Command7_Click()
TableView.Caption = "Вторая таблица"
Call ShowMeTable("SecondTable")
End Sub

Private Sub Command8_Click()
Call ShowMeTable("Table")
TableView.Caption = "Главная таблица"
End Sub


Private Sub Command9_Click()
If TList.ListCount = 256 Then Exit Sub
TList.AddItem sAdr & " - " & eAdr
Adr.sAdr2(TList.ListCount - 1) = Val("&H" & Right(sAdr, 2))
Adr.sAdr1(TList.ListCount - 1) = Val("&H" & Left(sAdr, Len(sAdr) - 2))
Adr.eAdr2(TList.ListCount - 1) = Val("&H" & Right(eAdr, 2))
Adr.eAdr1(TList.ListCount - 1) = Val("&H" & Left(eAdr, Len(sAdr) - 2))
End Sub


Private Sub Form_Load()
'Label14.ToolTipText = "Для анализа будет браться только первые n элементов, где n - данное значение." & vbCrLf & _
"Нажмите" & Chr(34) & "Определить" & Chr(34) & ", чтобы автоматически выставилось" & _
"максимально возможное количество элементов."
'If Val(Interval) <= 0 Then
'    Interval = 0
'    StopByte.Enabled = False
'Else
'    StopByte.Enabled = True
'End If
MemRec = 16777216
End Sub


Private Sub Interval_Change()
'If Val(Interval) <= 0 Then
'    Interval = 0
'    StopByte.Enabled = False
'Else
'    StopByte.Enabled = True
'End If
End Sub


Private Sub MaxLineLen_Change()
Static TWV As Boolean
If Val(MaxLineLen) <= 2 Then
    If TwoBytes.Value = 1 Then TWV = True Else TWV = False
    TwoBytes.Value = 0
    TwoBytes.Enabled = False
Else
    If TWV = True Then
        TwoBytes.Value = 1
    End If
    TwoBytes.Enabled = True
End If
End Sub

Private Sub MemSize_LostFocus()
If Val(MemSize) <= 0 Then MemSize = MemRec
End Sub


Private Sub StopTableChk_Click()
If Command2.Enabled = False Then
    Command2.Enabled = True
    Label6.Enabled = True
    LenTwo.Enabled = True
    If StopTable.en = True Then Command6.Enabled = True
Else
    Command2.Enabled = False
    Command6.Enabled = False
    Label6.Enabled = False
    LenTwo.Enabled = False
End If
End Sub

Private Sub TList_Click()
'MsgBox Hex(Adr.sAdr1(TList.ListIndex)) & Hex(Adr.sAdr2(TList.ListIndex)) & " " & Hex(Adr.eAdr1(TList.ListIndex)) & Hex(Adr.eAdr2(TList.ListIndex))
End Sub

Private Sub TwoBytes_Click()
sAdr.MaxLength = 4
eAdr.MaxLength = 4
End Sub
