object Form1: TForm1
  Left = 81
  Top = 44
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Little Ninja Brothers password generator by HoRRoR (v0.8a)'
  ClientHeight = 401
  ClientWidth = 668
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Screen: TDXDraw
    Left = 8
    Top = 8
    Width = 256
    Height = 249
    Hint = 'Click here and input password'
    AutoInitialize = True
    AutoSize = True
    Color = clBtnFace
    Display.FixedBitCount = True
    Display.FixedRatio = True
    Display.FixedSize = False
    Options = [doAllowReboot, doWaitVBlank, doCenter, doDirectX7Mode, doHardware, doSelectDriver]
    SurfaceHeight = 249
    SurfaceWidth = 256
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    TabStop = True
    OnClick = ScreenClick
    OnEnter = ScreenEnter
    OnExit = ScreenExit
    OnKeyDown = ScreenKeyDown
    OnKeyPress = ScreenKeyPress
    OnKeyUp = ScreenKeyUp
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 264
    Width = 209
    Height = 129
    Caption = ' Players: '
    Ctl3D = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 1
    object Label1: TLabel
      Left = 18
      Top = 16
      Width = 29
      Height = 14
      Alignment = taRightJustify
      Caption = 'Level:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 111
      Top = 16
      Width = 21
      Height = 14
      Alignment = taRightJustify
      Caption = 'Exp:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 13
      Top = 40
      Width = 34
      Height = 14
      Alignment = taRightJustify
      Caption = 'Attack:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 93
      Top = 64
      Width = 39
      Height = 14
      Alignment = taRightJustify
      Caption = 'Max HP:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label7: TLabel
      Left = 97
      Top = 40
      Width = 35
      Height = 14
      Alignment = taRightJustify
      Caption = 'Money:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label8: TLabel
      Left = 28
      Top = 64
      Width = 19
      Height = 14
      Alignment = taRightJustify
      Caption = 'M'#39's:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object eLevel: TSpinEdit
      Left = 48
      Top = 16
      Width = 41
      Height = 23
      Ctl3D = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxLength = 2
      MaxValue = 50
      MinValue = 1
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
      Value = 1
      OnChange = eLevelChange
    end
    object eAttack: TEdit
      Left = 48
      Top = 40
      Width = 41
      Height = 20
      Ctl3D = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      ReadOnly = True
      TabOrder = 2
      Text = '1'
    end
    object eExp: TSpinEdit
      Left = 136
      Top = 16
      Width = 57
      Height = 23
      Ctl3D = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxLength = 5
      MaxValue = 65535
      MinValue = 0
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 1
      Value = 0
      OnChange = eExpChange
    end
    object eMoney: TSpinEdit
      Left = 136
      Top = 40
      Width = 57
      Height = 23
      Ctl3D = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxLength = 5
      MaxValue = 99999
      MinValue = 0
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 3
      Value = 160
      OnChange = eMoneyChange
    end
    object eM: TSpinEdit
      Left = 48
      Top = 64
      Width = 41
      Height = 23
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxValue = 6
      MinValue = 0
      ParentFont = False
      TabOrder = 4
      Value = 0
      OnChange = eMoneyChange
    end
    object eMaxHP: TEdit
      Left = 136
      Top = 64
      Width = 57
      Height = 20
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 5
      Text = '10'
    end
  end
  object GroupBox2: TGroupBox
    Left = 272
    Top = 0
    Width = 145
    Height = 257
    Caption = ' Equip: '
    Ctl3D = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 3
    object Label11: TLabel
      Left = 13
      Top = 40
      Width = 36
      Height = 14
      Alignment = taRightJustify
      Caption = 'Sword:'
    end
    object Label12: TLabel
      Left = 16
      Top = 16
      Width = 33
      Height = 14
      Alignment = taRightJustify
      Caption = 'Punch:'
    end
    object Label13: TLabel
      Left = 17
      Top = 64
      Width = 32
      Height = 14
      Alignment = taRightJustify
      Caption = 'Shield:'
    end
    object Label14: TLabel
      Left = 21
      Top = 88
      Width = 28
      Height = 14
      Alignment = taRightJustify
      Caption = 'Robe:'
    end
    object Label15: TLabel
      Left = 4
      Top = 112
      Width = 45
      Height = 14
      Alignment = taRightJustify
      Caption = 'Talisman:'
    end
    object Label16: TLabel
      Left = 13
      Top = 136
      Width = 36
      Height = 14
      Alignment = taRightJustify
      Caption = 'Amulet:'
    end
    object Label17: TLabel
      Left = 23
      Top = 160
      Width = 26
      Height = 14
      Alignment = taRightJustify
      Caption = 'Light:'
    end
    object Label18: TLabel
      Left = 10
      Top = 184
      Width = 39
      Height = 14
      Alignment = taRightJustify
      Caption = 'T-Stars:'
    end
    object eEqPunch: TComboBox
      Left = 52
      Top = 16
      Width = 85
      Height = 22
      Style = csDropDownList
      Ctl3D = False
      ItemHeight = 14
      ItemIndex = 0
      ParentCtl3D = False
      TabOrder = 0
      Text = 'Nothing'
      OnChange = eEqPunchChange
      Items.Strings = (
        'Nothing'
        'Iron Claw'
        'Crush Punch'
        'Mega Punch'
        'Fire Punch'
        'Blunt Punch'
        'Golden Claw'
        'Lee'#39's Punch'
        'Prism Claw')
    end
    object eEqSword: TComboBox
      Left = 52
      Top = 40
      Width = 85
      Height = 22
      Style = csDropDownList
      ItemHeight = 14
      ItemIndex = 0
      TabOrder = 1
      Text = 'Nothing'
      OnChange = eEqPunchChange
      Items.Strings = (
        'Nothing'
        'Hawk Sword'
        'Hawk Sword'
        'Tiger Sword'
        'Eagle Sword'
        'Prism Sword')
    end
    object eEqShield: TComboBox
      Left = 52
      Top = 64
      Width = 85
      Height = 22
      Style = csDropDownList
      ItemHeight = 14
      ItemIndex = 0
      TabOrder = 2
      Text = 'Nothing'
      OnChange = eEqPunchChange
      Items.Strings = (
        'Nothing'
        'Scale Shield'
        'Mirror Shield'
        'Fire Shield'
        'Prism Shield')
    end
    object eEqRobe: TComboBox
      Left = 52
      Top = 88
      Width = 85
      Height = 22
      Style = csDropDownList
      ItemHeight = 14
      ItemIndex = 0
      TabOrder = 3
      Text = 'Nothing'
      OnChange = eEqPunchChange
      Items.Strings = (
        'Nothing'
        'White Robe'
        'Black Robe'
        'Lee'#39's Robe'
        'Sacred Robe')
    end
    object eEqTalisman: TComboBox
      Left = 52
      Top = 112
      Width = 85
      Height = 22
      Style = csDropDownList
      ItemHeight = 14
      ItemIndex = 0
      TabOrder = 4
      Text = 'Nothing'
      OnChange = eEqPunchChange
      Items.Strings = (
        'Nothing'
        'Talisman-a'
        'Talisman-B'
        'Talisman ???'
        'Talisman-Y'
        'Talisman-E'
        'Talisman-Omega'
        'Talisman ???')
    end
    object eEqAmulet: TComboBox
      Left = 52
      Top = 136
      Width = 85
      Height = 22
      Style = csDropDownList
      ItemHeight = 14
      ItemIndex = 0
      TabOrder = 5
      Text = 'Nothing'
      OnChange = eEqPunchChange
      Items.Strings = (
        'Nothing'
        'Amulet-I'
        'Amulet-II'
        'Amulet ???'
        'Amulet ???'
        'Amulet-III'
        'Amulet-IV')
    end
    object eEqLight: TComboBox
      Left = 52
      Top = 160
      Width = 85
      Height = 22
      Style = csDropDownList
      ItemHeight = 14
      ItemIndex = 0
      TabOrder = 6
      Text = 'Nothing'
      OnChange = eEqPunchChange
      Items.Strings = (
        'Nothing'
        'Match'
        'Candle'
        'Torch'
        'Piece of the Sun')
    end
    object eEqSS: TCheckBox
      Left = 52
      Top = 184
      Width = 73
      Height = 17
      Caption = 'Single'
      TabOrder = 7
      OnClick = eEqPunchChange
    end
    object eEqSV: TCheckBox
      Left = 52
      Top = 200
      Width = 73
      Height = 17
      Caption = 'Volley'
      TabOrder = 8
      OnClick = eEqPunchChange
    end
    object eEqSB: TCheckBox
      Left = 52
      Top = 216
      Width = 73
      Height = 17
      Caption = 'Boomerang'
      TabOrder = 9
      OnClick = eEqPunchChange
    end
    object eEqSF: TCheckBox
      Left = 52
      Top = 232
      Width = 81
      Height = 17
      Caption = 'Fixer'
      TabOrder = 10
      OnClick = eEqPunchChange
    end
  end
  object GroupBox3: TGroupBox
    Left = 544
    Top = 0
    Width = 113
    Height = 185
    Caption = ' Visited Cities: '
    Ctl3D = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 5
    object eCity001: TCheckBox
      Left = 8
      Top = 64
      Width = 65
      Height = 17
      Caption = 'Okay'
      TabOrder = 3
      OnClick = eCity080Click
    end
    object eCity002: TCheckBox
      Left = 8
      Top = 48
      Width = 73
      Height = 17
      Caption = 'Cilly City'
      TabOrder = 2
      OnClick = eCity080Click
    end
    object eCity004: TCheckBox
      Left = 8
      Top = 96
      Width = 73
      Height = 17
      Caption = 'Shorin'
      TabOrder = 5
      OnClick = eCity080Click
    end
    object eCity008: TCheckBox
      Left = 8
      Top = 128
      Width = 73
      Height = 17
      Caption = 'Ling-Rang'
      TabOrder = 7
      OnClick = eCity080Click
    end
    object eCity010: TCheckBox
      Left = 8
      Top = 80
      Width = 73
      Height = 17
      Caption = 'Yokan'
      TabOrder = 4
      OnClick = eCity080Click
    end
    object eCity020: TCheckBox
      Left = 8
      Top = 144
      Width = 105
      Height = 17
      Caption = 'Ling-Rang, basement'
      TabOrder = 8
      OnClick = eCity080Click
    end
    object eCity040: TCheckBox
      Left = 8
      Top = 32
      Width = 73
      Height = 17
      Caption = 'Deli-Chous'
      TabOrder = 1
      OnClick = eCity080Click
    end
    object eCity080: TCheckBox
      Left = 8
      Top = 16
      Width = 73
      Height = 17
      Caption = 'Hynen'
      TabOrder = 0
      OnClick = eCity080Click
    end
    object eCity100: TCheckBox
      Left = 8
      Top = 112
      Width = 73
      Height = 17
      Caption = 'Chatzy'
      TabOrder = 6
      OnClick = eCity080Click
    end
    object eCity200: TCheckBox
      Left = 8
      Top = 160
      Width = 73
      Height = 17
      Caption = 'unknown'
      TabOrder = 9
      OnClick = eCity080Click
    end
  end
  object GroupBox4: TGroupBox
    Left = 424
    Top = 0
    Width = 113
    Height = 257
    Caption = ' Items: '
    Ctl3D = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 4
    object Label19: TLabel
      Left = 14
      Top = 16
      Width = 57
      Height = 14
      Alignment = taRightJustify
      Caption = 'Sweet Bun:'
    end
    object Label20: TLabel
      Left = 23
      Top = 40
      Width = 48
      Height = 14
      Alignment = taRightJustify
      Caption = 'Meat Bun:'
    end
    object Label21: TLabel
      Left = 15
      Top = 64
      Width = 55
      Height = 14
      Alignment = taRightJustify
      Caption = 'Whirly Bird:'
    end
    object Label22: TLabel
      Left = 26
      Top = 88
      Width = 45
      Height = 14
      Alignment = taRightJustify
      Caption = 'Medicine:'
    end
    object Label23: TLabel
      Left = 23
      Top = 112
      Width = 48
      Height = 14
      Alignment = taRightJustify
      Caption = 'Sk-Board:'
    end
    object Label24: TLabel
      Left = 19
      Top = 136
      Width = 52
      Height = 14
      Alignment = taRightJustify
      Caption = 'Boo Bomb:'
    end
    object Label25: TLabel
      Left = 26
      Top = 160
      Width = 45
      Height = 14
      Alignment = taRightJustify
      Caption = 'Dragstar:'
    end
    object Label26: TLabel
      Left = 33
      Top = 184
      Width = 38
      Height = 14
      Alignment = taRightJustify
      Caption = 'Battery:'
    end
    object Label27: TLabel
      Left = 32
      Top = 208
      Width = 39
      Height = 14
      Alignment = taRightJustify
      Caption = 'T-Stars:'
    end
    object Label9: TLabel
      Left = 28
      Top = 232
      Width = 43
      Height = 14
      Alignment = taRightJustify
      Caption = 'Jack K'#39's:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object eSweetBun: TSpinEdit
      Left = 72
      Top = 16
      Width = 33
      Height = 23
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxValue = 8
      MinValue = 0
      ParentFont = False
      TabOrder = 0
      Value = 0
      OnChange = eSweetBunChange
    end
    object eMeatBun: TSpinEdit
      Left = 72
      Top = 40
      Width = 33
      Height = 23
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxValue = 1
      MinValue = 0
      ParentFont = False
      TabOrder = 1
      Value = 0
      OnChange = eSweetBunChange
    end
    object eWhirlyBird: TSpinEdit
      Left = 72
      Top = 64
      Width = 33
      Height = 23
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxValue = 8
      MinValue = 0
      ParentFont = False
      TabOrder = 2
      Value = 0
      OnChange = eSweetBunChange
    end
    object eMedicine: TSpinEdit
      Left = 72
      Top = 88
      Width = 33
      Height = 23
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxValue = 1
      MinValue = 0
      ParentFont = False
      TabOrder = 3
      Value = 0
      OnChange = eSweetBunChange
    end
    object eSkBoard: TSpinEdit
      Left = 72
      Top = 112
      Width = 33
      Height = 23
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxValue = 8
      MinValue = 0
      ParentFont = False
      TabOrder = 4
      Value = 0
      OnChange = eSweetBunChange
    end
    object eBooBomb: TSpinEdit
      Left = 72
      Top = 136
      Width = 33
      Height = 23
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxValue = 8
      MinValue = 0
      ParentFont = False
      TabOrder = 5
      Value = 0
      OnChange = eSweetBunChange
    end
    object eDragstar: TSpinEdit
      Left = 72
      Top = 160
      Width = 33
      Height = 23
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxValue = 1
      MinValue = 0
      ParentFont = False
      TabOrder = 6
      Value = 0
      OnChange = eSweetBunChange
    end
    object eBattery: TSpinEdit
      Left = 72
      Top = 184
      Width = 33
      Height = 23
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxValue = 8
      MinValue = 0
      ParentFont = False
      TabOrder = 7
      Value = 0
      OnChange = eSweetBunChange
    end
    object eTStars: TSpinEdit
      Left = 72
      Top = 208
      Width = 33
      Height = 23
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxValue = 8
      MinValue = 0
      ParentFont = False
      TabOrder = 8
      Value = 0
      OnChange = eSweetBunChange
    end
    object eJK: TSpinEdit
      Left = 72
      Top = 232
      Width = 33
      Height = 23
      MaxValue = 99
      MinValue = 0
      TabOrder = 9
      Value = 0
      OnChange = eSweetBunChange
    end
  end
  object ePass: TEdit
    Left = 8
    Top = 408
    Width = 305
    Height = 21
    TabStop = False
    TabOrder = 7
    Text = '2WBL443X3P33tJ337X3X3sN332tc-Z3Z6sN44'
    Visible = False
  end
  object Button1: TButton
    Left = 320
    Top = 408
    Width = 33
    Height = 17
    Caption = 'Conv'
    TabOrder = 8
    TabStop = False
    Visible = False
    OnClick = Button1Click
  end
  object GroupBox5: TGroupBox
    Left = 544
    Top = 192
    Width = 113
    Height = 201
    Caption = ' Bells and Treasure: '
    Ctl3D = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 6
    object eBell01: TCheckBox
      Left = 8
      Top = 16
      Width = 89
      Height = 17
      Caption = 'Red Bell'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = eBell01Click
    end
    object eBell02: TCheckBox
      Left = 8
      Top = 32
      Width = 81
      Height = 17
      Caption = 'Orange Bell'
      TabOrder = 1
      OnClick = eBell01Click
    end
    object eBell04: TCheckBox
      Left = 8
      Top = 48
      Width = 73
      Height = 17
      Caption = 'Yellow Bell'
      TabOrder = 2
      OnClick = eBell01Click
    end
    object eBell08: TCheckBox
      Left = 8
      Top = 64
      Width = 73
      Height = 17
      Caption = 'Green Bell'
      TabOrder = 3
      OnClick = eBell01Click
    end
    object eBell10: TCheckBox
      Left = 8
      Top = 80
      Width = 89
      Height = 17
      Caption = 'Dark Blue Bell'
      TabOrder = 4
      OnClick = eBell01Click
    end
    object eBell20: TCheckBox
      Left = 8
      Top = 96
      Width = 89
      Height = 17
      Caption = 'Light Blue Bell'
      TabOrder = 5
      OnClick = eBell01Click
    end
    object eBell40: TCheckBox
      Left = 8
      Top = 112
      Width = 89
      Height = 17
      Caption = 'Magenta Bell'
      TabOrder = 6
      OnClick = eBell01Click
    end
    object eEqAntidote: TCheckBox
      Left = 8
      Top = 128
      Width = 81
      Height = 17
      Caption = 'Antidote'
      TabOrder = 7
      OnClick = eBell01Click
    end
    object eEqMind: TCheckBox
      Left = 8
      Top = 144
      Width = 73
      Height = 17
      Caption = 'Mind'
      TabOrder = 8
      OnClick = eBell01Click
    end
    object eEqPop: TCheckBox
      Left = 8
      Top = 160
      Width = 89
      Height = 17
      Caption = 'Pop'
      TabOrder = 9
      OnClick = eBell01Click
    end
  end
  object GroupBox6: TGroupBox
    Left = 224
    Top = 264
    Width = 217
    Height = 65
    Caption = ' Location and events: '
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 2
    object eLoc: TComboBox
      Left = 8
      Top = 16
      Width = 201
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = '00 Mt. Epin (Begining)'
      OnClick = eBell01Click
      Items.Strings = (
        '00 Mt. Epin (Begining)'
        '01 Ling-Rang'
        '02 Mt. Cone-Rum'
        '03 Secret entrace to Cone-Rum'
        '04 Yokan'
        '05 Shinshin Tower'
        '06 unknown'
        '07 unknown'
        '08 unknown'
        '09 unknown'
        '0A unknown'
        '0B unknown'
        '0C unknown'
        '0D unknown'
        '0E unknown'
        '0F unknown'
        '10 unknown'
        '11 unknown'
        '12 unknown'
        '13 unknown'
        '14 unknown'
        '15 unknown'
        '16 unknown'
        '17 unknown'
        '18 unknown'
        '19 unknown'
        '1A unknown'
        '1B unknown'
        '1C unknown'
        '1D unknown'
        '1E unknown'
        '1F unknown'
        '20 unknown'
        '21 unknown'
        '22 unknown'
        '23 unknown'
        '24 unknown'
        '25 unknown'
        '26 unknown'
        '27 unknown'
        '28 unknown'
        '29 unknown'
        '2A unknown'
        '2B unknown'
        '2C unknown'
        '2D unknown'
        '2E unknown'
        '2F unknown'
        '30 unknown'
        '31 unknown'
        '32 unknown'
        '33 unknown'
        '34 unknown'
        '35 unknown'
        '36 unknown'
        '37 unknown'
        '38 unknown'
        '39 unknown'
        '3A unknown'
        '3B unknown'
        '3C unknown'
        '3D unknown'
        '3E unknown'
        '3F unknown'
        '40 unknown'
        '41 unknown'
        '42 unknown'
        '43 unknown'
        '44 unknown'
        '45 unknown'
        '46 unknown'
        '47 unknown'
        '48 unknown'
        '49 unknown'
        '4A unknown'
        '4B unknown'
        '4C unknown'
        '4D unknown'
        '4E unknown'
        '4F unknown'
        '50 unknown'
        '51 unknown'
        '52 unknown'
        '53 unknown'
        '54 unknown'
        '55 unknown'
        '56 unknown'
        '57 unknown'
        '58 unknown'
        '59 Cave north from Chatzy (Level 2)'
        '5A Water Lily Palace (W)'
        '5B Water Lily Palace'
        '5C Yokan (Part 2)'
        '5D Yokan (Part 2)'
        '5E Okay (C)'
        '5F Cilly-City (C)'
        '60 Shorin (C)'
        '61 Ling-Rang'
        '62 Yokan (Part 2, Shop)'
        '63 Yokan (C)'
        '64 Ling-Rang (und)'
        '65 Deli-Chous (C)'
        '66 Hynen (C)'
        '67 unknown'
        '68 unknown'
        '69 unknown'
        '6A unknown'
        '6B unknown'
        '6C unknown'
        '6D unknown'
        '6E unknown'
        '6F unknown'
        '70 unknown'
        '71 unknown'
        '72 unknown'
        '73 unknown'
        '74 unknown'
        '75 unknown'
        '76 unknown'
        '77 unknown'
        '78 unknown'
        '79 unknown'
        '7A unknown'
        '7B unknown'
        '7C unknown'
        '7D unknown'
        '7E unknown'
        '7F unknown'
        '80 unknown'
        '81 unknown'
        '82 unknown'
        '83 unknown'
        '84 unknown'
        '85 unknown'
        '86 unknown'
        '87 unknown'
        '88 unknown'
        '89 unknown'
        '8A unknown'
        '8B unknown'
        '8C unknown'
        '8D unknown'
        '8E unknown'
        '8F unknown'
        '90 unknown'
        '91 unknown'
        '92 unknown'
        '93 unknown'
        '94 unknown'
        '95 unknown'
        '96 unknown'
        '97 unknown'
        '98 unknown'
        '99 unknown'
        '9A unknown'
        '9B unknown'
        '9C unknown'
        '9D unknown'
        '9E unknown'
        '9F unknown'
        'A0 unknown'
        'A1 unknown'
        'A2 unknown'
        'A3 unknown'
        'A4 unknown'
        'A5 unknown'
        'A6 unknown'
        'A7 unknown'
        'A8 unknown'
        'A9 unknown'
        'AA unknown'
        'AB unknown'
        'AC unknown'
        'AD unknown'
        'AE unknown'
        'AF unknown'
        'B0 unknown'
        'B1 unknown'
        'B2 unknown'
        'B3 unknown'
        'B4 unknown'
        'B5 unknown'
        'B6 unknown'
        'B7 unknown'
        'B8 unknown'
        'B9 unknown'
        'BA unknown'
        'BB unknown'
        'BC unknown'
        'BD unknown'
        'BE unknown'
        'BF unknown'
        'C0 unknown'
        'C1 unknown'
        'C2 unknown'
        'C3 unknown'
        'C4 unknown'
        'C5 unknown'
        'C6 unknown'
        'C7 unknown'
        'C8 unknown'
        'C9 unknown'
        'CA unknown'
        'CB unknown'
        'CC unknown'
        'CD unknown'
        'CE unknown'
        'CF unknown'
        'D0 unknown'
        'D1 unknown'
        'D2 unknown'
        'D3 unknown'
        'D4 unknown'
        'D5 unknown'
        'D6 unknown'
        'D7 unknown'
        'D8 unknown'
        'D9 unknown'
        'DA unknown'
        'DB unknown'
        'DC unknown'
        'DD unknown'
        'DE unknown'
        'DF unknown'
        'E0 unknown'
        'E1 unknown'
        'E2 unknown'
        'E3 unknown'
        'E4 unknown'
        'E5 unknown'
        'E6 unknown'
        'E7 unknown'
        'E8 unknown'
        'E9 unknown'
        'EA unknown'
        'EB unknown'
        'EC unknown'
        'ED unknown'
        'EE unknown'
        'EF unknown'
        'F0 unknown'
        'F1 unknown'
        'F2 unknown'
        'F3 unknown'
        'F4 unknown'
        'F5 unknown'
        'F6 unknown'
        'F7 unknown'
        'F8 unknown'
        'F9 unknown'
        'FA unknown'
        'FB unknown'
        'FC unknown'
        'FD unknown'
        'FE unknown'
        'FF unknown')
    end
    object eAUsed: TCheckBox
      Left = 8
      Top = 40
      Width = 97
      Height = 17
      Caption = 'Antidote used'
      TabOrder = 1
      OnClick = eBell01Click
    end
  end
  object Button2: TButton
    Left = 360
    Top = 408
    Width = 41
    Height = 17
    Caption = 'Set'
    TabOrder = 9
    TabStop = False
    Visible = False
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 408
    Top = 408
    Width = 33
    Height = 17
    Caption = 'Get'
    TabOrder = 10
    TabStop = False
    Visible = False
    OnClick = Button3Click
  end
  object GroupBox8: TGroupBox
    Left = 448
    Top = 264
    Width = 89
    Height = 129
    Caption = ' Password: '
    Ctl3D = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 11
    object Label5: TLabel
      Left = 11
      Top = 16
      Width = 23
      Height = 14
      Alignment = taRightJustify
      Caption = 'PCS:'
    end
    object Label6: TLabel
      Left = 10
      Top = 40
      Width = 24
      Height = 14
      Alignment = taRightJustify
      Caption = 'DCS:'
    end
    object Label28: TLabel
      Left = 10
      Top = 64
      Width = 24
      Height = 14
      Alignment = taRightJustify
      Caption = 'Incr.:'
    end
    object ePCS: TEdit
      Left = 40
      Top = 16
      Width = 41
      Height = 20
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      Text = '-----'
    end
    object eDCS: TEdit
      Left = 40
      Top = 40
      Width = 41
      Height = 20
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
      Text = '-----'
    end
    object eDecr: TComboBox
      Left = 40
      Top = 64
      Width = 41
      Height = 22
      Style = csDropDownList
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ItemHeight = 14
      ItemIndex = 0
      ParentFont = False
      TabOrder = 2
      Text = 'Rnd'
      Items.Strings = (
        'Rnd'
        '00'
        '01'
        '02'
        '03'
        '04'
        '05'
        '06'
        '07'
        '08'
        '09'
        '0A'
        '0B'
        '0C'
        '0D'
        '0E'
        '0F'
        '10'
        '11'
        '12'
        '13'
        '14'
        '15'
        '16'
        '17'
        '18'
        '19'
        '1A'
        '1B'
        '1C'
        '1D'
        '1E'
        '1F')
    end
    object eAutogen: TCheckBox
      Left = 8
      Top = 88
      Width = 73
      Height = 17
      Caption = 'Autogen'
      TabOrder = 3
      OnClick = eAutogenClick
    end
    object eOriginal: TCheckBox
      Left = 8
      Top = 104
      Width = 65
      Height = 17
      Caption = 'Original'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = eOriginalClick
    end
  end
  object GroupBox7: TGroupBox
    Left = 224
    Top = 336
    Width = 217
    Height = 57
    Caption = ' Info: '
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 12
    object Label10: TLabel
      Left = 1
      Top = 14
      Width = 205
      Height = 13
      Align = alCustom
      Alignment = taCenter
      Caption = '   Little Ninja Brothers PasGen by HoRRoR '
    end
    object Label29: TLabel
      Left = 1
      Top = 32
      Width = 198
      Height = 13
      Align = alCustom
      Alignment = taCenter
      Caption = '    horror.cg@gmail.com :: ho-rr-or@mail.ru'
    end
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 16
    object File1: TMenuItem
      Caption = 'File'
      object Exit1: TMenuItem
        Action = AExit
      end
    end
    object Password1: TMenuItem
      Caption = 'Password'
      object Generate1: TMenuItem
        Action = AGenPass
      end
      object Applypassword1: TMenuItem
        Action = AEnterPass
      end
      object Recovery1: TMenuItem
        Action = ARecPass
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object About1: TMenuItem
        Action = AAbout
      end
    end
  end
  object ActionList1: TActionList
    Left = 48
    Top = 16
    object AExit: TAction
      Caption = 'Exit'
      OnExecute = AExitExecute
    end
    object AGenPass: TAction
      Caption = 'Generate'
      ShortCut = 116
      OnExecute = AGenPassExecute
    end
    object ARecPass: TAction
      Caption = 'Recovery...'
      ShortCut = 16466
    end
    object AAbout: TAction
      Caption = 'About...'
      ShortCut = 112
      OnExecute = AAboutExecute
    end
    object AEnterPass: TAction
      Caption = 'Apply'
      ShortCut = 120
      OnExecute = AEnterPassExecute
    end
  end
end
