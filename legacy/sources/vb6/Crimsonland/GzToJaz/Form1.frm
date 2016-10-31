VERSION 5.00
Object = "{F79ED619-0A0D-11D2-9F03-F39552419543}#6.0#0"; "zlib15.ocx"
Begin VB.Form Form1 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Gz->Jaz"
   ClientHeight    =   3600
   ClientLeft      =   45
   ClientTop       =   315
   ClientWidth     =   7605
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3600
   ScaleWidth      =   7605
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command5 
      Caption         =   "Command5"
      Height          =   375
      Left            =   6840
      TabIndex        =   10
      Top             =   2760
      Width           =   615
   End
   Begin MaqZlib20.Zlib Zlib1 
      Left            =   6600
      Top             =   1320
      _ExtentX        =   1032
      _ExtentY        =   1032
   End
   Begin VB.TextBox LogText 
      Height          =   2055
      Left            =   480
      MultiLine       =   -1  'True
      TabIndex        =   8
      Top             =   1320
      Width           =   6015
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Выход"
      Height          =   375
      Left            =   6600
      TabIndex        =   5
      Top             =   840
      Width           =   855
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   6600
      TabIndex        =   4
      Top             =   480
      Width           =   855
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   6600
      TabIndex        =   3
      Top             =   120
      Width           =   855
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Преобразовать"
      Height          =   375
      Left            =   480
      TabIndex        =   2
      Top             =   840
      Width           =   6015
   End
   Begin VB.TextBox file2 
      Height          =   285
      Left            =   480
      TabIndex        =   1
      Top             =   480
      Width           =   6015
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   480
      TabIndex        =   0
      Top             =   120
      Width           =   6015
   End
   Begin VB.Label Label3 
      Caption         =   $"Form1.frx":0000
      Height          =   1095
      Left            =   240
      TabIndex        =   9
      Top             =   1800
      Width           =   255
   End
   Begin VB.Label Label1 
      Alignment       =   1  'Правая привязка
      Caption         =   "Gz:"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Label2 
      Caption         =   "Jaz:"
      Height          =   255
      Left            =   120
      TabIndex        =   7
      Top             =   480
      Width           =   375
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
If file1 = CurDir & "~tmpungz.tmp" Or file1 = "~tmpungz.tmp" Then
    MsgBox "Имя файла " & Chr(34) & "~tmpungz.tmp" & Chr(34) & " зарезервировано! Задайте другое имя файла."
    Exit Sub
End If
If file2 = CurDir & "~tmpungz.tmp" Or file2 = "~tmpungz.tmp" Then
    MsgBox "Имя файла " & Chr(34) & "~tmpungz.tmp" & Chr(34) & " зарезервировано! Задайте другое имя файла."
    Exit Sub
End If
Open file1 For Binary As 1
Open file2 For Binary As 2
' Распаковка
Dim Myreturn As Boolean
Myreturn = Zlib1.ZlibUnCompressFile(file1, "~tmpungz.tmp")
DoLog "Файл извлечён." & vbCrLf
'--
'SFV
Dim pos As Long
pos = 1
sum = 1
Open "~tmpungz.tmp" For Binary As 3
While Not EOF(3)
Get #3, pos, bte: pos = pos + 1
sum = sum + bte
Wend
File3Len = LOF(3)
DoLog "SFV = " & sum & " = " & Hex(sum) & vbCrLf
Close 3
'--
Dim dbl As Boolean
Dim BCount As Integer
Dim byt(1 To 4) As Byte
Dim nl As String
BCount = 4
Put #2, 1, 1
For n = Len(Hex(File3Len)) To 1 Step -1
    If dbl = True Then
        nl = Mid(Hex(File3Len), n, 1) & nl
        byt(BCount) = Val("&H" & nl)
        BCount = BCount - 1
        nl = ""
        dbl = False
    Else
        nl = Mid(Hex(File3Len), n, 1)
        dbl = True
    End If
Next n
If dbl = True Then byt(BCount) = Val("&H" & nl)
For n = 9 To 6 Step -1
    Put #2, n, byt(10 - n)
Next n
DoLog "Прописаны байты " & byt(1) & " " & byt(2) & " " & byt(3) & " " & byt(4) & _
"(" & Right("0" + Hex(byt(1)), 2) & " " & Right("0" + Hex(byt(2)), 2) & " " & _
Right("0" + Hex(byt(3)), 2) & " " & Right("0" + Hex(byt(4)), 2) & "(" & Right("0" + _
Hex(byt(4)), 2) & Right("0" + Hex(byt(3)), 2) & Right("0" + Hex(byt(2)), 2) & Right _
("0" + Hex(byt(1)), 2) & "))" & vbCrLf
Put #2, 10, 120
Put #2, 11, 218
For n = 12 To LOF(1) - 7
    Get #1, n - 1, bte
    Put #2, n, bte
Next n
'--
nl = Right("0000" & Hex(sum), 4)
bte = Val("&H" & Left(nl, 2))
Put #2, LOF(2) + 3, bte
bte = Val("&H" & Right(nl, 2))
Put #2, LOF(2) + 1, bte
'--
dbl = False
nl = ""
For n = 1 To 4
    byt(n) = 0
Next n
BCount = 4

For n = Len(Hex(LOF(2) - 9)) To 1 Step -1
    If dbl = True Then
        nl = Mid(Hex(LOF(2) - 9), n, 1) & nl
        byt(BCount) = Val("&H" & nl)
        BCount = BCount - 1
        nl = ""
        dbl = False
    Else
        nl = Mid(Hex(LOF(2) - 9), n, 1)
        dbl = True
    End If
Next n
If dbl = True Then byt(BCount) = Val("&H" & nl)
For n = 5 To 2 Step -1
    Put #2, n, byt(6 - n)
Next n
DoLog "Записана длина " & LOF(2) - 9 & " как " & Hex(LOF(2) - 9) & vbCrLf
Close
End Sub

Private Sub Command2_Click()


Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "GZip архивы (*.gz)" _
        + Chr$(0) + "*.gz" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Выбирите GZip архив"
Dial.File = ShowOpen
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
Else
    file1 = Dial.File
End If
End Sub

Private Sub Command3_Click()



Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "Jaz архивы (*.jaz)" _
        + Chr$(0) + "*.jaz" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Выбирите Jaz архив"
Dial.File = ShowSave
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
Else
    file2 = Dial.File
End If
End Sub

Private Sub Command4_Click()
End
End Sub

Private Sub Command5_Click()
Call cr
End Sub
