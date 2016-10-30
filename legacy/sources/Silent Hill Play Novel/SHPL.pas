unit SHPL;

interface
uses
Classes;

Type
  THuf = Packed Record
    Teg1,Teg2: Integer;
    Bit0,Bit1: Integer;
  end;

Function UnHuf(Buf: Pointer; DPos,SPos: Integer): String;
Procedure ExtractText(var List: TStringList; Buf: Pointer; Adr: Integer);
implementation

Function UnHuf(Buf: Pointer; DPos,SPos: Integer): String;
var Get: Boolean; n: Integer; Rec: ^THuf;  Incr: Integer;
C: ^Byte; Cr: Byte;
begin
  Result:='';
  C:=Addr(Buf^);
  Inc(C,SPos);
  Rec:=Addr(Buf^); Inc(Integer(Rec),DPos);
  While not Get do
  begin
    For n:=0 To 7 do
    begin
      If Boolean(((C^ SHL n) AND $80) SHR 7) Then Incr:=Rec^.Bit1
      else Incr:=Rec^.Bit0;
      Rec:=Addr(Buf^); Inc(Integer(Rec),DPos+Incr);
      If Rec^.Teg1<>-1 then
      begin
        Cr:=Rec^.Teg1 AND $FF;
        If Cr=0 Then
        begin
          Get:=True;
          Break;
        end;
        Result:=Result+Char(Cr);
        Rec:=Addr(Buf^); Inc(Integer(Rec),DPos);
      end;
    end;
    Inc(C);
  end;

end;

Type
  TDHead = Packed Record
    Count,Size: Integer;
  end;
  TPtr = Array[0..2] of Byte;

Procedure ExtractText(var List: TStringList; Buf: Pointer; Adr: Integer);
var
  DH: ^TDHead;    n: Integer;
  DPos,PPos,SPos: Integer;
  Ptr: ^Integer;                S: String;
begin

  //If not Assigned(List) Then List:=TStringList.Create;
  List:=TStringList.Create;
  DH:= Addr(Buf^);
  Inc(Integer(DH),Adr);
  DPos:=Adr+16;
  PPos:=Adr+DH^.Size;
  Inc(Integer(DH),DH^.Size);
  Ptr:=Addr(Buf^);
  Inc(Integer(Ptr),PPos{+3});
  For n:=0 To (DH^.Count AND $FFFFFF)-1 do
  begin
    SPos:=(Ptr^ AND $FFFFFF)+PPos;
    S:=UnHuf(Buf,DPos,SPos);//List.Add();
    List.Add(S);
    Inc(Integer(Ptr),3);
  end;

end;

end.
