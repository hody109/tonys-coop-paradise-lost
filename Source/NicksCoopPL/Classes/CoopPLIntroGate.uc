// Gate the PL intro's PlayerStart event until a real player is ready.
class CoopPLIntroGate extends Actor;
var bool bWaiting;
var bool bStarting;
function Trigger(Actor Other, Pawn EventInstigator)
{
    local CoopGameReplicationInfo G;
    if (bWaiting || bStarting) return;
    bWaiting = true;
    G = CoopGameReplicationInfo(Level.Game.GameReplicationInfo);
    if (G != None) { G.bCoopWaitPlayers=true; G.bCoopWaitContinue=true; }
    Log("PLINTRO|waiting-for-players");
}
function RequestStart()
{
    local CoopGameReplicationInfo G;
    if (!bWaiting || bStarting) return;
    bStarting=true;
    CoopPLGameInfo(Level.Game).LockPLIntro();
    G=CoopGameReplicationInfo(Level.Game.GameReplicationInfo);
    if(G!=None) G.bCoopWaitContinue=false;
    CoopGameInfo(Level.Game).xCoopServerEventMessage("Starting intro in 8 seconds");
    SetTimer(8,false);
}
function Timer()
{
    local P2Player Host;
    local CoopGameReplicationInfo G;
    Host=CoopGameInfo(Level.Game).GetPlayer();
    if(Host==None || Host.Pawn==None) { SetTimer(1,false);return; }
    G=CoopGameReplicationInfo(Level.Game.GameReplicationInfo);
    if(G!=None) { G.bCoopWaitPlayers=false; G.bCoopWaitContinue=false; }
    CoopPLGameInfo(Level.Game).bPLIntroPlaying=true;
    Log("PLINTRO|starting-cinematic");
    TriggerEvent('Intro1',self,Host.Pawn);
    Destroy();
}
defaultproperties
{
    bHidden=true
    RemoteRole=ROLE_None
}
