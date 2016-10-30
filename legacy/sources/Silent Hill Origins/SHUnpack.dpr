program SHUnpack;

{$APPTYPE CONSOLE}

uses
  SysUtils, SHPacker;
var F: File; InFile, OutFile: String; Buf: Pointer; Compress: Boolean;
Size: Integer; Hdr: Word; PackHeader: Word=$DA78; W:^Word;
begin
  If ParamStr(1)='' then
  begin
    WriteLn('Usage: shunpack <option> <input file> <output file>');
    WriteLn('Options: -c - comress, -d - decompress');
    Exit;
  end;
  If (ParamStr(1)<>'-d') and (ParamStr(1)<>'-c') then
  begin
    WriteLn('Bad option!');
    Exit;
  end;
  If not FileExists(ParamStr(2)) then
  begin
    WriteLn('Input file not found!');
    Exit;
  end;
  AssignFile(F, ParamStr(2));
  Reset(F,1);
  Size:=FileSize(F);
  If ParamStr(1)='-d' then
  begin
    BlockRead(F, Hdr, 2);
    If PackHeader<>Hdr then
    begin
      WriteLn('Warning: Invalid file header!');
      //Exit;
    end;
    //Seek(F,2);
    //Inc(Size,-2);
  end;
  Seek(F,0);
  GetMem(Buf, Size);
  BlockRead(F, Buf^, Size);
  //W:=Addr(Buf^);
  //W^:=$9C78;
  If ParamStr(1)='-d' then
  begin
    Size:=UnPack(Buf, FileSize(F){-2});
    CloseFile(F);
    AssignFile(F, ParamStr(3));
    Rewrite(F,1);
    BlockWrite(F,Buf^, Size);
    WriteLn('Decompressed. Output file size ' + IntToStr(Size));
  end else
  begin
    Size:=Pack(Buf, FileSize(F));
    CloseFile(F);
    AssignFile(F, ParamStr(3));
    Rewrite(F,1);
    W:=Addr(Buf^);
    W^:=PackHeader;
    BlockWrite(F,Buf^, Size);

    WriteLn('Compressed. Output file size ' + IntToStr(Size));
  end;
  CloseFile(F);
  { TODO -oUser -cConsole Main : Insert code here }
end.
