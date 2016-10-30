program PSearch;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  Windows,
  PtrSrch in 'PtrSrch.pas';

var F: File; {I: DWord;} Buf: Pointer; List: TStringList;
InFile,OutFile: String;
SAdr1,SAdr2,TAdr1,TAdr2,PtrInterval,PtrDif,PtrStep,TextMultiple,PtrCount: Integer;
StopByte, PtrSize: Byte;
Motorola: Boolean;
n: Integer;
ErrorCount, FCount, FUCount: Integer;
begin

  // "Scooby\Scooby Doo Mystery.bin" "Scooby\PtrList.txt" 0 $14199D $145EB5 $120000 $180000 4 0 $14199C 1 0 0 -m
  // "Van Helsing\1478 - Van Helsing (U).gba" Van Helsing\VHPtrs.txt 0 $18290C $190EEC $176A50 $18290C 4 0 $F8000000 4 0 4
  WriteLn('Pointer Searcher v0.1b by HoRRoR <ho-rr-or@mail.ru>');
  WriteLn('http://consolgames.jino-net.ru/');
  WriteLn('Usage: PSearch <InputFile> <OutputFile> <StopByte> <TextBegin> <TextEnd>');
  WriteLn('<SearchBegin> <SearchEnd> <PointerSize> <PointerInterval> <PointerDifference>');
  WriteLn('<PointerStep> <MaxPointerCount> <TextMultiple> [Keys]');
  WriteLn('Keys:');
  WriteLn('    -m     Motorola (SEGA)');

  //WriteLn(IntToStr(ParamCount));

  If ParamCount<13 Then
  begin
    WriteLn('Not enough actual parameters!');
    Exit;
  End;

  InFile:=ParamStr(1);
  OutFile:=ParamStr(2);
  StopByte:=ParToInt(ParamStr(3));
  TAdr1:=ParToInt(ParamStr(4));
  TAdr2:=ParToInt(ParamStr(5));
  SAdr1:=ParToInt(ParamStr(6));
  SAdr2:=ParToInt(ParamStr(7));
  PtrSize:=ParToInt(ParamStr(8));
  PtrInterval:=ParToInt(ParamStr(9));
  PtrDif:=ParToInt(ParamStr(10));
  PtrStep:=ParToInt(ParamStr(11));
  PtrCount:=ParToInt(ParamStr(12));
  TextMultiple:=ParToInt(ParamStr(13));

  For n:=14 to ParamCount do
  begin
    If ParamStr(n)='-m' then Motorola:=True;
  end;

  If Not FileExists(InFile) Then
  begin
    WriteLn(InFile+' not found!');
    Exit;
  end;
  If (TAdr1>TAdr2) or (SAdr1>SAdr2) or (PtrSize>4) or (PtrSize<1) then
  begin
    WriteLn('Error! Check parameters!');
    Exit;
  end;



  AssignFile(F, InFile);
  Reset(F,1);
  GetMem(Buf, FileSize(F));
  BlockRead(F, Buf^, FileSize(F));

  ErrorCount:=ExtractPtrs(List,StopByte,Buf,TAdr1,TAdr2,PtrCount,SAdr1,SAdr2,
  TextMultiple,PtrSize,PtrDif,PtrInterval,PtrStep,Motorola,FCount,FUCount);

  WriteLn(Format('Total: Founded: %d, uniques: %d, not founded: %d',[FCount,FUCount,ErrorCount]));

  //If Not List.SaveToFile(OutFile) Then WriteLn('Can'+#$27+'t save output file!);
  List.SaveToFile(OutFile);
  List.Free;

  {AssignFile(F, 'Van Helsing\1478 - Van Helsing (U).gba');
  Reset(F,1);
  GetMem(Buf, FileSize(F));
  BlockRead(F, Buf^, FileSize(F)); //17C2B4
  WriteLn(IntToStr(ExtractPtrs(List,$00,Buf,$18290C,$190EEC,0,$176A50,$18290C,4,4,$F8000000,0,4,False)));
  }  //WriteLn(IntToStr(ExtractPtrs(List,$00,Buf,$190008,$190008,0,$17C2B4,$18290C,4,4,$F8000000,0,0,False)));
    //ExtractPtrs(List,$00,Buf,$190008,$190008,0,$17C2B4,$18290C,4,4,$F8000000,0,False
  {List.SaveToFile('Van Helsing\Û.txt');
  List.Free;
  ReadLn;}
  //ReadLn;
end.
