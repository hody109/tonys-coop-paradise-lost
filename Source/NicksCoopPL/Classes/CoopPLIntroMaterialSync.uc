// Replicate the comic panel index; MaterialSwitch is a shared asset, not an actor.
class CoopPLIntroMaterialSync extends Actor;
var int PanelIndex;
var MaterialSwitch IntroSurface;
var int LastLoggedPanel;
replication { reliable if(Role==ROLE_Authority) PanelIndex; }
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    IntroSurface=MaterialSwitch(DynamicLoadObject("PL-IntroTex.1.IntroSwitch",class'MaterialSwitch'));
    if(IntroSurface!=None) IntroSurface.SetCurrent(0);
    LastLoggedPanel=-1;
}
simulated function Tick(float DeltaTime)
{
    if(IntroSurface==None) return;
    if(Role==ROLE_Authority) PanelIndex=IntroSurface.Current;
    else if(IntroSurface.Current!=PanelIndex) IntroSurface.SetCurrent(PanelIndex);
    if(LastLoggedPanel!=PanelIndex) {
        Log("PLINTRO|panel=" $ PanelIndex $ "|role=" $ Role);
        LastLoggedPanel=PanelIndex;
    }
}
defaultproperties
{
    bHidden=True
    bAlwaysRelevant=True
    RemoteRole=ROLE_SimulatedProxy
    NetUpdateFrequency=20
}
