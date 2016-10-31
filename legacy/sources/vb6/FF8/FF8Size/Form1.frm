VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3090
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3090
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox Size 
      Height          =   285
      Left            =   0
      TabIndex        =   2
      Text            =   "635625472"
      Top             =   480
      Width           =   1935
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   855
      Left            =   960
      TabIndex        =   1
      Top             =   1080
      Width           =   2055
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   0
      TabIndex        =   0
      Text            =   "FF8\RSS\FF8CD1\DATA\FF8DISC1.IMG"
      Top             =   120
      Width           =   4455
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
Open file1 For Binary As 1
Put #1, Val(Size) - 1, 0
Close
MsgBox "Âñ¸!"
End Sub
