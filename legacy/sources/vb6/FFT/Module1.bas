Attribute VB_Name = "Модуль1"
Public Table(65536) As String
Public file(800, 85536) As Byte
Public text(800, 4000) As String
Public Type tTxt
    spos(4000) As Long
    epos(4000) As Long
    dlg As Integer
End Type
Public txt(800) As tTxt
Public cnt As Integer
