object MainForm: TMainForm
  Left = 374
  Top = 170
  BorderStyle = bsDialog
  Caption = 'MainForm'
  ClientHeight = 433
  ClientWidth = 342
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ePakList: TCheckListBox
    Left = 8
    Top = 8
    Width = 329
    Height = 249
    OnClickCheck = ePakListClickCheck
    ItemHeight = 13
    PopupMenu = PakListMenu
    TabOrder = 0
  end
  object eImagePath: TEdit
    Left = 8
    Top = 264
    Width = 297
    Height = 21
    Hint = 'Image file path'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    Text = 'F:\_job\Metroid Prime 3\Metroid_3_cor[pal].iso'
  end
  object eSelectImage: TButton
    Left = 312
    Top = 264
    Width = 25
    Height = 25
    Caption = '...'
    TabOrder = 2
    OnClick = eSelectImageClick
  end
  object bStart: TButton
    Left = 248
    Top = 368
    Width = 89
    Height = 41
    Caption = 'Start!'
    TabOrder = 3
    OnClick = bStartClick
  end
  object eFilesPath: TEdit
    Left = 8
    Top = 288
    Width = 297
    Height = 21
    Hint = 'Input folder path'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    Text = 'F:\_job\Metroid Prime 3\test\'
  end
  object eSelectPath: TButton
    Left = 312
    Top = 288
    Width = 25
    Height = 25
    Caption = '...'
    TabOrder = 5
    Visible = False
    OnClick = eSelectPathClick
  end
  object eCommonProgress: TProgressBar
    Left = 8
    Top = 320
    Width = 329
    Height = 17
    Min = 0
    Max = 100
    TabOrder = 6
  end
  object ePakProgress: TProgressBar
    Left = 8
    Top = 344
    Width = 329
    Height = 17
    Min = 0
    Max = 100
    TabOrder = 7
  end
  object eStatusBar: TStatusBar
    Left = 0
    Top = 418
    Width = 342
    Height = 15
    Panels = <
      item
        Width = 150
      end
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object eKeepTemp: TCheckBox
    Left = 120
    Top = 368
    Width = 113
    Height = 17
    Caption = 'Keep temp files'
    TabOrder = 9
  end
  object PakListMenu: TPopupMenu
    Left = 8
    Top = 368
    object AClearPakList1: TMenuItem
      Action = ASelectNone
    end
    object Selectall1: TMenuItem
      Action = ASelectAll
    end
  end
  object ActionList: TActionList
    Left = 40
    Top = 368
    object ASelectNone: TAction
      Caption = 'Select None'
      OnExecute = ASelectNoneExecute
    end
    object ASelectAll: TAction
      Caption = 'Select All'
      OnExecute = ASelectAllExecute
    end
  end
  object OpenImageDialog: TOpenDialog
    DefaultExt = '.iso'
    Filter = 'Wii ISO Images (*.iso)|*.iso'
    Left = 72
    Top = 368
  end
end
