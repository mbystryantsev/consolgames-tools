VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "FFT Text Editor"
   ClientHeight    =   8655
   ClientLeft      =   165
   ClientTop       =   855
   ClientWidth     =   11025
   LinkTopic       =   "Form1"
   ScaleHeight     =   8655
   ScaleWidth      =   11025
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command3 
      Caption         =   "Command3"
      Height          =   255
      Left            =   7800
      TabIndex        =   14
      Top             =   0
      Width           =   1095
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Command2"
      Height          =   255
      Left            =   6360
      TabIndex        =   13
      Top             =   0
      Visible         =   0   'False
      Width           =   615
   End
   Begin VB.TextBox file1 
      BackColor       =   &H80000003&
      Height          =   285
      Left            =   120
      Locked          =   -1  'True
      TabIndex        =   10
      Top             =   8040
      Width           =   5895
   End
   Begin VB.TextBox com 
      Height          =   285
      Left            =   3000
      TabIndex        =   6
      Top             =   360
      Width           =   3015
   End
   Begin VB.TextBox adr2 
      Height          =   285
      Left            =   1560
      Locked          =   -1  'True
      TabIndex        =   5
      Top             =   360
      Width           =   1335
   End
   Begin VB.TextBox adr1 
      Height          =   285
      Left            =   120
      Locked          =   -1  'True
      TabIndex        =   4
      Top             =   360
      Width           =   1335
   End
   Begin VB.CommandButton Command1 
      Caption         =   "GoTo:"
      Height          =   255
      Left            =   9480
      TabIndex        =   3
      Top             =   0
      Width           =   615
   End
   Begin VB.TextBox GTo 
      Height          =   285
      Left            =   10200
      TabIndex        =   2
      Text            =   "1"
      Top             =   0
      Width           =   735
   End
   Begin VB.TextBox Text1 
      Height          =   7215
      Left            =   120
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Оба
      TabIndex        =   1
      Text            =   "Form1.frx":0000
      Top             =   720
      Width           =   5895
   End
   Begin VB.ListBox List 
      Height          =   7470
      Left            =   6120
      TabIndex        =   0
      Top             =   360
      Width           =   4815
   End
   Begin VB.Label Label4 
      Caption         =   "Ctrl+C/Ctrl+V на списке - операции со всем блоком текста."
      Height          =   255
      Left            =   120
      TabIndex        =   12
      Top             =   8400
      Visible         =   0   'False
      Width           =   10815
   End
   Begin VB.Label LCount 
      Height          =   255
      Left            =   6120
      TabIndex        =   11
      Top             =   8040
      Width           =   1095
   End
   Begin VB.Label Label3 
      Caption         =   "Комментарии:"
      Height          =   255
      Left            =   3000
      TabIndex        =   9
      Top             =   120
      Width           =   3135
   End
   Begin VB.Label Label2 
      Caption         =   "Adr2:"
      Height          =   255
      Left            =   1560
      TabIndex        =   8
      Top             =   120
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Adr1:"
      Height          =   255
      Left            =   120
      TabIndex        =   7
      Top             =   120
      Width           =   1215
   End
   Begin VB.Menu mFile 
      Caption         =   "Файл"
      Begin VB.Menu mOpen 
         Caption         =   "Открыть..."
      End
      Begin VB.Menu mSave 
         Caption         =   "Сохранить"
         Enabled         =   0   'False
      End
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
If List.ListCount < 0 Then Exit Sub
If (Val(GTo) < 1) Or (Val(GTo) > List.ListCount) Then Exit Sub
List.ListIndex = Val(GTo)
End Sub

Private Sub Command2_Click()
For n = 0 To List.ListCount - 1
    If BlockC(n).Flag = False Then
    For m = n + 1 To List.ListCount - 1
        'BlockC(n).Flag = True
        If BlockC(m).Flag = False Then
        If Text(n).Text = Text(m).Text Then
            BlockC(n).Block(BlockC(n).Count) = m
            BlockC(n).Count = BlockC(n).Count + 1
            BlockC(m).Flag = True
        End If
        End If
    Next m
    End If
Next n
Open "tempfft.txt" For Output As 1
Open "tempffttext.txt" For Output As 2
For n = 0 To List.ListCount - 1
    If BlockC(n).Count > 0 Then
        Print #2, "@@XXXXXXXX-XXXXXXXX - " & n
        Print #2, vbCrLf
        Print #2, Text(n).Text
        'txt = Str(n) & ":"
        txt = Text(n).adr1 & "-" & Text(n).adr2
        For m = 0 To BlockC(n).Count - 1
            'cnt = cnt + 1
            txt = txt & " " & Text(BlockC(n).Block(m)).adr1 & "-" & Text(BlockC(n).Block(m)).adr2
            'txt = txt & Str(BlockC(n).Block(m))
        Next m
        Print #1, txt
        txt = ""
    Else
        If BlockC(n).Flag = False Then
            Print #2, "@@XXXXXXXX-XXXXXXXX - " & n
            Print #2, vbCrLf
            Print #2, Text(n).Text
            txt = Text(n).adr1 & "-" & Text(n).adr2
            Print #1, txt
            txt = ""
        End If
    End If
Next n
Close 1
'MsgBox cnt
End Sub

Private Sub Command3_Click()
Open fileT For Binary As 1
Open fileA For Input As 2
Open FileTable For Input As 3
'Table Loading
For m = 0 To List.ListCount - 1
     For n = 1 To Len(Text(m).Text)
        ''''
        For l = 1 To UBound(Table)
        Next l
    Next n
Next m

End Sub

Private Sub List_Click()
LCount = List.ListIndex + 1 & "/" & List.ListCount
Text1 = Text(List.ListIndex).Text
adr1 = Text(List.ListIndex).adr1
adr2 = Text(List.ListIndex).adr2
End Sub

Private Sub mOpen_Click()

Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "FFT text (*.txt)" _
        + Chr$(0) + "*.txt" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие РОМа"
Dial.File = ShowOpen
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
Else
    file1 = Dial.File
End If

If file1 = "" Then Exit Sub

mOpen.Enabled = False
mSave.Enabled = True


Open file1 For Input As 1
'Подсчёт блоков
While Not EOF(1)
    Line Input #1, s
    If Left(s, 2) = "@@" Then cnt = cnt + 1
Wend
Close
Open file1 For Input As 1
ReDim Text(cnt - 1)
cnt = -1
While Not EOF(1)
    Line Input #1, s
    If Left(s, 2) = "@@" Then
        If cnt >= 0 Then List.AddItem (cnt + 1 & " - " & Left(Text(cnt).Text, 100))
        cnt = cnt + 1
        Text(cnt).adr1 = Mid(s, 3, 8)
        Text(cnt).adr2 = Mid(s, 12, 8)
        Text(cnt).com = Right(s, Len(s) - 19)
        Line Input #1, s
    Else
        If Text(cnt).Text = "" Then Text(cnt).Text = s Else Text(cnt).Text = Text(cnt).Text & vbCrLf & s
    End If
Wend
Close 1
End Sub

Private Sub mSave_Click()
Open file1 For Output As 1
For n = 0 To List.ListCount - 1
    Print #1, "@@" & Text(n).adr1 & "-" & Text(n).adr2 & " " & Text(n).com
    Print #1, vbCrLf
    Print #1, Text(n).Text
Next n
Close 1
End Sub

Private Sub Text1_Change()
Text(List.ListIndex).Text = Text1
List.List(List.ListIndex) = List.ListIndex + 1 & " - " & Left(Text1, 100)
End Sub
