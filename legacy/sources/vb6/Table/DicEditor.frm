VERSION 5.00
Begin VB.Form DTEDicEditor 
   Caption         =   "Редактор DTE словаря"
   ClientHeight    =   4395
   ClientLeft      =   975
   ClientTop       =   1575
   ClientWidth     =   11220
   LinkTopic       =   "Form1"
   ScaleHeight     =   4395
   ScaleWidth      =   11220
   Begin VB.CommandButton ListAdd 
      Height          =   435
      Left            =   6120
      Picture         =   "DicEditor.frx":0000
      Style           =   1  'Graphical
      TabIndex        =   62
      ToolTipText     =   "5009"
      Top             =   3240
      UseMaskColor    =   -1  'True
      Width           =   435
   End
   Begin VB.CommandButton ListDelete 
      Enabled         =   0   'False
      Height          =   435
      Left            =   6120
      Picture         =   "DicEditor.frx":0102
      Style           =   1  'Graphical
      TabIndex        =   61
      ToolTipText     =   "5010"
      Top             =   3840
      UseMaskColor    =   -1  'True
      Width           =   435
   End
   Begin VB.CommandButton ListRevertAll 
      Caption         =   "<<->>"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   435
      Left            =   6720
      TabIndex        =   60
      Top             =   3840
      Width           =   675
   End
   Begin VB.CommandButton ListRevert 
      Caption         =   "<->"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   435
      Left            =   6720
      TabIndex        =   59
      Top             =   3240
      Width           =   675
   End
   Begin VB.CommandButton ListUp 
      Height          =   435
      Left            =   5520
      Picture         =   "DicEditor.frx":0204
      Style           =   1  'Graphical
      TabIndex        =   58
      Top             =   3240
      Width           =   435
   End
   Begin VB.CommandButton ListDown 
      Height          =   435
      Left            =   5520
      Picture         =   "DicEditor.frx":0306
      Style           =   1  'Graphical
      TabIndex        =   57
      Top             =   3840
      Width           =   435
   End
   Begin VB.Frame Frame6 
      Caption         =   "Работа со словарём:"
      Height          =   1335
      Left            =   5400
      TabIndex        =   56
      Top             =   3000
      Width           =   3255
   End
   Begin VB.CommandButton Command10 
      Caption         =   "Догрузить"
      Height          =   375
      Left            =   4080
      TabIndex        =   46
      Top             =   3840
      Width           =   1095
   End
   Begin VB.TextBox Text3 
      Height          =   285
      Left            =   3600
      TabIndex        =   45
      Top             =   3960
      Width           =   375
   End
   Begin VB.CommandButton Command5 
      Caption         =   "Загрузить"
      Height          =   375
      Left            =   4080
      TabIndex        =   44
      Top             =   3240
      Width           =   1095
   End
   Begin VB.TextBox Text2 
      Height          =   285
      Left            =   3600
      TabIndex        =   43
      Top             =   3600
      Width           =   375
   End
   Begin VB.TextBox Text1 
      Height          =   285
      Left            =   3600
      TabIndex        =   42
      Top             =   3240
      Width           =   375
   End
   Begin VB.CommandButton Command6 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   7680
      TabIndex        =   41
      Top             =   480
      Width           =   855
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Сохранить"
      Enabled         =   0   'False
      Height          =   375
      Left            =   7440
      TabIndex        =   40
      Top             =   2400
      Width           =   1095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Открыть"
      Enabled         =   0   'False
      Height          =   375
      Left            =   6360
      TabIndex        =   39
      Top             =   2400
      Width           =   1095
   End
   Begin VB.CheckBox SWT 
      Caption         =   "Сложить с таблицей"
      Height          =   255
      Left            =   8880
      TabIndex        =   27
      Top             =   2520
      Width           =   2055
   End
   Begin VB.TextBox EKol 
      Height          =   285
      Left            =   10440
      TabIndex        =   25
      Text            =   "255"
      Top             =   1800
      Width           =   615
   End
   Begin VB.TextBox BKol 
      Height          =   285
      Left            =   9720
      TabIndex        =   24
      Text            =   "0"
      Top             =   1800
      Width           =   615
   End
   Begin VB.TextBox Ebyte 
      Height          =   285
      Left            =   10440
      TabIndex        =   19
      Text            =   "255"
      Top             =   2160
      Width           =   615
   End
   Begin VB.CommandButton Command7 
      Caption         =   "Заполнить"
      Height          =   255
      Left            =   9720
      TabIndex        =   18
      Top             =   1440
      Width           =   1335
   End
   Begin VB.TextBox Bbyte 
      Height          =   285
      Left            =   9720
      TabIndex        =   17
      Text            =   "0"
      Top             =   2160
      Width           =   615
   End
   Begin VB.TextBox WordR 
      Height          =   285
      Left            =   9960
      TabIndex        =   16
      Top             =   3600
      Width           =   975
   End
   Begin VB.TextBox WRight 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   10560
      MaxLength       =   2
      TabIndex        =   15
      Top             =   3240
      Width           =   375
   End
   Begin VB.TextBox WLeft 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   8880
      MaxLength       =   2
      TabIndex        =   14
      Top             =   3240
      Width           =   375
   End
   Begin VB.CheckBox Check3 
      Caption         =   "Использовать таблицу"
      Height          =   255
      Left            =   5280
      TabIndex        =   12
      Top             =   2040
      Value           =   1  'Отмечено
      Width           =   2295
   End
   Begin VB.CheckBox Check2 
      Caption         =   "Сначала вторые, потом первые"
      Height          =   255
      Left            =   5280
      TabIndex        =   11
      Top             =   1800
      Width           =   3255
   End
   Begin VB.OptionButton Option4 
      Caption         =   "Загрузить из таблицы"
      Enabled         =   0   'False
      Height          =   255
      Left            =   2520
      TabIndex        =   10
      Top             =   3000
      Width           =   2055
   End
   Begin VB.OptionButton Option3 
      Caption         =   "Загрузить из файла:"
      Height          =   255
      Left            =   2520
      TabIndex        =   9
      Top             =   120
      Value           =   -1  'True
      Width           =   1935
   End
   Begin VB.TextBox Interval 
      Height          =   285
      Left            =   3960
      TabIndex        =   8
      Text            =   "0"
      Top             =   1920
      Width           =   1215
   End
   Begin VB.CheckBox Check1 
      Caption         =   "В обратном порядке"
      Height          =   255
      Left            =   5280
      TabIndex        =   7
      Top             =   1560
      Width           =   3255
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Применить"
      Height          =   255
      Left            =   8880
      TabIndex        =   6
      Top             =   720
      Width           =   2175
   End
   Begin VB.ComboBox Combo 
      Height          =   315
      ItemData        =   "DicEditor.frx":0408
      Left            =   8880
      List            =   "DicEditor.frx":040F
      Locked          =   -1  'True
      TabIndex        =   5
      Text            =   "Final Fantasy"
      Top             =   360
      Width           =   2175
   End
   Begin VB.TextBox WordL 
      Height          =   285
      Left            =   8880
      TabIndex        =   4
      Top             =   3600
      Width           =   975
   End
   Begin VB.TextBox EoR 
      Height          =   285
      Left            =   3960
      TabIndex        =   3
      Text            =   "&H"
      Top             =   1440
      Width           =   1215
   End
   Begin VB.TextBox BoR 
      Height          =   285
      Left            =   3960
      TabIndex        =   2
      Text            =   "&H"
      Top             =   1080
      Width           =   1215
   End
   Begin VB.TextBox ROM 
      Height          =   285
      Left            =   2760
      TabIndex        =   1
      Text            =   "ff\Final Fantasy.nes"
      Top             =   480
      Width           =   4815
   End
   Begin VB.ListBox List 
      DragIcon        =   "DicEditor.frx":0422
      Height          =   4155
      ItemData        =   "DicEditor.frx":072C
      Left            =   120
      List            =   "DicEditor.frx":073F
      TabIndex        =   0
      Top             =   120
      Width           =   2295
   End
   Begin VB.Frame Frame1 
      Caption         =   "Шаблоны:"
      Height          =   975
      Left            =   8760
      TabIndex        =   23
      Top             =   120
      Width           =   2415
   End
   Begin VB.Frame Frame2 
      Caption         =   "Экспорт в таблицу:"
      Height          =   1695
      Left            =   8760
      TabIndex        =   28
      Top             =   1200
      Width           =   2415
      Begin VB.Label Label4 
         Alignment       =   1  'Правая привязка
         Caption         =   "Элементы словаря:"
         Height          =   375
         Left            =   120
         TabIndex        =   30
         Top             =   360
         Width           =   855
      End
      Begin VB.Label Label5 
         Alignment       =   1  'Правая привязка
         Caption         =   "Ячейки таблицы:"
         Height          =   495
         Left            =   120
         TabIndex        =   29
         Top             =   840
         Width           =   855
      End
   End
   Begin VB.CommandButton Command9 
      Caption         =   "Просмотреть"
      Enabled         =   0   'False
      Height          =   375
      Left            =   4920
      TabIndex        =   38
      Top             =   2400
      Width           =   1455
   End
   Begin VB.CommandButton Command8 
      Caption         =   "Переписать"
      Enabled         =   0   'False
      Height          =   375
      Left            =   3840
      TabIndex        =   37
      Top             =   2400
      Width           =   1095
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Загрузить"
      Height          =   375
      Left            =   2760
      TabIndex        =   13
      Top             =   2400
      Width           =   1095
   End
   Begin VB.Frame Frame3 
      Height          =   2775
      Left            =   2640
      TabIndex        =   31
      Top             =   120
      Width           =   6015
      Begin VB.OptionButton Option1 
         Caption         =   "По порядку"
         Enabled         =   0   'False
         Height          =   255
         Left            =   2640
         TabIndex        =   36
         Top             =   840
         Width           =   1455
      End
      Begin VB.OptionButton Option2 
         Caption         =   "Первые отдельно, вторые отдельно"
         Height          =   255
         Left            =   2640
         TabIndex        =   35
         Top             =   1080
         Value           =   -1  'True
         Width           =   3255
      End
      Begin VB.Label Label7 
         Alignment       =   1  'Правая привязка
         Caption         =   "Адрес конца:"
         Height          =   375
         Left            =   120
         TabIndex        =   34
         Top             =   1320
         Width           =   1095
      End
      Begin VB.Label Label6 
         Alignment       =   1  'Правая привязка
         Caption         =   "Адрес начала:"
         Height          =   375
         Left            =   120
         TabIndex        =   33
         Top             =   960
         Width           =   1095
      End
      Begin VB.Label Label1 
         Alignment       =   1  'Правая привязка
         Caption         =   "Интервал:"
         Height          =   255
         Left            =   360
         TabIndex        =   32
         Top             =   1800
         Width           =   855
      End
   End
   Begin VB.Frame Frame4 
      Caption         =   "Редактор:"
      Height          =   1335
      Left            =   8760
      TabIndex        =   47
      Top             =   3000
      Width           =   2415
      Begin VB.Label Label2 
         Alignment       =   2  'Центровка
         Caption         =   "<-длина->"
         Height          =   255
         Left            =   720
         TabIndex        =   51
         Top             =   960
         Width           =   855
      End
      Begin VB.Label LLen 
         Caption         =   "<Нет>"
         Height          =   255
         Left            =   120
         TabIndex        =   50
         Top             =   960
         Width           =   615
      End
      Begin VB.Label RLen 
         Alignment       =   1  'Правая привязка
         Caption         =   "<Нет>"
         Height          =   255
         Left            =   1560
         TabIndex        =   49
         Top             =   960
         Width           =   615
      End
      Begin VB.Label Label3 
         Alignment       =   2  'Центровка
         Caption         =   "<-код->"
         Height          =   255
         Left            =   840
         TabIndex        =   48
         Top             =   240
         Width           =   615
      End
   End
   Begin VB.Frame Frame5 
      Height          =   1335
      Left            =   2640
      TabIndex        =   52
      Top             =   3000
      Width           =   2655
      Begin VB.Label Label10 
         Alignment       =   1  'Правая привязка
         Caption         =   "Старший байт:"
         Height          =   375
         Left            =   120
         TabIndex        =   55
         Top             =   840
         Width           =   735
      End
      Begin VB.Label Label9 
         Alignment       =   1  'Правая привязка
         Caption         =   "По:"
         Height          =   255
         Left            =   600
         TabIndex        =   54
         Top             =   600
         Width           =   255
      End
      Begin VB.Label Label8 
         Alignment       =   1  'Правая привязка
         Caption         =   "С:"
         Height          =   255
         Left            =   600
         TabIndex        =   53
         Top             =   240
         Width           =   255
      End
   End
   Begin VB.Label Label3a 
      Alignment       =   2  'Центровка
      Caption         =   "<-код->"
      Height          =   255
      Left            =   9600
      TabIndex        =   26
      Top             =   3240
      Width           =   615
   End
   Begin VB.Label RLena 
      Alignment       =   1  'Правая привязка
      Caption         =   "<Нет>"
      Height          =   255
      Left            =   10320
      TabIndex        =   22
      Top             =   3960
      Width           =   615
   End
   Begin VB.Label LLena 
      Caption         =   "<Нет>"
      Height          =   255
      Left            =   8880
      TabIndex        =   21
      Top             =   3960
      Width           =   615
   End
   Begin VB.Label Label2a 
      Alignment       =   2  'Центровка
      Caption         =   "<-длина->"
      Height          =   255
      Left            =   9480
      TabIndex        =   20
      Top             =   3960
      Width           =   855
   End
End
Attribute VB_Name = "DTEDicEditor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Sub SetListButtons()
  Dim i As Integer
  i = List.ListIndex
  'set the state of the move buttons
  ListUp.Enabled = (i > 0)
  ListDown.Enabled = ((i > -1) And (i < (List.ListCount - 1)))
  ListDelete.Enabled = (i > -1)
  ListRevert.Enabled = (i > -1)
  ListRevertAll.Enabled = (List.ListCount > 0)
End Sub



Private Sub Command2_Click()
If Combo.ItemData(0) = 0 Then
    DTEDicEditor.BoR = "&H3F060"
    DTEDicEditor.EoR = "&H3F0FF"
    DTEDicEditor.Interval = 0
    DTEDicEditor.Option1 = False ' По порядку
    DTEDicEditor.Option2 = True ' Отдельно
    DTEDicEditor.Check1 = False
    DTEDicEditor.Check2.Value = 1
    DTEDicEditor.Check3.Value = 1
End If
End Sub

Private Sub Command3_Click() ' Загрузка словаря
Open ROM For Binary As 1
For n = 0 To 256
    FullDic(n) = False
Next n
If List.ListCount > 0 Then
    s = List.ListCount
    'MsgBox s
    For n = 0 To s - 1
        'MsgBox n & vbCrLf & List.List(n)
        List.RemoveItem (0)
    Next n
End If
s = 0
    
If Option2 = True Then
    d = 0
    s = 0 ' Val("&H" + Bbyte)
    pol = Int((Abs(Val(EoR)) - Abs(Val(BoR))) / 2) '+ 1
    'MsgBox pol
    'ReDim Dic(1, (Abs(Val(EoR)) - Abs(Val(BoR))) / 2) As String
    If Not Check2 = False Then
        t = 1
    Else
        t = 0
    End If
    stp = Abs(Val(Interval)) + 1
    If Not Check1 = False Then
        Min = Abs(Val(EoR)) + 1
        Max = Abs(Val(BoR)) + 1
        stp = 0 - stp
    Else
        Min = Abs(Val(BoR)) + 1
        Max = Abs(Val(EoR)) + 1
    End If
    'MsgBox "Min = " & Min & vbCrLf & "Max = " & Max & vbCrLf & "stp = " & stp
    'Open ROM For Binary As 1 '-----------------------------------------------
    
    For n = Min To Max Step stp
        Get #1, n, bte
        If s > pol And d = 0 Then
            'MsgBox n & vbCrLf & s
            If t = 1 Then t = 0: d = 1: s = 0 Else t = 1: d = 1: s = 0
        End If
        FullDic(s) = True
        ValDic(s, t) = bte
        If Not Table(256, bte) = "" And Not Check3 = False Then
            Dic(s, t) = Table(256, bte)
        Else
            Dic(s, t) = "{" + Hex(bte) + "}"
        End If
        s = s + 1
        'MsgBox Dic(s, t)
        'Dic(s, t) = Chr(bte): s = s + 1
    Next n

    
End If
Close
For n = 0 To 256
    If FullDic(n) = True Then
        List.List(n) = Dic(n, 0) + Dic(n, 1)
        List.ItemData(n) = n
    End If
Next n

End Sub





Private Sub Command6_Click()
Res.LDTEDic = ROM

Dial.Form = Me.hWnd
Dial.Filter = "Все файлы (*.*)" + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие РОМа"
ROM = ShowOpen
If Not InStr(1, ROM, "\") = 0 Then
    Dial.Dir = Right(ROM, Len(ROM) - InStrRev(ROM, "\"))
End If
If ROM = "" Then ROM = Res.LDTEDic
End Sub

Private Sub Command7_Click()
If SWT = False Then
    For n = 0 To 255
        Table(256, n) = ""
    Next n
End If
s = Val(BKol)
For n = Val(Bbyte) To Val(Ebyte)
    If s = Val(EKol) Then Exit For
    If FullDic(s) = True Then
        Table(256, n) = Dic(s, 0) + Dic(s, 1)
    End If
    s = s + 1
Next n
s = 0
Call TableWr
End Sub


Private Sub Form_Load()
SetListButtons
' Оптимизация таблицы, пока нафиг не нужна
'For n = 0 To 255
'    DicTable(n) = -1
'Next n
'For n = 255 To 0 Step -1
'    If Len(Table(256, n)) = 1 Then
'        DicTable(Asc(Table(256, n))) = n
'        'MsgBox Hex(DicTable(Asc(Table(256, n))))
'    End If
'Next n
End Sub

Private Sub List_Click()
  SetListButtons

FromHexZapret = True
zapret = 1
WordL = Dic(List.ListIndex, 0)
WordR = Dic(List.ListIndex, 1)
WLeft = Hex(ValDic(List.ListIndex, 0))
WRight = Hex(ValDic(List.ListIndex, 1))
lst = List.ListIndex
zapret = 0
FromHexZapret = False
End Sub

Private Sub List_DragDrop(Source As Control, X As Single, Y As Single)
Dim i As Integer
On Error GoTo metka
  Dim nID As Integer
  Dim sTmp As String
  Dim dItem As Integer
  
  If Source.Name <> "List" Then Exit Sub
  If List.ListCount = 0 Then Exit Sub
  
  With List
    i = (Y \ TextHeight("A")) + .TopIndex
    If i = .ListIndex Then
      'dropped on top of itself
      Exit Sub
    End If
    If i > .ListCount - 1 Then i = .ListCount - 1
    dItem = .ItemData(.ListIndex)
    nID = .ListIndex
    sTmp = .Text
    If (nID > -1) Then
      sTmp = .Text
      .RemoveItem nID
      .AddItem sTmp, i
      .ItemData(i) = dItem
      .ListIndex = .NewIndex
    End If
  End With
metka:
  SetListButtons
End Sub

Private Sub List_KeyDown(KeyCode As Integer, Shift As Integer)
FromHexZapret = True
Word = List.Text
FromHexZapret = False
End Sub

Private Sub List_KeyUp(KeyCode As Integer, Shift As Integer)
FromHexZapret = True
Word = List.Text
FromHexZapret = False
End Sub

Private Sub List_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
If Button = vbLeftButton Then List.Drag
End Sub

Private Sub ListAdd_Click()
  Dim sTmp As String
  sTmp = InputBox("Введите новый элемент словаря:")
  If Len(sTmp) = 0 Then Exit Sub
  List.AddItem sTmp
  SetListButtons
End Sub

Private Sub ListDelete_Click()
  If List.ListIndex > -1 Then
    If MsgBox("Удалить '" & List.Text & "'?", vbQuestion + vbYesNo) = vbYes Then
      List.RemoveItem List.ListIndex
    End If
  End If
SetListButtons

If List.ListIndex > -1 Then
    FromHexZapret = True
    zapret = 1
    WordL = Dic(List.ListIndex, 0)
    WordR = Dic(List.ListIndex, 1)
    WLeft = Hex(ValDic(List.ListIndex, 0))
    WRight = Hex(ValDic(List.ListIndex, 1))
    lst = List.ListIndex
    zapret = 0
    FromHexZapret = False
Else
    WordL = ""
    WordR = ""
    WLeft = ""
    WRight = ""
End If
End Sub

Private Sub ListDown_Click()
  On Error Resume Next
  Dim nItem As Integer
  Dim dItem As Integer
  
  With lstSelected
    If List.ListIndex < 0 Then Exit Sub
    nItem = List.ListIndex
    If nItem = List.ListCount - 1 Then Exit Sub
    dItem = List.ItemData(nItem)
    List.AddItem List.Text, nItem + 2
    List.ItemData(nItem + 2) = dItem
    List.RemoveItem nItem
    List.Selected(nItem + 1) = True
  End With
End Sub

Private Sub ListRevert_Click()
    Dim td As String
    If List.ListIndex < 0 Then Exit Sub
    'MsgBox List.ItemData(List.ListIndex)
    List.List(List.ListIndex) = Dic(List.ItemData(List.ListIndex), 1) + Dic(List.ItemData(List.ListIndex), 0)
    td = Dic(List.ItemData(List.ListIndex), 0)
    Dic(List.ItemData(List.ListIndex), 0) = Dic(List.ItemData(List.ListIndex), 1)
    Dic(List.ItemData(List.ListIndex), 1) = td
    n = ValDic(List.ItemData(List.ListIndex), 0)
    ValDic(List.ItemData(List.ListIndex), 0) = ValDic(List.ItemData(List.ListIndex), 1)
    ValDic(List.ItemData(List.ListIndex), 1) = n
    
    FromHexZapret = True
    zapret = 1
    WordL = Dic(List.ListIndex, 0)
    WordR = Dic(List.ListIndex, 1)
    WLeft = Hex(ValDic(List.ListIndex, 0))
    WRight = Hex(ValDic(List.ListIndex, 1))
    lst = List.ListIndex
    zapret = 0
    FromHexZapret = False
End Sub

Private Sub ListRevertAll_Click()
    Dim td As String
    If List.ListCount < 1 Then Exit Sub
    'MsgBox List.ItemData(List.ListIndex)
    For s = 0 To List.ListCount - 1
        List.List(s) = Dic(List.ItemData(s), 1) + Dic(List.ItemData(s), 0)
        td = Dic(List.ItemData(s), 0)
        Dic(List.ItemData(s), 0) = Dic(List.ItemData(s), 1)
        Dic(List.ItemData(s), 1) = td
        n = ValDic(List.ItemData(s), 0)
        ValDic(List.ItemData(s), 0) = ValDic(List.ItemData(s), 1)
        ValDic(List.ItemData(s), 1) = n
    Next s
    
    If List.ListIndex < 0 Then Exit Sub
    FromHexZapret = True
    zapret = 1
    WordL = Dic(List.ListIndex, 0)
    WordR = Dic(List.ListIndex, 1)
    WLeft = Hex(ValDic(List.ListIndex, 0))
    WRight = Hex(ValDic(List.ListIndex, 1))
    lst = List.ListIndex
    zapret = 0
    FromHexZapret = False
End Sub

Private Sub ListUp_Click()

  On Error Resume Next
  Dim nItem As Integer
  Dim dItem As Integer
  
  With lstSelected
    If List.ListIndex < 0 Then Exit Sub
    nItem = List.ListIndex
    If nItem = 0 Then Exit Sub
    dItem = List.ItemData(nItem)
    List.AddItem List.Text, nItem - 1
    List.ItemData(nItem - 1) = dItem
    List.RemoveItem nItem + 1
    List.Selected(nItem - 1) = True
  End With
End Sub

Private Sub WLeft_Change()
If FromHexZapret = False Then
b = 0
For n = 1 To 47
    If InStr(WLeft, Chr(n)) > 0 Then
        b = 1
        GoTo nd
    End If
Next n '97 102
For n = 58 To 64
    If InStr(WLeft, Chr(n)) > 0 Then
        b = 1
        GoTo nd
    End If
Next n
For n = 71 To 96
    If InStr(WLeft, Chr(n)) > 0 Then
        b = 1
        GoTo nd
    End If
Next n
For n = 103 To 255
    If InStr(WLeft, Chr(n)) > 0 Then
        b = 1
        GoTo nd
    End If
Next n
nd:
If b = 0 Then
    If Not Table(256, Val("&H" + WLeft)) = "" Then
        WordL = Table(256, Val("&H" + WLeft))
    Else
        WordL = "{" + Right("00" + WLeft, 2) + "}"
    End If
    If WLeft = "" Then WordL = ""
    Res.WLeft = WLeft
Else
    WLeft = Res.WLeft
    SendKeys "{End}"
End If
End If
End Sub

Private Sub Word_Change()
If zapret = 0 Then
    If List.ListIndex >= 0 Then
        List.List(List.ListIndex) = Word
    End If
End If
If Len(Word) = 1 Then
    WLeft = Hex(Asc(Word))
    WRight = ""
ElseIf Len(Word) = 2 Then
    WLeft = Hex(Asc(Left(Word, 1)))
    WRight = Hex(Asc(Right(Word, 1)))
Else
    WLeft = ""
    WRigh = ""
End If
End Sub

Private Sub WordL_Change()
FromHexZapret = True

LLen = Len(WordL)
If WordL = "" Then
    WLeft = ""
    s = 1
Else
    For n = 0 To 255
        If WordL = Table(256, n) Then
            WLeft = Right("00" + Hex(n), 2)
            s = 1
            Exit For
        End If
    Next n
End If
If s = 0 Then
    If Len(WordL) = 4 Then
        If Left(WordL, 1) = "{" And Right(WordL, 1) = "}" Then
            WLeft = Right("00" + Hex(Val("&H" + Mid(WordL, 2, 2))), 2)
        Else
            WLeft = "--"
        End If
    Else
        WLeft = "--"
    End If
End If

s = 0
FromHexZapret = False
End Sub

Private Sub WordR_Change()
FromHexZapret = True

RLen = Len(WordR)

If WordR = "" Then
    s = 1
    WRight = ""
Else
    For n = 0 To 255
        If WordR = Table(256, n) Then
            WRight = Right("00" + Hex(n), 2)
            s = 1
            Exit For
        End If
    Next n
End If
If s = 0 Then
    If Len(WordR) = 4 Then
        If Left(WordR, 1) = "{" And Right(WordR, 1) = "}" Then
            WRight = Right("00" + Hex(Val("&H" + Mid(WordR, 2, 2))), 2)
        Else
            WRight = "--"
        End If
    Else
        WRight = "--"
    End If
End If

s = 0
FromHexZapret = False
End Sub

Private Sub WRight_Change()
If FromHexZapret = False Then
b = 0
For n = 1 To 47
    If InStr(WRight, Chr(n)) > 0 Then
        b = 1
        GoTo nd
    End If
Next n '97 102
For n = 58 To 64
    If InStr(WRight, Chr(n)) > 0 Then
        b = 1
        GoTo nd
    End If
Next n
For n = 71 To 96
    If InStr(WRight, Chr(n)) > 0 Then
        b = 1
        GoTo nd
    End If
Next n
For n = 103 To 255
    If InStr(WRight, Chr(n)) > 0 Then
        b = 1
        GoTo nd
    End If
Next n
nd:
If b = 0 Then
    If Not Table(256, Val("&H" + WLeft)) = "" Then
        WordR = Table(256, Val("&H" + WRight))
    Else
        WordR = "{" + Right("00" + WRight, 2) + "}"
    End If
    If WRight = "" Then WordR = ""
    Res.WRight = WRight
Else
    WRight = Res.WRight
    SendKeys "{End}"
End If
End If
End Sub

Private Sub WRight_KeyDown(KeyCode As Integer, Shift As Integer)
'If KeyCode >= 48 And KeyCode <= 57 Or KeyCode >= 65 And KeyCode <= 70 Or KeyCode >= 0 And KeyCode <= 18 Then
'    Res.WRight = WRight
'Else
'    WRight = Res.WRight
'End If
'MsgBox Asc(Right(WRight, 1))
End Sub
