unit PGen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DXDraws, LNBPass, Spin, DIB, Menus, ActnList;

type
  TForm1 = class(TForm)
    Screen: TDXDraw;
    GroupBox1: TGroupBox;
    eLevel: TSpinEdit;
    Label1: TLabel;
    eAttack: TEdit;
    eExp: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    eMoney: TSpinEdit;
    eM: TSpinEdit;
    Label8: TLabel;
    eMaxHP: TEdit;
    GroupBox2: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    eEqPunch: TComboBox;
    eEqSword: TComboBox;
    eEqShield: TComboBox;
    eEqRobe: TComboBox;
    eEqTalisman: TComboBox;
    eEqAmulet: TComboBox;
    eEqLight: TComboBox;
    eEqSS: TCheckBox;
    eEqSV: TCheckBox;
    eEqSB: TCheckBox;
    eEqSF: TCheckBox;
    GroupBox3: TGroupBox;
    eCity001: TCheckBox;
    eCity002: TCheckBox;
    eCity004: TCheckBox;
    eCity008: TCheckBox;
    eCity010: TCheckBox;
    eCity020: TCheckBox;
    eCity040: TCheckBox;
    eCity080: TCheckBox;
    eCity100: TCheckBox;
    eCity200: TCheckBox;
    GroupBox4: TGroupBox;
    eSweetBun: TSpinEdit;
    eMeatBun: TSpinEdit;
    eWhirlyBird: TSpinEdit;
    eMedicine: TSpinEdit;
    eSkBoard: TSpinEdit;
    eBooBomb: TSpinEdit;
    eDragstar: TSpinEdit;
    eBattery: TSpinEdit;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    eTStars: TSpinEdit;
    Label27: TLabel;
    ePass: TEdit;
    Button1: TButton;
    GroupBox5: TGroupBox;
    eBell01: TCheckBox;
    eBell02: TCheckBox;
    eBell04: TCheckBox;
    eBell08: TCheckBox;
    eBell10: TCheckBox;
    eBell20: TCheckBox;
    eBell40: TCheckBox;
    GroupBox6: TGroupBox;
    eLoc: TComboBox;
    eAUsed: TCheckBox;
    eJK: TSpinEdit;
    Label9: TLabel;
    eEqAntidote: TCheckBox;
    eEqMind: TCheckBox;
    Button2: TButton;
    Button3: TButton;
    GroupBox8: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label28: TLabel;
    ePCS: TEdit;
    eDCS: TEdit;
    eDecr: TComboBox;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Password1: TMenuItem;
    Generate1: TMenuItem;
    Recovery1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    ActionList1: TActionList;
    AExit: TAction;
    AGenPass: TAction;
    ARecPass: TAction;
    AAbout: TAction;
    AEnterPass: TAction;
    Applypassword1: TMenuItem;
    eEqPop: TCheckBox;
    eAutogen: TCheckBox;
    eOriginal: TCheckBox;
    GroupBox7: TGroupBox;
    Label10: TLabel;
    Label29: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure eCity080Click(Sender: TObject);
    procedure eSweetBunChange(Sender: TObject);
    procedure eLevelChange(Sender: TObject);
    procedure eBell01Click(Sender: TObject);
    procedure eMoneyChange(Sender: TObject);
    procedure eExpChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ScreenClick(Sender: TObject);
    procedure ScreenKeyPress(Sender: TObject; var Key: Char);
    procedure ScreenKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ScreenKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AExitExecute(Sender: TObject);
    procedure AGenPassExecute(Sender: TObject);
    procedure AEnterPassExecute(Sender: TObject);
    procedure ScreenExit(Sender: TObject);
    procedure ScreenEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure eAutogenClick(Sender: TObject);
    procedure eEqPunchChange(Sender: TObject);
    procedure eOriginalClick(Sender: TObject);
    procedure AAboutExecute(Sender: TObject);
  private
    { Private declarations }
  public
    Procedure SetPasswordData(Sender: TObject);
    Procedure GetPasswordData(Sender: TObject);
    Procedure SetPlayers(Sender: TObject);
    Procedure SetBells(Sender: TObject);
    Procedure SetCities(Sender: TObject);
    Procedure SetItems(Sender: TObject);
    Procedure SetEquip(Sender: TObject);
    Procedure GetPlayers(Sender: TObject);
    Procedure GetCities(Sender: TObject);
    Procedure GetItems(Sender: TObject);
    Procedure GetEquip(Sender: TObject);
    Procedure GetBells(Sender: TObject);

    Procedure DrawScreen;
    Procedure DrawChar(X,Y: Integer; C: Byte);
    Procedure PassEnter(Sender: TObject);
    Function CheckPass: Boolean;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
{$R Font.res}

var vLevelExp:    Boolean = False;
    vWrong:       Boolean = False;
    vSet:         Boolean = False;
    vGet:         Boolean = False;
    dBG:          TDIB;
    dFont:        TDIB;
    inCP,inX,inY: Integer;
    vShift:       Boolean = False;
    vCtrl:        Boolean = False;
    vDel:         Boolean = False;
    vInputPass:   Boolean = True;
    vF9:          Boolean = False;

const
  cInGrid: Array[0..4,0..9] of Byte = (
  ($FF,$01,$02,$03, $FF,$05,$06,$07, $FF,$DE),
  ($09,$0A,$0B,$0C, $0D,$0E,$0F,$10, $11,$FD),
  ($12,$13,$FF,$15, $16,$17,$18,$19, $1A,$ED),
  ($1B,$1C,$1D,$1E, $1F,$FF,$FF,$00, $08,$FF),
  ($14,$04,$0E,$FF, $FF,$FF,$FF,$FF, $FF,$FF));

  cLocIdx:  Array[0..255] of Byte = (
  $00,$66,$65,$64,$63,$62,$61,$60, $5F,$5E,$5D,$5C,$5B,$5A,$59,$58,
  $57,$56,$55,$54,$53,$52,$51,$50, $4F,$4E,$4D,$4C,$4B,$4A,$49,$48,
  $47,$46,$45,$44,$43,$42,$41,$40, $3F,$3E,$3D,$3C,$3B,$3A,$39,$38,
  $37,$36,$35,$34,$33,$32,$31,$30, $2F,$2E,$2D,$2C,$2B,$2A,$29,$28,
  $27,$26,$25,$24,$23,$22,$21,$20, $1F,$1E,$1D,$1C,$1B,$1A,$19,$18,
  $17,$16,$15,$14,$13,$12,$11,$10, $0F,$0E,$0D,$0C,$0B,$0A,$09,$08,
  $07,$06,$05,$04,$03,$02,$01,$67, $68,$69,$6A,$6B,$6C,$6D,$6E,$6F,
  $70,$71,$72,$73,$74,$75,$76,$77, $78,$79,$7A,$7B,$7C,$7D,$7E,$7F,
  $80,$81,$82,$83,$84,$85,$86,$87, $88,$89,$8A,$8B,$8C,$8D,$8E,$8F,
  $90,$91,$92,$93,$94,$95,$96,$97, $98,$99,$9A,$9B,$9C,$9D,$9E,$9F,
  $A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7, $A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF,
  $B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7, $B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF,
  $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7, $C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF,
  $D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7, $D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,
  $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7, $E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF,
  $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7, $F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF);


Function GetPassLen: Integer;
begin
  For Result:=0 To High(Pass) do If Pass[Result]>$1F Then Exit;
end;

var PassA,PassD: TByteArray; PassV: Byte; PassLen: Integer;
Function TForm1.CheckPass: Boolean;
var PCRC,DCRC: DWord;  pLen: Integer;
begin
  PassLen:=GetPassLen;
  If PassLen<6 Then
  begin
    ePCS.Text := '-----';
    eDCS.Text := '-----';
    Result:=False;
    Exit;
  end;
  SetLength(PassA,PassLen);
  Move(Pass,PassA[0],PassLen);
  PassV:=PassA[5];
  DecPass(PassA);
  pLen:=GetData(PassA,PassD,PassV);
  pLen:=GetCRCLen(pLen);
  DCRC:=GetCheckSum(PassD[3],{Length(PassD)-3}pLen);
  PCRC:=(PassD[0] or (PassD[1] SHL 8) or (PassD[2] SHL 16) and $FFFFF);
  Result:=PCRC=DCRC;
  ePCS.Text := Format('%.5x',[PCRC]);
  eDCS.Text := Format('%.5x',[DCRC]);
  //AEnterPass.Enabled := Result;
  //SetPasswordData(Sender);
end;

Procedure TForm1.PassEnter(Sender: TObject);
begin
  If CheckPass Then
  begin
    GetSaveData(PassD);
    SetPasswordData(Sender);
  end else
    vWrong:=True;
  If vWrong and vF9 Then
    DrawScreen;
end;

Function  GetUpCase(C: Char): Char;
begin
  Result := C;
  case Result of
    'a'..'z':  Dec(Result, Ord('a') - Ord('A'));
    'à'..'ÿ':  Dec(Result, Ord('à') - Ord('À'));
    '¸':       Result := '¨';
  end;
end;

Function GetKey(C: Char; Shift: Boolean = False): Byte;
var n: Integer;
const cDChain = '_ÈÑÂûÀÏÐ=ÎËÄÜÒÎÇÉÊÛÅåÌÖ×Íß234567';
begin
  C:=GetUpCase(C);
  Result:=$FF;
  If Shift Then
  begin
    Case C of
      'C','Ñ': Result:=$0E;
      'Å','T','6','^',':': Result:=$14;
      'S','Û': Result:=$04;
    end;
    If Result<$FF Then Exit;
  end;
  For n:=0 To 31 do
  begin
    If (cPassChain[n+1]=C) or (cDChain[n+1]=C) Then
    begin
      Result:=n;
      Exit;
    end;
  end;
  Case C of
    'O','Ù': Result:=$0E;
  end;
end;

Procedure TForm1.DrawChar(X,Y: Integer; C: Byte);
begin
  Screen.Surface.Canvas.CopyRect
   (Bounds(X,Y,8,8),dFont.Canvas,Bounds((C and $F) SHL 3,8*(C SHR 4),8,8));
end;

Procedure TForm1.DrawScreen;
const bX = 48; bY = 64; bSX = 40; bSY = 128; W: String = 'WRONG PASSWORD    ';
var n,m,X,Y: Integer;
begin
  X:=bX;
  Y:=bY;
  With Screen, Surface.Canvas do
  begin
    Draw(0,0,dBG);
    For n:=0 To High(Pass) do
    begin
      If Pass[n]=$FF Then break;
      If (X>bX) and (18*(n div 18)=n) Then
      begin
        Inc(Y,16);
        X:=bX;
      end else
        If (X>bX) and ((6*(n div 6))=n) Then Inc(X,8);
      DrawChar(X,Y,Pass[n]);
      Inc(X,8);
    end;
    Y:=inCP div 18;
    X:=(inCP-(Y*18));
    Inc(X,X div 6);
    DrawChar(bX+8*X,bY+Y*16+8,$40);

    If not vInputPass Then
      For n:=0 To 17 do DrawChar(32+n*8,32,$20)
    else
    If vWrong Then
    begin
      vWrong:=False;
      For n:=1 To Length(W) do
        DrawChar(24+n*8,32,Byte(W[n]));
    end;

    X:=bSX+16*inX;
    Y:=bsY+16*inY+8;
    If inX=9 Then Inc(X,8);
    DrawChar(X,Y,$40);

    Release;
    Flip;
  end;
end;

Procedure TForm1.GetPlayers(Sender: TObject);
begin
  If vSet Then Exit;
  With Save do
  begin
    Word(sExp)    := eExp.Value;
    DWord(sMoney) := eMoney.Value;
    sM            := eM.Value;
    Save.sJKicks  := eJK.Value;
  end;
  If (eAutogen.Checked and not vGet) Then AGenPassExecute(Sender);
end;


Procedure TForm1.GetItems(Sender: TObject);
begin
  If vSet Then Exit;
  With Save, sIt do
  begin
    iSweetBun   := eSweetBun.Value;
    iMeatBun    := eMeatBun.Value;
    iWhirlyBird := eWhirlyBird.Value;
    iMedicine   := eMedicine.Value;
    iSkBoard    := eSkBoard.Value;
    iBooBomb    := eBooBomb.Value;
    iDragstar   := eDragstar.Value;
    iBattery    := eBattery.Value;
    sTStars     := eTStars.Value;
  end;
  If (eAutogen.Checked and not vGet) Then AGenPassExecute(Sender);
end;

Procedure TForm1.GetEquip(Sender: TObject);
begin
  If vSet Then Exit;
  With Save.sEq do
  begin
    ePunch    := eEqPunch.ItemIndex;
    eSword    := eEqSword.ItemIndex;
    eShield   := eEqShield.ItemIndex;
    eRobe     := eEqRobe.ItemIndex;
    eTalisman := eEqTalisman.ItemIndex;
    eAmulet   := eEqAmulet.ItemIndex;
    eLight    := eEqLight.ItemIndex;
    eTStars    := 0;
    eTStars   := Byte(eEqSS.Checked);
    eTStars   := eTStars or (Byte(eEqSV.Checked) SHL 1);
    eTStars   := eTStars or (Byte(eEqSB.Checked) SHL 2);
    eTStars   := eTStars or (Byte(eEqSF.Checked) SHL 3);
  end;
  If (eAutogen.Checked and not vGet) Then AGenPassExecute(Sender);
end;

Procedure TForm1.GetBells(Sender: TObject);
begin
  If vSet Then Exit;
  With Save, sEq do
  begin
    eBells := Byte(eBell01.Checked);
    eBells := eBells or (Byte(eBell02.Checked) SHL 1);
    eBells := eBells or (Byte(eBell04.Checked) SHL 2);
    eBells := eBells or (Byte(eBell08.Checked) SHL 3);
    eBells := eBells or (Byte(eBell10.Checked) SHL 4);
    eBells := eBells or (Byte(eBell20.Checked) SHL 5);
    eBells := eBells or (Byte(eBell40.Checked) SHL 6);
    eTreasure := Byte(eEqAntidote.Checked);
    eTreasure := eTreasure or (Byte(eEqMind.Checked) SHL 1);
    sUsedTr   := Byte(eAUsed.Checked);
    sUsedTr   := sUsedTr or (Byte(eEqPop.Checked) SHL 1);
    sLoc      := eLoc.ItemIndex;
  end;
  If (eAutogen.Checked and not vGet) Then AGenPassExecute(Sender);
end;

Procedure TForm1.SetPasswordData(Sender: TObject);
begin
  SetPlayers(Sender);
  SetCities(Sender);
  SetItems(Sender);
  SetEquip(Sender);
  SetCities(Sender);
  SetBells(Sender);
  Application.ProcessMessages;
end;

Procedure TForm1.SetPlayers(Sender: TObject);
var Level: Byte;
begin
  vSet := True;
  With Save do
  begin
    Level         := GetLevel(Word(sExp));
    eLevel.Text   := Format('%d',[Level]);
    eExp.Value    := Word(sExp);
    eMoney.Value  := DWord(sMoney);
    eM.Value      := sM;
    eJK.Value     := Save.sJKicks;
    eMaxHP.Text   := Format('%d',[cLevelData[Level].MaxHP]);
    eAttack.Text  := Format('%d',[cLevelData[Level].Attack]);
  end;
  vSet := False;
end;

Procedure TForm1.SetEquip(Sender: TObject);
begin
  vSet := True;
  With Save.sEq do
  begin
    eEqPunch.ItemIndex    := ePunch;
    eEqSword.ItemIndex    := eSword;
    eEqShield.ItemIndex   := eShield;
    eEqRobe.ItemIndex     := eRobe;
    eEqTalisman.ItemIndex := eTalisman;
    eEqAmulet.ItemIndex   := eAmulet;
    eEqLight.ItemIndex    := eLight;
    eEqSS.Checked := Boolean(eTStars and 1);
    eEqSV.Checked := Boolean((eTStars SHR 1) and 1);
    eEqSB.Checked := Boolean((eTStars SHR 2) and 1);
    eEqSF.Checked := Boolean((eTStars SHR 3) and 1);
  end;
  vSet := False;
end;

Procedure TForm1.SetBells(Sender: TObject);
begin
  vSet := True;
  With Save,sEq do
  begin
    eBell01.Checked     := Boolean(eBells and 1);
    eBell02.Checked     := Boolean((eBells SHR 1) and 1);
    eBell04.Checked     := Boolean((eBells SHR 2) and 1);
    eBell08.Checked     := Boolean((eBells SHR 3) and 1);
    eBell10.Checked     := Boolean((eBells SHR 4) and 1);
    eBell20.Checked     := Boolean((eBells SHR 5) and 1);
    eBell40.Checked     := Boolean((eBells SHR 6) and 1);
    eEqAntidote.Checked := Boolean(eTreasure and 1);
    eEqMind.Checked     := Boolean((eTreasure SHR 1) and 1);
    eAUsed.Checked      := Boolean(sUsedTr and 1);
    eEqPop.Checked     := Boolean((sUsedTr SHR 1) and 1);
    eLoc.ItemIndex      := sLoc;
  end;
  vSet := False;
end;

Procedure TForm1.SetItems(Sender: TObject);
begin
  vSet := True;
  With Save.sIt do
  begin
    eSweetBun.Value   := iSweetBun;
    eMeatBun.Value    := iMeatBun;
    eWhirlyBird.Value := iWhirlyBird;
    eMedicine.Value   := iMedicine;
    eSkBoard.Value    := iSkBoard;
    eBooBomb.Value    := iBooBomb;
    eDragstar.Value   := iDragstar;
    eBattery.Value    := iBattery;
    eTStars.Value     := Save.sTStars;
  end;
  vSet := False;
end;

Procedure TForm1.SetCities(Sender: TObject);
begin
  vSet := True;
  With Save do
  begin
    eCity001.Checked := Boolean(sCities[0] and 1);
    eCity002.Checked := Boolean((sCities[0] SHR 1) and 1);
    eCity004.Checked := Boolean((sCities[0] SHR 2) and 1);
    eCity008.Checked := Boolean((sCities[0] SHR 3) and 1);
    eCity010.Checked := Boolean((sCities[0] SHR 4) and 1);
    eCity020.Checked := Boolean((sCities[0] SHR 5) and 1);
    eCity040.Checked := Boolean((sCities[0] SHR 6) and 1);
    eCity080.Checked := Boolean((sCities[0] SHR 7) and 1);
    eCity100.Checked := Boolean(sCities[1] and 1);
    eCity200.Checked := Boolean((sCities[1] SHR 1) and 1);
  end;
  vSet := False;
end;

Procedure TForm1.GetCities(Sender: TObject);
begin
  If vSet Then Exit;
  With Save do
  begin
    Word(sCities):=0;
    sCities[0]:=sCities[0] or  Byte(eCity001.Checked);
    sCities[0]:=sCities[0] or (Byte(eCity002.Checked) SHL 1);
    sCities[0]:=sCities[0] or (Byte(eCity004.Checked) SHL 2);
    sCities[0]:=sCities[0] or (Byte(eCity008.Checked) SHL 3);
    sCities[0]:=sCities[0] or (Byte(eCity010.Checked) SHL 4);
    sCities[0]:=sCities[0] or (Byte(eCity020.Checked) SHL 5);
    sCities[0]:=sCities[0] or (Byte(eCity040.Checked) SHL 6);
    sCities[0]:=sCities[0] or (Byte(eCity080.Checked) SHL 7);
    sCities[1]:=sCities[1] or  Byte(eCity100.Checked);
    sCities[1]:=sCities[1] or (Byte(eCity200.Checked) SHL 1);
  end;
  If (eAutogen.Checked and not vGet) Then AGenPassExecute(Sender);
end;

Procedure TForm1.GetPasswordData(Sender: TObject);
begin
  vGet:=True;
  GetPlayers(Sender);
  GetCities(Sender);
  GetItems(Sender);
  GetEquip(Sender);
  GetCities(Sender);
  GetBells(Sender);
  vGet:=False;
end;

procedure TForm1.Button1Click(Sender: TObject);
var A,D,M: TByteArray; MMask: Byte; n: Integer; S: String; V: Byte;
MMM: DWord;
begin
  PassToBin(ePass.Text,A);
  V:=A[5];
  FillChar(Pass,Length(Pass),$FF);
  Move(A[0],Pass,Length(A));

  DecPass(A);

  GetData(A,D,V);
  MMM:=GetSaveData(D);
  SetPasswordData(Sender);
  DrawScreen;
end;

procedure TForm1.eCity080Click(Sender: TObject);
begin
  GetCities(Sender);
end;

procedure TForm1.eSweetBunChange(Sender: TObject);
begin
  GetItems(Sender);
end;

procedure TForm1.eLevelChange(Sender: TObject);
var TL,TE: TNotifyEvent;
begin
  @TE:=@eExp.OnChange;
  @eExp.OnChange := nil;
  @TL:=@eLevel.OnChange;
  @eLevel.OnChange := nil;
  eExp.Value := cLevelData[eLevel.Value].Exp;
  eAttack.Text:=Format('%d',[cLevelData[eLevel.Value].Attack]);
  eMaxHP.Text:=Format('%d',[cLevelData[eLevel.Value].MaxHP]);
  GetPlayers(Sender);
  @eExp.OnChange := @TE;
  @eLevel.OnChange := @TL;
end;

procedure TForm1.eBell01Click(Sender: TObject);
begin
  GetBells(Sender);
end;

procedure TForm1.eMoneyChange(Sender: TObject);
begin
    GetPlayers(Sender);
end;

procedure TForm1.eExpChange(Sender: TObject);
var TL,TE: TNotifyEvent;
begin
  @TE:=@eExp.OnChange;
  @eExp.OnChange := nil;
  @TL:=@eLevel.OnChange;
  @eLevel.OnChange := nil;
  eLevel.Value:=GetLevel(eExp.Value);
  eAttack.Text:=Format('%d',[cLevelData[eLevel.Value].Attack]);
  eMaxHP.Text:=Format('%d',[cLevelData[eLevel.Value].MaxHP]);
  GetPlayers(Sender);
  @eExp.OnChange := @TE;
  @eLevel.OnChange := @TL;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  SetPasswordData(Sender);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  GetPasswordData(Sender);
end;

procedure TForm1.ScreenClick(Sender: TObject);
begin
  Screen.SetFocus;
end;

procedure TForm1.ScreenKeyPress(Sender: TObject; var Key: Char);
var C: Byte; Dr: Boolean;
begin
  Dr:=False;
  Case Key of
    #08: If inCP>0 Then Dec(inCP);
  end;
  If not (Key in [#13,#32,#08]) Then
  begin
    C:=GetKey(Key, vShift);
    If C>$1F Then Exit;
    Pass[inCP]:=C;
    If inCP<High(Pass) Then Inc(inCP);
    Dr:=True;
  end;
  If (Key=#08) or Dr Then
  begin
    CheckPass;
    DrawScreen;
  end;
end;

procedure TForm1.ScreenKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
const cLX: Array[0..4] of Byte = (10,10,10,9,3);
      cLY: Array[0..9] of Byte = (5,5,5,4,4,4,4,4,4,3);
begin
  Case Key of
    $10: vShift := True;
    $11: vCtrl  := True;
    $2E:
    begin
      vDel   := True;
      FillChar(Pass[inCP],Length(Pass)-inCP,$FF);
      CheckPass;
    end;
    37: Dec(InX);  // <-
    38: Dec(inY);  // ^
    39: Inc(inX);
    40: Inc(inY);
    13,32:
    begin
      If cInGrid[inY,inX]<=$1F Then
      begin
        Pass[inCP]:=cInGrid[inY,inX];
        If inCP<High(Pass) Then Inc(inCP);
      end else
      begin
        Case cInGrid[inY,inX] of
          $DE: FillChar(Pass[inCP],Length(Pass)-inCP,$FF);
          $FD: If (inCP<High(Pass)) and (Pass[inCP+1]<>$FF) Then Inc(inCP); 
          $ED: PassEnter(Sender);
        end;
      end;
    end;
  end;
  Case Key of
    37,39: If InX<0 Then inX:=cLX[inY]-1 else If inX>cLX[inY]-1 Then inX:=0;
    38,40: If inY<0 Then inY:=cLY[inX]-1 else If inY>cLY[inX]-1 Then inY:=0;
  end;
  If Key in [$2E,13,32,37..40] Then
  begin
    CheckPass;
    DrawScreen;
  end;

end;

procedure TForm1.ScreenKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    $10: vShift := False;
    $11: vCtrl  := False;
    $2E: vDel   := False;
  end;
end;

procedure TForm1.AExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TForm1.AGenPassExecute(Sender: TObject);
begin
  GetPasswordData(Sender);
  GeneratePassword(eDecr.ItemIndex-1,eOriginal.Checked);
  SetPasswordData(Sender);
  If not CheckPass Then
  begin
    Pass[GetPassLen]:=Pass[5];
    If not CheckPass Then
    begin
      ShowMessage('CRC Error :(');
      Pass[GetPassLen]:=Pass[5];
      CheckPass;
    end;
  end;
  DrawScreen;
end;

procedure TForm1.AEnterPassExecute(Sender: TObject);
begin
  vF9:=True;
  PassEnter(Sender);
  vF9:=False;
end;

procedure TForm1.ScreenExit(Sender: TObject);
begin
  vInputPass:=False;
  DrawScreen;
end;

procedure TForm1.ScreenEnter(Sender: TObject);
begin
  vInputPass := True;
  DrawScreen;  
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Screen.Initialize;
  AGenPassExecute(Sender);
  DrawScreen;
  If ParamStr(1)='-debug' Then
  begin
    ePass.Visible   := True;
    Button1.Visible := True;
    Button2.Visible := True;
    Button3.Visible := True;
    Form1.Height    := Form1.Height + 32;
  end;
end;

procedure TForm1.eAutogenClick(Sender: TObject);
begin
  If eAutogen.Checked Then AGenPassExecute(Sender);
end;

procedure TForm1.eEqPunchChange(Sender: TObject);
begin
  GetEquip(Sender);
end;

procedure TForm1.eOriginalClick(Sender: TObject);
begin
  If (eAutogen.Checked and not vGet) Then AGenPassExecute(Sender);
end;

procedure TForm1.AAboutExecute(Sender: TObject);
begin
  MessageDlg(
  'Little Ninja Brothers Password Generator by HoRRoR'#13#10+
  'horror.cg@gmail.com :: ho-rr-or@mail.ru'#13#10+
  'http://consolgames.ru/',
  mtInformation,[mbOK],-1);
end;

Initialization
  dFont:=TDIB.Create;
  dFont.LoadFromResourceName(HInstance,'FONT');
  dBG:=TDIB.Create;
  dBG.LoadFromResourceName(HInstance,'SCREEN');
  inCP:=0; inX:=0; inY:=0;
  FillChar(Pass,Length(Pass),$FF);
Finalization
  dFont.Free;
  dBG.Free;
end.
