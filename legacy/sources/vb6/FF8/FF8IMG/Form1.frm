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
   Begin VB.TextBox Log 
      Height          =   1455
      Left            =   120
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Вертикаль
      TabIndex        =   5
      Top             =   1560
      Width           =   4455
   End
   Begin VB.TextBox Text 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   120
      TabIndex        =   4
      Top             =   1200
      Width           =   4455
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   840
      Width           =   4455
   End
   Begin VB.TextBox MaxAdr 
      Height          =   285
      Left            =   2400
      TabIndex        =   2
      Text            =   "&H427"
      Top             =   480
      Width           =   2175
   End
   Begin VB.TextBox MinAdr 
      Height          =   285
      Left            =   120
      TabIndex        =   1
      Text            =   "&H0"
      Top             =   480
      Width           =   2175
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "FF8DISC1.IMG"
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
Dim pnt As Long
Dim bte As Byte
Open file1 For Binary As 1
For n = Val(MinAdr) + 1 To Val(MaxAdr) + 1 Step 4
    For c = 1 To 4 ' Step -1
        Get #1, n + c - 1, bte
        pnt = pnt + bte * 256 ^ (c - 1)
    Next c
    sum = sum + pnt
    pnt = H800(pnt)
    'MsgBox Hex(pnt)
    Log = Log & Hex(pnt) & vbCrLf
    sum2 = sum2 + pnt
    pnt = 0
Next n
Close
Text = sum & " - " & Hex(sum) & "   -==|||==-   " & sum2 & " - " & Hex(sum2)
End Sub
