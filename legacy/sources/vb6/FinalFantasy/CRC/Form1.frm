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
   Begin VB.CommandButton Command2 
      Caption         =   "Command2"
      Height          =   495
      Left            =   120
      TabIndex        =   5
      Top             =   2400
      Width           =   4455
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   375
      Left            =   3000
      TabIndex        =   4
      Top             =   480
      Width           =   1575
   End
   Begin VB.TextBox Text 
      Height          =   1335
      Left            =   120
      TabIndex        =   3
      Text            =   "Text4"
      Top             =   960
      Width           =   4455
   End
   Begin VB.TextBox en 
      Height          =   285
      Left            =   1560
      TabIndex        =   2
      Text            =   "37b35"
      Top             =   480
      Width           =   1335
   End
   Begin VB.TextBox st 
      Height          =   285
      Left            =   120
      TabIndex        =   1
      Text            =   "37b10"
      Top             =   480
      Width           =   1215
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "ff\KRUPTAR\Final Fantasy.nes"
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
Dim bte As Byte
For n = Val("&H" & st) + 1 To Val("&H" & en) + 1
    Get #1, n, bte
    Sum = Sum + bte
    'Sum = Val(Right(Hex(Sum), 2))
Next n
Text = Hex(Sum)
Close
'37b18
'3234
End Sub

Private Sub Command2_Click()
Open file1 For Binary As 1
Dim bte As Byte
Dim bte1 As Byte
Dim bte2 As Byte
For n = &H37B10 + 1 To &H37B17 + 1
    Get #1, n, bte
    Sum = Sum + bte
Next n
For n = &H37B1F + 1 To &H37B35 + 1
    Get #1, n, bte
    Sum = Sum + bte
Next n
For n = &H37B18 + 1 To &H37B1E + 1
    Get #1, n, bte
    Bts = Bts + bte
Next n
allsum = 3234 - Sum
MsgBox allsum & vbCrLf & Bts
For n = &H37B18 + 1 To &H37B1E + 1
    If allsum >= 255 Then
        allsum = allsum - 255
        Put #1, n, 255
    Else
        bte = allsum
        allsum = 0
        Put #1, n, bte
    End If
Next n
Close
'End
End Sub
