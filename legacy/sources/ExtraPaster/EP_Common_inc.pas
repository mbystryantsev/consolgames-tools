function GetParamStr(P: PChar; var Param: string): PChar;
  function CharNext(const C: PChar): PChar;
  begin
    Result := PChar(LongWord(C) + 1);
  end;

var
  i, Len: Integer;  Flag: Boolean;
  Start, S, Q: PChar;
begin
  Flag := False;
  while True do
  begin
    while (P[0] <> #0) and (P[0] <> '@') and (P[0] <= ' ') do
      Inc(P);
    if (P[0] = '"') and (P[1] = '"') then Inc(P, 2) else
    If (P[0] = ',') and not Flag Then
    begin
      Inc(P);
      Flag := True;
    end else
      break;
  end;
  Len := 0;
  Start := P;
  while (P[0] > ' ') and (P[0] <> '@') and (P[0] <> ',') do
  begin
    //If (P > Start) and (P[0] = '"') Then Break;
    if P[0] = '"' then
    begin
      Inc(P);
      while (P[0] <> #0) and (P[0] <> '@') and (P[0] <> '"') do
      begin
        Q := CharNext(P);
        Inc(Len, Q - P);
        P := Q;
      end;
      if P[0] <> #0 then
        P := CharNext(P);
    end
    else
    begin
      Q := CharNext(P);
      Inc(Len, Q - P);
      P := Q;
    end;
  end;

  If Len = 0 Then
  begin
    Param := '';
    Exit;
  end;
  SetLength(Param, Len);

  P := Start;
  S := Pointer(Param);
  i := 0;
  while (P[0] > ' ') and (P[0] <> ',') do
  begin
    if P[0] = '"' then
    begin
      P := CharNext(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Q := CharNext(P);
        while P < Q do
        begin
          S[i] := P^;
          Inc(P);
          Inc(i);
        end;
      end;
      if P[0] <> #0 then Inc(P);
    end
    else
    begin
      Q := CharNext(P);
      while P < Q do
      begin
        S[i] := P^;
        Inc(P);
        Inc(i);
      end;
    end;
  end;
  Result := P;
end;


function GetParam(Index: Integer; const S: String): string;
var
  P: PChar;
begin
  Result := '';
  P := PChar(S);
  while True do
  begin
    P := GetParamStr(P, Result);
    if (Index = 0) or (Result = '') then Break;
    Dec(Index);
  end;
end;

function RoundBy(const V, R: Integer): Integer;
var M: Integer;
begin
  M := V mod R;
  If M <> 0 Then
    Result := V - M + R
  else
    Result := V;
end;

const
    fmCreate         = $FFFF;
    fmOpenRead       = $0000;
    fmOpenWrite      = $0001;
    fmOpenReadWrite  = $0002;

Procedure Fin(var Data: Pointer);
begin
  If Data <> nil Then
  begin
    FreeMem(Data);
    Data := nil;
  end;
end;

Function EP_AddSpace(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
var Num, n, LV, RV, Code: Integer; S,L,R: String; C: Char;
begin
  Num := 1;
  Result := False;
  While True do
  begin
    S := GetParam(Num, Line);
    If S = '' Then Break;
    Inc(Num);
    C := #0;      
    L := '$';
    R := '$';
    For n := 1 To Length(S) do
    If (C = #0) and ((S[n] = '-') or (S[n] = ':')) Then
      C := S[n]
    else if (C = '-') or (C = ':') Then
      R := R + S[n]
    else
      L := L + S[n];
    Val(L, LV, Code);
    Result := Result or Boolean(Code);
    Val(R, RV, Code);
    Result := Result or Boolean(Code);
    If Result Then
    begin
      Paster.FErrorString := 'Invalid value!';
      Result := not Result;
      Exit;
    end;
    Case C of
      ':': Paster.AddSpace(LV, RV);
      '-': Paster.AddSpace(LV, RV - LV + 1);
    end;
  end;
  Result := True;
end;

Function EP_Chain(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
begin
  Result := False;
  With Paster do
  begin
    Push(Line);
    FCurConv := ctConv;
  end;
  Result := True;
  Inc(Paster.FCurNum);
end;

Function EP_TstInc(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
var n: Integer; B: ^Byte;
begin
  Result := False;
  B := Data;
  For n := 0 To Size - 1 do
  begin
    Inc(B^);
    Inc(B);
  end;
  Result := True;
end;

Function EP_PtrSize(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
var Code: Integer;
begin
  Val(GetParam(1, Line), Paster.FPtrSize, Code);
  Result := Code = S_OK;
end;

Function EP_Align(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
var Code: Integer;
begin
  Val(GetParam(1, Line), Paster.FAlign, Code);
  Result := Code = S_OK;
end;

Function EP_ClrSpace(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
begin
  Finalize(Paster.FSpace);
end;

Function EP_DestFile(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
begin
  Result := False;
  With Paster do
  begin
    If FFileStream <> nil Then FFileStream.Free;
    FFileName := GetParam(1, Line);
    Try
      FFileStream := TFileStream.Create(FWorkDir + FFileName, fmOpenWrite);
    except
      FErrorString := 'Can''t open file!';
      //FFileStream.Free;
      Exit;
    end;
  end;
  Result := True;
end;

Function EP_End(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
begin
  Paster.FPop := True;
  Result := True;
end;

Function EP_PtrDef(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
var Code: Integer;
begin
  Val(GetParam(1, Line), Paster.FPtrDef, Code);
  Result := Code = S_OK;
end;

Function EP_Stream(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
begin
  Result := False;
  With Paster do
  begin
    Push(Line);
    FCurConv := ctSrc;
  end;
  Result := True;
  Inc(Paster.FCurNum);
end;

Function EP_WorkDir(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
begin
  With Paster do
  begin
    FWorkDir := GetParam(1, Line);
    If (FWorkDir <> '') and (FWorkDir[Length(FWorkDir)] <> '\') Then
      FWorkDir := FWorkDir + '\';
  end;
  Result := True;
end;


Function EP_File(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
var Stream: TFileStream;
begin
  Result := False;
  Fin(Data);
  try
    Stream := TFileStream.Create(TPaster(Paster).FWorkDir + GetParam(1, Line), fmOpenRead);
  except
    Paster.FErrorString := 'Can''t open file!';
    //Stream.Free;
    Exit;
  end;
  Size := Stream.Size;
  GetMem(Data, Size);
  Stream.Read(Data^, Size);
  Stream.Free;
  Result := True;
end;

Function EP_DWord(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
var W: ^LongWord; Code, Count: Integer; S: String;
begin
  Result := False;
  Fin(Data);
  Count := 0;

  GetMem(Data, Length(Line));
  W := Data;
  While True do
  begin
    S := GetParam(Count + 1, Line);
    If S = '' Then Break;
    Val(S, W^, Code);
    If Code <> 0 Then
    begin
      Paster.FErrorString := 'Invalid Word value ' + S + '!';
      Size := 0;
      FreeMem(Data);
      Exit;
    end;
    Inc(W);
    Inc(Count);
  end;
  Size := Count * SizeOf(W);
  ReallocMem(Data, Size);
  Result := True;

end;

Function EP_Word(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
var W: ^Word; Code, Count: Integer; S: String;
begin
  Result := False;
  Fin(Data);
  Count := 0;

  GetMem(Data, Length(Line));
  W := Data;
  While True do
  begin
    S := GetParam(Count + 1, Line);
    If S = '' Then Break;
    Val(S, W^, Code);
    If Code <> 0 Then
    begin
      Paster.FErrorString := 'Invalid Word value ' + S + '!';
      Size := 0;
      FreeMem(Data);
      Exit;
    end;
    Inc(W);
    Inc(Count);
  end;
  Size := Count * SizeOf(Word);
  ReallocMem(Data, Size);
  Result := True;
end;

Function EP_Byte(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
var B: ^Word; Code, Count: Integer; S: String;
begin
  Result := False;
  Fin(Data);
  Count := 0;

  GetMem(Data, Length(Line));
  B := Data;
  While True do
  begin
    S := GetParam(Count + 1, Line);
    If S = '' Then Break;
    Val(S, B^, Code);
    If Code <> 0 Then
    begin
      Paster.FErrorString := 'Invalid Byte value ' + S + '!';
      Size := 0;
      FreeMem(Data);
      Exit;
    end;
    Inc(B);
    Inc(Count);
  end;
  Size := Count * SizeOf(Byte);
  ReallocMem(Data, Size);
  Result := True;  
end;
