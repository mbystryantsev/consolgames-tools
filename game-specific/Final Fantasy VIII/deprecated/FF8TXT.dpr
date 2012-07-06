program FF8TXT;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  FF8_Txt,
  TableText in '..\FFText\TableText.pas';


Function Progress(Cur, Max: Integer; S: String): Boolean;
begin
  Result := False;
  If (Cur = -1) and (Max = -1) Then
    WriteLn(S)
  else If (Max = -1) Then
    WriteLn(Format('[%d] %s', [Cur, S]))
  else
    WriteLn(Format('[%d/%d] %s', [Cur, Max, S]));
end;

var
  n: Integer;
  OneFile:  Boolean = False;
  Build:    Boolean = False;
  Optimize: Boolean = False;
  Param: String;
begin

 For n := 2 to ParamCount do
  begin
    Param := ParamStr(n);
    If (Param[1] = '-') and (Length(Param) > 1) Then
    begin
      Case Param[2] of
        '1': OneFile := True;
        'o': Optimize := True;
        'b': Build := True;
      end;
    end else
      Break;
  end;

  Param := ParamStr(1);
  If Param = '-kernel' Then
  begin
    // -kernel Tables\Table_En_DTE.tbl extract_test\kernel.bin kernel.txt
    // -kernel -b Tables\Table_En_DTE.tbl extract_test\kernel.bin kernel.txt kernel_test.bin
    If Build Then
      FF8_BuildKernelText(ParamStr(n), ParamStr(n + 1), ParamStr(n + 2), ParamStr(n + 3))
    else
      FF8_ExtractKernelText(ParamStr(n), ParamStr(n + 1), ParamStr(n + 2));
  end else
  If Param = '-field' Then
  begin
    // FF8TXT.exe -e [-o] <TableFile> <InDir> <OutPath>
    // -e -o Tables\Table_En.tbl extract_test\Field\mapdata Test.txt
    FF8_ExtractFieldText(ParamStr(n), ParamStr(n+1), ParamStr(n+2), OneFile, Optimize, @Progress);
    WriteLn('Done!');
  end else
  If Param = '-battle' Then
  begin
    //  -battle Tables\Table_En.tbl extract_test\battle\ battle.txt
    FF8_ExtractBattle(ParamStr(n), ParamStr(n+1), ParamStr(n+2), @Progress);
    WriteLn('Done!');
  end;
  ReadLn;
  { TODO -oUser -cConsole Main : Insert code here }
end.
