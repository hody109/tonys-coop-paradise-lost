class PLCoopMondayClient extends PLCoopPresentationPlayer;
var float NextAnimals;
var PersonPawn WatchedBody;
var float BodyWatchTime;
var bool BodyReported;
replication
{
 reliable if(Role==ROLE_Authority) WatchCorpse;
}
simulated function WatchCorpse(PersonPawn Body)
{
 WatchedBody=Body;
 BodyWatchTime=Level.TimeSeconds;
}

simulated function PlayerTick(float D)
{
 local LabMonkey M;
 Super.PlayerTick(D);
 if(Level.NetMode==NM_Client && BodyWatchTime>0 && !BodyReported && Level.TimeSeconds-BodyWatchTime>30)
 {
  BodyReported=true;
  if(WatchedBody!=None && !WatchedBody.bDeleteMe && WatchedBody.Health<=0)
   ReportPresentation("corpse-retained|life=" $ WatchedBody.LifeSpan $ "|physics=" $ WatchedBody.Physics);
  else ReportPresentation("corpse-retention-FAIL");
 }

 if(Level.NetMode!=NM_Client || Level.TimeSeconds<NextAnimals) return;
 NextAnimals=Level.TimeSeconds+10;
 foreach DynamicActors(class'LabMonkey',M)
  ReportPresentation("monkey|"$M$"|health="$M.Health$"|hidden="$M.bHidden$"|life="$M.LifeSpan$"|location="$M.Location$"|state="$M.GetStateName());
}
