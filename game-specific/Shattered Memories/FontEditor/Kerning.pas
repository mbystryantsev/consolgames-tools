unit Kerning;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Spin, StdCtrls, TntStdCtrls, ComCtrls, TntComCtrls, ExtCtrls, DIB,
  ActnList;

type
  TKerningForm = class(TForm)
    eCharsImage: TImage;
    eCharA: TTntEdit;
    eCharB: TTntEdit;
    eKerningValue: TSpinEdit;
    eKerningList: TTntListView;
    GroupBox1: TGroupBox;
    eTestStr: TTntEdit;
    eKerningEnable: TCheckBox;
    eTestImage: TImage;
    Button1: TButton;
    Button2: TButton;
    bOK: TButton;
    bCancel: TButton;
    ActionList: TActionList;
    AddAction: TAction;
    RemoveAction: TAction;
    procedure eTestStrChange(Sender: TObject);
    procedure eKerningEnableClick(Sender: TObject);
    procedure eKerningListClick(Sender: TObject);
    procedure eKerningValueChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure bOKClick(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure eCharAKeyPress(Sender: TObject; var Key: Char);
    procedure eCharBKeyPress(Sender: TObject; var Key: Char);
    procedure AddActionExecute(Sender: TObject);
    procedure RemoveActionExecute(Sender: TObject);
    procedure eCharAChange(Sender: TObject);
    procedure eCharBChange(Sender: TObject);
  private
    KerningIndex: Integer;
    CharInputLocked: Boolean;
    Procedure DrawTestString();
    Procedure DrawKerningChars();
    Procedure FillList();
    Procedure UpdateKerning;
  public
    procedure Show;
  end;

implementation

{$R *.dfm}

uses main;

var
  KerningData: Array of TKerningRecord;

{ TKerningForm }

Function min(a, b: Integer): Integer;
begin
  If a <= b Then Result := a
  Else Result := b;
end;

procedure DrawCharData(const img: TDIB; const Ch: TCharacter; const x, y: Integer);
var yy, xx: Integer; Src, Dest: ^Byte;
begin
  For yy := y To min(y + CharHeight, img.Height) - 1do
  begin
    Src := @Ch.Ch[yy - y, 0];
    Dest := img.ScanLine[yy];
    Inc(Dest, x);
    For xx := x To min(x + CharWidth, img.Width) - 1 do
    begin
      If Src^ > 0 Then
        Dest^ := Src^;
      Inc(Src);
      Inc(Dest);      
    end;
  end;
end;

Function DrawChar(const img: TDIB; Index: Integer; const x, y: Integer; Ker: Integer = 0): Integer;
begin
  Result := 0;
  If (Index < 0) or (Index >= FontData.Header.Count) Then Exit;
  DrawCharData(img, Chars[Index], x + Ker, y);
  With FontData.CharData[Index] do
    Result := WW + ker;
end;

Function GetIndex(const C: WideChar): Integer;
var i: Integer;
begin
  For i := 0 To High(FontData.CharData) do
    If FontData.CharData[i].Code = C Then
      break;
  if (i >= 0) and (i < FontData.Header.Count) Then
    Result := i
  else
    Result := -1;
end;

Function GetKerning(a, b: WideChar): Integer;
var i: Integer;
begin
  For i := 0 To High(KerningData) do
  begin
    If (KerningData[i].a = a) and (KerningData[i].b = b) Then
    begin
      Result := KerningData[i].Kerning;
      Exit;
    end;
  end;
  Result := 0;
end;

Procedure DrawString(const img: TDIB; const Str: WideString; x, y: Integer; KerningEnabled: Boolean = True);
var i, ker: Integer;
begin
  ker := 0;
  For i := 1 to Length(Str) do
  begin
    If (i > 1) and KerningEnabled Then ker := GetKerning(Str[i-1], Str[i]);
    Inc(x, DrawChar(img, GetIndex(Str[i]), x, y, ker));
  end;
end;

procedure TKerningForm.DrawTestString;
begin
  DIB1.Fill8bit(0);
  DrawString(DIB1, eTestStr.Text, 0, 0, eKerningEnable.Checked);
  eTestImage.Canvas.CopyRect(Rect(0, 0, 256, 64), DIB1.Canvas, Rect(0, 0, 256, 64));
end;

procedure TKerningForm.Show;
begin
  SetLength(KerningData, Length(FontData.KerningData));
  Move(FontData.KerningData[0], KerningData[0], Length(KerningData) * SizeOf(TKerningRecord));

  //DIB1.Fill8bit(0);
  //DrawCharData(DIB1, Chars[2], 0, 0);
  //DrawString(DIB1, 'Remote', 0, 0);
  //eCharsImage.Canvas.CopyRect(eCharsImage.Canvas.ClipRect, DIB1.Canvas, Rect(0, 0, 256, 128));
  //eCharsImage.Canvas.StretchDraw(eCharsImage.Canvas.ClipRect, DIB2);
  DrawTestString();
  FillList();
  CharInputLocked := False;
  Self.ShowModal;
end;

procedure TKerningForm.eTestStrChange(Sender: TObject);
begin
  DrawTestString();
end;

procedure TKerningForm.eKerningEnableClick(Sender: TObject);
begin
  DrawTestString();
end;

procedure TKerningForm.FillList;
var i: Integer;
begin
  eKerningList.Clear;
  For i := 0 To High(KerningData) do
  begin
    With eKerningList.Items.Add do
    begin
      Caption := KerningData[i].a;
      SubItems.Add(KerningData[i].b);
      SubItems.Add(IntToStr(KerningData[i].Kerning));
    end;
  end;
  If Length(KerningData) = 0 Then
    KerningIndex := -1
  else
  begin
    KerningIndex := 0;
    eKerningList.ItemIndex := 0;
    eKerningList.Selected := eKerningList.Items[KerningIndex];
    eKerningListClick(eKerningList);
  end;
end;

procedure TKerningForm.eKerningListClick(Sender: TObject);
begin
  If (eKerningList.ItemIndex < 0) or (eKerningList.ItemIndex > High(KerningData)) Then Exit;

  KerningIndex := eKerningList.ItemIndex;
  CharInputLocked := True;
  eCharA.Text := KerningData[KerningIndex].a;
  eCharB.Text := KerningData[KerningIndex].b;
  eKerningValue.Value := KerningData[KerningIndex].Kerning;
  CharInputLocked := False;
  DrawKerningChars();
end;

procedure TKerningForm.DrawKerningChars;
var Str: WideString;
begin
  SetLength(Str, 2);
  Str[1] := KerningData[KerningIndex].a;
  Str[2] := KerningData[KerningIndex].b;
  DIB1.Fill8bit(0);
  DrawString(DIB1, Str, 0, 0, True);
  eCharsImage.Canvas.CopyRect(eCharsImage.Canvas.ClipRect, DIB1.Canvas, Rect(0, 0, CharWidth * 2, CharHeight));
end;

procedure TKerningForm.eKerningValueChange(Sender: TObject);
begin
  If (KerningIndex < 0) or (KerningIndex > High(KerningData)) Then Exit;
  KerningData[KerningIndex].Kerning := eKerningValue.Value;
  UpdateKerning();
end;

procedure TKerningForm.UpdateKerning;
begin
  If (KerningIndex < 0) or (KerningIndex > High(KerningData)) Then Exit;
  With eKerningList.Items[KerningIndex] do
  begin
    Caption := KerningData[KerningIndex].a;
    Subitems[0] := KerningData[KerningIndex].b;
    Subitems[1] := IntToStr(KerningData[KerningIndex].Kerning);
  end;
  DrawTestString();
  DrawKerningChars();
end;

procedure TKerningForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #13 Then Key := #0;
end;

procedure TKerningForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    VK_ESCAPE:  Close;
    VK_RETURN:  bOKClick(nil); 
  end;
end;

procedure TKerningForm.bOKClick(Sender: TObject);
begin
  SetLength(FontData.KerningData, Length(KerningData));
  Move(KerningData[0], FontData.KerningData[0], SizeOf(TKerningRecord) * Length(KerningData));
  Close();
end;

procedure TKerningForm.bCancelClick(Sender: TObject);
begin
  Close();
end;

procedure TKerningForm.eCharAKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #$1B Then Key := #0;
end;

procedure TKerningForm.eCharBKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #$1B Then Key := #0;
end;

procedure TKerningForm.AddActionExecute(Sender: TObject);
begin
  KerningIndex := Length(KerningData);
  SetLength(KerningData, KerningIndex + 1);
  KerningData[KerningIndex].a := 'a';
  KerningData[KerningIndex].b := 'b';
  KerningData[KerningIndex].Kerning := 0;
  With eKerningList.Items.Add do
  begin
    Caption := 'a';
    Subitems.Add('b');
    Subitems.Add('0');
  end;
  eKerningList.ItemIndex := KerningIndex;
  eKerningListClick(eKerningList);
  eCharA.SetFocus;
  eCharA.SelectAll;
end;

procedure TKerningForm.RemoveActionExecute(Sender: TObject);
var i: Integer;
begin
  If (KerningIndex < 0) or (KerningIndex > High(KerningData)) Then Exit;
  For i := KerningIndex To High(KerningData) - 1 do
    KerningData[i] := KerningData[i + 1];
  SetLength(KerningData, Length(KerningData) - 1);
  eKerningList.Items.Delete(KerningIndex);
  If KerningIndex > High(KerningData) Then
    KerningIndex := High(KerningData);
  eKerningList.ItemIndex := KerningIndex;
  eKerningListClick(eKerningList);
end;

procedure TKerningForm.eCharAChange(Sender: TObject);
begin
  If CharInputLocked Then Exit;  
  If (KerningIndex < 0) or (KerningIndex > High(KerningData)) Then Exit;
  If eCharA.Text = '' Then Exit;
  KerningData[KerningIndex].a := eCharA.Text[1];
  UpdateKerning();
end;

procedure TKerningForm.eCharBChange(Sender: TObject);
begin
  If CharInputLocked Then Exit;
  If (KerningIndex < 0) or (KerningIndex > High(KerningData)) Then Exit;
  If eCharB.Text = '' Then Exit;                
  KerningData[KerningIndex].b := eCharB.Text[1];
  UpdateKerning();
end;

end.
