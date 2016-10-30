unit FF_TextEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TntStdCtrls, ComCtrls, TntComCtrls, VirtualTrees, Errors,
  ExtCtrls, XPMan, Menus, ToolWin, SynEdit, SynMemo, SynEditHighlighter,
  FFHighlighter, {SynHighlighterGeneral,} ImgList, ActnList, TableText, ItemProporties;

type

  TSearchOptions = Record
    soFirstNode:       PVirtualNode;
    soLastNode:        PVirtualNode;
    soIndex:           Integer;
    soPosition:        Integer;
    soOnlyCurItem:     Boolean;
    soMatchCase:       Boolean;
    soFindInHidden:    Boolean;
    soFindInInstances: Boolean;
    soWholeWords:      Boolean;
    soWrapAround:      Boolean;
    soExtended:        Boolean;
    soDirectionDown:   Boolean;
    soInOriginal:      Boolean;
    soBeginEnd:        Boolean;
    soFind:            Boolean;
  end;


  TMainForm = class(TForm)
    TntTabControl1: TTntTabControl;
    Panel1: TPanel;
    ItemsTree: TVirtualStringTree;
    StringsTree: TVirtualStringTree;
    Splitter1: TSplitter;
    XPManifest: TXPManifest;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    Panel2: TPanel;
    Splitter2: TSplitter;
    Label1: TLabel;
    Splitter3: TSplitter;
    StatusBar: TStatusBar;
    ImageList: TImageList;
    ActionList: TActionList;
    AFileSaveAs: TAction;
    AFileOpen1: TMenuItem;
    MemoChanged: TSynMemo;
    MemoOriginal: TSynMemo;
    OpenDialog: TOpenDialog;
    AItemsCut: TAction;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    AFileSave: TAction;
    ToolButton5: TToolButton;
    AFileNew: TAction;
    ToolButton6: TToolButton;
    AFileOpen: TAction;
    Save1: TMenuItem;
    Save2: TMenuItem;
    SaveAs1: TMenuItem;
    N1: TMenuItem;
    AFileExit: TAction;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    AItemsCut1: TMenuItem;
    AItemsUnlink: TAction;
    AItemsUnlink1: TMenuItem;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    AGoToParent: TAction;
    GoToParent1: TMenuItem;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    AItemsShowHidden: TAction;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    View1: TMenuItem;
    Hidehidden1: TMenuItem;
    Help1: TMenuItem;
    AAbout: TAction;
    About1: TMenuItem;
    ARemove: TAction;
    RemoveItem1: TMenuItem;
    SaveDialog: TSaveDialog;
    AOptimize: TAction;
    Optimize1: TMenuItem;
    AFind: TAction;
    AFindNext: TAction;
    N2: TMenuItem;
    AFind1: TMenuItem;
    AFindNext1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure AItemsCutExecute(Sender: TObject);
    procedure ItemsTreeGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure ItemsTreeGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure StringsTreeGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure AFileOpenExecute(Sender: TObject);
    procedure StringsTreeGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure StringsTreeFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure ItemsTreeFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure AFileSaveExecute(Sender: TObject);
    procedure MemoChangedChange(Sender: TObject);
    procedure AItemsUnlinkExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ItemsTreeDblClick(Sender: TObject);
    procedure AItemsShowHiddenExecute(Sender: TObject);
    procedure ItemsTreeGetHint(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex;
      var LineBreakStyle: TVTTooltipLineBreakStyle;
      var HintText: WideString);
    procedure ItemsTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AGoToParentExecute(Sender: TObject);
    procedure StringsTreeDblClick(Sender: TObject);
    procedure AAboutExecute(Sender: TObject);
    procedure ARemoveExecute(Sender: TObject);
    procedure AFileSaveAsExecute(Sender: TObject);
    procedure AOptimizeExecute(Sender: TObject);
    procedure AFindExecute(Sender: TObject);
    procedure AFindNextExecute(Sender: TObject);
  private
    { Private declarations }
  public
    //Procedure CreateError(const S: string; Level: TErrorType = etError);
    Procedure DrawItems;
    Procedure DrawStrings(SelIndex: Integer = -1);
    Procedure DrawString;
    Procedure DrawButtons;
    Function  Confirm(Text: String): Boolean;
    Function  FindText(Str: WideString; const Options: TSearchOptions;
                out Node: PVirtualNode; out Item: TGameText; out Index, SelPos: Integer): Boolean;
    Procedure SetSelection(Memo: TSynMemo; Pos, Len: Integer);
    Function  FindNode(Name: String): PVirtualNode;
  end;

  TStatus = (sNone, sProject, sText, sWindow, sViewer);
  TCurrent = Record
    Status: TStatus;
    Text:   TGameTextSet;
    Item:   TGameText;
    SelStr: Integer;
    SelItem:Integer;
    OpenedFile: String;
    HideHidden: Boolean;
    SearchString: WideString;
    SearchOptions: TSearchOptions;
  end;
  TNodeType = (ntNone, ntItem, ntString);
  TNodeData = Packed Record
    NodeType: TNodeType;
    Index:    Integer;
    Case TNodeType of
      ntNone:   (PData: Pointer);
      ntItem:   (RData: TGameTextSet);
      ntString: (IData: TGameText);
  end;
var
  MainForm: TMainForm;
  Current:  TCurrent;
  MText:    TGameTextSet;
  FFileName: String;

implementation

uses StringProperties, TextSearch;

{$R *.dfm}

Procedure CreateError(const S: string; Level: TErrorType = etError);
const cErrorStrings: Array[TErrorType] of String = ('','[Hint] ','[Warning] ','[Error] ');
begin
  ErrorForm.AddString(cErrorStrings[Level] + S, {Level = etError} True) 
end;

procedure TMainForm.FormCreate(Sender: TObject);
var HL: TSynFFSyn;
begin
//  HL := TSynFFSyn.Create(Self);
//  HL.AddWord('Ramza');
//  HL.AddWord('Ðאלחא');
  //HL.AddWord('Lucca');

//  MemoOriginal.Highlighter := HL;
//  MemoChanged.Highlighter  := HL;
  //MemoOriginal.Text := HL.SampleSource;
  //MemoOriginal.ClearAll;
  //SynEdit1.Text := HL.SampleSource;
  MemoOriginal.Clear;
  MemoChanged.Clear;
  Current.SelStr := -1;
  ItemsTree.NodeDataSize   := SizeOf(TNodeData);
  StringsTree.NodeDataSize := SizeOf(TNodeData);
  MText := TGameTextSet.Create(@CreateError);
//  MText.ErrorProcedure := ;
  DrawButtons;
end;

procedure TMainForm.AItemsCutExecute(Sender: TObject);
begin
  If Current.Item = nil Then Exit;
  If not Confirm('Remove strings after this?') Then Exit;
  Current.Item.Cut(Current.SelStr);
  Dec(Current.SelStr);
  DrawStrings;
  ItemsTree.Refresh;
end;

procedure TMainForm.ItemsTreeGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var Data: ^TNodeData;
begin
  If Column > 0 Then Exit;
  Data := Sender.GetNodeData(Node);
  Case Data^.IData.Hidden of
    True:  Case Data^.IData.Checked of
             True:  ImageIndex := 27;
             False: ImageIndex := 25;
           end;
    False: Case Data^.IData.Checked of
             True:  ImageIndex := 26;
             False: ImageIndex := 21;
           end;
  end;
end;

procedure TMainForm.ItemsTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var Data: ^TNodeData;
begin
  Data := Sender.GetNodeData(Node);
  Case Column of
    0: CellText := Data^.IData.Name;
    1: CellText := IntToStr(Data^.IData.Count);
    2: CellText := Data^.IData.Caption;
  end;

end;

procedure TMainForm.StringsTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString); 
var Data: ^TNodeData;
const cBoolStr: Array[Boolean] of WideString = ('No', 'Yes');
begin
  Data := Sender.GetNodeData(Node);
  Case Column of
    0: CellText := IntToStr(Data^.Index);
    1: CellText := Data^.IData.Strings[Data^.Index];
    2: CellText := Data^.IData.Name;
    3: CellText := cBoolStr[Data^.IData.Retry[Data^.Index]];
    4: CellText := IntToStr(Data^.IData.StrLength(Data^.Index));
  end;
end;

procedure TMainForm.AFileOpenExecute(Sender: TObject);
var Opt: Boolean;
begin
  Opt := False;
  With OpenDialog do
  begin
    If not Execute Then Exit;
    If FileExists(ChangeFileExt(FileName, '.idx')) Then
    begin
      MText.LoadOptimDataFromFile(ChangeFileExt(FileName, '.idx'));
      MText.LoadTextFromFile(FileName, True);
    end else
      MText.LoadTextFromFile(FileName);
    Current.OpenedFile := FileName;
  end;
  Current.Status := sText;
  Current.Text   := MText;
  Current.SelStr := -1;
  DrawItems;
  If MText.Count > 0 Then
  begin
    Current.Item   := MText.Items[0];
    ItemsTree.FocusedNode := ItemsTree.GetFirst;
    ItemsTree.Selected[ItemsTree.GetFirst] := True;
    If Current.Item.Count > 0 Then
      Current.SelStr := 0;
  end;   
  DrawStrings;
end;

procedure TMainForm.DrawItems;
var n: Integer; Sel, Node: PVirtualNode; Data: ^TNodeData;
begin
  Sel := nil;
  ItemsTree.Clear;
  ItemsTree.FocusedNode := nil;
  If Current.HideHidden Then
    ItemsTree.RootNodeCount := Current.Text.VisibleCount
  else
    ItemsTree.RootNodeCount := Current.Text.Count;
  Node := ItemsTree.GetFirst;
  For n := 0 To Current.Text.Count - 1 do
  begin
    If Current.HideHidden and Current.Text.Items[n].Hidden Then Continue;
    Data := ItemsTree.GetNodeData(Node);
    Data^.NodeType := ntItem;
    Data^.Index := n;
    Data^.RData := Current.Text;
    Data^.IData := Current.Text.Items[n];
    If n = Current.SelItem Then
      Sel := Node;            
    Node  := ItemsTree.GetNext(Node);
  end;
  If Sel <> nil Then
  begin
    ItemsTree.FocusedNode := Sel;
    ItemsTree.Selected[Sel] := True;
  end;
end;

procedure TMainForm.DrawStrings(SelIndex: Integer = -1);
var n: Integer; Node: PVirtualNode; Data: ^TNodeData;
begin
  StringsTree.Clear;
  StringsTree.FocusedNode := nil;
  If Current.Item = nil Then
    Exit;
  StringsTree.RootNodeCount := Current.Item.Count;
  Node := StringsTree.GetFirst;
  For n := 0 To Current.Item.Count - 1 do
  begin
    Data := StringsTree.GetNodeData(Node);
    Data^.NodeType := ntString;
    Data^.Index := n;
    Data^.RData := Current.Text;
    Data^.IData := Current.Item;
    Node  := StringsTree.GetNext(Node);
  end;
  If Current.Item.Count > 0 Then
  begin
    If (SelIndex < 0) or (SelIndex > Current.Item.Count) Then
      SelIndex := 0;
    Current.SelStr := SelIndex;
    DrawString;
  end;
  DrawButtons;
end;

procedure TMainForm.StringsTreeGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var Data: ^TNodeData;
begin
  If Column > 0 Then Exit;
  Data := Sender.GetNodeData(Node);
  Case Data^.IData.Retry[Data^.Index] of
    True:  ImageIndex := 18;
    False: ImageIndex := 14;
  end;
end;

procedure TMainForm.StringsTreeFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var Data: ^TNodeData;
begin
  Data := Sender.GetNodeData(Node);
  Current.Item   := Data^.IData;
  MemoChanged.Text := Data^.IData.Strings[Data^.Index];
  Current.SelStr := Data^.Index;
  DrawButtons;
end;

procedure TMainForm.ItemsTreeFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var Data: ^TNodeData;
begin
  Data := Sender.GetNodeData(Node);
  Current.Item := Data^.IData;
  Current.SelStr := -1;
  Current.SelItem := Data^.Index;
  DrawStrings;

  StatusBar.Panels.Items[0].Text :=
    Format('Item: %d/%d (%d/%d)',
    [ItemsTree.FocusedNode.Index + 1, ItemsTree.RootNodeCount, Data^.Index + 1, {PData^.RData.}MText.Count]);
end;

procedure TMainForm.AFileSaveExecute(Sender: TObject);
begin
  If Current.OpenedFile = '' Then Exit;
  MText.SaveTextToFile(Current.OpenedFile);
  If MText.Optimized Then
    MText.SaveOptimDataToFile(ChangeFileExt(Current.OpenedFile, '.idx'));
end;

procedure TMainForm.MemoChangedChange(Sender: TObject);
begin
  If Current.SelStr = -1 Then Exit;
  If Current.Item <> nil Then
    Current.Item.Strings[Current.SelStr] := MemoChanged.Text;
end;

function TMainForm.Confirm(Text: String): Boolean;
begin
  Result := MessageDlg(Text, mtConfirmation, [mbYes, mbNo], -1) = 6;
end;

procedure TMainForm.DrawButtons;
begin
  With Current do
  begin
    AItemsCut.Enabled := (Item <> nil) and (SelStr > -1);
    AItemsUnlink.Enabled := (Item <> nil) and (SelStr > -1) and (Item.Retry[SelStr]);
    AGoToParent.Enabled := (SelStr > -1) and Item.Retry[SelStr];
    If (Item <> nil) and (SelStr > -1) Then
      MemoChanged.ReadOnly := False
    else
    begin
      MemoChanged.Clear;
      MemoChanged.ReadOnly := True;
    end;
  end;
end;

procedure TMainForm.AItemsUnlinkExecute(Sender: TObject);
begin
  If (Current.Item = nil) or (Current.SelStr = -1) Then Exit;
  Current.Item.Unlink(Current.SelStr);
  DrawStrings;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If not (ssCtrl in Shift) Then Exit;
  If Current.Item = nil Then Exit;
  If ItemsTree.Focused or StringsTree.Focused Then Exit;
  Case Key of
    38: If Current.SelStr > 0 Then
        begin
          Dec(Current.SelStr);
          DrawString;
        end;
    40: If Current.SelStr < Current.Item.Count - 1 Then
        begin
          Inc(Current.SelStr);
          DrawString;
        end;
  end;

end;

procedure TMainForm.DrawString;
var n: Integer; Node: PVirtualNode;
begin
  If Current.SelStr = -1 Then Exit;
  If Current.Item = nil  Then Exit;
  Node := StringsTree.GetFirst;
  For n := 1 To Current.SelStr do
    Node := StringsTree.GetNext(Node);
  StringsTree.FocusedNode := Node;
  StringsTree.Selected[Node] := True;
end;

procedure TMainForm.ItemsTreeDblClick(Sender: TObject);
begin
  If Current.Item <> nil Then
    ItemPropForm.GetProps;
end;

procedure TMainForm.AItemsShowHiddenExecute(Sender: TObject);
begin
  Current.HideHidden := not Current.HideHidden;
  AItemsShowHidden.Checked := Current.HideHidden;
  If Current.Text <> nil Then DrawItems;
end;

procedure TMainForm.ItemsTreeGetHint(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex;
  var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: WideString);
var Data: ^TNodeData;
begin
  Data := Sender.GetNodeData(Node);
  HintText := Data^.IData.Caption; 
end;

procedure TMainForm.ItemsTreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    VK_RETURN: ItemsTreeDblClick(nil);
    VK_DELETE: ARemoveExecute(nil);
  end;
end;

procedure TMainForm.AGoToParentExecute(Sender: TObject);
var RetryIndex, Index: Integer; Node: PVirtualNode;
begin
  With Current do
  begin
    If (Item = nil) or (SelStr = -1) or not Item.Items[SelStr].Retry Then Exit;    
    Node := FindNode(Item.Items[SelStr].RName);
    Index := Text.FindItem(Item.Items[SelStr].RName);
    RetryIndex := Item.Items[SelStr].RID;
    If Index = -1 Then Exit;
    Item := Current.Text.Items[Index];
    If RetryIndex >= Item.Count Then Exit;
    SelStr := RetryIndex;
  end;
  ItemsTree.Selected[ItemsTree.FocusedNode] := False;
  ItemsTree.FocusedNode := Node;
  ItemsTree.Selected[Node] := True;
  DrawStrings(RetryIndex);
  //Current.Item
end;

procedure TMainForm.StringsTreeDblClick(Sender: TObject);
begin
  If (Current.Item <> nil) and (Current.SelStr > - 1) Then
    StrPropForm.GetProps;
  //AGoToParentExecute(nil);
end;

procedure TMainForm.AAboutExecute(Sender: TObject);
begin
  MessageDlg('Editor for HoRRoR''s text format.'+#13+#10+'http://consolgames.ru/'+#13+#10+'ho-rr-or@mail.ru', mtInformation, [mbOK], 0);
end;

procedure TMainForm.ARemoveExecute(Sender: TObject);
begin
  If Current.Item = nil Then Exit;
  If not Confirm('Remove item?') Then Exit;
  StringsTree.Clear;
  ItemsTree.Clear;
  Current.Text.RemoveItem(Current.Item);
  //Current.Item := nil;
  //Current.SelItem := -1;
  //Current.SelItem :=
  DrawItems;
end;

procedure TMainForm.AFileSaveAsExecute(Sender: TObject);
begin
  If Current.OpenedFile = '' Then Exit;
  SaveDialog.FileName := Current.OpenedFile;
  If not SaveDialog.Execute Then Exit;
  AFileSaveExecute(nil);
  Current.OpenedFile := SaveDialog.FileName;
end;

procedure TMainForm.AOptimizeExecute(Sender: TObject);
begin
  If MText.Optimized Then Exit;
  MText.OptimizeText(nil);
  DrawStrings(Current.SelStr);
end;

Function TMainForm.FindText(Str: WideString; const Options: TSearchOptions;
  out Node: PVirtualNode; out Item: TGameText;  out Index, SelPos: Integer): Boolean;
var Data: ^TNodeData; S: WideString; P, Len: Integer; Wrap, First: Boolean;
begin
  Wrap := True;
  First := True;
  Result := False;
  Node := Options.soFirstNode;
  Item := nil;
  Index := Options.soIndex;
  SelPos := 0;
  P := Options.soPosition;
  If P = 0 Then
  begin
    Dec(Index);
    First := False;
  end;
  If (Index = -1) and not Options.soOnlyCurItem Then
  begin
    Node := Node.PrevSibling;
    If Node <> nil Then
      Index := TNodeData(ItemsTree.GetNodeData(Node)^).IData.Count - 1;
  end;
  If not Options.soMatchCase Then
    CharLowerBuffW(Pointer(Str), Length(Str));
  While True{Node <> nil} do With Options do
  begin
    If Node <> nil Then
    begin
      //If (Node = nil) or (Node = LastNode) Then Exit;
      Data := ItemsTree.GetNodeData(Node);
      //If not soFindInHidden and Data^.IData.Hidden Then Continue;
      Item := Data^.IData;
      While (Index >= 0) and (Index < Item.Count) do
      begin
        If soFindInInstances or (not soFindInInstances and not Item.Retry[Index]) Then
        begin
          If soWrapAround and not Wrap Then
          begin
            If (soDirectionDown and (Node = soFirstNode.NextSibling)) or
               (soDirectionDown and (Node = soFirstNode) and (Index > soIndex)) or
               (not soDirectionDown and (Node = soLastNode.PrevSibling)) or
               (not soDirectionDown and (Node = soFirstNode) and (Index < soIndex)) Then
                  Exit
          end;

          S := Item.Strings[Index];
          If soExtended Then S := DeleteCarrets(S);
          Len := Length(S);
          If not First Then
          begin
            If soDirectionDown Then
              P := 1
            else
              P := Len;
          end;
          First := False;
          If not soMatchCase Then
            CharLowerBuffW(Pointer(S), Len);
          repeat
            If soDirectionDown Then
              P := WidePosEx(Str, S, P)
            else
              P := WidePosExRev(Str, S, P);
            If P = 0 Then break;
            If soWholeWords and not (((P = 1) or not IsCharAlphaNumericW(S[P-1]))
              and ((P + Length(Str) > Len) or not IsCharAlphaNumericW(S[P + Length(Str)]))) Then
                Continue;
            If soWrapAround and not Wrap and (Node = soFirstNode) and (Index = soIndex) Then
            begin
              If (soDirectionDown and (P >= soPosition))
                or (not soDirectionDown and (P <= soPosition)) Then
                  Exit;
            end;
            SelPos := P;
            Result := True;
            Exit;
          until P <> 0;
        end;
        If soDirectionDown Then
          Inc(Index)
        else
          Dec(Index);
      end;
      If soOnlyCurItem Then Break;
      If soDirectionDown Then
      begin
        Node := Node.NextSibling;
        Index := 0;
      end else
      begin
        Node := Node.PrevSibling;
        If Node <> nil Then
          Index := TNodeData(ItemsTree.GetNodeData(Node)^).IData.Count - 1;
      end;
    end;
    If (Node = nil) {or (Node = soLastNode)} and soWrapAround and Wrap Then
    begin
      Wrap := False;
      If soDirectionDown Then
      begin
        Node := soFirstNode.Parent.FirstChild;
        Index := 0;
      end else
      begin
        Node := soFirstNode.Parent.LastChild;
        Index := TNodeData(ItemsTree.GetNodeData(Node)^).IData.Count - 1;
      end;
    end;
    If Node = nil Then
      break;
  end;
end;

procedure TMainForm.SetSelection(Memo: TSynMemo; Pos, Len: Integer);
var S: WideString; StrCarrets, MemCarrets, n, P: Integer;
begin

  StrCarrets := 0;
  MemCarrets := 0;
  S := Memo.Text;
  n := 1;
  P := Pos;
  While P > 0 do
  begin
    If S[n] = #10 Then
    begin
      Inc(P);
      Inc(MemCarrets);
    end;
    Inc(n);
    Dec(P);
  end;
  Memo.SelStart  := Pos + MemCarrets - 1;
  Memo.SelLength := Len;
end;

procedure TMainForm.AFindExecute(Sender: TObject);
var Pressed: Boolean;
begin
  FindForm.FindText(Current.SearchString, Current.SearchOptions, Pressed);  
  If not Pressed Then Exit;
  Current.SearchOptions.soFind := True;
  AFindNextExecute(Sender);
end;

procedure TMainForm.AFindNextExecute(Sender: TObject);
var
  Node: PVirtualNode; Index, SelPos, SelLen: Integer; Item: TGameText;
begin
  If Current.SearchString = '' Then Exit;
  With Current, SearchOptions do
  begin
    soIndex := SelStr;
    soPosition := MemoChanged.SelStart;
    If soDirectionDown Then
      Inc(soPosition, MemoChanged.SelLength + 1);
    If soFind and soOnlyCurItem and soBeginEnd Then
    begin
      If soDirectionDown Then
        soIndex := 0
      else
        soIndex := TNodeData(ItemsTree.GetNodeData(ItemsTree.FocusedNode)^).IData.Count - 1;
    end;

    If soFind and soBeginEnd and not soOnlyCurItem Then
    begin
      Case soDirectionDown of
        True:
        begin
          soFirstNode := ItemsTree.GetFirst;
          //soLastNode  := ItemsTree.GetLast;
        end;
        False:
        begin
          //soLastNode   := ItemsTree.GetFirst;
          soFirstNode  := ItemsTree.GetLast;
        end;
      end;
    end else
    begin
      soFirstNode := ItemsTree.FocusedNode;
      Case soDirectionDown of
        True:   soLastNode := ItemsTree.GetLast;
        False:  soLastNode := ItemsTree.GetFirst;
      end;      
    end;
    soFind := False;
  end;
  If not FindText(Current.SearchString, Current.SearchOptions, Node, Item, Index, SelPos) Then
  begin
    MessageBox(0, 'Text not found!', 'Find', MB_ICONINFORMATION or MB_OK);
    Exit;
  end;
  Current.Item := Item;

  
  ItemsTree.Selected[ItemsTree.FocusedNode] := False;
  ItemsTree.FocusedNode := Node;
  ItemsTree.Selected[Node] := True;
  DrawStrings(Index);
  SetSelection(MemoChanged, SelPos, Length(Current.SearchString));
end;

function TMainForm.FindNode(Name: String): PVirtualNode;
begin
  Result := ItemsTree.GetFirst;
  While Result <> nil do
  begin
    If TNodeData(ItemsTree.GetNodeData(Result)^).IData.Name = Name Then
      Break;
    Result := Result.NextSibling;
  end;
end;

end.
