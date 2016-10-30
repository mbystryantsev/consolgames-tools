unit bmpfnt;

interface

Uses Windows, SysUtils, MyClasses, Graphics, DIB, DXDraws;

Type
 TBMPChar = Class
 private
  FPicture: TDIB;
  FSymbol: WideChar;
 public
  Constructor Create;
  Destructor Destroy; override;
  Property Picture: TDIB read FPicture write FPicture;
  Property Symbol: WideChar read FSymbol write FSymbol;
 end;
 TBMPFont = Class(TNodeList)
 private
  FTransparent: Boolean;
  FTransparentColor: Byte;
  //функи установки прозрачности и прозрачного цвета
  Procedure SetTransparent(Value: Boolean);
  Procedure SetTransparentColor(Value: Byte);

  //Поиск картинки по символу
  Function GetChar(Value: WideChar): TDIB;
 public
  Procedure LoadFromFile(Const FileName: String); virtual; abstract;
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //это так на будущее, можно написать класс основанный на TBMPFont,
  //а там уже эту функу реализовать

  //функи добавления картинок
  Function AddEmpty(Chr: WideChar): TDIB;
  Function AddFromFile(Const FileName: String; Chr: WideChar): TDIB;
  Function AddFromDIBRect(DIB: TDIB; Source: TRect; Width, Height: Integer; Chr: WideChar): TDIB;
  Function AddFromRect(Canvas: TCanvas; Source: TRect; Width, Height: Integer; Chr: WideChar): TDIB;
  Function CharToWideChar(Ch: Char): WideChar;
  
  //Процедура рисования текста на другой картинке TDIB.
  //Виртуальная, чтобы можно было изменить её в классе основанном на этом.
  Procedure DIBDrawText(Dest: TDIB; Const Text: WideString; X, Y: Integer); Virtual;
  Procedure CanvasDrawText(Canvas: TCanvas; Const Text: WideString; X, Y: Integer); Virtual;

  //свойства
  Property Transparent: Boolean read FTransparent write SetTransparent;
  Property TransparentColor: Byte read FTransparentColor write SetTransparentColor;
  Property Chars[Value: WideChar]: TDIB read GetChar;
 end;

implementation

Constructor TBMPChar.Create;
begin
 FSymbol := #0;
 FPicture := TDIB.Create;
 FPicture.PixelFormat := MakeDIBPixelFormat(8, 8, 8);
 FPicture.BitCount := 8;
end;

Destructor TBMPChar.Destroy;
begin
 FPicture.Free;
 inherited Destroy;
end;

Procedure TBMPFont.SetTransparent(Value: Boolean);
Var N: PNodeRec;
begin
 FTransparent := Value;
 N := Root;
 While N <> NIL do With N^ do
 begin
  If (Node <> NIL) and (Node is TBMPChar) then
   (Node as TBMPChar).Picture.Transparent := Value;
  N := Next;
 end;
end;

Function CharToWideChar(Ch: Char): WideChar;
Var WS: WideString;
begin
 WS := Ch;
 Result := WS[1];
end;

Procedure TBMPFont.SetTransparentColor(Value: Byte);
Var N: PNodeRec;
begin
 FTransparentColor := Value;
 N := Root;
 While N <> NIL do With N^ do
 begin
  If (Node <> NIL) and (Node is TBMPChar) then
   (Node as TBMPChar).Picture.TransparentColor := Value;
  N := Next;
 end;
end;

Function TBMPFont.AddEmpty(Chr: WideChar): TDIB;
begin
 try
  With Add^ do
  begin
   Node := TBMPChar.Create;
   With Node as TBMPChar do
   begin
    Symbol := Chr;
    Picture.Transparent := FTransparent;
    Picture.TransparentColor := FTransparentColor;
    Result := Picture;
   end;
  end;
 except
  on E: Exception do Result := NIL;
 end;
end;

Function TBMPFont.AddFromFile(Const FileName: String; Chr: WideChar): TDIB;
begin
 try
  With Add^ do
  begin
   Node := TBMPChar.Create;
   With Node as TBMPChar do
   begin
    Symbol := Chr;
    Picture.LoadFromFile(FileName);
    If Picture.BitCount <> 8 then Picture.BitCount := 8;
    Picture.Transparent := FTransparent;
    Picture.TransparentColor := FTransparentColor;
    Result := Picture;
   end;
  end;
 except
  on E: Exception do Result := NIL;
 end;
end;

Function TBMPFont.AddFromDIBRect(DIB: TDIB; Source: TRect; Width, Height: Integer; Chr: WideChar): TDIB;
begin
 If not Assigned(DIB) then
 begin
  Result := NIL;
  Exit;
 end;
 try
  With Add^ do
  begin
   Node := TBMPChar.Create;
   With Node as TBMPChar do
   begin
    Symbol := Chr;
    Picture.ColorTable := DIB.ColorTable;
    Picture.UpdatePalette;
    Picture.Width := Width;
    Picture.Height := Height;
    With Picture.Canvas do
     CopyRect(ClipRect, DIB.Canvas, Source);
    Picture.Transparent := FTransparent;
    Picture.TransparentColor := FTransparentColor;
    Result := Picture;
   end;
  end;
 except
  on E: Exception do Result := NIL;
 end;
end;

Function TBMPFont.AddFromRect(Canvas: TCanvas; Source: TRect; Width, Height: Integer; Chr: WideChar): TDIB;
begin
 try
  With Add^ do
  begin
   Node := TBMPChar.Create;
   With Node as TBMPChar do
   begin
    Symbol := Chr;
    Picture.Width := Width;
    Picture.Height := Height;
    With Picture.Canvas do
     CopyRect(ClipRect, Canvas, Source);
    Picture.Transparent := FTransparent;
    Picture.TransparentColor := FTransparentColor;
    Result := Picture;
   end;
  end;
 except
  on E: Exception do Result := NIL;
 end;
end;

Procedure TBMPFont.DIBDrawText(Dest: TDIB; Const Text: WideString; X, Y: Integer);
Var P: ^WideChar; I, XX: Integer; Bitmap: TDIB;
begin
 If (Text <> '') and Assigned(Dest) then
 begin
  P := Addr(Text[1]);
  XX := X;
  With Dest do For I := 0 to Length(Text) - 1 do
  begin
   Bitmap := GetChar(P^);
   If Bitmap <> NIL then
   begin
    DrawDIB(XX, Y, Bitmap);
    Inc(XX, Bitmap.Width);
   end;
   Inc(P);
  end;
 end;
end;

Function TBMPFont.GetChar(Value: WideChar): TDIB;
Var N: PNodeRec;
begin
 Result := NIL;
 If Value < ' ' then Exit;
 N := Root;
 While N <> NIL do With N^ do
 begin
  If (Node <> NIL) and (Node is TBMPChar) then
  With Node as TBMPChar do If Symbol = Value then
  begin
   Result := Picture;
   Exit;
  end;
  N := Next;
 end;
end;

Procedure TBMPFont.CanvasDrawText(Canvas: TCanvas; Const Text: WideString; X, Y: Integer);
Var P: ^WideChar; I, XX: Integer; Bitmap: TDIB; Bmp: TBitmap;
begin
 If (Text <> '') and Assigned(Canvas) then
 begin
  P := Addr(Text[1]);
  XX := X;
  Bmp := TBitmap.Create;
  For I := 0 to Length(Text) - 1 do
  begin
   Bitmap := GetChar(P^);
   If Bitmap <> NIL then
   begin
    Bmp.Width := Bitmap.Width;
    Bmp.Height := Bitmap.Height;
    With Bitmap.ColorTable[FTransparentColor] do
     Bmp.TransparentColor := rgbRed + rgbGreen shl 8 + rgbBlue shl 16;
    Bmp.Transparent := FTransparent;
    Bmp.Canvas.Draw(0, 0, Bitmap);
    Canvas.Draw(XX, Y, Bmp);
    Inc(XX, Bitmap.Width);
   end;
   Inc(P);
  end;
  Bmp.Free;
 end;
end;

end.
