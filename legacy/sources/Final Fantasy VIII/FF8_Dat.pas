unit FF8_Dat;

interface

uses
  FF8_compression;

Type

  DWord = LongWord;
  TDatFile = Record
    Data: Pointer;
    Size: Integer;
  end;
  TDatFileType = (dfINF, dfCA, dfID, dfMAP, dfHz0, dfRAT, dfMRT, dfHz1, dfMSD, dfPMD (*PMP?*), dfJSM);

  TFF8DatFileList = Array[TDatFileType] of TDatFile;
  TFF8Dat = Class
    FAddress:  DWord;
    FFileList: TFF8DatFileList;
    procedure FreeMemory;
  public
    destructor Destroy; override;
    function LoadFromMemory(P: Pointer; _FileSize: Integer): Boolean;
    function LoadFromFile(const FileName: String): Boolean;
    Function  SaveToMemory(out OutSize: Integer; Compress: Boolean = True): Pointer;
    procedure SaveToFile(const FileName: String; Compress: Boolean = True);
    procedure ImportFile(FileID: TDatFileType; P: Pointer; Size: Integer);
    procedure ImportFileFromFile(FileID: TDatFileType; const FileName: String);
    procedure ExportFile(FileID: TDatFileType; out P: Pointer; out OutSize: Integer);
    procedure ExportFileToFile(FileID: TDatFileType; const FileName: String);
    function  DataSize: Integer;
    property  Files: TFF8DatFileList read FFileList;
  end;

implementation

{ TFF8Dat }

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If R = 0 Then Exit;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

function TFF8Dat.DataSize: Integer;
var n: TDatFileType;
begin
  Result := $30;
  For n := Low(FFileList) to High(FFileList) do
    Inc(Result, RoundBy(FFileList[n].Size, 4));
end;

destructor TFF8Dat.Destroy;
begin
  FreeMemory;
end;

procedure TFF8Dat.ExportFile(FileID: TDatFileType; out P: Pointer;
  out OutSize: Integer);
begin
  P := nil;
  OutSize := 0;
  With FFileList[FileID] do
  begin
    If Size > 0 Then
    begin
      GetMem(P, Size);
      Move(Data^, P^, Size);
    end;
  end;          
end;

procedure TFF8Dat.ExportFileToFile(FileID: TDatFileType;
  const FileName: String);
var F: File;
begin
  //If FFileList[FileID].Size = 0 Then Exit;
  AssignFile(F, FileName);
  Rewrite(F, 1);
  With FFileList[FileID] do
  begin
    If Size > 0 Then
      BlockWrite(F, Data^, Size);
  end;
  CloseFile(F);
end;

procedure TFF8Dat.FreeMemory;
var n: TDatFileType;
begin
  For n := Low(FFileList) to High(FFileList) do With FFileList[n] do
  begin
    If Data <> nil Then
    begin
      FreeMem(Data);
      Size := 0;
      Data := nil;
    end;
  end;
end;

procedure TFF8Dat.ImportFile(FileID: TDatFileType; P: Pointer; Size: Integer);
begin
  FFileList[FileID].Size := Size;
  With FFileList[FileID] do
  begin
    If Data <> nil Then
    begin
      FreeMem(Data);
      Data := nil;
    end;
    If Size > 0 Then
    begin
      GetMem(Data, Size);
      Move(P^, Data^, Size);
    end;
  end;                    
end;

procedure TFF8Dat.ImportFileFromFile(FileID: TDatFileType;
  const FileName: String);                                  
var F: File; Buf: Pointer; Size: Integer;
begin       
  AssignFile(F, FileName);
  Reset(F, 1);
  Size := FileSize(F);
  GetMem(Buf, Size);   
  BlockRead(F, Buf^, Size);
  CloseFile(F);
  ImportFile(FileID, Buf, Size);
  FreeMem(Buf);                 
end;

Function TFF8Dat.LoadFromFile(const FileName: String): Boolean;
var F: File; Buf: Pointer; Size: Integer;
begin
  AssignFile(F, FileName);
  Reset(F, 1);
  Size := FileSize(F);
  GetMem(Buf, Size);
  BlockRead(F, Buf^, Size);
  CloseFile(F);
  Result := LoadFromMemory(Buf, Size);
  FreeMem(Buf);
end;

var
  TempBuf: Array[0..1024 * 1024 - 1] of Integer;

Function TFF8Dat.LoadFromMemory(P: Pointer; _FileSize: Integer): Boolean;
var D: ^DWord; {Buf: Pointer;} Ptr: DWord; n: TDatFileType; i, _Size: Integer;
begin
  //Buf := nil;
  Result := False;
  D := P;
  If D^ = _FileSize - 4 Then
  begin
    //Compressed := True;
    //GetMem(Buf, 1024 * 1024 * 16);
    lzs_decompress(Pointer(DWord(P)+4), D^, @TempBuf, _Size);

    P := @TempBuf;
    D := @TempBuf;
  end;
  For i := Integer(Low(TDatFileType)) to Integer(High(TDatFileType)) + 1 do
  begin
    If D^ and $FF000000 <> $80000000 Then break;
    Inc(D);
  end;

  If i = Integer(High(TDatFileType)) + 2 Then
  begin
    D := P;
    FreeMemory;
    FAddress := D^ - $30;
    For n := Low(FFileList) to High(FFileList) do With FFileList[n] do
    begin

      Ptr := D^; Inc(D);
      Size := D^ - Ptr;
      
      //if n <> dfMSD Then Continue;
      
      If Size <> 0 Then
      begin
        //If Size > 1024 * 1024 div 2 Then Readln;
        GetMem(Data, Size);
        Move(Pointer(DWord(P) + Ptr - FAddress)^, Data^, Size);
      end;
    end;
    //If Buf <> nil Then FreeMem(Buf, 1024 * 1024 * 16);
  end;// else
    //If Buf <> nil Then FreeMem(Buf, 1024 * 1024 * 16);
  Result := True;
end;

procedure TFF8Dat.SaveToFile(const FileName: String; Compress: Boolean);
var F: File; Buf, CBuf: Pointer; Size: Integer;
begin
  Buf := SaveToMemory(Size, Compress);
  AssignFile(F, FileName);
  Rewrite(F, 1);
  BlockWrite(F, Buf^, Size);
  CloseFile(F);
  FreeMem(Buf);
end;

Function TFF8Dat.SaveToMemory(out OutSize: Integer; Compress: Boolean = True): Pointer;
var n: TDatFileType; D: ^DWord; Pos: DWord; P: ^Byte; Buf: Pointer;
begin
  OutSize := DataSize;
  GetMem(Result, OutSize);
  D := Result;
  P := Result;
  Inc(P, $30);
  For n := Low(TDatFileType) To High(TDatFileType) do With FFileList[n] do
  begin
    D^ := DWord(P) - DWord(Result) + FAddress;
    Inc(D);
    If Size > 0 Then
    begin
      Move(Data^, P^, Size);
      Inc(P, RoundBy(Size, 4));
    end;
  end;
  D^ := DWord(P) - DWord(Result) + FAddress;

  If Compress Then
  begin
    Buf := Result;
    GetMem(Result, OutSize + OutSize div 8 + 4);
    lzs_compress(Buf, OutSize, Result, OutSize);
    FreeMem(Buf);
    ReallocMem(Result, OutSize);
  end;
end;

end.
