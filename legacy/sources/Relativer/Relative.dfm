object Form1: TForm1
  Left = 110
  Top = 112
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Relativer by HoRRoR :: http://consolgames.ru/'
  ClientHeight = 230
  ClientWidth = 674
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button3: TButton
    Left = 0
    Top = 168
    Width = 89
    Height = 25
    Caption = #1042#1099#1073#1088#1072#1090#1100' '#1092#1072#1081#1083
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button2: TButton
    Left = 88
    Top = 168
    Width = 89
    Height = 25
    Caption = #1053#1072#1081#1090#1080'!'
    TabOrder = 0
    OnClick = Button2Click
  end
  object Values: TValueListEditor
    Left = 0
    Top = 0
    Width = 353
    Height = 169
    Strings.Strings = (
      'FilePath=H:\KH2.IMG'
      'Position=0'
      'Size=0'
      'Step=1'
      'BlockSize=32'
      'String=ingdom')
    TabOrder = 1
    TitleCaptions.Strings = (
      #1055#1077#1088#1077#1084#1077#1085#1085#1072#1103
      #1047#1085#1072#1095#1077#1085#1080#1077)
    ColWidths = (
      101
      246)
  end
  object Results: TMemo
    Left = 352
    Top = 0
    Width = 321
    Height = 193
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object Progress: TProgressBar
    Left = 0
    Top = 192
    Width = 681
    Height = 17
    TabOrder = 4
  end
  object Button4: TButton
    Left = 176
    Top = 168
    Width = 89
    Height = 25
    Caption = #1057#1090#1086#1087
    TabOrder = 5
    OnClick = Button4Click
  end
  object Status: TStatusBar
    Left = 0
    Top = 210
    Width = 674
    Height = 20
    Panels = <
      item
        Width = 50
      end>
  end
  object ClearLogB: TButton
    Left = 264
    Top = 168
    Width = 89
    Height = 25
    Caption = #1054#1095#1080#1089#1090#1080#1090#1100' '#1083#1086#1075
    TabOrder = 7
    OnClick = ClearLogBClick
  end
  object OpenDialog: TOpenDialog
    Top = 192
  end
  object XPManifest1: TXPManifest
    Left = 32
    Top = 192
  end
end
