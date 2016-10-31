VERSION 5.00
Begin VB.Form Form1 
   AutoRedraw      =   -1  'True
   Caption         =   "Form1"
   ClientHeight    =   8955
   ClientLeft      =   165
   ClientTop       =   855
   ClientWidth     =   11535
   LinkTopic       =   "Form1"
   ScaleHeight     =   8955
   ScaleWidth      =   11535
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command4 
      Caption         =   "Command4"
      Height          =   255
      Left            =   2400
      TabIndex        =   19
      Top             =   4440
      Width           =   375
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Command3"
      Height          =   255
      Left            =   2880
      TabIndex        =   18
      Top             =   3960
      Width           =   495
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Command2"
      Height          =   195
      Left            =   1800
      TabIndex        =   17
      Top             =   240
      Width           =   615
   End
   Begin VB.TextBox Text2 
      Height          =   285
      Left            =   1680
      TabIndex        =   15
      Text            =   "Text2"
      Top             =   4320
      Width           =   495
   End
   Begin VB.Timer Timer1 
      Interval        =   1000
      Left            =   2400
      Top             =   3360
   End
   Begin VB.CheckBox Check1 
      Alignment       =   1  'Правая привязка
      Caption         =   "Обновлять всегда"
      Height          =   255
      Left            =   120
      TabIndex        =   14
      Top             =   3960
      Width           =   1935
   End
   Begin VB.TextBox Text1 
      Height          =   285
      Left            =   1680
      TabIndex        =   13
      Text            =   "60"
      Top             =   3600
      Width           =   375
   End
   Begin VB.TextBox lScale 
      BeginProperty DataFormat 
         Type            =   0
         Format          =   "0"
         HaveTrueFalseNull=   0
         FirstDayOfWeek  =   0
         FirstWeekOfYear =   0
         LCID            =   1049
         SubFormatType   =   0
      EndProperty
      Height          =   285
      Left            =   1680
      TabIndex        =   10
      Text            =   "3"
      Top             =   3120
      Width           =   375
   End
   Begin VB.PictureBox Picture1 
      AutoRedraw      =   -1  'True
      Height          =   3855
      Left            =   120
      ScaleHeight     =   3795
      ScaleWidth      =   11235
      TabIndex        =   9
      Top             =   5040
      Width           =   11295
   End
   Begin VB.CommandButton Command1 
      BackColor       =   &H00D89090&
      Caption         =   "Command1"
      Height          =   255
      Left            =   240
      TabIndex        =   8
      Top             =   4680
      Width           =   1215
   End
   Begin VB.TextBox lText 
      Height          =   1815
      Left            =   3600
      TabIndex        =   7
      Text            =   "Text1"
      Top             =   3120
      Width           =   7935
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   7320
      TabIndex        =   6
      Text            =   "Text1"
      Top             =   0
      Width           =   5055
   End
   Begin VB.CommandButton OpenButton 
      Height          =   375
      Left            =   120
      Picture         =   "Form1.frx":0000
      Style           =   1  'Graphical
      TabIndex        =   5
      ToolTipText     =   "Открыть..."
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton SaveButton 
      Enabled         =   0   'False
      Height          =   375
      Left            =   480
      Picture         =   "Form1.frx":0442
      Style           =   1  'Graphical
      TabIndex        =   4
      ToolTipText     =   "Сохранить..."
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton SaveAsButton 
      Enabled         =   0   'False
      Height          =   375
      Left            =   840
      Picture         =   "Form1.frx":0884
      Style           =   1  'Graphical
      TabIndex        =   3
      ToolTipText     =   "Сохранить как..."
      Top             =   0
      Width           =   375
   End
   Begin VB.ListBox lList 
      Height          =   2595
      Left            =   3480
      TabIndex        =   2
      Top             =   480
      Width           =   7935
   End
   Begin VB.ListBox lItem 
      Height          =   2595
      Left            =   1800
      TabIndex        =   1
      Top             =   480
      Width           =   1575
   End
   Begin VB.ListBox lGroup 
      Height          =   2595
      Left            =   120
      TabIndex        =   0
      Top             =   480
      Width           =   1575
   End
   Begin VB.Label Label3 
      Alignment       =   1  'Правая привязка
      Caption         =   "Прозрачный цвет"
      Height          =   255
      Left            =   120
      TabIndex        =   16
      Top             =   4320
      Width           =   1455
   End
   Begin VB.Label Label2 
      Alignment       =   1  'Правая привязка
      Caption         =   "Масштаб:"
      Height          =   255
      Left            =   120
      TabIndex        =   12
      Top             =   3120
      Width           =   1335
   End
   Begin VB.Label Label1 
      Alignment       =   1  'Правая привязка
      Caption         =   "Время обновления:"
      Height          =   255
      Left            =   0
      TabIndex        =   11
      Top             =   3600
      Width           =   1575
   End
   Begin VB.Menu mFile 
      Caption         =   "Файл"
   End
   Begin VB.Menu mPallete 
      Caption         =   "Палитра"
      Begin VB.Menu mLoadPallete 
         Caption         =   "Загрузить палитру..."
      End
      Begin VB.Menu mSavePallete 
         Caption         =   "Сохранить палитру..."
      End
      Begin VB.Menu mImportPallete 
         Caption         =   "Импорт"
         Begin VB.Menu miMSpal 
            Caption         =   "Microsoft Pallere (*.PAL)"
         End
         Begin VB.Menu miPSpal 
            Caption         =   "Photoshop pallete (*.PAL)"
         End
         Begin VB.Menu miGBApal 
            Caption         =   "GBA Pallete (*.*)"
         End
      End
      Begin VB.Menu mExportPallete 
         Caption         =   "Экспорт"
         Begin VB.Menu meMSpal 
            Caption         =   "Microsoft Pallere (*.PAL)"
         End
         Begin VB.Menu mePSpal 
            Caption         =   "Photoshop pallete (*.PAL)"
         End
         Begin VB.Menu meGBApal 
            Caption         =   "GBA Pallete (*.*)"
         End
      End
      Begin VB.Menu msi 
         Caption         =   "Импорт из сохранения"
         Begin VB.Menu msiVBA 
            Caption         =   "Visual Boy Advance (*.SGM)"
            Begin VB.Menu misVBABG 
               Caption         =   "BG"
            End
            Begin VB.Menu msiVBAOBJ 
               Caption         =   "OBJ"
            End
         End
         Begin VB.Menu msiNG 
            Caption         =   "No$gba (*.SNA)"
            Begin VB.Menu msiNGBG 
               Caption         =   "BG"
            End
            Begin VB.Menu msiNGOBJ 
               Caption         =   "OBJ"
            End
         End
      End
   End
   Begin VB.Menu mFont 
      Caption         =   "Шрифт"
      Begin VB.Menu mFontImport 
         Caption         =   "Импорт..."
      End
      Begin VB.Menu mFontLoadTable 
         Caption         =   "Загрузить таблицу ширин..."
      End
      Begin VB.Menu mFontSaveTable 
         Caption         =   "Сохранить таблицу ширин..."
      End
      Begin VB.Menu mFontEditTable 
         Caption         =   "Редактировать шрифты и таблицу..."
      End
   End
   Begin VB.Menu mHelp 
      Caption         =   "Помощь"
      Begin VB.Menu mHelpTable 
         Caption         =   "Таблица ширин"
      End
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
Private Sub Command1_Click()
Form1.Picture1.Cls
ReDim Tile(255)
For n = 0 To 15
    For l = 0 To 15
        Tile(0).Til(l, n) = l * 16 + n
    Next l
Next n
Tile(0).H = 16
Tile(0).w = 16

'Pallete(1) = &HFFFFFF
'    For m = 0 To 15
'        Tile(0).Til(m, m) = 1
'    Next m
Call Locate(0, 0, 0, lScale)
Call Locate(0, 15, 4, lScale)
'Call SetP(0, 0, 0, lScale)
End Sub




Private Sub Command2_Click()
Form1.BackColor = &H683020
End Sub

Private Sub Command3_Click()
Picture1.Cls
Call LocLine(lText, 0, 0)
End Sub

Private Sub Command4_Click()
MsgBox VarPtr(Pallete(1))
End Sub

Private Sub Form_Load()
For n = 0 To 255
    Pallete(n) = n + n / 2 * 256 + n / 3 * 256 ^ 2
Next n
GLoad.Show
End Sub

Private Sub mLoadPallete_Click()
fl = DlgOpen
Dim s As Byte
If fl = "" Then Exit Sub
Open fl For Binary As 1
For n = 1 To 768 Step 3
    Get #1, n, Pallete(pos)
    Get #1, n + 1, s: Pallete(pos) = Pallete(pos) + s * 256
    Get #1, n + 2, Pallete(pos): Pallete(pos) = Pallete(pos) + s * 256 ^ 2
    pos = pos + 1
Next n
End Sub

Private Sub OpenButton_Click()

Dial.Backup = Dial.file

Dial.Form = Me.hWnd
Dial.Filter = "AllFiles" & " (*.*)" + Chr$(0) + "*.*"
Dial.Title = "FileOpening"
Dial.file = ShowOpen
If Not InStr(1, Dial.file, "\") = 0 Then
    Dial.Dir = Right(Dial.file, Len(Dial.file) - InStrRev(Dial.file, "\"))
End If
If Dial.file = "" Then
    Dial.file = Dial.Backup
Else
    file1 = Dial.file
End If

Call ProjectLoad
End Sub

Public Sub ProjectLoad()
Open file1 For Input As 1
Dim GroupCount As Integer
Line Input #1, s
Line Input #1, s: Project.InputROM = Right(s, Len(s) - 11)
Line Input #1, s: Project.OutputROM = Right(s, Len(s) - 12)
Line Input #1, s: Project.Emulator = Right(s, Len(s) - 11)
'--Загрузка группы
Line Input #1, s: Project.InputROM = Right(s, Len(s) - 11)

End Sub

Private Sub Timer1_Timer()
Static n
n = n + 1
Label1 = n
End Sub
