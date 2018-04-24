{***********UNITE*************************************************
Auteur  ...... : 
Créé le ...... : 18/04/2018
Modifié le ... :   /  /
Description .. : Source TOF de la FICHE : BRGPDREFERENTIEL ()
Mots clefs ... : TOF;BRGPDREFERENTIEL
*****************************************************************}
Unit BRGPDREFERENTIEL_TOF ;

Interface

Uses
  StdCtrls
  , Controls
  , Classes
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
  ;

function BLanceFiche_RGPDReferentiel(Nat, Cod, Range, Lequel, Argument : string) : string;

Type
  TOF_BRGPDREFERENTIEL = Class (tTOFComm)
  private
    Population : THValCombobox;
    LstTables  : THGrid;
    LstFields  : THGrid;
    TobTables  : TOB;
    TobFields  : TOB;
    ColsTables : string;
    ColsFields : string;
    AddField   : TToolbarButton97;
    DelField   : TToolbarButton97;

    procedure GridsManagement;
    procedure ButtonManagement;
    procedure LoadTobTable(Sender : TObject);
    procedure LoadTobFields(TableName : string);
    procedure LstTables_OnClick(Sender : TObject);
    procedure LstFields_OnDlbclick(Sender : TObject);
    function GetTobFromGrid(CurrentGrid : THGrid) : TOB;

  public
    procedure OnNew                    ; override ;
    procedure OnDelete                 ; override ;
    procedure OnUpdate                 ; override ;
    procedure OnLoad                   ; override ;
    procedure OnArgument (S : String ) ; override ;
    procedure OnDisplay                ; override ;
    procedure OnClose                  ; override ;
    procedure OnCancel                 ; override ;
  end ;

Implementation

uses
  TntStdCtrls
  , wCommuns
  ;

const
  LstNameTables = 'LSTTABLESL';
  LstNameFields = 'LSTCHAMPS';

function BLanceFiche_RGPDReferentiel(Nat, Cod, Range,Lequel,Argument : string) : string;
begin
  V_PGI.ZoomOle := True;
  Result := AglLanceFiche(Nat, Cod, Range, Lequel, Argument);
  V_PGI.ZoomOle := False;
end;

procedure TOF_BRGPDREFERENTIEL.OnNew ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDREFERENTIEL.OnDelete ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDREFERENTIEL.OnUpdate ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDREFERENTIEL.OnLoad ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDREFERENTIEL.OnArgument (S : String ) ;
begin
  Inherited ;
  Population := THValCombobox(GetControl('POPULATION'));
  LstTables  := THGrid(GetControl(LstNameTables));
  LstFields  := THGrid(GetControl(LstNameFields));
  AddField   := TToolbarButton97(GetControl('ADDFIELD'));
  DelField   := TToolbarButton97(GetControl('DELFIELD'));
  TobTables  := TOB.Create('_LinkedTables', nil, -1);
  TobFields  := TOB.Create('BRGPDCHAMPS', nil, -1);
  Population.OnChange  := LoadTobTable;
  LstTables.OnClick    := LstTables_OnClick;
  LstFields.OnDblClick :=  LstFields_OnDlbclick;
  GridsManagement;
end ;

procedure TOF_BRGPDREFERENTIEL.OnClose ;
begin
  Inherited ;
  FreeAndNil(TobTables);
  FreeAndNil(TobFields);

end ;

procedure TOF_BRGPDREFERENTIEL.OnDisplay () ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDREFERENTIEL.OnCancel () ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDREFERENTIEL.LoadTobTable(Sender: TObject);
var
  Sql : string;
  Id  : string;
begin
  LstTables.VidePile(False);
  LstFields.VidePile(False);
  TobTables.ClearDetail;
  TobFields.ClearDetail;
  Id  := Population.Value;
  Sql := ' SELECT 1              as Sort'
       + '       , RG1_TABLENAME as TableName'
       + '       , RG1_LABEL     as Label'
       + ' FROM BRGPDTABLESP'
       + ' WHERE RG1_ID = ' + Id
       + ' UNION'
       + ' SELECT 2              as Sort'
       + '       , RG2_NOMTABLE  as TableName'
       + '       , RG2_LIBELLE   as Label'
       + ' FROM BRGPDTABLESL'
       + ' WHERE RG2_IDRG1 = ' + Id
       + ' ORDER BY Sort, Label'
       ;
  TobTables.LoadDetailFromSQL(Sql);
  if TobTables.Detail.Count > 0 then
  begin
    LoadTobFields(TobTables.Detail[0].GetString('TableName'));
    TobTables.PutGridDetail(LstTables, False, False, ColsTables);
  end;
end;

procedure TOF_BRGPDREFERENTIEL.LoadTobFields(TableName : string);
var
  Sql : string;
begin
  LstFields.VidePile(False);
  TobFields.ClearDetail;
  if TobTables.Detail.Count > 0 then
  begin
    Sql := 'SELECT BRGPDCHAMPS.*, DH_LIBELLE'
         + ' FROM BRGPDCHAMPS'
         + ' JOIN DECHAMPS ON DH_NOMCHAMP=RG3_FIELDNAME'
         + ' WHERE RG3_TABLENAME = "' + TableName + '"'
         + ' ORDER BY RG3_FIELDNAME'
         ;
    TobFields.LoadDetailFromSQL(Sql);
    TobFields.PutGridDetail(LstFields, False, False, ColsFields);
  end;
end;

procedure TOF_BRGPDREFERENTIEL.GridsManagement;
var
  Cpt : integer;
begin
  ColsTables := 'Label';
  ColsFields := 'RG3_FIELDNAME;DH_LIBELLE;RG3_EXPORT;RG3_RESET';
  for Cpt := 3 to 4 do
  begin
    LstFields.ColAligns[Cpt]  := taCenter;
    LstFields.ColTypes[Cpt]   := 'B';
    LstFields.ColFormats[Cpt] := IntToStr(Integer(csCoche));
  end;

end;

procedure TOF_BRGPDREFERENTIEL.ButtonManagement;
var
  TobField : TOB;
begin
  TobField := GetTobFromGrid(LstFields);
  if assigned(TobField) then
  begin
    DelField.Enabled := (not TobField.GetBoolean('RG3_INTERNE'));
  end;
end;
  
function TOF_BRGPDREFERENTIEL.GetTobFromGrid(CurrentGrid : THGrid): TOB;
begin
  if Assigned(CurrentGrid) then
  begin
    case CaseFromString(CurrentGrid.Name, [LstNameTables, LstNameFields]) of
      {LstNameTables} 0 : Result := TobTables.Detail[CurrentGrid.Row - 1];
      {LstNameFields} 1 : Result := TobFields.Detail[CurrentGrid.Row - 1];
    else
      Result := nil;
    end;
  end else
    Result := nil;
end;

procedure TOF_BRGPDREFERENTIEL.LstTables_OnClick(Sender: TObject);
var
  TobTable : TOB;
begin
  TobTable := GetTobFromGrid(LstTables);
  if Assigned(TobTable) then
    LoadTobFields(TobTable.GetString('TABLENAME'));
end;

procedure TOF_BRGPDREFERENTIEL.LstFields_OnDlbclick(Sender: TObject);
var
  TobField   : TOB;
  CurrentCol : integer;
  FieldName  : string;
  Sql        : string;
begin
  CurrentCol := LstFields.Col;
  if (CurrentCol = 3) or (CurrentCol = 4) then
  begin
    TobField := GetTobFromGrid(LstFields);
    if Assigned(TobField) then
    begin
      case CurrentCol of
        3 : FieldName := 'RG3_EXPORT';
        4 : FieldName := 'RG3_RESET';
      end;
      TobField.SetBoolean(FieldName, iif(TobField.GetBoolean(FieldName), False, True));
      TobField.PutLigneGrid(LstFields, LstFields.Row, False, False, ColsFields);
      Sql := 'UPDATE BRGPDCHAMPS'
           + ' SET ' + FieldName + ' = "' + TobField.GetString(FieldName) + '"'
           + ' WHERE RG3_TABLENAME = "' + TobField.GetString('RG3_TABLENAME') + '"'
           + '   AND RG3_FIELDNAME = "' + TobField.GetString('RG3_FIELDNAME') + '"'
           ;
      ExecuteSQL(Sql);
    end;
  end;
end;

Initialization
  registerclasses ( [ TOF_BRGPDREFERENTIEL ] ) ;
end.

