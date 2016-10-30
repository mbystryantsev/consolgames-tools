unit RomHxr;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, ToolWin, XPMan, Menus, VirtualTrees, ActnList,
  Errors, HaxList, ValEdit, ActiveX;

type
  TMainForm = class(TForm)
    ActionList1: TActionList;
    Tree: TVirtualStringTree;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    OpenDialog: TOpenDialog;
    OpenFileDialog: TOpenDialog;
    XPManifest1: TXPManifest;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ImageList1: TImageList;
    aOpen: TAction;
    aSave: TAction;
    aSaveAs: TAction;
    aAdd: TAction;
    aChange: TAction;
    aRemove: TAction;
    PopupMenu1: TPopupMenu;
    aAdd1: TMenuItem;
    aChange1: TMenuItem;
    aRemove1: TMenuItem;
    Open1: TMenuItem;
    aSave1: TMenuItem;
    aSaveAs1: TMenuItem;
    aExit: TAction;
    Exit1: TMenuItem;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    aNew: TAction;
    aUp: TAction;
    aDown: TAction;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    Edit1: TMenuItem;
    Add1: TMenuItem;
    Change1: TMenuItem;
    Remove1: TMenuItem;
    N2: TMenuItem;
    MoveUp1: TMenuItem;
    MoveDown1: TMenuItem;
    aSelectFile: TAction;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    N3: TMenuItem;
    SaveDialog: TSaveDialog;
    aUpdateFile: TAction;
    aUpdateValues: TAction;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    N1: TMenuItem;
    aUpdateFile1: TMenuItem;
    aUpdateValues1: TMenuItem;
    oAllName: TAction;
    Options1: TMenuItem;
    oAllName1: TMenuItem;
    Help1: TMenuItem;
    aAbout: TAction;
    About1: TMenuItem;
    N4: TMenuItem;
    MoveUp2: TMenuItem;
    MoveDown2: TMenuItem;
    StatusBar: TStatusBar;
    SelectFile1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure aExitExecute(Sender: TObject);
    procedure aAddExecute(Sender: TObject);
    procedure aUpExecute(Sender: TObject);
    procedure aDownExecute(Sender: TObject);
    procedure aChangeExecute(Sender: TObject);
    procedure TreeDblClick(Sender: TObject);
    procedure aOpenExecute(Sender: TObject);
    procedure aSaveAsExecute(Sender: TObject);
    procedure aRemoveExecute(Sender: TObject);
    procedure aNewExecute(Sender: TObject);
    procedure aSelectFileExecute(Sender: TObject);
    procedure TreeDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure TreeDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure TreeDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure TreeFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure TreeIncrementalSearch(Sender: TBaseVirtualTree;
      Node: PVirtualNode; const SearchText: WideString;
      var Result: Integer);
    procedure oAllNameExecute(Sender: TObject);
    procedure aUpdateFileExecute(Sender: TObject);
    procedure TreeUpdating(Sender: TBaseVirtualTree;
      State: TVTUpdateState);
    procedure aUpdateValuesExecute(Sender: TObject);
    procedure TreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure aSaveExecute(Sender: TObject);
    procedure aAboutExecute(Sender: TObject);
  private
    FSaved: Boolean;
    FFileName: String;
    Procedure SetSaved(Value: Boolean);
  public
    Property  Saved: Boolean read FSaved write SetSaved;
    Procedure Draw;
    Procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    Function  CheckSaved: Boolean;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

var List: THaxList;



procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose := CheckSaved;
end;

function TMainForm.CheckSaved: Boolean;
begin
 Result := True;
 If not Saved then
 begin
  Case MessageDlg('Config has been modified. Save it?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
   mrYes:    aSaveExecute(NIL);
   mrCancel: Result := False;
  end;
 end;
end;

procedure TMainForm.Draw;
begin
  If List.Count <> Tree.RootNodeCount Then
    Tree.RootNodeCount := List.Count;
  List.UpdateValues;
  Tree.Refresh;
  StatusBar.Panels.Items[0].Text := List.FileName;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  List := THaxList.Create;
  List.SetCreateError(@CreateError); 
  TreeFocusChanged(nil,nil,0);
  TreeUpdating(Tree, usBegin); 
  FSaved := True;
end;

procedure TMainForm.TreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
begin
  With List.Items[Node.Index] do Case Column of
    0: CellText := Name;
    1: CellText := Format('%.8x',[Offset]);
    2: Case ValStat of
         vsInvalidOffset: CellText := 'Invalid Offset';
         vsUnknown:       CellText := '?';
         vsOK:            CellText := Format('%.*x',[cTypeLen[ValType]*2,Source]);
       end;
    3: CellText := Format('%.*x',[cTypeLen[ValType]*2,Value]);
    4: CellText := cTypes[ValType];
    5: CellText := cEndian[BigEndian];
  end;
end;

procedure TMainForm.aExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.aAddExecute(Sender: TObject);
var Value: THaxValue;
begin
  FillChar(Value, SizeOf(THaxValue), 0);
  Value.BigEndian := True;
  If ValForm.EditValDialog(Value, vtDWord, Format('Item%d',[Tree.RootNodeCount + 1])) Then
  begin
    List.Add(Value);
    Draw;
    Tree.FocusedNode := Tree.GetLast;
    Tree.Selected[Tree.FocusedNode] := True;
    Saved := False;
  end;
end;

procedure TMainForm.aUpExecute(Sender: TObject);
begin
  If Tree.FocusedNode.Index = 0 Then Exit;
  List.Change(Tree.FocusedNode.Index, Tree.FocusedNode.Index - 1);
  Draw;
  Tree.FocusedNode := Tree.FocusedNode.PrevSibling;
  Tree.Selected[Tree.FocusedNode] := True;
  Saved := False;
end;

procedure TMainForm.aDownExecute(Sender: TObject);
begin
  If Tree.FocusedNode.Index = Tree.RootNodeCount - 1 Then Exit;
  List.Change(Tree.FocusedNode.Index, Tree.FocusedNode.Index + 1);
  Draw;
  Tree.FocusedNode := Tree.FocusedNode.NextSibling;
  Tree.Selected[Tree.FocusedNode] := True;
  Saved := False;
end;

procedure TMainForm.aChangeExecute(Sender: TObject);
begin
  If Tree.FocusedNode = nil Then Exit;
  If ValForm.EditValDialog(List.Items[Tree.FocusedNode.Index],List.Items[Tree.FocusedNode.Index].ValType,List.Items[Tree.FocusedNode.Index].Name) Then
  begin
    Draw;
    Saved := False;
  end;

end;

procedure TMainForm.TreeDblClick(Sender: TObject);
begin
  aChangeExecute(nil);
end;

procedure TMainForm.aOpenExecute(Sender: TObject);
var n,I: Integer; Node: PVirtualNode;
begin
  If not CheckSaved then Exit;
  If not OpenDialog.Execute Then Exit;
  I := List.LoadFromFile(OpenDialog.FileName);
  FFileName := OpenDialog.FileName;
  Saved := True;
  Draw;
  If (I>List.Count - 1) or (I<0) Then I := 0;
  Node := Tree.GetFirst;
  For n := 1 To I do Node := Node.NextSibling;
  Tree.Selected[Node] := True;
  Tree.FocusedNode := Node;
end;

procedure TMainForm.aSaveAsExecute(Sender: TObject);
begin
  If FFileName = '' Then SaveDialog.FileName := 'Config.cfg';
  If not SaveDialog.Execute Then Exit;
  FFileName := ChangeFileExt(SaveDialog.FileName, '.cfg');
  aSaveExecute(Sender);
end;

procedure TMainForm.aRemoveExecute(Sender: TObject);
var ID: Integer;
begin
  If Tree.FocusedNode = nil Then Exit;
  ID := Tree.FocusedNode.Index;
  If MessageDlg(Format('Remove ''%s''?',[List.Items[ID].Name]), mtConfirmation,
    [mbYes, mbNo],0) = 6 Then
    begin
      List.Remove(ID);
      {Tree.FocusedNode := Tree.GetLast;
      Tree.Selected[Tree.FocusedNode] := True;}
    end;
  Draw;
  Saved := False;
end;

procedure TMainForm.aNewExecute(Sender: TObject);
begin
  If not CheckSaved then Exit;
  List.Clear;
  FFileName := '';
  List.FileName := '';
  Saved := True;
  Draw;
end;

procedure TMainForm.aSelectFileExecute(Sender: TObject);
begin
  If not OpenFileDialog.Execute Then Exit;
  If FileExists(OpenFileDialog.FileName) Then
    List.SelectFile(OpenFileDialog.FileName)
  else
    MessageDlg('File not found!', mtError, [mbOK], 0);
  TreeUpdating(Tree, usBegin);
  List.UpdateValues;
  Saved := False;
  StatusBar.Panels.Items[0].Text := List.FileName;
end;

procedure TMainForm.TreeDragAllowed(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := True;
end;

procedure TMainForm.TreeDragOver(Sender: TBaseVirtualTree; Source: TObject;
  Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
  var Effect: Integer; var Accept: Boolean);
begin
  Accept := (Source is TVirtualStringTree) and (Source = Sender);
end;

procedure TMainForm.TreeDragDrop(Sender: TBaseVirtualTree; Source: TObject;
  DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
  Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var n: Integer; V: THaxValue; Attachmode: TVTNodeAttachMode; After: Boolean;
ID1,ID2: Integer;
begin
  If Sender.DropTargetNode = nil Then Exit;
  ID1 := Sender.FocusedNode.Index;
  ID2 := Sender.DropTargetNode.Index;
  V := List.Items[ID1];
  If ID2 > ID1 Then
  begin
    If Mode = dmAbove Then Dec(ID2);
    //If ID2>List.Count - 1 Then Dec(ID2);
    For n := ID1 To ID2 - 1 do
      List.Items[n] := List.Items[n+1];
  end else
  If ID2 < ID1 Then
  begin
    If Mode = dmBelow Then Inc(ID2);
    For n := ID1 downTo ID2 + 1 do
      List.Items[n] := List.Items[n-1];
  end;
  List.Items[ID2] := V;
  Draw;
end;

procedure TMainForm.TreeFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  aDown.Enabled   := (Node<>nil) and (Node.Index < List.Count - 1);
  aUp.Enabled     := (Node<>nil) and (Node.Index > 0);
  aRemove.Enabled := Node<>nil;
  aChange.Enabled := Node<>nil;
end;

procedure TMainForm.TreeIncrementalSearch(Sender: TBaseVirtualTree;
  Node: PVirtualNode; const SearchText: WideString; var Result: Integer);
var Res: Integer;
begin
  Res := Pos(SearchText, List.Items[Node.Index].Name);
  If (oAllName.Checked and (Res > 1)) or (Res = 1) Then
    Result := 0
  else
    Result := 1;
end;

procedure TMainForm.oAllNameExecute(Sender: TObject);
begin
  (Sender as TAction).Checked := not (Sender as TAction).Checked;
end;

procedure TMainForm.aUpdateFileExecute(Sender: TObject);
begin
  List.UpdateFile;
  List.UpdateValues;
  Draw;
end;

procedure TMainForm.TreeUpdating(Sender: TBaseVirtualTree;
  State: TVTUpdateState);
begin
  aUpdateFile.Enabled   := (Tree.RootNodeCount > 0) and (List.FileName <> '');
  aUpdateValues.Enabled := (Tree.RootNodeCount > 0) and (List.FileName <> '');
end;

procedure TMainForm.aUpdateValuesExecute(Sender: TObject);
begin
  List.UpdateValues;
  Tree.Refresh;
  TreeUpdating(Tree, usBegin);
end;

procedure TMainForm.TreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = 13 Then TreeDblClick(Sender);
end;

procedure TMainForm.aSaveExecute(Sender: TObject);
begin
  If FFileName = '' Then
  begin
    aSaveAsExecute(Sender);
    Exit;
  end;
  List.SaveToFile(FFileName, Tree.FocusedNode.Index);
  Saved := True; 
end;

procedure TMainForm.SetSaved(Value: Boolean);
const
  cName = 'Rom Haxxor';
  cStar: Array[Boolean] of String = ('[*]','');
begin
  FSaved := Value;
  MainForm.Caption := Format('%s %s %s',[cName, cStar[FSaved],
  ExtractFileName(FFileName)]);
end;

procedure TMainForm.aAboutExecute(Sender: TObject);
begin
  ShowMessage('Rom Haxxor by HoRRoR <horror.cg@gmail.com>'#13#10'http://consolgames.ru/');
end;

end.
