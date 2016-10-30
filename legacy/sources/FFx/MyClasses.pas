unit MyClasses;

interface

uses
 SysUtils, Classes, NodeLst, IniFiles;

const
 PackBufSize = 8192;

 (* TCustomPackStream states *)
 PS_ERROR = -1;
 PS_PREPARE = 0;
 PS_BUFWRITE = 1;
 PS_FINISHED = 2;
 PS_CUSTOM = 3;
 (* TCustomPackStreamML states *)
 PS_ML_INIT = PS_CUSTOM;
 PS_ML_FILL_LIMIT = PS_CUSTOM + 1;
 PS_ML_SEARCH = PS_CUSTOM + 2;
 PS_ML_WRITE = PS_CUSTOM + 3;
 (* TCustomUnpackStream *)
 US_ERROR = -1;
 US_PREPARE = 0;
 US_FINISHED = 1;
 US_CUSTOM = 2;

type
 TStreamedNode = class(TNode)
  public
    procedure LoadFromStream(const Stream: TStream); virtual; abstract;
    procedure SaveToStream(const Stream: TStream); virtual; abstract;
    procedure LoadFromFile(const FileName: String);
    procedure SaveToFile(const FileName: String);
 end;

 TStreamedList = class(TNodeList)
  public
    procedure LoadFromStream(const Stream: TStream); virtual; abstract;
    procedure SaveToStream(const Stream: TStream); virtual; abstract;
    procedure LoadFromFile(const FileName: String);
    procedure SaveToFile(const FileName: String);
 end;

 (* Streams *)

 TSubStream = class(TStream)
  private
    FStream: TStream;
    FStreamPosition: Int64;
    FStreamSize: Int64;
    FCurPos: Int64;
  protected
    procedure SetSize(NewSize: Integer); override;
    procedure SetSize(const NewSize: Int64); override;
    function GetSize: Int64; override;
  public
    constructor Create; overload;
    constructor Create(Source: TStream; Size: Int64); overload;
    constructor Create(Source: TStream; Size: Int64; Position: Int64); overload;
    function Read(var Buffer; Count: Integer): Integer; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    function Write(const Buffer; Count: Integer): Integer; override;
 end;

 TBufferStream = class(TCustomMemoryStream)
  public
    constructor Create(Source: Pointer; Size: Integer);
    function Write(const Buffer; Count: Integer): Integer; override;
 end;

 TVarStringStream = class(TStream)
  private
    FStringPtr: PAnsiString;
    FPosition: Integer;
  protected
    procedure SetSize(NewSize: Integer); override;
    function GetSize: Int64; override;
  public
    constructor Create(AStringPtr: PAnsiString);  
    function Read(var Buffer; Count: Integer): Integer; override;
    function Write(const Buffer; Count: Integer): Integer; override;
    function Seek(Offset: Integer; Origin: Word): Integer; override;
 end;

 (* INI files*)

 TStreamIniFile = class(TMemIniFile)
  public
    constructor Create; overload;
    constructor Create(const Source: TStream); overload;
    procedure UpdateFile; override;
    procedure LoadFromStream(const Stream: TStream); virtual;
    procedure SaveToStream(const Stream: TStream); virtual;
    procedure LoadFromFile(const FileName: String);
    procedure SaveToFile(const FileName: String);
 end;

 (* Compression utils *)

 TPackMode = (pmCompress, pmDecompress);

 TCustomPackUnpackStream = class(TStream)
  protected
    FInput: PByte;
    FOutput: PByte;
    FRemainIn: Integer;
    FRemainOut: Integer;
    FTotalIn: Integer;
    FTotalOut: Integer;
    FStream: TStream;
    FStartPosition: Int64;
    FStreamPosition: Int64;
    FMode: TPackMode;
  private
    FBuffer: Pointer;
    FBufferSize: Integer;
    FOnProgress: TNotifyEvent;
    function GetCompressionRate: Single;
    function GetMode: TPackMode;
  protected
    property OnProgress: TNotifyEvent read FOnProgress write FOnProgress;

    procedure Progress(Sender: TObject); dynamic;
    procedure Reset; virtual; abstract;
  public
    property Buffer: Pointer read FBuffer;
    property BufferSize: Integer read FBufferSize;
    property Mode: TPackMode read GetMode;
    property CompressionRate: Single read GetCompressionRate;

    constructor Create(AStream: TStream; BufSize: Integer = PackBufSize);
    destructor Destroy; override;
 end;

 TCustomPackStream = class(TCustomPackUnpackStream)
  private
    FWriteLimit: Integer;
  protected
    FState: Integer;
    FErrorMessage: String;
    FBufStream: TMemoryStream;
    FBytesWritten: Integer;
    FFinalWrite: Boolean;
    function Compress: Integer; virtual; abstract;
    procedure FinishCompression; virtual; abstract;
    procedure WriteHeader; virtual; abstract;
    function GetSize: Int64; override;
    procedure SetSize(NewSize: Integer); override;
  public
    property State: Integer read FState write FState;
    property CompressedSize: Integer read FTotalOut;
    property BytesWritten: Integer read FBytesWritten;
    property OnProgress;

    constructor Create(Dest: TStream; AWriteLimit: Integer = -1);
    destructor Destroy; override;
    procedure Reset; override;
    function Seek(Offset: Integer; Origin: Word): Integer; override;
    function Read(var Buffer; Count: Integer): Integer; override;
    function Write(const Buffer; Count: Integer): Integer; override;
    procedure Finalize;
 end;

 TCustomPackStreamML = class(TCustomPackStream)
  private
    FMatchLimit: Integer;
    FStringBuf: array of Byte;
  protected
    FSrcPtr: PByte;  
    FMatchLength: Integer;
    FRemainInsert: Integer;
    function Compress: Integer; override;
    procedure CompressInit; virtual;
    function FillMatchLength: Boolean; virtual;
    function SearchState: Boolean; virtual;
    function WriteState: Boolean; virtual;
    procedure FinishCompression; override;
  public
    constructor Create(Dest: TStream; AMatchLimit: Integer;
                                      AWriteLimit: Integer = -1);
    procedure Reset; override;
 end;

 TCustomUnpackStream = class(TCustomPackUnpackStream)
  private
    FOutputSize: Integer;
    function ReadBytes: Integer;
  protected
    FState: Integer;
    FErrorMessage: String;
    FTotalRemain: Integer;
    function Decompress: Boolean; virtual; abstract;        
    function ReadHeader: Integer; virtual; abstract;
    procedure SetSize(NewSize: Integer); override;
    function GetSize: Int64; override;
    procedure SetPos(Offset: Integer); virtual;
  public
    property CompressedSize: Integer read FTotalIn;
    property OnProgress;

    constructor Create(Source: TStream);
    function Read(var Buffer; Count: Integer): Integer; override;
    function Write(const Buffer; Count: Integer): Integer; override;
    function Seek(Offset: Integer; Origin: Word): Integer; override;
    procedure Reset; override;
 end;

 (* Huffman compression utils *)

 TBitStream = packed record
  Bits: Cardinal;
  Size: Integer;
 end;

 TBitStreams = array of TBitStream;

 TDirection = (diNone, diLeft, diRight);

 PHuffTreeNode = ^THuffTreeNode;
 THuffTreeNode = packed record
  Direction: TDirection;
  Value: Integer;
  Count: Cardinal;
  Position: Integer;
  Left: PHuffTreeNode;
  Right: PHuffTreeNode;
  Next: PHuffTreeNode;
 end;

 TBranches = array of packed record
  Level: Integer;
  Node: PHuffTreeNode;
 end;

 THuffmanTree = class
  private
    FRoot: PHuffTreeNode;
    FCount: Integer;
    FLeavesCount: Integer;
    FBitStreams: TBitStreams;
    FBranches: TBranches;
    FTotalBitsCount: Int64;
    function AddNode: PHuffTreeNode;
    function Build: Boolean;
  public
    property Trunk: PHuffTreeNode read FRoot;
    property Branches: TBranches read FBranches;
    property BitStreams: TBitStreams read FBitStreams;
    property TotalBitsCount: Int64 read FTotalBitsCount;
    property LeavesCount: Integer read FLeavesCount;

    constructor Create(const FreqList: array of Cardinal);
    destructor Destroy; override;
 end;

(* Exception classes *)

 ESubStreamError = class(Exception);
 ECompressionError = class(Exception);
 EDecompressionError = class(Exception);

const
 SInvalidStreamOperation: PChar = 'Invalid stream operation';
 SInvalidInitialParameters: PChar = 'Invalid initial parameters';
 SInvalidSeekOrigin: PChar = 'Invalid seek origin';
 SMethodIsNotSupported: PChar = 'Method is not supported';
 SHeaderIsInvalid: PChar = 'Header is invalid'; 

implementation

(* TStreamedNode *)

procedure TStreamedNode.LoadFromFile(const FileName: String);
var Stream: TFileStream;
begin
 Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
 try
  LoadFromStream(Stream);
 finally
  Stream.Free;
 end;
end;

procedure TStreamedNode.SaveToFile(const FileName: String);
var Stream: TFileStream;
begin
 Stream := TFileStream.Create(FileName, fmCreate);
 try
  SaveToStream(Stream);
 finally
  Stream.Free;
 end;
end;

(* TStreamedList *)

procedure TStreamedList.LoadFromFile(const FileName: String);
var Stream: TFileStream;
begin
 Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
 try
  LoadFromStream(Stream);
 finally
  Stream.Free;
 end;
end;

procedure TStreamedList.SaveToFile(const FileName: String);
var Stream: TFileStream;
begin
 Stream := TFileStream.Create(FileName, fmCreate);
 try
  SaveToStream(Stream);
 finally
  Stream.Free;
 end;
end;

(* TSubStream *)

constructor TSubStream.Create(Source: TStream; Size: Int64);
begin
 If Assigned(Source) and (Size >= 0) then
 begin
  inherited Create;
  FStream := Source;
  FStreamSize := Size;
  FStreamPosition := Source.Position;
  FCurPos := 0;
 end Else raise ESubStreamError.Create(SInvalidInitialParameters);
end;

constructor TSubStream.Create(Source: TStream; Size: Int64;
  Position: Int64);
begin
 If Assigned(Source) and (Size >= 0) then
 begin
  inherited Create;
  FStream := Source;
  FStreamSize := Size;
  FStreamPosition := Position;
  FCurPos := 0;
 end Else raise ESubStreamError.Create(SInvalidInitialParameters);
end;

constructor TSubStream.Create;
begin
 raise ESubStreamError.Create(SInvalidInitialParameters);
end;

function TSubStream.GetSize: Int64;
begin
 Result := FStreamSize;
end;

function TSubStream.Read(var Buffer; Count: Integer): Integer;
var
 OldPos: Int64;
begin
 If (FCurPos >= 0) and (FCurPos < FStreamSize) then
 begin
  FStream.Position := FStreamPosition + FCurPos;
  Result := FStream.Read(Buffer, Count);
  OldPos := FCurPos;
  Inc(FCurPos, Result);
  If FCurPos > FStreamSize then
  begin
   Result := FStreamSize - OldPos;
   FCurPos := FStreamSize;
  end;
 end Else Result := 0;
end;

function TSubStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
 case Origin of
  soBeginning: FCurPos := Offset;
  soCurrent: Inc(FCurPos, Offset);
  soEnd: FCurPos := FStreamSize + Offset;
  else raise ESubStreamError.Create(SInvalidSeekOrigin);
 end;
 Result := FCurPos;
end;

procedure TSubStream.SetSize(const NewSize: Int64);
begin
 raise ESubStreamError.Create(SInvalidStreamOperation);
end;

procedure TSubStream.SetSize(NewSize: Integer);
begin
 raise ESubStreamError.Create(SInvalidStreamOperation);
end;

function TSubStream.Write(const Buffer; Count: Integer): Integer;
begin
 raise ESubStreamError.Create(SInvalidStreamOperation);
end;

(* TBufferStream *)

constructor TBufferStream.Create(Source: Pointer; Size: Integer);
begin
 SetPointer(Source, Size);
end;

function TBufferStream.Write(const Buffer; Count: Integer): Integer;
var
 Pos: Integer;
begin
 Pos := Position;
 if (Pos >= 0) and (Count >= 0) then
 begin
  Result := Size - Pos;
  if Result > 0 then
  begin
   if Result > Count then Result := Count;
   Move(Buffer, Pointer(Integer(Memory) + Pos)^, Result);
   Seek(Result, soFromCurrent);
   Exit;
  end;
 end;
 Result := 0;
end;

(* TVarStringStream *)

constructor TVarStringStream.Create(AStringPtr: PAnsiString);
begin
 FStringPtr := AStringPtr;
 FPosition := 0;
end;

function TVarStringStream.GetSize: Int64;
begin
 Result := Length(FStringPtr^);
end;

function TVarStringStream.Read(var Buffer; Count: Integer): Integer;
begin
 if (FPosition >= 0) and (Count >= 0) then
 begin
  Result := Length(FStringPtr^) - FPosition;
  if Result > 0 then
  begin
   if Result > Count then Result := Count;
   System.Move(FStringPtr^[FPosition + 1], Buffer, Result);
   Inc(FPosition, Result);
   Exit;
  end;
 end;
 Result := 0;
end;

function TVarStringStream.Seek(Offset: Integer; Origin: Word): Integer;
begin
 case Origin of
  soFromBeginning: FPosition := Offset;
  soFromCurrent: Inc(FPosition, Offset);
  soFromEnd: FPosition := Length(FStringPtr^) + Offset;
 end;
 Result := FPosition;
end;

procedure TVarStringStream.SetSize(NewSize: Integer);
begin
 SetLength(FStringPtr^, NewSize);
 if FPosition > NewSize then FPosition := NewSize;
end;

function TVarStringStream.Write(const Buffer; Count: Integer): Integer;
var
  Pos: Integer;
begin
 if (FPosition >= 0) and (Count >= 0) then
 begin
  Pos := FPosition + Count;
  if Pos > 0 then
  begin
   if Pos > Length(FStringPtr^) then SetLength(FStringPtr^, Pos);
   System.Move(Buffer, FStringPtr^[FPosition + 1], Count);
   FPosition := Pos;
   Result := Count;
   Exit;
  end;
 end;
 Result := 0;
end;

(* TStreamIniFile *)

constructor TStreamIniFile.Create;
begin
 inherited Create('');
end;

constructor TStreamIniFile.Create(const Source: TStream);
begin
 inherited Create('');
 LoadFromStream(Source);
end;

procedure TStreamIniFile.LoadFromFile(const FileName: String);
var
 Stream: TFileStream;
begin
 Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
 try
  LoadFromStream(Stream);
 finally
  Stream.Free;
 end;
end;

procedure TStreamIniFile.LoadFromStream(const Stream: TStream);
var
 List: TStringList;
begin
 List := TStringList.Create;
 try
  List.LoadFromStream(Stream);
  SetStrings(List);
 finally
  List.Free;
 end;
end;

procedure TStreamIniFile.SaveToFile(const FileName: String);
var
 Stream: TFileStream;
begin
 Stream := TFileStream.Create(FileName, fmCreate);
 try
  SaveToStream(Stream);
 finally
  Stream.Free;
 end;
end;

procedure TStreamIniFile.SaveToStream(const Stream: TStream);
var
 List: TStringList;
begin
 List := TStringList.Create;
 try
  GetStrings(List);
  List.SaveToStream(Stream);
 finally
  List.Free;
 end;
end;

procedure TStreamIniFile.UpdateFile;
begin
 raise EIniFileException.Create(SMethodIsNotSupported);
end;

(* TCustomPackUnpackStream *)

constructor TCustomPackUnpackStream.Create(AStream: TStream; BufSize: Integer);
begin
 FStream := AStream;
 FStartPosition := AStream.Position;
 FStreamPosition := FStartPosition;
 if BufSize > 0 then
  GetMem(FBuffer, BufSize);
 FBufferSize := BufSize;
 try
  Reset;
 except
  if FBuffer <> NIL then
   FreeMem(FBuffer);
  raise;
 end;
end;

destructor TCustomPackUnpackStream.Destroy;
begin
 if FBuffer <> NIL then
  FreeMem(FBuffer);
 inherited;
end;

function TCustomPackUnpackStream.GetCompressionRate: Single;
begin
 Result := 0;
 case FMode of
  pmCompress: if FTotalIn <> 0 then
   Result := (1.0 - (FTotalOut / FTotalIn)) * 100.0;
  pmDecompress: if FTotalOut <> 0 then
   Result := (1.0 - (FTotalIn / FTotalOut)) * 100.0;
 end;
end;

function TCustomPackUnpackStream.GetMode: TPackMode;
begin
 Result := FMode;
end;

procedure TCustomPackUnpackStream.Progress(Sender: TObject);
begin
 if Assigned(FOnProgress) then FOnProgress(Sender);
end;

(* TCustomPackStream *)

constructor TCustomPackStream.Create(Dest: TStream; AWriteLimit: Integer = -1);
begin
 FWriteLimit := AWriteLimit;
 FBufStream := TMemoryStream.Create;
 try
  inherited Create(Dest, 0);
  FMode := pmCompress;
 except
  FBufStream.Free;
  raise;
 end;
end;

destructor TCustomPackStream.Destroy;
begin
 try
  try
   Finalize;
  finally
   FBufStream.Free;
   inherited;
  end;
 except
  on E: Exception do
  begin
   FState := PS_ERROR;
   FErrorMessage := E.Message;
   Progress(Self);
  end;
 end;
end;

procedure TCustomPackStream.Finalize;
var
 L, Count: Integer;
 P: PByte;
begin
 if (FState <> PS_FINISHED) and
    (FState <> PS_ERROR) then
 begin
  FFinalWrite := True;
  FinishCompression;
  FStream.Position := FStartPosition;
  WriteHeader;
  FState := PS_BUFWRITE;
  FBytesWritten := 0;
  Count := FTotalOut;
  Inc(FTotalOut, 4);
  Progress(Self);
  P := FBufStream.Memory;
  while Count > 0 do
  begin
   if Count > 65536 then
    L := 65536 else
    L := Count;
   FStream.WriteBuffer(P^, L);
   Inc(P, L);
   Inc(FBytesWritten, L);
   Dec(Count, L);
   Progress(Self);
  end;
  FState := PS_FINISHED;
  Progress(Self);
  FBufStream.Clear;
 end;
end;

function TCustomPackStream.GetSize: Int64;
begin
 Result := FTotalIn;
end;

function TCustomPackStream.Read(var Buffer; Count: Integer): Integer;
begin
 FState := PS_ERROR;
 FErrorMessage := SInvalidStreamOperation;
 raise ECompressionError.Create(FErrorMessage);
end;

procedure TCustomPackStream.Reset;
begin
 FRemainOut := PackBufSize;
 FBufStream.Size := PackBufSize;
 FOutput := FBufStream.Memory;
 FStream.Position := FStartPosition;
 FTotalIn := 0;
 FTotalOut := 0;
 FState := PS_PREPARE;
 FFinalWrite := False;
end;

function TCustomPackStream.Seek(Offset: Integer; Origin: Word): Integer;
begin
 case Origin of
  soFromBeginning: Result := Offset;
  soFromCurrent,
  soFromEnd: Result := FTotalIn + Offset;
  else Result := FTotalIn;
 end;
 if Result < 0 then
 begin
 // unable to set position lower then zero
  FState := PS_ERROR;
  FErrorMessage := SInvalidStreamOperation;
  raise ECompressionError.Create(FErrorMessage);
 end else
 if (Result = 0) and (FTotalIn <= 0) then
  Reset (* Restarting compression *) else
  SetSize(Result);
end;

procedure TCustomPackStream.SetSize(NewSize: Integer);
var
 Count, SZ: Integer;
 Buffer: array[0..1023] of Byte;
begin
 if NewSize = FTotalIn then Exit else
 if NewSize > FTotalIn then
 begin
  FillChar(Buffer, SizeOf(Buffer), 0);
  Count := NewSize - FTotalIn;
  while Count > 0 do
  begin
   if Count >= SizeOf(Buffer) then
    SZ := SizeOf(Buffer) else
    SZ := Count;
   WriteBuffer(Buffer, SZ);
   Dec(Count, SZ);
  end;
 end else
 begin
  FState := PS_ERROR;
  FErrorMessage := SInvalidStreamOperation;
  raise ECompressionError.Create(FErrorMessage);
 end;
end;

function TCustomPackStream.Write(const Buffer; Count: Integer): Integer;
var
 SZ: Integer;
begin
 if (FState = PS_FINISHED) or (FState = PS_ERROR) then
 begin
  Result := 0;
  Exit;
 end;
 FInput := @Buffer;
 if FWriteLimit >= 0 then
 begin
  if FTotalIn + Count > FWriteLimit then
   Count := FWriteLimit - FTotalIn;
 end;
 if Count > 0 then
  FRemainIn := Count else
  FRemainIn := 0;
 Result := 0;
 try
  while FRemainIn > 0 do
  begin
   Inc(Result, Compress);
   if FRemainOut = 0 then
   begin
    SZ := FBufStream.Size;
    FBufStream.Size := SZ + PackBufSize;
    FOutput := FBufStream.Memory;
    Inc(FOutput, SZ);
    FRemainOut := PackBufSize;
    Progress(Self);
   end;
  end;
 except
  on E: Exception do
  begin
   FState := PS_ERROR;
   FErrorMessage := E.Message;
   raise;
  end;
 end;
end;

(* TCustomPackStreamML *)

function TCustomPackStreamML.Compress: Integer;
var
 RemainSave, ML: Integer;
begin
 RemainSave := FRemainIn;
 CompressInit;
 while FRemainOut > 0 do
 begin
  case FState of
   PS_ML_INIT:
   begin
    if FillMatchLength then
    begin
     Move(FInput^, FStringBuf[0], FMatchLength);
     Inc(FInput, FMatchLength);
     Inc(FTotalIn, FMatchLength);
     Dec(FRemainIn, FMatchLength);
    end else if FRemainIn < FMatchLimit then
    begin
     if FRemainInsert > 0 then
     begin
      Move(FSrcPtr^, FStringBuf[0], FRemainInsert);
      FMatchLength := FRemainInsert;
      ML := FMatchLimit - FRemainInsert;
      if ML > FRemainIn then ML := FRemainIn;
      FSrcPtr := Addr(FStringBuf[FRemainInsert]);
      if ML > 0 then
      begin
       Move(FInput^, FSrcPtr^, ML);
       Inc(FSrcPtr, ML);
       Inc(FMatchLength, ML);
       Inc(FInput, ML);
       Inc(FTotalIn, ML);
       Dec(FRemainIn, ML);
      end;
     end else
     begin
      FMatchLength := FRemainIn;
      FRemainIn := 0;
      FSrcPtr := Pointer(FStringBuf);
      Move(FInput^, FSrcPtr^, FMatchLength);
      Inc(FSrcPtr, FMatchLength);
      Inc(FInput, FMatchLength);
      Inc(FTotalIn, FMatchLength);
     end;
     if (FMatchLength < FMatchLimit) and not FFinalWrite then
     begin
      FState := PS_ML_FILL_LIMIT;
      Break;
     end;
    end else if FRemainInsert > 0 then
    begin
     Move(FSrcPtr^, FStringBuf[0], FRemainInsert);
     ML := FMatchLimit - FRemainInsert;
     FMatchLength := FRemainInsert;
     if ML > 0 then
     begin
      Move(FInput^, FStringBuf[FRemainInsert], ML);
      Inc(FInput, ML);
      Inc(FTotalIn, ML);
      Dec(FRemainIn, ML);
      Inc(FMatchLength, ML);
     end;
    end else
    begin
     FMatchLength := FMatchLimit;
     Move(FInput^, FStringBuf[0], FMatchLength);
     Inc(FInput, FMatchLength);
     Inc(FTotalIn, FMatchLength);
     Dec(FRemainIn, FMatchLength);
    end;
    FSrcPtr := Pointer(FStringBuf);
    FRemainInsert := FMatchLength;
    FState := PS_ML_SEARCH;
   end;
   PS_ML_FILL_LIMIT:
   begin
    if FMatchLength + FRemainIn >= FMatchLimit then
    begin
     ML := FMatchLimit - FMatchLength;
     if ML > 0 then
     begin
      Move(FInput^, FSrcPtr^, ML);
      Inc(FInput, ML);
      Inc(FTotalIn, ML);
      Dec(FRemainIn, ML);
     end;
     FMatchLength := FMatchLimit;
    end else if FRemainIn > 0 then
    begin
     Inc(FMatchLength, FRemainIn);
     Move(FInput^, FSrcPtr^, FRemainIn);
     Inc(FInput, FRemainIn);
     Inc(FTotalIn, FRemainIn);
     if not FFinalWrite then
     begin
      Inc(FSrcPtr, FRemainIn);
      FRemainIn := 0;
      Break;
     end else FRemainIn := 0;
    end else if not FFinalWrite then Break;
    FRemainInsert := FMatchLength;
    FSrcPtr := Pointer(FStringBuf);
    FState := PS_ML_SEARCH;
   end;
   PS_ML_SEARCH: if not SearchState then Break;
   PS_ML_WRITE:
   begin
    if not WriteState then Break;
    if FRemainIn <= 0 then Break;
   end;
  end;
 end;
 Result := RemainSave - FRemainIn;
end;

constructor TCustomPackStreamML.Create(Dest: TStream; AMatchLimit,
  AWriteLimit: Integer);
begin
 FMatchLimit := AMatchLimit;
 SetLength(FStringBuf, FMatchLimit);
 inherited Create(Dest, AWriteLimit);
end;

procedure TCustomPackStreamML.CompressInit;
begin
 (* do nothing *)
end;

function TCustomPackStreamML.FillMatchLength: Boolean;
begin
 Result := False;
end;

function TCustomPackStreamML.SearchState: Boolean;
begin
 FState := PS_ML_WRITE;
 Result := False;
end;

function TCustomPackStreamML.WriteState: Boolean;
begin
 FState := PS_ML_INIT;
 Result := False;
end;

procedure TCustomPackStreamML.Reset;
begin
 inherited;
 FMatchLength := 0;
 FRemainInsert := 0;
 FState := PS_ML_INIT;
end;

procedure TCustomPackStreamML.FinishCompression;
var
 L: Integer;
begin
 if FTotalIn > 0 then
 begin
  Compress;
  while FRemainInsert > 0 do
  begin
   if (FRemainOut = 0)  then
   begin
    L := FBufStream.Size;
    FBufStream.Size := L + 64;
    FOutput := FBufStream.Memory;
    Inc(FOutput, L);
    FRemainOut := 64;
   end;
   Compress;
  end;
 end;
end;

(* TCustomUnpackStream *)

constructor TCustomUnpackStream.Create(Source: TStream);
begin
 inherited Create(Source);
 FMode := pmDecompress;
end;

function TCustomUnpackStream.GetSize: Int64;
begin
 Result := FOutputSize;
end;

function TCustomUnpackStream.Read(var Buffer; Count: Integer): Integer;
begin
 FOutput := @Buffer;
 if Count > 0 then
  FRemainOut := Count else
  FRemainOut := 0;
 Result := 0;
 while (FRemainOut > 0) and (FState <> US_FINISHED) and (FState <> US_ERROR) do
 begin
  if FRemainIn = 0 then
  begin
   FStream.Position := FStreamPosition;
   FRemainIn := FStream.Read(Self.Buffer^, BufferSize);
   if FRemainIn = 0 then Exit;
   Inc(FStreamPosition, FRemainIn);
   FInput := Self.Buffer;
   Progress(Self);
  end;
  Inc(Result, ReadBytes);
 end;
end;

function TCustomUnpackStream.ReadBytes: Integer;
var
 RemainSave: Integer;
begin
 RemainSave := FRemainOut;
 while (FTotalRemain > 0) and (FRemainOut > 0) and Decompress do;
 if FTotalRemain <= 0 then FState := US_FINISHED;
 Result := RemainSave - FRemainOut;
end;

procedure TCustomUnpackStream.Reset;
begin
 FStream.Position := FStartPosition;
 FTotalIn := ReadHeader;
 if FTotalIn < 0 then raise EDecompressionError.Create(SHeaderIsInvalid);
 FTotalRemain := FOutputSize;
 FStreamPosition := FStartPosition + FTotalIn;
 FTotalOut := 0;
 FState := US_PREPARE;
end;

function TCustomUnpackStream.Seek(Offset: Integer; Origin: Word): Integer;
begin
 case Origin of
  soFromBeginning: Result := Offset;
  soFromCurrent: Result := FTotalOut + Offset;
  soFromEnd: Result := FOutputSize + Offset;
  else Result := FTotalOut;
 end;
 if (Result < 0) or (Result > FOutputSize) then
 begin
 // unable to set position lower then zero or
 // greater then decompressed data size
  FState := US_ERROR;
  FErrorMessage := SInvalidStreamOperation;
  raise EDecompressionError.Create(FErrorMessage);
 end else
 if Result > FTotalOut then
  SetPos(Result) else
 if (Result = 0) and (FTotalOut > 0) then
  Reset; (* Restarting decompression *)
end;

procedure TCustomUnpackStream.SetPos(Offset: Integer);
var
 Remain, L: Integer;
 Buf: array[0..1023] of Byte;
begin
 Remain := Offset - FTotalOut;
 while Remain > 0 do
 begin
  if Remain >= SizeOf(Buf) then
   L := SizeOf(Buf) else
   L := Remain;
  ReadBuffer(Buf[0], L);
  Dec(Remain, L);
 end;
end;

procedure TCustomUnpackStream.SetSize(NewSize: Integer);
begin
 FState := US_ERROR;
 FErrorMessage := SInvalidStreamOperation;
 raise EDecompressionError.Create(FErrorMessage);
end;

function TCustomUnpackStream.Write(const Buffer; Count: Integer): Integer;
begin
 FState := US_ERROR;
 FErrorMessage := SInvalidStreamOperation;
 raise EDecompressionError.Create(FErrorMessage);
end;

(* THuffmanTree *)

function THuffmanTree.AddNode: PHuffTreeNode;
begin
 New(Result);
 FillChar(Result^, SizeOf(THuffTreeNode), 0);
 Result.Value := -1;
 Result.Next := FRoot;
 FRoot := Result;
 Inc(FCount);
end;

function THuffmanTree.Build: Boolean;
(* THuffmanTree.Build local functions *)
function FindMin: PHuffTreeNode;
var
 I: Cardinal;
 P, N: PHuffTreeNode;
begin
 I := High(Cardinal);
 N := FRoot;
 P := NIL;
 while N <> NIL do with N^ do
 begin
  if I > Count then
  begin
   I := Count;
   P := N;
  end;
  N := Next;
 end;
 N := FRoot;
 if N = P then
 begin
  FRoot := N.Next;
  P.Next := NIL;
  Dec(FCount);
  Result := P;
  Exit;
 end;
 while N <> NIL do
 begin
  if P = N.Next then
  begin
   N.Next := P.Next;
   P.Next := NIL;
   Dec(FCount);
   Result := P;
   Exit;
  end;
  N := N.Next;
 end;
 Result := NIL;
end;
(* End of THuffmanTree.Build local functions *)
var
 A, B: PHuffTreeNode;
begin
 A := FindMin;
 B := FindMin;
 if B = NIL then
 begin
  FRoot := A;
  Result := False;
 end else
 begin
  Result := FRoot <> NIL;
  with AddNode^ do
  begin
   Left := B;
   Right := A;
   Left.Direction := diLeft;
   Right.Direction := diRight;
   Value := -1;
   Count := A.Count + B.Count;
  end;
 end;
end;

constructor THuffmanTree.Create(const FreqList: array of Cardinal);
(* THuffmanTree.Create local functions *)
procedure FillBitStream(Node: PHuffTreeNode; SZ: Integer; B: Cardinal);
begin
 if Node = NIL then Exit;
 with Node^ do
 begin
  if Value >= 0 then with FBitStreams[Value] do
  begin
   Bits := B;
   Size := SZ;
   Inc(FTotalBitsCount, Int64(SZ) * Int64(FreqList[Value]));
  end;
  if (Left <> NIL) and (Right <> NIL) then
  begin
   FillBitStream(Left, SZ + 1, B + B);
   FillBitStream(Right, SZ + 1, (B + B) or 1);
  end;
 end;
end; (* FillBitStream *)
procedure FillList(N: PHuffTreeNode; LV: Integer);
var
 L: Integer;
begin
 if N <> NIL then with N^ do if (Left <> NIL) and (Right <> NIL) then
 begin
  L := Length(FBranches);
  SetLength(FBranches, L + 1);
  with FBranches[L] do
  begin
   Node := N;
   Level := LV;
   FillList(Left, LV + 1);
   FillList(Right, LV + 1);
  end;
 end;
end; (* FillList *)
procedure SortList(L, R: Integer);
var
 I, J, X, Y: Integer;
 TempNode: PHuffTreeNode;
begin
 I := L;
 J := R;
 X := FBranches[(L + R) shr 1].Level;
 repeat
  while FBranches[I].Level < X do Inc(I);
  while X < FBranches[J].Level do Dec(J);
  if I <= J then
  begin
   if FBranches[I].Level <> FBranches[J].Level then
   begin
    with FBranches[I] do
    begin
     Y := Level;
     TempNode := Node;
    end;
    FBranches[I] := FBranches[J];
    with FBranches[J] do
    begin
     Level := Y;
     Node := TempNode;
    end;
   end;
   Inc(I);
   Dec(J);
  end;
 until I > J;
 if L < J then SortList(L, J);
 if I < R then SortList(I, R);
end; (* SortList *)
(* End of THuffmanTree.Create local functions *)
var
 I: Integer;
begin
 FRoot := NIL;
 FCount := 0;
 for I := 0 to Length(FreqList) - 1 do if FreqList[I] > 0 then with AddNode^ do
 begin
  Value := I;
  Count := FreqList[I];
 end;
 FLeavesCount := FCount;
 if FCount > 0 then
 begin
  while Build do;
  SetLength(FBitStreams, Length(FreqList));
  FillChar(FBitStreams[0], Length(FreqList) * SizeOf(TBitStream), 0);
  FTotalBitsCount := 0;
  FillBitStream(FRoot, 0, 0);
  FillList(FRoot, 1);
  SortList(0, Length(FBranches) - 1);
  for I := 0 to Length(FBranches) - 1 do with FBranches[I].Node^ do
  begin
   Left.Position := I;
   Right.Position := I;
  end;
  FRoot.Position := -1;
 end;
end;

destructor THuffmanTree.Destroy;
(* THuffmanTree.Destroy local functions *)
procedure FreeNodes(Node: PHuffTreeNode);
begin
 if Node <> NIL then
 begin
  FreeNodes(Node.Left);
  FreeNodes(Node.Right);
  Dispose(Node.Left);
  Dispose(Node.Right);
 end;
end; (* FreeNodes *)
(* End of THuffmanTree.Destroy local functions *)
var
 N: PHuffTreeNode;
begin
 while FRoot <> NIL do
 begin
  with FRoot^ do
  begin
   N := Next;
   FreeNodes(Left);
   Dispose(Left);
   FreeNodes(Right);
   Dispose(Right);
  end;
  Dispose(FRoot);
  FRoot := N;
 end;
 FCount := 0;
 Finalize(FBranches);
 Finalize(FBitStreams);
 inherited;
end;

end.
