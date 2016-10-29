program Extract;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  ICO_DF in 'ICO_DF.pas';


Procedure Progress(Cur, Max: Integer; S: String);
begin
  WriteLn(Format('[%d/%d] %s',[Cur+1,Max,S]));
end;

Procedure CreateError(S: String);
begin
  WriteLn(Format('***ERROR: %s',[S]));
end;


var S: String; n,m: Integer; ErrorCount: Integer = 0; SavePaths, Dir, SubFolders: Boolean;
begin
  WriteLn('ICO Main DF Extractor by HoRRoR');
  WriteLn('E-mail: ho-rr-or@mail.ru :: horror.cg@gmail.com');
  WriteLn('http://consolgames.ru/');
  WriteLn('');
  If ParamStr(1)='-e' Then
  begin
    DFDATAS_Extract(ParamStr(2), ParamStr(3), '', @Progress, @CreateError);
    WriteLn('Archive extracted.');
  end else
  If ParamStr(1)='-b' Then
  begin
    SavePaths  := False;
    SubFolders := False;
    Dir        := False;
    For n:=2 To ParamCount do
    begin
      If ParamStr(n) = '-sp' Then
        SavePaths := True
      else If ParamStr(n) = '-dir' Then
        Dir := True
      else If ParamStr(n) = '-sf' Then
        SubFolders := True
      else
        Break;
    end;
    If Dir Then
      ErrorCount := DFDATAS_Build(ParamStr(n), ParamStr(n+1), SubFolders,
                                  SavePaths, @Progress, @CreateError)
    else
    begin
      For m:=n+2 To ParamCount do
        S := S + ParamStr(m) + ';';
      ErrorCount := DFDATAS_Build(ParamStr(n), ParamStr(n+1), S, False, @Progress, @CreateError);
    end;
    If ErrorCount = 0 Then
      WriteLn('Done!')
    else
      WriteLn('Completed with errors. (',ErrorCount,')');
  end;
end.

