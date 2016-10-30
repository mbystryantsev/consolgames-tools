object NewProjectForm: TNewProjectForm
  Left = 248
  Top = 129
  Width = 696
  Height = 480
  Caption = #1057#1086#1079#1076#1072#1085#1080#1077' '#1087#1088#1086#1077#1082#1090#1072
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object StaticText1: TStaticText
    Left = 8
    Top = 8
    Width = 114
    Height = 17
    BorderStyle = sbsSunken
    Caption = 'Final Fantasy                '
    TabOrder = 0
  end
  object ComboBox1: TComboBox
    Left = 128
    Top = 8
    Width = 97
    Height = 21
    Style = csDropDownList
    Ctl3D = False
    ItemHeight = 13
    ItemIndex = 0
    ParentCtl3D = False
    TabOrder = 1
    Text = 'VII'
    Items.Strings = (
      'VII'
      'VIII'
      'Tactics')
  end
  object StaticText2: TStaticText
    Left = 8
    Top = 32
    Width = 113
    Height = 17
    BorderStyle = sbsSunken
    Caption = #1054#1088#1080#1075#1080#1085#1072#1083#1100#1085#1099#1081' '#1090#1077#1082#1089#1090' '
    TabOrder = 2
  end
  object StaticText3: TStaticText
    Left = 8
    Top = 56
    Width = 112
    Height = 17
    BorderStyle = sbsSunken
    Caption = #1048#1079#1084#1077#1085#1103#1077#1084#1099#1081' '#1090#1077#1082#1089#1090'   '
    TabOrder = 3
  end
  object Edit1: TEdit
    Left = 128
    Top = 32
    Width = 73
    Height = 21
    TabOrder = 4
    Text = 'Edit1'
  end
  object Edit2: TEdit
    Left = 128
    Top = 56
    Width = 73
    Height = 21
    TabOrder = 5
    Text = 'Edit2'
  end
end
