class PLCoopHostProbePlayer extends CoopPLPlayerClient;
var bool bRequested;
var bool bVoteSent;
var float JoinedAt;
var bool bLockLogged;
var float SkinLogAt;
simulated function AuditInput()
{
 local int i;
 local CoopPLConsole C;
 local CoopPLPostalDude D;
 if (Player == None || Player.InteractionMaster == None) return;
 for(i=0;i<Player.InteractionMaster.GlobalInteractions.Length;i++)
 {
  C=CoopPLConsole(Player.InteractionMaster.GlobalInteractions[i]);
  if(C!=None && C.IntroLocked() && !bLockLogged)
  {
   bLockLogged=true;
   Log("PLINPUT|locked=" $ C.IntroLocked()
       $ "|escape=" $ C.KeyEvent(IK_Escape,IST_Press,0)
       $ "|mouse=" $ C.KeyEvent(IK_LeftMouse,IST_Press,0)
       $ "|move=" $ C.KeyEvent(IK_W,IST_Press,0)
       $ "|console=" $ C.KeyEvent(IK_Tilde,IST_Press,0)
       $ "|typed=" $ C.KeyType(IK_W,"w"));
  }
  if(C!=None && Level.TimeSeconds>SkinLogAt)
   Log("PLINPUT|current-map=" $ Level $ "|locked=" $ C.IntroLocked());
 }
 if(Level.TimeSeconds>SkinLogAt)
 {
  SkinLogAt=Level.TimeSeconds+20;
  foreach AllActors(class'CoopPLPostalDude',D)
   if(D.PlayerReplicationInfo!=None)
    Log("PLSKIN|player=" $ D.PlayerReplicationInfo.PlayerName $ "|material=" $ D.Skins[0] $ "|hidden=" $ D.bHidden);
 }
}
simulated function PlayerTick(float DeltaTime)
{
 local int i;
 local CoopPLConsole C;
 Super.PlayerTick(DeltaTime);
 if (Role != ROLE_AutonomousProxy || PlayerReplicationInfo == None) return;
 AuditInput();
 if (JoinedAt == 0) JoinedAt=Level.TimeSeconds;
 if(!PLIntroInputLocked() && Level.TimeSeconds-JoinedAt>70) {ConsoleCommand("quit"); return;}
 if(!bVoteSent && PLIntroInputLocked() && ((PlayerReplicationInfo.PlayerName=="PLTestA" && Level.TimeSeconds-JoinedAt>14)
     || (PlayerReplicationInfo.PlayerName=="PLTestB" && Level.TimeSeconds-JoinedAt>20)))
 {
  bVoteSent=true;
  for(i=0;i<Player.InteractionMaster.GlobalInteractions.Length;i++)
  {
   C=CoopPLConsole(Player.InteractionMaster.GlobalInteractions[i]);
   if(C!=None) Log("PLINPUT|skip-enter=" $ C.KeyEvent(IK_Enter,IST_Press,0));
  }
 }

 if (!bRequested && ((PlayerReplicationInfo.PlayerName == "PLTestB" && Level.TimeSeconds-JoinedAt > 1)
     || (PlayerReplicationInfo.PlayerName == "PLTestA" && Level.TimeSeconds-JoinedAt > 3)))
 {
   bRequested=true;
   for(i=0;i<Player.InteractionMaster.GlobalInteractions.Length;i++)
   {
    C=CoopPLConsole(Player.InteractionMaster.GlobalInteractions[i]);
    if(C!=None) Log("PLINPUT|enter=" $ C.KeyEvent(IK_Enter,IST_Press,0));
   }
 }
}


