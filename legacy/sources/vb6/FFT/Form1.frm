VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   8700
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   12045
   LinkTopic       =   "Form1"
   ScaleHeight     =   8700
   ScaleWidth      =   12045
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command2 
      Caption         =   "Add"
      Height          =   375
      Left            =   120
      TabIndex        =   9
      Top             =   8160
      Width           =   5295
   End
   Begin VB.ListBox List2 
      Height          =   6885
      Left            =   6360
      TabIndex        =   8
      Top             =   1200
      Width           =   5535
   End
   Begin VB.ListBox List1 
      Height          =   6885
      Left            =   960
      TabIndex        =   7
      Top             =   1200
      Width           =   5295
   End
   Begin VB.TextBox MaxPos 
      Height          =   285
      Left            =   840
      TabIndex        =   6
      Text            =   "10"
      Top             =   840
      Width           =   615
   End
   Begin VB.TextBox MinPos 
      Height          =   285
      Left            =   120
      TabIndex        =   5
      Text            =   "1"
      Top             =   840
      Width           =   615
   End
   Begin VB.ListBox List 
      Height          =   6885
      Left            =   120
      TabIndex        =   3
      Top             =   1200
      Width           =   735
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Execute"
      Height          =   195
      Left            =   120
      TabIndex        =   2
      Top             =   480
      Width           =   11295
   End
   Begin VB.TextBox file2 
      Height          =   285
      Left            =   5880
      TabIndex        =   1
      Text            =   "_job\fft\1.tbl"
      Top             =   120
      Width           =   5535
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "_job\fft\test.evt"
      Top             =   120
      Width           =   5655
   End
   Begin VB.Label LabelB 
      Caption         =   "Label2"
      Height          =   255
      Left            =   6720
      TabIndex        =   11
      Top             =   840
      Width           =   1455
   End
   Begin VB.Label LabelA 
      Caption         =   "Label2"
      Height          =   255
      Left            =   3240
      TabIndex        =   10
      Top             =   840
      Width           =   1095
   End
   Begin VB.Label Label1 
      Caption         =   "Label1"
      Height          =   255
      Left            =   1560
      TabIndex        =   4
      Top             =   840
      Width           =   615
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
Dim bte As Byte
'Упрощённый вариант загрузки таблицы
Open file2 For Input As 1
While Not EOF(1)
    Line Input #1, s
    If Mid(s, 3, 1) = "=" Then
        Table(Val("&H" & Mid(s, 1, 2))) = Right(s, Len(s) - 3)
    Else
    End If
Wend
Close
'Загрузка файла по блокам
Open file1 For Binary As 1
Dim head As Long
Dim dlg As Integer
Dim t As Long
pos = 1
retry:
Get #1, pos, head: pos = pos + 1
If head = &HF2F2F2F2 Then
    dlg = 0
    pos = pos + 3
again:
    r = 0
    For n = pos To pos + 20 Step 4
        Get #1, n, head
        If head = 0 Then r = r + 1
    Next n
    If r >= 5 Then
        'flag = False
        'MsgBox "1", , "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        'txt.dlg(cnt) = dlg
        cnt = cnt + 1
        List.AddItem (cnt)
        If cnt >= Val(MaxPos) Then GoTo ed:
        If pos > 4096000 Then GoTo ed:
        pos = pos + 4
        bte = 0
        While bte = 0
            Get #1, pos, bte: pos = pos + 1
        Wend
        GoTo aen:
    Else
        Get #1, pos, bte: pos = pos + 1
        If bte = &HFE Then
            'MsgBox text(cnt, dlg)
            dlg = dlg + 1 ': pos = pos + 1
            txt(cnt).dlg = dlg
            txt(cnt).epos(dlg) = pos - 2
            txt(cnt).spos(dlg + 1) = pos - 1
        Else
            If Table(bte) = "" Then
                text(cnt, dlg) = text(cnt, dlg) & "*"
            Else
                text(cnt, dlg) = text(cnt, dlg) & Table(bte) ': pos = pos + 1
            End If
        End If
    End If
End If
aen:
Label1.Caption = cnt
Label1.Refresh
GoTo again:
GoTo retry:

ed:
'For n = 0 To cnt
Close 1
End Sub

Private Sub List_Click()
List1.Clear
List2.Clear
For n = 0 To txt(List.ListIndex).dlg
    List1.AddItem text(List.ListIndex, n)
    List2.AddItem text(List.ListIndex, n)
Next n
End Sub

Private Sub List1_Click()
LabelA.Caption = Hex(txt(List.ListIndex).spos(List1.ListIndex))
End Sub

Private Sub List2_Click()
LabelB.Caption = Hex(txt(List.ListIndex).epos(List2.ListIndex))
End Sub
