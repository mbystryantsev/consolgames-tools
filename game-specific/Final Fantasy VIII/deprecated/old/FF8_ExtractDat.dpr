program FF8_ExtractDat;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  FF8,  Classes,
  TableText in '..\..\FFText\TableText.pas';

Function P(Cur, Max: Integer; S: String): Boolean;
begin
  Result := False;
  If Max <> -1 Then
    WriteLn(Format('[%d/%d] %s',[Cur, Max, S]))
  else
    WriteLn(Format('[%d] %s',[Cur, S]));
end;

Procedure FCreateError(S: String; Level: TErrorType = etError);
const cLevelStr: Array[TErrorType] of String = ('***LOG: ','***HINT: ','***WARNING: ','***ERROR: ');
begin
  WriteLn(cLevelStr[Level] + S);
end;

var InFolder,OutFolder, TextFile, OptFile, TableFile, Key: String; n: Integer; MText: TGameTextSet;
  List: TStringList; L: TFF8LBA; CD, r: Integer; S, Line: String;
begin

  FF8_LoadLBA('F:\_job\FF8\Dat\DAT.LIST', L);
  List := TStringList.Create;
  For CD := 1 to 4 do
  begin
    List.Add(Format('cDatNamesCD%1.1d: Array[0..%d] of String = (', [CD, High(L[CD])])); 
    Line := '';
    For n := 0 To High(L[CD]) do
    begin
      If (n > 0) and (n mod 8 = 0) Then
      begin
        List.Add(Line);
        Line := '';
      end;
      S := '''' + L[CD, n].Name + '''';
      If n < High(L[CD]) Then S := S + ',';
      For r := Length(S) to 10 do S := S + ' ';
      Line := Line + S;
    end;
    If Line <> '' Then
      List.Add(Line);
    List.Add(');');
    List.Add('');  
  end;
  List.SaveToFile('F:\_job\FF8\dat_names.txt'); 
  List.Free;

  Exit;
  WriteLn('Final Fantasy VIII text/dat extractor by HoRRoR <horror.cg@gmail.com>');
  WriteLn('http://consolgames.ru/');
  Key := ParamStr(1);

  //Key := '-et';
  If Key = '-ed' Then
  begin
    InFolder  := ParamStr(2);
    OutFolder := ParamStr(3);
    //InFolder := 'F:\_job\FF8\';
    //OutFolder := 'F:\_job\FF8\Dat\';
    If InFolder[Length(InFolder)]   <> '\' Then  InFolder :=  InFolder + '\';
    If OutFolder[Length(OutFolder)] <> '\' Then OutFolder := OutFolder + '\';
    If not DirectoryExists(InFolder) Then
    begin
      WriteLn(Format('Folder "%s" does not exists!',[InFolder]));
      Exit;
    end;
    For n:=1 To 4 do
    begin
      If not FileExists(Format('%sFF8DISC%d.IMG',[InFolder,n])) Then
      begin
        FCreateError(Format('File "FF8DISC%d.IMG" does not exists!',[n]));
        Exit;
      end;
    end;
    If not (DirectoryExists(OutFolder) or ForceDirectories(OutFolder)) Then
    begin
      FCreateError('Can''t create out folder!');
      Exit;
    end;
    WriteLn('Extracting dat files...');
    FF8_ExtractField(InFolder,OutFolder,@P);
  end else
  If Key = '-et' Then
  begin
    InFolder  := ParamStr(2);
    TableFile := ParamStr(3);
    TextFile  := ParamStr(4);
    OptFile   := ParamStr(5);

    //InFolder  := 'F:\_job\FF8\Dat\';
    //TableFile := 'D:\_job\FF8\Table_En.TBL';
    //TextFile  := 'D:\_job\FF8\Test.txt';
    //OptFile   := 'D:\_job\FF8\Test.idx';

    MText := TGameTextSet.Create(@FCreateError);
    MText.LoadTable(TableFile);
    WriteLn('Extracting text...');
    FF8_ExtractAllText(InFolder, MText, @P);
    If OptFile <> '' Then
    begin
      WriteLn('Optimizing...');
      MText.OptimizeText(P);
      MText.SaveOptimDataToFile(OptFile); 
    end;
    MText.SaveTextToFile(TextFile);
    MText.Free;
  end else
  begin
    WriteLn('Usage:');
    WriteLn('  FF8_ExtractDat.exe -ed <imgdir> <datdir>');
    WriteLn('  FF8_ExtractDat.exe -et <datdir> <table> <text> [optimize_data]');
    WriteLn('Examples:');
    WriteLn('  FF8_ExtractDat.exe -ed FF8IMG FF8DAT');
    WriteLn('  FF8_ExtractDat.exe -et FF8DAT Table_En.tbl FF8Script.txt FF8Script.idx');
    WriteLn('');
    WriteLn('ImgDir        - directory with FF8DISC*.IMG files.');
    WriteLn('DatDir        - directory with dat-files.');
    WriteLn('Table         - coding table with advanced features:');
    WriteLn('  - Unicode supported ;)');
    WriteLn('  - Directives:');
    WriteLn('    .format         - use cpp formatting string (\n, \t, etc)');
    WriteLn('    .normal         - use standard text format (default)');
    WriteLn('    .include <name> - include table file');
    WriteLn('  - Stop data must be defines as <data>!=<text>, for example - 02!=\0');
    WriteLn('Text          - text file');
    WriteLn('Optimize Data - if defined, the text will be optimized');
    WriteLn('                (All the duplicate strings will be removed)');
  end;
  //readln;
end.
