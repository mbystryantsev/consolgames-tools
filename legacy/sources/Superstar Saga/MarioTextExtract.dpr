program MarioTextExtract;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows,
  TableText in '..\FFText\TableText.pas';

Type
  DWord = LongWord;
  TTextDataRecord = Record
    PtrStart: DWord;
    PtrEnd:   DWord;
    PtrStep:  DWord;
    Scr:      Boolean;
    NL:       Boolean;
    Name:     WideString;
    Descr:    WideString;
  end;


Procedure CreateError(S: String; Level: TErrorType = etError);
const cLevelStr: Array[TErrorType] of String = ('***LOG: ','***HINT: ','***WARNING: ','***ERROR: ');
begin
  WriteLn(cLevelStr[Level] + S);
end;

Function Progress(Cur, Max: Integer; S: String): Boolean;
begin
  WriteLn(Format('[%d/%d] %s', [Cur+1,Max,S]));
end;

const
  cTextSet: Array[0..17] of TTextDataRecord = (
  (PtrStart: $4E8898; PtrEnd: $4F46BF; PtrStep: 5; Scr: True; NL: False;   Name: 'Dialogs1'; Descr: 'Диалоги 1'),
  (PtrStart: $516E98; PtrEnd: $517E9B; PtrStep: 5; Scr: True; NL: False;   Name: 'Dialogs2'; Descr: 'Диалоги 2'),
  (PtrStart: $518C88; PtrEnd: $518D87; PtrStep: 5; Scr: True; NL: False;   Name: 'Dialogs3'; Descr: 'Диалоги 3'),

  (PtrStart: $3BAA50; PtrEnd: $3BAAF7; PtrStep: 1; Scr: False; NL: False;  Name: 'Menu';   Descr: 'Меню'),
  (PtrStart: $3BB7F4; PtrEnd: $3BB8BB; PtrStep: 1; Scr: False; NL: True;   Name: 'Items';  Descr: 'Предметы и еда'),
  (PtrStart: $3BA4FC; PtrEnd: $3BA58B; PtrStep: 1; Scr: False; NL: False;  Name: 'Block0'; Descr: ''),
  (PtrStart: $3BA664; PtrEnd: $3BA6E7; PtrStep: 1; Scr: False; NL: False;  Name: 'Battle'; Descr: ''),
  (PtrStart: $3C07A8; PtrEnd: $3C08C7; PtrStep: 1; Scr: False; NL: False;  Name: 'Shop';   Descr: 'В магазине'),
  (PtrStart: $3C0D9C; PtrEnd: $3C1603; PtrStep: 1; Scr: False; NL: False;  Name: 'Staff';  Descr: 'Титры'),

  (PtrStart: $3BF470; PtrEnd: $3BF5FF; PtrStep: 1; Scr: False; NL: False;  Name: 'Areas';   Descr: 'Местности'),
  (PtrStart: $4FEAA0; PtrEnd: $4FEDB7; PtrStep: 1; Scr: False; NL: False;  Name: 'Enemies'; Descr: 'Враги'),
  (PtrStart: $3BEA14; PtrEnd: $3BEA4B; PtrStep: 1; Scr: False; NL: False;  Name: 'Bonuses'; Descr: 'Бонусы'),
  (PtrStart: $3BCCD4; PtrEnd: $3BCCF3; PtrStep: 1; Scr: False; NL: False;  Name: 'Beans';   Descr: 'Бобы'),
  (PtrStart: $3BAA50; PtrEnd: $3BAAF7; PtrStep: 1; Scr: False; NL: False;  Name: 'Save-Load-Delete'; Descr: ''),
  (PtrStart: $3BCDF4; PtrEnd: $3BCF53; PtrStep: 1; Scr: False; NL: False;  Name: 'Badges';  Descr: 'Значки'),
  (PtrStart: $3BDBB4; PtrEnd: $3BDD23; PtrStep: 1; Scr: False; NL: False;  Name: 'Pants';   Descr: 'Штаны'),
  (PtrStart: $4FE470; PtrEnd: $4FE4FF; PtrStep: 1; Scr: False; NL: False;  Name: 'Attacks'; Descr: 'Атаки'),
  (PtrStart: $3BEBF0; PtrEnd: $3BECEF; PtrStep: 2; Scr: False; NL: False;  Name: 'Block1'; Descr: '')
  );

 // cPtrStart = $4E8898;
 // cPtrEnd   = $4F46BF;
 // cStep = 5;

  cStrPos = $3D7C58;
var Buf: Pointer; Size, Count: Integer; Ptr: ^Integer; MText: TGameTextSet;
    n, m, Num, Code: Integer; F: File; ScrStr, S, Str: WideString; B: PByte; Pos: Integer;
    PEnd, PStart, PStep: Integer; Sc: Boolean;  LPtrs: Array of DWord;
    t1, t2: TSYSTEMTIME; Time: Integer;
begin
  If ParamStr(1) = '-e' Then
  begin
    AssignFile(F, ParamStr(2));
    Reset(F,1);
    Size := FileSize(F);
    GetMem(Buf, Size);
    BlockRead(F, Buf^, Size);
    CloseFile(F);
    MText := TGameTextSet.Create(@CreateError);
    MText.LoadTable(ParamStr(3));

    For Num := Low(cTextSet) to High(cTextSet) do With cTextSet[Num] do
    begin
      Progress(Num, Length(cTextSet), Name);
      n := 0;
      Count := (PtrEnd - PtrStart) div 4;
      Ptr := Pointer(LongWord(Buf) + PtrStart);
      MText.AddItem(Name, WideFormat('%6.6x-%6.6x,%d,%d',[PtrStart,PtrEnd,PtrStep,Integer(Scr)]), False, Descr);
      While n < Count do
      begin
        B := Pointer(LongWord(Buf) + Ptr^ - $08000000);
        If Scr Then
        begin
          S := Format('[%3.3d,', [B^]); Inc(B);
          S := S + Format('%3.3d]'#10,  [B^]); Inc(B);
        end;                   
        Str := '';
        Inc(B, MText.ExtractString(B, Str, 0, [$FF]));
        If NL Then
        begin
          Str := Str + #10'--'#10;
          MText.ExtractString(B, Str, 0, [$FF]);
        end;
        If Scr Then
          MText.AddString(S + Str)
        else
          MText.AddString(Str);
        Inc(Ptr, PtrStep);
        Inc(n,   PtrStep);
      end;
    end;

    MText.SaveTextToFile(ParamStr(4));
    FreeMem(Buf);
    MText.Free;      
    WriteLn('Done!');
    // MarioTextExtract.exe -e Mario_or.gba Tables\Table_En.tbl Mario.txt
  end else
  If ParamStr(1) = '-b' Then
  begin
    // MarioTextExtract.exe -b Mario.gba Tables\Table_En.tbl Mario.txt
    AssignFile(F, ParamStr(2));
    Reset(F,1);
    Size := FileSize(F);
    GetMem(Buf, Size);
    BlockRead(F, Buf^, Size);
    MText := TGameTextSet.Create(@CreateError);
    MText.LoadTable(ParamStr(3));
    MText.LoadTextFromFile(ParamStr(4)); 

    Pos := 0;
    SetLength(ScrStr, 3);
    SetLength(Str, 7);

    GetSystemTime(t1);

    For Num := 0 To MText.Count - 1 do
    begin
      Progress(Num, MText.Count, MText.Items[Num].Name);
      S := MText.Items[Num].UserData;
      If Length(S)<>17 Then
      begin
        CreateError('Invalid String: ' + S);
        Break;
      end;
      Str[1] := '$';
      Move(S[1], Str[2], Length(Str)*2 - 2);
      Val(Str, PStart, Code);
      Move(S[8], Str[2], Length(Str)*2 - 2);
      Val(Str, PEnd, Code);
      Val(S[17], PStep, Code);
      Sc := PStep > 0;
      Val(S[15], PStep, Code);
      Count := (PEnd - PStart) div 4;
      Ptr := Pointer(LongWord(Buf) + PStart);
      SetLength(LPtrs, MText.Items[Num].Count);
      For n := 0 To MText.Items[Num].Count - 1 do
      begin
        Ptr^ := cStrPos + Pos + $08000000;
        S := MText.Items[Num].Strings[n];   
        //WriteLn(n, ' ', Length(S));
        //FillChar(m, 4, $FF);
        m := $FFFFFFFF;
        For m := 0 To n - 1 do
          If MText.Items[Num].Strings[m] = S Then
            break;
        If (m >= 0) and (m < n) Then
        begin
          Ptr^     := LPtrs[m];
          LPtrs[n] := LPtrs[m];
          Inc(Ptr, PStep);
          Continue;
        end;
          LPtrs[n] := Ptr^;

        B := Pointer(LongWord(Buf) + cStrPos + Pos);
        If Sc Then
        begin
          Move(S[2], ScrStr[1], 3*2);
          Val(ScrStr, B^, Code);
          Inc(B);
          Move(S[6], ScrStr[1], 3*2);
          Val(ScrStr, B^, Code);
          Inc(B);
          Inc(Pos, 2);
          If Char(S[11]) in [#10,#13] Then
            m := 12
          else
            m := 11;
          //SetLength(Str, Length(S) - m + 1);
          //Move(S[m], Str[1], Length(Str) * 2);
          Inc(Pos, MText.ExportString(B, @S[m], Length(S) - m + 1, True));
        end else
          Inc(Pos, MText.ExportString(B, S, True));
        Pos := (Pos + 3) and $FFFFFFFC;
        //While (Pos mod 4) > 0 do
        //  Inc(Pos);
        Inc(Ptr, PStep);
      end;
    end;

    GetSystemTime(t2);
    Time := (t2.wMilliseconds + t2.wSecond * 1000 + t2.wMinute * 60000) - (t1.wMilliseconds + t1.wSecond * 1000 + t1.wMinute * 60000);
    WriteLn(Time, ' Milliseconds');

    Seek(F,0);
    BlockWrite(F, Buf^, Size);
    CloseFile(F);
    MText.Free;
    FreeMem(Buf);     
    WriteLn('Done!');
  end;

end.
 