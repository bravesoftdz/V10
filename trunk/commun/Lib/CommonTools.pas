unit CommonTools;

interface

uses
  Classes
  , ConstServices    
  , ADODB
  ,Ulog
  {$IFNDEF APPSRV}
  , UTob
  , HEnt1
  {$ELSE APPSRV}
   {$IFDEF APPSRVWITHCBP}
  , UTob
  , HEnt1
   {$ENDIF APPSRVWITHCBP}
  {$ENDIF !APPSRV}
  ;
const
  ToolsTobToTsl_LevelName = '^LEVEL';
  ToolsTobToTsl_Separator = '^';

type
  TGncERROR  = (GncOk, GncExists, GncAbort);
  tTypeField = (ttfNone, ttfNumeric, ttfInt, ttfMemo, ttfBoolean, ttfDate, ttfCombo, ttfText);
  tScaleSize = (tssNone, tssKo, TssMo);
  tTableName = (  ttnNone
                , ttnChoixCod            // CHOIXCOD
                , ttnCommun              // COMMUN
                , ttnChoixExt            // CHOIXEXT
                , ttnDevise              // DEVISE
                , ttnModeRegl            // MODEREGL
                , ttnPays                // PAYS
                , ttnRib                 // RIB
                , ttnSection             // SECTION
                , ttnTiers               // TIERS
                , ttnCodePostaux         // CODEPOST
                , ttnContact             // CONTACT
                , ttnEtabliss            // ETABLISS
                , ttnModePaie            // MODEPAIE
                , ttnGeneraux            // GENERAUX
                , ttnJournal             // JOURNAL
                , ttnRelance             // RELANCE
                , ttnCorresp             // CORRESP
                , ttnChancell            // CHANCELL
                , ttnExercice            // EXERCICE
                , ttnParamSoc            // PARAMSOC
                , ttnEcriture            // ECRITURE
                , ttnAcomptes            // ACOMPTES
                , ttnPiece               // PIECE
                , ttnLigne               // LIGNE
                , ttnAffaire             // AFFAIRE
                , ttnArticle             // ARTICLE
                , ttnRessource           // RESSOURCE
                , ttnConsommations       // CONSOMMATIONS
                , ttnAffTiers            // AFFTIERS
                , ttnCatalogu            // CATALOGU
                , ttnBtFamilleTarif      // BTFAMILLETARIF
                , ttnBtSousFamilleTarif // BTSOUSFAMILLETARIF
               );
  tTypeAlign = (traaNone, traaLeft, traaRigth);
  tFormatValueTypeDate = (tvtNone, tvtDate, tvtDateTime);
  tAdoQryObjects = (taqoNone, taqoFieldList, taqoRequest, taqoRecordCount, taqoTslResult);
  tMemoryTyp = (tmtNone, tmtOctetsAvailable, tmtOctetsTotal, tmtMoAvailable, tmtMoTotal);
  tInfoTable = (titNone, titRecordsQty, titKbTotalSize, titKbUseSize, titKbAvailableSize, titMoTotalSize, titMoUseSize, titMoAvailableSize);
  tRecordMaxSize = (trsNone, trsOctets, trsMo);

  AdoQry = class
  public
    ServerName  : string;
    DBName      : string;
    Request     : string;
    FieldsList  : string;
    ServiceName : string;
    PgiDB       : string;
    TSLResult   : TStringList;
    RecordCount : integer;
    LogValues   : T_WSLogValues;
    Qry         : TADOQuery;

    Constructor Create;
    Destructor Destroy; override;
    function GetConnectionString : string;
    procedure Reset(Without : tAdoQryObjects=taqoNone);
    function SingleTableSelect : string;
    procedure InsertUpdate;
  end;

  Tools = class
    class function StringInList (St : string; ListST : string) : boolean;
    class function CaseFromString(Value: string; Values: array of string): integer;
    class function GetTypeFieldFromStringType(TypeString : string) : tTypeField;
    class function GetStFieldType(FieldName: string{$IFDEF APPSRV}; ServerName, DBName : string; DebugEvents : integer=0{$ENDIF APPSRV}): string;
    class function GetFieldType(FieldName: string{$IFDEF APPSRV}; ServerName, DBName : string{$ENDIF APPSRV}): tTypeField;
    class function GetDefaultValueFromtTypeField(FieldType : tTypeField; WithQuote : boolean=True) : string;
    class function iif(Const Expression, TruePart, FalsePart: Boolean): Boolean; overload;
    class function iif(Const Expression: Boolean; Const TruePart, FalsePart: Integer): Integer; overload;
    class function iif(Const Expression: Boolean; Const TruePart, FalsePart: Double): Double; overload;
    class function iif(Const Expression: Boolean; Const TruePart, FalsePart: String): String; overload;
    class function iif(Const Expression: Boolean; Const TruePart, FalsePart: char): char; overload;
    class function iif(Const Expression: Boolean; Const TruePart, FalsePart: TStringList): TStringList; overload;
    class function iif(Const Expression: Boolean; Const TruePart, FalsePart: TGncERROR): TGncERROR; overload;
    {$IFNDEF APPSRV}
    class function iif(Const Expression: Boolean; Const TruePart, FalsePart: TActionFiche): TActionFiche; overload;
    class function iif(Const Expression: Boolean; Const TruePart, FalsePart: TOB): TOB; overload;
    {$ENDIF !APPSRV}
    class function ReadTokenSt_(var S : string; Separator : string) : string;
    class function CountOccurenceString(const S : string; ToCount : string) : integer;
    class function GetArgumentValue(Argument: string; Const MyArg : String; Const WithUpperCase: Boolean = True; const Separator: String = ';'): String;
    class function GetArgumentString(Argument: string; Const MyArg : String; WithUpperCase: Boolean = True; const Separator: String = ';') : string;
    class function SetStrDateTimeFromStrUTCDateTime(UTCDateTime : string) : string;
    class function SetStrDateTimeToUTCDateTime(stDateTime : string) : string;
    class function SetStrUTCDateTimeToDateTime(stUTCDateTime : string) : string;
    class function GetFileSize(FilePath : string; Size : tScaleSize) : Extended;
    class function StrFPoint_(Value : Extended) : string;
    class function IsNumeric_(stValue : string) : boolean;
    class function GetFieldsListFromPrefix(TablePrefix : string{$IFDEF APPSRV}; ServerName, DBName : string{$ENDIF APPSRV}; Separator : string=',') : string;
    class function GetStValueFromTSl(TSlLine, FieldName : string) : string; overload;
    class function GetStValueFromTSl(TSlLine : string; Index : integer; Separator : string=',') : string; overload;
    class function GetTSlIndexFromFieldName(TslLine, FieldName : string; Separator : string=',') : integer;
    class function GetTableNameFromTtn(Ttn : tTableName) : string;
    class function GetTtnFromTableName(TableName : string) : tTableName;
    class function CanInsertedInTable(TableName: string{$IFDEF APPSRV}; ServerName, DBName : string{$ENDIF APPSRV}): Boolean;
    class function GetPSocTreeToExport(OnlyAccounting : Boolean=False) : string;
    class function SetTRAFileFromTSl(lTSL : TStringList) : Boolean;
    class function FormatValue(Value : string; Align : tTypeAlign; iLength : integer; NbDec : Integer=0; TypeDate : tFormatValueTypeDate=tvtNone) : string;
    class function CompressFile(FullPath : string) : string;
    class function UnCompressFile(ZipPath, ZipFileName : string) : integer;
    class procedure FileCut(FullPath : string; MaxSizeBytes : integer; TSLResult : TStringList; KeepOriginFile : boolean=True);
    class function GetKoFromMo(Mo : integer) : integer;
    class function DeleteDirectroy(Path : string) : boolean;
    class function IsRecordableDocument(DocType, Establishment : string{$IFDEF APPSRV}; ServerName, DBName : string{$ENDIF APPSRV}) : boolean;
    class function EvalueDateJJMMYYY(sDate : string) : TDateTime;
    class procedure DecodeAccDocReferency(DocReferency : string; var DocType : string; var Stump : string; var DocDate : TDateTime; var DocNumber : integer; var Index : integer);
    class function GetParamSocSecur_(PSocName : string; DefaultValue : string{$IFDEF APPSRV}; ServerName, FolderName : string{$ENDIF APPSRV}) : string;
    class function GetConnectionString(ServerName, DBName: string): string;
    class function CastDateTimeForQry(lDate : TDateTime) : string;
    class function DecodeDateTimeFromQry(sDate : string) : string;
    class function CastDateForQry(lDate : TDateTime) : string;
    class function UsDateTime_(dDateTime : TDateTime) : string;
    class function GetDocTypeFromStub(Stub : string{$IFDEF APPSRV}; ServerName, DBName : string{$ENDIF APPSRV}) : string;
    class function GetStringSeparatorForQry : string;
    {$IFNDEF APPSRV}
    class procedure TobToTStringList(TobOrig : TOB; TSlResult : TStringList; Level : Integer=1);
    class procedure GetFieldsListAndTypeFromPrefix(TablePrefix : string; TslResult : TStringList);
    {$ENDIF !APPSRV}
    {$IFDEF APPSRVWITHCBP}
    class procedure TStringListToTOB(TslValues : TStringList; ArrOfFields : array of string; TobResult : TOB; WithType : boolean);
    {$ENDIF}
    {$IF not Defined(APPSRV) or (Defined(APPSRV) and Defined(APPSRVWITHCBP))}
    class function BlobToString_(Texte : string) : string;
    {$IFEND}
    class function ExtractFieldName(Value : string) : string;
    class function ExtractFieldType(Value : string) : string;
    {$IFDEF APPSRVWITHCBP}
    class function SelectDB (SQL: string; TOBD: TOB {$IFDEF APPSRV} ;Servername : string; DBName : string; ModeDebug : Integer=0; LogFile:string='' {$ENDIF APPSRV}) : boolean;
    class function LoadDetailDB(SQL: string; TOBD : TOB {$IFDEF APPSRV} ;Servername : string; DBName : string; ModeDebug : Integer=0; LogFile:string='' {$ENDIF APPSRV}): boolean;
    class function GetparamSocSecur(Paramsoc,ValeurDefaut: string  ;Servername : string; DBName : string; ModeDebug : Integer=0; LogFile:string=''): string;
    class function InsertOrUpdate(TobData : TOB{$IFDEF APPSRV} ;Servername : string; DBName : string; ModeDebug : Integer=0; LogFile:string='' {$ENDIF APPSRV}) : boolean;
    {$ENDIF}
    class function MemoryStreamToOleVariant(Strm: TMemoryStream):  OleVariant;
    class function GetNumUniqueConso (var TheResult : double{$IFDEF APPSRV}; ServerName, DBName : string{$ENDIF APPSRV}) : TGncERROR;
    class function IsPieceGerableCoTraitance(DocType, CaseCode, Flow, CaseRepresentative : string) : boolean;
    class function IsPieceGerableSousTraitance(DocType, Flow : string) : boolean;
    class function GetMainIban(Auxiliary : string{$IFDEF APPSRV}; ServerName, DBName : string{$ENDIF APPSRV}) : string;
    class function GetStringSeparator : string;
    class function GetIndexOnSortedTsl(TslData : TStringList; Value : string; iFrom, iLen : integer) : integer;
    class function GetComputerMoMemory(mType : tMemoryTyp) : integer;
    {$IFNDEF APPSRV}
    class function TobPutValue(TobData : TOB; FieldName : string; lValue : variant) : boolean;
    class function TobGetValue(TobData : TOB; FieldName : string; lValue : variant) : Variant;
    class Procedure TobPutValueDetail(TobData : TOB; fieldName : String; lValue : Variant);
    class function GetTableInf(tInf : tInfoTable; TableName : string) : integer;
    class procedure DropStoredProcedure(SPName : string);
    class function GetRecordMaxSize(TableName : string; sType : tRecordMaxSize) : double;
    class function GetTableSize(TableName : string) : double;
    {$ENDIF APPSRV}
  end;


implementation

uses
  Forms
  , SysUtils
  , DB
  , StrUtils
  , Variants
  , DateUtils
  , Zip
  , SvcMgr
  , Windows
  , ComCtrls
  , ExtCtrls
  {$IFDEF APPSRVWITHCBP}
  , CbpEnumerator
  {$ENDIF APPSRVWITHCBP}
  {$IFNDEF APPSRV}
  , hCtrls
  , EntGC
  , ParamSoc
  , CbpMCD
   {$IFNDEF DBXPRESS}
  , dbTables
   {$ELSE !DBXPRESS}
  , uDbxDataSet
   {$ENDIF !DBXPRESS}
  {$ENDIF !APPSRV}
  ;

{***********A.G.L.***********************************************
Auteur  ...... : ctrls
Créé le ...... : 10/12/2018
Modifié le ... :   /  /    
Description .. : Fonction permettant de savoir si une chaine est contenu 
Suite ........ : dans une liste de donnée séparée par des ;'
Mots clefs ... : 
*****************************************************************}
{ AdoQry }
function AdoQry.GetConnectionString : string;
begin
  Result := 'Provider=SQLOLEDB.1'
          + ';Password=ADMIN'
          + ';Persist Security Info=True'
          + ';User ID=ADMIN'
          + ';Initial Catalog=' + DBName
          + ';Data Source=' + ServerName
          + ';Use Procedure for Prepare=1'
          + ';Auto Translate=True'
          + ';Packet Size=4096'
          + ';Workstation ID=LOCALST'
          + ';Use Encryption for Data=False'
          + ';Tag with column collation when possible=False'
          ;
end;

constructor AdoQry.Create;
begin
  if LogValues.DebugEvents > 0 then TServicesLog.WriteLog(ssbylLog, Format('%sStart AdoQry.Create', [WSCDS_DebugMsg]), ServiceName, LogValues, 0);
  TSLResult           := TStringList.Create;
  TSLResult.Delimiter := ToolsTobToTsl_Separator;
  PgiDB               := Tools.iif(PgiDB = '', 'X', PgiDB);
end;

destructor AdoQry.Destroy;
begin
  FreeAndNil(TSLResult);
  inherited;
end;

procedure AdoQry.Reset(Without : tAdoQryObjects=taqoNone);
begin
  if Without = taqoNone then
  begin
    FieldsList  := '';
    Request     := '';
    RecordCount := 0;
    TSLResult.Clear;
  end else
  begin
    case Without of
      taqoFieldList   : begin
                          Request     := '';
                          RecordCount := 0;
                          TSLResult.Clear;
                        end;
      taqoRequest     : begin
                          FieldsList  := '';
                          RecordCount := 0;
                          TSLResult.Clear;
                        end;
      taqoRecordCount : begin
                          FieldsList  := '';
                          Request     := '';
                          TSLResult.Clear;
                        end;
      taqoTslResult   : begin
                          FieldsList  := '';
                          Request     := '';
                          RecordCount := 0;
                        end;
    end;
  end;
end;

{ Renvoie dans TSLResult le rï¿½sultat du SELECT dont les valeurs sont sï¿½parï¿½es par des ^.
  Exemple de code pour appeler cette mï¿½thode :

    lAdoQry := AdoQry.Create;
    try
      lAdoQry.ServerName     := 'SRV-BDD-CLI';
      lAdoQry.DBName         := 'DEMOBTPV10_JT';
      lAdoQry.FieldsList     := 'SOC_DATA,SOC_TREE';
      lAdoQry.Request        := 'SELECT ' + lAdoQry.FieldsList + ' FROM PARAMSOC WHERE SOC_NOM IN (''SO_BTWSSERVEUR'', ''SO_BTWSCEGIDDOS'')';
      lAdoQry.SingleTableSelect;
      ServerName := lAdoQry.TSLResult[0]; // Exemple : MODELE_CEGID_JTR^001;016;022;003;
      FolderName := lAdoQry.TSLResult[1]; // Exemple : SRV-Y2-PHASE2^001;016;022;005;
    finally
      lAdoQry.Free;
    end;
}
function AdoQry.SingleTableSelect : string;
var
  Cpt         : integer;
  Sql         : string;
  Select      : string;
  ResultValue : string;
  lFieldsList : string;
  Start       : integer;
  FieldsArray : Array of string;
begin
  if LogValues.DebugEvents > 0 then TServicesLog.WriteLog(ssbylLog, Format('%s #01 AdoQry.SingleTableSelect - Srv = %s, Folder = %s, Request = %s, FieldsList = %s'
                                                                           , [WSCDS_DebugMsg
                                                                              , ServerName
                                                                              , DBName
                                                                              , Request
                                                                              , FieldsList
                                                                          ]), ServiceName, LogValues, 0);
  Result := '';
  if     (ServerName <> '') // Nom du serveur
     and (DBName <> '')     // Nom de la BDD
     and (Request <> '')    // Requï¿½te
     and (FieldsList <> '') // Liste des champs
  then
  begin
    if LogValues.DebugEvents > 0 then TServicesLog.WriteLog(ssbylLog, Format('%s#02 AdoQry.SingleTableSelect', [WSCDS_DebugMsg]), ServiceName, LogValues, 0);
    lFieldsList := FieldsList;
    SetLength(FieldsArray, Tools.CountOccurenceString(lFieldsList, ',') + 1);
    Cpt := 0;
    while lFieldsList <> '' do
    begin
      FieldsArray[Cpt] := Tools.ReadTokenSt_(lFieldsList, ',');
      Inc(Cpt);
    end;
    Sql := Request;
    { Si SELECT *, remplace par un SELECT des champs du tableau }
    if Pos('SELECT *', Sql) > 0 then
    begin
      Select := '';
      for Cpt := 0 to pred(Length(FieldsArray)) do
      begin
        if FieldsArray[Cpt] <> '' then
          Select := Select + ',' + FieldsArray[Cpt];
      end;
      Select := Copy(Select, 2, Length(Select));
      Start  := Pos('SELECT', Request);
      Sql := Copy(Request, Start, Start + 6)
           + Select
           + Copy(Request, pos('*', Request) + 1, Length(Request));
    end;
    try
      if LogValues.DebugEvents = 2 then TServicesLog.WriteLog(ssbylLog, Format('%sAdoQry.SingleTableSelect - TADOQuery.Create', [WSCDS_DebugMsg]), ServiceName, LogValues, 0);
      try
        Qry.ConnectionString := GetConnectionString;
        Qry.SQL.Text   := Sql;
        Qry.Prepared   := True;
        if LogValues.DebugEvents > 0 then TServicesLog.WriteLog(ssbylLog, Format('%s AdoQry.SingleTableSelect / Connected ', [WSCDS_DebugMsg]), ServiceName, LogValues, 0);
        try
          if LogValues.DebugEvents = 2 then TServicesLog.WriteLog(ssbylLog, Format('%sAdoQry.SingleTableSelect - Qry.SQL.Text =%s', [WSCDS_DebugMsg, Qry.SQL.Text]), ServiceName, LogValues, 0);
          Qry.Open;
          RecordCount := Qry.RecordCount;
          if LogValues.DebugEvents = 2 then TServicesLog.WriteLog(ssbylLog, Format('%sAdoQry.SingleTableSelect - Qry.RecordCount =%s', [WSCDS_DebugMsg, IntToStr(Qry.RecordCount)]), ServiceName, LogValues, 0);
          if not Qry.Eof then
          begin
            Qry.first;
            while not Qry.Eof do
            begin
              for Cpt := 0 to pred(Length(FieldsArray)) do
                ResultValue := ResultValue + TSLResult.Delimiter + Qry.Fields[Cpt].asString;
              ResultValue := Copy(ResultValue, 2, Length(ResultValue));
              TSLResult.Add(ResultValue);
              if LogValues.DebugEvents = 2 then TServicesLog.WriteLog(ssbylLog, Format('%sAdoQry.SingleTableSelect - ResultValue =%s', [WSCDS_DebugMsg, ResultValue]), ServiceName, LogValues, 0);
              ResultValue := '';
              Qry.Next;
              if LogValues.DebugEvents = 2 then TServicesLog.WriteLog(ssbylLog, Format('%sAdoQry.SingleTableSelect - After Qry.Next', [WSCDS_DebugMsg]), ServiceName, LogValues, 0);
            end;
          end;
        except
          begin
            Result := Format('Erreur sur %s', [Qry.SQL.Text]);
            Raise Exception.Create(Result);
          end;
        end;
      finally
      end;
      if Result = '' then
    except
      on E:Exception do
      begin
        if LogValues.DebugEvents = 2 then TServicesLog.WriteLog(ssbylLog, Format('%sAdoQry.SingleTableSelect - Exception = %s', [WSCDS_DebugMsg, E.Message]), ServiceName, LogValues, 0);
        Result := E.Message;
      end;
    end;
  end;
end;

procedure AdoQry.InsertUpdate;
begin
  if     (ServerName <> '') // Nom du serveur
     and (DBName <> '')     // Nom de la BDD
     and (Request <> '')    // Requï¿½te
  then
  begin
    Qry.ConnectionString := GetConnectionString;
    Qry.SQL.Text         := Request;
    Qry.Prepared         := True;
    try
      RecordCount := Qry.ExecSQL;
    except
      on E:Exception do
      begin
        Raise;
      end;
    end;
  end;
end;


{ Tools }

class function Tools.StringInList (St : string; ListST : string) : boolean;
var SS,SST : string;
begin
  result := false;
  SS := ListSt;
  repeat
    SST := readTokenSt(SS);
    if SST <> '' then
    begin
      if St = SST then
      begin
        result := true;
        break;
      end;
    end;
  until SST = '';
end;

class function Tools.CaseFromString(Value: string; Values: array of string): integer;
var
  Cpt : Integer;
begin
  Result := -1;
  if (Value <> '') and (Length(Values) > -1) then
  begin
   for Cpt := Low(Values) to High(Values) do
    begin
      if Values[Cpt] = Value then
      begin
        Result := Cpt;
        Break;
      end;
    end;
  end;
end;

class function Tools.GetTypeFieldFromStringType(TypeString : string)  : tTypeField;
begin
  if TypeString <> '' then
  begin
    case Tools.CaseFromString(TypeString, ['INTEGER', 'SMALLINT', 'DOUBLE', 'RATE', 'EXTENDED', 'DATE', 'BLOB', 'DATA', 'COMBO', 'BOOLEAN']) of
      0..1 : Result := ttfInt;     {INTEGER , SMALLINT}
      2..4 : Result := ttfNumeric; {DOUBLE, RATE, EXTENDED}
      5    : Result := ttfDate;    {DATE}
      6..7 : Result := ttfMemo;    {BLOB, DATA}
      8    : Result := ttfCombo;   {COMBO}
      9    : Result := ttfBoolean; {BOOLEAN}
    else
      Result := ttfText;
    end;
  end else
    Result := ttfNone;
end;

class function Tools.GetStFieldType(FieldName: string{$IFDEF APPSRV}; ServerName, DBName : string; DebugEvents : integer=0{$ENDIF !APPSRV}): string;
{$IFDEF APPSRV}
var
  lAdoQry  : AdoQry;
  LogValue : T_WSLogValues;
{$ENDIF!APPSRV}
begin
  if FieldName <> '' then
  begin
    {$IFNDEF APPSRV}
    Result :=  ChampToType(FieldName);
    {$ELSE  !APPSRV}
    if (DebugEvents > 0) then TServicesLog.WriteLog(ssbylWindows, Format('%sTools.GetStFieldType / Srv=%s, Folder=%s', [WSCDS_DebugMsg, ServerName, DBName]), 'Debug service', LogValue, 0);
    lAdoQry := AdoQry.Create;
    try
      if (DebugEvents > 0) then TServicesLog.WriteLog(ssbylWindows, Format('%sTools.GetStFieldType', [WSCDS_DebugMsg]), 'Debug service', LogValue, 0);
      lAdoQry.ServerName            := ServerName;
      lAdoQry.DBName                := DBName;
      lAdoQry.Qry                   := TADOQuery.create(nil);
      lAdoQry.LogValues.DebugEvents := DebugEvents;
      lAdoQry.FieldsList            := 'DH_TYPECHAMP';
      lAdoQry.Request               := 'SELECT ' + lAdoQry.FieldsList + ' FROM DECHAMPS WHERE DH_NOMCHAMP =''' + FieldName + '''';
      if (DebugEvents > 0) then TServicesLog.WriteLog(ssbylWindows, Format('%sTools.GetStFieldType - Before create lAdoQry.Connect', [WSCDS_DebugMsg]), 'Debug service', LogValue, 0);
      if (DebugEvents > 0) then TServicesLog.WriteLog(ssbylWindows, Format('%sTools.GetStFieldType - Before lAdoQry.SingleTableSelect', [WSCDS_DebugMsg]), 'Debug service', LogValue, 0);
      lAdoQry.SingleTableSelect;
      Result := lAdoQry.TSLResult[0];
    finally
      lAdoQry.Reset;
      lAdoQry.Qry.Free;
      lAdoQry.Free;
    end;
    {$ENDIF !APPSRV}
  end else
    Result := '';
end;

class function Tools.GetFieldType(FieldName: string{$IFDEF APPSRV}; ServerName, DBName : string{$ENDIF APPSRV}): tTypeField;
var
  FieldType : string;
begin
  FieldType := Tools.GetStFieldType(FieldName{$IFDEF APPSRV}, ServerName, DBName{$ENDIF APPSRV});
  Result    := Tools.GetTypeFieldFromStringType(FieldType);
end;

class function Tools.GetDefaultValueFromtTypeField(FieldType : tTypeField; WithQuote : boolean=True) : string;
begin
  case FieldType of
    ttfNumeric : Result := '0';
    ttfInt     : Result := '0';
    ttfMemo    : Result := Tools.iif(WithQuote, '''''', '');
    ttfBoolean : Result := Tools.iif(WithQuote, '''-''', '-');
    ttfDate    : Result := Tools.iif(WithQuote, '''2''', '2');
    ttfCombo   : Result := Tools.iif(WithQuote, '''''', '');
    ttfText    : Result := Tools.iif(WithQuote, '''''', '');
  end;
end;

class function Tools.iif(Const Expression, TruePart, FalsePart: Boolean): Boolean;
begin
	if Expression then
		Result := TruePart
	else
		Result := FalsePart;
end;

class function Tools.iif(Const Expression: Boolean; Const TruePart, FalsePart: Integer): Integer;
begin
	if Expression then
		Result := TruePart
	else
		Result := FalsePart;
end;

class function Tools.iif(Const Expression: Boolean; Const TruePart, FalsePart: Double): Double;
begin
	if Expression then
		Result := TruePart
	else
		Result := FalsePart;
end;

class function Tools.iif(Const Expression: Boolean; Const TruePart, FalsePart: String): String;
begin
	if Expression then
		Result := TruePart
	else
		Result := FalsePart;
end;

class function Tools.iif(Const Expression: Boolean; Const TruePart, FalsePart: Char): Char;
begin
	if Expression then
		Result := TruePart
	else
		Result := FalsePart;
end;

class function Tools.iif(Const Expression: Boolean; Const TruePart, FalsePart: TStringList): TStringList;
begin
	if Expression then
		Result := TruePart
	else
		Result := FalsePart;
end;

class function Tools.iif(Const Expression: Boolean; Const TruePart, FalsePart: TGncERROR): TGncERROR; 
begin
	if Expression then
		Result := TruePart
	else
		Result := FalsePart;
end;

{$IFNDEF APPSRV}
class function Tools.iif(Const Expression: Boolean; Const TruePart, FalsePart: TActionFiche): TActionFiche;
begin
	if Expression then
		Result := TruePart
	else
		Result := FalsePart;
end;

class function Tools.iif(Const Expression: Boolean; Const TruePart, FalsePart: TOB): TOB;
begin
	if Expression then
		Result := TruePart
	else
		Result := FalsePart;
end;
{$ENDIF !APPSRV}

class function Tools.ReadTokenSt_(var S : string; Separator : string) : string;
var
  Cpt : integer;
begin
  Cpt:= Pos(Separator, S);
  if Cpt > 0 then
  begin
    Result := Copy(S, 1, Cpt-1);
    S      := Copy(S, Cpt + 1, Length(S)-Cpt);
  end else
  begin
    Result := S;
    S      := '';
  end;
end;

class function Tools.CountOccurenceString(const S: string; ToCount: string): integer;
var
  Pos : integer;
begin
  Result := 0;
  Pos    := PosEx(ToCount, S, 1);
  while Pos <> 0 do
  begin
    Inc(Result);
    Pos := PosEx(ToCount, S, Pos + 1);
  end;

end;

class function Tools.GetArgumentValue(Argument: string; const MyArg: String; const WithUpperCase: Boolean; const Separator: String): String;
var
	Critere	: String;
begin
	Result := '';
  while (Argument <> '') and (Result = '') do
  begin
    if WithUpperCase then
     	Critere := UpperCase(Tools.ReadTokenSt_(Argument, Separator))
    else
      Critere := Tools.ReadTokenSt_(Argument, Separator);
   	if (Pos(MyArg, Critere) > 0) and (Pos('=', Critere) <> 0) and (Trim(Copy(Critere, 1, Pos('=', Critere) - 1)) = MyArg) then
   	  Result := Trim(Copy(Critere, Pos('=', Critere) + 1, Length(Critere)));
	end;
end;

class function Tools.GetArgumentString(Argument: string; const MyArg: String; WithUpperCase: Boolean; const Separator: String): string;
begin
	if Pos(MyArg, Argument) > 0 then
		Result := VarToStr(GetArgumentValue(Argument, MyArg, WithUpperCase, Separator))
  else
   	Result := '';
end;

class function Tools.SetStrDateTimeFromStrUTCDateTime(UTCDateTime: string): string;
var
  Time       : TDateTime;
  Year       : integer;
  Month      : integer;
  Day        : integer;
  Hour       : integer;
  Minute     : integer;
  Second     : integer;
  Mlsecond   : integer;
  HourOffset : integer;
  MinOffset  : integer;
  WithMlSecond : Boolean;
  AddHour  : Boolean;
begin
  if UTCDateTime = '' then
    UTCDateTime := Tools.SetStrDateTimeToUTCDateTime('01/01/1900 00:00:00');
  WithMlSecond := UTCDateTime[20] = '.';
  Year     := StrToInt(copy(UTCDateTime,1 , 4));
  Month    := StrToInt(copy(UTCDateTime,6 , 2));
  Day      := StrToInt(copy(UTCDateTime,9 , 2));
  Hour     := StrToInt(copy(UTCDateTime,12, 2));
  Minute   := StrToInt(copy(UTCDateTime,15, 2));
  Second   := StrToInt(copy(UTCDateTime,18, 2));
  if not WithMlSecond then
  begin
    Mlsecond   := 0;
    HourOffset := StrToInt(copy(UTCDateTime,21, 2));
    MinOffset  := StrToInt(copy(UTCDateTime,24, 2));
    AddHour    := (UTCDateTime[20] = '+');
  end else
  begin
    Mlsecond   := StrToInt(copy(UTCDateTime,21, 3));
    HourOffset := 0;
    MinOffset  := 0;
    AddHour    := False;
  end;
  if AddHour then
  begin
    HourOffset := -1 * HourOffset;
    MinOffset  := -1 * MinOffset;
  end;
  Time   := EncodeDateTime(Year, Month, Day, Hour, Minute, Second, Mlsecond);
//  Time   := IncHour(Time, hourOffset);
//  Time   := IncMinute(Time, minOffset);
  Result := DateTimeToStr(Time);
end;

class function Tools.SetStrDateTimeToUTCDateTime(stDateTime : string) : string;
begin
  if stDateTime <> '' then
    Result := FormatDateTime('yyyy-mm-dd', Int(StrToDateTime(stDateTime))) + 'T' +  FormatDateTime('hh:nn:ss.zzz', StrToDateTime(stDateTime)) + 'Z'
  else
    Result := '';
end;

class function Tools.SetStrUTCDateTimeToDateTime(stUTCDateTime : string) : string;
begin
  if stUTCDateTime <> '' then
  begin
    Result := copy(stUTCDateTime, 1, pos('T', stUTCDateTime) -1);
    Result := Format('%s/%s/%s', [copy(Result, 9, 2), copy(Result, 6, 2), copy(Result, 1, 4)]);
  end else
    Result := '';
end;


class function Tools.GetFileSize(FilePath: string; Size: tScaleSize): Extended;
var
  SearchFile : TSearchRec;
  FileSize   : Int64;
begin
  Result := 0;
  if FilePath <> '' then
  begin
    if (FindFirst(FilePath, faAnyFile, SearchFile) = 0) then
      FileSize := SearchFile.Size
    else
      FileSize := 0;
    case Size of
      tssKo : Result := (FileSize / 1024);
      TssMo : Result := (FileSize / 1048576);
    else
      Result := 0;
    end;
  end;
end;

class function Tools.StrFPoint_(Value : Extended) : string;
{$IFDEF APPSRV}
var
  stValue : string;
{$ENDIF APPSRV}
begin
  {$IFDEF APPSRV}
  stValue := FloatToStr(Value);
  Result  := StringReplace(stValue, ',', '.', [rfReplaceAll]);
  {$ELSE APPSRV}
  Result := StrFPoint(Value);
  {$ENDIF !APPSRV}
end;

class function Tools.IsNumeric_(stValue : string) : boolean;
begin
  {$IFDEF APPSRV}
  try
    Result := True;
    StrToFloat(stValue);
  except
    Result := False;
  end;
  {$ELSE APPSRV}
  Result := IsNumeric(stValue);
  {$ENDIF APPSRV}
end;

class function Tools.GetFieldsListFromPrefix(TablePrefix : string{$IFDEF APPSRV}; ServerName, DBName : string{$ENDIF APPSRV}; Separator : string=',') : string;
var
  {$IFDEF APPSRV}
  lAdoQry : AdoQry;
  Cpt     : integer;
  {$ELSE APPSRV}
  TobFieldsList : TOB;
  Cpt           : Integer;
  {$ENDIF APPSRV}

  function GetSelect : string;
  begin
    Result := Format('SELECT DH_NOMCHAMP FROM DECHAMPS WHERE DH_PREFIXE = %s%s%s ORDER BY DH_NUMCHAMP', [Tools.GetStringSeparatorForQry, TablePrefix, Tools.GetStringSeparatorForQry]);
  end;

begin
  if TablePrefix <> '' then
  begin
    {$IFDEF APPSRV}
    lAdoQry := AdoQry.Create;
    try
      lAdoQry.ServerName := ServerName;
      lAdoQry.DBName     := DBName;
      lAdoQry.Qry        := TADOQuery.create(nil);;
      lAdoQry.FieldsList := 'DH_NOMCHAMP';
      lAdoQry.Request    := GetSelect;
      try
        lAdoQry.SingleTableSelect;
      finally
      end;
      for Cpt := 0 to pred(lAdoQry.TSLResult.Count) do
        Result := Result + Separator + lAdoQry.TSLResult[Cpt];
    finally
      lAdoQry.Qry.Free;
      lAdoQry.Free;
    end;
    {$ELSE APPSRV}
    TobFieldsList := TOB.Create('_FIELD', nil, -1);
    try
      TobFieldsList.LoadDetailFromSQL(GetSelect);
      for Cpt := 0 to pred(TobFieldsList.Detail.count) do
        Result := Result + Separator + TobFieldsList.Detail[Cpt].GetString('DH_NOMCHAMP');
    finally
      FreeAndNil(TobFieldsList);
    end;
    {$ENDIF APPSRV}
    Result := Copy(Result, Length(Separator)+1, Length(Result));
  end else
    Result := '';
end;

class function Tools.GetTSlIndexFromFieldName(TslLine, FieldName : string; Separator : string=',') : integer;
var
  lTSlLine   : string;
  lFieldName : string;
begin
  Result := 0;
  if (TSlLine <> '') and (FieldName <> '') then
  begin
    lTSlLine := TslLine;
    while lTSlLine <> '' do
    begin
      inc(Result);
      lFieldName := Tools.ReadTokenSt_(lTSlLine, Separator);
      if lFieldName = FieldName then
        break;
    end;
  end;
end;

class function Tools.GetStValueFromTSl(TSlLine, FieldName : string) : string;
var
  Values : string;
  Value  : string;
  FindIt : boolean;
begin
  Result := '';
  if (TSlLine <> '') and (FieldName <> '') then
  begin
    Values := TSlLine;
    while Values <> '' do
    begin
      Value  := Tools.ReadTokenSt_(Values, ToolsTobToTsl_Separator);
      FindIt := Copy(Value, 1, Pos('=', Value) - 1) = FieldName;
      if FindIt then
      begin
        Result := Copy(Value, pos('=', Value) + 1, Length(Value));
        Break;
      end;
    end;
  end;
end;

class function Tools.GetStValueFromTSl(TSlLine : string; Index : integer; Separator : string=',') : string;
var
  Values : string;
  Cpt    : integer;
begin
  Result := '';
  if (TSlLine <> '') and (Index >= 0) then
  begin
    Values := TSlLine;
    Cpt    := 0;
    while Cpt < Index do
    begin
      inc(Cpt);
      Result := Tools.ReadTokenSt_(Values, Separator);
    end;
  end;
end;

{$IFNDEF APPSRV}
class procedure Tools.TobToTStringList(TobOrig: TOB; TSlResult: TStringList; Level : Integer=1);
var
  Cpt : Integer;

  procedure TSlAdd(TobOrigL : TOB; FirstLevelOnly : Boolean);
  var
    CptFields   : integer;
    CptSublevel : integer;
    NewLevel    : integer;
    FieldName   : string;
    FieldValue  : string;
    Fields      : string;
  begin
    Fields := ToolsTobToTsl_LevelName + IntToStr(Level) + '=' + TobOrigL.NomTable;
    for CptFields := 1 to TobOrigL.NombreChampReel do
    begin
      FieldName  := TobOrigL.GetNomChamp(CptFields);
      if FieldName <> '' then
      begin
        FieldValue := TobOrigL.GetString(FieldName);
        Fields := Fields + ToolsTobToTsl_Separator + FieldName + '=' + FieldValue;
      end;
    end;
    TSlResult.Add(Fields);
    if (TobOrigL.Detail.Count > 0) and (not FirstLevelOnly) then
    begin
      NewLevel := Level + 1;
      for CptSublevel := 0 to pred(TobOrigL.Detail.Count) do
        TobToTStringList(TobOrigL.Detail[CptSublevel], TSlResult, NewLevel);
    end;
  end;

begin
  if (assigned(TobOrig)) and (Assigned(TSlResult)) then
  begin
    TSlAdd(TobOrig, True);
    Inc(Level);
    for Cpt := 0 to pred(TobOrig.Detail.Count) do
      TSlAdd(TobOrig.detail[Cpt], False);
  end;
end;
{$ENDIF !APPSRV}

{$IFNDEF APPSRV}
class procedure Tools.GetFieldsListAndTypeFromPrefix(TablePrefix : string; TslResult : TStringList);
var
  Sql : string;
  Qry : TQuery;
begin
  if (TablePrefix <> '') and (assigned(TslResult)) then
  begin
    Sql := Format('SELECT DH_NOMCHAMP, DH_TYPECHAMP FROM DECHAMPS WHERE DH_PREFIXE = %s%s%s ORDER BY DH_NUMCHAMP', [Tools.GetStringSeparatorForQry, TablePrefix, Tools.GetStringSeparatorForQry]);
    Qry := OpenSql(Sql, True);
    while not Qry.Eof do
    begin
      TslResult.Add(Format('%s=%s', [Qry.Fields[0].AsString, Qry.Fields[1].AsString]));
      Qry.Next;
    end;
  end;
end;
{$ENDIF APPSRV}

{$IFDEF APPSRVWITHCBP}
class procedure Tools.TStringListToTOB(TslValues : TStringList; ArrOfFields : array of string; TobResult : TOB; WithType : boolean);
var
  Cpt        : integer;
  CptField   : integer;
  Value      : string;
  FieldName  : string;
  FieldValue : string;
  FieldType  : string;
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
        if WithType then
        begin
          FieldType  := ExtractFieldType(ArrOfFields[CptField])
        end else
          FieldType  := '';
        if (FieldType = 'BOOLEAN') then
          FieldValue := Tools.iif(FieldValue = 'Faux', '-', 'X');
        TobL.AddChampSupValeur(FieldName, FieldValue);
        inc(CptField);
      end;
    end;
  end;
end;
{$ENDIF APPSRVWITHCBP}


class function Tools.GetTableNameFromTtn(Ttn: tTableName): string;
begin
  case Ttn of
    ttnChoixCod           : Result := 'CHOIXCOD';
    ttnCommun             : Result := 'COMMUN';
    ttnChoixExt           : Result := 'CHOIXEXT';
    ttnDevise             : Result := 'DEVISE';
    ttnModeRegl           : Result := 'MODEREGL';
    ttnPays               : Result := 'PAYS';
    ttnRib                : Result := 'RIB';
    ttnSection            : Result := 'SECTION';
    ttnTiers              : Result := 'TIERS';
    ttnCodePostaux        : Result := 'CODEPOST';
    ttnContact            : Result := 'CONTACT';
    ttnEtabliss           : Result := 'ETABLISS';
    ttnModePaie           : Result := 'MODEPAIE';
    ttnGeneraux           : Result := 'GENERAUX';
    ttnJournal            : Result := 'JOURNAL';
    ttnRelance            : Result := 'RELANCE';
    ttnCorresp            : Result := 'CORRESP';
    ttnChancell           : Result := 'CHANCELL';
    ttnExercice           : Result := 'EXERCICE';
    ttnParamSoc           : Result := 'PARAMSOC';
    ttnEcriture           : Result := 'ECRITURE';
    ttnAcomptes           : Result := 'ACOMPTES';
    ttnPiece              : Result := 'PIECE';
    ttnLigne              : Result := 'LIGNE';
    ttnAffaire            : Result := 'AFFAIRE';
    ttnArticle            : Result := 'ARTICLE';
    ttnRessource          : Result := 'RESSOURCE';
    ttnConsommations      : Result := 'CONSOMMATIONS';
    ttnAffTiers           : Result := 'AFFTIERS';
    ttnCatalogu           : Result := 'CATALOGU';
    ttnBtFamilleTarif     : Result := 'BTFAMILLETARIF';
    ttnBtSousFamilleTarif : Result := 'BTSOUSFAMILLETARIF';
  else
    Result := '';
  end;
end;


class function Tools.GetTtnFromTableName(TableName: string): tTableName;
begin
  case CaseFromString(TableName, [  'CHOIXCOD'      , 'COMMUN'            , 'DEVISE'   , 'MODEREGL'     , 'PAYS'    , 'RIB'
                                  , 'SECTION'       , 'TIERS'             , 'CODEPOST' , 'CONTACT'      , 'ETABLISS', 'MODEPAIE'
                                  , 'GENERAUX'      , 'JOURNAL'           , 'RELANCE'  , 'CORRESP'      , 'CHANCELL', 'EXERCICE'
                                  , 'PARAMSOC'      , 'CHOIXEXT'          , 'ECRITURE' , 'ACOMPTES'     , 'PIECE'   , 'LIGNE'
                                  , 'AFFAIRE'       , 'ARTICLE'           , 'RESSOURCE', 'CONSOMMATIONS', 'AFFTIERS', 'CATALOGU'
                                  , 'BTFAMILLETARIF', 'BTSOUSFAMILLETARIF'
                                 ]) of
    {CHOIXCOD}           0  : Result := ttnChoixCod;
    {COMMUN}             1  : Result := ttnCommun;
    {DEVISE}             2  : Result := ttnDevise;
    {MODEREGL}           3  : Result := ttnModeRegl;
    {PAYS}               4  : Result := ttnPays;
    {RIB}                5  : Result := ttnRib;
    {SECTION}            6  : Result := ttnSection;
    {TIERS}              7  : Result := ttnTiers;
    {CODEPOST}           8  : Result := ttnCodePostaux;
    {CONTACT}            9  : Result := ttnContact;
    {ETABLISS}           10 : Result := ttnEtabliss;
    {MODEPAIE}           11 : Result := ttnModePaie;
    {GENERAUX}           12 : Result := ttnGeneraux;
    {JOURNAL}            13 : Result := ttnJournal;
    {RELANCE}            14 : Result := ttnRelance;
    {CORRESP}            15 : Result := ttnCorresp;
    {CHANCELL}           16 : Result := ttnChancell;
    {EXERCICE}           17 : Result := ttnExercice;
    {PARAMSOC}           18 : Result := ttnParamSoc;
    {CHOIXEXT}           19 : Result := ttnChoixExt;
    {ECRITURE}           20 : Result := ttnEcriture;
    {ACOMPTES}           21 : Result := ttnAcomptes;
    {PIECE}              22 : Result := ttnPiece;
    {LIGNE}              23 : Result := ttnLigne;
    {AFFAIRE}            24 : Result := ttnAffaire;
    {ARTICLE}            25 : Result := ttnArticle;
    {RESSOURCE}          26 : Result := ttnRessource;
    {CONSOMMATIONS}      27 : Result := ttnConsommations;
    {AFFTIERS}           28 : Result := ttnAffTiers;
    {CATALOGU}           29 : Result := ttnCatalogu;
    {BTFAMILLETARIF}     30 : Result := ttnBtFamilleTarif;
    {BTSOUSFAMILLETARIF} 31 : Result := ttnBtSousFamilleTarif;
  else
    Result := ttnNone;
  end;
end;

class function Tools.CanInsertedInTable(TableName: string{$IFDEF APPSRV}; ServerName, DBName : string{$ENDIF APPSRV}): Boolean;
{$IFDEF APPSRV}
var
  AdoQryAut : AdoQry;
{$ENDIF APPSRV}
begin
  if (TableName <> '') and (GetTtnFromTableName(TableName) <> ttnNone) then
  begin
    {$IFNDEF APPSRV}
    Result := ExisteSql(Format('SELECT 1 FROM BTWSTABLEAUTO WHERE BWT_NOMTABLE = "%s" AND BWT_AUTORISEE = "X"', [TableName]))
    {$ELSE !APPSRV}
    AdoQryAut := AdoQry.create;
    try
      AdoQryAut.ServerName := ServerName;
      AdoQryAut.DBName     := DBName;
      AdoQryAut.Qry        := TADOQuery.create(nil);
      AdoQryAut.FieldsList := 'BWT_NOMTABLE';
      AdoQryAut.Request    := Format('SELECT %s FROM BTWSTABLEAUTO WHERE BWT_NOMTABLE = ''%s'' AND BWT_AUTORISEE = ''X''', [AdoQryAut.FieldsList, TableName]);
      AdoQryAut.SingleTableSelect;
      Result := AdoQryAut.RecordCount = 1;
    finally
      AdoQryAut.Qry.Free;
      AdoQryAut.Free;
    end;
    {$ENDIF !APPSRV}
  end else
    Result := True;
end;

class function Tools.GetPSocTreeToExport(OnlyAccounting : Boolean=False) : string;
var
  Sep : string;
begin
  {$IFNDEF APPSRV}
  Sep := '"';
  {$ELSE !APPSRV}
  Sep := '''';
  {$ENDIF !APPSRV}
  Result := Format('(soc_tree like %s001;001;%%s)', [Sep, Sep]);
  if not OnlyAccounting then
    Result := Result + Format('(soc_tree like %s001;027;%%s)', [Sep, Sep])
                     + Format('(soc_tree like %s001;035;%%s)', [Sep, Sep])
                     + Format('(soc_tree like %s001;012;%%s)', [Sep, Sep])
                     + Format('(soc_tree like %s001;002;%%s)', [Sep, Sep])
                     + Format('(soc_tree like %s001;023;%%s)', [Sep, Sep])
                     + Format('(soc_tree like %s001;006;%%s)', [Sep, Sep])
                     + Format('(soc_tree like %s001;005;%%s)', [Sep, Sep])
                     + Format('(soc_tree like %s001;014;%%s)', [Sep, Sep])
                     + Format('(soc_tree like %s001;031;%%s)', [Sep, Sep])
                     + Format('(soc_tree like %s001;013;%%s)', [Sep, Sep])
                     + Format('(soc_tree like %s001;018;%%s)', [Sep, Sep])
                     + Format('(soc_tree like %s001;021;%%s)', [Sep, Sep])
                     ;
end;

class function Tools.SetTRAFileFromTSl(lTSL : TStringList) : Boolean;
begin
  Result := False;
  if Assigned(lTSL) and (lTSL.Count > 0) then
  begin

  end;
end;

class function Tools.FormatValue(Value : string; Align : tTypeAlign; iLength : integer; NbDec : Integer=0; TypeDate : tFormatValueTypeDate=tvtNone) : string;
var
  sIntValue : string;
  sDecValue : string;
  Cpt       : integer;
begin
  if iLength > 0 then
  begin
    Result := Value;
    if NbDec > 0 then
    begin
      if Pos(DecimalSeparator, Result) = 0 then
      begin
        Result := Result + ',';
        Cpt    := 0;
        while Cpt < NbDec do
        begin
          inc(Cpt);
          Result := Result + '0';
        end;
      end else
      begin
        sIntValue := Copy(Result, 1, Pos(DecimalSeparator, Result) -1);
        sDecValue := Copy(Result, Pos(DecimalSeparator, Result) +1 , NbDec);
        while Length(sDecValue) < NbDec do
          sDecValue := sDecValue + '0';
        Result := sIntValue + DecimalSeparator + sDecValue;
      end;
    end else
    if TypeDate = tvtDate then
      Result := FormatDateTime('ddmmyyyy', StrToDate(Value))
    else if TypeDate = tvtDateTime then
      Result := FormatDateTime('ddmmyyyyhhnn', StrToDateTime(Value));

    while Length(Result) < iLength do
    begin
      case Align of
        traaLeft  : Result := Result + ' ';
        traaRigth : Result := ' ' + Result;
      end;
    end;
  end else
    Result := '';
end;

class function Tools.CompressFile(FullPath : string) : string;
var
  Zip : TZip;
  FileList : TStrings;
begin
  Result := '';
  if FullPath <> '' then
  begin
    Zip := TZip.create(nil);
    try
      FileList := TStringList.Create ;
      try
        FileList.Add(FullPath);
        Zip.FileSpecList := FileList;
        Zip.Filename     := FullPath + '.zip';
        if Zip.Add > 0 then
          Result := Zip.Filename;
      finally
        FreeAndNil(FileList);
      end;
    finally
      FreeAndNil(Zip);
    end;
  end;
end;

class function Tools.UnCompressFile(ZipPath, ZipFileName : string) : integer;
var
  Zip : TZip;
  Cpt : integer;
begin
  Result := 0;
  if (ZipPath <> '') and (ZipFileName <> '') then
  begin
    Zip := TZip.create(nil);
    try
      Zip.FileSpecList.Clear;
      //Zip.ExtractOptions := [oeUpdate];
      Zip.ExtractPath := ZipPath;
      Zip.Filename    := ZipPath + ZipFileName;
      if Zip.Count >= 0 then
      begin
        for Cpt := 0 to pred(Zip.Count) do
          Zip.FileSpecList.Add(Zip.FileInfos[Cpt].Filename);
      Result := Zip.Extract;
      end;
    finally
      FreeAndNil(Zip);
    end;

  end;
end;

class procedure Tools.FileCut(FullPath : string; MaxSizeBytes : integer; TSLResult : TStringList; KeepOriginFile : boolean=True);
var
  FileStream : TFileStream;
  Cpt        : integer;
  Qty        : Integer;

  procedure DoCut(Index : Integer);
  var
    FileExtension : string;
    SplitFileName : string;
    sStream       : TFileStream;
    DelPos        : Integer;
  begin
    DelPos        := LastDelimiter('.', FullPath);
    FileExtension := Copy(FullPath, DelPos, Length(FullPath));
    SplitFileName := Copy(FullPath, 1, DelPos -1) + '_' + FormatFloat('000', Index) + FileExtension;
    sStream       := TFileStream.Create(SplitFileName, fmCreate);
    try
      if FileStream.Size - FileStream.Position < MaxSizeBytes then
        MaxSizeBytes := FileStream.Size - FileStream.Position;
      sStream.CopyFrom(FileStream, MaxSizeBytes);
    finally
      TSLResult.Add(SplitFileName);
      sStream.Free;
    end;
  end;

begin
  if (FullPath <> '') and (MaxSizeBytes > 0 ) then
  begin
    FileStream := TFileStream.Create(FullPath, fmOpenRead);
    try
      if FileStream.Size > MaxSizeBytes then
      begin
        Qty := 0;
        for Cpt := 0 to pred(Trunc(FileStream.Size / MaxSizeBytes)) do
        begin
          inc(Qty);
          DoCut(Cpt);
        end;
        DoCut(Qty);
        if not KeepOriginFile then
          SysUtils.DeleteFile(FullPath);
      end else
        TSLResult.Add(FullPath);
    finally
      FileStream.free;
    end;
  end;
end;

class function Tools.GetKoFromMo(Mo : integer) : Integer;
begin
  Result := Mo * 1024;
end;

class function Tools.DeleteDirectroy(Path : string) : boolean;
var
  iIndex    : Integer;
  SearchRec : TSearchRec;
  LocalPath : string;
  sFileName : string;
begin
  if Path <> '' then
  begin
    if Copy(Path, Length(Path), 1) <> '\' then
      LocalPath := Path + '\*.*'
    else
      LocalPath := Path + '*.*';
    iIndex := FindFirst(LocalPath, faAnyFile, SearchRec);
    while iIndex = 0 do
    begin
      sFileName := ExtractFileDir(LocalPath) + '\' + SearchRec.Name;
      if SearchRec.Attr = faDirectory then
      begin
      if     (SearchRec.Name <> '' )
         and (SearchRec.Name <> '.')
         and (SearchRec.Name <> '..')
      then
        SysUtils.DeleteFile(sFileName);
      end else
      begin
        if SearchRec.Attr <> faArchive then
          FileSetAttr(sFileName, faArchive);
        SysUtils.DeleteFile(sFileName);
      end;
      iIndex := FindNext(SearchRec);
    end;
    SysUtils.FindClose(SearchRec);
    Result := RemoveDir(LocalPath);
  end else
    Result := False;
end;

class function Tools.IsRecordableDocument(DocType, Establishment : string{$IFDEF APPSRV}; ServerName, DBName : string{$ENDIF APPSRV}) : boolean;
var
  AccState : string;
  {$IFDEF APPSRV}
  lAdoQry  : AdoQry;
  {$ENDIF APPSRV}

  {$IFDEF APPSRV}
  function GetAccType(Prefix : string) : string;
  var
    Sql : string;
  begin
    lAdoQry.TSLResult.Clear;
    lAdoQry.RecordCount := 0;
    lAdoQry.ServerName  := ''; //ServerName;
    lAdoQry.DBName      := ''; //DBName;
    lAdoQry.FieldsList  := Prefix + '_TYPEECRCPTA';
    Sql                 := Format('SELECT %s FROM %s WHERE %s_NATUREPIECEG = ''%s''', [lAdoQry.FieldsList, Tools.iif(Prefix = 'GPC', 'PARPIECECOMPL', 'PARPIECE'), Prefix, DocType]);
    if Prefix = 'GPC' then
      Sql := Sql + Format(' AND GPC_ETABLISSEMENT = ''%s''', [Establishment]);
    lAdoQry.Request    := Sql;
    lAdoQry.SingleTableSelect;
    if lAdoQry.RecordCount > 0 then
      Result := lAdoQry.TSLResult[0]
    else
      Result := '';
    lAdoQry.Reset;  
  end;
  {$ENDIF APPSRV}

begin
  if DocType <> '' then
  begin
    {$IFDEF APPSRV}
    lAdoQry := AdoQry.Create;
    try
      lAdoQry.Qry := TADOQuery.create(nil);
      AccState := Tools.iif(Establishment <> '', GetAccType('GPC'), '');
      if AccState = '' then
        AccState := GetAccType('GPP');
    finally
      lAdoQry.Qry.Free;
      lAdoQry.Free;
    end;
    {$ELSE APPSRV}
    AccState := Tools.iif(Establishment <> '', GetInfoParPieceCompl(DocType, Establishment, 'GPC_TYPEECRCPTA'), '');
    if AccState = '' then
      AccState := GetInfoParPiece(DocType, 'GPP_TYPEECRCPTA');
    {$ENDIF APPSRV}
    Result := ((AccState <> '') and (AccState <> 'RIE'));
  end else
    Result := False;
end;

class function Tools.EvalueDateJJMMYYY(sDate : string) : TDateTime;
var
  dd : word;
  mm : Word;
  yy : Word ;
begin
  if sDate <> '' then
  begin
    dd     := StrToInt(Copy(sDate,1,2));
    mm     := StrToInt(Copy(sDate,3,2));
    yy     := StrToInt(Copy(sDate,5,4));
    Result := Encodedate(yy,mm,dd);
  end else
    Result := 2;
end;

class procedure Tools.DecodeAccDocReferency(DocReferency : string; var DocType : string; var Stump : string; var DocDate : TDateTime; var DocNumber : integer; var Index : integer);
begin
  if DocReferency <> '' then
  begin
    DocType   := Tools.ReadTokenSt_(DocReferency, ';');
    Stump     := Tools.ReadTokenSt_(DocReferency, ';');
    DocDate   := Tools.EvalueDateJJMMYYY(Tools.ReadTokenSt_(DocReferency, ';'));
    DocNumber := StrToInt(Tools.ReadTokenSt_(DocReferency, ';'));
    Index     := StrToInt(Tools.ReadTokenSt_(DocReferency, ';'));
  end;
end;

class function Tools.GetConnectionString (ServerName ,DBName : string) : string;
begin
  Result := 'Provider=SQLOLEDB.1'
          + ';Password=ADMIN'
          + ';Persist Security Info=True'
          + ';User ID=ADMIN'
          + ';Initial Catalog=' + DBName
          + ';Data Source=' + ServerName
          + ';Use Procedure for Prepare=1'
          + ';Auto Translate=True'
          + ';Packet Size=4096'
          + ';Workstation ID=LOCALST'
          + ';Use Encryption for Data=False'
          + ';Tag with column collation when possible=False'
          ;
end;

class function Tools.GetParamSocSecur_(PSocName : string; DefaultValue : string{$IFDEF APPSRV}; ServerName, FolderName : string{$ENDIF APPSRV}) : string;
{$IFDEF APPSRV}
var
  AdoQryL : AdoQry;
{$ENDIF APPSRV}
begin
  Result := DefaultValue;
  {$IFDEF APPSRV}
  if (ServerName <> '') and (FolderName <> '') and (PSocName <> '') then
  begin
    AdoQryL := AdoQry.Create;
    try
      AdoQryL.ServerName  := ServerName;
      AdoQryL.DBName      := FolderName;
      AdoQryL.Qry         := TADOQuery.create(nil);
      AdoQryL.FieldsList  := 'SOC_DATA';
      AdoQryL.Request     := Format('SELECT %s FROM PARAMSOC WHERE SOC_NOM = ''%s''', [AdoQryL.FieldsList, PSocName]);
      AdoQryL.SingleTableSelect;
      if AdoQryL.RecordCount > 0 then
        Result := AdoQryL.TSLResult[0];
    finally
      AdoQryL.Qry.Free;
      AdoQryL.free;
    end;
  end;
  {$ELSE APPSRV}
  Result := GetParamSocSecur(PSocName, DefaultValue);
  {$ENDIF APPSRV}
end;

class function Tools.CastDateTimeForQry(lDate: TDateTime): string;
begin
  Result := FormatDateTime('yyyymmdd hh:nn:ss', lDate);
end;

class function Tools.DecodeDateTimeFromQry(sDate : string) : string;
var
  lDateTime : TDateTime;
  yy        : word;
  mm        : word;
  dd        : word;
  hh        : word;
  nn        : word;
  ss        : word;
  zz        : word;
begin
  if copy(sDate, 1, 1) = '''' then
    sDate := copy(sDate, 2, length(sDate) -1);
  yy := StrToInt(copy(sDate, 1, 4));
  mm := StrToInt(copy(sDate, 5, 2));
  dd := StrToInt(copy(sDate, 7, 2));
  hh := StrToInt(copy(sDate, 10, 2));
  nn := StrToInt(copy(sDate, 13, 2));
  ss := StrToInt(copy(sDate, 16, 2));
  zz := 00;
  lDateTime := EncodeDateTime(yy, mm, dd, hh, nn, ss, zz);
  Result    := DateTimeToStr(lDateTime);
end;

class function Tools.CastDateForQry(lDate : TDateTime) : string;
begin
  Result := FormatDateTime('yyyymmdd', lDate);
end;

class function Tools.UsDateTime_(dDateTime: TDateTime): string;
begin
  Result := FormatDateTime('yyyymmdd hh:nn:ss', dDateTime);
end;

class function Tools.GetDocTypeFromStub(Stub : string{$IFDEF APPSRV}; ServerName, DBName : string{$ENDIF APPSRV}) : string;
var
  Sql : string;
  {$IFNDEF APPSRV}
  Qry : TQuery;
  {$ELSE !APPSRV}
  AdoQryL : AdoQry;
  {$ENDIF !APPSRV}
begin
  if Stub <> '' then
  begin
    Sql := Format('SELECT GPP_NATUREPIECEG FROM PARPIECE WHERE GPP_SOUCHE = %s%s%s', [Tools.GetStringSeparatorForQry, Stub, Tools.GetStringSeparatorForQry]);
    {$IFNDEF APPSRV}
    Qry := OpenSql(Sql, False);
    try
      Result := Tools.iif(not Qry.Eof, Qry.Fields[0].AsString, '');
    finally
      Ferme(Qry);
    end;
    {$ELSE !APPSRV}
    AdoQryL := AdoQry.Create;
    try
      AdoQryL.ServerName  := ServerName;
      AdoQryL.DBName      := DBName;
      AdoQryL.Qry         := TADOQuery.Create(nil);
      AdoQryL.FieldsList  := 'GPP_NATUREPIECEG';
      AdoQryL.Request     := Sql;
      AdoQryL.TSLResult.Clear;
      AdoQryL.SingleTableSelect;
      Result := Tools.iif(AdoQryL.TSLResult.Count > 0, AdoQryL.TSLResult[0], '');
    finally
      AdoQryL.Qry.Free;
      AdoQryL.free;
    end;
    {$ENDIF !APPSRV}
  end else
    Result := '';
end;

class function Tools.GetStringSeparatorForQry : string;
begin
  {$IFDEF APPSRV}
   Result := '''';
  {$ELSE APPSRV}
   Result := '"';
  {$ENDIF APPSRV}
end;

{$IF not Defined(APPSRV) or (Defined(APPSRV) and Defined(APPSRVWITHCBP))}
class function Tools.BlobToString_(Texte: string): string;
var
  Lignes   : HTStrings;
  RichEdit : TRichEdit;
  Panel    : TPanel;
begin
  Panel              := TPanel.Create (nil);
  Panel.Visible      := False;
  Panel.ParentWindow := GetDesktopWindow;
  RichEdit           := TRichEdit.Create(Panel);
  RichEdit.Parent    := Panel;
  Lignes             := HTStringList.Create;
  Lignes.Text        := Texte;
  StringsToRich(RichEdit, Lignes);
  Result := Trim (RichEdit.Text);
  Lignes.Free;
  RichEdit.Free;
  Panel.Free;
  // On remplace les saut de lignes et tabulations pour que ï¿½a passe dans le fichier d'ï¿½change (et pas de saut de ligne en fin de texte)
  if Result <> '' then
  begin
    while (Result [Length (Result)] = #10) or (Result [Length (Result)] = #13) do
      Delete (Result, Length (Result), 1);
    Result := StringReplace (Result, #9, ' ', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace (Result, #10, '~~', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace (Result, #13, '', [rfReplaceAll, rfIgnoreCase]);
  end;
end;
{$IFEND}

class function Tools.ExtractFieldName(Value : string) : string;
begin
  Result := copy(Value, 1, pos(';', Value) -1)
end;

class function Tools.ExtractFieldType(Value : string) : string;
begin
  Result := copy(Value, pos(';', Value) +1,length(Value));
end;

{$IFDEF APPSRVWITHCBP}
class function Tools.LoadDetailDB(SQL: string; TOBD : TOB {$IFDEF APPSRV} ;Servername : string; DBName : string; ModeDebug : Integer=0; LogFile:string='' {$ENDIF APPSRV}): boolean;
var
{$IFNDEF APPSRV}
  Qry : Tquery;
{$ELSE}
  Qry : TADOQuery;
  II : Integer;
  TOBJ : TOB;
  Name : string;
  Value : Variant;
{$ENDIF}
begin
  Result := True;
{$IFNDEF APPSRV}
  Qry := OpenSql(Sql, False);
  if not Qry.eof then
  begin
    TOBD.LoadDetailDb ('ONE TABLE','','',Qry,false);
  end;
  Ferme(Qry);
{$ELSE !APPSRV}
  Qry := TADOQuery.Create(nil);
  Qry.ConnectionString := Tools.GetConnectionString (Servername,DbName);
  Qry.SQL.Text := SQL;
  Qry.Prepared := True;
  TRY
    Qry.Open;
    QRY.first;
    repeat
      TOBJ := TOB.Create ('UNE LIGNE',TOBD,-1);
      if (LogFile <> '') and (ModeDebug >1) then
      begin
        ecritLogS (LogFile, '----- Ligne Resultat -------');
      end;
      For II := 0 to Qry.FieldCount -1 do
      begin
        Name := QRy.Fields [II].FieldName;
        Value := Qry.Fields[II].Value;
        TOBD.AddChampSupValeur(Name, Value);
        if (LogFile <> '') and (ModeDebug >1) then
        begin
          ecritLogS (LogFile, Format('%s = %s',[Name,Value]));
        end;
      end;
      Qry.Next;
      if (LogFile <> '') and (ModeDebug >1) then
      begin
        ecritLogS (LogFile, '----- Fin Ligne Resultat -------');
      end;
    until QRY.Eof;
  FINALLY
    Qry.Free;
  end;
{$ENDIF !APPSRV}
end;

class function Tools.SelectDB(SQL: string; TOBD: TOB {$IFDEF APPSRV} ;Servername : string; DBName : string; ModeDebug : Integer=0; LogFile:string='' {$ENDIF APPSRV}  ): boolean;
var
{$IFNDEF APPSRV}
  Qry : Tquery;
{$ELSE}
  Qry : TADOQuery;
  II : Integer;
  Name : string;
  Value : Variant;
{$ENDIF}
begin
  Result := false;
{$IFNDEF APPSRV}
  Qry := OpenSql(Sql, False);
  if not Qry.eof then
  begin
    TOBD.SelectDB ('',Qry);
    result := true;
  end;
  Ferme(Qry);
{$ELSE !APPSRV}
  SQL := StringReplace(SQL, '"', '''', [rfReplaceAll]);
  //
  Qry := TADOQuery.Create(nil);
  Qry.ConnectionString := Tools.GetConnectionString (Servername,DbName);
  Qry.SQL.Text := SQL;
  Qry.Prepared := True;
  TRY
    Qry.Open;
    Qry.First;
    if not Qry.eof then
    begin
      result := True;
      For II := 0 to Qry.FieldCount -1 do
      begin
        Name := QRy.Fields [II].FieldName;
        Value := Qry.Fields[II].Value;
        if (LogFile <> '') and (ModeDebug >1) then
        begin
          ecritLogS (LogFile, '----- Resultat -------');
          ecritLogS (LogFile, Format('%s = %s',[Name,Value]));
          ecritLogS (LogFile, '----- Fin Resultat -------');
        end;
        TOBD.AddChampSupValeur(Name, Value);
      end;
    end;
  FINALLY
    Qry.Free;
  end;
{$ENDIF !APPSRV}

end;

class function ToolS.GetparamSocSecur(Paramsoc,ValeurDefaut: string; Servername : string; DBName : string; ModeDebug : Integer=0; LogFile:string=''): string;
var SQL : string;
    TOBR  :TOB;
begin
  Result := '';
  TOBR := TOB.Create ('UN PARAMSOC',nil,-1);
  TRY
  SQL := 'SELECT SOC_DATA FROM PARAMSOC WHERE SOC_NOM="'+Paramsoc+'"';
  if Tools.SelectDB (SQL,TOBR,Servername,DBName,ModeDebug,LogFile) then
  begin
    Result := TOBR.GetString('SOC_DATA');
  end;
  FINALLY
    TOBR.free;
  END;
end;

class function Tools.InsertOrUpdate(TobData : TOB{$IFDEF APPSRV} ;Servername : string; DBName : string; ModeDebug : Integer=0; LogFile:string='' {$ENDIF APPSRV}) : boolean;
begin
  Result := True;
end;
{$ENDIF APPSRVWITHCBP}

class function Tools.MemoryStreamToOleVariant(Strm: TMemoryStream):  OleVariant;
var
  Data : PByteArray;
begin
  Result := VarArrayCreate ([0, Strm.Size - 1], varByte);
  Data   := VarArrayLock(Result);
  try
    Strm.Position := 0;
    Strm.ReadBuffer(Data^, Strm.Size);
  finally
    VarArrayUnlock(Result);
  end;
end;

class function Tools.GetNumUniqueConso(var TheResult : double{$IFDEF APPSRV}; ServerName, DBName : string{$ENDIF APPSRV}) : TGncERROR;
var
  NumUnique : double;
  PrecNum   : string;
  PSocName  : string;
  SqlUpdate : string; 
  CptNombre : integer;
  OkNumero  : boolean;
  {$IFDEF APPSRV}
  lAdoQry   : AdoQry;
  {$ENDIF APPSRV}

  function ReformatageNumStr(Numero : string) : string;
  begin
    Result := Numero;
    if Pos('.',Numero) > 0 then
    begin
      Result := Copy(Result,1,Pos('.',Numero)-1);
    end;
    if Pos(',',Numero) > 0 then
    begin
      Result := Copy(Result,1,Pos(',',Numero)-1);
    end;
    Result := StringReplace(Result,' ','',[rfReplaceAll]);
  end;


  function GetNumParamSoc (var Numero : string) : TGncError;
  var
    Sql : string;
    {$IFNDEF APPSRV}
    Qry : TQuery;
    {$ELSE !APPSRV}
    Qry : AdoQry;
    {$ENDIF !APPSRV}
  begin
    Sql := Format('SELECT SOC_DATA FROM PARAMSOC WHERE SOC_NOM = %s%s%s', [Tools.GetStringSeparator, PSocName, Tools.GetStringSeparator]);
    {$IFNDEF APPSRV}
    Qry := OpenSql(Sql,  True);
    try
      if not Qry.Eof then
      begin
        Result := GncOk;
        Numero := Qry.FindField('SOC_DATA').AsString;
        ReformatageNumStr(Numero);
      end else
        Result := GncAbort;
    finally
      ferme(Qry);
    end;
    {$ELSE !APPSRV}
    Qry := AdoQry.Create;
    try
      Qry.ServerName := ServerName;
      Qry.DBName     := DBName;
      Qry.Qry        := TADOQuery.create(nil);
      Qry.FieldsList := 'SOC_DATA';
      Qry.Request    := Sql;
      Qry.SingleTableSelect;
      if Qry.RecordCount = 1 then
      begin
        Result := GncOk;
        Numero := Qry.TSLResult[0];
      end else
        Result := GncAbort;
    finally
      Qry.Qry.Free;
      Qry.Free;
    end;
    {$ENDIF !APPSRV}
  end;

begin
  PSocName  := 'SO_BTCPTLIGCONSO';
  OkNumero  := False;
  CptNombre := 1;
  NumUnique := 0;
  Repeat
    Result := GetNumParamSoc(precNum);
    if Result = GncAbort then break;
    NumUnique := StrToFloat(PrecNum) + 1;
    SqlUpdate := Format('UPDATE PARAMSOC SET SOC_DATA = %s%s%s WHERE SOC_NOM = %s%s%s AND SOC_DATA = %s%s%s'
                     , [  Tools.GetStringSeparator
                        , FloatToStr(NumUnique)
                        , Tools.GetStringSeparator
                        , Tools.GetStringSeparator
                        , PSocName
                        , Tools.GetStringSeparator
                        , Tools.GetStringSeparator
                        , PrecNum
                        , Tools.GetStringSeparator
                       ]);                       
    {$IFNDEF APPSRV}
    OkNumero := (ExecuteSQL(SqlUpdate) = 1);
    {$ELSE !APPSRV}
    lAdoQry := AdoQry.Create;
    try
      lAdoQry.ServerName := ServerName;
      lAdoQry.DBName     := DBName;
      lAdoQry.Request    := SqlUpdate;
      lAdoQry.InsertUpdate;
      OkNumero := (lAdoQry.RecordCount = 1);
    finally
      lAdoQry.Free;
    end;
    {$ENDIF APPSRV}
    if OkNumero then
      break;                             
    if CptNombre > 1000 then
    begin
      Result := GncAbort;
      break;
    end;
    inc(CptNombre);
  until OKNumero;
  if Result = GncOk then
    TheResult := NumUnique;
end;

class function Tools.IsPieceGerableCoTraitance(DocType, CaseCode, Flow, CaseRepresentative : string) : boolean;
begin
  Result := (    (pos(Format(';%s;', [DocType]),';ETU;DBT;FBT;FBP;ABP;') > 0) // Est une piÃ¨ce de co-traitance   (GP_NATUREPIEEG)
             and (CaseCode <> '')                                             // Code affaire renseignÃ©          (GP_AFFAIRE)
             and (Flow = 'VEN')                                               // Flux de vente                   (GP_VENTEACHAT)
             and (CaseRepresentative <> '')                                   // Est une affaire avec mandataire (AFF_MANDATAIRE)
{$IFNDEF APPSRV}
             and (VH_GC.SeriaCoTraitance)                                     // Co-traitance sÃ©rialisÃ©e
{$ENDIF !APPSRV}
            );
end;

class function Tools.IsPieceGerableSousTraitance(DocType, Flow : string) : boolean;
begin
  Result := (    (pos(Format(';%s;', [DocType]),';ETU;BCE;DBT;FBT;PBT;ABT;FBP;ABP;') > 0) // Est une de piÃ¨ce de sous traitance (GP_NATUREPIEEG)
             and (Flow = 'VEN')                                                           // Flux de vente                      (GP_VENTEACHAT)
{$IFNDEF APPSRV}
             and  (VH_GC.SeriaSousTraitance)                                              // Sous-traitance sÃ©rialisÃ©e
{$ENDIF !APPSRV}
            );
end;

class function Tools.GetMainIban(Auxiliary : string{$IFDEF APPSRV}; ServerName, DBName : string{$ENDIF APPSRV}) : string;
var
  {$IFNDEF APPSRV}
  Qry : TQuery;
  {$ELSE !APPSRV}
  AdoQryL : AdoQry;
  {$ENDIF !APPSRV}

  function GetSql : string;
  begin
    Result := Format('SELECT R_CODEIBAN FROM RIB WHERE R_AUXILIAIRE = %s%s%s AND R_PRINCIPAL = %sX%s', [GetStringSeparator, Auxiliary, GetStringSeparator, GetStringSeparator, GetStringSeparator]);
  end;

begin
  Result := '';
  if Auxiliary <> '' then
  begin
    {$IFNDEF APPSRV}
    Qry := OpenSQL(GetSql, true);
    try
      Result := Qry.Fields[0].AsString;
    finally
      Ferme(Qry);
    end;
    {$ELSE !APPSRV}
    AdoQryL := AdoQry.Create;
    try
      AdoQryL.ServerName := ServerName;
      AdoQryL.DBName     := DBName;
      AdoQryL.Qry        := TADOQuery.Create(nil);
      AdoQryL.FieldsList := 'R_CODEIBAN';
      AdoQryL.Request    := GetSql;
      AdoQryL.SingleTableSelect;
      if AdoQryL.RecordCount = 1 then
        Result := AdoQryL.TSLResult[0];
    finally
      AdoQryL.Qry.Free;
      AdoQryL.free;
    end;
    {$ENDIF !APPSRV}
  end;
end;

class function Tools.GetStringSeparator : string;
begin
  {$IFDEF APPSRV}
  Result := '''';
  {$ELSE APPSRV}
  Result := '"';
  {$ENDIF APPSRV}
end;

{$IFNDEF APPSRV}
class function Tools.TobPutValue(TobData : TOB; FieldName : string; lValue : variant) : boolean;
var
  MCD       : IMCDServiceCOM;
  FieldType : tTypeField;
begin
  Result := True;
  if FieldName <> '' then
  begin
    if TobData.GetNumChamp(FieldName) < 1000 then
    begin
      MCD := TMCD.GetMcd;
      if not MCD.loaded then MCD.WaitLoaded();
      FieldType := GetTypeFieldFromStringType(MCD.ChampToType(FieldName));
      case FieldType of
        ttfNumeric : TobData.SetDouble(FieldName  , Double(lValue));
        ttfInt     : TobData.SetInteger(FieldName , Integer(lValue));
        ttfMemo
        , ttfText
        , ttfCombo : TobData.SetString(FieldName  , String(lValue));
        ttfBoolean : TobData.SetBoolean(FieldName , (lValue = 'X'));
        ttfDate    : TobData.SetDateTime(FieldName, tDateTime(lValue));
      else
         TobData.PutValue(FieldName, lValue);
      end;
    end else
      TobData.PutValue(FieldName, lValue);
  end;
end;
{$ENDIF !APPSRV}

{$IFNDEF APPSRV}
class function Tools.TobGetValue(TobData : TOB; FieldName : string; lValue : variant) : Variant;
var
  MCD       : IMCDServiceCOM;
  FieldType : tTypeField;
begin
  Result := True;
  if FieldName <> '' then
  begin
    if TobData.GetNumChamp(FieldName) < 1000 then
    begin
      MCD := TMCD.GetMcd;
      if not MCD.loaded then MCD.WaitLoaded();
      FieldType := GetTypeFieldFromStringType(MCD.ChampToType(FieldName));
      case FieldType of
        ttfNumeric : Result := TobData.GetDouble(FieldName);
        ttfInt     : Result := TobData.GetInteger(FieldName);
        ttfMemo
        , ttfText
        , ttfCombo : Result := TobData.GetString(FieldName);
        ttfBoolean : Result := TobData.GetBoolean(FieldName);
        ttfDate    : Result := TobData.GetDateTime(FieldName);
      else
         Result := TobData.GetValue(FieldName);
      end;
    end else
      Result := TobData.GetValue(FieldName);
  end;
end;
{$ENDIF !APPSRV}

{$IFNDEF APPSRV}
class Procedure Tools.TobPutValueDetail(TobData : TOB; FieldName : String; lValue : Variant);
Var Indice : Integer;
    TOBLData : TOB;
Begin

  If Tobdata = nil then Exit;

  If Tobdata.Detail.count = 0 then exit;

  if FieldName <> '' then
  begin
    For indice := 0 to TobData.Detail.count - 1 do
    begin
      TOBLData := Tobdata.detail[Indice];
      If TOBLData.FieldExists(FieldName) then Tools.TobPutValue(TOBLData, FieldName, lValue);
    end;
  end;


end;
{$ENDIF !APPSRV}

class function Tools.GetIndexOnSortedTsl(TslData : TStringList; Value : string; iFrom, iLen : integer) : integer;
var
  Milieu   : integer;
  Min      : integer;
  Max      : longint;
  Trouve   : boolean;
  TslValue : string;
begin
  Result := -1;
  Trouve := False;
  Min    := 0;
  Max    := pred(TslData.count);
  while (Max >= Min) and (not Trouve) do
  begin
    Milieu   := (Max + Min)  div 2;
    TslValue := copy(TslData[Milieu], 1, pos('=', TslData[Milieu])-1);
    Trouve   := (Value = TslValue);
    if Trouve then
      Result := Milieu
    else                                                                                  
    begin
      if TslValue > Value then
        Max := Milieu - 1
      else
        Min := Milieu + 1;
    end;
  end ;
end;

class function Tools.GetComputerMoMemory(mType : tMemoryTyp) : integer;
var
  Memory : TMemoryStatus;
begin
  Memory.dwLength := SizeOf(Memory);
  GlobalMemoryStatus(Memory);
  case mType of
    tmtOctetsAvailable : Result := (Memory.dwAvailPhys);
    tmtOctetsTotal     : Result := (Memory.dwTotalPhys);
    tmtMoAvailable     : Result := (Memory.dwAvailPhys Div 1000000);
    tmtMoTotal         : Result := (Memory.dwTotalPhys Div 1000000);
  else
    Result := -1;
  end;
end;

{$IFNDEF APPSRV}
class function Tools.GetTableInf(tInf : tInfoTable; TableName : string) : integer;
var
  Sql         : string;
  Qry         : TQuery;
  FieldNumber : integer;
  Coeff       : integer;
begin
  Result := -1;
  if (TableName <> '') and (tInf <> titNone) then
  begin
    case tInf of
      titRecordsQty                         : FieldNumber := 0;
      titKbTotalSize    ,titMoTotalSize     : FieldNumber := 1;
      titKbUseSize      ,titMoUseSize       : FieldNumber := 2;
      titKbAvailableSize,titMoAvailableSize : FieldNumber := 3;
    else
      FieldNumber := -1;
    end;
    if FieldNumber > -1 then
    begin
      case tInf of
        titMoTotalSize
        , titMoUseSize
        , titMoAvailableSize : Coeff := 1024;
      else
        Coeff := 1;
      end;
      Sql := Format('SELECT p.rows                                        AS RecordsQty'
                  + '    , (SUM(a.total_pages) * 8)                       AS MoSize'
                  + '    , (SUM(a.used_pages) * 8)                        AS UseMoSize'
                  + '    , ((SUM(a.total_pages) - SUM(a.used_pages)) * 8) AS AvailableMoSize'
                  + ' FROM sys.tables t'
                  + '  INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id'
                  + '  INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id'
                  + '  INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id'
                  + '  LEFT OUTER JOIN sys.schemas s ON t.schema_id = s.schema_id'
                  + '  WHERE t.NAME="%s"'
                  + '  GROUP BY t.Name, s.Name, p.Rows'
                    , [TableName]);
      Qry := OpenSql(Sql, True);
      try
        if not Qry.EOF then
          Result := Round(Qry.Fields[FieldNumber].AsInteger/Coeff);
      finally
        Ferme(Qry);
      end;
    end;
  end;
end;
{$ENDIF APPSRV}

{$IFNDEF APPSRV}
class procedure Tools.DropStoredProcedure(SPName : string);
begin
  if (SPName <> '') and (ExisteSql(Format('SELECT 1 FROM [DBO].sysobjects where name = "%s"', [SPName]))) then
    ExecuteSQL(Format('DROP PROCEDURE DBO.%s', [SPName]));
end;
{$ENDIF APPSRV}

{$IFNDEF APPSRV}
class function Tools.GetRecordMaxSize(TableName : string; sType : tRecordMaxSize) : double;
var
  Sql   : string;
  Qry   : TQuery;
  Coeff : integer;
begin
  Result := 0;
  if TableName <> '' then
  begin
    case sType of
      trsOctets : Coeff := 1;
      trsMo     : Coeff := 1000000;
    end;
    Sql := Format('SELECT MaxSize'
                + ' FROM (SELECT SUM(C.max_length) AS MaxSize'
                + '       FROM sys.tables AS T'
                + '       JOIN sys.columns AS C ON T.object_id = C.object_id'
                + '       JOIN sys.types AS TY ON C.user_type_id = TY.user_type_id'
                + '       WHERE T.Name = "%s"'
                + '       GROUP BY T.name'
                + ') AS TMP (MaxSize)'
                , [TableName]);
    Qry := OpenSql(Sql, True);
    try

      if not Qry.EOF then
        Result := (Qry.Fields[0].AsInteger / Coeff);
    finally
      Ferme(Qry);
    end;
  end;
end;

class function Tools.GetTableSize(TableName: string): double;
var
  Sql   : string;
  Qry   : TQuery;
  REs : string;
begin
  Result := 0;
  if TableName <> '' then
  begin
    Sql := Format('EXEC sp_spaceused "%s"', [TableName]);
    Qry := OpenSql(Sql, True);
    try
      if not Qry.EOF then
      begin
        Res := Qry.Fields[3].AsString;
        REs := StringReplace (REs,' KB','',[rfReplaceAll]);
        Result := StrToFloat(Res)/1024;
      end;
    finally
      Ferme(Qry);
    end;
  end;
end;
{$ENDIF APPSRV}

end.
