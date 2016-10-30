unit STR;

interface

uses
  Windows, SysUtils;

Type
	TSTRHeader = Packed Record
		StStatus:		Word;
		StType:			Word;
		StSector_Offset:Word;
		StSector_Size:	Word;
		StFrame_No:		DWord;
		StFrameSize:	DWord;
		StUser:			Array[0..15] of Byte;
	end;

  TFrame = Packed Record
    Sector,Pos: Integer;
    Head:   TSTRHeader;
  end;

  TFrameArray = Array of TFrame;

  TSTRParam = Packed Record
    BeginPos      : Integer;
    SectorSize    : Integer;
    HeaderOffset  : Integer;
  end;

  TPSector = Array of Byte;
  TBadArray = Array[Word] Of Boolean;

//var
  
Function LoadFrames(FileName: String; P: TSTRParam; var Sectors: Integer; var Bad: TBadArray): TFrameArray;
Function ReplaceFrames(DestFile, SrcFile: String; DestP,SrcP:TSTRParam; F1,F2: Integer): String;

implementation

//Function GetSector(FileName: String; Buf: Pointer; Sector: Integer): TSTRHeader;

Function LoadFrames(FileName: String; P: TSTRParam; var Sectors: Integer; var Bad: TBadArray): TFrameArray;
var F: File; Pos: Integer; n: Integer;
begin
  If not FileExists(FileName) Then Exit;
  AssignFile(F,FileName);
  Reset(F,1);
  Pos:=0;
  Sectors:=0;
  While Pos<=FileSize(F)-P.SectorSize do
  begin
    //If Sectors>15 Then Break;
    n:=Length(Result);
    Seek(F, Pos+P.BeginPos+P.HeaderOffset);
    SetLength(Result, n+1);
    BlockRead(F,Result[n].Head,16);
    If ((Result[n].Head.StStatus and $00F0)<>$0060)
    or ((Sectors>0) and (Result[n].Head.StFrame_No=Result[n-1].Head.StFrame_No)) Then
    begin
      //SetLength(Bad, Length(Bad)+1);
      Bad[Sectors]:=True;
      Inc(Sectors);
      Inc(Pos, P.SectorSize);
      SetLength(Result, n);
    end else
    If (Sectors>0) and (Result[n].Head.StFrame_No<>Result[n-1].Head.StFrame_No+1) Then
    begin
      SetLength(Result, n);
      Break;
    end else
    begin
      Result[n].Pos:=Pos+P.BeginPos;
      Result[n].Sector:=Pos div P.SectorSize;
      Inc(Pos, Result[n].Head.StSector_Size*P.SectorSize);
      Inc(Sectors, Result[n].Head.StSector_Size);
    end;
  end;
  CloseFile(F);
end;

Function ReplaceFrames(DestFile, SrcFile: String; DestP,SrcP:TSTRParam; F1,F2: Integer): String;
var DestF, SrcF: TFrameArray; n,m,SPos,DPos: Integer; Sector: TPSector;
SF, DF: File; D: Integer; B,B1: TBadArray; H: TStrHeader;
Label R;
begin
  If (not FileExists(DestFile)) or (not FileExists(SrcFile)) then
  begin
    Result:='File not found!';
    Exit;
  end;

  Result:='';
  If DestP.SectorSize-DestP.HeaderOffset<SrcP.SectorSize-SrcP.HeaderOffset
  Then Result:='Src sector size larger dest sector size!';
  SrcF:=LoadFrames(SrcFile, SrcP, D, B1);
  DestF:=LoadFrames(DestFile, DestP, D,B);
  If (F1<0) or (F1>F2) or (F2>Length(DestF)) or (F2>Length(SrcF))
  then Result:='Frame count or index error!';
  For n:=F1 to F2 do
  begin
    If DestF[n-1].Head.StSector_Size<SrcF[n-1].Head.StSector_Size Then
    begin
      Result:=Format(
      'Source sector count more destantion sector count (Frame #%d, Dest: %d, Src: %d)',
      [n,DestF[n-1].Head.StSector_Size,SrcF[n-1].Head.StSector_Size]);
      Exit;
    end;
  end;
  If Result<>'' Then Exit;

  SetLength(Sector, SrcP.SectorSize-SrcP.HeaderOffset);

  AssignFile(SF, SrcFile);
  AssignFile(DF, DestFile);
  Reset(SF,1);
  Reset(DF,1);
  For n:=F1-1 to F2-1 do
  begin
    SPos:=SrcF[n].Pos;
    DPos:=DestF[n].Pos;
    For m:=0 To SrcF[n].Head.StSector_Size-1 do
    begin
        Seek(SF, SPos+SrcP.HeaderOffset + SrcP.SectorSize*m);
        BlockRead(SF, Sector[0], Length(Sector));

    R:
        Seek(DF, DPos+DestP.HeaderOffset + DestP.SectorSize*m);
        BlockRead(DF,H,32);
        If (H.StStatus and $00F0)<>$0060 Then
        begin
          Inc(DPos,DestP.SectorSize);
          GoTo R;
        end;
        Seek(DF, DPos+DestP.HeaderOffset + DestP.SectorSize*m);
        BlockWrite(DF, Sector[0], Length(Sector));
    end;
  end;
  CloseFile(SF);
  CloseFile(DF);
end;

end.
