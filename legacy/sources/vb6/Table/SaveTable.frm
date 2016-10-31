VERSION 5.00
Begin VB.Form SaveTable 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Сохранение таблицы"
   ClientHeight    =   2940
   ClientLeft      =   45
   ClientTop       =   315
   ClientWidth     =   5940
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2940
   ScaleMode       =   0  'Пользовательское
   ScaleWidth      =   5970
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.CheckBox clsme 
      Caption         =   "Закрыть окно после сохранения"
      Height          =   375
      Left            =   3720
      TabIndex        =   15
      Top             =   2400
      Value           =   1  'Отмечено
      Width           =   2055
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   5040
      TabIndex        =   14
      Top             =   120
      Width           =   855
   End
   Begin VB.CheckBox Check4 
      Caption         =   "Старшие байты по порядку"
      Height          =   255
      Left            =   600
      TabIndex        =   13
      Top             =   1680
      Width           =   2415
   End
   Begin VB.CheckBox Check3 
      Caption         =   "Только со старшим байтом:"
      Height          =   315
      Left            =   3360
      TabIndex        =   12
      Top             =   1080
      Width           =   2535
   End
   Begin VB.TextBox FirstIndex 
      Alignment       =   2  'Центровка
      BackColor       =   &H8000000B&
      Height          =   285
      Left            =   3960
      Locked          =   -1  'True
      MaxLength       =   2
      TabIndex        =   9
      Text            =   "--"
      Top             =   1440
      Width           =   735
   End
   Begin VB.CommandButton Command6 
      Caption         =   "Нет"
      Height          =   255
      Left            =   4800
      TabIndex        =   8
      Top             =   1680
      Width           =   975
   End
   Begin VB.CheckBox Check2 
      Caption         =   "С комментариями"
      Height          =   255
      Left            =   240
      TabIndex        =   7
      Top             =   1920
      Width           =   1815
   End
   Begin VB.CheckBox Check1 
      Caption         =   "В обратном порядке"
      Height          =   255
      Left            =   240
      TabIndex        =   6
      Top             =   1440
      Width           =   2055
   End
   Begin VB.TextBox STable 
      Height          =   285
      Left            =   120
      TabIndex        =   5
      Text            =   "teenfnt.tbl"
      Top             =   120
      Width           =   4815
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Просмотр (пока недоступно)"
      Enabled         =   0   'False
      Height          =   495
      Left            =   2040
      TabIndex        =   4
      Top             =   2280
      Width           =   1335
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Сохранить"
      Height          =   255
      Left            =   240
      TabIndex        =   3
      Top             =   2520
      Width           =   1335
   End
   Begin VB.OptionButton Option3 
      Caption         =   "По алфавиту (Пока не доступно)"
      Enabled         =   0   'False
      Height          =   195
      Left            =   240
      TabIndex        =   2
      Top             =   1080
      Width           =   2895
   End
   Begin VB.OptionButton Option2 
      Caption         =   "По длине (Пока не доступно)"
      Enabled         =   0   'False
      Height          =   195
      Left            =   240
      TabIndex        =   1
      Top             =   840
      Width           =   3255
   End
   Begin VB.OptionButton Option1 
      Caption         =   "По порядку"
      Height          =   195
      Left            =   240
      TabIndex        =   0
      Top             =   600
      Value           =   -1  'True
      Width           =   1335
   End
   Begin VB.CommandButton Command5 
      Caption         =   "Выбрать..."
      Height          =   255
      Left            =   4800
      TabIndex        =   16
      Top             =   1440
      Width           =   975
   End
   Begin VB.CommandButton Command2_ 
      Caption         =   ">"
      Height          =   255
      Left            =   4320
      TabIndex        =   10
      Top             =   1680
      Width           =   375
   End
   Begin VB.CommandButton Command3 
      Caption         =   "<"
      Height          =   255
      Left            =   3960
      TabIndex        =   11
      Top             =   1680
      Width           =   375
   End
End
Attribute VB_Name = "SaveTable"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
On Error GoTo ending

Open STable For Output As 1

If Option1 = True Then
If Check1 = False Then '--------------- В обычном порядке

    If Not Check2 = False Then
        For w = 0 To 255
            If Not Table(256, w) = "" Then
                q = 1
                Exit For
            End If
        Next w
    End If


        If q = 1 Then
        If Check3 = False Then
            Print #1, ""
            Print #1, "// --"
            Print #1, ""
        End If
            q = 0
        End If


    For s = 0 To 255                    '---
        If Not Check3 = False Then
            If Not TInd = 256 Then Exit For
        End If
        If Not Table(256, s) = "" Then
            Print #1, Right("00" + Hex(s), 2) + "=" + Table(256, s)
        End If
    Next s                              '---
    
    
    
    For n = 0 To 255                    '---
    
    If Not Check2 = False Then
        For w = 0 To 255
            If Not Table(n, w) = "" Then
                q = 1
                Exit For
            End If
        Next w
    End If
            
        If q = 1 Then
        If Check3 = False Then
            Print #1, ""
            Print #1, "// " & Right("00" + Hex(n), 2)
            Print #1, ""
        End If
            q = 0
        End If
    
    For s = 0 To 255                    '---
    
        If Not Check3 = False Then
            If Not TInd = n Then Exit For
        End If
        
        If Not Table(n, s) = "" Then
            Print #1, Right("00" + Hex(n), 2) + Right("00" + Hex(s), 2) + "=" + Table(n, s)
        End If
    Next s                              '---
    Next n                              '---

ElseIf Not Check1 = False Then '-------------- В обратном порядке
    If Check4 = False Then
        Min = 255
        Max = 0
        stp = -1
    Else
        Max = 255
        Min = 0
        stp = 1
    End If
                        
If Not Check4 = False Then
                        
    If Not Check2 = False Then
        For w = 0 To 255
            If Not Table(256, w) = "" Then
                q = 1
                Exit For
            End If
        Next w
    End If


        If q = 1 Then
        If Check3 = False Then
            Print #1, ""
            Print #1, "// --"
            Print #1, ""
        End If
            q = 0
        End If

End If
                        
    For s = 255 To 0 Step -1            '---
        If Check4 = False Then Exit For
        If Not Check3 = False Then
            If Not TInd = 256 Then Exit For
        End If
        If Not Table(256, s) = "" Then
            Print #1, Right("00" + Hex(s), 2) + "=" + Table(256, s)
        End If
    Next s                              '---
    
    For n = Min To Max Step stp         '---
        If Not Check2 = False Then
        For w = 0 To 255
            If Not Table(n, w) = "" Then
                q = 1
                Exit For
            End If
        Next w
    End If
            
        If q = 1 Then
        If Check3 = False Then
            Print #1, ""
            Print #1, "// " & Right("00" + Hex(n), 2)
            Print #1, ""
        End If
            q = 0
        End If

    For s = 255 To o Step -1            '---
        If Not Check3 = False Then
            If Not TInd = n Then Exit For
        End If
        
        If Not Table(n, s) = "" Then
        
            Print #1, Right("00" + Hex(n), 2) + Right("00" + Hex(s), 2) + "=" + Table(n, s)
        End If
    Next s                              '---
    Next n                              '---
    
If Check4 = False Then
                        
    If Not Check2 = False Then
        For w = 0 To 255
            If Not Table(256, w) = "" Then
                q = 1
                Exit For
            End If
        Next w
    End If


        If q = 1 Then
        If Check3 = False Then
            Print #1, ""
            Print #1, "// --"
            Print #1, ""
        End If
            q = 0
        End If
End If
    
    For s = 255 To 0 Step -1            '---
        If Not Check4 = False Then Exit For
        If Not Check3 = False Then
            If Not TInd = 256 Then Exit For
        End If
        If Not Table(256, s) = "" Then
            Print #1, Right("00" + Hex(s), 2) + "=" + Table(256, s)
        End If
    Next s                              '---
    
End If
                    
ElseIf Option2 = True Then '-----OpTiOn 2--------- По длине
Else
End If
Close 1
If Not clsme = flase Then
    Me.Hide
End If
Exit Sub

ending:
MsgBox "Ошибка сохранения файла!", , "Ошибка!"

End Sub

Private Sub Command2__Click()
If TInd = 255 Then
    TInd = 256
    FirstIndex = "--"
    MainForm.FirstIndex = "--"
ElseIf TInd = 256 Then
    FirstIndex = "00"
    MainForm.FirstIndex = "00"
    TInd = 0
Else
    TInd = TInd + 1
    FirstIndex = Right("00" + Hex(TInd), 2)
    MainForm.FirstIndex = Right("00" + Hex(TInd), 2)
End If
Call TableWr
End Sub

Private Sub Command2_Click()
If Option1 = True Then
    'If not Check1=true
        Call ShowMeTable
ElseIf Option2 = True Then
Else
End If

End Sub

Private Sub Command3_Click()
If TInd = 0 Then
    TInd = 256
    FirstIndex = "--"
    MainForm.FirstIndex = "--"
Else
    TInd = TInd - 1
    FirstIndex = Right("00" + Hex(TInd), 2)
    MainForm.FirstIndex = Right("00" + Hex(TInd), 2)
End If
Call TableWr
End Sub

Private Sub Command4_Click()
LTableBackup = STable

Dial.Form = Me.hWnd
Dial.Filter = "Файлы таблиц (*.tbl)" + Chr$(0) _
        + "*.tbl" + Chr$(0) + "Текстовые файлы (*.txt)" _
        + Chr$(0) + "*.txt" + Chr$(0) + "Все файлы (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
Dial.Title = "Сохранение таблицы"
STable = ShowSave
If Not InStr(1, STable, "\") = 0 Then
    Dial.Dir = Right(STable, Len(STable) - InStrRev(STable, "\"))
End If
If STable = "" Then STable = LTableBackup
End Sub

Private Sub Command5_Click()
MainForm.Command4 = True
End Sub

Private Sub Command6_Click()
TInd = 256
FirstIndex = "--"
MainForm.FirstIndex = "--"
End Sub

Private Sub Form_Load()
If TInd = 256 Then FirstIndex = "--" Else FirstIndex = Right("00" + Hex(TInd), 2)
End Sub
