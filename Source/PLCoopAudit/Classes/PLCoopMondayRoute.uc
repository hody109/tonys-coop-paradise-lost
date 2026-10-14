class PLCoopMondayRoute extends PLCoopPresentationProbe;
var config int RouteStep;
var float LogAt;
var PersonPawn TestBody;
var bool KilledTestBody;
function Tick(float D)
{
 local PLCoopPresentationPlayer C;
 local LabMonkey M;
 local int N;
 local PersonPawn Victim;
 local vector Spot;
 local string URL;
 if(Level.TimeSeconds>LogAt)
 {
  LogAt=Level.TimeSeconds+10;
  foreach DynamicActors(class'LabMonkey',M)
   Log("PLROUTE|monkey|"$M$"|health="$M.Health$"|hidden="$M.bHidden$"|life="$M.LifeSpan$"|controller="$M.Controller$"|state="$M.Controller.GetStateName()$"|target="$LabMonkeyController(M.Controller).PostalDude$"|location="$M.Location);
 }
 if(Sent || GetPlayer()==None) return;
 foreach DynamicActors(class'PLCoopPresentationPlayer',C)
  if(C.Player!=None) {N++;C.bGodMode=true;}
 if(N<2) {ReadyAt=0;return;}
 if(ReadyAt==0) {ReadyAt=Level.TimeSeconds;
  if(RouteStep==3)
  {
   StopSceneManagers();
   foreach DynamicActors(class'LabMonkey',M) break;
   if(M!=None) foreach DynamicActors(class'PLCoopPresentationPlayer',C)
    if(C.Pawn!=None) {Spot=M.Location;Spot.X+=100;C.Pawn.SetLocation(Spot);}
  }
  foreach DynamicActors(class'PersonPawn',Victim)
   if(!Victim.bPlayer && Victim.Health>0 && Victim.Controller!=None)
   {
    foreach DynamicActors(class'PLCoopPresentationPlayer',C) if(C.Pawn!=None) break;
    if(C!=None && C.Pawn!=None)
    {
     TestBody=Victim;
     TestBody.bAlwaysRelevant=true;
     Spot=C.Pawn.Location+vect(150,0,80);
     TestBody.bCollideWorld=false;TestBody.SetLocation(Spot);TestBody.bCollideWorld=true;
     TestBody.Controller.GotoState('');
    }
    break;
   }
  Log("PLPRESENT|route|"$RouteStep$"|"$Level);}
 if(!KilledTestBody && TestBody!=None && Level.TimeSeconds-ReadyAt>5)
 {
  KilledTestBody=true;
  foreach DynamicActors(class'PLCoopPresentationPlayer',C)
   if(C.Player!=None) PLCoopMondayClient(C).WatchCorpse(TestBody);
  TestBody.Died(GetPlayer(),class'BulletDamage',TestBody.Location);
  Log("PLPRESENT|population|goal=" $ SliderPawnGoal $ "|body-limit=" $ BodiesSliderMax);
 }
 if(Level.TimeSeconds-ReadyAt<45) return;
 Sent=true;
 if(RouteStep==0) URL="PL-Industry#Pad1";
 else if(RouteStep==1) URL="PL-Highlands#Pad3";
 else if(RouteStep==2) URL="PL-WestMall#Pad2";
 else if(RouteStep==3) URL="PL-Highlands#Pad10";
 else if(RouteStep==4) URL="PL-rwsblock#pod5";
 else {foreach DynamicActors(class'PLCoopPresentationPlayer',C) C.FinishTest();Log("PLPRESENT|DONE");return;}
 RouteStep++;SaveConfig();
 StopSceneManagers();
 SendPlayerEx(GetPlayer(),URL,TRAVEL_Relative);
}
defaultproperties
{
 RouteStep=0
 SeedDay=0
 PlayerControllerClassName="PLCoopAudit.PLCoopMondayClient"
}

