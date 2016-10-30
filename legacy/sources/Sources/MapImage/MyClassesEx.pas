unit MyClassesEx;

interface

uses
 Windows, SysUtils, TntSysUtils, Classes, TntClasses, NodeLst, PlugInterface;

type
 TPathInspector = class;
 TProcessProc = procedure(const Path: WideString; const SR: TSearchRecW);
 TProcessEvent = procedure(Sender: TPathInspector;
                           const Path: WideString;
                           const SR: TSearchRecW) of Object;

 TPathInspector = class
  private
    FPath: WideString;
    FMask: WideString;
    FFileAttr: Integer;
    FProcessSubFolders: Boolean;
    FOnProcess: TProcessEvent;
    FProcessProc: TProcessProc;
    procedure SetPath(Value: WideString);
  protected
    procedure ProcessFile(const Path: WideString; const SR: TSearchRecW); virtual;
    procedure Initialize; virtual;
  public
    property InitialPath: WideString
        read FPath
       write SetPath;
    property Mask: WideString
        read FMask
       write FMask;
    property FileAttr: Integer
        read FFileAttr
       write FFileAttr;
    property ProcessSubFolders: Boolean
        read FProcessSubFolders
       write FProcessSubFolders;
    property ProcessProc: TProcessProc
        read FProcessProc
       write FProcessProc;
    property OnProcess: TProcessEvent
        read FOnProcess
       write FOnProcess;

    procedure Run;
    constructor Create; overload;
    constructor Create(const Path, Mask: WideString; ProcessSubFolders: Boolean;
      Attr: Integer = faArchive or faReadOnly or faHidden); overload;
    destructor Destroy; override;
 end;

 TUTF8StringList = class(TTntStringList)
  public
    procedure SaveToStream_BOM(Stream: TStream; WithBOM: Boolean); override;
 end;

 TNodeListEx = class(TNodeList)
  public
    procedure LoadFromStream(const Stream: TStream); virtual; abstract;
    procedure SaveToStream(const Stream: TStream); virtual; abstract;
    procedure LoadFromFile(const FileName: WideString);
    procedure SaveToFile(const FileName: WideString);    
 end;

 TStreamAdapter = class(TInterfacedObject, IStream32, IStream64)
  private
    FSource: TStream;
    FFreeAfterUse: Boolean;
    function GetPtr: Pointer; stdcall;
    function Read(var Buffer; Count: Integer): Integer; stdcall;
    function Write(const Buffer; Count: Integer): Integer; stdcall;
    function GetPos: Integer; stdcall;
    function GetPos64: Int64; stdcall;
    function IStream64.GetPos = GetPos64;
    function GetSize: Integer; stdcall;
    function GetSize64: Int64; stdcall;
    function IStream64.GetSize = GetSize64;
    procedure SetPos(Value: Integer); stdcall;
    procedure SetPos64(const Value: Int64); stdcall;
    procedure IStream64.SetPos = SetPos64;
    procedure SetSize(Value: Integer); stdcall;
    procedure SetSize64(const Value: Int64); stdcall;
    procedure IStream64.SetSize = SetSize64;
    procedure Seek(Offset, SeekOrigin: Integer); stdcall;
    procedure Seek64(const Offset: Int64; SeekOrigin: Integer); stdcall;
    procedure IStream64.Seek = Seek64;
    function CopyFrom(const Stream: IReadWrite; Count: Integer): Integer;
      stdcall;
    function CopyFrom64(const Stream: IReadWrite;
      const Count: Int64): Int64; stdcall;
    function IStream64.CopyFrom = CopyFrom64;
    procedure FreeObject; stdcall;
  public
    constructor Create(Source: TStream; FreeAfterUse: Boolean = False);
    destructor Destroy; override;
 end;

 TClassListItem = class(TNode)
  private
    FClass: TClass;
  protected
    procedure Initialize; override;  
  public
    property AClass: TClass read FClass;

    constructor Create(AClass: TClass);
    procedure Assign(Source: TNode); override;
 end;

 TClassList = class(TNodeList)
  private
    function GetClass(Index: Integer): TClassListItem;
  protected
    procedure Initialize; override;
    procedure AssignAdd(Source: TNode); override;
  public
    property Classes[Index: Integer]: TClassListItem read GetClass;

    function AddClass(AClass: TClass): TClassListItem;
    procedure RegisterClasses(const AList: array of TClass);
    function Find(const Name: String): TClassListItem; overload;
    function Find(ClType: TClass): TClassListItem; overload;
 end;

 EClassListError = class(Exception);

 TStringsAdapter = class(TInterfacedObject, IStringList, IWideStringList)
  private
    FTempA: AnsiString;
    FTempW: WideString;
    FSourceA: TStringList;
    FSourceW: TTntStringList;
    FFreeAfterUse: Boolean;
    function GetString(Index: Integer): PAnsiChar; stdcall;
    function GetStringW(Index: Integer): PWideChar; stdcall;
    function IWideStringList.GetString = GetStringW;
    procedure SetString(Index: Integer; Value: PAnsiChar); stdcall;
    procedure SetStringW(Index: Integer; Value: PWideChar); stdcall;
    procedure IWideStringList.SetString = SetStringW;
    function GetText: PAnsiChar; stdcall;
    function GetTextW: PWideChar; stdcall;
    function IWideStringList.GetText = GetTextW;
    procedure SetText(Value: PAnsiChar); stdcall;
    procedure SetTextW(Value: PWideChar); stdcall;
    procedure IWideStringList.SetText = SetTextW;    
    function Add(S: PAnsiChar): Integer; stdcall;
    function AddW(S: PWideChar): Integer; stdcall;
    function IWideStringList.Add = AddW;
    procedure Append(S: PAnsiChar); stdcall;
    procedure AppendW(S: PWideChar); stdcall;
    procedure IWideStringList.Append = AppendW;
    function Find(S: PAnsiChar; var Index: Integer): LongBool; stdcall;
    function FindW(S: PWideChar; var Index: Integer): LongBool; stdcall;
    function IWideStringList.Find = FindW;
    function IndexOf(S: PAnsiChar): Integer; stdcall;
    function IndexOfW(S: PWideChar): Integer; stdcall;
    function IWideStringList.IndexOf = IndexOfW;
    procedure Insert(Index: Integer; S: PAnsiChar); stdcall;
    procedure InsertW(Index: Integer; S: PWideChar); stdcall;
    procedure IWideStringList.Insert = InsertW;
    procedure Delete(Index: Integer); stdcall;
    procedure Exchange(Index1, Index2: Integer); stdcall;
    procedure Move(CurIndex, NewIndex: Integer); stdcall;
    procedure Sort; stdcall;
    procedure AddStrings(const Strings: IStrings); stdcall;
    procedure Assign(const Source: IStrings); stdcall;
    function Equals(const Strings: IStrings): LongBool; stdcall;
    procedure LoadFromStream(const Stream: IReadWrite); stdcall;
    procedure SaveToStream(const Stream: IReadWrite); stdcall;
    function GetCount: Integer; stdcall;
    procedure Clear; stdcall;
    function GetPtr: Pointer; stdcall;
    procedure FreeObject; stdcall;
  public
    constructor Create; overload;
    constructor Create(Source: TTntStringList; FreeAfterUse: Boolean = False); overload;
    constructor Create(Source: TStringList; FreeAfterUse: Boolean = False); overload;
    destructor Destroy; override;
 end;

implementation

Uses MyUtils;

constructor TPathInspector.Create;
begin
 Initialize;
 InitialPath := WideGetCurrentDir;
 FMask := '*.*';
end;

constructor TPathInspector.Create(const Path, Mask: WideString;
                                  ProcessSubFolders: Boolean; Attr: Integer);
begin
 Initialize;
 InitialPath := Path;
 FMask := Mask;
 FFileAttr := Attr;
 FProcessSubFolders := ProcessSubFolders;
end;

destructor TPathInspector.Destroy;
begin
 Finalize(FPath);
 Finalize(FMask);
 inherited;
end;

procedure TPathInspector.Initialize;
begin
 FFileAttr := faArchive or faHidden or faReadOnly;
end;

procedure TPathInspector.ProcessFile(const Path: WideString;
                                       const SR: TSearchRecW);
begin
 If Assigned(FOnProcess) then FOnProcess(Self, Path, SR);
 If Assigned(FProcessProc) then FProcessProc(Path, SR);
end;

procedure TPathInspector.Run;
procedure Process(const Pattern: WideString);
Var PDir, Mask: WideString; SR: TSearchRecW;
begin
 PDir := WideExtractFilePath(Pattern);
 Mask := WideExtractFileName(Pattern);
 If WideFindFirst(Pattern, FFileAttr, SR) = 0 then
 begin
  Repeat
   ProcessFile(PDir, SR);
  Until WideFindNext(SR) <> 0;
  WideFindClose(SR);
 end;
 If FProcessSubFolders and (WideFindFirst(PDir+'*.*', faDirectory, SR) = 0) then
 begin
  Repeat
   If (SR.Attr and faDirectory <> 0) and
      (SR.Name <> '.') and (SR.Name <> '..') then
   Process(PDir + SR.Name + '\' + Mask);
  Until WideFindNext(SR) <> 0;
  WideFindClose(SR);
 end;
end;
begin
 Process(FPath + FMask);
end;

procedure TPathInspector.SetPath(Value: WideString);
begin
 FPath := WideIncludeTrailingPathDelimiter(Value);
end;

procedure TUTF8StringList.SaveToStream_BOM(Stream: TStream; WithBOM: Boolean);
Var S: String;
begin
 If WithBOM then Stream.WriteBuffer(UTF8_BOM, SizeOf(UTF8_BOM));
 S := CodePageStringEncode(CP_UTF8, 3, GetTextStr);
 Stream.WriteBuffer(PAnsiChar(S)^, Length(S));
end;

procedure TNodeListEx.LoadFromFile(const FileName: WideString);
var Stream: TTntFileStream;
begin
 Stream := TTntFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
 try
  LoadFromStream(Stream);
 finally
  Stream.Free;
 end;
end;

procedure TNodeListEx.SaveToFile(const FileName: WideString);
var Stream: TTntFileStream;
begin
 Stream := TTntFileStream.Create(FileName, fmCreate);
 try
  SaveToStream(Stream);
 finally
  Stream.Free;
 end;
end;

function TStreamAdapter.CopyFrom(const Stream: IReadWrite;
  Count: Integer): Integer;
begin
 if Stream = NIL then
  Result := 0 else
  Result := FSource.CopyFrom(TStream(Stream.GetPtr), Count);
end;

function TStreamAdapter.CopyFrom64(const Stream: IReadWrite;
  const Count: Int64): Int64;
begin
 if Stream = NIL then
  Result := 0 else
  Result := FSource.CopyFrom(TStream(Stream.GetPtr), Count);
end;

constructor TStreamAdapter.Create(Source: TStream; FreeAfterUse: Boolean = False);
begin
 if Source = NIL then raise EStreamError.Create('Source must not be nil');
 FSource := Source;
 FFreeAfterUse := FreeAfterUse;
end;

destructor TStreamAdapter.Destroy;
begin
 if FFreeAfterUse then FSource.Free;
 inherited;
end;

procedure TStreamAdapter.FreeObject;
begin
 FreeAndNIL(FSource);
end;

function TStreamAdapter.GetPos: Integer;
begin
 Result := FSource.Position;
end;

function TStreamAdapter.GetPos64: Int64;
begin
 Result := FSource.Position;
end;

function TStreamAdapter.GetPtr: Pointer;
begin
 Result := Pointer(FSource);
end;

function TStreamAdapter.GetSize: Integer;
begin
 Result := FSource.Size;
end;

function TStreamAdapter.GetSize64: Int64;
begin
 Result := FSource.Size;
end;

function TStreamAdapter.Read(var Buffer; Count: Integer): Integer;
begin
 Result := FSource.Read(Buffer, Count);
end;

procedure TStreamAdapter.Seek(Offset, SeekOrigin: Integer);
begin
 FSource.Seek(Offset, TSeekOrigin(SeekOrigin));
end;

procedure TStreamAdapter.Seek64(const Offset: Int64; SeekOrigin: Integer);
begin
 FSource.Seek(Offset, TSeekOrigin(SeekOrigin));
end;

procedure TStreamAdapter.SetPos(Value: Integer);
begin
 FSource.Position := Value;
end;

procedure TStreamAdapter.SetPos64(const Value: Int64);
begin
 FSource.Position := Value;
end;

procedure TStreamAdapter.SetSize(Value: Integer);
begin
 FSource.Size := Value;
end;

procedure TStreamAdapter.SetSize64(const Value: Int64);
begin
 FSource.Size := Value;
end;

function TStreamAdapter.Write(const Buffer; Count: Integer): Integer;
begin
 Result := FSource.Write(Buffer, Count);
end;

procedure TClassListItem.Assign(Source: TNode);
begin
 inherited;
 FClass := TClassListItem(Source).FClass;
end;

constructor TClassListItem.Create(AClass: TClass);
begin
 inherited Create;
 FClass := AClass;
end;

procedure TClassListItem.Initialize;
begin
 FAssignableClass := TClassListItem;
end;

function TClassList.AddClass(AClass: TClass): TClassListItem;
begin
 if AClass = NIL then raise EClassListError.Create('AClass must not be nil');
 Result := TClassListItem.Create(AClass);
 AddCreated(Result);
end;

procedure TClassList.AssignAdd(Source: TNode);
var S: String;
begin
 if (Source <> NIL) and (Source is TClassListItem) then
  AddClass(TClassListItem(Source).FClass) else
 begin
  if Source = NIL then S := 'nil' else S := Source.ClassName;
  raise EClassListError.CreateFmt(SAssignError, [S, ClassName]);
 end;
end;

function TClassList.Find(const Name: String): TClassListItem;
var I: Integer;
begin
 for I := 0 to Count - 1 do
 begin
  Result := Classes[I];
  if (Result <> NIL) and (Result.FClass.ClassName = Name) then Exit;
 end;
 Result := NIL;
end;

function TClassList.Find(ClType: TClass): TClassListItem;
var I: Integer;
begin
 for I := 0 to Count - 1 do
 begin
  Result := Classes[I];
  if (Result <> NIL) and (Result.FClass = ClType) then Exit;
 end;
 Result := NIL;
end;

function TClassList.GetClass(Index: Integer): TClassListItem;
begin
 Result := Nodes[Index] as TClassListItem;
end;

procedure TClassList.Initialize;
begin
 NodeClass := TClassListItem;
 FAssignableClass := TClassList;
end;

procedure TClassList.RegisterClasses(const AList: array of TClass);
var I: Integer;
begin
 for I := 0 to Length(AList) - 1 do AddClass(AList[I]);
end;

function TStringsAdapter.Add(S: PAnsiChar): Integer;
begin
 if FSourceA <> NIL then
  Result := FSourceA.Add(S) else
  Result := FSourceW.Add(S);
end;

procedure TStringsAdapter.AddStrings(const Strings: IStrings);
var Obj: TObject; I: Integer;
begin
 Obj := TObject(Strings.GetPtr);
 if Obj is TStringList then
 begin
  if FSourceA <> NIL then
   FSourceA.AddStrings(TStringList(Obj)) else
   FSourceW.AddStrings(TStringList(Obj));
 end else if Obj is TTntStringList then
 begin
  if FSourceW <> NIL then FSourceW.AddStrings(TTntStringList(Obj)) else
  with TTntStringList(Obj) do
   for I := 0 to Count - 1 do FSourceA.Add(AnsiStrings[I]);
 end;
end;

function TStringsAdapter.AddW(S: PWideChar): Integer;
begin
 if FSourceW <> NIL then
  Result := FSourceW.Add(S) else
  Result := FSourceA.Add(S);
end;

procedure TStringsAdapter.Append(S: PAnsiChar);
begin
 if FSourceA <> NIL then
  FSourceA.Append(S) else
  FSourceW.Append(S);
end;

procedure TStringsAdapter.AppendW(S: PWideChar);
begin
 if FSourceW <> NIL then
  FSourceW.Append(S) else
  FSourceA.Append(S);
end;

procedure TStringsAdapter.Assign(const Source: IStrings);
var Obj: TObject; I: Integer; S: String;
begin
 Obj := TObject(Source.GetPtr);
 if Obj is TStringList then
 begin
  if FSourceA <> NIL then
   FSourceA.Assign(TStringList(Obj)) else
   FSourceW.Assign(TStringList(Obj));
 end else if Obj is TTntStringList then
 begin
  if FSourceW <> NIL then FSourceW.Assign(TTntStringList(Obj)) else
  with TTntStringList(Obj) do
  begin
   FSourceA.BeginUpdate;
   try
    FSourceA.Clear;
    S := NameValueSeparator;
    FSourceA.NameValueSeparator := S[1];
    S := QuoteChar;
    FSourceA.QuoteChar := S[1];
    S := Delimiter;
    FSourceA.Delimiter := S[1];
    for I := 0 to Count - 1 do FSourceA.Add(AnsiStrings[I]);
   finally
    FSourceA.EndUpdate;
   end;
  end;
 end;
end;

constructor TStringsAdapter.Create;
begin
 raise EStringListError.Create('This constructor is not allowed');
end;

procedure TStringsAdapter.Clear;
begin
 if FSourceA <> NIL then
  FSourceA.Clear else
  FSourceW.Clear;
end;

constructor TStringsAdapter.Create(Source: TStringList; FreeAfterUse: Boolean = False);
begin
 if Source = NIL then raise EStringListError.Create('Source must not be nil');
 FSourceA := Source;
 FSourceW := NIL;
 FFreeAfterUse := FreeAfterUse;
end;

constructor TStringsAdapter.Create(Source: TTntStringList; FreeAfterUse: Boolean = False);
begin
 if Source = NIL then raise EStringListError.Create('Source must not be nil');
 FSourceA := NIL;
 FSourceW := Source;
 FFreeAfterUse := FreeAfterUse; 
end;

procedure TStringsAdapter.Delete(Index: Integer);
begin
 If FSourceA <> NIL then
  FSourceA.Delete(Index) else
  FSourceW.Delete(Index);
end;

function TStringsAdapter.Equals(const Strings: IStrings): LongBool;
var Obj: TObject; 
begin
 Result := False;
 Obj := TObject(Strings.GetPtr);
 if Obj is TStringList then
 begin
  if FSourceA <> NIL then
   Result := FSourceA.Equals(TStringList(Obj));
 end else if Obj is TTntStringList then
 begin
  if FSourceW <> NIL then Result := FSourceW.Equals(TTntStringList(Obj));
 end;
end;

procedure TStringsAdapter.Exchange(Index1, Index2: Integer);
begin
 if FSourceA <> NIL then
  FSourceA.Exchange(Index1, Index2) else
  FSourceW.Exchange(Index1, Index2);
end;

function TStringsAdapter.Find(S: PAnsiChar; var Index: Integer): LongBool;
begin
 if FSourceA <> NIL then
  Result := FSourceA.Find(S, Index) else
  Result := FSourceW.Find(S, Index);
end;

function TStringsAdapter.FindW(S: PWideChar; var Index: Integer): LongBool;
begin
 if FSourceW <> NIL then
  Result := FSourceW.Find(S, Index) else
  Result := FSourceA.Find(S, Index);
end;

function TStringsAdapter.GetCount: Integer;
begin
 if FSourceA <> NIL then
  Result := FSourceA.Count else
  Result := FSourceW.Count;
end;

function TStringsAdapter.GetString(Index: Integer): PAnsiChar;
begin
 if FSourceA <> NIL then
  FTempA := FSourceA.Strings[Index] else
  FTempA := FSourceW.AnsiStrings[Index];
 Result := Pointer(FTempA);
end;

function TStringsAdapter.GetStringW(Index: Integer): PWideChar;
begin
 if FSourceW <> NIL then
  FTempW := FSourceW.Strings[Index] else
  FTempW := FSourceA.Strings[Index];
 Result := Pointer(FTempW);
end;

function TStringsAdapter.GetText: PAnsiChar;
begin
 if FSourceA <> NIL then
  FTempA := FSourceA.Text else
  FTempA := FSourceW.Text;
 Result := Pointer(FTempA);
end;

function TStringsAdapter.GetTextW: PWideChar;
begin
 if FSourceW <> NIL then
  FTempW := FSourceW.Text else
  FTempW := FSourceA.Text;
 Result := Pointer(FTempW);
end;

function TStringsAdapter.IndexOf(S: PAnsiChar): Integer;
begin
 if FSourceA <> NIL then
  Result := FSourceA.IndexOf(S) else
  Result := FSourceW.IndexOf(S);
end;

function TStringsAdapter.IndexOfW(S: PWideChar): Integer;
begin
 if FSourceW <> NIL then
  Result := FSourceW.IndexOf(S) else
  Result := FSourceA.IndexOf(S);
end;

procedure TStringsAdapter.Insert(Index: Integer; S: PAnsiChar);
begin
 if FSourceA <> NIL then
  FSourceA.Insert(Index, S) else
  FSourceW.Insert(Index, S);
end;

procedure TStringsAdapter.InsertW(Index: Integer; S: PWideChar);
begin
 if FSourceW <> NIL then
  FSourceW.Insert(Index, S) else
  FSourceA.Insert(Index, S);
end;

procedure TStringsAdapter.LoadFromStream(const Stream: IReadWrite);
begin
 if FSourceA <> NIL then
  FSourceA.LoadFromStream(TStream(Stream.GetPtr)) else
  FSourceW.LoadFromStream(TStream(Stream.GetPtr));
end;

procedure TStringsAdapter.Move(CurIndex, NewIndex: Integer);
begin
 if FSourceA <> NIL then
  FSourceA.Move(CurIndex, NewIndex) else
  FSourceW.Move(CurIndex, NewIndex);
end;

procedure TStringsAdapter.SaveToStream(const Stream: IReadWrite);
begin
 if FSourceA <> NIL then
  FSourceA.SaveToStream(TStream(Stream.GetPtr)) else
  FSourceW.SaveToStream(TStream(Stream.GetPtr));
end;

procedure TStringsAdapter.SetString(Index: Integer; Value: PAnsiChar);
begin
 if FSourceA <> NIL then
  FSourceA.Strings[Index] := Value else
  FSourceW.Strings[Index] := Value;
end;

procedure TStringsAdapter.SetStringW(Index: Integer; Value: PWideChar);
begin
 if FSourceW <> NIL then
  FSourceW.Strings[Index] := Value else
  FSourceA.Strings[Index] := Value;
end;

procedure TStringsAdapter.SetText(Value: PAnsiChar);
begin
 if FSourceA <> NIL then
  FSourceA.Text := Value else
  FSourceW.Text := Value;
end;

procedure TStringsAdapter.SetTextW(Value: PWideChar);
begin
 if FSourceW <> NIL then
  FSourceW.Text := Value else
  FSourceA.Text := Value;
end;

procedure TStringsAdapter.Sort;
begin
 if FSourceA <> NIL then
  FSourceA.Sort else
  FSourceW.Sort;
end;

function TStringsAdapter.GetPtr: Pointer;
begin
 if FSourceA <> NIL then
  Result := Pointer(FSourceA) else
  Result := Pointer(FSourceW);
end;

destructor TStringsAdapter.Destroy;
begin
 if FFreeAfterUse then
 begin
  FSourceA.Free;
  FSourceW.Free;
 end;
 inherited;
end;

procedure TStringsAdapter.FreeObject;
begin
 FreeAndNIL(FSourceA);
 FreeAndNIL(FSourceW);
end;

end.
