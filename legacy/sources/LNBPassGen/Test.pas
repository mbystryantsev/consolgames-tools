unit Test;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, LNBPass;

type
  TForm1 = class(TForm)
    ePass: TEdit;
    ePassBin: TEdit;
    ePassData: TEdit;
    Button1: TButton;
    ePassBin2: TEdit;
    eCheckSum: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    eData: TMemo;
    eMainMask: TEdit;
    eMask: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

Procedure ShowData;
begin
  With Form1, Save, sIt, sEq do
  begin
    eData.Text :=
    Format('Players:'#13#10+
    'Money:'#9#9'%d'#13#10+
    'Experience:'#9'%d'#13#10+
    'Cities:'#9#9'%.3x'#13#10+
    'Jack HP:'#9#9'%d'#13#10+
    'Ruy HP:'#9#9'%d'#13#10+
    'Jack Weight:'#9'%d'#13#10+
    'Ruy Weight:'#9'%d'#13#10+
    'Jack Kicks:'#9'%d'#13#10+
    'Ruy Kicks:'#9'%d'#13#10+
    'M'#$27's:'#9#9'%d'#13#10+
    'T-Stars:'#9#9'%d',
    [DWord(sMoney),Word(sExp),Word(sCities),sJHP,
    sRHP,sJW,sRW,sJKicks,sRKicks,sM,sTStars]);

    eData.Text := Format('%s'#13#10#13#10'Items:'#13#10+
    'Battery:'#9#9'%d'#13#10+
    'WhirlyBird:'#9'%d'#13#10+
    'Medicine:'#9#9'%d'#13#10+
    'SweetBun:'#9'%d'#13#10+
    'MeatBun:'#9#9'%d'#13#10+
    'Dragster:'#9#9'%d'#13#10+
    'SkBoard:'#9#9'%d'#13#10+
    'BooBomb:'#9'%d',
    [eData.Text,iBattery,iWhirlyBird,iMedicine,iSweetBun,
    iMeatBun,iDragstar,iSkBoard,iBooBomb]);

    eData.Text := Format('%s'#13#10#13#10'Equip:'#13#10+
    'Punch:'#9#9'%s'#13#10+
    'Sword:'#9#9'%s'#13#10+
    'Shield:'#9#9'%s'#13#10+
    'Robe:'#9#9'%s'#13#10+
    'Talisman:'#9#9'%s'#13#10+
    'Amulet:'#9#9'%s'#13#10+
    'Light:'#9#9'%s'#13#10+
    'T-Stars:'#9#9'%.2x',
    [eData.Text,cEqPunch[ePunch],cEqSword[eSword],cEqShield[eShield],
    cEqRobe[eRobe],cEqTalisman[eTalisman],cEqAmulet[eAmulet],
    cEqLight[eLight],eTStars]);

    eData.Text := Format('%s'#13#10#13#10'Unknown:'#13#10+
    'U[0]:'#9#9'%.2x'#13#10+
    'U[1]:'#9#9'%.2x'#13#10+
    'LU[0]:'#9#9'%.2x'#13#10+
    'LU[1]:'#9#9'%.2x'#13#10+
    'LU[2]:'#9#9'%.2x'#13#10+
    'LU[3]:'#9#9'%.2x'#13#10+
    'LU[4]:'#9#9'%.2x'#13#10+
    'LU[5]:'#9#9'%.2x',
    [eData.Text,sU[0],sU[1],sLU[0],sLU[1],sLU[2],sLU[3],
    sLU[4],sLU[5]]);
  end;


end;

procedure TForm1.Button1Click(Sender: TObject);
var A,D,M: TByteArray; MMask: Byte; n: Integer; S: String; V: Byte;
MMM: DWord;
begin
  PassToBin(ePass.Text,A);
  ePassBin.Text:=ShowArr(A);
  V:=A[5];

  DecPass(A);
  ePassBin2.Text:=ShowArr(A);


  GetData(A,D,V);
  MMask:=D[2] SHR 4;
  ePassData.Text:=ShowArr(D);
  eCheckSum.Text := Format('%.5x',[GetCheckSum(D[3],Length(D)-3)]);
  eMainMask.Text:='';
  With eMainMask do For n:=3 DownTo 0 do
  begin
    Text:=Format('%s%.1d',[Text,(MMask SHR n) and 1]);
  end;
  MMM:=GetSaveData(D);
  eMask.Text:=IntToHex(MMM,8);


  ShowData;
end;

end.
