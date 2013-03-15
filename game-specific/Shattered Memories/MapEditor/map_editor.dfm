object MainForm: TMainForm
  Left = 475
  Top = 209
  BorderStyle = bsToolWindow
  Caption = 'Shattered Memories Map Editor'
  ClientHeight = 298
  ClientWidth = 359
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  Menu = MainMenu1
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox3: TGroupBox
    Left = 168
    Top = 64
    Width = 185
    Height = 185
    Caption = 'Properties'
    TabOrder = 5
    object Label1: TLabel
      Left = 8
      Top = 20
      Width = 49
      Height = 13
      Caption = 'Caption X:'
    end
    object Label2: TLabel
      Left = 8
      Top = 44
      Width = 46
      Height = 13
      Caption = 'Caption Y'
    end
    object Label3: TLabel
      Left = 8
      Top = 72
      Width = 47
      Height = 13
      Caption = 'Font Size:'
    end
    object Label4: TLabel
      Left = 8
      Top = 96
      Width = 30
      Height = 13
      Caption = 'Angle:'
    end
    object Label5: TLabel
      Left = 8
      Top = 116
      Width = 27
      Height = 13
      Caption = 'Color:'
    end
    object eX: TEdit
      Left = 72
      Top = 20
      Width = 97
      Height = 21
      MaxLength = 20
      TabOrder = 0
      Text = '0,0000'
      OnChange = eXChange
      OnKeyPress = FloatKeyPress
    end
    object eY: TEdit
      Left = 72
      Top = 44
      Width = 97
      Height = 21
      MaxLength = 20
      TabOrder = 1
      Text = '0,0000'
      OnChange = eYChange
    end
    object eAngle: TEdit
      Left = 72
      Top = 92
      Width = 97
      Height = 21
      MaxLength = 20
      TabOrder = 2
      Text = '0,0000'
      OnChange = eAngleChange
    end
    object eSize: TEdit
      Left = 72
      Top = 68
      Width = 97
      Height = 21
      MaxLength = 20
      TabOrder = 3
      Text = '0,0000'
      OnChange = eSizeChange
    end
    object eColors: TComboBox
      Left = 72
      Top = 116
      Width = 97
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 4
      OnChange = eColorsChange
    end
    object Button1: TButton
      Left = 72
      Top = 144
      Width = 97
      Height = 25
      Caption = 'Undo'
      TabOrder = 5
      OnClick = Button1Click
    end
  end
  object Layers: TGroupBox
    Left = 8
    Top = 8
    Width = 153
    Height = 49
    Caption = 'Layers'
    TabOrder = 0
    object eLayers: TComboBox
      Left = 8
      Top = 16
      Width = 137
      Height = 21
      Style = csDropDownList
      Enabled = False
      ItemHeight = 13
      TabOrder = 0
      OnChange = eLayersChange
    end
  end
  object eCurOnly: TCheckBox
    Left = 168
    Top = 272
    Width = 137
    Height = 17
    Action = ACurOnly
    TabOrder = 1
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 64
    Width = 153
    Height = 225
    Caption = 'Captions'
    TabOrder = 2
    object eCaptions: TListBox
      Left = 8
      Top = 16
      Width = 137
      Height = 201
      Enabled = False
      ItemHeight = 13
      PopupMenu = PopupMenu
      TabOrder = 0
      OnClick = eCaptionsClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 168
    Top = 8
    Width = 185
    Height = 49
    Caption = 'Text'
    TabOrder = 3
    object eCaption: TEdit
      Left = 8
      Top = 16
      Width = 169
      Height = 21
      Enabled = False
      TabOrder = 0
      OnChange = eCaptionChange
    end
  end
  object eOnTop: TCheckBox
    Left = 168
    Top = 256
    Width = 81
    Height = 17
    Action = AOnTop
    State = cbChecked
    TabOrder = 4
  end
  object MainMenu1: TMainMenu
    Left = 24
    Top = 96
    object File1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Action = AOpen
      end
      object Save1: TMenuItem
        Action = ASave
      end
      object SaveAs1: TMenuItem
        Action = ASaveAs
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object InsertString1: TMenuItem
        Action = AInsertString
      end
      object DeleteString1: TMenuItem
        Action = ADeleteString
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      object OnTop1: TMenuItem
        Action = AOnTop
      end
      object Showcurrentlayeronly1: TMenuItem
        Action = ACurOnly
      end
      object AViewMap1: TMenuItem
        Action = AViewMap
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object Hotkeys1: TMenuItem
        Caption = 'Controls'
        OnClick = Hotkeys1Click
      end
      object About1: TMenuItem
        Caption = 'About'
        OnClick = About1Click
      end
    end
  end
  object ActionList1: TActionList
    Left = 56
    Top = 96
    object AOpen: TAction
      Caption = 'Open...'
      ShortCut = 16463
      OnExecute = AOpenExecute
    end
    object ASave: TAction
      Caption = 'Save'
      Enabled = False
      ShortCut = 16467
      OnExecute = ASaveExecute
    end
    object ASaveAs: TAction
      Caption = 'Save As...'
      Enabled = False
      ShortCut = 24659
      OnExecute = ASaveAsExecute
    end
    object AOnTop: TAction
      Caption = 'On Top'
      Checked = True
      OnExecute = AOnTopExecute
    end
    object ACurOnly: TAction
      Caption = 'Show selected layer only'
      OnExecute = ACurOnlyExecute
    end
    object ADeleteString: TAction
      Caption = 'Remove String'
      OnExecute = ADeleteStringExecute
    end
    object AInsertString: TAction
      Caption = 'Insert String'
      OnExecute = AInsertStringExecute
    end
    object AViewMap: TAction
      Caption = 'View Map'
      OnExecute = AViewMapExecute
    end
  end
  object OpenDialog: TOpenDialog
    FileName = 'UI_Map.rws'
    Filter = 'Map Files|*.rws'
    Left = 24
    Top = 128
  end
  object SaveDialog: TSaveDialog
    Filter = 'Map File (*.rws)|*.rws'
    Left = 56
    Top = 128
  end
  object PopupMenu: TPopupMenu
    Left = 88
    Top = 96
    object InsertString2: TMenuItem
      Action = AInsertString
    end
    object DeleteString2: TMenuItem
      Action = ADeleteString
    end
  end
end
