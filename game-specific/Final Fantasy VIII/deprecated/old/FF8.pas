unit FF8;

interface

uses SysUtils, Windows, {FF7_Common,} {FF_Compression,} TableText;

//Function GetFName(P: Pointer): String;

Type
  TFName = Array[0..7] of Char;
  TLBAIns = Packed Record
    Name: TFName;
    //Null: TFName;
    LBA:  DWord;
    Size: DWord;
  end;
  TDATListRec = Packed Record
    Name: TFName;
    DISC: Array[0..3] of Boolean;
    Reserved: Integer;
  end;
  TLBAInsArr = Array of TLBAIns;
  TFF8LBA = Array[1..4] of TLBAInsArr;
  TLBASize = Record LBA, Size: DWord; end;
  TLBASet = Array[0..2] of TLBASize;
  TFldFile = Packed Record
    Pos: Pointer;
    Size: Integer;
  end;
  TFF8Ptrs = Array[0..11] of DWord;
  TFF8Files = Array[1..4] of File;
  TFF8CDB = Array[1..4] of Boolean;
  TFF8Dat = Class
    Destructor Destroy;
    private
      FLoaded: Boolean;
      FBuf:  Pointer;
      FSize: DWord;
      PtrDef: DWord;
      Ptrs:   Array[0..11] of DWord;
      Files: Array[0..11] of TFldFile;
      FCompressed: Boolean;
      Function FGetFName: String;
    public
      FName:    TFName;
      property  Name: String Read FGetFName;
      Procedure Clear;
      Procedure LoadFromBuf(P: Pointer; Size: DWord = 0; Compression: Boolean = True);
      Procedure SaveToFile(FileName: String; Compression: Boolean = True);
      Function  SaveToStream(var Buf: Pointer; Compression: Boolean = True): Integer;
      Procedure LoadFromFile(FileName: String; Compression: Boolean = True);
      Procedure ReplaceText(Text: TGameTextSet; ID: Integer);
      Function  WriteToFile(const F: File; Pos: DWord;
                Compression: Boolean = True; MaxSize: Integer = 0): Integer;
      //Procedure InsertCDText(Toc: TFF8LBA; const F: TFF8Files; B: TFF8CDB);
      Procedure Reinit;
      Property  Compressed: Boolean Read FCompressed;
  end;
  TProgressFunc = Function(Cur, Max: Integer; S: String): Boolean;

var FF8CDB: Array[1..4] of Boolean;
const LBADef = $33A;
      level  = $FFF;

Function FF8_InsertText(Text: TGameTextSet; ID: Integer; Buf: Pointer): Integer;
Function FF8_ExtractAllText(Folder: String; var Text: TGameTextSet; P: TProgressFunc = NIL): Integer;
Procedure FF8_ExtractField(InFolder,OutFolder: String; P: TProgressFunc = NIL);
Procedure FF8_LoadLBA(FileName: String; var L: TFF8LBA);
Function FF8_LoadToc(const F: File; var Buf: Pointer): DWord;
Function FF8_GetLBACount(P: Pointer): Integer;
Function FF8_SaveToc(const F: File; Buf: Pointer; Size: Integer): DWord;
Function FF8_GetFName(P: Pointer): String;
implementation

Type
  TSDWordArray = Array[Word] of DWord;
  PSDWordArray = ^TSDWordArray;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

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

Function LoadFile(Name: String; var Pos: Pointer): Integer;
var F: File;
begin
  FileMode := fmOpenRead;
  Result:=-1;
  If not FileExists(Name) Then Exit;
  AssignFile(F,Name);
  Reset(F,1);
  Result:=FileSize(F);
  GetMem(Pos, Result);
  BlockRead(F, Pos^, Result);
  CloseFile(F);
  FileMode := fmOpenReadWrite;
end;

Destructor TFF8Dat.Destroy;
begin
  Clear;  
end;

Function TFF8Dat.WriteToFile(const F: File; Pos: DWord;
Compression: Boolean = True; MaxSize: Integer = 0): Integer;
var Buf: Pointer; Size: Integer;
begin
  Result:=0;
  Size:=SaveToStream(Buf,Compression);
  If (MaxSize<=0) or (Size<=MaxSize) Then
  begin
    Seek(F,Pos);
    BlockWrite(F,Buf^,Size);
    Result:=Size;
  end;
  FreeMem(Buf);
end;

Procedure TFF8Dat.ReplaceText(Text: TGameTextSet; ID: Integer);
var Buf,TBuf: Pointer; n,MSize,Size,Def: Integer; P: ^TFF8Ptrs; B,WB: ^Byte;
begin
  MSize:=0;
  GetMem(TBuf,$80000);
  Size:=RoundBy(FF8_InsertText(Text,ID,TBuf),4);
    //SaveFile('D:\_job\FF8\Test\Testing.MSG',TBuf,Size);
  GetMem(Buf,FSize-Files[8].Size+Size);
  P:=Buf;
  WB:=Addr(P^); Inc(WB,$30); B:=FBuf; Inc(B,$30);
  For n:=0 To 7 do Inc(MSize,Files[n].Size);
  FSize:=MSize+Size;
  Move(B^,WB^,MSize);
  //  SaveFile('D:\_job\FF8\Test\Testing.MSG',Buf,MSize+$30);
  Inc(B,MSize+Files[8].Size);
  Inc(WB,MSize);
  Move(TBuf^,WB^,Size);
  Inc(WB,Size);
  Def:=Size-Files[8].Size;
  MSize:=0;
  For n:=9 To 11 do Inc(MSize,Files[n].Size);
  Move(B^,WB^,MSize);
  Inc(FSize,MSize);
  FreeMem(TBuf);
  For n:=9 To 11 do Inc(Ptrs[n],Def);
  Move(Ptrs,P^,$30);
  ReallocMem(FBuf,FSize);
  Move(Buf^,FBuf^,FSize);
  FreeMem(Buf);
  Reinit;
    //SaveFile('D:\_job\FF8\Test\Testing.DAT',Buf,FSize);
end;

{Procedure TFF8Dat.InsertCDText(Toc: TFF8LBA;  const F: TFF8Files; B: TFF8CDB);
var n,m: Integer;
begin

end;}

Function TFF8Dat.SaveToStream(var Buf: Pointer; Compression: Boolean = True): Integer;
begin
  {If Compression Then Result:=LZ_Compress(FBuf,Buf,FSize,level,False) else}
  begin
    Result:=FSize;
    GetMem(Buf,FSize);
    Move(FBuf^,Buf^,Result);
  end;
end;

Procedure TFF8Dat.SaveToFile(FileName: String; Compression: Boolean = True);
var Buf: Pointer; Size: Integer;
begin
  Size:=SaveToStream(Buf,Compression);
  SaveFile(FileName,Buf,Size);
  FreeMem(Buf);
end;

Function TFF8Dat.FGetFName: String;
begin
  Result:=FF8_GetFName(Addr(FName));
end;

Procedure TFF8Dat.Clear;
begin    
  FSize:=0;
  If not FLoaded Then Exit;
  FreeMem(FBuf);
  FLoaded:=False;
end;

Procedure TFF8Dat.Reinit;
var n: Integer; Size: Integer;
begin
  Size:=0;
  For n:=0 To 11 do
  begin
    Files[n].Pos:=Pointer(DWord(FBuf)+(Ptrs[n]-PtrDef));
    If n>0 Then Files[n-1].Size:=DWord(Files[n].Pos)-DWord(Files[n-1].Pos);
  end;
  For n:=0 To 10 do Inc(Size,Files[n].Size);
  Files[n].Size:=FSize-Size;
end;

Procedure TFF8Dat.LoadFromBuf(P: Pointer; Size: DWord = 0; Compression: Boolean = True);
begin
  If FLoaded Then Clear;
  FCompressed:=True;
  //!!If Compression and TestArc(P,Size,$40) Then FSize:=LZ_Decompress(P,FBuf)
  //!!else
  begin
    FCompressed:=False;
    FSize:=Size;
    GetMem(FBuf,Size);
    Move(P^,FBuf^,Size);
  end;
  Move(FBuf^,Ptrs,12*4);
  PtrDef:=Ptrs[0]-$30;
  Move(Pointer(DWord(FBuf)+$30)^,FName,8);
  Reinit;
  //SaveFile('D:\_job\FF8\Test\DAT',FBuf,FSize);
end;

Procedure TFF8Dat.LoadFromFile(FileName: String; Compression: Boolean = True);
var Size: Integer; Buf: Pointer;
begin
  Size:=LoadFile(FileName,Buf);
  LoadFromBuf(Buf,Size,Compression);
  FreeMem(Buf);
end;

Procedure FF8_LoadLBA(FileName: String; var L: TFF8LBA);
var n: Integer; Count: Array[1..4] of DWord; F: File;
begin
  If Not FileExists(FileName) Then Exit;
  AssignFile(F,FileName);
  Reset(F,1);
  BlockRead(F,Count,16);
  For n:=1 To 4 do
  begin
    SetLength(L[n],Count[n]);
    BlockRead(F,L[n,0],Count[n]*16);
  end;
  CloseFile(F);                          
end;

Function FF8_GetLBACount(P: Pointer): Integer;
var W: ^Word;
begin
  W:=Pointer(DWord(P)+$440);
  Result:=(W^-$260-$610) div 24;
end;

Function FF8_LoadToc(const F: File; var Buf: Pointer): DWord;
var TBuf: Pointer; FH: TLBASize;
begin
  Seek(F,$10);
  BlockRead(F,FH,8);
  Seek(F,(FH.LBA-LBADef)*$800);
  GetMem(TBuf,RoundBy(FH.Size,$800));
  BlockRead(F,TBuf^,RoundBy(FH.Size,$800));
  //!!Result:=LZ_Decompress(TBuf,Buf);
  FreeMem(TBuf);
end;

Function FF8_SaveToc(const F: File; Buf: Pointer; Size: Integer): DWord;
var FH: TLBASize;
begin
  Seek(F,$10);
  BlockRead(F,FH,8);
  Seek(F,(FH.LBA-LBADef)*$800);
  BlockWrite(F,Buf^,Size);
  Seek(F,$14);
  BlockWrite(F,Size,4);
end;

Function FF8_GetFName(P: Pointer): String;
var n: Integer; NM: ^TFName;
begin
  Result:='';
  NM:=P;
  For n:=0 To 7 do
  begin
    If NM[n]=#0 Then Break;
    Result:=Format('%s%s',[Result,NM[n]]);
  end;
end;

Procedure SaveLBAFile(const F: File; LBA,Size: DWord; FileName: String);
var Buf: Pointer;
begin
  Seek(F,(LBA-LBADef)*$800);
  GetMem(Buf,Size);
  BlockRead(F,Buf^,Size);
  SaveFile(FileName,Buf,Size);
  FreeMem(Buf);
end;

Procedure FF8_ExtractField(InFolder,OutFolder: String; P: TProgressFunc = NIL);
var n,m, ID: Integer; F: File; Buf,LBuf: Pointer; Count: Integer;
Dat: TFF8Dat; FH: ^TLBASet;  Ins: Array of TLBAIns; Cnt: Array[1..4] Of DWord; ACnt: Integer;
Extracted: Array of TFName; Buf2: Pointer;
  Function InExtracted(Name: TFName): Integer;
  begin
    For Result := 0 To High(Extracted) do If Extracted[Result]=Name Then Exit;
    Result := -1;
  end;
begin
  ACnt:=0;
  FillChar(Cnt,SizeOf(Cnt),0);
  If not DirectoryExists(OutFolder) Then Exit;
  For n:=1 To 4 do
    If not FileExists(Format('%s\FF8DISC%d.IMG',[InFolder,n])) Then Exit;
  Dat := TFF8Dat.Create;
  For n:=1 To 4 do
  begin
    AssignFile(F,Format('%s\FF8DISC%d.IMG',[InFolder,n]));
    Reset(F,1);
    FF8_LoadToc(F,LBuf);
    Count:=FF8_GetLBACount(LBuf);
    FH:=Pointer(DWord(LBuf)+$28900);
    For m:=0 To Count-1 do
    begin
      Seek(F,(FH^[1].LBA-LBADef)*$800);
      GetMem(Buf,FH^[1].Size);
      BlockRead(F,Buf^,FH^[1].Size);
      Dat.LoadFromBuf(Buf, FH^[1].Size);
      If @P<>NIL Then
      begin
        If P(m + 1, Count, Dat.Name) Then
        begin
          CloseFile(F);
          Exit;
        end;
      end;
      SetLength(Ins,ACnt+1);
      Ins[ACnt].Name:=Dat.FName;
      Ins[ACnt].LBA:=FH^[1].LBA;
      Ins[ACnt].Size:=RoundBy(FH^[1].Size,$800);
      Inc(ACnt);
      Inc(Cnt[n]);
      ID := InExtracted(Dat.FName);
      If ID < 0 Then
      begin
        Seek(F,(FH^[0].LBA-LBADef)*$800);
        GetMem(Buf2,FH^[0].Size);
        BlockRead(F,Buf2^,FH^[0].Size);
        SaveFile(Format('%s\%s.pre',[OutFolder,Dat.Name]),Buf2,FH^[0].Size);
        FreeMem(Buf2);

        Seek(F,(FH^[2].LBA-LBADef)*$800);
        GetMem(Buf2,FH^[2].Size);
        BlockRead(F,Buf2^,FH^[2].Size);
        SaveFile(Format('%s\%s.pos',[OutFolder,Dat.Name]),Buf2,FH^[2].Size);
        FreeMem(Buf2);

        SaveFile(Format('%s\%s.dat',[OutFolder,Dat.Name]),Buf,FH^[1].Size);
        SetLength(Extracted,Length(Extracted)+1);
        Extracted[High(Extracted)]:=Dat.FName;
      end;
      //Dat.SaveToFile(Format('%s\%s.dat',[OutFolder,Dat.Name]));
      FreeMem(Buf);
    //  SaveLBAFile(F,FH^[0].LBA,FH^[0].Size,Format('%s\%s.mim',[OutFolder,Dat.Name]));
    //  SaveLBAFile(F,FH^[2].LBA,FH^[2].Size,Format('%s\%s.bsx',[OutFolder,Dat.Name]));
      Inc(FH);
    end;
    CloseFile(F);
  end;
  AssignFile(F,OutFolder+'\DAT.LIST');
  Rewrite(F,1);
  //Seek(F, 8);
  //BlockWrite(F, ACnt, 4);
  Seek(F,0);
  BlockWrite(F,Cnt,16);
  Seek(F,16);
  BlockWrite(F,Ins[0],ACnt*16);
  CloseFile(F);
  Dat.Free;
end;

Procedure FF8_LoadText(Buf: Pointer; Text: TGameTextSet);
var n,m: Integer; Ptr: ^DWord; P: PByte;
begin
  Ptr:=Buf;
  m := Ptr^ div 4;

  For n:=0 To m-1 do
  begin
    P := Pointer(DWord(Buf)+Ptr^);
    Text.AddString(P, 0, [4..6,9]);
    Inc(Ptr);
  end;
end;

Function FF8_ExtractAllText(Folder: String; var Text: TGameTextSet; P: TProgressFunc = NIL): Integer;
var SR: TSearchRec; DAT: TFF8Dat; n: Integer; Cancel: Boolean;
Label Stop;
const
  cIgnore: Array[0..19] of String = (
    'test8', 'testbl13', 'testmv', 'testno', 'gdsand2', 'glclub3',  // hlam
    'laguna01', 'laguna02', 'laguna03', 'laguna04', 'laguna05', 'laguna06',
    'laguna07', 'laguna08', 'laguna09', 'laguna10', 'laguna11', 'laguna12',
    'laguna13',
    'bghoke_2' // hz o_O
    );
   
  Function InBad(Name: String): Boolean;
  var n: Integer;
  begin
    Result:=True;
    For n:=0 To High(cIgnore) do If cIgnore[n] + '.dat' = Name Then Exit;
    Result:=False;
  end;

begin
  Dat:=TFF8Dat.Create;
  Cancel:=False;
  n:=0;
  If FindFirst(Folder+'\*.DAT',  faAnyFile, SR) = 0 then
  begin
    Repeat
    If InBad(SR.Name) Then continue;
    If @P<>NIL Then Cancel:=P(n + 1, -1, SR.Name);
    If Cancel Then GoTo Stop;
      Dat.LoadFromFile(Folder+'\'+SR.Name); 
      If Dat.Compressed and (Dat.Files[8].Size>0) Then
      begin
          Text.AddItem(SR.Name);
          FF8_LoadText(Dat.Files[8].Pos,Text);
          Inc(n);
      end else
        WriteLn(Format('Invalid DAT - %s',[SR.Name]));
      //Size:=FindNext(SR);
    Until (FindNext(SR) <> 0);
  end;
  Stop:
  Dat.Free;
end;

Function FF8_InsertText(Text: TGameTextSet; ID: Integer; Buf: Pointer): Integer;
var n: Integer; Ptr: PSDWordArray; Pos: Word; B: PByte;
begin
  Ptr := Buf;
  Pos := Text.Items[ID].Count * 4;
  B := Buf;
  Inc(B, Pos);
  For n:=0 To Text.Items[ID].Count -1 do
  begin
    Ptr^[n] := Pos;
    Inc(Pos, Text.ExportString(B, Text.Strings(ID, n), True));
  end;
  Result:=Pos;
end;

end.
