object Form1: TForm1
  Left = 196
  Top = 141
  Width = 696
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
  PixelsPerInch = 96
  TextHeight = 13
  object FrameBox: TGroupBox
    Left = 8
    Top = 288
    Width = 249
    Height = 73
    Caption = 'Frame:'
    TabOrder = 8
  end
  object SectorBox: TGroupBox
    Left = 8
    Top = 200
    Width = 249
    Height = 81
    Caption = 'Sector:'
    TabOrder = 5
  end
  object VList: TValueListEditor
    Left = 8
    Top = 8
    Width = 249
    Height = 185
    Ctl3D = False
    GridLineWidth = 2
    ParentCtl3D = False
    Strings.Strings = (
      'StStatus=0'
      'StType=0'
      'StSector_Offset=0'
      'StSector_Size=0'
      'StFrame_No=0'
      'StFrameSize=0'
      'StUser=0'
      'Position=0')
    TabOrder = 0
    TitleCaptions.Strings = (
      'Parameter'
      'Value'
      'Hex')
    ColWidths = (
      118
      127)
  end
  object SectorBar: TTrackBar
    Left = 16
    Top = 216
    Width = 233
    Height = 25
    Max = 1000
    PageSize = 15
    TabOrder = 1
    OnChange = SectorBarChange
  end
  object FrameBar: TTrackBar
    Left = 16
    Top = 304
    Width = 233
    Height = 25
    TabOrder = 2
    OnChange = FrameBarChange
  end
  object Button1: TButton
    Left = 208
    Top = 248
    Width = 33
    Height = 17
    Caption = 'Go'
    TabOrder = 3
  end
  object Edit1: TEdit
    Left = 136
    Top = 248
    Width = 65
    Height = 21
    TabOrder = 4
    Text = '0'
  end
  object Button2: TButton
    Left = 96
    Top = 248
    Width = 33
    Height = 17
    Caption = '>'
    TabOrder = 6
  end
  object Button3: TButton
    Left = 304
    Top = 24
    Width = 81
    Height = 41
    Caption = 'Button3'
    TabOrder = 7
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 344
    Top = 136
    Width = 41
    Height = 25
    Caption = 'Button4'
    TabOrder = 9
    OnClick = Button4Click
  end
  object MainMenu1: TMainMenu
    Left = 648
    Top = 8
    object File1: TMenuItem
      Caption = 'File'
      object LoadStream1: TMenuItem
        Action = aLoad
        Caption = 'Load Stream...'
      end
    end
  end
  object ActionList1: TActionList
    Left = 648
    Top = 40
    object aLoad: TAction
      OnExecute = aLoadExecute
    end
  end
  object Op: TOpenDialog
    Left = 648
    Top = 72
  end
  object XPManifest1: TXPManifest
    Left = 648
    Top = 104
  end
end
