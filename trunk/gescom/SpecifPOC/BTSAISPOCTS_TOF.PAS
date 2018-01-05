{***********UNITE*************************************************
Auteur  ...... : 
Créé le ...... : 27/12/2017
Modifié le ... :   /  /
Description .. : Source TOF de la FICHE : BTSAISPOCTS ()
Mots clefs ... : TOF;BTSAISPOCTS
*****************************************************************}
Unit BTSAISPOCTS_TOF ;

Interface

Uses StdCtrls, 
     Controls, 
     Classes, 
{$IFNDEF EAGLCLIENT}
     db, 
     uDbxDataSet, 
     mul, 
{$else}
     eMul, 
{$ENDIF}
     Vierge,
     uTob,
     HTB97, 
     forms, 
     sysutils, 
     ComCtrls,
     HCtrls, 
     HEnt1,
     HMsgBox,
     UTOF ;

const
  TheChamps = 'BLT_NUMDETAIL;BLT_CODEARTICLE;BLT_LIBELLE;BLT_QTEFACT;BLT_PUHTDEV;BLT_MONTANTHTDEV;';

Type
  TOF_BTSAISPOCTS = Class (TOF)
    procedure OnNew                    ; override ;
    procedure OnDelete                 ; override ;
    procedure OnUpdate                 ; override ;
    procedure OnLoad                   ; override ;
    procedure OnArgument (S : String ) ; override ;
    procedure OnDisplay                ; override ;
    procedure OnClose                  ; override ;
    procedure OnCancel                 ; override ;
  private
    GS : THGrid;
    TOBDET : TOB;
    procedure GSElipsisClick(Sender: TObject);
    procedure GSCellEnter(Sender: TObject; var ACol, ARow: Integer; var Cancel: Boolean);
    procedure GSCellExit(Sender: TObject; var ACol, ARow: Integer; var Cancel: Boolean);
    procedure GSRowEnter(Sender: TObject; Ou: Integer; var Cancel: Boolean; Chg: Boolean);
    procedure GSRowExit(Sender: TObject; Ou: Integer; var Cancel: Boolean; Chg: Boolean);
    procedure DefinieGrilleSaisie;
    procedure AfficheLaGrille;


  end ;

Implementation

procedure TOF_BTSAISPOCTS.OnNew ;
begin
  Inherited ;
end ;

procedure TOF_BTSAISPOCTS.OnDelete ;
begin
  Inherited ;
end ;

procedure TOF_BTSAISPOCTS.OnUpdate ;
begin
  Inherited ;
end ;

procedure TOF_BTSAISPOCTS.OnLoad ;
begin
  Inherited ;
end ;

procedure TOF_BTSAISPOCTS.OnArgument (S : String ) ;
var cancel : Boolean;
    Acol,Arow : Integer;
begin
  Inherited ;
  cancel := false;
  TOBDET := LaTOB;
  GS := THGrid(Getcontrol('GS'));
  DefinieGrilleSaisie;
  AfficheLaGrille;
  //
  GS.Row := 1; GS.col := 1; Acol := GS.Col; Arow := GS.Row;
  GS.OnRowEnter := GSRowEnter;
  GS.OnRowExit := GSRowExit;
  GS.OnCellEnter := GSCellEnter;
  GS.OnCellExit := GSCellExit;
  GS.OnElipsisClick := GSElipsisClick;
  GSRowEnter(Self,GS.row,cancel,false);
  GSCellEnter(Self,Acol,Arow,cancel);
end ;

procedure TOF_BTSAISPOCTS.OnClose ;
begin
  Inherited ;
end ;

procedure TOF_BTSAISPOCTS.OnDisplay () ;
begin
  Inherited ;
end ;

procedure TOF_BTSAISPOCTS.OnCancel () ;
begin
  Inherited ;
end ;

procedure TOF_BTSAISPOCTS.GSCellEnter(Sender: TObject; var ACol,ARow: Integer; var Cancel: Boolean);
begin

end;

procedure TOF_BTSAISPOCTS.GSCellExit(Sender: TObject; var ACol,ARow: Integer; var Cancel: Boolean);
begin

end;

procedure TOF_BTSAISPOCTS.GSElipsisClick(Sender: TObject);
begin

end;

procedure TOF_BTSAISPOCTS.GSRowEnter(Sender: TObject; Ou: Integer;var Cancel: Boolean; Chg: Boolean);
begin

end;

procedure TOF_BTSAISPOCTS.GSRowExit(Sender: TObject; Ou: Integer;var Cancel: Boolean; Chg: Boolean);
begin

end;

procedure TOF_BTSAISPOCTS.DefinieGrilleSaisie;
var NbrLig : Integer;
    FFM,FFQ,FFP : string;
    II : Integer;
begin
  FFM := '#';
  if V_PGI.OkDecV > 0 then
  begin
    FFM := '0.';
    for II := 1 to V_PGI.OkDecV - 1 do
    begin
      FFM := FFM + '#';
    end;
    FFM := FFM + '0';
  end;
  FFP := '#';
  if V_PGI.OkDecP > 0 then
  begin
    FFP := '0.';
    for II := 1 to V_PGI.OkDecP - 1 do
    begin
      FFP := FFP + '#';
    end;
    FFP := FFP + '0';
  end;
  FFQ := '#';
  if V_PGI.OkDecQ > 0 then
  begin
    FFQ := '0.';
    for II := 1 to V_PGI.OkDecQ - 1 do
    begin
      FFQ := FFQ + '#';
    end;
    FFQ := FFQ + '0';
  end;

  NbrLig := TOBDET.detail.Count; if NbrLig = 0 then NbrLig := 1;
  GS.VidePile(false);
  //
  GS.ColCount := 6;
  GS.RowCount := NbrLig +1;
  GS.Cells[0,0] := '';
  GS.ColWidths[0] := 20;
  GS.ColAligns[0] := taRightJustify;
  //
  GS.Cells[1,0] := 'Code';
  GS.ColWidths[1] := 30;
  GS.ColLengths[1] := 18;
  GS.ColAligns[1] := taLeftJustify;
  //
  GS.Cells[2,0] := 'Libellé';
  GS.ColWidths[2] := 70;
  GS.ColLengths[2] := 35;
  GS.ColAligns[2] := taLeftJustify;
  //
  GS.Cells[3,0] := 'Qté';
  GS.ColWidths[3] := 30;
  GS.ColLengths[3] := 14;
  GS.ColAligns[3] := taRightJustify;
  GS.ColTypes [3] := 'R';
  GS.ColFormats[3] := 'FFQ;FFQ; ;';
  //
  GS.Cells[4,0] := 'Prix Unitaire';
  GS.ColWidths[4] := 30;
  GS.ColLengths[4] := 14;
  GS.ColTypes [4] := 'R';
  GS.ColAligns[4] := taRightJustify;
  GS.ColFormats[4] := 'FFP;FFP; ;';
  //
  GS.Cells[5,0] := 'Montant';
  GS.ColWidths[5] := 40;
  GS.ColLengths[5] := 16;
  GS.ColTypes [5] := 'R';
  GS.ColAligns[5] := taRightJustify;
  GS.ColFormats[5] := 'FFM;FFM; ;';
end;

procedure TOF_BTSAISPOCTS.AfficheLaGrille;
var II : Integer;
begin
  for II := 0 to TOBDET.Detail.count -1 do
  begin
    TOBDET.Detail [II].PutLigneGrid(GS,II+1,false,False,TheChamps);
  end;
  TFVierge(Ecran).HMTrad.ResizeGridColumns(GS);
end;

Initialization
  registerclasses ( [ TOF_BTSAISPOCTS ] ) ; 
end.
