// Test only: acknowledge an actually possessed pawn on every new client level.
class PLCoopAllTransitionsClient extends CoopPLPlayerClient;
var bool bArrivalSent;
var bool bArrivalVerified;
var float PawnReadyAt;
replication
{
 reliable if(Role<ROLE_Authority) ConfirmArrival;
 reliable if(Role==ROLE_Authority) FinishAudit;
}
function ConfirmArrival(string MapName)
{
 if(MapName!=Left(string(Level),InStr(string(Level),"."))) return;
 bArrivalVerified=true;
 Log("PLALL|CLIENT|"$PlayerReplicationInfo.PlayerName$"|"$MapName);
}
simulated function FinishAudit() {ConsoleCommand("quit");}
simulated function PlayerTick(float D)
{
 Super.PlayerTick(D);
 if(Role!=ROLE_AutonomousProxy || Pawn==None || bArrivalSent) return;
 if(PawnReadyAt==0) PawnReadyAt=Level.TimeSeconds;
 if(Level.TimeSeconds-PawnReadyAt<3) return;
 bArrivalSent=true;
 ConfirmArrival(Left(string(Level),InStr(string(Level),".")));
}
