unit NodeLst;

interface

uses SysUtils;

type
 TNode = class
  private
    FIndex: Integer; //Node index
    FOwner: TNode;   //Link to owner node
    FPrev: TNode;    //Link to previous node
    FNext: TNode;    //Link to next node
  protected
    FAssignableClass: TClass;
    procedure AssignError(Source: TNode);
    procedure Initialize; virtual;
  public
    property Index: Integer read FIndex write FIndex;
    property Owner: TNode read FOwner;
    property Prev: TNode read FPrev;
    property Next: TNode read FNext;

    constructor Create;
    procedure Assign(Source: TNode); virtual;
 end;

 TNodeClass = class of TNode;
 TNodeArray = array of TNode;

 TNodeList = class(TNode)
  private
    FRoot: TNode;               //Link to first node
    FCur: TNode;                //Link to last node
    FCount: Integer;            //Nodes count
    FUnited: Boolean;           //TRUE if FNodes filled
    FNodes: TNodeArray;         //Array of links to all nodes
    FNodeClass: TNodeClass;     //Default class used in AddNode method
    function GetNode(Index: Integer): TNode;
    function GetRootLink: Pointer;
    function GetLastLink: Pointer;
    procedure SetUnited(Value: Boolean);
    (* if true then fill FNodes and refresh indexes else clear FNodes *)
  protected
    procedure SetNodeClass(Value: TNodeClass); virtual;
    procedure Initialize; override;
    procedure ClearData; virtual;
    procedure AssignAdd(Source: TNode); virtual;
    procedure AssignNodeClass(Source: TNodeList); virtual;
    procedure AppendError(Source: TNodeList);
  public
    property NodeClass: TNodeClass read FNodeClass write SetNodeClass;
    property RootNode: TNode read FRoot;
    property LastNode: TNode read FCur;
    property RootLink: Pointer read GetRootLink;
    property LastLink: Pointer read GetLastLink;
    property Count: Integer read FCount;
    property United: Boolean read FUnited write SetUnited;
    property Nodes[Index: Integer]: TNode read GetNode;

    function AddNode: TNode; overload;
    function AddNode(NodeClass: TNodeClass): TNode; overload;
    procedure AddCreated(Node: TNode);
    procedure Append(Source: TNodeList); virtual;
    procedure Assign(Source: TNode); override;
    procedure Clear;
    destructor Destroy; override;
    procedure Exchange(Index1, Index2: Integer);
    procedure Remove(Node: TNode); overload;
    procedure Remove(Index: Integer); overload;
    procedure MoveTo(CurIndex, NewIndex: Integer);
 end;

 ENodeListError = class(Exception);

const
 SAssignError: PChar = 'Cannot assign %s to %s';
 SAppendError: PChar = 'Cannot append %s to %s';

implementation

(* TNode *)

procedure TNode.Assign(Source: TNode);
begin
 if (Source = NIL) or not (Source is FAssignableClass) then AssignError(Source);
end;

procedure TNode.AssignError(Source: TNode);
var
 SourceName: String;
begin
 if Source <> nil then
  SourceName := Source.ClassName else
  SourceName := 'nil';
 raise EConvertError.CreateFmt(SAssignError, [SourceName, ClassName]);
end;

constructor TNode.Create;
begin
 FAssignableClass := ClassType;
 Initialize;
end;

procedure TNode.Initialize;
begin
 (* do nothing *)
end;

(* TNodeList *)

procedure TNodeList.AddCreated(Node: TNode);
begin
 Node.FOwner := Self;
 Node.FIndex := FCount;
 Node.FPrev := FCur;
 Node.FNext := NIL;
 If FRoot = NIL then
  FRoot := Node Else
  FCur.FNext := Node;
 FCur := Node;
 Inc(FCount);
 United := False;
end;

function TNodeList.AddNode: TNode;
begin
 Result := FNodeClass.Create;
 AddCreated(Result);
end;

function TNodeList.AddNode(NodeClass: TNodeClass): TNode;
begin
 if NodeClass = NIL then
  Result := FNodeClass.Create else
  Result := NodeClass.Create;
 AddCreated(Result);
end;

procedure TNodeList.Append(Source: TNodeList);
var
 N: TNode;
 Temp: TNodeClass;
begin
 if (Source = NIL) or not (Source is FAssignableClass) then AppendError(Source);
 Temp := FNodeClass;
 AssignNodeClass(Source);
 N := Source.FRoot;
 while N <> NIL do
 begin
  AssignAdd(N);
  N := N.Next;
 end;
 FNodeClass := Temp;
end;

procedure TNodeList.AppendError(Source: TNodeList);
var
 SourceName: String;
begin
 if Source <> nil then
  SourceName := Source.ClassName else
  SourceName := 'nil';
 raise ENodeListError.CreateFmt(SAppendError, [SourceName, ClassName]);
end;

procedure TNodeList.Assign(Source: TNode);
var
 N: TNode;
begin
 inherited;
 AssignNodeClass(Source as TNodeList);
 Clear;
 N := TNodeList(Source).FRoot;
 while N <> NIL do
 begin
  AssignAdd(N);
  N := N.Next;
 end;
end;

procedure TNodeList.AssignAdd(Source: TNode);
begin
 AddNode(TNodeClass(Source.ClassType)).Assign(Source);
end;

procedure TNodeList.AssignNodeClass(Source: TNodeList);
begin
 FNodeClass := Source.FNodeClass;
end;

procedure TNodeList.Clear;
var
 N: TNode;
begin
 ClearData;
 FUnited := False;
 Finalize(FNodes);
 while FRoot <> NIL do
 begin
  N := FRoot.FNext;
  FRoot.Free;
  FRoot := N;
 end;
 FCur := NIL;
 FCount := 0;
end;

procedure TNodeList.ClearData;
begin
 (* do nothing *)
end;

destructor TNodeList.Destroy;
begin
 Clear;
 inherited;
end;

procedure TNodeList.Exchange(Index1, Index2: Integer);
var
 N1, N2, TempNext, TempPrev: TNode;
 TmpIndex: Integer;
begin
 if Index1 <> Index2 then
 begin
  if Index2 < Index1 then
  begin
   TmpIndex := Index1;
   Index1 := Index2;
   Index2 := TmpIndex;
  end;
  N1 := Nodes[Index1];
  N2 := Nodes[Index2];
  if (N1 <> NIL) and (N2 <> NIL) then
  begin
   if Index1 + 1 <> Index2 then
   begin
    TempPrev := N1.FPrev;
    TempNext := N1.FNext;

    N1.FIndex := Index2;
    N2.FPrev.FNext := N1;
    N1.FPrev := N2.FPrev;
    N2.FNext.FPrev := N1;
    N1.FNext := N2.FNext;

    N2.FIndex := Index1;
    N1.FPrev.FNext := N2;
    N2.FPrev := TempPrev;
    N1.FNext.FPrev := N2;
    N2.FNext := TempNext;
   end else
   begin
    TempPrev := N1.FPrev;

    N1.FIndex := Index2;
    N1.FNext := N2.FNext;
    N1.FPrev := N2;

    N2.FIndex := Index1;
    N2.FNext := N1;
    N2.FPrev := TempPrev;
   end;
   if Index1 = 0 then FRoot := N2;
   if Index2 = FCount - 1 then FCur := N1;
   if FUnited then
   begin
    N1 := FNodes[Index1];
    FNodes[Index1] := FNodes[Index2];
    FNodes[Index2] := N1;
   end;
  end;
 end;
end;

function TNodeList.GetLastLink: Pointer;
begin
 if FCount > 0 then
 begin
  if not FUnited then United := True;
  Result := Addr(FNodes[FCount - 1]);
 end else Result := NIL;
end;

function TNodeList.GetNode(Index: Integer): TNode;
begin
 if (Index >= 0) and (Index < FCount) then
 begin
  if not FUnited then United := True;
  Result := FNodes[Index];
 end else Result := NIL;
end;

function TNodeList.GetRootLink: Pointer;
begin
 if FCount > 0 then
 begin
  if not FUnited then United := True;
  Result := Pointer(FNodes);
 end else Result := NIL;
end;

procedure TNodeList.Initialize;
begin
 FNodeClass := TNode;
 FAssignableClass := TNodeList;
end;

procedure TNodeList.MoveTo(CurIndex, NewIndex: Integer);
(* Local functions *)
 procedure Remove(Node: TNode);
 var
  PR: TNode;
 begin
  PR := Node.FPrev;
  with Node do
  begin
   if Node = FRoot then
   begin
    if FRoot = FCur then FCur := NIL;
    FRoot := FNext;
    if FRoot <> NIL then FRoot.FPrev := NIL;
   end else
   begin
    PR.FNext := FNext;
    if FNext = NIL then
     FCur := PR else
     FNext.FPrev := PR;
   end;
  end;
 end;
(* End of local functions *)
 var
  C1, C2, Temp: TNode;
(* TNodeList.MoveTo *)
begin
 if (CurIndex = NewIndex) or (FCount < 2) or (NewIndex > FCount) then Exit;
 C1 := Nodes[CurIndex];
 if C1 = NIL then Exit;
 Temp := C1;
 If NewIndex > 0 then
 begin
  C2 := Nodes[NewIndex];
  Remove(C1);
  if C2 <> NIL then
  begin
   Temp.FNext := C2;
   with C2 do
   begin
    Temp.FPrev := FPrev;
    FPrev.FNext := Temp;
    FPrev := Temp;
   end;
  end else //Move to end
  begin
   FCur.FNext := Temp;
   Temp.FPrev := FCur;
   Temp.FNext := NIL;
   FCur := Temp;
  end;
 end Else if NewIndex = 0 then
 begin
  Remove(C1);
  Temp.FNext := FRoot;
  Temp.FPrev := NIL;
  FRoot.FPrev := Temp;
  FRoot := Temp;
 end;
 United := False;
end;

procedure TNodeList.Remove(Node: TNode);
var
 PR: TNode;
begin
 if Node = NIL then Exit;
 PR := Node.FPrev;
 with Node do
 begin
  if Node = FRoot then
  begin
   if FRoot = FCur then FCur := NIL;
   FRoot := FNext;
   if FRoot <> NIL then FRoot.FPrev := NIL;
  end else
  begin
   PR.FNext := FNext;
   if FNext = NIL then
    FCur := PR else
    FNext.FPrev := PR;
  end;
  Free;
 end;
 Dec(FCount);
 United := False;
end;

procedure TNodeList.Remove(Index: Integer);
begin
 Remove(Nodes[Index]);
end;

procedure TNodeList.SetNodeClass(Value: TNodeClass);
begin
 FNodeClass := Value;
end;

procedure TNodeList.SetUnited(Value: Boolean);
var
 P: ^TNode;
 N: TNode;
 I: Integer;
begin
 if FUnited <> Value then
 begin
  Finalize(FNodes);
  if Value then
  begin
   SetLength(FNodes, FCount);
   P := Pointer(FNodes);
   N := FRoot;
   I := 0;
   while N <> NIL do
   begin
    P^ := N; Inc(P);
    N.FIndex := I;
    N := N.FNext;
    Inc(I);
   end;
  end;
  FUnited := Value;
 end;
end;

end.
