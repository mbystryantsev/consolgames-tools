program SHTextConv;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes//,
  {TntClasses};

Type
 TPtrRec = Packed Record
  ID: Cardinal;
  Ptr: Integer;
 end;

Var
 F: TFileStream; List: {TTnt}TStringList; WS: WideString; WC: WideChar;
 I, FileID, Cnt, SPos: Integer; PtrList: Array of TPtrRec;
begin
 WriteLn('http://consolgames.jino-net.ru/');
 If (ParamCount<2) or not FileExists(ParamStr(1)) Then Exit;
 F := TFileStream.Create(ParamStr(1), fmOpenRead);
 List := TStringList.Create;
 F.Read(FileID, 4);
 If FileID = 2 then
 begin
  F.Read(Cnt, 4);
  SetLength(PtrList, Cnt);
  F.Read(PtrList[0], Cnt * 8);
  SPos := F.Position;
  For I := 0 to Cnt - 1 do With PtrList[I] do
  begin
   List.Add('[' + IntToHex(ID,8) + ']');
   F.Position := SPos + Ptr * 2;
   WS := '';
   While True do
   begin
    F.Read(WC, 2);
    If WC = #0 then Break;
    If WC = #1 then
    begin
     F.Read(WC, 2);
     WS := WS + '<c=' + IntToStr(Word(WC)) + '>';
    end Else
    If WC = #3 then
    begin
     F.Read(WC, 2);
     WS := WS + '<b=' + IntToStr(Word(WC)) + '>';
    end Else
    If WC = #4 then
    begin
     F.Read(WC, 2);
     WS := WS + '<w=' + IntToStr(Word(WC))+'>';
    end Else
    If WC = #2 then
    begin
     //F.Read(WC, 2);
     WS := WS + '<p>' + WC;
    end Else
     WS := WS + WC;
   end;
   List.Add(WS);
   List.Add('');
  end;
 end;
 List.SaveToFile(ParamStr(2));
 List.Free;
 F.Free;
 WriteLn('Done ;)');
end.
