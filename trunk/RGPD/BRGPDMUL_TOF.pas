{***********UNITE*************************************************
Auteur  ...... : 
Créé le ...... : 18/04/2018
Modifié le ... :   /  /
Description .. : Source TOF de la FICHE : BRGPDREFERENTIEL ()
Mots clefs ... : TOF;BRGPDREFERENTIEL
*****************************************************************}
unit BRGPDMUL_TOF;

interface

uses
  StdCtrls
  , Controls
  , Classes
  , mul
  {$IFNDEF EAGLCLIENT}
  , db
  , uDbxDataSet
  , FE_Main
  {$ENDIF EAGLCLIENT}
  , uTob
  , forms
  , sysutils
  , ComCtrls
  , HCtrls
  , HEnt1
  , HMsgBox
  , UTOF
  , CBPMcd
  , Htb97
  , uTOFComm
  , BRGDPDUtils
  , HDB
  ;

function BLanceFiche_RGPDThirdMul(Nat, Cod, Range, Lequel, Argument: string): string;

type
  TOF_BRGPDMUL = class(tTOFComm)
  private
    bOuvrir    : TToolbarButton97;
    Action     : T_RGPDActions;
    Population : T_RGPDPopulation;
    FListe     : THDBGrid;
    PathFile   : string;
    TobRG2     : TOB;
    TobRG3     : TOB;

    procedure bOuvrir_OnClick(Sender: TObject);
    procedure FListe_OnDblClick(Sender : TObject);
    procedure LoadTobRG2;
    procedure LoadTobRG3;
    function GetWhereTablesL(Where, FieldName: string): string;
    function GetSelectedFieldsFromTable(TableName: string): string;
    procedure InsertJnal;
    procedure ExportDatas;
    procedure Anonymization;
    procedure Rectification;

  public
    sPopulationCode : string;
    sFieldCode      : string;
    sFieldCode2nd   : string;
    sFieldLabel     : string;
    sFieldLabel2nd  : string;

    procedure OnNew; override;
    procedure OnDelete; override;
    procedure OnUpdate; override;
    procedure OnLoad; override;
    procedure OnArgument(S: string); override;
    procedure OnDisplay; override;
    procedure OnClose; override;
    procedure OnCancel; override;
  end;

implementation

uses
  TntStdCtrls
  , wCommuns
  , UtilPGI
  , BRGPDVALIDTRT_TOF
  , FormsName
  , Windows
  , ShellAPI
  , UtilGC;

function BLanceFiche_RGPDThirdMul(Nat, Cod, Range, Lequel, Argument: string): string;
begin
  Result := AglLanceFiche(Nat, Cod, Range, Lequel, Argument);
end;

procedure TOF_BRGPDMUL.OnNew;
begin
  inherited;
end;

procedure TOF_BRGPDMUL.OnDelete;
begin
  inherited;
end;

procedure TOF_BRGPDMUL.OnUpdate;
begin
  inherited;
end;

procedure TOF_BRGPDMUL.OnLoad;
begin
  inherited;
end;

procedure TOF_BRGPDMUL.OnArgument(S: string);
begin
  inherited;
  fMulDeTraitement := True;
  TobRG2 := TOB.Create('BRGPDTABLESL', nil, -1);
  TobRG3 := TOB.Create('BRGPDTABLESL', nil, -1);
  Action := RGPDUtils.GetActionFromCode(GetArgumentString(S, 'ACTION'));
  Population := RGPDUtils.GetPopulationFromCode(sPopulationCode);
  FListe     := THDBGrid(GetControl('FListe'));
  bOuvrir    := TToolbarButton97(GetControl('BOUVRIR'));
  bOuvrir.OnClick       := bOuvrir_OnClick;
  FListe.MultiSelection := (Action = rgdpaConsentRequest);
  FListe.OnDblClick     := FListe_OnDblClick;
end;

procedure TOF_BRGPDMUL.OnClose;
begin
  inherited;
  FreeAndNil(TobRG2);
  FreeAndNil(TobRG3);
end;

procedure TOF_BRGPDMUL.OnDisplay();
begin
  inherited;
end;

procedure TOF_BRGPDMUL.OnCancel();
begin
  inherited;
end;

procedure TOF_BRGPDMUL.bOuvrir_OnClick(Sender: TObject);
var
  LastParam   : string;
  Params      : string;
  CanContinue : boolean;
begin
  if    (Action = rgdpaDataRectification)
     or ((Action <> rgdpaDataRectification) and (PGIAsk('Veuillez confirmer le traitement.', Ecran.Caption) = mrYes))
  then
  begin
    if Action <> rgdpaConsentRequest then
    begin
      CanContinue := True;
      LastParam   := ';QUI=' + GetString(sFieldCode) + '~' + GetString(sFieldLabel) + '~' + GetString(sFieldLabel2nd)
    end
    else
    begin
      CanContinue := (TFMul(Ecran).FListe.nbSelected > 0);
      LastParam   := ';QTE=' + IntToStr(TFMul(Ecran).FListe.nbSelected);
    end;
    if CanContinue then
    begin
      Params := 'ORIGINE=' + RGPDUtils.GetCodeFromPopulation(Population) + ';ACTION=' + RGPDUtils.GetCodeFromAction(Action) + LastParam;
      PathFile := BLanceFiche_RGPDValidTrt('BTP', frm_RGPDTrtValid, '', '', Params);
      if ReadTokenSt(PathFile) = 'OK' then
      begin
        case Action of
          rgpdaDataExport        : ExportDatas;
          rgpdaAnonymization     : Anonymization;
          rgdpaDataRectification : Rectification;
          rgdpaConsentRequest    : ;
        end;
      end;
    end
    else
      PGIError(TraduireMemoire('Veuillez effectuer une sélection.'), Ecran.Caption);
  end;
end;

procedure TOF_BRGPDMUL.FListe_OnDblClick(Sender : TObject);
begin
  bOuvrir_OnClick(Self);
end;
  
procedure TOF_BRGPDMUL.LoadTobRG2;
var
  Sql: string;
begin
  TobRG2.ClearDetail;
  Sql := 'SELECT RG1_TABLENAME'
       + '     , RG1_KEY'
       + '     , BRGPDTABLESL.*'
       + ' FROM BRGPDTABLESP'
       + ' LEFT JOIN BRGPDTABLESL ON RG2_IDRG1 = RG1_ID' + RGPDUtils.GetSqlTablesException
       + ' WHERE RG1_TABLENAME = "' + RGPDUtils.GetTableNameFromPopulation(Population) + '"';
  TobRG2.LoadDetailFromSQL(Sql);
end;

procedure TOF_BRGPDMUL.LoadTobRG3;
var
  Sql: string;

  function GetWhere: string;
  begin
    Result := ' WHERE RG1_TABLENAME = "' + RGPDUtils.GetTableNameFromPopulation(Population) + '"';
    case Action of
      rgpdaDataExport:
        Result := Result + ' AND RG3_EXPORT = "X"';
      rgpdaAnonymization:
        Result := Result + ' AND RG3_RESET  = "X"';
    end;
  end;

begin
  TobRG3.ClearDetail;
  Sql := 'SELECT 1 AS SORT, BRGPDCHAMPS.*, DH_LIBELLE' + ' FROM BRGPDTABLESP' + ' JOIN BRGPDCHAMPS ON RG3_TABLENAME = RG1_TABLENAME' + ' JOIN DECHAMPS    ON DH_NOMCHAMP   = RG3_FIELDNAME' + GetWhere + 'UNION ' + 'SELECT 2 AS SORT, BRGPDCHAMPS.*, DH_LIBELLE' + ' FROM BRGPDTABLESP' + ' JOIN BRGPDTABLESL ON RG2_IDRG1     = RG1_ID' + ' JOIN BRGPDCHAMPS  ON RG3_TABLENAME = RG2_NOMTABLE' + ' JOIN DECHAMPS     ON DH_NOMCHAMP   = RG3_FIELDNAME' + GetWhere;
  Sql := Sql + ' ORDER BY SORT, RG3_TABLENAME, RG3_FIELDNAME';
  TobRG3.LoadDetailFromSQL(Sql);
end;

function TOF_BRGPDMUL.GetWhereTablesL(Where, FieldName: string): string;
var
  Value: string;
  ValueLength: Integer;
begin
  Value := '|' + FieldName + '|';
  if Pos(Value, Where) > 0 then
  begin
    Result := Where;
    while Pos(Value, Result) > 0 do
    begin
      ValueLength := length(Value);
      Result := Copy(Result, 1, Pos(Value, Result) - 1) + GetString(FieldName) + Copy(Result, Pos(Value, Result) + ValueLength, Length(Result));
    end;
//    ValueLength := length(Value);
//    Result := Copy(Where, 1, Pos(Value, Where) - 1) + GetString(FieldName) + Copy(Where, Pos(Value, Where) + ValueLength, Length(Where));
  end
  else
    Result := '';
end;

function TOF_BRGPDMUL.GetSelectedFieldsFromTable(TableName: string): string;
var
  TobRG3L: TOB;
begin
  TobRG3L := TobRG3.FindFirst(['RG3_TABLENAME'], [TableName], True);
  while assigned(TobRG3L) do
  begin
    Result := Result + ',' + TobRG3L.GetString('RG3_FIELDNAME');
    TobRG3L := TobRG3.FindNext(['RG3_TABLENAME'], [TableName], True);
  end;
  Result := copy(Result, 2, length(Result));
end;

procedure TOF_BRGPDMUL.InsertJnal;
var
  InfoJnal : string;
begin
  InfoJnal := RGPDUtils.GetLabelFromPopulation(Population)
            + ' '
            + GetString(sFieldCode)
            + iif(GetString(sFieldCode2nd)  <> '', ' - ' + GetString(sFieldCode2nd), '')
            + iif(GetString(sFieldLabel)    <> '', ' - ' + GetString(sFieldLabel), '')
            + iif(GetString(sFieldLabel2nd) <> '', ' ' + GetString(sFieldLabel2nd), '')
            ;
  MAJJnalEvent(RGPDCodeJnal, 'OK', RGPDUtils.GetLabelFromAction(Action), InfoJnal, PathFile);
end;

procedure TOF_BRGPDMUL.ExportDatas;
var
  TobRG2L    : TOB;
  TobResult  : TOB;
  TobResultL : TOB;
  Cpt        : integer;
  Where      : string;
  TempPath   : string;
  tsFile     : TStringList;

  procedure AddTableValue(TableName, Where: string);
  var
    Sql        : string;
    FieldName  : string;
    FieldLabel : string;
    FieldsList : string;
    TobData    : TOB;
    CptData    : integer;
    CptFields  : integer;
  begin
    if (TableName <> '') and (Where <> '') then
    begin
      TobData := TOB.Create('_DATA', nil, -1);
      try
        FieldsList := GetSelectedFieldsFromTable(TableName);
        if FieldsList <> '' then
        begin
          Sql := 'SELECT ' + FieldsList + ' FROM ' + TableName + ' ' + Where;
          TobData.LoadDetailFromSQL(Sql);
          for CptData := 0 to pred(TobData.Detail.count) do
          begin
            for CptFields := 0 to pred(TobData.Detail[CptData].NombreChampSup) do
            begin
              TobResultL := TOB.Create('_VALUE', TobResult, -1);
              FieldName := TobData.Detail[CptData].GetNomChamp(1000 + CptFields);
              FieldLabel := TobRG3.FindFirst(['RG3_FIELDNAME'], [FieldName], True).GetString('DH_LIBELLE');
              TobResultL.AddChampSupValeur('_VALUE', TableName + ';' + FieldName + ';' + FieldLabel + ';' + TobData.Detail[CptData].GetString(FieldName));
            end;
          end;
        end;
      finally
        FreeAndNil(TobData);
      end;
    end;
  end;

begin
  TobResult := TOB.Create('_RESULT', nil, -1);
  try
    LoadTobRG2;
    LoadTobRG3;
    { Chargement des données }
    for Cpt := 0 to pred(TobRG2.detail.count) do
    begin
      TobRG2L := TobRG2.Detail[Cpt];
      { 1ère ligne, il faut traiter la table principale }
      if Cpt = 0 then
      begin
        Where := TobRG2L.GetString('RG1_KEY') + ' = "' + GetString(sFieldCode) + '"';
        AddTableValue(TobRG2L.GetString('RG1_TABLENAME'), ' WHERE ' + Where);
      end;
      { Traiter la table liée courante }
      Where := GetWhereTablesL(TobRG2L.GetString('RG2_FILTRE'), sFieldCode);
      if Where = '' then
        Where := GetWhereTablesL(TobRG2L.GetString('RG2_FILTRE'), sFieldCode2nd);
      AddTableValue(TobRG2L.GetString('RG2_NOMTABLE'), ' WHERE ' + Where);
      Where := '';
    end;
    if TobResult.Detail.Count > 0 then
    begin
      TempPath := GetMyTempPath + GetString(sFieldCode) + '.CSV';
      tsFile := TStringList.Create;
      try
        tsFile.Add('TABLE;CHAMP;LIBELLE;VALEUR');
        for Cpt := 0 to pred(TobResult.Detail.Count) do
          tsFile.Add(TobResult.Detail[Cpt].GetString('_VALUE'));
        tsFile.SaveToFile(TempPath);
      finally
        FreeAndNil(tsFile);
      end;
      InsertJnal;
      ShellExecute(0, pchar('open'), pchar(TempPath), nil, nil, SW_SHOW);
    end;
  finally
    FreeAndNil(TobResult);
  end;
  TobRG2.ClearDetail;
  TobRG3.ClearDetail;
end;

procedure TOF_BRGPDMUL.Anonymization;
var
  TobResult : TOB;
  TobRG2L   : TOB;
  Cpt       : integer;
  Where     : string;
  MCD       : IMCDServiceCOM;

  procedure AddUpdate(TableName, Where: string);
  var
    TobResultL: TOB;
    Sql: string;
    FieldsList: string;
    FieldName: string;
    FieldValue: string;
  begin
    if (TableName <> '') and (Where <> '') then
    begin
      Sql        := '';
      FieldsList := GetSelectedFieldsFromTable(TableName);
      if FieldsList <> '' then
      begin
        if ExisteSQL('SELECT 1 FROM ' + TableName + Where) then
        begin
          while FieldsList <> '' do
          begin
            FieldName := ReadTokenPipe(FieldsList, ',');
            case GetFieldType(FieldName) of
              ttfText    : FieldValue := 'iif(' + FieldName +  ' <> "", ' + '"' + wStringRepeat('Z', GetFieldSize(FieldName)) + '", "")';
              ttfNumeric : FieldValue := 'iif(' + FieldName +  ' <> 0, ' + '"0", "")';
              ttfMemo    : FieldValue := '""';
              ttfDate    : FieldValue := '"' + DateToStr(iDate1900) + '"';
            end;
            Sql := Sql + ', ' + FieldName + ' = ' + FieldValue;
          end;
          Sql := copy(Sql, 3, Length(Sql));
          Sql := 'UPDATE ' + TableName + ' SET ' + Sql + Where;
          TobResultL := TOB.Create('_UPDATE', TobResult, -1);
          TobResultL.AddChampSupValeur('_UPDATE', Sql);
        end;
      end;
    end;
  end;

begin
  TobResult := TOB.Create('_RESULT', nil, -1);
  try
    MCD := TMCD.GetMcd;
    if not MCD.loaded then
      MCD.WaitLoaded();
    LoadTobRG2;
    LoadTobRG3;
    { Chargement des données }
    for Cpt := 0 to pred(TobRG2.detail.count) do
    begin
      TobRG2L := TobRG2.Detail[Cpt];
      { 1ère ligne, il faut traiter la table principale }
      if Cpt = 0 then
      begin
        Where := TobRG2L.GetString('RG1_KEY') + ' = "' + GetString(sFieldCode) + '"';
        AddUpdate(TobRG2L.GetString('RG1_TABLENAME'), ' WHERE ' + Where);
      end;
      { Traiter la table liée courante }
      Where := GetWhereTablesL(TobRG2L.GetString('RG2_FILTRE'), sFieldCode);
      if Where = '' then
        Where := GetWhereTablesL(TobRG2L.GetString('RG2_FILTRE'), sFieldCode2nd);
      AddUpdate(TobRG2L.GetString('RG2_NOMTABLE'), ' WHERE ' + Where);
      Where := '';
    end;
    BeginTrans;
    try
      for Cpt := 0 to pred(TobResult.detail.count) do
        ExecuteSQL(TobResult.Detail[Cpt].GetString('_UPDATE'));
      InsertJnal;
      CommitTrans;
    except
      Rollback;
    end;
  finally
    FreeAndNil(TobResult);
  end;
  TFMul(Ecran).BChercheClick(nil);
end;

procedure TOF_BRGPDMUL.Rectification;
var
  OkUpdate : string;
  Return   : string;  
begin
  case Population of
    rgpdpThird    : begin
                      Return   := GetString('T_TIERS');
                      OkUpdate := OpenForm.CliPro(GetString('T_AUXILIAIRE'), GetString('T_NATUREAUXI'));

                    end;
    rgpdpResource : begin
                      Return   := GetString('ARS_RESSOURCE');
                      OkUpdate := OpenForm.Resource(Return, '', 'ORIGINE=RGP');
                    end;
    rgpdpUser     : begin
                      Return   := GetString('US_UTILISATEUR');
                      OkUpdate := OpenForm.User(Return);
                    end;
  end;
  if OkUpdate = Return then
   InsertJnal;
end;

initialization
  registerclasses([TOF_BRGPDMUL]);

end.

