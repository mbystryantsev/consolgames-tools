object Form1: TForm1
  Left = 240
  Top = 140
  Width = 464
  Height = 392
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Img: TImage
    Left = 136
    Top = 0
    Width = 313
    Height = 281
  end
  object PalImg: TImage
    Left = 0
    Top = 32
    Width = 128
    Height = 256
  end
  object Label1: TLabel
    Left = 296
    Top = 312
    Width = 5
    Height = 13
    Caption = 'x'
  end
  object Button9: TButton
    Left = 0
    Top = 288
    Width = 25
    Height = 33
    Action = APrevPal
    TabOrder = 9
  end
  object Button3: TButton
    Left = 24
    Top = 288
    Width = 17
    Height = 33
    Caption = '<<'
    Enabled = False
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 40
    Top = 288
    Width = 17
    Height = 33
    Caption = '<'
    Enabled = False
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button6: TButton
    Left = 56
    Top = 288
    Width = 17
    Height = 17
    Caption = '+'
    Enabled = False
    TabOrder = 6
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 56
    Top = 304
    Width = 17
    Height = 17
    Caption = '-'
    Enabled = False
    TabOrder = 7
    OnClick = Button7Click
  end
  object Button5: TButton
    Left = 72
    Top = 288
    Width = 17
    Height = 33
    Caption = '>'
    Enabled = False
    TabOrder = 5
    OnClick = Button5Click
  end
  object Button2: TButton
    Left = 88
    Top = 288
    Width = 17
    Height = 33
    Caption = '>>'
    Enabled = False
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button8: TButton
    Left = 104
    Top = 288
    Width = 25
    Height = 33
    Action = ANextPal
    TabOrder = 8
  end
  object Button1: TButton
    Left = 0
    Top = 0
    Width = 129
    Height = 33
    Caption = #1055#1086#1077#1093#1072#1083#1080'!'
    TabOrder = 0
    OnClick = Button1Click
  end
  object chBGR: TCheckBox
    Left = 0
    Top = 320
    Width = 41
    Height = 17
    Caption = 'BGR'
    Enabled = False
    TabOrder = 3
    OnClick = chBGRClick
  end
  object edGoTo: TEdit
    Left = 48
    Top = 320
    Width = 57
    Height = 21
    TabOrder = 10
    OnEnter = Button10Click
  end
  object Button10: TButton
    Left = 104
    Top = 320
    Width = 25
    Height = 25
    Caption = 'Go!'
    Enabled = False
    TabOrder = 11
    OnClick = Button10Click
  end
  object Button11: TButton
    Left = 136
    Top = 288
    Width = 41
    Height = 49
    Caption = 'Font 1'
    Enabled = False
    TabOrder = 12
    OnClick = Button11Click
  end
  object Button12: TButton
    Left = 176
    Top = 288
    Width = 41
    Height = 49
    Caption = 'Font 2'
    Enabled = False
    TabOrder = 13
    OnClick = Button12Click
  end
  object Button13: TButton
    Left = 216
    Top = 288
    Width = 41
    Height = 49
    Caption = 'Font 3'
    Enabled = False
    TabOrder = 14
    OnClick = Button13Click
  end
  object edGT: TEdit
    Left = 256
    Top = 288
    Width = 89
    Height = 21
    TabOrder = 15
  end
  object Button14: TButton
    Left = 352
    Top = 288
    Width = 49
    Height = 49
    Caption = 'GoTo'
    Enabled = False
    TabOrder = 16
    OnClick = Button14Click
  end
  object edW: TEdit
    Left = 256
    Top = 312
    Width = 41
    Height = 21
    TabOrder = 17
    Text = '256'
  end
  object edH: TEdit
    Left = 304
    Top = 312
    Width = 41
    Height = 21
    TabOrder = 18
    Text = '256'
  end
  object chAlpha: TCheckBox
    Left = 0
    Top = 336
    Width = 49
    Height = 17
    Caption = 'Alpha'
    Enabled = False
    TabOrder = 19
    OnClick = chBGRClick
  end
  object Button15: TButton
    Left = 400
    Top = 288
    Width = 49
    Height = 49
    Caption = 'Save'
    Enabled = False
    TabOrder = 20
    OnClick = Button15Click
  end
  object OpenDialog1: TOpenDialog
    FileName = 'GLOBAL.TXD.u'
    Left = 40
    Top = 216
  end
  object ActionList1: TActionList
    Left = 40
    Top = 184
    object ANextPal: TAction
      Caption = '>>>'
      ShortCut = 112
      SecondaryShortCuts.Strings = (
        'PgDown')
      OnExecute = ANextPalExecute
    end
    object APrevPal: TAction
      Caption = '<<<'
      OnExecute = APrevPalExecute
    end
  end
  object SavePictureDialog1: TSavePictureDialog
    Filter = 'Bitmaps (*.bmp)|*.bmp'
    Left = 40
    Top = 152
  end
end
