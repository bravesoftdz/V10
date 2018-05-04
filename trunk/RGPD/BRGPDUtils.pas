unit BRGPDUtils;

interface

uses  
  wCommuns
  ;

Type
  T_RGPDPopulation = (rgpdpNone, rgpdpThird, rgpdpUser, rgpdpResource, rgpdpSuspect, rgpdpContact);
  T_RGPDActions = (rgpdaNone, rgpdaDataExport, rgpdaAnonymization, rgdpaDataRectification, rgdpaConsentRequest, rgdpaConsentResponse);
  T_RGPDTypePath = (rgpdtIncomingRequest, rgpdtTemplateConsent, rgpdtGenerationConsent);

  RGPDUtils = Class
    class function GetActionFromCode(Code : string) : T_RGPDActions;
    class function GetCodeFromAction(Action : T_RGPDActions) : string;
    class function GetLabelFromAction(Action : T_RGPDActions) : string;
    class function GetPopulationFromCode(Code : string) : T_RGPDPopulation;
    class function GetCodeFromPopulation(Population : T_RGPDPopulation) : string;
    class function GetLabelFromPopulation(Population : T_RGPDPopulation) : string;
    class function GetLabelFromPopulationM(Population : T_RGPDPopulation) : string;
    class function AdvancedSettingsEnabled : Boolean;
    class function GetTableNameFromPopulation(Population : T_RGPDPopulation) : string;
    class function GetSqlTablesException : string;
    class function CanAnonymizableField(TableName, FieldName : string) : boolean;
    class function GetPath(PathType : T_RGPDTypePath) : string;
  end;

Const
  RGPDThird    = 'THI';
  RGPDUser     = 'USR';
  RGPDResource = 'RES';
  RGPDSuspect  = 'SUS';
  RGPDContact  = 'CON';
  RGPDCodeJnal = 'RGP';

implementation

Uses
  HEnt1
  , ParamSoc
  , SysUtils
  , HCtrls
  {$IFNDEF DBXPRESS}
  , dbTables
  {$ELSE}
  , uDbxDataSet
  {$ENDIF}
  ;

{ RGPDUtils }

class function RGPDUtils.GetActionFromCode(Code: string): T_RGPDActions;
begin
  case CaseFromString(Code, ['EXP', 'ANO', 'REC', 'CON', 'RET']) of
    {EXP} 0 : Result := rgpdaDataExport;
    {ANO} 1 : Result := rgpdaAnonymization;
    {REC} 2 : Result := rgdpaDataRectification;
    {CON} 3 : Result := rgdpaConsentRequest;
    {RET} 4 : Result := rgdpaConsentResponse;
  else
    Result := rgpdaNone;
  end;
end;

class function RGPDUtils.GetCodeFromAction(Action: T_RGPDActions): string;
begin
  case Action of
    rgpdaDataExport        : Result := 'EXP';
    rgpdaAnonymization     : Result := 'ANO';
    rgdpaDataRectification : Result := 'REC';
    rgdpaConsentRequest    : Result := 'CON';
    rgdpaConsentResponse   : Result := 'RET';
  else
    Result := '';
  end;
end;

class function RGPDUtils.GetLabelFromAction(Action : T_RGPDActions) : string;
begin
  case Action of
    rgpdaDataExport        : Result := TraduireMemoire('Export des données personnelles');
    rgpdaAnonymization     : Result := TraduireMemoire('Droit à l''oubli');
    rgdpaDataRectification : Result := TraduireMemoire('Rectification des données');
    rgdpaConsentRequest    : Result := TraduireMemoire('Demande de consentement');
    rgdpaConsentResponse   : Result := TraduireMemoire('Réponse de demande de consentement');
  else
    Result := '';
  end;
end;

class function RGPDUtils.GetCodeFromPopulation(Population: T_RGPDPopulation): string;
begin
  case Population of
    rgpdpThird    : Result := RGPDThird;
    rgpdpUser     : Result := RGPDUser;
    rgpdpResource : Result := RGPDResource;
    rgpdpSuspect  : Result := RGPDSuspect;
    rgpdpContact  : Result := RGPDContact;
  else
    Result := '';
  end;
end;

class function RGPDUtils.GetPopulationFromCode( Code: string): T_RGPDPopulation;
begin
  case CaseFromString(Code, [RGPDThird, RGPDUser, RGPDResource, RGPDSuspect, rgpdContact]) of
    {THI} 0 : Result := rgpdpThird;
    {USE} 1 : Result := rgpdpUser;
    {RES} 2 : Result := rgpdpResource;
    {SUS} 3 : Result := rgpdpSuspect;
    {CON} 4 : Result := rgpdpContact;
  else
    Result := rgpdpNone;
  end;
end;

class function RGPDUtils.GetLabelFromPopulation(Population: T_RGPDPopulation): string;
begin
  case Population of
    rgpdpThird    : Result := TraduireMemoire('Client');
    rgpdpUser     : Result := TraduireMemoire('Utilisateur');
    rgpdpResource : Result := TraduireMemoire('Ressource');
    rgpdpSuspect  : Result := TraduireMemoire('Suspect');
    rgpdpContact  : Result := TraduireMemoire('Contact');
  else ;
    Result := '';
  end;
end;

class function RGPDUtils.GetLabelFromPopulationM(Population: T_RGPDPopulation): string;
begin
  case Population of
    rgpdpThird    : Result := TraduireMemoire('client(s)');
    rgpdpUser     : Result := TraduireMemoire('utilisateur(s)');
    rgpdpResource : Result := TraduireMemoire('ressource(s)');
    rgpdpSuspect  : Result := TraduireMemoire('suspect(s)');
    rgpdpContact  : Result := TraduireMemoire('contact(s)');
  else ;
    Result := '';
  end;
end;

class function RGPDUtils.GetTableNameFromPopulation(Population : T_RGPDPopulation) : string;
begin
  case Population of
    rgpdpThird    : Result := 'TIERS';
    rgpdpUser     : Result := 'UTILISAT';
    rgpdpResource : Result := 'RESSOURCE';
    rgpdpSuspect  : Result := 'SUSPECTS';
    rgpdpContact  : Result := 'CONTACT';
  else ;
    Result := '';
  end;
end;

class function RGPDUtils.AdvancedSettingsEnabled : Boolean;
begin
  Result := GetParamSocSecur('SO_RGPDPARAMAVANCE', False);
end;

class function RGPDUtils.GetSqlTablesException : string;
var
  TablesName : string;
begin
  if (not RGPDUtils.AdvancedSettingsEnabled) then
    TablesName := ', "TIERSCOMPL", "PROSPECTS", "RTINFOS006", "SUSPECTSCOMPL"'
  else
  begin
    if not GetParamSocSecur('SO_RTGESTINFOS006', False) then
      TablesName := TablesName + '", RTINFOS006"';
    if not GetParamSocSecur('SO_RTPARAMAVANCES', False) then
      TablesName := TablesName + '", SUSPECTSCOMPL"';
  end;
  if TablesName <> '' then
  begin
    TablesName := Copy(TablesName, 2, Length(TablesName));
    Result := ' AND RG2_NOMTABLE NOT IN (' + TablesName + ')'
  end else
    Result := '';
end;

class function RGPDUtils.CanAnonymizableField(TableName, FieldName : string) : boolean;
begin
  case CaseFromString(TableName, ['TIERS', 'RESSOURCE', 'UTILISAT', 'ADRESSES', 'CONTACT', 'RIB', 'TIERSCOMPL', 'PROSPECTS', 'RTINFOS006', 'SUSPECTS', 'SUSPECTSCOMPL']) of
    {TIERS}         0  : Result := Pos(';' + FieldName + ';', ';T_AUXILIAIRE;T_TIERS;T_COLLECTIF;T_NATUREAUXI;') = 0;
    {RESSOURCE}     1  : Result := Pos(';' + FieldName + ';', ';ARS_RESSOURCE;ARS_AUXILIAIRE;ARS_TYPERESSOURCE;') = 0;
    {UTILISAT}      2  : Result := Pos(';' + FieldName + ';', ';US_UTILISATEUR;') = 0;
    {ADRESSES}      3  : Result := Pos(';' + FieldName + ';', ';ADR_TYPEADRESSE;ADR_NUMEROADRESSE;ADR_NATUREAUXI;ADR_REFCODE;') = 0;
    {CONTACT}       4  : Result := Pos(';' + FieldName + ';', ';C_TYPECONTACT;C_AUXILIAIRE;C_NUMEROCONTACT;C_TIERS;C_PRINCIPAL;C_TYPECONTACT;') = 0;
    {RIB}           5  : Result := Pos(';' + FieldName + ';', ';R_AUXILIAIRE;R_NUMERORIB;R_PRINCIPAL;') = 0;
    {TIERSCOMPL}    6  : Result := Pos(';' + FieldName + ';', ';YTC_AUXILIAIRE;YTC_TIERS;YTC_TIERSLIVRE;') = 0;
    {PROSPECTS}     7  : Result := Pos(';' + FieldName + ';', ';RPR_AUXILIAIRE;') = 0;
    {RTINFOS006}    8  : Result := Pos(';' + FieldName + ';', ';RD6_CLEDATA;') = 0;
    {SUSPECTS}      9  : Result := Pos(';' + FieldName + ';', ';RSU_SUSPECT;') = 0;
    {SUSPECTSCOMPL} 10 : Result := Pos(';' + FieldName + ';', ';RSC_SUSPECT;') = 0;
  else
    Result := True;
  end;
end;

class function RGPDUtils.GetPath(PathType : T_RGPDTypePath) : string;
begin
  case PathType of
    rgpdtIncomingRequest   : Result := IncludeTrailingBackslash(GetParamSocSecur('SO_RGPDCHEMINDEMANDES',''));
    rgpdtTemplateConsent   : Result := IncludeTrailingBackslash(GetParamSocSecur('SO_RGPDCHEMINMODELECONS',''));
    rgpdtGenerationConsent : Result := IncludeTrailingBackslash(GetParamSocSecur('SO_RGPDCHEMINCONSENT',''));
  else ;
    Result := '';
  end;
end;

end.
