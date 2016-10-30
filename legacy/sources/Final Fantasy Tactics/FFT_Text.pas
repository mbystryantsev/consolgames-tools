unit FFT_Text;

interface

uses TableText, SysUtils, FFTLen;

Procedure FFT_ExtractMainText(Buf: Pointer; Size: Integer; Text: TGameTextSet);
Procedure FFT_InsertMainText(P: Pointer; Text: TGameTextSet);
implementation

Type DWord = LongWord;

Function CheckTextBlock(P: Pointer): Boolean;
var DW: ^DWord; B: ^Byte;
begin
  DW:=P; Result:=False;
  If (DW^=$F2F2F2F2) or (DW^>=$2000-5) Then
	Exit
  else begin
    B:=Pointer(DWord(P)+DW^-1);
    If B^<>$DB Then Exit else Result:=True;
  end;
end;

Procedure FFT_ExtractText(P: Pointer; Size: Integer; Text: TGameTextSet; Count: Integer);
var B: PByte; n: Integer;
begin
  B:=P;
  While true do
  begin
    If DWord(B)-DWord(P)>=Size Then Break;
    Inc(B, Text.AddString(B,0,[$E2]));  {E2} 
    If (Count > 0) and (Text.Items[Text.Count - 1].Count >= Count) Then Break;
    //Inc(B,ExtractText(B,Table,Text[ID].S[n].Text,False,$FE));
    If Word(Pointer(B)^)=0 Then Break;
    If DWord(Pointer(B)^)=$F2F2F2F2 Then Break;
  end;
end;

Function FFT_InsertText(P: PByte; T: TGameTextSet; Index: Integer): Integer;
var n: Integer;
begin
  Result := 0;
  For n := 0 To T.Items[Index].Count - 1 do
    Inc(Result, T.ExportString(P, T.Items[Index].Strings[n], True));
end;

Procedure FFT_InsertMainText(P: Pointer; Text: TGameTextSet);
var n, Num: Integer; B: PByte; Offset: ^DWord;
begin
  For n := 0 To Text.Count - 1 do
  begin
    Num := StrToInt(Text.Items[n].UserData);
    Offset := Pointer(DWord(P)+$2000 * Num);
    FFT_InsertText(Pointer(DWord(Offset) + Offset^), Text, n);
  end;                                                                
end;

Procedure FFT_ExtractMainText(Buf: Pointer; Size: Integer; Text: TGameTextSet);
var n,Count: Integer; DW: ^DWord;
begin
  Count:=0;
  For n:=0 To (Size div $2000)-1 do
  begin
    If CheckTextBlock(Pointer(DWord(Buf)+$2000*n)) Then
    begin
      //SetLength(Text,Count+1);
      DW:=Pointer(DWord(Buf)+$2000*n);
      Text.AddItem(Format('block%d',[n]), IntToStr(n), FFTLens[Count].Hidden);

      //Text[Count].Name:=Format('%.4x:%.8x',[n,DW^]);
      FFT_ExtractText(Pointer(DWord(Buf)+n*$2000+DW^),$2000,Text, FFTLens[Count].Count);
      Inc(Count);
    end;
  end;
end;

end.
 