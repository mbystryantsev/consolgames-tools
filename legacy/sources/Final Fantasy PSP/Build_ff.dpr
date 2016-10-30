program Build_ff;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows,
  StrUtils,
  Packer;

Type
  THeader = Record
  Name: Array[0..21] of byte;
  Data: Word;
  Offset: DWord;
  Size: DWord;
  FullSize: DWord;
  Comp: Boolean;
end;
Type
  TAHeader = Record
  FileCount: DWord;
  Size: DWord;
  Blank1: DWord;
  Blank2: DWord;
end;

Function GetName(Bytes: Array of byte): String;
var n: integer;
begin
  Result:='';
  For n:=0 to Length(Bytes)-1 do
  begin
    If Bytes[n]=0 then begin Exit; end else Result:=Result+Char(Bytes[n]);
  end;
end;



Procedure Round(var a: DWord);
begin
  Inc(a,15);
  a:=(a div 16) * 16;
end;

var Count, S: Dword; Compressed: Boolean; B: ^Byte;
Buf: Pointer; AHead: TAHeader; Head: Array of THeader;
n: Integer; F, FW: File; Ex: String; Size: DWord; CtSt: DWord;
Blank: Array[0..3] of DWord = (0,0,0,0); BL: Integer;

begin
  If ParamStr(1)='' then Exit;
  AssignFile(F, ParamStr(1));
  Reset(F,1);
  {BlockRead(F,S, 4);
    If S<>$36317057 then
    begin
      CloseFile(F);
      Exit;
    end;}

    Seek(F,8);
    BlockRead(F, AHead.FileCount, 4);
    Seek(F,12);
    BlockRead(F, S, 4);
    If S=$36317057 then Compressed:=True else Compressed:=False;
    If Compressed=True then ex:='PCK' Else ex:='NPK';
    AHead.Size:=16+AHead.FileCount*36;
    //Round(AHead.Size);
    SetLength(Head, AHead.FileCount);

    For n:=0 to AHead.FileCount-1 do
    begin
      Seek(F, n*32+16);
      BlockRead(F, Head[n], 24);
      Seek(F, n*32+16+28);
      BlockRead(F, CTst, 4);
      Head[n].Comp:=False;
      If CTst=$36317057 then Head[n].Comp:=True;
    end;
    CloseFile(F);
    n:=0;
    If ParamStr(2)='' Then AssignFile(FW, LeftStr(ParamStr(1), Length(ParamStr(1))-4)+ex)
    else AssignFile(FW, ParamStr(2));
    Rewrite(FW,1);
    For n:=0 to AHead.FileCount-1 do
    begin
      WriteLn(GetName(Head[n].Name));
      Round(AHead.Size);
      AssignFile(F, ExtractFilePath(ParamStr(1))+'\'+GetName(Head[n].Name));
      Reset(F,1);
      Head[n].Size:=FileSize(F);

      If Head[n].Comp=True then
      begin
        Seek(F,4);
        BlockRead(F,Head[n].FullSize,4);
      end else
      begin
        Head[n].FullSize:=Head[n].Size;
      end;
      Head[n].Offset:=AHead.Size;
      Inc(AHead.Size, Head[n].Size);
      Seek(FW, 16 + (n*36));
      BlockWrite(FW, Head[n], 36);
      Seek(FW, Head[n].Offset);
      GetMem(Buf, Head[n].Size);
      Seek(F,0);
      BlockRead(F, Buf^, Head[n].Size);
      BlockWrite(FW, Buf^, Head[n].Size);
      FreeMem(Buf);
      CloseFile(F);
    end;
    Size:=FileSize(FW);
    Round(Size);
    If Size<>FileSize(FW) then
    begin
      Seek(FW, FileSize(FW));
      BL:=Size-FileSize(FW);
      BlockWrite(FW, Blank, BL);
    end;
    Seek(FW,0);
    AHead.Size:=Size;
    BlockWrite(FW, AHead, 16);
    If Compressed=True then
    begin
      Reset(FW,1);
      GetMem(Buf, AHead.Size + $1000);
      B:=Addr(Buf^);
      Inc(B, $1000);
      BlockRead(FW, B^, AHead.Size);
      Size:=Pack(Buf, AHead.Size, $7FF);
      Rewrite(FW,1);
      Seek(FW, 0);
      BlockWrite(FW, Buf^, Size);
      FreeMem(Buf);
    end;
    Close(FW);
    

end.