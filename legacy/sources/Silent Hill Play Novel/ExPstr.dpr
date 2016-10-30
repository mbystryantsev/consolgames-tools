program ExPstr;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows;

Function LoadFile(Name: String; var Pos: Pointer): Integer;
var F: File;
begin
  Result:=-1;
  If not FileExists(Name) Then Exit;
  AssignFile(F,Name);
  Reset(F,1);
  Result:=FileSize(F);
  //If Assigned(Pos) Then FreeMem(Pos);
  GetMem(Pos, Result);
  BlockRead(F, Pos^, Result);
  CloseFile(F);
end;

Procedure WriteFile(InF,WF: String; Pos: Integer);
var Size: Integer; Buf: Pointer; F: File;
begin
  AssignFile(F,InF);
  Reset(F,1);
  Size:=LoadFile(WF,Buf);
  Seek(F,Pos);
  BlockWrite(F,Buf^,Size);
  FreeMem(Buf);
  CloseFile(F);
end;

var Size: Integer; Buf: Pointer; F: File;
Bl: DWord = $F827F3FB; Bl2: DWord = $F9E7F3FD;
begin
  If not FileExists('..\..\Play Novel.gba') Then
  begin
    WriteLn('File not found!');
    beep(64,512);
    Exit;
  end;
  AssignFile(F,'..\..\Play Novel.gba');
  Reset(F,1);
  WriteFile('..\..\Play Novel.gba','code.GBA',$402080);
  WriteFile('..\..\Play Novel.gba','code_s.GBA',$402200);
  WriteFile('..\..\Play Novel.gba','Font.dat',$796300);
  Seek(F, $702E);
  BlockWrite(F,Bl,4);
  Seek(F,$4E2E);
  BlockWrite(F,Bl2,4);
  //FreeMem(Buf);
  CloseFile(F);

  { TODO -oUser -cConsole Main : Insert code here }
end.
