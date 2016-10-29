object PropForm: TPropForm
  Left = 268
  Top = 147
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'SYT Proporties'
  ClientHeight = 163
  ClientWidth = 201
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object RadioPlatform: TRadioGroup
    Left = 8
    Top = 8
    Width = 89
    Height = 81
    Caption = 'Platform'
    ItemIndex = 0
    Items.Strings = (
      'PC'
      'XBOX360'
      'PS3')
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 8
    Top = 128
    Width = 89
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 104
    Top = 128
    Width = 89
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object RadioTexType: TRadioGroup
    Left = 104
    Top = 8
    Width = 89
    Height = 81
    Caption = 'Texture'
    ItemIndex = 0
    Items.Strings = (
      'ARGB'
      'DXT1'
      'DXT3'
      'DXT5')
    TabOrder = 3
  end
  object EditName: TEdit
    Left = 8
    Top = 96
    Width = 185
    Height = 21
    MaxLength = 32
    TabOrder = 4
  end
end
