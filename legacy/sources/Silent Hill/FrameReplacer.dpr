program FrameReplacer;

{$APPTYPE CONSOLE}

uses
  SysUtils, StrUtils,
  STR in 'Programming\SH1\STR.pas';

Function HexToInt(S: String): Integer;
Var
 I, LS, J: Integer; PS: ^Char; H: Char;
begin
 Result := 0;
 LS := Length(S);
 If (LS <= 0) or (LS > 8) then Exit;
 PS := Addr(S[1]);
 I := LS - 1;
 J := 0;
 While I >= 0 do
 begin
  H := UpCase(PS^);
  If H in ['0'..'9'] then J := Byte(H) - 48 Else
  If H in ['A'..'F'] then J := Byte(H) - 55 Else
  begin
   Result := 0;
   Exit;
  end;
  Inc(Result, J shl (I shl 2));
  Inc(PS);
  Dec(I);
 end;
end;


Function ParToInt(S: String): Integer;
begin
  If (S[1]='H') or (S[1]='h') or (S[1]='$') Then
  begin
    S:=RightStr(S,Length(S)-1);
    Result:=HexToInt(S);
  end else
    Result:=StrToInt(S);
end;

var B: String; DestP,SrcP:TSTRParam;
begin


  WriteLn('STR Frame Replacer v0.0.0.0.0.0.0.1 by HoRRoR :-D <ho-rr-or@mail.ru');
  WriteLn('Usage: <DestFile> <SrcFile> <BeginPos> <SectorSize> <HeaderOffset> <FrameStart> <FrameEnd>');
  WriteLn('<DestFile>                - file with STR inside');
  WriteLn('<SrcFile>                 - STR file without audio, sector size = 0x800');
  WriteLn('<BeginPos>                - first sector position in file');
  WriteLn('<SectorSize>              - dest STR setor size (ordinary 0x930)');
  WriteLn('<HeaderOffset>            - header position relative to sector begining');
  WriteLn('<FrameStart> & <FrameEnd> - frame interval to replacing');
  // Frames 15 - 90 (125)
  WriteLn;
  WriteLn('For example:');
  WriteLn('FReplacer HILL SHop.STR $D2535AC $930 $18 15 90');
  WriteLn;
  If ParamCount<7 Then Exit;

  // SH1\STR\Old\!@!.STR SH1\STR\sh.str $2C $930 $18 15 90

  SrcP.BeginPos:=0;
  SrcP.SectorSize:=$800;
  SrcP.HeaderOffset:=0;

  DestP.BeginPos:=ParToInt(ParamStr(3));
  DestP.SectorSize:=ParToInt(ParamStr(4));
  DestP.HeaderOffset:=ParToInt(ParamStr(5));

  B:=ReplaceFrames(ParamStr(1),ParamStr(2),DestP,SrcP,ParToInt(ParamStr(6)),ParToInt(ParamStr(7)));

  If B<>'' Then WriteLn(Format('Error: "%s"',[B])) else
  WriteLn('Frames replaced successfully ;)');
  //readln;
end.
