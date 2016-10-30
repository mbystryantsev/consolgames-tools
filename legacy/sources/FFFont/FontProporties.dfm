object PropForm: TPropForm
  Left = 220
  Top = 193
  BorderStyle = bsToolWindow
  Caption = 'Font Proporties'
  ClientHeight = 136
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
  object Label1: TLabel
    Left = 112
    Top = 56
    Width = 102
    Height = 13
    Caption = '*Supported only 2bpp'
  end
  object Label2: TLabel
    Left = 112
    Top = 72
    Width = 97
    Height = 13
    Caption = ' font loading/saving.'
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 48
    Width = 97
    Height = 49
    Caption = ' Chars Count: '
    TabOrder = 2
    object eCount: TSpinEdit
      Left = 8
      Top = 16
      Width = 81
      Height = 25
      MaxValue = 65535
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 0
    Width = 97
    Height = 49
    Caption = ' Height: '
    TabOrder = 0
    object eHeight: TSpinEdit
      Left = 8
      Top = 16
      Width = 81
      Height = 25
      MaxLength = 2
      MaxValue = 64
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
  end
  object GroupBox2: TGroupBox
    Left = 112
    Top = 0
    Width = 97
    Height = 49
    Caption = ' Bit Count*: '
    TabOrder = 1
    object eBitCount: TSpinEdit
      Left = 8
      Top = 16
      Width = 81
      Height = 25
      MaxLength = 1
      MaxValue = 8
      MinValue = 0
      TabOrder = 0
      Value = 0
      OnChange = eBitCountChange
    end
  end
  object bOK: TButton
    Left = 8
    Top = 104
    Width = 97
    Height = 25
    Caption = 'OK'
    TabOrder = 3
    OnClick = bOKClick
  end
  object bCancel: TButton
    Left = 112
    Top = 104
    Width = 97
    Height = 25
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = bCancelClick
  end
end
