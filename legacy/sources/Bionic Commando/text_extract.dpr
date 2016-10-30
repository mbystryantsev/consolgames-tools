program text_extract;

{$APPTYPE CONSOLE}

uses
  SysUtils, classes;

Type
  DWord = LongWord;
  TTextInfo = Record
    Offset:     DWord;
    Offset2:    DWord;
    OffsetCmn:  DWord;
    Size:       Integer;
    Name:       String;
  end;


Function ExtractText(P: Pointer; Size: Integer): String;
var C: PChar;
begin
  Result := '';
  C := P;
  While Size > 0 do
  begin
    If C^ = #0 Then
      Result := Result + #13#10
    else
      Result := Result + C^;
    Inc(C);
    Dec(Size);
  end;
end;



const
  Texts: Array[0..4] of TTextInfo = (
  (Offset: $1179040; Offset2: $1185C06; OffsetCmn: $28EF1; Size: $B50A; Name: 'atmospheric_text.txt'),
  (Offset: $11927CC; Offset2: $119617F; OffsetCmn: $35AB7; Size: $2757; Name: 'cutscene_voice.txt'),
  (Offset: $119AE36; Offset2: $119ECD9; OffsetCmn: $39DEC; Size: $2F47; Name: 'error_messages_etc.txt'),
  (Offset: $11A2B7C; Offset2: $11B0518; OffsetCmn: $3DC8F; Size: $A4A0; Name: 'in_game_voice.txt'),
  (Offset: $11BDF00; Offset2: $11D0DD9; OffsetCmn: $4B651; Size: $ADFD; Name: 'system_text.txt')
  );


var
  Stream: TFileStream;
  List:   TStringList;
  n: Integer;
  Buf: Pointer; Dir: String;
begin
  If ParamCount < 1 Then Exit;
  If Dir = '' Then
    Dir := '.\';
  If Dir[Length(Dir)] <> '\' Then Dir := Dir + '\';
  Stream := TFileStream.Create(ParamStr(1), fmOpenRead);

  GetMem(Buf, 1024 * 1024);
  List := TStringList.Create;
  For n := 0 To High(Texts) do
  begin
    Stream.Seek(Texts[n].Offset, 0);
    Stream.Read(Buf^, Texts[n].Size);
    List.Text := ExtractText(Buf, Texts[n].Size);
    List.SaveToFile(Dir + Texts[n].Name);

  end;
  List.Free;
  FreeMem(Buf);
  Stream.Free;
  WriteLn('Done!');


  { TODO -oUser -cConsole Main : Insert code here }
end.
 