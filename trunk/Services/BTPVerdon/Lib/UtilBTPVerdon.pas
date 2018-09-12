unit UtilBTPVerdon;

interface

uses
  ConstServices
  , uTob
  , CommonTools
  , AdoDB
  , Classes
  , XmlIntf
  , XMLDoc
  ;

type

  T_TablesName = (tnNone, tnChantier, tnDevis, tnLignesBR, tnTiers);

  T_ThirdXmlFileType = (  txft_None
                        , txft_BankAccount_Code
                        , txft_BankAccountType_Code
                        , txft_Bank_Code
                        , txft_SwiftCode
                        , txft_Bic
                       );

  T_TiersValues    = Record
                       FirstExec   : boolean;
                       Count       : integer;
                       TimeOut     : integer;
                       LastSynchro : string;
                       IsActive    : boolean;
                     end;

  T_ChantierValues = Record
                       FirstExec   : boolean;
                       Count       : integer;
                       TimeOut     : integer;
                       LastSynchro : string;
                       IsActive    : boolean;
                     end;

  T_DevisValues    = Record
                       FirstExec   : boolean;
                       Count       : integer;
                       TimeOut     : integer;
                       LastSynchro : string;
                       IsActive    : boolean;
                     end;

  T_LignesBRValues = Record
                       FirstExec   : boolean;
                       Count       : integer;
                       TimeOut     : integer;
                       LastSynchro : string;
                       IsActive    : boolean;
                     end;

  T_FolderValues   = Record
                       BTPConnectionName : string;
                       BTPUserAdmin      : string;
                       BTPServer         : string;
                       BTPDataBase       : string;
                       TMPServer         : string;
                       TMPDataBase       : string;
                     end;

  TUtilBTPVerdon = class (TObject)
    class function GetTMPTableName(Tn : T_TablesName) : string;
    class function GetMsgStartEnd(Tn : T_TablesName; Start : boolean; LastSynchro : string) : string;
    class function AddLog(ServiceName : string; Tn : T_TablesName; Msg : string; LogValues : T_WSLogValues; LineLevel : integer) : string;
    class procedure AddFieldsTobAdd(Tn : T_TablesName; TobResult : TOB);
    class procedure AssignAdoQry(AdoQryBTP, AdoQryTMP : AdoQry; FolderValues : T_FolderValues; LogValues : T_WSLogValues);
  end;

  TTnTreatment = class (TObject)
  private
    BTPArrFields     : array of string;
    TMPArrFields     : array of string;
    BTPArrAdditionalFields : array of string;
    TMPArrAdditionalFields : array of string;

    function GetPrefix : string;
    function GetTMPFieldName(BTPFieldName : string) : string;
    function GetTMPIndexFieldName : string;
    function GetBTPIndexFieldName : string;
    function GetBTPLabelFieldName : string;
    (* ---------
    function ExtractFieldName(Value : string) : string;
    function ExtractFieldType(Value : string) : string;
    ---------- *)
    function SetFieldsArray : boolean;
    function GetSqlDataExist(FieldsList, KeyValue1, KeyValue2 : string) : string;
    function GetSystemFields : string;
    function GetFieldsListFromArray(ArrData : array of string; WithType : boolean) : string;
    function GetValue(FieldNameBTP, FieldNameTMP : string; FieldType : tTypeField; TobData : TOB) : string;
    function GetSqlInsertFields : string;
    function GetSqlInsertAdditionalFields : string;
    function GetSqlInsertValues(TobData : TOB; IsAdditional : boolean=False) : string;
    function GetSqlUpdate(TobData, TobAdd : TOB; KeyValue1, KeyValue2 : string) : string;
    function GetSqlInsert(TobData, TobAdd : TOB) : string;
    function GetDataSearchSql : string;
    function GetTMPFieldSizeMax(FieldName : string) : integer;
    function InsertUpdateData(TobData: TOB): boolean;
    procedure SetLinkedRecords(TobAdd, TobData : TOB);
    procedure SetLastSynchro(ServiceName : string);
//    procedure TStringListToTOB(TslValues : TStringList; ArrOfFields : array of string; TobResult : TOB; WithType : boolean);

  public
    Tn           : T_TablesName;
    LogValues    : T_WSLogValues;
    FolderValues : T_FolderValues;
    LastSynchro  : string;
    AdoQryBTP    : AdoQry;
    AdoQryTMP    : AdoQry;

    function TnTreatment(TobTable, TobAdd, TobQry: TOB): boolean;
  end;

  {$IFNDEF APPSRV}
  TExportEcr = class (TObject)
  private
    MsgCaption         : string;
    FolderCode         : string;
    PathXMLFileVTE     : string;
    PathXMLFileACH     : string;
    PathXMLFileCLI     : string;
    PathXMLFileFOU     : string;
    TempPathXMLFileVTE : string;
    TempPathXMLFileACH : string;
    TempPathXMLFileCLI : string;
    TempPathXMLFileFOU : string;
    TobEcrVen          : TOB;
    TobEcrAch          : TOB;
    TobEcrP            : TOB;
    TobCustomer        : TOB;
    TobProvider        : TOB;
    LineNumber         : integer;
    TslData            : TStringList;

    function LoadEcr : boolean;
    function LoadAnalytic : boolean;
    function GetAmount(Amount : double; PositiveValue : boolean) : string;
    function AddEntryToFile(GLEntries : IXMLNode) : boolean;
    function AddThirdToFile(Accounts : IXMLNode; TobData : TOB) : boolean;

  public
    StartDate   : TDateTime;
    EndDate     : TDateTime;
    ForceExport : boolean;

    constructor create;
    destructor destroy; override;
    function ExpTreatment : boolean;
  end;
  {$ENDIF APPSRV}

const
  DBSynchroName          = 'GLO_LSE_SYNCHRONISATION';
  LockDefaultValue       = 'O';
  TraiteDefaultValue     = 'N';
  DateTraiteDefaultValue = '19000101';

implementation

uses
  SysUtils
  , hEnt1
  , IniFiles
  , hCtrls
  , SvcMgr
  , ParamSoc
  , ed_Tools
  , Windows
  , UWinSystem
  {$IFNDEF DBXPRESS}
  , dbTables
  {$ELSE !DBXPRESS}
  , uDbxDataSet
  {$ENDIF !DBXPRESS}
  {$IFNDEF APPSRV}
  , hMsgBox
  , Controls
  , FactCpta
  , EntGC
  , UtilGC
  {$ENDIF APPSRV}
  ;

{ TUtilBTPVerdon }

class function TUtilBTPVerdon.GetTMPTableName(Tn : T_TablesName): string;
begin
  case Tn of
    tnChantier : Result := 'CHANTIER';
    tnDevis    : Result := 'DEVIS';
    tnLignesBR : Result := 'LIGNESBR';
    tnTiers    : Result := 'TIERS';
  else
    Result := '';
  end;
end;

class function TUtilBTPVerdon.GetMsgStartEnd(Tn : T_TablesName; Start : boolean; LastSynchro : string) : string;
begin
  Result := Format('%s de traitement de la table %s (donn�es cr��es ou modifi�es depuis le %s).', [Tools.iif(Start, 'D�but', 'Fin'), TUtilBTPVerdon.GetTMPTableName(Tn), LastSynchro]);
end;

class function TUtilBTPVerdon.AddLog(ServiceName : string; Tn : T_TablesName; Msg : string; LogValues : T_WSLogValues; LineLevel : integer) : string;
begin
  TServicesLog.WriteLog(ssbylLog, Msg, ServiceName_BTPVerdonImp, LogValues, LineLevel, True, TUtilBTPVerdon.GetTMPTableName(Tn));
end;

class procedure TUtilBTPVerdon.AddFieldsTobAdd(Tn : T_TablesName; TobResult : TOB);
begin
  case Tn of
    tnChantier :
      begin
        TobResult.AddChampSupValeur('LADR_LIBELLE'    , '');
        TobResult.AddChampSupValeur('LADR_ADRESSE1'   , '');
        TobResult.AddChampSupValeur('LADR_ADRESSE2'   , '');
        TobResult.AddChampSupValeur('LADR_ADRESSE3'   , '');
        TobResult.AddChampSupValeur('LADR_CODEPOSTAL' , '');
        TobResult.AddChampSupValeur('LADR_VILLE'      , '');
        TobResult.AddChampSupValeur('LADR_PAYS'       , '');
        TobResult.AddChampSupValeur('LADR_TYPEADRESSE', 'INT');
        TobResult.AddChampSupValeur('FADR_LIBELLE'    , '');
        TobResult.AddChampSupValeur('FADR_ADRESSE1'   , '');
        TobResult.AddChampSupValeur('FADR_ADRESSE2'   , '');
        TobResult.AddChampSupValeur('FADR_ADRESSE3'   , '');
        TobResult.AddChampSupValeur('FADR_CODEPOSTAL' , '');
        TobResult.AddChampSupValeur('FADR_VILLE'      , '');
        TobResult.AddChampSupValeur('FADR_PAYS'       , '');
        TobResult.AddChampSupValeur('FADR_TYPEADRESSE', 'AFA');
        TobResult.AddChampSupValeur('LISTEDEVIS'      , '');
        TobResult.AddChampSupValeur('CODESOCIETE'     , GetParamSocSecur('SO_SOCIETE', ''));
      end;
  end;
end;

class procedure TUtilBTPVerdon.AssignAdoQry(AdoQryBTP, AdoQryTMP : AdoQry; FolderValues : T_FolderValues; LogValues : T_WSLogValues);
begin
  AdoQryBTP.ServerName           := FolderValues.BTPServer;
  AdoQryBTP.DBName               := FolderValues.BTPDataBase;
  AdoQryBTP.PgiDB                := 'X';
  AdoQryBTP.Qry.ConnectionString := AdoQryBTP.GetConnectionString;
  AdoQryBTP.LogValues            := LogValues;
  AdoQryTMP.ServerName           := FolderValues.TMPServer;
  AdoQryTMP.DBName               := FolderValues.TMPDataBase;
  AdoQryTMP.PgiDB                := '-';
  AdoQryTMP.Qry.ConnectionString := AdoQryTMP.GetConnectionString;
  AdoQryTMP.LogValues            := LogValues;
end;

{ TTnTreatment }
(* --
function TTnTreatment.ExtractFieldName(Value : string) : string;
begin
  Result := copy(Value, 1, pos(';', Value) -1)
end;

function TTnTreatment.ExtractFieldType(Value : string) : string;
begin
  Result := copy(Value, pos(';', Value) +1,length(Value));
end;
--- *)

function TTnTreatment.SetFieldsArray : boolean;
var
  Cpt       : integer;
  ArrLen    : integer;

  function GetTMPFieldType(FieldName, BTPFieldType : string) : string;
  begin
    case Tools.CaseFromString(FieldName, ['LBR_CODEARTICLE']) of
      {LBR_CODEARTICLE} 0 : Result := 'INTEGER';
    else
      Result := BTPFieldType;
    end;
  end;


  procedure AddValues(BTPFieldName, TMPFieldName : string; IsAdditional : boolean=False);
  var
    FieldType : string;
  begin
    if not IsAdditional then
    begin
      AdoQryBTP.FieldsList := 'DH_TYPECHAMP';
      AdoQryBTP.Request    := 'SELECT ' + AdoQryBTP.FieldsList + ' FROM DECHAMPS WHERE DH_NOMCHAMP =''' + BTPFieldName + '''';
      AdoQryBTP.SingleTableSelect;
      FieldType := AdoQryBTP.TSLResult[0];
      AdoQryBTP.TSLResult.Clear;
    end else
      FieldType := 'VARCHAR(100)';
    if not IsAdditional then
    begin
      BTPArrFields[Cpt] := Format('%s;%s', [BTPFieldName, FieldType]);
      TMPArrFields[Cpt] := Format('%s;%s', [TMPFieldName, GetTMPFieldType(TMPFieldName, FieldType)]);
    end else
    begin
      BTPArrAdditionalFields[Cpt] := Format('%s;%s', [BTPFieldName, FieldType]);
      TMPArrAdditionalFields[Cpt] := Format('%s;%s', [TMPFieldName, FieldType]);
    end;
  end;

begin
  Result := True;
  case Tn of
    tnChantier : ArrLen := 12;
    tnDevis    : ArrLen := 12;
    tnLignesBR : ArrLen := 12;
    tnTiers    : ArrLen := 25;
  else
    Arrlen := 0;
  end;
  SetLength(BTPArrFields, ArrLen);
  SetLength(TMPArrFields, ArrLen);
  case Tn of
    tnChantier :
      begin
        for Cpt := Low(BTPArrFields) to High(BTPArrFields) do
        begin
          case Cpt of
            0  : AddValues('AFF_AFFAIRE'      , 'CHA_CODECOMPLET');
            1  : AddValues('AFF_AFFAIRE1'     , 'CHA_CODE');
            2  : AddValues('AFF_LIBELLE'      , 'CHA_LIBELLE');
            3  : AddValues('AFF_DESCRIPTIF'   , 'CHA_BLOCNOTE');
            4  : AddValues('AFF_TIERS'        , 'CHA_CODECLIENT');
            5  : AddValues('AFF_DATEDEBUT'    , 'CHA_DATEDEBUT');
            6  : AddValues('AFF_DATEFIN'      , 'CHA_DATEFIN');
            7  : AddValues('AFF_BOOLLIBRE1'   , 'CHA_VISA');
            8  : AddValues('AFF_STATUTAFFAIRE', 'CHA_STATUT');
            9  : AddValues('AFF_RESPONSABLE'  , 'CHA_RESPONSABLE');
            10 : AddValues('AFF_DATECREATION' , 'CHA_DATECREATION');
            11 : AddValues('AFF_DATEMODIF'    , 'CHA_DATEMODIF');
          end;
        end;
        ArrLen := 16;
        SetLength(BTPArrAdditionalFields, ArrLen);
        SetLength(TMPArrAdditionalFields, ArrLen);
        for Cpt :=  Low(BTPArrAdditionalFields) to High(BTPArrAdditionalFields) do
        begin
          case Cpt of
            0  : AddValues('LADR_LIBELLE'   , 'CHA_ADLLIBELLE' , True);
            1  : AddValues('LADR_ADRESSE1'  , 'CHA_ADLADRESSE1', True);
            2  : AddValues('LADR_ADRESSE2'  , 'CHA_ADLADRESSE2', True);
            3  : AddValues('LADR_ADRESSE3'  , 'CHA_ADLADRESSE3', True);
            4  : AddValues('LADR_CODEPOSTAL', 'CHA_ADLCP'      , True);
            5  : AddValues('LADR_VILLE'     , 'CHA_ADLVILLE'   , True);
            6  : AddValues('LADR_PAYS'      , 'CHA_ADLPAY'     , True);
            7  : AddValues('FADR_LIBELLE'   , 'CHA_ADFLIBELLE' , True);
            8  : AddValues('FADR_ADRESSE1'  , 'CHA_ADFADRESSE1', True);
            9  : AddValues('FADR_ADRESSE2'  , 'CHA_ADFADRESSE2', True);
            10 : AddValues('FADR_ADRESSE3'  , 'CHA_ADFADRESSE3', True);
            11 : AddValues('FADR_CODEPOSTAL', 'CHA_ADFCP'      , True);
            12 : AddValues('FADR_VILLE'     , 'CHA_ADFVILLE'   , True);
            13 : AddValues('FADR_PAYS'      , 'CHA_ADFPAY'     , True);
            14 : AddValues('LISTEDEVIS'     , 'CHA_LISTEDEVIS' , True);
            15 : AddValues('CODESOCIETE'    , 'CHA_CODESOCIETE', True);
          end;
        end;
      end;
    tnDevis :
      begin
        for Cpt :=  Low(BTPArrFields) to High(BTPArrFields) do
        begin
          case Cpt of
            0  : AddValues('GP_NUMERO'       , 'DEV_NUMDEVIS');
            1  : AddValues('GP_DATEPIECE'    , 'DEV_DATEDEVIS');
            2  : AddValues('GP_AFFAIRE'      , 'DEV_CODECHA');
            3  : AddValues('GP_TIERS'        , 'DEV_CODECLIENT');
            4  : AddValues('GP_REFINTERNE'   , 'DEV_LIBELLE');
            5  : AddValues('GP_REPRESENTANT' , 'DEV_RESPONSABLE');
            6  : AddValues('GP_TOTALHT'      , 'DEV_MONTANTHT');
            7  : AddValues('GP_BLOCNOTE'     , 'DEV_BLOCNOTE');
            8  : AddValues('GP_LIBREPIECE1'  , 'DEV_STATUS');
            9  : AddValues('GP_SOCIETE'      , 'DEV_CODESOCIETE');
            10 : AddValues('GP_DATECREATION' , 'DEV_DATECREATION');
            11 : AddValues('GP_DATEMODIF'    , 'DEV_DATEMODIF');
          end;
        end;
      end;
    tnLignesBR :
      begin
        for Cpt :=  Low(BTPArrFields) to High(BTPArrFields) do
        begin
          case Cpt of
            0  : AddValues('GL_NUMERO'       , 'LBR_NUMBR');
            1  : AddValues('GL_TIERS'        , 'LBR_FOURNISSEUR');
            2  : AddValues('GL_AFFAIRE'      , 'LBR_CODECHA');
            3  : AddValues('GL_NUMORDRE'     , 'LBR_NUMORDRE');
            4  : AddValues('GL_CODEARTICLE'  , 'LBR_CODEARTICLE');
            5  : AddValues('GL_LIBELLE'      , 'LBR_LIBELLE');
            6  : AddValues('GL_QTEFACT'      , 'LBR_QUANTITE');
            7  : AddValues('GL_PUHTDEV'      , 'LBR_PU');
            8  : AddValues('GL_UTILISATEUR'  , 'LBR_UTILISATEUR');
            9  : AddValues('GL_SOCIETE'      , 'LBR_CODESOCIETE');
            10 : AddValues('GL_DATECREATION' , 'LBR_DATECREATION');
            11 : AddValues('GL_DATEMODIF'    , 'LBR_DATEMODIF');
          end;
        end;
      end;
    tnTiers :
      begin
        for Cpt :=  Low(BTPArrFields) to High(BTPArrFields) do
        begin
          case Cpt of
            0  : AddValues('T_AUXILIAIRE'  , 'TIE_AUXILIAIRE');
            1  : AddValues('T_COLLECTIF'   , 'TIE_COLLECTIF');
            2  : AddValues('T_NATUREAUXI'  , 'TIE_NATUREAUXI');
            3  : AddValues('T_LIBELLE'     , 'TIE_LIBELLE');
            4  : AddValues('T_DEVISE'      , 'TIE_DEVISE');
            5  : AddValues('T_ADRESSE1'    , 'TIE_ADRESSE1');
            6  : AddValues('T_ADRESSE2'    , 'TIE_ADRESSE2');
            7  : AddValues('T_ADRESSE3'    , 'TIE_ADRESSE3');
            8  : AddValues('T_CODEPOSTAL'  , 'TIE_CP');
            9  : AddValues('T_VILLE'       , 'TIE_VILLE');
            10 : AddValues('T_PAYS'        , 'TIE_PAYS');
            11 : AddValues('T_TELEPHONE'   , 'TIE_TELEPHONE');
            12 : AddValues('T_FAX'         , 'TIE_TELEPHONE2');
            13 : AddValues('T_TELEX'       , 'TIE_TELEPHONE3');
            14 : AddValues('T_EMAIL'       , 'TIE_EMAIL');
            15 : AddValues('T_RVA'         , 'TIE_WEBURL');
            16 : AddValues('T_COMPTATIERS' , 'TIE_COMPTA');
            17 : AddValues('T_FACTURE'     , 'TIE_TIERSFACTURE');
            18 : AddValues('T_PAYEUR'      , 'TIE_TIERSPAYEUR');
            19 : AddValues('T_BLOCNOTE'    , 'TIE_BLOCNOTE');
            20 : AddValues('T_SIRET'       , 'TIE_SIRET');
            21 : AddValues('T_NIF'         , 'TIE_NUMINTRACOMM');
            22 : AddValues('T_SOCIETE'     , 'TIE_CODESOCIETE');
            23 : AddValues('T_DATEMODIF'   , 'TIE_DATEMODIF');
            24 : AddValues('T_DATECREATION', 'TIE_DATECREATION');
          end;
        end;
      end;
  end;
end;

function TTnTreatment.GetPrefix : string;
begin
  case Tn of
    tnChantier : Result := 'CHA';
    tnDevis    : Result := 'DEV';
    tnLignesBR : Result := 'LBR';
    tnTiers    : Result := 'TIE';
  else
    Result := '';
  end;
end;

function TTnTreatment.GetTMPFieldName(BTPFieldName : string) : string;
var
  Cpt : integer;
begin
  if BTPFieldName <> '' then
  begin
    for Cpt := Low(BTPArrFields) to High(BTPArrFields) do
    begin
     if Tools.ExtractFieldName(BTPArrFields[Cpt]) = BTPFieldName then
      begin
       Result := Tools.ExtractFieldName(TMPArrFields[Cpt]);
       break;
      end;
    end;
  end else
    Result := '';
end;

function TTnTreatment.GetTMPIndexFieldName : string;
begin
  case Tn of
    tnChantier : Result := 'CHA_CODECOMPLET';
    tnDevis    : Result := 'DEV_NUMDEVIS';
    tnLignesBR : Result := 'LBR_NUMBR;LBR_NUMORDRE';
    tnTiers    : Result := 'TIE_AUXILIAIRE';
  else
    Result := '';
  end;
end;

function TTnTreatment.GetBTPIndexFieldName : string;
begin
  case Tn of
    tnChantier : Result := 'AFF_AFFAIRE';
    tnDevis    : Result := 'GP_NUMERO';
    tnLignesBR : Result := 'GL_NUMERO;GL_NUMORDRE';
    tnTiers    : Result := 'T_AUXILIAIRE';
  else
    Result := '';
  end;
end;

function TTnTreatment.GetBTPLabelFieldName : string;
begin
  case Tn of
    tnChantier : Result := 'AFF_LIBELLE';
    tnDevis    : Result := 'GP_REFINTERNE';
    tnLignesBR : Result := 'GL_LIBELLE';
    tnTiers    : Result := 'T_LIBELLE';
  else
    Result := '';
  end;
end;

function TTnTreatment.GetSqlDataExist(FieldsList, KeyValue1, KeyValue2 : string) : string;
var
  IndexFieldName : string;
  IndexFieldType : tTypeField;
  Cpt            : integer;
begin
  case Tn of
    tnLignesBR : Result := Format('SELECT %s FROM LIGNESBR WHERE LBR_NUMBR = ''%s'' AND LBR_NUMORDRE = %s'  , [FieldsList, KeyValue1, KeyValue2]);
  else
    begin
      IndexFieldName := GetTMPIndexFieldName;
      IndexFieldType := ttfNone;
      for Cpt := 0 to High(TMPArrFields) do
      begin
        if Tools.ExtractFieldName(TMPArrFields[Cpt]) = IndexFieldName then
        begin
          IndexFieldType := Tools.GetTypeFieldFromStringType(Tools.ExtractFieldType(TMPArrFields[Cpt]));
          break;
        end;
      end;
      case IndexFieldType of
        ttfNumeric, ttfInt : Result := Format('SELECT %s FROM %s WHERE %s = %s'  , [FieldsList, TUtilBTPVerdon.GetTMPTableName(Tn), IndexFieldName, KeyValue1]);
      else ;
        Result := Format('SELECT %s FROM %s WHERE %s = ''%s'''  , [FieldsList, TUtilBTPVerdon.GetTMPTableName(Tn), IndexFieldName, KeyValue1]);
      end;
    end
  end;
end;

procedure TTnTreatment.SetLinkedRecords(TobAdd, TobData : TOB);

  procedure ClearValues;
  begin
    TobAdd.SetString('LADR_LIBELLE'    , '');
    TobAdd.SetString('LADR_ADRESSE1'   , '');
    TobAdd.SetString('LADR_ADRESSE2'   , '');
    TobAdd.SetString('LADR_ADRESSE3'   , '');
    TobAdd.SetString('LADR_CODEPOSTAL' , '');
    TobAdd.SetString('LADR_VILLE'      , '');
    TobAdd.SetString('LADR_PAYS'       , '');
    TobAdd.SetString('FADR_LIBELLE'    , '');
    TobAdd.SetString('FADR_ADRESSE1'   , '');
    TobAdd.SetString('FADR_ADRESSE2'   , '');
    TobAdd.SetString('FADR_ADRESSE3'   , '');
    TobAdd.SetString('FADR_CODEPOSTAL' , '');
    TobAdd.SetString('FADR_VILLE'      , '');
    TobAdd.SetString('FADR_PAYS'       , '');
    TobAdd.SetString('LISTEDEVIS'      , '');
  end;

  procedure AddAdress;
  var
    Sql        : string;
    FieldsList : array of string;
    TobAdr     : TOB;
    TobAdrL    : TOB;
    Cpt        : integer;

    procedure AddValues(Prefix : string);
    begin
      TobAdd.SetString(Format('%sADR_LIBELLE'    , [Prefix]), TobAdrL.GetString('ADR_LIBELLE'));
      TobAdd.SetString(Format('%sADR_ADRESSE1'   , [Prefix]), TobAdrL.GetString('ADR_ADRESSE1'));
      TobAdd.SetString(Format('%sADR_ADRESSE2'   , [Prefix]), TobAdrL.GetString('ADR_ADRESSE2'));
      TobAdd.SetString(Format('%sADR_ADRESSE3'   , [Prefix]), TobAdrL.GetString('ADR_ADRESSE3'));
      TobAdd.SetString(Format('%sADR_CODEPOSTAL' , [Prefix]), TobAdrL.GetString('ADR_CODEPOSTAL'));
      TobAdd.SetString(Format('%sADR_VILLE'      , [Prefix]), TobAdrL.GetString('ADR_VILLE'));
      TobAdd.SetString(Format('%sADR_PAYS'       , [Prefix]), TobAdrL.GetString('ADR_PAYS'));
    end;

  begin
    TobAdr := TOB.Create('_ADR', nil, -1);
    try
      SetLength(FieldsList, 8);
      FieldsList[0] := 'ADR_LIBELLE';
      FieldsList[1] := 'ADR_ADRESSE1';
      FieldsList[2] := 'ADR_ADRESSE2';
      FieldsList[3] := 'ADR_ADRESSE3';
      FieldsList[4] := 'ADR_CODEPOSTAL';
      FieldsList[5] := 'ADR_VILLE';
      FieldsList[6] := 'ADR_PAYS';
      FieldsList[7] := 'ADR_TYPEADRESSE';
      Sql := Format('SELECT %s'
                  + ' FROM ADRESSES'
                  + ' WHERE ADR_REFCODE     = ''%s'''
                  + '   AND ADR_TYPEADRESSE IN (''INT'', ''AFA'')'
                  , [Trim(GetFieldsListFromArray(FieldsList, False)), TobData.GetString('AFF_AFFAIRE')]);
      if (LogValues.DebugEvents > 0) then TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('%sSql Adress = %s', [WSCDS_DebugMsg, Sql]), LogValues, 0);
      AdoQryBTP.TSLResult.Clear;
      AdoQryBTP.FieldsList := Trim(GetFieldsListFromArray(FieldsList, False));
      AdoQryBTP.Request := Sql;
      AdoQryBTP.SingleTableSelect;
     {$IFDEF APPSRVWITHCBP}
      Tools.TStringListToTOB(AdoQryBTP.TSLResult, FieldsList, TobAdr, False);
     {$ENDIF APPSRVWITHCBP}
      AdoQryBTP.TSLResult.Clear;
      for Cpt := 0 to pred(TobAdr.Detail.count) do
      begin
        TobAdrL := TobAdr.Detail[Cpt];
        if TobAdrL.GetString('ADR_TYPEADRESSE') = 'INT' then
          AddValues('L')
        else if TobAdrL.GetString('ADR_TYPEADRESSE') = 'AFA' then
          AddValues('F');
      end;
    finally
      FreeAndNil(TobAdr);
    end;
  end;

  procedure AddQuotationList;
  var
    Sql       : string;
    FieldName : string;
    Value     : string;
    Cpt       : integer;
  begin
    FieldName := 'GP_NUMERO';
    Sql := Format('SELECT %s'
                + ' FROM PIECE'
                + ' WHERE GP_NATUREPIECEG = ''DBT'''
                + '       AND GP_TIERS    = ''%s'''
                + '       AND GP_AFFAIRE  = ''%s'''
                  , [FieldName, TobData.GetString('AFF_TIERS'), TobData.GetString('AFF_AFFAIRE')]);
    if (LogValues.DebugEvents > 0) then TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('%sSql Quotation list = %s', [WSCDS_DebugMsg, Sql]), LogValues, 0);
    AdoQryBTP.TSLResult.Clear;
    AdoQryBTP.FieldsList := FieldName;
    AdoQryBTP.Request    := Sql;
    AdoQryBTP.SingleTableSelect;
    for Cpt := 0 to pred(AdoQryBTP.TSLResult.Count) do
      Value := Format('%s;%s', [Value, AdoQryBTP.TSLResult[Cpt]]);
    Value := Copy(Value, 2, length(Value));
    TobAdd.SetString('LISTEDEVIS' , Value);
  end;

begin
  if (LogValues.DebugEvents > 0) then TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('%sTTnTreatment.SetLinkedRecords', [WSCDS_DebugMsg]), LogValues, 0);
  TobAdd.ClearDetail;
  case Tn of
    tnChantier :
      begin
        ClearValues;
        AddAdress;
        AddQuotationList;
      end;
  end;
end;

procedure TTnTreatment.SetLastSynchro(ServiceName : string);
var
  SettingFile : TInifile;
  IniFilePath : string;
begin
  IniFilePath := TServicesLog.GetFilePath(ServiceName, 'ini');
  SettingFile := TIniFile.Create(IniFilePath);
  try
    SettingFile.WriteString('EXPTABLESLASTSYNCHRO', TUtilBTPVerdon.GetTMPTableName(Tn), DateTimeToStr(Now));
    SettingFile.UpdateFile;
  finally
    SettingFile.Free;
  end;
end;
(*
procedure TTnTreatment.TStringListToTOB(TslValues : TStringList; ArrOfFields : array of string; TobResult : TOB; WithType : boolean);
var
  Cpt        : integer;
  CptField   : integer;
  Value      : string;
  FieldName  : string;
  FieldValue : string;
  TobL       : TOB;
begin
  if assigned(TobResult) and (TslValues.Count > 0) then
  begin
    for Cpt := 0 to pred(TslValues.Count) do
    begin
      TobL     := TOB.Create('_DATA', TobResult, -1);
      Value    := TslValues[Cpt];
      CptField := 0;
      while Value <> '' do
      begin
        FieldName  := Tools.iif(WithType, ExtractFieldName(ArrOfFields[CptField]), ArrOfFields[CptField]);
        FieldValue := Tools.ReadTokenSt_(Value, '^');
        TobL.AddChampSupValeur(FieldName, FieldValue);
        inc(CptField);
      end;
    end;
  end;
end;
*)
function TTnTreatment.GetSystemFields : string;
var
  Prefix : string;
begin
  Prefix := GetPrefix;
  Result := Format('%s_LOCK;%s_TRAITE;%s_DATETRAITE', [Prefix, Prefix, Prefix]);
end;

function TTnTreatment.GetFieldsListFromArray(ArrData: array of string; WithType : boolean): string;
var
  Cpt       : integer;
  FieldName : string;
begin
  Result := '';
  for Cpt := Low(ArrData) to High(ArrData) do
  begin
    FieldName := Tools.iif(WithType, Tools.ExtractFieldName(ArrData[Cpt]), ArrData[Cpt]);
    Result := Format('%s,%s', [Result, FieldName]);
  end;
  Result := copy(Result, 2, length(Result));
end;

function TTnTreatment.GetValue(FieldNameBTP, FieldNameTMP : string; FieldType : tTypeField; TobData : TOB) : string;
var
  FieldSize : integer;
  Value     : variant;
begin
  Result := '';
  Value  := TobData.GetValue(FieldNameBTP);
  case FieldType of
    ttfNumeric, ttfInt                     : Result := StringReplace(Value, ',', '.', [rfReplaceAll]);
    ttfDate                                : Result := Format('''%s''', [Tools.UsDateTime_(StrToDateTime(Value))]);
    ttfCombo, ttfText, ttfBoolean, ttfMemo : begin
                                               Result := Value;
                                               if Result <> '' then
                                               begin
                                                 if FieldType = ttfMemo then
                                                   Result := Tools.BlobToString_(Result);
                                                 FieldSize := GetTMPFieldSizeMax(FieldNameTMP);
                                                 Result    := Tools.iif(FieldSize > -1, Trim(Copy(Result, 1, FieldSize)), Result);
                                                 if pos('''', Result) > 0 then
                                                   Result := StringReplace(Result, '''', '''''', [rfReplaceAll]);
                                               end;
                                               Result := Format('''%s''', [Result]);
                                              end;
  end;
end;

function TTnTreatment.GetSqlInsertFields : string;
var
  Cpt          : integer;
  SystemFields : string;
begin
  Result := '';
  for Cpt :=  Low(TMPArrFields) to High(TMPArrFields) do
    Result := Format('%s, %s', [Result, Tools.ExtractFieldName(TMPArrFields[Cpt])]);
  SystemFields := GetSystemFields;
  while SystemFields <> '' do
    Result := Format('%s, %s', [Result, Tools.ReadTokenSt_(SystemFields, ';')]);
  Result := Copy(Result, 2, length(Result));
end;

function TTnTreatment.GetSqlInsertAdditionalFields : string;
var
  Cpt : integer;
begin
  Result := '';
  for Cpt :=  Low(TMPArrAdditionalFields) to High(TMPArrAdditionalFields) do
    Result := Format('%s, %s', [Result, Tools.ExtractFieldName(TMPArrAdditionalFields[Cpt])]);
  Result := Copy(Result, 2, length(Result));
end;

function TTnTreatment.GetSqlInsertValues(TobData: TOB; IsAdditional : boolean=False): string;
var
  Cpt          : integer;
  FieldNameTMP : string;
  FieldNameBTP : string;
  FieldType    : tTypeField;
begin
  Result := '';
  if not IsAdditional then
  begin
    for Cpt := 0 to High(BTPArrFields) do
    begin
      FieldNameBTP := Tools.ExtractFieldName(BTPArrFields[Cpt]);
      FieldNameTMP := Tools.ExtractFieldName(TMPArrFields[Cpt]);
      FieldType    := Tools.GetTypeFieldFromStringType(Tools.ExtractFieldType(BTPArrFields[Cpt]));
      Result       := Format('%s, %s', [Result, GetValue(FieldNameBTP, FieldNameTMP, FieldType, TobData)]);
    end;
    Result := Format('%s, ''%s'', ''%s'', ''%s''', [Result, LockDefaultValue, TraiteDefaultValue, DateTraiteDefaultValue]);
  end else
  begin
    for Cpt := 0 to High(BTPArrAdditionalFields) do
    begin
      FieldNameBTP := Tools.ExtractFieldName(BTPArrAdditionalFields[Cpt]);
      FieldNameTMP := Tools.ExtractFieldName(TMPArrAdditionalFields[Cpt]);
      FieldType    := Tools.GetTypeFieldFromStringType(Tools.ExtractFieldType(BTPArrAdditionalFields[Cpt]));
      Result       := Format('%s, %s', [Result, GetValue(FieldNameBTP, FieldNameTMP, FieldType, TobData)]);
    end;
  end;
  Result := Copy(Result, 2, length(Result));
end;

function TTnTreatment.GetSqlUpdate(TobData, TobAdd : TOB; KeyValue1, KeyValue2 : string) : string;
var
  Cpt          : integer;
  FieldNameTMP : string;
  FieldNameBTP : string;
  Sql          : string;
  Prefix       : string;
  SystemFields : string;
  FieldType    : tTypeField;
begin
  for Cpt := 0 to High(TMPArrFields) do
  begin
    FieldNameTMP := Tools.ExtractFieldName(TMPArrFields[Cpt]);
    FieldNameBTP := Tools.ExtractFieldName(BTPArrFields[Cpt]);
    FieldType    := Tools.GetTypeFieldFromStringType(Tools.ExtractFieldType(TMPArrFields[Cpt]));
    Sql          := Format('%s, %s=%s', [Sql, FieldNameTMP, GetValue(FieldNameBTP, FieldNameTMP, FieldType, TobData)]);
  end;
  case Tn of
    tnChantier :
    begin
      for Cpt :=  Low(BTPArrAdditionalFields) to High(BTPArrAdditionalFields) do
      begin
        FieldNameTMP := Tools.ExtractFieldName(TMPArrAdditionalFields[Cpt]);
        FieldNameBTP := Tools.ExtractFieldName(BTPArrAdditionalFields[Cpt]);
        FieldType    := Tools.GetTypeFieldFromStringType(Tools.ExtractFieldType(TMPArrAdditionalFields[Cpt]));
        Sql          := Format('%s, %s=%s', [Sql, FieldNameTMP, GetValue(FieldNameBTP, FieldNameTMP, FieldType, TobAdd)]); //TobAdd.GetString(FieldNameBTP)]);
      end;
    end;
  end;
  Prefix       := GetPrefix;
  SystemFields := GetSystemFields;
  while SystemFields <> '' do
  begin
    FieldNameTMP := Tools.ReadTokenSt_(SystemFields, ';');
    case Tools.CaseFromString(FieldNameTMP, [Prefix + '_LOCK', Prefix + '_TRAITE', Prefix + '_DATETRAITE']) of
      {LOCK}       0 : Sql := Format('%s, %s=''%s''', [Sql, FieldNameTMP, LockDefaultValue]);
      {TRAITE}     1 : Sql := Format('%s, %s=''%s''', [Sql, FieldNameTMP, TraiteDefaultValue]);
      {DATETRAITE} 2 : Sql := Format('%s, %s=''%s''', [Sql, FieldNameTMP, DateTraiteDefaultValue]);
    end;
  end;
  Sql := Copy(Sql, 2, length(Sql));
  case Tn of
    tnLignesBR : Result := Format('UPDATE LIGNESBR SET %s WHERE LBR_NUMBR = ''%s'' AND LBR_NUMORDRE = %s', [Sql, KeyValue1, KeyValue2]);
  else
    Result := Format('UPDATE %s SET %s WHERE %s = ''%s''', [TUtilBTPVerdon.GetTMPTableName(Tn), Sql, GetTMPIndexFieldName, KeyValue1]);
  end;
end;

function TTnTreatment.GetSqlInsert(TobData, TobAdd : TOB) : string;
var
  Fields    : string;
  Values    : string;
begin
  Fields := GetSqlInsertFields;
  Values := GetSqlInsertValues(TobData);
  case Tn of
    tnChantier :
      begin
        Fields := Format('%s, %s', [Fields, GetSqlInsertAdditionalFields]);
        Values := Format('%s, %s', [Values, GetSqlInsertValues(TobAdd, True)]);
      end;
  end;
  Result := Format('INSERT INTO %s (%s) VALUES (%s)', [TUtilBTPVerdon.GetTMPTableName(Tn), Fields, Values]);
end;

function TTnTreatment.GetDataSearchSql : string;

  function GetLastSynchro : string;
  begin
    Result := Tools.CastDateTimeForQry(StrToDatetime(LastSynchro));
  end;

begin
  case Tn of
    tnTiers    : Result := Format('SELECT %s FROM TIERS   WHERE T_DATEMODIF >= ''%s'' ORDER BY T_AUXILIAIRE'                                         , [GetFieldsListFromArray(BTPArrFields, True), GetLastSynchro]);
    tnDevis    : Result := Format('SELECT %s FROM PIECE   WHERE GP_NATUREPIECEG = ''DBT'' AND GP_DATEMODIF >= ''%s'' ORDER BY GP_NUMERO'             , [GetFieldsListFromArray(BTPArrFields, True), GetLastSynchro]);
    tnLignesBR : Result := Format('SELECT %s FROM LIGNE   WHERE GL_NATUREPIECEG = ''BLF'' AND GL_DATEMODIF >= ''%s'' ORDER BY GL_NUMERO, GL_NUMLIGNE', [GetFieldsListFromArray(BTPArrFields, True), GetLastSynchro]);
    tnChantier : Result := Format('SELECT %s FROM AFFAIRE WHERE AFF_AFFAIRE LIKE ''%s'' AND AFF_DATEMODIF >= ''%s'' ORDER BY AFF_AFFAIRE'            , [GetFieldsListFromArray(BTPArrFields, True), 'A%', GetLastSynchro]);
  else
    Result := '';
  end;
end;

function TTnTreatment.GetTMPFieldSizeMax(FieldName : string) : integer;
begin
  case Tools.CaseFromString(FieldName, [  'CHA_CODE'   , 'CHA_BLOCNOTE', 'CHA_ADLCP', 'CHA_ADFCP'
                                        , 'DEV_CODECHA', 'DEV_BLOCNOTE'
                                        , 'LBR_CODECHA'
                                        , 'TIE_CP'     , 'TIE_BLOCNOTE']) of
    {CHA_CODE}     0 : Result := 8;
    {CHA_BLOCNOTE} 1 : Result := 256;
    {CHA_ADLCP}    2 : Result := 5;
    {CHA_ADFCP}    3 : Result := 5;
    {DEV_CODECHA}  4 : Result := 8;
    {DEV_BLOCNOTE} 5 : Result := 256;
    {LBR_CODECHA}  6 : Result := 8;
    {TIE_CP}       7 : Result := 5;
    {TIE_BLOCNOTE} 8 : Result := 256;
  else
    Result := -1;
  end;
end;

function TTnTreatment.InsertUpdateData(TobData: TOB): boolean;
var
  Cpt       : integer;
  UpdateQty : integer;
  InsertQty : integer;
  OtherQty  : integer;
begin
  if (LogValues.DebugEvents > 0) then TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('%sStart TTnTreatment.InsertUpdateData', [WSCDS_DebugMsg]), LogValues, 0);
  Result := True;
  if (assigned(TobData)) then
  begin
    UpdateQty := TobData.GetInteger('UPDATEQTY');
    InsertQty := TobData.GetInteger('INSERTQTY');
    OtherQty  := TobData.GetInteger('OTHERQTY');
    if (LogValues.DebugEvents > 0) then TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('%sUpdateQty=%s, InsertQty=%s, OtherQty=%s', [WSCDS_DebugMsg, IntToStr(UpdateQty), IntToStr(InsertQty), IntToStr(OtherQty)]), LogValues, 0);
    try
      for Cpt := 0 to pred(TobData.Detail.Count) do
      begin
        AdoQryTMP.RecordCount := 0;
        AdoQryTMP.Request     := TobData.Detail[Cpt].GetString('SqlQry');
        if LogValues.DebugEvents > 0 then TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('%sEx�cution de %s ', [WSCDS_DebugMsg, AdoQryTMP.Request]), LogValues, 1);
        AdoQryTMP.InsertUpdate;
      end;
      if UpdateQty > 0 then
        TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('%s enregistrements de la table %s modifi�(s)', [IntToStr(UpdateQty), TUtilBTPVerdon.GetTMPTableName(Tn)]), LogValues, 1);
      if InsertQty > 0 then
        TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('%s enregistrements de la table %s cr��(s)', [IntToStr(InsertQty), TUtilBTPVerdon.GetTMPTableName(Tn)]), LogValues, 1);
      if OtherQty > 0 then
        TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('%s enregistrements de la table %s non trait�(s) car verrouill�(s)', [IntToStr(OtherQty), TUtilBTPVerdon.GetTMPTableName(Tn)]), LogValues, 1);
      SetLastSynchro(ServiceName_BTPVerdonExp);
    except
      Result := False;
    end;
  end;
end;

function TTnTreatment.TnTreatment(TobTable, TobAdd, TobQry: TOB): boolean;
var
  TobL          : TOB;
  Cpt           : integer;
  InsertQty     : integer;
  UpdateQty     : integer;
  OtherQty      : integer;
  FieldSize     : integer;
  SqlUnlock     : string;
  Sql           : string;
  Lock          : string;
  Treat         : string;
  KeyFieldsName : string;
  KeyField1     : string;
  KeyField2     : string;
  KeyValue1     : string;
  KeyValue2     : string;
  LabelValue    : string;
  Values        : string;
  FindData      : boolean;
begin
  if (LogValues.DebugEvents > 0) then TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('%s Start TTnTreatment.TnTreatment', [WSCDS_DebugMsg]), LogValues, 0);
  Result    := True;
  InsertQty := 0;
  UpdateQty := 0;
  OtherQty  := 0;
  SetFieldsArray;
  Sql := GetDataSearchSql;
  if (LogValues.DebugEvents > 0) then TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('%s TTnTreatment.TnTreatment / Sql = %s', [WSCDS_DebugMsg, Sql]), LogValues, 0);
  AdoQryBTP.TSLResult.Clear;
  AdoQryBTP.FieldsList := Trim(GetFieldsListFromArray(BTPArrFields, True));
  AdoQryBTP.Request := Sql;
  AdoQryBTP.SingleTableSelect;
  {$IFDEF APPSRVWITHCBP}
  Tools.TStringListToTOB(AdoQryBTP.TSLResult, BTPArrFields, TobTable, True);
  {$ENDIF APPSRVWITHCBP}
  Sql := '';
  if TobTable.Detail.Count > 0 then
  begin
    TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('Recherche des donn�es (%s enregistrement(s) de la table %s)', [IntToStr(TobTable.Detail.Count), TUtilBTPVerdon.GetTMPTableName(Tn)]), LogValues, 1);
    AdoQryTMP.TSLResult.Clear;
    AdoQryTMP.FieldsList := Format('%s_LOCK,%s_TRAITE', [GetPrefix, GetPrefix]);
    AdoQryTMP.LogValues  := LogValues;
    AdoQryTMP.TSLResult.Clear;
    KeyFieldsName := GetTMPIndexFieldName;
    SqlUnlock     := Format('UPDATE %s SET %s_LOCK = ''N'' WHERE %s IN(', [TUtilBTPVerdon.GetTMPTableName(Tn), GetPrefix, Tools.ReadTokenSt_(KeyFieldsName, ';')]);
    FindData      := False;
    for Cpt := 0 to pred(TobTable.Detail.Count) do
    begin
      TobL          := TobTable.Detail[Cpt];
      KeyFieldsName := GetBTPIndexFieldName;
      KeyField1     := Tools.ReadTokenSt_(KeyFieldsName, ';');
      KeyField2     := Tools.ReadTokenSt_(KeyFieldsName, ';');
      KeyValue1     := TobL.GetString(KeyField1);
      FieldSize     := GetTMPFieldSizeMax(GetTMPFieldName(KeyField1));
      KeyValue1     := Tools.iif(FieldSize > -1, Trim(Copy(KeyValue1, 1, FieldSize)), KeyValue1);
      if KeyField2 <> '' then
      begin
        KeyValue2 := TobL.GetString(KeyField2);
        FieldSize := GetTMPFieldSizeMax(GetTMPFieldName(KeyField2));
        KeyField2 := Tools.iif(FieldSize > -1, Trim(Copy(KeyField2, 1, FieldSize)), KeyField2);
      end;
      SetLinkedRecords(TobAdd, TobL);
      LabelValue := TobL.GetString(GetBTPLabelFieldName);
      SqlUnlock  := Format('%s%s''%s''', [SqlUnlock, Tools.iif(Cpt = 0, '', ', '), KeyValue1]); // Pr�pare update de Unlock
      AdoQryTMP.Request := GetSqlDataExist(AdoQryTMP.FieldsList, KeyValue1, KeyValue2); // Test si enregistrement existe
      AdoQryTMP.SingleTableSelect;
      if AdoQryTMP.RecordCount = 1 then // Update
      begin
        Values := AdoQryTMP.TSLResult[0];
        Lock   := Tools.ReadTokenSt_(Values, ToolsTobToTsl_Separator);
        Treat  := Tools.ReadTokenSt_(Values, ToolsTobToTsl_Separator);
        if Lock = 'N' then
        begin
          if LogValues.LogLevel = 2 then
            TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('Mise � jour de %s%s - %s', [KeyValue1, Tools.iif(KeyValue2 <> '', ' - ' + KeyValue2, ''), LabelValue]), LogValues, 2);
          inc(UpdateQty);
          FindData  := True;
          Sql := GetSqlUpdate(TobL, TobAdd, KeyValue1, KeyValue2);
        end else
        begin
          if LogValues.LogLevel = 2 then
            TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('Mise � jour de %s%s - %s impossible (bloqu�)', [KeyValue1, Tools.iif(KeyValue2 <> '', ' - ' + KeyValue2, ''), LabelValue]), LogValues, 2);
          Inc(OtherQty);
        end;
      end else
      begin
        if LogValues.LogLevel = 2 then
          TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('Cr�ation de %s%s - %s', [KeyValue1, Tools.iif(KeyValue2 <> '', ' - ' + KeyValue2, ''), LabelValue]), LogValues, 2);
        Inc(InsertQty);
        FindData  := True;
        Sql := GetSqlInsert(TobL, TobAdd);
      end;
      if Sql <> '' then
      begin
        TobL := TOB.Create('_QRYL', TobQry, -1);
        TobL.AddChampSupValeur('SqlQry', Sql);
        Sql := '';
      end;
    end;
    if FindData then
    begin
      SqlUnlock := Format('%s)', [SqlUnlock]);
      TobL      := TOB.Create('_QRYL', TobQry, -1);
      TobL.AddChampSupValeur('SqlQry', SqlUnlock);
    end;
    TobQry.AddChampSupValeur('UPDATEQTY', IntToStr(UpdateQty));
    TobQry.AddChampSupValeur('INSERTQTY', IntToStr(InsertQty));
    TobQry.AddChampSupValeur('OTHERQTY', IntToStr(OtherQty));
    InsertUpdateData(TobQry);
  end else
    TUtilBTPVerdon.AddLog(ServiceName_BTPVerdonExp, Tn, Format('Aucun %s n''a �t� trouv�.', [TUtilBTPVerdon.GetTMPTableName(Tn)]), LogValues, 1);
end;

{ TExportEcr }
{$IFNDEF APPSRV}
constructor TExportEcr.create;
begin
  TobEcrVen   := TOB.Create('_ECRITURE', nil, -1);
  TobEcrAch   := TOB.Create('_ECRITURE', nil, -1);
  TobEcrP     := TOB.Create('_ECRITURE', nil, -1);
  TobCustomer := TOB.Create('_CLIENT', nil, -1);
  TobProvider := TOB.Create('_FOURNISSEUR', nil, -1);
  TslData     := TStringList.Create;
end;

destructor TExportEcr.destroy;
begin
  inherited;
  FreeAndNil(TobEcrP);
  FreeAndNil(TobEcrVen);
  FreeAndNil(TobEcrAch);
  FreeAndNil(TobCustomer);
  FreeAndNil(TobProvider);
  FreeAndNil(TslData);
end;

function TExportEcr.LoadEcr : boolean;
var
  TobEcr : TOB;
  Sql    : string;

  procedure SearchThird(Flow, AuxiliaryCode : string);
  var
    TobT : TOB;
    TobL : TOB;
    Sql  : string;
    Qry  : TQuery;
  begin
    if not assigned(Tools.iif(Flow = 'VTE', TobCustomer, TobProvider).FindFirst(['T_AUXILIAIRE'], [AuxiliaryCode], True)) then
    begin
      TobT := TOB.Create('TIERS', Tools.iif(Flow = 'VTE', TobCustomer, TobProvider), -1);
      Sql  := Format('SELECT TIERS.*'
                   + '     , YTC_TEXTELIBRE1'
                   + ' FROM TIERS'
                   + ' LEFT JOIN TIERSCOMPL ON YTC_AUXILIAIRE = T_AUXILIAIRE'
                   + ' WHERE T_AUXILIAIRE = "%s"', [AuxiliaryCode]);
      Qry  := OpenSql(Sql, True);
      try
        if not Qry.Eof then
        begin
          TobT.SelectDB('', Qry);
          TslData.Add(Format('%s : %s - %s', [Tools.iif(TobT.GetString('T_NATUREAUXI') = 'CLI', 'Client', 'Fournisseur'), TobT.GetString('T_TIERS'), TobT.GetString('T_LIBELLE')]));
          { Recherche les adresses }
          TobL := TOB.Create('_ADRESSES', TobT, -1);
          TobL.AddChampSupValeur('TYPE', 'ADRESSES');
          Sql  := Format('SELECT * FROM ADRESSES WHERE ADR_REFCODE = "%s"', [TobT.GetString('T_TIERS')]);
          TobL.LoadDetailFromSQL(Sql);
          { Recherche les contacts }
          TobL := TOB.Create('_CONTACT', TobT, -1);
          TobL.AddChampSupValeur('TYPE', 'CONTACT');
          Sql  := Format('SELECT * FROM CONTACT WHERE C_TIERS = "%s" ORDER BY C_PRINCIPAL DESC', [TobT.GetString('T_TIERS')]);
          TobL.LoadDetailFromSQL(Sql);
          { Recherche les RIB }
          TobL := TOB.Create('_RIB', TobT, -1);
          TobL.AddChampSupValeur('TYPE', 'RIB');
          Sql  := Format('SELECT * FROM RIB WHERE R_AUXILIAIRE = "%s" ORDER BY R_PRINCIPAL DESC', [AuxiliaryCode]);
          TobL.LoadDetailFromSQL(Sql);
        end;
      finally
        Ferme(Qry);
      end;
    end;
  end;

begin
  InitMoveProgressForm(nil, MsgCaption, 'Recherche des �critures en cours.', 0, False, True);
  try
    TobEcr := TOB.Create('_ECR', nil, -1);
    try
      Sql := Format('SELECT J_NATUREJAL'
                  + '     , G_LIBELLE'
                  + '     , ECRITURE.*'
                  + ' FROM ECRITURE'
                  + ' JOIN JOURNAL  ON J_JOURNAL = E_JOURNAL AND J_NATUREJAL IN ("VTE", "ACH")'
                  + ' JOIN GENERAUX ON G_GENERAL = E_GENERAL'
                  + ' WHERE E_DATECOMPTABLE BETWEEN "%s" AND "%s"'
                  + '   AND E_EXPORTE = "---"'
                  + ' ORDER BY E_JOURNAL, E_NUMEROPIECE, E_NUMLIGNE'
                    , [Tools.UsDateTime_(StartDate), Tools.UsDateTime_(EndDate)]);
      TobEcr.LoadDetailFromSQL(Sql);
      Result := (TobEcr.Detail.Count > 0);
      if Result then
      begin
        { Eclate Vente et Achat}
        repeat
          if TobEcr.Detail[0].GetString('E_TYPEMVT') = 'TTC' then
            SearchThird(TobEcr.Detail[0].GetString('J_NATUREJAL'), TobEcr.Detail[0].GetString('E_AUXILIAIRE'));
          if TobEcr.Detail[0].GetString('J_NATUREJAL') = 'VTE' then
            TobEcr.Detail[0].ChangeParent(TobEcrVen, -1)
          else
            TobEcr.Detail[0].ChangeParent(TobEcrAch, -1);
        until TobEcr.Detail.count = 0
      end;
    finally
      FreeAndNil(TobEcr);
    end;
  finally
    FiniMoveProgressForm;
  end;
end;

function TExportEcr.LoadAnalytic : boolean;
var
  CptA     : integer;
begin
  Result := True;
  if TobEcrP.Detail.Count > 0 then
  begin
    for CptA := 0 to pred(TobEcrP.Detail.Count) do
      LoadAnalyticOnTobEntry(TobEcrP.Detail[CptA]);
  end;
end;

function TExportEcr.GetAmount(Amount : double; PositiveValue : boolean) : string;
begin
  Result := FloatToStr((Arrondi(Amount, 2)) * Tools.iif(PositiveValue, 1, -1));
  Result := StringReplace(Result, ',', '.', [rfReplaceAll]);
end;

function TExportEcr.AddEntryToFile(GLEntries : IXMLNode) : boolean;
var
  Cpt        : integer;
  TobL       : TOB;
  AccDate    : string;
  ThirdType  : string;
  ThirdCode  : string;
  Payment    : string;
  IsInvoice  : boolean;
  IsSales    : boolean;
  GLEntry    : IXMLNode;
  SubLevel   : IXMLNode;
  SubLevel1  : IXMLNode;
  SubLevel2  : IXMLNode;
begin
  Result    := True;
  TobL      := TobEcrP.FindFirst(['E_TYPEMVT'], ['TTC'], True);
  IsInvoice := ((TobL.GetString('E_NATUREPIECE') = 'FC') or (TobL.GetString('E_NATUREPIECE') = 'FF'));
  IsSales   := (TobL.GetString('J_NATUREJAL') = 'VTE');
  Payment   := TobL.GetString('E_MODEPAIE');
  ThirdCode := TobL.GetString('E_AUXILIAIRE');
  AccDate   := FormatDateTime('yyyy-mm-dd', TobL.GetDateTime('E_DATECOMPTABLE'));
  ThirdType := Tools.iif(IsSales, 'Debtor', 'Creditor');
  { Ajout de la pi�ce comptable dans le fichier }
  GLEntry := GLEntries.AddChild('GLEntry');     GLEntry.Attributes['entry']  := TobL.GetString('E_NUMEROPIECE');
                                                GLEntry.Attributes['status'] := 'E';
  SubLevel := GLEntry.AddChild('Division');     SubLevel.Attributes['code']  := FolderCode;
  SubLevel := GLEntry.AddChild('Description');  SubLevel.Text                := TobL.GetString('E_LIBELLE');
  SubLevel := GLEntry.AddChild('Date');         SubLevel.Text                := AccDate;
  SubLevel := GLEntry.AddChild('DocumentDate'); SubLevel.Text                := AccDate;
  SubLevel := GLEntry.AddChild('Journal');      SubLevel.Attributes['code']  := TobL.GetString('E_JOURNAL');
  SubLevel := GLEntry.AddChild('Amount');
    SubLevel1 := SubLevel.AddChild('Currency'); SubLevel1.Attributes['code'] := TobL.GetString('E_DEVISE');
    SubLevel1 := SubLevel.AddChild('Value');    SubLevel1.Text               := GetAmount(TobL.GetDouble('E_DEBIT') + TobL.GetDouble('E_CREDIT'), IsInvoice);
  for Cpt := 0 to pred(TobEcrP.Detail.Count) do
  begin
    Inc(LineNumber);
    TobL := TobEcrP.Detail[Cpt];
    SubLevel := GLEntry.AddChild('FinEntryLine');              SubLevel.Attributes['number']  := IntToStr(LineNumber);
                                                               SubLevel.Attributes['type']    := 'N';
                                                               SubLevel.Attributes['subtype'] := Tools.iif(IsSales, '"K"', '"T"');
      SubLevel1 := SubLevel.AddChild('Date');                  SubLevel1.Text                 := AccDate;
      SubLevel1 := SubLevel.AddChild('GLAccount');             SubLevel1.Attributes['code']   := TobL.GetString('E_GENERAL');
      SubLevel1 := SubLevel.AddChild('Description');           SubLevel1.Text                 := TobL.GetString('G_LIBELLE');
      SubLevel1 := SubLevel.AddChild('Costcenter');            SubLevel1.Attributes['code']   := '';
      SubLevel1 := SubLevel.AddChild('Costunit');              SubLevel1.Attributes['code']   := '';
      SubLevel1 := SubLevel.AddChild(ThirdType);               SubLevel1.Attributes['code']   := ThirdCode;
                                                               SubLevel1.Attributes['number'] := ThirdCode;
      SubLevel1 := SubLevel.AddChild('Resource');              SubLevel1.Attributes['number'] := TobL.GetString('E_UTILISATEUR');
      SubLevel1 := SubLevel.AddChild('Amount');
        Sublevel2 := SubLevel1.AddChild('Currency');           SubLevel2.Attributes['code']   := TobL.GetString('E_DEVISE');
        Sublevel2 := SubLevel1.AddChild('Debit');              SubLevel2.Text                 := GetAmount(TobL.GetDouble('E_DEBIT') , True);
        Sublevel2 := SubLevel1.AddChild('Credit');             SubLevel2.Text                 := GetAmount(TobL.GetDouble('E_CREDIT'), True);
        Sublevel2 := SubLevel1.AddChild('VAT');                SubLevel2.Attributes['code']   := TobL.GetString('E_TVA');
      SubLevel1 := SubLevel.AddChild('VATTransaction');        SubLevel2.Attributes['code']   := TobL.GetString('E_TVA');
        Sublevel2 := SubLevel1.AddChild('VATAmount');          SubLevel2.Text                 := '0';
        Sublevel2 := SubLevel1.AddChild('VATBaseAmount');      SubLevel2.Text                 := '0';
      SubLevel1 := SubLevel.AddChild('Payment');
        if Payment <> '' then
          SubLevel2 := SubLevel1.AddChild('PaymentCondition'); SubLevel2.Attributes['code']   := Payment;
        SubLevel2 := SubLevel1.AddChild('Reference');          SubLevel2.Text                 := TobL.GetString('E_REFINTERNE');
        SubLevel2 := SubLevel1.AddChild('CSSDDate1');          SubLevel2.Text                 := AccDate;
        SubLevel2 := SubLevel1.AddChild('CSSDDate2');          SubLevel2.Text                 := AccDate;
      SubLevel1 := SubLevel.AddChild('Delivery');
        SubLevel2 := SubLevel1.AddChild('Date');               SubLevel2.Text                 := AccDate;
      SubLevel1 := SubLevel.AddChild('FinReferences');         SubLevel2.Attributes['TransactionOrigin']   := 'N';
        SubLevel2 := SubLevel1.AddChild('UniquePostingNumber');SubLevel2.Text                 := '0';
        SubLevel2 := SubLevel1.AddChild('YourRef');            SubLevel2.Text                 := TobL.GetString('E_REFINTERNE');
        SubLevel2 := SubLevel1.AddChild('DocumentDate');       SubLevel2.Text                 := AccDate;
  end;
end;

function TExportEcr.AddThirdToFile(Accounts : IXMLNode; TobData : TOB) : boolean;
var
  IsCustomer : boolean;
  Account    : IXMLNode;
  SubLevel   : IXMLNode;
  SubLevel1  : IXMLNode;
  SubLevel2  : IXMLNode;
  SubLevel3  : IXMLNode;
  SubLevel4  : IXMLNode;
  TobAddress : TOB;
  TobContact : TOB;
  TobBank    : TOB;
  TobL1      : TOB;
  TobL2      : TOB;
  Cpt        : integer;
  ThirdMemo  : string;
  ThirdType  : string;


  function GetBankInformation(Country : string; tType : T_ThirdXmlFileType) : string;
  begin
    if Country = 'BE' then
    begin
      case tType of
        txft_BankAccount_Code     : Result := StringReplace(TobL1.GetString('R_NUMEROCOMPTE'), ' ', '', [rfReplaceAll]);
        txft_BankAccountType_Code : Result := TobL1.GetString('R_PAYS');
        txft_Bank_Code            : Result := TobL1.GetString('R_PAYS');
        txft_Bic                  : Result := TobL1.GetString('R_CODEBIC');
        txft_SwiftCode            : Result := Format('%sXXX', [TobL1.GetString('R_CODEBIC')]) ;
      end;
    end else
    if TobL1.GetString('R_CODEIBAN') = '' then
    begin
      case tType of
        txft_BankAccount_Code     : Result := TobL1.GetString('R_NUMEROCOMPTE');
        txft_BankAccountType_Code : Result := 'DEF';
        txft_Bank_Code            : Result := '';
        txft_Bic                  : Result := TobL1.GetString('R_CODEBIC');
        txft_SwiftCode            : Result := TobL1.GetString('R_CODEBIC');
      end;
    end else
      case tType of
        txft_BankAccount_Code     : Result := TobL1.GetString('R_CODEIBAN');
        txft_BankAccountType_Code : Result := 'IBA';
        txft_Bank_Code            : Result := '';
        txft_Bic                  : Result := TobL1.GetString('R_CODEBIC');
        txft_SwiftCode            : Result := '';
      end;
  end;

  function GetTobL2Value(FieldName : string) : string;
  begin
    if assigned(TobL2) then
      Result := TobL2.GetString(FieldName)
    else
      Result := '';
  end;

  function GetTaxSytem : string;
  begin
    { L=Assujeti, E=Exempt�, N=Non assujeti }
    case Tools.CaseFromString(TobData.GetString('T_REGIMETVA'), ['COR', 'DTM', 'EXO', 'EXP', 'FRA', 'INT']) of
      {COR} 0 : Result := 'N';
      {DTM} 1 : Result := 'N';
      {EXO} 2 : Result := 'E';
      {EXP} 3 : Result := 'E';
      {FRA} 4 : Result := 'L';
      {INT} 5 : Result := 'L';
    else
      Result := 'L';
    end;
  end;

begin
  Result     := True;
  IsCustomer := (TobData.GetString('T_NATUREAUXI') = 'CLI');
  TobAddress := TobData.FindFirst(['TYPE'], ['ADRESSES'], True);
  TobContact := TobData.FindFirst(['TYPE'], ['CONTACT'] , True);
  TobBank    := TobData.FindFirst(['TYPE'], ['RIB']     , True);
  ThirdType  := Tools.iif(IsCustomer, 'Debtor', 'Creditor');
  ThirdMemo  := Tools.iif(TobData.GetString('T_BLOCNOTE') <> '', Tools.BlobToString_(TobData.GetString('T_BLOCNOTE')), '');

  Account  := Accounts.AddChild('Account'); Account.Attributes['code']    := TobData.GetString('T_AUXILIAIRE');
                                            Account.Attributes['status']  := Tools.iif(TobData.GetBoolean('T_FERME'), 'B', 'A');
                                            Account.Attributes['type']    := Tools.iif(IsCustomer, 'C', 'S');
  SubLevel := Account.AddChild('Name');     SubLevel.Text                 := TobData.GetString('T_LIBELLE');
  SubLevel := Account.AddChild('Phone');    SubLevel.Text                 := TobData.GetString('T_TELEPHONE');
  SubLevel := Account.AddChild('Fax');      SubLevel.Text                 := TobData.GetString('T_FAX');
  SubLevel := Account.AddChild('Email');    SubLevel.Text                 := TobData.GetString('T_EMAIL');
  SubLevel := Account.AddChild('HomePage'); SubLevel.Text                 := TobData.GetString('T_RVA');
  SubLevel := Account.AddChild('Contacts');
  if assigned(TobContact) then
  begin
    if TobContact.Detail.Count > 0 then
    begin
      for Cpt := 0 to pred(TobContact.Detail.Count) do
      begin
        TobL1     := TobContact.Detail[Cpt];
        TobL2     := TobAddress.FindFirst(['ADR_NUMEROCONTACT'], [TobL1.GetInteger('C_NUMEROCONTACT')], True);
        SubLevel1 := SubLevel.AddChild('Contact');             SubLevel1.Attributes['default']    := Tools.iif(TobL1.GetBoolean('C_PRINCIPAL'), '1', '0');
                                                               SubLevel1.Attributes['gender']     := 'M';
                                                               SubLevel1.Attributes['type']       := 'A';
          SubLevel2 := SubLevel1.AddChild('LastName');         SubLevel2.Text                      := TobL1.GetString('C_NOM');
          SubLevel2 := SubLevel1.AddChild('FirstName');        SubLevel2.Text                      := TobL1.GetString('C_PRENOM');
          SubLevel2 := SubLevel1.AddChild('MiddleName');       SubLevel2.Text                      := '';
          SubLevel2 := SubLevel1.AddChild('Initials');         SubLevel2.Text                      := '';
          SubLevel2 := SubLevel1.AddChild('Title');            SubLevel2.Attributes['code']       := TobL1.GetString('C_CIVILITE');
          SubLevel2 := SubLevel1.AddChild('Addresses');
            SubLevel3 := SubLevel2.AddChild('Address');        SubLevel3.Attributes['type']       := 'V';
                                                               SubLevel3.Attributes['desc']       := '';
              SubLevel4 := SubLevel3.AddChild('AddressLine1'); SubLevel4.Text                     := GetTobL2Value('ADR_ADRESSE1');
              SubLevel4 := SubLevel3.AddChild('AddressLine2'); SubLevel4.Text                     := GetTobL2Value('ADR_ADRESSE2');
              SubLevel4 := SubLevel3.AddChild('AddressLine3'); SubLevel4.Text                     := GetTobL2Value('ADR_ADRESSE3');
              SubLevel4 := SubLevel3.AddChild('PostalCode');   SubLevel4.Text                     := GetTobL2Value('ADR_CODEPOSTAL');
              SubLevel4 := SubLevel3.AddChild('City');         SubLevel4.Text                     := GetTobL2Value('ADR_VILLE');
              SubLevel4 := SubLevel3.AddChild('State');        SubLevel4.Attributes['code']       := GetTobL2Value('ADR_REGION');
              SubLevel4 := SubLevel3.AddChild('Country');      SubLevel4.Attributes['code']       := GetTobL2Value('ADR_PAYS');
              SubLevel4 := SubLevel3.AddChild('Phone');        SubLevel4.Text                     := TobL1.GetString('C_TELEPHONE');
              SubLevel4 := SubLevel3.AddChild('Fax');          SubLevel4.Text                     := TobL1.GetString('C_FAX');
          SubLevel2 := SubLevel1.AddChild('Manager');          SubLevel2.Attributes['number']     := '';
          SubLevel2 := SubLevel1.AddChild('Language');         SubLevel2.Attributes['code']       := TobData.GetString('T_LANGUE');
          SubLevel2 := SubLevel1.AddChild('JobTitle');         SubLevel2.Attributes['code']       := TobL1.GetString('C_SERVICECODE');
          SubLevel2 := SubLevel1.AddChild('JobDescription');   SubLevel2.Text                     := TobL1.GetString('C_SERVICE');
          SubLevel2 := SubLevel1.AddChild('Phone');            SubLevel2.Text                     := TobL1.GetString('C_TELEPHONE');
          SubLevel2 := SubLevel1.AddChild('Fax');              SubLevel2.Text                     := TobL1.GetString('C_FAX');
          SubLevel2 := SubLevel1.AddChild('Mobile');           SubLevel2.Text                     := TobL1.GetString('C_TELEX');
          SubLevel2 := SubLevel1.AddChild('Email');            SubLevel2.Text                     := TobL1.GetString('C_RVA');
      end;
    end else
    begin
      SubLevel1 := SubLevel.AddChild('Contact');             SubLevel1.Attributes['default']    := '1';
                                                             SubLevel1.Attributes['gender']     := 'M';
                                                             SubLevel1.Attributes['type']       := 'A';
        SubLevel2 := SubLevel1.AddChild('LastName');         SubLevel2.Text                     := 'XXX';
        SubLevel2 := SubLevel1.AddChild('FirstName');        SubLevel2.Text                     := 'XXX';
        SubLevel2 := SubLevel1.AddChild('MiddleName');       SubLevel2.Text                     := 'XXX';
        SubLevel2 := SubLevel1.AddChild('Initials');         SubLevel2.Text                     := 'XXX';
        SubLevel2 := SubLevel1.AddChild('Title');            SubLevel2.Attributes['code']       := 'XXX';
    end;
  end;
  SubLevel := Account.AddChild('Note');     SubLevel.Text := ThirdMemo;
  SubLevel := Account.AddChild(ThirdType);  SubLevel.Attributes['number']   := TobData.GetString('T_AUXILIAIRE');
                                             SubLevel.Attributes['code']     := TobData.GetString('T_AUXILIAIRE');
    SubLevel1 := SubLevel.AddChild('Currency'); SubLevel1.Attributes['code'] := TobData.GetString('T_DEVISE');
    SubLevel1 := SubLevel.AddChild('BankAccounts');
    if (assigned(TobBank)) and (TobBank.Detail.Count > 0) then
    begin
      for Cpt := 0 to pred(TobBank.Detail.Count) do
      begin
        TobL1 := TobBank.Detail[Cpt];
        SubLevel2 := SubLevel1.AddChild('BankAccount');     SubLeveL2.Attributes['code']    := GetBankInformation(TobL1.GetString('R_PAYS'), txft_BankAccount_Code);
                                                            SubLevel2.Attributes['default'] := Tools.iif(TobL1.GetBoolean('R_PRINCIPAL'), '1', '0');
        SubLevel2 := SubLevel1.AddChild('BankAccountType'); SubLevel2.Attributes['code']    := GetBankInformation(TobL1.GetString('R_PAYS'), txft_BankAccountType_Code);
        SubLevel2 := SubLevel1.AddChild('Bank');            SubLevel2.Attributes['code']    := GetBankInformation(TobL1.GetString('R_PAYS'), txft_Bank_Code);
          SubLevel3 := SubLevel2.AddChild('Name');          SubLevel3.Text                  := TobL1.GetString('R_DOMICILIATION');
          SubLevel3 := SubLevel2.AddChild('Country');       SubLevel3.Attributes['code']    := TobL1.GetString('R_PAYS');
          if TobL1.GetString('R_CODEIBAN') <> '' then
            SubLevel3 := SubLevel2.AddChild('IBAN');        SubLevel3.Text                  := TobL1.GetString('R_CODEIBAN');
          SubLevel3 := SubLevel2.AddChild('BIC');           SubLevel3.Text                  := GetBankInformation(TobL1.GetString('R_PAYS'), txft_Bic);
          if    (TobL1.GetString('R_PAYS') = 'BE')
             or (TobL1.GetString('R_CODEIBAN') = '') then
            SubLevel3 := SubLevel2.AddChild('SwiftCode');   SubLevel3.Text                  := GetBankInformation(TobL1.GetString('R_PAYS'), txft_SwiftCode);
        SubLevel2 := SubLevel1.AddChild('Address');
          if TobL1.GetString('R_CODEIBAN') = '' then
            SubLevel3 := SubLevel2.AddChild('City');        SubLevel3.Text                  := TobL1.GetString('R_VILLE');
          SubLevel3 := SubLevel2.AddChild('Country');       SubLevel3.Attributes['code']    := TobL1.GetString('R_PAYS');
      end;
    end;
    SubLevel1 := SubLevel.AddChild('GLOffset');         SubLevel1.Attributes['code']   := Tools.iif(IsCustomer, VH_GC.GCCpteHTVTE, VH_GC.GCCpteHTACH);
    SubLevel1 := SubLevel.AddChild('GLCentralization'); SubLevel1.Attributes['code']   := TobData.GetString('T_COLLECTIF');
    SubLevel1 := SubLevel.AddChild(Tools.iif(IsCustomer, 'CreditLine', 'ExternalCode')); SubLevel1.Text:= Tools.iif(IsCustomer, GetAmount(TobData.GetDouble('T_CREDITACCORDE'), True), TobData.GetString('YTC_TEXTELIBRE1'));
  SubLevel := Account.AddChild('VATNumber');           SubLevel.Text                  := TobData.GetString('T_NIF');
  SubLevel := Account.AddChild('VATLiability');        SubLevel.Text                  := GetTaxSytem;
  SubLevel := Account.AddChild('PaymentCondition');    SubLevel1.Attributes['code']   := TobData.GetString('T_MODEREGLE');
  SubLevel := Account.AddChild('CompanySize');         SubLevel1.Attributes['code']   := 'UNKNOWN';
  SubLevel := Account.AddChild('CompanyOrigin');       SubLevel1.Attributes['code']   := 'P';
  SubLevel := Account.AddChild('CompanyRating');       SubLevel1.Attributes['code']   := '7';
  SubLevel := Account.AddChild('Sector');              SubLevel1.Attributes['code']   := 'UNKNOWN';
  SubLevel := Account.AddChild('AccountCategory');     SubLevel1.Attributes['code']   := 'ME';
  SubLevel := Account.AddChild('DunsNumber');          SubLevel.Text                  := 'LSE';
end;

function TExportEcr.ExpTreatment: boolean;
var
  MsgConfirm     : string;
  PathXMLFile    : string;
  PathXMLTmpFile : string;
  Msg            : string;
  TobEcrL        : TOB;

  procedure AddLineToTob;
  var
    TobEcrPL   : TOB;
  begin
    TobEcrPL := TOB.Create('_LINE', TobEcrP, -1);
    TobEcrPL.Dupliquer(TobEcrL, True, True);
  end;

  procedure EntryTreatment(Flow : string);
  var
    TobData    : TOB;
    CurrentPce : integer;
    XmlDoc     : IXMLDocument;
    RootNode   : IXMLNode;
    GLEntries  : IXMLNode;
    Cpt        : integer;

    procedure AddDocToFile;
    begin
      if TobEcrP.Detail.Count > 0 then
      begin
        LoadAnalytic;
        AddEntryToFile(GLEntries);
        TobEcrP.ClearDetail;
      end;
    end;

  begin
    TobData := Tools.iif(Flow = 'VTE', TobEcrVen, TobEcrAch);
    InitMoveProgressForm(nil, MsgCaption, Format('Traitement des lignes %s.', [Tools.iif(Flow = 'VTE', 'de vente', 'd''achat')]), pred(TobData.Detail.Count), False, True);
    CurrentPce := 0;
    LineNumber := 0;
    try
      XmlDoc := NewXMLDocument();
      try
        XmlDoc.Options := [doNodeAutoIndent];
        RootNode := XmlDoc.AddChild('eExact');
          RootNode.Attributes['xmlns:xsi']                     := 'http://www.w3.org/2001/XMLSchema-instance';
          RootNode.Attributes['xsi:noNamespaceSchemaLocation'] := 'eExact-Schema.xsd';
        GLEntries := RootNode.AddChild('GLEntries');
        for Cpt := 0 to pred(TobData.Detail.Count) do
        begin
          MoveCurProgressForm(Format('%s / %s', [IntToStr(Cpt), IntToStr(TobData.Detail.Count)]));
          TobEcrL := TobData.Detail[Cpt];
          if CurrentPce <> TobEcrL.GetInteger('E_NUMEROPIECE') then
          begin
            AddDocToFile;
            CurrentPce := TobEcrL.GetInteger('E_NUMEROPIECE');
            AddLineToTob;
          end else
            AddLineToTob;
        end;
        AddDocToFile;
        TobEcrP.ClearDetail;
        XmlDoc.SaveToFile(Tools.iif(Flow = 'VTE', TempPathXMLFileVTE, TempPathXMLFileACH));
      finally
        XmlDoc := nil;
      end;
    finally
      FiniMoveProgressForm;
    end;
  end;

  function ThirdTreatment(Flow : string) : boolean;
  var
    TobData    : TOB;
    XmlDoc     : IXMLDocument;
    RootNode   : IXMLNode;
    Accounts   : IXMLNode;
    Cpt        : integer;
  begin
    Result  := True;
    TobData := Tools.iif(Flow = 'VTE', TobCustomer, TobProvider);
    InitMoveProgressForm(nil, MsgCaption, Format('Traitement des %s.', [Tools.iif(Flow = 'VTE', 'clients', 'fournisseurs')]), pred(TobData.Detail.Count), False, True);
    try
      XmlDoc := NewXMLDocument();
      try
        XmlDoc.Options := [doNodeAutoIndent];
        RootNode := XmlDoc.AddChild('eExact');
          RootNode.Attributes['xmlns:xsi']                     := 'http://www.w3.org/2001/XMLSchema-instance';
          RootNode.Attributes['xsi:noNamespaceSchemaLocation'] := 'eExact-Schema.xsd';
        Accounts := RootNode.AddChild('Accounts');
        for Cpt := 0 to pred(TobData.Detail.Count) do
        begin
          MoveCurProgressForm(Format('%s / %s', [IntToStr(Cpt), IntToStr(TobData.Detail.Count)]));
          AddThirdToFile(Accounts, TobData.Detail[Cpt]);
        end;
        TobEcrP.ClearDetail;
        XmlDoc.SaveToFile(Tools.iif(Flow = 'VTE', TempPathXMLFileCLI, TempPathXMLFileFOU));
      finally
        XmlDoc := nil;
      end;
    finally
      FiniMoveProgressForm;
    end;
  end;

  function CheckExportEntry(TobE : TOB) : boolean;
  var
    Cpt        : integer;
    TobEL      : TOB;
    CurrentIdx : string;
    Sql        : string;

    function GetKey : string;
    begin
      Result := TobEL.GetString('E_ENTITY') + ';' + TobEL.GetString('E_EXERCICE') + ';' + TobEL.GetString('E_JOURNAL') + ';' + TobEL.GetString('E_NUMEROPIECE');
    end;

  begin
    Result     := True;
    CurrentIdx := '';
    for Cpt := 0 to pred(TobE.Detail.Count) do
    begin
      TobEL := TobE.Detail[Cpt];
      if CurrentIdx <> GetKey then
      begin
        TslData.Add(Format('%s - %s - %s', [TobEL.GetString('E_EXERCICE'), TobEL.GetString('E_JOURNAL'), TobEL.GetString('E_NUMEROPIECE')]));
        CurrentIdx := GetKey;
        Sql        := Format('%s OR (E_ENTITY = %s AND E_EXERCICE = "%s" AND E_JOURNAL = "%s" AND E_NUMEROPIECE = %s)'
                             , [  Sql
                                , TobEL.GetString('E_ENTITY')
                                , TobEL.GetString('E_EXERCICE')
                                , TobEL.GetString('E_JOURNAL')
                                , TobEL.GetString('E_NUMEROPIECE')
                               ]);
      end;
    end;
    if Sql <> '' then
    begin
      Sql    := Format('UPDATE ECRITURE SET E_EXPORTE = "X" WHERE %s', [Copy(Sql, 4, length(Sql))]);
      Result := (ExecuteSql(Sql) = TobE.Detail.Count);
    end;
  end;

  function GetFileName(Suffix : string) : string;
  begin
    Result := Format('%s_%s.xml', [FormatDateTime('yyyymmdd', NowH), Suffix]);
  end;

begin
  Result         := True;
  MsgCaption     := 'Export �critures';
  PathXMLFile    := IncludeTrailingBackslash(GetParamSocSecur('SO_EXPXMLDIR', ''));
  PathXMLTmpFile := IncludeTrailingBackslash(GetEnvironmentVariable('TEMP'));
  FolderCode     := GetParamSocSecur('SO_EXPXMLDOSSIERCPTA', '');
  if PathXMLFile = '' then
    PGIError('Export impossible, le r�pertoire de stockage des fichiers n''est pas renseign�.', MsgCaption)
  else if FolderCode = '' then
    PGIError('Export impossible, le num�ro de dossier EXACT n''est pas renseign�.', MsgCaption)
  else
  begin
    MsgConfirm := Format('Ce traitement exporte toutes les �critures%s non export�es du %s au %s et bloque les pi�ces associ�es.#13#10 Voulez-vous continuer ?'
                         , [  Tools.iif(ForceExport, ' d�j� export�es et', '')
                            , DateToStr(StartDate)
                            , DateToStr(EndDate)
                           ]);
    if PGIAsk(MsgConfirm, MsgCaption) = mrYes then
    begin
      PathXMLFileVTE     := PathXMLFile    + GetFileName('EcrVTE');
      PathXMLFileACH     := PathXMLFile    + GetFileName('EcrACH');
      PathXMLFileCLI     := PathXMLFile    + GetFileName('Clients');
      PathXMLFileFOU     := PathXMLFile    + GetFileName('Fournisseurs');
      TempPathXMLFileVTE := PathXMLTmpFile + GetFileName('EcrVTE');
      TempPathXMLFileACH := PathXMLTmpFile + GetFileName('EcrACH');
      TempPathXMLFileCLI := PathXMLTmpFile + GetFileName('Clients');
      TempPathXMLFileFOU := PathXMLTmpFile + GetFileName('Fournisseurs');
      { Si un des fichiers existe, on ne fait rien }
      if    (FileExists(PathXMLFileVTE))
         or (FileExists(PathXMLFileACH))
         or (FileExists(PathXMLFileCLI))
         or (FileExists(PathXMLFileFOU))
      then
      begin
        PGIError(Format('Export impossible, un des fichiers � g�n�rer existe d�j� dans %s', [PathXMLFile]), MsgCaption);
      end else
      begin
        { Supprime les fichiers du r�pertoire temporaire si existent }
        DeleteFile(PAnsiChar(TempPathXMLFileVTE));
        DeleteFile(PAnsiChar(TempPathXMLFileACH));
        DeleteFile(PAnsiChar(TempPathXMLFileCLI));
        DeleteFile(PAnsiChar(TempPathXMLFileFOU));
        if LoadEcr then
        begin
          TslData.Add('');
          TslData.Add('Pi�ces comptable (Exercice - Journal - N� de pi�ce) :');
          BeginTrans;
          try
            if TobEcrVen.Detail.Count   > 0 then
            begin
              try
                EntryTreatment('VTE');
              finally
                Result := CheckExportEntry(TobEcrVen);
                if not Result then
                  PGIError('Erreur lors de la mise � jour des �critures de ventes.', MsgCaption);
              end;
            end;
            if (Result) and (TobEcrAch.Detail.Count   > 0) then
            begin
              try
                EntryTreatment('ACH');
              finally
                Result := CheckExportEntry(TobEcrAch);
                if not Result then
                  PGIError('Erreur lors de la mise � jour des �critures de ventes.', MsgCaption);
              end;
            end;
            if (Result) and (TobCustomer.Detail.Count > 0) then Result := ThirdTreatment('VTE');
            if (Result) and (TobProvider.Detail.Count > 0) then Result := ThirdTreatment('ACH');
          finally
            if Result then
              CommitTrans
            else
              Rollback;
          end;
         if Result then
          begin
            MoveFile(PAnsiChar(TempPathXMLFileVTE), PAnsiChar(PathXMLFileVTE));
            MoveFile(PAnsiChar(TempPathXMLFileACH), PAnsiChar(PathXMLFileACH));
            MoveFile(PAnsiChar(TempPathXMLFileCLI), PAnsiChar(PathXMLFileCLI));
            MoveFile(PAnsiChar(TempPathXMLFileFOU), PAnsiChar(PathXMLFileFOU));
            SetParamSoc('SO_EXPXMLDE', StartDate);
            SetParamSoc('SO_EXPXMLA' , EndDate);
          end;
          Msg := Format('%s des �critures %s de ventes et achats du %s au %s.%s%s%s'
                        , [  Tools.iif(Result, 'Export', 'Tentative d''export')
                           , Tools.iif(ForceExport, 'd�j� export�es et non export�es', 'non export�es')
                           , DateTimeToStr(StartDate)
                           , DateTimeToStr(EndDate)
                           , #13#10
                           , #13#10
                           , TslData.Text
                          ]);
          MAJJnalEvent('EPC', Tools.iif(Result, 'OK', 'ERR'), MsgCaption, Msg);
          PGIBox(Format('Traitement termin� avec %s.', [Tools.iif(Result, 'succ�s', 'des erreurs')]), MsgCaption);
        end else
          PGIBox('Il n''y a pas d''�critures � exporter sur la p�riode demand�e.', MsgCaption);
      end;
    end;
  end;
end;
{$ENDIF APPSRV}

end.
