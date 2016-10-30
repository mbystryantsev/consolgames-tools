unit PakArc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ComCtrls, ActnList, Menus, StdActns, SH5_Pak, SH5_Common,
  ImgList, StdCtrls, SH5_Compression, AbCabMak, AbBase, AbBrowse, AbCBrows,
  AbCabExt, PFolderDialog, VirtualTrees, ExtCtrls;

type
  TPakForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Edit1: TMenuItem;
    FileListMenu: TPopupMenu;
    ActionList1: TActionList;
    Status: TStatusBar;
    Open1: TMenuItem;
    eOpen: TAction;
    OpenPAKDialog: TOpenDialog;
    eExtractFiles: TAction;
    Extract1: TMenuItem;
    Extract2: TMenuItem;
    ImageListPAKARC: TImageList;
    eReplaceFile: TAction;
    eReplaceFile1: TMenuItem;
    Replace1: TMenuItem;
    eSelectAll: TAction;
    N1: TMenuItem;
    SelectAll1: TMenuItem;
    N2: TMenuItem;
    SelectAll2: TMenuItem;
    eClose: TAction;
    eExit: TAction;
    Close1: TMenuItem;
    N3: TMenuItem;
    Exit1: TMenuItem;
    eExportToCab: TAction;
    Exporttocabinet1: TMenuItem;
    SaveCABDialog: TSaveDialog;
    AbCabExtractor: TAbCabExtractor;
    AbMakeCab: TAbMakeCab;
    SaveFileDialog: TSaveDialog;
    PFolderExtractDialog: TPFolderDialog;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    FileList: TVirtualStringTree;
    FolderList: TVirtualStringTree;
    Button1: TButton;
    Button2: TButton;
    eLoadAssets: TAction;
    OpenAssetsDialog: TOpenDialog;
    eLoadAssets1: TMenuItem;
    eLoadPaks: TAction;
    Close2: TMenuItem;
    PFolderPAK: TPFolderDialog;
    Options1: TMenuItem;
    oAllName: TAction;
    Searchinallname1: TMenuItem;
    Splitter1: TSplitter;
    oHideNExists: TAction;
    Hidenonexistentfiles1: TMenuItem;
    FolderListMenu: TPopupMenu;
    eExtractFolder: TAction;
    ExtractFolder1: TMenuItem;
    PEFolderDialog: TPFolderDialog;
    OpenFileDialog: TOpenDialog;
    procedure eOpenExecute(Sender: TObject);
    procedure eSelectAllExecute(Sender: TObject);
    procedure eExitExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure eCloseExecute(Sender: TObject);
    procedure eExtractFilesExecute(Sender: TObject);
    procedure eReplaceFileExecute(Sender: TObject);
    procedure eExportToCabExecute(Sender: TObject);
    procedure FileListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure FormCreate(Sender: TObject);
    procedure FileListFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure Button1Click(Sender: TObject);
    procedure FolderListGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure FileListGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure FolderListGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure FolderListFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure Button2Click(Sender: TObject);
    procedure eLoadAssetsExecute(Sender: TObject);
    procedure FileListHeaderDblClick(Sender: TVTHeader;
      Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure FileListHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure eLoadPaksExecute(Sender: TObject);
    procedure PFolderPAKInitialized(Sender: TObject);
    procedure FileListIncrementalSearch(Sender: TBaseVirtualTree;
      Node: PVirtualNode; const SearchText: WideString;
      var Result: Integer);
    procedure FileListDblClick(Sender: TObject);
    procedure oAllNameExecute(Sender: TObject);
    procedure FileListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FileListCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure eExtractFolderExecute(Sender: TObject);
  private
    { Private declarations }
  public
    Procedure DrawFiles(Pak: TPak; Sender: TObject);
    Procedure DrawFolders(A: TAssets);
    procedure CreateParams(var Params :TCreateParams); override;
    { Public declarations }
  end;

var
  PakForm: TPakForm;
  PAK: TPAK;
  Assets: TAssets;

implementation


{$R *.dfm}

uses
  SytViewer;

var ProgressBar: TProgressBar;


Procedure TPakForm.DrawFiles(Pak: TPak; Sender: TObject);
var n: Integer; Item: TListItem; Node: PVirtualNode;
const cCompBool: Array[0..2] of String = ('None','LZX:18','LZO');
begin
  Status.Panels.Items[0].Text := 'Loading...';
  Application.ProcessMessages;
  FileList.RootNodeCount := PAK.FileCount;
  Node := FileList.GetFirst;
  For n:=0 To FileList.RootNodeCount-1 do
  begin
    With TNodeData(FileList.GetNodeData(Node)^) do
    begin
      NodeType := ntFile;
      ID       := n;
      fiFile   := PAK.Files[n].Ptr;
      ExID     := PAK.Files[n].ExID;
      fiRoot   := Pak;
    end;
    Node := FileList.GetNext(Node); 
  end;
  FileList.FocusedNode := FileList.RootNode.FirstChild;
  FileList.Selected[FileList.RootNode.FirstChild] := True;
  
  {
  FileList.ItemIndex := 0;
  FileListClick(Sender);}
end;


procedure TPakForm.eOpenExecute(Sender: TObject);
begin
  If not OpenPAKDialog.Execute Then Exit;
  If not FileExists(OpenPAKDialog.FileName) Then Exit;
  PAK.Open(OpenPAKDialog.FileName);
  //Status.Panels.Items[0].Text := Format('%d Files',[Length(PAK.Files)]);
  Status.Panels.Items[0].Text := Format('%d Files',[PAK.FileCount]);

  FileList.Clear;
  Status.Panels.Items[1].Text := ExtractFileName(Pak.PakFileName);
  DrawFiles(PAK,Sender);
end;
                                                                          
procedure TPakForm.eSelectAllExecute(Sender: TObject);
begin
  //FileList.SelectAll;
  FileList.SelectAll(True); 
end;

procedure TPakForm.eExitExecute(Sender: TObject);
begin
  //eCloseExecute(Sender);
  PakForm.Close;
end;

procedure TPakForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  eCloseExecute(Sender);
end;

procedure TPakForm.eCloseExecute(Sender: TObject);
begin
  Pak.Close;
  FileList.Clear;
  Status.Panels.Items[0].Text:='';
  Status.Panels.Items[1].Text:='';
end;

procedure TPakForm.eExtractFilesExecute(Sender: TObject);
var n,Count,Sel: Integer; Folder,FileName: String; Node: PVirtualNode;
Data: ^TNodeData;
begin
  If FileList.SelectedCount<1 Then Exit;
  If FileList.SelectedCount=1 Then
  begin
    Data:=FileList.GetNodeData(FileList.FocusedNode);
    If Data^.NodeType <> ntFile Then Exit;
    n:=Data^.ID;
    If Assets.Loaded Then
      //FileName:=TPAK(Data^.RootData).GetFileName[n] + Assets.FileList[Data^.ExID].Header.Ex
      FileName:=Data^.fiRoot.Files[n].Name + Assets.FileList[Data^.ExID].Header.Ex
    else
      FileName:=Data^.fiRoot.Files[n].Name;
    SaveFileDialog.FileName:=FileName;
    If not SaveFileDialog.Execute Then Exit;
    Data^.fiRoot.ExtractFile(n,SaveFileDialog.FileName);
  end else
  begin
    Sel:=FileList.SelectedCount;
    Count:=0;
    If not PFolderExtractDialog.Execute Then Exit;
    Folder:=PFolderExtractDialog.FolderName;
    FileList.Enabled := False;
    Node:=FileList.GetFirst;
    With FileList do For n:=0 To FileList.RootNodeCount-1 do
    begin
      If FileList.Selected[Node] Then
      begin
        Data:=FileList.GetNodeData(FileList.FocusedNode);
        If Data^.NodeType <> ntFile Then Exit;
        Inc(Count);
        Status.Panels.Items[0].Text :=
        Format('Extracting: %d/%d (%d%%)',[Count,Sel,Round((Count/Sel)*100)]);
        Application.ProcessMessages;
        Try    
          If Assets.Loaded Then
            FileName:=Data^.fiRoot.Files[Data^.ID].Name + Assets.FileList[Data^.ExID].Header.Ex
          else
            FileName:=Data^.fiRoot.Files[Data^.ID].Name;
          //FileName:=TPAK(Data^.RootData).FileName[Data^.ID];
          Data^.fiRoot.ExtractFile(Data^.ID,Format('%s\%s',[Folder,FileName]));
        except
          ShowMessage(Format('Error! File ID: %d (Num: %d, Name: %s).',[Data^.ID,Count,FileName]));
          FileList.Enabled := True;
        end;
        If Count=Sel Then break;
      end;
      Node:=FileList.GetNext(Node); 
    end;
    FileList.Enabled := True;
  end;
  //FileListClick(Sender);
end;

procedure TPakForm.eReplaceFileExecute(Sender: TObject);
var Data: ^TNodeData;
begin
  Data := FileList.GetNodeData(FileList.FocusedNode);
  If Data^.NodeType <> ntFile Then Exit;
  If not OpenFileDialog.Execute Then Exit;
  Data^.fiRoot.ReplaceFile(Data^.ID,OpenFileDialog.FileName);
end;

procedure TPakForm.eExportToCabExecute(Sender: TObject);
var CAB: TCAB; var Buf: Pointer; Size,ID: Integer; S,Name: String;
begin
  ID:=FileList.FocusedNode.Index;
  If ID<0 Then Exit;
  Name:=PAK.Files[ID].Name;
  SaveCABDialog.FileName := Format('%s.cab',[PAK.Files[ID].Name]);
  If not SaveCABDialog.Execute Then Exit;
  CAB:=TCAB.Create;
  Size:=PAK.ExportFileToBuf(ID,Buf);
  CAB.ImportFromXCMBuf(Buf,Name,Size);
  CAB.SaveToFile(SaveCABDialog.FileName);
  CAB.Free;
end;

procedure TPakForm.FileListGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
const cCompBool: Array[0..2] of String = ('None','LZX:18','LZO');
var I: PInteger; n: INteger; Data: ^TNodeData;
begin
  Data := Sender.GetNodeData(Node);
  //I := FileList.GetNodeData(Node);
    Case Data^.NodeType of
      ntFile:
      begin
        n:=Data^.ID;
        Case Column of
            4:  CellText := IntToHex(Data^.ExID,4);
            5:  CellText := 'Yes';
            6:  If Data^.fiFile.pfPakID <> $FFFF Then
                  CellText := Format('%2.2d',[Data^.fiRoot.Files[n].PakID])
                else
                  CellText := 'rt';
            7:  CellText := IntToHex(Data^.fiRoot.Files[n].Offset,8);
            8:  CellText := ExtractFileName(Data^.fiRoot.PakFileName);
        end;
        If Assets.Loaded Then
        begin  
          Case Column of
            0:  CellText := Data^.fiFile.pfName + Assets.FileList[Data^.ExID].Header.Ex;
            1:  CellText := Assets.FileList[Data^.ExID].Header.Ex;
            2:  CellText := GetSize(Data^.fiRoot.Files[n].Size);
            3:  CellText := Assets.FileList[Data^.ExID].Header.Descr;
          end;
        end else
        begin
          Case Column of
            0:  CellText := Data^.fiFile^.pfName;
            1:  CellText := '?';//FileEx[n];
            2:  CellText := GetSize(Data^.fiRoot.Files[n].Size);
            3:  CellText := '?';
          end;
        end;
      end;
      ntFolder: CellText := Data^.foFolder^.Name;
      ntFileMaket:
      begin
        n:=Data^.ID;
        Case Column of
          0:  CellText := Assets.GetNameFromPos(Data^.fmList^.FileRecords[n].NamePos) + Data^.fmList^.Header.Ex;
          1:  CellText := Data^.fmList^.Header.Ex;
          2:  CellText := '?';
          3:  CellText := Data^.fmList^.Header.Descr;
          4:  CellText := IntToHex(Data^.ExID,4); //'?'; //TAssetsFileList(Data^.Data^)
          5:  CellText := 'No';
          6:  CellText := '--';
          7:  CellText := '';
          8:  CellText := '';
        end;
      end;
    end;
end;

procedure TPakForm.FormCreate(Sender: TObject);
begin
  FileList.NodeDataSize   := SizeOf(TNodeData);
  FolderList.NodeDataSize := SizeOf(TNodeData);
end;

procedure TPakForm.FileListFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var ID: Integer; Data: ^TNodeData;
begin
  Data := Sender.GetNodeData(Node);
  ID:=Sender.FocusedNode.Index;
  With FileList do Status.Panels.Items[0].Text :=
  Format('File %d/%d; Selected: %d',[ID+1,RootNodeCount,SelectedCount]);
  If ID<0 Then Exit;
  If Data^.NodeType = ntFile Then
  begin
    If Data^.fiRoot.Files[ID].Compressed=ctLZX Then eExportToCAB.Enabled := True
    else eExportToCAB.Enabled := False;
  end;
end;

Procedure TPakForm.DrawFolders;
var n: Integer; Nodes: Array of PVirtualNode; Data: ^TNodeData;
Node: PVirtualNode; FileCount: Integer;
begin
  FileCount:=0;
  FolderList.Clear;
  FolderList.RootNodeCount := Assets.PakCount;
  Node := FolderList.GetFirst;
  For n:=0 To Assets.PakCount -1 do
  begin
    With TNodeData(FolderList.GetNodeData(Node)^) do
    begin
      NodeType   := ntPak;
      pkPAK      := Assets.Paks[n];
      ID         := n;
      pkRoot     := Assets;
    end;
    Node := FolderList.GetNext(Node); 
  end;
  For n:=0 To A.FoldersCount-1 do
  begin
    Inc(FileCount, A.Folders[n].FileCount);
      If A.Folders[n].RootFolder = -1 Then
        Node:=FolderList.AddChild(FolderList.RootNode)
      else
        Node:=FolderList.AddChild(A.FolderData[A.Folders[n].RootFolder]);
      With TNodeData(FolderList.GetNodeData(Node)^) do
      begin
        NodeType := ntFolder;
        foFolder := A.FolderPointers[n];
        ID       := n;
      end;
      Assets.FolderData[n]:=Node;
  end;
end;

Procedure SetFilesProgr(S: String);
begin
  PakForm.Status.Panels.Items[0].Text
  := ExtractFileName(S);
  Application.ProcessMessages;
end;

procedure TPakForm.Button1Click(Sender: TObject);
begin
  Assets.LoadFromFile('Engine\assets_pc_b.xml');
  //Assets.LoadFromFile('assets_xenon_b.xml');
  Assets.LoadPaks('Engine\pak\pc');
  //Assets.SetFiles(@SetFilesProgr);
  DrawFolders(Assets);
end;

procedure TPakForm.FolderListGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var Data: ^TNodeData;
begin
  Data:=Sender.GetNodeData(Node);
  //{!}If (Data = nil) or (Data^.Data = nil) Then exit;
  Case Data^.NodeType of
    ntFolder: CellText := PChar(@(Data^.foFolder^.Name));
    ntPak:    CellText := ExtractFileName(Data^.pkPAK.PakFileName);
  end;
  //If Data^.Data<>nil Then CellText := PChar(@TAssetsFolder(Data^.Data^).Name);
end;

procedure TPakForm.FileListGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var Data: ^TNodeData;
begin
  If Column>0 Then Exit;
  Data:=Sender.GetNodeData(Node);
  Case Data^.NodeType of
    ntFile:      ImageIndex := 13;
    ntFileMaket: ImageIndex := 18;
    ntFolder:    ImageIndex := 14;
  end;
end;

procedure TPakForm.FolderListGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
begin
  Case TNodeData(Sender.GetNodeData(Node)^).NodeType of
    ntFolder:
      If Sender.Expanded[Node] Then ImageIndex := 15
      else ImageIndex := 14;
    ntPaK: ImageIndex := 17;
  end;
end;

procedure TPakForm.FolderListFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var m,n: Integer; Data, AddData: ^TNodeData; AddNode: PVirtualNode;
begin
  FileList.Clear;
  Data    := Sender.GetNodeData(Node);
  Case Data^.NodeType of
    ntPAK:    DrawFiles(Data^.pkPAK, nil);
    ntFolder:
    begin
      Assets.SetFolder(Data^.ID);
      For m:=0 To High(Assets.FileList) do
      begin
        For n:=0 To High(Assets.FileList[m].FileRecords) do
        begin
          If Assets.FileList[m].FileRecords[n].Folder <> Data^.ID Then Continue;
          If oHideNExists.Checked and (Assets.FileLink[m,n].PakID = -1) Then Continue;
          AddNode := FileList.AddChild(FileList.RootNode);
          AddData := FileList.GetNodeData(AddNode);
          //ShowMessage(Format('New: ExID: %d; Num: %d',[m,n]));
          With AddData^ do
          begin
            If Assets.FileLink[m,n].PakID <> -1 Then
            begin
              NodeType := ntFile;
              ID       := Assets.FileLink[m,n].Num;
              fiRoot   := Assets.Paks[Assets.FileLink[m,n].PakID];
              fiFile   := Assets.Paks[Assets.FileLink[m,n].PakID].Files[ID].Ptr;
              ExID     := m;
            end else
            begin
              NodeType := ntFileMaket;
              ID       := n;
              fmList   := @Assets.FileList[m];
              fmRoot   := @Assets;
              ExID     := m;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TPakForm.Button2Click(Sender: TObject);
var List: TStringList;
n: Integer;
begin
  CreateError('TPakForm.Button2Click: o_O');
  Exit;
  ShowMessage(IntToStr(SizeOf(SmallInt)));
  List:=TStringList.Create;
  PAK.Open('Engine\pak\pc\M01_NIGHTMARE.PAK');
  List.Add(Format('%40s %8.8s %8.8s %8.8s %8.8s %4.4s-%4.4s %8.8s',
    ['Name','Flags','CSize','Offset','PSize','P_ID',
    'ExID','Size']));
  For n:=0 To PAK.FileCount-1 do With PAK.Files[n].Ptr^ do
    List.Add(Format('%40s %.8x %.8x %.8x %.8x %.4x-%.4x %.8x',
    [pfName,pfFlags,pfCSize,pfOffset,pfPSize,pfPakID,
    pfExID,pfSize]));
  List.SaveToFile('Test.txt'); 

end;

procedure TPakForm.eLoadAssetsExecute(Sender: TObject);
begin
  If not OpenAssetsDialog.Execute Then Exit;
  Assets.LoadFromFile(OpenAssetsDialog.FileName); 
end;

procedure TPakForm.FileListHeaderDblClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  //ShowMessage(IntToStr(Column));
end;

procedure TPakForm.FileListHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Button = mbLeft then
  begin
    // Меняем индекс сортирующей колонки на индекс колонки,
    // которая была нажата.
    Sender.SortColumn := Column;
    // Сортируем всё дерево относительно этой колонки
    // и изменяем порядок сортировки на противополжный
    if Sender.SortDirection = sdAscending then
    begin
      Sender.SortDirection := sdDescending;
      FileList.SortTree(Column, Sender.SortDirection);
    end
    else begin
      Sender.SortDirection := sdAscending;
      FileList.SortTree(Column, Sender.SortDirection);
    end;
  end;
end;

procedure TPakForm.eLoadPaksExecute(Sender: TObject);
begin
  If not Assets.Loaded Then
  begin
    eLoadAssetsExecute(Sender);
    If not Assets.Loaded Then Exit;
  end;
  //PFolderPAK.SelectFolder(ExtractFilePath(Assets.FileName)); 
  If not PFolderPAK.Execute Then Exit;
  Assets.LoadPaks(PFolderPAK.FolderName);
  eCloseExecute(Sender);
  DrawFolders(Assets);
end;

procedure TPakForm.PFolderPAKInitialized(Sender: TObject);
begin
//  PFolderPAK.ExpandFolder(ExtractFilePath(Assets.FileName));
//  PFolderPAK.ExpandedFolder := ExtractFilePath(Assets.FileName);
  PFolderPAK.SelectFolder(ExtractFilePath(Assets.FileName));
end;

procedure TPakForm.CreateParams(var Params :TCreateParams); {override;}
begin
  inherited CreateParams(Params);
  with Params do
    Params.ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TPakForm.FileListIncrementalSearch(Sender: TBaseVirtualTree;
  Node: PVirtualNode; const SearchText: WideString; var Result: Integer);
var NNode: PVirtualNode; Res: Integer; Data: ^TNodeData;
begin
  Data := Sender.GetNodeData(Node);
  Case Data^.NodeType of
    ntFile:       Res := Pos(SearchText, Data^.fiFile.pfName);
    ntFileMaket:  Res := Pos(SearchText, Data^.fmRoot.GetNameFromPos(Data^.fmList.FileRecords[Data.ID].NamePos));   //Res := Pos(SearchText, Data^.fiFile.pfName);
  end;
  //If Res<=0 Then Exit;
  If (oAllName.Checked and (Res > 1)) or (Res = 1) Then
    Result := 0
  else
    Result := 1;
end;

procedure TPakForm.FileListDblClick(Sender: TObject);
var Data: ^TNodeData; Buf: Pointer; Size: Integer;
begin
  Data := FileList.GetNodeData(FileList.FocusedNode);
  If Data^.NodeType <> ntFile Then Exit;
  Case Data^.ExID of
    4:
    begin
      Size := Data^.fiRoot.ExtractFileToBuf(Data^.ID,Buf);
      If Size<=0 Then Exit;
      If not SytViewer.SYT.LoadFromBuf(Buf,Size) Then Exit;
      SytForm.ShowImage;
      SytForm.Show;
      FreeMem(Buf);
    end;
  end;
end;

procedure TPakForm.oAllNameExecute(Sender: TObject);
begin
  (Sender as TAction).Checked := not (Sender as TAction).Checked;
end;

procedure TPakForm.FileListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
   13: FileListDblClick(Sender);
  end;
end;

procedure TPakForm.FileListCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var Data1,Data2: ^TNodeData;
begin
  //TPAK(Data^.RootData).FileEx(Data^
  Data1 := Sender.GetNodeData(Node1);
  Data2 := Sender.GetNodeData(Node2);

  Result := 0;
  Case Column of
    0:      Result := CompareStr(Data1^.fiFile^.pfName,Data2^.fiFile^.pfName);
    1,3,4:  If Data1^.ExID > Data2^.ExID Then Result := 1 else
            If Data1^.ExID < Data2^.ExID Then Result := -1;
    2:
    begin
      If Data1^.NodeType <> Data2^.NodeType Then
      begin
        If Data1^.NodeType = ntFileMaket Then Result := -1 else Result := 1;
        Exit;
      end;
      If Data1^.NodeType = ntFileMaket Then Exit;
      If Data1^.fiRoot.Files[Data1^.ID].Size > Data2^.fiRoot.Files[Data2^.ID].Size Then
        Result := 1 else
      If Data1^.fiRoot.Files[Data1^.ID].Size < Data2^.fiRoot.Files[Data2^.ID].Size Then
        Result := -1;
    end;
  end;
end;

procedure TPakForm.eExtractFolderExecute(Sender: TObject);
begin
  If not PEFolderDialog.Execute Then Exit;
  Assets.ExtractFolder(
    TNodeData(FolderList.GetNodeData(FolderList.FocusedNode)^).ID,
    PEFolderDialog.FolderName)
end;

Initialization
  Pak:=TPak.Create;
  Assets:= TAssets.Create;
Finalization
  Pak.Free;
  Assets.Free;
end.
