program FontGim2Bmp;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  DIB,
  Windows,   {Graphics,}    Types,
 ClipBrd,


  FontGim in 'FontGim.pas';

Type
  TTable = Record
  Text: String;
  Code: Word;
end;





var Pal: Array[0..15] of DWord = (0, $101010, $202020, $303030, $404040, $505050,
$606060, $707070, $808080, $909090, $A0A0A0, $B0B0B0, $C0C0C0, $D0D0D0, $E0E0E0,
$F0F0F0);
S: String; Table: Array of TTable;
var F: File; TF: TextFile;
Buf: Pointer; n,m,r,l,d: Integer; B, B1: ^Byte;  Flag: Boolean;
Pic, FontPic, p1,p2: TDIB; Font: TFont; Codes: Array of Word;
 AFormat: Word;
 AData: Cardinal;
 APalette: HPALETTE;
Label brk, brk2;

begin
  If ParamStr(1)='' Then Exit;
  WriteLn(ParamStr(1));
  S:=ParamStr(1); S[Length(S)-2]:='G'; S[Length(S)-1]:='I'; S[Length(S)]:='M';
  LoadGim(S, Buf, Pic);
  RawToDib(Pic, Buf);
  SetPallete(Pic, Pal);
  FreeMem(Buf);
  LoadGim(ExtractFilePath(ParamStr(0))+'GETTABLE.GIM', Buf, FontPic);
  RawToDib(FontPic, Buf);
  SetPallete(FontPic, Pal);
  FreeMem(Buf);
  LoadFont(Font, ParamStr(1));


  //FontPic.SaveToFile('1.bmp');

  p1:=TDIB.Create;
  p2:=TDIB.Create;
  p1.PixelFormat:= MakeDIBPixelFormat(8, 8, 8);
  p2.PixelFormat:= MakeDIBPixelFormat(8, 8, 8);
  SetPallete(p1, Pal);
  SetPallete(P2, Pal);
  AssignFile(F, ExtractFilePath(ParamStr(0))+'GETTABLE.FFF');
  Reset(F,1);
  GetMem(Buf, FileSize(F));
  BlockRead(F, Buf^, FileSize(F));
  SetLength(Codes, FileSize(F));
  CloseFile(F);
  B:=Addr(Buf^);
  For n:=0 to Length(Codes)-1 do
  begin
    Codes[n]:=B^; Inc(B);
  end;
  FreeMem(Buf);
  //FontPic.SaveToFile(ExtractFilePath(ParamStr(0))+'GetTable_.bmp');
  FontPic.LoadFromFile(ExtractFilePath(ParamStr(0))+'GetTable.bmp');

  For r:=0 to Font.Count-1 do
  begin
  If r<>Font.StopByte then
  begin
  p1.Height:=Font.H;
  p1.Width:=Font.Char[r].W;
  p1.Canvas.CopyRect(Bounds(0,0,Font.Char[r].W,Font.H),Pic.Canvas, Bounds(Font.Char[r].X, Font.Char[r].Y,Font.Char[r].W, Font.H));
  //--

       {
 Clipboard.Open;
 try
  p1.SaveToClipboardFormat(AFormat, AData, APalette);
  Clipboard.SetAsHandle(AFormat, AData);
 finally
  Clipboard.Close;
 end; }

 //--
    For m:=0 to (FontPic.Height div 16) - 1 do
      For n:=0 to (FontPic.Width div 16) -1 do
        begin
        If (Font.Char[r].W>0) and (Codes[m*16+n]>0) then
        begin
          p2.Height:=Font.H;
          p2.Width:=Font.Char[r].W;
          p2.Canvas.CopyRect(Bounds(0,0,Font.Char[r].W, Font.H),FontPic.Canvas, Bounds(n*16, m*16,Font.Char[r].W, Font.H));
          //p1.SaveToFile('Test.bmp');
          //p2.SaveToFile('Test2.bmp');
          Flag:=True;
          For l:=0 to Font.H-1 do
          begin
            B:=Addr(p1.ScanLine[l]^);
            B1:=Addr(p2.ScanLine[l]^);
            For d:=0 to RoundBy(Font.Char[r].W,2)+1 div 2 do
            begin
              If (B1^<>B^) AND ((B1^=0) OR (B^=0)) then
              begin
                Flag:=False;
                GoTo brk2;
              end;
              Inc(B); Inc(B1);
            end;
          end;
          brk2:
         If Flag=True then
          begin
            SetLength(Table, Length(Table)+1);
            Table[Length(Table)-1].Text:=Chr(Codes[m*16+n]);
            Table[Length(Table)-1].Code:=r;
            WriteLn(IntToHex(Table[Length(Table)-1].Code, 2 +(2*(Table[Length(Table)-1].Code div 256)))+'='+Table[Length(Table)-1].Text);
            //p1.SaveToFile('Test.bmp');
            //p2.SaveToFile('Test2.bmp');
            If r>=$80 then Inc(Table[Length(Table)-1].Code, $8200);
            GoTo brk;

          end;
        end;
      end;
      brk:
  end;
  end;
            SetLength(Table, Length(Table)+3);
            Table[Length(Table)-1].Text:='^';
            Table[Length(Table)-1].Code:=Font.Count+1;
            Table[Length(Table)-2].Text:='~';
            Table[Length(Table)-2].Code:=Font.Count+3;
            Table[Length(Table)-3].Text:='/';
            Table[Length(Table)-3].Code:=Font.StopByte ;
            WriteLn(IntToHex(Table[Length(Table)-1].Code, 2 +(2*(Table[Length(Table)-1].Code div 256)))+'='+Table[Length(Table)-1].Text + '  [Stop Byte]');
  //FreeMem(Buf);
  S:=ParamStr(1); S[Length(S)-2]:='T'; S[Length(S)-1]:='B'; S[Length(S)]:='L';
  AssignFile(TF, S);
  Rewrite(TF);
  For n:=0 to length(Table)-1 do
  begin
    //WriteLn(IntToHex(Table[n].Code, 2 +(2*(Table[n].Code div 256)))+'='+Table[n].Text);
    WriteLn(TF, IntToHex(Table[n].Code, 2 +(2*(Table[n].Code div 256)))+'='+Table[n].Text);
  end;
  CloseFile(TF);
  Pic.Free;
  FontPic.Free;
  p1.Free;
  p2.Free;
end.
