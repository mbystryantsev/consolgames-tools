program FontConv;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  DR2Font in 'DR2Font.pas',
  AtlasBuilder in 'AtlasBuilder.pas';

Procedure PrintUsage;
begin
  WriteLn('Dead Rising 2 Font Convertor by HoRRoR');
  WriteLn('http://consolgames.ru/');
  WriteLn('Usage:');
  WriteLn('  -x <Width> <Height> <In_PC_Font> <Out_XBOX360_Font>');
end;

var Font: TDR2Font; i, W, H, Code: Integer; Mirror, ForceAlt: Boolean;
begin
  If ParamCount < 3 Then
  begin
    PrintUsage();
    Exit;
  end;
  If ParamStr(1) = '-x' Then
  begin
    Mirror := False;
    ForceAlt := False;
    For i := 6 To ParamCount do
    begin
      If ParamStr(i) = '-m' Then
        Mirror := True
      else
      If ParamStr(i) = '-f' Then
        ForceAlt := True;
    end;

    //!!
    //ForceAlt := False;

    Font := TDR2Font.Create;
    Val(ParamStr(2), W, Code);
    Val(ParamStr(3), H, Code);
    Font.LoadFont(ParamStr(4));
    If Font.SaveForXBOX360(ParamStr(5), W, H, Mirror, ForceAlt) Then
      WriteLn('Done!')
    else
      WriteLn(ExtractFileName(ParamStr(4)), ': Failed!');
    Font.Free;
  end;
end.
