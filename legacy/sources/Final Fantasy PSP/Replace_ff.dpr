program Replace_ff;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows,
  StrUtils;

Type
  THeader = Record
  Name: Array[0..21] of byte;
  Data: Word;
  Offset: DWord;
  Size: DWord;
  FullSize: DWord;
end;
Type
  TAHeader = Record
  FileCount: DWord;
  Size: DWord;
  Blank1: DWord;
  Blank2: DWord;
end;

Procedure Round(var a: DWord);
begin
  Inc(a,15);
  a:=(a div 16) * 16;
end;

Function GetName(Bytes: Array of byte): String;
var n: integer;
begin
  Result:='';
  For n:=0 to Length(Bytes)-1 do
  begin
    If Bytes[n]=0 then begin Exit; end else Result:=Result+Char(Bytes[n]);
  end;
end;


var
List: TextFile;    NM: String;
F, FW: File; {FT: TextFile;} Buf, Buffer: pointer;
Header: Array of THeader; AHeader: TAHeader;
H: ^THeader; n: Integer; S: DWord; FSize, Size: DWord;
UnpBuf: Pointer;
begin
  If ParamStr(1)='' then Exit;
  AssignFile(F, ParamStr(1));
  Reset(F,1);

  Seek(F,0);
  BlockRead(F,AHeader, 16);
  FSize:=FileSize(F);
  If AHeader.Size<>FSize then
  begin
    CloseFile(F);
    //FreeMem(Buffer);
    Exit;
  end;
  SetLength(Header,AHeader.FileCount);
  GetMem(Buffer,AHeader.FileCount*$24);
  Seek(F, $10);
  BlockRead(F, Buffer^, AHeader.FileCount*$24);
  H:=Addr(Buffer^);
  For n:=0 to AHeader.FileCount-1 do
  begin
    Header[n]:=H^;
    inc(H);
  end;

  If ParamStr(3)<>'' then begin NM:= ParamStr(3); end else NM:=ExtractFileName(ParamStr(2));
  For n:=0 to AHeader.FileCount-1 do
  begin
    WriteLn(GetName(Header[n].Name)+'  '+NM);
    If GetName(Header[n].Name)=NM then
    begin
      AssignFile(FW, ParamStr(2));
      Reset(FW,1);
      Size:=Header[n].Size;
      Round(Size);
      If FileSize(FW)>Size then
      begin
        Seek(F, FileSize(F));
      end else
      begin
        Seek(F, Header[n].Offset);
      end;
      Header[n].Size:=FileSize(FW);
      Header[n].FullSize:=FileSize(FW);
      GetMem(Buf, FileSize(FW));
      BlockRead(FW, Buf^, FileSize(FW));
      BlockWrite(F, Buf^, FileSize(FW));
      FreeMem(Buf);
      Seek(F, n*$24+16);
      BlockWrite(F, Header[n], $24);
      break;
    end;
  end;
  //FreeMem(Buffer);
  AHeader.Size:=FileSize(F);
  CloseFile(FW);
  Seek(F,0);
  BlockWrite(F, AHeader, 16);
  CloseFile(F);

end.

