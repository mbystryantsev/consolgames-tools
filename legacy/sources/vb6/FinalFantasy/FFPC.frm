VERSION 5.00
Begin VB.Form CP 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "FFPCalculator :)"
   ClientHeight    =   1770
   ClientLeft      =   9495
   ClientTop       =   1095
   ClientWidth     =   2475
   Icon            =   "FFPC.frx":0000
   LinkTopic       =   "CoPointers"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   OLEDropMode     =   1  'Вручную
   ScaleHeight     =   1770
   ScaleWidth      =   2475
   Begin VB.CommandButton Command2 
      Caption         =   "Поинтер"
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   1320
      Width           =   975
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Смещение"
      Height          =   255
      Left            =   1320
      TabIndex        =   4
      Top             =   1320
      Width           =   975
   End
   Begin VB.TextBox Adres 
      Height          =   285
      Left            =   1320
      MaxLength       =   4
      TabIndex        =   1
      Top             =   600
      Width           =   735
   End
   Begin VB.TextBox Pointer 
      Height          =   285
      Left            =   1320
      MaxLength       =   4
      TabIndex        =   0
      Top             =   120
      Width           =   735
   End
   Begin VB.Frame Frame1 
      Caption         =   "Вычислить:"
      Height          =   615
      Left            =   0
      TabIndex        =   6
      Top             =   1080
      Width           =   2415
   End
   Begin VB.Label Label1 
      Caption         =   "Смещение:"
      Height          =   255
      Index           =   1
      Left            =   360
      TabIndex        =   3
      Top             =   600
      Width           =   855
   End
   Begin VB.Label Label1 
      Caption         =   "Поинтер:"
      Height          =   255
      Index           =   0
      Left            =   480
      TabIndex        =   2
      Top             =   120
      Width           =   855
   End
End
Attribute VB_Name = "CP"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
 Dim word(0 To 31) As String
    word(0) = "0"
    word(1) = "1"
    word(2) = "2"
    word(3) = "3"
    word(4) = "4"
    word(5) = "5"
    word(6) = "6"
    word(7) = "7"
    word(8) = "8"
    word(9) = "9"
    word(10) = "A"
    word(11) = "B"
    word(12) = "C"
    word(13) = "D"
    word(14) = "E"
    word(15) = "F"
    word(16) = "0"
    word(17) = "1"
    word(18) = "2"
    word(19) = "3"
    word(20) = "4"
    word(21) = "5"
    word(22) = "6"
    word(23) = "7"
    word(24) = "8"
    word(25) = "9"
    word(26) = "A"
    word(27) = "B"
    word(28) = "C"
    word(29) = "D"
    word(30) = "E"
    word(31) = "F"
If Len(Pointer) > 4 Or Len(Pointer) < 4 Then
    MsgBox "Вы должны ввести ДВА байта в формате ABXY!", , "Ошибка!"
Else
If Option1 = True Then
    st = 0
ElseIf Option2 = True Then
    st = 0
Else
    st = 0
End If
    adr = Hex$(Val("&H" + Pointer))
    adr = Right$("0000" + adr, 4)
    a1 = Mid$(adr, 1, 1)
    a2 = Mid$(adr, 2, 1)
    a3 = Mid$(adr, 3, 1)
    a4 = Mid$(adr, 4, 1) '0-e
    
    If a3 = "0" Then
        a3 = word(st)
    ElseIf a3 = "1" Then
      a3 = word(st + 1)
    ElseIf a3 = "2" Then
        a3 = word(st + 2)
    ElseIf a3 = "3" Then
        a3 = word(st + 3)
    ElseIf a3 = "4" Then
        a3 = word(st + 4)
    ElseIf a3 = "5" Then
        a3 = word(st + 5)
    ElseIf a3 = "6" Then
        a3 = word(st + 6)
    ElseIf a3 = "7" Then
        a3 = word(st + 7)
    ElseIf a3 = "8" Then
        a3 = word(st + 8)
    ElseIf a3 = "9" Then
        a3 = word(st + 9)
    ElseIf a3 = "A" Then
        a3 = word(st + 10)
    ElseIf a3 = "B" Then
        a3 = word(st + 11)
    ElseIf a3 = "C" Then
        a3 = word(st + 12)
    ElseIf a3 = "D" Then
        a3 = word(st + 13)
    ElseIf a3 = "E" Then
        a3 = word(st + 14)
    ElseIf a3 = "F" Then
        a3 = word(st + 15)
    End If
    Adres = Right$("0000" + Hex$(Val("&H" + a3 + a4 + a1 + a2) + Val(&H10)), 4)
    
    
 End If
 End Sub

Private Sub Text2_Change()

End Sub

Private Sub Command2_Click()
    Dim word(0 To 31) As String
    word(0) = "0"
    word(1) = "1"
    word(2) = "2"
    word(3) = "3"
    word(4) = "4"
    word(5) = "5"
    word(6) = "6"
    word(7) = "7"
    word(8) = "8"
    word(9) = "9"
    word(10) = "A"
    word(11) = "B"
    word(12) = "C"
    word(13) = "D"
    word(14) = "E"
    word(15) = "F"
    word(16) = "0"
    word(17) = "1"
    word(18) = "2"
    word(19) = "3"
    word(20) = "4"
    word(21) = "5"
    word(22) = "6"
    word(23) = "7"
    word(24) = "8"
    word(25) = "9"
    word(26) = "A"
    word(27) = "B"
    word(28) = "C"
    word(29) = "D"
    word(30) = "E"
    word(31) = "F"
If Len(Adres) > 4 Or Len(Adres) < 4 Then
    MsgBox "Вы должны ввести ДВА байта в формате ABXY!", , "Ошибка!"
Else
If Option1 = True Then
    st = 0
ElseIf Option2 = True Then
    st = 0
Else
    st = 0
End If
    adr = Hex$(Val("&H" + Adres) - Val("&H10"))
    adr = Right$("0000" + adr, 4)
    a1 = Mid$(adr, 1, 1)
    a2 = Mid$(adr, 2, 1)
    a3 = Mid$(adr, 3, 1)
    a4 = Mid$(adr, 4, 1)
    If a1 = "0" Then
        a1 = word(st) '2
    ElseIf a1 = "1" Then
      a1 = word(st + 1)
    ElseIf a1 = "2" Then
        a1 = word(st + 2)
    ElseIf a1 = "3" Then
        a1 = word(st + 3)
    ElseIf a1 = "4" Then
        a1 = word(st + 4)
    ElseIf a1 = "5" Then
        a1 = word(st + 5)
    ElseIf a1 = "6" Then
        a1 = word(st + 6)
    ElseIf a1 = "7" Then
        a1 = word(st + 7)
    ElseIf a1 = "8" Then
        a1 = word(st + 8)
    ElseIf a1 = "9" Then
        a1 = word(st + 9)
    ElseIf a1 = "A" Then
        a1 = word(st + 10)
    ElseIf a1 = "B" Then
        a1 = word(st + 11)
    ElseIf a1 = "C" Then
        a1 = word(st + 12)
    ElseIf a1 = "D" Then
        a1 = word(st + 13)
    ElseIf a1 = "E" Then
        a1 = word(st + 14)
    ElseIf a1 = "F" Then
        a1 = word(st + 15)
    End If
    Pointer = a3 + a4 + a1 + a2

    
End If
End Sub

Private Sub Command3_Click()
End
End Sub

Private Sub Command4_Click()
MsgBox "Эта программа создана для просчета поинтеров в смещения и обратно в игре на NES 'Little Ninja Brothers'.       Программа распространяется бесплатно, любое распространение в коммерческих целях возможно только с согласия автора.                                                                                                                                                                                     Автор программы не несет никакой ответственности за любой ущерб, принесенный при использовании данной программы.                                                                                                                                                                                                                                                           © HoRRoR, 2005г. Ho-RR-oR@mail.ru", vbOKOnly, "О программе"


End Sub
