program BOUGHT;

{$APPTYPE CONSOLE}

uses
  SysUtils;

Type
  TArr = Array[Word] of Char;
  PArr = ^TArr;
  TStandard = Record
    Eng: String;
    Rus: String;
  end;

const
  CharSet    = [' ', 'a'..'z', 'A'..'Z'];
  AdvCharSet = ['.', ',', ':', ';', '-', '!', '"', '''', '?'];

{$INCLUDE dic.inc}



Function IsString(C: PChar; MaxSize: Integer): Integer;
var n: Integer; Digit, Eq: Integer; L: Char;
begin
  Result := 0;
  Digit := 0;
  For n := 0 To MaxSize - 1 do
    If not ((C[n] in CharSet) or (C[n] in AdvCharSet)) Then
      break
    else
    begin
      If C[n] in AdvCharSet Then
        Inc(Digit);
      If (n > 0) and (C[n] = L) Then
        Inc(Eq)
      else
        Eq := 0;
      L := C[n];
    end;
  If (n < 5) Then Exit;
  If (Digit > n / 6) Then Exit;
  If Eq > 2 Then Exit;
  Result := n;
end;

Function Compare(P1, P2: PByte; Length: Integer): Boolean;
var n: Integer;
begin
  Result := False;
  For n := 0 To Length - 1 do
  begin
    If P1^ <> P2^ Then
      Exit;
    Inc(P1);
    Inc(P2);
  end;
  Result := True;
end;

function ReplaceStandard(C: PChar; var Count: Integer): Boolean;
var n: Integer; S: String;
begin
  SetLength(S, Count);
  Move(C^, S[1], Count);
  S := UpperCase(S);
  For n := 0 To High(Standard) do
  begin
    If (Count >= Length(Standard[n].Eng)) and
    CompareMem(@S[1], @Standard[n].Eng[1], Length(Standard[n].Eng)) Then
    begin
      If Length(Standard[n].Rus) > Length(Standard[n].Eng) Then Continue;
      Result := True;
      FillChar(C^, Length(Standard[n].Eng), ' ');
      Move(Standard[n].Rus[1], C^, Length(Standard[n].Rus));
      Count := Length(Standard[n].Eng);
      Exit;
    end;
  end;
  Result := False;
end;

procedure GenerateString(C: PChar; Count: Integer; var Pos: Integer);
begin
  If ReplaceStandard(C, Count) Then
    Inc(Pos, Count)
  else
    Inc(Pos);
end;

var F: File; Buf: PArr; Size, Count: Integer; Pos: Integer = 0;
//const PChar Test = '';
begin
  WriteLn('BOUGHT v1.0 by http://consolgames.ru/');
  WriteLn('(Basic Omega Ultimate Game Home Translator)');
  WriteLn('Release date: 01.04.2008');
  If not FileExists(ParamStr(1)) Then
  begin
    WriteLn('NCUOL''3OBAHNE: RusVer <ROM>');
    Exit;
  end;

  FileMode := fmOpenReadWrite;
  AssignFile(F, ParamStr(1));
  {$I-}
  Reset(F,1);
  {$I+}
  If IOResult <> 0 Then
  begin
    WriteLn('SHNMN GALKY "TOLbKO DLR 4TEHNR", BLNH!!!');
    ReadLn;
    Exit;
  end;
  Size := FileSize(F);
  GetMem(Buf, Size);
  BlockRead(F, Buf^, Size);
  Pos := $1000;
  WriteLn('Working...');
  While Pos < FileSize(F) do
  begin
    //If Pos >= $357D6 Then
    Count := IsString(@Buf^[Pos], Size - Pos);
    If Count > 0 Then
      GenerateString(@Buf^[Pos], Count, Pos)
    else
      Inc(Pos);
  end;
  Seek(F, 0);
  BlockWrite(F, Buf^, Size);
  FreeMem(Buf);
  CloseFile(F);
  WriteLn('GOTOBO!');
end.
 