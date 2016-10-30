unit FFScript;

interface

uses Classes, SysUtils;

type
  TScriptArgument = (saS8, saU8, saU8X, saS16, saU16, saU16X, saS32, saU32, saU32X);
  TScriptArgumentArray = Array of TScriptArgument;
  TScriptOpcode = Packed Record
    ID:   Byte;
    Len:  Integer;
    Name: String;
    Args: TScriptArgumentArray;
  end;

  TScriptOpcodeSet = Array[0..255] of TScriptOpcode;

  TScriptObjectType = ( soNone,
    soComment, soComBegin, soComEnd, soVal, soChar, soStr, soFunc, soType,
    soTail, soSemi, soColon, soDot, soBraceOpen, soBraceClose, soCrampOpen,
    soCrampClose, soName, soEnum, soOpcodes);

  TScriptError = (seNone, seError);

  TCreateError = Procedure(S: String);

  TScriptMemoryStream = Class(TMemoryStream)
  private
    function GetCurMemory: Pointer;
  public
    Property CurMemory: Pointer Read GetCurMemory;
  end;

  TFFScript = Class
  private
    FOpcodes: TScriptOpcodeSet;
    FErrorProc: TCreateError;
    Function GetObjectType(const P: PChar; Var Len: Integer; Var Error: TScriptError): TScriptObjectType;
    Procedure CreateError(const S: string; const Args: array of const);
    Function  SeekScript(var P: PChar): Integer; overload;
    Function  SeekScript(Stream: TScriptMemoryStream): Integer; overload;
  public
    Procedure LoadOpcodes(Stream: TScriptMemoryStream); overload;
    Procedure LoadOpcodes(const FileName: String); overload;
  end;

implementation

{ TFFScript }

procedure TFFScript.CreateError(const S: string;
  const Args: array of const);
begin
  If @FErrorProc<>nil Then FErrorProc(Format(S, Args));
end;

function TFFScript.GetObjectType(const P: PChar; Var Len: Integer; Var Error: TScriptError): TScriptObjectType;
var n: Integer;
begin
  Len := 0;
  n   := 0; 
  Error := seNone;
  If P[Len] <= #$20 Then
  begin
    Result := soNone;
    Exit;
  end;
  Case P[Len] of
    ':': Result := soColon;
    ';': Result := soSemi;
    '.': Result := soDot;
    ',': Result := soTail;
    '{': Result := soBraceOpen;
    '}': Result := soBraceClose;
    '(': Result := soCrampOpen;
    ')': Result := soCrampClose;
    '/':
    begin
      Inc(Len,2);
      Case P[Len-1] of
        '/': Result := soComment;
        '*': Result := soComBegin;
      else
        Dec(Len);
      end;
    end;
    '*': If P[1] = '/' Then
         begin
          Result := soComEnd;
          Len := 2;
         end else
          Error := seError;
    '0'..'9':
    begin
      Inc(Len);
      While P[Len] in ['0'..'9','x','X'] do
      begin
        If (P[Len] in ['x','X']) and (Len <> 1) Then Break;
        Inc(Len);
      end;
      If not (P[Len] in [#0..#$20, ')','}',':',';',',','.','/']) Then
        Error := seError;
      Result := soVal;
    end;
    'a'..'z','A'..'Z','_':
    begin
      Inc(Len);
      While P[Len] in ['0'..'9','A'..'Z','a'..'z'] do
        Inc(Len);
      If not (P[Len] in [#0..#$20, ')','}',':',';',',','.','/']) Then
        Error := seError;
      Result := soName;
    end;
  end;
  If Result = soComment Then
    While not (P[Len] in [#13,#0]) do Inc(Len);
  If Result = soComBegin Then
  While True do
  begin
    While not (P[Len] in ['*',#0]) do Inc(Len);
    Inc(Len);
    If P[Len] = '/' Then
    begin
      Result := soComment;
      Inc(Len);
      break;
    end;
  end;
  If P^ in [':',';','{','}','(',')'] Then Len := 1;
  
end;

{$O-}
procedure TFFScript.LoadOpcodes(Stream: TScriptMemoryStream);
var Pos: String; Obj: TScriptObjectType;
Error: TScriptError; Len: Integer;
begin
  SeekScript(Stream);
  Obj := GetObjectType(Stream.Memory, Len, Error);
  Stream.Seek(Len, soCurrent);
  SeekScript(Stream);
  Obj := GetObjectType(Stream.Memory, Len, Error);
end;
{$O+}

procedure TFFScript.LoadOpcodes(const FileName: String);
var Stream: TScriptMemoryStream;
begin
  If not FileExists(FileName) Then
  begin
    CreateError('File %s does not exists!', [FileName]);
    Exit;
  end;
  Stream := TScriptMemoryStream.Create;
  Stream.LoadFromFile(FileName);
  LoadOpcodes(Stream);
  Stream.Free; 
end;

function TFFScript.SeekScript(var P: PChar): Integer;
begin
  Result := 0;
  While P[Result] <=#$20 do
    Inc(Result);
  Inc(P,Result);
end;

function TFFScript.SeekScript(Stream: TScriptMemoryStream): Integer;
var P: PChar;
begin
  P := Stream.Memory;
  Result := SeekScript(P);
  Stream.Seek(Result, soCurrent);
end;

{ TScriptMemoryStream }

function TScriptMemoryStream.GetCurMemory: Pointer;
begin
  Result := Pointer(LongWord(FMemory) + Self.Position);
end;

end.
