class PLCoopTravelClient extends CoopPLPlayerClient;
var float ReportAt;
var float MoveStarted;
var bool bReportedGate;
replication
{
 reliable if(Role<ROLE_Authority) ReportTravelState;
}
function ReportTravelState(string Message)
{
 Log("PLTRANS|CLIENT|"$PlayerReplicationInfo.PlayerName$"|"$Message);
}
simulated function PlayerTick(float D)
{
 local CoopPLTelepadBlocker G;
 local Pawn Other;
 if(Role==ROLE_AutonomousProxy && Pawn!=None && InStr(Caps(string(Level)),"PL-COMPOUND")>=0)
 {
  if(MoveStarted==0) MoveStarted=Level.TimeSeconds;
  if(Level.TimeSeconds-MoveStarted>2 && Level.TimeSeconds-MoveStarted<5) aStrafe=8000;
 }
 Super.PlayerTick(D);
 if(Role!=ROLE_AutonomousProxy || Pawn==None) return;
 if(!bReportedGate)
  foreach DynamicActors(class'CoopPLTelepadBlocker',G)
   if(G.bPLOpen && !G.bCollideActors && !G.bBlockPlayers)
   {ReportTravelState("wall removed on client");bReportedGate=true;break;}
 if(InStr(Caps(string(Level)),"PL-COMPOUND")>=0 && Level.TimeSeconds>ReportAt)
 {
  ReportAt=Level.TimeSeconds+5;
  foreach DynamicActors(class'Pawn',Other)
   if(Other!=Pawn && Other.PlayerReplicationInfo!=None)
    ReportTravelState("destination|self="$Pawn.Location$"|other="$Other.PlayerReplicationInfo.PlayerName$"|position="$Other.Location);
 }
}
