Attribute VB_Name = "Модуль1"
Public sum As Long
Public sum2 As Long

Public Function H800(H As Long) As Long
HH = H
HH = HH + 2047
H800 = (HH \ 2048) * 2048
End Function
