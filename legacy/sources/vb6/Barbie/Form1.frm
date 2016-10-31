VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Barbie - Game Girl archiver"
   ClientHeight    =   1710
   ClientLeft      =   45
   ClientTop       =   315
   ClientWidth     =   9225
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1710
   ScaleWidth      =   9225
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command4 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   8040
      TabIndex        =   10
      Top             =   480
      Width           =   1095
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   8040
      TabIndex        =   9
      Top             =   120
      Width           =   1095
   End
   Begin VB.CommandButton Command2 
      Caption         =   "<< Запаковать"
      Height          =   375
      Left            =   4200
      TabIndex        =   5
      Top             =   1200
      Width           =   3735
   End
   Begin VB.TextBox adr2 
      Height          =   285
      Left            =   3120
      TabIndex        =   4
      Text            =   "142cf"
      Top             =   2760
      Visible         =   0   'False
      Width           =   1575
   End
   Begin VB.TextBox adr1 
      Height          =   285
      Left            =   720
      TabIndex        =   3
      Text            =   "14150"
      Top             =   840
      Width           =   1695
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Распаковать >>"
      Height          =   375
      Left            =   120
      TabIndex        =   2
      Top             =   1200
      Width           =   3735
   End
   Begin VB.TextBox File2 
      Height          =   285
      Left            =   720
      TabIndex        =   1
      Text            =   "Barbie_-_Game_Girl_(U).gb.chr"
      Top             =   480
      Width           =   7215
   End
   Begin VB.TextBox File1 
      Height          =   285
      Left            =   720
      TabIndex        =   0
      Text            =   "Barbie_-_Game_Girl_(U).gb"
      Top             =   120
      Width           =   7215
   End
   Begin VB.Label Label3 
      Alignment       =   1  'Правая привязка
      Caption         =   "Адрес:"
      Height          =   255
      Left            =   0
      TabIndex        =   8
      Top             =   840
      Width           =   615
   End
   Begin VB.Label Label2 
      Alignment       =   1  'Правая привязка
      Caption         =   "Файл:"
      Height          =   255
      Left            =   120
      TabIndex        =   7
      Top             =   480
      Width           =   495
   End
   Begin VB.Label Label1 
      Alignment       =   1  'Правая привязка
      Caption         =   "РОМ:"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   120
      Width           =   495
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
If Len(Dir(File2)) > 0 And Dir(File2) = Right(File2, Len(Dir(File2))) Then Kill (File2)
Open File1 For Binary As 1
Open File2 For Binary As 2
Dim bte As Byte
wpos = 1
pos = Ist("&H" & adr1) + 1
pos2 = Ist("&H" & adr2) + 1
For n = pos To LOF(1)
    Get #1, n, bte
    If bte <> 254 Then 'And bte > 0 Then
        Put #2, wpos, bte: wpos = wpos + 1
    ElseIf bte = 254 Then
        n = n + 1
        Get #1, n, bte
        If bte = 0 Then GoTo ed:
        If bte < 64 Then
        n = n + 1
            For l = 0 To bte
                Get #1, n, bte
                Put #2, wpos, bte: wpos = wpos + 1
            Next l
        Else
            For l = 0 To bte - 64
                Put #2, wpos, 255: wpos = wpos + 1
            Next l
        End If
        'n = n + 1
    Else
        GoTo ed:
    End If
Next n
ed:
Close
End Sub

Private Sub Command2_Click()

Open File2 For Binary As 1
Open File1 For Binary As 2
Dim bte As Byte
Dim bte2 As Byte
Dim Sum As Byte
pos = Ist("&H" & adr1) + 1
For n = 1 To LOF(1) + 1
    Get #1, n, bte
    If bte = bte2 Then
        Sum = Sum + 1
    ElseIf Sum > 2 Then
        If bte2 = 255 Then Sum = Sum + 63
        Put #2, pos, 254: pos = pos + 1
        Put #2, pos, Sum: pos = pos + 1
        Put #2, pos, bte2: pos = pos + 1
        Sum = 0
    Else
        If flag = False Then
            flag = True: GoTo ed2:
        End If
        For l = 0 To Sum
            Put #2, pos, bte2: pos = pos + 1
        Next l
        Sum = 0
    End If
ed2:
    bte2 = bte
Next n
If Sum > 2 Then
    If bte2 = 255 Then Sum = Sum + 64
    Put #2, pos, 254: pos = pos + 1
    Put #2, pos, Sum: pos = pos + 1
    Put #2, pos, bte2: pos = pos + 1
    Sum = 0
ElseIf Sum > 0 Then
    For l = 0 To Sum
        Put #2, pos, bte2: pos = pos + 1
    Next l
End If
Put #2, pos, 254: pos = pos + 1
Put #2, pos, 0
Close
End Sub

Private Sub Command3_Click()
Dial.Backup = Dial.file

Dial.Form = Me.hWnd
Dial.Filter = "Все файлы (*.*)" + Chr$(0) + "*.*"
Dial.Title = "Открытие РОМа"
Dial.file = ShowOpen
If Not InStr(1, Dial.file, "\") = 0 Then
    Dial.Dir = Right(Dial.file, Len(Dial.file) - InStrRev(Dial.file, "\"))
End If
If Dial.file = "" Then
    Dial.file = Dial.Backup
Else
    File1 = Dial.file
End If
End Sub

Private Sub Command4_Click()

Dial.Backup = Dial.file

Dial.Form = Me.hWnd
Dial.Filter = "Все файлы (*.*)" + Chr$(0) + "*.*"
Dial.Title = "Открытие файла графики"
Dial.file = ShowOpen
If Not InStr(1, Dial.file, "\") = 0 Then
    Dial.Dir = Right(Dial.file, Len(Dial.file) - InStrRev(Dial.file, "\"))
End If
If Dial.file = "" Then
    Dial.file = Dial.Backup
Else
    File2 = Dial.file
End If
End Sub
