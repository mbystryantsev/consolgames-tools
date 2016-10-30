unit FontUnit;

interface


Type

TFontHeader = Packed Record
  Signature:   Array[0..3] of Char;
  FileSize:    Integer;
  Hz:          Word;
  CharCount:   Word;
  CharOffset:  Integer;
  Hz2:		     Integer;
  Height:	     Integer; // Height?
  Hz4:		     Integer;
  Hz5:		     Integer;
  Name:		 Array[0..31] of Char;
  DataSize:  Integer;
  Hz6:		 Integer;
  HzSize:	 Integer; // First block
  Hz7:     Integer;
 end;
 
TCharRect = Packed Record
  Left, Top, Right, Bottom: Word;
end;
 
TCharRecord = Packed Record
  Code:     WideChar;
  Width:    Word;
  Height:   Word;
  Right:    SmallInt;
  Left:     SmallInt;
  U1:       Word;
  Rect:     TCharRect;
  Reserved: Integer;
end;

PCharRecord = ^TCharRecord;

Function Endian(V: Cardinal): Cardinal;
Function EndianW(W: Word): Word;
implementation

Function Endian(V: Cardinal): Cardinal;
begin
  Result := (V SHR 24) or ((V SHR 8) AND $FF00 ) or ((V SHL 8) AND $FF0000 ) or (V SHL 24);
end;

Function EndianW(W: Word): Word;
begin
  Result := (W SHR 8) or (W SHL 8);
end;

end.
 