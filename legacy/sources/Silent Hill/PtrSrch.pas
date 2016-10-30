unit PtrSrch;

interface

uses
  SysUtils,
  Classes,
  Windows,
  StrUtils;

Type
TByteArray = Array[0..3] of Byte;


Function ToMot(X: Integer; SZ: Byte): Integer;                                  // Конвертирование в формат Моторолы
Function GetPtr(Adr: Dword; Sz: Byte; Mot: Boolean; Dif: DWord): DWord;         //
Function GetAdr(Ptr: Dword; Sz: Byte; Mot: Boolean; Dif: DWord): DWord;         //
Function CutVal(V,Sz: Integer): Integer;                                        // Обрезание DWord'а до нужного размера
Function RoundBy(Value, R: Integer): Integer;                                   // Округление
Function FindPtr(SAdr: DWord; Buf: Pointer; Sz: Byte; Mot: Boolean;
Adr1,Adr2: DWord; Dif, Interval, Step: Integer): DWord;
Function ExtractPtrs(var List: TStringList; StopByte: Byte; Buf: Pointer; Adr1,Adr2: DWord;
Count, SAdr1,SAdr2: DWord; TextDiv: Byte; PtrSz: Byte;
PtrDif,PtrInterval,PtrStep: Integer; Mot: Boolean; var Finded,UFinded: Integer): Integer;
Function HexToInt(S: String): Integer;
Function ParToInt(S: String): Integer;

implementation

Function ParToInt(S: String): Integer;
begin
  If (S[1]='H') or (S[1]='h') or (S[1]='$') Then
  begin
    S:=RightStr(S,Length(S)-1);
    Result:=HexToInt(S);
  end else
    Result:=StrToInt(S);
end;

Function HexToInt(S: String): Integer;
Var
 I, LS, J: Integer; PS: ^Char; H: Char; HexError: Boolean;
begin
 HexError := True;
 Result := 0;
 LS := Length(S);
 If (LS <= 0) or (LS > 8) then Exit;
 HexError := False;
 PS := Addr(S[1]);
 I := LS - 1;
 J := 0;
 While I >= 0 do
 begin
  H := UpCase(PS^);
  If H in ['0'..'9'] then J := Byte(H) - 48 Else
  If H in ['A'..'F'] then J := Byte(H) - 55 Else
  begin
   HexError := True;
   Result := 0;
   Exit;
  end;
  Inc(Result, J shl (I shl 2));
  Inc(PS);
  Dec(I);
 end;
end;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If R<=0 Then Exit;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

Function ToMot(X: Integer; SZ: Byte): Integer;
var B,B1: TByteArray; n: Integer;
begin
  B:=TByteArray(X);
  For n:=0 To Sz-1 do
  begin
    B1[n]:=B[Sz-n-1];
  end;
  Result:=Integer(B1);
  
end;

Function CutVal(V,Sz: Integer): Integer;
var I: DWord;
begin
  Case Sz of
    1: I:=$000000FF;
    2: I:=$0000FFFF;
    3: I:=$00FFFFFF;
    4: I:=$FFFFFFFF;
  end;
  Result:=V AND I;
end;

Function GetPtr(Adr: Dword; Sz: Byte; Mot: Boolean; Dif: DWord): DWord;
var I: DWord;
begin
  Result:=Adr;
  Inc(Result,-Dif);
  Result:=CutVal(Result, Sz);
  //Result:=(Result SHL (4-Sz)*8) SHR (4-Sz)*8;
  If Mot Then Result:=ToMot(Result,Sz);
end;

Function GetAdr(Ptr: Dword; Sz: Byte; Mot: Boolean; Dif: DWord): DWord;
var I: DWord;
begin
  Result:=Ptr;
  If Mot Then Result:=ToMot(Result,Sz);
  Inc(Result,Dif);
end;

Function ExtractPtrs(var List: TStringList; StopByte: Byte; Buf: Pointer; Adr1,Adr2: DWord;
Count, SAdr1,SAdr2: DWord; TextDiv: Byte; PtrSz: Byte;
PtrDif,PtrInterval,PtrStep: Integer; Mot: Boolean; var Finded,UFinded: Integer): Integer;
var Pos: DWord; B: ^Byte; Flag: Boolean; n,Cnt: DWord; Fnd: Boolean;
begin
  Result:=0;
  Finded:=0;
  UFinded:=0;
  Pos:=Adr1;
  If not Assigned(List) Then List:=TStringList.Create;
  // Список поинтеров не очищается. Если надо, то это делается перед процедурой
  // Ищем первый поинтер вне цикла
  Cnt:=0;
  n:=SAdr1-PtrSz-PtrInterval;
  Fnd:=True;
  While (Cnt<=Count) and (n+PtrSz+PtrInterval<=SAdr2-PtrSz) do
  begin
      If Count>0 Then Inc(Cnt);
      n:=FindPtr(Pos,Buf,PtrSz,Mot,n+PtrSz+PtrInterval,SAdr2,PtrDif,PtrInterval,PtrStep);
      If n<$FFFFFFFF Then
      begin
        List.Add(IntToHex(n,8));
        Inc(Finded);
        Fnd:=False;
      end else
      begin
        If Fnd Then Inc(Result);
        Break;
      end;
  end;
  If not Fnd Then Inc(UFinded);// else Inc(NFinded);
  B:=Addr(Buf^);
  Inc(B,Pos);
  While Pos<Adr2 do
  begin
    While (StopByte<>B^) And (Pos<Adr2) do
    begin
      Inc(B); Inc(Pos);
    end;
    If Pos>=Adr2 Then Break;
    Integer(B):=RoundBy(Integer(B),TextDiv);
    Pos:=RoundBy(Pos,TextDiv);
    While (B^=StopByte) And (Pos<Adr2) do
    begin
      Inc(B); Inc(Pos);
    end;
    If Pos>=Adr2 Then Break;
    //n:=Pos;
    n:=SAdr1-PtrSz-PtrInterval;
    Cnt:=0;
    Fnd:=True;
    While (Cnt<=Count) and (n+PtrSz+PtrInterval<=SAdr2-PtrSz) do
    begin
      If Count<0 Then Inc(Cnt);
      n:=FindPtr(Pos,Buf,PtrSz,Mot,n+PtrSz+PtrInterval,SAdr2,PtrDif,PtrInterval,PtrStep);
      If n<$FFFFFFFF Then
      begin
        List.Add(IntToHex(n,8));
        Inc(Finded);
        Fnd:=False;
      end else
      begin
        If Fnd Then Inc(Result);
        Break;
      end;
    end;
    If not Fnd Then Inc(UFinded);// else Inc(UFinded);
  end;
end;

Function FindPtr(SAdr: DWord; Buf: Pointer; Sz: Byte; Mot: Boolean;
Adr1,Adr2: DWord; Dif, Interval, Step: Integer): DWord;
var Pos: DWord; DW: ^DWord; Ptr: DWord;
begin
  If Step=0 Then Step:=1;
  Pos:=Adr1;
  Ptr:=GetPtr(SAdr,Sz,Mot,Dif);
  DW:=Addr(Buf^);
  Inc(Integer(DW),Pos);
  While Pos<=Adr2-Sz do
  begin
    If CutVal(DW^,Sz)=Ptr Then
    begin
      Result:=Pos;
      Exit;
    end;
    Inc(Integer(DW),Step+Interval);
    Inc(Pos,Step+Interval);
  end;
  Result:=$FFFFFFFF; //Возвращаем данное значение, если поинтер не найден.
  // В любом случае поинтер в этом месте возможен, только если его размер 1 байт.
  // Так что этот адрес можно смело использовать в качестве индикатора.
end;


end.
