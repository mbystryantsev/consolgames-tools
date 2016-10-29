unit FF_Compression;

interface

uses
Windows, sggzip, Classes, SysUtils;//, Dialogs;


Type

  TBinHeader = Packed Record
    Case Byte of
    0: (Size1: Word; USize1: Word; Num: Word);
    1: (USize2,Size2: DWord);
  end;

  TBinRec = Packed Record
    Size,USize,Num: Integer;
    Pos: Pointer;
    GZipPos: Pointer;
    HSize: Byte;
    BHeader: Boolean;
  end;
  TBinRecArr = Array of TBinRec;

  TBinFile = Class
    Constructor Create;
    Destructor Destroy;// override;
  private
    FCount: Integer;
    FBuf: Pointer;
    FLoaded: Boolean;
    FSize: Integer;
    FFiles: TBinRecArr;
    FBigHeader: Boolean;
    Function GetPosition(ID: Integer): Integer;
  public
    property BigHeader: Boolean Read FBigHeader;
    property Files: TBinRecArr Read FFiles;
    property Loaded: Boolean Read FLoaded;
    property Count: Integer Read FCount;
    property Position[ID: Integer]: Integer Read GetPosition;
    Procedure LoadFromBuf(Buf: Pointer; Size: Integer; BLoaded: Boolean = False);
    Procedure LoadFromFile(FileName: String);
    Procedure Remove(ID: Integer);
    Procedure AddFromBuf(Buf: Pointer; ID: Integer);
    Procedure ReplaceFromBuf(Buf: Pointer; ID: Integer; Size: Integer); 
    Procedure ReplaceFile(ID: Integer; FileName: String);
    Procedure Exchange(ID1, ID2: Integer);
    Procedure ExtractFile(ID: Integer; FileName: String);
    Procedure ExtractGZip(ID: Integer; FileName: String; WithHeader: Boolean = False);
    Function ExtractFileToBuf(ID: Integer; var Buf: Pointer): Integer;
    Procedure ExtractGZipToBuf(ID: Integer; Buf: Pointer; WithHeader: Boolean = False);
    Procedure SaveToBuf(Buf: Pointer);
    Procedure SaveToFile(FileName: String);
  end;

Function LZ_CryptBack(Back: Word; Pos: DWord): Word;
Function LZ_GetBack(B1,B2: Byte; Pos: DWord): Word;
Function LZ_GetBackW(W: Word; Pos: DWord): Word;
Function LZ_Compress(Buf: Pointer; var WBuf: Pointer; Size: Integer; level: Word = $FFF; NullOpt: Boolean = True): Integer;
Function LZ_Decompress(Buf: Pointer; var WBuf: Pointer): Integer;
Function TestArc(Buf: Pointer; Size: Integer; Def: Integer=0): Boolean;
Function GZip_Decompress(inBuf: Pointer; var outBuf: Pointer; Size: Integer): Integer;
Function GZip_Compress(inBuf: Pointer; var outBuf: Pointer; Size: Integer): Integer;
Function TZ_Decompress(Buf: Pointer; WBuf: Pointer; Size: Integer): Integer;
implementation

{uses
  FF7_Common;}
  //var S: Array[0..15] of Word;
 { S[0]:=(B2 AND $F0) SHL 4 + B1;
  S[1]:=B2 AND $F;
  S[2]:=S[0]+$F012;
  S[3]:=(Pos-S[2]) AND $FFF;  }

Procedure SaveFile(Name: String; Pos: Pointer; Size: Integer);
var F: File;
begin
  FileMode := fmOpenWrite;
  AssignFile(F,Name);
  Rewrite(F,1);
  BlockWrite(F, Pos^, Size);
  CloseFile(F);
  FileMode := fmOpenReadWrite;
end;

Destructor TBinFile.Destroy;
begin
  FreeMem(FBuf);
  inherited Destroy;
end;

Constructor TBinFile.Create;
begin
  FLoaded:=False;
  inherited Destroy;
end;
Function TBinFile.GetPosition(ID: Integer): Integer;
begin
  Result:=Integer(FFiles[ID].Pos)-Integer(FBuf);
end;

Procedure TBinFile.LoadFromBuf(Buf: Pointer; Size: Integer; BLoaded: Boolean = False);
var Head: ^TBinHeader;{ Pos,SZ: Integer;} DW: ^DWord;
begin
  FCount:=0;
  If FLoaded and not BLoaded Then
  begin
    FreeMem(FBuf);
    FLoaded:=False;
  end;
  If not BLoaded Then
  begin
    GetMem(FBuf,Size);
    Move(Buf^,FBuf^,Size);
    FSize:=Size;
  end;
  FLoaded:=True;
  Head:=FBuf;

  DW:=Addr(Buf^); Inc(Integer(DW),6);
  If DW^=$88B1F Then FBigHeader:=False else FBigHeader:=True;
  //If Head^.USize2>Size Then FBigHeader:=False else FBigHeader:=True;
  While ((Integer(Head)-Integer(Buf))<Size) and ((Head^.Size1<>0) or ((Integer(Head)-Integer(FBuf))+2<Size)) do
  begin
    DW:=Addr(Head^);
    If FBigHeader Then Inc(Integer(DW),8) else Inc(Integer(DW),6);
    If DW^<>$88B1F Then Break;
    SetLength(FFiles,FCount+1);
    If FBigHeader Then
    begin
      FFiles[FCount].Size:=Head^.Size2;
      FFiles[FCount].USize:=Head^.USize2;
      FFiles[FCount].HSize:=8;
    end else
    begin
      FFiles[FCount].Size:=Head^.Size1;
      FFiles[FCount].USize:=Head^.USize1;
      FFiles[FCount].Num:=Head^.Num;
      FFiles[FCount].HSize:=6;
    end;
    FFiles[FCount].Pos:=Head;
    FFiles[FCount].GZipPos:=Head;
    Inc(Integer(FFiles[FCount].GZipPos),FFiles[FCount].HSize);
    FFiles[FCount].BHeader:=FBigHeader;
    //Inc(Pos,FFiles[FCount].HSize+FFiles[FCount].Size);
    Inc(Integer(Head),FFiles[FCount].HSize+FFiles[FCount].Size);
    Inc(FCount);
  end;
end;


Procedure TBinFile.LoadFromFile(FileName: String);
var F: File;
begin
  AssignFile(F, FileName);
  Reset(F, 1);
  FSize := FileSize(F);
  GetMem(FBuf, FSize);
  BlockRead(F, FBuf^, FSize);
  //FSize:=LoadFile(FileName,FBuf);
  CloseFile(F);
  LoadFromBuf(FBuf,FSize,True);
end;

Procedure TBinFile.Remove(ID: Integer);
//var Buf: Pointer; n,Size: Integer; LW: Word; W: ^Word;
begin
{  W:=FBuf;
  Inc(Integer(W),FSize-2); LW:=W^;
  Size:=0;
  For n:=ID To High(FFiles) do Inc(Size,FFiles[n].Size+FFiles[n].HSize);
  If Size>0 Then
  begin
    GetMem(Buf,Size);
    Move(FFiles[ID].Pos^,Buf^,Size);
  end;
  Dec(FSize,FFiles[ID].Size);
  ReallocMem(FBuf,FSize);
  W:=FBuf;
  Inc(Integer(W),FSize-2); W^:=LW;
  LoadFromBuf(FBuf,FSize,True);    }
end;

Procedure TBinFile.AddFromBuf(Buf: Pointer; ID: Integer);
begin
end;

Procedure TBinFile.ReplaceFromBuf(Buf: Pointer; ID: Integer; Size: Integer);
var BSize, ZipSize, Position: Integer; TBuf,ZipBuf,Pos: Pointer; Head: ^TBinHeader;
begin
  If FBigHeader and (Size>$FFFF) Then Exit;
  Position:=Integer(FFiles[ID].Pos)-Integer(FBuf);
  BSize:=FSize-((Integer(FFiles[ID].Pos)-Integer(FBuf))+FFiles[ID].HSize);
  If FBigHeader Then Dec(BSize,FSize-8) else Dec(BSize,FFiles[ID].Size);
  Pos:=FFiles[ID].Pos; Inc(Integer(Pos),FFiles[ID].Size+FFiles[ID].HSize);
  GetMem(TBuf,BSize);
  Move(Pos^,TBuf^,BSize);
  ZipSize:=GZip_Compress(Buf,ZipBuf,Size);
  FSize:=(Integer(FFiles[ID].Pos)-Integer(FBuf))+ZipSize+BSize+FFiles[ID].HSize;
  //ResizeMem(FBuf,FSize,(Integer(FFiles[ID].Pos)-Integer(FBuf))+ZipSize+BSize+FFiles[ID].HSize);
  Head:=FFiles[ID].Pos;
  If FBigHeader Then
  begin
    //Head^.Size2:=ZipSize;
    Head^.USize2:=Size;
  end else
  begin                  
    Head^.Size1:=ZipSize;
    Head^.USize1:=Size;
  end;
  ReallocMem(FBuf,FSize);
  Pos:=FBuf; Inc(Integer(Pos),Position+FFiles[ID].HSize);
  Move(ZipBuf^,Pos^,ZipSize);
  Inc(Integer(Pos),{FFiles[ID].Size}ZipSize);
  //Pos:=FFiles[ID].GZipPos; Inc(Integer(Pos),ZipSize);
  Move(TBuf^,Pos^,BSize);
        //SaveFile('F:\_FF7\_LZ\Test\FBuf',FBuf,FSize);
  LoadFromBuf(FBuf,FSize,True);
end;

Procedure TBinFile.ReplaceFile(ID: Integer; FileName: String);
var Buf: Pointer; Size: Integer; F: File;
begin
  If not FileExists(FileName) Then Exit;
  //Size:=LoadFile(FileName,Buf);
  AssignFile(F, FileName);
  Reset(F,1);
  Size := FileSize(F);
  GetMem(Buf, Size);
  BlockRead(F, Buf^, Size);
  CloseFile(F);


  ReplaceFromBuf(Buf,ID,Size);
  FreeMem(Buf);
end;

Procedure TBinFile.Exchange(ID1, ID2: Integer);            
begin
end;

Procedure TBinFile.ExtractFile(ID: Integer; FileName: String);
var Buf: Pointer;
begin
  If (ID<0) or (ID>High(FFiles)) Then Exit;
  GetMem(Buf,FFiles[ID].USize);
  ExtractFileToBuf(ID,Buf);
  SaveFile(FileName,Buf,FFiles[ID].USize);
  FreeMem(Buf);
end;

Procedure TBinFile.ExtractGZip(ID: Integer; FileName: String; WithHeader: Boolean = False);
var Size: Integer;
begin
  If FBigHeader Then Size:=FSize-8 else Size:=FFiles[ID].Size;
  SaveFile(FileName,FFiles[ID].GZipPos,Size);
end;

Function TBinFile.ExtractFileToBuf(ID: Integer; var Buf: Pointer): Integer;
//var Size: Integer; Pos: Pointer;
begin
  {Size:=}GZip_Decompress(FFiles[ID].GZipPos,Buf,FFiles[ID].USize);
  Result:=FFiles[ID].USize;
  {If Size>FFiles[ID].USize Then
  begin
    Pos:=Buf; Inc(Integer(Pos),FFiles[ID].USize);
    FillChar(Pos^,Size-FFiles[ID].USize,0);
  end;                                     }
end;

Procedure TBinFile.ExtractGZipToBuf(ID: Integer; Buf: Pointer; WithHeader: Boolean = False);
begin
end;

Procedure TBinFile.SaveToBuf(Buf: Pointer);
begin
  If Buf=NIL Then GetMem(Buf,FSize);
  Move(FBuf^,Buf^,FSize);
end;

Procedure TBinFile.SaveToFile(FileName: String);
begin
  SaveFile(FileName,FBuf,FSize);
end;


Function LZ_GetBack(B1,B2: Byte; Pos: DWord): Word;
begin
	Result:=(Pos - (((B2 AND $F0) SHL 4) + B1 + $F012)) AND $FFF;
end;

Function LZ_GetBackW(W: Word; Pos: DWord): Word;
var B1,B2: Byte;
begin
  B1:=W and $FF; B2:=W shr 4;
	Result:=(Pos - (((B2 AND $F0) SHL 4) + B1 + $F012)) AND $FFF;
end;

Function LZ_CryptBack(Back: Word; Pos: DWord): Word;
begin
	Result:=(Pos-(Back+$F012)) AND $FFF;
end;

Procedure LZ_Move(P1,P2: Pointer; Size: Byte);
var B1,B2: ^Byte; n: Byte;
begin
  B1:=P1; B2:=P2;
  For n:=0 To Size do begin B2^:=B1^; Inc(B1); Inc(B2); end;
end;

Function LZ_Decompress(Buf: Pointer; var WBuf: Pointer): Integer;
var Size: ^DWord; RPos,WPos,WBPos,UB,B2: ^Byte; Count,n: Byte; Back, TBack: Word;
Null: Boolean; OldCount: Integer;
//List: TStringList;
begin
//List:=TStringList.Create;

  Size:=Buf; GetMem(WBuf, Size^*8*8); RPos:=Buf; WPos:=WBuf; Inc(RPos,4);
  While Size^>=DWord(RPos)-DWord(Buf)-4+1 do
  begin
    UB:=RPos; Inc(RPos);
    For n:=0 to 7 do
    begin
      If Size^<DWord(RPos)-DWord(Buf)-4+1 Then Break;
      If Boolean((UB^ SHR n) AND 1) Then
      begin
        WPos^:=RPos^; Inc(RPos); Inc(WPos);
      end else
      begin
        B2:=RPos; Inc(B2);
        Back:=LZ_GetBack(RPos^,B2^,DWord(WPos)-DWord(WBuf));
        TBack:=Back;
        Count:=(B2^ AND $F)+3; WBPos:=WPos;
        OldCount:=Count;
//List.Add(Format('%d'#9'%d',[Count,DWord(WPos)-DWord(WBuf)]));
        While (Count>0) and (Back>=DWord(WPos)-DWord(WBuf)) do
        begin
            WBPos^:=0; Inc(WBPos); Dec(Back); Dec(Count);
        end;

        {Null:=False;
        If Back>=DWord(WPos)-DWord(WBuf) Then Null:=True;
        If Null Then
        begin
            OldCount:=Count;
            //Count:=Back-(DWord(WPos)-DWord(WBuf))+1;}
//If  DWord(WPos)-DWord(WBuf)=2836 Then           ShowMessage(Format('Back: %d, Count: %d, Pos: %d, Pos-Back=%d, NewCount: %d',
//            [Back,OldCount,DWord(WPos)-DWord(WBuf),DWord(WPos)-DWord(WBuf)-Back,Count]));
          {FillChar(WBPos^,Count,0);
          WPos:=WBPos;
        end else
        begin    }
          WPos:=WBPos;
          Back:=TBack;//LZ_GetBack(RPos^,B2^,DWord(WPos)-DWord(WBuf));
          If Count>0 Then LZ_Move(Pointer(DWord(WPos)-Back),WPos,Count);
        //end;
        Inc(RPos,2); Inc(WPos, Count);
      end;
    end;
  end;
  Result:=DWord(WPos)-DWord(WBuf);
  ReallocMem(WBuf,Result);// FreeMem(Buf); Buf:=WBuf;

//List.SaveToFile('D:\_job\FF8\Test\OR.TXT');
//List.Free;
end;

Function LZ_Compress(Buf: Pointer; var WBuf: Pointer; Size: Integer; level: Word = $FFF; NullOpt: Boolean = True): Integer;
Type TBest = Record Count: Byte; Back,Link,NullRes: Word; Null: Boolean; end;
var UB,WB,B,CR,CB: ^Byte; u,n,m,CountMax,PosMax: Integer; I: ^Integer; Best: TBest; Null: Boolean;
TempByte: Byte; NullCount: Word;
Label SetRes;
//var List: TStringList;
begin
//List:=TStringList.Create;
  Result:=-1;
  {If Assigned(WBuf) Then }GetMem(WBuf,4+Size+Size div 8);
  //else ReallocMem(WBuf,4+Size+Size div 8);
  I:=WBuf; WB:=Addr(I^); Inc(WB,4); B:=Buf;
  While Integer(B)-Integer(Buf)+1<=Size do
  begin
    UB:=WB; Inc(WB); UB^:=0;
    For u:=0 to 7 do
    begin
      //SaveFile('F:\_FF7\RUS\MD1STIN.Stream',WBuf,Integer(WB)-Integer(WBuf)+1);
      If Integer(B)-Integer(Buf)+1>Size{+1!} Then Break;
      PosMax:=Integer(B)-Integer(Buf){+18};
      If PosMax>level Then PosMax:=level;
      Best.Count:=0;
      //For n:=PosMax downto 1 do
      Best.NullRes:=0;
      CB:=B;
      If NullOpt Then
      begin
        While (CB^=0) and (Best.NullRes<$F+3) and (Integer(B)-Integer(Buf)<$1000)
        and (Integer(B)-Integer(Buf)<=Size) do
        begin
          Inc(Best.NullRes);
          Inc(CB);
        end;
        If Best.NullRes>=$F+3 Then GoTo SetRes;
      end;
      For n:=1 to PosMax do
      begin
        CB:=B;
        CR:=B; Dec(CR,n);
        CountMax:=Size-(1+Integer(B)-Integer(Buf));
        If CountMax>$F+3 Then CountMax:=$F+3;
        //Null:=False;
        For m:=0 to CountMax-1 do
        begin
          If CR=B Then Dec(CR,n);
          If DWord(CR)<DWord(Buf) Then Break;
          {If (Integer(CR)-Integer(Buf))+m<0 Then
          begin
            Null:=True;
            If CB^<>0 Then break;
          end else}
          If {Null or} (CR^<>CB^) Then break;
          Inc(CR); Inc(CB);
        end;
        //If m<CountMax Then Inc(m,1);
        If m>Best.Count Then
        begin
          Best.Count:=m;
          Best.Back:=Integer(B)-(Integer(B)-n);
          If m=$F+3 Then GoTo SetRes;
          //Best.Null:=Null;
        end;
      end;
      If (Best.Count>2) or (Best.NullRes>2) Then //сжатие
      begin
        SetRes:
        Best.Null:=False;
        If Best.NullRes>=Best.Count Then
        begin
          Best.Null:=True;
          Best.Count:=Best.NullRes;
        {end;
        If Best.Null Then}
          Best.Back:=Integer(B)-Integer(Buf)+Best.NullRes-1;
        end;
        Best.Link:=LZ_CryptBack(Best.Back,Integer(B)-Integer(Buf));
        WB^:=Best.Link and $FF; TempByte:=WB^;  Inc(WB);
        WB^:=((Best.Link shr 4) and $F0) or ((Best.Count-3) and $F);
//         If Best.Null Then
//List.Add(Format('%d'#9'%d',[Best.Count,Integer(B)-Integer(Buf)]));
{         ShowMessage(Format('%d : %d, Count: %d, Pos: %d, Link: %s, Back-Pos: %d',
          [Best.Back,LZ_GetBack(TempByte,WB^,Integer(B)-Integer(Buf)),Best.Count,
          Integer(B)-Integer(Buf),IntToHex(Best.Link,3),Integer(B)-Integer(Buf)-Best.Back]));
}         Inc(WB); If Best.Null Then Inc(B,Best.NullRes) else Inc(B,Best.Count);
         Best.Null:=False;
      end else
      begin
        UB^:=UB^ or (1 shl u);
        WB^:=B^; Inc(WB); Inc(B);
      end;
    end;
    //If u<8 Then UB^:=UB^ or ($FF shl 8-u);
  end;
  {WB^:=0; Inc(WB); WB^:=0; Inc(WB);}
  Result:=Integer(WB)-Integer(WBuf);
  I^:=Result-4;
  ReallocMem(WBuf,Result);
  //Buf:=WBuf;
  //FreeMem(WBuf);
  //SaveFile('F:\_FF7\RUS\MD1STIN.Stream',Buf,Size);
  //SaveFile('F:\_FF7\RUS\MD1STIN.PackedStream',WBuf,Result);

//List.SaveToFile('D:\_job\FF8\Test\CM.TXT');
//List.Free;
end;

Function TestArc(Buf: Pointer; Size: Integer; Def: Integer=0): Boolean;
var DW: ^DWord;
begin
  DW:=Buf;
  //If DW^=Size-4 Then Result:=True else Result:=False;
  If ABS(DW^-(Size-4))<=Def Then Result:=True else Result:=False;
end;

Function GZip_Decompress(inBuf: Pointer; var outBuf: Pointer; Size: Integer): Integer;
Var  GZIP: TGZip; InStream,OutStream: TMemoryStream;
begin
  InStream:=TMemoryStream.Create;
  OutStream:=TMemoryStream.Create;
  InStream.Size:=Size;
  Move(inBuf^, InStream.Memory^, Size);
  GZIP:= TGZip.Create;
  GZIP.UnCompress(InStream,OutStream);
  Result:=OutStream.Size;
  ReallocMem(outBuf,Result);
  Move(OutStream.Memory^,outBuf^,Result);
  InStream.Free;
  OutStream.Free;
  GZIP.Free;
end;

Function GZip_Compress(inBuf: Pointer; var outBuf: Pointer; Size: Integer): Integer;
Var  GZIP: TGZip; InStream,OutStream: TMemoryStream; Ver: ^Byte;
begin
  InStream:=TMemoryStream.Create;
  OutStream:=TMemoryStream.Create;
  InStream.Size:=Size;
  Move(inBuf^, InStream.Memory^, Size);
  GZIP:= TGZip.Create;
  GZIP.CompressionLevel:=9;
  GZIP.Compress(InStream,OutStream);
  Result:=OutStream.Size;
  ReallocMem(outBuf,Result);
  Move(OutStream.Memory^,outBuf^,Result);
  Ver:=outBuf;
  Inc(Ver,9);
  Ver^:=3;
  InStream.Free;
  OutStream.Free;
  GZIP.Free;
end;

Function TZ_Decompress(Buf: Pointer; WBuf: Pointer; Size: Integer): Integer;
var B,WB,RB: ^Byte; n,Back,Count: Byte;
begin
  //GetMem(WBuf,Size*4);
  B:=Buf; WB:=WBuf;
  While Integer(B)-Integer(Buf)<=Size do
  begin
    If B^<>$F9 Then
    begin
      WB^:=B^; Inc(WB); Inc(B);
    end else
    begin
      Inc(B); Back:=2+(B^ and $3F); Count:=((B^ shr 6)*2)+4; //Count:=((B^ shr 6)+2)*2;
      RB:=B; Dec(RB,Back);
      For n:=0 To Count-1 do
      begin
        WB^:=RB^; Inc(WB); Inc(RB);
      end;
      Inc(B);
    end;
  end;
  Result:=Integer(WB)-Integer(WBuf);
  //ReallocMem(WBuf,Result);
end;

end.
