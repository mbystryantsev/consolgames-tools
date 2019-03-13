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
  TSHTexRec = Packed Record
    Hash: DWord;
    Ptr:  DWord;
  end;

  TSHTextArray = Array of TSHText;
  TStringArray = Array of String;

Procedure SetSlash(var S: String);
begin
  If S = '' Then Exit;
  If S[Length(S)] <> '\' Then S := S + '\';
end;

Function GetPaths(S: String; var P: TStringArray): Integer;
var i, Count: Integer; Flag: Boolean;
begin
  Count := 0;
  Flag  := False;
  For i := 1 To Length(S) do If S[i] = ';' Then S[i] := #0;
  For i := 1 To Length(S) do
  begin
    If (S[i] <> #0) and not Flag Then
    begin
     Flag := True;
     Inc(Count);
     SetLength(P, Count);
     P[Count - 1] := PChar(@S[i]);
    end else If S[i] = #0 Then
     Flag    := False;
  end;
  Result := Count;
end;

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

// D:\_job\SH\SHText.txt D:\_job\SH\SHText.eng

var F: File; List: TStringList; T: TSHTextArray; FT: Array of TSHTexRec;
n,m,l,i,Carry,CountDecr: Integer; Count: Integer=0; S,P,P1: String; Flag: Boolean;
Buf: Pointer; PPos: ^DWord; TPos: ^Word; Pos: DWord; SR: TSearchRec;
InDir, InFiles, OutFile, ForceFile: String; Forced: Boolean;
FileNames: TStringArray;
begin
  WriteLn('Silent Hill 0rigins Text Builder v1.0 by HoRRoR <ho-rr-or@mail.ru>');
  WriteLn('http://consolgames.ru/');

  Forced := False;
  Carry:=0;
  If ParamCount<2 Then
  begin
    WriteLn('Usage:');
    WriteLn('SHTextBuild [Keys] <TextFile(s)/Mask(s)> <StringsFile>');
    WriteLn('Keys:');
    WriteLn(' -f: Force string order from Strings file/header');
    Exit;
  end;

  For n := 1 To ParamCount do
  begin
    S := ParamStr(n);
    if S[1] <> '-' Then Break;
    Case S[2] of
      'f':
      begin
        Forced := True;
        SetLength(ForceFile, Length(S) - 2);
        Move(S[3], ForceFile[1], Length(ForceFile));
      end;
    end;
  end;
  {If not ExtractFilePath(ParamStr(2))) Then
  begin
    //If not MkDir(ExtractFilePath(ParamStr(2))) Then
    //begin
      WriteLn('Output directory not exists!');
      Exit;
    //end;
  end;}


  InFiles := ParamStr(n);
  GetPaths(InFiles, FileNames);
  OutFile := ParamStr(n + 1);

  For i := 0 To High(FileNames) do
  begin
    InDir := ExtractFilePath(FileNames[i]);
    SetSlash(InDir);
    If SysUtils.FindFirst(FileNames[i], faAnyFile xor faDirectory, SR) <> 0 Then
    begin
      WriteLn('Input file(s) not exists!');
      Exit;
    end;

    List:=TStringList.Create;

    repeat
      List.LoadFromFile(InDir + SR.Name);
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
    until SysUtils.FindNext(SR) <> 0;
    SysUtils.FindClose(SR);
  end;
  List.Free;

  If Forced Then
  begin
    AssignFile(F, ForceFile);
    Reset(F, 1);
    Seek(F, 4);
    BlockRead(F, Count, 4);
    SetLength(FT, Count);
    BlockRead(F, FT[0], Count * SizeOf(TSHTexRec));
    CloseFile(F);
  end;

  GetMem(Buf,$180000);
  PPos := Buf;
  PPos^ := 2;
  Inc(PPos, 2);
  Pos:=0;
  TPos:=Addr(Buf^);
  Inc(DWord(TPos), Count * 8 + 8);

  CountDecr := 0;
  For n:=0 To Count - 1 do
  begin
    if Forced Then
    begin
      For i := 0 To High(T) do
        If FT[n].Hash = T[i].ID Then
          break;
      If i = Length(T) Then
      begin
        Inc(CountDecr);
        WriteLn(Format('***ERROR: String with hash %8.8X from forced header not found in script!', [FT[n].Hash]));
        Continue;
      end else
      begin
        PPos^ := T[i].ID; Inc(PPos);
        PPos^ := Pos;     Inc(PPos);
        S := T[i].S;
      end;
    end else
    begin
      PPos^:=T[n].ID; Inc(PPos);
      PPos^:=Pos; Inc(PPos);
      S:=T[n].S;
    end;
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
  
  PPos:=Addr(Buf^);
  Inc(PPos);
  PPos^ := Count - CountDecr;

  Try
    AssignFile(F, OutFile);
    Rewrite(F,1);
    BlockWrite(f, Buf^,Count * SizeOf(TSHText) + 10 + (Pos-1) * 2);
  except
    WriteLn('Unable to save file!');
    FreeMem(Buf);
    Exit;
  end;
  FreeMem(Buf);
  WriteLn('Done ;)');

end.
 