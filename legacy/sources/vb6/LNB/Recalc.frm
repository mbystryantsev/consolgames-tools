VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "Mscomctl.ocx"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
Begin VB.Form Form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "LNB Pointer Recalculator"
   ClientHeight    =   5880
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   6750
   Icon            =   "Recalc.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5880
   ScaleWidth      =   6750
   StartUpPosition =   3  'Windows Default
   Begin MSComctlLib.ProgressBar PB1 
      Height          =   375
      Left            =   240
      TabIndex        =   16
      Top             =   5280
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
      Left            =   5040
      TabIndex        =   13
      Top             =   3360
      Width           =   1455
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
      Left            =   5040
      TabIndex        =   12
      Top             =   2520
      Width           =   1455
   End
   Begin VB.OptionButton All 
      Caption         =   "Все таблицы"
      Height          =   375
      Left            =   240
      TabIndex        =   9
      Top             =   4560
      Value           =   -1  'True
      Width           =   1695
   End
   Begin VB.OptionButton One 
      Caption         =   "Отдельные таблицы:"
      Height          =   375
      Left            =   240
      TabIndex        =   8
      Top             =   2640
      Width           =   2415
   End
   Begin VB.CheckBox T2 
      Caption         =   "Таблица 2 (3E710-3E88F)"
      Enabled         =   0   'False
      Height          =   255
      Left            =   840
      TabIndex        =   7
      Top             =   3720
      Width           =   2295
   End
   Begin VB.CheckBox T1 
      Caption         =   "Таблица 1 (36C15-372A0)"
      Enabled         =   0   'False
      Height          =   255
      Left            =   840
      TabIndex        =   6
      Top             =   3360
      Width           =   2295
   End
   Begin VB.TextBox file2 
      Height          =   285
      Left            =   240
      TabIndex        =   1
      Top             =   1800
      Width           =   4935
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   240
      TabIndex        =   0
      Top             =   840
      Width           =   4935
   End
   Begin VB.Frame Frame1 
      Caption         =   "Оригинальный файл"
      Height          =   735
      Left            =   120
      TabIndex        =   2
      Top             =   600
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
      Top             =   1560
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
   Begin VB.Frame Frame3 
      Caption         =   "Быбор таблиц"
      Height          =   2655
      Left            =   120
      TabIndex        =   10
      Top             =   2400
      Width           =   4815
      Begin VB.Frame Frame4 
         Caption         =   "Обрабатываемые таблицы:"
         Height          =   1455
         Left            =   480
         TabIndex        =   11
         Top             =   600
         Width           =   4095
         Begin VB.CheckBox T3 
            Caption         =   "Таблица 3 ( 7DBD-7DEB )"
            Enabled         =   0   'False
            Height          =   255
            Left            =   240
            TabIndex        =   20
            Top             =   1080
            Width           =   2295
         End
      End
   End
   Begin VB.Frame Frame5 
      Caption         =   "Статус:"
      Height          =   975
      Left            =   5040
      TabIndex        =   14
      Top             =   4080
      Width           =   1575
      Begin VB.Label Stat 
         Alignment       =   2  'Центровка
         Caption         =   "Жду..."
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   204
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   120
         TabIndex        =   15
         Top             =   360
         Width           =   1335
      End
   End
   Begin VB.Frame Frame6 
      Caption         =   "Прогресс:"
      Height          =   735
      Left            =   120
      TabIndex        =   17
      Top             =   5040
      Width           =   6495
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Центровка
      Caption         =   "©HoRRoR, 2006г. Ho-RR-oR@mail.ru"
      Height          =   255
      Left            =   240
      TabIndex        =   19
      Top             =   240
      Width           =   6135
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Центровка
      Caption         =   "Рекалькулятор поинтеров для игры ""Little Ninja Brothers""(NES). V2.3.0.7 alpha"
      Height          =   255
      Left            =   240
      TabIndex        =   18
      Top             =   0
      Width           =   6255
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
Stat = "Обработка..."
PB1 = 0.0001
Dim b1 As Byte
Dim b2 As Byte
Dim tb As Byte
Dim ep1 As Byte
Dim ep2 As Byte
Dim bte As Byte
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

If One = True Then
    If T1 = False And T2 = False And T3 = False Then
        Stat = "Жду..."
        MsgBox "Выбирите таблицу!", , "Не выбрана таблица"
    End If
    If Not T1 = False And Not T2 = False And T3 = False Then f1 = 1: f2 = 1: Stat = "Обработка...": mes = 0: PB1 = 0.0001
    If Not T1 = False And Not T2 = False And Not T3 = False Then f1 = 1: f2 = 1: f3 = 1: Stat = "Обработка...": mes = 0: PB1 = 0.0001
    If Not T1 = False And T2 = False And T3 = False Then
        f1 = 1: Stat = "Обработка..."
        mes = 0: PB1 = 0.0001
    End If
    If Not T2 = False And T1 = False And T3 = False Then
        f2 = 1: Stat = "Обработка..."
        mes = 0: PB1 = 0.0001
    End If
    If Not T3 = False And T1 = False And T2 = False Then f3 = 1: PB1 = 0.0001
    If Not T3 = False And Not T1 = False And T2 = False Then f3 = 1: f1 = 1: PB1 = 0.0001
    If Not T3 = False And T1 = False And Not T2 = False Then f3 = 1: f2 = 1: PB1 = 0.0001
ElseIf All = True Then: Stat = "Обработка..."
    f1 = 1: f2 = 1: f3 = 1: mes = 0: PB1 = 0.0001
End If

If f1 = 1 Then
If mes = 0 Then
    MsgBox "Внимание! Во время обработки файлов программа может 'зависнуть' на некоторое время, от 1 секунды до нескольких минут, взависимости от конфигурации вашего компьютера и выбранных таблиц. Индикатор в нижнем правом углу показывает состояние программы.", , "Внимание!"
    mes = 1
End If
Stat = "Обработка..."

Open file1 For Binary As #1 'открытие оригинала
Open file2 For Binary As #2 'открытие измененного файла

For pos = Val("&H36C18") + 1 To Val("&H372A1") Step 3 'Берутся начальное и конечное смещения таблицы
    Get #1, pos, b1 'считывается первый байт поинтера
    Get #1, pos + 1, b2 'считывается второй байт поинтера
       Rem MsgBox "Первый и второй байты считаы " & Hex$(b1) & " по смещению " & Hex$(pos - 1) & " и " & Hex$(b2) & " по смещению " & Hex$(pos)

    If f2 = 0 And f3 = 0 Then
        PB1 = ((pos - 224280) / 1673) * 100 '224280-225953=1673
    ElseIf f2 = 1 And f3 = 0 Then
        PB1 = ((pos - 224280) / 1673) * 81.37
    ElseIf f3 = 1 And f2 = 0 Then
        PB1 = ((pos - 224280) / 1673) * 97.5
    Else
        PB1 = ((pos - 224280) / 1673) * 79.7
    End If



 

    st = 6
    adr = Right$("0000" + Hex$(b1), 2) + Right$(Hex$(b2), 2)
    adr = Right$("0000" + adr, 4)
    a1 = Mid$(adr, 1, 1)
    a2 = Mid$(adr, 2, 1)
    a3 = Mid$(adr, 3, 1)
    a4 = Mid$(adr, 4, 1) '0-e
       Rem MsgBox "Поинтер = " & a1 + a2 + a3 + a4
    
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
       Rem MsgBox adr & " --> " & a3 + a4 + a1 + a2 & " + 10h"
    Adres = "&H3" + Right$(Hex$(Val("&H" + a3 + a4 + a1 + a2) + Val(&H10)), 4) 'определение конечного адреса
    adres2 = Val(Adres) + 1
       Rem MsgBox "Адрес вычислен " & adr & " --> " & Hex$(adres2 - 1)
    
    
        
    
        Get #1, Adres, bte
        For pos2 = Val("&H372A1") + 1 To adres2 - 1 'цикл определения количества "FF" до смещения, указанного поинтером
            Get #1, pos2, tb 'получение байта в переменную
            If tb = bte Then numff = numff + 1 'If tb = 255 Or tb = 246 Then numff = numff + 1 'если бай равен "FF", то счетчик=счетчик+1
        Next pos2 'закрытие цикла
           Rem MsgBox "Найдено байт " & Hex$(255) & " до смещения " & Hex$(adres2 - 1) & ": " & numff
        For pos3 = Val("&H372A1") + 1 To Val("&H39F73") 'цикл счетчика байт "FF" в изменяемом файле
            Get #2, pos3, tb 'получение байта в переменную
             'сравнивание его с кол-вом байт оригинала, если больше или равно - пропуск
            If num2ff < numff Then
                If tb = bte Then 'If tb = 255 Or tb = 246 Then
                    num2ff = num2ff + 1 'увиличение счетчика

                       Rem MsgBox "Найден байт FF по адресу " & Hex$(pos3 - 1)
                End If
            End If
            If numff = num2ff Then 'если счетчики равны, берется следующий байт после стоп-байта
                num2ff = num2ff + 1
                padres = pos3
             GoTo 10
                   Rem MsgBox "Счетчики совпали: " & numff & "=" & num2ff - 1 & " смещение байта после стоп-байта = " & Hex$(padres - 1)
            End If
        Next pos3
10         numff = 0
        num2ff = 0
        
                
                
                
                
     'определение поинтера по адресу
    st = 10
    dr = Hex$(padres - Val("&H10"))
    dr = Right$("0000" + dr, 4)
    a1 = Mid$(dr, 1, 1)
    a2 = Mid$(dr, 2, 1)
    a3 = Mid$(dr, 3, 1)
    a4 = Mid$(dr, 4, 1)
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
    epointer1 = Val("&H" + a3 + a4 + a1 + a2)
    epointer1 = Right$("0000" + Hex$(epointer1), 4)
    epointer2 = Right$(epointer1, 2)
    epointer1 = Left$(epointer1, 2)
       Rem MsgBox "Адрес --> поинтер: " & Hex$(Val("&H" + dr) + Val("&H10")) & " --> " & epointer1 + epointer2
    ep1 = Val("&H" + epointer1)
    ep2 = Val("&H" + epointer2)
    Put #2, pos, ep1
    Put #2, pos + 1, ep2
       Rem MsgBox "Запись байт поинтера: " & Hex$(ep1) & " в " & Hex$(pos - 1) & " и " & Hex$(ep2) & " в " & Hex$(pos)
Next pos
Stat = "Готово!"
PB1 = 0.0001
Close
End If
    
    
    
Rem PART 2-----------------------------------------------------------------------
    
    
    
If f2 = 1 Then
If mes = 0 Then
    MsgBox "Внимание! Во время обработки файлов программа может 'зависнуть' на некоторое время, от 1 секунды до нескольких минут, взависимости от конфигурации вашего компьютера и выбранных таблиц. Индикатор в нижнем правом углу показывает состояние программы.", , "Внимание!"
    mes = 1
End If
Stat = "Обработка..."

Open file1 For Binary As #1 'открытие оригинала
Open file2 For Binary As #2 'открытие измененного файла

For pos = Val("&H3E714") + 1 To Val("&H3E88F") Step 2 'Берутся начальное и конечное смещения таблицы
    Get #1, pos, b1 'считывается первый байт поинтера
    Get #1, pos + 1, b2 'считывается второй байт поинтера
       Rem MsgBox "Первый и второй байты считаы " & Hex$(b1) & " по смещению " & Hex$(pos - 1) & " и " & Hex$(b2) & " по смещению " & Hex$(pos)

    If f1 = 0 And f3 = 0 Then
        PB1 = ((pos - 255760) / 383) * 100 '256143-255760=383
    ElseIf f1 = 1 And f3 = 0 Then
        PB1 = (((pos - 255760) / 383) * 18.62) + 81.37
    ElseIf f1 = 0 And f3 = 1 Then
        PB1 = ((pos - 255760) / 383) * 90
    Else
        PB1 = (((pos - 255760) / 383) * 18.24) + 79.7
    End If



 

    st = 14
    adr = Right$("0000" + Hex$(b1), 2) + Right$("0000" + Hex$(b2), 2)
    adr = Right$("0000" + adr, 4)
    a1 = Mid$(adr, 1, 1)
    a2 = Mid$(adr, 2, 1)
    a3 = Mid$(adr, 3, 1)
    a4 = Mid$(adr, 4, 1) '0-e
       Rem MsgBox "Поинтер = " & a1 + a2 + a3 + a4
    
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
       Rem MsgBox adr & " --> " & a3 + a4 + a1 + a2 & " + 10h"
    Adres = "&H3" + Right$(Hex$(Val("&H" + a3 + a4 + a1 + a2) + Val(&H10)), 4) 'определение конечного адреса
    adres2 = Val(Adres) + 1
       Rem MsgBox "Адрес вычислен " & adr & " --> " & Hex$(adres2 - 1)
    If adres2 < Val("&H3E894") + 1 Then
        Rem MsgBox "Недопустимый адрес: " & adr
        GoTo 30
    End If
        
    
    
        Get #1, Adres, bte
        For pos2 = Val("&H3E894") + 1 To adres2 - 1 'цикл определения количества "FF" до смещения, указанного поинтером
            Get #1, pos2, tb 'получение байта в переменную
            If tb = bte Then numff = numff + 1 'If tb = 255 Or tb = 246 Then numff = numff + 1 'если бай равен "FF", то счетчик=счетчик+1
        Next pos2 'закрытие цикла
           Rem MsgBox "Найдено байт " & Hex$(bte) & " до смещения " & Hex$(adres2 - 1) & ": " & numff
        For pos3 = Val("&H3E894") + 1 To Val("&H3FFBF") 'цикл счетчика байт "FF" в изменяемом файле
            Get #2, pos3, tb 'получение байта в переменную
             'сравнивание его с кол-вом байт оригинала, если больше или равно - пропуск
            If num2ff < numff Then
                If tb = bte Then 'If tb = 255 Or tb = 246 Then
                    num2ff = num2ff + 1 'увиличение счетчика

                       Rem MsgBox "Найден байт" & Hex$(bte) & "по адресу " & Hex$(pos3 - 1)
                End If
            End If
            If numff = num2ff Then 'если счетчики равны, берется следующий байт после стоп-байта
                num2ff = num2ff + 1
                padres = pos3
             GoTo 20
                   Rem MsgBox "Счетчики совпали: " & numff & "=" & num2ff - 1 & " смещение байта после стоп-байта = " & Hex$(padres - 1)
            End If
        Next pos3
20         numff = 0
        num2ff = 0
        
                
                
                
                
     'определение поинтера по адресу
    st = 2
    dr = Hex$(padres - Val("&H10"))
    dr = Right$("0000" + dr, 4)
    a1 = Mid$(dr, 1, 1)
    a2 = Mid$(dr, 2, 1)
    a3 = Mid$(dr, 3, 1)
    a4 = Mid$(dr, 4, 1)
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
    epointer1 = Val("&H" + a3 + a4 + a1 + a2)
    epointer1 = Right$("0000" + Hex$(epointer1), 4)
    epointer2 = Right$(epointer1, 2)
    epointer1 = Left$(epointer1, 2)
       Rem MsgBox "Адрес --> поинтер: " & Hex$(Val("&H" + dr) + Val("&H10")) & " --> " & epointer1 + epointer2
    ep1 = Val("&H" + epointer1)
    ep2 = Val("&H" + epointer2)
    Put #2, pos, ep1
    Put #2, pos + 1, ep2
       Rem MsgBox "Запись байт поинтера: " & Hex$(ep1) & " в " & Hex$(pos - 1) & " и " & Hex$(ep2) & " в " & Hex$(pos)
30 Next pos
Stat = "Готово!"
PB1 = 0.0001
Close
End If



f1 = 0: f2 = 0







Rem PART 3----------------------------------------------------------------------


If f3 = 1 Then
If mes = 0 Then
    MsgBox "Внимание! Во время обработки файлов программа может 'зависнуть' на некоторое время, от 1 секунды до нескольких минут, взависимости от конфигурации вашего компьютера и выбранных таблиц. Индикатор в нижнем правом углу показывает состояние программы.", , "Внимание!"
    mes = 1
End If
Stat = "Обработка..."

Open file1 For Binary As #1 'открытие оригинала
Open file2 For Binary As #2 'открытие измененного файла

For pos = Val("&H7DC0") + 1 To Val("&H7DEA") Step 3 'Берутся начальное и конечное смещения таблицы
    Get #1, pos, b1 'считывается первый байт поинтера
    Get #1, pos + 1, b2 'считывается второй байт поинтера
        Rem MsgBox "Первый и второй байты считаы " & Hex$(b1) & " по смещению " & Hex$(pos - 1) & " и " & Hex$(b2) & " по смещению " & Hex$(pos)

    If f1 = 1 And f2 = 0 Then
        PB1 = (((pos - 32192) / 43) * 2.5) + 97.5 '32192-32235=43
    ElseIf f1 = 0 And f2 = 1 Then
        PB1 = (((pos - 32192) / 43) * 10) + 90
    ElseIf f1 = 1 And f2 = 1 Then
        PB1 = (((pos - 32192) / 43) * 2.04) + 79.7 + 18.24
    Else
        PB1 = ((pos - 32192) / 43) * 100
    End If



 

    st = 12
    adr = Right$("0000" + Hex$(b1), 2) + Right$(Hex$(b2), 2)
    adr = Right$("0000" + adr, 4)
    a1 = Mid$(adr, 1, 1)
    a2 = Mid$(adr, 2, 1)
    a3 = Mid$(adr, 3, 1)
    a4 = Mid$(adr, 4, 1) '0-e
        Rem MsgBox "Поинтер = " & a1 + a2 + a3 + a4
    
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
        Rem MsgBox adr & " --> " & a3 + a4 + a1 + a2 & " + 10h"
    Adres = "&H" + Right$(Hex$(Val("&H" + a3 + a4 + a1 + a2) + Val(&H10)), 4) 'определение конечного адреса
    adres2 = Val(Adres) + 1
        Rem MsgBox "Адрес вычислен " & adr & " --> " & Hex$(adres2 - 1)
    If adres2 < Val("&H7DEC") + 1 Or adres2 > Val("&H7EE7") + 1 Then
         Rem MsgBox "Недопустимый адрес: " & adr
        GoTo 70
    End If
    
    
        
    
        Get #1, Adres, bte
        For pos2 = Val("&H7DEC") + 1 To adres2 - 1 'цикл определения количества "FF" до смещения, указанного поинтером
            Get #1, pos2, tb 'получение байта в переменную
            If tb = bte Then numff = numff + 1 'If tb = 255 Or tb = 246 Then numff = numff + 1 'если бай равен "FF", то счетчик=счетчик+1
        Next pos2 'закрытие цикла
            Rem MsgBox "Найдено байт " & Hex$(255) & " до смещения " & Hex$(adres2 - 1) & ": " & numff
        For pos3 = Val("&H7DEC") + 1 To Val("&H7EE7") 'цикл счетчика байт "FF" в изменяемом файле
            Get #2, pos3, tb 'получение байта в переменную
             'сравнивание его с кол-вом байт оригинала, если больше или равно - пропуск
            If num2ff < numff Then
                If tb = bte Then 'If tb = 255 Or tb = 246 Then
                    num2ff = num2ff + 1 'увиличение счетчика

                        Rem MsgBox "Найден байт FF по адресу " & Hex$(pos3 - 1)
                End If
            End If
            If numff = num2ff Then 'если счетчики равны, берется следующий байт после стоп-байта
                num2ff = num2ff + 1
                padres = pos3
             GoTo 60
                    Rem MsgBox "Счетчики совпали: " & numff & "=" & num2ff - 1 & " смещение байта после стоп-байта = " & Hex$(padres - 1)
            End If
        Next pos3
60         numff = 0
        num2ff = 0
        
                
                
                
                
     'определение поинтера по адресу
    st = 4
    dr = Hex$(padres - Val("&H10"))
    dr = Right$("0000" + dr, 4)
    a1 = Mid$(dr, 1, 1)
    a2 = Mid$(dr, 2, 1)
    a3 = Mid$(dr, 3, 1)
    a4 = Mid$(dr, 4, 1)
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
    epointer1 = Val("&H" + a3 + a4 + a1 + a2)
    epointer1 = Right$("0000" + Hex$(epointer1), 4)
    epointer2 = Right$(epointer1, 2)
    epointer1 = Left$(epointer1, 2)
        Rem MsgBox "Адрес --> поинтер: " & Hex$(Val("&H" + dr) + Val("&H10")) & " --> " & epointer1 + epointer2
    ep1 = Val("&H" + epointer1)
    ep2 = Val("&H" + epointer2)
    Put #2, pos, ep1
    Put #2, pos + 1, ep2
        Rem MsgBox "Запись байт поинтера: " & Hex$(ep1) & " в " & Hex$(pos - 1) & " и " & Hex$(ep2) & " в " & Hex$(pos)
70 Next pos
Stat = "Готово!"
PB1 = 0.0001
Close
End If
End If


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
