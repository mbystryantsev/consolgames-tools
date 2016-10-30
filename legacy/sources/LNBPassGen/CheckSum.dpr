program CheckSum;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  LNBPass in 'LNBPass.pas';

const
  P: Array[0..6] of Byte = (0, 1, 2, 3, 4, 5, 100);
  Money: Integer = 160;
  Null: Integer = 0;

var
  n: Integer;
begin
  //WriteLn(GetCheckSum(P, Length(P)));
  //WriteLn(GetCRCLen($5A));
  For n := 0 To High(Ram) do
    Ram[n] := @Null;
  //FillChar(Ram, SizeOf(Ram), Integer(@Null));
  Ram[2] := @Money;
  GeneratePassword(0);
  ReadLn;
  { TODO -oUser -cConsole Main : Insert code here }
end.
