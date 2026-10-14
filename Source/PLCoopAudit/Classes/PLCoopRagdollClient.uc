class PLCoopRagdollClient extends CoopPLPlayerClient;
var PersonPawn Watched;
var vector InitialPelvis;
var float WatchAt,NextWatch;
var bool bReported;
replication
{
 reliable if(Role==ROLE_Authority) ClientWatchBody;
 reliable if(Role<ROLE_Authority) ReportBody;
}
simulated function ClientWatchBody(PersonPawn P)
{
 Watched=P;
 InitialPelvis=P.GetBoneCoords('MALE01 pelvis').Origin;
 WatchAt=Level.TimeSeconds;
 Log("PLRAG|watch|pawn="$P$"|pelvis="$InitialPelvis);
}
function ReportBody(bool OK,string Detail)
{
 if(OK) Log("PLRAG|PASS|"$PlayerReplicationInfo.PlayerName$"|"$Detail);
 else Log("PLRAG|FAIL|"$PlayerReplicationInfo.PlayerName$"|"$Detail);
}
simulated function PlayerTick(float D)
{
 local vector Pelvis;
 Super.PlayerTick(D);
 if(Role!=ROLE_AutonomousProxy || Watched==None || bReported || Level.TimeSeconds<NextWatch)return;
 NextWatch=Level.TimeSeconds+1;
 Pelvis=Watched.GetBoneCoords('MALE01 pelvis').Origin;
 Log("PLRAG|sample|physics="$Watched.Physics$"|health="$Watched.Health$"|pelvis="$Pelvis);
 if(Level.TimeSeconds-WatchAt>12)
 {
  bReported=true;
  ReportBody(Watched.Health<=0 && Watched.Physics==PHYS_KarmaRagDoll && InitialPelvis.Z-Pelvis.Z>40,
   "physics="$Watched.Physics$"|drop="$(InitialPelvis.Z-Pelvis.Z)$"|skeleton="$KarmaParamsSkel(Watched.KParams).KSkeleton);
 }
}
