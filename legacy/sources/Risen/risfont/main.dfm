object MainForm: TMainForm
  Left = 134
  Top = 83
  Width = 802
  Height = 617
  Caption = 'Risen Font Editor by HoRRoR'
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
    Height = 512
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
    Width = 256
    Height = 184
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 546
    Width = 794
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
  end
  object OpenDialog: TOpenDialog
    Filter = 'Risen font (*.fnt)|*.fnt'
    Left = 80
    Top = 24
  end
  object OpenTGADialog: TOpenDialog
    Filter = 'TGA Images (*.tga)|*.tga'
    Left = 112
    Top = 24
  end
  object SaveDialog: TSaveDialog
    Filter = 'Font files (*.fnt)|*.fnt'
    Left = 144
    Top = 24
  end
end
