unit FF7_DAT;

interface

uses
  FF7_Compression, Windows, SysUtils, FF7_Common;

Type
  TDATMain = Packed Record
    Pos: Pointer;
    Size: Integer;
    Ptr: DWord;
  end;
  TDATTextPtr = Packed Record
    Pos: Pointer;
    Size: Integer;
    Ptr: DWord;
  end;
  TDATPtr = Packed Record
    Pos: Pointer;
    Size: Integer;
    Ptr: DWord;
  end;
  TDAT = Packed Record
    MainPtr: Array[0..6] of TDATMain;
    TextPtr: TDATTextPtr;
    Ptr: Array of TDATPtr;
    IdxPtr: TDATTextPtr;
    IdxArr: TDATTextPtr;
    DatArr: TDATTextPtr;
  end;
 { TScriptHeader = Packed Record
    Unknown1:       Word;
    nEntities:      Byte;		// Number of entities
    nModels:        Byte;		// Number of models
    wStringOffset:	Word;		// Offset to strings
    nAkaoOffsets:   Word;		// Specifies the number of Akao blocks/offsets
    Scale:          Word;   // Scale of field. For move and talk calculation (9bit fixed point).
    Unknown2:       Array[0..2] of Word;
    szCreator:      Array[0..7] of Char;			// Field creator (never shown)
    szName:         Array[0..7] of Char;			// Field name (never shown)
    szEntities:     Array[nEntities,8] of Char;	// Field entity names
    u32 dwAkaoOffsets[nAkaoOffsets];	// Akao block offsets
    u16 vEntityScripts[nEntities][32];	// Entity script entry points, or more
 					// explicitly, subroutine offsets
  end;  }

{  struct FF7SCRIPTHEADER 
    u16 unknown1;
    char nEntities;			// Number of entities
    char nModels;			// Number of models
    u16 wStringOffset;			// Offset to strings
    u16 nAkaoOffsets;			// Specifies the number of Akao blocks/offsets
    u16 scale;                          // Scale of field. For move and talk calculation (9bit fixed point).
    u16 unknown4[3];
    char szCreator[8];			// Field creator (never shown)
    char szName[8];			// Field name (never shown)
    char szEntities[nEntities][8];	// Field entity names
    u32 dwAkaoOffsets[nAkaoOffsets];	// Akao block offsets
    u16 vEntityScripts[nEntities][32];	// Entity script entry points, or more
 					// explicitly, subroutine offsets
}


  TEntName = Array[0..7] of Char;
  TEntNames = Array of TEntName;
  TEntScript = Array[0..31] of Word;
  TFldFile = Packed Record
    Pos: Pointer;
    Size: Integer;
  end;
  TFiledRecordHeader = Packed Record
    HD:             Word;
    nEntities:      Byte;
    nModels:        Byte;
    wStringOffset:  Word;
    nAkaoOffsets:   Word;
    Scale:          Word;
    HZ:             Array[0..2] of Word;
    szCreator:      TEntName;
    szName:         TEntName;
    szEntities:     TEntNames;            // [0..nEntities-1]
    dwAkaoOffsets:  Array of DWord;       // [0..nAkaoOffsets-1]
    vEntityScripts: Array of TEntScript;  // [0..nEntities-1]
  end;
  TFieldRec = Class
    Constructor         Create;
    Destructor          Destroy;
  private
    Opened:             Boolean;
    SBuf,FBuf,TBuf,ABuf:Pointer;
    FileSize,SSize,FSize,TSize,ASize,CSize:  Integer;
    PtrDef:             DWord;
    Ptrs:               Array[0..6] of DWord;
    Head:               TFiledRecordHeader;
    Script:             TFldFile;
    TextBlock:          TFldFile;
    Akao:               Array of TFldFile;
    Files:              Array[0..6] of TFldFile;
    Function            GetText(Table: TTableArray): TMsg;
    Procedure           UpdatePointers;
    Procedure           Clear;
  public
    Property  pScript: Pointer Read SBuf;
    Property  sScript: Integer Read SSize;
    Property  Header: TFiledRecordHeader Read Head;
    Procedure LoadFromStream(P: Pointer; Size: Integer; Compressed: Boolean = True);
    Procedure LoadFromFile(FileName: String; Compressed: Boolean = True);
    Function  SaveToStream(var P: Pointer; Compression: Boolean = True;  level: Word = $FFF; LZNull: Boolean = True): Integer;
    Procedure SaveToFile(FileName: String; Compression: Boolean = True;  level: Word = $FFF; LZNull: Boolean = True);
    Procedure ReplaceText(Text: TText; ID: Integer; Field: TLField; Table: TTableArray);
    //Property  Text(Table: TTableArray): TMsg Read GetText;// Write ReplaceTextFromMsg;
  end;


Function AssignDat(Buf: Pointer; Size: Integer): TDAT;
Function LoadDat(Name: String; var Buf: Pointer): Integer;
Function BuildDat(var DAT: TDAT; var Buf: Pointer): Integer;

implementation

uses FF7_Text, FF7_Field;

Constructor TFieldRec.Create;
begin
  Opened:=False;
  inherited Create;
end;

Destructor TFieldRec.Destroy;
begin
  Clear;
  inherited Destroy;
end;

Procedure TFieldRec.UpdatePointers;
var Pos,Def,n: Integer;
begin
  Pos:=32+4*Head.nAkaoOffsets+64*Head.nEntities+8*Head.nEntities+SSize;
  Head.wStringOffset:=Pos;
  Inc(Pos,TSize);
  If Head.nAkaoOffsets>0 Then
  begin
    Def:=Pos-Head.dwAkaoOffsets[0];
    For n:=0 To Head.nAkaoOffsets-1 do Inc(Head.dwAkaoOffsets[n],Def);
  end;
  Inc(Pos,ASize);
  Def:=Pos-(Ptrs[1]-PtrDef);
  For n:=1 To 6 do Inc(Ptrs[n],Def);
end;

Function TFieldRec.GetText(Table: TTableArray): TMsg;
begin
end;

Procedure TFieldRec.Clear;
begin
  If Opened Then
  begin
    FreeMem(FBuf);
    FreeMem(SBuf);
    FreeMem(TBuf);
    FreeMem(ABuf);
    Finalize(Head.szEntities);
    Finalize(Head.dwAkaoOffsets);
    Finalize(Head.vEntityScripts);
    Finalize(Akao);
    Opened:=False;
  end;
end;

Procedure TFieldRec.LoadFromStream(P: Pointer; Size: Integer; Compressed: Boolean = True);
var Buf: Pointer; Ptr: Pointer; SOffset,n,AkSize: Integer;
begin
  Clear;
  AkSize:=0;
  If Compressed Then FileSize:=LZ_Decompress(P,Buf) else
  begin
    FileSize:=Size;
    GetMem(Buf,Size);
    Move(P^,Buf^,Size);
  end;
  Move(Buf^,Ptrs,7*4);
  PtrDef:=Ptrs[0];
  Ptr:=Pointer(Integer(Buf)+7*4);
  Move(Ptr^,Head,32); Inc(Integer(Ptr),32);
  SetLength(Head.szEntities,Head.nEntities);
  SetLength(Head.vEntityScripts,Head.nEntities);
  Move(Ptr^,Head.szEntities[0],Head.nEntities*8);
  //SaveFile('_FF7\_LZ\Build\B\Ent',Ptr,Head.nEntities*8);
  Inc(Integer(Ptr),Head.nEntities*8);
  If Head.nAkaoOffsets>0 Then
  begin
    SetLength(Head.dwAkaoOffsets,Head.nAkaoOffsets);
    Move(Ptr^,Head.dwAkaoOffsets[0],Head.nAkaoOffsets*4);
    Inc(Integer(Ptr),Head.nAkaoOffsets*4);
  end;
  Move(Ptr^,Head.vEntityScripts[0],Head.nEntities*64);
  SOffset:=32+8*Head.nEntities+64*Head.nEntities+4*Head.nAkaoOffsets;
  SSize:=Head.wStringOffset-SOffset;
  GetMem(SBuf,SSize);
  Ptr:=Pointer(Integer(Buf)+7*4+SOffset);
  Move(Ptr^,SBuf^,SSize);
  //SaveFile('_FF7\_LZ\Build\B\SBuf',SBuf,SSize);
    If Head.nAkaoOffsets>0 Then
      TSize:=Head.dwAkaoOffsets[0]-Head.wStringOffset
    else
      TSize:=Ptrs[1]-PtrDef-Head.wStringOffset;
    GetMem(TBuf,TSize);
    Ptr:=Pointer(Integer(Buf)+7*4+Head.wStringOffset);
    Move(Ptr^,TBuf^,TSize);
    //SaveFile('_FF7\_LZ\Build\B\TBuf',TBuf,TSize);
  If Head.nAkaoOffsets>0 Then
  begin
    SetLength(Akao,Head.nAkaoOffsets);
    ASize:=Ptrs[1]-PtrDef-Head.dwAkaoOffsets[0];
    GetMem(ABuf,ASize);
    Ptr:=Pointer(Integer(Buf)+7*4+Head.dwAkaoOffsets[0]);
    Move(Ptr^,ABuf^,ASize);
    //SaveFile('_FF7\_LZ\Build\B\ABuf',ABuf,ASize);
    For n:=0 To Head.nAkaoOffsets-1 do
    begin
      Akao[n].Pos:=Pointer(Integer(Buf)+4*7+Head.dwAkaoOffsets[n]);
      If n<Head.nAkaoOffsets-1 Then Akao[n].Size:=Head.dwAkaoOffsets[n+1]-Head.dwAkaoOffsets[n]
      else Akao[n].Size:=ASize-AkSize;
      Inc(AkSize,Akao[n].Size);
    end;
  end;
  CSize:=32+64*Head.nEntities+8*Head.nEntities+4*Head.nAkaoOffsets+ASize+TSize+SSize;
  FSize:=FileSize-CSize-7*4;
  GetMem(FBuf,FSize);
  Ptr:=Pointer(Integer(Buf)+Ptrs[1]-PtrDef+7*4);
  Move(Ptr^,FBuf^,FSize);
  Files[0].Size:=CSize;
  For n:=1 To 6 do
  begin
    Files[n].Pos:=Pointer(Integer(FBuf)+Ptrs[n]-PtrDef);
    If n<6 Then Files[n].Size:=Ptrs[n+1]-Ptrs[n]
    else Files[n].Size:=FSize-Ptrs[n]-PtrDef;
  end;
  FreeMem(Buf);
  Opened:=True;
end;

Procedure TFieldRec.LoadFromFile(FileName: String; Compressed: Boolean = True);
var Buf: Pointer; Size: Integer;
begin
  If not FileExists(FileName) Then Exit;
  Size:=LoadFile(FileName,Buf);
  LoadFromStream(Buf,Size);
  FreeMem(Buf);
end;

//{$O-}
Function TFieldRec.SaveToStream(var P: Pointer; Compression: Boolean = True; level: Word = $FFF; LZNull: Boolean = True): Integer;
var Size: Integer; Buf: Pointer; B: ^Byte; n: Integer;
begin
  If not Opened Then Exit;
  //UpdatePointers;
  Size:=7*4+32+Head.nEntities*8+Head.nEntities*64+Head.nAkaoOffsets*4+SSize+TSize+ASize+FSize;
  GetMem(P,Size);
  B:=P;
  Move(Ptrs,P^,7*4);
  Inc(B,7*4);
  Move(Head,B^,32);
  Inc(B,32);
  Move(Head.szEntities[0],B^,Head.nEntities*8);
  Inc(B,Head.nEntities*8);
  If Head.nAkaoOffsets>0 Then
  begin
    Move(Head.dwAkaoOffsets[0],B^,Head.nAkaoOffsets*4);
    Inc(B,Head.nAkaoOffsets*4);
  end;
  Move(Head.vEntityScripts[0],B^,Head.nEntities*64);
  Inc(B,Head.nEntities*64);
  Move(SBuf^,B^,SSize);
  Inc(B,SSize);
  Move(TBuf^,B^,TSize);
  Inc(B,TSize);
  Move(ABuf^,B^,ASize);
  Inc(B,ASize);
  Move(FBuf^,B^,FSize);
  //FreeMem(Buf);
  //SaveFile('_FF7\_LZ\Build\B\TESTUP.DAT',P,Size);
  If Compression Then
  begin
    GetMem(Buf,Size);
    Move(P^,Buf^,Size);
    FreeMem(P);
    Result:=LZ_Compress(Buf,P,Size,level,LZNull);
    FreeMem(Buf);
    //SaveFile('_FF7\_LZ\Build\B\TESTP.DAT',P,Result);
  end else Result:=Size;
end;

Procedure TFieldRec.SaveToFile(FileName: String; Compression: Boolean = True; level: Word = $FFF; LZNull: Boolean = True);
var Buf: Pointer; Size: Integer;
begin
  If not Opened Then Exit;
  Size:=SaveToStream(Buf,Compression,level, LZNull);
  SaveFile(FileName,Buf,Size);
  FreeMem(Buf);
  {If Compression Then
  begin
    Size:=LZ_Compress(inBuf,outBuf,Size,level);
    SaveFile(FileName,outBuf,Size);
    FreeMem(outBuf);
  end else
    SaveFile(FileName,inBuf,Size);
  FreeMem(inBuf);                }
end;
//{$O+}

Procedure TFieldRec.ReplaceText(Text: TText; ID: Integer; Field: TLField; Table: TTableArray);
var m: Integer; Buf: Pointer;
begin
  GetMem(Buf,$80000);
  TSize:=RoundBy(InsertText(Text,ID,Buf,MTable),4);
  ReallocMem(TBuf,TSize);
  Move(Buf^,TBuf^,TSize);
  FreeMem(Buf);
  m:=FindField(MLField,Text[ID].Name);
  SSize:=MLField[m].Size;
  ReallocMem(SBuf,SSize);
  Move(MLField[m].Pos^,SBuf^,SSize);
  UpdatePointers;
end;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

Function LoadDat(Name: String; var Buf: Pointer): Integer;
var F: File; WBuf: Pointer;
begin
  AssignFile(F, Name);
  Reset(F,1);
  GetMem(Buf, FileSize(F));
  BlockRead(F, Buf^, FileSize(F));
  If TestArc(Buf, FileSize(F)) Then Result:=LZ_Decompress(Buf,WBuf) else Result:=-1;
  If Result>0 Then
  begin
    ReallocMem(Buf,Result);
    Move(WBuf^,Buf^,Result);
    FreeMem(WBuf);
  end;
  CloseFile(F);
end;

Function AssignDat(Buf: Pointer; Size: Integer): TDAT;
var DW: ^DWord; PtrDef,n: DWord; F: File; B: ^Byte; W: ^Word;
begin
  // Define Files
  DW:=Buf;
  For n:=0 To 6 do
  begin
    Result.MainPtr[n].Ptr:=DW^; Inc(DW);
  end;
  PtrDef:=Result.MainPtr[0].Ptr-$1C;
  For n:=0 To 6 do
  begin
    Integer(Result.MainPtr[n].Pos):=Integer(Buf)+Result.MainPtr[n].Ptr-PtrDef;
    If n<6 Then Result.MainPtr[n].Size:=Result.MainPtr[n+1].Ptr-Result.MainPtr[n].Ptr;
  end;
  Result.MainPtr[6].Size:=Size-(Result.MainPtr[6].Ptr-PtrDef);
  // Define TextBlock
  W:=Result.MainPtr[0].Pos;
  B:=Addr(W^); Inc(B,6); SetLength(Result.Ptr,B^);
  Result.TextPtr.Pos:=W;
  Inc(W,2); Result.TextPtr.Ptr:=W^;
  Inc(DWord(Result.TextPtr.Pos),W^);
  // /-/ Define FilePtrs
  B:=Result.MainPtr[0].Pos;
  DW:=Addr(B^);
  Inc(B,2);
  Inc(DWord(DW),(B^ SHL 3)+$20);
  For n:=0 To Length(Result.Ptr)-1 do
  begin
    If Length(Result.Ptr)<1 Then Break;
    Result.Ptr[n].Pos:=Result.MainPtr[0].Pos;
    Inc(DWord(Result.Ptr[n].Pos),DW^);
    Result.Ptr[n].Ptr:=DW^; Inc(DW);
    If n<Length(Result.Ptr)-1 Then Result.Ptr[n].Size:=DW^-Result.Ptr[n].Ptr;
  end;
  If Length(Result.Ptr)>0 Then Result.Ptr[Length(Result.Ptr)-1].Size:=Result.MainPtr[0].Size - Result.Ptr[Length(Result.Ptr)-1].Ptr;
  // <Back to text
  If Length(Result.Ptr)>0 Then
    Result.TextPtr.Size:=Result.Ptr[0].Ptr-Result.TextPtr.Ptr
  else
    Result.TextPtr.Size:=Result.MainPtr[0].Size-Result.TextPtr.Ptr;
  // />
  // Define IdxPtr
  W:=Addr(DW^);
  Result.IdxPtr.Ptr:=W^;
  Result.IdxPtr.Pos:=Result.MainPtr[0].Pos;
  Inc(DWord(Result.IdxPtr.Pos), W^);
  Result.IdxPtr.Size:=DWord(Result.TextPtr.Pos)-DWord(Result.IdxPtr.Pos);
  // Define IdxArr
  Inc(W);
  Result.IdxArr.Pos:=W;
  Result.IdxArr.Size:=DWord(Result.IdxPtr.Pos)-DWord(W);
  // First Data
  Result.DatArr.Pos:=Result.MainPtr[0].Pos;
  Result.DatArr.Size:=DWord(Result.IdxArr.Pos)-DWord(Result.DatArr.Pos)-(Length(Result.Ptr)*4+2);

  {SaveFile('_FF7\_LZ\Test\Data.ff7',Result.DatArr.Pos,Result.DatArr.Size);
  SaveFile('_FF7\_LZ\Test\IdxArray.ff7',Result.IdxPtr.Pos,Result.IdxPtr.Size);
  SaveFile('_FF7\_LZ\Test\IdxPtrs.ff7',Result.IdxArr.Pos,Result.IdxArr.Size);
  SaveFile('_FF7\_LZ\Test\Text.ff7',Result.TextPtr.Pos,Result.TextPtr.Size);
  For n:=0 To Length(Result.Ptr)-1 do
  SaveFile(Format('_FF7\_LZ\Test\File%d.ff7',[n+1]),Result.Ptr[n].Pos,Result.Ptr[n].Size); }

end;

Function BuildDat(var DAT: TDAT; var Buf: Pointer): Integer;
var B: ^Byte; W: ^Word; DW: ^DWord; n,m: Integer; FL: ^Byte; BPtr: DWord;
begin
  B:=Buf; Inc(B,$1C);
  Move(DAT.DatArr.Pos^,B^,DAT.DatArr.Size); // Пишем первый блок данных
  //SaveFile('_FF7\_LZ\Test\!!!',Buf,1000);
  Inc(B,DAT.DatArr.Size+Length(DAT.Ptr)*4 + 2);
  Move(DAT.IdxArr.Pos^, B^, DAT.IdxArr.Size);
  //SaveFile('_FF7\_LZ\Test\!!!',Buf,$81E4);
  Inc(B, DAT.IdxArr.Size);
  Move(DAT.IdxPtr.Pos^, B^, DAT.IdxPtr.Size); // Пишем массив поинтеров
  //SaveFile('_FF7\_LZ\Test\!!!',Buf,$81E4);
  Inc(B, DAT.IdxPtr.Size);
  Move(DAT.TextPtr.Pos^, B^, DAT.TextPtr.Size); // Пишем массив текста
  //SaveFile('_FF7\_LZ\Test\!!!',Buf,$81E4);
  Inc(B,RoundBy(DAT.TextPtr.Size,4));
  //
  For n:=0 To Length(DAT.Ptr)-1 do
  begin
    Move(DAT.Ptr[n].Pos^, B^, DAT.Ptr[n].Size);
    //SaveFile('_FF7\_LZ\Test\!!!',Buf,$81E4);
    Inc(B,DAT.Ptr[n].Size);
  end;
  FL:=Addr(B^);
  // Ptrs
  B:=Buf; Inc(B,$1C+6); B^:=Length(Dat.Ptr);
  W:=Addr(B^); Dec(W);
  W^:=Dat.DatArr.Size+(Length(Dat.Ptr)*4)+2+Dat.IdxPtr.Size+Dat.IdxArr.Size;
  B:=Buf; Inc(B,$1C); DW:=Addr(B^); Inc(DWord(DW),Dat.DatArr.Size);
  //SaveFile('_FF7\_LZ\Test\!!!',Buf,$81E4);
  For n:=0 To Length(Dat.Ptr)-1 do
  begin
    DW^:=W^+RoundBy(Dat.TextPtr.Size,4);
    For m:=0 To n-1 do Inc(DW^, Dat.Ptr[m].Size);
    //SaveFile('_FF7\_LZ\Test\!!!',Buf,$81E4);
    Inc(DW);
  end;
  W:=Addr(DW^); W^:=Dat.DatArr.Size+(Length(Dat.Ptr)*4)+2+Dat.IdxArr.Size;
  DW:=Buf;
  DW^:=DAT.MainPtr[0].Ptr; Inc(DW);
  DW^:=DWord(FL)-DWord(Buf)+Dat.MainPtr[0].Ptr-$1C;
  For n:=2 To 6 do
  begin
    BPtr:=DW^; Inc(DW);
    DW^:=BPtr+Dat.MainPtr[n-1].Size;
  end;
  B:=Addr(FL^);
  For n:=1 To 6 do
  begin
    Move(Dat.MainPtr[n].Pos^,B^,Dat.MainPtr[n].Size);
    Inc(B,Dat.MainPtr[n].Size);
  end;
  Result:=(DWord(B)-DWord(Buf));
  //SaveFile('_FF7\_LZ\Test\!!!',Buf,Result);
end;

end.
 