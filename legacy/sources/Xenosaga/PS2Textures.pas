unit PS2Textures;



interface

//uses QDialogs, SysUtils;

Type
  DWord = LongWord;

var
gsmem: Array[0..1024 * 1024 - 1] of LongWord;

block32: Array[0..31] of Integer =
(
	 0,  1,  4,  5, 16, 17, 20, 21,
	 2,  3,  6,  7, 18, 19, 22, 23,
	 8,  9, 12, 13, 24, 25, 28, 29,
	10, 11, 14, 15, 26, 27, 30, 31
);

columnWord32: Array[0..16-1] of Integer =
(
	 0,  1,  4,  5,  8,  9, 12, 13,
	 2,  3,  6,  7, 10, 11, 14, 15
);

blockZ32: Array[0..31] of Integer =
(
	 24, 25, 28, 29, 8, 9, 12, 13,
	 26, 27, 30, 31,10, 11, 14, 15,
	 16, 17, 20, 21, 0, 1, 4, 5,
	 18, 19, 22, 23, 2, 3, 6, 7
);

columnWordZ32: Array[0..16-1] of Integer =
(
	 0,  1,  4,  5,  8,  9, 12, 13,
	 2,  3,  6,  7, 10, 11, 14, 15
);

//$3c00, $140
Procedure writeTexPSMCT32(dbp, dbw, dsax, dsay, rrw, rrh: Integer; data: Pointer;
toGS: Boolean = True; Z: Boolean = False);
Procedure TexSwizzle4(dbp, dbw, dsax, dsay, rrw, rrh: Integer; data: Pointer;
toGS: Boolean = True; Z: Boolean = False);
implementation

Procedure writeTexPSMCT32(dbp, dbw, dsax, dsay, rrw, rrh: Integer; data: Pointer;
toGS: Boolean = True; Z: Boolean = False);
var
    src,DW  : ^DWord;
    startBlockPos, x, y, pageX, pageY, page, px, py, blockX, blockY, block,
    column, cx, cy,cw, bx,by      : Integer;
begin
  src := data;
	startBlockPos := dbp * 64;
  For y:=dsay to dsay + rrh - 1 do
  begin
		For x:=dsax to dsax + rrw - 1 do
    begin
			pageX := x div 64;
			pageY := y div 32;
			//page  := pageX + pageY * dbw;
      page := ((y SHR 5) * (dbw SHR 6)) + (x SHR 6);

			px := x - (pageX * 64);
			py := y - (pageY * 32);

			blockX := px div 8;
			blockY := py div 8;
			If Z Then block  := blockZ32[blockX + blockY * 8]
      else block  := block32[blockX + blockY * 8];

			bx := px - blockX * 8;
			by := py - blockY * 8;

			column := by div 2;

			cx := bx;
			cy := by - column * 2;
			If Z Then cw := columnWordZ32[cx + cy * 8]
      else cw := columnWord32[cx + cy * 8];
   // Try
			If toGS Then gsmem[startBlockPos + page * 2048 + block * 64 + column * 16 + cw] := src^
      else src^ := gsmem[startBlockPos + page * 2048 + block * 64 + column * 16 + cw];
   // except
   //   ShowMessage(Format('%dx%d',[x,y]));
   //end;
      Inc(src);
		end;
	end;
end;

{
void readTexPSMCT32(int dbp, int dbw, int dsax, int dsay, int rrw, int rrh, void *data)
{
	unsigned int *src = (unsigned int *)data;
	int startBlockPos = dbp * 64;

	for(int y = dsay; y < dsay + rrh; y++)
	{
		for(int x = dsax; x < dsax + rrw; x++)
		{
			int pageX = x / 64;
			int pageY = y / 32;
			int page  = pageX + pageY * dbw;

			int px = x - (pageX * 64);
			int py = y - (pageY * 32);

			int blockX = px / 8;
			int blockY = py / 8;
			int block  = block32[blockX + blockY * 8];

			int bx = px - blockX * 8;
			int by = py - blockY * 8;

			int column = by / 2;

			int cx = bx;
			int cy = by - column * 2;
			int cw = columnWord32[cx + cy * 8];

			*src = gsmem[startBlockPos + page * 2048 + block * 64 + column * 16 + cw];
			src++;
		}



var
block4: Array[0..31] of Integer =
(
	 0,  2,  8, 10,
	 1,  3,  9, 11,
	 4,  6, 12, 14,
	 5,  7, 13, 15,
	16, 18, 24, 26,
	17, 19, 25, 27,
	20, 22, 28, 30,
	21, 23, 29, 31
);

columnWord4: Array[0..1,0..127] of Integer =
(
	(
		 0,  1,  4,  5,  8,  9, 12, 13,   0,  1,  4,  5,  8,  9, 12, 13,   0,  1,  4,  5,  8,  9, 12, 13,   0,  1,  4,  5,  8,  9, 12, 13,
		 2,  3,  6,  7, 10, 11, 14, 15,   2,  3,  6,  7, 10, 11, 14, 15,   2,  3,  6,  7, 10, 11, 14, 15,   2,  3,  6,  7, 10, 11, 14, 15,

		 8,  9, 12, 13,  0,  1,  4,  5,   8,  9, 12, 13,  0,  1,  4,  5,   8,  9, 12, 13,  0,  1,  4,  5,   8,  9, 12, 13,  0,  1,  4,  5,
		10, 11, 14, 15,  2,  3,  6,  7,  10, 11, 14, 15,  2,  3,  6,  7,  10, 11, 14, 15,  2,  3,  6,  7,  10, 11, 14, 15,  2,  3,  6,  7
	),
	(
		 8,  9, 12, 13,  0,  1,  4,  5,   8,  9, 12, 13,  0,  1,  4,  5,   8,  9, 12, 13,  0,  1,  4,  5,   8,  9, 12, 13,  0,  1,  4,  5,
		10, 11, 14, 15,  2,  3,  6,  7,  10, 11, 14, 15,  2,  3,  6,  7,  10, 11, 14, 15,  2,  3,  6,  7,  10, 11, 14, 15,  2,  3,  6,  7,

		 0,  1,  4,  5,  8,  9, 12, 13,   0,  1,  4,  5,  8,  9, 12, 13,   0,  1,  4,  5,  8,  9, 12, 13,   0,  1,  4,  5,  8,  9, 12, 13,
		 2,  3,  6,  7, 10, 11, 14, 15,   2,  3,  6,  7, 10, 11, 14, 15,   2,  3,  6,  7, 10, 11, 14, 15,   2,  3,  6,  7, 10, 11, 14, 15
	)
);

columnByte4: Array[0..127] of Integer =
(
	0, 0, 0, 0, 0, 0, 0, 0,  2, 2, 2, 2, 2, 2, 2, 2,  4, 4, 4, 4, 4, 4, 4, 4,  6, 6, 6, 6, 6, 6, 6, 6,
	0, 0, 0, 0, 0, 0, 0, 0,  2, 2, 2, 2, 2, 2, 2, 2,  4, 4, 4, 4, 4, 4, 4, 4,  6, 6, 6, 6, 6, 6, 6, 6,

	1, 1, 1, 1, 1, 1, 1, 1,  3, 3, 3, 3, 3, 3, 3, 3,  5, 5, 5, 5, 5, 5, 5, 5,  7, 7, 7, 7, 7, 7, 7, 7,
	1, 1, 1, 1, 1, 1, 1, 1,  3, 3, 3, 3, 3, 3, 3, 3,  5, 5, 5, 5, 5, 5, 5, 5,  7, 7, 7, 7, 7, 7, 7, 7
);


Procedure TexSwizzle4(dbp, dbw, dsax, dsay, rrw, rrh: Integer; data: Pointer;
toGS: Boolean = True; Z: Boolean = False);
var
    src: ^Byte;
    startBlockPos, x, y, pageX, pageY, page, px, py, blockX, blockY, block,
    column, cx, cy,cw, cb, bx,by      : Integer;
    odd: Boolean; dst,tmp: ^Byte;
begin
(*
	u32 basepage = ((y>>7) * ((bw+127)>>7)) + (x>>7);
	u32 word = bp * 512 + basepage * 16384 + g_pageTable4[y&127][x&127];
*)

	dbw := dbw shr 1;
	src := data;
	startBlockPos := dbp * 64;

	odd := false;

  For y:=dsay to dsay + rrh -1 do
  begin
	//for(int y = dsay; y < dsay + rrh; y++)
			//for(int x = dsax; x < dsax + rrw; x++)
    For x:=dsax to dsax + rrw -1 do
    begin

			pageX := x div 128;
			pageY := y div 128;
		 //	page  := pageX + pageY * dbw;
      page := ((y shr 7) * ((dbw+127) shr 7)) + (x shr 7);


			px := x - (pageX * 128);
			py := y - (pageY * 128);

			blockX := px div 32;
			blockY := py div 16;
			block  := block4[blockX + blockY * 4];

			bx := px - blockX * 32;
			by := py - blockY * 16;

			column := by div 4;

			cx := bx;
			cy := by - column * 4;
			cw := columnWord4[column and 1,cx + cy * 32];
			cb := columnByte4[cx + cy * 32];

			dst := Addr(gsmem[startBlockPos + page * 2048 + block * 64 + column * 16 + cw]);

      DWord(tmp):=DWord(dst)+cb shr 1;

      If toGS Then
      begin
        if Boolean(cb and 1) Then
			  begin
				  if odd Then
					  tmp^ := (tmp^ and $0f) or (src^ and $f0)
				  else
					  tmp^ := (tmp^ and $0f) or ((src^ shl 4) and $f0);
			  end else
			  begin
				  if odd Then
					  tmp^ := (tmp^ and $f0) or ((src^ shr 4) and $0f)
				  else
					  tmp^ := (tmp^ and $f0) or (src^ and $0f);
        end;
      end else
      begin
			  if Boolean(cb and 1) Then
			  begin
				  if odd Then
					  src^ := (src^ and $0F) or ({dst^[cb shr 1]}(tmp^ and $F0))
				  else
					  src^ := (src^ and $F0) or (({dst^[cb SHR 1]}(tmp^ SHR 4)) and $0F);
			  end else
			  begin
				  if odd Then
					  src^ := (src^ and $0f) or ((tmp^ shl 4) and $f0)
				  else
					  src^ := (src^ and $f0) or (tmp^ and $0f);
			  end;
      end;

			if odd Then
				Inc(src);

			odd := not odd;
		end;
  end;
end;


Initialization
  FillChar(gsmem,SizeOf(gsmem),0);
end.
