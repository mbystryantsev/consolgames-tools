unit AtlasBuilder;

interface


uses SysUtils, Types;


Type

  TNode = class
    Child: Array[0..1] of TNode;
    FRect: TRect;
    Busy: Boolean;
  public
    Function Insert(const Width, Height: Integer): TNode;
    Constructor Create;
    Destructor Destroy; override;
    Property Rect: TRect read FRect;
  end;
  TAtlasNode = TNode;

  TAtlasTree = class(TNode)
  public
    Constructor Create(const Width, Height: Integer);
  end;

implementation



{ TNode }

constructor TNode.Create;
begin
  Busy := False;
  Child[0] := nil;
  Child[1] := nil;
end;

destructor TNode.Destroy;
begin
  If Child[0] <> Nil Then Child[0].Free;
  If Child[1] <> Nil Then Child[1].Free;
  inherited;
end;

function TNode.Insert(const Width, Height: Integer): TNode;
var dw, dh, rw, rh: Integer;
begin
  If (Self.Child[0] <> Nil) AND (Self.Child[1] <> Nil) Then
  begin
    Result := Child[0].Insert(Width, Height);
    If Result <> Nil Then Exit;
    Result := Child[1].Insert(Width, Height);
    Exit;
  end else
  begin
    Result := Nil;
    If Busy Then Exit;
    rw := FRect.Right - FRect.Left + 1;
    rh := FRect.Bottom - FRect.Top + 1;
    If (rw < Width) or (rh < Height) Then Exit;
    If (rw = Width) and (rh = Height) Then
    begin
      Busy := True;
      Result := Self;
      Exit;
    end;
    Child[0] := TNode.Create;
    Child[1] := TNode.Create;
    dw := rw - Width;
    dh := rh - Height;


    if dw > dh then
    begin
      Child[0].FRect := Types.Rect(FRect.Left, FRect.Top, FRect.Left + Width - 1, FRect.Bottom);
      Child[1].FRect := Types.Rect(FRect.Left + Width, FRect.Top, FRect.Right, FRect.Bottom);
    end else
    begin
      Child[0].FRect := Types.Rect(FRect.Left, FRect.Top, FRect.Right, FRect.Top + Height - 1);
      Child[1].FRect := Types.Rect(FRect.Left, FRect.Top + Height, FRect.Right, FRect.Bottom);
    end;
    Result := Child[0].Insert(Width, Height);
  end;
end;

{ TTree }

constructor TAtlasTree.Create(const Width, Height: Integer);
begin
  inherited Create;
  FRect := Types.Rect(0, 0, Width - 1, Height - 1);
end;

end.
