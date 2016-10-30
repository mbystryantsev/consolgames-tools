object CharPropForm: TCharPropForm
  Left = 307
  Top = 395
  BorderStyle = bsToolWindow
  Caption = 'Char Properties...'
  ClientHeight = 98
  ClientWidth = 115
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
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 97
    Height = 49
    Caption = 'Code:'
    TabOrder = 0
    object eCode: TEdit
      Left = 8
      Top = 16
      Width = 49
      Height = 21
      TabOrder = 0
      Text = '0000'
      OnKeyPress = eCodeKeyPress
    end
    object bSelect: TButton
      Left = 64
      Top = 16
      Width = 25
      Height = 25
      Caption = '...'
      TabOrder = 1
      TabStop = False
      OnClick = bSelectClick
    end
  end
  object bOK: TButton
    Left = 8
    Top = 64
    Width = 49
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = bOKClick
  end
  object bCancel: TButton
    Left = 56
    Top = 64
    Width = 49
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = bCancelClick
  end
end
