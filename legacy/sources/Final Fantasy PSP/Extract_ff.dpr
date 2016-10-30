\program Extract_ff;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows, StrUtils, Packer;

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
List: TextFile;
F, FW: File; {FT: TextFile;} Buffer, FBuf: pointer;
Header: Array of THeader; AHeader: TAHeader;
H: ^THeader; n: Integer; S: DWord; Size: DWord;
UnpBuf: Pointer; LstFl: String;
begin
  If ParamStr(1)='' then Exit;
  LstFl:=LeftStr(ParamStr(1), Length(ParamStr(1))-4);
  If not DirectoryExists(LstFl) then   CreateDir(LeftStr(ParamStr(1), Length(ParamStr(1))-4));
  { TODO -oUser -cConsole Main : Insert code here }
  AssignFile(F, ParamStr(1) {'ff1psp.dpk'});
  Reset(F,1);
  BlockRead(F,S, 4);
  If S=$36317057 then
  begin
    Seek(F,4);
    BlockRead(F, Size, 4);
    Seek(F,0);
    GetMem(UnpBuf, FileSize(F));
    BlockRead(F, UnpBuf^, FileSize(F));
    CloseFile(F);
    UnPack(UnpBuf);
    AssignFile(F, '~ff1extr.tmp');
    Rewrite(F,1);
    BlockWrite(F, UnpBuf^, Size);
    FreeMem(UnpBuf);
    Reset(F,1);
  end;
  Seek(F,0);
  BlockRead(F,AHeader, 16);
  If AHeader.Size<>FileSize(F) then
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
  LstFl:=LeftStr(ParamStr(1), Length(ParamStr(1))-4)+'\'+LeftStr(ExtractFileName(ParamStr(1)), Length(ParamStr(1))-4)+'.LST';
  AssignFile(List, LeftStr(ParamStr(1), Length(ParamStr(1))-4)+'\'+LeftStr(ExtractFileName(ParamStr(1)), Length(ParamStr(1))-4)+'.LST');
  Rewrite(List);
  For n:=0 to AHeader.FileCount-1 do
  begin
    Header[n]:=H^;
    inc(H);

    AssignFile(FW, LeftStr(ParamStr(1), Length(ParamStr(1))-4)+'\'+GetName(Header[n].Name));
    Rewrite(FW,1);
    GetMem(FBuf, Header[n].Size);
    Seek(F, Header[n].Offset);
    BlockRead(F, FBuf^, Header[n].Size);
    BlockWrite(FW,FBuf^,Header[n].Size);
    FreeMem(FBuf);

    WriteLn(GetName(Header[n].Name)+' Sz:'+IntToStr(Header[n].Size));
    WriteLn(List, GetName(Header[n].Name));
   // readln;
  end;
  CloseFile(F);
  CloseFile(FW);
  //--
  AssignFile(FW, LeftStr(ParamStr(1), Length(ParamStr(1))-4)+'\'+LeftStr(ExtractFileName(ParamStr(1)), Length(ParamStr(1))-4)+'.DATA');
  Rewrite(FW,1);
  //BlockWrite(FW,'FFPSPDAT',8);
  BlockWrite(FW,'FFPSPDT2',8);
  Seek(FW,8);
  BlockWrite(FW, AHeader.FileCount, 4);
  Seek(FW,12);
  If S=$36317057 then BlockWrite(FW,S,4) else BlockWrite(FW,'NONE',4);
  For n:=0 to Length(Header)-1 do
  begin
    Seek(FW,16+32*n);
    BlockWrite(FW,Header[n],24);
    Seek(FW,16+28+32*n);
    If Header[n].Size<> Header[n].FullSize then
    begin
      BlockWrite(FW,'Wp16',4); end
    else begin
      BlockWrite(FW,'NONE',4);
    end;
  end;
  CloseFile(FW);
  //--
  If FileExists('~ff1extr.tmp') and (S=$36317057) then
  begin
    DeleteFile('~ff1extr.tmp');
  end;
  CloseFile(List);
  //FreeMem(Buffer);

end.
 