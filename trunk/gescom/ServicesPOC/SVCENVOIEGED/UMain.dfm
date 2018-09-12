object SVCENREGBASTGED: TSVCENREGBASTGED
  OldCreateOrder = False
  DisplayName = 'Service d'#39'enregistrement des BAST dans GED'
  AfterInstall = ServiceAfterInstall
  OnExecute = ServiceExecute
  OnStart = ServiceStart
  OnStop = ServiceStop
  Left = 438
  Top = 125
  Height = 150
  Width = 215
end
