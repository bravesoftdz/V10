object FSoldeP: TFSoldeP
  Left = 439
  Top = 269
  Width = 365
  Height = 201
  Caption = 'Recalcul totaux point'#233's'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 357
    Height = 140
    Align = alClient
    TabOrder = 0
    object TCPTEDEBUT: THLabel
      Left = 41
      Top = 28
      Width = 90
      Height = 13
      Caption = 'Compte de banque'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object TPP: THLabel
      Tag = 1
      Left = 5
      Top = 65
      Width = 93
      Height = 13
      Caption = 'Totaux Point'#233' Pivot'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object DP: THLabel
      Tag = 1
      Left = 230
      Top = 65
      Width = 8
      Height = 13
      Caption = 'D'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object CP: THLabel
      Tag = 1
      Left = 339
      Top = 65
      Width = 7
      Height = 13
      Caption = 'C'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object TPD: THLabel
      Tag = 1
      Left = 5
      Top = 105
      Width = 102
      Height = 13
      Caption = 'Totaux Point'#233' Devise'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object DD: THLabel
      Tag = 1
      Left = 230
      Top = 105
      Width = 8
      Height = 13
      Caption = 'D'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object CD: THLabel
      Tag = 1
      Left = 339
      Top = 105
      Width = 7
      Height = 13
      Caption = 'C'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object BVoirSP: TToolbarButton97
      Tag = 1000
      Left = 254
      Top = 24
      Width = 22
      Height = 21
      Hint = 'Voir les soldes actuels'
      ParentShowHint = False
      ShowHint = True
      OnClick = BVoirSPClick
      GlobalIndexImage = 'Z0047_S16G1'
    end
    object TOTDEBPP: THCritMaskEdit
      Tag = 3
      Left = 144
      Top = 61
      Width = 82
      Height = 21
      Ctl3D = True
      Enabled = False
      ParentCtl3D = False
      TabOrder = 0
      Text = '0.00'
      TagDispatch = 0
      Operateur = Inferieur
      OpeType = otReel
    end
    object TOTCREPP: THCritMaskEdit
      Tag = 3
      Left = 254
      Top = 61
      Width = 82
      Height = 21
      Ctl3D = True
      Enabled = False
      ParentCtl3D = False
      TabOrder = 1
      Text = '0.00'
      TagDispatch = 0
      Operateur = Inferieur
      OpeType = otReel
    end
    object TOTDEBPD: THCritMaskEdit
      Tag = 3
      Left = 144
      Top = 101
      Width = 82
      Height = 21
      Ctl3D = True
      Enabled = False
      ParentCtl3D = False
      TabOrder = 2
      Text = '0.00'
      TagDispatch = 0
      Operateur = Inferieur
      OpeType = otReel
    end
    object TOTCREPD: THCritMaskEdit
      Tag = 3
      Left = 254
      Top = 101
      Width = 82
      Height = 21
      Ctl3D = True
      Enabled = False
      ParentCtl3D = False
      TabOrder = 3
      Text = '0.00'
      TagDispatch = 0
      Operateur = Inferieur
      OpeType = otReel
    end
    object CPTEBQ: THCritMaskEdit
      Left = 144
      Top = 24
      Width = 82
      Height = 21
      ReadOnly = True
      TabOrder = 4
      TagDispatch = 0
      ElipsisButton = True
      OnElipsisClick = CPTEBQElipsisClick
    end
  end
  object HPB: TPanel
    Left = 0
    Top = 140
    Width = 357
    Height = 34
    Align = alBottom
    BevelInner = bvLowered
    Caption = ' '
    Ctl3D = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    ParentShowHint = False
    ShowHint = False
    TabOrder = 1
    object BValider: THBitBtn
      Left = 293
      Top = 4
      Width = 28
      Height = 27
      Hint = 'Lancer la v'#233'rification'
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = BValiderClick
      Glyph.Data = {
        BE060000424DBE06000000000000360400002800000024000000120000000100
        0800000000008802000000000000000000000001000000010000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0C8
        A400000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00030303030303
        0303030303030303030303030303030303030303030303030303030303030303
        03030303030303030303030303030303030303030303FF030303030303030303
        03030303030303040403030303030303030303030303030303F8F8FF03030303
        03030303030303030303040202040303030303030303030303030303F80303F8
        FF030303030303030303030303040202020204030303030303030303030303F8
        03030303F8FF0303030303030303030304020202020202040303030303030303
        0303F8030303030303F8FF030303030303030304020202FA0202020204030303
        0303030303F8FF0303F8FF030303F8FF03030303030303020202FA03FA020202
        040303030303030303F8FF03F803F8FF0303F8FF03030303030303FA02FA0303
        03FA0202020403030303030303F8FFF8030303F8FF0303F8FF03030303030303
        FA0303030303FA0202020403030303030303F80303030303F8FF0303F8FF0303
        0303030303030303030303FA0202020403030303030303030303030303F8FF03
        03F8FF03030303030303030303030303FA020202040303030303030303030303
        0303F8FF0303F8FF03030303030303030303030303FA02020204030303030303
        03030303030303F8FF0303F8FF03030303030303030303030303FA0202020403
        030303030303030303030303F8FF0303F8FF03030303030303030303030303FA
        0202040303030303030303030303030303F8FF03F8FF03030303030303030303
        03030303FA0202030303030303030303030303030303F8FFF803030303030303
        030303030303030303FA0303030303030303030303030303030303F803030303
        0303030303030303030303030303030303030303030303030303030303030303
        0303}
      Margin = 2
      NumGlyphs = 2
      Spacing = -1
      IsControl = True
    end
    object BFerme: THBitBtn
      Left = 324
      Top = 4
      Width = 28
      Height = 27
      Hint = 'Fermer'
      Cancel = True
      ModalResult = 2
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Glyph.Data = {
        CE070000424DCE07000000000000360000002800000024000000120000000100
        1800000000009807000000000000000000000000000000000000008284008284
        0082840082840082840082840082840082840082840082840082840082840082
        8400828400828400828400828400828400828400828400828400828400828400
        8284008284008284008284008284008284008284008284008284008284008284
        0082840082840082840082840082840082848482848482840082840082840082
        8400828400828400828400828400828400828400828400828400828400828400
        8284008284008284008284FFFFFF008284008284008284008284008284008284
        0082840082840082840082840082840082840082840082840082840000FF0000
        840000848482840082840082840082840082840082840000FF84828400828400
        8284008284008284008284008284008284008284848284848284FFFFFF008284
        008284008284008284008284008284FFFFFF0082840082840082840082840082
        840082840082840000FF00008400008400008484828400828400828400828400
        00FF000084000084848284008284008284008284008284008284008284848284
        FFFFFF008284848284FFFFFF008284008284008284FFFFFF848284848284FFFF
        FF0082840082840082840082840082840082840000FF00008400008400008400
        00848482840082840000FF000084000084000084000084848284008284008284
        008284008284008284848284FFFFFF008284008284848284FFFFFF008284FFFF
        FF848284008284008284848284FFFFFF00828400828400828400828400828400
        82840000FF000084000084000084000084848284000084000084000084000084
        000084848284008284008284008284008284008284848284FFFFFF0082840082
        84008284848284FFFFFF848284008284008284008284008284848284FFFFFF00
        82840082840082840082840082840082840000FF000084000084000084000084
        0000840000840000840000848482840082840082840082840082840082840082
        84008284848284FFFFFF00828400828400828484828400828400828400828400
        8284FFFFFF848284008284008284008284008284008284008284008284008284
        0000FF0000840000840000840000840000840000848482840082840082840082
        84008284008284008284008284008284008284848284FFFFFF00828400828400
        8284008284008284008284FFFFFF848284008284008284008284008284008284
        0082840082840082840082840082840000840000840000840000840000848482
        8400828400828400828400828400828400828400828400828400828400828400
        8284848284FFFFFF008284008284008284008284008284848284008284008284
        0082840082840082840082840082840082840082840082840082840000FF0000
        8400008400008400008484828400828400828400828400828400828400828400
        8284008284008284008284008284008284848284FFFFFF008284008284008284
        8482840082840082840082840082840082840082840082840082840082840082
        840082840000FF00008400008400008400008400008484828400828400828400
        8284008284008284008284008284008284008284008284008284008284848284
        008284008284008284008284848284FFFFFF0082840082840082840082840082
        840082840082840082840082840000FF00008400008400008484828400008400
        0084000084848284008284008284008284008284008284008284008284008284
        008284008284848284008284008284008284008284008284848284FFFFFF0082
        840082840082840082840082840082840082840082840000FF00008400008400
        00848482840082840000FF000084000084000084848284008284008284008284
        008284008284008284008284008284848284008284008284008284848284FFFF
        FF008284008284848284FFFFFF00828400828400828400828400828400828400
        82840000FF0000840000848482840082840082840082840000FF000084000084
        000084848284008284008284008284008284008284008284848284FFFFFF0082
        84008284848284008284848284FFFFFF008284008284848284FFFFFF00828400
        82840082840082840082840082840082840000FF000084008284008284008284
        0082840082840000FF0000840000840000840082840082840082840082840082
        84008284848284FFFFFFFFFFFF848284008284008284008284848284FFFFFF00
        8284008284848284FFFFFF008284008284008284008284008284008284008284
        0082840082840082840082840082840082840082840000FF0000840000FF0082
        8400828400828400828400828400828400828484828484828400828400828400
        8284008284008284848284FFFFFFFFFFFFFFFFFF848284008284008284008284
        0082840082840082840082840082840082840082840082840082840082840082
        8400828400828400828400828400828400828400828400828400828400828400
        8284008284008284008284008284008284008284008284848284848284848284
        0082840082840082840082840082840082840082840082840082840082840082
        8400828400828400828400828400828400828400828400828400828400828400
        8284008284008284008284008284008284008284008284008284008284008284
        008284008284008284008284008284008284}
      NumGlyphs = 2
    end
  end
  object HMTrad: THSystemMenu
    Caption = '&Personnalisation'
    Separator = True
    Traduction = True
    Left = 30
    Top = 181
  end
  object HMess: THMsgBox
    Police.Charset = DEFAULT_CHARSET
    Police.Color = clBlack
    Police.Height = -11
    Police.Name = 'MS Sans Serif'
    Police.Style = []
    Mess.Strings = (
      
        '0;Recalcul totaux point'#233's;Confirmez-vous le traitement ?;Q;YNC;Y' +
        ';C;'
      '1;Recalcul totaux point'#233's;Le compte n'#39'existe pas.;W;Y;Y;Y;'
      
        '2;Recalcul totaux point'#233's;Le compte n'#39'est pas un compte de banqu' +
        'e.;W;Y;Y;Y;')
    Left = 76
    Top = 172
  end
end