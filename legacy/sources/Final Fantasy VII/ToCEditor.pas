unit ToCEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FF7_Image, FF7_Compression, ComCtrls, Menus, ActnList, ToolWin,
  StdCtrls, ImgList, FF7_Common, Grids, ValEdit;

type
  TToCForm = class(TForm)
    Tree: TTreeView;
    ToolBar1: TToolBar;
    ActionList1: TActionList;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    Button1: TButton;
    TocImages: TImageList;
    Button2: TButton;
    ValList: TValueListEditor;
    Button3: TButton;
    Button5: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure TreeExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure TreeCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ToCForm: TToCForm;
  MToc: TTocRec;

implementation

{$R *.dfm}

procedure TToCForm.Button1Click(Sender: TObject);
var Toc: TTocRec; n,ID: Integer; node: TTreeNode;
begin
  MToc.LoadFileListFromFile('_FF7\_LZ\ToC\FileList.txt');
  {For n:=0 To Toc.FileCount-1 do
  begin
    Tree.Items.AddFirst(Node,Toc.FileList[n].Name);
  end;}

  {LoadImageFiles('_FF7\TestImg\FileList.txt',F);
  CreateFileList(F);}
  //ShowMessage(Format('"%s"',[AdvGetPart('123 456_78',[' ','_'],2)]));
  //ShowMessage(IntToStr(PartCount('123 456_78',[' ','_'])));
  //ShowMessage(Format('"%s"',[RemS(#9'   abc!  ')]));
end;

procedure TToCForm.Button2Click(Sender: TObject);
begin
  MToc.LoadFileListFromFile('_FF7\_LZ\ToC\FileList.txt');
  MToc.FillTree(Tree);
  MToc.GetFileSizes('_FF7\TestImg\');
end;

procedure TToCForm.TreeExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
begin
  Node.ImageIndex:=1;
end;

procedure TToCForm.TreeCollapsing(Sender: TObject; Node: TTreeNode;
  var AllowCollapse: Boolean);
begin
  Node.ImageIndex:=1;
end;

Procedure FillValList(F: TTocFile);
var S: String;
const ST: Array[TTocFileType] of String = ('None','Normal','Static');
SB: Array[Boolean] of String = ('False','True');
begin
  With TocForm.ValList do
  begin
    S:=F.Folder; If S<>'' Then S:=Format('%s\',[S]);
    Strings[0]:=Format('File=%s%s',[S,F.Name]);
    Strings[1]:=Format('LBA=%d',[F.LBA]);
    Strings[2]:=Format('Size=%d',[F.Size]);
    Strings[3]:=Format('RealSize=%d',[F.RSize]);
    Strings[4]:=Format('Key=%s',[SB[F.Key]]);
    Strings[5]:=Format('kCompressed=%s',[SB[F.kCompr]]);
    Strings[6]:=Format('Type=%s',[ST[F.fType]]);
  end;
end;

procedure TToCForm.TreeChange(Sender: TObject; Node: TTreeNode);
var n: Integer; Name,Folder: String;
begin
  With Node do
  begin
    If Parent<>NIL Then
    begin
      Folder:=Parent.Text;
      Name:=Text;
    end else
    begin
      Folder:='';
      Name:=Text;
    end;
    n:=MToc.GetFileIndex(Folder,Name);
    If n<0 Then Exit;
    FillValList(MToc.FileList[n]);
  end;
end;

procedure TToCForm.Button3Click(Sender: TObject);
begin
  ShowMessage(Format('%.8x',[18]));
end;

procedure TToCForm.Button5Click(Sender: TObject);
begin
  MToc.LoadScriptFromFile('_FF7\_LZ\ToC\LBAScript.txt');
end;

procedure TToCForm.Button4Click(Sender: TObject);
begin
  MToc.LoadKeyFiles('_FF7\TestImg\'); 
end;

Initialization
  MToC:=TTocRec.Create;
Finalization
  MToC.Free;
end.
