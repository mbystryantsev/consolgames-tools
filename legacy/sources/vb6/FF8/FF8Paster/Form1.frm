VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   4875
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   8970
   LinkTopic       =   "Form1"
   ScaleHeight     =   4875
   ScaleWidth      =   8970
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command2 
      Caption         =   "Выход"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   4560
      Width           =   8775
   End
   Begin VB.TextBox Log 
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   8.25
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3255
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Вертикаль
      TabIndex        =   3
      Top             =   1200
      Width           =   8775
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Вставить"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   840
      Width           =   8775
   End
   Begin VB.TextBox file2 
      Height          =   285
      Left            =   120
      TabIndex        =   1
      Text            =   "FF8\list.lst"
      Top             =   480
      Width           =   8775
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "FF8DISC1.IMG"
      Top             =   120
      Width           =   8775
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
Dim sz As String
Dim position As String
Open file1 For Binary As 1
Open file2 For Input As 2
While Not EOF(2)
    chpos = 1
    Line Input #2, lin
    While Not Mid(lin, chpos, 1) = " "
     file = file + Mid(lin, chpos, 1)
     chpos = chpos + 1
    Wend
    chpos = chpos + 1
    While Not Mid(lin, chpos, 1) = " "
     position = position + Mid(lin, chpos, 1)
     chpos = chpos + 1
    Wend
    sz = Mid(lin, chpos, Len(lin) - chpos + 1)
    ' Вставка
    Size = Ist(sz)
    pos = Ist(position) + 1
    readpos = 1
    Open file For Binary As 3
    While Not EOF(3)
        Get #3, readpos, bte: readpos = readpos + 1
        Put #1, pos, bte: pos = pos + 1
    Wend
    Close 3
    DoLog "Файл " & Chr(34) & file & Chr(34) & " вставлен по адресу " & Hex(Ist(position)) & vbCrLf
    file = ""
    position = ""
    sz = ""
Wend
Close
End Sub

Private Sub Command2_Click()
End
End Sub
