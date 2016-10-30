object StrPropForm: TStrPropForm
  Left = 219
  Top = 139
  Width = 248
  Height = 164
  BorderStyle = bsSizeToolWin
  Caption = 'StrPropForm'
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
  object GroupBox: TGroupBox
    Left = 8
    Top = 8
    Width = 225
    Height = 81
    TabOrder = 0
    object LabelName: TLabel
      Left = 8
      Top = 24
      Width = 31
      Height = 13
      Caption = 'Name:'
    end
    object LabelIndex: TLabel
      Left = 8
      Top = 48
      Width = 29
      Height = 13
      Caption = 'Index:'
    end
    object eRName: TEdit
      Left = 48
      Top = 24
      Width = 169
      Height = 21
      TabOrder = 0
    end
    object eRIndex: TSpinEdit
      Left = 48
      Top = 48
      Width = 57
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
    end
  end
  object eRetry: TCheckBox
    Left = 8
    Top = 0
    Width = 81
    Height = 17
    Caption = 'Instance of ...  '
    TabOrder = 1
    OnClick = eRetryClick
  end
  object bOK: TButton
    Left = 8
    Top = 96
    Width = 105
    Height = 25
    Caption = 'OK'
    TabOrder = 2
    OnClick = bOKClick
  end
  object bCancel: TButton
    Left = 120
    Top = 96
    Width = 105
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = bCancelClick
  end
end
