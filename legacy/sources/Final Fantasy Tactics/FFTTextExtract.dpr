program FFTTextExtract;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  StrUtils,
  TableText in '..\FFText\TableText.pas',
  FFT_Text in 'FFT_Text.pas';

Procedure FCreateError(S: String; Level: TErrorType = etError);
const cLevelStr: Array[TErrorType] of String = ('***LOG: ','***HINT: ','***WARNING: ','***ERROR: ');
begin
  WriteLn(cLevelStr[Level] + S);
end;

Function OptimizeProgress(Cur, Max: Integer; S: String): Boolean;
begin
  WriteLn(Format('[%d/%d] %s', [Cur+1,Max,S]));
end;

var MText: TGameTextSet; Buf: Pointer; F: File; Size: Integer;
n: Integer; List: TStringList; Key, FileName: String;
begin

    {MText := TGameTextSet.Create(@FCreateError);
    MText.LoadTextFromFile('FFTScript.txt');
    List := TStringList.Create;
      For n := 0 To MText.Count - 1 do With MText.Items[n] do
        List.Add(Format('(Index: %3s; Count: %2d),',[RightStr(Name, Length(Name) - 5), Count]));
    List.SaveToFile('Len.txt');
    List.Free;
    MText.Free;
    Exit;}
  Key := ParamStr(1);
  If Key = '-et' Then
  begin
    // -et _TEST.EVT tables\Table_eng.tbl FFTScript.txt FFTScript.idx
    AssignFile(F, {'_TEST.EVT'}ParamStr(2));
    Reset(F, 1);
    Size := FileSize(F);
    GetMem(Buf, Size);
    BlockRead(F, Buf^, Size);
    CloseFile(F);

    MText := TGameTextSet.Create(@FCreateError);
    MText.LoadTable({'tables\Table_eng.tbl'} ParamStr(3));
    FFT_ExtractMainText(Buf, Size, MText);

    If ParamStr(4) <> '' Then
    begin
      MText.OptimizeText(@OptimizeProgress);
      MText.SaveOptimDataToFile({'FFTScript.idx'}ParamStr(5));
    end;
    //MText.Items[0].Hide := True;
    //MText.Items[0].Checked := True;
    //MText.Items[0].UserData := 'abc';
    MText.SaveTextToFile({'FFTScript.txt'} ParamStr(4));
    MText.Free;
    FreeMem(Buf);
  end else
  If Key = '-bt' Then
  begin
    //  1      2              3                 4             5           6
    // -bt _TEST.EVT tables\Table_eng.tbl FFTScript.txt FFTScript.idx TEST.EVT
    AssignFile(F, ParamStr(2));
    Reset(F, 1);
    Size := FileSize(F);
    GetMem(Buf, Size);
    BlockRead(F, Buf^, Size);
    CloseFile(F);

    If ParamStr(6) = '' Then
      FileName := ParamStr(2)
    else
      FileName := ParamStr(6);
    
    MText := TGameTextSet.Create(@FCreateError);
    MText.LoadTable({'tables\Table_eng.tbl'} ParamStr(3));
    MText.LoadOptimDataFromFile(ParamStr(5));
    MText.LoadTextFromFile(ParamStr(4), True);  
    FFT_InsertMainText(Buf, MText);

    AssignFile(F, FileName);
    Rewrite(F, 1);
    BlockWrite(F, Buf^, Size);
    CloseFile(F);
    FreeMem(Buf);
    MText.Free;
    WriteLn('Done!');
  end;
end.
