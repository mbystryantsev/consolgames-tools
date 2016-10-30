object Form1: TForm1
  Left = 208
  Top = 169
  Width = 696
  Height = 480
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Img: TImage
    Left = 96
    Top = 8
    Width = 209
    Height = 257
  end
  object List: TListBox
    Left = 8
    Top = 8
    Width = 81
    Height = 425
    ItemHeight = 13
    TabOrder = 0
    OnClick = ListClick
  end
  object eX: TEdit
    Left = 96
    Top = 408
    Width = 49
    Height = 21
    TabOrder = 1
    Text = 'eX'
    OnChange = eXChange
  end
  object eY: TEdit
    Left = 160
    Top = 408
    Width = 49
    Height = 21
    TabOrder = 2
    Text = 'eY'
    OnChange = eYChange
  end
  object eW: TEdit
    Left = 224
    Top = 408
    Width = 49
    Height = 21
    TabOrder = 3
    Text = 'eW'
    OnChange = eWChange
  end
  object uX: TUpDown
    Left = 144
    Top = 408
    Width = 9
    Height = 25
    Max = 512
    TabOrder = 4
    OnClick = uXClick
  end
  object uY: TUpDown
    Left = 208
    Top = 408
    Width = 9
    Height = 25
    Max = 512
    TabOrder = 5
    OnClick = uYClick
  end
  object uW: TUpDown
    Left = 272
    Top = 408
    Width = 9
    Height = 25
    Max = 512
    TabOrder = 6
    OnClick = uWClick
  end
  object Button1: TButton
    Left = 592
    Top = 8
    Width = 89
    Height = 41
    Caption = 'Button1'
    TabOrder = 7
    OnClick = Button1Click
  end
end
