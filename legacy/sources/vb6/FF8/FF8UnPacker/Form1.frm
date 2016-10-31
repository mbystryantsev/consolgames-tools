VERSION 5.00
Object = "{63E5F280-E28C-11D4-BF3F-A7DE75CE211C}#1.0#0"; "AdvProgressBar.ocx"
Begin VB.Form Form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Final Fantasy VIII Text UnPacker  -  By HoRRoR"
   ClientHeight    =   4845
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   11115
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4845
   ScaleWidth      =   11115
   StartUpPosition =   3  'Windows Default
   Begin VB.CheckBox PChBlock 
      Caption         =   "Блок"
      Height          =   255
      Left            =   3840
      TabIndex        =   24
      Top             =   1080
      Width           =   735
   End
   Begin VB.CheckBox PChText 
      Caption         =   "Текст"
      Height          =   255
      Left            =   3000
      TabIndex        =   23
      Top             =   1080
      Width           =   855
   End
   Begin VB.TextBox PBufInd 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   4560
      MaxLength       =   1
      TabIndex        =   19
      Text            =   "4"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox PBuf 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   4800
      MaxLength       =   2
      TabIndex        =   18
      Text            =   "45"
      Top             =   1080
      Width           =   495
   End
   Begin AdvanceProgressBar.AdvProgressBar APB 
      Height          =   255
      Left            =   120
      Top             =   4560
      Width           =   10815
      _ExtentX        =   19076
      _ExtentY        =   450
      Appearance      =   1
      BackColor       =   -2147483633
      BorderStyle     =   1
      Caption         =   "50%"
      Enabled         =   -1  'True
      FloodColor      =   192
      ForeColor       =   -2147483634
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      HelpContextID   =   0
      Max             =   100
      Min             =   0
      OLEDropMode     =   0
      Orientation     =   0
      Style           =   0
      Object.WhatsThisHelpID =   0
   End
   Begin VB.TextBox PEndPos 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   1560
      TabIndex        =   16
      Text            =   "&Hf62"
      Top             =   1080
      Width           =   1335
   End
   Begin VB.TextBox PZamByte 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   8520
      MaxLength       =   2
      TabIndex        =   15
      Text            =   "00"
      Top             =   1080
      Width           =   615
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Распаковать!"
      Height          =   495
      Left            =   9720
      TabIndex        =   14
      Top             =   840
      Width           =   1215
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   10080
      TabIndex        =   13
      Top             =   480
      Width           =   855
   End
   Begin VB.TextBox file2 
      Height          =   285
      Left            =   120
      TabIndex        =   12
      Text            =   "FF8\noname2.UnPack.fhx"
      Top             =   480
      Width           =   9855
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
      Height          =   2775
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Вертикаль
      TabIndex        =   10
      Top             =   1680
      Width           =   10815
   End
   Begin VB.TextBox PBits 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   6000
      MaxLength       =   8
      TabIndex        =   8
      Text            =   "11111111"
      Top             =   1080
      Width           =   855
   End
   Begin VB.TextBox PBPos 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   7200
      MaxLength       =   1
      TabIndex        =   6
      Text            =   "8"
      Top             =   1080
      Width           =   495
   End
   Begin VB.TextBox PByte 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   5400
      MaxLength       =   2
      TabIndex        =   4
      Text            =   "FF"
      Top             =   1080
      Width           =   495
   End
   Begin VB.TextBox PPos 
      Alignment       =   2  'Центровка
      Height          =   285
      Left            =   120
      TabIndex        =   2
      Text            =   "&H62"
      Top             =   1080
      Width           =   1335
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   10080
      TabIndex        =   1
      Top             =   120
      Width           =   855
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "FF8\noname2.fhx"
      Top             =   120
      Width           =   9855
   End
   Begin VB.Label Label9 
      Alignment       =   2  'Центровка
      Caption         =   "Не сначала:"
      Height          =   255
      Left            =   3000
      TabIndex        =   22
      Top             =   840
      Width           =   1575
   End
   Begin VB.Label Label8 
      Alignment       =   2  'Центровка
      Caption         =   "Заменяющий байт:"
      Height          =   255
      Left            =   8040
      TabIndex        =   21
      Top             =   840
      Width           =   1575
   End
   Begin VB.Label Label7 
      Alignment       =   2  'Центровка
      Caption         =   "Буфер:"
      Height          =   255
      Left            =   4560
      TabIndex        =   20
      Top             =   840
      Width           =   735
   End
   Begin VB.Label Label6 
      Alignment       =   2  'Центровка
      Caption         =   "Конечная:"
      Height          =   255
      Left            =   1560
      TabIndex        =   17
      Top             =   840
      Width           =   1335
   End
   Begin VB.Label Label5 
      Alignment       =   2  'Центровка
      Caption         =   "-==ЛОГ==-"
      Height          =   255
      Left            =   120
      TabIndex        =   11
      Top             =   1440
      Width           =   10815
   End
   Begin VB.Label Label4 
      Alignment       =   2  'Центровка
      Caption         =   "Биты:"
      Height          =   255
      Left            =   6000
      TabIndex        =   9
      Top             =   840
      Width           =   855
   End
   Begin VB.Label Label3 
      Alignment       =   2  'Центровка
      Caption         =   "Текущий бит:"
      Height          =   255
      Left            =   6840
      TabIndex        =   7
      Top             =   840
      Width           =   1215
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Центровка
      Caption         =   "Байт:"
      Height          =   255
      Left            =   5400
      TabIndex        =   5
      Top             =   840
      Width           =   495
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Центровка
      Caption         =   "Позиция:"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   840
      Width           =   1335
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Command1_Click()

Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие файла"
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

Private Sub Command2_Click()

Dial.Backup = Dial.File

Dial.Form = Me.hWnd
Dial.Filter = "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Открытие файла"
Dial.File = ShowOpen
If Not InStr(1, Dial.File, "\") = 0 Then
    Dial.Dir = Right(Dial.File, Len(Dial.File) - InStrRev(Dial.File, "\"))
End If
If Dial.File = "" Then
    Dial.File = Dial.Backup
Else
    file2 = Dial.File
End If
End Sub

Private Sub Command3_Click()
'On Error GoTo exsb
'-
WPos = 1
Buffer = Val("&H" & PBuf) + (Val("&H" & PBufInd) * 256)
'-
Open file1 For Binary As 1
DoLog "Открыт файл " & Chr(34) & file1 & Chr(34)
Open file2 For Binary As 2
DoLog "Открыт файл " & Chr(34) & file2 & Chr(34)
pos = Val(PPos) + 1
DoLog "Установлена позиция: " & Hex(Val(PPos)) & " [+1]"
'__--==Распаковка==--__'
DoLog "Собственно, распаковка 8)"
APB.Min = Val(PPos)
APB.Max = Val(PEndPos)
'Buffer = Buffer + 2
If PChText.Value = 1 Then
    UByte = Val("&H" & PByte)
    n = PBPos
    GoTo TextBeg
End If
While pos < Val(PEndPos)
APB.Value = pos
APB.Caption = pos & "/" & Val(PEndPos)
Get #1, pos, UByte: pos = pos + 1
tmpbte = UByte
UBits = AllBits(tmpbte)
'MsgBox " Получен управляющий байт " & Hex(UByte) & " (" & UBits & ")"
For n = 8 To 1 Step -1
TextBeg:
    If Mid(UBits, n, 1) = "1" Then
        Get #1, pos, bte: pos = pos + 1
        Put #2, WPos, bte: WPos = WPos + 1
        'Buffer = Buffer + 1
        'MsgBox "     Бит равен 1, добавляем байт " & Hex(bte) & "(" & Hex(WPos - 2) & ") по адресу " & Hex(pos - 2)
        'DoLog "     Бит равен 1, добавляем байт " & Hex(bte) & "(" & Hex(WPos - 2) & ") по адресу " & Hex(pos - 2)
Else
        Get #1, pos, PosByte1: pos = pos + 1
        Get #1, pos, PosByte2: pos = pos + 1
        BPos = PosByte1 + GetLByte(PosByte2) * 256
        If BPos >= 4096 Then BPos = BPos - 4096
        Retry = GetRByte(PosByte2) + 3
        'If (BPos - Buffer + Retry - 1) < 0 Or (BPos - Buffer) < 0 Then
        '    For c = 1 To Retry
        '        Put #2, WPos, 0: WPos = WPos + 1
        '    Next c
        'Else
            For c = BPos - Buffer To BPos - Buffer + Retry - 1
                If c > 0 Then
                    Get #2, c, bte
                    Put #2, WPos, bte: WPos = WPos + 1
                Else
                    Put #2, WPos, 0: WPos = WPos + 1
                End If
            Next c
        'End If
        'DoLog "     Бит равен 0, читаем байты " & Hex(PosByte1) & " и " & Hex(PosByte2)
        'DoLog "         Позиция = " & PosByte1 & " + (" & GetLByte(PosByte2) & ") * 256 = " & PosByte1 + (GetLByte(PosByte2) * 256)
        'MsgBox "     Бит равен 0, читаем байты " & Hex(PosByte1) & " и " & Hex(PosByte2)
        'MsgBox "         Позиция = " & PosByte1 & " + (" & GetLByte(PosByte2) & ") * 256 = " & PosByte1 + (GetLByte(PosByte2) * 256)
    End If
Next n
Wend
exsb:
Close
End Sub




Private Sub PBits_Change()
If Zapret.PBits = True Then Exit Sub
For n = Len(PBits) To 1 Step -1
    If Mid(PBits, n, 1) <> "1" Then
        If Mid(PBits, n, 1) <> "0" Then Exit Sub
    End If
Next n
Zapret.PByte = True
PByte = Hex(GetByte(PBits))
Zapret.PByte = False
End Sub

Private Sub PBits_LostFocus()
GoTo St:
Ispr:
Call PByte_Change
Exit Sub
St:
For n = Len(PBits) To 1 Step -1
    If Mid(PBits, n, 1) <> "1" Then
        If Mid(PBits, n, 1) <> "0" Then GoTo Ispr
    End If
Next n
End Sub

Private Sub PByte_Change()
If Zapret.PByte = True Then Exit Sub
Zapret.PBits = True
PBits = AllBits(Val("&H" & PByte))
Zapret.PBits = False
End Sub
