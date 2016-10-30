unit IPS_Patch;

interface

Type
 TPATCHSignature = Array[0..4] of Char;
 TAB = Packed record
  A: Byte;
  B: Byte;
 end;
 TABCD = Packed record
  A: Byte;
  B: Byte;
  C: Byte;
  D: Byte;
 end;
Const
 PATCHSignature: TPATCHSignature = 'PATCH';

Procedure IPS_ApplyPatch(Patch, Data: Pointer);
Procedure IPS_PatchFile(IPSFile, FileName: String);
implementation


Procedure IPS_PatchFile(IPSFile, FileName: String);
var IPSBuf, Buf: Pointer; F, IPSF: File; Size, IPSSize: Integer;
begin
  AssignFile(F, FileName);
  Reset(F,1);
  Size := FileSize(F);
  GetMem(Buf, Size);
  BlockRead(F, Buf^, Size);

  AssignFile(IPSF, IPSFile);
  Reset(IPSF,1);
  IPSSize := FileSize(IPSF);
  GetMem(IPSBuf, IPSSize);
  BlockRead(IPSF, IPSBuf^, IPSSize);
  CloseFile(IPSF);

  IPS_ApplyPatch(IPSBuf, Buf);
  Seek(F,0);
  BlockWrite(F, Buf^, Size);
  CloseFile(F);

  FreeMem(IPSBuf);
  FreeMem(Buf);
end;


Procedure IPS_ApplyPatch(Patch, Data: Pointer);
var
  Sign:     TPATCHSignature;
  P:        PByte;
  RLen:     Word;
  D:        Integer;
  W:        Word;
  Position: Integer;
  I:        Integer;

  Procedure Write(var src; Size: Integer);
  begin
    Move(src, Pointer(LongWord(Data)+Position)^, Size);
    Inc(Position, Size);
  end;
  
begin
  P := Patch;
  Move(P^, Sign, 5);
  Inc(P, 5);
  If Sign = PATCHSignature then
    Repeat
      With TABCD(D) do
      begin
       D := 0;
       C := P^;
       Inc(P);
       B := P^;
       Inc(P);
       A := P^;
       Inc(P);
      end;
      If D = $454F46 then Break;
      Position := D;
      With TAB(W) do
      begin
       B := P^;
       Inc(P);
       A := P^;
       Inc(P);
      end;
      If W > 0 then
      begin
       Write(P^, W);
       Inc(P, W);
      end Else
      begin
       With TAB(RLEn) do
       begin
        B := P^;
        Inc(P);
        A := P^;
        Inc(P);
       end;
       For I := 1 to RLEn do Write(P^, 1);
       Inc(P);
      end;
    Until False;
end;

end.
