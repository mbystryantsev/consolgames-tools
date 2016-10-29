unit FF8_Str;

interface

uses SysUtils;

const
  RIFF: Array[0..15] of Char = 'RIFF'#0#0#0#0'CDXA'#0#0#0#0;
  cHEADER: Array[0..83] of Byte = (
    $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$FF,$FF,$FF,
    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00, $00,$00,$00,$00,$00,$00,$08,$00,
    $00,$00,$08,$00,$60,$01,$01,$80, $00,$00,$08,$00,$00,$00,$00,$00,
    $00,$3F,$00,$00,$40,$01,$E0,$00, $00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00
  );
  cNull: Array[0..63] of Integer = (
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  );
Type
  TProgrFunc = Function(Cur, Max: Integer; S: String): Boolean;
  DWord = LongWord;

Function SMN2STR(InFile, OutFile: String; Progr: TProgrFunc): Boolean;
implementation



Function SMN2STR(InFile, OutFile: String; Progr: TProgrFunc): Boolean;
var
  buff: Array[Byte] of Char;
	blocks: DWord;
	count:  DWord;
	i,j,k, n:  Integer;
	pcount, pnum: DWord;
  fpin, fpout: File;
  blockbuff: Array[0..10-1, 0..$800-1] of Byte;
  HEADER: Array[0..83] of Byte;
begin
  Result := False;
  pcount := 0;
  pnum   := 0;

	AssignFile(fpout, OutFile);
  Rewrite(fpout, 1);
  AssignFile(fpin,  InFile);
  Reset(fpin, 1);
  n := 0;

	blocks := FileSize(fpin) div $5000;
	BlockWrite(fpout, RIFF, SizeOf(RIFF));
  Move(cHeader, Header, SizeOf(Header));
	For count := 0 to blocks - 1 do
  begin
		HEADER[$3C]:=Byte((count+1)  AND $FF);
		HEADER[$3D]:=Byte(((count+1) SHR 8) AND $FF);
    BlockRead(fpin, BlockBuff, $5000);
    if (count and $F = 0) and (@progr <> nil) Then progr(count, blocks, '');
		if(not CompareMem(@blockbuff[0], PChar('SMN'),3) AND (@progr <> nil) ) Then progr(-1, 0, 'SMN Error');
		if(not CompareMem(@blockbuff[1], PChar('SMR'), 3) and (@progr <> nil) ) Then progr(-1, 0, 'SMR Error');
		For j := 2 to 10 - 1 do
      if(not CompareMem(@blockbuff[j], PChar('SMJ') ,3) and (@progr <> nil)) Then progr(-1, 0, 'SMJ Error');
    Move(blockbuff[2][8], HEADER[$48], 8);
		for j:=0 to 8-1 do
    begin
			HEADER[$38] := Byte(j);
      BlockWrite(fpout, Header, SizeOf(Header));
			k := $18*j;
      BlockWrite(fpout, blockbuff[j+1][$800-k], k);
			k := $7E0-$18*j;
      BlockWrite(fpout, blockbuff[j+2][8], k);
			BlockWrite(fpout, cNull, $FC);
		end;
	end;
	BlockWrite(fpout, cNull, $1C);
	CloseFile( fpout );
	CloseFile( fpin  );
  Result := True;
end;

end.



