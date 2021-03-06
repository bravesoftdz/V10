{***********UNITE*************************************************
Auteur  ...... : 
Cr�� le ...... : 07/12/2000
Modifi� le ... :   /  /
Description .. : Source TOT de la TABLE : PGTYPEORGANISME (PGTYPEORGANISME)
Mots clefs ... : TOF;PGTYPEORGANISME
*****************************************************************}
{
 PT1 : 10/05/2005 MF V_602 FQ 12267 - En cr�ation le code type d�organisme doit
                           obligatoirement �tre renseign� sur 3 caract�res
                           alphanum�riques.
                           En cr�ation, si le code saisi est num�rique, il ne
                           doit pas �tre compris entre 000 et 100.
}
Unit UTOTPGTYPEORGANISME ;

Interface

Uses StdCtrls, Controls, Classes,forms,sysutils,ComCtrls,
{$IFNDEF EAGLCLIENT}
      db,{$IFNDEF DBXPRESS} dbTables, {$ELSE} uDbxDataSet, {$ENDIF}HDB,
{$ELSE}
       UTOB,
{$ENDIF}
     HCtrls,HEnt1,HMsgBox,UTOT ;

Type
  TOT_PGTYPEORGANISME = Class ( TOT )
    procedure OnNewRecord              ; override ;
    procedure OnDeleteRecord           ; override ;
    procedure OnUpdateRecord           ; override ;
    procedure OnAfterUpdateRecord      ; override ;
    procedure OnClose                  ; override ;
    procedure OnArgument (S : String ) ; override ;
  end ;

Implementation

procedure TOT_PGTYPEORGANISME.OnNewRecord ;
begin
  Inherited ;
end ;

procedure TOT_PGTYPEORGANISME.OnDeleteRecord ;
begin
  Inherited ;
  if (GetField ('CC_CODE') > '000') AND (GetField ('CC_CODE') < '100')  then
     begin
     LastError:=1;
     LastErrorMsg:='Attention ! Ce code est obligatoire '+
                 '#13#10Vous ne pouvez le supprimer !';
      end;
end ;

procedure TOT_PGTYPEORGANISME.OnUpdateRecord ;
begin
  Inherited ;
// d PT1
  if (DS.State in [dsInsert]) then
  begin
    if (length(GetField ('CC_CODE')) <> 3) then
    begin
     LastError:=1;
     LastErrorMsg:='Attention ! Il faut renseigner un code sur 3 caract�res'+
                   ' alphanum�riques';
    end;

    if (isnumeric(GetField ('CC_CODE')) and (GetField ('CC_CODE') > '000') AND
       (GetField ('CC_CODE') < '100')  ) then
    begin
     LastError:=1;
     LastErrorMsg:='Attention ! Ce code '+ GetField ('CC_CODE') +' est un num�ro r�serv� '+
                 '#13#10Vous ne pouvez pas l''utiliser !' +
                 '#13#10Utilisez des codes alphanum�riques non compris entre 000 et 100 ';
    end;
  end;
// f PT1

end ;

procedure TOT_PGTYPEORGANISME.OnAfterUpdateRecord ;
begin
  Inherited ;
end ;

procedure TOT_PGTYPEORGANISME.OnClose ;
begin
  Inherited ;
end ;

procedure TOT_PGTYPEORGANISME.OnArgument (S : String ) ;
begin
  Inherited ;
end ;

Initialization
  registerclasses ( [ TOT_PGTYPEORGANISME ] ) ;
end.
