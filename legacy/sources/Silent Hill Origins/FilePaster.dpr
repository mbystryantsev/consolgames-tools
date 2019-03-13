program FilePaster;

{$APPTYPE CONSOLE}

uses
  SysUtils;

var MF,F: File; Code, Offset, SizeOffset, Size: Integer;
Buf: Pointer;
begin
// BaseFile InFile Offset SizeOffset
  If ParamCount <> 4 Then Exit;
  If not FileExists(ParamStr(1)) Then Exit;
  If not FileExists(ParamStr(2)) Then Exit;
  AssignFile(MF, ParamStr(1));
  AssignFile(F , ParamStr(2));
  Reset(MF,1);
  Reset(F,1);
  Val(ParamStr(3), Offset,     Code);
  Val(ParamStr(4), SizeOffset, Code);
  Size := FileSize(F);

  GetMem(Buf, Size);
  BlockRead(F, Buf^, Size);
  CloseFile(F);
  
  Seek(MF, Offset);
  BlockWrite(MF, Buf^, Size);
  Seek(MF, SizeOffset);
  BlockWrite(MF, Size, 4);

  CloseFile(MF);
  FreeMem(Buf);

  WriteLn('Data successfully writed!');
end.
