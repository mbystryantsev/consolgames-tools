unit PakUnit;

interface

uses Zlib, ZlibEx, Classes, SysUtils, G3PakDef, Windows;


Type
  TTreeNode = Class
    FParent: TTreeNode;
    FFirst:  TTreeNode;
    FLast:   TTreeNode;
    FPrev:   TTreeNode;
    FNext:   TTreeNode;
    FCount:  Integer;
  public
    Folder:     Boolean;
    Compressed: Boolean;
    Name:       String;
    Header:     TG3PakFileRecordHeader;
    Offset:     Int64;
    Attr: TG3PakFileAttributes;
      FileData    : TG3PakFileRecordData;

        
    Property Count: Integer read FCount;

    Destructor Destroy; override;
    Constructor Create(Parent: TTreeNode = nil);
    Procedure Clear;
    Function AddSibling:  TTreeNode;
    Function AddChildren: TTreeNode;
  end;

  TTree = Class(TTreeNode)
  private
  public
    Constructor Create;
  end;


Procedure Extract(FileName, OutDir: String);
Procedure Build(Dir, OutFile: String; Compression: Boolean = False);
implementation


Function Z_Compress(src: Pointer; var dest: Pointer; Size: Integer): Integer;
var W: ^Word; Buf2: Pointer;
begin
  ZCompress(src, Size, dest, Result, zcMax);
  //ReallocMem(Buf,Result);
  //FreeMem(Buf);
  //Buf := Buf2;
  //W:=Addr(Buf^);
  //W^:=$DA78;
end;

Procedure ExtractFromStream(const Stream: TStream; OutDir: String);
var Header: TG3PakFileHeader; Tree: TTree;  RootDir: TG3PakFileRecordHeader; n: Integer;

Function CheckFlag(Attr: Integer; Flag: TG3PakFileAttribute): Boolean;
begin
  Result := Boolean((1 SHL Integer(Flag)) and Attr);
end;

Procedure ReadFolder(Root: TTreeNode; Count: Integer);
var n, Len: Integer; S: String; Node: TTreeNode;

begin
  For n := 0 To Count - 1 do With Node do
  begin

    Node := Root.AddChildren;

    //WriteLn(IntToHex(Stream.Position, 8));
    Stream.Read(Node.Attr, 4);
    Stream.Read(Len, 4);
    If Len > 0 Then
    begin
      SetLength(S, Len);
      Stream.Read(S[1], Len + 1);
    end;
    Node.Name := S;
    Node.Folder := (G3PakFileAttributeDirectory in Attr);
    If not Node.Folder Then
      Stream.Read(Node.Offset, 8);
    Stream.Read(Node.Header, SizeOf(Node.Header));

    If Node.Folder Then
      ReadFolder(Node, Node.Header.Count)
    else
    begin
      //Node.Compressed := (G3PakCompressionZip = Node.FileData.Compression);
      Node.Compressed := (G3PakFileAttributeCompressed in Node.Attr);
      Stream.Read(Node.FileData, SizeOf(Node.FileData));
    end;
  end;
end;

Procedure ExtractNode(Node: TTreeNode; OutDir: String);
var n: Integer; _node: TTreeNode; Buf, Buf2: Pointer; F: File; Size: Integer;
begin

  If not DirectoryExists(OutDir) Then
    ForceDirectories(ExpandFileName(OutDir));
  If Node.Folder Then
  begin
    _node := Node.FFirst;
    For n := 0 To Node.Count - 1 do
    begin
      If Node.Name = '' Then
        ExtractNode(_node, OutDir)
      else
        ExtractNode(_node, OutDir + Node.Name + '\');
      _node := _node.FNext;
    end;
  end else
  begin
    WriteLn(OutDir, Node.Name);
    Stream.Seek(Node.Offset, 0);
    If Node.Compressed Then
    begin                                              
      GetMem(Buf2, Node.FileData.FileSizePacked);
      Stream.Read(Buf2^, Node.FileData.FileSizePacked);
      //GetMem(Buf, Node.FileData.FileSizeFull);
      DecompressBuf(Buf2, Node.FileData.FileSizePacked, Node.FileData.FileSizeFull, Buf, Size);
      FreeMem(Buf2);
    end else
    begin
      GetMem(Buf, Node.FileData.FileSizeFull);
      Stream.Read(Buf^, Node.FileData.FileSizeFull);
    end;
   AssignFile(F, OutDir + Node.Name);
   Rewrite(F, 1);
   BlockWrite(F, Buf^, Node.FileData.FileSizeFull);
   CloseFile(F);
   FreeMem(Buf);
   SetFileAttributes(PChar(OutDir + Node.Name), LongWord(Node.Header.Attribs));
  end;
end;

begin
  If OutDir[Length(OutDir)] <> '\' Then
    OutDir := OutDir + '\';      
  Stream.Read(Header, SizeOf(Header));
  Tree := TTree.Create();
  Tree.Folder := True; 


  Stream.Seek(Header.OffsetToFolders.QuadPart + 4, 0);
  Stream.Read(RootDir, SizeOf(RootDir));
  ReadFolder(Tree, RootDir.Count);
  ExtractNode(Tree, OutDir);

  Tree.Free;

end;

Procedure Extract(FileName, OutDir: String);
var Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  ExtractFromStream(Stream, OutDir);
  Stream.Free;
end;

Function FillTree(Node: TTreeNode; Dir: String; Compression: Boolean = False): Integer;
var SR: TSearchRec; N: TTreeNode;
begin
  Result := 0;
  If Dir[Length(Dir)] <> '\' Then Dir := Dir + '\';
  If FindFirst(Dir + '*', faAnyFile, SR) = 0 Then
  begin
    repeat
      If (SR.Name = '..') or (SR.Name = '.') Then Continue;
      N := Node.AddChildren;
      N.Folder := SR.Attr and faDirectory <> 0;
      N.Name := SR.Name;
      N.Header.Created := SR.FindData.ftCreationTime;
      N.Header.Accessed := SR.FindData.ftLastAccessTime;
      N.Header.Written := SR.FindData.ftLastWriteTime;
      LongWord(N.Header.Attribs) := SR.FindData.dwFileAttributes;
      LongWord(N.Attr) := SR.FindData.dwFileAttributes;
      N.Attr := N.Attr + [G3PakFileAttributePacked];
      If N.Folder Then
      begin
        N.Header.Count := FillTree(N, Dir + SR.Name, Compression);
        N.Attr := N.Attr + [G3PakFileAttribute13];
        //Include(N.Attr, [G3PakFileAttribute13, G3PakFileAttributePacked]);
        //LongWord(N.Attr) := LongWord(N.Attr) or LongWord(G3PakFileAttribute13) or LongWord(G3PakFileAttributePacked)
      end else
      begin
        If Compression Then
        begin
          N.Attr := N.Attr + [G3PakFileAttributeCompressed];
          N.FileData.Compression := G3PakCompressionZip;
        end else
        begin
          N.FileData.Compression := G3PakCompressionNone;   
          N.FileData.FileSizePacked := SR.FindData.nFileSizeLow;
        end;
        N.FileData.FileSizeFull := SR.FindData.nFileSizeLow;
      end;

      N.Compressed := Compression;
      Inc(Result);
    Until FindNext(SR) <> 0;
  end;
end;

{ TTreeNode }

Function TTreeNode.AddChildren:  TTreeNode;
var Node: TTreeNode;
begin           
  Result := nil;
  Node := TTreeNode.Create;
  If FLast <> nil Then
  begin
    FLast.FNext := Node;
    Node.FPrev := FLast;
  end;
  FLast := Node;
  If FFirst = nil Then
    FFirst := Node;
  Inc(FCount);
  Result := Node;
end;

Function TTreeNode.AddSibling:  TTreeNode;
begin
  Result := nil;
  If FParent = nil Then Exit;
  Result := FParent.AddChildren;
end;

procedure TTreeNode.Clear;
var n: Integer; Node, OldNode: TTreeNode;
begin
  Node := FFirst;
  For n := 0 To FCount -1 do
  begin
    OldNode := Node;
    Node := Node.FNext;
    OldNode.Free;
  end;
end;

constructor TTreeNode.Create(Parent: TTreeNode);
begin
  FParent := Parent;
end;

destructor TTreeNode.Destroy;
begin
  Clear();
end;

{ TTree }

constructor TTree.Create;
begin
  inherited Create(nil);
end;


Procedure BuildToStream(Dir: String; Stream: TStream; Compression: Boolean = False);
var Tree: TTree; TreeStream: TMemoryStream;
Header: TG3PakFileHeader; RootDir: TG3PakFileRecordHeader; n: Integer;

Procedure WriteNode(Node: TTreeNode; Dir: String; Root: Boolean = False);
var n, len: Integer; Child: TTreeNode; offset: Int64; F: File; Buf, Buf2: Pointer;
begin

  If Dir[Length(Dir)] <> '\' Then Dir := Dir + '\';
  If Root Then
  begin
    Node.Folder := True;
    len := 0;                
    TreeStream.Write(len, 4);
  end;
  If Node.Folder Then
  begin
    If not Root Then
    begin
      TreeStream.Write(Node.Attr, 4);
      len := Length(Node.Name);
      TreeStream.Write(len, 4);
      TreeStream.Write(Node.Name[1], len + 1);
    end;
    Node.Header.Count := Node.Count;
    TreeStream.Write(Node.Header, SizeOf(Node.Header));
    //Child := Node.FFirst;
    Child := Node.FLast;
    For n := 0 To Node.Count - 1 do
    begin
      WriteNode(Child, Dir + Node.Name);
      //Child := Child.FNext;
      Child := Child.FPrev;
    end;
    //Node.Header.
  end else
  begin
    WriteLn(Dir + Node.Name);                                         
    Offset := Stream.Position;

    FileMode := fmOpenRead;
    AssignFile(F, Dir + Node.Name);
    Reset(F, 1);
    GetMem(Buf, FileSize(F));
    BlockRead(F, Buf^, FileSize(F));
    CloseFile(F);

    Node.Header.Attribs := Node.Header.Attribs + [G3PakFileAttributePacked];

    If Node.Compressed Then
    begin
      //CompressBuf(Buf, Node.FileData.FileSizeFull, Buf2, Integer(Node.FileData.FileSizePacked));
      ZCompress(Buf, Node.FileData.FileSizeFull, Buf2, Integer(Node.FileData.FileSizePacked), zcDefault);
      If Node.FileData.FileSizeFull <= Node.FileData.FileSizePacked Then
      begin
        Node.Attr := Node.Attr - [G3PakFileAttributeCompressed];
        Node.Compressed := False;
        Node.FileData.Compression := G3PakCompressionNone;
        FreeMem(Buf2);
      end else
      begin
        FreeMem(Buf);
        Buf := Buf2;
      end;
    end;
    
    Stream.Write(Buf^, Node.FileData.FileSizePacked);
    FreeMem(Buf);
                                                            
    TreeStream.Write(Node.Attr, 4);
    len := Length(Node.Name);
    TreeStream.Write(len, 4);
    TreeStream.Write(Node.Name[1], len + 1);
    TreeStream.Write(Offset, 8);
    //Node.Header.Count := 0;
    TreeStream.Write(Node.Header, SizeOf(Node.Header));
    TreeStream.Write(Node.FileData, SizeOf(Node.FileData));
  end;
end;

begin
  Tree := TTree.Create;
  Tree.Header.Count := FillTree(Tree, Dir, Compression);
  Header.Version := 1;
  Header.Product := 'G3V0';
  Header.Revision := 0;
  Header.Encryption := G3PakEncryptionNone;
  Header.Compression := G3PakCompressionAuto;
  Header.Reserved := G3PakReservedNone;
  Header.OffsetToFiles.QuadPart := $30;

  TreeStream := TMemoryStream.Create;

  Stream.Seek($30, 0);
  //n := 0;
  //TreeStream.Write(n, 4);
  GetSystemTimeAsFileTime(RootDir.Created);
  GetSystemTimeAsFileTime(RootDir.Accessed);
  GetSystemTimeAsFileTime(RootDir.Written);
  RootDir.Attribs := [G3PakFileAttributePacked, G3PakFileAttributeDirectory];
  Tree.Header := RootDir;

  //TreeStream.Write(RootDir, SizeOf(RootDir));

  WriteNode(Tree, Dir, True);

  Header.OffsetToFolders.QuadPart := Stream.Position;
  Stream.WriteBuffer(TreeStream.Memory^, TreeStream.Size);
  Header.DataSize.QuadPart := Stream.Position;
  Stream.Seek(0,0);
  Stream.Write(Header, SizeOf(Header));  

  TreeStream.Free;    
  Tree.Free;

end;

Procedure Build(Dir, OutFile: String; Compression: Boolean = False);
var Stream: TFileStream; F: File;
begin
  //If FileExists(OutFile) Then DeleteFile(OutFile);
  AssignFile(F, OutFile);
  Rewrite(F, 1);
  CloseFile(F);
  Stream := TFileStream.Create(ExpandFileName(OutFile), fmOpenWrite);
  BuildToStream(Dir, Stream, Compression);
  Stream.Free;
end;

end.
