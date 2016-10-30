unit EPaster;

interface

uses Classes, EP_GBA;

Type
  TErrorType = (etLog, etHint, etWarning, etError);
  TCreateError = Procedure(const S: string; Level: TErrorType = etError);
  {ECreateError = Class(EAbort)
    constructor Create(S: String; ErrorProc: TCreateError = nil); overload;
    constructor Create(S: String; const Args: Array of const; ErrorProc: TCreateError = nil); overload;
  end;}


  TExtraPaster = Class;
  TPaster = TExtraPaster;
  TSpaceBlock = Record
    Offset: LongWord;
    Size:   Integer;
  end;
  TSpace = Array of TSpaceBlock;
  TPasteType = (ptError = -1, ptPtrs, ptOffset);
  TConvType = (ctError = -1, ctConv, ctSrc, ctSystem);
  TConvProc = function(var Data: Pointer; var Size: Integer; Line: String; Paster: TPaster): Boolean;
  TProcItem = Record
    Name: String;
    Proc: TConvProc;
    Conv: TConvType;
  end;
  TProcList = Array of TProcItem;

  TPasterData = Record
   Data:    Pointer;
   Size:    Integer;
   Conv:    TConvType;
   Num:     Integer;
   Align:   Integer;
   WordDir: String;
   PtrDef:  Integer;
   PtrSize: Integer;
   Line:    String;
  end;

  TPasterStack = Array of TPasterData;

  TExtraPaster = Class
  private
    FPop:         Boolean;
    FSpace:       TSpace;
    FCurData:     Pointer;
    FCurSize:     Integer;
    FCurConv:     TConvType;
    FCurNum:      Integer;
    FAlign:       Integer;
    FWorkDir:     String;
    FPtrDef:      Integer;
    FPtrSize:     Integer;
    FLevel:       Integer;
    FFileStream:  TFileStream;
    FFileName:    String;
    FStack:       TPasterStack;
    FProcList:    TProcList;
    FScript:      TStringList;
    FErrorString: String;
    FErrorLine:   Integer;
    procedure   AddProc(Proc: TConvProc; Name: String; Conv: TConvType = ctConv);
    function    GetProc(Index: String): TConvProc;
    procedure   SetProc(Index: String; const Value: TConvProc);
    function    FindProc(Name: String): Integer;
    function    WriteData(Line: String): Boolean;
    function    ExecuteAdditional(const Line: String; var S: String): TPasteType;
    procedure   Push(Line: String = '');
    Procedure   Pop(var Line: String);
  public
    constructor Create;
    destructor  Destroy;
    procedure   Initialize;
    procedure   LoadScript(FileName: String);
    procedure   LoadScriptFromString(Str: String);
    Function    Execute(var Line: String): Boolean;
    function    Run: Integer;
    procedure   AddSpace(const Offset, Size: Integer);
    procedure   RemoveSpace(Index: Integer);
    property    Proc[Index: String]: TConvProc read GetProc write SetProc;
    property    ErrorString: String Read FErrorString;
    property    ErrorLine:   Integer read FErrorLine;
  end;

function RoundBy(const V, R: Integer): Integer;
function GetParam(Index: Integer; const S: String): string;
implementation

{ ETableError }

{constructor ECreateError.Create(S: String; ErrorProc: TCreateError = nil);
begin
  If @ErrorProc <> nil Then ErrorProc(S);
end;

constructor ECreateError.Create(S: String; const Args: array of const; ErrorProc: TCreateError);
begin
  If @ErrorProc <> nil Then ErrorProc(Format(S,Args));
end;}

{$INCLUDE EP_Common_inc.pas}

{ TExtraPaster }

procedure TExtraPaster.AddProc(Proc: TConvProc; Name: String; Conv: TConvType = ctConv);
var Count: Integer;
begin
  Count := Length(FProcList);
  SetLength(FProcList, Count + 1); 
  FProcList[Count].Proc := Proc;
  FProcList[Count].Name := Name;
  FProcList[Count].Conv := Conv;
end;

procedure TExtraPaster.AddSpace(const Offset, Size: Integer);
var Count, n: Integer;
begin
  {
  For n := 0 To High(FSpace) do
  begin
    If FSpace[n].Offset
  end;
  }
  Count := Length(FSpace);
  SetLength(FSpace, Count + 1);
  FSpace[Count].Offset := Offset;
  FSpace[Count].Size   := Size;
end;

constructor TExtraPaster.Create;
begin
  FScript := TStringList.Create;
  FAlign  := 1;
  Initialize;
end;

destructor TExtraPaster.Destroy;
begin
  FScript.Free;
  If FCurData <> nil Then FreeMem(FCurData);
  If FFileStream <> nil Then FFileStream.Free;
end;

function TExtraPaster.Execute(var Line: String): Boolean;
var n: Integer; Data: Pointer; Size: Integer; ConvType: TConvType;
begin
  Result := False;
  Data := nil;
  Size := 0;
  If (Line <> '') and (Line[1] <> ';') Then n := FindProc(GetParam(0, Line));
  If n = -1 Then
  begin
    FErrorString := 'Unknown instruction!';
    Exit;
  end;
  Data := FCurData;

  If (FLevel > 0) and (FCurNum > 0) Then
  begin
    Case FProcList[n].Conv {FCurConv} of
      ctSrc:
      begin
        Result := FProcList[n].Proc(Data, Size, Line, Self);
        ReallocMem(FCurData, Size + FCurSize);
        Move(Data^, Pointer(LongWord(FCurData)+FCurSize)^, Size);
        Inc(FCurSize, Size);
        FreeMem(Data);
      end;
      ctConv, ctSystem: Result := FProcList[n].Proc(FCurData, FCurSize, Line, Self);
    end;
    If FPop Then
    begin
      //FPop := False;
      Data := FCurData;
      Size := FCurSize;
      Pop(Line);
      Result := True;
      If FCurData <> nil Then
      begin
        ReallocMem(FCurData, Size + FCurSize);
        Move(Data^, Pointer(LongWord(FCurData)+FCurSize)^, Size);
        Inc(FCurSize, Size);
        FreeMem(Data);
      end else
      begin
        FCurData := Data;
        FCurSize := Size;
      end;
    end;
  end else
    Result := FProcList[n].Proc(FCurData, FCurSize, Line, Self);
  If FProcList[n].Conv <> ctSystem Then
    Inc(FCurNum);
end;

function TExtraPaster.ExecuteAdditional(const Line: String; var S: String): TPasteType;
var n, Len: Integer; P: String;
begin
  S := '';
  Result := ptError;
  For n := 1 To Length(Line) do
    If Line[n] = '@' Then
      break;
  Inc(n);
  If n > Length(Line) Then Exit;
  P := GetParam(0, PChar(@Line[n]));
  If P = 'ptrs:' Then
  begin
    Inc(n, 5);
    Result := ptPtrs;
  end else
  If P = 'offs:' Then
  begin              
    Inc(n, 5);
    Result := ptOffset;
  end;

  If Result = ptError Then Exit;

  Len := Length(Line) - n + 1;
  SetLength(S, Len);
  Move(Line[n], S[1], Len);

end;

function TExtraPaster.FindProc(Name: String): Integer;
begin
  For Result := 0 To High(FProcList) do
    If FProcList[Result].Name = Name Then
      Exit;
  If Result >= Length(FProcList) Then Result := -1;
end;

function TExtraPaster.GetProc(Index: String): TConvProc;
var n: Integer;
begin
  Result := nil;
  n := FindProc(Index);
  If n = -1 Then Exit;
  Result := @FProcList[n].Proc;
end;

procedure TExtraPaster.Initialize;
begin
  AddProc(@EP_AddSpace, 'addspace', ctSystem);
  AddProc(@EP_Chain,    'chain',    ctSystem);
  AddProc(@EP_Stream,   'stream',   ctSystem);
  AddProc(@EP_ClrSpace, 'clrspace', ctSystem);
  AddProc(@EP_End,      'end',      ctSystem);
  AddProc(@EP_PtrDef,   'ptrdef',   ctSystem);
  AddProc(@EP_PtrSize,  'ptrsize',  ctSystem);
  AddProc(@EP_DestFile, 'destfile', ctSystem);
  AddProc(@EP_WorkDir,  'workdir',  ctSystem);
  AddProc(@EP_Align,    'align',    ctSystem);

  AddProc(@EP_File, 'file', ctSrc);
  AddProc(@EP_Word, 'word', ctSrc);
  AddProc(@EP_Byte, 'byte', ctSrc);
  AddProc(@EP_DWord,'dword', ctSrc);

  AddProc(@EP_TstInc,'tstinc', ctConv);
end;

procedure TExtraPaster.LoadScript(FileName: String);
begin
  FScript.LoadFromFile(FileName);
end;


procedure TExtraPaster.LoadScriptFromString(Str: String);
begin
  FScript.Text := Str;
end;

procedure TExtraPaster.Pop(var Line: String);
var Count: Integer;
begin
  Count := High(FStack);
  If Count < 0 Then Exit;
  With FStack[Count] do
  begin
    FCurData := Data;
    FCurSize := Size;
    FCurConv := Conv;
    FCurNum  := Num;
    FAlign   := Align;
    FWorkDir := WordDir;
    FPtrDef  := PtrDef;
    FPtrSize := PtrSize;
  end;
  Line := FStack[Count].Line;
  SetLength(FStack, Count);
  Dec(FLevel);
end;

procedure TExtraPaster.Push;
var Count: Integer;
begin
  Count := Length(FStack);
  SetLength(FStack, Count + 1);
  FStack[Count].Line := Line;
  With FStack[Count] do
  begin
    Data    := FCurData;
    Size    := FCurSize;
    Conv    := FCurConv;
    Num     := FCurNum;
    Align   := FAlign;
    WordDir := FWorkDir;
    PtrDef  := FPtrDef;
    PtrSize := FPtrSize;
  end;

  FCurNum := 0;
  Inc(FLevel);
end;

procedure TExtraPaster.RemoveSpace(Index: Integer);
var n: Integer;
begin
  If (Index < 0) or (Index > High(FSpace)) Then Exit;
  For n := Index to High(FSpace) - 1 do
    FSpace[n] := FSpace[n + 1];
  SetLength(FSpace, Length(FSpace) - 1);
end;

function TExtraPaster.Run: Integer;
var n, Num: Integer; S: String;
Size: Integer; Data: Pointer;
begin
  Result := 0;
  For n := 0 To FScript.Count - 1 do
  begin
    S := FScript.Strings[n];
    Num := FindProc(GetParam(0, S));
    FErrorString := '';
    If (S = '') or (S[1] = ';') Then Continue;
    case FProcList[Num].Conv of
      ctSystem: Result := Integer(not Execute(S));
      ctError:  Inc(Result);
      ctConv:
      begin
        If (FCurConv <> ctConv) and (FCurNum > 0)Then
          FErrorString := 'The function is not appropriate type of block!'
        else If (FCurNum = 0) Then
          FErrorString := 'The first should be a function-source!'
        else If FLevel = 0 Then
          FErrorString := 'This function must be used in block!'
        else If FCurData = nil Then
          FErrorString := 'Data is nil!';

        If FErrorString <> '' Then
        begin
          Inc(Result);
          break;
        end else
          Result := Integer(not Execute(S));

      end;
      ctSrc: Result := Integer(not Execute(S));
    end;
    If Result > 0 Then
    begin
      FErrorLine := n + 1;
      Exit;
    end;
    case FProcList[Num].Conv of
      ctSystem:
      If not FPop Then
        Continue
      else
        FPop := False;
    end;
    If (FLevel = 0) and (FCurData <> nil) Then
    begin
      WriteData(S);
      FreeMem(FCurData);
      FCurData := nil;
      FCurSize := 0;
    end;
    //
  end;
end;

procedure TExtraPaster.SetProc(Index: String; const Value: TConvProc);
var n: Integer;
begin
  n := FindProc(Index);
  If n = -1 Then Exit;
  FProcList[n].Proc := @Value;
end;

function TExtraPaster.WriteData(Line: String): Boolean;
var n, Off, PtrOff, Code, Num, Ptr: Integer; P, S: String;
begin
  Result := False;
  Off := -1;      
  Num := 0;

  If FFileStream = nil Then Exit;
  case ExecuteAdditional(Line, S) of
    ptPtrs:
    begin
      For n := 0 To High(FSpace) do
      begin
        If FSpace[n].Size >= FCurSize Then
        begin
          Off := FSpace[n].Offset;
          Ptr := Off - FPtrDef;
          Inc(FSpace[n].Offset, RoundBy(FCurSize, FAlign));
          Dec(FSpace[n].Size, FSpace[n].Offset - Off);
          Break;
        end;
      end;                  
      While True do
      begin
        P := GetParam(Num, S);
        If P = '' Then break;
        Val('$' + P, PtrOff, Code);
        If Code <> 0 Then Exit;
        Inc(Num);
        FFileStream.Seek(PtrOff, soBeginning);
        FFileStream.Write(Ptr, FPtrSize);
      end;
      If n >= Length(FSpace) Then Exit;
      If FSpace[n].Size <= 0 Then RemoveSpace(n);
      FFileStream.Seek(Off, soBeginning);
      FFileStream.Write(FCurData^, FCurSize);
    end;
    ptOffset:
    begin                
      While True do
      begin
        P := GetParam(Num, S);
        If P = '' Then break;
        Val('$' + P, Off, Code);
        If Code <> 0 Then Exit;
        Inc(Num);
        FFileStream.Seek(Off, soBeginning);
        FFileStream.Write(FCurData^, FCurSize);
      end;
    end;
  end;
  If Off < 0 Then Exit;


  Result := True;
end;

end.
