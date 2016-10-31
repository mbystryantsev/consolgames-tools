VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3090
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   5625
   LinkTopic       =   "Form1"
   ScaleHeight     =   3090
   ScaleWidth      =   5625
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command3 
      Caption         =   "Command3"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   840
      Width           =   5295
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Îבחמנ..."
      Height          =   255
      Left            =   4680
      TabIndex        =   3
      Top             =   480
      Width           =   855
   End
   Begin VB.TextBox fileLOG 
      Height          =   285
      Left            =   120
      TabIndex        =   2
      Text            =   "Sega\dis\1.asm.txt"
      Top             =   480
      Width           =   4455
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Îבחמנ..."
      Height          =   255
      Left            =   4680
      TabIndex        =   1
      Top             =   120
      Width           =   855
   End
   Begin VB.TextBox fileASM 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "Sega\dis\1.asm"
      Top             =   120
      Width           =   4455
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command3_Click()
Dim lne(1 To 3) As String
Open fileASM For Input As 1
Open fileLOG For Output As 2
While Not EOF(1)
For n = 1 To 2
    lne(n) = lne(n + 1)
Next n
Line Input #1, lne(3)
If lne(3) = Chr(9) & "JSR" & Chr(9) & "$000016E2" Then
    Print #2, "&H" & Mid(lne(1), 12, 8)
End If
Wend
Close
End Sub
