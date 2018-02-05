unit UTransferts;

interface
uses sysutils,classes,windows,messages,controls,forms,hmsgbox,stdCtrls,clipbrd,nomenUtil,
     HCtrls,SaisUtil,HEnt1,Ent1,EntGC,UtilPGI,UTOB,HTB97,FactUtil,FactComm,Menus,ParamSoc,
     AglInit,FactTob,FactVariante,vierge,UtilNumParag,uEntCommun,
{$IFDEF EAGLCLIENT}
     maineagl,
{$ELSE}
     fe_main,{$IFNDEF DBXPRESS} dbTables, {$ELSE} uDbxDataSet, {$ENDIF}
{$ENDIF}
     HRichOLE,UTOF;

const MAXITEMS = 4;

type

  TGestTransfert = class (TObject)
  private
    fCreatedPop : boolean;
    FF : TForm;
    fusable : boolean;
    POPGS : TPopupMenu;
    MesMenuItem: array[0..MAXITEMS] of TMenuItem;
    fMaxItems : integer;
    procedure DefiniMenuPop(Parent: Tform);
    procedure AjoutTransfert (Sender : TObject);
    procedure DetailTransfert (Sender : TObject);
    procedure ModifTransfert (Sender : TObject); 
    function IsTransfert (TOBL : TOB) : boolean;
    procedure ActiveMenu (Etat : boolean);
  public
    property CurrentSaisie : TForm read FF;
    destructor  destroy ; override;
    constructor create(TT: TForm);
    procedure DefiniMenu (TOBL : TOB);
    procedure SetPiece (NaturePiece : string);

  end;

var CurrentTransfert : TGestTransfert;

function FindTransfert (TOBTRFPOC,TOBL : TOB) : TOB;
procedure LoadLesTOBTRF(CleDoc : r_cledoc;TOBTRFPOC : TOB);
procedure ValideLesTOBTRF (TOBPiece,TOBTRFPOC : TOB);

implementation
uses Facture,UtilTOBPiece;


function FindTransfert (TOBTRFPOC,TOBL : TOB) : TOB;
var TOBTRFE : TOB;
begin
  result := nil;
  TOBTRFE := TOBTRFPOC.findfirst(['BT2_UNIQUE'],[TOBL.GetInteger('NUMTRANSFERT')],True);
  if TOBTRFE = nil then Exit;
  Result := TOBTRFE.FindFirst(['BT3_NUMORDRE'],[TOBL.GetInteger('GL_NUMORDRE')],true)
end;

procedure LoadLesTOBTRF(CleDoc : r_cledoc;TOBTRFPOC : TOB);
var QQ : TQuery;
    TOBT,TT,ThePere : TOB;
    LastUnique : integer;
    II : Integer;
begin
  LastUnique := -1;
  ThePere := nil;
  TOBT := TOB.Create ('LES LIGNES TRF',nil,-1);
  TRY
    QQ := OpenSQL('SELECT * FROM BTRFENTETE WHERE '+WherePiece(CleDoc,ttdTRFEntPoc,true)+' ORDER BY BT2_UNIQUE',True,-1,'',True);
    if not QQ.Eof then
    begin
      TOBTRFPOC.LoadDetailDB('BTRFENTETE','','',QQ,False);
    end;
    ferme (QQ);
    //
    QQ := OpenSQL('SELECT * FROM BTRFDETAIL WHERE '+WherePiece(CleDoc,ttdTRFDetPOC,true)+' ORDER BY BT3_UNIQUE,BT3_TYPELIGNETRF,BT3_NUMORDRE',True,-1,'',True);
    if not QQ.Eof then
    begin
      TOBT.LoadDetailDB('BTRFDETAIL','','',QQ,False);
      II := 0;
      repeat
        TT := TOBT.detail[II];
        if LastUnique <> TT.GetInteger('BT3_UNIQUE') then
        begin
          ThePere := TOBTRFPOC.FindFirst(['BT2_UNIQUE'],[TT.GetInteger('BT3_UNIQUE')],true);
          if ThePere = nil then
          begin
            TT.free;
            continue;
          end;
          LastUnique := TT.GetInteger('BT3_UNIQUE');
        end;
        if ThePere <> nil then TT.ChangeParent(ThePere,-1);
      until II >= TOBT.detail.Count;
    end;
    ferme (QQ);
  finally
    TOBT.free;
  end;
end;


procedure ValideLesTOBTRF (TOBPiece,TOBTRFPOC : TOB);
var II,JJ : Integer;
    TOBT,TT : TOB;
begin
  for II := 0 to TOBTRFPOC.detail.count -1 do
  begin
    TOBT := TOBTRFPOC.detail[II];
    TOBT.SetString('BT2_NATUREPIECEG',TOBPiece.GetString('GP_NATUREPIECEG') );
    TOBT.SetString('BT2_SOUCHE',TOBPiece.GetString('GP_SOUCHE') );
    TOBT.SetInteger('BT2_NUMERO',TOBPiece.GetInteger('GP_NUMERO') );
    TOBT.SetInteger('BT2_INDICEG',TOBPiece.GetInteger('GP_INDICEG') );
    TOBT.SetAllModifie(true);
    for JJ := 0 to TOBT.detail.count -1 do
    begin
      TT := TOBT.detail[JJ];
      TT.SetString('BT3_NATUREPIECEG',TOBPiece.GetString('GP_NATUREPIECEG') );
      TT.SetString('BT3_SOUCHE',TOBPiece.GetString('GP_SOUCHE') );
      TT.SetInteger('BT3_NUMERO',TOBPiece.GetInteger('GP_NUMERO') );
      TT.SetInteger('BT3_INDICEG',TOBPiece.GetInteger('GP_INDICEG') );
      TT.SetInteger('BT3_UNIQUE',TOBT.GetInteger('BT2_UNIQUE'));
      TT.SetAllModifie(true);
    end;
  end;
  TOBTRFPOC.InsertDBByNivel(false); 
end;


{ TGestTransfert }

procedure TGestTransfert.ActiveMenu(Etat: boolean);
var II : integer;
begin
  for II := 0 to fMaxItems -1 do
  begin
    MesMenuItem[II].visible := Etat;
  end;
end;

procedure TGestTransfert.AjoutTransfert(Sender: TObject);
var TOBT : TOB;
    TOBPiece : TOB;
    TOBTRFPOC : TOB;

  function BeforeTransfert (TOBPiece,TOBTRFPOC,TOBT : TOB) : boolean;
  var II : Integer;
      GS : Thgrid;
      TOBL,TT,TL  : TOB;
  begin
    GS := TFFActure(FF).GS;
    Result := false;
    if GS.nbSelected = 0 then BEGIN PGIInfo('Aucune ligne séléctionné'); Exit; END;
    for II := 1 to GS.RowCount do
    begin
      TOBL := GetTOBLigne(TOBPiece,II);
      if not GS.IsSelected(II) then Continue;
      if TOBL.GetString('GL_TYPELIGNE')<>'ART' then
      begin
        PGIInfo('Seule les lignes de documents sont acceptées');
        Exit;
      end;
      if TOBL.GetInteger('NUMTRANSFERT') <> 0 then
      begin
        TT := FindTransfert (TOBTRFPOC,TOBL);
        if TT <> nil then
        begin
          if TT.GetString('BT3_TYPELIGNETRF')='000' then
          begin
            PGIInfo('La ligne '+TOBL.GetString('GL_NUMLIGNE')+' est déjà transférée');
            Exit;
          end;
        end;
      end;
      TL := TOB.Create('BTRFDETAIL',TOBT,-1);
      TL.SetInteger('BT3_UNIQUE',TOBT.GetInteger('BT2_UNIQUE'));
      TL.SetString('BT3_TYPELIGNETRF','000');
      TL.SetInteger('BT3_NUMORDRE',TOBL.GetInteger('GL_NUMORDRE'));
      TL.Data := TOBL;
    end;
    Result := True;
  end;

begin
  TOBPIece := TFFacture (FF).LaPieceCourante;
  TOBTRFPOC := TFFActure(FF).XTOBTRFPOC;
  //
  TOBT := TOB.create ('BTRFENTETE',nil,-1);
  TOBT.SetInteger('BT2_UNIQUE',TOBPiece.GetInteger('MAXUNIQUE')+1);
  TOBT.SetDateTime('BT2_DATECREATION',Now);
  TOBT.SetDateTime('BT2_DATEMODIF',NowH);
  TOBT.SetSTring('BT2_CREATEUR',V_PGI.User);
  TOBT.SetSTring('BT2_UTILISATEUR',V_PGI.User);
  TOBT.AddChampSupValeur('OKOK','-');
  try
    if not BeforeTransfert (TOBPiece,TOBTRFPOC,TOBT) then exit;
    //
    if TOBT.detail.count > 0 then
    begin
      TheTOB := TOBT;
      AGLLanceFiche('BTP','BTSAISTRFPOC','','','');
      TheTOB := nil;
      if TOBT.GetString('OKOK')='X' then
      begin
        TOBT.ChangeParent(TOBTRFPOC,-1);
        TOBPiece.SetInteger('MAXUNIQUE',TOBT.GetInteger('BT2_UNIQUE'));
      end;
    end;
    TFFacture(FF).CopierColleObj.deselectionneRows;
  finally
    TOBT.Free;
  end;

end;

constructor TGestTransfert.create(TT: TForm);
var ThePop : Tcomponent;
begin
  fCreatedPop := false;
  fusable := false;
  FF := TT;
  ThePop := TT.Findcomponent  ('POPBTP');
  if ThePop = nil then
  BEGIN
    // pas de menu BTP trouve ..on le cree
    POPGS := TPopupMenu.Create(TT);
    POPGS.Name := 'POPBTP';
    fCreatedPop := true;
  END else
  BEGIN
    POPGS := TPopupMenu(thePop);
  END;
  DefiniMenuPop(TT);
  CurrentTransfert := Self;
end;

procedure TGestTransfert.DefiniMenu(TOBL: TOB);
var II : Integer;
begin
  if not fusable then Exit;
  for II := 0 to fMaxItems -1 do
  begin
    if MesMenuItem[fMaxItems].Name = 'mListTransfert' then
    begin
      if ISTransfert (TOBL) then MesMenuItem[fMaxItems].Enabled := true
                            else MesMenuItem[fMaxItems].Enabled := false;
    end;
    if MesMenuItem[fMaxItems].Name = 'mModifTransfert' then
    begin
      if ISTransfert (TOBL) then MesMenuItem[fMaxItems].Enabled := true
                            else MesMenuItem[fMaxItems].Enabled := false;
    end;
  end;
end;

procedure TGestTransfert.DefiniMenuPop (Parent : Tform);
var Indice : integer;
begin
  fMaxItems := 0;
  if not fcreatedPop then
  begin
    MesMenuItem[fMaxItems] := TmenuItem.Create (parent);
    with MesMenuItem[fMaxItems] do
      begin
      Caption := '-';
      end;
    inc (fMaxItems);
  end;
  MesMenuItem[fMaxItems] := TmenuItem.Create (parent);
  with MesMenuItem[fMaxItems] do
  begin
    Name := 'mTransfert';
    Caption := TraduireMemoire ('Créer transfert');
    OnClick := AjoutTransfert;
  end;
  inc (fMaxItems);
  MesMenuItem[fMaxItems] := TmenuItem.Create (parent);
  with MesMenuItem[fMaxItems] do
  begin
    Name := 'mModifTransfert';
    Caption := TraduireMemoire ('Modifier transfert');
    OnClick := ModifTransfert;
    Enabled := false;
  end;
  inc (fMaxItems);
  MesMenuItem[fMaxItems] := TmenuItem.Create (parent);
  with MesMenuItem[fMaxItems] do
  begin
    Name := 'mListTransfert';
    Caption := TraduireMemoire ('Détail transferts');
    OnClick := DetailTransfert;
    Enabled := false;
  end;
  inc (fMaxItems);

  for Indice := 0 to fMaxItems -1 do
  begin
    if MesMenuItem [Indice] <> nil then POPGS.Items.Add (MesMenuItem[Indice]);
  end;
end;

destructor TGestTransfert.destroy;
var indice : integer;
begin
  inherited;
  for Indice := 0 to fMaxItems -1 do   
  begin
    MesMenuItem[Indice].Free;
  end;
  if fcreatedPop then POPGS.free;
  CurrentTransfert := nil;
end;

procedure TGestTransfert.DetailTransfert(Sender: TObject);
begin
//
end;

function TGestTransfert.IsTransfert(TOBL: TOB): boolean;
begin
  Result := false;
  if TOBL = nil then exit;
  Result := (TOBL.GetInteger('NUMTRANSFERT')<>0);
end;

procedure TGestTransfert.ModifTransfert(Sender: TObject);
begin
//
end;

procedure TGestTransfert.SetPiece(NaturePiece: string);
begin
  if (VH_GC.BTCODESPECIF <> '001') or (NaturePiece <>'BCE') then
  begin
    ActiveMenu (false);
    fusable := false;
  end;
end;

end.
