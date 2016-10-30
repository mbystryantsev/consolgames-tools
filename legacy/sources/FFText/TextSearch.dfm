object FindForm: TFindForm
  Left = 275
  Top = 159
  Width = 404
  Height = 176
  BorderStyle = bsSizeToolWin
  Caption = 'Find'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox2: TGroupBox
    Left = 272
    Top = 64
    Width = 113
    Height = 73
    Caption = 'Direction'
    TabOrder = 11
    object eUp: TRadioButton
      Left = 8
      Top = 16
      Width = 97
      Height = 17
      Caption = 'Up'
      TabOrder = 0
    end
    object eDown: TRadioButton
      Left = 8
      Top = 32
      Width = 97
      Height = 17
      Caption = 'Down'
      Checked = True
      TabOrder = 1
      TabStop = True
    end
    object eBeginEnd: TCheckBox
      Left = 8
      Top = 48
      Width = 97
      Height = 17
      Caption = 'From begin/end'
      TabOrder = 2
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 297
    Height = 49
    Caption = ' Find what '
    TabOrder = 0
    object eText: TTntEdit
      Left = 8
      Top = 20
      Width = 273
      Height = 21
      TabOrder = 0
    end
  end
  object eCurOnly: TCheckBox
    Left = 8
    Top = 72
    Width = 121
    Height = 17
    Caption = 'Only in current item'
    TabOrder = 3
  end
  object eHidden: TCheckBox
    Left = 8
    Top = 88
    Width = 113
    Height = 17
    Caption = 'Find in hidden items'
    Enabled = False
    State = cbGrayed
    TabOrder = 4
  end
  object eInstances: TCheckBox
    Left = 8
    Top = 104
    Width = 113
    Height = 17
    Caption = 'Find in instances'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object eWholeWords: TCheckBox
    Left = 136
    Top = 72
    Width = 105
    Height = 17
    Caption = 'Whole word only'
    TabOrder = 7
  end
  object eMatchCase: TCheckBox
    Left = 136
    Top = 88
    Width = 105
    Height = 17
    Caption = 'Match case'
    TabOrder = 8
  end
  object eWrapAround: TCheckBox
    Left = 136
    Top = 104
    Width = 81
    Height = 17
    Caption = 'Wrap around'
    TabOrder = 9
  end
  object eExtended: TCheckBox
    Left = 136
    Top = 120
    Width = 129
    Height = 17
    Caption = 'Extended (\n, \t, ...)'
    TabOrder = 10
  end
  object bFind: TButton
    Left = 312
    Top = 8
    Width = 73
    Height = 25
    Caption = 'Find next'
    TabOrder = 1
    OnClick = bFindClick
  end
  object bClose: TButton
    Left = 312
    Top = 40
    Width = 73
    Height = 25
    Caption = 'Close'
    TabOrder = 2
    OnClick = bCloseClick
  end
  object eOriginal: TCheckBox
    Left = 8
    Top = 120
    Width = 113
    Height = 17
    Caption = 'Search in original'
    Enabled = False
    TabOrder = 6
  end
end
