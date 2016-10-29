program CreateTestTable;

{$APPTYPE CONSOLE}

uses
  SysUtils;

const
  HeaderData: Array[0..2] of Word = ($0001, $0002, $8000);
  EndData: Word = $FFFF;
  StrEnd:  Word = $8000;
  Eq: Char = Char(Byte('=') - $20);
  null: Byte = 0;
  NewLine: Word = $FDFF;
Type
  WA = Array[0..1] of Byte;

var F: File; n, m: Word; S: String[4]; W: Word;
begin
  AssignFile(F, 'data.test');
  Rewrite(F, 1);
  BlockWrite(F, HeaderData, SizeOf(HeaderData));
  For n := $E000 to $FFFE do
  begin
    WA(W)[0] := WA(n)[1];
    WA(W)[1] := WA(n)[0];
    S := IntToHex(n, 4);
    For m := 1 To 4 do
      Dec(S[m], $20);
    BlockWrite(F, S[1], 4);
    BlockWrite(F, Eq, 1);
    BlockWrite(F, W, 2);
    BlockWrite(F, NewLine, 2);
  end;
  BlockWrite(F, EndData, 2);
  If FilePos(F) mod 2 <> 0 Then
    BlockWrite(F, null, 1);
  BlockWrite(F, StrEnd, 2);
  CloseFile(F);


  { TODO -oUser -cConsole Main : Insert code here }
end.
