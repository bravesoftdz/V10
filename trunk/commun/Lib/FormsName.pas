unit FormsName;

Interface

const
  frm_RGPDRepository  = 'BRGPDREFERENTIEL';
  frm_RGPDThirdMul    = 'BRGPDTIERSMUL';
  frm_RGPDTrtValid    = 'BRGPDVALIDTRT';
  frm_RGPDResourceMul = 'BRGPDRESSOURCEMUL';
  frm_RGPDUtilisatMul = 'BRGPDUTILISATMUL';
  frm_ThirdCliPro     = 'GCTIERS';
  frm_Resource        = 'BTRESSOURCE';
  frm_Utilisat        = 'YYUTILISAT';

type
  OpenForm = class
    private
      class function SetArgument(Argument : string) : string;

    public
      class function CliPro(Auxiliary, ThirdType : string; Argument : string='') : string;
      class function Resource(ResourceCode, ResourceType : string; Argument : string='') : string;
      class function User(UserCode : string) : string;
    end;

implementation

uses
  UFonctionsCBP
  , BTPUtil
  , Fe_Main
  , uTOFComm
  , HEnt1
  , ConfidentAffaire
  , HCtrls
  ;

class function OpenForm.SetArgument(Argument: string): string;
begin
  if (Argument <> '') and (Copy(Argument, 1, 1) <> ';') then
    Result := ';' + Argument
  else
    Result := Argument;
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

end.
