program FF8LZS;

{$APPTYPE CONSOLE}

uses
  SysUtils, DIB, FF8_Compression;

Type
  TLZSHeader = Packed Record
    Code: Integer;
    Width, Height: Word;
  end;

Procedure ReverseColors(Data: Pointer; Size: Integer);
var P: ^Word;
begin
  P := Data;
  Size := Size and not 1;
  While Size > 0 do
  begin
    P^ := $7FFF AND ((P^ SHR 10) or (P^ and $3E0) or (P^ SHL 10));
    Dec(Size, 2);
    Inc(P);
  end;     
end;

var n: Integer; S: String; SrcFile, DestFile: String;
ConvType: Integer = -1; Pic, NewPic: TDIB;  F: File; Buf1, Buf: Pointer;
Code: Integer = 0; LZSCode: Integer = 0;  Size: Integer; Header: ^TLZSHeader;
P: ^Byte;
begin
  For n := 1 To ParamCount do
  begin
    S := ParamStr(n);
    If (Length(S) < 2) or (S[1] <> '-') Then
      break;
    Case S[2] of
      'e': ConvType := 0;
      'b': ConvType := 1;
      'c': Val(PChar(@S[3]), LZSCode, Code);
    end;
  end;
  If Code <> 0 Then
  begin
    WriteLn('Invalid code!');
    Exit;
  end;
  SrcFile := ParamStr(n);
  If not FileExists(SrcFile) Then Exit;
  DestFile := ParamStr(n + 1);
  If DestFile = '' Then
  begin
    If (ConvType = -1) Then
    begin
      If LowerCase(ExtractFileExt(SrcFile)) = '.lzs' Then
      begin
        ConvType := 0;
        DestFile := ChangeFileExt(SrcFile, '.bmp');
      end
      else If LowerCase(ExtractFileExt(SrcFile)) = '.bmp' Then
      begin
        ConvType := 1;
        DestFile := ChangeFileExt(SrcFile, '.lzs');
      end else
      begin
        WriteLn('WTF? o_O');
        Exit;
      end;
    end;
  end;

  Pic := TDIB.Create;
  Case ConvType of
    0:
    begin
      AssignFile(F, SrcFile);
      Reset(F, 1);
      BlockRead(F, Size, 4);
      GetMem(Buf1, Size);
      BlockRead(F, Buf1^, Size);
      GetMem(Buf, 1024 * 1024 * 4);
      lzs_decompress(Buf1, Size, Buf, Size);
      FreeMem(Buf1);
      Header := Buf;                          
      Pic.PixelFormat := MakeDIBPixelFormat(5, 5, 5);
      Pic.BitCount := 16;
      Pic.Width := Header^.Width;
      Pic.Height := Header^.Height;
      P := Buf;
      Inc(P, SizeOf(TLZSHeader));
      ReverseColors(P, Size - SizeOf(TLZSHeader));
      For n := 0 To Header^.Height - 1 do
      begin
        Move(P^, Pic.ScanLine[n]^, Header^.Width * 2);
        Inc(P, Header^.Width * 2);
      end;
      FreeMem(Buf);
      Pic.SaveToFile(DestFile);
    end;
    1:
    begin
      Pic.LoadFromFile(SrcFile);
      If (Pic.BitCount <> 16) {or (Pic.PixelFormat <> MakeDIBPixelFormat(5, 5, 5))} Then
      begin
        NewPic := TDIB.Create;
        NewPic.PixelFormat := MakeDIBPixelFormat(5, 5, 5);
        NewPic.BitCount := 16;
        NewPic.Width := Pic.Width;
        NewPic.Height := Pic.Height;
        NewPic.Canvas.Draw(0, 0, Pic);
        Pic.Free;
        Pic := NewPic;
      end;

      Size := Pic.Width * Pic.Height * 2 + SizeOf(TLZSHeader);
      GetMem(Buf, Size);
      Header := Buf;
      If (ExtractFileName(DestFile) = 'loop01.lzs') or (ExtractFileName(SrcFile) = 'loop02.lzs') Then
        Header^.Code := $280000
      else
        Header^.Code := 0;
      Header^.Width  := Pic.Width;
      Header^.Height := Pic.Height;   
      P := Buf;
      Inc(P, SizeOf(TLZSHeader));
      For n := 0 To Header^.Height - 1 do
      begin
        Move(Pic.ScanLine[n]^, P^, Header^.Width * 2);
        Inc(P, Header^.Width * 2);
      end;
      GetMem(Buf1, Size);
      lzs_compress(Buf, Size, Buf1, Size);
      FreeMem(Buf);
      AssignFile(F, DestFile);
      Rewrite(F, 1);
      BlockWrite(F, Buf1^, Size);
      CloseFile(F);
      FreeMem(Buf1);
    end;
  end;
  Pic.Free;
  
  
end.
