unit DrawUnit;

interface

uses DIB, DXDraws, TextUnit, Classes, StrUtils;

Type
  TFont = Class
    Constructor Create;
    Destructor  Destroy;
  private
    FPic: TDIB;
    TPic: TDIB;
  public

  end;


  TWFont = Class
  Private
    Count: Integer;
    O: Array of Byte;
    W: Array of Byte;
    cW,cH,cIX,cIY: Integer;
    FPic,TPic: TDIB;
    Function FLoaded: Boolean;
  Public
    Procedure LoadFont(FileName: String);
    Property Loaded: Boolean read FLoaded;
    Function DrawChar(ID: Byte; DXD: TDXDraw; X,Y: Integer): Byte;
    Procedure DrawIDLine(Line: String; DXD: TDXDraw; X,Y: Integer);
    Function DrawLine(S: String; DXD: TDXDraw; Table: TTableArray; X,Y: Integer): Integer;
    Procedure DrawText(Text: String; DXD: TDXDraw; Table: TTableArray; X,Y,H: Integer);
  end;

implementation

Function TWFont.FLoaded: Boolean;
begin
  If Assigned(FPic) Then Result:=True else Result:=False;
end;

Procedure TWFont.LoadFont(FileName: String);
begin
    FPic.LoadFromFile(FileName); 
end;

Function TWFont.DrawChar(ID: Byte; DXD: TDXDraw; X,Y: Integer): Byte;
var XX,YY,C: Integer;
begin
  C:=(FPic.Width div (cW+cIX));
  YY:=(ID div C)*(cW+cIY);
  XX:=(ID-((ID div C)*C))*(cH+cIX);
  DXD.Surface.Canvas.CopyRect(Bounds(X+O[ID],Y,W[ID],12),FPic.Canvas,
  Bounds(XX,YY,W[ID],12));
end;

Procedure TWFont.DrawIDLine(Line: String; DXD: TDXDraw; X,Y: Integer);
var n: Integer;
begin
  For n:=0 To Length(Line) do
  Inc(X,DrawChar(Byte(Line[n]),DXD,X,Y));
  //DrawChar(1,DXD,0,0);
end;

Function TWFont.DrawLine(S: String; DXD: TDXDraw; Table: TTableArray; X,Y: Integer): Integer;
var n,m,l,Ln,LnTbl: Integer; B: Byte;
Label Compl;
begin
  Result:=X;
  l:=1;
  Ln:=Length(S);
  LnTbl:=Length(Table)-1;
  While l<=Ln do
  begin
    If S[l]='{' Then
    begin
      If (Length(S)-l>2) and (S[l+3]='}') then
      begin
        B:=HexToInt(MidStr(S,l+1,2));
        Inc(l,4);
        GoTo Compl;
      end;
    end;
    If S[l]='[' Then
    begin
      If (Length(S)-l>2) and (S[l+4]=']') and (S[l+1]='#') then
      begin
        B:=HexToInt(MidStr(S,l+2,2));
        Inc(l,5);
        GoTo Compl;
      end;
    end;
    For m:=0 To LnTbl do
    begin
      If Table[m].Text[1]=S[l] Then
      begin
        If (Length(Table[m].Text)<=Length(S)-l+1) and
        (MidStr(S,l,Length(Table[m].Text))=Table[m].Text) Then
        begin
          If not Table[m].D Then B:=Table[m].Value else B:=$FF;
          Inc(l, Length(Table[m].Text));
          GoTo Compl;
        end;
      end;
    end;
    B:=$1F; // Неизвестный символ
    Inc(l);
    Compl:
    If B<>$FF Then Inc(X,DrawChar(B,DXD,X,Y));
  end;
  Result:=X-Result;
end;

Procedure TWFont.DrawText(Text: String; DXD: TDXDraw; Table: TTableArray; X,Y,H: Integer);
var n,Up: Integer; List: TStringList; S: String;
begin
  Up:=Y;
  List:=TStringList.Create;
  List.Text:=Text;
  For n:=0 to List.Count-1 do
  begin
    S:=List.Strings[n];
    DrawLine(S,DXD,Table,X,Y);
    If (S<>'') and (H>0) and (S[Length(S)]='~') Then
    begin
      If (Y-UP+8)>=H-8 Then Inc(Up,RoundBy(Y-UP-H+16,16));
      Inc(Up,H);
      Y:=Up;
    end else Inc(Y,16);
  end;
  List.Free;
end;


Constructor TFont.Create;
begin
  FPic:=TDIB.Create;
  TPic:=TDIB.Create;
end;

Destructor TFont.Destroy;
begin
  FPic.Free;
  TPic.Free;
end;

end.
