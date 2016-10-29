unit FontProporties;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin;

Type
  TImportInfo = Record
    Empty:      Boolean;
    Autodetect: Boolean;
    DataOffset: DWord;
    MaxSize:    DWord;
    DirectOffset: Boolean;
    Case Byte of
    0:(
    PtrDef:     DWord;
    PtrsOffset: DWord;
    );
    1:(
    Font0Offset: DWord;
    Font1Offset: DWord;
    );
  end;

type
  TPropForm = class(TForm)
    bOK: TButton;
    bCancel: TButton;
    RadioEmpty: TRadioButton;
    RadioImport: TRadioButton;
    BoxImportOptions: TGroupBox;
    RadioAutodetect: TRadioButton;
    RadioManual: TRadioButton;
    BoxImportSettings: TGroupBox;
    RadioOffset: TRadioButton;
    RadioDirect: TRadioButton;
    BoxPresets: TGroupBox;
    bPCEXE: TButton;
    bPS2EXE: TButton;
    BoxDataSettings: TGroupBox;
    ePtrDef: TEdit;
    LabelPtrDef: TLabel;
    ePtrsOffset: TEdit;
    eDataOffset: TEdit;
    Label1: TLabel;
    LabelDataOffset: TLabel;
    eMaxSize: TEdit;
    LabelMaxSize: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure bOKClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure bCancelClick(Sender: TObject);
    procedure RadioEmptyClick(Sender: TObject);
    procedure RadioImportClick(Sender: TObject);
    procedure RadioAutodetectClick(Sender: TObject);
    procedure RadioManualClick(Sender: TObject);
    procedure bPCEXEClick(Sender: TObject);
    procedure bPS2EXEClick(Sender: TObject);
  private
    FInfo:  ^TImportInfo;
    FResult: Boolean;
  public
    Function Show(var Info: TImportInfo; Insert: Boolean = False): Boolean;
  end;

var
  PropForm: TPropForm;

implementation

{$R *.dfm}

uses main;

Function TPropForm.Show(var Info: TImportInfo; Insert: Boolean = False): Boolean;
begin
  FResult := False;
  FInfo := @Info;
  // ...
  eDataOffset.Visible     := Insert;
  LabelDataOffset.Visible := Insert;
  eMaxSize.Visible        := Insert;
  LabelMaxSize.Visible    := Insert;


  ShowModal;
  Result := FResult;
end;

procedure TPropForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//  Caption := IntToHex(Key, 4);
  Case Key of
    $1B:  Close;
    $0D:  PropForm.bOKClick(nil); 
  end;
end;

procedure TPropForm.bOKClick(Sender: TObject);

  Function GetVal(const Edit: TEdit; var I: DWord): Boolean;
  var Code: Integer;
  begin
    Result := False;
    If not (Edit.Visible and Edit.Enabled) Then Exit;
    Val('$' + Edit.Text, I, Code);
    If Code <> 0 Then
    begin
      Edit.SetFocus;
      Beep;
      Result := True;
    end;
  end;

begin
  // ...
  FInfo^.Empty := RadioEmpty.Checked;
  FInfo^.Autodetect := RadioAutodetect.Checked;
  FInfo^.DirectOffset := RadioDirect.Checked;
  If GetVal(ePtrDef, FInfo^.PtrDef) Then Exit;
  If GetVal(ePtrsOffset, FInfo^.PtrsOffset) Then Exit;
  If GetVal(eDataOffset, FInfo^.DataOffset) Then Exit;
  If GetVal(eMaxSize, FInfo^.MaxSize)  Then Exit;
  FResult := True;
  Close;
end;

procedure TPropForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #13 Then Key := #0;
end;

procedure TPropForm.bCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TPropForm.RadioEmptyClick(Sender: TObject);
begin
  //BoxImportOptions.Enabled := False;
  //BoxImportSettings.Enabled := False;
  RadioAutodetect.Enabled := False;
  RadioManual.Enabled := False;
  RadioOffset.Enabled := False;
  RadioDirect.Enabled := False;

  bPCEXE.Enabled := False;
  bPS2EXE.Enabled := False;
end;

procedure TPropForm.RadioImportClick(Sender: TObject);
begin
  RadioAutodetect.Enabled := True;
  RadioManual.Enabled := True;
  If RadioAutodetect.Checked Then
    RadioAutodetectClick(RadioAutodetect)
  else
    RadioManualClick(RadioManual);
end;

procedure TPropForm.RadioAutodetectClick(Sender: TObject);
begin
  RadioOffset.Enabled := False;
  RadioDirect.Enabled := False;
  bPCEXE.Enabled := False;
  bPS2EXE.Enabled := False;
end;

procedure TPropForm.RadioManualClick(Sender: TObject);
begin
  RadioOffset.Enabled := True;
  RadioDirect.Enabled := True;
  bPCEXE.Enabled := True;
  bPS2EXE.Enabled := True;
end;

procedure TPropForm.bPCEXEClick(Sender: TObject);
begin
  ePtrDef.Text := IntToHex(cPCPtrDef, 8);
  ePtrsOffset.Text := IntToHex(cPCPointer1, 8);
  eDataOffset.Text := '403910';
  eMaxSize.Text := '72D30';
end;

procedure TPropForm.bPS2EXEClick(Sender: TObject);
begin
  ePtrDef.Text := IntToHex(cPtrDef, 8);
end;

end.
