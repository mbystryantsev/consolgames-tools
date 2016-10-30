program SHExtract;

{$APPTYPE CONSOLE}

uses
  SysUtils, SHPacker, Windows, Classes;

Type
  TFileHeader = Packed Record
  NamePos: DWord;
  FilePos: DWord;
  FileSize: DWord;
  FullSize: DWord;
end;

Type
  THeader = Packed Record
  Sign: Array[0..3] Of char;
  Count: DWord;
  HeadSize: DWord;
  NamesPos: DWord;
  NamesSize: DWord;
  FHead: Array of TFileHeader;
end;

var F, FW: File; Buf: Pointer; B: ^Byte; W: ^Word; List: TStringList;
Head: THeader; n: Integer; H: ^TFileHeader; Name: Array of String;
Size: Integer;
begin
  WriteLn('Silen Hill Origins ARC extractor by HoRRoR <ho-rr-or@mail.ru>');
  If (ParamStr(1)='') or (ParamStr(2)='') then
  begin
    WriteLn('Usage: <in file> <out dir>');
    Exit;
  end;
  If not FileExists(ParamStr(1)) then
  begin
    WriteLn('File not found!');
    Exit;
  end;
  If not DirectoryExists(ParamStr(2)) then
  begin
    If not CreateDir(ParamStr(2)) Then
    begin
      WriteLn('Cant create dir!');
      Exit;
    end;
  end;

  FileMode:=fmOpenRead;
  AssignFile(F, ParamStr(1));
  Reset(F,1);
  BlockRead(F, Head, 20);
  If Head.Sign[0]+Head.Sign[1]+Head.Sign[2]+Head.Sign[3]<>'A2.0' then
  WriteLn('Warning! Header incorrect!');
  SetLength(Head.FHead, Head.Count);
  GetMem(Buf, Head.HeadSize-20);
  Seek(F,20);
  BlockRead(F, Buf^, Head.HeadSize-20);
  H:=Addr(Buf^);
  For n:=0 to Head.Count-1 do
  begin
    Head.FHead[n]:=H^;
    Inc(H);
  end;
  FreeMem(Buf);
  GetMem(Buf, Head.NamesSize);
  Seek(F, Head.NamesPos);
  BlockRead(F, Buf^, Head.NamesSize);
  SetLength(Name, Head.Count);

  For n:=0 to Head.Count-1 do
  begin
    B:=Addr(Buf^);
    Inc(B, Head.FHead[n].NamePos);
    Name[n]:='';
    While B^>0 do
    begin
      Name[n]:=Name[n]+Char(B^);
      Inc(B);
    end;
  end;
  FreeMem(Buf);
  List:=TStringList.Create;

  FileMode:=fmOpenWrite;
  For n:=0 to Head.Count-1 do
  begin
    WriteLn(Format('[%d/%d] %s',[n+1, Head.Count, Name[n]]));
    If Head.FHead[n].FullSize>0 then List.Add(Name[n]+' p')
    else List.Add(Name[n]+' n');
    Seek(F,Head.FHead[n].FilePos);
    GetMem(Buf, Head.FHead[n].FileSize);
    BlockRead(F, Buf^, Head.FHead[n].FileSize);
    If Head.FHead[n].FullSize>0 then Size:=UnPack(Buf,Head.FHead[n].FileSize)
    else Size:=Head.FHead[n].FileSize;
    AssignFile(FW, ParamStr(2)+'\'+Name[n]);
    Rewrite(FW,1);
    BlockWrite(FW,Buf^, Size);
    CloseFile(FW);
    FreeMem(Buf);
  end;
  List.SaveToFile(ParamStr(2)+'\'+'LIST.LST');
  CloseFile(F);
  List.Free;
end.
