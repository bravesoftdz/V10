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
  TTypeEnvoi = (TTevMt,TTevST);
  
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

var TOBDestVERDON : TOB;

procedure ConstitueAffaireVerdon(FF : TForm);
procedure TraiteAcceptationVerdon (naturepiece,souche : string; numero,Indice : integer);
procedure ChargeDestinatairesVerdon;
procedure LibereDestinatairesVerdon;

implementation

uses Facture,
     FactTOB,
     UtilsMail
     ;
procedure LibereDestinatairesVerdon;
begin
  TOBDestVERDON.free;
  TOBDestVERDON := nil;
end;

procedure ChargeDestinatairesVerdon;
var QQ : Tquery;
begin
  if TOBDestVERDON = nil then
  begin
    TOBDestVERDON := TOB.Create ('LES DESTINATAIRES',nil,-1);
  end;
  QQ := OpenSQL('SELECT * FROM BTVERDDESTMAIL',True,-1,'',True);
  if not QQ.eof then
  begin
    TOBDestVERDON.LoadDetailDB('BVERDESTMAIL','','',QQ,false);
  end;
  Ferme(QQ);
end;

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


procedure EnvoiMail (TOBP : TOB; NatureEnvoie : TTypeEnvoi);
var XX : TGestionMail;
    QualifTexte : string;
begin
  XX := TGestionMail.Create(Application);

  if NatureEnvoie=TTevMt then
      XX.Sujet := 'Acceptation de devis - Depassement montant'
  else
      XX.Sujet := 'Acceptation de devis - Sous traitance présente';
  //    
  XX.Corps := hTStringList.Create;
  XX.Corps.Clear ;

  XX.Copie         := '';
  XX.TypeContact   := '';
  XX.Fournisseur   := '';
  XX.FichierSource := '';
  XX.FichierTempo  := '';
  XX.Fichiers      := '';
  XX.TypeDoc       := '';
  //Pourrait être déterminé par le type d'enregistrement traité ou par le type de planning (????)
  XX.Tiers         := '';
  XX.Contact       := '';
  XX.Destinataire  := '';
  if NatureEnvoie=TTevMt then
  begin
    XX.QualifMail    := 'VVM';
  end else if NatureEnvoie=TTevST then
  begin
    XX.QualifMail    := 'VVS';
  end;
  XX.TobRapport    := TOBP;
  XX.GestionParam  := True;
  XX.ListeDestinataires := TOBDestVERDON;

  XX.AppelEnvoiMail (false,False);

  FreeAndNil(XX);

end;

procedure TraiteAcceptationVerdon (naturepiece,souche : string; numero,Indice : integer);
var TT : TOB;
    QQ : TQuery;
    SQl : string;
    MtAccepte,MtDevis : double;
    StPresent : Boolean;
begin
    StPresent := false;
    MtAccepte := 0;
    MtDevis := 0;
    TT := TOB.Create ('PIECE',nil,-1);
    TRY
      SQL := 'SELECT * FROM PIECE '+
             'LEFT JOIN TIERS ON T_NATUREAUXI="CLI" AND GP_TIERS=T_TIERS '+
             'LEFT JOIN AFFAIRE ON GP_AFFAIRE=AFF_AFFAIRE '+
             'WHERE '+
             'GP_NATUREPIECEG="'+naturepiece+'" AND '+
             'GP_SOUCHE="'+Souche+'" AND '+
             'GP_NUMERO='+InttoStr(Numero)+' AND '+
             'GP_INDICEG='+InttoStr(Indice);
      QQ := OpenSql (SQL,True,1,'',true);
      begin
        if not QQ.eof then
        begin
          TT.SelectDB('',QQ);
          MtDevis := TT.GetDouble('GP_TOTALHTDEV');
        end;
      end;
      ferme (QQ);
      //
      SQL := 'SELECT SUM(P2.GP_TOTALHTDEV) FROM PIECE P2 '+
             'WHERE '+
             'P2.GP_AFFAIRE=(SELECT P1.GP_AFFAIRE FROM PIECE P1 WHERE '+
             'P1.GP_NATUREPIECEG="'+naturepiece+'" AND '+
             'P1.GP_SOUCHE="'+Souche+'" AND '+
             'P1.GP_NUMERO='+InttoStr(Numero)+' AND '+
             'P1.GP_INDICEG='+InttoStr(Indice)+') AND '+
             '(SELECT AFF_ETATAFFAIRE FROM AFFAIRE WHERE AFF_AFFAIRE=P2.GP_AFFAIREDEVIS)="ACP"';
      QQ := OpenSql (SQL,True,1,'',true);
      begin
        if not QQ.eof then
        begin
          MtAccepte := QQ.fields[0].AsFloat;
        end;
      end;
      ferme (QQ);
      //
      SQL := 'SELECT 1 AS EXIST FROM LIGNE '+
             'LEFT JOIN ARTICLE ON GL_ARTICLE=GA_ARTICLE '+
             'WHERE '+
             'GA_NATUREPRES IN (SELECT BNP_NATUREPRES FROM NATUREPREST WHERE BNP_TYPERESSOURCE="ST") AND '+
             'GL_NATUREPIECEG="'+naturepiece+'" AND '+
             'GL_SOUCHE="'+Souche+'" AND '+
             'GL_NUMERO='+InttoStr(Numero)+' AND '+
             'GL_INDICEG='+InttoStr(Indice);
      if ExisteSQL(SQL) then
      begin
        StPresent := True;
      end;
      //
      if ARRONDI(MtAccepte+MTDevis,V_PGI.okdecV) > 25000 then
      begin
        // Envoie mail pour montant depassé
        EnvoiMail (TT,TTevMt);
      end else if StPresent then
      begin
        EnvoiMail (TT,TTevST);
        // Envoie mail pour sous traitance      
      end;
    FINALLY
      TT.free;
    END;

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
