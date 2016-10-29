object PropForm: TPropForm
  Left = 446
  Top = 126
  BorderStyle = bsToolWindow
  Caption = 'Import Properties'
  ClientHeight = 238
  ClientWidth = 285
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
  object bOK: TButton
    Left = 8
    Top = 208
    Width = 129
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = bOKClick
  end
  object bCancel: TButton
    Left = 144
    Top = 208
    Width = 129
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = bCancelClick
  end
  object RadioEmpty: TRadioButton
    Left = 152
    Top = 0
    Width = 73
    Height = 17
    Caption = 'Empty font'
    TabOrder = 2
    OnClick = RadioEmptyClick
  end
  object RadioImport: TRadioButton
    Left = 16
    Top = 0
    Width = 105
    Height = 17
    Caption = 'Import from file'
    Checked = True
    TabOrder = 3
    TabStop = True
    OnClick = RadioImportClick
  end
  object BoxImportOptions: TGroupBox
    Left = 8
    Top = 16
    Width = 129
    Height = 57
    Caption = ' Import options '
    TabOrder = 4
    object RadioAutodetect: TRadioButton
      Left = 8
      Top = 16
      Width = 129
      Height = 17
      Caption = 'Autodetect'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = RadioAutodetectClick
    end
    object RadioManual: TRadioButton
      Left = 8
      Top = 32
      Width = 113
      Height = 17
      Caption = 'Manual settings'
      TabOrder = 1
      OnClick = RadioManualClick
    end
  end
  object BoxImportSettings: TGroupBox
    Left = 144
    Top = 16
    Width = 129
    Height = 57
    Caption = ' Import settings '
    TabOrder = 5
    object RadioOffset: TRadioButton
      Left = 8
      Top = 16
      Width = 113
      Height = 17
      Caption = 'Offset from pointers'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object RadioDirect: TRadioButton
      Left = 8
      Top = 32
      Width = 129
      Height = 17
      Caption = 'Direct offset'
      TabOrder = 1
    end
  end
  object BoxPresets: TGroupBox
    Left = 144
    Top = 80
    Width = 129
    Height = 121
    Caption = ' Presets '
    TabOrder = 6
    object bPCEXE: TButton
      Left = 8
      Top = 32
      Width = 113
      Height = 25
      Caption = 'PC EXE'
      TabOrder = 0
      OnClick = bPCEXEClick
    end
    object bPS2EXE: TButton
      Left = 8
      Top = 80
      Width = 113
      Height = 25
      Caption = 'PS2 EXE'
      TabOrder = 1
      OnClick = bPS2EXEClick
    end
  end
  object BoxDataSettings: TGroupBox
    Left = 8
    Top = 80
    Width = 129
    Height = 121
    Caption = ' Data Settings (hex)'
    TabOrder = 7
    object LabelPtrDef: TLabel
      Left = 8
      Top = 18
      Width = 39
      Height = 13
      Caption = 'Ptr. Def.'
    end
    object Label1: TLabel
      Left = 8
      Top = 40
      Width = 40
      Height = 13
      Caption = 'PtrsOffs:'
    end
    object LabelDataOffset: TLabel
      Left = 8
      Top = 64
      Width = 49
      Height = 13
      Caption = 'Data offs.:'
    end
    object LabelMaxSize: TLabel
      Left = 8
      Top = 88
      Width = 44
      Height = 13
      Caption = 'Max.size:'
    end
    object ePtrDef: TEdit
      Left = 56
      Top = 16
      Width = 65
      Height = 21
      MaxLength = 8
      TabOrder = 0
      Text = 'FF800'
    end
    object ePtrsOffset: TEdit
      Left = 56
      Top = 40
      Width = 65
      Height = 21
      TabOrder = 1
    end
    object eDataOffset: TEdit
      Left = 56
      Top = 64
      Width = 65
      Height = 21
      TabOrder = 2
      Text = 'eDataOffset'
    end
    object eMaxSize: TEdit
      Left = 56
      Top = 88
      Width = 65
      Height = 21
      TabOrder = 3
      Text = 'eMaxSize'
    end
  end
end
