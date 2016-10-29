unit FontUnit;

interface

uses OpenGL, OpenGLUnit, Classes;

Procedure DecodeFont(src: Pointer; image: Pointer);

type

 T2DCoord = Packed Record
  X, Y: Real;
 end;
 TTexCoord = Array[0..3] of T2DCoord;

 TMarioFont = class
  FTexture: Integer;
  FWidth:   Array[Byte] of ShortInt;
  FCharCoords: Array[Byte] of TTexCoord;
 public
  Constructor Create;
  Destructor  Destroy; override;
  Procedure   LoadFromStream(Stream: TStream);
  Procedure   LoadFromMemory(Ptr: Pointer);
  Procedure   DrawChar(C: Byte);
  Procedure   DrawString(S: String; X, Y: Integer);


  Property    Texture: Integer read FTexture;
 end;
               
Type
 TByteArray = array [0..1] of Byte;
 PByteArray = ^TByteArray;
 TIntegerArray = array [0..1] of Integer;
 PIntegerArray = ^TIntegerArray;
 TSymb = Array[0..23] of Byte;
 
implementation




const
  cFontDataSize = $1884;


Procedure DecodeChar(Src, Image: Pointer; RowStride: Integer = 256);     
const Pal: Array[0..7] of Integer = ($00FFFFFF, $FF000000, $FF0000FF, $FFD0C8D8, 0, 0, 0, 0);
var
  n, m, l, r: Integer;
  B1, B2, B3: Byte;
  Symb: PByteArray absolute Src;
  Dest: PIntegerArray absolute Image;
begin
  For r := 0 To 2 do
  For l := 0 To 1 do
  begin
    For n := 0 To 3 do
    begin
      If n mod 2 = 0 Then
      begin
        B1 := Symb^[r*8+l*2+(n div 2)];
        B2 := Symb^[r*8+l*2+(n div 2)+4];
      end;
      For m := 0 To 3 do
      begin
        Dest[(m + r * 4) * RowStride + (n + l * 4)] := Pal[((B1 and 1) or (B2 SHL 1)) and 3];
        B1 := B1 SHR 1;
        B2 := B2 SHR 1;
      end;
    end;
  end;     
end;

Procedure DecodeFont(src: Pointer; image: Pointer);
begin
  
end;



{ TMarioFont }

constructor TMarioFont.Create;
begin
  FTexture := 0;
end;

destructor TMarioFont.Destroy;
begin
  If FTexture <> 0 Then
    glDeleteTextures(1, @FTexture);
  Inherited;
end;

procedure TMarioFont.DrawChar(C: Byte);
begin
    glBegin(GL_QUADS);
      glTexCoord2f(FCharCoords[c, 0].X, FCharCoords[c, 0].Y);
      glVertex2f(0, 0);
      glTexCoord2f(FCharCoords[c, 1].X, FCharCoords[c, 1].Y);
      glVertex2f(FWidth[c], 0);
      glTexCoord2f(FCharCoords[c, 2].X, FCharCoords[c, 2].Y);
      glVertex2f(FWidth[c], 16);
      glTexCoord2f(FCharCoords[c, 3].X, FCharCoords[c, 3].Y);
      glVertex2f(0, 16);
    glEnd();
    glTranslatef(FWidth[c], 0, 0);
end;

procedure TMarioFont.DrawString(S: String; X, Y: Integer);
var i, c: Integer;
begin
  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glScalef(1 / 256, 1 / 256, 1);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glScalef(3, 3, 1);
  glTranslatef(X, Y, 0);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, FTexture);
     
  For i := 1 To Length(S) do
    DrawChar(Byte(S[i]));
end;

procedure TMarioFont.LoadFromMemory(Ptr: Pointer);
var S: ^TSymb;
n,m, Num: Integer; B: ^Byte;
ImageData: Pointer;
I: PIntegerArray absolute ImageData;
X, Y: Real;
begin
    S := Ptr;
    Inc(LongWord(S), $80);
    GetMem(ImageData, 256 * 256 * 4);
    //FillChar(ImageData^, 256 * 256 * 4, 0);
    For n := 0 To 256 * 256 - 1 do
      I^[n] := $00FFFFFF;
    For n := 0 To 255 do
    begin
      DecodeChar(S, Pointer(LongWord(ImageData) + (n SHR 4) * 256 * 16 * 4 + 3 * 256 * 4 + (n and $F) * 16 * 4));
      Inc(S);
    end;
    FTexture := LoadTexture(256, 256, ImageData);
    FreeMem(ImageData);

    B := Ptr;
    For n := 0 To 127 do
    begin
      FWidth[n * 2 + 0] := B^ AND $F + 1;
      FWidth[n * 2 + 1] := B^ SHR 4  + 1;
      Inc(B);
    end;
    FWidth[Byte(' ')] := 6;
    For n := 0 To 255 do
    begin
      X := (n AND $F) * 16;
      Y := (n SHR 4)  * 16;
      FCharCoords[n, 0].X := X;
      FCharCoords[n, 0].Y := Y;
      FCharCoords[n, 1].X := X + FWidth[n];
      FCharCoords[n, 1].Y := Y;
      FCharCoords[n, 2].X := X + FWidth[n];
      FCharCoords[n, 2].Y := Y + 16;
      FCharCoords[n, 3].X := X;
      FCharCoords[n, 3].Y := Y + 16;
    end;
end;

procedure TMarioFont.LoadFromStream(Stream: TStream);
var Buf: Array[0..cFontDataSize - 1] of Byte;
begin
  Stream.Read(Buf, SizeOf(Buf));
  LoadFromMemory(@Buf); 
end;

end.
