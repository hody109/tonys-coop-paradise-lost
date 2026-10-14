class PLCoopPresentationPlayer extends CoopPLPlayerClient;
var float JoinedAt;
var bool TestedMap,ReportedMap,ReportedCard;
var bool StartedIntro;
replication
{
 reliable if(Role<ROLE_Authority) ReportPresentation;
 reliable if(Role==ROLE_Authority) FinishTest;
}
function ReportPresentation(string S)
{
 Log("PLPRESENT|client|" $ PlayerReplicationInfo.PlayerName $ "|" $ S);
}
simulated function FinishTest() {ConsoleCommand("quit");}
simulated function PlayerTick(float D)
{
 local CoopPLShellRootWindow R;
 local CoopPLMapInteraction M;
 local CoopGameReplicationInfo G;
 local Actor A;
 local DayBlocker Sky;
 local int i;
 Super.PlayerTick(D);
 if(Role!=ROLE_AutonomousProxy || Player==None || PlayerReplicationInfo==None) return;
 G=CoopGameReplicationInfo(GameReplicationInfo);
 if(G==None) return;
 if(JoinedAt==0) JoinedAt=Level.TimeSeconds;
 if(InStr(Caps(Level.GetLocalURL()),"PL-INTRO")>=0)
 {
  if(!StartedIntro && PlayerReplicationInfo.PlayerName=="TeamHost" && Level.TimeSeconds-JoinedAt>15)
  {
   StartedIntro=true;
   NETCoopWaitContinue();
   ReportPresentation("intro-start-requested");
  }
  return;
 }
 R=CoopPLShellRootWindow(Player.InteractionMaster.BaseMenu);
 if(R!=None && R.bPLDayRendered && !ReportedCard)
 {
  ReportedCard=true;
  ReportPresentation("card-rendered|" $ R.PLDayName);
 }
 if(!TestedMap && Level.TimeSeconds-JoinedAt>5) CoopQuickUseMap(true);
 M=CoopPLMapInteraction(CoopMap);
 if(M==None) return;
 if(!TestedMap && Level.TimeSeconds-JoinedAt>5)
 {
  TestedMap=true;
  M.TryToEnableRenderBase();
 }
 if(TestedMap && !ReportedMap && Level.TimeSeconds-JoinedAt>8)
 {
  ReportedMap=true;
  ReportPresentation("zone|controller=" $ Region.Zone $ "|view=" $ ViewTarget.Region.Zone $ "|sounds=" $ ViewTarget.Region.Zone.GetPropertyText("ZoneSounds"));
  for(i=0;i<ViewTarget.Region.Zone.ZoneSounds.Length;i++)
   ReportPresentation("zone-native-id|" $ ViewTarget.Region.Zone.ZoneSounds[i].ID);
  foreach AllActors(class'Actor',A)
   if(A.AmbientSound!=None && (InStr(Caps(string(A.AmbientSound)),"WIND")>=0 || A.IsA('AmbientSound')))
    ReportPresentation("ambient|" $ A $ "|sound=" $ A.AmbientSound $ "|location=" $ A.Location $ "|volume=" $ A.SoundVolume $ "|radius=" $ A.SoundRadius $ "|camera=" $ Location);
  foreach DynamicActors(class'DayBlocker',Sky)
   if(Sky.StaticMesh==StaticMesh'PL_EnvMesh.sky.skydome_polar')
    ReportPresentation("sky|" $ Sky $ "|unlit=" $ Sky.bUnlit $ "|hidden=" $ Sky.bHidden);
  ReportPresentation("map-audio|day=" $ G.CurrentDay $ "|handle=" $ M.PLMapSong $ "|writing=" $ class'MapScreen'.default.WritingSounds.Length);
  M.MapReset();
 }
}
simulated function xClientPlayMusicExt(int SongHandle,string Song,float FadeInTime,optional float VolumeOverride,optional bool bAllowPause)
{
 Super.xClientPlayMusicExt(SongHandle,Song,FadeInTime,VolumeOverride,bAllowPause);
 ReportPresentation("scene-music|" $ Song $ "|handle=" $ SongInfos_ClientHandle[SongHandle]);
}
