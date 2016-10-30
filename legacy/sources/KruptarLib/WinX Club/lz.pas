unit lz;

interface

implementation

Function LZ_Decompress(var src): String;
var UB,B,WB,RB,Back,C: ^Byte; n: Integer;
begin
  SetLength(Result,256);
  FillChar(Rusult[0],Length(Result),0);
  B:=@src;
  While True do
  begin
    WB:=B; Inc(B);
    For n:=0 To 7 do
    begin
      If Boolean(1 and (WB^ SHR (7-n))) Then
      begin
        RB:=WB;
        C:=B;
        Back:=B; Inc(Back);
        For n:=0 To C^+3 do
        begin
          WB^:=RB^; Inc(WB); Inc(RB);
        end;
        Inc(B,2);
      end else
      begin
        WB^:=B^; Inc(WB); Inc(B);
      end;

    end;
  end;

end;

end.
 