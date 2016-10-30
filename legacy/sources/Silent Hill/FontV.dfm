object Form1: TForm1
  Left = 252
  Top = 95
  Width = 388
  Height = 480
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Img: TImage
    Left = 160
    Top = 8
    Width = 217
    Height = 256
  end
  object List: TListBox
    Left = 8
    Top = 8
    Width = 137
    Height = 361
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ItemHeight = 14
    ParentFont = False
    TabOrder = 0
    OnClick = ListClick
  end
  object eW: TEdit
    Left = 8
    Top = 376
    Width = 33
    Height = 21
    MaxLength = 3
    TabOrder = 1
    OnChange = eWChange
  end
  object UD: TUpDown
    Left = 40
    Top = 376
    Width = 17
    Height = 25
    Max = 255
    TabOrder = 2
    OnClick = UDClick
  end
  object OD: TOpenDialog
    FileName = 'SH_E_C_EDIT.BIN'
    Left = 344
    Top = 40
  end
  object OPD: TOpenPictureDialog
    FileName = 'SILENT_0002.bmp'
    Filter = 'Bitmaps (*.bmp)|*.bmp'
    Left = 344
    Top = 8
  end
  object MainMenu1: TMainMenu
    Left = 200
    Top = 296
    object File1: TMenuItem
      Caption = 'File'
      object Save1: TMenuItem
        Caption = 'Save'
        OnClick = Save1Click
      end
    end
  end
end
