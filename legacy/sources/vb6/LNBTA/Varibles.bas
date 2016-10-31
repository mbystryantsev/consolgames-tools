Attribute VB_Name = "Varibles"
Public Table As MainTable
Public Type MainTable
    Table() As String
    Value() As Integer
    Temp(2048) As String
    temp2(2048) As Integer
    File As String
    count As Integer
End Type
Public StopTable As StopWordTable
Public Type StopWordTable
    Table() As String
    Temp(2048) As String
    File As String
    count As Integer
    en As Boolean
End Type
Public TwoTable As SecondTable
Public Type SecondTable
    Length() As Integer
    en As Boolean
    Table() As String
    Temp(2048) As String
    File As String
    count As Integer
End Type
Public GenTable As GeneratedTable
Public Type GeneratedTable
    Value() As Integer
    strng() As String
    count As Integer
End Type
Public Adr As TableAdres
Public Type TableAdres
    eAdr1(255) As Byte
    eAdr2(255) As Byte
    sAdr1(255) As Byte
    sAdr2(255) As Byte
End Type
Public WordCount As Long
Public Temp()  As String
Public iCount() As Integer
Public word As String
Public Gold() As Long
Public n, c, l As Long
Public Flag() As Boolean
Public NewWord() As String
Public Tmp As Long
Public MemRec As Long
Public Clear() As String
Public Cnt, NewCnt As Long
Public NewFlag()
Public NewiCount() As Integer
Public NewGold() As Integer
Public LenSort() As Integer
'Public NewCount() As Integer
