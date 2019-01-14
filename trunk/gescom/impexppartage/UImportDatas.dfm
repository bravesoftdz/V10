object FImportDatas: TFImportDatas
  Left = 754
  Top = 274
  Width = 890
  Height = 527
  Caption = 'FImportDatas'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Dock971: TDock97
    Left = 0
    Top = 453
    Width = 874
    Height = 35
    AllowDrag = False
    Position = dpBottom
    object PBouton: TToolWindow97
      Left = 0
      Top = 0
      ClientHeight = 31
      ClientWidth = 874
      Caption = 'Barre outils fiche'
      ClientAreaHeight = 31
      ClientAreaWidth = 874
      DockPos = 0
      FullSize = True
      TabOrder = 0
      DesignSize = (
        874
        31)
      object BValider: TToolbarButton97
        Left = 778
        Top = 2
        Width = 28
        Height = 27
        Hint = 'Valider'
        AllowAllUp = True
        Anchors = [akTop, akRight]
        Default = True
        Flat = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ModalResult = 1
        ParentFont = False
        Spacing = -1
        GlobalIndexImage = 'Z0127_S16G1'
        IsControl = True
      end
      object BFerme: TToolbarButton97
        Left = 810
        Top = 2
        Width = 28
        Height = 27
        Hint = 'Fermer'
        AllowAllUp = True
        Anchors = [akTop, akRight]
        Cancel = True
        Flat = False
        ModalResult = 2
        GlobalIndexImage = 'Z0021_S16G1'
      end
      object HelpBtn: TToolbarButton97
        Left = 842
        Top = 2
        Width = 28
        Height = 27
        Hint = 'Aide'
        AllowAllUp = True
        Anchors = [akTop, akRight]
        Flat = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Spacing = -1
        GlobalIndexImage = 'Z1117_S16G1'
        IsControl = True
      end
      object bDefaire: TToolbarButton97
        Left = 4
        Top = 2
        Width = 28
        Height = 27
        Hint = 'Annuler les modifications'
        Caption = 'Annuler'
        AllowAllUp = True
        DisplayMode = dmGlyphOnly
        Flat = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Spacing = -1
        Visible = False
        GlobalIndexImage = 'M0080_S16G1'
        IsControl = True
      end
      object Binsert: TToolbarButton97
        Left = 36
        Top = 2
        Width = 28
        Height = 27
        Hint = 'Nouveau'
        AllowAllUp = True
        Flat = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Visible = False
        GlobalIndexImage = 'Z0053_S16G1'
      end
      object BDelete: TToolbarButton97
        Left = 68
        Top = 2
        Width = 28
        Height = 27
        Hint = 'Supprimer'
        AllowAllUp = True
        Flat = False
        Visible = False
        GlobalIndexImage = 'Z0005_S16G1'
      end
      object BImprimer: TToolbarButton97
        Left = 746
        Top = 2
        Width = 28
        Height = 27
        Hint = 'Imprimer'
        Anchors = [akTop, akRight]
        Flat = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Visible = False
        GlobalIndexImage = 'Z0369_S16G1'
      end
    end
  end
end
