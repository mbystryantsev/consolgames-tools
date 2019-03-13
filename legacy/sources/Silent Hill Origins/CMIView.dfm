object Form1: TForm1
  Left = 75
  Top = 14
  Width = 776
  Height = 632
  HorzScrollBar.Style = ssFlat
  HorzScrollBar.Tracking = True
  VertScrollBar.Style = ssFlat
  VertScrollBar.Tracking = True
  Caption = 'CMIViewer'
  Color = clBtnFace
  DockSite = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnMouseDown = FormMouseDown
  OnMouseUp = FormMouseUp
  PixelsPerInch = 96
  TextHeight = 13
  object Img: TImage
    Left = 0
    Top = 0
    Width = 1980
    Height = 1088
    OnClick = ImgClick
    OnMouseDown = ImgMouseDown
    OnMouseMove = ImgMouseMove
    OnMouseUp = ImgMouseUp
  end
  object Status: TStatusBar
    Left = 0
    Top = 1088
    Width = 1980
    Height = 16
    Panels = <
      item
        Width = 50
      end
      item
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 24
    object File1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Action = fOpen
      end
      object Save1: TMenuItem
        Action = fSave
      end
      object SaveAs1: TMenuItem
        Action = aSaveAs
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object eSaveBG1: TMenuItem
        Action = eSaveBG
      end
      object eSaveLayer01: TMenuItem
        Action = eSaveLayer0
      end
      object eSaveLayer11: TMenuItem
        Action = eSaveLayer1
      end
      object eSaveTiles1: TMenuItem
        Action = eSaveTiles
      end
      object eLoadLayer01: TMenuItem
        Action = eLoadLayer0
      end
      object eLoadLayer11: TMenuItem
        Action = eLoadLayer1
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object MaxLevel01: TMenuItem
        Action = eMaxLV0
      end
      object MaxLevel11: TMenuItem
        Action = eMaxLV1
      end
      object Method1: TMenuItem
        Caption = 'Method'
        object Abstract1: TMenuItem
          Action = ePMAbstract
        end
        object Columns1: TMenuItem
          Action = ePMGrid
        end
        object Columns2: TMenuItem
          Action = ePMColumns
        end
        object Rows1: TMenuItem
          Action = ePMRows
        end
        object ePMColRow1: TMenuItem
          Action = ePMColRow
        end
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      object All1: TMenuItem
        Caption = 'All'
        Enabled = False
        OnClick = All1Click
      end
      object Layer01: TMenuItem
        Caption = 'Layer0'
        Enabled = False
        OnClick = Layer01Click
      end
      object Layer11: TMenuItem
        Caption = 'Layer1'
        Enabled = False
        OnClick = Layer11Click
      end
      object BG1: TMenuItem
        Caption = 'BG'
        Enabled = False
        OnClick = BG1Click
      end
      object iles1: TMenuItem
        Caption = 'Tiles'
        Enabled = False
        OnClick = iles1Click
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object About1: TMenuItem
        Action = aAbout
      end
    end
  end
  object ActionList1: TActionList
    Left = 16
    Top = 56
    object fOpen: TAction
      Caption = 'Open'
      OnExecute = fOpenExecute
    end
    object fSave: TAction
      Caption = 'Save'
      Enabled = False
      OnExecute = fSaveExecute
    end
    object eSaveBG: TAction
      Caption = 'Save BG...'
      Enabled = False
      OnExecute = eSaveBGExecute
    end
    object eSaveLayer0: TAction
      Caption = 'Save Layer0...'
      Enabled = False
      OnExecute = eSaveLayer0Execute
    end
    object eSaveLayer1: TAction
      Caption = 'Save Layer1...'
      Enabled = False
      OnExecute = eSaveLayer1Execute
    end
    object eSaveTiles: TAction
      Caption = 'Save Tiles...'
      Enabled = False
      OnExecute = eSaveTilesExecute
    end
    object eLoadLayer0: TAction
      Caption = 'Load Layer0...'
      Enabled = False
      OnExecute = eLoadLayer0Execute
    end
    object eLoadLayer1: TAction
      Caption = 'Load Layer1...'
      Enabled = False
      OnExecute = eLoadLayer1Execute
    end
    object aSaveAs: TAction
      Caption = 'Save As...'
      Enabled = False
      OnExecute = aSaveAsExecute
    end
    object eMaxLV0: TAction
      Caption = 'Max Level0'
      Checked = True
      OnExecute = eMaxLV0Execute
    end
    object eMaxLV1: TAction
      Caption = 'Max Level1'
      Checked = True
      OnExecute = eMaxLV1Execute
    end
    object eSetGrid: TAction
      Caption = 'Grid Mode'
      OnExecute = eSetGridExecute
    end
    object aAbout: TAction
      Caption = 'About...'
      OnExecute = aAboutExecute
    end
    object ePMAbstract: TAction
      Caption = 'Abstract'
      OnExecute = ePMAbstractExecute
    end
    object ePMGrid: TAction
      Caption = 'Grid'
      OnExecute = ePMGridExecute
    end
    object ePMColumns: TAction
      Caption = 'Columns'
      OnExecute = ePMColumnsExecute
    end
    object ePMRows: TAction
      Caption = 'Rows'
      OnExecute = ePMRowsExecute
    end
    object eClearPM: TAction
      Caption = 'eClearPM'
      OnExecute = eClearPMExecute
    end
    object ePMColRow: TAction
      Caption = 'Columns && Rows'
      Checked = True
      OnExecute = ePMColRowExecute
    end
  end
  object Op: TOpenDialog
    Filter = 'SH0 Maps (*.CMI)|*.CMI|All Files (*.*)|*'
    Left = 16
    Top = 88
  end
  object Sv: TSaveDialog
    Left = 48
    Top = 24
  end
  object OpP: TOpenPictureDialog
    Left = 48
    Top = 56
  end
  object SvP: TSavePictureDialog
    Filter = 'Bitmaps (*.bmp)|*.bmp'
    Left = 48
    Top = 88
  end
  object SaveDialog: TSaveDialog
    Filter = 'SH0 Maps (*.CMI)|*.CMI|All Files (*.*)|*'
    Left = 16
    Top = 120
  end
end
