unit StrP;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Grids, ValEdit, ActnList, Menus, StdCtrls, XPMan, Str;

type
  TForm1 = class(TForm)
    VList: TValueListEditor;
    MainMenu1: TMainMenu;
    ActionList1: TActionList;
    File1: TMenuItem;
    LoadStream1: TMenuItem;
    aLoad: TAction;
    Op: TOpenDialog;
    SectorBar: TTrackBar;
    FrameBar: TTrackBar;
    Button1: TButton;
    Edit1: TEdit;
    SectorBox: TGroupBox;
    XPManifest1: TXPManifest;
    Button2: TButton;
    Button3: TButton;
    FrameBox: TGroupBox;
    Button4: TButton;
    procedure aLoadExecute(Sender: TObject);
    procedure SectorBarChange(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FrameBarChange(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  SectorCount: Integer = 1000;

implementation

{$R *.dfm}

procedure TForm1.aLoadExecute(Sender: TObject);
begin
  //D
end;

procedure TForm1.SectorBarChange(Sender: TObject);
begin
  SectorBox.Caption:=Format('Sector [%d/%d]:',
  [SectorBar.Position,SectorCount]);

end;

var Fr,Fr2: TFrameArray;
procedure TForm1.Button3Click(Sender: TObject);
var P,P2: TSTRParam; B: TBadArray;
begin

// Frames 15 - 90

  {P.BeginPos:=0;
  P.SectorSize:=$800;
  P.HeaderOffset:=0;
  Fr:=LoadFrames('sh1\str\sh.str', P, SectorCount);}

  //P.BeginPos:=$D2535AC;
  P.SectorSize:=$930;
  P.HeaderOffset:=$18;
  //Fr:=LoadFrames('Копия HILL', P, SectorCount,B);
  //P.BeginPos:=$D2535AC;
  //Fr:=LoadFrames('HILL', P, SectorCount,B);
  P.BeginPos:=$100B074C;
  Fr:=LoadFrames('Копия HILL', P, SectorCount,B);
  {
  P.BeginPos:=$2C;
  P.SectorSize:=$930;
  P.HeaderOffset:=$18;
  Fr:=LoadFrames('SH1\STR\Old\!@!.STR', P, SectorCount,B);
  }


  SectorBar.Max:=SectorCount;
  FrameBar.Min:=1;
  FrameBar.Max:=Length(Fr);
  SectorBar.Max:=SectorCount;


end;

procedure TForm1.FrameBarChange(Sender: TObject);
begin
  FrameBox.Caption:=Format('Frame[%d/%d]:',
  [FrameBar.Position,FrameBar.Max]);
  SectorBar.Position:=Fr[FrameBar.Position-1].Sector;
  VList.Strings[0]:='StStatus='+IntToStr(Fr[FrameBar.Position-1].Head.StStatus);
  VList.Strings[1]:='StType='+IntToHex(Fr[FrameBar.Position-1].Head.StType,4);
  VList.Strings[2]:='StSector_Offset='+IntToStr(Fr[FrameBar.Position-1].Head.StSector_Offset);
  VList.Strings[3]:='StSector_Size='+IntToStr(Fr[FrameBar.Position-1].Head.StSector_Size);
  VList.Strings[4]:='StFrame_No='+IntToStr(Fr[FrameBar.Position-1].Head.StFrame_No);
  VList.Strings[5]:='StFrameSize='+IntToStr(Fr[FrameBar.Position-1].Head.StFrameSize);
  //VList.Strings[6]:=IntToHex(Fr[FrameBar.Position].Head.StUser);
  VList.Strings[7]:='Pos='+IntToHex(Fr[FrameBar.Position].Pos,8);
end;

procedure TForm1.Button4Click(Sender: TObject);
var B: String; DestP,SrcP:TSTRParam;
begin
  // Frames 15 - 90 (125)         100B074C

  SrcP.BeginPos:=0;
  SrcP.SectorSize:=$800;
  SrcP.HeaderOffset:=0;

  DestP.BeginPos:=$D2535AC;
  DestP.SectorSize:=$930;
  DestP.HeaderOffset:=$18;


  {DestP.BeginPos:=$2C;
  DestP.SectorSize:=$930;
  DestP.HeaderOffset:=$18;}
  B:=ReplaceFrames('HILL','SH1\STR\SH.STR',DestP,SrcP,8,125);
  DestP.BeginPos:=$100B074C;
  B:=ReplaceFrames('HILL','SH1\STR\SH.STR',DestP,SrcP,8,125);
end;

end.
  