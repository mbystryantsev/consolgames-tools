program XML2RML;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows, ComObj, ActiveX,
  xmldom,
  XMLIntf,
  msxmldom,
  XMLDoc;

var XML: TXMLDocument; Dest: String;
  StrBuf, NodeBuf, NodeData: Pointer; StrData: PChar;
  StrCount: Integer; WS: WideString; SS: String;
  StrPtrs: Array of PChar;  NodeCount: Integer;
  ExtendCount: Integer;
  //StrPos: LongWord;

const
  cStrPtrsLen = 4096;    
  cBufferSize = 1024 * 1024 * 4;


Procedure Write(var Ptr: Pointer; var Data, Size: Integer);
begin
  Move(Data, Ptr^, Size);
  Inc(LongWord(Ptr), Size);
end;

Procedure WriteInt(const Value: Integer);
begin
  If Value < 255 Then
  begin
    Byte(NodeData^) := Value;
    Inc(LongWord(NodeData), 1);
  end else
  begin
    Byte(NodeData^) := $FF;
    Inc(LongWord(NodeData), 1);
    Integer(NodeData^) := Value;
    Inc(LongWord(NodeData), 4);
    Inc(ExtendCount);
  end;
end;

Procedure WriteData(const Value: Integer; Size: Integer);
begin
  Integer(NodeData^) := Value;
  Inc(LongWord(NodeData), Size);
end;

//var CharBuf: Array[0..$10000-1] of Char;

Function AddString(const S: WideString): Integer;
var n, Len: Integer;
begin
  Len := WideCharToMultiByte(CP_UTF8, 0, PWideChar(S), Length(S), StrData, cBufferSize - (LongWord(NodeData) - LongWord(NodeBuf)), nil, nil);
  (StrData + Len)^ := #0;
  Inc(Len);
  For n := 0 To StrCount - 1 do
    If CompareMem(StrData, StrPtrs[n], Len) Then
      break;
  If n >= StrCount Then
  begin  
    Result := LongWord(StrData) - LongWord(StrBuf);
    If StrCount >= Length(StrPtrs) Then
      SetLength(StrPtrs, Length(StrPtrs) + cStrPtrsLen);
    StrPtrs[StrCount] := StrData;
    Inc(LongWord(StrData), Len);
    //If StrData^ <> #0 Then
    //begin
      //StrData^ := #0;
      //Inc(LongWord(StrData));
    //end;
    Inc(StrCount);
  end else
    Result := LongWord(StrPtrs[n]) - LongWord(StrBuf);
end;

Procedure AddNode(Node: IDOMNode; First: Boolean = True);
var n: Integer;
label AddNodes;
begin
  If First Then GoTo AddNodes;
  Inc(NodeCount);
  WriteInt(AddString(Node.NodeName));
  WriteInt(AddString(''));
  //WriteInt(NodeData, $0C, 1); // AddString(#0) ???
  WriteInt(Node.attributes.length);
  WriteInt(Node.childNodes.length);
  For n := 0 To Node.attributes.length - 1 do
  begin                            
    WriteInt(0);
    WriteInt(AddString(Node.attributes[n].nodeName));
    WriteInt(AddString(Node.attributes[n].nodeValue));
  end;
AddNodes:
  For n := 0 To Node.childNodes.length - 1 do
    AddNode(Node.childNodes[n], False);
end;

const
  cFF: Integer = $FF;
  c00: Integer = $00;
var
  F: File;
  V: Integer;
begin
  StrBuf := nil;
  NodeBuf := nil;
  StrPtrs := nil;
  StrCount := 0;
  NodeCount := 0;
  //StrPos := 0;
  ExtendCount := 0;

  WS := 'Test!';
  SS := '      ';
  //SetLength(SS, Length(WS));
  //WideCharToMultiByte( CP_ACP, 0, PWideChar(WS), Length(WS), PChar(SS), Length(SS), nil, nil);

  //XML.Node.
  If ParamCount = 0 Then
  begin
    WriteLn('XML to RML convertor by HoRRoR');
    WriteLn('http://consolgames.ru/');
    WriteLn('Usage: XML2RML <src.xml> [dest.rml]');
    Exit;
  end else
  If ParamCount = 1 Then
  begin
    Dest := ChangeFileExt(ParamStr(1), '.rml');
  end else
    Dest := ParamStr(2);

  CoInitialize(nil);
  WriteLn('Converting...');
  try
    XML := TXMLDocument.Create(ParamStr(1));
    GetMem(StrBuf, cBufferSize);
    GetMem(NodeBuf, cBufferSize);
    StrData := StrBuf;
    NodeData := NodeBuf;
    AddNode(XML.Node.DOMNode);

    AssignFile(F, Dest);
    Rewrite(F, 1);
    BlockWrite(F, c00, 2);
    BlockWrite(F, cFF, 1);
    V := LongWord(StrData) - LongWord(StrBuf);
    BlockWrite(F, V, 4);  
    BlockWrite(F, cFF, 1);
    BlockWrite(F, NodeCount, 4);
    BlockWrite(F, cFF, 1); 
    Inc(ExtendCount, 3);
    BlockWrite(F, ExtendCount, 4);

    BlockWrite(F, NodeBuf^, LongWord(NodeData) - LongWord(NodeBuf));
    BlockWrite(F, StrBuf^, LongWord(StrData) - LongWord(StrBuf));
    CloseFile(F);
  finally
    If StrBuf <> nil Then FreeMem(StrBuf);
    If NodeBuf <> nil Then FreeMem(NodeBuf);

    Finalize(StrPtrs);

    XML.Free;
    CoUnInitialize();
  end;
  WriteLn('Done!');
end.
