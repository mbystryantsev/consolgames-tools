program DoSTextExtract;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows,
  TableText in '..\FFText\TableText.pas';

Type
  TBROM = Array[0..$1000000-1] of Byte;
  TWROM = Array[0..($1000000 div 2)-1] of Word;
  TDWROM = Array[0..($1000000 div 4)-1] of DWord;

const
  cPtrsPos      = $828848;
  cPtrsCount    = $1180 div 2;
  cTextPtrsPos  = $2601C0;
  cScriptPos    = $812DE8;
  cCharsPos     = $1A66F8;

Function ExtractString(Text: TGameTextSet; Ptr: Pointer): WideString;
begin
  Result := '';
  Text.ExtractString(Ptr, Result, 0, [0..255]);
end;

var F: File; ROM: TWROM; S: WideString;
I,n,m: Integer; Ptr: DWord; MText: TGameTextSet; Read: Boolean;  P: PByte;  EOS: Boolean = False;

Procedure Opcode(Fmt: WideString);
begin
  Inc(n);
  S := S + WideFormat(Fmt,[ROM[n]]);
end;

begin
  AssignFile(F, '1805 - Final Fantasy I & II - Dawn of Souls (UA).gba');
  Reset(F, 1);
  BlockRead(F, ROM, Length(ROM)*2);
  CloseFile(F);

  MText := TGameTextSet.Create;
  MText.SepStrEnd := #10'{END}';
  MText.LoadTable('tables\Table_FF2_Eng_TableText.tbl');
  MText.AddItem('main');


  I := cPtrsPos div 2;
  For I := I to I + (cPtrsCount - 1) do
  begin
    n := (ROM[I] * 2 + cScriptPos) div 2;
    S := '';
    //Read := True;
    //Read := False;
    While ROM[n] <> $80FF do
    begin
      If ROM[n] > $8000 Then
      begin
        Case ROM[n] of
          $80F0: S := S + #10;
          $80F1: Opcode('{V=%d}');
          $80F2: Opcode('{C=%d}');
          $80F3: Opcode('{HERO=%d}');
          $80F5: Opcode('{SND=%d}');
          $80F7: Opcode('{W=%d}');
          $80F8: Opcode('{I=%d}');
          $80F9: S := S + ' ';
          $80FA:
          begin
            Inc(n);
            S := S + ExtractString(MText, @TBROM(ROM)[TDWROM(ROM)[(cTextPtrsPos + ROM[n] * 4) div 4] - $08000000]);
          end;
          else
            S := S + WideFormat('{%4.4x}', [ROM[n]]);
        end;
      end
      else
      begin
          P := @ROM[n];
          MText.GetElementString(P, S, EOS, 2, [0..255]);
        end;
        inc(n);
    end;
    MText.AddString(S);
    //WriteLn(Format('[%d] %s',[MText.Items[0].Count, S]));
  end;

  MText.SaveTextToFile('FF2Text.txt');
  MText.Free;
  WriteLn('Done!');
end.
