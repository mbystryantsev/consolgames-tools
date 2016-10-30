object SEFORM: TSEFORM
  Left = 415
  Top = 475
  BorderStyle = bsDialog
  ClientHeight = 88
  ClientWidth = 167
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel: TBevel
    Left = 7
    Top = 6
    Width = 153
    Height = 51
    Shape = bsFrame
  end
  object OKBtn: TButton
    Left = 6
    Top = 58
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = OKBtnClick
  end
  object CancelBtn: TButton
    Left = 86
    Top = 58
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object StartEdit: TLabeledEdit
    Left = 15
    Top = 30
    Width = 137
    Height = 21
    EditLabel.Width = 35
    EditLabel.Height = 13
    EditLabel.Caption = 'Type in'
    TabOrder = 2
  end
end
