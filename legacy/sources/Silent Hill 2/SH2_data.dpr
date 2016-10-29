program SH2_data;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  SH2_ARC in 'SH2_ARC.pas';

Function Progress(Cur, Max: Integer; S: String): Boolean;
begin
  Result := False;
  If Max <> 0 Then
    WriteLn(Format('[%d/%d] %s', [Cur+1, Max, S]))
  else
    WriteLn(S);
end;

var SrcDir, DestDir, ExeName: String;
begin
  If ParamStr(1) = '-b' Then
  begin
    ExeName := ParamStr(2);
    SrcDir := ParamStr(3);
    DestDir := ParamStr(4);
    Try
      SH2_Build(ExeName, SrcDir, DestDir, Progress);
    except
      WriteLn('Error!');
      ReadLn;
      Exit;
    end;
    WriteLn('Done!');
    //ReadLn;
  end;
end.
