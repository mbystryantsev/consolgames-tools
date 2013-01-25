object PropForm: TPropForm
  Left = 220
  Top = 193
  BorderStyle = bsToolWindow
  Caption = 'Font Proporties'
  ClientHeight = 89
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
    TabOrder = 1
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
  object GroupBox1: TGroupBox
    Left = 112
    Top = 0
    Width = 97
    Height = 49
    Caption = ' Height: '
    TabOrder = 0
    object eHeight: TSpinEdit
      Left = 8
      Top = 16
      Width = 81
      Height = 22
      MaxLength = 2
      MaxValue = 64
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
    TabOrder = 2
    OnClick = bOKClick
  end
  object bCancel: TButton
    Left = 112
    Top = 56
    Width = 97
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = bCancelClick
  end
end
