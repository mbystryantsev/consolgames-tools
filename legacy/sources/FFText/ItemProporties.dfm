object ItemPropForm: TItemPropForm
  Left = 258
  Top = 82
  BorderStyle = bsToolWindow
  Caption = 'Item Proporties'
  ClientHeight = 226
  ClientWidth = 217
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
  object gbFlags: TGroupBox
    Left = 8
    Top = 128
    Width = 201
    Height = 57
    Caption = ' Flags: '
    TabOrder = 2
    object eHide: TCheckBox
      Left = 8
      Top = 16
      Width = 137
      Height = 17
      Caption = 'Hidden'
      TabOrder = 0
    end
    object eChecked: TCheckBox
      Left = 8
      Top = 32
      Width = 137
      Height = 17
      Caption = 'Checked'
      TabOrder = 1
    end
  end
  object gbUserData: TGroupBox
    Left = 8
    Top = 88
    Width = 201
    Height = 41
    Caption = ' User Data: '
    TabOrder = 5
    object eUserData: TTntEdit
      Left = 8
      Top = 14
      Width = 185
      Height = 21
      TabOrder = 0
    end
  end
  object gbCaption: TGroupBox
    Left = 8
    Top = 48
    Width = 201
    Height = 41
    Caption = ' Caption: '
    TabOrder = 1
    object eCaption: TTntEdit
      Left = 8
      Top = 14
      Width = 185
      Height = 21
      TabOrder = 0
      Text = 'eCaption'
    end
  end
  object gbName: TGroupBox
    Left = 8
    Top = 8
    Width = 201
    Height = 41
    Caption = ' Name: '
    TabOrder = 0
    object eName: TEdit
      Left = 7
      Top = 14
      Width = 186
      Height = 21
      ReadOnly = True
      TabOrder = 0
      Text = 'eName'
    end
  end
  object bOK: TButton
    Left = 8
    Top = 192
    Width = 97
    Height = 25
    Caption = 'OK'
    TabOrder = 3
    OnClick = bOKClick
  end
  object bCancel: TButton
    Left = 112
    Top = 192
    Width = 97
    Height = 25
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = bCancelClick
  end
end
