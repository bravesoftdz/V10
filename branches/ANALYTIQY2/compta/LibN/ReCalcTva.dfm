object FCalcTva: TFCalcTva
  Left = 478
  Top = 145
  Width = 365
  Height = 264
  Caption = 'Recalcul des bases de tva sur encaissement'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 357
    Height = 203
    Align = alClient
    TabOrder = 0
    object TFDateCpta1: THLabel
      Left = 11
      Top = 51
      Width = 124
      Height = 13
      AutoSize = False
      Caption = '&Date comptable du'
      FocusControl = FDateCpta1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object TFDateCpta2: TLabel
      Left = 217
      Top = 51
      Width = 15
      Height = 13
      AutoSize = False
      Caption = 'au'
      FocusControl = FDateCpta2
    end
    object TFEtab: THLabel
      Left = 11
      Top = 82
      Width = 88
      Height = 13
      AutoSize = False
      Caption = '&Etablissement'
      FocusControl = FEtab
    end
    object TFNumPiece1: THLabel
      Left = 11
      Top = 113
      Width = 92
      Height = 13
      AutoSize = False
      Caption = '&N'#176' de pi'#232'ces de'
      FocusControl = FNumPiece1
    end
    object TFExercice: THLabel
      Left = 11
      Top = 20
      Width = 88
      Height = 13
      AutoSize = False
      Caption = 'E&xercice'
      FocusControl = FExercice
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label1: TLabel
      Left = 217
      Top = 113
      Width = 15
      Height = 13
      AutoSize = False
      Caption = #224
      FocusControl = FDateCpta2
    end
    object FDateCpta1: TMaskEdit
      Left = 108
      Top = 47
      Width = 81
      Height = 21
      Ctl3D = True
      EditMask = '!99/99/0000;1;_'
      MaxLength = 10
      ParentCtl3D = False
      TabOrder = 1
      Text = '01/01/1900'
    end
    object FDateCpta2: TMaskEdit
      Left = 256
      Top = 47
      Width = 86
      Height = 21
      Ctl3D = True
      EditMask = '!99/99/0000;1;_'
      MaxLength = 10
      ParentCtl3D = False
      TabOrder = 2
      Text = '31/12/2099'
    end
    object FEtab: THValComboBox
      Left = 108
      Top = 78
      Width = 234
      Height = 21
      Style = csDropDownList
      Ctl3D = True
      ItemHeight = 13
      ParentCtl3D = False
      TabOrder = 3
      TagDispatch = 0
      Vide = True
      DataType = 'TTETABLISSEMENT'
    end
    object FNumPiece1: TMaskEdit
      Left = 108
      Top = 109
      Width = 81
      Height = 21
      Ctl3D = True
      MaxLength = 9
      ParentCtl3D = False
      TabOrder = 4
      Text = '0'
    end
    object FNumPiece2: TMaskEdit
      Left = 256
      Top = 109
      Width = 86
      Height = 21
      Ctl3D = True
      MaxLength = 9
      ParentCtl3D = False
      TabOrder = 5
      Text = '99999999'
    end
    object FExercice: THValComboBox
      Left = 108
      Top = 16
      Width = 234
      Height = 21
      Style = csDropDownList
      Ctl3D = True
      ItemHeight = 13
      ParentCtl3D = False
      TabOrder = 0
      OnChange = FExerciceChange
      TagDispatch = 0
      Vide = True
      DataType = 'TTEXERCICE'
    end
    object FCbV: TCheckBox
      Left = 11
      Top = 143
      Width = 109
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Pour les &ventes'
      Checked = True
      State = cbChecked
      TabOrder = 6
    end
    object FCbA: TCheckBox
      Left = 233
      Top = 143
      Width = 109
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Pour les &achats'
      Checked = True
      State = cbChecked
      TabOrder = 7
    end
    object FCbHT: TCheckBox
      Left = 108
      Top = 175
      Width = 160
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Recalcul sur les lignes de HT'
      Checked = True
      State = cbChecked
      TabOrder = 8
    end
  end
  object HPB: TPanel
    Left = 0
    Top = 203
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
      Margin = 2
      Spacing = -1
      GlobalIndexImage = 'Z0003_S16G2'
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
      GlobalIndexImage = 'Z0021_S16G1'
    end
  end
  object HMTrad: THSystemMenu
    Caption = '&Personnalisation'
    Separator = True
    Traduction = True
    Left = 30
    Top = 189
  end
  object HMess: THMsgBox
    Police.Charset = DEFAULT_CHARSET
    Police.Color = clBlack
    Police.Height = -11
    Police.Name = 'MS Sans Serif'
    Police.Style = []
    Mess.Strings = (
      '0;Recalcul des bases;Confirmez-vous le traitement ?;Q;YNC;Y;C;')
    Left = 48
    Top = 12
  end
end
