VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form QEdit 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Редактор файла вопросов"
   ClientHeight    =   10155
   ClientLeft      =   1065
   ClientTop       =   195
   ClientWidth     =   8775
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   10155
   ScaleWidth      =   8775
   ShowInTaskbar   =   0   'False
   Begin MSComctlLib.ProgressBar Progress 
      Height          =   255
      Left            =   240
      TabIndex        =   38
      Top             =   9720
      Width           =   8295
      _ExtentX        =   14631
      _ExtentY        =   450
      _Version        =   393216
      BorderStyle     =   1
      Appearance      =   0
      Min             =   1e-4
      Scrolling       =   1
   End
   Begin VB.Frame Frame11 
      Caption         =   "Работа с таблицами:"
      Height          =   975
      Left            =   3360
      TabIndex        =   27
      Top             =   5160
      Width           =   5295
      Begin VB.CommandButton Command14 
         Caption         =   "RUS->ENG"
         Enabled         =   0   'False
         Height          =   255
         Left            =   2160
         TabIndex        =   43
         Top             =   240
         Width           =   975
      End
      Begin VB.CommandButton Command12 
         Caption         =   "Восст. служ. знаки"
         Height          =   255
         Left            =   3240
         TabIndex        =   41
         Top             =   600
         Width           =   1935
      End
      Begin VB.CommandButton Command11 
         Caption         =   "Спасти служ. знаки"
         Height          =   255
         Left            =   1200
         TabIndex        =   40
         Top             =   600
         Width           =   1935
      End
      Begin VB.CommandButton Command10 
         Caption         =   "Показать таблицу"
         Enabled         =   0   'False
         Height          =   255
         Left            =   3240
         TabIndex        =   37
         Top             =   240
         Width           =   1935
      End
      Begin VB.CommandButton Command7 
         Caption         =   "ENG->RUS"
         Enabled         =   0   'False
         Height          =   255
         Left            =   1200
         TabIndex        =   30
         Top             =   240
         Width           =   975
      End
      Begin VB.OptionButton jobTable2 
         Caption         =   "Вторая"
         Enabled         =   0   'False
         Height          =   255
         Left            =   120
         TabIndex        =   29
         Top             =   600
         Width           =   855
      End
      Begin VB.OptionButton jobTable1 
         Caption         =   "Первая"
         Enabled         =   0   'False
         Height          =   255
         Left            =   120
         TabIndex        =   28
         Top             =   240
         Value           =   -1  'True
         Width           =   975
      End
   End
   Begin VB.CommandButton Command6 
      Caption         =   "Сохранить"
      Height          =   255
      Left            =   7560
      TabIndex        =   22
      Top             =   4680
      Width           =   975
   End
   Begin VB.Frame Frame4 
      Caption         =   "Параметры:"
      Height          =   3135
      Left            =   120
      TabIndex        =   9
      Top             =   6240
      Width           =   8535
      Begin VB.Frame Frame7 
         Caption         =   "Таблицы:"
         Height          =   1695
         Left            =   120
         TabIndex        =   15
         Top             =   1320
         Width           =   8295
         Begin VB.Frame Frame13 
            Caption         =   "Статус:"
            Height          =   615
            Left            =   4320
            TabIndex        =   35
            Top             =   840
            Width           =   3735
            Begin VB.TextBox statusTable2 
               BackColor       =   &H8000000F&
               Height          =   285
               Left            =   120
               Locked          =   -1  'True
               TabIndex        =   36
               Text            =   "Не загружена"
               Top             =   240
               Width           =   3495
            End
         End
         Begin VB.Frame Frame9 
            Caption         =   "Вторая:"
            Height          =   1335
            Left            =   4200
            TabIndex        =   18
            Top             =   240
            Width           =   3975
            Begin VB.CommandButton Command9 
               Caption         =   "Загрузить"
               Height          =   255
               Left            =   2880
               TabIndex        =   34
               Top             =   240
               Width           =   975
            End
            Begin VB.CommandButton Command5 
               Caption         =   "Обзор..."
               Height          =   255
               Left            =   1920
               TabIndex        =   21
               Top             =   240
               Width           =   855
            End
            Begin VB.TextBox fileTable2 
               Height          =   285
               Left            =   120
               TabIndex        =   20
               Top             =   240
               Width           =   1695
            End
         End
         Begin VB.TextBox fileTable1 
            Height          =   285
            Left            =   240
            TabIndex        =   16
            Text            =   "teenfnt.tbl"
            Top             =   480
            Width           =   1695
         End
         Begin VB.Frame Frame8 
            Caption         =   "Первая:"
            Height          =   1335
            Left            =   120
            TabIndex        =   17
            Top             =   240
            Width           =   3975
            Begin VB.CommandButton Command8 
               Caption         =   "Загрузить"
               Height          =   255
               Left            =   2880
               TabIndex        =   33
               Top             =   240
               Width           =   975
            End
            Begin VB.Frame Frame12 
               Caption         =   "Статус:"
               Height          =   615
               Left            =   120
               TabIndex        =   31
               Top             =   600
               Width           =   3735
               Begin VB.TextBox statusTable1 
                  BackColor       =   &H8000000F&
                  Height          =   285
                  Left            =   120
                  Locked          =   -1  'True
                  TabIndex        =   32
                  Text            =   "Не загружена"
                  Top             =   240
                  Width           =   3495
               End
            End
            Begin VB.CommandButton Command4 
               Caption         =   "Обзор..."
               Height          =   255
               Left            =   1920
               TabIndex        =   19
               Top             =   240
               Width           =   855
            End
         End
      End
      Begin VB.Frame Frame6 
         Caption         =   "Сохранение"
         Height          =   975
         Left            =   4320
         TabIndex        =   14
         Top             =   240
         Width           =   4095
         Begin VB.CommandButton Command13 
            Caption         =   "Command13"
            Height          =   255
            Left            =   3480
            TabIndex        =   42
            Top             =   480
            Width           =   255
         End
         Begin VB.OptionButton STable2 
            Caption         =   "Вторую"
            Enabled         =   0   'False
            Height          =   195
            Left            =   2280
            TabIndex        =   26
            Top             =   600
            Width           =   975
         End
         Begin VB.OptionButton STable1 
            Caption         =   "Первую"
            Enabled         =   0   'False
            Height          =   255
            Left            =   2280
            TabIndex        =   25
            Top             =   240
            Value           =   -1  'True
            Width           =   1575
         End
         Begin VB.CheckBox Check2 
            Caption         =   "При сохранении использовать таблицу"
            Height          =   495
            Left            =   120
            TabIndex        =   24
            Top             =   240
            Width           =   2055
         End
      End
      Begin VB.OptionButton LTable2 
         Caption         =   "Вторую"
         Enabled         =   0   'False
         Height          =   255
         Left            =   2400
         TabIndex        =   12
         Top             =   840
         Width           =   855
      End
      Begin VB.OptionButton LTable1 
         Caption         =   "Первую"
         Enabled         =   0   'False
         Height          =   255
         Left            =   2400
         TabIndex        =   11
         Top             =   480
         Value           =   -1  'True
         Width           =   975
      End
      Begin VB.CheckBox Check1 
         Caption         =   "При загрузке использовать таблицу"
         Height          =   495
         Left            =   240
         TabIndex        =   10
         Top             =   480
         Width           =   2055
      End
      Begin VB.Frame Frame5 
         Caption         =   "Загрузка:"
         Height          =   975
         Left            =   120
         TabIndex        =   13
         Top             =   240
         Width           =   4095
      End
   End
   Begin VB.TextBox mx 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   2280
      MaxLength       =   3
      TabIndex        =   6
      Text            =   "70"
      Top             =   5640
      Width           =   615
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Абзацы"
      Height          =   255
      Left            =   240
      TabIndex        =   5
      Top             =   5400
      Width           =   1695
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Загрузить"
      Height          =   255
      Left            =   6480
      TabIndex        =   4
      Top             =   4680
      Width           =   975
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   5400
      TabIndex        =   3
      Top             =   4680
      Width           =   975
   End
   Begin VB.TextBox Qfile 
      Height          =   285
      Left            =   240
      TabIndex        =   2
      Text            =   "arena\trans\QUESTION.TXT"
      Top             =   4680
      Width           =   5055
   End
   Begin VB.TextBox questions 
      Height          =   4095
      Left            =   240
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Оба
      TabIndex        =   0
      Text            =   "QEdit.frx":0000
      Top             =   240
      Width           =   8295
   End
   Begin VB.Frame Frame1 
      Caption         =   "Текст вопросов:"
      Height          =   4455
      Left            =   120
      TabIndex        =   1
      Top             =   0
      Width           =   8535
   End
   Begin VB.Frame Frame2 
      Caption         =   "Инт./кол.:"
      Height          =   615
      Left            =   2040
      TabIndex        =   7
      Top             =   5400
      Width           =   1095
   End
   Begin VB.Frame Frame3 
      Caption         =   "Расставить:"
      Height          =   975
      Left            =   120
      TabIndex        =   8
      Top             =   5160
      Width           =   3135
      Begin VB.CommandButton Command15 
         Caption         =   "Пробелы"
         Height          =   255
         Left            =   120
         TabIndex        =   44
         Top             =   600
         Width           =   1695
      End
   End
   Begin VB.Frame Frame10 
      Caption         =   "Файл вопросов:"
      Height          =   615
      Left            =   120
      TabIndex        =   23
      Top             =   4440
      Width           =   8535
   End
   Begin VB.Frame Frame14 
      Caption         =   "Прогресс:"
      Height          =   615
      Left            =   120
      TabIndex        =   39
      Top             =   9480
      Width           =   8535
   End
End
Attribute VB_Name = "QEdit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim NEWtable2(255) As String
Dim NEWtable1(255) As String
Dim table1(255) As String
Dim table2(255) As String
Private Sub Command10_Click()

If jobTable1 = True Then
        For n = 33 To 126
            If Not table1(n) = "" Then
                tableView = tableView + Hex(n) + "=" + table1(n) + vbCrLf
            End If
        Next n
        TabView.Show
        TabView.TabViewText = tableView
ElseIf jobTable2 = True Then
        For n = 33 To 126
            If Not table2(n) = "" Then
                tableView = tableView + Hex(n) + "=" + table2(n) + vbCrLf
            End If
        Next n
        TabView.Show
        TabView.TabViewText = tableView
End If

End Sub

Private Sub Command11_Click()
pos = 1
While a = 0
    znak = InStr(pos, questions, " (5v)")
    If znak = 0 Then
        a = 1
    Else
        'MsgBox znak
        lt = Left(questions, znak - 1)
        rt = Right(questions, Len(questions) - znak - 4)
        'MsgBox lt + " - " + rt
        questions = lt + "њ" + rt
    End If
Wend

pos = 1
a = 0
While a = 0
    znak = InStr(pos, questions, " (5l)")
    If znak = 0 Then
        a = 1
    Else
        'MsgBox znak
        lt = Left(questions, znak - 1)
        rt = Right(questions, Len(questions) - znak - 4)
        'MsgBox lt + " - " + rt
        questions = lt + "ќ" + rt
    End If
Wend

a = 0
pos = 1
While a = 0
    znak = InStr(pos, questions, " (5c)")
    If znak = 0 Then
        a = 1
    Else
        'MsgBox znak
        lt = Left(questions, znak - 1)
        rt = Right(questions, Len(questions) - znak - 4)
        'MsgBox lt + " - " + rt
        questions = lt + "ћ" + rt
    End If
Wend
End Sub

Private Sub Command12_Click()
pos = 1
While a = 0
    znak = InStr(pos, questions, "њ")
    If znak = 0 Then
        a = 1
    Else
        'MsgBox znak
        lt = Left(questions, znak - 1)
        rt = Right(questions, Len(questions) - znak)
        'MsgBox lt + " - " + rt
        questions = lt + " (5v)" + rt
    End If
Wend

pos = 1
a = 0
While a = 0
    znak = InStr(pos, questions, "ќ")
    If znak = 0 Then
        a = 1
    Else
        'MsgBox znak
        lt = Left(questions, znak - 1)
        rt = Right(questions, Len(questions) - znak)
        'MsgBox lt + " - " + rt
        questions = lt + " (5l)" + rt
    End If
Wend

a = 0
pos = 1
While a = 0
    znak = InStr(pos, questions, "ћ")
    If znak = 0 Then
        a = 1
    Else
        'MsgBox znak
        lt = Left(questions, znak - 1)
        rt = Right(questions, Len(questions) - znak)
        'MsgBox lt + " - " + rt
        questions = lt + " (5c)" + rt
    End If
Wend
End Sub

Private Sub Command13_Click()
MsgBox InStr(questions, vbCrLf)
End Sub

Private Sub Command14_Click()
If jobTable1 = True Then
    For n = 33 To 126
        If Not table1(n) = "" Then
            NEWtable1(Asc(table1(n))) = Chr(n)
            'MsgBox NEWtable1(Asc(table1(n)))
        End If
    Next n
    
    Progress.Min = 1
    Progress.Max = Len(questions) + 0.001
    For Number = 1 To Len(questions)
        bukva = Mid(questions, Number, 1)
        
        If Not NEWtable1(Asc(bukva)) = "" Then
        'MsgBox bukva & " - " & Asc(bukva)
            If Not NEWtable1(Asc(bukva)) = "" Then
                NEWbukva = NEWtable1(Asc(bukva))
                'MsgBox NEWbukva & " = " & NEWtable1(Asc(bukva))
            Else
                NEWbukva = bukva
                'MsgBox "="
            End If
        Else
            NEWbukva = bukva
        End If
        NEWquestions = NEWquestions + NEWbukva
        Progress = Number
    Next Number
    questions = NEWquestions
    'MsgBox NEWquestions
    Progress = 1
Else
 For n = 33 To 126
        If Not table2(n) = "" Then
            NEWtable2(Asc(table2(n))) = Chr(n)
            MsgBox NEWtable2(Asc(table2(n)))
        End If
    Next n
    
    Progress.Min = 1
    Progress.Max = Len(questions) + 0.001
    For Number = 1 To Len(questions)
        bukva = Mid(questions, Number, 1)
        
        If Not NEWtable2(Asc(bukva)) = "" Then
        'MsgBox bukva & " - " & Asc(bukva)
            If Not NEWtable2(Asc(bukva)) = "" Then
                NEWbukva = NEWtable2(Asc(bukva))
                'MsgBox NEWbukva & " = " & NEWtable1(Asc(bukva))
            Else
                NEWbukva = bukva
                'MsgBox "="
            End If
        Else
            NEWbukva = bukva
        End If
        NEWquestions = NEWquestions + NEWbukva
        Progress = Number
    Next Number
    questions = NEWquestions
    'MsgBox NEWquestions
    Progress = 1
End If
End Sub

Private Sub Command15_Click()

ps = 1
Progress.Min = 0.001
Progress.Max = Len(questions)
While Not ps = Len(questions)
    t = Mid(questions, ps, 2)
    If t = vbCrLf Then abz = abz + 1
    ps = ps + 1
    Progress = ps
Wend
'MsgBox abz

nm = 1
begin:

For h = 1 To abz + 1

pos = InStr(nm, questions, vbCrLf)
If pos = 0 Then pos = Len(questions) + 2
'MsgBox "pos = " & pos
lin = Mid(questions, nm, pos - 1)
'nm = nm + pos + 1
'MsgBox "lin = " & lin & "1"
'-----------------------------------'
For d = 1 To mx
    If Mid(lin, d, 1) = " " Then
        s = s + 1
    Else
        Exit For
    End If
Next d

If Not s = 0 Then
    nlin = Right(lin, Len(lin) - s)
Else
    nlin = lin
End If
'MsgBox nlin
'If Not s = mx Then
    For c = 1 To mx
        nlin = " " + nlin
    Next
'End If
'MsgBox nlin, , "2"

'-------------------'
nqst = nqst + nlin + vbCrLf
s = 0
'MsgBox nqst, , "3"
If Len(questions) - pos - 1 > 0 Then questions = Right(questions, Len(questions) - pos - 1)
Next h
'-------------------'
'GoTo begin
questions = Left(nqst, Len(nqst) - 2)
'MsgBox questions, , 4
Progress = 0.001
End Sub

Private Sub Command2_Click()

If Qfile = "" Then GoTo er
pth = InStrRev(Qfile, "\")
If pth <> 0 Then
    pth2 = Right(Qfile, Len(Qfile) - pth)
Else
    pth2 = Qfile
End If
'MsgBox pth2 & "_-_" & Dir(file1)
If Not pth2 = Dir(Qfile) Then GoTo er

GoTo beg
er:
    MsgBox "Указанный файл не существует!", , "Ошибка!"
    GoTo error
beg:
Open Qfile For Input As 1
questions = ""
While Not EOF(1)
    Line Input #1, qfl
''Input #1, qfl
''questions = qfl
    questions = questions + qfl + vbCrLf
Wend
questions = Left(questions, Len(questions) - 2)
Close 1

Progress.Min = 1
Progress.Max = 5

pos = 1
While a = 0
    znak = InStr(pos, questions, Chr(32) + Chr(10))
    If znak = 0 Then
        a = 1
    Else
        'MsgBox znak
        lt = Left(questions, znak - 1)
        rt = Right(questions, Len(questions) - znak - 1)
        'MsgBox lt + " - " + rt
        questions = lt + vbCrLf + rt
    End If
Wend
Progress = 2

a = 0
pos = 1
While a = 0
    znak = InStr(pos, questions, Chr(13) + Chr(10))
    If znak = 0 Then
        a = 1
    Else
        'MsgBox znak
        lt = Left(questions, znak - 1)
        rt = Right(questions, Len(questions) - znak - 1)
        'MsgBox lt + " - " + rt
        questions = lt + Chr(186) + rt
    End If
Wend

Progress = 3
'GoTo en
a = 0
pos = 1
While a = 0
    znak = InStr(pos, questions, Chr(10))
    If znak = 0 Then
        a = 1
    Else
        'MsgBox znak
        lt = Left(questions, znak - 1)
        rt = Right(questions, Len(questions) - znak)
        'MsgBox lt + " - " + rt
        questions = lt + Chr(186) + rt
    End If
Wend

Progress = 4

a = 0
pos = 1
While a = 0
    znak = InStr(pos, questions, Chr(186))
    If znak = 0 Then
        a = 1
    Else
        'MsgBox znak
        lt = Left(questions, znak - 1)
        rt = Right(questions, Len(questions) - znak)
        'MsgBox lt + " - " + rt
        questions = lt + vbCrLf + rt
    End If
Wend

Progress = 5
en:
Progress = 1

error:

End Sub

Private Sub Command3_Click()
MsgBox "Сегодня не работаю!", , "Ошибка!"
GoTo error
nm = 1
pos = InStr(nm, questions, vbCrLf)
If pos = 0 Then pos = Len(questions) + 2
'MsgBox "pos = " & pos
lin = Mid(questions, nm, pos - 2)
'MsgBox "lin = " & lin
kol = 0
'------------------------------'
'Обработка строки
temp = Left(lin, mx + 1) 'temp=первые 70 знаков
'MsgBox "temp = " & temp
lineobr:
pos2 = InStrRev(temp, " ")
If pos2 = 0 Then
    leftpart = temp
    pos2 = mx
    GoTo p20
End If
'MsgBox "pos2 = " & pos2
p20:
leftpart = Left(temp, pos2 - 1)
'rightpart = Right(temp, Len(temp) - pos2)
midpart = leftpart & vbCrLf
'MsgBox midpart
completepart = completepart & midpart
kol = kol + 1
templen = pos2 + templen
If Len(lin) - templen > mx Then
    temp = Mid(lin, templen + 1, mx + 1)
    GoTo lineobr
Else
    completepart = completepart & Right(lin, Len(lin) - templen)
    MsgBox completepart, , "УСЁ!!!!"
End If
'--------------------------------'
'Замена строки
en:
MsgBox "Итог: " & vbCrLf & completepart, , "Итог:"
questions = completepart
error:
End Sub

Private Sub Command6_Click()

SvQst = questions
pos = 1
While a = 0
    znak = InStr(pos, SvQst, vbCrLf)
    If znak = 0 Then
        a = 1
    Else
        'MsgBox znak
        lt = Left(SvQst, znak - 1)
        rt = Right(SvQst, Len(SvQst) - znak - 1)
        'MsgBox lt + " - " + rt
        SvQst = lt + Chr(32) + Chr(10) + rt
    End If
Wend


If Qfile = "" Then
    MsgBox "Введите путь к файлу!", , "Ошибка!"
    GoTo error1
End If

pth = InStrRev(Qfile, "\")
If pth <> 0 Then
    pth2 = Right(Qfile, Len(Qfile) - pth)
Else
    pth2 = Qfile
End If

If pth2 = Dir(Qfile) Then
    q = MsgBox("Файл уже существует, перезаписать?", vbYesNo, "Файл уже существует")
    If q = 7 Then GoTo error1
End If



Open Qfile For Output As 1

        Print #1, SvQst

Close

error1:
End Sub

Private Sub Command7_Click()
          
If jobTable1 = True Then
    Progress.Min = 1
    Progress.Max = Len(questions) + 0.001
    For Number = 1 To Len(questions)
        bukva = Mid(questions, Number, 1)
        If Asc(bukva) > 32 And Asc(bukva) < 127 Then
        'MsgBox bukva & " - " & Asc(bukva)
            If Not table1(Asc(bukva)) = "" Then
                NEWbukva = table1(Asc(bukva))
                'MsgBox NEWbukva & " = " & table1(Asc(bukva))
            Else
                NEWbukva = bukva
                'MsgBox "="
            End If
        Else
            NEWbukva = bukva
        End If
        NEWquestions = NEWquestions + NEWbukva
        Progress = Number
    Next Number
    questions = NEWquestions
    'MsgBox NEWquestions
    Progress = 1
    
Else
    Progress.Min = 1
    Progress.Max = Len(questions) + 0.001
    For Number = 1 To Len(questions)
        bukva = Mid(questions, Number, 1)
        If Asc(bukva) > 32 And Asc(bukva) < 127 Then
        'MsgBox bukva & " - " & Asc(bukva)
            If Not table2(Asc(bukva)) = "" Then
                NEWbukva = table2(Asc(bukva))
                'MsgBox NEWbukva & " = " & table1(Asc(bukva))
            Else
                NEWbukva = bukva
                'MsgBox "="
            End If
        Else
            NEWbukva = bukva
        End If
        NEWquestions = NEWquestions + NEWbukva
        Progress = Number
    Next Number
    questions = NEWquestions
    'MsgBox NEWquestions
    Progress = 1

End If
End Sub

Private Sub Command8_Click()

If fileTable1 = "" Then GoTo er
pth = InStrRev(fileTable1, "\")
If pth <> 0 Then
    pth2 = Right(fileTable1, Len(fileTable1) - pth)
Else
    pth2 = fileTable1
End If
'MsgBox pth2 & "_-_" & Dir(file1)
If Not pth2 = Dir(fileTable1) Then GoTo er
    
GoTo beg
er:
    MsgBox "Указанный файл не существует!", , "Ошибка!"
    GoTo error

beg:
Open fileTable1 For Input As 1

For n = 33 To 126
    table1(n) = ""
Next n

While Not EOF(1)
    Line Input #1, lne
    If Len(lne) = 4 Then
        If Mid(lne, 3, 1) = "=" Then
            If Val("&H" + Left(lne, 2)) > 32 And Val("&H" + Left(lne, 2)) < 127 Then
                table1(Val("&H" + Left(lne, 2))) = Right(lne, 1)
                'MsgBox Left(lne, 2) & " - " & Val("&H" + Left(lne, 2)) & " - " & table1(Val("&H" + Left(lne, 2)))
            End If
        End If
    End If
Wend
Close 1
table1(127) = 1
statusTable1 = "Таблица загружена: " & Dir(fileTable1)
Command7.Enabled = True
Command10.Enabled = True
Command14.Enabled = True
jobTable1.Enabled = True
If jobTable2.Enabled = False Then
    jobTable1.Value = True
End If
error:
    
End Sub

Private Sub Command9_Click()

If fileTable2 = "" Then GoTo er
pth = InStrRev(fileTable2, "\")
If pth <> 0 Then
    pth2 = Right(fileTable2, Len(fileTable2) - pth)
Else
    pth2 = fileTable2
End If
'MsgBox pth2 & "_-_" & Dir(file1)
If Not pth2 = Dir(fileTable2) Then GoTo er
    
GoTo beg
er:
    MsgBox "Указанный файл не существует!", , "Ошибка!"
    GoTo error

beg:
Open fileTable2 For Input As 2

For n = 33 To 126
    table2(n) = ""
Next n

While Not EOF(2)
    Line Input #2, lne
    If Len(lne) = 4 Then
        If Mid(lne, 3, 1) = "=" Then
            If Val("&H" + Left(lne, 2)) > 32 And Val("&H" + Left(lne, 2)) < 127 Then
                table2(Val("&H" + Left(lne, 2))) = Right(lne, 1)
                'MsgBox Left(lne, 2) & " - " & Val("&H" + Left(lne, 2)) & " - " & table1(Val("&H" + Left(lne, 2)))
            End If
        End If
    End If
Wend
Close 2
table2(127) = 1
statusTable2 = "Таблица загружена: " & Dir(fileTable1)
Command7.Enabled = True
Command10.Enabled = True
Command14.Enabled = True
jobTable2.Enabled = True
If jobTable1.Enabled = False Then
    jobTable2.Value = True
End If
error:

End Sub

