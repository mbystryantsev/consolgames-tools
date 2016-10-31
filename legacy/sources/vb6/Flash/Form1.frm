VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   2250
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   2250
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command2 
      Caption         =   "Command2"
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   1920
      Width           =   4455
   End
   Begin VB.TextBox file4 
      Height          =   285
      Left            =   120
      TabIndex        =   4
      Text            =   "Flash\NEWlogo_.map"
      Top             =   1560
      Width           =   4455
   End
   Begin VB.TextBox file3 
      Height          =   285
      Left            =   120
      TabIndex        =   3
      Text            =   "Flash\NEWlogo.map"
      Top             =   1200
      Width           =   4455
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   840
      Width           =   4455
   End
   Begin VB.TextBox file2 
      Height          =   285
      Left            =   120
      TabIndex        =   1
      Text            =   "Flash\logo.map"
      Top             =   480
      Width           =   4455
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "Flash\logo_.map"
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
Dim fil(1199) As Byte
Dim map(1199) As Byte
Open file1 For Binary As 1
pos = 0
Get #1, 5, fil()
Close 1
For n = 0 To 1199 Step 8
    map(pos) = fil(n)
    map(pos + 1) = fil(n + 1)
    map(pos + 2) = fil(n + 2)
    map(pos + 3) = fil(n + 3)
    map(pos + 60) = fil(n + 4)
    map(pos + 61) = fil(n + 5)
    map(pos + 62) = fil(n + 6)
    map(pos + 63) = fil(n + 7)
    pos = pos + 4
    cnt = cnt + 1
    If cnt = 15 Then
        cnt = 0
        pos = pos + 60
    End If
Next n
Open file2 For Binary As 2
Put #2, 1, 30
Put #2, 3, 20
Put #2, 5, map()
Close
End Sub

Private Sub Command2_Click()
On Error GoTo ed:
Dim fil(1199) As Byte
Dim map(1199) As Byte
Open file3 For Binary As 1
pos = 0
Get #1, 5, fil()
Close 1
For n = 0 To 1199 Step 120
    For l = n To n + 59 Step 4
        map(pos) = fil(l)
        map(pos + 1) = fil(l + 1)
        map(pos + 2) = fil(l + 2)
        map(pos + 3) = fil(l + 3)
        pos = pos + 8
    Next l
Next n
pos = 4
For n = 60 To 1199 Step 120
    For l = n To n + 59 Step 4
        map(pos) = fil(l)
        map(pos + 1) = fil(l + 1)
        map(pos + 2) = fil(l + 2)
        map(pos + 3) = fil(l + 3)
        pos = pos + 8
    Next l
Next n
ed:
Open file4 For Binary As 2
'Put #2, 1, 30
'Put #2, 3, 20
Put #2, 1, map()
Close
End Sub
