unit FormsName;

Interface

uses
  Hent1
  , BRGDPDUtils
  ;

const
  frm_RGPDRepository  = 'BRGPDREFERENTIEL';
  frm_RGPDThirdMul    = 'BRGPDTIERSMUL';
  frm_RGPDTrtValid    = 'BRGPDVALIDTRT';
  frm_RGPDResourceMul = 'BRGPDRESSOURCEMUL';
  frm_RGPDUtilisatMul = 'BRGPDUTILISATMUL';
  frm_RGPDSuspectMul  = 'BRGPDSUSPECTMUL';
  frm_RGPDSensibilization = 'BRGPDSENSIBILISAT';
  frm_ThirdCliPro     = 'GCTIERS';
  frm_Resource        = 'BTRESSOURCE';
  frm_Utilisat        = 'YYUTILISAT';
  frm_Suspect         = 'RTSUSPECTS';
  frm_JnalEvent       = 'YYJNALEVENT';

type
  OpenForm = class
    private
      class function SetArgument(Argument : string) : string;

    public
      class function SetWindowCaption(ParentNumber, TagNumber : integer; Action : T_RGPDActions=rgpdaNone; Population : T_RGPDPopulation=rgpdpNone) : string;
      class function CliPro(Auxiliary, ThirdType : string; Argument : string='') : string;
      class function Resource(ResourceCode, ResourceType : string; Argument : string='') : string;
      class function User(UserCode : string) : string;
      class function Suspect(SuspectCode : string) : string;
      class function JnalEvent(Params : string='') : string;
      class function RGPDSensibilisation : string;
      class function RGPDWindows(Population : T_RGPDPopulation; TagMother, TagNumber : integer; Action : T_RGPDActions) : string;
    end;

implementation

uses
  UFonctionsCBP
  , BTPUtil
  , Fe_Main
  , uTOFComm
  , ConfidentAffaire
  , HCtrls
  , SysUtils
  , wCommuns
  , BRGPDTIERSMUL_TOF
  , BRGPDRESSOURCEMUL_TOF
  , BRGPDUTILISATMUL_TOF
  , BRGPDSUSPECTMUL_TOF
  , uDbxDataSet
  ;

class function OpenForm.SetArgument(Argument: string): string;
begin
  if (Argument <> '') and (Copy(Argument, 1, 1) <> ';') then
    Result := ';' + Argument
  else
    Result := Argument;
end;

class function OpenForm.SetWindowCaption(ParentNumber, TagNumber : integer; Action : T_RGPDActions=rgpdaNone; Population : T_RGPDPopulation=rgpdpNone) : string;
var
  Sql : string;
  Qry : TQuery;
  IsConsent : boolean;
  Num       : Integer;
begin
  IsConsent := ((Action = rgdpaConsentRequest) or (Action = rgdpaConsentResponse));
  Num := 0;
  Sql := 'SELECT MN_LIBELLE FROM MENU WHERE MN_TAG IN(' + IntToStr(ParentNumber) + ', ' + IntToStr(TagNumber) + ')';
  Qry := OpenSQL(Sql, True);
  try
    while not Qry.Eof do
    begin
      Inc(Num);
      Result := Result + ' - ' + Qry.Fields[0].AsString;
      if (IsConsent) and (Num > 1) then
        Result := Result + ' ' + RGPDUtils.GetLabelFromPopulation(Population);
      Qry.Next;
    end;
  finally
    Ferme(Qry);
  end;
  Result := Copy(Result, 4, Length(Result));
  Result := 'WINDOWCAPTION=' + Result;
end;

class function OpenForm.CliPro(Auxiliary, ThirdType : string; Argument : string='') : string;
var
  stAction : string;
begin
  if (Auxiliary <> '') and (ThirdType <> '') then
  begin
    stAction := 'ACTION=MODIFICATION;';
    if ThirdType = 'PRO' then
    begin
      if not ExJaiLeDroitConcept(TConcept(bt510),False) then
        stAction:= 'ACTION=CONSULTATION;';
    end else
      if not ExJaiLeDroitConcept(TConcept(bt511),False) then
        stAction:= 'ACTION=CONSULTATION;';
    SetArgument(Argument);
    Result := AGLLanceFiche('GC', frm_ThirdCliPro, '', Auxiliary, stAction + 'MONOFICHE;T_NATUREAUXI=' + ThirdType + Argument);
  end else
    Result := '';
end;

class function OpenForm.Resource(ResourceCode, ResourceType : string; Argument : string='') : string;
var
  stArg : string;
begin
  if ResourceCode <> '' then
  begin
    stArg := 'ACTION=MODIFICATION;';
    if AGLJaiLeDroitFiche(['RESSOURCE', StArg], 2) then
    begin
      stArg := SetArgument(Argument);
      Result := AGLLanceFiche('BTP', frm_Resource, '', ResourceCode, 'TYPERESSOURCE=' + ResourceType + stArg);
    end else
      Result := '';
  end else
    Result := '';
end;

class function OpenForm.User(UserCode: string): string;
begin
  if (UserCode <> '') and (JaiLeDroitTag(60202)) then
    Result := AGLLanceFiche('YY', frm_Utilisat, '', UserCode, 'ACTION=MODIFICATION');
end;

class function OpenForm.Suspect(SuspectCode: string): string;
begin
  if (SuspectCode <> '') and (JaiLeDroitTag(92106)) then
    Result := AGLLanceFiche('RT', frm_Suspect, '', SuspectCode, 'MONOFICHE;ACTION=MODIFICATION');
end;

class function OpenForm.JnalEvent(Params : string): string;
begin
  Result := AGLLanceFiche('YY', frm_JnalEvent, '', '', Params);
end;

class function OpenForm.RGPDSensibilisation : string;
begin
  V_PGI.ZoomOle := True;
  Result := AGLLanceFiche('BTP', frm_RGPDSensibilization, '', '', '');
  V_PGI.ZoomOle := False;

end;

class function OpenForm.RGPDWindows(Population: T_RGPDPopulation; TagMother, TagNumber: integer; Action: T_RGPDActions): string;
begin
  case Population of
    rgpdpThird    : BLanceFiche_RGPDThirdMul   ('BTP', frm_RGPDThirdMul   , '', '', OpenForm.SetWindowCaption(TagMother, TagNumber, Action, Population)+ ';ACTION=' + RGPDUtils.GetCodeFromAction(Action));
    rgpdpResource : BLanceFiche_RGPDResourceMul('BTP', frm_RGPDResourceMul, '', '', OpenForm.SetWindowCaption(TagMother, TagNumber, Action, Population)+ ';ACTION=' + RGPDUtils.GetCodeFromAction(Action));
    rgpdpUser     : BLanceFiche_RGPDUtilisatMul('BTP', frm_RGPDUtilisatMul, '', '', OpenForm.SetWindowCaption(TagMother, TagNumber, Action, Population)+ ';ACTION=' + RGPDUtils.GetCodeFromAction(Action));
    rgpdpSuspect  : BLanceFiche_RGPDSuspectMul ('BTP', frm_RGPDSuspectMul , '', '', OpenForm.SetWindowCaption(TagMother, TagNumber, Action, Population)+ ';ACTION=' + RGPDUtils.GetCodeFromAction(Action));
  end;
end;

end.
