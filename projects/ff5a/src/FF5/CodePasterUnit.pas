Type
  TSpace = Record
    sOffset: DWord;
    sSize:   DWord;
  end;
  TSpaceList = Array of TSpace;

var
  PtrDef: Integer = 0;
  MainStream: TFileStream;
  Pos: DWord;
  Space: TSpaceList;
  FileOpened: Boolean;
  PtrSize: Integer = 4;        
  Streams: Array of TMemoryStream;
  Stream: TStream;
  Align: Integer = 1;
  LastPos: DWord = 0;

Procedure SetAlign(A: Integer);
begin
  Align := A;
end;

Procedure SetPtrSize(Size: Integer);
begin
  PtrSize := Size;
  If PtrSize > 4 Then
    PtrSize := 4
  else If PtrSize < 1 Then
    PtrSize := 1;
end;


Procedure AddSpace(Offset, Size: DWord; Two: Boolean); overload;
var n: Integer;
begin
  For n := 0 To High(Space) do With Space[n] do
  begin
    If (Offset >= sOffset) and (Offset <= sOffset + sSize) Then
    begin
      sSize := (Size + Offset) - sOffset;
      Exit;
    end;
  end;
  SetLength(Space, Length(Space) + 1);
  With Space[High(Space)] do
  begin
    sOffset := Offset;
    sSize   := Size;
  end;
end;

Procedure AddSpace(StartOffset, EndOffset: DWord); overload;
begin
  AddSpace(StartOffset, EndOffset - StartOffset + 1, True);
end;

procedure Block;
var n: Integer;
begin
  n := Length(Streams);
  SetLength(Streams, n + 1);
  Streams[n] := TMemoryStream.Create;
end;

Procedure OpenFile(FileName: String);
begin
  If FileOpened Then
    MainStream.Free;
  MainStream := TFileStream.Create(FileName, 1{2});
  Stream := MainStream;
  FileOpened:=True;
end;

Procedure ReplacePtrs(PtrOffsets: Array of DWord);
var n: Integer; V: DWord;
begin
  For n := 0 to High(PtrOffsets) do
  begin
    Stream.Seek(PtrOffsets[n], 0);
    V := Pos - PtrDef;
    Stream.Write(V, PtrSize);
  end;
end;

Procedure SetPtrDef(Def: Integer);
begin
  PtrDef := Def;
end;

Procedure WriteBytePos(Offset: DWord; Data: Array of Byte);
var n: Integer;
begin
  Stream.Seek(Offset, 0);
  For n := 0 To High(Data) do
    Stream.Write(Data[n], 1);
end;

Procedure WriteWordPos(Offset: DWord; Data: Array of Word);
var n: Integer;
begin
  Stream.Seek(Offset, 0);
  For n := 0 To High(Data) do
    Stream.Write(Data[n], 2);
end;

Procedure WriteIntPos(Offset: DWord; Data: Array of Integer);
var n: Integer;
begin
  Stream.Seek(Offset, 0);
  For n := 0 To High(Data) do
    Stream.Write(Data[n], 4);
end;

