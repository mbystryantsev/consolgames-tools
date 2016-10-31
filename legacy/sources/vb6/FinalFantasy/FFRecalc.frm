VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
Begin VB.Form Form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "FF Pointer Recalculator"
   ClientHeight    =   3675
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   6750
   Icon            =   "FFRecalc.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3675
   ScaleWidth      =   6750
   StartUpPosition =   3  'Windows Default
   Begin MSComctlLib.ProgressBar PB1 
      Height          =   375
      Left            =   240
      TabIndex        =   8
      Top             =   3000
      Width           =   6255
      _ExtentX        =   11033
      _ExtentY        =   661
      _Version        =   393216
      Appearance      =   1
      Min             =   1e-4
      Scrolling       =   1
   End
   Begin VB.CommandButton Command4 
      Caption         =   "ВЫХОД"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Left            =   3480
      TabIndex        =   7
      Top             =   2040
      Width           =   3135
   End
   Begin VB.CommandButton Command3 
      Caption         =   "ПУСК!"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Left            =   120
      TabIndex        =   6
      Top             =   2040
      Width           =   3135
   End
   Begin VB.TextBox file2 
      Height          =   285
      Left            =   240
      TabIndex        =   1
      Text            =   "ff\Копия Final fantasy.nes"
      Top             =   1320
      Width           =   4935
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   240
      TabIndex        =   0
      Text            =   "ff\Final fantasy.nes"
      Top             =   360
      Width           =   4935
   End
   Begin VB.Frame Frame1 
      Caption         =   "Оригинальный файл"
      Height          =   735
      Left            =   120
      TabIndex        =   2
      Top             =   120
      Width           =   6375
      Begin MSComDlg.CommonDialog CommonDialog1 
         Left            =   5400
         Top             =   480
         _ExtentX        =   847
         _ExtentY        =   847
         _Version        =   393216
         DialogTitle     =   "Открытие РОМа"
         Filter          =   "Все файлы (*.*)"
      End
      Begin VB.CommandButton Command1 
         Caption         =   "Обзор..."
         Height          =   255
         Left            =   5280
         TabIndex        =   4
         Top             =   240
         Width           =   855
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "Измененный файл"
      Height          =   735
      Left            =   120
      TabIndex        =   3
      Top             =   1080
      Width           =   6375
      Begin VB.CommandButton Command2 
         Caption         =   "Обзор..."
         Height          =   255
         Left            =   5280
         TabIndex        =   5
         Top             =   240
         Width           =   855
      End
   End
   Begin VB.Frame Frame6 
      Caption         =   "Прогресс:"
      Height          =   735
      Left            =   120
      TabIndex        =   9
      Top             =   2760
      Width           =   6495
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub All_Click()
T1.Enabled = False
T2.Enabled = False
T3.Enabled = False
End Sub

Private Sub Command1_Click()
'MsgBox "По тупости программиста данная операция не может быть осуществлена.", , "Обнаружен баг в башке программиста!"
On Error GoTo OpenErr   'just quit if they hit cancel
    CommonDialog1.DialogTitle = "Открытие оригинального РОМа"
    CommonDialog1.ShowOpen
    file1 = CommonDialog1.FileName
OpenErr:
End Sub

Private Sub Command2_Click()
'MsgBox "По тупости программиста данная операция не может быть осуществлена.", , "Обнаружен баг в башке программиста!"
On Error GoTo OpenErr   'just quit if they hit cancel
    CommonDialog1.DialogTitle = "Открыти измененного РОМа"
    CommonDialog1.ShowOpen
    file2 = CommonDialog1.FileName
OpenErr:
End Sub

Private Sub Command3_Click()
'247
If file1 = "" Or file1 <> "" And Dir(file1) = "" Then
    If file2 = "" Or file2 <> "" And Dir(file2) = "" Then
        MsgBox "Пути к обоим файлам введены неверно!"
    Else
        MsgBox "Путь к оригинальному файлу введен неверно!"
    End If
ElseIf file2 = "" Or file2 <> "" And Dir(file2) = "" Then
    If file1 = "" Or file1 <> "" And Dir(file1) = "" Then
        MsgBox "Пути к обоим файлам введены неверно!"
    Else
        MsgBox "Путь к измененному файлу введен неверно!"
    End If
ElseIf Dir(file1) <> "" And Dir(file2) <> "" Then

End If

Dim bte As Byte
Dim tp As String



Open file1 For Binary As 1
Open file2 For Binary As 2

beginp = Val("&H28010") + 1
endp = Val("&H2820F") + 1
begint = Val("&H28210") + 1
endt = Val("&H2B466") + 1
PB1.Min = 1 '163855
PB1.Max = 250 '164352

For pos = beginp To endp Step 2
PB1 = PB1 + 1
Get #1, pos, bte: p1 = bte ': MsgBox Hex(pos - 1) & "  " & Hex(bte) & "  " & bte
Get #1, pos + 1, bte: p2 = bte ': MsgBox Hex(pos) & "  " & Hex(bte) & "  " & bte
'-------------------------------'
tp1 = Right("00" + Hex(p1), 2)
tp2 = Right("00" + Hex(p2), 2)
'MsgBox "1. " & tp2 & tp1
tp = Right("0000" + Hex(Val("&H" + tp2) * 256 + Val("&H" + tp1) + 17), 4)
padres = Val("&H2" + tp)
'MsgBox "2. " & Hex(padres - 1)
'-------------------------------'
For cnt = begint To padres
    Get #1, cnt, bte
    If bte = 0 Then counter1 = counter1 + 1
Next cnt
'MsgBox "Kol-vo   " & counter1
cnt = begint
cntbeg:
If counter1 = 0 Then GoTo nxt
If counter1 = counter2 Then
    'MsgBox counter1 & " = " & counter2 & "  " & Hex(cnt - 1)
    GoTo cntend
End If
    
    Get #2, cnt, bte: cnt = cnt + 1
    If bte = 0 Then counter2 = counter2 + 1
    GoTo cntbeg
cntend:
'If pos >= endp Then MsgBox counter1
counter1 = 0
counter2 = 0

'-------------------------------'
a = Right(Hex(cnt), 4)
a1 = Left(a, 2)
a2 = Right("00" + Hex(Val("&H" + Right(a, 2)) - 17), 2)
'-------------------------------'
bte = Val("&H" + a2)
Put #2, pos, bte
If bte >= 239 Then
    bte = Val("&H" + a1) - 1
Else
    bte = Val("&H" + a1)
End If
Put #2, pos + 1, bte
'-------------------------------'
nxt:
Next pos
PB1 = 1.0001
Close


End Sub

Private Sub Command4_Click()
End
End Sub

Private Sub Command5_Click()
End Sub

Private Sub One_Click()
T1.Enabled = True
T2.Enabled = True
T3.Enabled = True
End Sub
