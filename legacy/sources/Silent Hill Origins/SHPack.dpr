program SHPack;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  SH0_ARC in 'SH0_ARC.pas';

Procedure CreateError(S: String);
begin
  WriteLn(Format('***ERROR: %s',[S]));
end;

Procedure Progress(Cur, Max: Integer; S: String);
begin
  WriteLn(Format('[%d/%d] %s', [Cur + 1, Max, S]));
end;

var Folders, S, SS, FromDir: String; n,m, I: Integer;
SubFolders:  Boolean = False; Patch:     Boolean = False;
Compression: Boolean = False; SavePaths: Boolean = False;
ShatteredMemories: Boolean = False;
Align: Integer = 2048; Code: Integer;
InFile, OutFile: String;
begin
// SHPack [-patch] LIST.LST SH.ARC [InFolder1, InFolder1, ..., InFolderN]
  //WriteLn(IntToHex(CalcHash(PChar('Boot.Arc')), 8));
  WriteLn('Silent Hill Origins ARC builder v2.0 by HoRRoR <ho-rr-or@mail.ru>');
  WriteLn('http://consolgames.ru/');
  If ParamCount < 2 Then
  begin
    WriteLn('Usage:');
    WriteLn('SHPack [-patch] [Keys] <LST/FOLDER> <ARC> [InDir1, InDir1, ..., InDirN]');
    WriteLn('Keys:');
    WriteLn('  -p:  Save paths in file names');
    WriteLn('  -s:  Include subfolders');
    WriteLn('  -c:  Use compression');
    WriteLn('  -aN: Set align (default: 2048)');
    WriteLn('  -sm: Shattered Memories');
    Exit;
  end;
  Patch       := ParamStr(1)='-patch';
  For i := 1 To ParamCount do
  begin
    S := ParamStr(i);
    If (S[1] = '-') Then
    begin
      Case S[2] of
        'p': SavePaths   := True;
        's':
        begin
          If S = '-s' Then
            SubFolders  := True
          else If S = '-sm' Then
            ShatteredMemories := True;
        end;
        'c': Compression := True;
        'a':
        begin
          SetLength(SS, Length(S) - 2);
          Move(S[3], SS[1], Length(SS));
          Val(SS, Align, Code);
        end;
      end;
    end else
      break;
  end;
  InFile := ParamStr(i);
  OutFile := ParamStr(i + 1);
  //I       := Byte(SavePaths) + Byte(SubFolders) + Byte(Compression);
  Folders := '';
  FromDir := '';
  //If Patch or SavePaths Then m:=4 else m:=3;
  For n := i + 2 To ParamCount do
  begin
    Folders := Folders + ParamStr(n);
    If n < ParamCount Then Folders := Folders + ';';
  end;
  If Patch Then
  begin
    If ARC_Patch(InFile, OutFile, Folders, @Progress, @CreateError)=0 Then
      WriteLn('Archive successfully patched ;)')
    else
      WriteLn('Archive patched with errors :(');
  end else
  begin
    If DirectoryExists(InFile) Then
      FromDir := InFile;
    If FromDir <> '' Then
    begin
      If ARC_Build(FromDir, SubFolders, OutFile, Compression, Align, ShatteredMemories, SavePaths,
        @Progress, @CreateError) = 0 Then
          WriteLn('Archive successfully builded ;)')
        else
          WriteLn('Archive builded with errors :(');
    end else
    begin
      If ARC_Build(InFile, OutFile, Folders, Align, ShatteredMemories, SavePaths,
        @Progress, @CreateError)=0 Then
          WriteLn('Archive successfully builded ;)')
        else
          WriteLn('Archive builded with errors :(');
    end;
  end;
end.
