unit SH5_Common;

interface

Uses Windows, SysUtils, Errors;

Type
  TThankYou = Record
    Name: String;
    Help: String;
  end;
  TErrorType = (etNone, etInfo, etWarning, etError);

const
  cThankYou: Array[0..4] of TThankYou = (
  (Name: 'Андрей Кудрявцев'; Help: 'LZO packer/unpacker'),
  (Name: 'DrLeo';            Help: 'Helpfull people search'),
  (Name: 'Djinn';            Help: 'Design and coding cosultation'),
  (Name: 'VadimV';           Help: 'Help in LZX identification'),
  (Name: 'eol';              Help: 'Help in LZX structure researching'));

var
  TempDir: String;

Function SQR(Y,X: DWord): DWord;
Function GetSize(Size: Integer): String;
Function  BigToLittle(V: DWord): DWord; overload;
Function  GetEndian(V: DWord; Big: Boolean = True): DWord;
Function  GetEndianW(V: Word; Big: Boolean = True): Word;
//Function  BigToLittle(V: Word): Word; overload;
Function RoundBy(Value, R: Integer): Integer;
Function LoadFile(FileName: String; var Buf: Pointer): Integer;
function GetTempDir: String;
Procedure CreateError(S: String; Error: TErrorType = etError);
Function MakeDirs(S: String): Boolean;
Function GetUpCase(S: String): String;
implementation

Function GetUpCase(S: String): String;
var n: Integer;
begin
  Result := S;
  For n:=1 To Length(Result) do Result[n]:=UpCase(Result[n]);
end;

Function MakeDirs(S: String): Boolean;
Var I, L, J: Integer; P: PChar; SS: String;
begin
 Result := False;
 S := ExtractFilePath(S);
 L := Length(S);
 If (S <> '') and (S[L] <> '\') then S := S + '\';
 P := Addr(S[1]);
 I := L;
 SS := '';
 If L > 2 then
 begin
  If S[2] = ':' then
  begin
   SS := Copy(S, 1, 3);
   Inc(P, 3);
   Dec(I, 3);
  end Else If (S[1] = '\') and (S[2] = '\') then
  begin
   SS := '\\';
   Inc(P, 2);
   Dec(I, 2);
   J := 0;
   While (I > 0) and (J < 2) do
   begin
    If P^ = '\' then Inc(J);
    SS := SS + P^;
    Inc(P);
    Dec(I);
   end;
  end;
 end;
 While I > 0 do
 begin
  If (P^ = '\') and not DirectoryExists(SS) then
  begin
   If not CreateDir(SS) then
    Exit;
  end;
  SS := SS + P^;
  Inc(P);
  Dec(I);
 end;
 Result := True;
end;

Procedure CreateError(S: String; Error: TErrorType = etError);
const ErrorStrings: Array[TErrorType] of String =
('','[Info] ','[Warning] ','[Error] ');
begin
  ErrorForm.AddString(ErrorStrings[Error] + S);
end;

function GetTempDir: String;
var
  Buf: array[0..1023] of Char;
begin
  SetString(Result, Buf, GetTempPath(Sizeof(Buf)-1, Buf));
end;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

Function  BigToLittleInt(V: Integer; Sz: Integer = 4): Integer;
var B,WB: ^Byte;
begin
  If (Sz>4) or (Sz<1) Then Exit;
  B:=@V; Inc(B,Sz-1);
  WB:=@Result;
  While Sz>0 do
  begin
    WB^:=B^;
    Inc(WB); Dec(B); Dec(Sz);
  end;
end;

Function  GetEndianW(V: Word; Big: Boolean = True): Word;
begin
  If Big Then Result := BigToLittleInt(V,2) else Result := V;
end;

Function  GetEndian(V: DWord; Big: Boolean = True): DWord;
begin
  If Big Then Result := BigToLittleInt(V) else Result := V;
end;

Function  BigToLittle(V: DWord): DWord; //overload;
begin
  Result:=BigToLittleInt(V,4);
end;

{Function  BigToLittle(V: Word): Word; //overload;
begin
  Result:=BigToLittleInt(V,2);
end;}

Function SQR(Y,X: DWord): DWord;
begin
  Result:=Y;
  While X>1 do
  begin
    Result:=Result*Y;
    Dec(X);
  end;
end;


Function GetSize(Size: Integer): String;
var n,Tp: Integer; Lim: DWord; V: Real;
const cSizeNames: Array[0..3] of String = (
'b','kB','MB','GB');
begin
  If Size<=0 Then
  begin
    Result:='0 b';
    Exit;
  end;
  Lim:=1;
  Tp:=0;
  For n:=3 downto 0 do
  begin
    If Size>=SQR(1024,n) Then
    begin
      Tp:=n;
      Lim:=Sqr(1024,n);
      break;
    end;
  end;
  V:=Size/Lim;
  Try
    Result:=Format('%n %s',[V,cSizeNames[Tp]]);
  except
    Result:='ERROR!';
  end;
end;

Function LoadFile(FileName: String; var Buf: Pointer): Integer;
var F: File;
begin
  FileMode:=fmOpenRead;
  AssignFile(F,FileName);
  Reset(F,1);
  Result:=FileSize(F);
  GetMem(Buf,Result);
  BlockRead(F,Buf^,Result);
  CloseFile(F);
end;

Initialization
  TempDir := GetTempDir;
  If TempDir[Length(TempDir)]<>'\' Then TempDir := TempDir + '\';
end.
 