 program SHPack;

{$APPTYPE CONSOLE}

uses
  SysUtils, SHPacker, Windows, Classes, StrUtils;

var Head: THeader; Folders: Array of String;

Procedure Patch();
var F, FW: File; Buf: Pointer; B: ^Byte; W: ^Word; List: TStringList;
n,m,Pos: Integer; H: ^TFileHeader; Name: Array of String;
Size: Integer; P: Boolean; S, FileName: String;
begin
  AssignFile(F, ParamStr(3));
  Reset(F,1);
  BlockRead(F, Head, 20);
  If Head.Sign[0]+Head.Sign[1]+Head.Sign[2]+Head.Sign[3]<>'A2.0' then
    WriteLn('Warning! Header incorrect!');
  SetLength(Head.FHead, Head.Count);
  GetMem(Buf, Head.HeadSize-20);
  Seek(F,20);
  BlockRead(F, Buf^, Head.HeadSize-20);
  H:=Addr(Buf^);
  For n:=0 to Head.Count-1 do
  begin
    Head.FHead[n]:=H^;
    Inc(H);
  end;
  FreeMem(Buf);
  GetMem(Buf, Head.NamesSize);
  Seek(F, Head.NamesPos);
  BlockRead(F, Buf^, Head.NamesSize);
  SetLength(Name, Head.Count);

  For n:=0 to Head.Count-1 do
  begin
    B:=Addr(Buf^);
    Inc(B, Head.FHead[n].NamePos);
    Name[n]:='';
    While B^>0 do
    begin
      Name[n]:=Name[n]+Char(B^);
      Inc(B);
    end;
  end;
  FreeMem(Buf);

  List:=TStringList.Create;
  List.LoadFromFile(ParamStr(2));
  For n:=0 To List.Count-1 do
  begin
    S:=List.Strings[n];
    If (Length(S)>2) and (S[Length(S)-1]=' ') Then
    begin
      P:=True;
      SetLength(S,Length(S)-2);
    end;
    FileName:='';
    For m:=0 To High(Folders) do
    begin
      If FileExists(Format('%s\%s',[Folders[m],S])) Then
      begin
        FileName:=Format('%s\%s',[Folders[m],S]);
        WriteLn(S);
        break;
      end;
    end;
    If FileName<>'' Then
    begin
      For m:=0 To Head.Count -1 do
      begin
        If Name[m]=S Then break;
      end;
      If m<Head.Count Then
      begin
        AssignFile(FW,FileName);
        Reset(FW,1);
        Size:=FileSize(FW);
        GetMem(Buf,Size);
        BlockRead(FW,Buf^,Size);
        CloseFile(FW);
        Size:=Pack(Buf, Size);
        If Size<=RoundBy(Head.FHead[m].FileSize,16) Then
          Pos:=Head.FHead[m].FilePos
        else
          Pos:=RoundBy(FileSize(F),16);
        With Head.FHead[m] do
        begin
          FilePos := Pos;
          FileSize:= Size;
          Seek(F,FilePos);
        end;
        BlockWrite(F,Buf^,Size);
        FreeMem(Buf);
      end;
    end;
  end;
  Seek(F,20);
  BlockWrite(F,Head.FHead[0],Head.Count*SizeOf(TFileHeader));
  CloseFile(F);
  List.Free;
end;


var  List: TStringList; Buf: Pointer;
n, m, Size, Pos, NPos: Integer; S,S1: String; F, FW: File; Names: Array of Char;
ErrorCount: Integer; WBuf: Pointer; FSize: Integer;
FileName: String;
Label NN;
begin
  WriteLn('Silent Hill Origins Packer v0.1 by HoRRoR <ho-rr-or@mail.ru>');
  WriteLn('http://consolgames.ru/');
  If (ParamCount < 2) {or not FileExists(ParamStr(1))} then
  Exit;


  If ParamStr(1)='-patch' Then m:=4 else m:=3;
  If ParamStr(1)='-patch' Then SetLength(Folders,ParamCount-3)
  else SetLength(Folders,ParamCount-2);
  For n:=m To ParamCount do
  begin
    Folders[n-m]:=ParamStr(n);
  end;
  If ParamStr(1)='-patch' Then
  begin
    If Length(Folders)<=0 Then Exit;
    Patch;
    Exit;
  end;

  //AssignFile(FW, 'SH.ARC');
  AssignFile(FW, ParamStr(2));
  Rewrite(FW,1);
  List:=TStringList.Create;
  //List.LoadFromFile('HTEST\LIST.LST');
  List.LoadFromFile(ParamStr(1));
  Pos:=RoundBy(20+(16*List.Count),16);
  SetLength(Head.FHead, List.Count);
  Head.Count:=List.Count;
  Head.Sign:='A2.0';
  Head.HeadSize:=Pos;
  NPos:=0;
  SetLength(Folders,Length(Folders)+1);
  Folders[High(Folders)]:=ExtractFilePath(ParamStr(1));
  For n:=0 to List.Count-1 do
  begin
    S:=LeftStr(List.Strings[n], Length(List.Strings[n])-2);
    For m:=0 To High(Folders) do
    begin
      If FileExists(Format('%s\%s',[Folders[m],S])) Then
      begin
        FileName:=Format('%s\%s',[Folders[m],S]);
        break;
      end;
    end;
    //FileName:=Format('%s\%s',ExtractFilePath(ParamStr(1)),S);

    If m<Length(Folders) then
    begin
      Write(Format('[%d/%d] %s',[n+1,List.Count,S]));
      Head.FHead[n].NamePos:=NPos;
      Head.FHead[n].FilePos:=Pos;
      S1:=ExtractFileName(S);
      Inc(NPos, Length(S1)+1);
      SetLength(Names, NPos);
      //If RightStr(S,3)='Eng' Then ReadLn;
      For m:=0 to Length(S1) do
      begin
        Names[NPos-Length(S1)-1+m]:=S1[m+1];
      end;
      Names[NPos-1]:=#0;
      //Assign(F, ExtractFilePath(ParamStr(1))+'\'+S);
      Assign(F, FileName);
      Reset(F,1);
      FSize:=FileSize(F);
      WriteLn(Format(' - %d bytes',[FSize]));
      GetMem(Buf, FSize);
      BlockRead(F, Buf^, FSize);
      If n=0 Then GetMem(WBuf,FSize) else ReallocMem(WBuf,FSize);
      Move(Buf^,WBuf^,FSize);
      If RightStr(List.Strings[n],1)='p' then
      begin
        Size:=Pack(Buf, FSize);
        Head.FHead[n].FullSize:=FSize;
        If Size>=FSize Then
        begin
          ReallocMem(Buf,FSize);
          Move(WBuf^,Buf^,FSize);
          GoTo NN;
        end;
      end else
      begin
        NN:
        Size:=FSize;
        Head.FHead[n].FullSize:=0;
      end;
      Head.FHead[n].FileSize:=Size;
      Close(F);
      Seek(FW, Pos);
      BlockWrite(FW, Buf^, Size);
      FreeMem(Buf);
      Pos:=RoundBy(Pos + Size, 16)
    end else
    begin
      WriteLn(S+' - not found!');
      Inc(ErrorCount);
    end;
  end;
  Head.NamesPos:=Pos;
  Head.NamesSize:=Length(Names);
  Seek(FW,0);
  BlockWrite(FW,Head,20);
  Seek(FW, 20);
  BlockWrite(FW, Head.FHead[0], Head.HeadSize-20);
  Seek(FW, Pos);
  BlockWrite(FW, Names[0], Length(Names));
  CloseFile(FW);
  WriteLn(Format('Completed! Errors: %d',[ErrorCount]));



end.
