class PLCoopHostProbe extends CoopPLGameInfo;
var float AuditAt;
event Tick(float D)
{
 local Pawn P;
 local CoopPlayerController C;
 Super.Tick(D);
 if(Level.TimeSeconds<AuditAt) return;
 AuditAt=Level.TimeSeconds+3;
 foreach AllActors(class'Pawn',P)
  if(P.IsA('PostalDude') || P.IsA('PLPostalDude') || P.IsA('CoopPLPostalDude'))
  {
   C=CoopPlayerController(P.Controller);
   Log("PLBODY|" $ Level.TimeSeconds $ "|pawn=" $ P $ "|controller=" $ P.Controller $ "|hidden=" $ P.bHidden $ "|loc=" $ P.Location);
   if(C!=None) Log("PLBODY|camera=" $ C.NETSceneCamera $ "|scene=" $ C.xGetMatineeCameraStatus());
  }
}
defaultproperties
{
 PlayerControllerClassName="PLCoopAudit.PLCoopHostProbePlayer"
}
