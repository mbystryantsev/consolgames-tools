Attribute VB_Name = "Module1"
Public LinLen As Integer
Public Declare Function GetOpenFileName Lib "comdlg32.dll" Alias "GetOpenFileNameA" (pOpenfilename As OPENFILENAME) As Long ' Объявление функций
Public Declare Function GetSaveFileName Lib "comdlg32.dll" Alias "GetSaveFileNameA" (pOpenfilename As OPENFILENAME) As Long
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
Public ListZapret As Boolean
Public Opened As Boolean

Public Dial             As DIALOG
Public Type DIALOG                              '
    Form                As Long                 ' Форма, вызвавшая диалог
    Filter              As String               ' Фильтр
    Title               As String               ' Заголовок
    Dir                 As String               ' Начальная директория
    Backup              As String
    File                As String
End Type
Public msgChText(2048, 512) As String
'Public n, c As Long

Public Fs As FormSizes
Public Type FormSizes
    leftleft As String
    rightleft As String
    leftwidth As String
    rightwidth As String
End Type

Public EditType As Boolean
Public teg(2048, 512) As Boolean
Public tempteg(512) As Boolean
Public Msgtext(2048, 512) As String
Public Tegs(1 To 70) As String
Public msg As NewMsg
Public Type NewMsg
    'zapret As Boolean
    Index As Integer
    nstr As Integer
    pos As Integer
    tg As Integer
    num As Integer
    clear(2048) As Boolean
    count(2048) As Integer
    strn As Integer
    temp(512) As String
    flag    As Boolean
End Type
Public CntTxtMax As Integer
Public FullTextBox As Integer
Public Word As ScriptWord
Public Type ScriptWord
    Index               As Long
    Text(2048)                 As String
    first(2048)              As Long
    last(2048)                 As Long
    max                 As Long
    clear(2048)               As Boolean
    lastText            As Long
    count               As Long
    pos                 As Long
    ChText(2048)              As String
End Type

Public labz, rabz As Boolean
Public cnt              As Long
Public zapret           As Boolean
Public tex, scr As String
'Public c, n As Long
Public script, code As String

Public Sub Main()
Tegs(1) = "<NOx"
Tegs(2) = "<CLx"
Tegs(3) = "<MSx"
Tegs(4) = "<KEx"
Tegs(5) = "<RMx"
Tegs(6) = "<TUx"
Tegs(7) = "<SLx"
Tegs(8) = "<HMx"
Tegs(9) = "<PRx"
Tegs(10) = "<SVx"
Tegs(11) = "<SMx"
Tegs(12) = "<FMx"
Tegs(13) = "<CSx"
Tegs(14) = ""
Tegs(15) = ""
Tegs(16) = ""
Tegs(17) = ""
Tegs(18) = ""
Tegs(19) = ""
Tegs(20) = "<MLxxxxx"
Tegs(21) = "<FAxxxxx"
Tegs(22) = "<WAxxxxx"
Tegs(23) = ""
Tegs(24) = "<GIxxxxx"
Tegs(25) = ""
Tegs(26) = "<YNxxxxx"
Tegs(27) = "<MYxxxxx"
Tegs(28) = "<EVxxxxx"
Tegs(29) = ""
Tegs(30) = ""
Tegs(31) = "<DNxxxxx"
Tegs(32) = "<SOxxxxx"
Tegs(33) = ""
Tegs(34) = "<BSxxxxx"
Tegs(35) = "<EQxxxxx"
Tegs(57) = "<NCxxxxx"
Tegs(37) = "<MOxxxxx"
Tegs(38) = "<QUxxxxx"
Tegs(39) = "<SKxxxxx"
Tegs(40) = "<BOxxxxx"
Tegs(41) = "<TAxxxxx"
Tegs(42) = "<LIxxxxx"
Tegs(43) = ""
Tegs(44) = ""
Tegs(45) = ""
Tegs(46) = ""
Tegs(47) = ""
Tegs(48) = ""
Tegs(49) = ""
Tegs(50) = "<ANxxxxx:xxxx:xxxx"
Tegs(51) = "<CNxxxxx:xxxx:xxxx"
Tegs(52) = ""
Tegs(53) = ""
Tegs(66) = "<FOxxxxx"
Tegs(55) = "<PSxxxxx:xxxx"
Tegs(56) = "<AMxxxxx:xxxx"
Tegs(63) = "<TRAxxxx:xxxx:xxxx:xxxx"
Tegs(62) = "<CMx"
Tegs(61) = "<FLx"
Tegs(60) = "<MNx"
Tegs(65) = "<ITxxxxx"
Fs.leftleft = Form1.LeftText.Left
Fs.leftwidth = Form1.LeftText.Width
Fs.rightleft = Form1.RightText.Left
Fs.rightwidth = Form1.RightText.Width
EditSelect.Show
End Sub


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

Public Sub FindButton()

If Search.FText <> "" Then
If EditType = False Then
    For n = Word.Index To Word.count
        If Word.clear(n) = True Then
            If Word.Index = n Then beg = Form1.RightText.SelStart + 1 + Form1.RightText.SelLength Else beg = 1
            If InStr(beg, Word.Text(n), Search.FText) > 0 Then
                'If Not Check2 = False Then
                    
                'End If
                For c = 0 To Form1.List.ListCount - 1
                    If Form1.List.ItemData(c) = n Then
                        Form1.List.ListIndex = c
                        Exit For
                    End If
                Next c
                Search.Hide
                Form1.Enabled = True
                Form1.RightText.SetFocus
                Form1.RightText.SelStart = InStr(beg, Word.Text(n), Search.FText) - 1
                Form1.RightText.SelLength = Len(Search.FText)
                'Form1.Enabled = False
                Exit Sub
            End If
        End If
    Next n
    MsgBox "Искомая строка не найдена!", , "Поиск завершён"
Else
    ListZapret = True
    If fndFlag = False Then
        lbg = Form1.NewList.ItemData(Form1.NewList.ListIndex)
        fndFlag = True
    End If
    For n = Word.Index To Word.count
        If Word.clear(n) = True Then
            For c = lbg To msg.count(n)
            If teg(n, c) = False Then
                If Word.Index = n And Form1.NewList.ItemData(Form1.NewList.ListIndex) = c Then beg = Form1.RightText.SelStart + 1 + Form1.RightText.SelLength Else beg = 1
                pInStr = InStr(beg, Msgtext(n, c), Search.FText)
                If pInStr > 0 Then
                    For l = 0 To Form1.List.ListCount - 1
                        If Form1.List.ItemData(l) = n Then
                            Form1.List.ListIndex = l
                            Exit For
                        End If
                    Next l
                    For l = 0 To Form1.NewList.ListCount - 1
                        If Form1.NewList.ItemData(l) = c Then
                            Form1.NewList.ListIndex = l
                            Exit For
                        End If
                    Next l
                    Search.Hide
                    Form1.Enabled = True
                    Form1.RightText.SetFocus
                    Form1.RightText.SelStart = pInStr - 1
                    Form1.RightText.SelLength = Len(Search.FText)
                    ListZapret = False
                    Exit Sub
                End If
            End If
            Next c
        End If
        lbg = 1
    Next n
    
    MsgBox "Искомая строка не найдена!", , "Поиск завершён"
    ListZapret = False
End If
End If
End Sub
