object Form1: TForm1
  Left = 8
  Top = 188
  AutoScroll = False
  Caption = 'FFx - Bitmap Font Text Viewer'
  ClientHeight = 674
  ClientWidth = 1027
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnMouseMove = FormMouseMove
  PixelsPerInch = 96
  TextHeight = 13
  object LBlock: TLabel
    Left = 8
    Top = 200
    Width = 28
    Height = 13
    Caption = #1041#1083#1086#1082':'
  end
  object GroupBox1: TGroupBox
    Left = 904
    Top = 32
    Width = 113
    Height = 153
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099':'
    TabOrder = 27
    object Label1: TLabel
      Left = 8
      Top = 16
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object Label2: TLabel
      Left = 64
      Top = 16
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object Label3: TLabel
      Left = 8
      Top = 40
      Width = 11
      Height = 13
      Caption = 'D:'
    end
    object Label4: TLabel
      Left = 0
      Top = 64
      Width = 22
      Height = 13
      Caption = 'WH:'
    end
    object Label5: TLabel
      Left = 56
      Top = 64
      Width = 25
      Height = 13
      Caption = 'WW:'
    end
    object Label6: TLabel
      Left = 0
      Top = 88
      Width = 21
      Height = 13
      Caption = 'WX:'
    end
    object Label7: TLabel
      Left = 56
      Top = 88
      Width = 21
      Height = 13
      Caption = 'WY:'
    end
    object Label8: TLabel
      Left = 56
      Top = 40
      Width = 16
      Height = 13
      Caption = 'LC:'
    end
    object Label9: TLabel
      Left = 8
      Top = 112
      Width = 16
      Height = 13
      Caption = 'Av:'
    end
    object Label10: TLabel
      Left = 64
      Top = 112
      Width = 16
      Height = 13
      Caption = 'Sc:'
    end
  end
  object List: TListBox
    Left = 8
    Top = 32
    Width = 385
    Height = 161
    ItemHeight = 13
    TabOrder = 0
    OnClick = ListClick
  end
  object Text: TMemo
    Left = 400
    Top = 32
    Width = 377
    Height = 161
    Lines.Strings = (
      'Text')
    ScrollBars = ssBoth
    TabOrder = 1
    OnChange = TextChange
  end
  object FontAdr: TEdit
    Left = 592
    Top = 192
    Width = 17
    Height = 21
    TabOrder = 2
    Text = 'ff4fnt.bmp'
    Visible = False
  end
  object FontTxt: TEdit
    Left = 608
    Top = 192
    Width = 17
    Height = 21
    TabOrder = 3
    Text = 'ff4txt.txt'
    Visible = False
  end
  object Button3: TButton
    Left = 624
    Top = 192
    Width = 17
    Height = 25
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    TabOrder = 4
    Visible = False
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 784
    Top = 120
    Width = 113
    Height = 17
    Caption = #1055#1086#1082#1072#1079#1072#1090#1100
    TabOrder = 5
    OnClick = Button4Click
  end
  object DXDraw1: TDXDraw
    Left = 8
    Top = 224
    Width = 969
    Height = 433
    AutoInitialize = True
    AutoSize = True
    Color = clBtnFace
    Display.FixedBitCount = True
    Display.FixedRatio = True
    Display.FixedSize = False
    Options = [doAllowReboot, doWaitVBlank, doCenter, doDirectX7Mode, doHardware, doSelectDriver]
    SurfaceHeight = 433
    SurfaceWidth = 969
    TabOrder = 6
  end
  object ChAvatar: TCheckBox
    Left = 784
    Top = 96
    Width = 81
    Height = 17
    Caption = #1040#1074#1072#1090#1072#1088#1099
    Checked = True
    State = cbChecked
    TabOrder = 7
    OnClick = Button4Click
  end
  object cX: TEdit
    Left = 928
    Top = 50
    Width = 25
    Height = 21
    MaxLength = 3
    TabOrder = 8
    Text = '12'
    OnChange = cXChange
    OnKeyPress = cXKeyPress
  end
  object cY: TEdit
    Left = 984
    Top = 48
    Width = 25
    Height = 21
    MaxLength = 3
    TabOrder = 9
    Text = '8'
    OnChange = cXChange
    OnKeyPress = cXKeyPress
  end
  object cD: TEdit
    Left = 928
    Top = 72
    Width = 25
    Height = 21
    MaxLength = 3
    TabOrder = 10
    Text = '12'
    OnChange = cXChange
    OnKeyPress = cXKeyPress
  end
  object ChBG: TCheckBox
    Left = 784
    Top = 48
    Width = 65
    Height = 17
    Caption = 'BG'
    Checked = True
    State = cbChecked
    TabOrder = 12
    OnClick = Button4Click
  end
  object ChAuto: TCheckBox
    Left = 784
    Top = 32
    Width = 113
    Height = 17
    Caption = #1040#1074#1090#1086#1086#1073#1085#1086#1074#1083#1077#1085#1080#1077
    Checked = True
    State = cbChecked
    TabOrder = 13
  end
  object ChReplace: TCheckBox
    Left = 784
    Top = 64
    Width = 120
    Height = 17
    Caption = #1047#1072#1084#1077#1085#1072' '#1087#1086' '#1090#1072#1073#1083#1080#1094#1077
    Checked = True
    State = cbChecked
    TabOrder = 14
    OnClick = Button4Click
  end
  object ChByte: TCheckBox
    Left = 784
    Top = 80
    Width = 97
    Height = 17
    Caption = #1059#1073#1088#1072#1090#1100' '#1073#1072#1081#1090#1099
    Checked = True
    State = cbChecked
    TabOrder = 15
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 784
    Top = 168
    Width = 113
    Height = 17
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1082#1072#1082'...'
    TabOrder = 16
    OnClick = Button5Click
  end
  object EGoTo: TEdit
    Left = 112
    Top = 200
    Width = 49
    Height = 21
    TabOrder = 17
  end
  object Button6: TButton
    Left = 168
    Top = 200
    Width = 41
    Height = 17
    Caption = 'GoTo'
    TabOrder = 18
    OnClick = Button6Click
  end
  object EFind: TEdit
    Left = 216
    Top = 200
    Width = 169
    Height = 21
    TabOrder = 19
  end
  object Button7: TButton
    Left = 392
    Top = 200
    Width = 65
    Height = 17
    Caption = #1053#1072#1081#1090#1080
    TabOrder = 20
    OnClick = Button7Click
  end
  object Edit4: TEdit
    Left = 464
    Top = 200
    Width = 41
    Height = 21
    Enabled = False
    TabOrder = 21
    Visible = False
  end
  object Button8: TButton
    Left = 504
    Top = 200
    Width = 57
    Height = 17
    Caption = #1047#1072#1084#1077#1085#1080#1090#1100
    Enabled = False
    TabOrder = 22
    Visible = False
  end
  object Button9: TButton
    Left = 680
    Top = 200
    Width = 25
    Height = 17
    Caption = #1047#1072#1084#1077#1085#1080#1090#1100' '#1074#1089#1105
    Enabled = False
    TabOrder = 23
    Visible = False
  end
  object ePos1: TRadioButton
    Left = 984
    Top = 232
    Width = 33
    Height = 17
    Checked = True
    TabOrder = 24
    TabStop = True
    OnClick = Button4Click
  end
  object ePos2: TRadioButton
    Left = 984
    Top = 248
    Width = 33
    Height = 17
    TabOrder = 25
    OnClick = Button4Click
  end
  object ePos3: TRadioButton
    Left = 984
    Top = 264
    Width = 33
    Height = 17
    TabOrder = 26
    OnClick = Button4Click
  end
  object cWH: TEdit
    Left = 928
    Top = 96
    Width = 25
    Height = 21
    MaxLength = 3
    TabOrder = 11
    Text = '53'
    OnChange = cXChange
    OnKeyPress = cXKeyPress
  end
  object cWW: TEdit
    Left = 984
    Top = 96
    Width = 25
    Height = 21
    MaxLength = 3
    TabOrder = 28
    Text = '240'
    OnChange = cXChange
    OnKeyPress = cXKeyPress
  end
  object cWX: TEdit
    Left = 928
    Top = 120
    Width = 25
    Height = 21
    MaxLength = 3
    TabOrder = 29
    Text = '2'
    OnChange = cXChange
    OnKeyPress = cXKeyPress
  end
  object cWY: TEdit
    Left = 984
    Top = 120
    Width = 25
    Height = 21
    MaxLength = 3
    TabOrder = 30
    Text = '4'
    OnChange = cXChange
    OnKeyPress = cXKeyPress
  end
  object Button10: TButton
    Left = 1000
    Top = 8
    Width = 17
    Height = 17
    Caption = '?'
    TabOrder = 31
    OnClick = Button10Click
  end
  object cLC: TEdit
    Left = 984
    Top = 72
    Width = 25
    Height = 21
    MaxLength = 2
    TabOrder = 32
    Text = '3'
    OnChange = cXChange
    OnKeyPress = cXKeyPress
  end
  object cAv: TEdit
    Left = 928
    Top = 144
    Width = 25
    Height = 21
    MaxLength = 3
    TabOrder = 33
    Text = '32'
    OnChange = cXChange
    OnKeyPress = cXKeyPress
  end
  object cSc: TEdit
    Left = 984
    Top = 144
    Width = 25
    Height = 21
    MaxLength = 1
    TabOrder = 34
    Text = '2'
    OnChange = cXChange
  end
  object Button11: TButton
    Left = 976
    Top = 288
    Width = 49
    Height = 17
    Caption = 'Button11'
    TabOrder = 35
    Visible = False
    OnClick = Button11Click
  end
  object Button12: TButton
    Left = 976
    Top = 304
    Width = 49
    Height = 17
    Caption = 'Button12'
    TabOrder = 36
    Visible = False
    OnClick = Button12Click
  end
  object Button13: TButton
    Left = 784
    Top = 144
    Width = 113
    Height = 17
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 37
    OnClick = Button13Click
  end
  object Button2: TButton
    Left = 856
    Top = 8
    Width = 65
    Height = 17
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    TabOrder = 38
    OnClick = Button2Click
  end
  object OpenDialog1: TOpenDialog
    Left = 560
    Top = 192
  end
  object SaveDialog1: TSaveDialog
    FilterIndex = 0
    Left = 648
    Top = 192
  end
end
