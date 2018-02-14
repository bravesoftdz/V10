{***********UNITE*************************************************
Auteur  ...... :
Créé le ...... : 27/10/2017
Modifié le ... :   /  /
Description .. : Source TOF de la FICHE : BSAISIEAVANCPOC ()
Mots clefs ... : TOF;BSAISIEAVANCPOC
*****************************************************************}
Unit BSAISIEAVANCPOC_TOF ;

Interface

Uses StdCtrls,
     Controls,
     Classes,
     AglInit,
     M3FP,
{$IFNDEF EAGLCLIENT}
     db,
     {$IFNDEF DBXPRESS} dbtables, {$ELSE} uDbxDataSet, {$ENDIF}
     mul,Fe_Main,
{$else}
     eMul,
{$ENDIF}
     uTob,
     forms,
     sysutils,
     ComCtrls,
     HCtrls,
     HEnt1,
     HMsgBox,
     utofAfBaseCodeAffaire,
     UTOF ;
const
   stLigPP  = 'IND;BM8_PHASETRA;BM8_FAMILLENIV2;BM8_LIBELLE;BM8_QTEMARCHE;BM8_UNITE;BM8_POURCENTAVANC;BM8_QTEMOIS;BM8_QTECUMUL;BM8_RADQTE;QTEPROJETE;'; // production propre
   stLigMOI = 'IND;BM8_PHASETRA;BM8_FAMILLENIV2;BM8_LIBELLE;BM8_QTEMARCHE;BM8_UNITE;BM8_RADQTE;BM8_QTECUMUL;BM8_POURCENTAVANC;'; // Main d'oeuvre indirecte
   stLigFI  = 'IND;BM8_PHASETRA;BM8_FAMILLENIV2;BM8_LIBELLE;BM8_QTEMARCHE;BM8_UNITE;BM8_RADQTE;BM8_RADPU;BM8_RADMT;MTAVANCCALC;SUMQTECONSO;SUMMTCONSO;ECARTDEPENSE;'; // Frais indirect
   stLigST  = 'IND;BM8_PHASETRA;BM8_CODEMARCHE;BM8_FAMILLENIV2;BM8_LIBELLE;BM8_QTEMARCHE;BM8_UNITE;PU;DEPENSECUMUL;DEPENSEESTIME;POURCENTCALC;BM8_POURCENTAVANC;BM8_MTCUMUL;'; // Sous-traitance
   STAVANCSQL = 'SELECT BAVANCTECHDET.*, '+
                '0 AS QTEPROJETE,'+
                '0 AS MTAVANCCALC,'+
                '0 AS MTCUMULCALC,'+
                '0 AS SUMQTECONSO,'+
                '0 AS SUMMTCONSO,'+
                '0 AS ECARTDEPENSE,'+
                '0 AS DEPENSEESTIME,'+
                '0 AS POURCENTCALC,'+
                '0 AS DEPENSECUMUL,'+
                '"LIG" AS TYPELIGNE,'+
                '"-" AS NEWONE '+
                'FROM BAVANCTECHDET';
Type

  TTSaisie = (TmsPP,TmsMOI,TmsFI,TmsST);

  TGSaisie = class (TObject)
    fName : string;
    fGS : THGrid;
    fStCellCur : string;
    fListSaisie : string;
    TheMode : TTSaisie;
  end;

  TListGs = class(TList)
  private
    function Add(AObject: TGSaisie): Integer;
    function GetItems(Indice: integer): TGSaisie;
    procedure SetItems(Indice: integer; const Value: TGSaisie);
    procedure AddGrille(TG : THgrid; NomGrille, ListeSaisie: String);
  public
    constructor create;
    destructor destroy; override;
    property Items [Indice : integer] : TGSaisie read GetItems write SetItems;
    function findGrille (NomGrille : string ): TGSaisie;
    procedure clear; override;
  end;

  TOF_BSAISIEAVANCPOC = Class (TOF_AFBASECODEAFFAIRE)
    procedure OnNew                    ; override ;
    procedure OnDelete                 ; override ;
    procedure OnUpdate                 ; override ;
    procedure OnLoad                   ; override ;
    procedure OnArgument (S : String ) ; override ;
    procedure OnDisplay                ; override ;
    procedure OnClose                  ; override ;
    procedure OnCancel                 ; override ;
    procedure NomsChampsAffaire(var Aff, Aff0, Aff1, Aff2, Aff3, Aff4,Aff_, Aff0_, Aff1_, Aff2_, Aff3_, Aff4_, Tiers, Tiers_: THEdit); override;
  private
    TOBSTRUCTLIG : TOB;
    TOBSTDEPENSES : TOB;
    TheListGrid : TListGs;
    TOBPP,TOBMOI,TOBFI,TOBST : TOB;
    FFP,FFQ : string;
    // info de siasie sur grille courante
    StGrid: string;
    GS : THGrid;
    stCellCur : string;
    // ---
    procedure ChargeTOBS;
    procedure ChargeGrids;
    procedure PrepareGrids;
    procedure PrepareGrid(Nomgrille : String);
    procedure TraiteChamps(GS : THGrid;NomChamps: string;Colonne : integer);
    procedure MemoriseLigneSaisie;
    procedure SMemoriseLigneSaisie(QQ: TQuery);
    procedure AddlesChampsSupSaisie(TOBPT: TOB);
    procedure InsereElement(TOBPP, TL: TOB; IndDep: integer);
    function CreTOBLigne: TOB;
  end ;

Implementation
uses CalcOLEGenericBTP,UtilchampsSup,galPatience
;


procedure AGLAvancementPOC (Parms : array of variant ; nb : integer) ;
var TheParam  :string;
begin
  TheParam := 'BNATURE='+Parms[1]+';BSOUCHE='+Parms[2]+';BNUMERO='+Parms[3]+';BINDICEG='+Parms[4]+';BMOIS='+Parms[5]+';BAFFAIRE='+Parms[6];
  AGLLanceFiche('BTP','BSAISIEAVANCPOC','','','ACTION=MODIFICATION;'+TheParam);
  Sleep(1);
end;

procedure TOF_BSAISIEAVANCPOC.MemoriseLigneSaisie;
var QQ : TQuery;
begin
  QQ := OpenSQL(STAVANCSQL+' WHERE 1=2', True,-1, '', True);
  SMemoriseLigneSaisie(QQ);
  ferme (QQ);
end;

procedure TOF_BSAISIEAVANCPOC.SMemoriseLigneSaisie (QQ : TQuery);
var TOBEtalon : TOB;
		Indice : integer;
    NomChamps : string;
begin
  //
  TOBSTRUCTLIG.clearDetail;
	TOBEtalon := TOB.Create ('LA LIGNE ETALON',TOBSTRUCTLIG,-1);
  //
  for Indice := 0 to QQ.FieldCount -1 do
  begin
  	NomChamps := QQ.Fields[Indice].FieldName;
		if ExtractPrefixe (NomChamps) = 'BM9' then continue; // pour ne prendre que les champs sup
  	TOBEtalon.AddChampSupValeur (NomChamps,getValInitChampsSup(NomChamps));
  end;
end;

procedure TOF_BSAISIEAVANCPOC.AddlesChampsSupSaisie (TOBPT : TOB);
var Indice : integer;
		TOBEtl : TOB;
    NomChamps : string;
begin
	if TOBSTRUCTLIG.detail.count = 0 then exit;
  TOBEtl := TOBSTRUCTLIG.detail[0];
  //
  for Indice := 0 to TOBETL.NombreChampSup -1 do
  begin
  	NomChamps := TOBEtl.GetNomChamp(1000+Indice);
    if not TOBPT.FieldExists(NomChamps) then
    begin
  		TOBPT.AddChampSupValeur (NomChamps,TOBEtl.Getvaleur(1000+Indice));
    end;
  end;
end;


procedure TOF_BSAISIEAVANCPOC.OnNew ;
begin
  Inherited ;
end ;

procedure TOF_BSAISIEAVANCPOC.OnDelete ;
begin
  Inherited ;
end ;

procedure TOF_BSAISIEAVANCPOC.OnUpdate ;
begin
  Inherited ;
end ;

procedure TOF_BSAISIEAVANCPOC.OnLoad ;
var CodeAffaire,Aff0,Aff1,Aff2,Aff3,Aff4 : string;
    XX : TFPatience;

begin
  Inherited ;

//  XX := FenetrePatience('Récupération de l''avancement',aoMilieu, False,true);
//  XX.lAide.Caption := 'Préparation ...';
//  XX.StartK2000 ;
//  XX.Refresh;
  TRY
    CodeAffaire:=GetControlText ('BAFFAIRE');
    BTPCodeAffaireDecoupe (CodeAffaire,Aff0,Aff1,Aff2,Aff3,Aff4,tacreat,false);
    //
    SetControlText('BAFFAIRE0',aff0);
    SetControlText('BAFFAIRE1',aff1);
    SetControlText('BAFFAIRE2',aff2);
    SetControlText('BAFFAIRE3',aff3);
    SetControlText('BAVENANT',Aff4);
    //
    TOBPP := TOB.Create('SAISIE PP',nil,-1);
    TOBMOI := TOB.Create('SAISIE MOI',nil,-1);
    TOBFI := TOB.Create('SAISIE FI',nil,-1);
    TOBST := TOB.Create('SAISIE ST',nil,-1);
    //
    TheListGrid := TListGs.create;
    TheListGrid.AddGrille(THGrid(GetControl('GSPP')),'GSPP',stLigPP);
    TheListGrid.AddGrille(THGrid(GetControl('GSMOI')),'GSMOI',stLigMOI);
    TheListGrid.AddGrille(THGrid(GetControl('GSFI')),'GSFI',stLigFI);
    TheListGrid.AddGrille(THGrid(GetControl('GSST')),'GSST',stLigST);
    //
    //
    PrepareGrids;
    ChargeTOBS;
    ChargeGrids;
  FINALLY
//    XX.StopK2000 ;
//    XX.free;
  END;
end ;

procedure TOF_BSAISIEAVANCPOC.OnArgument (S : String ) ;

  procedure ChargePostesDepenses;
  var QQ: TQuery;
  begin
    QQ := OpenSql('SELECT * FROM BDEPENSESPOC',True,-1,'',true);
    if Not QQ.eof then
    begin
      TOBSTDEPENSES.LoadDetailDB('BDEPENSESPOC','','',QQ,false);
    end;
    ferme (QQ);
  end;

  function GetLibelleAffaire (TheAff : string) : string;
  var QQ: TQuery;
  begin
    Result := '';
    QQ := OpenSql ('SELECT AFF_LIBELLE FROM AFFAIRE WHERE AFF_AFFAIRE="'+TheAff+'"',True,1,'',True);
    if not QQ.eof then
    begin
      Result := QQ.fields[0].asstring;
    end;
    ferme (QQ);
  end;

  procedure ControleChamp (ChampMul,ValMul : string);
  begin
    if GetControl(ChampMul) <> nil then
    begin
      SetControlText(ChampMul,ValMul);
      if ChampMul = 'BMOIS' then
      begin
        SetControlText('MAAAA',Copy(ValMul,1,4));
        SetControlText('MMM',Copy(ValMul,5,2));
      end else if ChampMul = 'BAFFAIRE' then
      begin
        SetControlText('TAFFAIRELIBELLE',GetLibelleAffaire(ValMul))
      end;
    end;
  end;

var i : Integer;
    STSt,Critere,ChampMul,ValMul : string;
    X : Integer;
begin
  Inherited ;
  //
  TOBSTRUCTLIG := TOB.Create (' LA STRUCTURE LIGNE',nil,-1);
  TOBSTDEPENSES := TOB.Create ('LES POSTES',nil,-1);
  MemoriseLigneSaisie;
  //
  STSt := S;
  Repeat
    Critere:=uppercase(ReadTokenSt(STSt)) ;
    valMul := '';
    if Critere<>'' then
    begin
      x:=pos('=',Critere);
      if x<>0 then
      begin
        ChampMul:=copy(Critere,1,x-1);
        ValMul:=copy(Critere,x+1,length(Critere));
      end else
      begin
        ChampMul := Critere;
      end;
      ControleChamp(ChampMul, ValMul);
    end;
  until  Critere='';

  FFP := '#';
  if V_PGI.OkDecP > 0 then
  begin
    FFP := '0.';
    for i := 1 to V_PGI.OkDecP - 1 do
    begin
      FFP := FFP + '#';
    end;
    FFP := FFP + '0';
  end;
  //
  FFQ := '#';
  if V_PGI.OkDecQ > 0 then
  begin
    FFQ := '0.';
    for i := 1 to V_PGI.OkDecQ - 1 do
    begin
      FFQ := FFQ + '#';
    end;
    FFQ := FFQ + '0';
  end;
  //
  ChargePostesDepenses;
end ;

procedure TOF_BSAISIEAVANCPOC.OnClose ;
begin
  TOBSTDEPENSES.free;
  TOBSTRUCTLIG.free;
  Inherited ;
end ;

procedure TOF_BSAISIEAVANCPOC.OnDisplay () ;
begin
  Inherited ;
end ;

procedure TOF_BSAISIEAVANCPOC.OnCancel () ;
begin
  Inherited ;
end ;

procedure TOF_BSAISIEAVANCPOC.NomsChampsAffaire(var Aff, Aff0, Aff1, Aff2, Aff3, Aff4, Aff_, Aff0_, Aff1_, Aff2_, Aff3_, Aff4_, Tiers, Tiers_:THEdit);
begin
Aff:=THEdit(GetControl('BAFFAIRE'));
Aff0:=THEdit(GetControl('BAFFAIRE0'));
Aff1:=THEdit(GetControl('BAFFAIRE1'));
Aff2:=THEdit(GetControl('BAFFAIRE2')); Aff3:=THEdit(GetControl('BAFFAIRE3'));
Aff4:=THEdit(GetControl('BAVENANT'));
end;

procedure TOF_BSAISIEAVANCPOC.ChargeGrids;
begin

end;

function TOF_BSAISIEAVANCPOC.CreTOBLigne : TOB;
begin
  Result := TOB.Create ('BAVANCTECHDET',nil,-1);
  Result.SetString ('BM8_NATUREPIECEG',GetControlText('BNATURE'));
  Result.SetString ('BM8_SOUCHE',GetControlText('BSOUCHE'));
  Result.SetInteger ('BM8_NUMERO',StrToInt(GetControlText('BNUMERO')));
  Result.SetInteger ('BM8_INDICEG',StrToInt(GetControlText('BINDICEG')));
  Result.SetString ('BM8_MOIS',GetControlText('BMOIS'));
  AddlesChampsSupSaisie (Result);
  Result.SetString ('NEWONE','X');
  Result.SetString ('LIG','X');
end;


procedure TOF_BSAISIEAVANCPOC.InsereElement (TOBPP,TL: TOB; IndDep : integer);
var II,LastPos : Integer;
    TOBL,TOBI : TOB;
begin
  LastPos := -1;
  for II := IndDep to TOBPP.detail.Count -1 do
  begin
    TOBL := TOBPP.detail[II];
    if (TOBL.GetString('BM8_PHASETRA')=TL.GetString('BM8_PHASETRA')) AND
       (TOBL.GetString('BM8_CODEMARCHE')=TL.GetString('BM8_CODEMARCHE')) then LastPos := TOBL.GetIndex;
    if (TOBL.GetString('BM8_PHASETRA')<>TL.GetString('BM8_PHASETRA')) OR
       (TOBL.GetString('BM8_CODEMARCHE')<>TL.GetString('BM8_CODEMARCHE')) then Break;
  end;
  if LastPos <> -1 then
  begin
    TOBI := CreTOBLigne;
    TOBI.Dupliquer(TL,False,true);
    TOBI.ChangeParent(TOBPP,LastPos+1); 
  end;
end;

procedure TOF_BSAISIEAVANCPOC.ChargeTOBS;

  function WhereDoc (racine : string) : string;
  begin
    Result := Racine + '_NATUREPIECEG="'+GetControlText('BNATURE')+'" AND '+
              Racine + '_SOUCHE="'+GetControlText('BSOUCHE')+'" AND '+
              Racine + '_NUMERO='+GetControlText('BNUMERO')+' AND '+
              Racine + '_INDICEG='+GetControlText('BINDICEG');
  end;


  function CreTOBLigneStruct : TOB;
  begin
    Result := TOB.Create ('BAVANCTECHDET',nil,-1);
    Result.SetString ('BM8_NATUREPIECEG',GetControlText('BNATURE'));
    Result.SetString ('BM8_SOUCHE',GetControlText('BSOUCHE'));
    Result.SetInteger ('BM8_NUMERO',StrToInt(GetControlText('BNUMERO')));
    Result.SetInteger ('BM8_INDICEG',StrToInt(GetControlText('BINDICEG')));
    Result.SetString ('BM8_MOIS',GetControlText('BMOIS'));
    AddlesChampsSupSaisie (Result);
    Result.SetString ('NEWONE','-');
    Result.SetString ('LIG','-');
  end;

  procedure RecupExistant (TT,TOBD : TOB);
  var II,IndDep : Integer;
      TL,TI : TOB;
  begin
    for II := 0 to TT.Detail.count -1 do
    begin
      TL := TT.detail[II];

      if Pos(TL.GetString('GL_FAMILLENIV2'),TOBSTRUCTLIG.GetString('BM7_PRODPOC'))>0 then
      begin
        TI := TOBPP.FindFirst(['BM8_PHASETRA','BM8_CODEMARCHE'],[TL.GetString('BM8_PHASETRA'),TL.GetString('BM8_CODEMARCHE')],true);
        if TI <> nil then
        begin
          IndDep := TI.GetIndex;
          InsereElement (TOBPP,TL,IndDep);
        end;
      end else if Pos(TL.GetString('GL_FAMILLENIV2'),TOBSTRUCTLIG.GetString('BM7_PRODMOI'))>0 then
      begin
        TI := TOBMOI.FindFirst(['BM8_PHASETRA','BM8_CODEMARCHE'],[TL.GetString('BM8_PHASETRA'),TL.GetString('BM8_CODEMARCHE')],true);
        if TI <> nil then
        begin
          IndDep := TI.GetIndex;
          InsereElement (TOBMOI,TL,IndDep);
        end;
      end else if Pos(TL.GetString('GL_FAMILLENIV2'),TOBSTRUCTLIG.GetString('BM7_PRODFI'))>0 then
      begin
        TI := TOBFI.FindFirst(['BM8_PHASETRA','BM8_CODEMARCHE'],[TL.GetString('BM8_PHASETRA'),TL.GetString('BM8_CODEMARCHE')],true);
        if TI <> nil then
        begin
          IndDep := TI.GetIndex;
          InsereElement (TOBFI,TL,IndDep);
        end;
      end else if Pos(TL.GetString('GL_FAMILLENIV2'),TOBSTRUCTLIG.GetString('BM7_PRODST'))>0 then
      begin
        TI := TOBST.FindFirst(['BM8_PHASETRA','BM8_CODEMARCHE'],[TL.GetString('BM8_PHASETRA'),TL.GetString('BM8_CODEMARCHE')],true);
        if TI <> nil then
        begin
          IndDep := TI.GetIndex;
          InsereElement (TOBST,TL,IndDep);
        end;
      end;
    end;
  end;

  procedure AffecteStructure(TTS : TOB; Mois : string);
  var II : Integer;
      TTPP,TTL: TOB;
  begin
    For II := 0 to TTS.Detail.Count -1 do
    begin
      TTL := TTS.detail[II];
      //
      TTPP := CreTOBLigneStruct;
      TTPP.SetString('BM8_PHASETRA',TTL.GetString('BLP_PHASETRA'));
      TTPP.SetString('LIBELLE',TTL.GetString('GL_LIBELLE'));
      TTPP.ChangeParent(TOBPP,-1);
      //
      TTPP := CreTOBLigneStruct;
      TTPP.SetString('BM8_PHASETRA',TTL.GetString('BLP_PHASETRA'));
      TTPP.SetString('LIBELLE',TTL.GetString('GL_LIBELLE'));
      TTPP.ChangeParent(TOBMOI,-1);
      //
      TTPP := CreTOBLigneStruct;
      TTPP.SetString('BM8_PHASETRA',TTL.GetString('BLP_PHASETRA'));
      TTPP.SetString('LIBELLE',TTL.GetString('GL_LIBELLE'));
      TTPP.ChangeParent(TOBFI,-1);
      //
      TTPP := CreTOBLigneStruct;
      TTPP.SetString('BM8_PHASETRA',TTL.GetString('BLP_PHASETRA'));
      TTPP.SetString('LIBELLE',TTL.GetString('GL_LIBELLE'));
      TTPP.ChangeParent(TOBST,-1);
    end;
  end;

  procedure ExamineEtComplete(TTL,TTOP : TOB);
  var II : Integer;
      TOBL : TOB;
  begin
    For II := 0 to TTL.detail.count -1 do
    begin
      TOBL := TTL.detail[II];
      if TOBL.GetString('GL_TYPELIGNE')<>'ART' then Continue;
      if Pos(TOBL.GetSTring('GL_TYPEARTICLE'),'OUV;ARP;')>0 then
      begin

      end else
      begin

      end;
    end;
  end;



var QQ : Tquery;
    SQL : String;
    TT,TTL,TTD,TTS,TTOP : TOB;
    Mois : string;
begin
  TT := TOB.Create ('LES REGISTRED',nil,-1);
  TTD := TOB.Create ('LES REGISTRED DET',nil,-1);
  TTL := TOB.Create ('LE DOCUMENT',nil,-1);
  TTOP := TOB.Create ('OUVRAGES PLAT',nil,-1);
  //
  TTS := TOB.Create ('LA STRUCTURE',nil,-1);
  SQL := 'SELECT BLP_PHASETRA,GL_LIBELLE FROM LIGNEPHASES '+
                'LEFT JOIN LIGNE ON BLP_NATUREPIECEG=GL_NATUREPIECEG AND BLP_SOUCHE=GL_SOUCHE AND BLP_NUMERO=GL_NUMERO AND BLP_NUMORDRE=GL_NUMORDRE '+
                'WHERE '+WhereDoc('BLP');
  QQ := OpenSQL(SQL,True,-1,'',True);
  if not QQ.eof then TTS.loadDetailDb('LIGNEPHASES','','',QQ,false);
  Ferme(QQ);
  //
  //
  Mois := GetControlText('BMOIS');
  TRY
    SQL := STAVANCSQL + ' WHERE '+ WhereDoc ('BM8')+' AND BM8_MOIS = '+Mois;
    if not ExisteSQL(SQL) then
    begin
      QQ := OpenSQL('SELECT MAX(BM9_MOIS) FROM BAVANCTECH WHERE '+WhereDoc('BM9'),True,1,'',True);
      if not QQ.eof then
      begin
        Mois := QQ.Fields[0].AsString;
      end else
      begin
        Mois := '';
      end;
      ferme (QQ);
    end;
    //
    if Mois <> '' then
    begin
      SQL := STAVANCSQL + ' WHERE '+WhereDoc ('BM8')+' AND BM8_MOIS = '+Mois;
      if ExisteSQL(SQL) then
      begin
        QQ := OpenSQL(SQL,True,-1,'',true);
        //
        if not QQ.eof then
        begin
          TT.LoadDetailDB('BAVANCTECHDET','','',QQ,false);
          ferme (QQ);
          //
          SQL := 'SELECT * FROM BAVANCTECHDL WHERE '+ WhereDoc('BMB')+' AND BMB_MOIS="'+Mois+'"';
          QQ := OpenSQL(SQL,True,-1,'',true);
          if not QQ.Eof then TTD.LoadDetailDB('BAVANCTECHDL','','',QQ,false);
        end;
        Ferme(QQ);
      end;
    end;
    //
    AffecteStructure(TTS,mois);
    // récup de l'existant
    RecupExistant (TT,TTD);
    //
    SQL := 'SELECT LIGNE.*,(SELECT CC_LIBELLE FROM CHOIXCOD WHERE CC_TYPE="FN2" AND CC_CODE=GL_FAMILLENIV2) AS LIBELLE FROM LIGNE WHERE '+ WhereDoc('GL')+' ORDER BY GL_NUMLIGNE';
    QQ := OpenSQL(SQL,true,-1,'',true);
    if not QQ.Eof then
    begin
      TTL.LoadDetailDB('LIGNE','','',QQ,false);
    end;
    Ferme(QQ);
    //
    SQL := 'SELECT LIGNEOUVPLAT.*,(SELECT CC_LIBELLE FROM CHOIXCOD WHERE CC_TYPE="FN2" AND CC_CODE=BOP_FAMILLENIV2) AS LIBELLE FROM LIGNEOUVPLAT WHERE '+ WhereDoc('BOP')+' ORDER BY BOP_NUMORDRE';
    QQ := OpenSQL(SQL,true,-1,'',true);
    if not QQ.Eof then
    begin
      TTOP.LoadDetailDB('LIGNE','','',QQ,false);
    end;
    Ferme(QQ);
    //
    ExamineEtComplete(TTL,TTOP);
  FINALLY

    TT.Free;
    TTL.free;
    TTD.free;
    TTS.free;
    TTOP.Free;
  END;
end;

procedure TOF_BSAISIEAVANCPOC.PrepareGrids;
begin
  PrepareGrid('GSPP');
  PrepareGrid('GSMOI');
  PrepareGrid('GSFI');
  PrepareGrid('GSST');
end;


procedure TOF_BSAISIEAVANCPOC.PrepareGrid ( Nomgrille : String);
var II : Integer;
    STST,STdet : string;
    TGS : TGSaisie;
begin
  TGS := TheListGrid.findGrille(Nomgrille);
  STST := TGS.fListSaisie;
  II := 0;
  STdet := READTOKENST(STST);
  repeat
    if STDET = '' then exit;
    TraiteChamps(TGS.fGS,STDET,II);
    STdet := READTOKENST(STST);
    inc(II);
  until STdet = '';
end;

procedure TOF_BSAISIEAVANCPOC.TraiteChamps(GS: THGrid; NomChamps: string; Colonne: integer);
begin
  if GS.colCount < colonne +1 then GS.colCount := GS.ColCOunt + 1;  
  if NomChamps='IND' then
  begin
    GS.cells[Colonne,0] := ' ';
    GS.ColWidths [Colonne] := 20;
    GS.ColEditables[Colonne] := false;
  end else if NomChamps='BM8_PHASETRA' then
  begin
    GS.cells[Colonne,0] := 'Phase';
    GS.ColWidths[colonne] := 48;
    GS.ColAligns[Colonne] := taLeftJustify;
  end else if NomChamps='TYPEARTICLE' then
  begin
    GS.cells[Colonne,0] := ' ';
    GS.ColWidths[colonne] := 48;
    GS.ColAligns[Colonne] := taLeftJustify;
  end else if NomChamps='BM8_CODEMARCHE' then
  begin
    GS.cells[Colonne,0] := 'Marché S/T';
    GS.ColWidths[colonne] := 70;
    GS.ColLengths[colonne] := 17;
    GS.ColAligns[Colonne] := taLeftJustify;
  end else if NomChamps='BM8_FAMILLENIV2' then
  begin
    GS.cells[Colonne,0] := 'Code';
    GS.ColWidths[colonne] := 75;
    GS.ColLengths[colonne] := 3;
    GS.ColAligns[Colonne] := taLeftJustify;
  end else if NomChamps='LIBFAMILLE2' then
  begin
    GS.cells[Colonne,0] := 'Analytique';
    GS.ColWidths[colonne] := 50*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 70;
    GS.ColAligns[Colonne] := taLeftJustify;
  end else if NomChamps='BM8_QTEMARCHE' then
  begin
    GS.cells[Colonne,0] := 'Quantité';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := FFQ+';'+FFQ+'; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='BM8_UNITE' then
  begin
    GS.cells[Colonne,0] := 'Unité';
    GS.ColWidths[colonne] := 5*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 5;
    GS.ColAligns[Colonne] := taCenter;
  end else if NomChamps='BM8_POURCENTAVANC' then
  begin
    GS.cells[Colonne,0] := '% Avct';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := '#0.00;#0.00; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='BM8_QTEMOIS' then
  begin
    GS.cells[Colonne,0] := 'Qté Avct';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := FFQ+';'+FFQ+'; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='BM8_QTECUMUL' then
  begin
    GS.cells[Colonne,0] := 'Qté Dépensés Cumul.';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := FFQ+';'+FFQ+'; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='BM8_RADQTE' then
  begin
    GS.cells[Colonne,0] := 'Qté RAD';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := FFQ+';'+FFQ+'; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='BM8_QTECUMUL' then
  begin
    GS.cells[Colonne,0] := 'Qté Fin chantier';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := FFQ+';'+FFQ+'; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='BM8_RADPU' then
  begin
    GS.cells[Colonne,0] := 'RAD Pu';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := FFP+';'+FFP+'; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='BM8_RADMT' then
  begin
    GS.cells[Colonne,0] := 'RAD Mt';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := '#0 000.00;#0 000.00; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='MTAVANCCALC' then
  begin
    GS.cells[Colonne,0] := 'Mt Avanc. Calc.';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := '#0 000.00;#0 000.00; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='SUMQTECONSO' then
  begin
    GS.cells[Colonne,0] := 'Qté Cumulé Cons.';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := FFQ+';'+FFQ+'; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='SUMMTCONSO' then
  begin
    GS.cells[Colonne,0] := 'Mt Cumulé Cons.';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := '#0 000.00;#0 000.00; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='ECARTDEPENSE' then
  begin
    GS.cells[Colonne,0] := 'Variation M/M-1';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := '#0 000.00;#0 000.00; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='PU' then
  begin
    GS.cells[Colonne,0] := 'Pu Achat';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := FFP+';'+FFP+'; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='DEPENSECUMUL' then
  begin
    GS.cells[Colonne,0] := 'Dépenses Cumul.';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := '#0 000.00;#0 000.00; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='DEPENSEESTIME' then
  begin
    GS.cells[Colonne,0] := 'Dépenses Estimées';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := '#0 000.00;#0 000.00; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='POURCENTCALC' then
  begin
    GS.cells[Colonne,0] := '% Avct calc.';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := '#0.00;#0.00; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end else if NomChamps='BM8_MTCUMUL' then
  begin
    GS.cells[Colonne,0] := 'MT Avct corrigé';
    GS.ColWidths[colonne] := 12*GS.canvas.TextWidth('w');
    GS.ColLengths[colonne] := 12;
    GS.ColFormats[colonne] := '#0.00;#0.00; ;';
    GS.ColAligns[Colonne] := taRightJustify;
  end;
end;

{ TListGs }

function TListGs.Add(AObject: TGSaisie): Integer;
begin
	Result := inherited ADD(Aobject);
end;

procedure TListGs.AddGrille(TG : THgrid; NomGrille, ListeSaisie: String);
var TT : TGSaisie;
begin
  TT := TGSaisie.Create;
  TT.fName := NomGrille;
  TT.fGS := TG;
  TT.fListSaisie := ListeSaisie;
  add(TT);
end;

procedure TListGs.clear;
var indice : integer;
begin
  if count > 0 then
  begin
    for Indice := count -1 downto 0 do
    begin
      if TGSaisie(Items [Indice])<> nil then
      begin
         TGSaisie (Items [Indice]).free;
         Items[Indice] := nil;
      end;
    end;
  end;
  Pack;
  inherited;
end;

constructor TListGs.create;
begin

end;

destructor TListGs.destroy;
begin
	clear;
  inherited;
end;

function TListGs.findGrille(NomGrille: string): TGSaisie;
var Indice : integer;
begin
  result := nil;
  for Indice := 0 to Count -1 do
  begin
    if Items[Indice].fName = NomGrille then
    begin
      result:=Items[Indice];
      break;
    end;
  end;
end;

function TListGs.GetItems(Indice: integer): TGSaisie;
begin
  result := TGSaisie (Inherited Items[Indice]);
end;

procedure TListGs.SetItems(Indice: integer; const Value: TGSaisie);
begin
  Inherited Items[Indice]:= Value;
end;

Initialization
  RegisterAglProc( 'SaisAvancementPOC',True,6,AGLAvancementPOC);
  registerclasses ( [ TOF_BSAISIEAVANCPOC ] ) ;

end.
