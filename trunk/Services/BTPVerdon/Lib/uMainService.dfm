object SvcSyncBTPVerdon: TSvcSyncBTPVerdon
  OldCreateOrder = False
  DisplayName = 'Synchronisation BTP VERDON'
  AfterInstall = ServiceAfterInstall
  OnExecute = ServiceExecute
  OnStart = ServiceStart
  OnStop = ServiceStop
  Left = 198
  Top = 117
  Height = 150
  Width = 215
end
