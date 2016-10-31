Attribute VB_Name = "Модуль1"


Public fil() As Byte
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
Public Dial             As DIALOG
Public Type DIALOG                              '
    Form                As Long                 ' Форма, вызвавшая диалог
    Filter              As String               ' Фильтр
    Title               As String               ' Заголовок
    Dir                 As String               ' Начальная директория
    Backup              As String
    file                As String
End Type

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

    If GetOpenFileName(OFName) Then
        ShowOpen = Trim$(OFName.lpstrFile)
    Else
        ShowOpen = ""
    End If
End Function

'Private
Public Function ShowSave() As String
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

Public Function Ist(IstTxt As String) As Long
Dim w As Long
txt = IstTxt
If Left(txt, 2) <> "&H" Then
    If Left(txt, 2) <> "&h" Then
        Ist = Val(txt)
        Exit Function
    End If
End If
txt = Right(txt, Len(txt) - 2)
For n = Len(txt) To 1 Step -1
    w = w + Val("&H" & Mid(txt, n, 1)) * 16 ^ (Len(txt) - n)
Next n
Ist = w
End Function


