object KerningForm: TKerningForm
  Left = 418
  Top = 414
  BorderStyle = bsToolWindow
  Caption = 'Kerning'
  ClientHeight = 479
  ClientWidth = 530
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
  object eCharsImage: TImage
    Left = 8
    Top = 168
    Width = 512
    Height = 256
  end
  object eCharA: TTntEdit
    Left = 408
    Top = 128
    Width = 25
    Height = 21
    MaxLength = 1
    TabOrder = 0
    OnChange = eCharAChange
    OnKeyPress = eCharAKeyPress
  end
  object eCharB: TTntEdit
    Left = 440
    Top = 128
    Width = 25
    Height = 21
    MaxLength = 1
    TabOrder = 1
    OnChange = eCharBChange
    OnKeyPress = eCharBKeyPress
  end
  object eKerningValue: TSpinEdit
    Left = 472
    Top = 128
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = -255
    TabOrder = 2
    Value = 0
    OnChange = eKerningValueChange
  end
  object eKerningList: TTntListView
    Left = 408
    Top = 8
    Width = 117
    Height = 113
    Columns = <
      item
        Caption = 'A'
        Width = 25
      end
      item
        Caption = 'B'
        Width = 25
      end
      item
        Caption = 'K'
        Width = 60
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    ShowColumnHeaders = False
    TabOrder = 3
    ViewStyle = vsReport
    OnClick = eKerningListClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 281
    Height = 153
    Caption = 'Test string '
    TabOrder = 4
    object eTestImage: TImage
      Left = 8
      Top = 73
      Width = 256
      Height = 64
    end
    object eTestStr: TTntEdit
      Left = 8
      Top = 16
      Width = 257
      Height = 21
      TabOrder = 0
      Text = 'Test'
      OnChange = eTestStrChange
    end
    object eKerningEnable: TCheckBox
      Left = 8
      Top = 48
      Width = 145
      Height = 17
      Caption = 'Enable Kerning'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = eKerningEnableClick
    end
  end
  object Button1: TButton
    Left = 344
    Top = 8
    Width = 57
    Height = 25
    Action = AddAction
    TabOrder = 5
  end
  object Button2: TButton
    Left = 344
    Top = 40
    Width = 57
    Height = 25
    Action = RemoveAction
    TabOrder = 6
  end
  object bOK: TButton
    Left = 168
    Top = 440
    Width = 89
    Height = 25
    Caption = 'OK'
    TabOrder = 7
    OnClick = bOKClick
  end
  object bCancel: TButton
    Left = 272
    Top = 440
    Width = 89
    Height = 25
    Caption = 'Cancel'
    TabOrder = 8
    OnClick = bCancelClick
  end
  object ActionList: TActionList
    Left = 304
    Top = 96
    object AddAction: TAction
      Caption = 'Add'
      OnExecute = AddActionExecute
    end
    object RemoveAction: TAction
      Caption = 'Remove'
      OnExecute = RemoveActionExecute
    end
  end
end
