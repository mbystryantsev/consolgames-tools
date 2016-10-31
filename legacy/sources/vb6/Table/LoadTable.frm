VERSION 5.00
Begin VB.Form LoadTable 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Загрузка таблицы"
   ClientHeight    =   3090
   ClientLeft      =   45
   ClientTop       =   315
   ClientWidth     =   5970
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3090
   ScaleWidth      =   5970
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command2 
      Caption         =   "Показать"
      Height          =   375
      Left            =   1680
      TabIndex        =   3
      Top             =   720
      Width           =   1095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Загрузить"
      Height          =   375
      Left            =   480
      TabIndex        =   2
      Top             =   720
      Width           =   1095
   End
   Begin VB.CommandButton Obzor 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   5040
      TabIndex        =   1
      Top             =   120
      Width           =   855
   End
   Begin VB.TextBox LTable 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "ff\Final_Fantasy_RUS.tbl"
      Top             =   120
      Width           =   4815
   End
End
Attribute VB_Name = "LoadTable"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
For n = 0 To 256
    For n2 = 0 To 255
        Table(n, n2) = ""
    Next n2
Next n

Open LTable For Input As 1
'Dim Table(256, 256) As String
While Not EOF(1)
    Line Input #1, lin
    'MsgBox lin
    If InStr(lin, "=") = 3 Then
        HexVal = Val("&H" + Left(lin, 2))
        If HexVal >= 0 And HexVal <= 255 Then
            Table(256, HexVal) = Right(lin, Len(lin) - 3)
        End If
    ElseIf InStr(lin, "=") = 5 Then
        HexIndx = Val("&H" + Left(lin, 2))
        HexVal = Val("&H" + Mid(lin, 3, 2))
        If HexVal >= 0 And HexVal <= 255 And HexIndx >= 0 And HexIndx <= 255 Then
            Table(HexIndx, HexVal) = Right(lin, Len(lin) - 5)
        End If
    End If
Wend
Close 1
zapret = 1
Call TableWr
zapret = 0
Me.Hide
End Sub



Private Sub Command2_Click()
On Error GoTo ending
For n = 0 To 256
    For n2 = 0 To 255
        NEWtable(n, n2) = ""
    Next n2
Next n

Open LTable For Input As 1
'Dim NEWtable(256, 256) As String
While Not EOF(1)
    Line Input #1, lin
    If InStr(lin, "=") = 3 Then
        HexVal = Val("&H" + Left(lin, 2))
        If HexVal >= 0 And HexVal <= 255 Then
            NEWtable(256, HexVal) = Right(lin, Len(lin) - 3)
        End If
    ElseIf InStr(lin, "=") = 5 Then
        HexIndx = Val("&H" + Left(lin, 2))
        HexVal = Val("&H" + Mid(lin, 3, 2))
        If HexVal >= 0 And HexVal <= 255 And HexIndx >= 0 And HexIndx <= 255 Then
            NEWtable(HexIndx, HexVal) = Right(lin, Len(lin) - 5)
        End If
    End If
Wend
'----------------------------
tb = ""
For n = 0 To 255
    If Not NEWtable(256, n) = "" Then
        tb = tb + Right("00" + Hex(n), 2) & "=" & NEWtable(256, n) & vbCrLf
    End If
Next n

For s = 0 To 255
For n = 0 To 255
    If Not NEWtable(s, n) = "" Then
        tb = tb + Right("00" + Hex(s), 2) + Right("00" + Hex(n), 2) & "=" & NEWtable(s, n) & vbCrLf
    End If
Next n
Next s
ShowTable.ShowTableText = tb
ShowTable.Show
    
For n = 0 To 256
    For n2 = 0 To 255
        NEWtable(n, n2) = ""
    Next n2
Next n
Close 1
Exit Sub

ending:
MsgBox "Ошибка при открытии файла!", , "Ошибка!"
End Sub





Private Sub Obzor_Click()
LTableBackup = LTable

Dial.Form = Me.hWnd
Dial.Filter = "Файлы таблиц (*.tbl)" + Chr$(0) _
        + "*.tbl" + Chr$(0) + "Текстовые файлы (*.txt)" _
        + Chr$(0) + "*.txt" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие таблицы"
LTable = ShowOpen
If Not InStr(1, LTable, "\") = 0 Then
    Dial.Dir = Right(LTable, Len(LTable) - InStrRev(LTable, "\"))
End If
If LTable = "" Then LTable = LTableBackup
End Sub
