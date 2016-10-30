unit ConvImg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, StdCtrls, Menus, ExtDlgs, ExtCtrls, ToolWin, DIB, FF7_Common,
  ComCtrls, FF7_Compression, ImgList;

type
  TConvForm = class(TForm)
    ActionList1: TActionList;
    AConvertImage: TAction;
    Img: TImage;
    SavePDialog: TSavePictureDialog;
    OpenPDialog: TOpenPictureDialog;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    edW: TEdit;
    Label1: TLabel;
    edH: TEdit;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    AOpenRAW: TAction;
    AOpenBMP: TAction;
    ASaveRAW: TAction;
    ASaveBMP: TAction;
    ASaveRAWAs: TAction;
    RAW1: TMenuItem;
    RAW2: TMenuItem;
    RAW3: TMenuItem;
    N2: TMenuItem;
    AOpenBMP1: TMenuItem;
    BMP1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    ImageList1: TImageList;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    procedure AConvertImageExecute(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure AOpenRAWExecute(Sender: TObject);
    procedure ASaveBMPExecute(Sender: TObject);
    procedure ASaveRAWExecute(Sender: TObject);
    procedure ASaveRAWAsExecute(Sender: TObject);
    procedure AOpenBMPExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConvForm: TConvForm;
  MPic: TDIB;
  PicLoaded: Boolean;
  PicFile: String;

implementation

{$R *.dfm}

procedure TConvForm.AConvertImageExecute(Sender: TObject);
var Buf, WBuf: Pointer; Size: Integer; Pic: TDIB;
n: Integer; B: ^Byte;
begin
  Size:=LoadFile('_FF7\MOVIE\OVER.LZS',WBuf);
  Size:=LZ_Decompress(WBuf,Buf);
  FreeMem(WBuf);
  CreateDib(Pic,StrToInt(edW.Text),StrToInt(edH.Text));
  PicToDib(Buf,Pic);
  Pic.SaveToFile('_FF7\MOVIE\OVER.BMP');
  Pic.Free;
  FreeMem(Buf);
end;

procedure TConvForm.N4Click(Sender: TObject);
begin
  Close;
end;

procedure TConvForm.AOpenRAWExecute(Sender: TObject);
var W,H: Integer; Buf,WBuf: Pointer; Size: Integer;
begin
  Try
    W:=StrToInt(edW.Text);
    H:=StrToInt(edH.Text);
  except
    edW.Text:='576';
    edH.Text:='416';
    ShowMessage('Введены не числовые значения');
    Exit;
  end;
  If (W<=0) or (H<=0) Then
  begin
    ShowMessage('Неверное разрешение!');
    Exit;
  end;
  If OpenDialog.Execute and FileExists(OpenDialog.FileName) Then
  begin
    Try
      Size:=LoadFile(OpenDialog.FileName,WBuf);
    except
      ShowMessage('Ошибка при открытии файла!');
      FreeMem(WBuf);
      Exit;
    end;
    If not TestArc(WBuf,Size) Then
    begin
      ShowMessage('Данный файл не является архивом!');
      FreeMem(WBuf);
      Exit;
    end;
    Try
      Size:=LZ_Decompress(WBuf,Buf);
    except
      ShowMessage('Ошибка при распаковке!');
      FreeMem(Buf);
      FreeMem(WBuf);
      Exit;
    end;
    FreeMem(WBuf);
    If (W*H*2)<Size Then
    begin
      ShowMessage(Format('Размер файла больше, чем указанный размер картинки!'+
      #13#10'При сохранении RAW данные в конце файла будут утеряны.'#13#10+
      'Предполагаемая высота картинки при данной ширине: %d'#13#10+
      'Предполагаемая ширина картинки при данной высоте: %d',
      [(Size div 2) div W,(Size div 2) div H]));
    end else
    If (W*H*2)>Size Then
    begin
      ShowMessage(Format('Размер файла меньше, чем размер картинки!'#13#10+
      'Предполагаемая высота картинки при данной ширине: %d'#13#10+
      'Предполагаемая ширина картинки при данной высоте: %d',
      [(Size div 2) div W,(Size div 2) div H]));
      FreeMem(Buf);
      Exit;
    end;
    MPic.Height:=H;
    MPic.Width:=W;
    PicToDib(Buf,MPic);
    FreeMem(Buf);
    PicLoaded:=True;
    ASaveBMP.Enabled:=True;
    PicFile:=OpenDialog.FileName;
    Img.Picture.Graphic:=MPic;
  end;
end;

procedure TConvForm.ASaveBMPExecute(Sender: TObject);
begin
  If SavePDialog.Execute Then
  begin
    Try
      MPic.SaveToFile(SavePDialog.FileName);
    except
      ShowMessage('Ошибка при сохранении файла!');
    end;
  end;
end;

procedure TConvForm.ASaveRAWExecute(Sender: TObject);
var Buf,WBuf: Pointer; Size: Integer;
begin
  Size:=MPic.Width*MPic.Height*2;
  GetMem(WBuf,Size);
  DibToPic(WBuf,MPic);
  Try
    Size:=LZ_Compress(WBuf,Buf,Size);
  except
    ShowMessage('Ошибка при запаковке!');
    FreeMem(Buf);
    FreeMem(WBuf);
    Exit;
  end;
  Try
    SaveFile(PicFile,Buf,Size)
  except
    ShowMessage('Ошибка сохранения файла!');
  end;
  FreeMem(Buf);
end;

procedure TConvForm.ASaveRAWAsExecute(Sender: TObject);
begin
  If SaveDialog.Execute Then
  begin
    PicFile:=SaveDialog.FileName;
    ASaveRAWExecute(Sender);
  end;
end;

procedure TConvForm.AOpenBMPExecute(Sender: TObject);
begin
  If OpenPDialog.Execute and FileExists(OpenPDialog.FileName) Then
  begin
    Try
      MPic.LoadFromFile(OpenPDialog.FileName);
    except
      ShowMessage('Ошибка при загрузке файла!');
      PicLoaded:=False;
      Exit;
    end;
    If MPic.BitCount<>16 Then
    begin
      ShowMessage('Цветность картинки должна быть 15bpp (5,5,5)');
      PicLoaded:=False;
      Exit;
    end;
  end;
end;

initialization
  CreateDib(MPic,576,416);
Finalization
  MPic.Free;
end.
