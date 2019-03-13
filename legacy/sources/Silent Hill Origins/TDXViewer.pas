unit TDXViewer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, DIB_classic, PSPRAW, ComCtrls, Menus,
  ToolWin, ExtDlgs, StrUtils, ActnList, PFolderDialog, PFolderDialogWCB;

type
  TForm1 = class(TForm)
    Img: TImage;
    List: TListBox;
    Status: TStatusBar;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Close1: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    About1: TMenuItem;
    CopytoBitmap1: TMenuItem;
    PastetoBitmap1: TMenuItem;
    OpenDialog1: TOpenDialog;
    OpenBitmap: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    ActionList: TActionList;
    LoadFileAction: TAction;
    CloseAction: TAction;
    N1: TMenuItem;
    ExitAction: TAction;
    CopyToBitmapAction: TAction;
    PasteFromBitmapAction: TAction;
    Options1: TMenuItem;
    ReplPal: TMenuItem;
    IBC: TMenuItem;
    ScanFile1: TMenuItem;
    ScanFileAction: TAction;
    OpenScanFile: TOpenDialog;
    PopupMenu1: TPopupMenu;
    CopytoBitmap2: TMenuItem;
    PastefromBitmap1: TMenuItem;
    eExtractAllFromDir: TAction;
    PFolderOpen: TPFolderDialog;
    PFolderSave: TPFolderDialog;
    eExtractAll: TAction;
    N2: TMenuItem;
    Close2: TMenuItem;
    N3: TMenuItem;
    Close3: TMenuItem;
    N4: TMenuItem;
    Extractallimages1: TMenuItem;
    eReplaceTextures: TAction;
    eCopyIfContainPic: TAction;
    eReplaceTextures1: TMenuItem;
    eCopyIfContainPic1: TMenuItem;
    eSavePal: TAction;
    SavePalDialog: TSaveDialog;
    Close4: TMenuItem;
    procedure OpenTXD(Sender: TObject;  OFile: String; Pos: Integer);
    procedure ListClick(Sender: TObject);
    Procedure LoadFileActionExecute(Sender: TObject);
    procedure CopyToBitmapActionExecute(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure CloseActionExecute(Sender: TObject);
    procedure ExitActionExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PasteFromBitmapActionExecute(Sender: TObject);
    procedure IBCClick(Sender: TObject);
    procedure ScanFileActionExecute(Sender: TObject);
    procedure eExtractAllExecute(Sender: TObject);
    procedure eExtractAllFromDirExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure eReplaceTexturesExecute(Sender: TObject);
    procedure eCopyIfContainPicExecute(Sender: TObject);
    procedure eSavePalExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public        
    procedure ExtractAllFromDir(Sender: TObject; InFolder, OutFolder: String);
    procedure ExtractAll(Folder: String; Replace: Boolean = True);
    procedure ScanFile(Sender: TObject; FileName: String);
    procedure CopyIfExists(const PicDir,InFolder,OutFolder: String; Sender: TObject = nil);
    procedure ReplacePics(const PicDir,OutFolder: String; Sender: TObject = nil);
  end;



  Type THead = Packed Record
    HeadSize: DWord;
    Size: DWord;
    Unknown1: DWord;
    Unknown2: DWord;
    FHead: Array of TFHead;
  end;

  Type TPHead = Packed Record
    HeadSize: DWord;
    Size: DWord;
    Unknown1: DWord;
    Unknown2: DWord;
    FHead: TFHead;
  end;



var
  Form1: TForm1;

implementation

{$R *.dfm}

var OpenedFile: String; Pic: Array of TDIB; Head: THead;
NotShow: Boolean = False;

Procedure TForm1.LoadFileActionExecute(Sender: TObject);
var n: Integer; F: File;
begin
  OpenDialog1.Filter:='TXD files (*.txd)|*.txd|All Files(*.*)|*';
  If OpenDialog1.Execute then
  begin
    If FileExists(OpenDialog1.FileName) then
    begin
      Img.Height:=0;
      Img.Width:=0;
      For n:=0 to High(Pic) do Pic[n].Free;
      Finalize(Head.FHead);
      Finalize(Pic);
      List.Clear;
      OpenedFile:=OpenDialog1.FileName;
      Status.Panels.Items[6].Text:=OpenDialog1.FileName;
      //AssignFile(F, OpenedFile);
      //Reset(F,1);
      OpenTXD(Sender,OpenedFile,0);
    end;
  end;
end;




procedure TForm1.OpenTXD(Sender: TObject;  OFile: String; Pos: Integer);
var  F: File; Buf: Pointer;// Pal: Array of DWord;
n: Integer;
begin
  AssignFile(F, OFile);
  Reset(F,1);
  Seek(F,Pos);
  BlockRead(F, Head, 16);

  Inc(Pos,16);
  //SetLength(Pal,16);
  n:=0;
  List.Clear;
  While (pos+208<Head.Size) {and (n<100)} do
  begin
    SetLength(Head.FHead,Length(Head.FHead)+1);
    If not NotShow Then
      SetLength(Pic,Length(Pic)+1);

    LoadTexture(F, Head.FHead[n], Pic[n], Pos, NotShow);
    If not NotShow Then
      List.Items.Add(Head.FHead[n].Name);
    Inc(n);
  end;
  List.ItemIndex:=0;
  ListClick(Sender);
  CloseFile(F);

end;



procedure TForm1.ListClick(Sender: TObject);
begin
  //Pic[List.ItemIndex].SaveToFile('D:\test.bmp');
  If NotShow Then Exit;
  Img.Picture.Graphic := Pic[List.ItemIndex];
  Img.Height:=Pic[List.ItemIndex].Height;
  Img.Width:=Pic[List.ItemIndex].Width;
  //Img.Canvas.Draw(0,0,Pic[List.ItemIndex]); 
  Status.Panels.Items[0].Text:='Width: '+IntToStr(Pic[List.ItemIndex].Width);
  Status.Panels.Items[1].Text:='Height: '+IntToStr(Pic[List.ItemIndex].Height);
  Status.Panels.Items[2].Text:='BitCount: '+IntToStr(Pic[List.ItemIndex].BitCount);
  Status.Panels.Items[3].Text:=IntToHex(Head.FHead[List.ItemIndex].Pos,8);
  Status.Panels.Items[4].Text:='Size: '+IntToStr(Head.FHead[List.ItemIndex].Size+12);
  Status.Panels.Items[5].Text:=Format('%d/%d',[List.ItemIndex+1,List.Items.Count]);
end;




procedure TForm1.CloseActionExecute(Sender: TObject);
var n: Integer;
begin
  For n:=0 to High(Pic) do Pic[n].Free;
  Finalize(Head.FHead);
  Finalize(Pic);
  List.Clear;
  Img.Picture:=nil;
  Status.Panels.Items[0].Text:='';
  Status.Panels.Items[1].Text:='';
  Status.Panels.Items[2].Text:='';
  Status.Panels.Items[3].Text:='';
  Status.Panels.Items[4].Text:='';
  Status.Panels.Items[5].Text:='';
  Status.Panels.Items[6].Text:='';
  OpenedFile:='';
end;









    {Head.FHead[n].Pos:=Pos;
    Seek(F, Pos); Inc(Pos,208);
    BlockRead(F, Head.FHead[n], 208);
    If Head.FHead[n].Bpp<=8 then
    begin
      Seek(F,Pos);
      Inc(Pos,(1 SHL Head.FHead[n].Bpp)*4);
      SetLength(Pal, 1 SHL Head.FHead[n].Bpp);
      BlockRead(F, Pal[0], (1 SHL Head.FHead[n].Bpp)*4);
    end;
    Seek(F, Pos);
    Pic[n]:=TDIB.Create;
    If Head.FHead[n].Bpp>8 then
    Pic[n].PixelFormat:=MakeDibPixelFormat(5, 6, 5);
    Pic[n].BitCount:=Head.FHead[n].Bpp;
    Pic[n].Width:=Head.FHead[n].Width;
    Pic[n].Height:=Head.FHead[n].Height;
    GetMem(Buf,(Head.FHead[n].Height * Head.FHead[n].Width * Head.FHead[n].Bpp) div 8);
    BlockRead(F, Buf^,(Head.FHead[n].Height * Head.FHead[n].Width * Head.FHead[n].Bpp) div 8);
    //If Head.FHead[n].Bpp>8 then Flip(Buf,Head.FHead[n].Height * Head.FHead[n].Width);
    RawToDib(Pic[n], Buf);
    If Head.FHead[n].Bpp<=8 then SetPallete(Pic[n], Pal);
    List.Items.Add(GetName(Head.FHead[n].Name));
    FreeMem(Buf);
    Inc(Pos,(Head.FHead[n].Height * Head.FHead[n].Width * Head.FHead[n].Bpp) div 8); }
procedure TForm1.CopyToBitmapActionExecute(Sender: TObject);
var S: String;
begin
  S:='.bmp';
  If (List.Items.Count>0) then
  SavePictureDialog1.FileName:=GetName(Head.FHead[List.ItemIndex].Name)+'.bmp';
  If (List.Items.Count>0) and SavePictureDialog1.Execute then
  begin
    Pic[List.ItemIndex].SaveToFile(ChangeFileExt(SavePictureDialog1.FileName, '.bmp'));
    //ShowMessage('”казанный путь не найден!');
  end;
end;

procedure TForm1.About1Click(Sender: TObject);
begin
  MessageDlg('Silent Hill Origins TXD Viewer v1.0 by HoRRoR <ho-rr-or@mail.ru>'#13#10+
  'http://consolgames.ru/',
  mtInformation,[mbOk],0);
end;



procedure TForm1.ExitActionExecute(Sender: TObject);
begin
  CloseActionExecute(Sender);
  Close;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseActionExecute(Sender);
end;


Procedure PasteFromBitmap(FileName: String; ID: Integer; IW, IH: Boolean; ReplPal: Boolean; IBC: Boolean = True);
var Buf: Pointer; Full, Bitmap, Temp: TDIB; F: File; sSize: Integer; Pal: Array of DWord;
Pos:Integer; Flag: Boolean; Tmp,n: Integer; DW: ^DWord; Bpp: Integer; bpp8to4: Boolean;
begin
      Bitmap:=TDIB.Create;
      Bitmap.LoadFromFile(FileName);
      bpp8to4:=False;
      With Pic[ID] do
      begin
        If BitCount>=24 Then Bpp:=16 else Bpp:=BitCount;
        If ((Bitmap.Width<>Width) and not IW) or ((Bitmap.Height<>Height) and not IH) then
        begin
          If Assigned(Bitmap) Then Bitmap.Free;
          MessageDlg('Bitmap Width or Height is not identical with the original image!',mtWarning,[mbOk],0);
          Exit;
        end else
        If IBC and (Bitmap.BitCount=8) and (bpp=4) then bpp8to4:=True else
        If not ((BitCount=32) and (Bitmap.BitCount=24)) and ((Bitmap.BitCount<>BitCount)) then
        begin
          If Assigned(Bitmap) Then Bitmap.Free;
          MessageDlg('Bitmap Bit Count is not identical with the original image!',mtWarning,[mbOk],0);
          Exit;
        end;
        If not (bpp in [4,8,16]) Then Exit;
        sSize:=RoundBy(Pic[ID].Width, 8*16 div Bpp)*
        RoundBy(Pic[ID].Height, 8) div 8 * Bpp;

        If ReplPal and (Pic[ID].BitCount<=8) then
        begin
          SetLength(Pal, 1 SHL Pic[ID].BitCount);
          For n:=0 to Length(Pal)-1 do
          begin
            Pal[n]:=DWord(Bitmap.ColorTable[n]);

          end;
        end;
      end;

      //If bpp8to4 Then sSize:=sSize*2;
      GetMem(Buf, sSize);

      AssignFile(F, OpenedFile);
      Reset(F,1);
      Pos:=Head.FHead[ID].Pos;
      If Bitmap.BitCount >=16 Then
      begin
        Seek(F, Pos+208);
        BlockRead(F, Buf^,sSize);
      end;
      DibToRaw(Bitmap, Buf, bpp8to4);
      If ReplPal and (Pic[ID].BitCount<=8) then
      begin
        Seek(F, Pos+208);
        BlockWrite(F, Pal[0], Length(Pal)*4);
      end;
      If Bitmap.BitCount >=16 Then
        Seek(F, Pos+208)
      else
        Seek(F, Pos+(1 SHL Head.FHead[ID].Bpp)*4+208);
      BlockWrite(F, Buf^, sSize);
      FreeMem(Buf);
      LoadTexture(F, Head.FHead[ID], Pic[ID],Pos, NotShow);
      CloseFile(F);

end;

procedure TForm1.PasteFromBitmapActionExecute(Sender: TObject);
begin
  If (List.ItemIndex>=0) and OpenBitmap.Execute then
  begin
    If FileExists(OpenBitmap.FileName) then
    begin
      PasteFromBitmap(OpenBitmap.FileName,List.ItemIndex,false,false,ReplPal.Checked);
      ListClick(Sender);
    end else
    begin
      MessageDlg('File not found!',mtWarning,[mbOk],0);
    end;
  end;
end;


procedure TForm1.IBCClick(Sender: TObject);
begin
  (Sender as TMenuItem).Checked:=not (Sender as TMenuItem).Checked;
end;

procedure TForm1.ScanFileActionExecute(Sender: TObject);
begin
  If OpenScanFile.Execute and FileExists(OpenScanFile.FileName) then
    ScanFile(Sender, OpenScanFile.FileName);
end;

procedure TForm1.ScanFile(Sender: TObject; FileName: String);
var F: File; Buf: Pointer; Head: ^TPHead; Size,n,Pos: Integer; B: ^Byte;
begin

    For n:=0 to High(Pic) do Pic[n].Free;
    Img.Height:=0;
    Img.Width:=0;
    //SetLength(Head.FHead,0);
    SetLength(Pic,0);
    If not NotShow Then
      List.Clear;

    n:=0;
    OpenedFile:=FileName;
    Status.Panels.Items[6].Text:=OpenedFile;
    AssignFile(F, OpenedFile);
    Reset(F,1);
    GetMem(Buf, FileSize(F));
    BlockRead(F, Buf^, FileSize(F));
    Size:=FileSize(F);
    CloseFile(F);
    Head:=Addr(Buf^);
    B:=Addr(Buf^);

    While n<Size-224 do
    begin
      If (Head^.HeadSize=$16) and (Head^.Unknown1=$1C020065) and (Head^.Unknown2=1) and
      (Head^.FHead.Unknown0[0]=4) and (Head^.FHead.Unknown0[1]=Head^.Unknown1) and
      (Head^.FHead.Unknown0[3]=$15) then
      begin
        OpenTXD(Sender, OpenedFile, n);
        Inc(n, Head^.Size+12);
        Inc(B, Head^.Size+12);
        Head:=Addr(B^);
      end else
      begin
        Inc(n);
        Inc(B);
        Head:=Addr(B^);
      end;
    end;
    FreeMem(Buf);
end;

procedure TForm1.ExtractAll(Folder: String; Replace: Boolean = True);
var n: Integer; FileName: String;
begin
  For n:=0 To List.Count-1 do
  begin
    FileName:=Format('%s\%s.bmp',[Folder,GetName(Head.FHead[n].Name)]);
    If not Replace and FileExists(FileName) Then Continue;
    Pic[n].SaveToFile(FileName);
  end;
end;

procedure TForm1.ExtractAllFromDir(Sender: TObject; InFolder, OutFolder: String);
var SR: TSearchRec; FileName: String; n: Integer;//FileCount: Integer;
begin
  If FindFirst(InFolder+'\*',  faAnyFile XOR faDirectory, SR) <> 0 then Exit;
  Repeat
    Status.Panels[6].Text := SR.Name;
    Application.ProcessMessages;
    For n:=0 to High(Pic) do Pic[n].Free;
    Finalize(Head.FHead);
    Finalize(Pic);
    FileName:=Format('%s\%s',[InFolder,SR.Name]);
    If RightStr(SR.Name,4)='.txd' Then OpenTXD(Sender,FileName,0)
    else ScanFile(Sender,FileName);
    ExtractAll(OutFolder,False);
  Until (FindNext(SR) <> 0); 
  CloseActionExecute(Sender);
  Status.Panels.Items[6].Text:='Done!';
end;

Procedure GetFileList(var List: TStringList; DirMask: String; Cut: Integer = 4);
var SR: TSearchRec;
begin
  If FindFirst(DirMask,  faAnyFile XOR faDirectory, SR) <> 0 then Exit;
  List:=TStringList.Create;
  Repeat
    If Cut>0 Then List.Add(LeftStr(SR.Name,Length(SR.Name)-Cut))
    else List.Add(SR.Name);
  Until (FindNext(SR) <> 0);
end;

procedure TForm1.CopyIfExists(const PicDir,InFolder,OutFolder: String; Sender: TObject = nil);
var PicList: TStringList; SR: TSearchRec; n,m: Integer; FileName: String;
Label brk;
begin
  GetFileList(PicList, PicDir+'\*.bmp', 4);
  If PicList.Count<=0 Then
  begin
    PicList.Free;
    Exit;
  end;
  If FindFirst(InFolder+'\*',  faAnyFile XOR faDirectory, SR) <> 0 then Exit;
  Repeat
    Status.Panels[6].Text := SR.Name;
    Application.ProcessMessages;
    For n:=0 to High(Pic) do Pic[n].Free;
    Finalize(Head.FHead);
    Finalize(Pic);
    FileName:=Format('%s\%s',[InFolder,SR.Name]);
    If RightStr(SR.Name,4)='.txd' Then OpenTXD(Sender,FileName,0)
    else ScanFile(Sender,FileName);
      //ShowMessage(Format('%d = %d?', [Length(Pic), Length(Head.FHead)]));
    For m:=0 To High(Head.FHead) do
    begin
      For n:=0 To PicList.Count-1 do
      begin
        If PicList[n]=Head.FHead[m].Name Then
        begin
          CopyFile(PChar(FileName),PChar(OutFolder+'\'+ExtractFileName(FileName)),False);
          GoTo brk;
        end;
      end;
brk:
    end;
  Until (FindNext(SR) <> 0);
  PicList.Free;         
  CloseActionExecute(Sender);
  Status.Panels.Items[6].Text:='Done!';
end;

procedure TForm1.ReplacePics(const PicDir,OutFolder: String; Sender: TObject = nil);
var PicList: TStringList; SR: TSearchRec; n,m: Integer; FileName: String;
begin
  GetFileList(PicList, PicDir+'\*.bmp', 4);
  If PicList.Count<=0 Then
  begin
    PicList.Free;
    Exit;
  end;
  If FindFirst(OutFolder+'\*',  faAnyFile XOR faDirectory, SR) <> 0 then Exit;
  Repeat
    Status.Panels[6].Text := SR.Name;
    Application.ProcessMessages;
    For n:=0 to High(Pic) do Pic[n].Free;
    Finalize(Head.FHead);
    Finalize(Pic);
    FileName:=Format('%s\%s',[OutFolder,SR.Name]);
    OpenedFile:=FileName;
    If RightStr(SR.Name,4)='.txd' Then OpenTXD(Sender,FileName,0)
    else ScanFile(Sender,FileName);
    For m:=0 To High(Head.FHead) do
    begin
      For n:=0 To PicList.Count-1 do
      begin
        If PicList[n]=Head.FHead[m].Name Then
        begin
          PasteFromBitmap(Format('%s\%s.bmp',[PicDir,PicList.Strings[n]]),m,false,false,false);
        end;
      end;
    end;
  Until (FindNext(SR) <> 0);
  PicList.Free;
  CloseActionExecute(Sender);
  Status.Panels.Items[6].Text:='Done!';
end;

procedure TForm1.eExtractAllExecute(Sender: TObject);
begin
  PFolderSave.Caption := 'Save Images...';
  If not PFolderSave.Execute Then Exit;
  ExtractAll(PFolderSave.FolderName,True);
end;

procedure TForm1.eExtractAllFromDirExecute(Sender: TObject);
begin
  PFolderSave.Caption := 'Save Images To Folder...';
  PFolderOpen.Caption := 'Select TXD Folder...';
  If not (PFolderOpen.Execute and PFolderSave.Execute) Then Exit;
  ExtractAllFromDir(Sender,PFolderOpen.FolderName,PFolderSave.FolderName);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  CopyIfExists('F:\_job\_SH\RUS\TEX','F:\_job\_SH\arc','F:\_job\_SH\RUS\TXD');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ReplacePics('F:\_job\_SH\RUS\TEX','F:\_job\_SH\RUS\TXD');
end;

procedure TForm1.eReplaceTexturesExecute(Sender: TObject);
begin
  PFolderOpen.Caption := 'Select Images Folder...';
  PFolderSave.Caption := 'Select TXD Folder...';
  If not (PFolderOpen.Execute and PFolderSave.Execute) Then Exit;
  ReplacePics(PFolderOpen.FolderName,PFolderSave.FolderName);
end;

procedure TForm1.eCopyIfContainPicExecute(Sender: TObject);
var PicDir: String;
begin
  PFolderOpen.Caption := 'Select Images Folder...';
  If not PFolderOpen.Execute Then Exit;
  PicDir:=PFolderOpen.FolderName;
  PFolderOpen.Caption := 'Select TXD Folder...';
  PFolderSave.Caption := 'Copy TXD To Folder...';
  If not (PFolderOpen.Execute and PFolderSave.Execute) Then Exit;
  CopyIfExists(PicDir,PFolderOpen.FolderName,PFolderSave.FolderName);
end;

procedure TForm1.eSavePalExecute(Sender: TObject);
var F: File; Size: Int64; Alpha: LongBool;
const Sign: Array[0..3] of Char = 'bap';
begin
  If Pic[List.ItemIndex].BitCount > 16 Then Exit;
  If not SavePalDialog.Execute Then Exit;
  AssignFile(F, SavePalDialog.FileName);
  Rewrite(F,1);
  BlockWrite(F, Sign, 4);
  Alpha := True;
  BlockWrite(F, Alpha, 4);
  If Pic[List.ItemIndex].BitCount = 4 Then
  begin
    Size := 16;
    BlockWrite(F, Size, 8);
    BlockWrite(F, Pic[List.ItemIndex].ColorTable[0], Size * 4);
  end else
  begin                                                        
    Size := 256;
    BlockWrite(F, Size, 8);
    BlockWrite(F, Pic[List.ItemIndex].ColorTable[0], Size * 4);
  end;
  CloseFile(F);

end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  
  If ParamCount < 3 Then Exit;
  If ParamStr(1) = '-ce' Then
  begin
  //             PicDir,      InFolder,    OutFolder
    NotShow := True;
    CopyIfExists(ParamStr(2), ParamStr(3), ParamStr(4));
    If ParamStr(5) <> '-dc' Then Close;
    NotShow := False;
  end else
  If ParamStr(1) = '-rt' Then
  begin
  //             PicDir,      OutFolder
    ReplacePics(ParamStr(2), ParamStr(3));
    If ParamStr(4) <> '-dc' Then Close;
  end;
end;

end.
