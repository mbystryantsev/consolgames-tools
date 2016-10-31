VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   7770
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   9240
   LinkTopic       =   "Form1"
   ScaleHeight     =   7770
   ScaleWidth      =   9240
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command6 
      Caption         =   "Упаковать"
      Height          =   255
      Left            =   4080
      TabIndex        =   9
      Top             =   1200
      Width           =   3855
   End
   Begin VB.CommandButton Command5 
      Caption         =   "Command5"
      Height          =   6135
      Left            =   8040
      TabIndex        =   8
      Top             =   1560
      Width           =   1095
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   8040
      TabIndex        =   7
      Top             =   840
      Width           =   1095
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   8040
      TabIndex        =   6
      Top             =   480
      Width           =   1095
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   8040
      TabIndex        =   5
      Top             =   120
      Width           =   1095
   End
   Begin VB.TextBox Log 
      Height          =   6135
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Вертикаль
      TabIndex        =   4
      Text            =   "Form1.frx":0000
      Top             =   1560
      Width           =   7815
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Извлечь"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   1200
      Width           =   3855
   End
   Begin VB.TextBox File3 
      Height          =   285
      Left            =   120
      TabIndex        =   2
      Text            =   "Crimsonland\Rus\crimson.paq.log"
      Top             =   840
      Width           =   7815
   End
   Begin VB.TextBox Path 
      Height          =   285
      Left            =   120
      TabIndex        =   1
      Text            =   "Crimsonland\Rus\crimson\"
      Top             =   480
      Width           =   7815
   End
   Begin VB.TextBox File1 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "Crimsonland\crimson.paq"
      Top             =   120
      Width           =   7815
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()

If Not Right(Path, 1) = "\" Then Path = Path + "\"

Open File1 For Binary As 1
Open File3 For Output As 3
DoLog "Файл архива " & Chr(34) & File1 & Chr(34) & " открыт."
pos = 5
NewFile:
If pos >= LOF(1) Then GoTo Complete
FLen = 0
FName = ""
GetName:
Get #1, pos, bte: pos = pos + 1

If bte = 0 Then
    For n = 0 To 3
        Get #1, pos, bte: pos = pos + 1
        'MsgBox Hex(bte) & " * 256" & "^" & n & " = " & bte * 256 ^ n
        FLen = FLen + bte * 256 ^ n
    Next n
Else
    FName = FName + Chr(bte)
    GoTo GetName
End If

Print #3, FName

DoLog "Извлечение файла " & Chr(34) & FName & Chr(34) & " размеров " & FLen & " байт..."

FPath = ""
If InStr(1, FName, "\") > 0 Then
    FPath = Left(FName, InStr(1, FName, "\"))
    FName = Right(FName, Len(FName) - InStr(1, FName, "\"))
End If
'MsgBox FName
'MsgBox FPath

On Error GoTo NotDir
'MsgBox Path & FPath, , "Папка"

If Dir(Path & FPath) = "" Then
    MkDir Path & FPath
End If

NotDir:
'MsgBox Path & FPath & "\" & FName

Open Path & FPath & FName For Binary As 2
    For n = 1 To FLen
        Get #1, pos, bte: pos = pos + 1
        Put #2, n, bte
    Next n
    Close #2
GoTo NewFile
Complete:
Close
FName = ""
FPath = ""
pos = 0
FLen = 0
DoLog "Извлечение завершено."
End Sub

Private Sub Command6_Click()

If Not Right(Path, 1) = "\" Then Path = Path + "\"
Open File3 For Input As 3
DoLog "Открыт лог " & Chr(34) & File3 & Chr(34)
If Dir(File1) <> "" Then Kill File1
Open File1 For Binary As 1
DoLog "Открыт архив " & Chr(34) & File1 & Chr(34)
Put #1, 1, 112
Put #1, 2, 97
Put #1, 3, 113
Put #1, 4, 0
pos = 5

Line Input #3, lin
If Not lin = "" Then
    Open Path & lin For Binary As 1
    
End Sub
