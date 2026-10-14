// Test only: real day travel, without completing the errands that unlock it.
class PLCoopPresentationProbe extends CoopPLGameInfo;
var float ReadyAt;
var bool Sent;
var config int SeedDay;
var config int LastDay;
var config float HoldSeconds;
event InitGame(out string Options,out string Error)
{
 Super.InitGame(Options,Error);
 bAutoSave_FirstRun=false;
}
function bool CoopLoadServerGameState()
{
 if(SeedDay>=0)
 {
  TheGameState.CurrentDay=0;
  TheGameState.NextDay=SeedDay;
  TheGameState.bChangeDayPostTravel=true;
  SeedDay=-1;SaveConfig();
  return true;
 }
 return Super.CoopLoadServerGameState();
}
function Tick(float D)
{
 local PLCoopPresentationPlayer C;
 local int N,i;
 local ScriptedSequence S;
 Super.Tick(D);
 if(InStr(Caps(Level.GetLocalURL()),"PL-INTRO")>=0) return;
 if(TheGameState==None || GetPlayer()==None || Sent) return;
 foreach DynamicActors(class'PLCoopPresentationPlayer',C)
  if(C.Player!=None && C.Pawn!=None) N++;
 if(N<2) {ReadyAt=0;return;}
 if(ReadyAt==0)
 {
  ReadyAt=Level.TimeSeconds;
  Log("PLPRESENT|arrived|day=" $ GetCurrentDay() $ "|map=" $ Level.GetLocalURL());
  foreach AllActors(class'ScriptedSequence',S)
   for(i=0;i<S.Actions.Length;i++)
    if(ACTION_PlayMusic(S.Actions[i])!=None)
     Log("PLAUDIT|music|" $ S $ "|" $ ACTION_PlayMusic(S.Actions[i]).Song);
    else if(ACTION_PlaySound(S.Actions[i])!=None)
     Log("PLAUDIT|sound|" $ S $ "|" $ ACTION_PlaySound(S.Actions[i]).Sound);
 }
 if(Level.TimeSeconds-ReadyAt<HoldSeconds) return;
 Sent=true;
 if(GetCurrentDay()==LastDay)
 {
  foreach DynamicActors(class'PLCoopPresentationPlayer',C) C.FinishTest();
  Log("PLPRESENT|DONE");
  return;
 }
 StopSceneManagers();
 Log("PLPRESENT|next|" $ GetCurrentDay());
 SendPlayerToNextDay(GetPlayer());
}
defaultproperties
{
 SeedDay=-1
 LastDay=6
 HoldSeconds=25
 PlayerControllerClassName="PLCoopAudit.PLCoopPresentationPlayer"
}
