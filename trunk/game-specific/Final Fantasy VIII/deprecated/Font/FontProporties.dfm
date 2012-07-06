object PropForm: TPropForm
  Left = 220
  Top = 193
  BorderStyle = bsToolWindow
  Caption = 'Font Proporties'
  ClientHeight = 86
  ClientWidth = 216
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox3: TGroupBox
    Left = 8
    Top = 0
    Width = 97
    Height = 49
    Caption = ' Chars Count: '
    TabOrder = 0
    object eCount: TSpinEdit
      Left = 8
      Top = 16
      Width = 81
      Height = 22
      MaxValue = 65535
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
  end
  object bOK: TButton
    Left = 8
    Top = 56
    Width = 97
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = bOKClick
  end
  object bCancel: TButton
    Left = 112
    Top = 56
    Width = 97
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = bCancelClick
  end
  object eCompressed: TCheckBox
    Left = 112
    Top = 8
    Width = 97
    Height = 17
    Caption = 'Compressed'
    TabOrder = 3
  end
end
