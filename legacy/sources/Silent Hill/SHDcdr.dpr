program SHDcdr;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  PtrSrch,
  Windows,
  SHDec;

// $47800 $292C0*4
// $EC800 400*4

var F: File; Buf: Pointer;
begin
  WriteLn('Silent Hill Data Decryptor/Encryptor by HoRRoR <ho-rr-or@mail.ru');
  WriteLn('http://consolgames.jino-net.ru/');
  If ParamCount<1 Then Exit;
  If not FileExists(ParamStr(1)) Then
  begin
    WriteLn('File "'+ParamStr(1)+'" not found!');
    Exit;
  end;

  AssignFile(F,ParamStr(1));
  Reset(F,1);
  GetMem(Buf,FileSize(F));
  BlockRead(F, Buf^,FileSize(F));
  SHDecrypt(Buf,FileSize(F));
  Seek(F,0);
  BlockWrite(F,Buf^,FileSize(F));
  FreeMem(Buf);
  CloseFile(F);


  {AssignFile(F,'SH1\M2.BIN');
  Reset(F,1);
  Seek(F,0*$47800);
  GetMem(Buf,$292C0*4);
  BlockRead(F, Buf^,$292C0*4);
  CloseFile(F);
  SHDecrypt(Buf,$292C0*4);
  //SHDecrypt(Buf,$292C0*4);
  AssignFile(F,'SH1\M3.BIN');
  Rewrite(F,1);
  Seek(F,0);
  BlockWrite(F,Buf^,$292C0*4);
  FreeMem(Buf);
  CloseFile(F);}

end.
