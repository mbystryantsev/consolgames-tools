program Extract;

{$APPTYPE CONSOLE}
//{$DEFINE EMULATION}

uses
  SysUtils, GBAUnit, StrUtils, Classes, SCANF;

Type
  TOffsetArray = Array[0..1] of DWord;
  DWord = LongWord;
  TWinXFile = Packed Record
    fNextPos: TOffsetArray;
    fSize:    DWord;
    fU:       DWord;
    fName:    Array[0..$40-1] of Char;
  end;
  TFilesHeader = Packed Record
    Sign:     Array[0..7] of Char;
    U0:       DWord;
    ArcSize:  DWord;
    Count:    Dword;
    U1,U2:    DWord;
    FOffset:  DWord;
    FSign:    Array[0..15] of Char;
  end;


Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

Type TNameOffset = Packed Record
  FileName: String;
  Offset:   DWord;
  NOffset:  TOffsetArray;
  U:        DWord;
  //PU:       ^DWord;
  PO:       ^TOffsetArray;
end;
TM = Packed Record m0,m1: Integer; end;
TNameOffsetArray = Array of TNameOffset;

var Buf: Pointer; H: ^TWinXFile; Header: ^TFilesHeader;
n,i,v,NameLen, FSize: Integer; OutDir,FileName: String; F: File; P: Pointer; m: Array[0..1] of Integer;
WBuf: Pointer; List: TStringList;  NO: TNameOffsetArray; PM: ^TM; DW: ^Integer; PC: PChar;
FName,Dir: String; LZ: Boolean;




Procedure Build();
var Folders: Array of String; S: String;
begin
  For n:=4 to ParamCount do
  begin
    If DirectoryExists(ParamStr(n)) Then
    begin
      SetLength(Folders,Length(Folders)+1);
      Folders[High(Folders)]:=ParamStr(n);
    end;
  end;
  SetLength(Folders,Length(Folders)+1);
  Folders[High(Folders)]:=ExtractFilePath(ParamStr(2));
  GetMem(WBuf,$400000);

  AssignFile(F,ParamStr(3));
  Reset(F,1);
  GetMem(Buf,FileSize(F));
  BlockRead(F,Buf^,FileSize(F));
  CloseFile(F);
  List:=TStringList.Create;
  List.LoadFromFile(ParamStr(2));
  Header:=Buf;
  Inc(DWord(Header),$ACBB0);

  P:=Header;
  FillChar(P^,$753450,0);

  Header^.Sign := 'JonFS1.2';
  H:=Addr(Header^);
  Inc(DWord(H),$30);
  With Header^ do sscanf(PChar(List.Strings[0]),'%8x %8x %8x',[@U0,@U1,@U2]);
  SetLength(NO,List.Count-1);
  For n:=0 To List.Count-2 do
  begin
    S := List.Strings[n+1];
    With NO[n] do sscanf(PChar(S),'%4d %4d %8x %s',[@NOffset[0],@NOffset[1],@H^.fU{@U},@H^.fName]);
    If (n and not $F) = n Then WriteLn(Format('[%d/%d] %s',[n+1, List.Count-1, H^.fName]));
    PC:=@H^.fName;
    NO[n].FileName := PC;
    If RightStr(NO[n].FileName,3)='.lz' Then
    begin
      FName:=LeftStr(NO[n].FileName,Length(NO[n].FileName)-3);
      LZ:=True;
    end else
    begin
      FName:=NO[n].FileName;
      LZ:=False;
    end;
    For i:=0 To High(Folders) do
    begin
      If FileExists(Format('%s\%s',[Folders[i],FName])) Then
      begin
        Dir :=Folders[i];
        Break;
      end;
    end;
    If i=Length(Folders) Then
    begin
      WriteLn(Format('Input file %s not found!',[FName]));
    end;
    P:=H;
    //NO[n].PU :=     @H^.fU;
    NO[n].PO :=     @H^.fNextPos;
    NO[n].Offset := DWord(H)-DWord(Header);
    Inc(DWord(P),16+RoundBy(Length(NO[n].FileName)+1,16));
    AssignFile(F,Format('%s\%s',[Dir,FName]));
    Reset(F,1);
    FSize:=FileSize(F);
    If LZ Then
    begin
      BlockRead(F,WBuf^,FSize);
      FSize:=Lz77Compress(WBuf^,P^,FSize,False);
    end else
      BlockRead(F,P^,FSize);
    CloseFile(F);

    H^.fSize := FSize;
    H:=P;
    Inc(DWord(H),RoundBy(FSize,16));
    If DWord(H)-DWord(Buf) >= $800000 Then
    begin
      WriteLn('***ERROR! Overflow!');
      Break;
    end;
    //Write(' ', IntToHex(DWord(H)-DWord(Buf),8));
  end;

  Header^.ArcSize := DWord(H)-DWord(Header);
  Header^.Count   := Length(NO);
  Header^.FSign   := 'winxgba_files';
  Header^.FOffset := $30;

  For n:=0 To High(NO) do
  begin
    With NO[n] do For i:=0 To 1 do
    begin
      If NOffset[i]>0 Then PO^[i]:=NO[NOffset[i]].Offset else
        PO^[i]:=0;
    end;
  end;

  FillChar(H^,$753450-Header^.ArcSize,$FF);

  AssignFile(F,ParamStr(3));
  Rewrite(F,1);
  BlockWrite(F,Buf^,8388608);
  CloseFile(F);
  List.Free;
  FreeMem(WBuf);
  FreeMem(Buf);
  WriteLn('Done!');
end;


begin
  If ParamStr(1)='-b' Then
  begin
    Build;
    Exit;
  end;
  List:=TStringList.Create;
  AssignFile(F,ParamStr(2));
  Reset(F,1);
  GetMem(Buf,FileSize(F));
  BlockRead(F,Buf^,FileSize(F));
  CloseFile(F);
  Header:=Buf;
  Inc(DWord(Header),$ACBB0);
  H:=Addr(Header^);
  Inc(DWord(H),$30);
  OutDir:=ParamStr(3);
  GetMem(WBuf,$400000);
  SetLength(NO,Header^.Count);
  With Header^ do List.Add(Format('%8.8x %8.8x %8.8x',[U0,U1,U2]));
  For n:=0 To Header^.Count-1 do
  begin
    FileName:=PChar(@H^.fName[0]);
    WriteLn(Format('[%d/%d] %s',[n+1,Header^.Count,FileName]));
    NameLen:=RoundBy(Length(FileName)+1,16);
    P:=Pointer(DWord(H)+$10+NameLen);
    NO[n].FileName:=FileName;
    NO[n].Offset := DWord(H)-DWord(Header);
    NO[n].NOffset :=H^.fNextPos;
    NO[n].U := H^.fU;
    //NO[n].Offset :=
    If RightStr(FileName,3)='.lz' Then
    begin
      FileName:=LeftStr(FileName,Length(FileName)-3);
      FSize := Integer(P^) shr 8;
      {$IFDEF EMULATION}
      {$ELSE}
      Lz77Decompress(P^,WBuf^);
      {$ENDIF}
      P:=WBuf;
    end else
    begin
      FSize:=H^.fSize;
    end;
    {$IFDEF EMULATION}
    {$ELSE}
    AssignFile(F,Format('%s\%s',[OutDir,FileName]));
    Rewrite(F,1);
    BlockWrite(F,P^,FSize);
    CloseFile(F);
    {$ENDIF}
    //H:=Pointer(DWord(Header)+H.fNextPos);
    Inc(DWord(H),$10+NameLen+RoundBy(H^.fSize,16));
  end;
  For n:=0 To Header^.Count-1 do
  begin
    DW:=@m[0];
    For i:=0 To 1 do
    begin
      If NO[n].NOffset[i]>0 Then
      begin
        For V:=0 To Header^.Count do
          If NO[V].Offset = NO[n].NOffset[i] Then Break;
        m[i]:=V;
        If m[i]=Header^.Count Then m[i]:=-1 else if m[i]=0 Then m[i]:=-2;
      end else
        m[i]:=0;
    end;
    With NO[n] do List.Add(Format('%4.4d %4.4d %8.8x %s',[m[0],m[1],U,NO[n].FileName]));
  end;
  FreeMem(Buf);
  List.SaveToFile(Format('%s\FILELIST.LST',[OutDir]));
  List.Free;
  WriteLn('Done!');
  //ReadLn;
  { TODO -oUser -cConsole Main : Insert code here }
end.
 