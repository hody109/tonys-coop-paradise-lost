// Test-only loading stress route. Does not claim to complete mission unlocks.
class PLCoopAllTransitions extends PLCoopPresentationProbe;
var config int Step;
var config array<string> Sources;
var config array<string> Destinations;
var config string FinalMap;
var bool bInventoried, bKilled;
function Tick(float D)
{
 local PLCoopAllTransitionsClient C;
 local Telepad T;
 local NavigationPoint P;
 local PersonPawn Victim;
 local int N,K,I;
 local string MapName,Portal;
 if(Sent || TheGameState==None || GetPlayer()==None) return;
 MapName=Left(string(Level),InStr(string(Level),"."));
 if(!bInventoried)
 {
  bInventoried=true;
  foreach AllActors(class'Telepad',T)
   Log("PLALL|PAD|"$MapName$"|"$T.Tag$"|"$T.URL$"|enabled="$T.bEnabled);
  if(Step>0)
  {
   I=InStr(Destinations[Step-1],"#");
   if(I>=0)
   {
    Portal=Mid(Destinations[Step-1],I+1);
    I=InStr(Portal,"?");if(I>=0)Portal=Left(Portal,I);
    foreach AllActors(class'NavigationPoint',P)
     if(Caps(string(P.Tag))==Caps(Portal)) K++;
    Log("PLALL|PORTAL|"$Step$"|"$Portal$"|matches="$K);
   }
  }
 }
 foreach DynamicActors(class'PLCoopAllTransitionsClient',C)
  if(C.Player!=None && C.Pawn!=None)
  {C.bGodMode=true;if(C.bArrivalVerified)N++;}
 if(N<2) {ReadyAt=0;return;}
 if(ReadyAt==0)
 {
  ReadyAt=Level.TimeSeconds;
  Log("PLALL|ARRIVED|"$Step$"|"$MapName$"|day="$GetCurrentDay());
  if((Step<Sources.Length && Caps(MapName)!=Caps(Sources[Step])) || (Step==Sources.Length && Caps(MapName)!=Caps(FinalMap)))
  {Log("PLALL|FAIL|unexpected destination");Sent=true;return;}
 }
 if(!bKilled && Level.TimeSeconds-ReadyAt>2)
 {
  bKilled=true;K=0;
  foreach DynamicActors(class'PersonPawn',Victim)
   if(!Victim.bPlayer && Victim.Health>0 && Victim.Controller!=None)
   {Victim.Died(GetPlayer(),class'BulletDamage',Victim.Location);K++;if(K>=3)break;}
  Log("PLALL|CORPSES|"$Step$"|"$K);
 }
 if(Level.TimeSeconds-ReadyAt<10) return;
 Sent=true;
 if(Step>=Destinations.Length)
 {
  Log("PLALL|DONE");
  foreach DynamicActors(class'PLCoopAllTransitionsClient',C) C.FinishAudit();
  return;
 }
 StopSceneManagers();
 Log("PLALL|TRAVEL|"$Step$"|"$MapName$"|"$Destinations[Step]);
 Step++;SaveConfig();
 SendPlayerEx(GetPlayer(),Destinations[Step-1],TRAVEL_Relative);
}
defaultproperties
{
 SeedDay=0
 Step=0
 PlayerControllerClassName="PLCoopAudit.PLCoopAllTransitionsClient"
}
