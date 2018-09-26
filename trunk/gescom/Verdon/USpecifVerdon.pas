unit USpecifVerdon;

interface
uses
  Classes,
  SysUtils,
  uTob,
  hEnt1,
  hCtrls,
  EntGC,
  SaisUtil,
  wCommuns,
  uEntCommun,
  UtilConso,
  forms,
  Menus,
  Db, {$IFNDEF DBXPRESS} dbTables, {$ELSE} uDbxDataSet, {$ENDIF}
  affaireutil,FE_Main,Paramsoc
  ;

type
  TOptionVerdonSais = class (TObject)
    private
      fActif : Boolean;
      FF : TForm;
      POPGS : TPopupMenu;
      fMaxItems : Integer;
      fCreatedPop : Boolean;
      MesMenuItem : array[0..2] of TMenuItem;
      //
      procedure DefiniMenuPop(Parent: Tform);
    procedure VerdonVoirStockWTT(Sender: TObject);
    public
      constructor create (Parent : Tform);
      Destructor destroy; override;
  end;



procedure ConstitueAffaireVerdon(FF : TForm);

implementation

uses Facture,
     FactTOB
     ;


procedure ConstitueAffaireVerdon(FF : TForm );
var XX : TFFacture;
    P0,P1,P2,P3,Av,CodeAffaire : string;
    TOBAFFaire,TOBpiece : TOB;
    LgCodeAffaire1 : integer;
    FormatAff1 : string;
begin
  XX := TFFacture(FF);
  if XX.GP_AFFAIRE.Text <> ''  then exit;  // si c'est un avenant et donc que le code affaire est déjà affecté --> on ne fait rien de plus
  TOBAFFaire := XX.TheTOBAffaire;
  TOBPiece := XX.LaPieceCourante;
  //
  LgCodeAffaire1 := GetParamSocSecur('SO_AFFCO1LNG',8);
  FormatAff1 := '%0.'+InttoStr(LgCodeAffaire1)+'d';
  P0 := 'A'; P1 := Format(FormatAff1,[TOBPiece.GetInteger('GP_NUMERO')]); P2 := ''; P3 := ''; Av := '';
  CodeAffaire := CodeAffaireRegroupe (P0,P1,P2,P3,Av,taCreat,False,False,false);
  TOBAFFaire.InitValeurs(false);
  TOBAFFaire.SetString('AFF_AFFAIRE',CodeAffaire);
  TOBAFFaire.SetString('AFF_AFFAIREREF',CodeAffaire);
  TOBAFFaire.SetString('AFF_AFFAIREINIT',CodeAffaire);
  TOBAFFaire.SetString('AFF_AFFAIRE0',P0);
  TOBAFFaire.SetString('AFF_AFFAIRE1',P1);
  TOBAFFaire.SetString('AFF_AFFAIRE2',P2);
  TOBAFFaire.SetString('AFF_AFFAIRE3',P3);
  TOBAFFaire.SetString('AFF_AVENANT',Av);
  //
  TOBAFFaire.PutValue('AFF_SSTRAITANCE','-');
  TOBAFFaire.SetDateTime('AFF_DATESSTRAIT',iDate1900);
  TOBAFFaire.SetString('AFF_MANDATAIRE','');
  TOBAFFaire.PutValue ('AFF_INTERVALGENER',	GetParamSocSecur('SO_AFINTERVAL',1));
  TOBAFFaire.PutValue ('AFF_PERIODICITE', GetParamSocSecur('SO_AfPeriodicte', 'M')) ;
  TOBAFFaire.PutValue ('AFF_GENERAUTO', VH_GC.AFFGenerAuto ) ;
  TOBAFFaire.PutValue ('AFF_COEFFREVALO', 1) ;
  TOBAFFaire.PutValue ('AFF_RECONDUCTION', VH_GC.AFFReconduction) ;
  TOBAFFaire.PutValue ('AFF_DATECREATION', V_PGI.DateEntree) ; // gm 07/01/03 car maintenant l'agl met l'heure
  TOBAFFaire.PutValue ('AFF_CALCTOTHTGLO', 'X') ; // mcd 11/09/02
  TOBAFFaire.PutValue ('AFF_TYPEPREVU', 'GLO') ;
  TOBAFFaire.PutValue ('AFF_NUMDERGENER', '') ;
  TOBAFFaire.PutValue ('AFF_PROFILGENER', GetParamSocSecur('SO_AFPROFILGENER', '')) ;
  TOBAFFaire.PutValue ('AFF_TERMEECHEANCE', GetParamSocSecur('SO_AFTERMEECHE', '')) ;
  TOBAFFaire.PutValue ('AFF_METHECHEANCE', GetParamSocSecur('SO_AFMETHECHE', '')) ;
  TOBAFFaire.PutValue ('AFF_ADMINISTRATIF', '-') ;
  TOBAFFaire.PutValue ('AFF_MODELE', '-') ;
  TOBAFFaire.PutValue ('AFF_AFFAIREHT', 'X') ;
  TOBAFFaire.SetDateTime ('AFF_DATEDEBUT', V_PGI.DateEntree) ;
  TOBAFFaire.SetDateTime ('AFF_DATEFIN', idate2099) ;
  TOBAFFaire.PutValue ('AFF_REGSURCAF', '-') ; // gm sic 26/09/02
  TOBAFFaire.SetDateTime ('AFF_DATESIGNE', idate2099) ;
  TOBAFFaire.SetDateTime ('AFF_DATEDEBGENER', idate1900);
  TOBAFFaire.SetDateTime ('AFF_DATEFINGENER', idate2099) ;
  TOBAFFaire.SetDateTime ('AFF_DATELIMITE', idate2099) ;
  TOBAFFaire.SetDateTime ('AFF_DATERESIL', idate2099) ;
  TOBAFFaire.SetDateTime ('AFF_DATECLOTTECH', idate2099) ;
  TOBAFFaire.SetDateTime ('AFF_DATEGARANTIE', idate2099) ;
  TOBAFFaire.SetDateTime ('AFF_DATECUTOFF', idate1900) ;
  TOBAFFaire.PutValue ('AFF_STATUTAFFAIRE', 'AFF') ;
  TOBAFFaire.PutValue ('AFF_ETATAFFAIRE', 'ENC');
  TOBAFFaire.PutValue ('AFF_REGROUPEFACT', 'AUC') ;
  TOBAFFaire.PutValue ('AFF_CREATEUR', V_PGI.User) ;
  TOBAFFaire.PutValue ('AFF_UTILISATEUR', V_PGI.User) ;
  TOBAFFaire.PutValue ('AFF_CREERPAR', 'SAI') ; // saisie
  TOBAFFaire.PutValue ('AFF_ETABLISSEMENT',  TOBpiece.getString('GP_ETABLISSEMENT'));
  TOBAFFaire.PutValue ('AFF_SAISIECONTRE', '-') ;
  TOBAFFaire.PutValue ('AFF_DEVISE',TOBpiece.getString('GP_DEVISE')) ;
  TOBAFFaire.PutValue ('AFF_REPRISEACTIV', 'TOU') ;
  TOBAFFaire.PutValue ('AFF_TIERS',TOBpiece.getString('GP_TIERS'));
  TOBAFFaire.PutValue ('AFF_DEVISE',TOBpiece.GetString('GP_DEVISE')) ;

  TOBAFFaire.PutValue ('AFF_AFFCOMPLETE', 'X') ;
  TOBAFFaire.PutValue ('MONTANTGLOBAL', 0);
  TOBAFFaire.PutValue ('MONTANTDEJAFACT', 0);
  TOBAFFaire.PutValue ('MONTANTAFACT', 0);
  TOBAFFaire.PutValue ('AFF_AFFCOMPLETE', 'X');
  TOBAFFaire.PutValue ('AFF_DESCRIPTIF',XX.TDESCAFFAIRE.Text);
  TOBAFFaire.PutValue ('AFF_LIBELLE',XX.TDESCAFFAIRE.Text);
  if not TOBAFFaire.InsertDB(nil) then
  begin
    V_PGI.IOError := oeUnknown; 
  end;
  //
  if V_PGI.IOError = OeOK then
  begin
    PutValueDetail(TOBpiece,'GP_AFFAIRE',TOBAFFaire.GetString('AFF_AFFAIRE'));
    PutValueDetail(TOBpiece,'GP_AFFAIRE1',TOBAFFaire.GetString('AFF_AFFAIRE1'));
    PutValueDetail(TOBpiece,'GP_AFFAIRE2',TOBAFFaire.GetString('AFF_AFFAIRE2'));
    PutValueDetail(TOBpiece,'GP_AFFAIRE3',TOBAFFaire.GetString('AFF_AFFAIRE3'));
    PutValueDetail(TOBpiece,'GP_AVENANT',TOBAFFaire.GetString('AFF_AVENANT'));
    XX.GP_AFFAIRE.Text := TOBAFFaire.GetString('AFF_AFFAIRE');
    XX.GP_AFFAIRE0.Text := TOBAFFaire.GetString('AFF_AFFAIRE0');
    XX.GP_AFFAIRE1.Text := TOBAFFaire.GetString('AFF_AFFAIRE1');
    XX.GP_AFFAIRE2.text := TOBAFFaire.GetString('AFF_AFFAIRE2');
    XX.GP_AFFAIRE3.text := TOBAFFaire.GetString('AFF_AFFAIRE3');
    XX.GP_AVENANT.text := TOBAFFaire.GetString('AFF_AVENANT');
    TOBPiece.SetString('GP_AFFAIRE',TOBAFFaire.GetString('AFF_AFFAIRE'));
    TOBPiece.SetString('GP_AFFAIRE1',TOBAFFaire.GetString('AFF_AFFAIRE1'));
    TOBPiece.SetString('GP_AFFAIRE2',TOBAFFaire.GetString('AFF_AFFAIRE2'));
    TOBPiece.SetString('GP_AFFAIRE3',TOBAFFaire.GetString('AFF_AFFAIRE3'));
    TOBPiece.SetString('GP_AVENANT',TOBAFFaire.GetString('AFF_AVENANT'));
  end;
end;

constructor TOptionVerdonSais.create(Parent: Tform);
var ThePop : Tcomponent;
begin
  fActif := false;
  if VH_GC.BTCODESPECIF = '002' then
  begin
    fActif := True;
    FF := Parent;
    ThePop := Parent.Findcomponent  ('POPBTP');
    if ThePop = nil then
    BEGIN
      // pas de menu BTP trouve ..on le cree
      POPGS := TPopupMenu.Create(Parent);
      POPGS.Name := 'POPBTP';
      fCreatedPop := true;
    END else
    BEGIN
      fCreatedPop := false;
      POPGS := TPopupMenu(thePop);
    END;
    DefiniMenuPop(Parent);
  end;
end;

procedure TOptionVerdonSais.DefiniMenuPop (Parent : Tform);
var Indice : integer;

begin
  fMaxItems := 0;
  if not fcreatedPop then
  begin
    MesMenuItem[fMaxItems] := TmenuItem.Create (parent);
    with MesMenuItem[fMaxItems] do
      begin
      Caption := '-';
      end;
    inc (fMaxItems);
  end;
  MesMenuItem[fMaxItems] := TmenuItem.Create (parent);
  with MesMenuItem[fMaxItems] do
    begin
    Name := 'VERDONVOIRSTOCK';
    Caption := TraduireMemoire ('Voir le stock(WTT)');
    OnClick := VerdonVoirStockWTT;
    end;
  inc (fMaxItems);
  MesMenuItem[fMaxItems] := TmenuItem.Create (parent);
  with MesMenuItem[fMaxItems] do
    begin
    Caption := '-';
    end;
  inc (fMaxItems);

  for Indice := 0 to fMaxItems -1 do
    begin
      if MesMenuItem [Indice] <> nil then POPGS.Items.Add (MesMenuItem[Indice]);
    end;
end;

destructor TOptionVerdonSais.destroy;
var Indice : integer;
begin
  if not fActif then Exit;
  for Indice := 0 to fMaxItems -1 do
  begin
    MesMenuItem[Indice].Free;
  end;
  if fcreatedPop then POPGS.free;
  //
  inherited;
end;

procedure TOptionVerdonSais.VerdonVoirStockWTT (Sender : TObject);
begin
  TFFacture(FF).VerdonVoirStockClick(Sender); 
end;

end.
