VERSION 5.00
Begin VB.Form GLoad 
   AutoRedraw      =   -1  'True
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Загрузка шрифта..."
   ClientHeight    =   8850
   ClientLeft      =   45
   ClientTop       =   315
   ClientWidth     =   6945
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8850
   ScaleWidth      =   6945
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame Frame4 
      Caption         =   "Параметры просмотра:"
      Height          =   735
      Left            =   120
      TabIndex        =   47
      Top             =   5760
      Width           =   6735
      Begin VB.TextBox vCount 
         Height          =   285
         Left            =   4560
         TabIndex        =   54
         Text            =   "256"
         Top             =   240
         Width           =   735
      End
      Begin VB.TextBox vScale 
         Height          =   285
         Left            =   2760
         TabIndex        =   52
         Text            =   "1"
         Top             =   240
         Width           =   735
      End
      Begin VB.TextBox vX 
         Height          =   285
         Left            =   480
         TabIndex        =   48
         Text            =   "16"
         Top             =   240
         Width           =   375
      End
      Begin VB.Label Label14 
         Caption         =   "символов."
         Height          =   255
         Left            =   5400
         TabIndex        =   55
         Top             =   240
         Width           =   855
      End
      Begin VB.Label Label13 
         Alignment       =   1  'Правая привязка
         Caption         =   "Вывести"
         Height          =   255
         Left            =   3720
         TabIndex        =   53
         Top             =   240
         Width           =   735
      End
      Begin VB.Label Label12 
         Alignment       =   1  'Правая привязка
         Caption         =   "Масштаб"
         Height          =   255
         Left            =   1920
         TabIndex        =   51
         Top             =   240
         Width           =   735
      End
      Begin VB.Label Label11 
         Caption         =   "символов."
         Height          =   255
         Left            =   960
         TabIndex        =   50
         Top             =   240
         Width           =   855
      End
      Begin VB.Label Label10 
         Alignment       =   1  'Правая привязка
         Caption         =   "По"
         Height          =   255
         Left            =   120
         TabIndex        =   49
         Top             =   240
         Width           =   255
      End
   End
   Begin VB.CommandButton Command8 
      Caption         =   "Загрузить таблицу"
      Height          =   375
      Left            =   120
      TabIndex        =   45
      Top             =   7680
      Width           =   6735
   End
   Begin VB.CommandButton Command4 
      Caption         =   "..."
      Height          =   255
      Left            =   6480
      TabIndex        =   44
      Top             =   7320
      Width           =   375
   End
   Begin VB.TextBox Gtable1 
      Height          =   285
      Left            =   120
      TabIndex        =   43
      Text            =   "KPE\ff.tbl"
      Top             =   7320
      Width           =   6255
   End
   Begin VB.PictureBox Picture1 
      Height          =   135
      Left            =   120
      ScaleHeight     =   75
      ScaleWidth      =   6675
      TabIndex        =   24
      Top             =   7080
      Width           =   6735
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Просмотреть"
      Height          =   375
      Left            =   120
      TabIndex        =   23
      Top             =   5280
      Width           =   6735
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Загрузить"
      Height          =   375
      Left            =   120
      TabIndex        =   22
      Top             =   6600
      Width           =   6735
   End
   Begin VB.ComboBox сSymbolH 
      Height          =   315
      ItemData        =   "GLoad.frx":0000
      Left            =   4200
      List            =   "GLoad.frx":0010
      Style           =   2  'Dropdown List
      TabIndex        =   12
      Top             =   720
      Width           =   495
   End
   Begin VB.ComboBox сSymbolW 
      Height          =   315
      ItemData        =   "GLoad.frx":0020
      Left            =   3480
      List            =   "GLoad.frx":0030
      Style           =   2  'Dropdown List
      TabIndex        =   11
      Top             =   720
      Width           =   495
   End
   Begin VB.ComboBox cBpp 
      Height          =   315
      ItemData        =   "GLoad.frx":0040
      Left            =   1800
      List            =   "GLoad.frx":0050
      Style           =   2  'Dropdown List
      TabIndex        =   4
      Top             =   720
      Width           =   855
   End
   Begin VB.ComboBox cTileH 
      Height          =   315
      ItemData        =   "GLoad.frx":006C
      Left            =   1080
      List            =   "GLoad.frx":0089
      Style           =   2  'Dropdown List
      TabIndex        =   3
      Top             =   720
      Width           =   615
   End
   Begin VB.ComboBox cTileW 
      Height          =   315
      ItemData        =   "GLoad.frx":00A6
      Left            =   240
      List            =   "GLoad.frx":00C3
      Style           =   2  'Dropdown List
      TabIndex        =   2
      Top             =   720
      Width           =   615
   End
   Begin VB.CommandButton Command1 
      Caption         =   "..."
      Height          =   255
      Left            =   6480
      TabIndex        =   1
      Top             =   120
      Width           =   375
   End
   Begin VB.TextBox Gfile1 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "ff\Kruptar\Final fantasy.nes"
      Top             =   120
      Width           =   6255
   End
   Begin VB.Frame Frame1 
      Caption         =   "Режим:"
      Height          =   4695
      Left            =   120
      TabIndex        =   5
      Top             =   480
      Width           =   6735
      Begin VB.CommandButton Command9 
         Caption         =   "Command9"
         Height          =   375
         Left            =   2040
         TabIndex        =   46
         Top             =   3720
         Width           =   375
      End
      Begin VB.CheckBox cSum 
         Caption         =   "Суммирование"
         Height          =   255
         Left            =   120
         TabIndex        =   42
         Top             =   2760
         Width           =   1575
      End
      Begin VB.CommandButton Command7 
         Caption         =   "Мэнеджер шаблонов"
         Height          =   255
         Left            =   3240
         TabIndex        =   41
         Top             =   4320
         Width           =   3255
      End
      Begin VB.CommandButton Command6 
         Caption         =   "Удалить щаблон..."
         Height          =   255
         Left            =   3240
         TabIndex        =   40
         Top             =   3960
         Width           =   3255
      End
      Begin VB.CommandButton Command5 
         Caption         =   "Сохранить шаблон..."
         Height          =   255
         Left            =   3240
         TabIndex        =   39
         Top             =   3600
         Width           =   3255
      End
      Begin VB.Frame Frame3 
         Caption         =   "Игровые шаблоны:"
         Height          =   615
         Left            =   3240
         TabIndex        =   36
         Top             =   2880
         Width           =   3255
         Begin VB.ComboBox cShGr 
            Height          =   315
            ItemData        =   "GLoad.frx":00E0
            Left            =   2520
            List            =   "GLoad.frx":00E7
            Style           =   2  'Dropdown List
            TabIndex        =   38
            Top             =   240
            Width           =   630
         End
         Begin VB.ComboBox cShGl 
            Height          =   315
            ItemData        =   "GLoad.frx":00EF
            Left            =   120
            List            =   "GLoad.frx":00F6
            Style           =   2  'Dropdown List
            TabIndex        =   37
            Top             =   240
            Width           =   2295
         End
      End
      Begin VB.CheckBox cVertical 
         Caption         =   "Вертикально"
         Height          =   255
         Left            =   120
         TabIndex        =   35
         Top             =   2520
         Width           =   2775
      End
      Begin VB.CheckBox cRIs 
         Caption         =   "Row-Interleaved, символы"
         Height          =   255
         Left            =   120
         TabIndex        =   34
         Top             =   840
         Width           =   2415
      End
      Begin VB.ComboBox cShP 
         Height          =   315
         ItemData        =   "GLoad.frx":0109
         Left            =   3360
         List            =   "GLoad.frx":0110
         Style           =   2  'Dropdown List
         TabIndex        =   31
         Top             =   2280
         Width           =   1215
      End
      Begin VB.Frame Frame2 
         Caption         =   "Шаблоны режимов:"
         Height          =   735
         Left            =   3240
         TabIndex        =   32
         Top             =   2040
         Width           =   3375
         Begin VB.ComboBox cShR 
            Height          =   315
            ItemData        =   "GLoad.frx":0120
            Left            =   1440
            List            =   "GLoad.frx":0127
            Style           =   2  'Dropdown List
            TabIndex        =   33
            Top             =   240
            Width           =   1815
         End
      End
      Begin VB.TextBox Text1 
         Height          =   285
         Left            =   5400
         TabIndex        =   29
         Text            =   "0"
         Top             =   1680
         Width           =   1095
      End
      Begin VB.CheckBox cSInvertV 
         Caption         =   "Инверсия символа по-вертикали"
         Height          =   255
         Left            =   120
         TabIndex        =   28
         Top             =   2280
         Width           =   2895
      End
      Begin VB.CheckBox cSInvertH 
         Caption         =   "Инверсия символа по-горизонтали"
         Height          =   255
         Left            =   120
         TabIndex        =   27
         Top             =   2040
         Width           =   3015
      End
      Begin VB.CheckBox cInvertH 
         Caption         =   "Инверсия тайла по-горизонтали"
         Height          =   255
         Left            =   120
         TabIndex        =   26
         Top             =   1560
         Width           =   2895
      End
      Begin VB.CheckBox cInvertV 
         Caption         =   "Инверсия тайла по-вертикали"
         Height          =   195
         Left            =   120
         TabIndex        =   25
         Top             =   1800
         Width           =   2655
      End
      Begin VB.TextBox cSStep 
         Height          =   285
         Left            =   5400
         TabIndex        =   21
         Text            =   "0"
         Top             =   1320
         Width           =   1095
      End
      Begin VB.TextBox cSCount 
         Height          =   285
         Left            =   5400
         TabIndex        =   18
         Text            =   "256"
         Top             =   960
         Width           =   1095
      End
      Begin VB.TextBox cFileAdr 
         Height          =   285
         Left            =   5400
         TabIndex        =   16
         Text            =   "&H24810"
         Top             =   600
         Width           =   1095
      End
      Begin VB.CheckBox cBitR 
         Caption         =   "Биты в обратном порядке"
         Height          =   255
         Left            =   120
         TabIndex        =   9
         Top             =   1320
         Width           =   2415
      End
      Begin VB.CheckBox cByteR 
         Caption         =   "Байт в обратном порядке"
         Height          =   255
         Left            =   120
         TabIndex        =   8
         Top             =   1080
         Width           =   2295
      End
      Begin VB.CheckBox cRIt 
         Caption         =   "Row-Interleaved, тайлы"
         Height          =   255
         Left            =   120
         TabIndex        =   7
         Top             =   600
         Width           =   2055
      End
      Begin VB.Label Label8 
         Alignment       =   1  'Правая привязка
         Caption         =   "Интервал, байт:"
         Height          =   255
         Left            =   3600
         TabIndex        =   30
         Top             =   1680
         Width           =   1695
      End
      Begin VB.Label Label7 
         Alignment       =   1  'Правая привязка
         Caption         =   "Интервал, символов:"
         Height          =   255
         Left            =   3600
         TabIndex        =   20
         Top             =   1320
         Width           =   1695
      End
      Begin VB.Label Label6 
         Alignment       =   1  'Правая привязка
         Caption         =   "Количество символов:"
         Height          =   255
         Left            =   3360
         TabIndex        =   19
         Top             =   960
         Width           =   1935
      End
      Begin VB.Label Label5 
         Alignment       =   1  'Правая привязка
         Caption         =   "Адрес в файле(&&H - Hex):"
         Height          =   255
         Left            =   3360
         TabIndex        =   17
         Top             =   720
         Width           =   1935
      End
      Begin VB.Label Label4 
         Caption         =   "тайлов"
         Height          =   255
         Left            =   4680
         TabIndex        =   15
         Top             =   240
         Width           =   615
      End
      Begin VB.Label Label1 
         Alignment       =   2  'Центровка
         Caption         =   "x"
         Height          =   255
         Index           =   1
         Left            =   3840
         TabIndex        =   13
         Top             =   240
         Width           =   255
      End
      Begin VB.Label Label2 
         Caption         =   "Символ"
         Height          =   255
         Left            =   2640
         TabIndex        =   10
         Top             =   240
         Width           =   615
      End
      Begin VB.Label Label1 
         Alignment       =   2  'Центровка
         Caption         =   "x"
         Height          =   255
         Index           =   0
         Left            =   720
         TabIndex        =   6
         Top             =   240
         Width           =   255
      End
   End
   Begin VB.Label Label3 
      Caption         =   "Label3"
      Height          =   255
      Left            =   4680
      TabIndex        =   14
      Top             =   720
      Width           =   615
   End
End
Attribute VB_Name = "GLoad"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
Gfile1 = DlgOpen
End Sub

Private Sub Command3_Click()
On Error GoTo ExSub:
Dim vXc
Dim tmpTil(15, 15) As Byte
Form1.Picture1.Cls
Open Gfile1 For Binary As 1
ReDim Tile(Ist(cSCount))
Dim tnS, tnE, tmS, tmE, nSt, nEn, mSt, mEn, tnStep, tmStep, nStep, mStep
Dim Vtn, Vtm, vBpp, sumFlag
vBpp = cBpp.ItemData(cBpp.ListIndex)
'MsgBox (vBpp / 8 * Val(cSCount) * (cTileW.ItemData(cTileW.ListIndex) * cTileH.ItemData(cTileH.ListIndex) * сSymbolW.ItemData(сSymbolW.ListIndex) * сSymbolH.ItemData(сSymbolH.ListIndex)))
ReDim fil((Val(cSStep) + 1) * (vBpp / 8 * Val(cSCount) * (cTileW.ItemData(cTileW.ListIndex) * cTileH.ItemData(cTileH.ListIndex) * сSymbolW.ItemData(сSymbolW.ListIndex) * сSymbolH.ItemData(сSymbolH.ListIndex))))
If cSum.Value = 1 Then vBpp = vBpp / 2
Get #1, Ist(cFileAdr) + 1, fil()
Close
For tilenum = 0 To Val(cSCount) * (Val(cSStep) + 1) - 1 '---

bpos = 1
For tn = 0 To сSymbolH.ItemData(сSymbolH.ListIndex) - 1
    For tm = 0 To сSymbolW.ItemData(сSymbolW.ListIndex) - 1
SumBegin:
        If cVertical.Value = 0 Then Vtn = tn: Vtm = tm Else Vtn = tm: Vtm = tn
        For n = Vtn * cTileH.ItemData(cTileH.ListIndex) To Vtn * cTileH.ItemData(cTileH.ListIndex) + cTileH.ItemData(cTileH.ListIndex) - 1
            For m = Vtm * cTileW.ItemData(cTileW.ListIndex) To Vtm * cTileW.ItemData(cTileW.ListIndex) + cTileW.ItemData(cTileW.ListIndex) - 1
                s = GetBits(fil(pos), bpos, vBpp, cBitR.Value * -1, cByteR.Value * -1)
                bpos = bpos + vBpp
                If bpos > 8 Then bpos = 1
                If sumflug = False Then Tile(tilenum).Til(n, m) = GetByte(s) Else Tile(tilenum).Til(n, m) = Tile(tilenum).Til(n, m) + GetByte(s)
                cnt = cnt + Len(s)
                If cnt >= 8 Then
                    cnt = 0
                    pos = pos + 1
                End If
            Next m
        Next n
        If cSum.Value = 1 And sumflug = False Then
            n = 0: m = 0: sumflug = True: GoTo SumBegin
        ElseIf cSum.Value = 1 And sumflug = True Then
            sumflug = False
        End If
    Next tm
Next tn
If Not sstep = Val(cSStep) + 1 And cSStep > 0 Then
    sstep = sstep + 1
    'Tile(tilenum).Til = tmpTil
    tilenum = tilenum - 1
    GoTo SkP:
End If
sstep = 0
Tile(tilenum).H = 8
Tile(tilenum).w = 8
If vXc >= Val(vX) Then
    vXc = 0
    locpos = 0
    locposy = locposy + сSymbolH.ItemData(сSymbolH.ListIndex) * cTileH.ItemData(cTileH.ListIndex)
End If
vXc = vXc + 1
If tilenum < Val(vCount) Then Call Locate(tilenum, locpos, locposy, vScale)
Form1.Picture1.Refresh
locpos = locpos + 8
SkP:
Next tilenum
ExSub:
End Sub



Private Sub Command4_Click()
Gtable1 = DlgOpen
End Sub

Private Sub Command8_Click()
Open Gtable1 For Input As 1
Dim s As String
Dim cnt As Integer
Dim rCom As String
Dim w As String
ReDim Table(0) As TypeTable '--------+++--------+++------
While Not EOF(1)
    Line Input #1, s
    If Left(s, 10) = "[TileDif]=" Then
        cTable.TileDif = Ist(Right(s, Len(s) - 10))
    ElseIf Left(s, 8) = "[Width]=" Then
        cTable.Width = Ist(Right(s, Len(s) - 8))
    ElseIf Left(s, 9) = "[Height]=" Then
        cTable.Height = Ist(Right(s, Len(s) - 9))
    Else
        GoTo LoadS:
    End If
    GoTo nxt:
LoadS:
If s = "" Or InStr(s, "=") = 0 Then GoTo nxt
l = Probel(s, 1, "=")
Table(cnt).Value = Ist("&H" & l)
Table(cnt).Height = cTable.Height
Table(cnt).Width = cTable.Width
Table(cnt).Tile = Table(cnt).Value - cTable.TileDif
r = Right(s, Len(s) - Len(l) - 1)
rCom = Right(r, Len(r) - InStrRev(r, ":", Len(r)))
If InStrRev(r, ":", Len(r)) <= 1 Then
    Table(cnt).Text = r
    cnt = cnt + 1
    Call Add(Table())
    GoTo nxt:
End If
Table(cnt).Text = Left(r, Len(r) - Len(rCom) - 1)
w = Probel(rCom, 1, ";")
If w = "" Then Table(cnt).Width = cTable.Width Else Table(cnt).Width = Ist(w)
w = Probel(rCom, 2, ";")
If w = "" Then Table(cnt).Height = cTable.Height Else Table(cnt).Height = Ist(w)
w = Probel(rCom, 3, ";")
If w = "" Then Table(cnt).Tile = Table(cnt).Value - cTable.TileDif Else Table(cnt).Tile = Ist(w)
Tile(Table(cnt).Tile).H = Table(cnt).Height
Tile(Table(cnt).Tile).w = Table(cnt).Width
Call Add(Table())
cnt = cnt + 1
nxt:
Wend
cTable.cnt = cnt
Close
End Sub

Private Sub Command9_Click()
Form1.Picture1.Cls
Call LocLine("Yes! All worked! I'm very happy!!!!", 0, 0)
End Sub

Private Sub cSCount_Change()
vCount = cSCount
End Sub

Private Sub Form_Load()
Static Opnd As Boolean
If Opnd = False Then
    cTileW.ListIndex = 2
    cTileH.ListIndex = 2
    cBpp.ListIndex = 1
    сSymbolW.ListIndex = 0
    сSymbolH.ListIndex = 0
    cRIs.Enabled = False
    cRIt.Enabled = False
    cInvertH.Enabled = False
    cInvertV.Enabled = False
    cSInvertH.Enabled = False
    cSInvertV.Enabled = False
    'cByteR.Enabled = False
    'cBitR.Enabled = False
    cShP.ListIndex = 0
    cShR.ListIndex = 0
    cSum.Value = 1
    Opnd = True
End If
End Sub

