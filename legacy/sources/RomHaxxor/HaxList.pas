unit HaxList;

interface

uses Windows, Classes, SysUtils, StrUtils;


Type
  TValueType = (vtByte, vtWord, vtDWord);
  TValueStatus = (vsOK, vsInvalidOffset, vsUnknown);
  TCreateError = Procedure(S: String);
  THaxValue  = Record
    Name:      String;
    Offset:    DWord;
    Source:    DWord;
    Value:     DWord;
    ValType:   TValueType;
    ValStat:   TValueStatus;
    BigEndian: Boolean;
  end;
  THaxValueList = Array of THaxValue;
  THaxList = Class
  private
    FCreateError: TCreateError;
    FList:        THaxValueList;
    FSaved:       Boolean;
    FFile:        File;
    FFileName:    String;
    FFileLoaded:  Boolean;
    Procedure CreateError(S: String);
    Function GetCount: Integer;
    function GetItem(Index: Integer): THaxValue;
    //Procedure SetItem(ID: Integer; Item: THaxValue);
  public
    Property  FileName: String read FFileName write FFileName;
    Property  Count: Integer read GetCount;
    //Property Items[Index: Integer]: THaxValue read GetItem;
    Property  Items: THaxValueList read FList write FList;
    Procedure Add(Name: String; Offset, Value: DWord; ValType: TValueType; BigEndian: Boolean = False); overload;
    Procedure Add(Value: THaxValue); overload;
    Procedure SaveToFile(Name: String; ID: Integer = 0);
    Function  LoadFromFile(Name: String): Integer;
    Procedure SetCreateError(CrErrProc: TCreateError);
    Procedure Change(ID1, ID2: Integer);
    Procedure Remove(ID: Integer);
    Procedure UpdateValues;
    Procedure UpdateValue(ID: Integer);
    Procedure SelectFile(Name: String);
    Procedure Clear;
    Procedure UpdateFile;
  end;

const
  cTypeLen:    Array[TValueType] of Integer = (1,2,4);
  cTypes:  Array[TValueType] of String  = ('Byte', 'Word', 'DWord');
  cEndian: Array[Boolean]    of String  = ('Little', 'Big');

implementation

Function GetEndian(V: DWord; ValType: TValueType): DWord;
var B,WB: ^Byte; Sz: Integer;
begin
  Case ValType of
    vtByte:  Sz := 1;
    vtWord:  Sz := 2;
    vtDWord: Sz := 4;
  end;
  If (Sz>4) or (Sz<1) Then Exit;
  B:=@V; Inc(B,Sz-1);
  WB:=@Result;
  While Sz>0 do
  begin
    WB^:=B^;
    Inc(WB); Dec(B); Dec(Sz);
  end;
end;

Procedure THaxList.Add(Name: String; Offset, Value: DWord; ValType: TValueType; BigEndian: Boolean = False);
var I: Integer;
begin
  I := Length(FList);
  SetLength(FList, I + 1);
  FList[I].Name      := Name;
  FList[I].ValType   := ValType;
  FList[I].Offset    := Offset;
  {If BigEndian Then
    FList[I].Value := GetEndian(Value, ValType)
  else}
  FList[I].Value := Value;
  FList[I].BigEndian := BigEndian;
end;

procedure THaxList.Add(Value: THaxValue);
var I: Integer;
begin
  I := Length(FList);
  SetLength(FList, I + 1);
  FList[I] := Value;
end;

procedure THaxList.Change(ID1, ID2: Integer);
var Value: THaxValue;
begin
  If (ID1<0) or (ID2<0) or (ID1>High(FList)) or (ID2>High(FList)) Then
  begin
    CreateError('THaxList.Change: Out of bounds!');
    Exit;
  end;
  Value := FList[ID1];
  FList[ID1] := FList[ID2];
  FList[ID2] := Value;
end;

procedure THaxList.Clear;
begin
  Finalize(FList);
end;

procedure THaxList.CreateError(S: String);
begin
 If @FCreateError <> nil Then FCreateError(S);
end;

function THaxList.GetCount: Integer;
begin
  Result := Length(FList);
end;


function THaxList.GetItem(Index: Integer): THaxValue;
begin
  If (Index < 0) or (Index > High(FList)) Then
  begin
    CreateError(Format('THaxList.GetItem: Out of bounds! (%d/%d)', [Index, High(FList)]));
    Exit;
  end;
  Result := FList[Index];
end;

Function CutString(S: String; Sep: Char; var Start: Integer): String;
var P: Integer;
begin
  Result := '';
  If Start > Length(S) Then Exit;
  P := PosEx(Sep, S, Start);
  If (P<=0) Then P := Length(S) + 1;
  If (Start>P) Then Exit;
  SetLength(Result, P - Start);
  Move(S[Start],Result[1], P - Start);
  Start := P + 1;
end;

Procedure GetLineValues(S: String; var VO,VN,VV,VT,VE: String);
var PosVal: Integer;
begin
  PosVal := 1;
  VN := CutString(S, '=', PosVal);
  VO := CutString(S, ';', PosVal);
  VV := CutString(S, ';', PosVal);
  VT := CutString(S, ';', PosVal);
  VE := CutString(S, ';', PosVal);
end;

function THaxList.LoadFromFile(Name: String): Integer;
var List: TStringList; n: Integer; S: String;
V, Code, Offset: Integer; VO,VV,VT,VN,VE: String; BigEndian: Boolean; ValType: TValueType;
PosVal: Integer;
begin
  If not FileExists(Name) Then
  begin
    CreateError(Format('File %s does not exist!',[Name]));
    Exit;
  end;
  List := TStringList.Create;
  List.LoadFromFile(Name);
  Clear;
  V := 6;
  If Pos('file=',List.Strings[0])=1 Then
    FFileName := CutString(List.Strings[0], '=', V)
  else
    CreateError(Format('Invalid input line: %s',[List.Strings[0]]));
  V := 7;
  If Pos('index=',List.Strings[1])=1 Then
    Result := StrToInt(CutString(List.Strings[1],'=',V))
  else
    CreateError(Format('Invalid input line: %s',[List.Strings[1]]));  
  For n:=2 To List.Count - 1 do
  begin
    S := List.Strings[n];
    If S='' Then Continue;
    GetLineValues(S, VO,VN,VV,VT,VE);
    Val('$'+VV, V, Code);
    If Code<>0 Then
    begin
      CreateError(Format('Hex->Int error! (%s)',[VV]));
      V := 0;
    end;
    Val('$'+VO, Offset, Code);
    If Code<>0 Then
    begin
      CreateError(Format('Hex->Int error! (%s)',[VO]));
      Offset := 0;
    end;
    If      VT = 'Byte'  Then
      ValType := vtByte
    else If VT = 'Word'  Then
      ValType := vtWord
    else If VT = 'DWord' Then
      ValType := vtDWord
    else
    begin
      CreateError(Format('Unknown value type - %s',[VT]));
      ValType := vtByte;
    end;
    If      VE = 'Big' Then
      BigEndian := True
    else If VE = 'Little' Then
      BigEndian := False
    else
    begin
      CreateError(Format('Unknown endian type - %s',[VE]));
      BigEndian := False;
    end;
    Add(VN, Offset, V, ValType,BigEndian);
  end;
end;

procedure THaxList.Remove(ID: Integer);
var n: Integer;
begin
  For n:=ID to High(FList) - 1 do
    FList[n] := FList[n + 1];
  SetLength(FList, High(FList));
end;

procedure THaxList.SaveToFile(Name: String; ID: Integer = 0);
var List: TStringList; n: Integer;
begin
  List := TStringList.Create;
  List.Add(Format('file=%s',[FFileName]));
  List.Add(Format('index=%d',[ID]));
  For n:=0 To High(FList) do With FList[n] do
    List.Add(Format('%s=%8.8x;%8.8x;%s;%s',[Name,Offset,Value,cTypes[ValType],cEndian[BigEndian]]));
  List.SaveToFile(Name);
  List.Free; 
end;

procedure THaxList.SelectFile(Name: String);
begin
  FFileName := Name;
end;

procedure THaxList.SetCreateError(CrErrProc: TCreateError);
begin
  @FCreateError := @CrErrProc;
end;

procedure THaxList.UpdateValue(ID: Integer);
var F: File; Size: Integer; Exists: Boolean;
begin
  If (ID<0) or (ID>High(FList)) Then
  begin
    CreateError(Format('THaxList.UpdateValue: Array out of bounds! (%d/%d)',[ID,High(FList)]));
    Exit;
  end;
  Exists := FileExists(FFileName);
    //CreateError(Format('File %s does not exist!',[FFileName]));
  If Exists Then
  begin
    AssignFile(F, FFileName);
    Reset(F,1);
    Size := FileSize(F);
  end;
  With FList[ID] do
  begin
    If Exists Then
    begin
      If (Offset >= 0) and (Offset + cTypeLen[ValType] <= Size) Then
      begin
        Source := 0;
        Seek(F, Offset);
        BlockRead(F, Source, cTypeLen[ValType]);
        ValStat := vsOK;
        If BigEndian Then Source := GetEndian(Source, ValType);
      end else
        ValStat := vsInvalidOffset;
    end else
      ValStat := vsUnknown;
  end;
  If Exists Then CloseFile(F);
end;

procedure THaxList.UpdateValues;
var F: File; n, Size: Integer; Exists: Boolean;
begin
  Exists := FileExists(FFileName);
  If Exists Then
  begin
    AssignFile(F, FFileName);
    Reset(F,1);
    Size := FileSize(F);
  end;
  For n:=0 To High(FList) do With FList[n] do
  begin
    If Exists Then
    begin
      If (Offset >= 0) and (Offset + cTypeLen[ValType] <= Size) Then
      begin
        Source := 0;
        Seek(F, Offset);
        BlockRead(F, Source, cTypeLen[ValType]);
        ValStat := vsOK;
        If BigEndian Then Source := GetEndian(Source, ValType);
      end else
        ValStat := vsInvalidOffset;
    end else
      ValStat := vsUnknown;
  end;
  If Exists Then CloseFile(F);
end;

procedure THaxList.UpdateFile;
var F: File; n, Size: Integer; Exists: Boolean;  V: Integer;
begin
  If not FileExists(FFileName) Then Exit;
  AssignFile(F, FFileName);
  Reset(F,1);
  Size := FileSize(F);
  For n:=0 To High(FList) do With FList[n] do
  begin
    If (Offset >= 0) and (Offset + cTypeLen[ValType] <= Size) Then
    begin
      V := 0;
      If BigEndian Then V := GetEndian(Value, ValType)
      else V := Value;
      Seek(F, Offset);
      BlockWrite(F, V, cTypeLen[ValType]);
    end;
  end;
  CloseFile(F);
end;

end.
