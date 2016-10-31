object Form1: TForm1
  Left = 226
  Top = 77
  Width = 515
  Height = 426
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnActivate = LoadFont
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Img: TImage
    Left = 168
    Top = 0
    Width = 209
    Height = 217
  end
  object List: TListBox
    Left = 0
    Top = 0
    Width = 161
    Height = 337
    ItemHeight = 13
    TabOrder = 0
    OnClick = ListClick
  end
  object XT: TEdit
    Left = 0
    Top = 344
    Width = 33
    Height = 21
    TabOrder = 1
    Text = '0'
    OnChange = XTChange
  end
  object YT: TEdit
    Left = 56
    Top = 344
    Width = 33
    Height = 21
    TabOrder = 2
    Text = '0'
    OnChange = YTChange
  end
  object WT: TEdit
    Left = 112
    Top = 344
    Width = 33
    Height = 21
    TabOrder = 3
    Text = '0'
    OnChange = WTChange
  end
  object UpDown1: TUpDown
    Left = 32
    Top = 344
    Width = 17
    Height = 25
    TabOrder = 4
    OnClick = UpDown1Click
  end
  object UpDown2: TUpDown
    Left = 88
    Top = 344
    Width = 17
    Height = 25
    TabOrder = 5
    OnClick = UpDown2Click
  end
  object UpDown3: TUpDown
    Left = 144
    Top = 344
    Width = 17
    Height = 25
    TabOrder = 6
    OnClick = UpDown3Click
  end
  object OpenDialog1: TOpenDialog
    FileName = 'GLOBAL_BINARY.STR'
    Left = 656
    Top = 8
  end
  object OpenP: TOpenPictureDialog
    Left = 656
    Top = 40
  end
  object MainMenu1: TMainMenu
    Left = 656
    Top = 72
    object File1: TMenuItem
      Caption = 'File'
      object Save1: TMenuItem
        Caption = 'Save'
        OnClick = Save1Click
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object Font11: TMenuItem
        Caption = 'Font 1'
        Checked = True
        RadioItem = True
        OnClick = Font11Click
      end
      object Font21: TMenuItem
        Caption = 'Font 2'
        RadioItem = True
        OnClick = Font21Click
      end
      object Font31: TMenuItem
        Caption = 'Font 3'
        RadioItem = True
        OnClick = Font31Click
      end
    end
    object About1: TMenuItem
      Caption = 'About'
    end
  end
end
