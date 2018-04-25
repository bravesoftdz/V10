unit BRGDPDUtils;

interface

uses
  wCommuns
  ;

Type
  T_RGPDPopulation = (rgpdpNone, rgpdpThird, rgpdpUser, rgpdpResource);
  T_RGPDActions = (rgpdaNone, rgpdaDataExport, rgpdaAnonymization, rgdpaDataRectification, rgdpaConsentRequest);

  RGPDUtils = Class
    class function GetActionFromCode(Code : string) : T_RGPDActions;
    class function GetCodeFromAction(Action : T_RGPDActions) : string;
    class function GetLabelFromAction(Action : T_RGPDActions) : string;
    class function GetPopulationFromCode(Code : string) : T_RGPDPopulation;
    class function GetCodeFromPopulation(Population : T_RGPDPopulation) : string;
    class function GetLabelFromPopulation(Population : T_RGPDPopulation) : string;
    class function GetLabelFromPopulationM(Population : T_RGPDPopulation) : string;
    class function GetTableNameFromPopulation(Population : T_RGPDPopulation) : string;
    class function CanAddDelFieldInRepository : Boolean;
    class function GetSqlTablesException : string;
    class function CanAnonymizableField(TableName, FieldName : string) : boolean;

  end;

Const
  RGPDThird    = 'THI';
  RGPDUser     = 'USR';
  RGPDResource = 'RES';
  RGPDCodeJnal = 'RGP';

implementation

Uses
  HEnt1
  , ParamSoc
  ;

{ RGPDUtils }

class function RGPDUtils.GetActionFromCode(Code: string): T_RGPDActions;
begin
  case CaseFromString(Code, ['EXP', 'ANO', 'REC', 'CON']) of
    {EXP} 0 : Result := rgpdaDataExport;
    {ANO} 1 : Result := rgpdaAnonymization;
    {REC} 2 : Result := rgdpaDataRectification;
    {CON} 3 : Result := rgdpaConsentRequest;
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
  else
    Result := '';
  end;
end;

class function RGPDUtils.GetPopulationFromCode( Code: string): T_RGPDPopulation;
begin
  case CaseFromString(Code, [RGPDThird, RGPDUser, RGPDResource]) of
    {THI} 0 : Result := rgpdpThird;
    {USE} 1 : Result := rgpdpUser;
    {RES} 2 : Result := rgpdpResource
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
  else ;
    Result := '';
  end;
end;

class function RGPDUtils.CanAddDelFieldInRepository : Boolean;
begin
  Result := True;
end;

class function RGPDUtils.GetSqlTablesException : string;
begin
  if (not RGPDUtils.CanAddDelFieldInRepository) then
  begin
    Result := ' AND RG2_NOMTABLE NOT IN ("TIERSCOMPL", "PROSPECTS"';
    if GetParamSocSecur('SO_RTGESTINFOS006', False) then
      Result := Result + ', "RTINFOS006"';
    Result := Result + ')';
  end else
    Result := '';
end;

class function RGPDUtils.CanAnonymizableField(TableName, FieldName : string) : boolean;
begin
  case CaseFromString(TableName, ['TIERS', 'RESSOURCE', 'UTILISAT', 'ADRESSES', 'CONTACT', 'RIB', 'TIERSCOMPL', 'PROSPECTS', 'RTINFOS006']) of
    {TIERS}      0 : Result := Pos(';' + FieldName + ';', ';T_AUXILIAIRE;T_TIERS;T_NATUREAUXI;') = 0;
    {RESSOURCE}  1 : Result := Pos(';' + FieldName + ';', ';ARS_RESSOURCE;ARS_AUXILIAIRE;ARS_TYPERESSOURCE;') = 0;
    {UTILISAT}   2 : Result := Pos(';' + FieldName + ';', ';US_UTILISATEUR;') = 0;
    {ADRESSES}   3 : Result := Pos(';' + FieldName + ';', ';ADR_TYPEADRESSE;ADR_NUMEROADRESSE;ADR_NATUREAUXI;ADR_REFCODE;') = 0;
    {CONTACT}    4 : Result := Pos(';' + FieldName + ';', ';C_TYPECONTACT;C_AUXILIAIRE;C_NUMEROCONTACT;C_TIERS;C_PRINCIPAL;C_TYPECONTACT') = 0;
    {RIB}        5 : Result := Pos(';' + FieldName + ';', ';R_AUXILIAIRE;R_NUMERORIB;R_PRINCIPAL;') = 0;
    {TIERSCOMPL} 6 : Result := Pos(';' + FieldName + ';', ';YTC_AUXILIAIRE;YTC_TIERS;YTC_TIERSLIVRE;') = 0;
    {PROSPECTS}  7 : Result := Pos(';' + FieldName + ';', ';RPR_AUXILIAIRE;') = 0;
    {RTINFOS006} 8 : Result := Pos(';' + FieldName + ';', ';RD6_CLEDATA;') = 0;
  else
    Result := True;
  end;
end;


end.
