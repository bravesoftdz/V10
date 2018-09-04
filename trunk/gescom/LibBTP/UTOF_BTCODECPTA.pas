{***********UNITE*************************************************
Auteur  ...... : 
Créé le ...... : 30/08/2018
Modifié le ... :   /  /
Description .. : Source TOF de la FICHE : BTCODECPTA ()
Mots clefs ... : TOF;BTCODECPTA
*****************************************************************}
Unit UTOF_BTCODECPTA ;

Interface

Uses StdCtrls, 
     Controls, 
     Classes, 
     db,
     {$IFNDEF DBXPRESS}
     dbtables,
     {$ELSE}
     uDbxDataSet,
     {$ENDIF}
     fe_main,
     mul,
     forms,
     sysutils,
     ComCtrls,
     HCtrls,
     HPanel,
     HTB97,
     HEnt1,
     HMsgBox,
     uTOB,
     Paramsoc,
     LookUp,
     UtilsGrille,
     UtilsEtat,
     Vierge,
     HSysMenu,
     HRichEdt,
     HRichOLE,
     UTOF;

Type
  TOF_BTCODECPTA = Class (TOF)
    procedure OnNew                    ; override ;
    procedure OnDelete                 ; override ;
    procedure OnUpdate                 ; override ;
    procedure OnLoad                   ; override ;
    procedure OnArgument (S : String ) ; override ;
    procedure OnDisplay                ; override ;
    procedure OnClose                  ; override ;
    procedure OnCancel                 ; override ;

  private
    //
    Action        : TActionFiche;
    //Variable nécessaire pour la gestion de l'état
    OptionEdition : TOptionEdition;
    fEtat         : THValComboBox;
    TheType       : String;
    TheNature     : String;
    TheTitre      : String;
    TheModele     : String;
    //
    VenteAchat  : THValComboBox;
    FamCptaArt  : THValComboBox;
    FamCptaTiers: THValComboBox;
    FamCptaAff  : THValComboBox;
    RegimeTaxe  : THValComboBox;
    FamTaxe     : THValComboBox;
    Etablissement: THValComboBox;
    //
    Rang        : THEdit;
    CptHTAchat  : THEdit;
    CptHTVente  : THEdit;
    CptHtStock  : THEdit;
    CptHTVarStk : THEdit;
    //
    TCptaArt    : THLabel;
    TCptaTiers  : THLabel;
    TCptaAff    : THLabel;
    TCptHTAchat : THLabel;
    TCptHTVente : THLabel;
    TCptStock   : THLabel;
    TCptVarStk  : THLabel;
    //
    OkCptaArt   : Boolean;
    OkCptaTiers : Boolean;
    OkCptaAff   : Boolean;
    AvecStock   : Boolean;
    NoAchat     : Boolean;
    AvecImmoDiv : Boolean;
    //
    BImprimer   : TToolbarButton97;
    BVENTILACH  : TToolbarButton97;
    BVENTILVTE  : TToolbarButton97;
    BVENTILSTK  : TToolbarButton97;
    //
    GroupBoxEsc : TGroupBox;
    GroupBoxRem : TGroupBox;
    //
    TobCodeCPTA : TOB;
    TobEdition  : TOB;
    //
    PageCTRL    : TPageControl;
    //
    procedure AffichageInitEcran(OkAff: Boolean);
    procedure Controlechamp(Champ, Valeur: String);
    procedure CreateEdition;
    procedure CreateTOB;
    procedure DestroyTOB;
    procedure GetObjects;
    procedure OnChangeVenteAchat(Sender: TObject);
    procedure OnImprimeFiche(Sender: TObject);
    procedure RazZoneEcran;
    procedure SetScreenEvents;
    procedure VentilationAchat(Sender: TObject);
    procedure VentilationStock(Sender: TObject);
    procedure VentilationVente(Sender: TObject);
    procedure VentilCompteHT(Nature: String);
    //
  end ;

Implementation

Uses  EntGC,
      Ventil;

procedure TOF_BTCODECPTA.OnNew ;
begin
  Inherited ;
end ;

procedure TOF_BTCODECPTA.OnDelete ;
begin
  Inherited ;
end ;

procedure TOF_BTCODECPTA.OnUpdate ;
begin
  Inherited ;
end ;

procedure TOF_BTCODECPTA.OnLoad ;
begin
  Inherited ;
end ;

procedure TOF_BTCODECPTA.OnArgument (S : String ) ;
var Critere : string;
    Champ   : string;
    Valeur  : string;
    i       : Integer;
    x       : Integer;
begin
  Inherited ;
  //
  TFvierge(Ecran).FormResize := false;
  //
  AvecImmoDiv := GetParamSocSecur('SO_GCCPTAIMMODIV', False) ;
  AvecStock   := GetParamSocSecur('SO_GCINVPERM', False) ;
  OkCptaArt   := GetParamSocSecur('SO_GCVENTCPTAART', False);
  OkCptaTiers := GetParamSocSecur('SO_GCVENTCPTATIERS', False);
  OkCptaAff   := GetParamSocSecur('SO_GCVENTCPTAAFF', False);

  //Chargement des zones ecran dans des zones programme
  GetObjects;
  //
  CreateTOB;
  //
  CreateEdition;
  //
  Critere := uppercase(Trim(ReadTokenSt(S)));
  while Critere <> '' do
  begin
     x := pos('=', Critere);
     if x <> 0 then
        begin
        Champ  := copy(Critere, 1, x - 1);
        Valeur := copy(Critere, x + 1, length(Critere));
        end
     else
        Champ  := Critere;
     ControleChamp(Champ, Valeur);
     Critere:= uppercase(Trim(ReadTokenSt(S)));
  end;

  //Gestion des évènement des zones écran
  SetScreenEvents;

  //Remise à blanc des zone ecran
  RAZZoneEcran;

  //Affichage de l'écran initial
  AffichageInitEcran(False);

end ;

procedure TOF_BTCODECPTA.OnClose ;
begin
  Inherited ;
end ;

procedure TOF_BTCODECPTA.OnDisplay () ;
begin
  Inherited ;
end ;

procedure TOF_BTCODECPTA.OnCancel () ;
begin
  Inherited ;
end ;

procedure TOF_BTCODECPTA.GetObjects;
begin

  if Assigned(GetControl('GCP_VENTEACHAT'))     then VenteAchat   := THValComboBox(GetControl('GCP_VENTEACHAT'));
  if Assigned(GetControl('GCP_COMPTAARTICLE'))  then FamCptaArt   := THValComboBox(GetControl('GCP_COMPTAARTICLE'));
  if Assigned(GetControl('GCP_COMPTATIERS'))    then FamCptaTiers := THValComboBox(GetControl('GCP_COMPTATIERS'));
  if Assigned(GetControl('GCP_COMPTAAFFAIRE'))  then FamCptaAff   := THValComboBox(GetControl('GCP_COMPTAAFFAIRE'));
  if Assigned(GetControl('GCP_ETABLISSEMENT'))  then Etablissement:= THValComboBox(GetControl('GCP_ETABLISSEMENT'));
  if Assigned(GetControl('GCP_REGIMETAXE'))     then RegimeTaxe   := THValComboBox(GetControl('GCP_REGIMETAXE'));
  if Assigned(GetControl('GCP_FAMILLETAXE'))    then FamTaxe      := THValComboBox(GetControl('GCP_FAMILLETAXE'));

  if Assigned(GetControl('TGCP_COMPTAARTICLE')) then TCptaArt     := THLabel(GetControl('TGCP_COMPTAARTICLE'));
  if Assigned(GetControl('TGCP_COMPTATIERS'))   then TCptaTiers   := THLabel(GetControl('TGCP_COMPTATIERS'));
  if Assigned(GetControl('TGCP_COMPTAAFFAIRE')) then TCptaAff     := THLabel(GetControl('TGCP_COMPTAAFFAIRE'));

  if Assigned(GetControl('GCP_RANG'))           then Rang         := THEdit(GetControl('GCP_RANG'));
  if Assigned(GetControl('GCP_CPTEGENEACH'))    then CptHTAchat   := THEdit(GetControl('GCP_CPTEGENEACH'));
  if Assigned(GetControl('GCP_CPTEGENEVTE'))    then CptHTVente   := THEdit(GetControl('GCP_CPTEGENEVTE'));
  if Assigned(GetControl('GCP_CPTEGENESTOCK'))  then CptHTStock   := THEdit(GetControl('GCP_CPTEGENESTOCK'));
  if Assigned(GetControl('GCP_CPTEGENEVARSTK')) then CptHTVarStk  := THEdit(GetControl('GCP_CPTEGENEVARSTK'));

  if Assigned(GetControl('GROUPBOXESC'))        then GroupBoxEsc  := TGroupBox(GetControl('GROUPBOXESC'));
  if Assigned(GetControl('GROUPBOXREM'))        then GroupBoxRem  := TGroupBox(GetControl('GROUPBOXREM'));

  if Assigned(GetControl('BIMPRIMER'))          then BImprimer    := TToolbarButton97(GetControl('BIMPRIMER'));
  if assigned(Getcontrol('BVENTILACH'))         then BVENTILACH   := TToolbarButton97(Getcontrol('BVENTILACH'));
  if assigned(Getcontrol('BVENTILVTE'))         then BVENTILVTE   := TToolbarButton97(Getcontrol('BVENTILVTE'));
  if assigned(Getcontrol('BVENTILSTK'))         then BVENTILSTK   := TToolbarButton97(Getcontrol('BVENTILSTK'));

end;

procedure TOF_BTCODECPTA.SetScreenEvents;
begin

  VenteAchat.OnChange := OnChangeVenteAchat;
  //
  BImprimer.OnClick   := OnImprimeFiche;
  BVENTILACH.OnClick  := VentilationAchat;
  BVENTILVTE.OnClick  := VentilationVente;
  BVENTILSTK.OnClick  := VentilationStock;

end;


Procedure TOF_BTCODECPTA.Controlechamp(Champ, Valeur : String);
begin

  if Champ='ACTION' then
  begin
    if      Valeur='CREATION'     then Action:=taCreat
    else if Valeur='MODIFICATION' then Action:=taModif
    else if Valeur='CONSULTATION' then Action:=taConsult;
  end;

  if Champ='RANG'         then Rang.text := Valeur;

end;

procedure TOF_BTCODECPTA.RazZoneEcran;
begin

  Rang.text         := '0';
  VenteAchat.Text   := '';
  //
  FamCptaArt.Text   := '';
  FamCptaAff.Text   := '';
  FamCptaTiers.Text := '';
  //
  Etablissement.Text:= '';
  FamTaxe.Text      := '';
  RegimeTaxe.text   := '';
  //
  CptHTAchat.Text   := '';
  CptHTVente.text   := '';
  CptHtStock.text   := '';
  CptHTVarStk.text  := '';
  //

end;

Procedure TOF_BTCODECPTA.AffichageInitEcran(OkAff : Boolean);
begin

end;

Procedure TOF_BTCODECPTA.CreateTOB;
begin

  TobCodeCPTA   := Tob.Create('CODECPTA', nil, -1);

  // Edition
  TobEdition    := TOB.Create(' EDITCODECPTA', nil, -1);

end;

procedure TOF_BTCODECPTA.DestroyTOB;
begin

  FreeAndNil(TobCodeCPTA);
  //
  FreeAndNil(TobEdition);
  FreeAndNil(OptionEdition);

end;

procedure TOF_BTCODECPTA.CreateEdition;
begin
  //
  TheType       := 'E';
  TheNature     := 'PAR';
  TheTitre      := 'Ventilation comptable';
  TheModele     := 'VCP';
  //
  OptionEdition := TOptionEdition.Create(TheType,TheNature,TheModele, TheTitre, '', True, True, True, False, False, PageCTRL, fEtat);
  //
  OptionEdition.Apercu    := True;
  OptionEdition.DeuxPages := False;
  OptionEdition.Spages    := PageCTRL;

end;

Procedure TOF_BTCODECPTA.OnImprimeFiche(Sender : TObject);
begin

end;

Procedure TOF_BTCODECPTA.OnChangeVenteAchat(Sender : TObject);
begin

end;

Procedure TOF_BTCODECPTA.VentilationAchat(Sender : TObject);
begin

end;

Procedure TOF_BTCODECPTA.VentilationVente(Sender : TObject);
begin

end;

Procedure TOF_BTCODECPTA.VentilationStock(Sender : TObject);
begin

end;

procedure TOF_BTCODECPTA.VentilCompteHT(Nature : String) ;
Var StAxes : String ;
begin

  //if GS.cells[colRang,GS.row]='' then begin GS.cells[colRang,GS.row]:=inttostr(NextRang); inc(NextRang); end ;

  if EstSerie(S7) then
    StAxes:='12345'
  else
  BEGIN
    StAxes:='1' ;
    {$IFNDEF CCS3}
    if VH_GC.GCventAxe2 then StAxes:=StAxes+'2' ;
    if VH_GC.GCventAxe3 then StAxes:=StAxes+'3' ;
    {$ENDIF}
  END ;

  //ParamVentil(Nature,string(GS.cells[colRang,GS.row]) ,StAxes,taCreat,FALSE);

end ;




Initialization
  registerclasses ( [ TOF_BTCODECPTA ] ) ; 
end.

