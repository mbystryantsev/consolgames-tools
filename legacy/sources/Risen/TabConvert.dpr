program TabConvert;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  TabConv, Classes,
  TableText in '..\FFText\TableText.pas';

Procedure PrintUsage;
begin
  WriteLn('Risen text convertor by HoRRoR');
  WriteLn('http://consolgames.ru/');
  WriteLn('Usage:');
  WriteLn('  -e <TableFile> <TextFile>');
  WriteLn('  -b <TextFile> <TableFile>'); 
end;

var
  Stream: TMemoryStream;
  Text: TGameTextSet;
  Convert: Integer = 0;
  S, Src, Dest: String;
  n: Integer = 1;
  Unicode: Boolean;
const
  TOTEXT = 1;
  TOTABLE = 2;

Procedure Error(const S: string; Level: TErrorType = etError);
const
  cType: Array[TErrorType] of String = ('', '[hint] ', '[WARNING] ', '***ERROR: ');
begin
  WriteLn(cType[Level], S);
end;

begin

  Unicode := False;//True;
  If ParamStr(n) = '-a' Then
  begin
    Inc(n);
    Unicode := False;
  end else
  If ParamStr(n) = '-u' Then
  begin              
    Inc(n);
    Unicode := True;
  end;

  S := ParamStr(n);
  If S = '-e' Then
    Convert := TOTEXT
  else If S = '-d' Then
    Convert := TOTABLE
  else
    Dec(n);
  Inc(n);
  Src := ParamStr(n);
  Dest := ParamStr(n + 1);
  If Convert = 0 Then
  begin
    If LowerCase(ExtractFileExt(Src)) = '.tab' Then
    begin
      Convert := TOTEXT;
      If Dest = '' Then
        Dest := ChangeFileExt(Src, '.txt');
    end
    else If LowerCase(ExtractFileExt(Src)) = '.txt' Then
    begin
      Convert := TOTABLE;
      If Dest = '' Then
        Dest := ChangeFileExt(Src, '.tab');
    end
    else
    begin
      PrintUsage;
      Exit;
    end;
  end;
            
  Stream := TMemoryStream.Create;
  Text := TGameTextSet.Create(@Error);
  Text.DelCarrets := False;
  Case Convert of
    TOTEXT:
    begin
      Stream.LoadFromFile(Src); 
      ExtractText(Stream, Text);
      Text.SaveTextToFile(Dest);
    end;
    TOTABLE:
    begin
      Text.LoadTextFromFile(Src);
      BuildText(Stream, Text, Unicode);
      Stream.SaveToFile(Dest);
    end;
  end;
  Stream.Free;
  Text.Free;
  WriteLn('Done!');

end.
