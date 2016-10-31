VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   1800
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   1800
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   1200
      Width           =   4455
   End
   Begin VB.TextBox MaxTxt 
      Height          =   285
      Left            =   2400
      TabIndex        =   3
      Text            =   "&H54c27"
      Top             =   840
      Width           =   2175
   End
   Begin VB.TextBox MinTxt 
      Height          =   285
      Left            =   120
      TabIndex        =   2
      Text            =   "&H53649"
      Top             =   840
      Width           =   2175
   End
   Begin VB.TextBox file2 
      Height          =   285
      Left            =   120
      TabIndex        =   1
      Text            =   "PMLog.txt"
      Top             =   480
      Width           =   4455
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "PM\Pac-Man_2_-_The_New_Adventures_(U)_[!].bin"
      Top             =   120
      Width           =   4455
   End
   Begin VB.Label Label 
      Alignment       =   2  'Центровка
      Caption         =   "Label1"
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   1560
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
Open file2 For Output As 2
Dim byt(1 To 4) As Byte
Dim PntTxt As String
ReDim fil(LOF(1) - 1) As Byte
Dim dmp As String
LofF = LOF(1) - 1
Get #1, 1, fil()
Close 1
mnps = Val(MinTxt)
mxps = Val(MaxTxt)
pos = mnps

n1:
'Dumping
q = ""
For ss = pos To pos + 5
    dmp = dmp & "[#" & Right("00" & Hex(fil(ss)), 2) & "]"
Next ss
n11:
If fil(ss) <= 7 Then
    If fil(ss) = 1 Then q = "\" Else If fil(ss) = 2 Then q = "|" Else If fil(ss) = 3 Then q = "/" Else If fil(ss) = 4 Then q = "@" Else If fil(ss) = 5 Then q = "#" Else If fil(ss) = 6 Then q = "&" Else If fil(ss) = 7 Then q = "%"
    dmp = dmp & q
    GoTo PreSearch
ElseIf fil(ss) >= 128 And fil(ss) <= &H8F Then
    For n = 128 To fil(ss) Step 2
        q = q & "_"
    Next n
    dmp = dmp & q
    q = ""
    ss = ss + 1
    GoTo n11
ElseIf fil(ss) = 255 Then
    dmp = dmp & "^"
    ss = ss + 1
    GoTo n11
Else
    dmp = dmp & Chr(fil(ss))
    ss = ss + 1
    GoTo n11
End If
PreSearch:
PntTxt = Nul(Hex(pos))
For n = 1 To 7 Step 2
    s = Mid(PntTxt, n, 2)
    byt((n + 1) / 2) = Val("&H" & s)
Next n
Search:
If pos >= mxps Then
    Close 2
    Exit Sub
End If
Label = pos & "/" & mxps & " [" & Int(((pos - mnps) / (mxps - mnps)) * 100 + 1) & "%]"
Label.Refresh
For n = 0 To LofF Step 2
Cnt = 1
cn:
If Cnt = 5 Then
txt = "[DefineTextBlock]=" & Nul("&H" & Hex(n)) & vbCrLf & "[UsedTableSet]=0" & vbCrLf
txt = txt & "[PtrTableStart]=h" & Nul("&H" & Hex(n)) & vbCrLf & "[StringPointer]=h"
txt = txt & PntTxt & vbCrLf & "[StringStart]" & vbCrLf & dmp & vbCrLf & "[StringEnd]" & vbCrLf & "[TextBlockEnd]"
Print #2, txt
GoTo nn
End If
If byt(Cnt) = fil(n + Cnt - 1) Then
    Cnt = Cnt + 1
    GoTo cn:
Else
    Cnt = 1
End If
'byt(4) = 1
nn:
Next n

pos = pos + 6
n2:
If fil(pos) <= 7 Then
    pos = pos + 1
    dmp = ""
    GoTo n1
Else
    pos = pos + 1
    GoTo n2
End If
Close 2
End Sub

