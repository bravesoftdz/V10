{***********UNITE*************************************************
Auteur  ...... : 
Créé le ...... : 18/04/2018
Modifié le ... :   /  /
Description .. : Source TOF de la FICHE : BRGPDREFERENTIEL ()
Mots clefs ... : TOF;BRGPDREFERENTIEL
*****************************************************************}
Unit BRGPDVALIDTRT_TOF ;

Interface

Uses
  StdCtrls
  , Controls
  , Classes
  , mul
  {$IFNDEF EAGLCLIENT}
  , db
  , uDbxDataSet
  , FE_Main
  {$ENDIF EAGLCLIENT}
  , uTob
  , forms
  , sysutils
  , ComCtrls
  , HCtrls
  , HEnt1
  , HMsgBox
  , UTOF
  , CBPMcd
  , Htb97
  , uTOFComm
  , BRGDPDUtils
  ;

function BLanceFiche_RGPDValidTrt(Nat, Cod, Range, Lequel, Argument : string) : string;

Type
  TOF_BRGPDVALIDTRT = Class (tTOFComm)
  private
    Action       : T_RGPDActions;
    Population   : T_RGPDPopulation;
    PdfFile      : THEdit;
    Confirmation : THLabel;
    FileLabel    : THLabel;
    bValider     : TToolbarButton97;

    procedure PdfFile_OnChange(Sender : TObject);

  public
    procedure OnNew                    ; override ;
    procedure OnDelete                 ; override ;
    procedure OnUpdate                 ; override ;
    procedure OnLoad                   ; override ;
    procedure OnArgument (S : String ) ; override ;
    procedure OnDisplay                ; override ;
    procedure OnClose                  ; override ;
    procedure OnCancel                 ; override ;
  end ;                                                                    

Implementation

uses
  wCommuns
  , UtilPGI
  , Vierge
  ;

function BLanceFiche_RGPDValidTrt(Nat, Cod, Range,Lequel,Argument : string) : string;
begin
  V_PGI.ZoomOle := True;
  Result := AglLanceFiche(Nat, Cod, Range, Lequel, Argument);
  V_PGI.ZoomOle := False;
end;

procedure TOF_BRGPDVALIDTRT.OnNew ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDVALIDTRT.OnDelete ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDVALIDTRT.OnUpdate ;
var
  Cancel : boolean;
begin
  Inherited ;
  if PdfFile.Text = '' then
  begin
    Cancel := (Action = rgdpaConsentRequest);
    if not Cancel then
      Cancel := (PGIAsk('Vous n''avez pas sélectionné ' + iif(Action = rgdpaConsentRequest, 'modèle', 'demande') + '. Voulez-vous continuer ?', Ecran.Caption) <> mrYes);
  end else
  begin
    Cancel := (not FileExists(PdfFile.Text));
    if Cancel then
      PGIError(Format(TraduireMemoire('Le fichier %s n''existe pas.'), [PdfFile.Text]), Ecran.Caption);
  end;
  if Cancel then
  begin
    TFVierge(Ecran).ModalResult := 0;
  end else
    TFVierge(Ecran).Retour := 'OK;' + PdfFile.Text;
end ;

procedure TOF_BRGPDVALIDTRT.OnLoad ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDVALIDTRT.OnArgument (S : String ) ;
var
  Who       : string;
  sCode     : string;
  sLabel    : string;
  sLabel2nd : string;
  Cpt       : integer;
begin
  Inherited ;
  Action       := RGPDUtils.GetActionFromCode(GetArgumentString(S, 'ACTION'));
  Population   := RGPDUtils.GetPopulationFromCode(GetArgumentString(S, 'ORIGINE'));
  Confirmation := THLabel(GetControl('CONFIRMATION'));
  FileLabel    := THLabel(GetControl('LABEL'));
  PdfFile      := THEdit(GetControl('PDFFILE'));
  bValider     := TToolbarButton97(GetControl('BVALIDER'));
  sCode        := '';
  sLabel       := '';
  sLabel2nd    := '';
  Who          := GetArgumentString(S, 'QUI', False);
  if Who <> '' then
  begin
    Cpt := 0;
    while Cpt < 3 do
    begin
      case Cpt of
        0 : sCode     := ReadTokenPipe(Who, '~');
        1 : sLabel    := ReadTokenPipe(Who, '~');
        2 : sLabel2nd := ReadTokenPipe(Who, '~');
      end;
      Inc(Cpt);
    end;
  end else
    sLabel    := GetArgumentString(S, 'QTE', False);
  case Action of
    rgpdaDataExport
    , rgpdaAnonymization
    , rgdpaDataRectification :  begin
                                  FileLabel.Caption := TraduireMemoire('Sélection de la demande');
                                  PdfFile.DataType  := 'OPENFILE(*.PDF;*.*)';
                                  Ecran.Caption     := Format('%s - %s %s %s', [  RGPDUtils.GetLabelFromAction(Action)
                                                                                                    , RGPDUtils.GetLabelFromPopulation(Population)
                                                                                                    , sLabel
                                                                                                    , sLabel2nd
                                                                                                   ]);
                                end;
    rgdpaConsentRequest      :  begin
                                  FileLabel.Caption := TraduireMemoire('Sélection du modèle');
                                  PdfFile.DataType  := 'OPENFILE(*.DOTX)';
                                  Ecran.Caption     := Format(TraduireMemoire('%s pour %s %s'), [  RGPDUtils.GetLabelFromAction(Action)
                                                                                                 , sLabel
                                                                                                 , RGPDUtils.GetLabelFromPopulationM(Population)
                                                                                                ]);
                                end;
  end;
  bValider.Enabled       := (Action <> rgdpaConsentRequest);
  PdfFile.OnChange       := PdfFile_OnChange;
  TFVierge(Ecran).Retour := '';
end ;

procedure TOF_BRGPDVALIDTRT.OnClose ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDVALIDTRT.OnDisplay () ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDVALIDTRT.OnCancel () ;
begin
  Inherited ;
  TFMul(Ecran).Retour := 'CANCEL';
end ;

procedure TOF_BRGPDVALIDTRT.PdfFile_OnChange(Sender: TObject);
begin
  bValider.Enabled := ((Action <> rgdpaConsentRequest) or ((Action = rgdpaConsentRequest) and (PdfFile.Text <> '')));
end;

Initialization
  registerclasses ( [ TOF_BRGPDVALIDTRT ] ) ;
end.

