unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ActnList, SH5_Compression, SH5_PAK, StdCtrls, ComCtrls, PakArc,
  XPMan, SH5_Common, ImgList, VirtualTrees, SH5_SYT, DIB, SytViewer, ShellApi;

type

  TTrayType = (ttNone, ttShow, ttHide, ttModify);
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    ActionList1: TActionList;
    File1: TMenuItem;
    Exit1: TMenuItem;
    ools1: TMenuItem;
    ePakArcAction: TAction;
    PakArc1: TMenuItem;
    XPManifest1: TXPManifest;
    ImageList1: TImageList;
    eAbout: TAction;
    Help1: TMenuItem;
    About1: TMenuItem;
    Button4: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button5: TButton;
    eSYTShow: TAction;
    eFontShow: TAction;
    eStrShow: TAction;
    SYTEditor1: TMenuItem;
    FontEditor1: TMenuItem;
    STREditor1: TMenuItem;
    PopupMenuTray: TPopupMenu;
    Show1: TMenuItem;
    N1: TMenuItem;
    eExit: TAction;
    Exit2: TMenuItem;
    eShow: TAction;
    PAKArchiver1: TMenuItem;
    N2: TMenuItem;
    SYTEditor2: TMenuItem;
    FontEditor2: TMenuItem;
    STREditor2: TMenuItem;
    procedure ePakArcActionExecute(Sender: TObject);
    procedure eAboutExecute(Sender: TObject);
    procedure TreeGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure Button4Click(Sender: TObject);
    procedure eSYTShowExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure eExitExecute(Sender: TObject);
    procedure eShowExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    Procedure Tray(T: TTrayType);
  protected
    Procedure ControlWindow(Var Msg:TMessage); message WM_SYSCOMMAND;
    Procedure IconMouse(var Msg : TMessage); message WM_USER+1; 
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}



procedure TMainForm.ePakArcActionExecute(Sender: TObject);
begin
  PakForm.Show;
end;

procedure TMainForm.eAboutExecute(Sender: TObject);
var S,Sp: String; n: Integer;
begin
  Sp:=#9#9#9;
  S:='Silent Hill 5 Translation Tools by Horror <horror.cg@gmail.com>'+
  #13#10'http://consolgames.ru/'#13#10;
  For n:=0 To High(cThankYou) do With cThankYou[n] do
    S:=Format('%s'#13#10'%.32s%s',[S,Name+Sp,Help]);
  MessageDlg(S,mtInformation,[mbOK],0);
end;

procedure TMainForm.TreeGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
begin
  ImageIndex := 0;
end;

procedure TMainForm.TreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
begin
  Case Column of
    0: CellText:='test';
    1: CellText:='test1';
  end;
end;

Type T24bppColor = Array[0..2] of Byte;
Procedure GetRect(Pic: TDIB; Color: T24bppColor; X,Y,W,H: Integer; var LX,RX: Integer);
var n,m: Integer;
Label brk;
begin
  For n:=X To X+W-1 do
  begin
    For m:=Y to Y+H-1 do
    begin
      If not CompareMem(Pointer(DWord(Pic.ScanLine[m])+n*3),@Color,3) Then
      begin
        LX := n;
        Goto brk;
      end;
    end;
  end;
  brk:
  For n:=X+W-1 DownTo X do
  begin
    For m:=Y to Y+H-1 do
    begin
      If not CompareMem(Pointer(DWord(Pic.ScanLine[m])+n*3),@Color,3) Then
      begin
        RX := n;
        Exit;
      end;
    end;
  end;
end;

procedure TMainForm.Button4Click(Sender: TObject);
var DIB: TDIB; m,n,LX,RX: Integer; Color: T24bppColor; List: TStringList;
begin
  DIB := TDIB.Create;
  List:=TStringList.Create;
  DIB.LoadFromFile('D:\shv_fontcento03 copy.bmp');
  Color:=T24bppColor(DIB.ScanLine[0]^);
  For m:=0 to 3 do
  begin
    For n:=0 To 15 do
    begin
      GetRect(DIB,Color,n*28,180+m*36,28,36,LX,RX);
      List.Add(Format(
      #9'<TNextGenCharacter Character="%d" LeftCord="%d" RightCord="%d" TopCord="%d" BottomCord="%d"/>',
      [$C0+m*16+n,LX,RX,180+m*36,180+m*36+36]));
    end;
  end;
  List.SaveToFile('C:\List.txt');
  DIB.Free;
  List.Free;
end;

procedure TMainForm.eSYTShowExecute(Sender: TObject);
begin
  SytForm.Show;
end;

Procedure TMainForm.Tray(T: TTrayType);
Var Nim:TNotifyIconData; Icon: TIcon;
begin
  With Nim do
	Begin
		cbSize:=SizeOf(Nim);
	  Wnd:=MainForm.Handle;
	  uID:=1;
	  uFlags:=NIF_ICON or NIF_MESSAGE or NIF_TIP;
	  hicon:=Application.Icon.Handle;
	  uCallbackMessage:=wm_user+1;
	  szTip:='Silent Hill: Homecoming Translation Tools';
  End;
  Case Integer(T) of
		1: Shell_NotifyIcon(Nim_Add,@Nim);
	  2: Shell_NotifyIcon(Nim_Delete,@Nim);
	  3: Shell_NotifyIcon(Nim_Modify,@Nim);
  End;
end;

Procedure TMainForm.ControlWindow(Var Msg:TMessage);
Begin
  IF Msg.WParam=SC_MINIMIZE then
  Begin
    //Tray(ttShow); // Добавляем значок в трей
    ShowWindow(Handle,SW_HIDE); // Скрываем программу
  End
  else
    inherited;
End;

procedure TMainForm.IconMouse(var Msg:TMessage);
Var p:tpoint;
begin
  GetCursorPos(p); // Запоминаем координаты курсора мыши
	Case Msg.LParam OF // Проверяем какая кнопка была нажата
	  WM_LBUTTONUP,WM_LBUTTONDBLCLK:
	  Begin
	    //Tray(ttHide); // Удаляем зна?ок из трея
	    ShowWindow(Handle,SW_SHOWNORMAL); // Восстанавливаем окно программы
      MainForm.Show;
	  End;
	  WM_RBUTTONUP: {Действия, выполняемый по одинарному щел?ку правой кнопки мыши}
    Begin
	    SetForegroundWindow(Handle); // Восстанавливаем программу в ка?естве переднего окна
	    PopupMenuTray.Popup(p.X,p.Y);
	    PostMessage(Handle,WM_NULL,0,0) // Обнуляем сообщение
  	end;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Tray(ttHide);
end;

procedure TMainForm.eExitExecute(Sender: TObject);
begin
  Tray(ttHide);
  Close;
end;

procedure TMainForm.eShowExecute(Sender: TObject);
begin
	ShowWindow(Handle,SW_SHOWNORMAL);
  MainForm.Show;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
 SetWindowLong(Application.Handle, GWL_EXSTYLE, 
    GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
 Tray(ttShow);
end;

end.
