VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Редактор скриптов Cave Story"
   ClientHeight    =   8535
   ClientLeft      =   1020
   ClientTop       =   1470
   ClientWidth     =   13155
   Icon            =   "Form1.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Picture         =   "Form1.frx":0442
   ScaleHeight     =   8535
   ScaleWidth      =   13155
   Begin VB.CommandButton ReAllButton 
      Caption         =   ">>"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   -1  'True
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   5040
      TabIndex        =   22
      ToolTipText     =   "Обработать ВСЁ (не советую, теряется литературность)"
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton ReBlockButton 
      Caption         =   ">>"
      Enabled         =   0   'False
      Height          =   375
      Left            =   4680
      TabIndex        =   20
      ToolTipText     =   "Обработать данный блок"
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton ReButton 
      Caption         =   ">"
      Enabled         =   0   'False
      Height          =   375
      Left            =   4320
      TabIndex        =   19
      ToolTipText     =   "Обработать данную строку"
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Enabled         =   0   'False
      Height          =   375
      Left            =   6120
      TabIndex        =   18
      Top             =   0
      Visible         =   0   'False
      Width           =   375
   End
   Begin VB.CommandButton SearchButton 
      Enabled         =   0   'False
      Height          =   375
      Left            =   3600
      Picture         =   "Form1.frx":0884
      Style           =   1  'Graphical
      TabIndex        =   16
      ToolTipText     =   "Найти..."
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton ShowMsgButton 
      Enabled         =   0   'False
      Height          =   375
      Left            =   2880
      Picture         =   "Form1.frx":09CE
      Style           =   1  'Graphical
      TabIndex        =   14
      ToolTipText     =   "Показать изменённое сообщение"
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton OpenOptScrButton 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      Picture         =   "Form1.frx":0E10
      Style           =   1  'Graphical
      TabIndex        =   13
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton OptScrButton 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1440
      Picture         =   "Form1.frx":1252
      Style           =   1  'Graphical
      TabIndex        =   12
      Top             =   0
      Width           =   375
   End
   Begin VB.ListBox NewList 
      Appearance      =   0  'Плоска
      Enabled         =   0   'False
      Height          =   3540
      ItemData        =   "Form1.frx":1694
      Left            =   6600
      List            =   "Form1.frx":1696
      TabIndex        =   8
      Top             =   360
      Width           =   6495
   End
   Begin VB.CommandButton Command5 
      Caption         =   ">"
      Height          =   255
      Left            =   6420
      TabIndex        =   7
      Top             =   7920
      Width           =   200
   End
   Begin VB.CommandButton Command4 
      Caption         =   "<"
      Height          =   255
      Left            =   6240
      TabIndex        =   6
      Top             =   7920
      Width           =   200
   End
   Begin VB.CommandButton Vosst 
      Caption         =   "<|"
      DownPicture     =   "Form1.frx":1698
      Height          =   255
      Left            =   12840
      Picture         =   "Form1.frx":1ADA
      TabIndex        =   5
      Top             =   7920
      Visible         =   0   'False
      Width           =   255
   End
   Begin VB.TextBox file1 
      Appearance      =   0  'Плоска
      BackColor       =   &H8000000F&
      Height          =   285
      Left            =   6600
      Locked          =   -1  'True
      TabIndex        =   3
      ToolTipText     =   "Открытый файл"
      Top             =   0
      Width           =   6495
   End
   Begin VB.TextBox RightText 
      Appearance      =   0  'Плоска
      Enabled         =   0   'False
      Height          =   4215
      Left            =   6600
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Оба
      TabIndex        =   2
      Top             =   3960
      Width           =   6495
   End
   Begin VB.TextBox LeftText 
      Appearance      =   0  'Плоска
      Enabled         =   0   'False
      Height          =   4215
      Left            =   0
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Оба
      TabIndex        =   1
      Top             =   3960
      Width           =   6495
   End
   Begin VB.ListBox List 
      Appearance      =   0  'Плоска
      Enabled         =   0   'False
      Height          =   3540
      ItemData        =   "Form1.frx":200C
      Left            =   0
      List            =   "Form1.frx":200E
      TabIndex        =   0
      Top             =   360
      Width           =   6495
   End
   Begin VB.CommandButton ShowOrMsg 
      Enabled         =   0   'False
      Height          =   375
      Left            =   2520
      Picture         =   "Form1.frx":2010
      Style           =   1  'Graphical
      TabIndex        =   15
      ToolTipText     =   "Показать оригинальное сообщение"
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton SaveCopyAsButton 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1080
      Picture         =   "Form1.frx":2452
      Style           =   1  'Graphical
      TabIndex        =   17
      ToolTipText     =   "Сохранить копию как..."
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton SaveAsButton 
      Enabled         =   0   'False
      Height          =   375
      Left            =   720
      Picture         =   "Form1.frx":2894
      Style           =   1  'Graphical
      TabIndex        =   11
      ToolTipText     =   "Сохранить как..."
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton SaveButton 
      Enabled         =   0   'False
      Height          =   375
      Left            =   360
      Picture         =   "Form1.frx":2CD6
      Style           =   1  'Graphical
      TabIndex        =   10
      ToolTipText     =   "Сохранить..."
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton OpenButton 
      Height          =   375
      Left            =   0
      Picture         =   "Form1.frx":3118
      Style           =   1  'Graphical
      TabIndex        =   9
      ToolTipText     =   "Открыть..."
      Top             =   0
      Width           =   375
   End
   Begin VB.Label StLn 
      Caption         =   "Максимальная длина строки: "
      Height          =   255
      Left            =   8400
      TabIndex        =   21
      Top             =   8280
      Width           =   2775
   End
   Begin VB.Label CntTxt 
      Alignment       =   2  'Центровка
      Caption         =   "_"
      Height          =   255
      Left            =   4560
      TabIndex        =   4
      ToolTipText     =   $"Form1.frx":355A
      Top             =   8280
      Width           =   3735
   End
   Begin VB.Menu mFile 
      Caption         =   "Файл"
      Index           =   0
      Begin VB.Menu mOpen 
         Caption         =   "Открыть..."
         Shortcut        =   ^O
      End
      Begin VB.Menu mSave 
         Caption         =   "Сохранить"
         Enabled         =   0   'False
         Shortcut        =   ^S
      End
      Begin VB.Menu mSaveAs 
         Caption         =   "Сохранить как..."
         Enabled         =   0   'False
      End
      Begin VB.Menu mSaveCopyAs 
         Caption         =   "Сохранить копию как..."
         Enabled         =   0   'False
      End
      Begin VB.Menu mMakeS 
         Caption         =   "Создать оптимизированный скрипт..."
         Enabled         =   0   'False
      End
      Begin VB.Menu mLoadS 
         Caption         =   "Загрузить оптимизированный скрипт..."
         Enabled         =   0   'False
      End
      Begin VB.Menu mExit 
         Caption         =   "Выход"
         Shortcut        =   ^Q
      End
   End
   Begin VB.Menu mEdit 
      Caption         =   "Правка"
      Begin VB.Menu mFind 
         Caption         =   "Найти..."
         Enabled         =   0   'False
         Shortcut        =   ^F
      End
      Begin VB.Menu mFindNext 
         Caption         =   "Найти далее..."
         Enabled         =   0   'False
         Shortcut        =   {F3}
      End
      Begin VB.Menu mReplace 
         Caption         =   "Заменить..."
         Enabled         =   0   'False
         Shortcut        =   ^H
      End
      Begin VB.Menu mLook 
         Caption         =   "Просмотреть исходный текст блока..."
         Enabled         =   0   'False
      End
      Begin VB.Menu mChLook 
         Caption         =   "Просмотреть изменённый текст блока..."
         Enabled         =   0   'False
      End
   End
   Begin VB.Menu mView 
      Caption         =   "Вид"
      Begin VB.Menu mOrText 
         Caption         =   "Окно оригинального текста"
      End
      Begin VB.Menu mChText 
         Caption         =   "Окно изменённого текста"
      End
      Begin VB.Menu mAllText 
         Caption         =   "Оба окна текста"
         Checked         =   -1  'True
      End
   End
   Begin VB.Menu mHelp 
      Caption         =   "Помощь"
      Begin VB.Menu mAbout 
         Caption         =   "О программе..."
      End
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub LoadScript()
If Opened = True Then
    For n = 1 To List.ListCount
        List.RemoveItem (0)
    Next n
    For n = 1 To NewList.ListCount
        NewList.RemoveItem (0)
    Next n
    code = ""
    For n = 1 To Word.count
        Word.clear(n) = False
    Next n
    script = ""
    txt = ""
    If EditType = True Then
        For n = 1 To Word.count
            msg.clear(n) = False
            msg.count(n) = 0
        Next n
        msg.flag = False
    End If
    Word.count = 0
End If
CntTxt = "Подождите..."
CntTxt.Refresh
'On Error GoTo ext
Open file1 For Input As 1
While Not EOF(1)
    Line Input #1, txt
    script = script & txt & vbCrLf
Wend
'MsgBox Right(script, 100)
ext:
Close

code = script
Word.count = 1
Word.pos = 1
'MsgBox InStr(code, "<MSG")
StartIf:
If InStr(code, "<MSG") > 0 Then
    Word.Text(Word.count) = Left(code, InStr(code, "<MSG") + 3)
    'MsgBox Left(Word.text(Word.count), 100) & "..." & vbCrLf & "..." & Right(Word.text(Word.count), 100)
    Word.clear(Word.count) = False
    Word.pos = Word.pos + InStr(code, "<MSG") + 3
    Word.count = Word.count + 1
    code = Right(code, Len(code) - InStr(code, "<MSG") - 3)
   ' Тег открыт
    'MsgBox code
    Word.Text(Word.count) = Left(code, InStr(code, "<END") - 1)
    'MsgBox Left(Word.text(Word.count), 100) & "..." & vbCrLf & "..." & Right(Word.text(Word.count), 100)
    Word.clear(Word.count) = True
    Word.pos = Word.pos + InStr(code, "<END") ' - 1
    Word.count = Word.count + 1
    code = Right(code, Len(code) - InStr(code, "<END") + 1)
    ' Тег закрыт
    GoTo StartIf
Else
    Word.count = Word.count + 1
    Word.Text(Word.count) = code
End If
'MsgBox Word.count

'GoTo skp
If EditType = True Then
    For n = 1 To 2048
        If n = Word.count Then Exit For
        If Word.clear(n) = True Then
            msg.clear(n) = True
            msg.num = 0
            msg.pos = 1
RetryMsg:
            msg.strn = InStr(msg.pos, Word.Text(n), "<")
            msg.nstr = InStr(msg.pos, Word.Text(n), "#")
            If msg.strn + msg.nstr > 0 Then
                If msg.nstr < msg.strn Or msg.strn = 0 Then
                    If msg.nstr > 0 Then
                        'MsgBox msg.nstr
                        msg.strn = msg.nstr
                        msg.tg = 4
                        GoTo zabor
                    End If
                End If
            'MsgBox msg.strn & " _ " & n
                For c = 1 To 70
                    If c = 70 Then '<!>
                        'MsgBox Mid(Word.text(n), msg.strn + 1, 2) & vbCrLf & n, , "Нима!" '<!>
                    End If '<!>
                    'MsgBox Chr(34) & Mid(Word.text(n), msg.strn + 1, 2) & Chr(34) & "=?" & Chr(34) & Mid(Tegs(c), 2, 2) & Chr(34) & vbCrLf _
                    & n & "   " & msg.num
                    If Mid(Word.Text(n), msg.strn + 1, 2) = Mid(Tegs(c), 2, 2) Then
                        'MsgBox Mid(Word.text(n), InStr(Word.text(n), "<") + 1, 2) ' <!>
                        msg.tg = 3
                        If c > 19 Then msg.tg = 7
                        If c > 49 Then msg.tg = 17
                        If c > 54 Then msg.tg = 12
                        If c > 59 Then
                            If Mid(Word.Text(n), msg.strn + 1, 3) = "MNA" Then msg.tg = 3
                            If Mid(Word.Text(n), msg.strn + 1, 3) = "MNP" Then msg.tg = 22
                            If Mid(Word.Text(n), msg.strn + 1, 2) = "FL" Then msg.tg = 7
                            If Mid(Word.Text(n), msg.strn + 1, 3) = "FLJ" Then msg.tg = 12
                            If Mid(Word.Text(n), msg.strn + 1, 3) = "CMP" Then msg.tg = 17
                            If Mid(Word.Text(n), msg.strn + 1, 3) = "CMU" Then msg.tg = 7
                            If Mid(Word.Text(n), msg.strn + 1, 3) = "TRA" Then msg.tg = 22
                            If Mid(Word.Text(n), msg.strn + 1, 2) = "IT" Then msg.tg = 7
                            If Mid(Word.Text(n), msg.strn + 1, 3) = "ITJ" Then msg.tg = 12
                            If Mid(Word.Text(n), msg.strn + 1, 3) = "FOM" Then msg.tg = 7
                            If Mid(Word.Text(n), msg.strn + 1, 3) = "FON" Then msg.tg = 12
                            'MsgBox Mid(Word.Text(n), msg.strn + 1, 3) & "  " & msg.tg
                        End If
zabor:
                        'MsgBox msg.strn & " - " & msg.pos & " = " & msg.strn - msg.pos
                        If msg.strn - msg.pos > 0 Then 'msg.pos = 1 And
                            'MsgBox "С позиции " & msg.pos & " номер " & msg.strn, , ">1"
                            msg.num = msg.num + 1
                            msg.count(n) = msg.count(n) + 1
                            Msgtext(n, msg.num) = Mid(Word.Text(n), msg.pos, msg.strn - msg.pos) ' + 1)
                            'MsgBox Msgtext(n, msg.num) & vbCrLf & "Msgtext(" & n & "," & msg.num & ")", , "Текст"
                        End If
                        ' Забирание тега
                        'MsgBox Mid(Word.Text(n), msg.strn + msg.tg + 1, 2)
                        If Mid(Word.Text(n), msg.strn + msg.tg + 1, 2) = vbCrLf Then msg.tg = msg.tg + 2 ' And MsgBox("!!!" & msg.tg)
                        'MsgBox ("!!!" & msg.tg)
                        msg.num = msg.num + 1
                        msg.count(n) = msg.count(n) + 1
                        teg(n, msg.num) = True
                        Msgtext(n, msg.num) = Mid(Word.Text(n), msg.strn, msg.tg + 1)
                        msg.pos = msg.strn + msg.tg + 1
                        'MsgBox Msgtext(n, msg.num) & vbCrLf & "Msgtext(" & n & "," & msg.num & ")", , "Тег"  ' <!>
                        GoTo RetryMsg
                    End If
                Next c
            Else
                'if len(word.
            End If
        'Else
        '    Msgtext(n, 1) = Word.text(n)
        '    msg.count(n) = 1
        End If
    Next n
    
'For n = 1 To msg.count(2)
'    sds = sds & Msgtext(2, n) & vbCrLf
'Next n
'MsgBox sds
    ' Оптимизация
    
    For n = 1 To 2048
        If msg.clear(n) = True Then
            msg.num = 0
            msg.flag = False
            If msg.count(n) > 1 Then
                For c = 1 To msg.count(n)
                    If teg(n, c) = True Then
                        If msg.flag = True Then
                            msg.temp(msg.num) = msg.temp(msg.num) & Msgtext(n, c)
                        Else
                            msg.num = msg.num + 1
                            msg.flag = True
                            tempteg(msg.num) = True
                            msg.temp(msg.num) = Msgtext(n, c)
                        End If
                    Else
                        msg.flag = False
                        msg.num = msg.num + 1
                        tempteg(msg.num) = False
                        msg.temp(msg.num) = Msgtext(n, c)
                    End If
                Next c
                msg.count(n) = msg.num
                For l = 1 To msg.num
                    Msgtext(n, l) = msg.temp(l)
                    teg(n, l) = tempteg(l)
                Next l
            End If
        End If
    Next n
            
    
    
'    For n = 1 To 2048
'        msg.flag = False
'        msg.num = 0
'        If n <= 256 Then msg.temp(n) = ""
'        If n = Word.count Then Exit For
'        If msg.clear(n) = True Then
'            If msg.count(n) > 1 Then
'                For c = 1 To msg.count(n)
'                    If Left(Msgtext(n, c), 1) = "<" Then
'                        If msg.flag = True Then
'                            msg.temp(msg.num) = Msgtext(n, c - 1) & Msgtext(n, c)
'                        Else
'                            msg.num = msg.num + 1
'                            msg.temp(msg.num) = Word.text(n)
'                            msg.flag = True
'                        End If
'                    Else
'                        msg.flag = False
'                        msg.num = msg.num + 1
'                        msg.temp(msg.num) = Word.text(n)
'                    End If
'                Next c
'                For l = 1 To msg.num
'                    Msgtext(n, l) = msg.temp(l)
'                Next l
'                For l = msg.num + 1 To msg.count(n)
'                    Msgtext(n, l) = ""
'                Next l
'            End If
'        End If
'    Next n
                
For n = 1 To Word.count
If Word.clear(n) = True Then
    For c = 1 To msg.count(n)
        If teg(n, c) = False Then
            NewList.AddItem (Left(Msgtext(n, c), 90) & "...")
            NewList.ItemData(NewList.ListCount - 1) = c
        End If
    Next c
    Exit For
End If
Next n
For n = 1 To Word.count
    For c = 1 To msg.count(n)
        msgChText(n, c) = Msgtext(n, c)
    Next c
Next n
ReButton.Enabled = True
ReBlockButton.Enabled = True
ReAllButton.Enabled = True
End If


skp:






For n = 1 To Word.count
Word.ChText(n) = Word.Text(n)
If Word.clear(n) = True Then
    List.AddItem (Left(Word.Text(n), 90) & "...")
    List.ItemData(List.ListCount - 1) = n
    'List.ItemData(n) = n
End If
Next n
CntTxt = "Готово!"
'For n = 1 To msg.count(2)
'    sds = sds & Msgtext(2, n) & vbCrLf
'Next n
'MsgBox sds
Opened = True
List.Enabled = True
NewList.Enabled = True
LeftText.Enabled = True
RightText.Enabled = True
SaveButton.Enabled = True
SaveAsButton.Enabled = True
ShowMsgButton.Enabled = True
ShowOrMsg.Enabled = True
SaveCopyAsButton.Enabled = True
mSaveCopyAs = True
List.ListIndex = 0
SearchButton.Enabled = True
mSave = True
mSaveAs = True
mFind = True
mLook = True
mChLook = True
End Sub

Private Sub Command2_Click()
Open "C:\2.txt" For Output As 2
For n = 1 To Word.count
    If Word.clear(n) = True Then
        Print #2, "[Count=" & n & "]"
        Print #2, Word.ChText(n)
        Print #2, "[End Count]"
        Print #2, ""
    End If
Next n
Print #2, "     0"
Print #2, "     |"
Print #2, "_-===-_"
Print #2, ""
For n = 1 To Word.count
    If Word.clear(n) = False Then
        Print #2, "[Count=" & n & "]"
        Print #2, Word.ChText(n)
        Print #2, "[End Count]"
        Print #2, ""
    End If
Next n
Print #2, "MaxCount=" & Word.count
Close
End Sub

Private Sub Command3_Click()
For n = 1 To Word.count
    If Word.clear(n) = True Then
clr:
    scr = scr + "[Block=" & n & "]" & vbCrLf
    ' Очистка
        If InStr(Word.ChText(n), "<") > 0 Then ' Если есть теги
            ' Определение длины тега \
            If Mid(Word.ChText(n), InStr(Word.ChText(n), "<") + 1, 2) = "NO" Or Mid(Word.ChText(n), InStr(Word.ChText(n), "<") + 1, 2) = "CL" Or Mid(Word.ChText(n), InStr(Word.ChText(n), "<") + 1, 2) = "MS" Or Mid(Word.ChText(n), InStr(Word.ChText(n), "<") + 1, 2) = "KE" Or Mid(Word.ChText(n), InStr(Word.ChText(n), "<") + 1, 2) = "RM" Or Mid(Word.ChText(n), InStr(Word.ChText(n), "<") + 1, 2) = "TU" Then
                ln = 3
            ElseIf Mid(Word.ChText(n), InStr(Word.ChText(n), "<") + 1, 2) = "ML" Or Mid(Word.ChText(n), InStr(Word.ChText(n), "<") + 1, 2) = "FA" Or Mid(Word.ChText(n), InStr(Word.ChText(n), "<") + 1, 2) = "WA" Or Mid(Word.ChText(n), InStr(Word.ChText(n), "<") + 1, 2) = "CM" Or Mid(Word.ChText(n), InStr(Word.ChText(n), "<") + 1, 2) = "GI" Then
                ln = 7
            ElseIf Mid(Word.ChText(n), InStr(Word.ChText(n), "<") + 1, 2) = "AN" Or Mid(Word.ChText(n), InStr(Word.ChText(n), "<") + 1, 2) = "CN" Then
                ln = 17
            Else
                ln = 12
            End If
            ' -------------------------------------/
            ' Вырезаем тег\
            labz = False
            rabz = False
            'If Mid(Word.ChText(n), InStr(Word.ChText(n), "<") - 1, 1) = Chr(10) Then labz = True
            'If Mid(Word.ChText(n), InStr(Word.ChText(n), "<") + ln, 1) = Chr(13) Then rabz = True
            scr = scr + "[Count=" & cnt & "]" & vbCrLf
            scr = scr + "[L=" & labz & "]" & vbCrLf
            scr = scr + "[R=" & rabz & "]" & vbCrLf
            scr = scr + Mid(Word.ChText(n), InStr(Word.ChText(n), "<"), ln + 1) & vbCrLf
            scr = scr + "[End]" + vbCrLf
            Word.ChText(n) = Left(Word.ChText(n), InStr(Word.ChText(n), "<") - 1) & vbCrLf & "{" & cnt & "}" & vbCrLf & Right(Word.ChText(n), Len(Word.ChText(n)) - InStr(Word.ChText(n), "<") + ln - 6)
            MsgBox Word.ChText(n)
            ' ---------------------/
            GoTo clr
        Else
            GoTo nxt
        End If
            scr = scr + "[EndBlock]" & vbCrLf
    End If
    cnt = 0
nxt:
Next n
LeftText = scr
End Sub









Private Sub Command1_Click()
ks = NewList.ItemData(NewList.ListIndex)
For n = List.ItemData(List.ListIndex) To 1 Step -1
    ks = msg.count(n)
    For c = ks To 1 Step -1
        pst = InStrRev(msgChText(n, c), "<FAC", -1)
        If pst > 0 Then
            If Mid(msgChText(n, c), pst, 8) = "<FAC0010" Then
                MsgBox Setup = True
            ElseIf Mid(msgChText(n, c), pst, 8) = "<FAC0000" Then
                MsgBox n & "!!"
            End If
        End If
        'MsgBox msgChText(n, c)
    Next c
Next n
End Sub

Private Sub Command4_Click()
RightText.Move 0, RightText.Top, RightText.Width + 6600 ' + 5175
Vosst.Caption = ">"
LeftText.Visible = False
Vosst.Visible = True
Command4.Visible = False
Command5.Visible = False
FullTextBox = 2
mOrText.Checked = False
mChText.Checked = True
mAllText.Checked = False
End Sub

Private Sub Command5_Click()
LeftText.Move LeftText.Left, LeftText.Top, LeftText.Width + 6600 ' + 5175
Vosst.Caption = "<"
RightText.Visible = False
Vosst.Visible = True
Command4.Visible = False
Command5.Visible = False
FullTextBox = 1
mOrText.Checked = True
mChText.Checked = False
mAllText.Checked = False
End Sub



Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
'If KeyCode = 114 Then
'    Call FindButton
'End If
End Sub

Private Sub mAbout_Click()
MsgBox "Редактор скриптов для игры Cave Story." & vbCrLf & "Привет Repl0id'у от HoRRoR'а.", , "О программе..."
End Sub

Private Sub mAllText_Click()
If mAllText.Checked = False Then
    Call Vosst_Click
End If
End Sub

Private Sub mChText_Click()
If mChText.Checked = False Then
    If mOrText.Checked = False Then
        Call Command4_Click
    Else
        Call Vosst_Click
        Call Command4_Click
    End If
End If
End Sub

Private Sub mExit_Click()
End
End Sub

Private Sub mFind_Click()
Call SearchButton_Click
End Sub

Private Sub mFindNext_Click()
Call FindButton
End Sub

Private Sub mOrText_Click()
If mOrText.Checked = False Then
    If mChText.Checked = False Then
        Call Command5_Click
    Else
        Call Vosst_Click
        Call Command5_Click
    End If
End If
End Sub

Private Sub mSave_Click()
Call SaveButton_Click
End Sub

Private Sub mSaveAs_Click()
Call SaveAsButton_Click
End Sub

Private Sub mSaveCopyAs_Click()
Call SaveCopyAsButton_Click
End Sub

Private Sub NewList_Click()
zapret = True
For n = List.ItemData(List.ListIndex) To 1 Step -1
    If flg = False Then
        ld = NewList.ItemData(NewList.ListIndex) - 1
        flg = True
    Else
        ld = msg.count(n)
    End If
    For c = ld To 1 Step -1
        'MsgBox Msgtext(n, c)
        If Len(Msgtext(n, c)) > 0 Then
            If InStrRev(msgChText(n, c), "<FAC", Len(Msgtext(n, c))) > 0 Then
                If Mid(msgChText(n, c), InStrRev(Msgtext(n, c), "<FAC", Len(msgChText(n, c))), 8) = "<FAC0010" Then
                    LinLen = 26
                Else
                    LinLen = 35
                End If
                GoTo fnd
            End If
        End If
    Next c
Next n
LinLen = 35
fnd:
StLn = "Максимальная длина строки: " & LinLen
LeftText = Msgtext(List.ItemData(List.ListIndex), NewList.ItemData(NewList.ListIndex))
RightText = msgChText(List.ItemData(List.ListIndex), NewList.ItemData(NewList.ListIndex))
msg.Index = (NewList.ItemData(NewList.ListIndex))
zapret = False
CntTxt = List.ListIndex + 1 & "/" & List.ListCount & "  (" & _
List.ItemData(List.ListIndex) & "/" & Word.count & ")" & "  -  " & _
NewList.ListIndex + 1 & "/" & NewList.ListCount & "  (" & _
NewList.ItemData(NewList.ListIndex) & "/" & msg.count(List.ItemData(List.ListIndex)) & ")"
End Sub

Private Sub mOpen_Click()
Call OpenButton_Click
End Sub

Private Sub OpenButton_Click()

Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "Текстовые файлы (*.txt)" _
        + Chr$(0) + "*.txt" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие скрипта"
Dial.File = ShowOpen
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
Else
    file1 = Dial.File
    Call LoadScript
End If
'file1 = Dial.File
End Sub

Private Sub Form_Unload(Cancel As Integer)
End
End Sub

Private Sub List_Click()

zapret = True
If EditType = True Then
    For n = 1 To NewList.ListCount
        NewList.RemoveItem (0)
    Next n
    If Word.clear(List.ItemData(List.ListIndex)) = True Then
        For c = 1 To msg.count(List.ItemData(List.ListIndex))
            If teg(List.ItemData(List.ListIndex), c) = False Then
                NewList.AddItem (Left(msgChText(List.ItemData(List.ListIndex), c), 90))
                NewList.ItemData(NewList.ListCount - 1) = c
            End If
        Next c
    End If
    'If ListZapret = False Then
        NewList.ListIndex = 0
    'End If
    Word.Index = (List.ItemData(List.ListIndex))
    'CntTxt = List.ListIndex + 1 & "/" & List.ListCount & "  (" & _
'List.ItemData(List.ListIndex) & "/" & Word.count & ")" & "  -  " & _
'NewList.ListIndex + 1 & "/" & NewList.ListCount & "  (" & _
'NewList.ItemData(NewList.ListIndex) & "/" & msg.count(List.ItemData(List.ListIndex)) & ")"

Else
    LeftText = Word.Text(List.ItemData(List.ListIndex))
    RightText = Word.ChText(List.ItemData(List.ListIndex))
    Word.Index = (List.ItemData(List.ListIndex))
    CntTxt = List.ListIndex + 1 & "/" & List.ListCount & "  (" & List.ItemData(List.ListIndex) & "/" & Word.count & ")"
End If
    zapret = False

End Sub

Private Sub Text2_Change()

End Sub


Private Sub ReAllButton_Click()
lst = List.ListIndex
nlst = NewList.ListIndex
l = List.ListCount - 1
For n = 0 To l
    CntTxt = n & "/" & l & " [" & Int(n / l * 100 + 0.5) & "%]"
    CntTxt.Refresh
    List.ListIndex = n
    Call ReBlockButton_Click
Next n
List.ListIndex = lst
NewList.ListIndex = nlst
End Sub

Private Sub ReBlockButton_Click()
lst = List.ListIndex
nlst = NewList.ListIndex

For n = msg.count(List.ItemData(List.ListIndex)) To 1 Step -1
    If teg(List.ItemData(List.ListIndex), n) = False Then
        
For l = List.ItemData(List.ListIndex) To 1 Step -1
    ld = msg.count(n)
    For c = ld To 1 Step -1
        'MsgBox Msgtext(l, c)
        If Len(Msgtext(l, c)) > 0 Then
            If InStrRev(msgChText(l, c), "<FAC", Len(Msgtext(l, c))) > 0 Then
                If Mid(msgChText(l, c), InStrRev(Msgtext(l, c), "<FAC", Len(msgChText(l, c))), 8) = "<FAC0010" Then
                    LinLel = 26
                Else
                    LinLel = 35
                End If
                GoTo fnd
            End If
        End If
    Next c
Next l
fnd:
        
'        If Len(Msgtext(List.ItemData(List.ListIndex), n)) > 0 Then
'
'            If InStrRev(msgChText(List.ItemData(List.ListIndex), n), "<FAC", Len(Msgtext(List.ItemData(List.ListIndex), n))) > 0 Then
'                If Mid(msgChText(List.ItemData(List.ListIndex), n), InStrRev(Msgtext(List.ItemData(List.ListIndex), n), "<FAC", Len(msgChText(List.ItemData(List.ListIndex), n))), 8) = "<FAC0010" Then
'                    LinLen = 26
'                Else
'                    LinLen = 35
'                End If
'                GoTo fnd
'            End If
'        End If
'        LinLen = 35
'fnd:
'List.ListIndex = lst
For l = 0 To NewList.ListCount - 1
    If NewList.ItemData(l) = n Then
        NewList.ListIndex = l
    End If
Next l
        Call ReButton_Click
    End If
Next n

List.ListIndex = lst
NewList.ListIndex = nlst
End Sub

Private Sub ReButton_Click()
If Len(msgChText(List.ItemData(List.ListIndex), NewList.ItemData(NewList.ListIndex))) <= LinLen Then Exit Sub
w = msgChText(List.ItemData(List.ListIndex), NewList.ItemData(NewList.ListIndex))
Dim newW As String
els1:
If InStr(w, vbCrLf) > 0 Then
    w = Left(w, InStr(w, vbCrLf) - 1) & " " & Right(w, Len(w) - InStr(w, vbCrLf) - 1)
    GoTo els1
End If

els2:
If InStr(w, "  ") > 0 Then
    w = Left(w, InStr(w, "  ") - 1) & " " & Right(w, Len(w) - InStr(w, "  ") - 1)
    GoTo els2:
End If

r = 1
els3:
s = Mid(w, r, LinLen)
If Len(s) < LinLen Then
    RightText = newW & s
    Exit Sub
End If
qwq = InStrRev(s, " ", Len(s))
If qwq > 0 Then
    s = Left(s, qwq - 1)
    r = r + qwq
Else
    MsgBox "Ашшипка вь приаббразаванеи стлокк! Нет пробелов и переносов! Нельзя, короче, обработать."
End If
newW = newW & s & vbCrLf
'If LinLen < Len(s) Then
GoTo els3
'End If
RightText = newW
End Sub

Private Sub RightText_Change()
If zapret = False Then
    If EditType = True Then
        msgChText(List.ItemData(List.ListIndex), NewList.ItemData(NewList.ListIndex)) = RightText
        NewList.List(NewList.ListIndex) = msgChText(List.ItemData(List.ListIndex), NewList.ItemData(NewList.ListIndex))
        Word.ChText(Word.Index) = ""
            'MsgBox msg.count(NewList.ItemData(NewList.ListIndex)) & "  " & (NewList.ItemData(NewList.ListIndex))
        For n = 1 To msg.count(List.ItemData(List.ListIndex))
            'MsgBox "Word.ChText(" & n & ") = " & Word.ChText(Word.Index) & msgChText(List.ItemData(List.ListIndex), n)
            Word.ChText(Word.Index) = Word.ChText(Word.Index) & msgChText(List.ItemData(List.ListIndex), n)
        Next n
        List.List(List.ListIndex) = Left(Word.ChText(List.ItemData(List.ListIndex)), 90) & "..."
    Else
        Word.ChText(Word.Index) = RightText
        List.List(List.ListIndex) = Left(Word.ChText(List.ItemData(List.ListIndex)), 90) & "..."
    End If
End If
End Sub

Private Sub SaveAsButton_Click()
Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "Текстовые файлы (*.txt)" _
        + Chr$(0) + "*.txt" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Сохранение скрипта"
Dial.File = ShowSave
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
Else
    file1 = Dial.File
    If Not Right(file1, 4) = ".txt" Then
        file1 = file1 & ".txt"
    End If
    Call SaveButton_Click
End If
End Sub

Private Sub SaveButton_Click()
Open file1 For Output As 1
Dim SaveText As String
SaveText = ""
If EditType = True Then
    For n = 1 To Word.count
        If Word.clear(n) = False Then
            SaveText = SaveText & Word.Text(n)
        Else
            For c = 1 To msg.count(n)
                SaveText = SaveText & msgChText(n, c)
            Next c
        End If
    Next n
Else
    For n = 1 To Word.count
        SaveText = SaveText & Word.ChText(n)
    Next n
End If
Print #1, SaveText
Close
End Sub

Private Sub SaveCopyAsButton_Click()
tmp = file1
Call SaveAsButton_Click
file1 = tmp
End Sub

Private Sub SearchButton_Click()
Search.Show
End Sub

Private Sub ShowMsgButton_Click()
ShowMsg.Text = Word.ChText(Word.Index)
ShowMsg.Caption = "Сообщение " & List.ListIndex + 1 & "/" & List.ListCount & "  (" & List.ItemData(List.ListIndex) & "/" & Word.count & ") (*)"
ShowMsg.Show
End Sub

Private Sub ShowOrMsg_Click()
ShowMsg.Text = Word.Text(Word.Index)
ShowMsg.Caption = "Сообщение " & List.ListIndex + 1 & "/" & List.ListCount & "  (" & List.ItemData(List.ListIndex) & "/" & Word.count & ")"
ShowMsg.Show
End Sub

Private Sub Vosst_Click()
If FullTextBox = 1 Then
LeftText.Move Fs.leftleft, LeftText.Top, Fs.leftwidth ' - 5175
RightText.Visible = True
Vosst.Visible = False
Command4.Visible = True
Command5.Visible = True
FullTextBox = 0
Else
RightText.Move Fs.rightleft, RightText.Top, Fs.rightwidth ' + 5175
LeftText.Visible = True
Vosst.Visible = False
Command4.Visible = True
Command5.Visible = True
FullTextBox = 0
End If
mOrText.Checked = False
mChText.Checked = False
mAllText.Checked = True

End Sub
