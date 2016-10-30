unit MyUtils;

interface

uses Windows, SysUtils, TntSysUtils;

//******** Working with files *******//
type
 TCheckFileResult = (cfNotExist, cfLocked, cfCanWrite);

function CheckFileName(const FileName: AnsiString): Boolean;
function CheckFileNameW(const FileName: WideString): Boolean;
//Validates file name AnsiString
function CheckFileForWrite(const FileName: AnsiString): TCheckFileResult;
function CheckFileForWriteW(const FileName: WideString): TCheckFileResult;
//Returns: cfNotExist if file not found;
//         cfLocked if file cannot be changed;
//         cfCanWrite if file can be modified.
function ExpandFileNameEx(const Path, FileName: AnsiString): AnsiString;
function ExpandFileNameExW(const Path, FileName: WideString): WideString;
//Converts the relative file name into a fully qualified path name
function MakeDirs(Path: AnsiString): Boolean;
function MakeDirsW(Path: WideString): Boolean;
//Create all directories founded in Path parameter
function WideGetCurrentDir: WideString;
//Returns current directory name
function MaskedPos(const SubStr, Str: AnsiString): Integer;
function MaskedPosW(const SubStr, Str: WideString): Integer;
//Finds masked with ? sub string in a specified string.
//Example:
// Position := MaskedPos('.???', 'filename.txt');
//Result will be same as System.Pos('.txt', 'filename.txt') gives
function WideMatchesMask(FileName, Mask: WideString;
                         CaseSensitive: Boolean = False): Boolean;
//Indicates whether a file name conforms to the format specified by a filter string

//**** AnsiString conversion utilities ****//
const
 //**** Code Page Constants ****//
 CP_SHIFT_JIS = 932;
 CP_UTF8 = 65001;
 UTF8_BOM: array[0..2] of Char = #$EF#$BB#$BF;

function CodePageStringEncode(CodePage: Cardinal; MaxCharSize: Integer;
                 const S: WideString): AnsiString;
//Converts unicode string to the string with a specified code page
function CodePageStringDecode(CodePage: Cardinal;
                 const S: AnsiString): WideString;
//Converts string to the unicode string with a specified code page
function EUCJPtoUTF16(S: AnsiString): WideString;
//Converts EUC-JP string to unicode string
function UTF16toEUCJP(const S: WideString): AnsiString;
//Converts unicode string to EUC-JP string
function WideStrLen(Str: PWideChar): Integer;
//Returns null-terminated unicode string length

var
 HexError: Boolean = False;
 IntError: Boolean = False;

const
 E_ERROR = -1;
 E_OK = 0;
 faAnyTrueFile = faArchive or faHidden or faReadOnly;

implementation

function CheckFileName(const FileName: AnsiString): Boolean;
var
 P: PChar;
 I: Integer;
begin
 P := Pointer(FileName);
 for I := 1 to Length(FileName) do
 begin
  if P^ in [#0..#$1F, '\', '/', ':', '*', '?', '"', '<', '>', '|'] then
  begin
   Result := False;
   Exit;
  end;
  Inc(P);
 end;
 Result := True;
end;

function CheckFileNameW(const FileName: WideString): Boolean;
var
 P: PWideChar;
 C: WideChar;
 I: Integer;
begin
 P := Pointer(FileName);
 for I := 1 to Length(FileName) do
 begin
  C := P^;
  if (Byte(C) < 32) or (C = '\') or (C = '/') or (C = ':') or (C = '*') or
     (C = '?') or (C = '"') or (C = '<') or (C = '>') or (C = '|') then
  begin
   Result := False;
   Exit;
  end;
  Inc(P);
 end;
 Result := True; 
end;

function CodePageStringEncode(CodePage: Cardinal; MaxCharSize: Integer;
  const S: WideString): AnsiString;
begin
 if (S <> '') and (MaxCharSize > 0) then
 begin
  SetLength(Result, Length(S) * MaxCharSize);
  SetLength(Result, WideCharToMultiByte(CodePage, 0, Pointer(S), Length(S),
                    Pointer(Result), Length(Result), NIL, NIL));
 end else Result := '';
end;

function CodePageStringDecode(CodePage: Cardinal;
  const S: AnsiString): WideString;
begin
 if S <> '' then
 begin
  SetLength(Result, Length(S));
  SetLength(Result, MultiByteToWideChar(CodePage, 0, Pointer(S), Length(S),
                    Pointer(Result), Length(Result)));
 end else Result := '';
end;

function EUCJPtoUTF16(S: AnsiString): WideString;
var
 P, PP: PByte;
 FirstByte: Byte;
 OddA: Boolean;
begin
 if S <> '' then
 begin
  P := Pointer(S);
  FirstByte := $81; OddA := False;
  while P^ <> 0 do
  begin
   if P^ >= $80 then
   begin
    PP := P;
    Inc(P);
    case PP^ of
     $A1..$DE:
     begin
      FirstByte := PP^ - $A1;
      OddA := Odd(FirstByte);
      FirstByte := FirstByte shr 1 + $81;
     end;
     $DF..$F4:
     begin
      FirstByte := PP^ - $DF;
      OddA := Odd(FirstByte);
      FirstByte := FirstByte shr 1 + $E0;
     end;
     else
     begin
      PP^ := $81;
      P^ := $A1;
      Inc(P);
      Continue;
     end;
    end;
    if P^ < $A1 then
    begin
     PP^ := $81;
     P^ := $A1;
    end else if OddA then
    begin
     PP^ := FirstByte;
     P^ := (P^ - $A1) + $9F;
    end else if P^ >= $E0 then
    begin
     PP^ := FirstByte;
     P^ := (P^ - $E0) + $80;
    end else
    begin
     PP^ := FirstByte;
     P^ := (P^ - $A1) + $40;
    end;;
    Inc(P);
   end else Inc(P);
  end;
  Result := CodePageStringDecode(CP_SHIFT_JIS, S);
 end else Result := '';
end; //EUCJPtoUTF16

function UTF16toEUCJP(const S: WideString): AnsiString;
var
 P, PP: PByte;
 FirstByte: Byte;
begin
 if S <> '' then
 begin
  Result := CodePageStringEncode(CP_SHIFT_JIS, 2, S);
  P := Pointer(Result);
  FirstByte := $A1;
  while P^ <> 0 do
  begin
   if P^ >= $80 then
   begin
    PP := P;
    Inc(P);
    case PP^ of
     $81..$9F: FirstByte := (PP^ - $81) shl 1 + $A1;
     $E0..$EA: FirstByte := (PP^ - $E0) shl 1 + $DF;
     else
     begin
      PP^ := $A2;
      P^ := $A3;
      Inc(P);
      Continue;
     end;
    end;
    if P^ >= $9F then
    begin
     PP^ := FirstByte + 1;
     P^ := (P^ - $9F) + $A1;
    end else if P^ >= $80 then
    begin
     PP^ := FirstByte;
     P^ := (P^ - $80) + $E0;
    end else if P^ >= $40 then
    begin
     PP^ := FirstByte;
     P^ := (P^ - $40) + $A1;
    end else
    begin
     PP^ := $A2;
     P^ := $A3;
    end;
    Inc(P);
   end else Inc(P);
  end;
 end else Result := '';
end; //UTF16toEUCJP

function ExpandFileNameEx(const Path, FileName: AnsiString): AnsiString;
var
 U, D: AnsiString;
 J, I, K: Integer;
begin
 if Path <> '' then
 begin
  Result := FileName;
  if Pos('.\', Result) = 1 then Delete(Result, 1, 2);
  if Pos('\', Result) < 1 then
  begin
   D := Path;
   if D[Length(D)] <> '\' then D := D + '\';
   Result := D + Result;
   Exit;
  end;
  U := Result;
  I := 0;
  while Pos('..\', U) > 0 do
  begin
   Delete(U, Pos('..\', U), 3);
   Inc(I);
  end;
  D := Path;
  if D[Length(D)] <> '\' then D := D + '\';
  for J := 1 to I do
  begin
   K := Length(D) - 1;
   while (K > 0) and (D[K] <> '\') do Dec(k);
   Delete(D, K + 1, Length(D) - (K + 1) + 1);
  end;
  if I > 0 then Result := D + U;
 end else Result := '';
end; //ExpandFileNameEx

function ExpandFileNameExW(const Path, FileName: WideString): WideString;
var
 U, D: WideString;
 J, I, K: Integer;
begin
 if Path = '' then Exit;
 Result := FileName;
 if Pos('.\', Result) = 1 then Delete(Result, 1, 2);
 if Pos('\', Result) < 1 then
 begin
  D := Path;
  if D[Length(D)] <> '\' then D := D + '\';
  Result := D + Result;
  Exit;
 end;
 U := Result;
 I := 0;
 while Pos('..\', U) > 0 do
 begin
  Delete(U, Pos('..\', U), 3);
  Inc(I);
 end;
 D := Path;
 if D[Length(D)] <> '\' then D := D + '\';
 for J := 1 to I do
 begin
  K := Length(D) - 1;
  while (K > 0) and (D[K] <> '\') do Dec(k);
  Delete(D, K + 1, Length(D) - (K + 1) + 1);
 end;
 if I > 0 then Result := D + U;
end; //ExpandFileNameExW

function CheckFileForWrite(const FileName: AnsiString): TCheckFileResult;
var
 SR: TSearchRec;
begin
 Result := cfNotExist;
 if FindFirst(FileName, faAnyFile, SR) = 0 then
 begin
  if SR.Attr and (faReadOnly or faVolumeID or faDirectory or faSymLink) = 0 then
   Result := cfCanWrite else
   Result := cfLocked;
  FindClose(SR);
 end;
end;

function CheckFileForWriteW(const FileName: WideString): TCheckFileResult;
var
 SR: TSearchRecW;
begin
 Result := cfNotExist;
 if WideFindFirst(FileName, faAnyFile, SR) = 0 then
 begin
  if SR.Attr and (faReadOnly or faVolumeID or faDirectory or faSymLink) = 0 then
   Result := cfCanWrite else
   Result := cfLocked;
  WideFindClose(SR);
 end;
end;

function MakeDirs(Path: AnsiString): Boolean;
var
 I, L, J: Integer;
 P: PChar;
 SS: AnsiString;
begin
 Result := False;
 Path := ExtractFilePath(Path);
 L := Length(Path);
 if (Path <> '') and (Path[L] <> '\') then Path := Path + '\';
 P := Pointer(Path);
 I := L;
 SS := '';
 if L > 2 then
 begin
  if Path[2] = ':' then
  begin
   SS := Copy(Path, 1, 3);
   Inc(P, 3);
   Dec(I, 3);
  end else if (Path[1] = '\') and (Path[2] = '\') then
  begin
   SS := '\\';
   Inc(P, 2);
   Dec(I, 2);
   J := 0;
   while (I > 0) and (J < 2) do
   begin
    if P^ = '\' then Inc(J);
    SS := SS + P^;
    Inc(P);
    Dec(I);
   end;
  end;
 end;
 while I > 0 do
 begin
  if (P^ = '\') and not DirectoryExists(SS) then
  begin
   if not CreateDir(SS) then
    Exit;
  end;
  SS := SS + P^;
  Inc(P);
  Dec(I);
 end;
 Result := True;
end; //MakeDirs

function MakeDirsW(Path: WideString): Boolean;
var
 I, L, J: Integer;
 P: PWideChar;
 SS: WideString;
begin
 Result := False;
 Path := WideExtractFilePath(Path);
 L := Length(Path);
 if (Path <> '') and (Path[L] <> '\') then Path := Path + '\';
 P := Pointer(Path);
 I := L;
 SS := '';
 if L > 2 then
 begin
  if Path[2] = ':' then
  begin
   SS := Copy(Path, 1, 3);
   Inc(P, 3);
   Dec(I, 3);
  end else if (Path[1] = '\') and (Path[2] = '\') then
  begin
   SS := '\\';
   Inc(P, 2);
   Dec(I, 2);
   J := 0;
   while (I > 0) and (J < 2) do
   begin
    if P^ = '\' then Inc(J);
    SS := SS + P^;
    Inc(P);
    Dec(I);
   end;
  end;
 end;
 while I > 0 do
 begin
  if (P^ = '\') and not WideDirectoryExists(SS) then
  begin
   if not WideCreateDir(SS) then
    Exit;
  end;
  SS := SS + P^;
  Inc(P);
  Dec(I);
 end;
 Result := True;
end; //MakeDirsW

function MaskedPos(const SubStr, Str: AnsiString): Integer;
asm
        { EAX = SubStr }
        { EDX = Str    }
        { Result = EAX }
        TEST    EAX,EAX
        JE      @@noWork

        TEST    EDX,EDX
        JE      @@stringEmpty

        PUSH    EBX
        PUSH    ESI
        PUSH    EDI

        MOV     ESI,EAX                 // Point ESI to SubStr
        MOV     EDI,EDX                 // Point EDI to Str
        MOV     ECX,[EDI-4]             // ECX = Length(Str)
        PUSH    EDI                     // remember Str position to
                                        // calculate index
        MOV     EDX,[ESI-4]             // EDX = Length(SubStr)
        DEC     EDX                     // EDX = Length(SubStr) - 1
        JS      @@fail                  // < 0 ? return 0
        MOV     AL,[ESI]                // AX = first char of SubStr
        INC     ESI                     // Point ESI to 2'nd char of SubStr
        SUB     ECX,EDX                 // #positions in Str to look at
                                        // = Length(Str) - Length(SubStr) + 1
        JLE     @@fail

@@find:
        cmp     al,$3F                  // if first char of SubStr = '?' then
        je      @@foundchar             // first char found

@@loop:
        cmp     byte ptr [edi],al       // find first char of SubStr
        je      @@foundchar
        inc     edi
        loop    @@loop

        jmp     @@fail

@@foundchar:
        inc     edi
        test    edx,edx
        je      @@found
        MOV     EBX,ECX                 // save outer loop counter
        dec     ebx
        PUSH    ESI                     // save outer loop SubStr pointer
        PUSH    EDI                     // save outer loop Str pointer
        MOV     ECX,EDX

@@cmpstr:
        mov     ah,byte ptr [esi]
        cmp     ah,$3F
        je      @@proceed
        cmp     byte ptr [edi],ah
        jne     @@foundfail
@@proceed:
        inc     esi
        inc     edi
        loop    @@cmpstr

        POP     EDI                     // restore outer loop Str pointer
        POP     ESI                     // restore outer loop SubStr pointer
        jmp     @@found

@@foundfail:
        pop     edi
        pop     esi
        MOV     ECX,EBX                 // restore outer loop counter
        JMP     @@find

@@fail:
        POP     EDX                     // get rid of saved Str pointer
        XOR     EAX,EAX
        JMP     @@exit

@@stringEmpty:
        XOR     EAX,EAX
        JMP     @@noWork

@@found:
        POP     EDX                     // restore pointer to first char of Str
        MOV     EAX,EDI                 // EDI points of char after match
        SUB     EAX,EDX                 // the difference is the correct index
@@exit:
        POP     EDI
        POP     ESI
        POP     EBX
@@noWork:
end; //MaskedPos

function MaskedPosW(const SubStr, Str: WideString): Integer;
asm
                { EAX = SubStr }
                { EDX = Str    }
                { Result = EAX }
        TEST    EAX,EAX
        JE      @@noWork

        TEST    EDX,EDX
        JE      @@stringEmpty

        PUSH    EBX
        PUSH    ESI
        PUSH    EDI

        MOV     ESI,EAX                 // Point ESI to SubStr
        MOV     EDI,EDX                 // Point EDI to Str
        MOV     ECX,[EDI-4]
        SHR     ECX,1                   // ECX = Length(Str)
        PUSH    EDI                     // remember Str position to
                                        // calculate index
        MOV     EDX,[ESI-4]
        SHR     EDX,1                   // EDX = Length(SubStr)
        DEC     EDX                     // EDX = Length(SubStr) - 1
        JS      @@fail                  // < 0 ? return 0
        MOV     AX,[ESI]                // AX = first char of SubStr
        ADD     ESI,2                   // Point ESI to 2'nd char of SubStr
        SUB     ECX,EDX                 // #positions in Str to look at
                                        // = Length(Str) - Length(SubStr) + 1
        JLE     @@fail

@@find:
        cmp     ax,$3F                  // if first char of SubStr = '?' then
        je      @@foundchar             // first char found

@@loop:
        cmp     word ptr [edi],ax       // find first char of SubStr
        je      @@foundchar
        add     edi,2
        loop    @@loop

        jmp     @@fail

@@foundchar:
        add     edi,2
        test    edx,edx
        je      @@found
        bswap   eax
        MOV     EBX,ECX                 // save outer loop counter
        dec     ebx
        PUSH    ESI                     // save outer loop SubStr pointer
        PUSH    EDI                     // save outer loop Str pointer
        MOV     ECX,EDX

@@cmpstr:
        mov     ax,word ptr [esi]
        cmp     ax,$3F
        je      @@proceed
        cmp     word ptr [edi],ax
        jne     @@foundfail
@@proceed:
        add     esi,2
        add     edi,2
        loop    @@cmpstr

        POP     EDI                     // restore outer loop Str pointer
        POP     ESI                     // restore outer loop SubStr pointer
        jmp     @@found

@@foundfail:
        bswap   eax
        pop     edi
        pop     esi
        MOV     ECX,EBX                 // restore outer loop counter
        JMP     @@find

@@fail:
        POP     EDX                     // get rid of saved Str pointer
        XOR     EAX,EAX
        JMP     @@exit

@@stringEmpty:
        XOR     EAX,EAX
        JMP     @@noWork

@@found:
        POP     EDX                     // restore pointer to first char of Str
        MOV     EAX,EDI                 // EDI points of char after match
        SUB     EAX,EDX                 // the difference is the correct index
        SHR     EAX,1
@@exit:
        POP     EDI
        POP     ESI
        POP     EBX
@@noWork:
end; //MaskedPosW

function WideMatchesMask(FileName, Mask: WideString; CaseSensitive: Boolean): Boolean;
var
 FP, MP: PWideChar;
 WS: WideString;
 Parts: array of WideString;
 I, J: Integer;
 SlowFind: Boolean;
begin
 WS := WideExtractFileExt(FileName);
 if WS = '' then FileName := FileName + '.';
 if not CaseSensitive then
 begin
  FileName := WideUpperCase(FileName);
  Mask := WideUpperCase(Mask);
 end;
 SlowFind := False;
 FP := Pointer(FileName);
 MP := Pointer(Mask);
 SetLength(Parts, 0);                   //*nto*old*.xls
 while MP^ <> #0 do                     //PhantomasFolder.xls
 begin
  WS := '';
  while (MP^ <> '*') and (MP^ <> #0) do
  begin
   if MP^ = '?' then SlowFind := True;
   WS := WS + MP^;
   Inc(MP);
  end;
  if MP^ = '?' then SlowFind := True;
  if MP^ <> #0 then Inc(MP);
  if WS <> '' then
  begin
   I := Length(Parts);
   SetLength(Parts, I + 1);
   Parts[I] := WS;
  end;
 end;
 Result := True;
 for I := 0 to Length(Parts) - 1 do
 begin
  WS := Parts[I];
  Finalize(Parts[I]);
  if SlowFind then
   J := MaskedPosW(WS, FileName) else
   J := Pos(WS, FileName);
  if J > 0 then Delete(FileName, 1, Length(WS) + (J - 1)) else
  begin
   Result := False;
   Break;
  end;
 end;
end;

function WideStrLen(Str: PWideChar): Integer;
asm
        MOV     EDX,EDI
        MOV     EDI,EAX
        MOV     ECX,0FFFFFFFFH
        XOR     AX,AX
        REPNE   SCASW
        MOV     EAX,0FFFFFFFEH
        SUB     EAX,ECX
        MOV     EDI,EDX
end;

function WideGetCurrentDir: WideString;
var
 S: AnsiString;
begin
 GetDir(0, S);
 if Win32PlatformIsUnicode then
 begin
  SetLength(Result, Length(S));
  GetCurrentDirectoryW(Length(S), Pointer(Result));
 end else Result := S;
end;

end.
