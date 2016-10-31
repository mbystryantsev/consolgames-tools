VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   6885
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   7170
   LinkTopic       =   "Form1"
   ScaleHeight     =   6885
   ScaleWidth      =   7170
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command6 
      Caption         =   "save"
      Height          =   255
      Left            =   2280
      TabIndex        =   15
      Top             =   3720
      Width           =   495
   End
   Begin VB.CommandButton Command5 
      Caption         =   "<<--"
      Height          =   255
      Left            =   2280
      TabIndex        =   13
      Top             =   3360
      Width           =   495
   End
   Begin VB.HScrollBar HS2 
      Height          =   255
      Left            =   3000
      TabIndex        =   12
      Top             =   4320
      Width           =   1815
   End
   Begin VB.HScrollBar HS 
      Height          =   255
      Left            =   240
      TabIndex        =   10
      Top             =   4320
      Width           =   1815
   End
   Begin VB.PictureBox P2 
      Height          =   1575
      Left            =   3000
      ScaleHeight     =   1600
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   1600
      TabIndex        =   9
      Top             =   2760
      Width           =   1815
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Command4"
      Height          =   495
      Left            =   120
      TabIndex        =   8
      Top             =   1800
      Width           =   5775
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Command3"
      Height          =   495
      Left            =   120
      TabIndex        =   6
      Top             =   1200
      Width           =   5775
   End
   Begin VB.TextBox file3 
      Height          =   285
      Left            =   120
      TabIndex        =   5
      Text            =   "PM\TL\00187411.til"
      Top             =   840
      Width           =   5775
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Command2"
      Height          =   495
      Left            =   120
      TabIndex        =   4
      Top             =   5880
      Width           =   735
   End
   Begin VB.TextBox file2 
      Height          =   285
      Left            =   120
      TabIndex        =   3
      Text            =   "PM\GF\Test\0015DCD1.sgf"
      Top             =   480
      Width           =   5775
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   120
      TabIndex        =   2
      Text            =   "PM\GF\Test\0018536A.sgf"
      Top             =   120
      Width           =   5775
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   495
      Left            =   1440
      TabIndex        =   1
      Top             =   5760
      Width           =   1335
   End
   Begin VB.PictureBox P 
      Height          =   1575
      Left            =   240
      ScaleHeight     =   1600
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   1600
      TabIndex        =   0
      Top             =   2760
      Width           =   1815
   End
   Begin VB.Label L2 
      Caption         =   "Label1"
      Height          =   255
      Left            =   3000
      TabIndex        =   14
      Top             =   4680
      Width           =   1815
   End
   Begin VB.Label L1 
      Caption         =   "Label1"
      Height          =   255
      Left            =   240
      TabIndex        =   11
      Top             =   4680
      Width           =   1815
   End
   Begin VB.Label Pr 
      Caption         =   "Label1"
      Height          =   375
      Left            =   480
      TabIndex        =   7
      Top             =   5520
      Width           =   4455
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Command1_Click()
Dim n As Integer
Dim c As Integer
For n = 1 To 8
    For c = 1 To 8
        Call PsSet(n, c, n + c - 1)
    Next c
Next n
End Sub

Private Sub Command2_Click()
Open file2 For Binary As 2
'Dim fil2() As Byte
ReDim fil2(LOF(2))
Get #2, 1, fil2()
Close 2
Call GetBlock(3)
End Sub


Private Sub Command3_Click()
Open file1 For Binary As 1
Open file2 For Binary As 2
Dim c As Integer
Dim n As Long
Dim f As Integer
ReDim Block(1 To 16) As Byte
ReDim fil1(LOF(1)) As Byte
ReDim fil2(LOF(2)) As Byte
ReDim fil3(LOF(1) * 16 - 1) As Byte
ReDim Ef(LOF(1) / 2 + 1) As Byte
LofF(1) = LOF(1)
LofF(2) = LOF(2)
Get #1, 1, fil1()
Get #2, 1, fil2()
f3pos = 0
cnt = 1
For n = 1 To LofF(1) Step 2
    If cnt = 17 Then
        cnt = 1
        For l = 1 To 16
            f = Block(l)
            Call WrBlock(f + 1)
            'MsgBox Block(l)
        Next l
    End If
    Block(cnt) = fil1(n): cnt = cnt + 1
    'MsgBox "fil1(" & n & ") = " & fil1(n)
    Pr = n & "/" & LofF(1) & " [" & Int(n / LofF(1) * 100) & "%]"
    Pr.Refresh
Next n
Close 1
Close 2
Open file3 For Binary As 3
For n = 1 To f3pos
    Put #3, n, fil3(n - 1)
Next n
Close 3
End Sub

Private Sub Command4_Click()
Edit.zapret = True
Open file1 For Binary As 1
Open file2 For Binary As 2
Dim c As Integer
Dim n As Long
Dim f As Integer
ReDim fil1(LOF(1)) As Byte
ReDim fil2(LOF(2)) As Byte
LofF(1) = LOF(1)
LofF(2) = LOF(2)
Get #1, 1, fil1()
Get #2, 1, fil2()
Close 1
Close 2
HS.Min = 1
HS.Max = LofF(1) / 2
L1 = "1/" & LofF(1) / 2
Call GetBlock(1)
Edit.pos1 = 1
Edit.pos2 = 1
HS2.Min = 1
HS2.Max = LofF(2) / 32
L2 = "1/" & LofF(2) / 32
Call GetBlock2(1)
Edit.zapret = False
End Sub

Private Sub Command5_Click()
fil1(Edit.pos1 * 2 - 1) = Edit.pos2 - 1
Call HS_Change
End Sub

Private Sub Command6_Click()
Open file1 For Binary As 1
For n = 1 To LofF(1)
    Put #1, n, fil1(n - 1)
Next n
Close 1
End Sub

Private Sub Form_Load()
clr(0) = &H403060
clr(1) = &H6848A0
clr(2) = &HFFE0B0
clr(3) = &HFEFFFF
clr(4) = &H1
clr(5) = &H787878
clr(6) = &HB0B0B0
clr(7) = &HE8E8E8
clr(8) = &H1
clr(9) = &HE8E8E8
clr(10) = &HB0B0B0
clr(11) = &H787878
clr(12) = &H1
clr(13) = &HF04090
clr(14) = &HFFA070
clr(15) = &HFFC0B0
End Sub

Private Sub HS_Change()
Dim s As Integer
If Edit.zapret = True Then Exit Sub
 Edit.pos1 = HS
 s = fil1(Edit.pos1 * 2 - 1)
 L1 = HS & "/" & LofF(1) / 2 & " - " & Right("00" & Hex(s), 2) & " " & Edit.pos1 & " " & Edit.pos1 * 2 - 1
 Call GetBlock(s + 1)
End Sub

Private Sub HS2_Change()

Dim s As Integer
If Edit.zapret = True Then Exit Sub
 Edit.pos2 = HS2
 s = Edit.pos2
 L2 = HS2 & "/" & LofF(1) / 2 & " - " & s
 Call GetBlock2(s)
End Sub
