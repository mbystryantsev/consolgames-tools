program Unpack_ff;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows,
  Packer;



var UnpBuf: Pointer;  F: File; S, Size: DWord;

begin
  If ParamStr(1)='' then Exit;
    AssignFile(F, ParamStr(1) {'ff1psp.dpk'});
    Reset(F,1);
    BlockRead(F,S, 4);
    If S<>$36317057 then
    begin
      CloseFile(F);
      Exit;
    end;

    Seek(F,4);
    BlockRead(F, Size, 4);
    Seek(F,0);

    GetMem(UnpBuf, FileSize(F));
    BlockRead(F, UnpBuf^, FileSize(F));
    CloseFile(F);
    UnPack(UnpBuf);

    If ParamStr(2)='' Then AssignFile(F, ParamStr(1)+'.NPK')
    else AssignFile(F, ParamStr(2));
    Rewrite(F,1);
    BlockWrite(F, UnpBuf^, Size);
    FreeMem(UnpBuf);
    Reset(F,1);


  { TODO -oUser -cConsole Main : Insert code here }
end.
 