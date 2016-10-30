program SHTextBuild;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, StrUtils,
  Windows;

Type
  TSHText = Packed Record
    ID: DWord;
    S:  String;
  end;
  TSHTextArray = Array of TSHText;


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

Function CharToWideChar(Ch: Char): WideChar;
Var WS: WideString;
begin
 WS := Ch;
 Result := WS[1];
end;

// SH\SHText.txt SH\SHText.eng

var F: File; List: TStringList; T: TSHTextArray;
n,m,l,Carry: Integer; Count: Integer=0; S,P,P1: String; Flag: Boolean;
Buf: Pointer; PPos: ^DWord; TPos: ^Word; Pos: DWord;
begin
  WriteLn('Silent Hill 0rigins Text Builder v1.0 by HoRRoR <ho-rr-or@mail.ru>');
  WriteLn('http://consolgames.ru/');
  
  Carry:=0;
  If ParamCount<2 Then
  begin
    WriteLn('Usage:');
    WriteLn('SHTextBuild <TextFile> <StringsFile>');
    WriteLn('  -p: Save paths in file names');
    WriteLn('  -s: Include subfolders');
    WriteLn('  -c: Use compression');
    Exit;
  end;
  If not FileExists(ParamStr(1)) Then
  begin
    WriteLn('Input file not exists!');
    Exit;
  end;
  {If not ExtractFilePath(ParamStr(2))) Then
  begin
    //If not MkDir(ExtractFilePath(ParamStr(2))) Then
    //begin
      WriteLn('Output directory not exists!');
      Exit;
    //end;
  end;}

  List:=TStringList.Create;
  List.LoadFromFile(ParamStr(1));
  For n:=0 To List.Count-1 do
  begin
    S:=List.Strings[n];
    If (Length(S)=10) and (S[1]='[') and (S[10]=']') Then
    begin
      Carry:=0;
      Inc(Count);
      SetLength(T, Count);
      T[Count-1].ID:=HexToInt(MidStr(S,2,8));
    end
    else if Count<=0 Then Carry:=0
    else if S='' Then Inc(Carry)
    else
    begin
      For m:=0 to Carry-1 do T[Count-1].S:=T[Count-1].S+#$0A;
      Carry:=0;
      If T[Count-1].S<>'' Then T[Count-1].S:=T[Count-1].S+#$0A;
      T[Count-1].S:=T[Count-1].S+S;
    end;
  end;
  GetMem(Buf,$100000);
  PPos:=Addr(Buf^);
  PPos^:=2;
  Inc(PPos);
  PPos^:=Count;
  Inc(PPos);
  Pos:=0;
  TPos:=Addr(Buf^);
  Inc(DWord(TPos),Count*8+8);

  For n:=0 To Count-1 do
  begin
    PPos^:=T[n].ID; Inc(PPos);
    PPos^:=Pos; Inc(PPos);
    S:=T[n].S;
    m:=0;
    While m<Length(S) do
    begin
      Inc(m);
      If S[m]='<' Then
      begin
        P1:=S[m+1];
        If ((P1='c') or (P1='b') or (P1='w')) And (S[m+2]='=') Then
        begin
          L:=m+3; P:='';
          While (S[l]<>'>') and (l<=Length(S)) do
          begin
            P:=P+S[l];
            Inc(l); Inc(m);
          end;
          If P1='c' Then TPos^:=1 else if P1='b' Then TPos^:=3 else TPos^:=4;
          Inc(TPos);
          Inc(m,3);
          TPos^:=StrToInt(P);
          Inc(Pos);
        end else if P='p' Then
        begin
          TPos^:=2;
          Inc(m,3);
        end;
      end else
        TPos^:=Word(CharToWideChar(S[m]));
      Inc(TPos); Inc(Pos);
    end;
    TPos^:=0;
    Inc(TPos); Inc(Pos);
  end;
  Try
    AssignFile(F, ParamStr(2));
    Rewrite(F,1);
    BlockWrite(f, Buf^,Count*8+10+(Pos-1)*2);
  except
    WriteLn('Unable to save file!');
    FreeMem(Buf);
    Exit;
  end;
  FreeMem(Buf);
  WriteLn('Done ;)');

end.
 