program Xenofont;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  DIB,
  PS2Textures;
var Pic: TDIB;
Header: Array[0..7] of LongWord = (0,0,0,$51003C01,$BC00,$8000000,0,0);

Procedure TileToPic(P: Pointer; W,H,bx,by,TW,TH,BitCount: Integer; Rev: Boolean = True; RC: Boolean = False; Cut2bpp: Integer = 0; Write: Boolean = False);
var n,m,l,r,ByteCount: Integer; B,WB: ^Byte;  TWc,THc: Integer;
begin
  B:=P;
  If RC Then THc:=TW else THc:=TH;
  If RC Then TWc:=TH else TWc:=TW;
  ByteCount:=W*BitCount div 8;
  For l:=0 To THc-1 do
  begin
    For r:=0 To TWc-1 do
    begin
      For m:=0 To H-1 do
      begin
        Case BitCount of
          4:
          begin
            If RC Then WB:=Pointer(DWord(Pic.ScanLine[by+m+r*H])+l*W)
            else WB:=Pointer(DWord(Pic.ScanLine[by+m+l*H])+r*W);
            For n:=0 To ByteCount-1 do
            begin
              Case Byte(Write) of
                0: If Rev Then WB^:=B^ and $F else WB^:=B^ SHR 4;
                //1: If Rev Then B^:=B^ or (WB^ and $F) else B^:=B^ or (WB^ SHR 4);
              end;
              Case Cut2bpp of
                1: If Write Then B^:=B^ or ((WB^ shl 2) and $0C) else WB^:=WB^ shr 2;
                2: If Write Then B^:=B^ or WB^ else WB^:=WB^ and 3;
              end;
              Inc(WB);
              Case Byte(Write) of
                0: If Rev Then WB^:=B^ shr 4 else WB^:=B^ AND $F;
                //1: If Rev Then B^:=B^ or (WB^ shr 4) else B^:=B^ or (WB^ AND $F);
              end;
              Case Cut2bpp of
                1: If Write Then B^:=B^ or ((WB^ shl 6) and $C0) else WB^:=WB^ shr 2;
                2: If Write Then B^:=B^ or (WB^ shl 4) else WB^:=WB^ and 3;
              end;
              Inc(WB); Inc(B);
            end;
            Dec(B,ByteCount);
          end;
          8:  Move(B^,Pointer(DWord(Pic.ScanLine[m+l*H])+r*W)^,W);
        end;
        Inc(B,ByteCount);
      end;
    end;
  end;
end;


Procedure SaveFile(Name: String; Pos: Pointer; Num: Integer);
var F: File;
begin
  FileMode := fmOpenWrite;
  AssignFile(F,Name);
  If Num=0 Then Rewrite(F,1) else
  begin
    Reset(F,1);
    Seek(F,$3C020);
  end;
  If Num=0 Then Seek(F,0) else Seek(F,$3C020);
  BlockWrite(F,Header,32);
  If Num=0 Then Seek(F,$20) else Seek(F,$3C040);
  BlockWrite(F, Pos^, $3C000);
  CloseFile(F);
  FileMode := fmOpenReadWrite;
end;

Function LoadFile(Name: String; Pos: Pointer; Sk: Integer; Size: Integer): Integer;
var F: File;
begin
  FileMode := fmOpenRead;
  Result:=-1;
  If not FileExists(Name) Then Exit;
  AssignFile(F,Name);
  Reset(F,1);
  Seek(F,sk);
  Result:=Size;
  BlockRead(F, Pos^, Result);
  CloseFile(F);
  FileMode := fmOpenReadWrite;
end;

var Buf,Buf2: Pointer; n,m,z: Integer; Build: Boolean = False;
begin
  WriteLn('Xenofont - Xenosaga font converter by HoRRoR');
  WriteLn('http://consolgames.ru/ :: ho-rr-or@mail.ru :: horror.cg@gmail.com');
  WriteLn('For Exclusive project [http://ex-ve.ucoz.ru]');
  WriteLn('Extract: -e <tex dir> <out dir>');
  WriteLn('Build:   -b <bmp dir> <out dir>');
  WriteLn('Note:    Widths will be ignored!');
  If ParamCount<3 Then exit;
  If not (DirectoryExists(ParamStr(2)) and DirectoryExists(ParamStr(3))) Then Exit;
  If ParamStr(1)='-b' Then Build:=True;
  Pic:=TDIB.Create;
  If not Build Then
  begin
    Pic.BitCount:=8;
    Pic.Width:=640;
    Pic.Height:=128*6*4;
    DWord(Pic.ColorTable[0]):=0;
    DWord(Pic.ColorTable[1]):=$666666;
    DWord(Pic.ColorTable[2]):=$AAAAAA;
    DWord(Pic.ColorTable[3]):=$FFFFFF;
    Pic.UpdatePalette;
  end;
  GetMem(Buf2,$3C000*4);
  GetMem(Buf,$3C000);
  WriteLn('Converting...');
  For z:=0 to 1 do
  begin
    If Build Then Pic.LoadFromFile(Format('%s\font%.1d.bmp',[ParamStr(2),z]));
    For m:=0 to 1 do
    begin
      FillChar(Buf^,$3C000,0);
      FillChar(Buf2^,$3C000*4,0);
      If Build Then
        For n:=0 To 1 do
          TileToPic(Buf2,640,128,0,m*1536+n*128*6,1,6,4,True,False,2-n{n+1},True)
      else
      begin
        LoadFile(Format('%s\font%.1d.tex',[ParamStr(2),z]),Buf,$3C000*m+$20*(m+1),$3C000);
        writeTexPSMCT32(0,$140,0,0,320,192,Buf);
      end;
      for n:=0 to 6*1-1 do
        texSwizzle4((n*640) div 4,64,0,0,640,128,Pointer(DWord(Buf2)+(n*640*128*4) div 8), Build);
      If not Build Then For n:=0 To 1 do
        TileToPic(Buf2,640,128,0,m*1536+n*128*6,1,6,4,True,False,2-n{n+1})
      else
	  begin
        writeTexPSMCT32(0,$140,0,0,320,192,Buf,False);
        SaveFile(Format('%s\font%.1d.tex',[ParamStr(3),z]),Buf,m);
	  end;
    end;

    If not Build Then
      Pic.SaveToFile(Format('%s\font%.1d.bmp',[ParamStr(3),z]))


  end;
  Pic.Free;
  FreeMem(Buf);
  FreeMem(Buf2);

end.
