//////////////////////////////////
// TARGA Loader v0.2 by XProger //
// XProger@list.ru              //
// 15.06.05                     //
//////////////////////////////////
unit targa;

interface

type
 TByteArray = array [0..1] of Byte;
 PByteArray = ^TByteArray;
 TGA_Header = packed record
  FileType       : Byte;
  ColorMapType   : Byte;
  ImageType      : Byte;
  ColorMapStart  : WORD;
  ColorMapLength : WORD;
  ColorMapDepth  : Byte;
  OrigX          : WORD;
  OrigY          : WORD;
  Width          : WORD;
  Height         : WORD;
  BPP            : Byte;
  ImageInfo      : Byte;
  Data           : pointer;
 end;

 function LoadTGA(const FileName: string): TGA_Header;
 function SaveTGA(const FileName: string; Width, Height: integer; pixels: pointer; Flip: Boolean = False): boolean;
procedure FlipVertically(Data: PByteArray);

implementation

type

 TWordArray = array [0..1] of Word;
 PWordArray = ^TWordArray;

 TCardinalArray = array [0..1] of Cardinal;
 PCardinalArray = ^TCardinalArray;

var
 F   : File of Byte;
 TGA : TGA_Header;

function inci(var i: integer): integer;
begin
Result := i;
i := i + 1;
end;

procedure FlipHorizontally(Data: PByteArray);
var
 scanLine : PByteArray;
 i, j, x, w, h, pixelSize: Integer;
begin
w := TGA.Width;
h := TGA.Height;
pixelSize := TGA.BPP div 8;

GetMem(scanLine, w*pixelSize);
for i := 0 to h - 1 do
 begin
 Move(Data[i*w*pixelSize], scanLine[0], w*pixelSize);
 for x := 0 to w div 2 do
  for j := 0 to pixelSize - 1 do
   scanLine[x*pixelSize + j] := scanLine[(w-1-x)*pixelSize + j];
 Move(scanLine[0], Data[i*w*pixelSize], w*pixelSize);
 end;
FreeMem(scanLine);
end;

procedure FlipVertically(Data: PByteArray);
var
 scanLine : PByteArray;
 i, w, h, pixelSize: Integer;
begin
w := TGA.Width;
h := TGA.Height;
pixelSize := TGA.BPP div 8;
GetMem(scanLine, w*pixelSize);

for i := 0 to h div 2 - 1 do
 begin
 Move(Data[i*w*pixelSize], scanLine[0], w*pixelSize);
 Move(Data[(h-i-1)*w*pixelSize], Data[i*w*pixelSize], w*pixelSize);
 Move(scanLine[0], Data[(h-i-1)*w*pixelSize], w*pixelSize);
 end;
FreeMem(scanLine); 
end;

procedure TGA_GetPackets(data: PByteArray; width, height, depth: WORD);
var
 current_byte, run_length, i: integer;
 buffer8: array [0..3] of Byte;
 buffer16: WORD;
 bpp: Byte;
 header: Byte;
begin
current_byte := 0;

if depth = 16 then
 bpp := 3
else
 bpp := depth div 8;

while current_byte < width * height * bpp do
 begin
 BlockRead(F, header, 1);
 run_length := (header and $7F) + 1;

 if (header and $80)<>0 then
  begin
  if depth = 32 then
   BlockRead(F, buffer8[0], 4);

  if depth = 24 then
   BlockRead(F, buffer8[0], 3);

  if depth = 16 then
   BlockRead(F, buffer16, 2);

  if depth = 8 then
   BlockRead(F, buffer8[0], 1);

  for i := 0 to run_length - 1 do
   begin
   if depth = 32 then
    begin
    data[inci(current_byte)] := buffer8[0];
    data[inci(current_byte)] := buffer8[1];
    data[inci(current_byte)] := buffer8[2];
    data[inci(current_byte)] := buffer8[3];
    end;

   if depth = 24 then
    begin
    data[inci(current_byte)] := buffer8[0];
    data[inci(current_byte)] := buffer8[1];
    data[inci(current_byte)] := buffer8[2];
    end;

   if depth = 16 then
    begin
    data[inci(current_byte)] := (buffer16 and $1F) shl 3;
    data[inci(current_byte)] := ((buffer16 shr 5) and $1F) shl 3;
    data[inci(current_byte)] := ((buffer16 shr 10) and $1F) shl 3;
    end;

  if depth = 8 then
   data[inci(current_byte)] := buffer8[0];
  end;
 end;

 if (header and $80) = 0 then
  begin
  for i := 0 to run_length - 1 do
   begin
   if depth = 32 then
    begin
    BlockRead(F, buffer8[0], 4);
    data[inci(current_byte)] := buffer8[0];
    data[inci(current_byte)] := buffer8[1];
    data[inci(current_byte)] := buffer8[2];
    data[inci(current_byte)] := buffer8[3];
    end;

   if depth = 24 then
    begin
    BlockRead(F, buffer8[0], 3);
    data[inci(current_byte)] := buffer8[0];
    data[inci(current_byte)] := buffer8[1];
    data[inci(current_byte)] := buffer8[2];
    end;

   if depth = 16 then
    begin
    BlockRead(F, buffer16, 2);
    data[inci(current_byte)] := (buffer16 and $1F) shl 3;
    data[inci(current_byte)] := ((buffer16 shr 5)and $1F) shl 3;
    data[inci(current_byte)] := ((buffer16 shr 10)and $1F) shl 3;
    end;

   if depth = 8 then
    begin
    BlockRead(F, buffer8[0], 1);
    data[inci(current_byte)] := buffer8[0];
    end;

   end;
  end;
 end;
end;


function TGA_GetData(const FileName: string): boolean;
var
 buffer1: PByteArray;
 buffer2: PWordArray;
 i: integer;
 ColorMap: PByteArray;
begin
 Result := false;
 FileMode := 64;
 AssignFile(F, FileName);
{$I-}
 Reset(F);
{$I+}
 if IOResult <> 0 then Exit;

 BlockRead(F, TGA, sizeof(TGA) - 4); // -4 Data pointer
 Seek(F, FilePos(F) + TGA.FileType);
 ColorMap := nil;

 case TGA.ImageType of
 1:
  if (TGA.ColorMapType = 1) and (TGA.ColorMapDepth = 24) then
   begin
   GetMem(ColorMap, TGA.ColorMapLength*(TGA.ColorMapDepth div 8));
   BlockRead(F, ColorMap[0], TGA.ColorMapLength*(TGA.ColorMapDepth div 8));
   end
  else
   begin
   CloseFile(F);
   Exit;
   end;

 9:
  if (TGA.ColorMapType = 1) and (TGA.ColorMapDepth = 24) then
   begin
   GetMem(ColorMap, TGA.ColorMapLength*(TGA.ColorMapDepth div 8));
   BlockRead(F, ColorMap[0], TGA.ColorMapLength*(TGA.ColorMapDepth div 8));
   end
  else
   begin
   CloseFile(F);
   Exit;
   end;
 end;


 case TGA.BPP of
 32:
  begin
  GetMem(TGA.Data, TGA.Width * TGA.Height * 4);

  if TGA.ImageType=2 then
   BlockRead(F, TGA.Data^, TGA.Width * TGA.Height * 4)
  else
   if TGA.ImageType=10 then
    TGA_GetPackets(TGA.Data, TGA.Width, TGA.Height, TGA.BPP);
  end;

 24:
  begin
  GetMem(TGA.Data, TGA.Width * TGA.Height * 3);

  if TGA.ImageType=2 then
   BlockRead(F, TGA.Data^, TGA.Width*TGA.Height*3)
  else
   if TGA.ImageType=10 then
    TGA_GetPackets(TGA.Data, TGA.Width, TGA.Height, TGA.BPP);
  end;

 16:
  begin
  GetMem(TGA.Data, TGA.Width * TGA.Height * 3);

  if TGA.ImageType = 2 then
   begin
   GetMem(buffer2, 2 * TGA.Width * TGA.Height);
   BlockRead(F, buffer2[0], 2 * TGA.Width * TGA.Height);

   for i := 0 to TGA.Width * TGA.Height - 1 do
    begin
    PByteArray(TGA.Data)[3*i]   := (buffer2[i] and $1F) shl 3;
    PByteArray(TGA.Data)[3*i+1] := ((buffer2[i] shr 5) and $1F) shl 3;
    PByteArray(TGA.Data)[3*i+2] := ((buffer2[i] shr 10) and $1F) shl 3;
    end;

   FreeMem(buffer2);
   TGA.BPP := 24;
   end
  else
   if TGA.ImageType = 10 then
    begin
    TGA_GetPackets(TGA.Data, TGA.Width, TGA.Height, TGA.BPP);
    TGA.BPP := 24;
    end;
  end;


 8:
  begin
  GetMem(TGA.Data, TGA.Width * TGA.Height * 3);
  GetMem(Buffer1, TGA.Width * TGA.Height);

  if (TGA.ColorMapType = 1) and (TGA.ColorMapDepth = 24) then
   begin
   if TGA.ImageType = 9 then
    TGA_GetPackets(buffer1, TGA.Width, TGA.Height, TGA.BPP)
   else
    BlockRead(F, buffer1[0], TGA.Width * TGA.Height);

   For i := 0 to TGA.Width * TGA.Height - 1 do
    begin
    PByteArray(TGA.Data)[3*i]   := ColorMap[3*buffer1[i]];
    PByteArray(TGA.Data)[3*i+1] := ColorMap[3*buffer1[i]+1];
    PByteArray(TGA.Data)[3*i+2] := ColorMap[3*buffer1[i]+2];
    end;

   FreeMem(ColorMap);
   end
  else
   begin
   if TGA.ImageType = 3 then
    BlockRead(F, Buffer1[0], TGA.Width * TGA.Height)
   else
    if TGA.ImageType = 11 then
     TGA_GetPackets(Buffer1, TGA.Width, TGA.Height, TGA.BPP);

   for i := 0 to TGA.Width * TGA.Height - 1 do
    begin
    PByteArray(TGA.Data)[3*i]   := Buffer1[i];
    PByteArray(TGA.Data)[3*i+1] := Buffer1[i];
    PByteArray(TGA.Data)[3*i+2] := Buffer1[i];
    end;
   end;

  FreeMem(buffer1);
  TGA.BPP := 24;
  end;
 end;
 CloseFile(F);

 if (TGA.ImageInfo and (1 shl 4)) <> 0 then FlipHorizontally(TGA.Data);
 if (TGA.ImageInfo and (1 shl 5)) <> 0 then FlipVertically(TGA.Data);

 Result := true;
end;

function LoadTGA(const FileName: string): TGA_Header;
begin
  TGA.Data := nil;
  Result   := TGA;
  if not TGA_GetData(FileName) then Exit;
  Result := TGA;
end;

function SaveTGA(const FileName: string; Width, Height: integer; pixels: pointer; Flip: Boolean = False): boolean;
var
 F   : File of Byte;
 TGA : TGA_Header;
 Y: Integer; Ar: PCardinalArray absolute pixels;
begin
  TGA.FileType       := 0;
  TGA.ColorMapType   := 0;
  TGA.ImageType      := 2;
  TGA.ColorMapStart  := 0;
  TGA.ColorMapLength := 0;
  TGA.ColorMapDepth  := 0;
  TGA.OrigX          := 0;
  TGA.OrigY          := 0;
  TGA.Width          := Width;
  TGA.Height         := Height;
  TGA.BPP            := 32;
  TGA.ImageInfo      := 8;

  AssignFile(F, FileName);
  Rewrite(F);
  BlockWrite(F, TGA, SizeOf(TGA) - 4);
  If not Flip then BlockWrite(F, pixels^, Width * Height * 4) Else
  begin
    For Y := Height - 1 downto 0 do
      BlockWrite(F, Ar^[Y * Width], Width * 4);
  end;
  CloseFile(F);
  Result := true;
end;

end.

