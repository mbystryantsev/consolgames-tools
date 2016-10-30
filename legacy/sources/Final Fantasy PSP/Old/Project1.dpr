program Project1;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows, StrUtils;

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
F, FW: File; {FT: TextFile;} Buffer, FBuf: pointer;
Header: Array of THeader; AHeader: TAHeader;
H: ^THeader; n: Integer;
begin
  { TODO -oUser -cConsole Main : Insert code here }
  AssignFile(F, 'ff1psp.dpk');
  Reset(F,1);
  BlockRead(F,AHeader, 16);
  SetLength(Header,AHeader.FileCount-1);
  GetMem(Buffer,AHeader.FileCount*$24);
  Seek(F, $10);
  BlockRead(F, Buffer^, AHeader.FileCount*$24);
  H:=Addr(Buffer^);
  For n:=0 to AHeader.FileCount-1 do
  begin
    Header[n]:=H^;
    inc(H);

    AssignFile(FW, 'Extract\'+GetName(Header[n].Name));
    Rewrite(FW,1);
    GetMem(FBuf, Header[n].Size);
    Seek(F, Header[n].Offset);
    BlockRead(F, FBuf^, Header[n].Size);
    BlockWrite(FW,FBuf^,Header[n].Size);
    FreeMem(FBuf);

    WriteLn(GetName(Header[n].Name)+' Sz:'+IntToStr(Header[n].Size));
   // readln;
  end;
  CloseFile(F);
  CloseFile(FW);
  FreeMem(Buffer);
 { For n:=0 to AHeader.FileCount-1 do
  begin
    AssignFile(FW, 'Extract\'+GetName(Header[n].Name));
    Rewrite(FW,1);
    FreeMem(Buffer);
    GetMem(Buffer, Header[n].Size);
    Seek(F, Header[n].Offset);
    BlockRead(F, Buffer^, Header[n].Size);
    BlockWrite(FW,Buffer^,Header[n].Size);
  end;  }



end.
 