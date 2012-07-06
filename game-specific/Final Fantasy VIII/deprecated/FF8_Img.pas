unit FF8_Img;

interface

uses SysUtils, FF8_Compression, Windows, FF8_CD;

Type                         
  TStringArray = Array of String;
  TIMGFileRecord = Packed Record
    Sector: Integer;
    Size:   Integer;
  end;
  TOffsetSize = Packed Record
    osOffset: Integer;
    osSize:   Integer;
  end;
  TTOC = Array of TIMGFileRecord;
  TTOCArray = Array[Word] of TIMGFileRecord;
  PTOCArray = ^TTOCArray;
  TFF8IMGHeader = Array[0..132] of TIMGFileRecord;
  TFF8WorldTOC = Array[0..11] of TIMGFileRecord;
  TArray = Array[Word] of Byte;
  PArray = ^TArray;
  TProgrFunc = Function(const Cur, Max: Integer; const S: String): Boolean;
  DWord = LongWord;

  function IMG_WriteFile(const F: File; Sector: Integer; FileName: String; ToImage: Boolean = False; LastFile: Boolean = False): Integer;
  Procedure CompareBattle(File1, File2: String);
  procedure DecompressFiles(SrcDir, DestDir: String);
Procedure IMG_ExtractAll(InFiles: Array of String; OutDir: String; SLUSName: String = ''; OnProgress: TProgrFunc = nil);
procedure IMG_Build(FileName, Folder: String; CD: Integer;
  OnProgress: TProgrFunc = nil; BuildImage: Boolean = False; SLUSName: String = '');
Procedure ExtractGrp(FileName, SlusName, OutDir: String; OnProgress: TProgrFunc = nil);
Procedure BuildGrp(FileName, SlusName, InDir: String; OnProgress: TProgrFunc = nil);
procedure ExtractResources(InDir, OutDir: String; OnProgress: TProgrFunc = nil);
procedure ExtractKernel(FileName, OutDir: String);
implementation

{$INCLUDE names.pas}

const
  StartSector  = 826;
  SectorSize   = 2048;
  CommonFiles  = [0, 3, 5, 7..8, 10..14, 17, 19..22, 27..132];
  LZFiles      = [1,2,23,26];
  MusicScore   = [30..127];
  DifBattles: Array[0..13] of Integer =
  (21, 55, 57, 807, 830, 832, 835, 836, 974, 979, 983, 1018, 1058, 1092);
  //MainTocFile  = 2;
  //OtherTocFile = 1;

  HeaderCount = 133;

  DatOffset   = $28900;
  DatTocFile  = 2;
  DatCount: Array[1..4] of Integer = (309, 483, 596, 205);

  WorldTocFile = 26;
  WorldCount  = 12;
  WorldOffset = $2CCA4;
  
  TexTocFile  = 2;
  TexCount    = 76;
  TexOffset   = $286A0;

  AkaoTocFile = 2;
  AkaoCount   = 88;

  BattleTocFile  = 25;
  BattleOffset   = $499B4;
  BattleCount    = 1113;

  MainTocFile     = 1;
  MainOffset      = $10B8;
  MainCount       = 36;

  VideoCount: Array[1..4] of Integer = (32, 35, 34, 9);
  VideoTocFile = 2;


procedure SetSlash(var S: String);
begin
  If S = '' Then Exit;
  If S[Length(S)] <> '\' Then
    S := S + '\';
end;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If R = 0 Then Exit;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

procedure SaveFile(FileName: String; P: Pointer; Size: Integer);
var F: File;
begin
  AssignFile(F, FileName);
  Rewrite(F, 1);
  BlockWrite(F, P^, Size);
  CloseFile(F);
end;

procedure ExtractKernel(FileName, OutDir: String);
var F, WF: File; Buf: Pointer; Size, Count, n: Integer; A: Array of DWord;
begin
  SetSlash(OutDir);
  If not DirectoryExists(OutDir) Then
    ForceDirectories(OutDir);
  AssignFile(F, FileName);
  Reset(F, 1);
  BlockRead(F, Count, 4);
  SetLength(A, Count);
  BlockRead(F, A[0], Count * 4);
  GetMem(Buf, 1024 * 64);
  For n := 0 To Count - 1 do
  begin
    If n < (Count - 1) Then
      Size := A[n + 1] - A[n]
    else
      Size := FileSize(F) - A[n];
    Seek(F, A[n]);
    BlockRead(F, Buf^, Size);
    AssignFile(WF, OutDir + Format('kernel%2.2d.bin', [n]));
    Rewrite(WF, 1);
    BlockWrite(WF, Buf^, Size);
    CloseFile(WF);
  end;
  CloseFile(F);
  FreeMem(Buf);
end;

procedure ExtractResource(FileName, OutDir: String; Res: PResInfo; Count: Integer);
var F, WF: File; Buf: Pointer; n: Integer; Name: String;
begin
  SetSlash(OutDir);
  GetMem(Buf, 1024 * 256);
  AssignFile(F, FileName);
  Reset(F, 1);        
  If not DirectoryExists(OutDir) Then
    ForceDirectories(ExpandFileName(OutDir));
  For n := 0 To Count - 1 do
  begin
    Seek(F, Res^.Pos);
    BlockRead(F, Buf^, Res^.Size);
    Name := OutDir + Res^.Name;
    AssignFile(WF, Name);
    Rewrite(WF, 1);
    BlockWrite(WF, Buf^, Res^.Size);
    CloseFile(WF);
  end;
  CloseFile(F);
  FreeMem(Buf);
end;

procedure ExtractResources(InDir, OutDir: String; OnProgress: TProgrFunc = nil);
var m, n: Integer;
begin
  SetSlash(InDir);
  SetSlash(OutDir);
  For m := 0 To High(cResources) do With cResources[m] do
  begin
    If FileExists(InDir + Name) Then
    begin
      If @OnProgress <> nil Then
        OnProgress(m, Length(cResources), Name);
      ExtractResource(InDir + Name, OutDir, Info, Count);
    end else
    begin
      If @OnProgress <> nil Then
        OnProgress(-1, -1, Format('***ERROR: File %s not found!', [Name]));
    end;
    If (m = 0) Then
    begin
      InDir  := InDir  + 'menu\';
      OutDir := OutDir + 'menu\';
    end;
  end;
end;

procedure GetGrpNames(var List: TStringArray);
var n: Integer;
begin
  SetLength(List, Length(cGrpIndexes));
  For n := 0 To High(List) do
  begin
    Case n of
      00: List[n] := 'tkmnmes1.bin';
      01: List[n] := 'tkmnmes2.bin';
      02: List[n] := 'tkmnmes3.bin';
      //03: List[n] := 'msx.bin';
      05: List[n] := 'face1.tim';
      06: List[n] := 'face2.tim';
      07: List[n] := 'magita.tim';
      08: List[n] := 'start.tim';
      09: List[n] := 'mag00.tim'; // Double \/
      10: List[n] := 'mag07.tim';
      11..17: List[n] := Format('mag%2.2d.tim', [n - 11]); // mag00 doubled
      18: List[n] := 'mag08.tim';
      19: List[n] := 'mag09.tim';
      20..29: List[n] := Format('mc%2.2d.tim', [n - 20]);
      30..32: List[n] := Format('tutor%1.1d.tim', [n - 30 + 1]);
      33..37: List[n] := Format('mag%2.2d.tim', [n - 33 + 10]);
      38: List[n] := 'weapons.msd';
      39: List[n] := 'btltutor.msd';
      40: List[n] := 'cardrules.msd';
      41: List[n] := 'chocobo.msd';
      42: List[n] := 'test.msd';
      43..73: List[n] := Format('questions%2.2d.msd', [n - 42]);
      // 74 - pointers... to text?
      75: List[n] := 'info0.msx'; // Terms
      76: List[n] := 'info1.msx'; // Abilities
      77: List[n] := 'info2.msx'; // Abilities -> Select Menu Ability
      78: List[n] := 'info3.msx'; // Select Term
      79: List[n] := 'info4.msx'; // Magic
      80: List[n] := 'info5.msx'; // Basic Terms
      81..88: List[n] := Format('tutor%2.2d.msd', [n - 80]);

      97: List[n] := 'gfnames0.dat';
      98: List[n] := 'gfnames0.bin';
      99: List[n] := 'gfnames1.dat';
      100: List[n] := 'gfnames1.bin';
      101..105: List[n] := Format('mag%2.2d.tim', [n - 85]);
      106..110: List[n] := Format('m%3.3d.bin', [n - 105]);
      111..115: List[n] := Format('m%3.3d.msg', [n - 110]);
      116: List[n] := 'tutor09.msd';
    else
      List[n] := Format('grp%3.3d.bin', [n]);
    end;
  end;

end;

Procedure ExtractGrp(FileName, SlusName, OutDir: String; OnProgress: TProgrFunc = nil);
var F: File; Table: Array[0..205] of TOffsetSize;
n: Integer; Buf: Pointer; Name: String;  List: TStringArray;
begin
  SetSlash(OutDir);
  If not DirectoryExists(OutDir) and not ForceDirectories(OutDir) Then
    Exit;
  AssignFile(F, SlusName);
  Reset(F, 1);
  Seek(F, $44508);
  BlockRead(F, Table, SizeOf(Table));
  CloseFile(F);
  AssignFile(F, FileName);
  Reset(F, 1);
  GetMem(Buf, 1024*1024);
  GetGrpNames(List);
  For n := 0 to High(cGrpIndexes) do With Table[cGrpIndexes[n]] do
  begin
    //WriteLn(IntToHex(osOffset AND $FFFFFFFE, 8));
    If @OnProgress <> nil Then OnProgress(n, Length(cGrpIndexes), List[n]);
    Seek(F, osOffset and $FFFFFFFE);
    BlockRead(F, Buf^, osSize);
    SaveFile(OutDir + List[n], Buf, osSize);
  end;
  FreeMem(Buf);
  CloseFile(F);
end;

Procedure BuildGrp(FileName, SlusName, InDir: String; OnProgress: TProgrFunc = nil);
var Table: Array[0..205] of TOffsetSize; n, Pos: Integer; F, RF: File; Buf: Pointer;
List: TStringArray;
begin
  For n := 0 To High(Table) do With Table[n] do
  begin
    osOffset := -1;
    osSize   := 0;
  end;

  SetSlash(InDir);
  If not DirectoryExists(InDir) Then
    Exit;
  AssignFile(F, FileName);
  Rewrite(F, 1);
  GetMem(Buf, 1024*1024);
  GetGrpNames(List);
  Pos := 0;
  For n := 0 to High(cGrpIndexes) do With Table[cGrpIndexes[n]] do
  begin          
    If @OnProgress <> nil Then OnProgress(n, Length(cGrpIndexes), List[n]);
    //WriteLn(IntToHex(Pos, 8));
    Seek(F, Pos);
    osOffset := Pos + 1;
    AssignFile(RF, InDir + List[n]);
    Reset(RF, 1);
    osSize := FileSize(RF);
    BlockRead(RF, Buf^, osSize);
    CloseFile(RF);
    BlockWrite(F, Buf^, osSize);
    osSize := RoundBy(osSize, 2048);
    Inc(Pos, osSize);
  end;
  FreeMem(Buf);
  CloseFile(F);

  If SlusName <> '' Then
  begin
    AssignFile(F, SlusName);
    Reset(F, 1);
    Seek(F, $44508);
    BlockWrite(F, Table, SizeOf(Table));
    CloseFile(F);
  end;
end;

Procedure IMG_ExtractFile(const F: File; Sector, Size: Integer; FileName: String; CopyBuf: Pointer; BufSize: Integer; Image: Boolean; SizeFromLZ: Boolean = False);
var {Buf: Pointer; }WF: File; Dir: String; _Size, TempSize: Integer; P: PByte;
begin
  If Image Then
    Seek(F, Sector * $930 + $18)
  else
    Seek(F, (Sector - StartSector) * SectorSize);
  If SizeFromLZ Then
  begin
    BlockRead(F, Size, 4);
    Inc(Size, 4);
    If not Image Then
      Seek(F, (Sector - StartSector) * SectorSize);
  end;

  //GetMem(Buf, Size);
  //BlockRead(F, Buf^, Size);

  Dir := ExtractFilePath(ExpandFileName(FileName));
  If not DirectoryExists(Dir) Then
    ForceDirectories(Dir);
  AssignFile(WF, FileName);
  Rewrite(WF, 1);
  While Size > 0 do
  begin
    If BufSize > Size Then
      TempSize := Size
    else
      TempSize := BufSize;
    If Image Then
      ReadSectorsData(F, Sector, CopyBuf, TempSize)
    else
      BlockRead(F, CopyBuf^, TempSize);
    Inc(Sector, TempSize div 2048);
    BlockWrite(WF, CopyBuf^, TempSize);
    Dec(Size, TempSize);
  end;

  //BlockWrite(WF, Buf^, Size);
  //FreeMem(Buf);
  CloseFile(WF);
end;

Type
  TFilesType = (ftHeader, ftWorld, ftField, ftTex, ftAkao, ftBattle, ftMain, ftVideo);

Function InDifferentBattle(Index: Integer): Boolean;
var n: Integer;
begin
  Result := True;
  For n := 0 To High(DifBattles) do
    If DifBattles[n] = Index Then
      Exit;
  Result := False;
end;

procedure GetFileList(var List: TStringArray; FilesType: TFilesType; CD: Integer);
var n, m: Integer; Name: String;
const DatExt: Array[0..2] of String = ('.mim', '.dat', '.chr');
begin
  Case FilesType of
    ftHeader:
    begin
      SetLength(List, HeaderCount);
      For n := 0 To HeaderCount - 1 do
      begin
        If n in [4..20] Then
          List[n] := 'menu\menu' + cOVLNames[n] + '.ovl'
        else If n in [27..29] Then
          List[n] := Format('sound\unk_snd%2.2d.bin', [n - 27])
        //else If cHeaderNames[n] <> '' Then
        //  List[n] := cHeaderNames[n]
        else If n in MusicScore Then
          List[n] := Format('sound\music\score\music%3.3d.dat', [n - 30])
        else If n in CommonFiles Then
          List[n] := Format('other\file%3.3d.bin', [n])
        else
          List[n] := Format('other\file%3.3d_CD%1.1d.bin', [n, CD]);
      end;
      List[0]  :=  'main.ovl';
      List[3]  :=  'wm2field.tbl';
      List[21] :=  'menu\mngrp.bin';
      List[22] :=  'init.out';
      List[128] := 'kernel.bin';
      List[129] := 'sysfnt.tdw';
      List[130] := 'icon.tim';
      List[131] := 'namedic.bin';
      List[132] := 'sound\unk_snd.bin';
    end;
    ftField:
    begin
      SetLength(List, DatCount[CD] * 3);
      For n := 0 To DatCount[CD] - 1 do
      begin
        Case CD of
          1: Name := cDatNamesCD1[n];
          2: Name := cDatNamesCD2[n];
          3: Name := cDatNamesCD3[n];
          4: Name := cDatNamesCD4[n];
        end;
        For m := 0 to 2 do
          List[n*3+m] := 'field\mapdata\' + Name[1] + Name[2] + '\' + Name + DatExt[m];
      end;
    end;
    ftTex:
    begin
      SetLength(List, TexCount);
      For n := 0 To TexCount - 1 do
        List[n] := Format('textures\tex%3.3d.bin', [n]);
    end;
    ftWorld:
    begin  
      SetLength(List, WorldCount);
      For n := 0 To WorldCount - 1 do
        List[n] := 'world\' + cWorldNames[n];
    end;
    ftBattle:
    begin
      SetLength(List, BattleCount);
      For n := 0 To BattleCount - 1 do
      begin
        Case n of
               000: List[n] := 'scene.out';
          001..163: If InDifferentBattle(n) Then
                      List[n] := Format('a0stg%3.3d_CD%1.1d.x', [n - 001, CD])
                    else
                      List[n] := Format('a0stg%3.3d.x', [n - 001]);
               164: List[n] := 'a8def.tim';
               165: List[n] := 'a9btlfnt.bft';
               166: List[n] := 'b0wave.dat';
          167..310: List[n] := Format('c0m%3.3d.dat', [n - 167]);
          311..312: List[n] := Format('d0c%3.3d.dat', [n - 311]);
          313..320: List[n] := Format('d0w%3.3d.dat', [n - 313]);
          321:      List[n] := 'd1c003.dat';
          322:      List[n] := 'd1c004.dat';
          323..326: List[n] := Format('d1w%3.3d.dat', [n - 323 + 8]);
          327:      List[n] := 'd2c006.dat';
          328..331: List[n] := Format('d2w%3.3d.dat', [n - 328 + 13]);
          332:      List[n] := 'd3c007.dat';
          333..336: List[n] := Format('d3w%3.3d.dat', [n - 333 + 18]);
          337:      List[n] := 'd4c009.dat';
          338..342: List[n] := Format('d4w%3.3d.dat', [n - 338 + 23]);
          343..344: List[n] := Format('d5c%3.3d.dat', [n - 343 + 11]);
          345..348: List[n] := Format('d5w%3.3d.dat', [n - 345 + 28]);
          349:      List[n] := 'd6c014.dat';
          350:      List[n] := 'd6w033.dat';
          351:      List[n] := 'd7c016.dat';
          352..353: List[n] := Format('d8c%3.3d.dat', [n - 352 + 17]);
          354:      List[n] := 'd8w035.dat';
          355:      List[n] := 'd9c019.dat';
          356:      List[n] := 'd9c020.dat';
          357:      List[n] := 'd9w037.dat';
          358:      List[n] := 'dac021.dat';
          359:      List[n] := 'dac022.dat';
          360:      List[n] := 'daw039.dat';
          361..363: List[n] := Format('ma8def_%1.1d.tim', [n - 361]);
          364..367: List[n] := Format('ma8def_p.%1.1d', [n - 364]);
          368..383: List[n] := Format('mag005_b.%2.2d', [n - 368 + 2]);
          384..386: List[n] := Format('mag007_b.1s%1.1d', [n - 384]);
          387..388: List[n] := Format('mag007_b.1t%1.1d', [n - 387]);
          389..391: List[n] := Format('mag046_b.1t%1.1d', [n - 389]);
          392..395: List[n] := Format('mag064_h.%2.2d', [n - 392]);
          396:      List[n] := 'mag076_b.02';
          397:      List[n] := 'mag078_b.1s0';
          //
          566..576: List[n] := Format('mag200_b.%2.2d', [n - 566 + 2]);
          577..614: List[n] := Format('mag201_b.%2.2d', [n - 577 + 2]);
          615..625: List[n] := Format('mag202_b.%2.2d', [n - 615 + 2]);
          626..639: List[n] := Format('mag203_b.%2.2d', [n - 626 + 2]);
          640..649: List[n] := Format('mag204_b.%2.2d', [n - 640 + 2]);
          650..704: List[n] := Format('mag205_b.%2.2d', [n - 650 + 2]);
          705:      List[n] := 'mag209_h.00';
          706..709: List[n] := Format('mag217_%s.dat', [Char(n - 706 + Byte('a'))]);
          // 710 - ?
          711..713: List[n] := Format('mag218_b.%2.2d', [n - 711 + 2]);
          //

          766: List[n] := 'mag999_a.dat';
          767: List[n] := 'r0win.dat';
          768..1112:
            If InDifferentBattle(n) Then
              List[n] := Format('mag%3.3d_CD%1.1d.ovl', [n - 768, CD])
            else
              List[n] := Format('mag%3.3d.ovl', [n - 768]);
          else
          begin
            If InDifferentBattle(n) Then
              List[n] := Format('battle%4.4d_CD%1.1d.bin', [n, CD])
            else
              List[n] := Format('battle%4.4d.bin', [n]);
          end;
        end;
        If n < 768 Then
          List[n] := 'battle\' + List[n]
        else
          List[n] := 'magic\'  + List[n];
      end;
    end;
    ftMain:
    begin
      SetLength(List, MainCount);
      For n := 0 To MainCount - 1 do
        List[n] := cMainNames[n];
    end;
    ftVideo:
    begin
      SetLength(List, VideoCount[CD]);
      List[0] := 'video.ovl';
      For n := 1 To High(List) do
      begin
        Case CD of
          1: Name := cVideoNamesCD1[n];
          2: Name := cVideoNamesCD2[n];
          3: Name := cVideoNamesCD3[n];
          4: Name := cVideoNamesCD4[n];
        end;
        List[n] := 'Video\' + Name + '.smn';
      end;
    end;
    ftAkao:
    begin
      SetLength(List, AkaoCount);
      For n := 0 To High(List) do
        List[n] := Format('sound\akao\akao%3.3d.bin', [n]);
    end;
  end;
  
end;

Function LoadFile(FileName: String; out Buf: Pointer): Integer;
var F: File;
begin
  WriteLn(FileName);
  AssignFile(F, FileName);
  Reset(F, 1);
  Result := FileSize(F);
  GetMem(Buf, Result);
  BlockRead(F, Buf^, Result);
  CloseFile(F);
end;

var
  ISOBuf: Array[0..512-1] of TMode2Sector;

function IMG_WriteFile(const F: File; Sector: Integer; FileName: String; ToImage: Boolean = False; LastFile: Boolean = False): Integer;
var Buf: Pointer; SrcF: File; Size, n, Count, ModeData: Integer;
begin
  ModeData := $080000;
  If not ToImage Then
  begin
    Result := LoadFile(FileName, Buf);
    Seek(F, Sector * SectorSize);
    BlockWrite(F, Buf^, Result);
    FreeMem(Buf);
  end else
  begin
    AssignFile(SrcF, FileName);
    Reset(SrcF, 1);
    Result := FileSize(SrcF);
    Size := FileSize(SrcF);
    Seek(F, (StartSector + Sector) * 2352);
    While Size > 0 do
    begin
      If Size >= 2048 * 512 Then
        Count := ReadToSectors(SrcF, @ISOBuf, 2048 * 512)
      else                                               
        Count := ReadToSectors(SrcF, @ISOBuf, Size);
      Dec(Size, 2048 * 512);
      If LastFile and (Size <= 0) Then
        ModeData := $890000;
      For n := 0 To Count - 1 do
        ConvertSector(@ISOBuf[n], StartSector + Sector + n, ModeData);
      BlockWrite(F, ISOBuf, Count * SizeOf(TMode2Sector));
      Inc(Sector, Count);
    end;
    CloseFile(SrcF);
  end;
end;

function IMG_WriteMemory(const F: File; Data: Pointer; Size, Sector: Integer; ToImage: Boolean = False): Integer;
var n, Count: Integer;
begin    
  Result := Size;
  If not ToImage Then
  begin
    Seek(F, Sector * SectorSize);
    BlockWrite(F, Data^, Result);
  end else
  begin
    Seek(F, (StartSector + Sector) * 2352);
    While Size > 0 do
    begin
      If Size >= 2048 * 512 Then
        Count := ReadToSectors(Data, @ISOBuf, 2048 * 512)
      else                                               
        Count := ReadToSectors(Data, @ISOBuf, Size);
      Inc(LongWord(Data), 2048 * 512);
      Dec(Size, 2048 * 512);
      For n := 0 To Count - 1 do
        ConvertSector(@ISOBuf[n], StartSector + Sector + n);
      BlockWrite(F, ISOBuf, Count * SizeOf(TMode2Sector));
      Inc(Sector, Count);
    end;
  end;
end;

procedure IMG_Build(FileName, Folder: String; CD: Integer;
  OnProgress: TProgrFunc = nil; BuildImage: Boolean = False; SLUSName: String = '');
var
  BufFile001, BufFile002, BufFile025, BufFile026, Buf: Pointer;
  Size001, Size002, Size025, Size026, Size: Integer;
  Sec001, Sec002, Sec025, Sec026: Integer;
  Pos, n, Offset: Integer; CharBuf: Array[0..MAX_PATH] of Char;
  HTOC: TFF8IMGHeader; HList, List: TStringArray;
  F: File; TempDir: String;
  TOC: PTOCArray;
  procedure LoadBufFile(const FileName: String; out Buffer: Pointer; out Size: Integer);
  begin
    Size := LoadFile(FileName, Buf);
    GetMem(Buffer, 1024*1024);
    lzs_decompress(Pointer(DWord(Buf) + 4), Size - 4, Buffer, Size);
    FreeMem(Buf);
    ReallocMem(Buffer, Size);
  end;
  procedure Write(const FileName: String; out Sector: Integer; out Size: Integer; LastFile: Boolean = False);
  begin
    WriteLn(FileName);
    Sector := Pos + StartSector;
    If (FileName[1] = '\') or (FileName[2] = ':') Then
      Size := IMG_WriteFile(F, Pos, FileName, BuildImage, LastFile)
    else
      Size := IMG_WriteFile(F, Pos, Folder + FileName, BuildImage, LastFile);
    Inc(Pos, RoundBy(Size, SectorSize) div SectorSize);
  end;
//const
  //cTempGrpName = '~grp.tmp';
begin
  If BuildImage and (SLUSName = '') Then
    Exit;

  SetSlash(Folder);
  GetFileList(HList, ftHeader, CD);
  {
  If (SLUSName <> '') Then
  begin
    If not FileExists(SLUSName) Then
    begin
      If @OnProgress <> nil Then OnProgress(-1, -1, '***ERROR: File not Found - ' + SLUSName);
      Exit;
    end;
    GetTempPath(SizeOf(CharBuf), @CharBuf);
    TempDir := CharBuf;
    SetSlash(TempDir);
    If @OnProgress <> nil Then OnProgress(-1, -1, 'Building GRP...');
    BuildGrp(TempDir + cTempGrpName, SLUSName, Folder + 'menu\', @OnProgress);
    HList[21] := TempDir + cTempGrpName;
  end;
  }

  If @OnProgress <> nil Then OnProgress(-1, -1, 'Building IMG...');

  LoadBufFile(Folder + HList[01], BufFile001, Size001);
  LoadBufFile(Folder + HList[02], BufFile002, Size002);
  Size025 := LoadFile(Folder + HList[25], BufFile025);
  LoadBufFile(Folder + HList[26], BufFile026, Size026);
  GetMem(Buf, 1024*1024);
  lzs_compress(BufFile001, Size001, Buf, Sec001);
  lzs_compress(BufFile002, Size002, Buf, Sec002);
  lzs_compress(BufFile026, Size026, Buf, Sec026);
  Sec001 := RoundBy(Sec001 + $200, $800) div $800;
  Sec002 := RoundBy(Sec002 + $200, $800) div $800;
  Sec026 := RoundBy(Sec026 + $200, $800) div $800;
  Sec025 := RoundBy(Size025, $800) div $800;
  FreeMem(Buf);

  FillChar(HTOC, SizeOf(HTOC), 0);
  AssignFile(F, FileName);
  Rewrite(F, 1);
  Pos := 1;

  Write(HList[0], HTOC[0].Sector, HTOC[0].Size);
  HTOC[1].Sector := Pos + StartSector;                                          // toc001
  Inc(Pos, Sec001);                                                             //
  For n := 128 to 132 do
    Write(HList[n], HTOC[n].Sector, HTOC[n].Size);
  For n := 27 to 29 do
    Write(HList[n], HTOC[n].Sector, HTOC[n].Size);
  n := 23;
  Write(HList[n], HTOC[n].Sector, HTOC[n].Size);

  HTOC[26].Sector := Pos + StartSector;                                         // toc026
  Inc(Pos, Sec026);                                                             //
  //Write(HList[26], HTOC[n].Sector, HTOC[n].Size);

  (*      WORLD    *)
  GetFileList(List, ftWorld, CD);
  TOC := Pointer(DWord(BufFile026) + WorldOffset);
  For n := 0 To WorldCount - 1 do
    Write(List[n], TOC^[n].Sector, TOC^[n].Size);
  (*  - - - - - -  *)

  //Write(HList[2], HTOC[2].Sector, HTOC[2].Size);
  HTOC[2].Sector := Pos + StartSector;                                          // toc002
  Inc(Pos, Sec002);                                                             //
  
  n := 3;
  Write(HList[n], HTOC[n].Sector, HTOC[n].Size);


  (*  Field (DAT)  *)
  GetFileList(List, ftField, CD);
  TOC := Pointer(DWord(BufFile002) + DatOffset);
  For n := 0 To (DatCount[CD] * 3) - 1 do
    Write(List[n], TOC^[n].Sector, TOC^[n].Size);
  (*  - - - - - -  *)

  (*      TEX      *)
  GetFileList(List, ftTex, CD);
  TOC := Pointer(DWord(BufFile002) + TexOffset);
  For n := 0 To TexCount - 1 do
    Write(List[n], TOC^[n].Sector, TOC^[n].Size);
  (*  - - - - - -  *)

  For n := 30 To 127 do
    Write(HList[n], HTOC[n].Sector, HTOC[n].Size);


  (* AKAO *)
  GetFileList(List, ftAkao, CD);
  Offset := Word(Pointer(DWord(BufFile002) + $440)^) + $287AC + VideoCount[CD]*8;
  If CD < 3 Then Inc(Offset, 8);
  TOC := Pointer(DWord(BufFile002) + Offset);
  For n := 0 To AkaoCount - 1 do
    Write(List[n], TOC^[n].Sector, TOC^[n].Size);
  (* ---- *)

  For n := 4 To 22 do
    Write(HList[n], HTOC[n].Sector, HTOC[n].Size);
  n := 24;
  Write(HList[n], HTOC[n].Sector, HTOC[n].Size);

  HTOC[25].Sector := Pos + StartSector;                                         // toc025
  HTOC[25].Size   := Size025;                                                   //
  Inc(Pos, Sec025);                                                             //

  (* Battle *)  
  GetFileList(List, ftBattle, CD);
  TOC := Pointer(DWord(BufFile025) + BattleOffset);
  For n := 0 To BattleCount - 1 do
    Write(List[n], TOC^[n].Sector, TOC^[n].Size);
  For n := BattleCount to BattleCount + 4 do
  begin
    TOC^[n].Sector := Pos;
    TOC^[n].Size   := 0;
  end;
  (* ------ *)

  (*   LZS  *)
  GetFileList(List, ftMain, CD);
  TOC := Pointer(DWord(BufFile001) + MainOffset);
  For n := 0 To MainCount - 1 do
    Write(List[n], TOC^[n].Sector, TOC^[n].Size);
  (* ------ *)

  (*  Video *)
  GetFileList(List, ftVideo, CD);
  Offset := Word(Pointer(DWord(BufFile002) + $440)^) + $287AC;
  TOC := Pointer(DWord(BufFile002) + Offset);
  For n := 0 To VideoCount[CD] - 1 do
    Write(List[n], TOC^[n].Sector, TOC^[n].Size, n = VideoCount[CD] - 1);
  If CD < 3 Then
  begin
    TOC^[n].Sector := TOC^[0].Sector;
    TOC^[n].Size   := 0;
  end;
  (* ------ *)

  //SaveFile('001.test', BufFile001, Size001);
  //SaveFile('002.test', BufFile002, Size002);
  //SaveFile('025.test', BufFile025, Size025);
  //SaveFile('026.test', BufFile026, Size026);


  IMG_WriteMemory(F, BufFile025, Size025, HTOC[25].Sector - StartSector, BuildImage);
  //Seek(F, (HTOC[25].Sector - StartSector) * SectorSize);
  //BlockWrite(F, BufFile025^, Size025);

  GetMem(Buf, 1024*1024);
  lzs_compress(BufFile001, Size001, Buf, Size);
  HTOC[1].Size := Size;
  IMG_WriteMemory(F, Buf, Size, HTOC[1].Sector - StartSector, BuildImage);
  //Seek(F, (HTOC[1].Sector - StartSector) * SectorSize);
  //BlockWrite(F, Buf^, Size);

  lzs_compress(BufFile002, Size002, Buf, Size);  
  HTOC[2].Size := Size;       
  IMG_WriteMemory(F, Buf, Size, HTOC[2].Sector - StartSector, BuildImage);
  //Seek(F, (HTOC[2].Sector - StartSector) * SectorSize);
  //BlockWrite(F, Buf^, Size);

  lzs_compress(BufFile026, Size026, Buf, Size); 
  HTOC[26].Size := Size;
  IMG_WriteMemory(F, Buf, Size, HTOC[26].Sector - StartSector, BuildImage);
  //Seek(F, (HTOC[26].Sector - StartSector) * SectorSize);
  //BlockWrite(F, Buf^, Size);
  FreeMem(Buf);

  //Seek(F, 0);
  //BlockWrite(F, HTOC, SizeOf(HTOC));
  IMG_WriteMemory(F, @HTOC, SizeOf(HTOC), 0, BuildImage);

  FreeMem(BufFile001);
  FreeMem(BufFile002);
  FreeMem(BufFile025);
  FreeMem(BufFile026);

  If BuildImage Then
  begin
    WritePrimarySectors(F, CD, Pos * 2048, SLUSName);
    FillChar(ISOBuf, 150 * SizeOf(TMode2Sector), 0);
    For n := 0 To 150 - 1 do
      ConvertSector(@ISOBuf[n], Pos + StartSector + n, $200000);
    Seek(F, (Pos + StartSector) * $930);
    BlockWrite(F, ISOBuf, 150 * SizeOf(TMode2Sector));
  end;

  
  {
  If (SLUSName <> '') and FileExists(TempDir + cTempGrpName) Then
    DeleteFile(PChar(TempDir + cTempGrpName));
  }

  CloseFile(F);
end;

Type
  TTOCList = Array[TFilesType] of TTOC;
procedure GetToc(const F: File; var TOC: TTOCList; CD: Integer; Image: Boolean);
var Buf, tBuf: Pointer; Size, Offset: Integer;
begin
  GetMem(Buf,  2048 * 1024);
  GetMem(tBuf, 2048 * 1024);

  If Image Then
    Seek(F, StartSector * $930 + $18)
  else
    Seek(F, 0);
  SetLength(TOC[ftHeader], 133);
  BlockRead(F, TOC[ftHeader, 0], 133 * 8);

  ///////////////////////////////////////////////////////////////
  If Image Then
    Seek(F, TOC[ftHeader, 2].Sector * $930 + $18)
  else
    Seek(F, (TOC[ftHeader, 2].Sector - StartSector) * SectorSize);
  BlockRead(F, Size, 4);
  If Image Then
    ReadSectorsData(F, TOC[ftHeader, 2].Sector, tBuf, Size, 4)
  else
    BlockRead(F, tBuf^, Size);
  lzs_decompress(tBuf, Size, Buf, Size);
  // Field
  SetLength(TOC[ftField], DatCount[CD] * 3);
  Move(Pointer(DWord(Buf) + DatOffset)^, TOC[ftField, 0], DatCount[CD] * 3 * 8);
  // Textures
  SetLength(TOC[ftTex], TexCount);
  Move(Pointer(DWord(Buf) + TexOffset)^, TOC[ftTex, 0], TexCount * 8);
  // Videos
  SetLength(TOC[ftVideo], VideoCount[CD]);
  Offset := Word(Pointer(DWord(Buf) + $440)^) + $287AC;//
  Move(Pointer(DWord(Buf) + Offset)^, TOC[ftVideo, 0], VideoCount[CD] * 8);
  // Akao
  SetLength(TOC[ftAkao], AkaoCount);
  Offset := Offset + VideoCount[CD] * 8;
  If CD < 3 Then Inc(Offset, 8);   
  Move(Pointer(DWord(Buf) + Offset)^, TOC[ftAkao, 0], AkaoCount * 8);

  ///////////////////////////////////////////////////////////////
  If Image Then
    Seek(F,  TOC[ftHeader, 1].Sector * $930 + $18)
  else
    Seek(F, (TOC[ftHeader, 1].Sector - StartSector) * SectorSize);
  BlockRead(F, Size, 4);
  If Image Then
    ReadSectorsData(F, TOC[ftHeader, 1].Sector, tBuf, Size, 4)
  else
    BlockRead(F, tBuf^, Size);
  lzs_decompress(tBuf, Size, Buf, Size);
  // Lzs wallpapers
  SetLength(TOC[ftMain], MainCount);
  Move(Pointer(DWord(Buf) + MainOffset)^, TOC[ftMain, 0], MainCount * 8);

  ///////////////////////////////////////////////////////////////
  If Image Then
    Seek(F,  TOC[ftHeader, 26].Sector * $930 + $18)
  else
    Seek(F, (TOC[ftHeader, 26].Sector - StartSector) * SectorSize);
  BlockRead(F, Size, 4);
  If Image Then
    ReadSectorsData(F, TOC[ftHeader, 26].Sector, tBuf, Size, 4)
  else
    BlockRead(F, tBuf^, Size);
  lzs_decompress(tBuf, Size, Buf, Size);
  // World
  SetLength(TOC[ftWorld], WorldCount);
  Move(Pointer(DWord(Buf) + WorldOffset)^, TOC[ftWorld, 0], WorldCount * 8);

  ////////////////////////////////////////////////////////////////
  If Image Then
    ReadSectorsData(F, TOC[ftHeader, 25].Sector, Buf, TOC[ftHeader, 25].Size)
  else
  begin
    Seek(F, (TOC[ftHeader, 25].Sector - StartSector) * SectorSize);
    BlockRead(F, Buf^, TOC[ftHeader, 25].Size);
  end;
  // Battle
  SetLength(TOC[ftBattle], BattleCount); 
  Move(Pointer(DWord(Buf) + BattleOffset)^, TOC[ftBattle, 0], BattleCount * 8);

  FreeMem(Buf);
  FreeMem(tBuf);
end;

Type
  T4ByteArray = Array[1..4] of Boolean;

Function FieldExtracted(Name: String; const A: T4ByteArray): Boolean;
var n, CD, Count: Integer; C: PChar; S: String[8];
begin
  Result := True;
  Name := ChangeFileExt(ExtractFileName(Name), '');
  For CD := 1 To 4 do
  begin
    If not A[CD] Then Continue;
    C := cDatNamesPtrs[CD];
    Count := DatCount[CD];
    For n := 0 To Count - 1 do
    begin
      Move(Pointer(C)^, S[0], 8);
      If PChar(@S) = Name Then
        Exit;
      Inc(C, 8);
    end;
  end;
  Result := False;
end;

procedure IMG_Extract(FileName, Folder: String; CD: Integer; ExtractedCD: T4ByteArray; SLUSName: String = ''; OnProgress: TProgrFunc = nil; CommonExtracted: Boolean = False);
var
  F: File; TOC: TTOCList; n, Count, Num: Integer; Cur: TFilesType;
  List: TStringArray; Buf: Pointer; Image: Boolean; Hdr: Array[0..11] of Byte;
const BufSize = 1024 * 1024 * 32;
begin
  If not (CD in [1..4]) Then Exit;
  SetSlash(Folder);
  FileMode := fmOpenRead;
  AssignFile(F, FileName);
  Reset(F, 1);
  BlockRead(F, Hdr, SizeOf(Hdr));
  Image := CompareMem(@Hdr, @cSectorHeader, SizeOf(Hdr));

  GetToc(F, TOC, CD, Image);
  GetMem(Buf, BufSize);

  Count := 0;
  Num := -1;
  For Cur := Low(TFilesType) to High(TFilesType) do
    Inc(Count, Length(TOC[Cur]));

  For Cur := Low(TFilesType) to High(TFilesType) do
  begin
    If CommonExtracted and (Cur in [ftWorld, ftTex, ftAkao, ftMain]) Then Continue;
    GetFileList(List, Cur, CD);
    If not CommonExtracted or (Cur = ftHeader) or (Cur = ftField) or (Cur = ftBattle) or (Cur = ftVideo)Then
    begin
      For n := 0 To High(TOC[Cur]) do with TOC[Cur, n] do
      begin
        Inc(Num);
        Case Cur of
          ftWorld:  Continue;

          ftHeader: If CommonExtracted and (n in CommonFiles) Then Continue;
          ftBattle: If CommonExtracted and not InDifferentBattle(n) Then Continue;
          ftField:  If CommonExtracted and FieldExtracted(List[n], ExtractedCD) Then Continue;
          ftVideo:  If CommonExtracted and (n = 0) Then Continue;
        else
          If CommonExtracted Then
            break;
        end;
        If @OnProgress <> nil Then
          OnProgress(Num, Count, List[n]);
        IMG_ExtractFile(F, Sector, Size, Folder + List[n], Buf, BufSize, Image, (Cur = ftHeader) and (n in LZFiles));
      end;
    end;
  end;
  If not CommonExtracted and (SLUSName <> '') Then
    ExtractGrp(Folder + 'menu\mngrp.bin', SLUSName, Folder + 'menu\');

  FreeMem(Buf);
  CloseFile(F);
  
end;

Procedure IMG_ExtractAll(InFiles: Array of String; OutDir: String; SLUSName: String = ''; OnProgress: TProgrFunc = nil);
var n: Integer; CommonExtracted: Boolean; Name: String; A: T4ByteArray;
begin
  CommonExtracted := False;
  FillChar(A, SizeOf(A), 0);
  //SetSlash(InDir);
  For n := 1 to 4 do
  begin
    If Length(InFiles) < n Then break;
    //Name := Format('%sFF8DISC%1.1d.IMG', [InDir, n]);
    Name := InFiles[n - 1];
    If (Name <> '') and (FileExists(Name)) Then
    begin
      IMG_Extract(Name, OutDir, n, A, SLUSName, @OnProgress, CommonExtracted); 
      A[n] := True;
      CommonExtracted := True;
    end;
  end;
end;

(*  ///////////////////////////
  Cur := 0;
  For m := 0 To High(HTOC) do
  begin
    Min := High(Min);
    For n := 0 To High(HTOC) do
    begin
      If (HTOC[n].Sector < Min) and (HTOC[n].Sector > Cur) Then
      begin
        Min := HTOC[n].Sector;
        MinID := n;
      end;
    end;
    Cur := Min;
    WriteLn(MinID:4, '  ', Min-StartSector);
  end;
*)

procedure DecompressFiles(SrcDir, DestDir: String);
var SR: TSearchRec; Buf0, Buf1: Pointer; F: File; Size: Integer;
begin
  SetSlash(SrcDir);
  SetSlash(DestDir);
  If not DirectoryExists(DestDir) Then
    ForceDirectories(DestDir);
  If FindFirst(SrcDir + '*', faAnyFile XOR faDirectory, SR) = 0 Then
  begin
    GetMem(Buf0, 1024*1024*8);
    GetMem(Buf1, 1024*1024*8);
    repeat
      AssignFile(F, SrcDir + SR.Name);
      Reset(F, 1);
      Size := FileSize(F);
      BlockRead(F, Buf0^, Size);
      CloseFile(F);
      If Integer(Buf0^) = Size - 4 Then
      begin
        WriteLn(SR.Name);
        lzs_decompress(Pointer(Integer(Buf0)+4), Size - 4, Buf1, Size);
        AssignFile(F, DestDir + SR.Name);
        Rewrite(F, 1);
        BlockWrite(F, Buf1^, Size);
        CloseFile(F);
      end;
    until FindNext(SR) <> 0;
    FreeMem(Buf0);
    FreeMem(Buf1);
  end;

end;

Procedure CompareBattle(File1, File2: String);
var F: Array[0..1] of File; TOC: Array[0..1, 0..BattleCount-1] of TIMGFileRecord;
    n, i, Offset: Integer; FileName: Array[0..1] of String; Buf: Array[0..1] of Pointer;
    A: Array[0..BattleCount-1] of Boolean;
begin
  FileName[0] := File1;
  FileName[1] := File2;
  FillChar(A, SizeOf(A), 0);
  For n := 0 To 1 do
  begin
    AssignFile(F[n], FileName[n]);
    Reset(F[n], 1);
    Seek(F[n], 25*8);
    BlockRead(F[n], Offset, 4);
    Seek(F[n], (Offset - StartSector) * SectorSize + BattleOffset);
    BlockRead(F[n], TOC[n], BattleCount * 8);
    GetMem(Buf[n], 1024*1024*16);
  end;

  For i := 0 To BattleCount - 1 do
  begin
    Write(#13, i+1, '/', BattleCount);
    If TOC[0, i].Size <> TOC[1, i].Size Then
    begin
      A[i] := True;
      Continue;
    end;
    For n := 0 To 1 do
    begin
      Seek(F[n], (TOC[n, i].Sector - StartSector) * SectorSize);
      BlockRead(F[n], Buf[n]^, TOC[n, i].Size);
    end;
    A[i] := not CompareMem(Buf[0], Buf[1], TOC[0, i].Size);
  end;
  WriteLn('Result:');
  For i := Low(A) to High(A) do
    If A[i] Then WriteLn(i);

  For n := 0 To 1 do
  begin
    CloseFile(F[n]);
    FreeMem(Buf[n]);
  end;

end;

end.
