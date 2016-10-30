object Form1: TForm1
  Left = 126
  Top = 40
  Width = 634
  Height = 375
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
  object Label1: TLabel
    Left = 504
    Top = 104
    Width = 55
    Height = 13
    Caption = 'CheckSum:'
  end
  object Label2: TLabel
    Left = 16
    Top = 8
    Width = 49
    Height = 13
    Caption = 'Password:'
  end
  object Label3: TLabel
    Left = 32
    Top = 32
    Width = 33
    Height = 13
    Caption = 'Indata:'
  end
  object Label4: TLabel
    Left = 8
    Top = 56
    Width = 57
    Height = 13
    Caption = 'True indata:'
  end
  object Label5: TLabel
    Left = 16
    Top = 80
    Width = 53
    Height = 13
    Caption = 'Decr. data:'
  end
  object ePass: TEdit
    Left = 72
    Top = 8
    Width = 545
    Height = 21
    TabOrder = 0
    Text = '6TD677 7X-T7H HJVYG7 37'
  end
  object ePassBin: TEdit
    Left = 72
    Top = 32
    Width = 545
    Height = 22
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
  end
  object ePassData: TEdit
    Left = 72
    Top = 80
    Width = 545
    Height = 22
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 2
  end
  object Button1: TButton
    Left = 72
    Top = 104
    Width = 49
    Height = 17
    Caption = 'Button1'
    TabOrder = 3
    OnClick = Button1Click
  end
  object ePassBin2: TEdit
    Left = 72
    Top = 56
    Width = 545
    Height = 22
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 4
  end
  object eCheckSum: TEdit
    Left = 568
    Top = 104
    Width = 49
    Height = 21
    ReadOnly = True
    TabOrder = 5
  end
  object eData: TMemo
    Left = 336
    Top = 128
    Width = 281
    Height = 209
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object eMainMask: TEdit
    Left = 456
    Top = 104
    Width = 41
    Height = 22
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 7
  end
  object eMask: TEdit
    Left = 336
    Top = 104
    Width = 113
    Height = 21
    ReadOnly = True
    TabOrder = 8
    Text = 'eMask'
  end
end
