program FF8Pst;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  FF7_Text, FF7_Common;

var List: TStringList; Dir,S,V,Name: String; F: Array[1..4] of File;
B: Array[1..4] Of Boolean; Vl,Size,n,m,Code: Integer; Error: Boolean; Buf: Pointer;
begin
  S:=ParamStr(1);
  If S='' Then S:='List.txt';
  If not FileExists(S) Then Exit;
  List:=TStringList.Create;
  List.LoadFromFile(S);
  Dir:=List.Strings[0];
  FillChar(B,4,1);
  For n:=1 To 4 do
  begin
    S:=Format('%s\FF8DISC%d.IMG',[Dir,n]);
    If not FileExists(S) Then B[n]:=False
    else
    begin
      AssignFile(F[n],S);
      Reset(F[n],1);
    end;
  end;
  For n:=1 To List.Count-1 do
  begin
    S:=RemS(List.Strings[n]);
    If (Length(S)>2) and (S[1]+S[2]<>'//') Then
    begin
      Name:=GetPart2(S,' ',1);
      If FileExists(Name) Then
      begin
        Size:=LoadFile(Name,Buf);
        For m:=1 To 4 do
        begin
          If B[m] Then
          begin
            V:=GetPart2(S,' ',m+1);
            If V<>'' Then
            begin
              Val(V,Vl,Code);
              If (Vl>0) and (Code=0) Then
              begin
                Seek(F[m],Vl);
                BlockWrite(F[m],Buf^,Size);
              end;
            end;
          end;
        end;
        FreeMem(Buf);
      end else Error:=True;
    end;
  end;
  For n:=1 To 4 do If B[n] Then CloseFile(F[n]);
  If Error Then ReadLn;
  { TODO -oUser -cConsole Main : Insert code here }
end.
 