object X: TX
  Left = 358
  Top = 167
  Width = 696
  Height = 460
  Caption = 'X'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object List: TListBox
    Left = 0
    Top = 32
    Width = 249
    Height = 377
    ItemHeight = 13
    TabOrder = 0
    OnClick = ListClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 409
    Width = 671
    Height = 16
    Panels = <>
  end
  object OpenP: TOpenPictureDialog
    Left = 648
    Top = 40
  end
  object OpenDialog1: TOpenDialog
    FileName = 'GLOBAL_BINARY.STR'
    Filter = 'Streams (*.STR)|*.STR|All Files (*.*)|*'
    Left = 648
    Top = 8
  end
  object MainMenu1: TMainMenu
    Left = 648
    Top = 80
    object File1: TMenuItem
      Caption = 'File'
      object Exit1: TMenuItem
        Caption = 'Exit'
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object About1: TMenuItem
        Caption = 'Font 1'
        Checked = True
        RadioItem = True
      end
      object Font21: TMenuItem
        Caption = 'Font 2'
        RadioItem = True
      end
      object Font31: TMenuItem
        Caption = 'Font 3'
        RadioItem = True
      end
    end
    object About2: TMenuItem
      Caption = 'About'
    end
  end
end
