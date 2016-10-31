Attribute VB_Name = "Calls"
Public Sub ShowMeTable(TableCont As String)
If TableCont = "Table" Then
    TableView.Text = ""
    For n = 1 To Table.count
        TableView.Text = TableView.Text & Hex(Table.Value(n)) & "=" & Table.Table(n) & vbCrLf
    Next n
ElseIf TableCont = "SecondTable" Then
    TableView.Text = ""
    For n = 1 To TwoTable.count
        TableView.Text = TableView.Text & "[" & TwoTable.Length(n) & "]" & TwoTable.Table(n) & vbCrLf
    Next n
TableView.Show
ElseIf TableCont = "StopTable" Then
    TableView.Text = ""
    For n = 1 To StopTable.count
        TableView.Text = TableView.Text & StopTable.Table(n) & vbCrLf
    Next n
ElseIf TableCont = "GenTable" Then
    'For n = 1 To GenTable.count
    '    If Len(Hex(GenTable.count)) > 2 Then dfd = "0000" Else dfd = "00"
    '    TableView.Text = TableView.Text & Right(dfd & Hex(GenTable.count), Len(dfd)) & "=" & GenTable.strng & vbCrLf
    'Next n
End If
TableView.Show
End Sub
