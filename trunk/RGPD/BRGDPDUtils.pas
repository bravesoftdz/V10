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

  end;

Const
  RGPDThird    = 'THI';
  RGPDUser     = 'USR';
  RGPDResource = 'RES';
  RGPDCodeJnal = 'RGP';

implementation

Uses
  HEnt1
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

end.
