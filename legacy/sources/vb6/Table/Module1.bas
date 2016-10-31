Attribute VB_Name = "Модуль1"


Public Declare Function GetOpenFileName Lib "comdlg32.dll" Alias "GetOpenFileNameA" (pOpenfilename As OPENFILENAME) As Long ' Объявление функций
Public Declare Function GetSaveFileName Lib "comdlg32.dll" Alias "GetSaveFileNameA" (pOpenfilename As OPENFILENAME) As Long

'Public Declare Function ChooseColor Lib "comdlg32.dll" Alias "ChooseColorA" (pColor As Color) As Long ' Объявление функций

'Public Cr As Color
'Public Type Color
'    lStructSize As Long
'    hwndOwner As Long
'    hInstance As Long
'    lpstrFilter As String
'    lpstrCustomFilter As String
'    nMaxCustFilter As Long
'    nFilterIndex As Long
'    lpstrFile As String
'    nMaxFile As Long
'    lpstrFileTitle As String
'    nMaxFileTitle As Long
'    lpstrInitialDir As String
'    lpstrTitle As String
'    flags As Long
'    nFileOffset As Integer
'    nFileExtension As Integer
'    lpstrDefExt As String
'    lCustData As Long
'    lpfnHook As Long
'    lpTemplateName As String
'End Type
Public sh               As shablon
Public Type shablon
    Beg                 As Long
    En                  As Long
    Por                 As Boolean
    Otd                 As Boolean
    Obr                 As Boolean
    Inter               As Integer
End Type

Public OFName           As OPENFILENAME
Public Type OPENFILENAME
    lStructSize         As Long
    hwndOwner           As Long
    hInstance           As Long
    lpstrFilter         As String
    lpstrCustomFilter   As String
    nMaxCustFilter      As Long
    nFilterIndex        As Long
    lpstrFile           As String
    nMaxFile            As Long
    lpstrFileTitle      As String
    nMaxFileTitle       As Long
    lpstrInitialDir     As String
    lpstrTitle          As String
    flags               As Long
    nFileOffset         As Integer
    nFileExtension      As Integer
    lpstrDefExt         As String
    lCustData           As Long
    lpfnHook            As Long
    lpTemplateName      As String
End Type

Public vid              As INTERFACE
Public Type INTERFACE
    MFormHeight         As Long
    Index               As Integer
    NavColor            As Long
    temp2               As Long
    temp                As Long
    BackColorSelSel     As Long
    BackColorSel        As Long
    BackColorCross      As Long
    StandartColor       As Long
End Type
Public Dial             As DIALOG
Public Type DIALOG                              '
    Form                As Long                 ' Форма, вызвавшая диалог
    Filter              As String               ' Фильтр
    Title               As String               ' Заголовок
    Dir                 As String               ' Начальная директория
End Type

Public Res              As Reserv
Public Type Reserv                              '
    LDTEDic             As String
    WRight              As String
    WLeft               As String
End Type

Option Explicit

Public FromHexZapret    As Boolean
Public FullDic(256)     As Boolean              ' Если = false, то Dic пустой
Public Dic(256, 1)      As String               ' Текстовые значения словаря (например {3F})
Public ValDic(256, 1)   As Byte                 ' Числовые значения словаря (например val(3F))
Public bte              As Byte                 ' Для считывания в бинарном режиме
Public lostswr          As Integer
Public SelWr(255)       As Boolean
Public tb               As String
Public FormIndex        As Long
Public HxIndOne         As String
Public TInd, STInd      As Integer              ' Первый байт двухбайтогого hex-значения
Public sv               As Boolean              ' = True, если в момент включения выбора старшего байта была форма SaveTable
Public IndexSelect      As Boolean              ' = True, если происходит выбор старшего байта
Public Table(256, 256)  As String
Public NEWtable(256, 256) As String
Public DicTable(255)    As Integer
Public s, n             As Long                 'Бессмысленные переменные в циклах For n = x To y
'Public Wr              As Object
Public LostFocus        As Integer              ' Последняя активная ячейка
Public zapret           As Integer              ' Если 1, то Word не может прписать в WR(x)
Sub ShowMeTable()
tb = ""
For n = 0 To 255
    If Not Table(TInd, n) = "" Then
        If TInd = 256 Then
            tb = tb + Right("00" + Hex(n), 2) & "=" & Table(256, n) & vbCrLf
        Else
            tb = tb + Right("0000" + Hex(n), 4) & "=" & Table(TInd, n) & vbCrLf
        End If
    End If
Next n
ShowTable.ShowTableText = tb
ShowTable.Show
End Sub
Sub Main()
'For s = 0 To 0
    For n = 0 To 256
        FullDic(n) = False
    Next n
'Next s

    vid.MFormHeight = MainForm.Height
    vid.NavColor = &HC0FFC0
    vid.BackColorSelSel = &H80000013
    vid.BackColorCross = &H80000014
    vid.BackColorSel = &HC0C0FF
    vid.StandartColor = &H80000005
    vid.temp = &HC0C0FF 'vid.StandartColor
    

    STInd = 256

    OFName.lStructSize = Len(OFName)
    OFName.hwndOwner = Dial.Form
    OFName.hInstance = App.hInstance
    Dial.Filter = "Text Files (*.txt)" + Chr$(0) _
        + "*.txt" + Chr$(0) + "All Files (*.*)" _
        + Chr$(0) + "*.*" + Chr$(0)
    OFName.lpstrFile = Space$(254)
    OFName.nMaxFile = 255
    OFName.lpstrFileTitle = Space$(254)
    OFName.nMaxFileTitle = 255
    Dial.Dir = "C:\"
    Dial.Title = "Save File"
    OFName.flags = 0
    MainForm.Show
End Sub

Sub ShowAllTable()
tb = ""
For n = 0 To 255
    If Not Table(256, n) = "" Then
        tb = tb + Right("00" + Hex(n), 2) & "=" & Table(256, n) & vbCrLf
    End If
Next n

For s = 0 To 255
For n = 0 To 255
    If Not Table(s, n) = "" Then
        tb = tb + Right("00" + Hex(s), 2) + Right("00" + Hex(n), 2) & "=" & Table(s, n) & vbCrLf
    End If
Next n
Next s
ShowTable.ShowTableText = tb
ShowTable.Show
End Sub





'For n = 0 To 127
'    wrpos(n) = MainForm.Wr(n).Left
'Next n


'Private
Public Function ShowOpen() As String 'Подпрограмма. Обозначение всего чего нужно и вызов окна
    OFName.lStructSize = Len(OFName)
    OFName.hwndOwner = FormIndex
    OFName.hInstance = App.hInstance
    OFName.lpstrFilter = Dial.Filter 'фильтр
    OFName.lpstrFile = Space$(254)
    OFName.nMaxFile = 255
    OFName.lpstrFileTitle = Space$(254)
    OFName.nMaxFileTitle = 255
    OFName.lpstrInitialDir = Dial.Dir 'Начальная директория
    OFName.lpstrTitle = Dial.Title
    OFName.flags = 0

    If GetOpenFileName(OFName) Then 'Если была нажата кнопка Отмена или возникла ошибка, то в переменную ShowOpen возврашается  "" , иначе путь к файлу
        ShowOpen = Trim$(OFName.lpstrFile)
    Else
        ShowOpen = ""
    End If
End Function

'Private
Public Function ShowSave() As String ' Здесь всё аналогично
    OFName.lStructSize = Len(OFName)
    OFName.hwndOwner = FormIndex
    OFName.hInstance = App.hInstance
    OFName.lpstrFilter = Dial.Filter
    OFName.lpstrFile = Space$(254)
    OFName.nMaxFile = 255
    OFName.lpstrFileTitle = Space$(254)
    OFName.nMaxFileTitle = 255
    OFName.lpstrInitialDir = Dial.Dir
    OFName.lpstrTitle = Dial.Title
    OFName.flags = 0

    If GetSaveFileName(OFName) Then
        ShowSave = Trim$(OFName.lpstrFile)
    Else
        ShowSave = ""
    End If
End Function

'Public Function ChooseC() As String ' Здесь всё аналогично
'    Color.lStructSize = Len(Color)
'    Color.hwndOwner = FormIndex
'    Color.hInstance = App.hInstance
'    Color.lpstrFilter = Dial.Filter
'    Color.lpstrFile = Space$(254)
'    Color.nMaxFile = 255
'    Color.lpstrFileTitle = Space$(254)
'    Color.nMaxFileTitle = 255
'    Color.lpstrInitialDir = Dial.Dir
'    Color.lpstrTitle = Dial.Title
'    Color.flags = 0''''

'    If ChooseColor(Color) Then
'        ChooseC = Trim$(Color.lpstrFile)
'    Else
'        ChooseC = ""
'    End If
'End Function

Public Sub TableWr()
zapret = 1
For n = 0 To 255
    MainForm.Wr(n) = Table(TInd, n)
Next n
zapret = 0
MainForm.Word = MainForm.Wr(LostFocus)
End Sub


Public Sub Shablon_write()
    DTEDicEditor.BoR = sh.Beg
    DTEDicEditor.EoR = sh.En
    DTEDicEditor.Interval = sh.Inter
    DTEDicEditor.Option1 = sh.Por
    DTEDicEditor.Option2 = sh.Otd
    DTEDicEditor.Check1 = sh.Obr
End Sub
