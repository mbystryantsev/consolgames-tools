program FF8IMG;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  FF8_Img in 'FF8_Img.pas',
  ecc in '..\ISO\ecc.pas',
  edc in '..\ISO\edc.pas';

Function Progress(const Cur, Max: Integer; const S: String): Boolean;
begin
  Result := True;
  If Cur <> -1 Then
    WriteLn(Format('[%d/%d] %s', [Cur+1, Max, S]))
  else
    WriteLn(S);
end;

Procedure PrintUsage;
begin
  WriteLn('Usage: FF8IMG.EXE <action> [keys] <InFile(s)/InDir> <OutDir>');
  WriteLn('Actions:');
  WriteLn('  -img - extract files from disc image or IMG-archive');
  WriteLn('  -res - extract resources from disc image or IMG-archive.');
  WriteLn('         As an input folder you must specify a folder with main.ovl (root dir)');
  WriteLn('Keys:');
  WriteLn('  -f<Folder> - set the input folder for InFile(s) and SLUS');
  WriteLn('  -s<SLUS>   - path to any SLUS_???.?? (PS-EXE) file from the disc.');
  WriteLn('               If defined, files from menu\mngrp.bin will be extracted.');
  //WriteLn('');
  WriteLn('As input files for the "-img" action, you can specify FF8DISC?.IMG');
  WriteLn('files or disc images (binary, not cue).');

  WriteLn('You must enter the four names as four parameters, or a single name with');
  WriteLn('a ''?'', which is replaced by disk number.');
  WriteLn('Here are two equivalent options:');
  WriteLn('FF8IMG.exe -img -fC:\ISO FF8CD1.bin FF8CD2.bin FF8CD3.bin FF8CD4.bin C:\outdir');
  WriteLn('FF8IMG.exe -img -fC:\ISO FF8CD?.bin C:\outdir');
end;

var
  F: File;
  n, m, Num: Integer;
  P: String;
  InDir, OutDir, SLUSName: String;
  A: Array of String;
begin     
  WriteLn('Final Fantasy VIII (PSX, NTSC) Files Extractor v0.1 by HoRRoR');
  WriteLn('ho-rr-or@mail.ru, horror.cg@gmail.com');
  WriteLn('http://consolgames.ru/');
  For Num := 2 To ParamCount do
  begin
    P := ParamStr(Num);
    If (P <> '') and (P[1] = '-') Then
    begin
      Case P[2] of
        'f','F': InDir := PChar(@P[3]);
        's','S': SLUSName := PChar(@P[3]);
        //'':
      end;
    end else
      break;
  end;

  SetLength(A, 4);
  If ParamStr(1) = '-img' Then
  begin
    WriteLn('Extracting...');
    A[0] := ParamStr(Num);
    For n := 0 To Length(A[0]) do
      If A[0, n] = '?' Then
        break;
    If n <= Length(A[0]) Then
    begin
      For m := 1 to 3 do
        A[m]   := A[0];
      For m := 1 to 4 do
        A[m - 1, n] := Char($30 + m);
      Inc(Num);
    end else
    begin
      For n := 1 to 3 do
        A[n] := ParamStr(Num + n);
      Inc(Num, 4);
    end;     
    If InDir <> '' Then
    begin
      If InDir[Length(InDir)] <> '\' Then
        InDir := InDir + '\';
      For n := 0 To 3 do
        A[n] := InDir + A[n];
    end;
    OutDir := ParamStr(Num);  
    IMG_ExtractAll(A, OutDir, SLUSName, @Progress);
    WriteLn('Done!');
  end else
  If ParamStr(1) = '-res' Then
  begin
    WriteLn('Resources extracting...');
    ExtractResources(ParamStr(Num), ParamStr(Num + 1), @Progress);
    WriteLn('Done!');
  end else
    PrintUsage;
  //WriteLn(A[0], ' ', A[1], ' ', A[2], ' ', A[3], ' ', OutDir);
  //ReadLn;
  Exit;

//    ExtractKernel('extract_test\kernel.bin', 'extract_test\kernel\');
//    Exit;

//  ExtractGrp('extract_test\menu\mngrp.bin', 'test\SLUS_008.92', 'extract_test\menu\'{, @Progress});
//  BuildGrp('extract_test\menu\grptest.grp', 'test\SLUS', 'extract_test\menu\'{, @Progress});
//  ExtractGrp('extract_test\menu\grptest.grp', 'test\SLUS', 'extract_test\grp\', @Progress);
//Exit;

  //CompareBattle('FF8DISC3.IMG', 'FF8DISC4.IMG');
  //DecompressFiles('extract_test\Battle', 'extract_test\Battle2\');
  //Exit;

  //ExtractResources('extract_test', 'extract_test', @Progress);
  //Exit;

  {
  AssignFile(F, 'imgtest');
  Rewrite(F, 1);
  IMG_WriteFile(F, 0, 'cd1.header', True);
  CloseFile(F);
  Exit;
  }
  If ParamCount < 2 Then Exit;
  //IMG_ExtractAll(ParamStr(1), ParamStr(2), ''{ParamStr(3)}, @Progress);
  //IMG_Build('bld_test\FF8DISC1.BIN', 'extract_test\', 1, @Progress, True, 'bld_test\SLUS_008.92');
  WriteLn('Done!');
  ReadLn;
  { TODO -oUser -cConsole Main : Insert code here }
end.
