VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Object = "{7F0DC2FA-DACB-4A76-B3C3-86A36AB1228A}#1.0#0"; "LEDMeter.ocx"
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   8085
   ClientLeft      =   1080
   ClientTop       =   570
   ClientWidth     =   8850
   LinkTopic       =   "Form1"
   ScaleHeight     =   8085
   ScaleWidth      =   8850
   Begin MSComctlLib.Slider Slider1 
      Height          =   495
      Left            =   1800
      TabIndex        =   34
      Top             =   3720
      Width           =   4455
      _ExtentX        =   7858
      _ExtentY        =   873
      _Version        =   393216
      Max             =   20
   End
   Begin LEDMETERLib.LEDMeter LEDMeter1 
      Height          =   1575
      Left            =   1680
      TabIndex        =   33
      Top             =   5520
      Width           =   1935
      _Version        =   65536
      _ExtentX        =   3413
      _ExtentY        =   2778
      _StockProps     =   0
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   32
      Left            =   7440
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   32
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   31
      Left            =   7080
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   31
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   30
      Left            =   6720
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   30
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   29
      Left            =   6360
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   29
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   28
      Left            =   6000
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   28
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   27
      Left            =   5640
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   27
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   26
      Left            =   5280
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   26
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   25
      Left            =   4920
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   25
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   24
      Left            =   4560
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   24
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   23
      Left            =   4200
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   23
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   22
      Left            =   3840
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   22
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   21
      Left            =   3480
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   21
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   20
      Left            =   3120
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   20
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   19
      Left            =   2760
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   19
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   18
      Left            =   2400
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   18
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   17
      Left            =   2040
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   17
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   0
      Left            =   5520
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   16
      Top             =   720
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   1
      Left            =   2040
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   15
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   2
      Left            =   2400
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   14
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   3
      Left            =   2760
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   13
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   4
      Left            =   3120
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   12
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   5
      Left            =   3480
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   11
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   6
      Left            =   3840
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   10
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   7
      Left            =   4200
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   9
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   8
      Left            =   4560
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   8
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   9
      Left            =   4920
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   7
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   10
      Left            =   5280
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   6
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   11
      Left            =   5640
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   5
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   12
      Left            =   6000
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   4
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   13
      Left            =   6360
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   3
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   14
      Left            =   6720
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   2
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   15
      Left            =   7080
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   1
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox Pic 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   375
      Index           =   16
      Left            =   7440
      ScaleHeight     =   278.226
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   375
      TabIndex        =   0
      Top             =   2160
      Width           =   375
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Pic_Click(Index As Integer)
Pic(Index).BackColor = 0
End Sub

Private Sub Pic_MouseMove(Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)

Select Case Button
Case vbLeftButton
    Pic(Index).BackColor = 0
End Select
'End If

End Sub
