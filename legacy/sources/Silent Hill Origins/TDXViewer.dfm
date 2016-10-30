object Form1: TForm1
  Left = 146
  Top = 66
  Width = 714
  Height = 535
  HorzScrollBar.Tracking = True
  VertScrollBar.Tracking = True
  Caption = 'TXD Viewer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020100001000400E80200001600000028000000200000004000
    000001000400000000008002000000000000000000000000000000000000211E
    1D008D827E0062595600B3AAA700433D3B00776B67009F938F00C0B9B6006E63
    60007D716D00554D4A00978B8700A89D9900342E2D00C8C2C000827772002885
    59955558FF999F5555595888858F85999FF99982A4D4AAA228555885859F555F
    F9558AD0044AAAAAA29F95955F9F855FF55AD00D44AAAA22228855595F955559
    9540004AAA285585888885555FF98599540004A29FF995558885889F99118FF5
    A000AA5999588222585991B159118852000A29F851C37CBF528F16CC159F822D
    00AA99FB337E73336525BC336F5FFFA004A959CE777733CCBF821C333BFFF9D0
    0A89FCEE777733C6BF529BC33CFF5A00D488BEEE7C1F1FB615222FCC331F5400
    42857EE7B8AA2A2F1822286CC3CFFD00A5517E76824A284A552A22BC37399D0D
    A58C77712A2A5144852AA21C3E7FF004A5237779A428815825AAA21C7EEF100A
    A5833335561F5BF895AAAA1C7EE91D0AA95333C52F19B6B1582AAA1CEE7F140A
    2F9C33C12F6BC3B582AAAA1CEE3F1A0A2F9B3CC6F916CB828AAAA263EECF180A
    299FCCB582855888AAAAA967E7B9B14A281F1BB92895992AAAAA8B3EE3FF6B8A
    2211FFFF952222AAAAA21C7E7C116612221B1F55882222A2AA2F63EE3BF1666F
    2251BB988828222A281C37EEC1F16666F8816B1F98822228FC33E77CB9FBB666
    BF51BB166B11111B337EEE3BB1FB6CC66611666CC33333333EEEE3B1111B6CC6
    CCC66CCC33777733EEE761B1111B6CC6CCCCCCCC33777337E736B9911BBBCC6C
    CCCC3CCC337773C3C1BBB11BBB1BCCCCC6CCCCCCC66BB11161BBBB6611160000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000}
  Menu = MainMenu1
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Img: TImage
    Left = 192
    Top = 8
    Width = 209
    Height = 193
  end
  object List: TListBox
    Left = 8
    Top = 8
    Width = 177
    Height = 441
    ItemHeight = 13
    PopupMenu = PopupMenu1
    TabOrder = 0
    OnClick = ListClick
  end
  object Status: TStatusBar
    Left = 0
    Top = 460
    Width = 706
    Height = 21
    Panels = <
      item
        Width = 64
      end
      item
        Width = 64
      end
      item
        Width = 64
      end
      item
        Alignment = taCenter
        Width = 64
      end
      item
        Alignment = taCenter
        BiDiMode = bdRightToLeft
        ParentBiDiMode = False
        Width = 80
      end
      item
        Alignment = taCenter
        Width = 64
      end
      item
        Width = 50
      end>
  end
  object MainMenu1: TMainMenu
    Left = 408
    Top = 40
    object File1: TMenuItem
      Caption = '&File'
      ShortCut = 16463
      object Open1: TMenuItem
        Action = LoadFileAction
      end
      object ScanFile1: TMenuItem
        Action = ScanFileAction
      end
      object Close1: TMenuItem
        Action = CloseAction
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object Extractallimages1: TMenuItem
        Action = eExtractAllFromDir
      end
      object eReplaceTextures1: TMenuItem
        Action = eReplaceTextures
        Caption = 'Replace Textures...'
      end
      object eCopyIfContainPic1: TMenuItem
        Action = eCopyIfContainPic
        Caption = 'Copy If Exists Pics...'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Action = ExitAction
      end
    end
    object Edit1: TMenuItem
      Caption = '&Edit'
      object CopytoBitmap1: TMenuItem
        Action = CopyToBitmapAction
      end
      object PastetoBitmap1: TMenuItem
        Action = PasteFromBitmapAction
      end
      object Close4: TMenuItem
        Action = eSavePal
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Close2: TMenuItem
        Action = eExtractAll
      end
    end
    object Options1: TMenuItem
      Caption = '&Options'
      object ReplPal: TMenuItem
        Caption = '&Replace Pallete (Alpha disappear)'
        OnClick = IBCClick
      end
      object IBC: TMenuItem
        Caption = '&Ignore Bit Count (8bpp->4bpp)'
        Checked = True
        OnClick = IBCClick
      end
    end
    object About1: TMenuItem
      Caption = '&About...'
      OnClick = About1Click
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 408
    Top = 72
  end
  object OpenBitmap: TOpenPictureDialog
    Left = 408
    Top = 104
  end
  object SavePictureDialog1: TSavePictureDialog
    Filter = 'Bitmaps (*.bmp)|*.bmp'
    Left = 408
    Top = 136
  end
  object ActionList: TActionList
    Left = 408
    Top = 8
    object LoadFileAction: TAction
      Caption = 'Open...'
      ShortCut = 16463
      OnExecute = LoadFileActionExecute
    end
    object CloseAction: TAction
      Caption = 'Close'
      ShortCut = 16471
      OnExecute = CloseActionExecute
    end
    object ExitAction: TAction
      Caption = 'Exit'
      ShortCut = 16465
      OnExecute = ExitActionExecute
    end
    object CopyToBitmapAction: TAction
      Caption = 'Copy to Bitmap...'
      ShortCut = 16450
      OnExecute = CopyToBitmapActionExecute
    end
    object PasteFromBitmapAction: TAction
      Caption = 'Paste from Bitmap...'
      ShortCut = 16464
      OnExecute = PasteFromBitmapActionExecute
    end
    object ScanFileAction: TAction
      Caption = 'Scan File...'
      ShortCut = 16466
      OnExecute = ScanFileActionExecute
    end
    object eExtractAllFromDir: TAction
      Caption = 'Extract All Images...'
      OnExecute = eExtractAllFromDirExecute
    end
    object eExtractAll: TAction
      Caption = 'Extract All...'
      OnExecute = eExtractAllExecute
    end
    object eReplaceTextures: TAction
      Caption = 'eReplaceTextures'
      OnExecute = eReplaceTexturesExecute
    end
    object eCopyIfContainPic: TAction
      Caption = 'eCopyIfContainPic'
      OnExecute = eCopyIfContainPicExecute
    end
    object eSavePal: TAction
      Caption = 'Save Palette...'
      OnExecute = eSavePalExecute
    end
  end
  object OpenScanFile: TOpenDialog
    Filter = 'All Files (*.*)|*'
    Left = 408
    Top = 168
  end
  object PopupMenu1: TPopupMenu
    Left = 440
    Top = 8
    object CopytoBitmap2: TMenuItem
      Action = CopyToBitmapAction
    end
    object PastefromBitmap1: TMenuItem
      Action = PasteFromBitmapAction
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Close3: TMenuItem
      Action = eExtractAll
    end
  end
  object PFolderOpen: TPFolderDialog
    RootFolder = sfDesktop
    BrowseOptions = [boOnlyFileSystemAncestors, boOnlyDirectories, boNewStyle]
    AdvancedOptions = [aoStandardStatusText, aoStandardOkButtonText, aoStandardCancelButtonText]
    OkButtonEnabled = True
    Caption = 'Select TXD Folder...'
    Left = 440
    Top = 40
  end
  object PFolderSave: TPFolderDialog
    RootFolder = sfDesktop
    BrowseOptions = [boOnlyFileSystemAncestors, boOnlyDirectories, boNewStyle]
    AdvancedOptions = [aoStandardStatusText, aoStandardOkButtonText, aoStandardCancelButtonText]
    OkButtonEnabled = True
    StatusText = 'asdas'
    Caption = 'Save Images...'
    Left = 440
    Top = 72
  end
  object SavePalDialog: TSaveDialog
    Left = 440
    Top = 104
  end
end
