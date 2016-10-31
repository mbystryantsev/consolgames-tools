VERSION 5.00
Object = "{63E5F280-E28C-11D4-BF3F-A7DE75CE211C}#1.0#0"; "AdvProgressBar.ocx"
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   4800
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   6015
   LinkTopic       =   "Form1"
   ScaleHeight     =   4800
   ScaleWidth      =   6015
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox fileLOG 
      Height          =   285
      Left            =   120
      TabIndex        =   9
      Text            =   "FF8\RIPlog.log"
      Top             =   840
      Width           =   5775
   End
   Begin VB.TextBox FPrefix 
      Height          =   285
      Left            =   120
      TabIndex        =   8
      Text            =   "file"
      Top             =   1920
      Width           =   5775
   End
   Begin VB.TextBox EndPos 
      Height          =   285
      Left            =   3000
      TabIndex        =   7
      Text            =   "&H25E09A6F"
      Top             =   1560
      Width           =   2895
   End
   Begin VB.TextBox StartPos 
      Height          =   285
      Left            =   120
      TabIndex        =   6
      Text            =   "&H0"
      Top             =   1560
      Width           =   2775
   End
   Begin VB.CheckBox Check1 
      Caption         =   "                 Только изменйнные в RGR-овской версии"
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   2280
      Width           =   5775
   End
   Begin VB.TextBox fileRGR 
      ForeColor       =   &H8000000D&
      Height          =   285
      Left            =   120
      TabIndex        =   4
      Text            =   "FF8\RSS\FF8DISC1.IMG"
      Top             =   1200
      Width           =   5775
   End
   Begin AdvanceProgressBar.AdvProgressBar APB 
      Height          =   255
      Left            =   120
      Top             =   4440
      Width           =   5775
      _ExtentX        =   10186
      _ExtentY        =   450
      Appearance      =   1
      BackColor       =   -2147483633
      BorderStyle     =   1
      Caption         =   ""
      Enabled         =   -1  'True
      FloodColor      =   192
      ForeColor       =   -2147483634
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
   Begin VB.CommandButton Command1 
      Caption         =   "Разобрать"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   4080
      Width           =   5775
   End
   Begin VB.TextBox Text3 
      Height          =   1335
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Вертикаль
      TabIndex        =   2
      Top             =   2640
      Width           =   5775
   End
   Begin VB.TextBox Path 
      Height          =   285
      Left            =   120
      TabIndex        =   1
      Text            =   "FF8\RIP\"
      Top             =   480
      Width           =   5775
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "FF8DISC1.IMG"
      Top             =   120
      Width           =   5775
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
Open file1 For Binary As 1
Open fileLOG For Output As 2
Open fileRGR For Binary As 3
Dim bte As Byte
minpos = IntH(Ist(StartPos)) + 1
maxpos = IntH(Ist(EndPos)) + 1
spos = minpos
epos = spos + 2048 - 1
APB.Min = minpos
APB.Max = maxpos
For n = minpos To maxpos Step 2048
APB.Value = n
APB.Caption = Hex(n) & "/" & Hex(maxpos) & " - " & Int((n - minpos) / (maxpos - minpos) * 100) & "%"
    For l = 1 To 32
        Get #1, n + 2015 + l, bte
        If bte <> 0 Then
            epos = n + 4095
            GoTo exfr
        End If
    Next l
    For l = spos To epos
    Get #3, l, bte
    If bte > 0 Then GoTo bignull
    Next l
    GoTo minnull
bignull:
    Open Path & FPrefix & Right("00000000" & Hex(spos - 1), 8) & "-" & Right("00000000" & Hex(epos - 1), 8) & ".fhx" For Binary As 5
    cnt = 1
    For l = spos To epos
        Get #1, l, bte
        Put #5, cnt, bte: cnt = cnt + 1
    Next l
    Print #2, Path & FPrefix & Right("00000000" & Hex(spos - 1), 8) & "-" & Right("00000000" & Hex(epos - 1), 8) & ".fhx" & " " & Right("00000000" & Hex(spos - 1), 8) & " " & Right("00000000" & Hex(epos - 1), 8)
minnull:
    Close 5
    spos = n + 2048
    epos = n + 4095
exfr:
Next n
End Sub
