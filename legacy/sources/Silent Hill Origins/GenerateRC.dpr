program GenerateRC;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes;

var List: TStringList; n, Size: Integer; Buf: Pointer; B: ^Byte; F: File; S: String;
begin
  If ParamCount <> 2 Then Exit;
  If not FileExists(ParamStr(1)) Then Exit;
  // Resource RC
  List := TStringList.Create;
  List.Add('IPS_ARC RCDATA'#13#10 +
           'MOVEABLE PURE LOADONCALL DISCARDABLE'#13#10 +
           'LANGUAGE LANG_NEUTRAL, 0'#13#10 +
           'BEGIN');
  AssignFile(F, ParamStr(1));
  Reset(F,1);
  Size := FileSize(F);
  GetMem(Buf, Size);
  BlockRead(F, Buf^, Size);
  CloseFile(F);

  B := Buf;
  S := '''';
  For n:=0 To Size - 1 do
  begin
    If (n > 0) and (n AND $F = 0) Then
    begin
      S := S + '''';
      List.Add(S);
      S:='''';
    end;
    S := Format('%s%2.2x ',[S, B^]);
    Inc(B);
  end;

  S := S + '''';
  If S <> '''''' Then
    List.Add(S);
  List.Add('END');

  List.SaveToFile(ParamStr(2));
  List.Free;
  FreeMem(Buf);
  WriteLn('RC generated!');
end.
 