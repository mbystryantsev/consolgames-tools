object MainForm: TMainForm
  Left = 291
  Top = 64
  Width = 800
  Height = 730
  Caption = 'Dante'#39's Inferno Font Editor by HoRRoR'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object FontImage: TImage
    Left = 272
    Top = 16
    Width = 512
    Height = 256
    OnMouseDown = FontImageMouseDown
    OnMouseMove = FontImageMouseMove
  end
  object CharsImage: TImage
    Left = 8
    Top = 16
    Width = 256
    Height = 320
    OnMouseDown = CharsImageMouseDown
  end
  object BigImage: TImage
    Left = 8
    Top = 344
    Width = 417
    Height = 304
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 659
    Width = 792
    Height = 17
    Panels = <
      item
        Width = 50
      end>
  end
  object MainMenu1: TMainMenu
    Left = 48
    Top = 24
    object File1: TMenuItem
      Caption = 'File'
      ShortCut = 16463
      object AOpenFile1: TMenuItem
        Action = AOpenFile
      end
      object Save1: TMenuItem
        Action = ASave
      end
      object SaveAs1: TMenuItem
        Action = ASaveAs
      end
      object ALoadImage1: TMenuItem
        Action = ALoadImage
      end
      object ALoadTG4D1: TMenuItem
        Action = ALoadTG4D
      end
      object ASaveImage1: TMenuItem
        Action = ASaveImage
      end
      object ASaveTG4D1: TMenuItem
        Action = ASaveTG4D
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object C1: TMenuItem
        Action = ACopy
      end
      object Paste1: TMenuItem
        Action = APaste
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exchangedebug1: TMenuItem
        Caption = 'Exchange (debug)'
        OnClick = Exchangedebug1Click
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object About1: TMenuItem
        Caption = 'About'
        OnClick = About1Click
      end
      object Controls1: TMenuItem
        Caption = 'Controls'
        OnClick = Controls1Click
      end
    end
  end
  object ActionList1: TActionList
    Left = 16
    Top = 24
    object AOpenFile: TAction
      Caption = 'Open...'
      ShortCut = 16463
      OnExecute = AOpenFileExecute
    end
    object ALoadImage: TAction
      Caption = 'Load Image...'
      OnExecute = ALoadImageExecute
    end
    object ASave: TAction
      Caption = 'Save'
      ShortCut = 16467
      OnExecute = ASaveExecute
    end
    object ASaveAs: TAction
      Caption = 'Save As...'
      OnExecute = ASaveAsExecute
    end
    object ALoadTG4D: TAction
      Caption = 'Load TG4D...'
      OnExecute = ALoadTG4DExecute
    end
    object ASaveTG4D: TAction
      Caption = 'Save TG4D...'
      OnExecute = ASaveTG4DExecute
    end
    object ASaveImage: TAction
      Caption = 'Save Image...'
      OnExecute = ASaveImageExecute
    end
    object ACopy: TAction
      Caption = 'Copy'
      ShortCut = 16451
      OnExecute = ACopyExecute
    end
    object APaste: TAction
      Caption = 'Paste'
      ShortCut = 16470
      OnExecute = APasteExecute
    end
  end
  object OpenDialog: TOpenDialog
    FileName = 'minion_pro.inf'
    Filter = 'Dante'#39's Inferno Font (*.inf)|*.inf'
    Left = 80
    Top = 24
  end
  object OpenTGADialog: TOpenDialog
    FileName = 'minion_pro.bmp'
    Filter = 'BMP Images (*.bmp)|*.bmp'
    Left = 112
    Top = 24
  end
  object SaveDialog: TSaveDialog
    Filter = 'Font files (*.fnt)|*.fnt'
    Left = 144
    Top = 24
  end
  object DOpenDialog: TOpenDialog
    FileName = 'minion_pro.tg4d'
    Filter = 'Font Image Data (*.tg4d)|*.tg4d'
    Left = 16
    Top = 64
  end
  object DSaveDialog: TSaveDialog
    FileName = 'minion_pro.tg4d'
    Filter = 'Font Image Data (*.tg4d)|*.tg4d'
    Left = 48
    Top = 64
  end
  object PicSaveDialog: TSaveDialog
    FileName = 'minion_pro.bmp'
    Filter = 'BMP Images (*.bmp)|*.bmp'
    Left = 80
    Top = 64
  end
end
